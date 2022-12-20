#!/bin/bash
#########################################################
#  Fix where the linked H1 header doesn't match the filename in Obsidian Notes
#  
#        Written by: Mike Owens
#        Email:      mikeowens (at) fastmail (dot) com
#        Website:    https://michaelowens.me
#        GitLab:     https://gitlab.com/mikeo85
#        GitHub:     https://github.com/mikeo85
#        Mastodon:   https://infosec.exchange/@m0x4d
#        Twitter:    https://twitter.com/quietmike8192
#
#   Instructions:
#   - One input required: The file path to traverse and check
#########################################################

filepath="$1"
filelist="$(find "$1" -iname '*.md')"
for file in "$filelist";do
    ext=$(basename "$file" | cut -f 2 -d '.')
    # if [ "$ext" == 'md' ];then
        echo "$ext :: $file"
    # fi
done