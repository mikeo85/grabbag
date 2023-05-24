#!/bin/bash

# Function to check if a directory is a Git repository
is_git_repo() {
    git -C "$1" rev-parse --is-inside-work-tree >/dev/null 2>&1
}

# Function to summarize the Git status
summarize_status() {
    local status=$1

    if [[ $status =~ "Already up to date" ]]; then
        echo "Already up to date."
    elif [[ $status =~ "Updating" ]]; then
        echo "Updated successfully."
    else
        echo "Not a Git repository."
    fi
}

# Main script
directory="$1"

# Iterate through the subdirectories of the given directory
for subdir in "$directory"/*; do
    if [[ -d "$subdir" && -e "$subdir/.git" ]]; then
        if is_git_repo "$subdir"; then
            echo "Pulling latest updates for $subdir..."
            status=$(git -C "$subdir" pull 2>&1)
            summarize_status "$status"
        else
            echo "$subdir is not a Git repository."
        fi
    fi
done

