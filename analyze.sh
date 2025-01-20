#!/bin/bash
source "functions.sh"

ANALYSIS_GROUPS="0 1 2 3 4 5"

list_backtests() {
  echo "Available backtest results:"

  # Store the list of files in an array, sorted by modification time
  mapfile -t files < <(find "$BACKTESTS_DIR" -type f -name '*.json' \
         -not -name '*meta.json' \
         -not -name '.*.json' -print0 | xargs -0 ls -t)

  # Print the files with numbers
  for i in "${!files[@]}"; do
    printf "%d. %s\n" "$((i + 1))" "${files[i]}"
  done
}

select_backtest() {
  echo "Select a backtest file by number:"
  list_backtests

  read -rp "Enter the number of the file to analyze: " choice

  # Check if choice is a valid number
  if ! [[ "$choice" =~ ^[0-9]+$ ]]; then
    echo "Invalid selection. Exiting."
    exit 1
  fi

  # Check if choice is within the range of available files
  if (( choice < 1 || choice > ${#files[@]} )); then
    echo "Invalid selection. Exiting."
    exit 1
  fi

  # Select the file based on the choice
  backtest_file="${files[choice-1]}"

  echo "Selected file: $backtest_file"
}

show_results_and_analyze() {
  select_backtest
  show_backtest "$backtest_file"

  echo "Do you want to run analysis on the selected backtest? (y/n)"
  read -rp "Your choice: " analyze_choice

  if [[ "$analyze_choice" == "y" || "$analyze_choice" == "Y" ]]; then
    run_analysis "$backtest_file"
  else
    echo "Analysis skipped."
  fi
}

main() {
  check_freqtrade

  echo "Starting backtest analysis..."

  select_pairlist_file
  
  # Generate temporary configuration files
  generate_temp_configs

  # Ensure there are backtest results available
  if [[ ! -d "$BACKTESTS_DIR" || -z $(find "$BACKTESTS_DIR" -name "*.json") ]]; then
    echo "No backtest results found in $BACKTESTS_DIR. Exiting."
    exit 1
  fi

  show_results_and_analyze

  # Cleanup
  echo "Cleaning up temporary files..."
  cleanup_temp_configs
}

main



