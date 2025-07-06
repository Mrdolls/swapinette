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

    if ! command -v git &> /dev/null; then
        echo -e "${C_RED}Error: 'git' is not installed. Please install it before proceeding.${C_RESET}"
        exit 1
    fi
    echo -e "${C_GREEN}✔ 'git' dependency found.${C_RESET}"

    if [ -d "$INSTALL_DIR" ]; then
        echo -e "${C_YELLOW}Existing directory found. Forcing update to the latest version...${C_RESET}"
        cd "$INSTALL_DIR"
        git fetch origin > /dev/null 2>&1
        git reset --hard origin/main || { echo -e "${C_RED}Forced update failed.${C_RESET}"; exit 1; }
    else
        echo -e "Cloning the tool..."
        git clone "$REPO_URL" "$INSTALL_DIR" || { echo -e "${C_RED}Failed to download the tool.${C_RESET}"; exit 1; }
    fi
    echo -e "${C_GREEN}✔ Tool downloaded/updated in $INSTALL_DIR.${C_RESET}"

    SHELL_CONFIG=""
    shell_name=$(basename "$SHELL")

    # Reliable detection of the current shell name
    if [ -n "$SHELL" ]; then
        base_name=$(basename "$SHELL")
    else
        base_name=$(ps -p $$ -o comm=)
    fi

    # Choose the correct shell config file
    case "$base_name" in
        zsh)   SHELL_CONFIG="$HOME/.zshrc" ;;
        bash)  SHELL_CONFIG="$HOME/.bashrc" ;;
        *)     SHELL_CONFIG="$HOME/.profile" ;;
    esac
    echo -e "Detected shell config file: ${C_BLUE}$SHELL_CONFIG${C_RESET}"

    ALIAS_COMMAND="alias $COMMAND_NAME='$INSTALL_DIR/swapinette.sh'"
    if ! grep -qF "$ALIAS_COMMAND" "$SHELL_CONFIG"; then
        echo "Adding alias to shell config file..."
        echo -e "\n# Alias for Swapinette" >> "$SHELL_CONFIG"
        echo "$ALIAS_COMMAND" >> "$SHELL_CONFIG"
    fi
    chmod +x "$INSTALL_DIR/swapinette.sh"
    echo -e "${C_GREEN}✔ Alias '$COMMAND_NAME' has been configured.${C_RESET}"
    sleep 3
    clear
    text="
███████╗██╗    ██╗ █████╗ ██████╗ ██╗███╗   ██╗███████╗████████╗████████╗███████╗
██╔════╝██║    ██║██╔══██╗██╔══██╗██║████╗  ██║██╔════╝╚══██╔══╝╚══██╔══╝██╔════╝
███████╗██║ █╗ ██║███████║██████╔╝██║██╔██╗ ██║█████╗     ██║      ██║   █████╗  
╚════██║██║███╗██║██╔══██║██╔═══╝ ██║██║╚██╗██║██╔══╝     ██║      ██║   ██╔══╝  
███████║╚███╔███╔╝██║  ██║██║     ██║██║ ╚████║███████╗   ██║      ██║   ███████╗
╚══════╝ ╚══╝╚══╝ ╚═╝  ╚═╝╚═╝     ╚═╝╚═╝  ╚═══╝╚══════╝   ╚═╝      ╚═╝   ╚══════╝
"

# On sépare les lignes
IFS=$'\n' read -rd '' -a lines <<<"$text"

num_lines=${#lines[@]}

for ((i=0; i<num_lines; i++)); do
    # Calcul progressif du rouge et vert (de vert pur à rouge pur)
    r=$((255 * i / (num_lines - 1)))
    g=$((255 - r))
    b=0

    # Code ANSI 24-bit foreground color
    printf "\e[38;2;%d;%d;%dm%s\e[0m\n" "$r" "$g" "$b" "${lines[i]}"
done
    echo -e "${C_GREEN}🎉 Installation completed successfully!${C_RESET}"
    echo -e "${C_BLUE}✔  Use swapinette everywhere!${C_RESET}\n"
    cd "$ORIGINAL_DIR"
    case "$base_name" in
        zsh)   zsh ;;
        bash)  bash ;;
    esac
}

main
