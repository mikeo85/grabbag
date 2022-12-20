#!/usr/bin/env bash
set -euo pipefail
############################################################
#
#  TITLE
#  ---------------------------------------------------------
#  Subtitle
#
#        Written by: Mike Owens
#        Email:      mikeowens (at) fastmail (dot) com
#        Website:    https://michaelowens.me
#        GitLab:     https://gitlab.com/mikeo85
#        GitHub:     https://github.com/mikeo85
#        Mastodon:   https://infosec.exchange/@m0x4d
#        Twitter:    https://twitter.com/quietmike8192
#
#  Description of script plus any instructions
#  
############################################################

# //========== BEGIN INPUT VALIDATION ==========\\

## Input Validation Functions
## ----------------------------------------
exitHelp() { echo >&2 "$@";printf "%s" "$helpText";exit 1; }
countInputs() { [ "$#" -eq "$requiredNumOfInputs" ] || exitHelp "$requiredNumOfInputs argument(s) required, $# provided"; }
isNum() { echo "$1" | grep -E -q '^[0-9]+$' || exitHelp "Numeric argument required, \"$1\" provided"; }
inList() { local ckInput="$1"; shift; local arr=("$@"); printf '%s\n' "${arr[@]}" | grep -P -q "^$ckInput\$" || exitHelp "\"$ckInput\" is not a valid argument."; }

## Input Validation Process
## ----------------------------------------
## ++++ TO BE MODIFIED BY SCRIPT AUTHOR ++++

### Define the Help Text With Usage Instructions
helpText="Usage: $(basename "$0") validates user inputs against expected values.
       $ $0 <input1> <input2>
"
### Define Input Requirements
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

# \\=========== END INPUT VALIDATION ===========//

# //============================================\\
# \\============================================//

echo "Running $(basename "$0")..."
# //============ BEGIN SCRIPT BODY =============\\

# \\============= END SCRIPT BODY ==============//
echo "$(basename "$0") complete."
