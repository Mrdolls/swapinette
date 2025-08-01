#!/bin/bash

PS=$1
CK=$2
avg_ops_100=0
avg_ops_500=0
GREEN="\033[0;32m"
RED="\033[0;31m"
YELLOW="\033[0;33m"
NC="\033[0m"
MAX_DESC_LENGTH=50
failed_tests=0;

print_result() {
    status=$1
    desc=$2
    padding=$((MAX_DESC_LENGTH - ${#desc}))
    printf "%s%*s : " "$desc" "$padding" ""
	sleep 0.2
    if [ "$status" = "OK" ]; then
        echo -e "${GREEN}OK${NC}"
    else
        failed_tests=$((failed_tests + 1))
        echo -e "${RED}KO${NC}"
    fi
}

empty_test() {
    desc=$1
    input=$2
    result=$($PS $input | wc -l)
    if [ "$result" -eq 0 ]; then
        print_result "OK" "$desc"
    else
        print_result "KO" "$desc"
    fi
}

test_valid() {
    desc=$1
    input=$2
    result=$("$PS" $input | "$CK" $input)
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
    total_ops=0
    size=$(( $(echo "$input" | wc -w) ))

    for i in $(seq 1 $nb_tests); do
        result=$("$PS" $input | "$CK" $input)
        if [ "$result" = "KO" ]; then
            failed_tests=$((failed_tests + 1))
            print_result "KO" "$desc"
            return 1
        fi
        if [ "$nb_tests" -gt 1 ]; then
            input=$(shuf -i 1-10000 -n $size | tr '\n' ' ' | sed 's/ $//')
        fi

        output=$($PS $input)
        ops=$(echo "$output" | wc -l)
        total_ops=$((total_ops + ops))

        percent=$((i * 100 / nb_tests ))
        padding=$((MAX_DESC_LENGTH - ${#desc}))
        printf "\r%s%*s :%3d%%" "$desc" "$padding" "" "$percent"

        if [ "$ops" -gt "$max_ops" ]; then
            fail=1
        fi
    done

    average_ops=$((total_ops / nb_tests))
    average_ops=$((total_ops / nb_tests))

    size=$(echo "$input" | wc -w)
    if [ "$size" = 100 ]; then
        avg_ops_100=$average_ops
    elif [ "$size" = 500 ]; then
        avg_ops_500=$average_ops
    fi

    printf "\r%*s\r" $((MAX_DESC_LENGTH + 10)) ""
    padding=$((MAX_DESC_LENGTH - ${#desc}))
    printf "%s%*s : " "$desc" "$padding" ""

    if [ "$fail" -eq 0 ]; then
        echo -e "${GREEN}OK${NC} ~> avg $average_ops ops"
    else
        failed_tests=$((failed_tests + 1))
        echo -e "${RED}KO${NC} ~> avg $average_ops ops (Too many operations in at least one test)"
    fi
}

test_leaks() {
    desc=$1
    args=$2

    if ! command -v valgrind &> /dev/null; then
        print_result "KO" "$desc"
        echo "[Valgrind not installed]"
        return
    fi

    valgrind_output=$(LANG=C valgrind $PS $args 2>&1)
    lost_line=$(echo "$valgrind_output" | grep "definitely lost:" | head -1)

    if [ -n "$lost_line" ]; then
        lost_bytes=$(echo "$lost_line" | awk '{print $4}')
        if ! [[ "$lost_bytes" =~ ^[0-9]+$ ]]; then
            print_result "KO" "$desc"
            echo "[Valgrind parsing error: lost_bytes='$lost_bytes']"
            return
        fi
        if [ "$lost_bytes" -eq 0 ]; then
            print_result "OK" "$desc"
        else
            printf "%-50s : %b%s%b %s\n" "$desc" "$RED" "KO" "$NC" "[definitely lost = $lost_bytes bytes]"
        fi
    else
        freed_line=$(echo "$valgrind_output" | grep "All heap blocks were freed -- no leaks are possible")
        if [ -n "$freed_line" ]; then
            print_result "OK" "$desc"
        else
            print_result "KO" "$desc"
            echo "[Valgrind output missing definitely lost info and no confirmation of no leaks]"
        fi
    fi
}

test_norminette() {
    desc=$1

    norm_output=$(norminette 2>&1)
    error_count=$(echo "$norm_output" | grep -c "Error:")

    if [ "$error_count" -eq 0 ]; then
        print_result "OK" "$desc"
    else
        printf "%-50s : %b%s%b %s\n" "$desc" "$RED" "KO" "$NC" "[$error_count Errors]"
    fi
}

check_forbidden_functions() {
    local forbidden_funcs="printf putchar puts sprintf snprintf strcpy strncpy strcmp strncmp strlen memcpy memset calloc realloc fork open close readv writev dup dup2 execve system"
    local desc="Forbidden functions in source code"
    local found=""

    for f in $forbidden_funcs; do
        local matches
        matches=$(grep -r -w --include=\*.{c,h} "$f" . 2>/dev/null | grep -vE '^\./(build|\.git)/')
        if [ -n "$matches" ]; then
            found="$found$f"$'\n'
        fi
    done

    if [ -z "$found" ]; then
        print_result "OK" "$desc"
        return 0
    else
        found=$(echo "$found" | sed '/^$/d')

        local count
        count=$(echo "$found" | grep -c .)
        printf "%-50s : %b%s%b [%d forbidden function(s) found]\n" "$desc" "$RED" "KO" "$NC" "$count"
        echo "$found" | sed 's/^/  - /'
        return 1
    fi
}

### --- TESTS ---
echo -e "${YELLOW}"
echo "========================================"
echo "       NORMINETTE and FONCTIONS         "
echo "========================================"
echo -e "${NC}"

test_norminette "Norminette"
check_forbidden_functions "Forbidden Fonctions"

echo -e "${YELLOW}"
echo "========================================"
echo "                 Leaks                  "
echo "========================================"
echo -e "${NC}"

test_leaks "Empty list" ""
test_leaks "One number (3)" "3"
test_leaks "Two number (2 1)" "2 1"
test_leaks "Zero in a list (1 3 0 4)" "1 3 0 4"
test_leaks "Basic list (2 1 4 3 5)" "2 1 4 3 5"
test_leaks "Negative list (-2 -1 -4 -3 -5)" "-2 -1 -4 -3 -5"
test_leaks "Sorted list (1 2 3 4 5 6 7 8 9)" "1 2 3 4 5 6 7 8 9"
test_leaks "Error 1 (1 2 3 3) " "1 2 3 3"
test_leaks "Error 2 (a) " "a"
test_leaks "Error 3 (1 4 4.5 3.9) " "1 4 4.5 3.9"
test_leaks "Error 4 (3 6 4a b c) " "3 6 4a b c"
test_leaks "Error 5 (1 2 9 -2147483649 5) " "1 2 9 -2147483649 5"

ARG=$(seq 1 10 | sort -R | tr '\n' ' ')
test_leaks "Small args (10)" "$ARG"

ARG=$(seq 1 100 | sort -R | tr '\n' ' ')
test_leaks "Medium args (100)" "$ARG"

ARG=$(seq 1 1000 | sort -R | tr '\n' ' ')
test_leaks "Big args (1000)" "$ARG"

echo -e "${YELLOW}"
echo "========================================"
echo "         Evaluation Sheet for 42        "
echo "========================================"
echo -e "${NC}"

echo -e "${YELLOW}"
echo "===============  Error  ================"
echo -e "${NC}"

test_error "Duplicate values 1 (2 2)" "2 1 2"
test_error "Duplicate values 2 (2 1 2)" "2 1 2"
test_error "Non-numeric input (a b c)" "a b c"
test_error "Floating point numbers (1.5 2.6)" "1.5 2.6"
test_error "INT_MAX (2 5 2147483648 97)" "2 5 2147483648 97"
test_error "INT_MIN (1 9 5 -2147483649 -5)" "1 9 5 -2147483649 -5"

echo -e "${YELLOW}"
echo "============  Empty Input  ============="
echo -e "${NC}"

empty_test "One number (42)" "42"
empty_test "Already Sorted 1 (2 3)" "2 3"
empty_test "Already Sorted 2 (0 1 2 3)" "0 1 2 3"
empty_test "Already Sorted 3 (0 1 2 3 4 5 6 7 8 9)" "0 1 2 3 4 5 6 7 8 9"

echo -e "${YELLOW}"
echo "============  Simple Cases  ============"
echo -e "${NC}"

three_test1=$(shuf -i 1-10000 -n 3 | tr '\n' ' ' | sed 's/ $//')
three_test2=$(shuf -i 1-10000 -n 3 | tr '\n' ' ' | sed 's/ $//')
three_test3=$(shuf -i 1-10000 -n 3 | tr '\n' ' ' | sed 's/ $//')
five_test1=$(shuf -i 1-10000 -n 5 | tr '\n' ' ' | sed 's/ $//')
five_test2=$(shuf -i 1-10000 -n 5 | tr '\n' ' ' | sed 's/ $//')
five_test3=$(shuf -i 1-10000 -n 5 | tr '\n' ' ' | sed 's/ $//')

test_valid "Three numbers (2 1 0)" "2 1 0"
ARG=$(seq 1 3 | sort -R | tr '\n' ' ')
test_ops_count "3 random elements (< 3 ops)" "$ARG" 3 250

test_valid "Five numbers (1 5 2 4 3)" "1 5 2 4 3"
ARG=$(seq 1 5 | sort -R | tr '\n' ' ')
test_ops_count "5 random elements (< 12 ops)" "$ARG" 12 250

echo -e "${YELLOW}"
echo "=========  Performance Tests  =========="
echo -e "${NC}"

ARG=$(seq 1 100 | sort -R | tr '\n' ' ')
test_ops_count "100 random elements (< 1500 ops)" "$ARG" 1500 250

ARG=$(seq 1 500 | sort -R | tr '\n' ' ')
test_ops_count "500 random elements (< 11500 ops)" "$ARG" 11500 250

calculate_score() {
    score_100=$1
    score_500=$2
    global_score=0
    base_score=(60 - $failed_tests)

    if [ "$score_100" -ge 1 ] && [ "$score_500" -ge 1 ]; then
        if [ "$base_score" -lt 0 ]; then base_score=0; fi
        global_score=$((60 + (score_100 + score_500) * 4))
    else
        global_score=$base_score
    fi

    echo -e "${YELLOW}"
    echo "========================================"
    echo "             Final Result               "
    echo "========================================"
    echo -e "${NC}"

    echo -e "${GREEN}All critical tests passed.${NC}"
    echo -e "100 elements performance: ${score_100}/5"
    echo -e "500 elements performance: ${score_500}/5"
    echo -e "${YELLOW}Estimated score: ${global_score}/100${NC}"
}

get_score1(){
score_100=0
ops_100=$avg_ops_100
if [ "$ops_100" -lt 700 ]; then score_100=5
elif [ "$ops_100" -lt 900 ]; then score_100=4
elif [ "$ops_100" -lt 1100 ]; then score_100=3
elif [ "$ops_100" -lt 1300 ]; then score_100=2
elif [ "$ops_100" -lt 1500 ]; then score_100=1
fi
}
get_score2(){
score_500=0
ops_500=$avg_ops_500
if [ "$ops_500" -lt 5500 ]; then score_500=5
elif [ "$ops_500" -lt 7000 ]; then score_500=4
elif [ "$ops_500" -lt 8500 ]; then score_500=3
elif [ "$ops_500" -lt 10000 ]; then score_500=2
elif [ "$ops_500" -lt 11500 ]; then score_500=1
fi
}
get_score1
get_score2
calculate_score $score_100 $score_500
