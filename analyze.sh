#!/bin/bash

# Configuration
SCRIPT_DIR="$(dirname $(realpath $0))"
source "$SCRIPT_DIR/functions.sh"
ANALYSIS_GROUPS="0 1 2 3 4 5"

list_backtests() {
  echo "Available backtest results:"
  # Filtrar solo los archivos relevantes con '(backtest).json' en su nombre
  find "$USER_DATA_DIR" -type f -name "*\\(backtest\\).json" | nl
}

select_backtest() {
  echo "Select a backtest file by number:"
  list_backtests
  read -rp "Enter the number of the file to analyze: " choice

  # Obtener el archivo seleccionado
  backtest_file=$(find "$USER_DATA_DIR" -type f -name "*\\(backtest\\).json" | sed -n "${choice}p")

  if [[ -z "$backtest_file" ]]; then
    echo "Invalid selection. Exiting."
    exit 1
  fi

  echo "Selected file: $backtest_file"
}

# Validar si el archivo de señales existe
validate_signals_file() {
  local base_file=$1
  local signals_file="${base_file%.*}_signals.pkl"

  if [[ ! -f "$signals_file" ]]; then
    echo "Error: Signals file not found for $base_file"
    echo "Expected: $signals_file"
    exit 1
  fi

  echo "Found signals file: $signals_file"
  echo "$signals_file"  # Devolver el archivo de señales
}

run_analysis() {
  local backtest_file=$1

  echo "Running analysis on $backtest_file..."
  freqtrade backtesting-analysis \
    -c "$BACKTEST_CONFIG" \
    --userdir "$SCRIPT_DIR/user_data" \
    --export-filename="$backtest_file" \
    --analysis-groups $ANALYSIS_GROUPS
}




main() {
  echo "Starting backtest analysis..."

  # Generate temporary config files
  generate_temp_configs

  # Ensure there are backtest results available
  if [[ ! -d "$USER_DATA_DIR" || -z $(find "$USER_DATA_DIR" -name "*.json") ]]; then
    echo "No backtest results found in $USER_DATA_DIR. Exiting."
    exit 1
  fi

  # Select a backtest file
  select_backtest

  # Run analysis
  run_analysis "$backtest_file"

  # Cleanup
  echo "Cleaning up temporary files..."
  cleanup_temp_configs
}

main

