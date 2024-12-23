# Ensure NostalgiaForInfinity repository exists
ensure_repo() {
  if [ ! -d "$REPO_PATH" ]; then
    echo "NostalgiaForInfinity repository not found. Cloning..."
    git clone "$REPO_URL" "$REPO_PATH"
    if [ $? -ne 0 ]; then
      echo "Error: Failed to clone the repository."
      exit 1
    fi
  else
    echo "NostalgiaForInfinity repository already exists at $REPO_PATH."
  fi
}

# Function to configure timerange
configure_timerange() {
  local default_timerange=${1:-$DEFAULT_TIMERANGE}
  local default_timerange_download=${2:-$DEFAULT_TIMERANGE_DOWNLOAD}

  echo "Current TIMERANGE: $default_timerange"
  read -rp "Enter new TIMERANGE (or press Enter to keep default): " new_timerange

  # If the user enters a new timerange, use it; otherwise, keep the default
  TIMERANGE=${new_timerange:-$default_timerange}

  echo "How many days before TIMERANGE should be included in TIMERANGE_DOWNLOAD?"
  read -rp "Enter the number of days (default: 60): " days_before
  days_before=${days_before:-60}

  # Calculate TIMERANGE_DOWNLOAD
  TIMERANGE_START=$(echo "$TIMERANGE" | cut -d'-' -f1)
  TIMERANGE_DOWNLOAD=$(date -d "$TIMERANGE_START - $days_before days" +"%Y%m%d")-$TIMERANGE_START

  echo "New TIMERANGE: $TIMERANGE"
  echo "New TIMERANGE_DOWNLOAD: $TIMERANGE_DOWNLOAD"
}

# Function to select a specific version of the NFI repository
select_nfi_version() {
  local default_branch="main"

  echo "Fetching the latest updates from the repository..."
  git -C "$REPO_PATH" fetch --all --tags

  # Show the current branch
  current_branch=$(git -C "$REPO_PATH" rev-parse --abbrev-ref HEAD)
  echo "Currently checked out branch: $current_branch"

  echo "Choose a version type:"
  echo "1) Latest version of '$default_branch' (default)"
  echo "2) Branch"
  echo "3) Commit"
  echo "4) Tag"
  read -rp "Enter your choice (1, 2, 3, or 4, default: 1): " version_type

  version_type=${version_type:-1} # Default to 1 if no input

  case $version_type in
    1)
      echo "Switching to the latest version of '$default_branch'..."
      git -C "$REPO_PATH" checkout "$default_branch" 2>/dev/null || {
        echo "Error: Failed to switch to '$default_branch'."
        exit 1
      }
      git -C "$REPO_PATH" pull origin "$default_branch"
      ;;
    2)
      read -rp "Enter branch name (or press Enter to keep '$default_branch'): " selected_version
      selected_version=${selected_version:-$default_branch}
      echo "Switching to branch: $selected_version..."
      git -C "$REPO_PATH" checkout "$selected_version" 2>/dev/null || {
        echo "Error: Branch '$selected_version' does not exist."
        exit 1
      }
      git -C "$REPO_PATH" pull origin "$selected_version"
      ;;
    3)
      read -rp "Enter commit hash: " selected_version
      echo "Switching to commit: $selected_version..."
      git -C "$REPO_PATH" checkout "$selected_version" 2>/dev/null || {
        echo "Error: Commit '$selected_version' does not exist."
        exit 1
      }
      ;;
    4)
      echo "Available tags:"
      git -C "$REPO_PATH" tag
      read -rp "Enter tag name: " selected_version
      echo "Switching to tag: $selected_version..."
      git -C "$REPO_PATH" checkout "tags/$selected_version" 2>/dev/null || {
        echo "Error: Tag '$selected_version' does not exist."
        exit 1
      }
      ;;
    *)
      echo "Invalid choice. Defaulting to the latest version of '$default_branch'."
      git -C "$REPO_PATH" checkout "$default_branch" 2>/dev/null || {
        echo "Error: Failed to switch to '$default_branch'."
        exit 1
      }
      git -C "$REPO_PATH" pull origin "$default_branch"
      ;;
  esac

  echo "Repository is now on version: $(git -C "$REPO_PATH" rev-parse --short HEAD)"
}

# Function to get the current repository version
get_repo_version() {
  local branch=$(git -C "$REPO_PATH" rev-parse --abbrev-ref HEAD)
  local tag=$(git -C "$REPO_PATH" describe --tags --exact-match 2>/dev/null)
  local commit=$(git -C "$REPO_PATH" rev-parse --short HEAD)

  if [ -n "$tag" ]; then
    echo "$tag"
  elif [ "$branch" == "HEAD" ]; then
    echo "$commit"
  else
    echo "$branch"
  fi
}


# Ensure user_data directory exists and setup symbolic link for strategy
ensure_user_data() {
  if [ ! -d "$USER_DATA_DIR" ]; then
    echo "Creating user_data directory at $USER_DATA_DIR..."
    freqtrade create-userdir --userdir "$USER_DATA_DIR"
    if [ $? -ne 0 ]; then
      echo "Error: Failed to create user_data directory."
      exit 1
    fi
  else
    echo "user_data directory already exists at $USER_DATA_DIR."
  fi

  # Ensure strategies directory exists
  STRATEGIES_DIR="$USER_DATA_DIR/strategies"
  if [ ! -d "$STRATEGIES_DIR" ]; then
    mkdir -p "$STRATEGIES_DIR"
    echo "Created strategies directory at $STRATEGIES_DIR."
  fi

  # Ensure symbolic link for NostalgiaForInfinityX5.py
  STRATEGY_FILE="$REPO_PATH/NostalgiaForInfinityX5.py"
  STRATEGY_LINK="$STRATEGIES_DIR/NostalgiaForInfinityX5.py"

  if [ ! -L "$STRATEGY_LINK" ]; then
    if [ -f "$STRATEGY_FILE" ]; then
      ln -s "$STRATEGY_FILE" "$STRATEGY_LINK"
      echo "Created symbolic link for strategy: $STRATEGY_LINK -> $STRATEGY_FILE"
    else
      echo "Error: Strategy file not found at $STRATEGY_FILE."
      exit 1
    fi
  else
    echo "Symbolic link for strategy already exists: $STRATEGY_LINK"
  fi
}


# Generate temporary configuration files
generate_temp_configs() {
  BACKTEST_CONFIG=$(mktemp)
  DISABLE_DERISK_CONFIG=$(mktemp)
  BTC_CONFIG=$(mktemp)

# Generate temp config files
cat << EOF > "$BACKTEST_CONFIG"
  {
    "strategy": "NostalgiaForInfinityX5",
    "add_config_files": [
      "$REPO_PATH/configs/trading_mode-spot.json",
      "$REPO_PATH/configs/exampleconfig.json",
      "$REPO_PATH/configs/exampleconfig_secret.json"
    ]
  }
EOF

cat << EOF > "$DISABLE_DERISK_CONFIG"
  {
    "derisk_enable": false,
    "stop_threshold_doom_spot": 0.99
  }
EOF

cat << EOF > "$BTC_CONFIG"
  {
    "exchange": {
      "name": "$EXCHANGE",
      "pair_whitelist": [
        "BTC/USDT"
      ]
    },
    "pairlists": [
      {
        "method": "StaticPairList"
      }
    ]
  }
EOF

}

validate_feather_files() {
  local data_dir="$USER_DATA_DIR/data/$EXCHANGE"
  for file in "$data_dir"/*.feather; do
    if [ -f "$file" ]; then
      if ! python3 -c "import pandas as pd; pd.read_feather('$file')" >/dev/null 2>&1; then
        echo "Corrupted file detected: $file. Removing..."
        rm "$file"
      fi
    fi
  done
}

download_data() {
  TIMERANGE_DOWNLOAD=${1:-$DEFAULT_TIMERANGE_DOWNLOAD}
  PAIRLIST_CONFIG="$REPO_PATH/tests/backtests/pairlist-backtest-static-focus-group-binance-spot-usdt.json"

  echo "Downloading data for pairs in $PAIRLIST_CONFIG with timerange $TIMERANGE_DOWNLOAD..."
  freqtrade download-data \
    --exchange "$EXCHANGE" \
    -t 1m 5m 15m 1h 4h 1d \
    -c "$PAIRLIST_CONFIG" \
    --timerange "$TIMERANGE_DOWNLOAD" \
    --prepend

  echo "Validating downloaded data..."
  validate_feather_files
  echo "Data download and validation completed successfully."
}

# Function for default backtest
run_default_backtest() {
  local timerange=$1
  local results_dir="$USER_DATA_DIR/backtest_results"
  local timestamp=$(date +"%Y%m%d_%H%M%S")
  local repo_version=$(get_repo_version)
  local results_file="$results_dir/default_${repo_version}_${timerange}_${timestamp}.json"

  # Ensure results directory exists
  mkdir -p "$results_dir"

  echo "Running default backtest..."
  freqtrade backtesting \
    -c "$BACKTEST_CONFIG" \
    -c "$REPO_PATH/tests/backtests/pairlist-backtest-static-focus-group-binance-spot-usdt.json" \
    --timerange "$timerange" \
    --export trades --export signals \
    --export-filename "$results_file" \
    --timeframe-detail 1m \
    -v
  echo "Results saved to $results_file"
}

# Function for backtest without derisk
run_noderisk_backtest() {
  local timerange=$1
  local results_dir="$USER_DATA_DIR/backtest_results"
  local timestamp=$(date +"%Y%m%d_%H%M%S")
  local repo_version=$(get_repo_version)
  local results_file="$results_dir/noderisk_${repo_version}_${timerange}_${timestamp}.json"

  # Ensure results directory exists
  mkdir -p "$results_dir"

  echo "Running backtest without derisk..."
  freqtrade backtesting \
    -c "$BACKTEST_CONFIG" \
    -c "$REPO_PATH/tests/backtests/pairlist-backtest-static-focus-group-binance-spot-usdt.json" \
    -c "$DISABLE_DERISK_CONFIG" \
    --timerange "$timerange" \
    --export trades --export signals \
    --export-filename "$results_file" \
    --timeframe-detail 1m \
    -v
  echo "Results saved to $results_file"
}

# Function to test different max_open_trades values
test_slots() {
  local timerange=${1:-$DEFAULT_TIMERANGE}
  local max_slots=10
  local results_dir="$USER_DATA_DIR/backtest_results"
  local timestamp=$(date +"%Y%m%d_%H%M%S")
  local repo_version=$(get_repo_version)

  # Ensure results directory exists
  mkdir -p "$results_dir"

  echo "Testing different values for max_open_trades (slots) (version: $repo_version)..."
  for slots in $(seq 1 "$max_slots"); do
    local slots_config=$(mktemp)
    local results_file="$results_dir/results_slots_${slots}_${repo_version}_${timerange}_${timestamp}.json"

    # Create temporary configuration for current slots
    cat << EOF > "$slots_config"
{
  "max_open_trades": $slots
}
EOF

    echo "Running backtest with $slots slots..."
    freqtrade backtesting \
      -c "$BACKTEST_CONFIG" \
      -c "$REPO_PATH/tests/backtests/pairlist-backtest-static-focus-group-binance-spot-usdt.json" \
      -c "$slots_config" \
      --timerange "$timerange" \
      --export signals \
      --export-filename "$results_file" \
      --timeframe-detail 1m \
      -v

    echo "Backtesting with $slots slots completed. Results saved to $results_file."

    # Clean up temporary configuration file
    rm -f "$slots_config"
  done

  echo "Slot testing completed. Results saved in $results_dir."
}


# Perform backtesting based on user choice
run_backtest() {
  local timerange=${1:-$DEFAULT_TIMERANGE}

  echo "Choose the type of backtest to run:"
  echo "1) Default backtest"
  echo "2) Backtest without derisk"
  echo "3) Test different max_open_trades (slots)"
  read -rp "Enter your choice (1, 2, or 3): " choice

  case $choice in
    1)
      run_default_backtest "$timerange"
      ;;
    2)
      run_noderisk_backtest "$timerange"
      ;;
    3)
      test_slots "$timerange"
      ;;
    *)
      echo "Invalid choice. Please select 1, 2, or 3."
      ;;
  esac
}


# Clean up temporary files
cleanup_temp_configs() {
  rm -f "$BACKTEST_CONFIG" "$DISABLE_DERISK_CONFIG" "$BTC_CONFIG"
}
