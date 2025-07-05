# 🧪 Swapinette – Automatic Tester for push_swap

**Swapinette** is a Bash script that automatically tests your `push_swap` program. It:
- Auto-detects your `push_swap` executable and the correct checker for your OS
- Validates if the output is correctly sorted
- Checks the number of operations
- Displays a clean progress bar

![read](https://github.com/user-attachments/assets/ad660d2f-199a-4cc0-b7ea-4a5f1790fa6c)

---

## 🚀 Quick Installation
This will download and run the tester directly from GitHub — no need to clone anything manually.
```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/Mrdolls/swapinette/refs/heads/main/install.sh)"
```


## ✅ Requirements

Your push_swap binary must be compiled and present (in the current or a parent directory).
The appropriate checker (checker_linux or checker_Mac) must also be present and executable.

## 📦 Usage
```bash
swapinette <nb_tests> <list_size> <max_operations>
```
| Argument           | Description                                           |
| ------------------ | ----------------------------------------------------- |
| `<nb_tests>`       | Number of random test cases to run                    |
| `<list_size>`      | Number of elements to sort in each test (e.g., `100`) |
| `<max_operations>` | Max allowed operations per test (e.g., `700`)         |

## 🧾 Example
```bash
swapinette 100 50 550
```
• Runs 100 tests

• Each test uses a list of 50 integers

• Fails if more than 550 operations are used

## 💡 Smart Detection

You can launch the script from any subfolder of your project. It will automatically search upward to locate push_swap and the correct checker binary.

## 🛠 OS Compatibility

✅ macOS (uses checker_Mac)

✅ Linux (uses checker_linux)

❌ Not compatible with Windows
