#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
MODULE_TESTER_PATH="$SCRIPT_DIR/module_tester.sh"
MODULE_BRUT_PATH="$SCRIPT_DIR/module_brut.sh"

GREEN="\033[0;32m"
RED="\033[0;31m"
YELLOW="\033[0;33m"
BLUE="\033[0;34m"
NC="\033[0m" # No Color

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

exec_name=$(find_upwards "push_swap")
if [ -z "$exec_name" ]; then
    echo -e "${RED}✘ Error: Executable 'push_swap' not found.${NC}"
    echo "  Make sure it is compiled and has execution permissions (chmod +x push_swap)."
    exit 1
fi

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
    echo -e "${YELLOW}=========================================${NC}"
    echo -e "${YELLOW}              SWAPINETTE                ${NC}"
    echo -e "${YELLOW}=========================================${NC}"
    echo ""
    echo -e "${BLUE}Select an option:${NC}"
    echo "  1. Evaluation Mode (predefined tests and scoring)"
    echo "  2. Manual Mode (custom tests in loop)"
    echo "  3. Exit"
    echo ""
}

run_evaluation_mode() {
    echo -e "\n${GREEN}Starting Evaluation Mode...${NC}"
    sleep 1
    clear
    bash "$MODULE_TESTER_PATH" "$exec_name" "$checker_path"
}

run_manual_mode() {
    echo -e "\n${GREEN}Starting Manual Mode...${NC}"
    sleep 1
    clear
    bash "$MODULE_BRUT_PATH"
}

while true; do
    display_menu
    read -p "Your choice [1-3]: " choice

    case "$choice" in
        1)
            run_evaluation_mode
            echo -e "\n${YELLOW}Press Enter to return to the menu...${NC}"
            read -r
            ;;
        2)
            run_manual_mode
            echo -e "\n${YELLOW}Press Enter to return to the menu...${NC}"
            read -r
            ;;
        3)
            clear
            echo -e "\n${GREEN}Goodbye!${NC}"
            exit 0
            ;;
        *)
            echo -e "\n${RED}Invalid choice. Please try again.${NC}"
            sleep 2
            ;;
    esac
done
