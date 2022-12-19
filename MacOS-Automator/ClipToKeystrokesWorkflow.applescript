# ClipToKeystrokes Automator Workflow
# ---------------------------------
#
# ABOUT
# Purpose: To paste text into windows that normally don't allow it or have access to the clipboard.
# Examples: Virtual machines that do not yet have tools installed, websites that hijack paste
# Sourced and modifed from: https://gist.github.com/sscotth/310db98e7c4ec74e21819806dc527e97
#
# SETUP
# - Launch Automator (installed by default)
# - Create a new document of type 'Quick Action'
# - Change "Workflow Receives" to "No Input"
# - Add action 'Run AppleScript'
# - Paste this entire document's contents into the textbox
# - *Optional:* Modify the 'DELAY BETWEEN EACH KEYPRESS IN SECONDS' line as needed (toward the bottom)
# - Save the quick action with a recognizable name, e.g., ClipToKeystrokes
#   - Note: By default, quick actions are saved to ~/Library/Services
#
# USAGE
# - Copy text to clipboard
# - Switch to the target Application
# - Ensure the cursor is located wherever the typing should start
# - Click the Application name in the menu bar
# - Select Services > ClipToKeystrokes (or whatever you named it)
# - Text should be typed where the cursor was located
#
# ADDITIONAL NOTES:
# - Accessibility (System Preferences > Security & Privacy) will need to be enabled for Automator AND 
#   for any Application were you want to use this automation. IF YOU ENCOUNTER AN ERROR, START HERE!
# - Make sure your capslock is off

on run
    tell application "System Events"
        delay 2 # DELAY BEFORE BEGINNING KEYPRESSES IN SECONDS
        repeat with char in (the clipboard)
            set cID to id of char

            if ((cID ≥ 48) and (cID ≤ 57)) then
                # Converts numbers to ANSI_# characters rather than ANSI_Keypad# characters
                # https://apple.stackexchange.com/a/227940
                key code {item (cID - 47) of {29, 18, 19, 20, 21, 23, 22, 26, 28, 25}}
            else if (cID = 46) then
                # Fix VMware Fusion period bug
                # https://apple.stackexchange.com/a/331574
                key code 47
            else
                keystroke char
            end if

            delay 0.01 # DELAY BETWEEEN EACH KEYPRESS IN SECONDS
        end repeat
    end tell
end run
