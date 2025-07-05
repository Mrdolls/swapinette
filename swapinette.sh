#!/bin/bash

clear
show_help=false
TERM_WIDTH=$(tput cols 2>/dev/null || echo 80)
(( TERM_WIDTH > 80 )) && TERM_WIDTH=80

if [[ "$1" == "-help" ]]; then
    show_help=true
    shift
fi

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
    echo -e "\e[31m✘ Error: 'push_swap' executable not found when searching upward from current directory.\e[0m"
    echo -e "  Make sure it is compiled and marked as executable (chmod +x push_swap)."
    exit 1
fi

os_type=$(uname -s)
case "$os_type" in
    Linux*)  checker_name="checker_linux";;
    Darwin*) checker_name="checker_Mac";;
    *)
        echo -e "\e[31m✘ Error: OS '$os_type' not supported.\e[0m"
        exit 1
        ;;
esac

checker=$(find_upwards "$checker_name")

if [ -z "$checker" ]; then
    echo -e "\e[31m✘ Error: Checker '$checker_name' not found when searching upward from current directory.\e[0m"
    echo -e "  Make sure it is present and marked as executable (chmod +x $checker_name)."
    exit 1
fi

if [ "$show_help" = true ]; then
    printf "\
Usage: %s <nb_tests> <list_size> <max_operations>\n\
\n\
Description:\n\
This script tests 'push_swap'. It auto-detects executables,\n\
even if launched from a subfolder of your project.\n\
\n\
Arguments:\n\
<nb_tests>          Number of random tests to run.\n\
<list_size>         Size of the list to sort.\n\
<max_operations>    Maximum number of allowed operations.\n"
    exit 0
fi

if [ "$#" -ne 3 ]; then
    printf "\e[31m✘ Error:\e[0m Invalid arguments. Expected 3, got $#.\nUse \e[34m-help\e[0m for more information.\n"
    exit 1
fi

total=$1
size=$2
max_moves=$3

print_progress_bar() {
    local current=$1
    local total=$2
    local color=$3
    local width=$(( TERM_WIDTH > 120 ? 120 : (TERM_WIDTH < 40 ? 40 : TERM_WIDTH) ))
    local bar_width=$(( width - 20 ))
    local percent=$(( current * 100 / total ))
    local filled=$(( percent * bar_width / 100 ))
    local empty=$(( bar_width - filled ))

    [ "$percent" -eq 100 ] && filled=$bar_width && empty=0

    local bar=""
    (( filled > 0 )) && bar+=$(printf "%0.s█" $(seq 1 $filled))
    (( empty > 0 )) && bar+=$(printf "%0.s " $(seq 1 $empty))

    if [[ "$color" == "33" ]]; then
        printf "\rProgress: \e[38;5;208m|%-*s|%3d%%\e[0m" "$bar_width" "$bar" "$percent"
    else
        printf "\rProgress: \e[%sm|%-*s|%3d%%\e[0m" "$color" "$bar_width" "$bar" "$percent"
    fi
}

## TEST 1
echo -e "\n➤ Test 1: Validating output with $checker_name..."

for ((i=1; i<=total; i++)); do
    ARG="$(shuf -i 1-$(($size)) -n $size | tr '\n' ' ')"
    RESULT=$("$exec_name" $ARG | "$checker" $ARG)

    if [ "$RESULT" != "OK" ]; then
        sleep 0.5
        printf "\r\033[K"
        echo -e "\n\e[31m✘ KO with $checker_name ➜ Result: $RESULT\e[0m"
        exit 1
    fi

    print_progress_bar $i $total 92
done
sleep 0.5
printf "\r\033[K"
echo -e "\e[92m✔ All output validations passed with $checker_name\e[0m"

sleep 0.5

## TEST 2
echo -e "\n➤ Test 2: Checking number of operations..."
success=0
total_ops=0
force_red=false
has_failed=false

for ((i=1; i<=total; i++)); do
    ARG="$(shuf -i 0-$(($size - 1)) -n $size | tr '\n' ' ')"
    INDEX=$("$exec_name" $ARG | wc -l | tr -d ' ')

    total_ops=$((total_ops + INDEX))

    if [ "$INDEX" -le "$max_moves" ]; then
        ((success++))
    else
        has_failed=true
    fi

    remaining=$(( total - i ))
    max_possible=$(( success + remaining ))
    if ! $force_red && [ $(( max_possible * 100 / total )) -lt 50 ]; then
        force_red=true
    fi

    if $force_red; then
        current_color=31
    elif $has_failed; then
        current_color=33
    else
        current_color=92
    fi

    print_progress_bar $i $total $current_color
done

rate=$(( success * 100 / total ))
average=$(( total_ops / total ))
sleep 0.5

if [ "$rate" -lt 50 ]; then
    final_color=31
elif $has_failed; then
    final_color=33
else
    final_color=92
fi

print_progress_bar $total $total $final_color
printf "\r\033[K"

if [ "$rate" -lt 50 ]; then
    echo -e "\e[31m✘ Low success rate: $rate% ($success/$total tests were within the limit ($max_moves)) ~ Average: $average ops\e[0m"
elif $has_failed; then
    echo -e "\e[38;5;208m⚠ Partial success: $rate% ($success/$total tests were within the limit ($max_moves)) ~ Average: $average ops\e[0m"
else
    echo -e "\e[92m✔ All tests respected the operation limit ($max_moves) ($rate%) ~ Average: $average ops\e[0m"
fi
