#!/bin/bash
source "functions.sh"

# Modificación de main para preguntar por el tipo de backtest
main() {
  check_freqtrade
  select_pairlist_file
  ensure_repo
  ensure_user_data
  generate_temp_configs
  configure_timerange "$DEFAULT_TIMERANGE" "$DEFAULT_TIMERANGE_DOWNLOAD"
  select_nfi_version

  # Preguntar una vez por el tipo de backtest
  select_backtest_type

  echo "Downloading data..."
  download_data

  echo "Running segmented backtests..."
  run_backtest "$TIMERANGE"

  echo "Cleaning up temporary files..."
  cleanup_temp_configs

  echo "Backtesting completed."
}

# Ejecutar la función principal
main



