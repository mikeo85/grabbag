#!/bin/bash
#########################################################
#  Prompt to continue
#  ------------------------------------------------------
#  Script will prompt user whether to continue, then
#  output the response for further processing. Can be
#  used in two ways:
#    1) If the function is given a variable name as input
#       then the function output will be saved to that
#       variable name for further use.
#         Example: $ promptContinue myVariable
#
#    2) If the function is run without providing any
#       initial input variable name, then the output
#       is returned to stdout.
#         Example: $ promptContinue
#   
#  Reference:
#  - https://stackoverflow.com/questions/1885525/how-do-i-prompt-a-user-for-confirmation-in-bash-script#1885670
#  - https://www.linuxjournal.com/content/return-values-bash-functions
#########################################################

promptContinue() {
    local __resultVar=$1
    while true; do
        read -p "Continue Y/N (<Enter> for Y): " choice
        case "$choice" in 
            y|Y|'' ) local funcResult="Y" && break;;
            n|N ) local funcResult="N" && break;;
            * ) echo "Invalid entry. Try again...";;
        esac
    done
    if [ "$__resultVar" ]; then
        eval $__resultVar="'$funcResult'"
    else
        echo "$funcResult"
    fi
}

# Usage #1
promptContinue myVariable
echo "$myVariable"

# Usage #2
promptContinue

