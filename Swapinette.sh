#!/bin/bash

if [ "$#" -ne 5 ]; then
    echo "Usage: $0 <executable> <checker> <nb_tests> <size_of_list> <max_operations>"
    exit 1
fi

exec_name=$1
checker=$2
total=$3
size=$4
max_moves=$5

### Test 1 : Vérification avec le checker choisi
echo -e "\n➤ Test 1 : Vérification avec $checker..."

for ((i=1; i<=total; i++)); do
    ARG="$(shuf -i 0-$(($size - 1)) -n $size | tr '\n' ' ')"
    RESULT=$(./"$exec_name" $ARG | ./"$checker" $ARG)

    if [ "$RESULT" != "OK" ]; then
        echo -e "\n\e[31mKO avec $checker ➜ Résultat: $RESULT\e[0m"
        echo "Arguments : $ARG"
        exit 1
    fi

    percent=$(( i * 100 / total ))
    filled=$(( percent ))
    bar=$(printf "%-${filled}s" "#" | tr ' ' '#')
    printf "\rProgression : [%-100s] %d%%" "$bar" "$percent"
done

echo -e "\n\e[92m✔ Toutes les vérifications $checker sont OK\e[0m"

### Test 2 : Vérification du nombre d'opérations (exécuté uniquement si checker = OK)
echo -e "\n➤ Test 2 : Vérification du nombre d'opérations..."

for ((i=1; i<=total; i++)); do
    ARG="$(shuf -i 0-$(($size - 1)) -n $size | tr '\n' ' ')"
    INDEX="$(./"$exec_name" $ARG | wc -l)"

    if [ "$INDEX" -gt "$max_moves" ]; then
        echo -e "\n\e[31mKO ➜ $INDEX opérations (limite $max_moves)\e[0m"
        echo "Arguments : $ARG"
        exit 1
    fi

    percent=$(( i * 100 / total ))
    filled=$(( percent ))
    bar=$(printf "%-${filled}s" "#" | tr ' ' '#')
    printf "\rProgression : [%-100s] %d%%" "$bar" "$percent"
done

echo -e "\n\e[92m✔ Toutes les opérations sont sous la limite ($max_moves)\e[0m"
