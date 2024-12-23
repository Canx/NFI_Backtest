# Backtesting Automation for NostalgiaForInfinity

This project provides an automated solution to perform backtests for the **NostalgiaForInfinity** trading strategy using the `freqtrade` framework. The main script, `backtest.sh`, allows users to test different configurations and scenarios easily.

## Requirements

### Prerequisites

Ensure the following tools are installed:

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
4. **jq**:
   - Required for handling JSON configurations in the scripts.
     ```bash
     sudo apt install jq # For Ubuntu/Debian
     brew install jq     # For macOS
     ```

### Additional Requirements

- **NostalgiaForInfinity Repository**:
  The script will automatically clone or update the repository.
- **User Data Directory**:
  The script creates and manages a `user_data` directory for storing backtest configurations and results.
- **Pairlist Configuration**:
  Place a JSON pairlist configuration file in the `pairlists` folder within the project directory.

## Usage

### Step 1: Clone this repository
Clone the repository containing the backtest script:

```bash
git clone https://github.com/Canx/NFI_Backtest.git
cd NFI_Backtest
```

### Step 2: Configure the script
The `backtest.sh` script is preconfigured with default values for:

- **Exchange**: `binance`
- **Timerange**: `20241201-20241220`
- **Timerange for Data Download**: Two months prior to the backtest range.
- **Pairlist Configuration**: Selected interactively from the `pairlists` folder.

You can modify these values directly in the script or set them dynamically during execution.

### Step 3: Run the script
Execute the backtest script:

```bash
./backtest.sh
```

### Features

The script offers the following options:

1. **Default Backtest**:
   Runs the strategy with default settings.
2. **Backtest Without Derisk**:
   Disables specific risk mitigation parameters.
3. **Test Slots (max_open_trades)**:
   Allows testing the strategy with different numbers of maximum open trades.
4. **Backtest with Custom Disabled Signals**:
   Interactively disables specific long entry signals.

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

### Freqtrade Webserver (Pending Task)

The functionality to run the freqtrade webserver after backtests and visualize signals is planned for future development.

## Contributing

If you want to enhance this project, feel free to open an issue or submit a pull request.

## License

This project is licensed under the MIT License. See the LICENSE file for details.

---

For detailed documentation on Freqtrade and its features, visit the [official Freqtrade documentation](https://www.freqtrade.io/).