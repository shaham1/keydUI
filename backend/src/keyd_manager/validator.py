import subprocess
import tempfile
import os
from typing import Optional
from .models import ValidationResult


class ConfigValidator:
    @classmethod
    def validate_content(cls, content: str) -> ValidationResult:
        """
        Validates keyd configuration syntax by writing to a temporary file
        and running `keyd check <temp_file>`.
        """
        temp_file = tempfile.NamedTemporaryFile(
            mode="w",
            suffix=".conf",
            delete=False,
            encoding="utf-8",
        )
        try:
            temp_file.write(content)
            temp_file.flush()
            temp_file.close()

            # Execute keyd check
            result = subprocess.run(
                ["keyd", "check", temp_file.name],
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True,
                timeout=5.0,
            )

            output = (result.stdout + "\n" + result.stderr).strip()

            # Check if there are critical errors
            # Note: keyd check outputs "WARNING:" or "ERROR:"
            if result.returncode != 0:
                # Filter out minor warnings or return details
                lines = [line.strip() for line in output.splitlines() if line.strip()]
                return ValidationResult(
                    is_valid=False,
                    error_message="\n".join(lines),
                )

            return ValidationResult(is_valid=True)
        except subprocess.TimeoutExpired:
            return ValidationResult(
                is_valid=False,
                error_message="Validation timed out running `keyd check`.",
            )
        except Exception as e:
            # If `keyd` binary is not in PATH during test, fall back to basic syntax check
            return cls._basic_syntax_check(content)
        finally:
            try:
                os.remove(temp_file.name)
            except OSError:
                pass

    @classmethod
    def _basic_syntax_check(cls, content: str) -> ValidationResult:
        """Fallback check if `keyd check` binary is unavailable."""
        current_section = ""
        for idx, raw_line in enumerate(content.splitlines(), start=1):
            line = raw_line.strip()
            if not line or line.startswith("#"):
                continue

            if line.startswith("[") and line.endswith("]"):
                current_section = line[1:-1].strip()
                continue

            if not current_section:
                return ValidationResult(
                    is_valid=False,
                    error_message=f"Line {idx}: directive outside of any section: '{line}'",
                    error_line=idx,
                )

            if current_section != "ids" and "=" not in line:
                return ValidationResult(
                    is_valid=False,
                    error_message=f"Line {idx}: missing '=' in mapping: '{line}'",
                    error_line=idx,
                )

        return ValidationResult(is_valid=True)

