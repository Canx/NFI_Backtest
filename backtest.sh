#!/bin/bash
source "functions.sh"

main() {
  select_pairlist_file
  ensure_repo
  ensure_user_data
  generate_temp_configs
  configure_timerange "$DEFAULT_TIMERANGE" "$DEFAULT_TIMERANGE_DOWNLOAD"
  select_nfi_version

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




