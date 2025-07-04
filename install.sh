#!/bin/bash

REPO_URL="git@github.com:Mrdolls/swapinette.git"
INSTALL_DIR="$HOME/.swapinette"
COMMAND_NAME="swapinette"

C_RESET='\033[0m'
C_BLUE='\033[0;34m'
C_GREEN='\033[0;32m'
C_RED='\033[0;31m'
C_YELLOW='\033[0;33m'

ORIGINAL_DIR="$(pwd)"

main() {
    echo -e "${C_BLUE}Bienvenue dans l'installateur de Swapinette !${C_RESET}"

    if ! command -v git &> /dev/null; then
        echo -e "${C_RED}Erreur : 'git' n'est pas installé. Veuillez l'installer avant de continuer.${C_RESET}"
        exit 1
    fi
    echo -e "${C_GREEN}✔ Dépendance 'git' trouvée.${C_RESET}"

    if [ -d "$INSTALL_DIR" ]; then
        echo -e "${C_YELLOW}Dossier trouvé. Mise à jour forcée vers la dernière version...${C_RESET}"
        cd "$INSTALL_DIR"
        git fetch origin > /dev/null 2>&1
        git reset --hard origin/main || { echo -e "${C_RED}La mise à jour forcée a échoué.${C_RESET}"; exit 1; }
    else
        echo -e "Téléchargement de l'outil..."
        git clone "$REPO_URL" "$INSTALL_DIR" || { echo -e "${C_RED}Le téléchargement a échoué.${C_RESET}"; exit 1; }
    fi
    echo -e "${C_GREEN}✔ Outil téléchargé/mis à jour dans $INSTALL_DIR.${C_RESET}"

    SHELL_CONFIG=""
    if [ -n "$ZSH_VERSION" ]; then
        SHELL_CONFIG="$HOME/.zshrc"
    elif [ -n "$BASH_VERSION" ]; then
        SHELL_CONFIG="$HOME/.bashrc"
    else
        SHELL_CONFIG="$HOME/.profile"
    fi
    echo -e "Fichier de configuration détecté : ${C_BLUE}$SHELL_CONFIG${C_RESET}"

    ALIAS_COMMAND="alias $COMMAND_NAME='$INSTALL_DIR/swapinette.sh'"
    if ! grep -qF "$ALIAS_COMMAND" "$SHELL_CONFIG"; then
        echo "Ajout de l'alias au fichier de configuration..."
        echo -e "\n# Alias pour Swapinette" >> "$SHELL_CONFIG"
        echo "$ALIAS_COMMAND" >> "$SHELL_CONFIG"
    fi
    chmod +x "$INSTALL_DIR/swapinette.sh"
    echo -e "${C_GREEN}✔ Alias '$COMMAND_NAME' configuré.${C_RESET}"
    echo -e "\n${C_GREEN}🎉 Installation terminée avec succès !${C_RESET}"
    cd "$ORIGINAL_DIR"
    exec "$SHELL"
}

main
