#!/bin/bash
#########################################################
#  TODOIST FILTERS GENERATOR
#  [[ By: Mike Owens (GitLab/GitHub @ mikeo85) ]]
#  ---------------------------------------------------------
#  For simplifying management of my overlapping filters
#
#########################################################

# ===== CONFIGURE ALL FILTERS ===========================
# FILTER: NOW
# Description: P1, overdue, or due today
NOW="P1 | overdue | today"

# FILTER: NEXT
# Description: P2 or due within the next three days, and not NOW and not @recurring_nolead
NEXT="(P2 | 3 days) & !($NOW) & !@recurring_nolead"

# FILTER: LATER
# Description: P3 or due within 10 days. But not P1 or P2 or overdue or today or 3 days or @recurring*
LATER="(P3 | 10 days) & !(P1 | P2 | overdue | 3 days | @recurring*)"

# FILTER: MAIN
# Description: 1) NOW, 2) NEXT, 3) LATER, 4) @Waiting
MAIN="$NOW,$NEXT,$LATER,@Waiting"

# FILTER: MAIN-Personal
# Description: Same as main, but exclude work-related tasks from each section
MAINPersonal="($NOW) & !##Work,($NEXT) & !##Work,($LATER) & !##Work,(@Waiting) & !##Work"

# FILTER: MAIN-WORK
# Description: Same as main, but only include work-related tasks from each section
MAINWork="($NOW) & ##Work,($NEXT) & ##Work,($LATER) & ##Work,(@Waiting) & ##Work"

# FILTER: Super Old
# Description: Created more than 200 days ago, aren’t recurring, and don’t have a due date
SuperOld="created before: -200 days & !recurring & no due date"

# ===== OUTPUT ALL FILTERS ==============================
echo -e "\n### NOW\n"$NOW
echo -e "\n### NEXT\n"$NEXT
echo -e "\n### LATER\n"$LATER
echo -e "\n### MAIN\n"$MAIN
echo -e "\n### MAIN-Personal\n"$MAINPersonal
echo -e "\n### MAIN-Work\n"$MAINWork
echo -e "\n### Super Old\n"$SuperOld
echo ''