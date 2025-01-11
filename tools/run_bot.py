import os
import subprocess
import sys
from datetime import datetime

# Global variable for the target file to check
TARGET_FILE = "NostalgiaForInfinityX5.py"

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


def check_dependency(command, name):
    """Check if a required command is available on the system."""
    try:
        subprocess.run([command, "--version"], check=True, text=True, capture_output=True)
    except FileNotFoundError:
        log_message(f"Error: Dependency '{name}' is not installed. Please install it and try again.")
        sys.exit(1)


def check_dependencies():
    """Check if all required dependencies are installed."""
    dependencies = [
        ("git", "Git"),
        ("docker", "Docker"),
    ]
    for command, name in dependencies:
        check_dependency(command, name)


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

        # Fetch updates from the remote repository
        fetch_result = subprocess.run(["git", "fetch", "origin"], check=True, capture_output=True, text=True)

        # Check if the specific file has differences
        diff_result = subprocess.run(
            ["git", "diff", "--name-only", "HEAD", "origin/main"],
            check=True, capture_output=True, text=True
        ).stdout.strip()

        # Log the diff output for debugging
        log_message(f"Files changed: {diff_result}")

        # Check if the target file is in the list of changed files
        if TARGET_FILE in diff_result.splitlines():
            log_message(f"Update detected for {TARGET_FILE}.")
            if check_branch_status():
                pull_result = subprocess.run(["git", "pull", "origin", "main"], check=True, capture_output=True, text=True)
                log_message(pull_result.stdout.strip())
            else:
                log_message(f"Warning: Unable to pull updates due to branch issues. Skipping pull.")
            return True
        else:
            log_message(f"No updates detected for {TARGET_FILE}.")
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


def ensure_on_main_branch():
    """Ensure that the current branch is 'main'."""
    try:
        branch = subprocess.run(["git", "rev-parse", "--abbrev-ref", "HEAD"], check=True, text=True, capture_output=True).stdout.strip()
        if branch != "main":
            log_message(f"Error: You are on branch '{branch}', but 'main' is required. Please switch to the 'main' branch and try again.")
            sys.exit(1)
        log_message("Confirmed: On 'main' branch.")
    except subprocess.CalledProcessError:
        log_message("Error: Unable to determine the current branch. Ensure you are in a valid Git repository.")
        sys.exit(1)


def main():
    log_message("Starting update process...")

    ensure_on_main_branch()  # Ensure we are on the main branch
    check_dependencies()
    check_env_file()

    update_needed = check_strategy_update()

    if update_needed or not is_docker_running():
        restart_docker_compose()
    else:
        log_message("No updates detected and Docker Compose is already running. No action taken.")


if __name__ == "__main__":
    main()

