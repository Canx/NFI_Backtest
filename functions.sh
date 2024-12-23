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

# Perform backtesting based on user choice
run_backtest() {
  TIMERANGE=${1:-$DEFAULT_TIMERANGE}

  echo "Choose the type of backtest to run:"
  echo "1) Default backtest"
  echo "2) Backtest without derisk"
  read -rp "Enter your choice (1 or 2): " choice

  case $choice in
    1)
      echo "Running default backtest..."
      freqtrade backtesting \
        -c "$BACKTEST_CONFIG" \
        -c "$REPO_PATH/tests/backtests/pairlist-backtest-static-focus-group-binance-spot-usdt.json" \
        --timerange "$TIMERANGE" \
        --export trades \
        --timeframe-detail 1m \
        -v
      ;;
    2)
      echo "Running backtest without derisk..."
      freqtrade backtesting \
        -c "$BACKTEST_CONFIG" \
        -c "$REPO_PATH/tests/backtests/pairlist-backtest-static-focus-group-binance-spot-usdt.json" \
        -c "$DISABLE_DERISK_CONFIG" \
        --timerange "$TIMERANGE" \
        --export trades \
        --timeframe-detail 1m \
        -v
      ;;
    *)
      echo "Invalid choice. Please select 1 or 2."
      ;;
  esac
}


# Clean up temporary files
cleanup_temp_configs() {
  rm -f "$BACKTEST_CONFIG" "$DISABLE_DERISK_CONFIG" "$BTC_CONFIG"
}
