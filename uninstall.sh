#!/bin/bash

INSTALL_DIR="$HOME/.swapinette"
COMMAND_NAME="swapinette"

# Couleurs
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${YELLOW}[⚠] Are you sure you want to uninstall Swapinette? [y/n]${NC}"
read -n1 -r answer
echo
case "$answer" in
    y|Y)
        echo -e "${RED}[ℹ] Uninstalling Swapinette...${NC}"
        cd "$HOME" || exit 1

        if [ -d "$INSTALL_DIR" ]; then
            chmod -R u+w "$INSTALL_DIR" 2>/dev/null
            rm -rf "$INSTALL_DIR"
            if [ -d "$INSTALL_DIR" ]; then
                echo -e "${RED}[⚠] Could not fully remove $INSTALL_DIR${NC}"
            else
                echo -e "${GREEN}[✔] Removed $INSTALL_DIR${NC}"
            fi
        else
            echo -e "${YELLOW}[ℹ] No installation directory found${NC}"
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
            echo -e "${GREEN}[✔] Alias removed from $SHELL_CONFIG${NC} (backup saved as $SHELL_CONFIG.bak)"
        fi

        echo -e "${GREEN}[✔] Swapinette has been successfully uninstalled!${NC}"
        ;;
    *)
        echo -e "${YELLOW}[ℹ] Uninstallation cancelled.${NC}"
        ;;
esac
