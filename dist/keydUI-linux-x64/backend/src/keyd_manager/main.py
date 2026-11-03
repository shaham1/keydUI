import argparse
import json
import sys

from .models import CommandResult
from .service import KeydService


def main() -> None:
    parser = argparse.ArgumentParser(
        description="keyd_manager: Backend CLI service for keydUI"
    )
    parser.add_argument(
        "action",
        choices=["get-profile", "save-profile", "verify-auth", "get-status", "list-keys"],
        help="Action to execute",
    )
    parser.add_argument(
        "--config",
        default=KeydService.DEFAULT_CONFIG_PATH,
        help="Path to keyd configuration file",
    )
    parser.add_argument(
        "--base-hash",
        default=None,
        help="Base content hash for conflict detection",
    )
    parser.add_argument(
        "--force",
        action="store_true",
        help="Force overwrite ignoring conflict detection",
    )

    args = parser.parse_args()
    service = KeydService(config_path=args.config)

    try:
        if args.action == "get-profile":
            result = service.get_profile()

        elif args.action == "verify-auth":
            # Read password from stdin
            input_text = sys.stdin.read().strip()
            # Support either raw password or JSON object {"password": "..."}
            password = input_text
            try:
                data = json.loads(input_text)
                if isinstance(data, dict) and "password" in data:
                    password = data["password"]
            except Exception:
                pass

            result = service.verify_auth(password)

        elif args.action == "save-profile":
            input_text = sys.stdin.read().strip()
            data = json.loads(input_text)
            password = data.get("sudo_password", "")
            new_config = data.get("config", "")
            base_hash = data.get("base_hash") or args.base_hash

            result = service.save_profile(
                new_conf_content=new_config,
                sudo_password=password,
                base_hash=base_hash,
                force=args.force,
            )

        elif args.action == "get-status":
            result = service.get_status()

        elif args.action == "list-keys":
            result = service.list_keys()

        else:
            result = CommandResult(
                success=False,
                command=args.action,
                error=f"Unknown action: {args.action}",
            )

        # Output pure JSON to stdout
        sys.stdout.write(json.dumps(result.to_dict(), indent=2) + "\n")
        sys.stdout.flush()

        sys.exit(0 if result.success else 1)

    except Exception as e:
        sys.stderr.write(f"Unexpected backend exception: {e}\n")
        error_result = {
            "success": False,
            "command": args.action,
            "error": str(e),
            "code": "INTERNAL_EXCEPTION",
        }
        sys.stdout.write(json.dumps(error_result, indent=2) + "\n")
        sys.stdout.flush()
        sys.exit(1)


if __name__ == "__main__":
    main()

