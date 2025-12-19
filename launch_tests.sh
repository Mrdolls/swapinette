#!/bin/bash

check_update() {
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    VERSION_URL="https://raw.githubusercontent.com/Mrdolls/swapinette/main/version.txt"
    INSTALL_URL="https://raw.githubusercontent.com/Mrdolls/swapinette/refs/heads/main/install.sh"

    LOCAL_VERSION="unknown"
    REMOTE_VERSION="unknown"

    if [ -f "$SCRIPT_DIR/version.txt" ]; then
        LOCAL_VERSION=$(cat "$SCRIPT_DIR/version.txt")
    fi

    REMOTE_VERSION=$(curl -fsSL "$VERSION_URL" 2>/dev/null)

    [ -z "$REMOTE_VERSION" ] && return

    if [ "$LOCAL_VERSION" != "$REMOTE_VERSION" ]; then
        echo -e "\033[0;33m[⚠] New version available\033[0m"
        echo -e "    Local version : \033[0;31m$LOCAL_VERSION\033[0m"
        echo -e "    Latest version: \033[0;32m$REMOTE_VERSION\033[0m"
        echo
        read -n1 -r -s -p "Do you want to update Swapinette? [y/n] " answer
        echo
        case "$answer" in
            y|Y)
                echo -e "\033[0;34m[ℹ] Updating Swapinette...\033[0m"
                bash -c "$(curl -fsSL "$INSTALL_URL")"
                ;;
            n|N)
                echo -e "\033[0;33m[ℹ] Update skipped\033[0m"
                ;;
            *)
                echo -e "\033[0;33m[ℹ] Invalid input, update skipped\033[0m"
                ;;
        esac
    fi
}

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
VERSION_FILE="$SCRIPT_DIR/version.txt"

MODULE_TESTER_PATH="$SCRIPT_DIR/module_tester.sh"
MODULE_42_PATH="$SCRIPT_DIR/module_42.sh"
MODULE_BRUT_PATH="$SCRIPT_DIR/module_perf.sh"

GREEN="\033[0;32m"
RED="\033[0;31m"
YELLOW="\033[0;33m"
BLUE="\033[0;34m"
NC="\033[0m"

check_update

find_upwards() {
    local filename="$1"
    local path="$PWD"
    while [ "$path" != "/" ]; do
        local found
        found=$(find "$path" -maxdepth 1 -name "$filename" -type f -executable)
        if [ -n "$found" ]; then
            echo "$found"
            return 0
        fi
        path=$(dirname "$path")
    done
    return 1
}

compile_push_swap() {
    if [ ! -f ./push_swap ]; then
        echo -e "${YELLOW}[ℹ] push_swap not found, compiling...${NC}"
        if [ -f Makefile ]; then
            make
            if [ ! -f ./push_swap ]; then
                echo -e "${RED}✘ Error:  Compilation failed: push_swap still missing${NC}"
                exit 1
            else
                echo -e "${GREEN}[✔] Compilation successful!${NC}"
            fi
        else
            echo -e "${RED}✘ Error:  No Makefile found"${NC}
            exit 1
        fi
    else
        echo -e "${GREEN}[✔] push_swap found${NC}"
    fi
}

exec_name=$(find_upwards "push_swap")
compile_push_swap
sleep 0.2
echo -e "${YELLOW}[ℹ] Launching swapinette...${NC}"
sleep 1

os_type=$(uname -s)
case "$os_type" in
    Linux*)  checker_name="checker_linux";;
    Darwin*) checker_name="checker_Mac";;
    *)
        echo -e "${RED}✘ Error: Unsupported operating system '$os_type'.${NC}"
        exit 1
        ;;
esac

checker_path="$SCRIPT_DIR/checker_os/$checker_name"
if [ ! -f "$checker_path" ]; then
    echo -e "${RED}✘ Error: Checker not found at path '$checker_path'.${NC}"
    exit 1
fi

chmod +x "$checker_path"
chmod +x "$MODULE_TESTER_PATH"
chmod +x "$MODULE_BRUT_PATH"

display_menu() {
    clear
    local version
    version=$(cat "$SCRIPT_DIR/version.txt")
    if [ -z "$version" ]; then
        version="unknown"
    fi
    echo -e "${YELLOW}╔═════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}║               Menu ${version}             ║${NC}"
    echo -e "${YELLOW}╚═════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${BLUE}Select an option:${NC}"
    echo "  1. 42 Evaluation"
    echo "  2. Check Performance"
    echo "  3. Options"
    echo "  4. Exit"
    echo ""
}

run_evaluation_mode() {
    clear
    bash "$MODULE_TESTER_PATH" "$exec_name" "$checker_path"
}

run_42_mode() {
    clear
    bash "$MODULE_42_PATH" "$exec_name" "$checker_path"
}

run_manual_mode() {
    clear
    bash "$MODULE_BRUT_PATH"
}

run_options() {
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    while true; do
        clear
        echo -e "${YELLOW}╔═════════════════════════════════════╗${NC}"
        echo -e "${YELLOW}║                Options              ║${NC}"
        echo -e "${YELLOW}╚═════════════════════════════════════╝${NC}"
        echo ""
        echo -e "${BLUE}Select an option:${NC}"
        echo -e "  1. Uninstall Swapinette"
        echo -e "  2. Return to main menu"
        echo
        read -n1 -r -p "Choose an option: " opt
        echo

        case "$opt" in
            1)
                if [ -f "$SCRIPT_DIR/uninstall.sh" ]; then
                    bash "$SCRIPT_DIR/uninstall.sh"
                    break
                else
                    echo -e "\033[0;31muninstall.sh not found!\033[0m"
                    read -n1 -r -p "Press any key to return..."
                fi
                ;;
            2)
                break
                ;;
            *)
                echo -e "\033[0;31mInvalid option. Try again.\033[0m"
                sleep 1
                ;;
        esac
    done
}

while true; do
    display_menu
    read -n1 -r -s -p "Your choice [1-4]: " choice

    case "$choice" in
        1)
            run_42_mode
            echo -e "\n${YELLOW}Press Enter to return to the menu...${NC}"
            read -r
            ;;
        2)
            run_manual_mode
            echo -e "\n${YELLOW}Press Enter to return to the menu...${NC}"
            read -r
            ;;
        3)
            run_options
            ;;
        4)
            clear
            exit 0
            ;;
        *)
            echo -e "\n${RED}Invalid choice. Please try again.${NC}"
            sleep 2
            ;;
    esac
done
