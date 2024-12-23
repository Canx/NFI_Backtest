# Backtesting Automation for NostalgiaForInfinity

This project provides an automated solution to run backtests for the **NostalgiaForInfinity** trading strategy using the `freqtrade` framework. The main script, `backtest.sh`, allows users to test different configurations and scenarios easily.

## Requirements

### Prerequisites

Ensure that the following tools are installed:

1. **Python**: Version 3.9 or later is required.
   - Install using [pyenv](https://github.com/pyenv/pyenv) or your system's package manager.
2. **Freqtrade**:
   - Install the latest stable version of freqtrade:
     ```bash
     pip install freqtrade
     ```
3. **Git**:
   - Required to clone and update the NostalgiaForInfinity repository.
     ```bash
     sudo apt install git # For Ubuntu/Debian
     brew install git     # For macOS
     ```

### Additional Requirements

- **NostalgiaForInfinity Repository**:
  The script will automatically clone or update the repository.
- **User Data Directory**:
  The script creates and manages a `user_data` directory for storing backtest configurations and results.
- **Pairlist Configuration**:
  Place a file named `pairlist.json` in the root directory (next to `backtest.sh`).

## Usage

### Step 1: Clone this repository
Clone the repository containing the backtest script:

```bash
git clone https://github.com/Canx/NFI_Backtest.git
cd NFI_Backtest
```

### Step 2: Configure the script
The `backtest.sh` script is pre-configured with default values for:

- **Exchange**: `binance`
- **Timerange**: `20241201-20241220`
- **Timerange for Data Download**: Two months before the backtest timerange.
- **Pairlist Configuration**: Ensure `pairlist.json` is present in the root directory.

You can modify these values in the script or dynamically set them during execution.

### Step 3: Run the script
Execute the backtest script:

```bash
./backtest.sh
```

### Features

The script provides the following options:

1. **Default Backtest**:
   Runs the strategy with default settings.
2. **Backtest Without Derisk**:
   Disables specific risk mitigation parameters.
3. **Test Slots (max_open_trades)**:
   Tests the strategy with varying numbers of `max_open_trades` and outputs results for analysis.
4. **Backtest with custom disabled signals**:
   Allows you to disable specific long entry signals interactively.

### Results

Backtest results are saved in the `user_data/backtest_results/` directory. File names include:

- **Type of Backtest**: `default`, `noderisk`, or `slots`.
- **Version**: The current branch, tag, or commit of the NostalgiaForInfinity repository.
- **Timerange**: The backtesting period.
- **Timestamp**: When the test was run.

Example:

```plaintext
results_slots_5_main_20241201-20241220_20241223_123456.json
```

### Analyzing Results

To analyze backtest results, use `freqtrade backtesting-analysis`. For example:

```bash
freqtrade backtesting-analysis --export-filename /path/to/results.json
```

## Contributing

Feel free to open issues or submit pull requests to enhance the functionality of this project.

## License

This project is licensed under the MIT License. See the LICENSE file for details.

---

For detailed documentation on Freqtrade and its features, visit the [official Freqtrade documentation](https://www.freqtrade.io/).