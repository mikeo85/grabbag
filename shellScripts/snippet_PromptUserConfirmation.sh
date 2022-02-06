# WORK IN PROGRESS

#!/bin/bash
#########################################################
#  Prompt user for confirmation
#  ------------------------------------------------------
#  Reference:
#  - https://stackoverflow.com/questions/1885525/how-do-i-prompt-a-user-for-confirmation-in-bash-script#1885670
#########################################################

promptUserConfirmation() {
	while true; do
    read -p "Continue (y/n)? " choice
    case "$choice" in 
      y|Y ) echo "Continuing..." && break;;
      n|N ) echo "Terminating..." && exit;;
      * ) echo "Invalid entry. Try again...";;
    esac
	done
}

promptUserConfirmation
echo "this is the end of the script"
