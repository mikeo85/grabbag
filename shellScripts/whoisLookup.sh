#!/bin/bash
#########################################################
#  WHOIS LOOKUP
#  [[ By: Mike Owens (GitLab/GitHub @ mikeo85) ]]
#  ---------------------------------------------------------
#  Look up WHOIS information based on a provided CSV of IP addresses.
#
#  Results are output to a separate CSV file.
#
#  Usage: whoisLookup.sh /path/to/inputFile.csv /path/to/outputFile.csv
#
#########################################################

# //========== BEGIN INPUT VALIDATION ==========\\

## Input Validation Functions
## ----------------------------------------
exitHelp() { echo >&2 "$@";printf "%s" "$helpText";exit 1; }
countInputs() { [ "$#" -eq "$requiredNumOfInputs" ] || exitHelp "$requiredNumOfInputs argument(s) required, $# provided"; }
isNum() { echo "$1" | grep -E -q '^[0-9]+$' || exitHelp "Numeric argument required, \"$1\" provided"; }
inList() { local ckInput="$1"; shift; local arr=("$@"); printf '%s\n' "${arr[@]}" | grep -P -q "^$ckInput\$" || exitHelp "\"$ckInput\" is not a valid argument."; }

## Input Validation Process
## ----------------------------------------
helpText="Usage: $(basename "$0") looks up WHOIS information based on a provided CSV of IP addresses.
       $ $0 /path/to/inputFile.csv /path/to/outputFile.csv
"
requiredNumOfInputs=2       # Indicate the required number of inputs
countInputs "$@"            # Were the expected number of inputs provided?

# \\=========== END INPUT VALIDATION ===========//

# //============================================\\
# \\============================================//

# echo "Running $(basename "$0")..."
# //============ BEGIN SCRIPT BODY =============\\

INPUT=$1
OUTPUT=$2
OLDIFS=$IFS
IFS=$'\n'
getHeaders=1

function file_ends_with_newline() {
    [[ $(tail -c1 "$1" | wc -l) -gt 0 ]]
}

if ! file_ends_with_newline "$INPUT"
then
    echo "" >> "$INPUT"
fi

function remove_windows_line_terminator() {
    sed 's/\r//' $1 > $1
}

remove_windows_line_terminator "$INPUT"

declare -a ipList
let i=0
while IFS=$'\n' read -r ip; do
    ipList[i]="${ip}"
    ((++i))
done < "$INPUT"

# let i=0
# while (( ${#ipList[@]} > i )); do
#     printf "${ipList[i++]}\n"
#     echo "http://whois.arin.net/rest/ip/${1}.txt" | \

# done

for ip in ${ipList[@]}; do
    echo "http://whois.arin.net/rest/ip/$ip.txt"
    printf "http://whois.arin.net/rest/ip/%s.txt\n" $ip
    printf "http://whois.arin.net/rest/ip/%s.txt\n" 1.2.3.4
done

# function arinHeader()
# {
#     echo $1
#     printf "http://whois.arin.net/rest/ip/%s%s" "$1" txt

# #   curl "http://whois.arin.net/rest/ip/${1}.txt" | \
# #   sed '/^#/d' | \
# #   sed '/^$/d' | \
# #   sed 's/:.*$//' | \
# #   sed 's/$/,/g'
# }

# function arin()
# {
#   curl "http://whois.arin.net/rest/ip/${1}.txt" | \
#   sed '/^#/d' | \
#   sed '/^$/d' | \
#   sed 's/^.*:  *//' | \
#   sed '/,/ s/^/"/' | \
#   sed '/,/ s/$/"/' | \
#   sed 's/$/,/g'
# }

# [ ! -f $INPUT ] && { echo "$INPUT file not found"; exit 99; }

# while read ip;
# do
#     if [ $getHeaders -eq 1 ]; then
#     #    arinHeader $ip
#         # printf "http://whois.arin.net/rest/ip/%s\n" ${ip}.txt
#         # printf "%s\n" ${ip}.txt
#         # printf "http://whois.arin.net/rest/ip/%s%s\n" $ip .txt
#         # echo curl http://whois.arin.net/rest/ip/${ip}'.'txt
#         a='http://whois.arin.net/rest/ip/'
#         b=$ip
#         c=$a$b
#         d='.txt'
#         e=$c$d
#         echo $c$d
#         echo "$c"$d
#         echo "$c$d"
#         echo $e
#         echo "$e"
#         # myheaders=$(arinHeader "$ip")
#         # echo "IP,$myheaders"
#         getHeaders=0
#     fi
#     echo $ip
# done <"$INPUT"

# for ip in "$INPUT"; do echo my $ip; done

# for ip in "$(cat $INPUT)"; do
#     echo IP: $ip
# done

# myvar=$(arin "$1" | sed '/^#/d' | sed '/^$/d' | sed 's/^.*:  *//' | sed '/,/ s/^/"/' | sed '/,/ s/$/"/' | sed 's/$/,/g')
# printf $myvar
# echo $myvar

# arin "$1"
# myheader=$(arinHeader "$1")
# myvar=$(arin "$1")
# echo $myheader
# echo $myvar

# IFS=$OLDIFS

# \\============= END SCRIPT BODY ==============//
# echo "$(basename "$0") complete."
