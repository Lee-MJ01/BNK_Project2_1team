"""Write a Compose env_file from runner environment; never print credential values."""
import os
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]
OPTIONAL = {"REDIS_PASSWORD", "AI_SERVER_RECO_URL", "FIREBASE_SERVICE_ACCOUNT_PATH"}
FIXED = {"TERMS_BASE_DIR": "/app/uploads/terms"}


def compose_value(value):
    if any(char in value for char in "\r\n\0"):
        raise ValueError("Multiline environment values are not supported")
    # Single quotes preserve $, spaces, # and backslashes literally in Compose.
    if "'" in value:
        raise ValueError("Apostrophes are not supported in deployment environment values")
    return "'" + value + "'"


def write_env(destination, environment):
    names = [line.split("=", 1)[0] for line in (ROOT / "backend/.env.example").read_text().splitlines()
             if line and not line.startswith("#")]
    values = {}
    missing = []
    for name in names:
        value = FIXED.get(name, environment.get(name, ""))
        if not value and name not in OPTIONAL:
            missing.append(name)
        values[name] = value
    if missing:
        raise ValueError("Missing GitHub Secrets: " + ", ".join(missing))
    values["AI_SERVER_RECO_URL"] = values["AI_SERVER_RECO_URL"] or values["AI_SERVER_URL"]
    content = "\n".join(f"{name}={compose_value(value)}" for name, value in values.items()) + "\n"
    destination = Path(destination)
    destination.parent.mkdir(parents=True, exist_ok=True)
    descriptor = os.open(destination, os.O_WRONLY | os.O_CREAT | os.O_TRUNC, 0o600)
    with os.fdopen(descriptor, "w", encoding="utf-8", newline="\n") as output:
        output.write(content)
    destination.chmod(0o600)
    print("Deployment environment validated and written (values hidden).")


if __name__ == "__main__":
    try:
        write_env(sys.argv[1], os.environ)
    except (ValueError, OSError) as error:
        print(str(error), file=sys.stderr)
        sys.exit(1)
