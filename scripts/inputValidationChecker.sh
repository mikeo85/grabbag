#!/usr/bin/env bash
set -euo pipefail

# # initialize checkinputs variable as blank
# checkinputs=''

# # define valid inputs for input field 1
# inputList1=(
#     "a"
#     "b"
#     "c"
# )

# # function to check input value against valid list
# # to use: contains <inputItem> <validList>
# # contains() {
# function inList {
#     local ckInput="^$1\$"
#     shift
#     local arr=("$@")
#     if printf '%s\n' "${arr[@]}" | grep -P -q "$ckInput"; then
#         output'yes'
#     else
#         output'no'
#     fi
# }

# if [[ $# -eq 1 ]];then # correct number of inputs?
#     # Validate inputs match correct options
#     # (Copy & modify this section for each additional input field)
#     test=${inList "$1" "${inputList1[@]}"}
#     if [[ "$test" == 'yes' ]];then
#         checkinputs+='pass';
#     fi
# fi

# echo $checkinputs



requiredNumOfInputs


helpText="
A
b
c
"
# echo "$helpText"
