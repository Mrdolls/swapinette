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
    echo -e "\e[31m✘ Erreur : L'exécutable 'push_swap' n'a pas été trouvé en remontant depuis votre position.\e[0m"
    echo -e "  Assurez-vous qu'il est compilé et exécutable (chmod +x push_swap)."
    exit 1
fi

os_type=$(uname -s)
case "$os_type" in
    Linux*)  checker_name="checker_linux";;
    Darwin*) checker_name="checker_Mac";;
    *)
        echo -e "\e[31m✘ Erreur : OS '$os_type' non supporté.\e[0m"
        exit 1
        ;;
esac

checker=$(find_upwards "$checker_name")

if [ -z "$checker" ]; then
    echo -e "\e[31m✘ Erreur : Le checker '$checker_name' n'a pas été trouvé en remontant depuis votre position.\e[0m"
    echo -e "  Assurez-vous qu'il est présent et exécutable (chmod +x $checker_name)."
    exit 1
fi

if [ "$show_help" = true ]; then
    printf "\
    Usage: %s [-a] <nb_tests> <list_size> <max_operations>\n\
    \n\
    Description:\n\
    Ce script teste 'push_swap'. Il trouve les exécutables automatiquement,\n\
    même si vous le lancez depuis un sous-dossier de votre projet.\n\
    \n\
    Options:\n\
    -a                  Affiche les arguments en cas d'échec d'un test.\n\
    \n\
    Arguments:\n\
    <nb_tests>          Nombre de tests aléatoires à exécuter.\n\
    <list_size>         Taille de la liste de nombres à trier.\n\
    <max_operations>    Nombre maximal d'opérations autorisées.\n"
    exit 0
fi

if [ "$#" -ne 3 ]; then
    printf "\e[31m✘ Erreur:\e[0m Arguments invalides. 3 attendus, $# reçus.\nPour plus d'infos ➤ utilisez \e[34m-help\e[0m\n"
    exit 1
fi

total=$1
size=$2
max_moves=$3

print_progress_bar() {
    local current=$1
    local total=$2
    local width=$(( TERM_WIDTH > 120 ? 120 : (TERM_WIDTH < 40 ? 40 : TERM_WIDTH) ))
    local bar_width=$(( width - 20 ))
    local percent=$(( current * 100 / total ))
    local filled=$(( percent * bar_width / 100 ))
    local empty=$(( bar_width - filled ))

    [ "$percent" -eq 100 ] && filled=$bar_width && empty=0

    local bar=""
    (( filled > 0 )) && bar+=$(printf "%0.s█" $(seq 1 $filled))
    (( empty > 0 )) && bar+=$(printf "%0.s " $(seq 1 $empty))
    printf "\rProgression : \e[92m|%-*s|%3d%%\e[0m" "$bar_width" "$bar" "$percent"
}

echo -e "\n➤ Test 1 : Vérification avec $checker_name..."

for ((i=1; i<=total; i++)); do
    ARG="$(shuf -i 1-$(($size)) -n $size | tr '\n' ' ')"
    RESULT=$("$exec_name" $ARG | "$checker" $ARG)

    if [ "$RESULT" != "OK" ]; then
        sleep 0.5
        printf "\r\033[K"
        echo -e "\n\e[31m✘ KO avec $checker_name ➜ Résultat : $RESULT\e[0m"
        if [ "$show_args" = true ]; then
            echo -e "\e[33m  Arguments : $ARG\e[0m"
        fi
        exit 1
    fi

    print_progress_bar $i $total
done
sleep 0.5
printf "\r\033[K"
echo -e "\e[92m✔ Toutes les vérifications avec $checker_name sont passées\e[0m"

sleep 0.5
echo -e "\n➤ Test 2 : Vérification du nombre d'opérations..."

for ((i=1; i<=total; i++)); do
    ARG="$(shuf -i 0-$(($size - 1)) -n $size | tr '\n' ' ')"
    INDEX=$("$exec_name" $ARG | wc -l | tr -d ' ')

    if [ "$INDEX" -gt "$max_moves" ]; then
        sleep 0.5
        printf "\r\033[K"
        echo -e "\e[31m✘ KO ➜ $INDEX opérations (limite $max_moves)\e[0m"
        if [ "$show_args" = true ]; then
            echo -e "\e[33m  Arguments : $ARG\e[0m"
        fi
        exit 1
    fi

    print_progress_bar $i $total
done
sleep 0.5
printf "\r\033[K"
echo -e "\e[92m✔ Toutes les opérations respectent la limite ($max_moves opérations)\e[0m"
