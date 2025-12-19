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

    if [ -n "$SHELL" ]; then
        base_name=$(basename "$SHELL")
    else
        base_name=$(ps -p $$ -o comm=)
    fi

    case "$base_name" in
        zsh)   SHELL_CONFIG="$HOME/.zshrc" ;;
        bash)  SHELL_CONFIG="$HOME/.bashrc" ;;
        *)     SHELL_CONFIG="$HOME/.profile" ;;
    esac
    echo -e "Detected shell config file: ${C_BLUE}$SHELL_CONFIG${C_RESET}"

    ALIAS_COMMAND="alias $COMMAND_NAME='$INSTALL_DIR/launch_tests.sh'"
    if ! grep -qF "$ALIAS_COMMAND" "$SHELL_CONFIG"; then
        echo "Adding alias to shell config file..."
        echo -e "\n# Alias for Swapinette" >> "$SHELL_CONFIG"
        echo "$ALIAS_COMMAND" >> "$SHELL_CONFIG"
    fi
    echo -e "${C_GREEN}✔ Alias '$COMMAND_NAME' has been configured.${C_RESET}"
    clear
    ## TEST ASCII
    hsla_to_rgb() {
    local h=$1
    local s=$2
    local l=$3

    local c=$(echo "scale=4; (1 - c($h*3.14159/180)*c($h*3.14159/180))" | bc -l)
    if (( $(echo "$h >= 0 && $h < 60" | bc -l) )); then
        r=255; g=128; b=0
    elif (( $(echo "$h >= 60 && $h < 90" | bc -l) )); then
        r=255; g=165; b=0
    else
        r=0; g=255; b=0
    fi

    echo "$r $g $b"
}
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
    echo -e "${C_BLUE}✔  Use swapinette everywhere!${C_RESET}\n"
    cd "$ORIGINAL_DIR"
    read -n1 -rsp $'\033[0;33mPress any key to launch Swapinette...\033[0m'
    bash -c "$(curl -fsSL "$INSTALL_URL")" && bash "$SCRIPT_DIR/swapinette.sh"
}

main

