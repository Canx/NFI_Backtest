import os
import subprocess
import sys
from datetime import datetime
from dotenv import load_dotenv

load_dotenv()

# Dynamically resolve the directory where the script is located
def get_script_directory():
    """Returns the directory where the script is located."""
    return os.path.dirname(os.path.realpath(__file__))

# Global constants
SCRIPT_DIR = get_script_directory()
STRAT_DIR = SCRIPT_DIR  # Assuming strategy files are in the script's directory
STRATEGY_NAME = os.getenv("FREQTRADE__STRATEGY", "NostalgiaForInfinityX5")
TARGET_FILE = f"{STRATEGY_NAME}.py"
LOG_FILE = os.path.join(SCRIPT_DIR, "run_bot.log")






def log_message(message):
    """Log a message to both the console and the log file."""
    timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    log_entry = f"{timestamp} - {message}"
    print(log_entry)
    with open(LOG_FILE, "a") as log_file:
        log_file.write(log_entry + "\n")


def change_to_base_directory():
    """Change to the script's base directory."""
    try:
        os.chdir(SCRIPT_DIR)
        log_message(f"Changed working directory to {SCRIPT_DIR}.")
    except Exception as e:
        log_message(f"Error: Unable to change to the directory {SCRIPT_DIR}: {e}")
        sys.exit(1)


def check_dependencies():
    """Ensure all required dependencies are installed."""
    dependencies = [
        ("git", "Git"),
        ("docker", "Docker"),
    ]
    for command, name in dependencies:
        try:
            subprocess.run([command, "--version"], check=True, text=True, capture_output=True)
        except FileNotFoundError:
            log_message(f"Error: {name} is not installed. Please install it and try again.")
            sys.exit(1)


def ensure_on_main_branch():
    """Ensure the current branch is 'main'."""
    try:
        branch = subprocess.run(["git", "rev-parse", "--abbrev-ref", "HEAD"], check=True, text=True, capture_output=True).stdout.strip()
        if branch != "main":
            log_message(f"Error: You are on branch '{branch}', but 'main' is required. Please switch to 'main'.")
            sys.exit(1)
        log_message("Confirmed: On 'main' branch.")
    except subprocess.CalledProcessError:
        log_message("Error: Unable to determine the current branch. Ensure you are in a valid Git repository.")
        sys.exit(1)


def check_env_file():
    """Ensure the .env file exists."""
    env_file = os.path.join(STRAT_DIR, ".env")
    if not os.path.exists(env_file):
        log_message("Error: .env file not found. Ensure a valid .env file exists.")
        sys.exit(1)
    log_message(".env file found and valid.")


def check_strategy_update():
    """Check if the strategy file has been updated."""
    log_message(f"Checking updates for {STRAT_DIR}...")
    try:
        os.chdir(STRAT_DIR)
        subprocess.run(["git", "fetch", "origin"], check=True, capture_output=True, text=True)
        diff_result = subprocess.run(
            ["git", "diff", "--name-only", "HEAD", "origin/main"],
            check=True, capture_output=True, text=True
        ).stdout.strip()

        log_message(f"Files changed: {diff_result}")
        if TARGET_FILE in diff_result.splitlines():
            log_message(f"Update detected for {TARGET_FILE}.")
            subprocess.run(["git", "pull", "origin", "main"], check=True, capture_output=True, text=True)
            return True
        else:
            log_message(f"No updates detected for {TARGET_FILE}.")
            return False
    except subprocess.CalledProcessError as e:
        log_message(f"Error checking updates: {e}")
        return False


def restart_docker_compose():
    """Restart the Docker Compose services."""
    log_message("Restarting Docker Compose...")
    try:
        subprocess.run(["docker", "compose", "down"], check=True)
        subprocess.run(["docker", "compose", "up", "-d"], check=True)
        log_message("Docker Compose restarted successfully.")
    except subprocess.CalledProcessError as e:
        log_message(f"Error restarting Docker Compose: {e}")


def is_docker_running():
    """Check if Docker Compose is currently running."""
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
    """Main function to orchestrate the update and restart process."""
    log_message("Starting update process...")
    change_to_base_directory()
    check_dependencies()
    ensure_on_main_branch()
    check_env_file()

    update_needed = check_strategy_update()
    if update_needed or not is_docker_running():
        restart_docker_compose()
    else:
        log_message("No updates detected and Docker Compose is already running. No action taken.")


if __name__ == "__main__":
    main()
