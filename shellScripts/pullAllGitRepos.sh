#!/bin/bash
############################################################
# PULL ALL GIT REPOS
# ------------------
# Given a directory of git repos, iterate through the repos
# and pull the latest updates for each.
#
# Input:    One or more directories that contain subdirectories
#           with git repos. May also use directory wildcards.
#
#           E.g., if this is the directory structure:
#               /foo
#                 +-bar
#                 |  +-repo1
#                 |  +-repo2
#                 +-baz
#                   +-repo3
#                   +-repo4
#           Then any of the following are valid script inputs that
#           will result in all four repos being updated.
#             > bash pullAllGitRepos.sh /foo/bar /foo/baz
#             > bash pullAllGitRepos.sh /foo/*
############################################################

# ----- FUNCTIONS ---------------
# Function to check if a directory is a Git repository
is_git_repo() {
    git -C "$1" rev-parse --is-inside-work-tree >/dev/null 2>&1
}

# Function to summarize the status
summarize_status() {
  local status_message="$1"
  if [ $exit_code -eq 0 ]; then
    echo "Git pull completed successfully."
  else
    echo "Git pull failed with exit code $exit_code."
    echo "Status message: $status_message"
    # Add your additional actions here based on the failure
    # For example, you can send an alert or perform error handling
  fi
}

# Function to execute on each directory
process_directory() {
    local directory="$1"
    echo "Processing directory: $directory"
    for subdir in "$directory"/*; do
        if [[ -d "$subdir" && -e "$subdir/.git" ]]; then
            if is_git_repo "$subdir"; then
                echo "Pulling latest updates for $subdir..."
                status=$(git -C "$subdir" pull 2>&1)
                exit_code=$?
                summarize_status "$status"
            else
                echo "$subdir is not a Git repository."
            fi
        fi
    done
}

# ----- MAIN -------------------- 

# Iterate through each argument
for path in "$@"; do
    # Check if the path contains wildcards
    if [[ "$path" == *"*"* ]]; then
        # Expand the wildcard path and iterate through each matched directory
        for directory in $path; do
            # Check if the matched path is a directory
            if [[ -d "$directory" ]]; then
                process_directory "$directory"
            else
                echo "Invalid directory: $directory"
            fi
        done
    else
        # If no wildcards, check if the path is a directory
        if [[ -d "$path" ]]; then
            process_directory "$path"
        else
            echo "Invalid directory: $path"
        fi
    fi
done
