#!/bin/bash
#########################################################
#  CLEAN UP NEXTCLOUD CONFLICTED FILES
#  [[ By: Mike Owens (GitLab/GitHub @ mikeo85) ]]
#  ---------------------------------------------------------
#  Script will find any files marked "conflicted" from
#  Nextcloud sync, then prompt the user to go through an
#  interactive 'diff' of the files to merge them appropriately
#  and remove the remnants. Result is a single file with
#  approved changes/merges that has the original filename
#  and will be automatically synced again by Nextcloud.
#########################################################


# ----- INPUT CHECK -----
# check if the directory path is provided
if [ $# -ne 1 ]; then
  echo "Error: Please provide a directory path"
  exit 1
fi

# ----- VARIABLES -----
temp_file="./CleanupNextcloudConflicts.temp"

# ----- FUNCTIONS -----
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

# ----- MAIN -----


# search for all files in the directory containing "conflicted copy" in the file name & save in array
# files=($(find "$1" -type f -name "*conflicted copy*"))
# use the find command with the -print0 option to list all of the files in the directory
# find "$1" -type f -name "*conflicted copy*" -print0 | readarray -d '' files
# read -a files <<< $(find "$1" -type f -name "*conflicted copy*" -print0)
files=()
while IFS= read -r -d '' file; do
    files+=("$file")
done < <(find "$1" -type f -name "*conflicted copy*" -print0)

# iterate over the files in the array to handle conflicts
for file in "${files[@]}"; do
# echo "Filename: $file"
  # save file name as local
  local_file="$file"

  # find source file
  source_file=$(echo $local_file | sed 's/ (conflicted copy [0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\} [0-9]\{6\})//')

  # write both file names to screen & confirm continue
  echo "Local (conflicted): $local_file"
  echo "Source:             $source_file"
  promptContinue doContinue

  if [ "$doContinue" = "Y" ]; then
    echo -e "\n----- BEGIN DIFF ---------------------------------------------------------------\n"
    # Show Summary Diff
    diff --color -y -W 80 --suppress-common-lines "$local_file" "$source_file"
    echo -e "\n----- END DIFF -----------------------------------------------------------------\n"
    echo -e "Do you want to... ?\n\tl) Keep left (local) file\n\tr) Keep right (source) file\n\ts) Skip\n\tm) Perform manual, interactive diff of the files\nEnter option (l/r/s/m):"
    read opt

    case $opt in
    l) 
        echo -e "Keeping left (local) file.\n..."
        mv "$local_file" "$source_file"
        ;;
    r) 
        echo -e "Keeping right (source) file.\n..."
        rm "$local_file"
        ;;
    s) echo -e "Skipping.\n..." ;;
    m)
        echo "Beginning interactive manual diff."
        # perform interactive diff
        sdiff -s --output="$temp_file" "$local_file" "$source_file"
        mv "$temp_file" "$source_file"
        rm "$local_file"
        ;;
    *) echo "Invalid option selected." ;;
    esac

  else
    echo -e "Skipping...\n"
  fi
done
echo "$(basename "$0") complete."
