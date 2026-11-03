import hashlib
from typing import List, Dict
from .models import KeydProfile


class KeydParser:
    @staticmethod
    def calculate_hash(content: str) -> str:
        """Returns the SHA-256 hex digest of the raw content string."""
        return hashlib.sha256(content.encode("utf-8")).hexdigest()

    @classmethod
    def parse(cls, content: str) -> KeydProfile:
        """
        Parses keyd configuration content into a structured KeydProfile.
        Handles keyd specific syntax, symbols (*, ,, \\, ;), and macros.
        """
        content_hash = cls.calculate_hash(content)
        ids: List[str] = []
        layers: Dict[str, Dict[str, str]] = {}
        raw_header_lines: List[str] = []

        current_section = ""
        lines = content.splitlines()

        for line in lines:
            stripped = line.strip()

            # Preserve comments / empty lines in header if before first section
            if not current_section and (not stripped or stripped.startswith("#")):
                raw_header_lines.append(line)
                continue

            # Skip comments and empty lines inside sections
            if not stripped or stripped.startswith("#"):
                continue

            # Section header: [ids], [main], [nums], etc.
            if stripped.startswith("[") and stripped.endswith("]"):
                current_section = stripped[1:-1].strip()
                if current_section != "ids" and current_section not in layers:
                    layers[current_section] = {}
                continue

            if current_section == "ids":
                ids.append(stripped)
            elif current_section:
                # Key-value assignment
                separator_index = stripped.find("=")
                if separator_index != -1:
                    key = stripped[:separator_index].strip()
                    val = stripped[separator_index + 1:].strip()
                    if current_section not in layers:
                        layers[current_section] = {}
                    layers[current_section][key] = val

        if not ids:
            ids = ["*"]
        if "main" not in layers:
            layers["main"] = {}

        return KeydProfile(
            ids=ids,
            layers=layers,
            content_hash=content_hash,
            raw_header_lines=raw_header_lines,
        )

    @classmethod
    def serialize(cls, profile: KeydProfile) -> str:
        """
        Serializes KeydProfile back into standard keyd .conf syntax.
        """
        out: List[str] = []

        # Write any preserved headers / comments
        for header_line in profile.raw_header_lines:
            out.append(header_line)

        # Write [ids] section
        out.append("[ids]")
        for device_id in profile.ids:
            out.append(device_id)
        out.append("")

        # Write [main] layer first if it exists
        layers_order = ["main"] + [layer for layer in profile.layers if layer != "main"]

        for layer_name in layers_order:
            if layer_name not in profile.layers:
                continue
            mappings = profile.layers[layer_name]
            out.append(f"[{layer_name}]")
            for key, val in mappings.items():
                out.append(f"{key} = {val}")
            out.append("")

        return "\n".join(out).strip() + "\n"

