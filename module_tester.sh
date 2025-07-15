#!/bin/bash

PS=$1
CK=$2

GREEN="\033[0;32m"
RED="\033[0;31m"
YELLOW="\033[0;33m"
NC="\033[0m"
MAX_DESC_LENGTH=50

print_result() {
    status=$1
    desc=$2
    padding=$((MAX_DESC_LENGTH - ${#desc}))
    printf "%s%*s : " "$desc" "$padding" ""
	sleep 0.2
    if [ "$status" = "OK" ]; then
        echo -e "${GREEN}OK${NC}"
    else
        echo -e "${RED}KO${NC}"
    fi
}

empty_test() {
    desc=$1
    result=$($PS "" 2> /dev/null | $CK "" 2> /dev/null)
    if [ -z "$result" ]; then
        print_result "OK" "$desc"
    else
        print_result "KO" "$desc"
    fi
}

test_valid() {
    desc=$1
    input=$2
    result=$($PS $input 2> /dev/null | $CK $input 2> /dev/null)
    if [ "$result" = "OK" ]; then
        print_result "OK" "$desc"
    else
        print_result "KO" "$desc"
    fi
}

test_error() {
    desc=$1
    input=$2
    $PS $input 1> /dev/null 2> tmp_error
    if grep -q "Error" tmp_error; then
        print_result "OK" "$desc"
    else
        print_result "KO" "$desc"
    fi
    rm -f tmp_error
}

show_progress() {
    current=$1
    total=$2
    width=50
    percent=$(( current * 100 / total ))
    filled=$(( current * width / total ))
    empty=$(( width - filled ))
    bar=$(printf "%0.s#" $(seq 1 $filled))
    space=$(printf "%0.s." $(seq 1 $empty))
    printf "\rProgression : [${bar}${space}] %3d%% (%d/%d)" $percent $current $total
}

test_ops_count() {
    desc=$1
    input=$2
    max_ops=$3
    nb_tests=${4:-1}

    fail=0
    size=$(( $(echo $input | wc -w) ))

    for i in $(seq 1 $nb_tests); do
        if [ "$nb_tests" -gt 1 ]; then
            input=$(shuf -i 1-10000 -n $size | tr '\n' ' ' | sed 's/ $//')
        fi

        output=$($PS $input)
        ops=$(echo "$output" | wc -l)

        percent=$((i * 100 / nb_tests ))
        padding=$((MAX_DESC_LENGTH - ${#desc}))
        printf "\r%s%*s :%3d%%" "$desc" "$padding" "" "$percent"

        if [ "$ops" -gt "$max_ops" ]; then
            fail=1
        fi
    done

    # Efface la ligne en fin de boucle et affiche OK/KO finale
    printf "\r%*s\r" $((MAX_DESC_LENGTH + 10)) ""
    padding=$((MAX_DESC_LENGTH - ${#desc}))
    printf "%s%*s : " "$desc" "$padding" ""
    if [ "$fail" -eq 0 ]; then
        echo -e "${GREEN}OK${NC}"
    else
        echo -e "${RED}KO${NC} (Trop d'opérations sur au moins un test)"
    fi
}


### --- TESTS ---

# Colors for section headers
echo -e "${YELLOW}"
echo "========================================"
echo "             Error Tests                "
echo "========================================"
echo -e "${NC}"
test_error "Duplicate values (1 2 2)" "1 2 2"
test_error "Non-numeric input (a b c)" "a b c"
test_error "Floating point numbers (1.5 2.6)" "1.5 2.6"
test_error "Integer overflow (2147483648)" "2147483648 2"
test_error "Integer underflow (-2147483649)" "-2147483649 2"

echo -e "${YELLOW}"
echo "========================================"
echo "             Empty Inputs               "
echo "========================================"
echo -e "${NC}"
empty_test "Empty input ()"
empty_test "Empty string (\"\")"
test_valid "Single number (1)" "1"
test_valid "Sorted 3 elements (1 2 3)" "1 2 3"
test_valid "Sorted 9 elements" "1 2 3 4 5 6 7 8 9"
test_valid "Sorted negative/positive (-52 40 80 1500)" "-52 40 80 1500"

echo -e "${YELLOW}"
echo "========================================"
echo "              Simple Cases              "
echo "========================================"
echo -e "${NC}"
test_valid "Reversed order (3 2 1)" "3 2 1"
test_valid "Negative numbers (-1 -5 -60)" "-1 -5 -60"
test_valid "Random 5 elements (3 1 5 2 4)" "3 1 5 2 4"
test_valid "Multiple spaces (1      9  2   8)" "1      9  2   8"

echo -e "${YELLOW}"
echo "========================================"
echo "                 Limits                 "
echo "========================================"
echo -e "${NC}"
test_valid "INT_MIN and INT_MAX" "-2147483648 2147483647"

echo -e "${YELLOW}"
echo "========================================"
echo "            Performance Tests           "
echo "========================================"
echo -e "${NC}"
ARG=$(seq 1 3 | sort -R | tr '\n' ' ')
test_ops_count "3 elements random (< 3) — 1000 tests" "$ARG" 3 1000

ARG=$(seq 1 5 | sort -R | tr '\n' ' ')
test_ops_count "5 elements random (< 12) — 1000 tests" "$ARG" 12 1000

ARG=$(seq 1 100 | sort -R | tr '\n' ' ')
test_ops_count "100 elements random (< 1500) — 500 tests" "$ARG" 1500 500

ARG=$(seq 1 500 | sort -R | tr '\n' ' ')
test_ops_count "500 elements random (< 11500) — 250 tests" "$ARG" 11500 250

calculate_score() {
    score_100=$1
    score_500=$2
    global_score=0

    if [ "$score_100" -ge 1 ] && [ "$score_500" -ge 1 ]; then
        global_score=$((80 + (score_100 + score_500) * 2))
    else
        global_score=0
    fi

    echo "========================================"
    echo "             Final Result               "
    echo "========================================"
    if [ "$global_score" -eq 0 ]; then
        echo -e "${RED}Tests failed or performance too low. Score: 0/100${NC}"
    else
        echo -e "${GREEN}All tests passed.${NC}"
        echo -e "100 elements performance: ${score_100}/5"
        echo -e "500 elements performance: ${score_500}/5"
        echo -e "${YELLOW}Estimated score: ${global_score}/100${NC}"
    fi
}


# Test 100 éléments
score_100=0
ARG=$(seq 1 100 | sort -R | tr '\n' ' ')
ops_100=$($PS $ARG | wc -l)
if [ "$ops_100" -lt 700 ]; then score_100=5
elif [ "$ops_100" -lt 900 ]; then score_100=4
elif [ "$ops_100" -lt 1100 ]; then score_100=3
elif [ "$ops_100" -lt 1300 ]; then score_100=2
elif [ "$ops_100" -lt 1500 ]; then score_100=1
fi

# Test 500 éléments
score_500=0
ARG=$(seq 1 500 | sort -R | tr '\n' ' ')
ops_500=$($PS $ARG | wc -l)
if [ "$ops_500" -lt 5500 ]; then score_500=5
elif [ "$ops_500" -lt 7000 ]; then score_500=4
elif [ "$ops_500" -lt 8500 ]; then score_500=3
elif [ "$ops_500" -lt 10000 ]; then score_500=2
elif [ "$ops_500" -lt 11500 ]; then score_500=1
fi

calculate_score $score_100 $score_500