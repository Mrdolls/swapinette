#!/bin/bash

# --- VARIABLES DE CONFIGURATION ---
# Mettez l'URL de VOTRE dépôt ici
REPO_URL="git@github.com:Mrdolls/swapinette.git"
# Le dossier où l'outil sera installé
INSTALL_DIR="$HOME/.swapinette"
# Le nom que vous voulez donner à la commande pour lancer votre outil
COMMAND_NAME="swapinette"

# --- COULEURS POUR UN AFFICHAGE PLUS JOLI ---
C_RESET='\033[0m'
C_BLUE='\033[0;34m'
C_GREEN='\033[0;32m'
C_RED='\033[0;31m'

# --- FONCTION PRINCIPALE ---
main() {
    echo -e "${C_BLUE}Bienvenue dans l'installateur de Mon Super Outil !${C_RESET}"

    # 1. Vérifier si 'git' est installé
    if ! command -v git &> /dev/null; then
        echo -e "${C_RED}Erreur : 'git' n'est pas installé. Veuillez l'installer avant de continuer.${C_RESET}"
        exit 1
    fi
    echo -e "${C_GREEN}✔ Dépendance 'git' trouvée.${C_RESET}"

    # 2. Cloner ou mettre à jour le dépôt
    if [ -d "$INSTALL_DIR" ]; then
    echo -e "Dossier trouvé. Mise à jour forcée vers la dernière version..."
    echo -e "ATTENTION : Toutes les modifications locales seront écrasées."
    cd "$INSTALL_DIR"
    # Récupère les dernières données sans les appliquer
    git fetch origin
    # Force la branche locale à être identique à la branche distante
    git reset --hard origin/main || { echo -e "${C_RED}La mise à jour forcée a échoué.${C_RESET}"; exit 1; }
	else
        echo -e "Téléchargement de l'outil..."
        git clone "$REPO_URL" "$INSTALL_DIR" || { echo -e "${C_RED}Le téléchargement a échoué.${C_RESET}"; exit 1; }
    fi
    echo -e "${C_GREEN}✔ Outil téléchargé/mis à jour dans $INSTALL_DIR.${C_RESET}"

    # 3. Déterminer le fichier de configuration du shell (.zshrc, .bashrc, etc.)
    SHELL_CONFIG=""
    if [ -f "$HOME/.zshrc" ]; then
        SHELL_CONFIG="$HOME/.zshrc"
    elif [ -f "$HOME/.bashrc" ]; then
        SHELL_CONFIG="$HOME/.bashrc"
    elif [ -f "$HOME/.bash_profile" ]; then
        SHELL_CONFIG="$HOME/.bash_profile"
    else
        echo -e "${C_RED}Erreur : Impossible de trouver le fichier de configuration de votre shell (.zshrc, .bashrc).${C_RESET}"
        exit 1
    fi
    echo -e "Fichier de configuration détecté : ${C_BLUE}$SHELL_CONFIG${C_RESET}"

    # 4. Ajouter un alias pour rendre la commande accessible partout
    # L'alias pointera vers le script principal de votre outil
    ALIAS_COMMAND="alias $COMMAND_NAME='$INSTALL_DIR/swapinette.sh'"

    # Vérifie si l'alias n'existe pas déjà avant de l'ajouter
    if ! grep -q "$ALIAS_COMMAND" "$SHELL_CONFIG"; then
        echo "Ajout de l'alias au fichier de configuration..."
        echo -e "\n# Alias pour Mon Super Outil" >> "$SHELL_CONFIG"
        echo "$ALIAS_COMMAND" >> "$SHELL_CONFIG"
        echo -e "${C_GREEN}✔ Alias '$COMMAND_NAME' ajouté.${C_RESET}"
    else
        echo -e "${C_GREEN}✔ L'alias '$COMMAND_NAME' est déjà configuré.${C_RESET}"
    fi
	chmod +x "$INSTALL_DIR/swapinette.sh"

    # 5. Instructions finales
    echo -e "\n${C_GREEN}🎉 Installation terminée avec succès !${C_RESET}"
    echo -e "Pour utiliser la commande, veuillez faire l'une des actions suivantes :"
    echo -e "1. Redémarrez votre terminal."
    echo -e "2. Ou exécutez la commande : ${C_BLUE}source $SHELL_CONFIG${C_RESET}"
    echo -e "\nEnsuite, tapez simplement '${C_BLUE}$COMMAND_NAME${C_RESET}' pour lancer l'outil."
}

# Lancement de la fonction principale
main