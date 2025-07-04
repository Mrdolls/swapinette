#!/bin/bash

# --- VARIABLES DE CONFIGURATION ---
REPO_URL="git@github.com:Mrdolls/swapinette.git"
INSTALL_DIR="$HOME/.swapinette"
COMMAND_NAME="swapinette"

# --- COULEURS ---
C_RESET='\033[0m'
C_BLUE='\033[0;34m'
C_GREEN='\033[0;32m'
C_RED='\033[0;31m'
C_YELLOW='\033[0;33m'

# --- FONCTION PRINCIPALE ---
main() {
    echo -e "${C_BLUE}Bienvenue dans l'installateur de Swapinette !${C_RESET}"

    # 1. Vérifier si 'git' est installé
    if ! command -v git &> /dev/null; then
        echo -e "${C_RED}Erreur : 'git' n'est pas installé. Veuillez l'installer avant de continuer.${C_RESET}"
        exit 1
    fi
    echo -e "${C_GREEN}✔ Dépendance 'git' trouvée.${C_RESET}"

    # 2. Cloner ou mettre à jour le dépôt
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

    # 3. Déterminer le fichier de configuration du shell
    SHELL_CONFIG=""
    if [ -n "$ZSH_VERSION" ]; then
        SHELL_CONFIG="$HOME/.zshrc"
    elif [ -n "$BASH_VERSION" ]; then
        SHELL_CONFIG="$HOME/.bashrc"
    else
        SHELL_CONFIG="$HOME/.profile"
    fi
    echo -e "Fichier de configuration détecté : ${C_BLUE}$SHELL_CONFIG${C_RESET}"

    # 4. Ajouter l'alias
    ALIAS_COMMAND="alias $COMMAND_NAME='$INSTALL_DIR/swapinette.sh'"
    if ! grep -qF "$ALIAS_COMMAND" "$SHELL_CONFIG"; then
        echo "Ajout de l'alias au fichier de configuration..."
        echo -e "\n# Alias pour Swapinette" >> "$SHELL_CONFIG"
        echo "$ALIAS_COMMAND" >> "$SHELL_CONFIG"
    fi
    chmod +x "$INSTALL_DIR/swapinette.sh"
    echo -e "${C_GREEN}✔ Alias '$COMMAND_NAME' configuré.${C_RESET}"

    # 5. Instructions finales et relancement du shell
    echo -e "\n${C_GREEN}🎉 Installation terminée avec succès !${C_RESET}"
    echo -e "${C_YELLOW}Pour rendre la commande disponible immédiatement, le shell va se relancer...${C_RESET}"
    sleep 2 # Pause pour que l'utilisateur lise le message

    # Remplace le processus shell actuel par un nouveau, appliquant les changements
    exec "$SHELL"
}

# Lancement de la fonction principale
main