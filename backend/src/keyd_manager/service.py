import os
import subprocess
from typing import Optional, Dict, Any, List
from .models import KeydProfile, CommandResult
from .parser import KeydParser
from .sudo_runner import SudoRunner
from .validator import ConfigValidator


class KeydService:
    DEFAULT_CONFIG_PATH = "/etc/keyd/default.conf"
    BACKUP_CONFIG_PATH = "/etc/keyd/.default.conf.bak"

    def __init__(self, config_path: str = DEFAULT_CONFIG_PATH):
        self.config_path = config_path

    def get_profile(self, sudo_password: Optional[str] = None) -> CommandResult:
        """
        Reads the ground-truth configuration directly from disk, computes
        the content SHA-256 hash, and parses into a structured JSON payload.
        """
        content = ""
        try:
            if os.path.exists(self.config_path):
                with open(self.config_path, "r", encoding="utf-8") as f:
                    content = f.read()
            else:
                return CommandResult(
                    success=False,
                    command="get-profile",
                    error=f"Config file not found at {self.config_path}",
                    code="FILE_NOT_FOUND",
                )
        except PermissionError:
            # Fall back to privileged read if file or directory has restricted permissions
            if sudo_password:
                rc, stdout, stderr = SudoRunner.run_sudo(
                    ["cat", self.config_path],
                    password=sudo_password,
                )
                if rc == 0:
                    content = stdout
                else:
                    return CommandResult(
                        success=False,
                        command="get-profile",
                        error=f"Permission denied reading {self.config_path}. Sudo read failed: {stderr}",
                        code="PERMISSION_DENIED",
                    )
            else:
                return CommandResult(
                    success=False,
                    command="get-profile",
                    error=f"Permission denied reading {self.config_path}. Password required.",
                    code="PERMISSION_DENIED",
                )
        except Exception as e:
            return CommandResult(
                success=False,
                command="get-profile",
                error=f"Failed to read config file: {e}",
                code="READ_ERROR",
            )

        profile = KeydParser.parse(content)
        return CommandResult(
            success=True,
            command="get-profile",
            hash=profile.content_hash,
            data=profile.to_dict(),
        )

    def save_profile(
        self,
        new_conf_content: str,
        sudo_password: str,
        base_hash: Optional[str] = None,
        force: bool = False,
    ) -> CommandResult:
        """
        Saves new configuration to disk and reloads keyd daemon.
        Follows a strict safety workflow:
        1. Concurrency check (SHA-256 dispute detection)
        2. Pre-flight validation
        3. Automated backup
        4. Privileged atomic write
        5. Daemon reload with auto-rollback on failure
        """
        # Step 1: Concurrency check against current ground truth on disk
        if base_hash and not force and os.path.exists(self.config_path):
            try:
                with open(self.config_path, "r", encoding="utf-8") as f:
                    current_content = f.read()
                current_hash = KeydParser.calculate_hash(current_content)
                if current_hash != base_hash:
                    return CommandResult(
                        success=False,
                        command="save-profile",
                        error=(
                            "The configuration file on disk has been modified externally since it was loaded. "
                            "Please reload to view the current system profile and prevent overwriting."
                        ),
                        code="CONFLICT_DETECTED",
                    )
            except Exception:
                pass

        # Step 2: Pre-flight syntax validation
        validation = ConfigValidator.validate_content(new_conf_content)
        # Note: If keyd check reports warnings only, we can proceed, but if invalid syntax we halt
        if not validation.is_valid and validation.error_message and "ERROR:" in validation.error_message:
            return CommandResult(
                success=False,
                command="save-profile",
                error=f"Configuration validation failed:\n{validation.error_message}",
                code="VALIDATION_FAILED",
            )

        # Step 3: Create backup of current configuration
        if os.path.exists(self.config_path):
            backup_rc, _, _ = SudoRunner.run_sudo(
                ["cp", self.config_path, self.BACKUP_CONFIG_PATH],
                password=sudo_password,
            )
            # Backup creation failure shouldn't silently proceed without root privileges
            if backup_rc != 0:
                return CommandResult(
                    success=False,
                    command="save-profile",
                    error="Failed to create backup. Sudo authorization may have failed.",
                    code="BACKUP_FAILED",
                )

        # Step 4: Write new content to config file
        write_success, write_err = SudoRunner.write_file(
            file_path=self.config_path,
            content=new_conf_content,
            password=sudo_password,
        )
        if not write_success:
            return CommandResult(
                success=False,
                command="save-profile",
                error=f"Failed to write config file: {write_err}",
                code="WRITE_FAILED",
            )

        # Step 5: Trigger daemon reload
        reload_rc, reload_out, reload_err = SudoRunner.run_sudo(
            ["keyd", "reload"],
            password=sudo_password,
        )

        if reload_rc != 0:
            # Automatic Rollback to backup file
            if os.path.exists(self.BACKUP_CONFIG_PATH):
                SudoRunner.run_sudo(
                    ["cp", self.BACKUP_CONFIG_PATH, self.config_path],
                    password=sudo_password,
                )
                SudoRunner.run_sudo(["keyd", "reload"], password=sudo_password)

            return CommandResult(
                success=False,
                command="save-profile",
                error=f"Failed to reload keyd daemon (Restored previous backup):\n{reload_err or reload_out}",
                code="RELOAD_FAILED",
            )

        new_hash = KeydParser.calculate_hash(new_conf_content)
        return CommandResult(
            success=True,
            command="save-profile",
            hash=new_hash,
            data={"message": "Configuration successfully applied and keyd reloaded."},
        )

    def verify_auth(self, sudo_password: str) -> CommandResult:
        """Verifies sudo elevation password."""
        is_valid = SudoRunner.verify_password(sudo_password)
        if is_valid:
            return CommandResult(
                success=True,
                command="verify-auth",
                data={"verified": True},
            )
        return CommandResult(
            success=False,
            command="verify-auth",
            error="Incorrect sudo password or user not in sudoers.",
            code="AUTH_FAILED",
        )

    def get_status(self) -> CommandResult:
        """Checks if keyd daemon service is active."""
        # Check systemctl
        try:
            res = subprocess.run(
                ["systemctl", "is-active", "keyd"],
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True,
                timeout=3.0,
            )
            is_active = res.stdout.strip() == "active"
            return CommandResult(
                success=True,
                command="get-status",
                data={
                    "service_active": is_active,
                    "service_status": res.stdout.strip(),
                    "config_path": self.config_path,
                },
            )
        except Exception as e:
            # Fall back to pgrep
            try:
                pg_res = subprocess.run(
                    ["pgrep", "-x", "keyd"],
                    stdout=subprocess.PIPE,
                    stderr=subprocess.PIPE,
                )
                return CommandResult(
                    success=True,
                    command="get-status",
                    data={
                        "service_active": pg_res.returncode == 0,
                        "service_status": "running" if pg_res.returncode == 0 else "inactive",
                        "config_path": self.config_path,
                    },
                )
            except Exception as ex:
                return CommandResult(
                    success=False,
                    command="get-status",
                    error=f"Could not check keyd daemon status: {ex}",
                )

    def list_keys(self) -> CommandResult:
        """Retrieves list of valid key identifiers recognized by keyd."""
        try:
            res = subprocess.run(
                ["keyd", "list-keys"],
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True,
                timeout=3.0,
            )
            if res.returncode == 0:
                keys = [k.strip() for k in res.stdout.splitlines() if k.strip()]
                return CommandResult(
                    success=True,
                    command="list-keys",
                    data={"keys": keys},
                )
        except Exception as e:
            pass

        return CommandResult(
            success=False,
            command="list-keys",
            error="Failed to execute `keyd list-keys`",
        )

