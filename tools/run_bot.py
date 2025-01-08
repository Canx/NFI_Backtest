# Usage:
# This script is designed to manage a single bot using Docker Compose.
# It checks for updates in the strategy repository and restarts the bot container if updates are found.
#
# Example setup:
# 1. Place `run_bot.py` in the `NostalgiaForInfinity` folder.
# 2. Ensure a valid `.env` file exists in the same directory.
# 3. Execute the script manually: python run_bot.py
# 4. To automate execution, add the script to `crontab`. For example, to run every hour:
#    0 * * * * /usr/bin/python3 /path/to/NostalgiaForInfinity/run_bot.py
#
# This will check for updates every hour and restart the bot if updates are found.

import os
import subprocess
import sys
from datetime import datetime

# Resolve the actual script location, even if called through a symlink
SCRIPT_DIR = os.path.dirname(os.path.realpath(__file__))
STRAT_DIR = SCRIPT_DIR  # Assuming the script is in the root of NostalgiaForInfinity
LOG_FILE = os.path.join(SCRIPT_DIR, "run_bot.log")

def log_message(message):
    """Log message to console and a log file."""
    timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    log_entry = f"{timestamp} - {message}"
    print(log_entry)
    with open(LOG_FILE, "a") as log_file:
        log_file.write(log_entry + "\n")


def check_branch_status():
    """Ensure the current branch is valid and has a remote tracking branch."""
    try:
        branch = subprocess.run(["git", "rev-parse", "--abbrev-ref", "HEAD"], check=True, text=True, capture_output=True).stdout.strip()
        if branch == "HEAD":
            log_message("Error: You are in a detached HEAD state. Please switch to a valid branch.")
            return False

        tracking_branch = subprocess.run(["git", "rev-parse", "--abbrev-ref", "--symbolic-full-name", "@{u}"], check=True, text=True, capture_output=True).stdout.strip()
        log_message(f"Current branch '{branch}' is tracking '{tracking_branch}'.")
        return True
    except subprocess.CalledProcessError:
        log_message("Error: The current branch is not tracking any remote branch.")
        return False


def check_strategy_update():
    """Check if the strategy file has been updated."""
    log_message(f"Checking updates for {STRAT_DIR}")
    try:
        os.chdir(STRAT_DIR)
        subprocess.run(["git", "fetch"], check=True)

        local = subprocess.run(["git", "rev-parse", "HEAD"], check=True, text=True, capture_output=True).stdout.strip()
        remote = subprocess.run(["git", "rev-parse", "origin/main"], check=True, text=True, capture_output=True).stdout.strip()

        if local != remote:
            log_message("Update detected in the strategy repository.")
            if check_branch_status():
                subprocess.run(["git", "pull"], check=True)
            else:
                log_message("Warning: Unable to pull updates due to branch issues. Skipping pull.")
            return True
        else:
            log_message("No updates in the strategy repository.")
            return False
    except subprocess.CalledProcessError as e:
        log_message(f"Error checking updates for the strategy: {e}")
        return False


def check_env_file():
    """Ensure that a .env file exists in the directory."""
    env_file = os.path.join(STRAT_DIR, ".env")
    if not os.path.exists(env_file):
        log_message("Error: .env file not found. Ensure a valid .env file exists in the directory.")
        sys.exit(1)
    log_message(".env file found and valid.")


def restart_docker_compose():
    """Restart the bot using Docker Compose."""
    log_message("Restarting Docker Compose...")
    try:
        os.chdir(STRAT_DIR)
        subprocess.run(["docker", "compose", "down"], check=True)
        subprocess.run(["docker", "compose", "up", "-d"], check=True)
        log_message("Docker Compose restarted successfully.")
    except subprocess.CalledProcessError as e:
        log_message(f"Error restarting Docker Compose: {e}")


def is_docker_running():
    """Check if Docker Compose is running."""
    try:
        result = subprocess.run(["docker", "compose", "ps"], check=True, text=True, capture_output=True).stdout
        if "Up" in result:
            log_message("Docker Compose is already running.")
            return True
        else:
            log_message("Docker Compose is not running.")
            return False
    except subprocess.CalledProcessError:
        log_message("Error checking Docker Compose status.")
        return False


def main():
    log_message("Starting update process...")

    check_env_file()

    update_needed = check_strategy_update()

    if update_needed or not is_docker_running():
        restart_docker_compose()
    else:
        log_message("No updates detected and Docker Compose is already running. No action taken.")


if __name__ == "__main__":
    main()
