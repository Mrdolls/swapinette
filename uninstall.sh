#!/bin/bash

INSTALL_DIR="$HOME/.swapinette"
COMMAND_NAME="swapinette"

echo "Uninstalling Swapinette..."

if [ -d "$INSTALL_DIR" ]; then
    rm -rf "$INSTALL_DIR"
    echo "✔ Removed $INSTALL_DIR"
else
    echo "ℹ No installation directory found"
fi

SHELL_CONFIG=""
shell_name=$(basename "$SHELL")

case "$shell_name" in
    zsh)   SHELL_CONFIG="$HOME/.zshrc" ;;
    bash)  SHELL_CONFIG="$HOME/.bashrc" ;;
    *)     SHELL_CONFIG="$HOME/.profile" ;;
esac

if [ -f "$SHELL_CONFIG" ]; then
    sed -i.bak "/alias $COMMAND_NAME=/d" "$SHELL_CONFIG"
    echo "✔ Alias removed from $SHELL_CONFIG (backup saved as $SHELL_CONFIG.bak)"
fi

echo "Swapinette has been successfully uninstalled!"