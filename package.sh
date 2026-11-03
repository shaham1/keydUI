#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$SCRIPT_DIR/dist"
BUNDLE_DIR="$SCRIPT_DIR/frontend/build/linux/x64/release/bundle"

# If bundle doesn't exist or --build flag is provided, trigger flutter build
if [ ! -f "$BUNDLE_DIR/keydui" ] || [ "$1" == "--build" ] || [ "$1" == "--rebuild" ]; then
    echo "==> Building keydUI release binary..."
    cd "$SCRIPT_DIR/frontend"
    if command -v flutter >/dev/null 2>&1; then
        flutter build linux --release
    elif [ -f "$HOME/development/flutter/bin/flutter" ]; then
        "$HOME/development/flutter/bin/flutter" build linux --release
    elif [ -f "$SCRIPT_DIR/.bin/flutter" ]; then
        "$SCRIPT_DIR/.bin/flutter" build linux --release
    else
        echo "Error: Flutter executable not found."
        exit 1
    fi
else
    echo "==> Using existing release binary in bundle."
fi

echo "==> Bundling backend and assets..."
cp -r "$SCRIPT_DIR/backend" "$BUNDLE_DIR/"
cp "$SCRIPT_DIR/frontend/web/icons/Icon-512.png" "$BUNDLE_DIR/icon.png"

mkdir -p "$DIST_DIR"
TARBALL="$DIST_DIR/keydUI-linux-x64.tar.gz"

echo "==> Creating portable archive at $TARBALL..."
cd "$BUNDLE_DIR"
tar --exclude=".venv" --exclude="__pycache__" -czf "$TARBALL" ./*

echo "=================================================================="
echo "  Portable bundle created successfully!"
echo "  File: $TARBALL"
echo "=================================================================="
