#!/bin/bash
#########################################################
#  Find and Diff Syncthing Conflicts in a Given Directory
#  
#        Written by: Mike Owens
#        Email:      mikeowens (at) fastmail (dot) com
#        Website:    https://michaelowens.me
#        GitLab:     https://gitlab.com/mikeo85
#        GitHub:     https://github.com/mikeo85
#        Twitter:    https://twitter.com/quietmike8192
#########################################################

# Create array with conflicts files
IFS=$'\n' read -r -d '' -a conflictsArray < <( find $1 -name '*.sync-conflict-*' && printf '\0' )

# Create blank arrays for tracking progress
deletedOriginals=()
deletedConflicts=()
forReview=()

# Determine and display number of conflicts identified
numConflicts=${#conflictsArray[@]}
echo Number of Sync Conflicts Identified: $numConflicts
while true; do
read -p "Continue (y/n)? " choice
case "$choice" in 
	y|Y ) echo "Continuing..." && break;;
	n|N ) echo "Terminating..." && exit;;
	* ) echo "Invalid entry. Try again...";;
esac
done

# REVIEW EACH FILE CONFLICT
for cfile in "${conflictsArray[@]}"; do
	ofile=$(echo "$cfile" | sed 's/sync-conflict-.*[\.]//')
	echo ''
	echo '-----'
	echo "Original File (<): $ofile"
	echo "Conflict File (>): $cfile"
	echo ''
	echo '----- DIFF -----'
	
	# Show the diff
	diff -y --suppress-common-lines "$ofile" "$cfile"
	echo ''
	echo '-----'
	
	# Review and delete
	while true; do
		echo "OPTIONS: 1 = Keep Original   2 = Keep Conflicting   0 = Keep Both and Flag for Review   M = Show More Detail   V = Open in Vim"
		read -p "Choice? " choice
		case "$choice" in 
		1 ) echo "Keeping original and deleting conflicting file..." && rm "$cfile" && deletedConflicts+=("$cfile") && break;;
		2 ) echo "Overwriting original with conflicting file..." && mv "$cfile" "$ofile" && deletedOriginals+=("$ofile") && break;;
		0 ) echo "Preserving both files for further review..." && forReview+=("$cfile") && break;;
		m|M ) echo '' && echo "----- Original File (<) | Conflict File (>) -----" && diff "$ofile" "$cfile" && 	echo '' && echo '-----';;
		v|V ) vim -O "$ofile" "$cfile" ;;
		* ) echo "Invalid entry. Try again...";;
		esac
	done
done
echo "Originals deleted: ${#deletedOriginals[@]}"
echo "Conflicts deleted: ${#deletedConflicts[@]}"
echo "Files for Further Review (Conflicts still exist): ${#forReview[@]}"
for i in "${forReview[@]}"; do 
	echo "$i"
done