#!/usr/bin/env bash
set -euo pipefail

############################################################
#
#  INPUT VALIDATION CHECKER
#  ---------------------------------------------------------
#  Snippet to validate user inputs for a bash script
#
#        Written by: Mike Owens
#        Email:      mikeowens (at) fastmail (dot) com
#        Website:    https://michaelowens.me
#        GitLab:     https://gitlab.com/mikeo85
#        GitHub:     https://github.com/mikeo85
#        Twitter:    https://twitter.com/quietmike8192
#
#  This snippet contains different methods for validating
#  user input to a bash script, including verifying the
#  correct number of arguments were provided, checking for
#  numerical values, and/or verifying the provided argument
#  is in a list of expected inputs.
#
############################################################

echo "Running $(basename "$0")..."
# //----- Begin Script -----\\
## INPUT VALIDATION FUNCTIONS
## ========================================
exitHelp() { echo >&2 "$@";printf "%s" "$helpText";exit 1; }
countInputs() { [ "$#" -eq "$requiredNumOfInputs" ] || exitHelp "$requiredNumOfInputs argument(s) required, $# provided"; }
isNum() { echo "$1" | grep -E -q '^[0-9]+$' || exitHelp "Numeric argument required, \"$1\" provided"; }
inList() { local ckInput="$1"; shift; local arr=("$@"); printf '%s\n' "${arr[@]}" | grep -P -q "^$ckInput\$" || exitHelp "\"$ckInput\" is not a valid argument."; }

## INPUT VALIDATION PROCESS
## ========================================
## ++++ TO BE MODIFIED BY SCRIPT AUTHOR ++++

### Define the HELP TEXT with USAGE INSTRUCTIONS
### ----------------------------------------
helpText="Usage: $(basename "$0") validates user inputs against expected values.
       $ $0 <input1> <input2>
"
### Define INPUT Requirements
### ----------------------------------------
#### Indicate the required number of inputs
requiredNumOfInputs=2
##### List the valid inputs for each field.
##### Repeat for each field as needed. Remove if not required.
validInputs1=( 1 2 3 )
validInputs2=( "a" "b" "c" )

### Validate The Inputs
### ----------------------------------------
countInputs "$@" # Were the expected number of inputs provided?
inList "$1" "${validInputs1[@]}" # check input 1
inList "$2" "${validInputs2[@]}" # check input 2

# \\------ End Script ------//
