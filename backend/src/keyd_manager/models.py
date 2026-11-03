from dataclasses import dataclass, field
from typing import Dict, List, Optional, Any


@dataclass
class KeydProfile:
    ids: List[str] = field(default_factory=lambda: ["*"])
    layers: Dict[str, Dict[str, str]] = field(default_factory=dict)
    content_hash: str = ""
    raw_header_lines: List[str] = field(default_factory=list)

    def to_dict(self) -> Dict[str, Any]:
        return {
            "ids": self.ids,
            "layers": self.layers,
            "content_hash": self.content_hash,
        }


@dataclass
class ValidationResult:
    is_valid: bool
    error_message: Optional[str] = None
    error_line: Optional[int] = None


@dataclass
class CommandResult:
    success: bool
    command: str
    data: Optional[Any] = None
    error: Optional[str] = None
    code: Optional[str] = None
    hash: Optional[str] = None

    def to_dict(self) -> Dict[str, Any]:
        result: Dict[str, Any] = {
            "success": self.success,
            "command": self.command,
        }
        if self.hash is not None:
            result["hash"] = self.hash
        if self.data is not None:
            result["data"] = self.data
        if self.error is not None:
            result["error"] = self.error
        if self.code is not None:
            result["code"] = self.code
        return result

