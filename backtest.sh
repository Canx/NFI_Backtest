#!/bin/bash

# General settings
REPO_URL="https://github.com/iterativv/NostalgiaForInfinity.git"
REPO_NAME="NostalgiaForInfinity"
USER_DATA_DIR="user_data"
EXCHANGE="binance"
DEFAULT_TIMERANGE="20241201-20241220"
DEFAULT_TIMERANGE_DOWNLOAD="20241007-20241220"

# Get the script's directory
SCRIPT_DIR=$(dirname "$(realpath "$0")")
REPO_PATH="$SCRIPT_DIR/$REPO_NAME"
USER_DATA_DIR="$SCRIPT_DIR/$USER_DATA_DIR"

# Import functions
source "$SCRIPT_DIR/functions.sh"

main() {
  ensure_repo
  ensure_user_data
  generate_temp_configs
  configure_timerange "$DEFAULT_TIMERANGE" "$DEFAULT_TIMERANGE_DOWNLOAD"

  echo "Downloading data..."
  download_data "$TIMERANGE_DOWNLOAD"

  echo "Running backtests..."
  run_backtest "$TIMERANGE"

  echo "Cleaning up temporary files..."
  cleanup_temp_configs

  echo "Backtesting completed."
}

# Execute main function
main




