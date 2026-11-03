#!/usr/bin/env bash
set -e

INSTALL_DIR="$HOME/.local/share/keydui"
DESKTOP_DIR="$HOME/.local/share/applications"

echo "==> Uninstalling keydUI..."
rm -rf "$INSTALL_DIR"
rm -f "$DESKTOP_DIR/keydui.desktop"
rm -f "$DESKTOP_DIR/com.keydui.app.desktop"
rm -f "$HOME/.local/share/icons/hicolor/512x512/apps/keydui.png"
rm -f "$HOME/.local/share/icons/hicolor/512x512/apps/com.keydui.app.png"
rm -f "$HOME/.local/share/icons/keydui.png"
rm -f "$HOME/.local/share/icons/com.keydui.app.png"
rm -f "$HOME/.local/share/pixmaps/keydui.png"
rm -f "$HOME/.local/share/pixmaps/com.keydui.app.png"

if command -v gtk-update-icon-cache >/dev/null 2>&1; then
    gtk-update-icon-cache -f -t "$HOME/.local/share/icons/hicolor" 2>/dev/null || true
fi
if command -v update-desktop-database >/dev/null 2>&1; then
    update-desktop-database "$DESKTOP_DIR" 2>/dev/null || true
fi

echo "keydUI has been uninstalled."

