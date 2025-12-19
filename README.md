# Swapinette – Push_swap Tester
**Swapinette** is an interactive script to test your [`push_swap`](https://github.com/) project from 42 School.  
It provides two modes:
- **Evaluation Mode** – Automated tests with scoring based on 42's guidelines.
- **Custom Performance Test** – Custom input testing in an interactive loop.

---

## Quick Installation
This will download and run the tester directly from GitHub — no need to clone anything manually.
```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/Mrdolls/swapinette/refs/heads/main/install.sh)"
```

---

## Smart Detection && Smart Compilation

No need to download any checker!
The required binaries (checker_linux / checker_Mac) are bundled inside the script's checker_os/ folder and selected automatically based on your OS.

Automatic push_swap detection
You can launch the script from any subfolder of your project — it will automatically locate your push_swap executable and use the correct built-in checker.

Intelligent compilation
If push_swap is not compiled or the executable is missing, Swapinette will automatically run make to build it before running any tests.
This ensures you’re always testing the latest version of your code without manually compiling.

---

## OS Compatibility

- macOS

- Linux
