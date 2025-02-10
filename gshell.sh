#!/data/data/com.termux/files/usr/bin/bash
# Enhanced script with UI improvements:
# • Animated spinner for background tasks
# • Progress bar for waiting periods
# • Detailed status dashboard
# Purpose: Automate setup for Google Cloud Shell via Termux and proot-distro

set -eo pipefail

# ----------------------------------------------------------------------
# Define color and style variables (raw ANSI escapes)
# ----------------------------------------------------------------------
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
BLUE="\033[0;34m"
RED="\033[0;31m"
BOLD="\033[1m"
RESET="\033[0m"

# Status indicator icons
CHECKMARK="${GREEN}${BOLD}✓${RESET}"
CROSSMARK="${RED}${BOLD}✗${RESET}"
INFO="${BLUE}${BOLD}ℹ${RESET}"

# Global variables to record progress for dashboard
packages_updated="Pending"
proot_installed="Pending"
ubuntu_installed="Pending"
cloud_sdk_configured="Pending"                                                                              
#-------------------------------------------
#direct launch function with argumemt
#------------------------------------------

if [ "$1" == "-direct" ]; then                                                                                  echo -e "${BLUE}${BOLD}Directly launching Cloud Shell...${RESET}"
    proot-distro login ubuntu --termux-home -- bash -c "gcloud alpha cloud-shell ssh --authorize-session "
    exit 0
fi

                                                                                                            # ----------------------------------------------------------------------
# Function: section
# Displays a header for each major section
# ----------------------------------------------------------------------
section() {
    clear
    echo -e "${BLUE}${BOLD}"
    echo "┌─────────────────────────────────────────────────────┐"
    printf "│ %-51s │\n" "$1"
    echo "└─────────────────────────────────────────────────────┘"
    echo -e "${RESET}"
}

# ----------------------------------------------------------------------
# Function: error_handler
# Prints an error message and exits.
# ----------------------------------------------------------------------
error_handler() {
    echo -e "\n${CROSSMARK} ${RED}Error in script at line $1${RESET}"
    exit 1
}
trap 'error_handler $LINENO' ERR

# ----------------------------------------------------------------------
# Function: spinner
# Shows an animated spinner for a given process ID.
# ----------------------------------------------------------------------
spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    while kill -0 "$pid" 2>/dev/null; do
        for (( i=0; i<${#spinstr}; i++ )); do
            printf "\r[%c] Working..." "${spinstr:$i:1}"
            sleep "$delay"
        done
    done
    printf "\r[${GREEN}${BOLD}✓${RESET}] Done!          \n"
}

# ----------------------------------------------------------------------
# Function: progress_bar
# Visualizes waiting time with a simple progress bar.
# ----------------------------------------------------------------------
progress_bar() {
    local current=$1
    local total=$2
    local width=40
    local percent=$(( 100 * current / total ))
    local done=$(( width * current / total ))
    local left=$(( width - done ))
    local done_bar
    local left_bar
    done_bar=$(printf "%${done}s" | tr ' ' '#')
    left_bar=$(printf "%${left}s" | tr ' ' '-')
    printf "\rProgress : [${done_bar}${left_bar}] %d%%" "$percent"
    if [ "$current" -eq "$total" ]; then
        echo ""
    fi
}

# ----------------------------------------------------------------------
# Function: dashboard
# Displays a status dashboard summarizing key variables.
# ----------------------------------------------------------------------
dashboard() {
    clear
    echo -e "${BLUE}${BOLD}┌─────────────────────────────────────────────┐${RESET}"
    printf "│ %-43s │\n" "Setup Status Dashboard"
    echo -e "${BLUE}${BOLD}├─────────────────────────────────────────────┤${RESET}"
    printf "│ Packages updated: %-25s │\n" "$packages_updated"
    printf "│ proot-distro:     %-25s │\n" "$proot_installed"
    printf "│ Ubuntu installed: %-25s │\n" "$ubuntu_installed"
    printf "│ Cloud SDK:        %-25s │\n" "$cloud_sdk_configured"
    echo -e "${BLUE}${BOLD}└─────────────────────────────────────────────┘${RESET}"
    sleep 2
}

# ======================================================================
# Main Script Execution
# ======================================================================

# -------------------------------
# Section 1: Termux Environment Setup
# -------------------------------
section "Termux Environment Setup"
echo -e "${INFO} Updating Termux packages..."
if pkg update -y && pkg upgrade -y; then
    echo -e "${CHECKMARK} Packages updated successfully"
    packages_updated="Yes"
else
    echo -e "${CROSSMARK} Failed to update packages"
    exit 1
fi
dashboard

# -------------------------------
# Section 2: Install proot-distro if missing
# -------------------------------
section "Installing proot-distro"
if ! command -v proot-distro >/dev/null; then
    echo -e "${INFO} Installing proot-distro..."
    if pkg install proot-distro -y; then
        echo -e "${CHECKMARK} proot-distro installed successfully"
        proot_installed="Yes"
    else
        echo -e "${CROSSMARK} Failed to install proot-distro"

    fi
else
    echo -e "${CHECKMARK} proot-distro already installed"
    proot_installed="Yes"
fi
dashboard

# -------------------------------
# Section 3: Ubuntu Installation using proot-distro
# -------------------------------
section "PROOT Ubuntu Setup"
if ! proot-distro info ubuntu >/dev/null 2>&1; then
    echo -e "${INFO} Installing Ubuntu distribution..."
    # Launch installation in background and use spinner for feedback
    proot-distro install ubuntu &
    install_pid=$!
    spinner "$install_pid"
    if proot-distro info ubuntu >/dev/null 2>&1; then
        echo -e "${CHECKMARK} Ubuntu installed successfully"
        ubuntu_installed="Yes"
    else
        echo -e "${CROSSMARK} Failed to install Ubuntu"

    fi
else
    echo -e "${CHECKMARK} Ubuntu already installed"
    ubuntu_installed="Yes"
fi
dashboard

# -------------------------------
# Section 4: Cloud SDK Setup Script Creation inside Ubuntu
# -------------------------------
section "Cloud SDK Configuration"
#SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
UBUNTU_SETUP_SCRIPT=termux_gcloud_setup.sh


cat > "$UBUNTU_SETUP_SCRIPT" <<'EOF'
#!/bin/bash
set -eo pipefail

# Define colors for Ubuntu script using tput
GREEN=$(tput setaf 2)
BLUE=$(tput setaf 4)
RED=$(tput setaf 1)
BOLD=$(tput bold)
RESET=$(tput sgr0)

echo -e "${BLUE}${BOLD}"
echo "┌─────────────────────────────────────────────────────┐"
echo "│          Google Cloud SDK Installation              │"
echo "└─────────────────────────────────────────────────────┘"
echo -e "${RESET}"

echo -e "${BOLD}Updating package lists...${RESET}"
apt update -y

echo -e "\n${BOLD}Installing dependencies...${RESET}"
apt install -y curl gnupg python3

echo -e "\n${BOLD}Configuring Google Cloud SDK repository...${RESET}"
export CLOUD_REPO_FILE="/etc/apt/sources.list.d/google-cloud-sdk.list"
export KEYRING_PATH="/usr/share/keyrings/cloud.google.gpg"

# Add repository configuration
echo "deb [signed-by=$KEYRING_PATH] https://packages.cloud.google.com/apt cloud-sdk main" | tee $CLOUD_REPO_FILE

# Import and store Google Cloud public key
curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | gpg --dearmor -o $KEYRING_PATH

echo -e "\n${BOLD}Installing Google Cloud SDK...${RESET}"
apt update -y && apt install -y google-cloud-sdk

echo -e "\n${GREEN}${BOLD}Initializing gcloud configuration...${RESET}"
echo -e "${BOLD}Follow the interactive prompts to complete setup${RESET}"
gcloud init

echo -e "\n${GREEN}${BOLD}Connecting to Cloud Shell...${RESET}"
gcloud alpha cloud-shell ssh
EOF

chmod +x "$UBUNTU_SETUP_SCRIPT"
cloud_sdk_configured="Pending"
dashboard

# -------------------------------
# Section 5: Launching PROOT Ubuntu environment and executing the Cloud SDK script
# -------------------------------
section "Starting Ubuntu Environment"
echo -e "${INFO} Launching PROOT Ubuntu with Cloud Shell setup..."
#proot-distro login ubuntu \
 #   --bind /dev/null:/proc/sys/kernal/cap_last_cap \
  #  --shared-tmp \
   # --termux-home \
 #   -- bash -c "./$UBUNTU_SETUP_SCRIPT && rm -f ./$UBUNTU_SETUP_SCRIPT"
#cloud_sdk_configured="Configured"
proot-distro login ubuntu \
    --bind /data/data/com.termux/files/home:/home \
    --shared-tmp \
    --termux-home \
    -- bash -c "/home/termux-cloudshell-setup/termux_gcloud_setup.sh && rm -f /home/termux-cloudshell-setup/termux_gcloud_setup.sh"
dashboard

# -------------------------------
# Section 6: Cleanup Temporary Files
# -------------------------------
section "Cleanup"
echo -e "${INFO} Removing temporary files..."
rm -f "$UBUNTU_SETUP_SCRIPT"
echo -e "${CHECKMARK} Cleanup completed successfully"
dashboard

# -------------------------------
# Final Step: Wait and then signal completion via progress bar
# -------------------------------
echo -e "\n${INFO} Finalizing setup, please wait..."
for i in {1..5}; do
    sleep 1
    progress_bar "$i" 5
done
echo -e "${CHECKMARK} Setup process completed successfully!${RESET}"
