import os
import subprocess
import tempfile
from typing import Tuple, Optional, List


class SudoRunner:
    DEFAULT_TIMEOUT = 6.0

    @classmethod
    def verify_password(cls, password: str, timeout: float = DEFAULT_TIMEOUT) -> bool:
        """
        Verifies sudo password using `sudo -k -S true`.
        Returns True if password is valid, False otherwise.
        """
        if not password:
            return False

        process: Optional[subprocess.Popen[str]] = None
        try:
            process = subprocess.Popen(
                ["sudo", "-k", "-S", "true"],
                stdin=subprocess.PIPE,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True,
            )
            process.communicate(input=f"{password}\n", timeout=timeout)
            return process.returncode == 0
        except subprocess.TimeoutExpired:
            if process:
                process.kill()
                process.communicate()
            return False
        except OSError:
            return False

    @classmethod
    def run_sudo(
        cls,
        args: List[str],
        password: str,
        input_data: Optional[str] = None,
        timeout: float = DEFAULT_TIMEOUT,
    ) -> Tuple[int, str, str]:
        """
        Executes a command with sudo, piping the password into standard input.
        Never uses shell=True.
        """
        cmd = ["sudo", "-S"] + args
        process: Optional[subprocess.Popen[str]] = None
        try:
            process = subprocess.Popen(
                cmd,
                stdin=subprocess.PIPE,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True,
            )

            # Sudo takes the password on the first line of stdin
            full_input = f"{password}\n"
            if input_data:
                full_input += input_data

            stdout, stderr = process.communicate(input=full_input, timeout=timeout)
            return process.returncode, stdout, stderr
        except subprocess.TimeoutExpired:
            if process:
                process.kill()
                process.communicate()
            return -1, "", "Command timed out waiting for execution or sudo authorization."
        except Exception as e:
            return -1, "", f"Failed to execute command: {e}"

    @classmethod
    def write_file(
        cls,
        file_path: str,
        content: str,
        password: str,
        timeout: float = DEFAULT_TIMEOUT,
    ) -> Tuple[bool, str]:
        """
        Safely writes content to a privileged destination by staging in /tmp
        and copying via sudo. This eliminates any stdin conflict with sudo's password prompt.
        """
        temp = tempfile.NamedTemporaryFile(
            mode="w",
            suffix=".conf",
            delete=False,
            encoding="utf-8",
        )
        try:
            temp.write(content)
            temp.flush()
            temp.close()

            # Copy staged file to privileged destination using sudo
            returncode, _, stderr = cls.run_sudo(
                ["cp", temp.name, file_path],
                password=password,
                timeout=timeout,
            )

            if returncode == 0:
                return True, ""
            return False, stderr or "Failed to write file."
        finally:
            try:
                os.remove(temp.name)
            except OSError:
                pass
