"""Pinned Gitleaks installer and Git guards (Python 3.10+, standard library only)."""
import argparse
import hashlib
import io
import os
from pathlib import Path, PurePosixPath
import platform
import shutil
import subprocess
import sys
import tarfile
import tempfile
import urllib.request
import zipfile

ROOT = Path(__file__).resolve().parents[1]
VERSION = "8.30.1"
ZERO = "0" * 40


def git(*args):
    return subprocess.check_output(["git", *args], cwd=ROOT)


def install():
    system = {"Windows": "windows", "Linux": "linux", "Darwin": "darwin"}[platform.system()]
    arch = {"amd64": "x64", "x86_64": "x64", "arm64": "arm64", "aarch64": "arm64"}[platform.machine().lower()]
    extension = "zip" if system == "windows" else "tar.gz"
    name = f"gitleaks_{VERSION}_{system}_{arch}.{extension}"
    base = f"https://github.com/gitleaks/gitleaks/releases/download/v{VERSION}/"
    with urllib.request.urlopen(base + name, timeout=60) as response:
        archive = response.read()
    with urllib.request.urlopen(base + f"gitleaks_{VERSION}_checksums.txt", timeout=30) as response:
        checksums = response.read().decode()
    expected = next(line.split()[0] for line in checksums.splitlines() if line.split()[-1] == name)
    if hashlib.sha256(archive).hexdigest() != expected:
        raise RuntimeError("Gitleaks checksum mismatch")
    executable = "gitleaks.exe" if system == "windows" else "gitleaks"
    target = ROOT / ".tools" / "gitleaks" / VERSION / executable
    target.parent.mkdir(parents=True, exist_ok=True)
    if extension == "zip":
        with zipfile.ZipFile(io.BytesIO(archive)) as bundle:
            content = bundle.read(executable)
    else:
        with tarfile.open(fileobj=io.BytesIO(archive), mode="r:gz") as bundle:
            content = bundle.extractfile(executable).read()
    target.write_bytes(content)
    target.chmod(0o755)
    print(f"Installed checksum-verified Gitleaks {VERSION}.")
    return target


def scanner():
    name = "gitleaks.exe" if os.name == "nt" else "gitleaks"
    binary = ROOT / ".tools" / "gitleaks" / VERSION / name
    if not binary.is_file():
        raise RuntimeError("Run 'python scripts/security.py setup' first.")
    return str(binary)


def forbidden(path):
    p = PurePosixPath(path.lower())
    name = p.name
    if name.endswith(".example"):
        return False
    return (
        name == ".env" or name.startswith(".env.")
        or name in {"google-services.json", "googleservice-info.plist", "firebase-sa.json", "credentials.json", "key.properties"}
        or (name.endswith(".json") and any(part in name for part in ("service-account", "serviceaccount")))
        or (name.startswith("application-local.") and p.suffix in {".yml", ".yaml", ".properties"})
        or p.suffix in {".pem", ".key", ".p12", ".pfx", ".jks", ".keystore"}
    )


def paths_for(ref):
    raw = git("ls-files", "-z") if ref == "working" else (
        git("ls-files", "--cached", "-z") if ref == "staged" else
        git("ls-tree", "-r", "--name-only", "-z", ref)
    )
    return [p.decode("utf-8") for p in raw.split(b"\0") if p]


def run_scan(*args):
    subprocess.run([
        scanner(), *args, "--config", str(ROOT / ".gitleaks.toml"),
        "--redact=100", "--no-banner", "--no-color", "--ignore-gitleaks-allow",
    ], cwd=ROOT, check=True)


def export_git_content(ref, destination):
    if ref == "staged":
        rows = git("ls-files", "--stage", "-z").split(b"\0")
    else:
        rows = git("ls-tree", "-r", "--full-tree", "-z", ref).split(b"\0")
    entries = []
    for row in rows:
        if not row:
            continue
        metadata, path = row.split(b"\t", 1)
        if ref == "staged":
            mode, object_id, stage = metadata.split()
            if stage != b"0":
                raise RuntimeError("Resolve staged merge conflicts before scanning")
        else:
            mode, kind, object_id = metadata.split()
        if mode == b"160000":
            continue  # Submodules have their own repositories and guards.
        entries.append((path.decode("utf-8"), object_id))
    # Read raw blobs in one process: checkout filters/CRLF conversion and
    # export-ignore attributes must not alter what the guard inspects.
    result = subprocess.run(["git", "cat-file", "--batch"], cwd=ROOT,
                            input=b"".join(oid + b"\n" for _, oid in entries),
                            capture_output=True, check=True)
    content = io.BytesIO(result.stdout)
    for path, _ in entries:
        header = content.readline().split()
        if len(header) != 3 or header[1] != b"blob":
            raise RuntimeError("Cannot read Git blob for " + path)
        target = destination / path
        if not target.resolve().is_relative_to(destination):
            raise RuntimeError("Unsafe Git path")
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_bytes(content.read(int(header[2])))
        if content.read(1) != b"\n":
            raise RuntimeError("Invalid Git object stream")


def snapshot(ref="working"):
    paths = paths_for(ref)
    blocked = [p for p in paths if forbidden(p)]
    if blocked:
        raise RuntimeError("Credential files must be untracked:\n" + "\n".join(blocked))
    # Export only tracked content; ignored local .env/keys never enter the scan.
    with tempfile.TemporaryDirectory(prefix="flobank-scan-") as directory:
        destination = Path(directory)
        if ref == "working":
            for path in paths:
                source = ROOT / path
                if not source.is_file() or source.is_symlink():
                    continue
                target = destination / path
                target.parent.mkdir(parents=True, exist_ok=True)
                shutil.copyfile(source, target)
        else:
            export_git_content(ref, destination)
        run_scan("dir", str(destination))


def commit_range(tip, base):
    revisions = [tip] + (["^" + base] if base else [])
    commits = git("rev-list", *revisions).decode().splitlines()
    if not commits:
        return
    # Check names in every new commit too: add-then-delete credentials must fail.
    for commit in commits:
        blocked = [p for p in paths_for(commit) if forbidden(p)]
        if blocked:
            raise RuntimeError(f"Credential files in commit {commit[:12]}:\n" + "\n".join(blocked))
    run_scan("git", str(ROOT), "--log-opts=" + " ".join(revisions))


def pre_push():
    for line in sys.stdin:
        local_ref, local_sha, remote_ref, remote_sha = line.split()
        if local_sha == ZERO:
            continue
        snapshot(local_sha)
        if remote_sha == ZERO:
            # Existing legacy history is audited separately. New branches check
            # every commit not already reachable from the remote default branch.
            remote_sha = git("rev-parse", "--verify", "refs/remotes/origin/main").decode().strip()
        commit_range(local_sha, remote_sha)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("command", choices=["setup", "check", "staged", "pre-push", "history", "range"])
    parser.add_argument("--base")
    parser.add_argument("--head", default="HEAD")
    args = parser.parse_args()
    if args.command == "setup":
        install()
        old = subprocess.run(["git", "config", "--local", "--get", "core.hooksPath"], cwd=ROOT, capture_output=True, text=True).stdout.strip()
        if old and old != ".githooks":
            raise RuntimeError(f"Existing hooksPath '{old}'; integrate hooks before replacing it.")
        for key, value in [("core.hooksPath", ".githooks"), ("push.default", "simple"), ("push.autoSetupRemote", "true"), ("pull.ff", "only"), ("fetch.prune", "true")]:
            subprocess.run(["git", "config", "--local", key, value], cwd=ROOT, check=True)
        print("Repository-local commit/push guards and push defaults configured.")
    elif args.command == "check":
        snapshot()
    elif args.command == "staged":
        snapshot("staged")
    elif args.command == "pre-push":
        pre_push()
    elif args.command == "history":
        run_scan("git", str(ROOT), "--log-opts=--all")
    else:
        snapshot(args.head)
        commit_range(args.head, args.base)


if __name__ == "__main__":
    try:
        main()
    except (RuntimeError, subprocess.CalledProcessError, OSError, KeyError) as error:
        print(f"Security check failed: {error}", file=sys.stderr)
        sys.exit(1)
