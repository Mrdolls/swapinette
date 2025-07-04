# Push_Swap Tester 🧪

A Bash script to automatically test your `push_swap` project with a checker and validate performance constraints.

## 🔧 Features

- Verifies the correctness of your `push_swap` output using a checker.
- Ensures the number of operations stays within a specified limit.
- Shows a progress bar for both verification and performance tests.
- Optional flag to display arguments when a test fails.

## 📝 Usage

```bash
./test.sh [-a] <executable> <checker> <nb_tests> <list_size> <max_operations>
```

| Argument           | Description                                                  |
| ------------------ | ------------------------------------------------------------ |
| `-a` *(optional)*  | Show the list of arguments when a test fails                 |
| `<executable>`     | The `push_swap` executable to test                           |
| `<checker>`        | The checker program (e.g., `checker_linux` or `checker_Mac`) |
| `<nb_tests>`       | Number of random test cases to run                           |
| `<list_size>`      | Size of the list to generate for each test                   |
| `<max_operations>` | Maximum number of allowed operations per test                |

Example
```bash
./test.sh -a ./push_swap ./checker_linux 100 50 550
```

📦 Requirements

    bash

    shuf (GNU coreutils)

    wc

    A valid push_swap executable and compatible checker (e.g., from 42 project)
