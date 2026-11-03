#!/usr/bin/env bash
set -e

# ==============================================================================
# keydUI Linux Installer for Zorin OS / Ubuntu / Debian
# Installs keydUI into ~/.local/share/keydui and creates a desktop app launcher
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="$HOME/.local/share/keydui"
DESKTOP_DIR="$HOME/.local/share/applications"
ICON_DIR="$HOME/.local/share/icons/hicolor/512x512/apps"

echo "==> Preparing keydUI for Linux..."
cd "$SCRIPT_DIR/frontend"

BUNDLE_DIR="$SCRIPT_DIR/frontend/build/linux/x64/release/bundle"

# If bundle doesn't exist or --build flag is provided, trigger flutter build
if [ ! -f "$BUNDLE_DIR/keydui" ] || [ "$1" == "--build" ] || [ "$1" == "--rebuild" ]; then
    echo "==> Building keydUI release binary..."
    if command -v flutter >/dev/null 2>&1; then
        flutter build linux --release
    elif [ -f "$HOME/development/flutter/bin/flutter" ]; then
        "$HOME/development/flutter/bin/flutter" build linux --release
    elif [ -f "$SCRIPT_DIR/.bin/flutter" ]; then
        "$SCRIPT_DIR/.bin/flutter" build linux --release
    else
        echo "Error: Flutter executable not found in PATH or standard locations."
        exit 1
    fi
else
    echo "==> Found existing release binary in bundle."
fi

if [ ! -d "$BUNDLE_DIR" ]; then
    echo "Error: Release bundle directory not found at $BUNDLE_DIR."
    exit 1
fi

echo "==> Packaging backend services..."
cp -r "$SCRIPT_DIR/backend" "$BUNDLE_DIR/"
rm -rf "$BUNDLE_DIR/backend/.venv"
find "$BUNDLE_DIR/backend" -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
cp "$SCRIPT_DIR/frontend/web/icons/Icon-512.png" "$BUNDLE_DIR/icon.png"

echo "==> Installing keydUI to $INSTALL_DIR..."
mkdir -p "$INSTALL_DIR"
rm -rf "${INSTALL_DIR:?}"/*
cp -r "$BUNDLE_DIR"/* "$INSTALL_DIR/"

# Ensure executable permissions
chmod +x "$INSTALL_DIR/keydui"
chmod +x "$INSTALL_DIR/backend/run.py"

echo "==> Installing Desktop Launcher and Icon..."
mkdir -p "$DESKTOP_DIR"
mkdir -p "$ICON_DIR"
mkdir -p "$HOME/.local/share/icons"
mkdir -p "$HOME/.local/share/pixmaps"

# Install icons to all standard XDG lookup locations
cp "$INSTALL_DIR/icon.png" "$ICON_DIR/keydui.png"
cp "$INSTALL_DIR/icon.png" "$ICON_DIR/com.keydui.app.png"
cp "$INSTALL_DIR/icon.png" "$HOME/.local/share/icons/keydui.png"
cp "$INSTALL_DIR/icon.png" "$HOME/.local/share/icons/com.keydui.app.png"
cp "$INSTALL_DIR/icon.png" "$HOME/.local/share/pixmaps/keydui.png"
cp "$INSTALL_DIR/icon.png" "$HOME/.local/share/pixmaps/com.keydui.app.png"

# Remove old/duplicate desktop files to ensure exactly ONE app launcher appears
rm -f "$DESKTOP_DIR/keydui.desktop"

# Generate the single canonical desktop file
cat > "$DESKTOP_DIR/com.keydui.app.desktop" <<EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=keydUI
GenericName=Keyboard Remapper
Comment=Manage and configure keyd keyboard mappings with a modern UI
Exec=$INSTALL_DIR/keydui
Icon=$INSTALL_DIR/icon.png
Terminal=false
Categories=Settings;HardwareSettings;Utility;
Keywords=keyd;keyboard;remap;keybinds;wooting;
StartupWMClass=com.keydui.app
EOF

chmod +x "$DESKTOP_DIR/com.keydui.app.desktop"

# Refresh desktop and icon database caches
if command -v gtk-update-icon-cache >/dev/null 2>&1; then
    gtk-update-icon-cache -f -t "$HOME/.local/share/icons/hicolor" 2>/dev/null || true
fi
if command -v update-desktop-database >/dev/null 2>&1; then
    update-desktop-database "$DESKTOP_DIR" 2>/dev/null || true
fi

echo ""
echo "=================================================================="
echo "  keydUI has been successfully installed!"
echo "=================================================================="
echo "You can now:"
echo " 1. Open your Zorin OS Application Menu / App Grid and launch 'keydUI'"
echo " 2. Search for 'keydUI' using the Super (Windows) key"
echo " 3. Right-click 'keydUI' in your menu to Pin / Add to Favorites on your dock"
echo "=================================================================="
