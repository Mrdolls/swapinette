#!/bin/bash
# bash Swapinette [repetitions] [nombres de nombres generes aleatoirement pour push_swap] [limit a ne pas depasser]
i=1
total=$2
size=$3
max_moves=$4

while [ $i -le $total ]; do
    ARG="$(shuf -i 0-$size -n $size | tr '\n' ' ')"
    INDEX="$(./"$1" $ARG | wc -l)"
    if [ $INDEX -gt $max_moves ]; then
        echo -e "\n\e[31mKO ➜ $INDEX operations (limite $max_moves)\e[0m"
        exit 1
    fi
    percent=$(( i * 100 / total ))
    bar=$(printf "%-${percent}s" "#" | tr ' ' '#')
    printf "\rProgression : [%-100s] %d%%" "$bar" "$percent"

    ((i++))
done

echo -e "\n\e[92mOK - Toutes les operations respectent la limite ($max_moves)\e[0m"
