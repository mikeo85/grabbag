#!/bin/bash
############################################################
#
#  REMOVE GIT SUBMODULE
#  ---------------------------------------------------------
#  Simplify the removal of git submodules.
#
#        Written by: Mike Owens
#        Email:      mikeowens (at) fastmail (dot) com
#        Website:    https://michaelowens.me
#        GitLab:     https://gitlab.com/mikeo85
#        GitHub:     https://github.com/mikeo85
#        Twitter:    https://twitter.com/quietmike8192
#
#  Instead of remembering all of the commands,
#  just run this script.
#
#  Instructions:
#  -------------
#  1) Copy the script into the repo root.
#  2) The only input is the name of the submodule to remove.
#  3) Run the script.
#       $ ./removeGitSubmodule.sh <submodule full name>
#
#  References:
#  -----------
#  This GitHub Gist from moyaldror and subsequent comments:
#    https://gist.github.com/moyaldror/63b4c2b601592aa3ae8a317adec00a1c
#
############################################################
echo "Running "$(basename "$0")"..."
# //----- Begin Script -----\\
if [ $# -ne 1 ]; then
        echo "Usage: $0 <submodule full name>"
        exit 1
fi

MODULE_NAME=$1

git config -f .gitmodules --remove-section submodule.$MODULE_NAME
git config -f .git/config --remove-section submodule.$MODULE_NAME
git add .gitmodules
git rm --cached $MODULE_NAME
rm -rf .git/modules/$MODULE_NAME
rm -rf $MODULE_NAME
git commit -m "removing submodule $MODULE_NAME" || echo "* * * * *
Unable to commit changes. See output above to identify and correct any issues.
Note: If you never committed the submodule addition, then that's the most likely reason that this commit attempt failed. Most likely, no further action is necessary in this case.
* * * * *"
# \\------ End Script ------//
echo $(basename "$0")" complete."
