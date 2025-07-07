# 🧪 Swapinette – Automatic Tester for push_swap

**Swapinette** is a Bash script that automatically tests your `push_swap` program. It:
- Auto-detects your `push_swap` executable and the correct checker for your OS
- Validates if the output is correctly sorted
- Checks the number of operations
- Displays a clean progress bar

![update](https://github.com/user-attachments/assets/f0d78fda-f080-44da-802c-cf4411b4a30c)


---

## 🚀 Quick Installation
This will download and run the tester directly from GitHub — no need to clone anything manually.
```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/Mrdolls/swapinette/refs/heads/main/install.sh)"
```

---

## ✅ Requirements  
Your `push_swap` binary must be compiled and located in the current or any parent directory.

---

## 📦 Usage
```bash
swapinette [-help] [-f] [<nb_tests> <list_size> <max_operations>]
```
| Argument (optional) | Description                                                    |
| ------------------  | ---------------------------------------------------------------|
| `-help`             | Displays the help page.                                        |
| `-f`                | Shows the input for tests that fail the operation count limit. |
| `<nb_tests>`        | Number of random test cases to run                             |
| `<list_size>`       | Number of elements to sort in each test (e.g., `100`)          |
| `<max_operations>`  | Max allowed operations per test (e.g., `700`)                  |

---

## 🧾 Example
```bash
swapinette -f
```
### You will then be prompted:

Number of tests to run        : 100

Size of each list to sort     : 50

Maximum allowed operations    : 550

---

## 💡 Smart Detection

✅ No need to download any checker!
The required binaries (checker_linux / checker_Mac) are bundled inside the script's checker_os/ folder and selected automatically based on your OS.
You can launch the script from any subfolder of your project — it will automatically locate push_swap and use the correct built-in checker.

---

## 🛠 OS Compatibility

✅ macOS (uses checker_Mac)

✅ Linux (uses checker_linux)

❌ Not compatible with Windows
