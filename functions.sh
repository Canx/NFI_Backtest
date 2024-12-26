# Global Configuration Variables
REPO_URL="https://github.com/iterativv/NostalgiaForInfinity.git"
REPO_NAME="NostalgiaForInfinity"
USER_DATA_DIR="user_data"

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
BACKTESTS_DIR="$SCRIPT_DIR/user_data/backtest_results"
REPO_PATH="$(realpath "$SCRIPT_DIR/../$REPO_NAME")"
USER_DATA_DIR="$SCRIPT_DIR/user_data"
EXCHANGE="binance"
DEFAULT_TIMERANGE="20241201-20241220"


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

# Function to configure timerange, using saved configuration if available
configure_timerange() {
  # Try to load the timerange from the saved configuration
  load_timerange_config

  # If TIMERANGE is still empty, prompt the user for input
  if [ -z "$TIMERANGE" ]; then
    echo "Current TIMERANGE: $DEFAULT_TIMERANGE"
    read -rp "Enter new TIMERANGE (or press Enter to keep default): " new_timerange
    TIMERANGE=${new_timerange:-$DEFAULT_TIMERANGE}
  fi

  # Save the selected timerange to the config file for future use
  save_timerange_config "$TIMERANGE"

  echo "New TIMERANGE: $TIMERANGE"
  
  # Continue with the rest of the process as before
  local default_timerange_download=${1:-$DEFAULT_TIMERANGE_DOWNLOAD}
  echo "How many days before TIMERANGE should be included in TIMERANGE_DOWNLOAD?"
  read -rp "Enter the number of days (default: 60): " days_before
  days_before=${days_before:-60}

  # Calculate TIMERANGE_DOWNLOAD
  TIMERANGE_START=$(echo "$TIMERANGE" | cut -d'-' -f1)
  TIMERANGE_DOWNLOAD=$(date -d "$TIMERANGE_START - $days_before days" +"%Y%m%d")-$TIMERANGE_START

  echo "New TIMERANGE_DOWNLOAD: $TIMERANGE_DOWNLOAD"
}


# Save the timerange configuration to backtest.json
save_timerange_config() {
  local timerange=$1
  local config_file="$SCRIPT_DIR/backtest.json"  # O usa config.json

  # Create or overwrite the backtest.json file with the new timerange
  cat <<EOF > "$config_file"
{
  "timerange": "$timerange"
}
EOF

  echo "Timerange configuration saved: $timerange"
}


# Load the timerange configuration from backtest.json or config.json
load_timerange_config() {
  local config_file="$SCRIPT_DIR/backtest.json"  # O usa config.json si prefieres

  # Check if the config file exists
  if [ -f "$config_file" ]; then
    # Read the timerange value from the JSON file
    TIMERANGE=$(jq -r '.timerange' "$config_file")
    echo "Loaded timerange from config: $TIMERANGE"
  else
    echo "No previous timerange configuration found. Using default."
    TIMERANGE="$DEFAULT_TIMERANGE"
  fi
}


# Function to configure timerange, using saved configuration if available
configure_timerange() {
  # Try to load the timerange from the saved configuration
  load_timerange_config

  # Always prompt the user to enter a new timerange, showing the last one as the default
  echo "Current TIMERANGE: $TIMERANGE"
  read -rp "Enter new TIMERANGE (or press Enter to keep current): " new_timerange
  
  # If the user doesn't enter anything, keep the last loaded timerange
  TIMERANGE=${new_timerange:-$TIMERANGE}

  # Save the selected timerange to the config file for future use
  save_timerange_config "$TIMERANGE"

  echo "New TIMERANGE: $TIMERANGE"
  
  # Proceed with the timerange download configuration
  local default_timerange_download=${1:-$DEFAULT_TIMERANGE_DOWNLOAD}
  echo "How many days before TIMERANGE should be included in TIMERANGE_DOWNLOAD?"
  read -rp "Enter the number of days (default: 60): " days_before
  days_before=${days_before:-60}

  # Calculate TIMERANGE_DOWNLOAD
  TIMERANGE_START=$(echo "$TIMERANGE" | cut -d'-' -f1)
  TIMERANGE_END=$(echo "$TIMERANGE" | cut -d'-' -f2)
  TIMERANGE_DOWNLOAD=$(date -d "$TIMERANGE_START - $days_before days" +"%Y%m%d")-$TIMERANGE_END

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
  # Usar la variable global $PAIRLIST_FILE
  local pairlist_config="$PAIRLIST_FILE"

  # Verificar disponibilidad de datos
  if check_data_availability "$TIMERANGE_DOWNLOAD"; then
    read -rp "Data is already available. Do you want to re-download it anyway? (y/N): " choice
    if [[ ! $choice =~ ^[Yy]$ ]]; then
      echo "Skipping data download."
      return
    fi
  fi

  echo "Downloading data for pairs in $pairlist_config with timerange $TIMERANGE_DOWNLOAD..."
  freqtrade download-data \
    --exchange "$EXCHANGE" \
    -t 1m 5m 15m 1h 4h 1d \
    -c "$pairlist_config" \
    --timerange "$TIMERANGE_DOWNLOAD"

  echo "Data download completed."
}

# Function to select the pairlist.json file interactively and set the global variable
select_pairlist_file() {
  PAIRLIST_DIR="$SCRIPT_DIR/pairlists"
  DEFAULT_PAIRLIST="$PAIRLIST_DIR/default.json"
  
  # Check if the pairlists directory exists
  if [ ! -d "$PAIRLIST_DIR" ]; then
    echo "The pairlists directory does not exist."
    exit 1
  fi

  # List all JSON files in the pairlists directory
  echo "Select a pairlist file from the '$PAIRLIST_DIR' folder:"
  select pairlist_file in "$PAIRLIST_DIR"/*.json; do
    if [ -z "$pairlist_file" ]; then
      echo "No file selected, using the default file."
      pairlist_file="$DEFAULT_PAIRLIST"
    fi
    echo "Using the pairlist file: $pairlist_file"
    break
  done

  # Assign the selected file to the global variable PAIRLIST_FILE
  PAIRLIST_FILE="$pairlist_file"
}




extract_pairs() {
  local json_file=$1

  # Extrae los pares usando Python
  python3 - <<EOF
import json
import sys

try:
    with open("$json_file", "r") as file:
        data = json.load(file)
        pairs = data.get("exchange", {}).get("pair_whitelist", [])
        if not pairs:
            print("Error: 'pair_whitelist' is empty or not found in the JSON file.")
            sys.exit(1)
        for pair in pairs:
            print(pair)
except json.JSONDecodeError as e:
    print(f"JSON validation error in {json_file}: {e}")
    sys.exit(1)
except Exception as e:
    print(f"Unexpected error: {e}")
    sys.exit(1)
EOF
}

check_data_availability() {
  local timerange_download=${1:-$DEFAULT_TIMERANGE_DOWNLOAD}
  local data_dir="$USER_DATA_DIR/data/$EXCHANGE"

  echo "Checking if data directory exists: $data_dir"

  # Comprobar si el directorio de datos contiene archivos
  if [ -d "$data_dir" ] && [ "$(ls -A "$data_dir")" ]; then
    echo "Data directory is not empty. Assuming data is already downloaded."
    return 0
  else
    echo "Data directory is empty or does not exist. Data needs to be downloaded."
    return 1
  fi
}

######################
# Backtest functions #
######################

run_default_backtest() {
  local timerange=$1
  local pairlist_config=$2
  local results_dir="$USER_DATA_DIR/backtest_results"
  local timestamp=$(date +"%Y%m%d_%H%M%S")
  local repo_version=$(get_repo_version)
  local results_file="$results_dir/default_${repo_version}_${timerange}_${timestamp}.json"

  # Ensure results directory exists
  mkdir -p "$results_dir"

  freqtrade backtesting \
    -c "$BACKTEST_CONFIG" \
    -c "$pairlist_config" \
    --timerange "$timerange" \
    --export signals \
    --export-filename "$results_file" \
    --timeframe-detail 1m \
    -v
  echo "Results saved to $results_file"
}


run_noderisk_backtest() {
  local timerange=$1
  local pairlist_config=$2
  local results_dir="$USER_DATA_DIR/backtest_results"
  local timestamp=$(date +"%Y%m%d_%H%M%S")
  local repo_version=$(get_repo_version)
  local results_file="$results_dir/noderisk_${repo_version}_${timerange}_${timestamp}.json"

  # Ensure results directory exists
  mkdir -p "$results_dir"

  echo "Running backtest without derisk..."
  freqtrade backtesting \
    -c "$BACKTEST_CONFIG" \
    -c "$pairlist_config" \
    -c "$DISABLE_DERISK_CONFIG" \
    --timerange "$timerange" \
    --export signals \
    --export-filename "$results_file" \
    --timeframe-detail 1m \
    -v
  echo "Results saved to $results_file"
}


test_slots() {
  local timerange=${1:-$DEFAULT_TIMERANGE}
  local pairlist_config=$2
  local results_dir="$USER_DATA_DIR/backtest_results"
  local timestamp=$(date +"%Y%m%d_%H%M%S")
  local repo_version=$(get_repo_version)

  # Ensure results directory exists
  mkdir -p "$results_dir"

  # Prompt user for the number of slots
  read -rp "Enter the number of max_open_trades (slots) to test: " slots

  # Validate input
  if ! [[ "$slots" =~ ^[0-9]+$ ]] || [ "$slots" -le 0 ]; then
    echo "Invalid input. Please enter a positive integer."
    return 1
  fi

  local slots_config=$(mktemp)
  local results_file="$results_dir/results_slots_${slots}_${repo_version}_${timerange}_${timestamp}.json"

  # Create temporary configuration for the specified slots
  cat << EOF > "$slots_config"
{
  "max_open_trades": $slots
}
EOF

  echo "Running backtest with $slots slots..."
  freqtrade backtesting \
    -c "$BACKTEST_CONFIG" \
    -c "$pairlist_config" \
    -c "$slots_config" \
    --timerange "$timerange" \
    --export signals \
    --export-filename "$results_file" \
    --timeframe-detail 1m \
    -v

  echo "Backtesting with $slots slots completed. Results saved to $results_file."

  # Clean up temporary configuration file
  rm -f "$slots_config"
}


generate_signal_config() {
  local signals_config=$(mktemp)
  local signal_numbers=()

  echo "Enter the numbers of the long signals you want to disable (e.g., 6, 41, 120)." >&2
  echo "Press Enter without input to finish." >&2

  while true; do
    read -rp "Enter signal number to disable (or press Enter to finish): " signal
    if [[ -z $signal ]]; then
      break
    elif [[ $signal =~ ^[0-9]+$ ]]; then
      signal_numbers+=("$signal")
    else
      echo "Invalid input. Please enter a numeric value." >&2
    fi
  done

  if [[ ${#signal_numbers[@]} -eq 0 ]]; then
    echo "No signals were selected to disable. Exiting." >&2
    rm -f "$signals_config"
    return 1
  fi

  echo "Generating signal configuration for disabled signals: ${signal_numbers[*]}..." >&2

  # Crear el archivo JSON
  {
    echo "{"
    echo "  \"long_entry_signal_params\": {"
    for signal in "${signal_numbers[@]}"; do
      echo "    \"long_entry_condition_${signal}_enable\": false,"
    done
    echo "  }"
    echo "}"
  } > "$signals_config"

  # Solo devolver la ruta del archivo
  echo "$signals_config"
}




run_custom_signals_backtest() {
  local timerange=$1
  local pairlist_config=$2
  local signals_config=$3
  local results_dir="$USER_DATA_DIR/backtest_results"
  local timestamp=$(date +"%Y%m%d_%H%M%S")
  local repo_version=$(get_repo_version)
  local results_file="$results_dir/custom_signals_${repo_version}_${timerange}_${timestamp}.json"

  # Verificar la existencia del archivo de configuración de señales
  if [[ ! -f "$signals_config" ]]; then
    echo "Error: Signal configuration file not found: $signals_config"
    return 1
  fi

  echo "Using signal configuration file: $signals_config"
  echo "Content of signal configuration:"
  cat "$signals_config"

  # Ejecutar el backtest
  freqtrade backtesting \
    -c "$BACKTEST_CONFIG" \
    -c "$pairlist_config" \
    -c "$signals_config" \
    --timerange "$timerange" \
    --export signals \
    --export-filename "$results_file" \
    --timeframe-detail 1m \
    -v

  if [[ $? -eq 0 ]]; then
    echo "Results saved to $results_file"
  else
    echo "Error: Backtest failed."
  fi
}

#################
# Backtest menu #
#################

run_backtest() {
  local timerange=${1:-$DEFAULT_TIMERANGE}
  
  # Usar la variable global $PAIRLIST_FILE
  local pairlist_config="$PAIRLIST_FILE"

  echo "Choose the type of backtest to run:"
  echo "1) Default backtest (default)"
  echo "2) Backtest without derisk"
  echo "3) Test different max_open_trades (slots)"
  echo "4) Backtest with custom disabled signals"
  read -rp "Enter your choice (1, 2, 3, or 4, default: 1): " choice

  choice=${choice:-1}

  case $choice in
    1)
      run_default_backtest "$timerange" "$pairlist_config"
      ;;
    2)
      run_noderisk_backtest "$timerange" "$pairlist_config"
      ;;
    3)
      test_slots "$timerange" "$pairlist_config"
      ;;
    4)
      local signals_config
      signals_config=$(generate_signal_config)
      if [[ $? -eq 0 && -n "$signals_config" ]]; then
        run_custom_signals_backtest "$timerange" "$pairlist_config" "$signals_config"
        rm -f "$signals_config"
      else
        echo "Skipping custom signal backtest due to errors."
      fi
      ;;
    *)
      echo "Invalid choice. Running default backtest."
      run_default_backtest "$timerange" "$pairlist_config"
      ;;
  esac
}


# Clean up temporary files
cleanup_temp_configs() {
  rm -f "$BACKTEST_CONFIG" "$DISABLE_DERISK_CONFIG" "$BTC_CONFIG"
}
