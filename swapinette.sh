#!/bin/bash

show_args=false

show_help=false
TERM_WIDTH=$(tput cols 2>/dev/null || echo 80)
(( TERM_WIDTH > 80 )) && TERM_WIDTH=80

if [[ "$1" == "-a" ]]; then
    show_args=true
    shift
fi

if [[ "$1" == "-help" ]]; then
    show_help=true
    shift
fi

if [ "$show_help" = true ]; then
    printf "\
    Usage: %s [-a] <executable> <checker> <nb_tests> <list_size> <max_operations>\n\
    \n\
    Options:\n\
    -a                  Show arguments if a test fails\n\
    \n\
    Arguments:\n\
    <executable>        Your push_swap executable\n\
    <checker>           The checker program to validate output (e.g., checker_linux or checker_Mac)\n\
    <nb_tests>          Number of random tests to run\n\
    <list_size>         Size of the list to sort\n\
    <max_operations>    Maximum allowed operations per test\n\
    " "$0"
    exit 1
fi

if [ "$#" -ne 5 ]; then
    printf "\e[31m✘ Error:\e[0m Invalid arguments.\nFor more info ➤ use \e[34m-help\e[0m\n"
    exit 1
fi

exec_name=$1
checker=$2
total=$3
size=$4
max_moves=$5
p=0

print_progress_bar() {
    local current=$1
    local total=$2

    local width=$TERM_WIDTH
    (( width < 40 )) && width=40  # limite min

    (( width > 120 )) && width=120
    (( width < 40 )) && width=40

    local bar_width=$(( width - 20 ))
    local percent=$(( current * 100 / total ))
    local filled=$(( percent * bar_width / 100 ))

    if [ "$percent" -eq 100 ]; then
        filled=$bar_width
        empty=0
    else
        empty=$(( bar_width - filled ))
    fi

    local bar=""
    if (( filled > 0 )); then
        bar+=$(printf "%0.s█" $(seq 1 $filled))
    fi
    if (( empty > 0 )); then
        bar+=$(printf "%0.s░" $(seq 1 $empty))
    fi
    p=$percent
    printf "\rProgress: \e[92m%-*s %3d%%\e[0m" "$bar_width" "$bar" "$percent"
}




### Test 1
echo -e "\n➤ Test 1: Verifying with $checker..."

for ((i=1; i<=total; i++)); do
    ARG="$(shuf -i 1-$(($size - 1)) -n $size | tr '\n' ' ')"
    RESULT=$(./"$exec_name" $ARG | ./"$checker" $ARG)

    if [ "$RESULT" != "OK" ]; then
        sleep 0.5
        printf "\r\033[K"
        echo -e "\n\e[31m✘ KO with $checker ➜ Result: $RESULT\e[0m"
        if [ "$show_args" = true ]; then
            echo -e "\e[33m  Arguments: $ARG\e[0m"
        fi
        exit 1
    fi

    print_progress_bar $i $total
done
sleep 0.5
printf "\r\033[K"
echo -e "\e[92m✔ All verifications with $checker passed\e[0m"

### Test 2
sleep 0.5
echo -e "\n➤ Test 2: Verifying number of operations..."

for ((i=1; i<=total; i++)); do
    ARG="$(shuf -i 0-$(($size - 1)) -n $size | tr '\n' ' ')"
    INDEX="$(./"$exec_name" $ARG | wc -l)"

    if [ "$INDEX" -gt "$max_moves" ]; then
        sleep 0.5
        printf "\r\033[K"
        echo -e "\e[31m✘ KO ➜ $INDEX operations (limit $max_moves)\e[0m"
        if [ "$show_args" = true ]; then
            echo -e "\e[33m  Arguments: $ARG\e[0m"
        fi
        exit 1
    fi

    print_progress_bar $i $total
done
sleep 0.5
printf "\r\033[K"
echo -e "\e[92m✔ All operations are within the limit ($max_moves operations)\e[0m"

