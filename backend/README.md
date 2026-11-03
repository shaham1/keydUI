# keyd-backend

Plain Python backend service for keydUI, managed via `uv`.

## Usage
- Read current profile:
  `uv run python -m keyd_manager get-profile`
- Verify sudo password:
  `uv run python -m keyd_manager verify-auth`
- Check keyd status:
  `uv run python -m keyd_manager get-status`
- Save profile:
  `uv run python -m keyd_manager save-profile`

