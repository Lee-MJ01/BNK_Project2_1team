import contextlib
import io
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import unittest
from unittest.mock import patch

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
import security
import write_deploy_env


class DeploymentEnvironmentTest(unittest.TestCase):
    def environment(self):
        template = (write_deploy_env.ROOT / "backend/.env.example").read_text()
        return {line.split("=", 1)[0]: "fixture-value" for line in template.splitlines()
                if line and not line.startswith("#")}

    def test_special_characters_are_literal_and_values_are_never_logged(self):
        environment = self.environment()
        environment["DB_PASSWORD"] = 'fixture $HOME # back\\slash "quotes"'
        environment["AI_SERVER_RECO_URL"] = ""
        output = io.StringIO()
        with tempfile.TemporaryDirectory() as directory, contextlib.redirect_stdout(output):
            destination = Path(directory) / ".env"
            write_deploy_env.write_env(destination, environment)
            content = destination.read_text()
            self.assertIn("DB_PASSWORD='" + environment["DB_PASSWORD"] + "'", content)
            self.assertIn("TERMS_BASE_DIR='/app/uploads/terms'", content)
            self.assertIn("AI_SERVER_RECO_URL='fixture-value'", content)
            self.assertNotIn(environment["DB_PASSWORD"], output.getvalue())
            if os.name != "nt":
                self.assertEqual(destination.stat().st_mode & 0o777, 0o600)

    def test_missing_credentials_fail_before_writing(self):
        with tempfile.TemporaryDirectory() as directory:
            destination = Path(directory) / ".env"
            with self.assertRaisesRegex(ValueError, "SLAVE_DB_PASSWORD"):
                write_deploy_env.write_env(destination, {})
            self.assertFalse(destination.exists())

    def test_line_injection_and_ambiguous_quotes_are_rejected(self):
        for value in ["value\nINJECTED=yes", "value\rINJECTED=yes", "value\0", "value'quoted"]:
            with self.assertRaises(ValueError):
                write_deploy_env.compose_value(value)


class SecretGuardTest(unittest.TestCase):
    def test_sensitive_filenames_and_templates(self):
        for name in ["backend/.env", "a/.env.production", "android/google-services.json",
                     "keys/firebase-sa.json", "a/serviceAccount.json", "a/private.pem", "application-local.yml"]:
            self.assertTrue(security.forbidden(name), name)
        for name in ["backend/.env.example", "google-services.json.example", "backend/application.yml"]:
            self.assertFalse(security.forbidden(name), name)

    def test_real_scanner_blocks_staged_secret_and_checks_intermediate_commits(self):
        scanner = security.scanner()
        config = security.ROOT / ".gitleaks.toml"
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            def git(*args):
                return subprocess.check_output(["git", *args], cwd=root, stderr=subprocess.DEVNULL).decode().strip()
            git("init")
            git("config", "user.name", "Guard Test")
            git("config", "user.email", "guard@example.invalid")
            git("config", "core.hooksPath", str(root / "no-hooks"))
            shutil.copyfile(config, root / ".gitleaks.toml")
            (root / "safe.txt").write_text("safe")
            git("add", ".")
            git("commit", "-m", "base")
            base = git("rev-parse", "HEAD")
            # Build the fixture at runtime so this test source is itself clean.
            literal = 'dataSource.set' + 'Password("fixture-password");'
            (root / "Database.java").write_text(literal)
            git("add", ".")
            # Scanner must inspect index content even if working file is clean.
            (root / "Database.java").write_text("// safe working copy")
            with patch.object(security, "ROOT", root), patch.object(security, "scanner", return_value=scanner):
                with self.assertRaises(subprocess.CalledProcessError):
                    security.snapshot("staged")
                git("commit", "-m", "unsafe intermediate commit")
                git("add", ".")
                git("commit", "-m", "remove secret")
                security.snapshot("HEAD")
                with self.assertRaises(subprocess.CalledProcessError):
                    security.commit_range("HEAD", base)


if __name__ == "__main__":
    unittest.main()
