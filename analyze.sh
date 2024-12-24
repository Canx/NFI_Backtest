#!/bin/bash
source "functions.sh"

ANALYSIS_GROUPS="0 1 2 3 4 5"

list_backtests() {
  echo "Available backtest results:"
  find "$BACKTESTS_DIR" -type f -name "*.json" | nl
}

select_backtest() {
  echo "Select a backtest file by number:"
  list_backtests
  read -rp "Enter the number of the file to analyze: " choice

  backtest_file=$(find "$BACKTESTS_DIR" -type f -name "*.json" | sed -n "${choice}p")

  if [[ -z "$backtest_file" ]]; then
    echo "Invalid selection. Exiting."
    exit 1
  fi

  echo "Selected file: $backtest_file"
}

run_analysis() {
  local backtest_file=$1

  echo "Running analysis on $backtest_file..."
  freqtrade backtesting-analysis \
      -c "$BACKTEST_CONFIG" \
      -c "$PAIRLIST_FILE" \
      --userdir "$SCRIPT_DIR/user_data" \
      --export-filename="$backtest_file" \
      --analysis-groups $ANALYSIS_GROUPS
}

main() {
  echo "Starting backtest analysis..."

  select_pairlist_file
  
  # Generate temporary configuration files
  generate_temp_configs

  # Ensure there are backtest results available
  if [[ ! -d "$BACKTESTS_DIR" || -z $(find "$BACKTESTS_DIR" -name "*.json") ]]; then
    echo "No backtest results found in $BACKTESTS_DIR. Exiting."
    exit 1
  fi

  # Select a backtest file
  select_backtest

  # Run analysis
  run_analysis "$backtest_file"

  # Cleanup
  echo "Cleaning up temporary files..."
  #cleanup_temp_configs
}

main



