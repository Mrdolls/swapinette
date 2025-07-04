#!/bin/bash

show_args=false

show_help=false

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
    printf "\e[31mError:\e[0m Invalid arguments.\nFor more info ➤ use \e[34m-help\e[0m\n"
    exit 1
fi

exec_name=$1
checker=$2
total=$3
size=$4
max_moves=$5

print_progress_bar() {
    local current=$1
    local total=$2

    local width=${COLUMNS:-80}
    (( width > 100 )) && width=100
    (( width < 10 )) && width=10

    local bar_width=$(( width - 20 ))
    (( bar_width < 10 )) && bar_width=10

    local percent=$(( current * 100 / total ))
    local filled=$(( percent * bar_width / 100 ))

    local bar=$(printf "%-${bar_width}s" "" | tr ' ' '#')
    bar=${bar:0:filled}$(printf "%-$((bar_width-filled))s" "")

    printf "\rProgress: [%s] %3d%%" "$bar" "$percent"
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
            echo -e "\e[33mArguments: $ARG\e[0m"
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
            echo -e "\e[33mArguments: $ARG\e[0m"
        fi
        exit 1
    fi

    print_progress_bar $i $total
done
sleep 0.5
printf "\r\033[K"
echo -e "\e[92m✔ All operations are within the limit ($max_moves operations)\e[0m"

