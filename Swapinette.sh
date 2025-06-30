#!/bin/bash

if [ "$#" -ne 4 ]; then
    echo "Usage: $0 <executable> <nb_tests> <size_of_list> <max_operations>"
    exit 1
fi

exec_name=$1
total=$2
size=$3
max_moves=$4
i=1

while [ $i -le $total ]; do
    ARG="$(shuf -i 0-$(($size - 1)) -n $size | tr '\n' ' ')"
    INDEX="$(./"$exec_name" $ARG | wc -l)"

    if [ "$INDEX" -gt "$max_moves" ]; then
        echo -e "\n\e[31mKO ➜ $INDEX operations (limite $max_moves)\e[0m"
        exit 1
    fi

    percent=$(( i * 100 / total ))
    filled=$(( percent ))
    bar=$(printf "%-${filled}s" "#" | tr ' ' '#')
    printf "\rProgression : [%-100s] %d%%" "$bar" "$percent"

    ((i++))
done

echo -e "\n\e[92mOK - Toutes les operations respectent la limite ($max_moves)\e[0m"
