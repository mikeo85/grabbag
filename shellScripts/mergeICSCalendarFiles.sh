#!/bin/bash
#########################################################
#  Merge .ics Calendar Files for Easy Import
#  [[ By: Mike Owens (GitLab/GitHub @ mikeo85) ]]
#  ---------------------------------------------------------
#  Reference:
#  - https://unix.stackexchange.com/questions/539600/merge-multiple-ics-calendar-files-into-one-file
#  - https://iaizzi.me/2021/02/10/how-to-merge-ics-files/
#########################################################

echo "BEGIN:VCALENDAR" >> merge;
for file in *.ics; do 
cat "$file" | sed -e '$d' $1 | sed -e '1,/VEVENT/{/VEVENT/p;d;}' $2  >> merge; 
done
mv merge merge.ics
echo "END:VCALENDAR" >> merge.ics;
