#!/bin/bash

###############################################################################
#
# Restart GlobalProtect: Mixed Version Compatible
# Handles both CLI binary names: globalprotect (old) and GlobalProtect (new)
#
VERSION=1.0
#
#   Created by Pat Servedio
#       06.07.2025
#
###############################################################################

#LOG_FILE="/Users/"$CURRENT_USER"/Library/logs/globalprotect_restart.log"
APP_NAME="GlobalProtect"
GP_APP="/Applications/$APP_NAME.app"

DAEMON_PLIST="/Library/LaunchDaemons/com.paloaltonetworks.gp.pangpsd.plist"
AGENT_PANGPA="/Library/LaunchAgents/com.paloaltonetworks.gp.pangpa.plist"
AGENT_PANGPS="/Library/LaunchAgents/com.paloaltonetworks.gp.pangps.plist"

# Get the currently logged-in user
CURRENT_USER=$(stat -f%Su /dev/console)
USER_UID=$(id -u "$CURRENT_USER")

# Log file
LOG_FILE="/Users/"$CURRENT_USER"/Library/logs/globalprotect_restart.log"


# Logging function
log() {
    echo "$(date "+%Y-%m-%d %H:%M:%S") $1" | tee -a "$LOG_FILE"
}


log "----- Starting GlobalProtect restart -----"


user_choice=$(osascript -e 'display dialog "We are going to restart GlobalProtect VPN to help resolve any connection issues.

You may receive a Keychain popup or two asking for your password during the process.

Do you want to continue?" buttons {"Cancel", "OK"} default button "OK" with title "GlobalProtect Restart"')

if [[ "$user_choice" != *"OK" ]]; then
    echo "User canceled GlobalProtect restart."
    exit 0
fi



# --- Unload agents ---

log "Unloading GlobalProtect user agents..."
launchctl bootout gui/$USER_UID "$AGENT_PANGPA" 2>/dev/null || echo "Agent pangpa already stopped or missing."
launchctl bootout gui/$USER_UID "$AGENT_PANGPS" 2>/dev/null || echo "Agent pangps already stopped or missing."

# --- Unload daemon ---
log "Unloading GlobalProtect service..."
launchctl bootout system "$DAEMON_PLIST" 2>/dev/null || echo "Daemon already stopped or missing."

    sleep 5


# --- Reload agents ---
log "Reloading user agents..."
launchctl bootstrap gui/$USER_UID "$AGENT_PANGPA" 2>/dev/null || echo "Agent pangpa already loaded or failed."
launchctl bootstrap gui/$USER_UID "$AGENT_PANGPS" 2>/dev/null || echo "Agent pangps already loaded or failed."


# --- Reload daemon ---
log "Reloading GlobalProtect service..."
launchctl bootstrap system "$DAEMON_PLIST" 2>/dev/null || echo "Daemon already loaded or failed."

    sleep 5


# --- Relaunch GlobalProtect UI ---
if [ -d "$GP_APP" ]; then
    log "Relaunching GlobalProtect..."
    open -a "$GP_APP" 
  sleep 5
else
    log "GlobalProtect.app not found at $GP_APP."
    notify_user "$APP_NAME not found at $GP_APP."
    exit 1
fi


# --- Checking status of GlobalProtect ---
log "Checking GlobalProtect status..."
if (ps aux | grep GlobalProtect | grep -v grep > /dev/null); then
    log "VPN is connected."
    osascript -e 'display dialog "GlobalProtect has been restarted." & return & return & "Please click the GlobalProtect icon in the menu bar and click '\''Connect'\'' to re-establish your VPN connection." & return & return & "Thank you for your patience." buttons {"OK"} default button "OK" with title "GlobalProtect Status"'
else
    log "VPN is not connected."
    osascript -e 'display dialog "GlobalProtect has not restarted. Please re-launch the GlobalProtect app from the Applications folder." buttons {"OK"} default button "OK" with title "GlobalProtect Status"'
fi


log "===== Restart Complete. User prompted to reconnect manually. ====="
