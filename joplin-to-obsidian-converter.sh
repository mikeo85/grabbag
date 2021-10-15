#!/usr/bin/env bash
set -euo pipefail
############################################################
#
#  Joplin To Obsidian Converter
#  ---------------------------------------------------------
#  Migrating Joplin Notes to Obsidian
#
#        Written by: Mike Owens
#        Email:      mikeowens (at) fastmail (dot) com
#        Website:    https://michaelowens.me
#        GitLab:     https://gitlab.com/mikeo85
#        GitHub:     https://github.com/mikeo85
#        Twitter:    https://twitter.com/quietmike8192
#
#  TODO Description of script plus any instructions
#  
############################################################

# //========== BEGIN INPUT VALIDATION ==========\\

## Input Validation Functions
## ----------------------------------------
exitHelp() { echo >&2 "$@";printf "%s" "$helpText";exit 1; }
countInputs() { [ "$#" -eq "$requiredNumOfInputs" ] || exitHelp "$requiredNumOfInputs argument(s) required, $# provided"; }
isNum() { echo "$1" | grep -E -q '^[0-9]+$' || exitHelp "Numeric argument required, \"$1\" provided"; }
inList() { local ckInput="$1"; shift; local arr=("$@"); printf '%s\n' "${arr[@]}" | grep -P -q "^$ckInput\$" || exitHelp "\"$ckInput\" is not a valid argument."; }

## Input Validation Process
## ----------------------------------------
## ++++ TO BE MODIFIED BY SCRIPT AUTHOR ++++

### TODO Define the Help Text With Usage Instructions
helpText="Usage: $(basename "$0") validates user inputs against expected values.
       $ $0 <input1> <input2>
"
### Define Input Requirements
### ----------------------------------------
#### Indicate the required number of inputs
requiredNumOfInputs=2

### Validate The Inputs
### ----------------------------------------
# countInputs "$@" # Were the expected number of inputs provided?

# \\=========== END INPUT VALIDATION ===========//

# //============================================\\
# \\============================================//

echo "Running $(basename "$0")..."
# //============ BEGIN SCRIPT BODY =============\\
## Receive Inputs
## ------------------------------------
# source="$1"
# destin="$2"
### Temporarily hardcoding file paths
#TODO remove before finalizing
source="/Users/mikeowens/Downloads/joplinExport/"
destin="/Users/mikeowens/Downloads/J2OC/"

## Create Working folders &  source files to working folder
## ------------------------------------
if [ -d "$destin" ]; then
    echo "Destination directory is $destin"
else
    echo "Creating directory $destin"
    mkdir "$destin"
fi
mkdir $destin/.jtoc
mkdir $destin/.jtoc/1
mkdir $destin/.jtoc/1_renamed
mkdir $destin/.jtoc/2
mkdir $destin/.jtoc/4
mkdir $destin/.jtoc/5
mkdir $destin/.jtoc/6
cp -r $source $destin/.jtoc/source
mv $destin/.jtoc/source/resources $destin/resources

## Initial Sorting and Moving of Files
## ------------------------------------
## Type 1 = Note
## Type 2 = Folder
## Type 4 = Attachment
## Type 5 = Tag
## Type 6 = ???

### Move Type 1
for file in $destin/.jtoc/source/*.md
do
    if [[ $(grep "type_: 1" $file | wc -l) -gt 0 ]]; then
        mv $file $destin/.jtoc/1
    fi
done

### Move Type 2
for file in $destin/.jtoc/source/*.md
do
    if [[ $(grep "type_: 2" $file | wc -l) -gt 0 ]]; then
        mv $file $destin/.jtoc/2
    fi
done

### Move Type 4
for file in $destin/.jtoc/source/*.md
do
    if [[ $(grep "type_: 4" $file | wc -l) -gt 0 ]]; then
        mv $file $destin/.jtoc/4
    fi
done

### Move Type 5
for file in $destin/.jtoc/source/*.md
do
    if [[ $(grep "type_: 5" $file | wc -l) -gt 0 ]]; then
        mv $file $destin/.jtoc/5
    fi
done

### Move Type 6
for file in $destin/.jtoc/source/*.md
do
    if [[ $(grep "type_: 6" $file | wc -l) -gt 0 ]]; then
        mv $file $destin/.jtoc/6
    fi
done

## Rename Notes Based on First Line of File
## ------------------------------------

### Function to sanitize filenames
sanitizeFilename() { echo $@ | sed 's/[\/\\?%*:|"<>,;=]/-/g'; }

STARTCOUNT=$(ls "$destin/.jtoc/1" | wc -l) #mck
for file in $destin/.jtoc/1/*.md
do
    # echo file is $file #mck
    newname=$(sanitizeFilename "$(sed -n '1p' "$file")").md
    # echo newname is $newname #mck
    newfile="$destin/.jtoc/1_renamed/$newname"
    # echo newfile is $newfile #mck
    # Check for duplicate filenames before copying
    # & add counter numbers as needed [e.g. (2), (3)] to avoid duplicates
    if [ -f "$newfile" ];then #check if filename already exists
        echo initial dup identified #mck
        i=2 #set counter
        while true;do #add counter and recheck filename until there are no duplicates
            # echo "i=$i" #mck
            testname="$(echo "$newname" | cut -f 1 -d '.')($i).md" #add counter to filename
            # echo testing $testname #mck
            if [ -f "$destin/.jtoc/1_renamed/$testname" ];then
                # echo duplicate #mck
                i=$(($i+1))
            else
                echo OK good name found -- $testname #mck
                newname="$testname"
                newfile="$destin/.jtoc/1_renamed/$newname"
                break
            fi
        done
    # else #mck
        # echo OK no dups #mck
    fi
    cp $file $file.temp
    # echo "Copied $file to $file.temp" #mck

    ### Gather joplin metadata into admonition block
    sed -i '' 's/^id: /```ad-info\ntitle: Metadata From Joplin\ncollapse: closed\nid: /' "$file.temp"
    # echo created admonition block #mck

    printf -v closeMetadata '\n```'
    echo "$closeMetadata" >> "$file.temp"
    # echo closed metadata #mck
    
    ### Get created time & prep backmatter
    createTime=$(grep "^created_time" "$file.temp" | sed 's/created_time: //')
    printf -v backmatter1 "\n---\n\n*Created Date: $createTime*\n"
    backmatter2='*Last Modified Date: <%+tp.file.last_modified_date("MMMM Do, YYYY (hh:ss a)")%>*'
    # echo prepped backmatter #mck

    ### Check for source_url & grab it if so
    if [[ $(grep source_url "$file.temp" | sed 's/source_url: //' |wc -m) -gt "1" ]];then
        sourceURL=$(grep source_url "$file.temp" | sed 's/source_url: //')
        printf -v addSourceURL "Source URL: %s \n\n" $sourceURL
    else
        addSourceURL=''
    fi
    # echo checked url #mck

    ### build frontmatter
    printf -v front_meta '%s\naliases: [\"\"]\n---\n\n*Primary Categories:* \n*Secondary Categories:*  \n*Links:* \n*Search Tags:* \n' '---'
    printf -v front_comment '%%%% { Add link(s) [[]] above to related PRIMARY categories, SECONDARY categories, LINKED terms, and search TAGS } %%%%\n\n'
    front_title="# [[$(echo "$newname" | cut -f 1 -d '.').md]]"
    # echo frontmatter #mck

    ### BUILD NEW NOTE FILE
    # newfile=$file #mck
    echo "$front_meta$front_comment$addSourceURL$front_title" > "$newfile"
    # echo "$front_meta$front_comment# HERE'S A TITLE" > "$newfile" #mck
    awk "NR > 1" "$file.temp" >> "$newfile"
    echo "$backmatter1$backmatter2" >> "$newfile"

    ### remove sourcefile
    # rm "$file.temp"
    # rm "$file"
done

ENDCOUNT=$(ls "$destin/.jtoc/1_renamed/" | wc -l)
echo "START: $STARTCOUNT | END: $ENDCOUNT"

# \\============= END SCRIPT BODY ==============//
echo "$(basename "$0") complete."
