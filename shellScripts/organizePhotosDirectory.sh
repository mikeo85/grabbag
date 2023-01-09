#!/usr/bin/env bash
set -euo pipefail
############################################################
#
#  Organize Photos Directory
#  ---------------------------------------------------------
#  Script to organize photos by date and prepend date to filename
#
#        Written by: Mike Owens
#        Email:      mikeowens (at) fastmail (dot) com
#        Website:    https://michaelowens.me
#        GitLab:     https://gitlab.com/mikeo85
#        GitHub:     https://github.com/mikeo85
#        Mastodon:   https://infosec.exchange/@m0x4d
#        Twitter:    https://twitter.com/quietmike8192
#
#  This script will:
#  - Move all files from source directory to target directory
#  - Organize files into folders by creation year and month
#  - Prepend date to each filename
#
#  Two inputs are required:
#  1) Source Directory (where the files currently are)
#  2) Target Directory (where the files should be moved)
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
helpText="Usage: $(basename "$0") renames and organizes photo files in a directory.
        $ $0 <source_directory> <target_directory>
"
### Define Input Requirements
### ----------------------------------------
#### Indicate the required number of inputs
requiredNumOfInputs=2

### Validate The Inputs
### ----------------------------------------
countInputs "$@" # Were the expected number of inputs provided?

# \\=========== END INPUT VALIDATION ===========//

# //============================================\\
# \\============================================//

echo "Running $(basename "$0")..."
# //============ BEGIN SCRIPT BODY =============\\

# Set the path to the source and target directories
source_dir="${1%/}"
target_dir="${2%/}"

# Set the text to append to likely duplicate files
dup="DUPLICATE"

# Find all files in the photos directory
find "$source_dir" -type f | while read file; do

    # Get the base filename
    base_filename="$(basename "$file")"

    # Get the creation date for the file
    creation_date=$(exiftool -d "%Y%m%d" -CreateDate "$file" | sed -n 's/^Create Date *: //p') || true

    # If the creation date could not be determined from the metadata, use the file creation date
    if [ -z "$creation_date" ] || [[ $(echo "$creation_date" | cut -c1-4) == "0000" ]]; then
        creation_date=$(stat -c "%y" "$file" | cut -d' ' -f1 | tr -d '-')
    fi

    # Get the year, month, and day from the creation date
    year=$(echo "$creation_date" | cut -c1-4)
    month=$(echo "$creation_date" | cut -c5-6)
    day=$(echo "$creation_date" | cut -c7-8)
    dest_dir="$target_dir/$year/$month"

    # Define new filename, checking if it already starts with the creation date
    if [[ "$creation_date" == "$(echo "$base_filename" | cut -c1-8)" ]]; then
        dest_filename="$base_filename"
    elif [[ "$year-$month-$day" == "$(echo "$base_filename" | cut -c1-10)" ]]; then
        base_separator="$(echo "$base_filename" | cut -c11)"
        separators="_ -"
        if [[ "$separators" =~ "$base_separator" ]]; then
            dest_filename="${creation_date}_$(echo "$base_filename" | cut -c12-)"
        else
            dest_filename="${creation_date}_$(echo "$base_filename" | cut -c11-)"
        fi
    else
        dest_filename=$creation_date"_"$base_filename
    fi

    # Establish the expected destination path
    dest="$dest_dir/$dest_filename"

    # Only continue if the destination is different than the source
    # (i.e., if file and dest are the same, then the file is already in the right place and no action is required)
    if [[ "$file" != "$dest" ]]; then

        # Check if a duplicate file already exists in the destination directory
        if [ -f "$dest" ] && [[ "$(md5sum "$file" | cut -d' ' -f1)" == "$(md5sum "$dest" | cut -d' ' -f1)" ]]; then
            dest="$([[ "${dest%.*}" != "${dest}" ]] && echo "${dest%.*}_$dup.${dest##*.}" || echo "${dest%.*}_$dup")"
        fi

        if [ -f "$dest" ]; then
            # If duplicate file name still exists, append a number to the filename to make it unique
            i=1
            while [ -f "$dest" ]; do
                dest="$([[ "${dest%.*}" != "${dest}" ]] && echo "${dest%.*}_$i.${dest##*.}" || echo "${dest%.*}_$i")"
                i=$((i+1))
            done
        fi

        # Create the year and month subdirectories if they don't already exist
        if [ ! -d "$dest_dir" ]; then
            mkdir -p "$dest_dir"
        fi

        # # Move the file to the appropriate year/month subdirectory
        echo "Moving $file to $dest"
        mv "$file" "$dest"
    fi
done

# Consolidate Duplicates
dups_ct=$(find "$target_dir" -type f -name "*${dup}*" | wc -l)
if [[ $dups_ct -gt 0 ]]; then
    dups_dir="$target_dir/_DUPLICATES.$(date +"%Y%m%dT%H%M")"
    mkdir -p "$dups_dir"

    find "$target_dir" -type f -name "*${dup}*" | while read file; do
        mv "$file" "$dups_dir/$(basename "$file")"
    done
    echo -e "Directory organizing complete. $dups_ct duplicates were identified.\nDuplicates are consolidated in the following folder:\n$dups_dir"
else
    echo "Directory organizing complete. No duplicates were identified."
fi
# Find all empty directories in the photos directory and delete them (but leave the photos directory itself still there)
find "$source_dir"/* -type d -empty -delete

# \\============= END SCRIPT BODY ==============//
echo "$(basename "$0") complete."
