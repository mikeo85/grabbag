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
#  Instead of remembering all of the commands, just run this script!
#
#  Instructions:
#  -------------
#  1) The only input is the name of the submodule to remove.
#  2) Run the script by referencing the full or relative path.
#       $ path/to/removeGitSubmodule.sh <submodule full name>
#  3) If planning to use the script regularly, consider
#     symlinking it into your PATH somewhere. For example:
#       $ ln -s path/to/removeGitSubmodule.sh /usr/local/bin/
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
echo "Removing submodule $MODULE_NAME"
echo "... Removing from .gitmodules ..."
git config -f .gitmodules --remove-section submodule.$MODULE_NAME
echo "Success"
echo "... Removing from .git/config ..."
git config -f .git/config --remove-section submodule.$MODULE_NAME
echo "Success"
echo "... Adding .gitmodules change to git tracking ..."
git add .gitmodules && echo "Success"
echo "... Removing cached files from git tracking ..."
git rm --cached $MODULE_NAME && echo "Success"
echo "... Removing files from .git/modules/$MODULE_NAME ..."
rm -rf .git/modules/$MODULE_NAME && echo "Success"
echo "... Removing files from working tree at $MODULE_NAME ..."
rm -rf $MODULE_NAME && echo "Success"
echo "... Committing changes ..."
git commit -m "removing submodule $MODULE_NAME" || echo "* * * * *
Unable to commit changes. See output above to identify and correct any issues.
Note: If you never committed the submodule addition, then that's the most likely reason that this commit attempt failed. Most likely, no further action is necessary in this case.
* * * * *"
# \\------ End Script ------//
echo $(basename "$0")" complete."
