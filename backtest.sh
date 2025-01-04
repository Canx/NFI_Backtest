#!/bin/bash
source "functions.sh"

# Function to split the TIMERANGE into monthly segments
split_timerange_into_months() {
  local start_date=$(echo "$1" | cut -d'-' -f1)
  local end_date=$(echo "$1" | cut -d'-' -f2)

  # Convert start and end dates to a format usable by date command
  local start_date_formatted=$(date -d "$start_date" +"%Y-%m-%d")
  local end_date_formatted=$(date -d "$end_date" +"%Y-%m-%d")

  local current_date=$start_date_formatted
  local segments=()

  while [[ "$current_date" < "$end_date_formatted" ]]; do
    # Get the first day of the next month
    local next_month=$(date -d "$current_date +1 month" +"%Y-%m-01")

    # If the next month starts after the end date, adjust to the end date
    if [[ "$next_month" > "$end_date_formatted" ]]; then
      next_month=$end_date_formatted
    fi

    # Format the segment as YYYYMMDD-YYYYMMDD and add to the segments array
    local segment=$(date -d "$current_date" +"%Y%m%d")-$(date -d "$next_month -1 day" +"%Y%m%d")
    segments+=("$segment")

    # Update current_date to the start of the next month
    current_date=$next_month
  done

  echo "${segments[@]}"
}

# Overriding the run_backtest function to include segmentation
run_backtest() {
  local timerange=${1:-$DEFAULT_TIMERANGE}
  local pairlist_config="$PAIRLIST_FILE"

  # Check if the timerange spans multiple months
  local segments=($(split_timerange_into_months "$timerange"))

  echo "Backtesting across the following segments:"
  for segment in "${segments[@]}"; do
    echo "$segment"
  done

  # Iterate through each segment and run the backtest
  for segment in "${segments[@]}"; do
    echo "Running backtest for segment: $segment"

    # Call the original backtest logic for each segment
    run_default_backtest "$segment" "$pairlist_config"
  done

  echo "All segmented backtests completed."
}

# Main function remains mostly unchanged
main() {
  check_freqtrade
  select_pairlist_file
  ensure_repo
  ensure_user_data
  generate_temp_configs
  configure_timerange "$DEFAULT_TIMERANGE" "$DEFAULT_TIMERANGE_DOWNLOAD"
  select_nfi_version

  echo "Downloading data..."
  download_data

  echo "Running segmented backtests..."
  run_backtest "$TIMERANGE"

  echo "Cleaning up temporary files..."
  cleanup_temp_configs

  echo "Backtesting completed."
}

# Execute main function
main





