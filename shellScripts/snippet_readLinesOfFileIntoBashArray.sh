############################################################
# How to read all lines of a file into a bash array
# ==========================================================
# Source: https://peniwize.wordpress.com/2011/04/09/how-to-read-all-lines-of-a-file-into-a-bash-array/
############################################################

declare -a myarray
let i=0
while IFS=$'\n' read -r line_data; do
    myarray[i]="${line_data}"
    ((++i))
done < fileNameToRead

let i=0
while (( ${#myarray[@]} > i )); do
    printf "${myarray[i++]}\n"
done
