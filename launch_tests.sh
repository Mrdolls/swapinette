#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
VERSION_FILE="$SCRIPT_DIR/version.txt"
CURRENT_VERSION=""

get_git_version() {
    git -C "$SCRIPT_DIR" describe --tags --abbrev=0 2>/dev/null || echo "unknown"
}

if [ ! -f "$VERSION_FILE" ]; then
    echo "$CURRENT_VERSION" > "$VERSION_FILE"
fi

stored_version=$(<"$VERSION_FILE")
latest_version=$(get_git_version)

if [ "$latest_version" = "unknown" ]; then
    echo "Unable to retrieve git version (not in a git repo?)"
else
    if [ "$latest_version" != "$stored_version" ]; then
        echo "New version detected: $latest_version (stored: $stored_version)"
        echo "Updating swapinette..."

        git -C "$SCRIPT_DIR" pull

        echo "$latest_version" > "$VERSION_FILE"

        echo "Update complete. Automatically restarting the script..."
        sleep 3
        exec "$0" "$@"
    fi
fi
MODULE_TESTER_PATH="$SCRIPT_DIR/module_tester.sh"
MODULE_42_PATH="$SCRIPT_DIR/module_42.sh"
MODULE_BRUT_PATH="$SCRIPT_DIR/module_perf.sh"

GREEN="\033[0;32m"
RED="\033[0;31m"
YELLOW="\033[0;33m"
BLUE="\033[0;34m"
NC="\033[0m"

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
    echo "Make sure it is compiled and has execution permissions (chmod +x push_swap)."
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
    local version
    version=$(git -C "$SCRIPT_DIR" describe --tags --abbrev=0 2>/dev/null)
    if [ -z "$version" ]; then
        version="unknown"
    fi
    echo -e "${YELLOW}=========================================${NC}"
    echo -e "${YELLOW}          SWAPINETTE ${version}              ${NC}"
    echo -e "${YELLOW}=========================================${NC}"
    echo ""
    echo -e "${BLUE}Select an option:${NC}"
    echo "  1. 42 Evaluation"
    echo "  2. Check Performance"
    echo "  3. Exit"
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

while true; do
    display_menu
    read -p "Your choice [1-3]: " choice

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
            clear
            exit 0
            ;;
        *)
            echo -e "\n${RED}Invalid choice. Please try again.${NC}"
            sleep 2
            ;;
    esac
done
