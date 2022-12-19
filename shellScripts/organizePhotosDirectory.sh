#!/bin/bash

# Check if a starting directory was provided as a parameter
if [ -z "$1" ]; then
    echo "Error: No starting directory provided"
    exit 1
fi

# Set the path to the starting directory
photos_dir="${1%/}"

# Set the text to append to likely duplicate files
dup="DUPLICATE"

# Find all files in the photos directory
find "$photos_dir" -type f | while read file; do

    # Get the base filename
    base_filename="$(basename "$file")"

    # Get the creation date for the file
    creation_date=$(exiftool -d "%Y%m%d" -CreateDate "$file" | sed -n 's/^Create Date *: //p')

    # If the creation date could not be determined from the metadata, use the file creation date
    if [ -z "$creation_date" ] || [[ $(echo "$creation_date" | cut -c1-4) == "0000" ]]; then
        creation_date=$(stat -c "%y" "$file" | cut -d' ' -f1 | tr -d '-')
    fi

    # Get the year, month, and day from the creation date
    year=$(echo "$creation_date" | cut -c1-4)
    month=$(echo "$creation_date" | cut -c5-6)
    day=$(echo "$creation_date" | cut -c7-8)
    year_dir="$photos_dir/$year"
    month_dir="$year_dir/$month"

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
    dest="$month_dir/$dest_filename"

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
        if [ ! -d "$month_dir" ]; then
            mkdir -p "$month_dir"
        fi

        # # Move the file to the appropriate year/month subdirectory
        echo "Moving $file to $dest"
        mv "$file" "$dest"
    fi
done

# Consolidate Duplicates
dups_ct=$(find "$photos_dir" -name "*${dup}*" | wc -l)
if [[ $dups_ct -gt 0 ]]; then
    dups_dir="$photos_dir/_DUPLICATES.$(date +"%Y%m%dT%H%M")"
    mkdir -p "$dups_dir"

    find "$photos_dir" -name "*${dup}*" | while read file; do
        mv "$file" "$dups_dir/$(basename "$file")"
    done
    echo -e "Directory organizing complete. $dups_ct duplicates were identified.\nDuplicates are consolidated in the following folder:\n$dups_dir"
else
    echo "Directory organizing complete. No duplicates were identified."
fi
# Find all empty directories in the photos directory and delete them
find "$photos_dir" -type d -empty -delete
