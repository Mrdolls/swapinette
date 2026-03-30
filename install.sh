#!/bin/bash

REPO_URL="https://github.com/Mrdolls/swapinette.git"
INSTALL_DIR="$HOME/.swapinette"
COMMAND_NAME="swapinette"

C_RESET='\033[0m'
C_BLUE='\033[0;34m'
C_GREEN='\033[0;32m'
C_RED='\033[0;31m'
C_YELLOW='\033[0;33m'

ORIGINAL_DIR="$(pwd)"

main() {
    clear
    echo -e "${C_BLUE}Welcome to the Swapinette installer!${C_RESET}"

    # Vérification de Git
    if ! command -v git &> /dev/null; then
        echo -e "${C_RED}Error: 'git' is not installed. Please install it before proceeding.${C_RESET}"
        exit 1
    fi
    echo -e "${C_GREEN}✔ 'git' dependency found.${C_RESET}"

    # Clone ou Mise à jour
    if [ -d "$INSTALL_DIR" ]; then
        echo -e "${C_YELLOW}Existing directory found. Forcing update to the latest version...${C_RESET}"
        cd "$INSTALL_DIR" || exit 1
        git fetch origin > /dev/null 2>&1
        git reset --hard origin/main || { echo -e "${C_RED}Forced update failed.${C_RESET}"; exit 1; }
    else
        echo -e "Cloning the tool..."
        git clone "$REPO_URL" "$INSTALL_DIR" || { echo -e "${C_RED}Failed to download the tool.${C_RESET}"; exit 1; }
    fi
    echo -e "${C_GREEN}✔ Tool downloaded/updated in $INSTALL_DIR.${C_RESET}"

    # --- NOUVELLE GESTION DES ALIAS ---
    ALIAS_COMMAND="alias $COMMAND_NAME='$INSTALL_DIR/launch_tests.sh'"
    CONFIG_FILES=("$HOME/.zshrc" "$HOME/.bashrc")
    ALIAS_ADDED=0

    echo -e "${C_BLUE}Configuring alias...${C_RESET}"

    for config_file in "${CONFIG_FILES[@]}"; do
        if [ -f "$config_file" ]; then
            # On nettoie une éventuelle ancienne version de l'alias
            sed -i.bak "/alias $COMMAND_NAME=/d" "$config_file" 2>/dev/null
            
            # On ajoute le nouvel alias
            echo -e "\n# Alias for Swapinette" >> "$config_file"
            echo "$ALIAS_COMMAND" >> "$config_file"
            
            echo -e "${C_GREEN}✔ Alias added to $config_file${C_RESET}"
            ALIAS_ADDED=1
        fi
    done

    if [ "$ALIAS_ADDED" -eq 0 ]; then
        # Fallback si ni .zshrc ni .bashrc n'existent
        echo -e "\n# Alias for Swapinette" >> "$HOME/.profile"
        echo "$ALIAS_COMMAND" >> "$HOME/.profile"
        echo -e "${C_GREEN}✔ Alias added to $HOME/.profile${C_RESET}"
    fi

    echo -e "${C_GREEN}✔ Alias '$COMMAND_NAME' has been configured.${C_RESET}"
    echo -e "${C_YELLOW}(Note: Please restart your terminal or run 'source ~/.zshrc' or 'source ~/.bashrc' to apply the alias)${C_RESET}"
    sleep 1
    clear
    # --- FIN DE LA NOUVELLE GESTION DES ALIAS ---


    ## TEST ASCII
    # (J'ai supprimé la fonction hsla_to_rgb car tu ne l'utilises pas dans la boucle en dessous, 
    # tu utilises tes variables green_r, orange_r, etc. C'est plus propre comme ça !)

green_r=0; green_g=255; green_b=0
orange_r=255; orange_g=165; orange_b=0
red_r=255; red_g=0; red_b=0

text="
███████╗██╗    ██╗ █████╗ ██████╗ ██╗███╗   ██╗███████╗████████╗████████╗███████╗
██╔════╝██║    ██║██╔══██╗██╔══██╗██║████╗  ██║██╔════╝╚══██╔══╝╚══██╔══╝██╔════╝
███████╗██║ █╗ ██║███████║██████╔╝██║██╔██╗ ██║█████╗     ██║      ██║   █████╗
╚════██║██║███╗██║██╔══██║██╔═══╝ ██║██║╚██╗██║██╔══╝     ██║      ██║   ██╔══╝
███████║╚███╔███╔╝██║  ██║██║     ██║██║ ╚████║███████╗   ██║      ██║   ███████╗
╚══════╝ ╚══╝╚══╝ ╚═╝  ╚═╝╚═╝     ╚═╝╚═╝  ╚═══╝╚══════╝   ╚═╝      ╚═╝   ╚══════╝
"

text=$(echo "$text" | sed '/^\s*$/d')

while IFS= read -r line; do
    len=${#line}
    # Prévention d'une division par zéro si la ligne est vide ou fait 1 caractère
    if (( len <= 1 )); then
        echo "$line"
        continue
    fi

    for ((i=0; i<len; i++)); do
        pos=$(( i * 100 / (len - 1) ))
        if (( pos <= 50 )); then
            ratio=$(( pos * 2 ))  # 0 à 100
            r=$(( green_r + (orange_r - green_r) * ratio / 100 ))
            g=$(( green_g + (orange_g - green_g) * ratio / 100 ))
            b=$(( green_b + (orange_b - green_b) * ratio / 100 ))
        else
            ratio=$(( (pos - 50) * 2 )) # 0 à 100
            r=$(( orange_r + (red_r - orange_r) * ratio / 100 ))
            g=$(( orange_g + (red_g - orange_g) * ratio / 100 ))
            b=$(( orange_b + (red_b - orange_b) * ratio / 100 ))
        fi

        char="${line:i:1}"
        printf "\e[38;2;%d;%d;%dm%s\e[0m" "$r" "$g" "$b" "$char"
    done
    echo
done <<< "$text"
    echo -e "${C_GREEN}🎉 Installation completed successfully!${C_RESET}"
    echo -e "${C_BLUE}✔ Use swapinette everywhere!${C_RESET}\n"
    cd "$ORIGINAL_DIR" || exit
}

main
