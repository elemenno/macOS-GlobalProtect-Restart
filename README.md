# GlobalProtect Restart Tool for macOS

This script provides a reliable way to restart the GlobalProtect VPN app and its background services on macOS systems, especially useful when users encounter connection issues. It is designed for deployment through **Jamf Self Service**, with a user-friendly interface and no reliance on GlobalProtect CLI (which is deprecated or non-functional on many macOS versions).

---

## Features

- Restarts GlobalProtect LaunchAgents and LaunchDaemons
- Relaunches the GlobalProtect app as the logged-in user
- Uses `osascript` for interactive dialogs (no jamfHelper required)
- Prompts users with clear instructions before and after the restart
- Logs all actions to `/var/log/globalprotect_restart.log`
- Compatible with Jamf Self Service deployments

---

## Files

| File                          | Description                                |
|-------------------------------|--------------------------------------------|
| `restart_globalprotect.sh`    | The main script to restart GlobalProtect   |
| `README.md`                   | This file                                  |

---

## Usage (Jamf Deployment)

1. Upload `restart_globalprotect.sh` as a **script** in Jamf Pro.
2. Create a **policy** scoped to relevant Mac devices.
3. Enable **Self Service** and give it a name like:  
   `Restart GlobalProtect VPN`
4. (Optional) Use a custom icon (e.g., GlobalProtect globe).
5. Add the following **description** for users:

   > **Having trouble connecting to VPN?**  
   > This tool will restart the GlobalProtect VPN app and background services.  
   > After it runs, you’ll be prompted to click **Connect** again in the app.

---

## What the Script Does

1. Prompts the user with a dialog to confirm they want to restart VPN.
2. Unloads GlobalProtect-related LaunchAgents and Daemon:
   - `com.paloaltonetworks.gp.pangpa`
   - `com.paloaltonetworks.gp.pangps`
3. Reloads those agents/daemons.
4. Relaunches the GlobalProtect GUI app.
5. Instructs the user to reconnect manually.

---

## Notes

- The script avoids using `globalprotect` CLI, which is unreliable or missing on modern macOS builds.
- No portal or auto-connect functionality is used — this is **restart-only**.
- Requires the user to manually reconnect via the GlobalProtect app after the restart.

---

## Tested On

- macOS 14 Sonoma, 15 Sequoia
- GlobalProtect versions: 5.2.x through 6.x
- Jamf Pro Self Service (root context)

---

## License

This project is licensed for internal use only. Adapt and deploy freely within your organization.


