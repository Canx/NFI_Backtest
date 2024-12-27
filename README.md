# Backtesting Automation for NostalgiaForInfinity

This project provides an automated solution to perform backtests for the **NostalgiaForInfinity** trading strategy using the `freqtrade` framework. The main scripts, `backtest.sh` and `analyze.sh`, allow users to test configurations and analyze results.

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
Clone the repository containing the backtest and analysis scripts:

```bash
git clone https://github.com/Canx/NFI_Backtest.git
cd NFI_Backtest
```

### Step 2: Run a Backtest
Run the backtesting script to generate results:

```bash
./backtest.sh
```

### Step 3: Analyze Backtest Results

To analyze backtest results, use the `analyze.sh` script. This script allows you to:

1. View the details of a specific backtest file.
2. Optionally run further analysis on the selected backtest file.

#### Running the Analysis Script

Execute the analysis script:

```bash
./analyze.sh
```

#### Features of `analyze.sh`

1. **View Backtest Results**:
   The script lists all backtest results saved in the `user_data/backtest_results/` directory. You can select a file to view its details interactively.

2. **Run Detailed Analysis**:
   After selecting a backtest file, the script gives you the option to run detailed analysis using `freqtrade backtesting-analysis`.

### Example Workflow

1. Run the backtest script to generate results:
   ```bash
   ./backtest.sh
   ```

2. Analyze the results using the `analyze.sh` script:
   ```bash
   ./analyze.sh
   ```

3. Follow the prompts to select and analyze a specific backtest file.

### Results

Backtest results are saved in the `user_data/backtest_results/` directory. Example file names include:

- **Type of Backtest**: `default`, `noderisk`, or `slots`.
- **Version**: The current branch, tag, or commit of the NostalgiaForInfinity repository.
- **Timerange**: The backtesting period.
- **Timestamp**: When the test was run.

Example:

```plaintext
results_slots_5_main_20241201-20241220_20241223_123456.json
```

## Contributing

If you want to enhance this project, feel free to open an issue or submit a pull request.

## License

This project is licensed under the MIT License. See the LICENSE file for details.

---

For detailed documentation on Freqtrade and its features, visit the [official Freqtrade documentation](https://www.freqtrade.io/).
