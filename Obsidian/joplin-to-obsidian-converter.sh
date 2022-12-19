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
#        Mastodon:   https://infosec.exchange/@m0x4d
#        Twitter:    https://twitter.com/quietmike8192
#
#   Takes a Joplin RAW export and converts the notes for easy
#   copying into an Obsidian vault. Includes renaming the notes
#   from the Joplin ID to the title, recreating and resorting
#   into folders, converting Joplin Tags to Obsidian linked 
#   notes (on the assumption that Joplin tags are typically 
#   used for categories and keywords, whereas due to Obsidian's 
#   linking properties, tags are more suitable for tracking 
#   metadata like the type of note), and re-linking images
#   and attachments into notes.
#
#   USAGE
#   -----
#   Two inputs are required:
#   1) Source directory (location of the Joplin RAW export data)
#   2) Destination directory for the converted files
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
    
        ### TODO Define the Help Text With Usage Instructions
        helpText="Usage: $(basename "$0") converts a directory of Joplin RAW export files for importing into Obsidian.
            $ $0 <SourceDirectory> <DestinationDirectory>
        "
    ### Define Input Requirements
    ### ----------------------------------------
    #### Indicate the required number of inputs
        requiredNumOfInputs=2

    ### Validate The Inputs
    ### ----------------------------------------
        countInputs "$@" # Were the expected number of inputs provided?

# \\=========== END INPUT VALIDATION ===========//

# //============================================\\
# \\============================================//

echo "Running $(basename "$0")..."
# //============ BEGIN SCRIPT BODY =============\\

    ## FUNCTIONS
    ## ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        getBasenameNoExt() { echo "$(basename "$@")" | cut -f 1 -d '.'; } # Input: Filename
        getFirstLine() { sed -n '1p' "$@"; } # Input: filename
        sanitizeFilename() { echo "$@" | sed 's/[?%*"<>,;.]//g'| sed 's/[:|]/-/g' | sed 's/[\/\\=]/_/g'| sed 's/\[/(/g' | sed 's/\]/)/g'; } # Input: filename
        #### Function to get tags from taglist
            getTags() {
                if [[ $(grep "$@" "$destin/.jtoc/notetaglist.txt" | wc -l) -gt "0" ]];then
                    echo "$(grep "$@" "$destin/.jtoc/notetaglist.txt" | sed "s/$@:/[[/g" | sed 's/$/]]/g' | tr -d '\n' | sed 's/\]\[/\] - \[/g')"
                else
                    echo ''
                fi
            }
    ## ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    ## Receive Inputs
    ## ------------------------------------
        source="$1"
        destin="$2"

    ## Create Working folders
    ## ------------------------------------
        if [ -d "$destin" ]; then
            echo "Destination directory is $destin"
        else
            echo "Creating directory $destin"
            mkdir "$destin"
        fi
        mkdir $destin/.jtoc
        mkdir $destin/.jtoc/.notes
        mkdir $destin/.jtoc/.notes_renamed
        mkdir $destin/.jtoc/.folders
        mkdir $destin/.jtoc/.attached
        mkdir $destin/.jtoc/.tags
        mkdir $destin/.jtoc/.notetag
        mkdir $destin/.jtoc/temp
        cp -r $source $destin/.jtoc/source
        mv $destin/.jtoc/source/resources $destin/.jtoc/temp/_resources

    ## Initial Sorting and Moving of Files
    ## ------------------------------------
        ## Type 1 = Note
        ## Type 2 = Folder
        ## Type 4 = Attachment
        ## Type 5 = Tag
        ## Type 6 = Note-Tag Relationship

        ### Move Type 1
        echo "Identifying notes"
        for file in $destin/.jtoc/source/*.md;do if [[ $(grep "type_: 1" $file | wc -l) -gt 0 ]]; then mv $file $destin/.jtoc/.notes;fi;done
        ### Move Type 2
        for file in $destin/.jtoc/source/*.md;do if [[ $(grep "type_: 2" $file | wc -l) -gt 0 ]]; then mv $file $destin/.jtoc/.folders;fi;done
        echo "Identifying folders"
        ### Move Type 4
        echo "Identifying attachments"
        for file in $destin/.jtoc/source/*.md;do if [[ $(grep "type_: 4" $file | wc -l) -gt 0 ]]; then mv $file $destin/.jtoc/.attached;fi;done
        ### Move Type 5
        echo "Identifying tags"
        for file in $destin/.jtoc/source/*.md;do if [[ $(grep "type_: 5" $file | wc -l) -gt 0 ]]; then mv $file $destin/.jtoc/.tags;fi;done
        ### Move Type 6
        echo "Identifying note-tag relationships"
        for file in $destin/.jtoc/source/*.md;do if [[ $(grep "type_: 6" $file | wc -l) -gt 0 ]]; then mv $file $destin/.jtoc/.notetag;fi;done

    ## Create Initial Content Folders
    ## ----------------------
        echo "Creating folders"
        for file in $destin/.jtoc/.folders/*.md;do
            dir=$(getBasenameNoExt "$file")
            mkdir "$destin/.jtoc/temp/$dir"
        done

    ## Create Note-Tag Match list
    ## ------------------------------------
        echo "Creating index of note-tag relationships"
        noteTagList=$destin/.jtoc/notetaglist.txt
        # notesWithTags=$(dirname $noteTagList)/noteswithtags.txt #helpCheck
        echo 'note_id:tag' > "$noteTagList"
        # touch $notesWithTags #helpCheck
        for file in $destin/.jtoc/.notetag/*.md;do
            noteID=$(grep "^note_id" "$file" | sed 's/note_id: //')
            tagID=$(grep "^tag_id" "$file" | sed 's/tag_id: //')
            tagName=$(getFirstLine "$destin/.jtoc/.tags/$tagID.md")
            echo "$noteID:$tagName" >> $noteTagList
            # echo "$noteID" >> $notesWithTags #helpCheck
        done

    ## Generate Attachments List
    ## ------------------------------------
    ls $destin/.jtoc/temp/_resources/ > $destin/.jtoc/attachmentslist

    ## NOTE BUILDER
    ## ------------------------------------

        ### Get Count and set up progress counter
            STARTCOUNT=$(ls "$destin/.jtoc/.notes" | wc -l)
            echo "Beginning conversion of $STARTCOUNT notes"
            notesProcessed="0"
            p25=0
            p50=0
            p75=0
        
        ### Create filename index for checking filenames for duplicates
            echo '' > $destin/.jtoc/filenameIndex.txt

        for file in $destin/.jtoc/.notes/*.md;do
            # echo "Processing $file" #helpCheck

            ### Get key metadata fields
                noteID=$(grep "^id" "$file" | sed 's/id: //')
                noteTitle=$(getFirstLine $file)
                # echo noteID is $noteID #helpCheck
                createTime=$(grep "^created_time" "$file" | sed 's/created_time: //')
                parentID=$(grep "^parent_id" "$file" | sed 's/parent_id: //')
                #### Check for source_url & grab it if so
                    sourceURL='' #initializing
                    searchTag='' #initializing
                    isWebCapture=0 #initializing
                    if [[ $(grep source_url "$file" | sed 's/source_url: //' |wc -m) -gt "1" ]];then
                        sourceURL=$(grep source_url "$file" | sed 's/source_url: //')
                        searchTag='#webcapture'
                        isWebCapture=1
                    fi
                    # echo checked url #helpCheck
                joplinMetadataStart=$(grep -n '^id' "$file" | cut -f 1 -d ':')
                # echo "metadata done" #helpCheck

            ### Use parentID to get the names of the containing folders as "category" notes
                printf -v parentName '[[%s]]' "$(sanitizeFilename "$(getFirstLine $destin/.jtoc/.folders/$parentID.md)")"
                # echo "**$parentID**" #helpCheck
                # echo "@@$parentName@@" #helpCheck
                # echo "does parent have parent: $(grep "^parent_id" "$destin/.jtoc/.folders/$parentID.md" | sed 's/parent_id: //' | wc -m)" #helpCheck
                if [[ $(grep "^parent_id" "$destin/.jtoc/.folders/$parentID.md" | sed 's/parent_id: //' | wc -m) -gt "1" ]];then
                    parent2ID=$(grep "^parent_id" "$destin/.jtoc/.folders/$parentID.md" | sed 's/parent_id: //')
                    printf -v parent2Name '[[%s]]' "$(sanitizeFilename "$(getFirstLine "$destin/.jtoc/.folders/$parent2ID.md")")"
                    # echo "parent2**$parent2ID**" #helpCheck
                    # echo "parent2@@$parent2Name@@" #helpCheck
                else
                    parent2Name=''
                fi
                # echo parentName $parentName #helpCheck
                # echo parent2Name $parent2Name #helpCheck
                
            ### Get note tags and add them as links
                # NOTE: Not translating tags to tags -- rather translating tags into (uncreated) notes 
                # that then serve as obsidian links between related files. This is more in line with 
                # how I'm differentiating notes and tags in obsidian, i.e. using tags for note types 
                # and structural indicators, not concepts/topics/categories.
                taglist=$(getTags "$noteID")
                # echo "got taglist: $taglist" #helpCheck

            ### Get New Note Name from First Line of File
                # echo file is $file #helpCheck
                newname=$(sanitizeFilename "$noteTitle").md
                # echo newname is $newname #helpCheck
                #### Check for duplicate filenames before copying & add counter numbers as needed [e.g. (2), (3)] to avoid duplicates
                    # echo "@@@@@ DUPLICATE CHECK: $(grep "$newname" "$destin/.jtoc/filenameIndex.txt" | wc -l)" #helpCheck
                    if [ $(grep "$newname" "$destin/.jtoc/filenameIndex.txt" | wc -l) -gt "0" ];then # check if filename already exists in index
                        # echo initial dup identified #helpCheck
                        i=2 # set counter
                        while true;do # add counter and recheck filename until there are no duplicates
                            # echo "i=$i" #helpCheck
                            testname="$(echo $newname | cut -f 1 -d '.')($i).md" #add counter to filename
                            # echo testing $testname #helpCheck
                            if [ $(grep "$testname" "$destin/.jtoc/filenameIndex.txt" | wc -l) -gt "0" ];then
                                # echo duplicate #helpCheck
                                i=$(($i+1))
                            else
                                # echo OK good name found -- $testname #helpCheck
                                newname="$testname"
                                break
                            fi
                        done
                    # else #helpCheck
                        # echo OK no dups #helpCheck
                    fi
                # echo newname is $newname #helpCheck

            ### Build converted note
                newFileName="$destin/.jtoc/temp/$parentID/$newname"
                # echo "newfilename is $newFileName" #helpCheck

                ### Add frontmatter
                    printf '%s\naliases: [\"\"]\n---\n\n' '---' > "$newFileName"
                    printf '*Primary Categories:* %s\n*Secondary Categories:* %s\n*Links:* %s\n*Search Tags:* %s\n' "$parent2Name" "$parentName" "$taglist" "$searchTag" >> "$newFileName"
                    if [ "$isWebCapture" -eq "1" ];then
                        echo "*Source URL:* $sourceURL" >> "$newFileName"
                    fi
                    printf '%%%% { Add link(s) [[]] above to related PRIMARY categories, SECONDARY categories, LINKED terms, and search TAGS } %%%%\n\n' >> "$newFileName"
                    echo "# [[$(echo $newname | cut -f 1 -d '.')]]" >> "$newFileName"
                    # echo "added frontmatter" #helpCheck
                
                ### Add Note Body
                    awk "NR > 1 && NR < $joplinMetadataStart" "$file" >> "$newFileName"
                    echo '---' >> "$newFileName"
                    if [ "$isWebCapture" -eq "1" ];then
                        echo '***##### END OF WEBCAPTURE #####***' >> "$newFileName"
                    fi
                    # echo "added note body" #helpCheck

                ### Check for and update attachments
                    fileAttached=$(grep -E '!\[.?\]\(:/' "$newFileName" | sed 's/^.*(:\///' | sed 's/[^a-z0-9].*//' | sort -u) || fileAttached=0
                    if [ "$fileAttached" != 0 ];then
                        for i in $(echo $fileAttached);do
                            # echo "checking for $i" #helpCheck
                            attachFile=$(grep "$i" "$destin/.jtoc/attachmentslist") || attachFile="0"
                            # echo "$attachFile" #helpCheck
                            # echo "check done $i" #helpCheck
                            if [ "$(echo $attachFile)" != 0 ];then
                                sed -i '' "s#:/$i#_resources/$attachFile#g" "$newFileName"
                            fi
                        done
                        # echo "updated attachments" #helpCheck
                    # else #helpCheck
                        # echo "no attachments" #helpCheck
                    fi

                ### Add Joplin Metadata
                    printf "%sad-info\ntitle: Metadata From Joplin\ncollapse: closed\n" '```' >> "$newFileName"
                    awk "NR>=$joplinMetadataStart" "$file" >> "$newFileName"
                    echo '```' >> "$newFileName"
                    # echo "added joplin metadata" #helpCheck

                ### Add backmatter
                    printf "\n---\n\n*Created Date: $createTime*\n" >> "$newFileName"
                    echo '*Last Modified Date: <%+tp.file.last_modified_date("MMMM Do, YYYY (hh:ss a)")%>*' >> "$newFileName"
                    # echo "added backmatter" #helpCheck

            echo "$newname" >> $destin/.jtoc/filenameIndex.txt

            ### Update Progress
            notesProcessed=$(($notesProcessed + 1))
            multNotesProcessed=$(($notesProcessed * 100))
            progress=$(($multNotesProcessed / $STARTCOUNT))
            # echo progress $progress #helpCheck
            if [[ $progress -ge "75" ]] && [[ $p75 == 0 ]] ;then
                p75=1
                echo "Conversion at 75%"
            elif [[ $progress -ge "50" ]] && [[ $p50 == 0 ]] ;then
                p50=1
                echo "Conversion at 50%"
            elif [[ $progress -ge '25' ]] && [[ $p25 == 0 ]] ;then
                p25=1
                echo "Conversion at 25%"
            fi
        done

        echo "Notes conversion done. Processed $notesProcessed of $STARTCOUNT notes."

    ## Rename Initial Content Folders
    ## ----------------------
        for file in $destin/.jtoc/.folders/*.md;do
            dir=$(echo "$(basename $file)" | cut -f 1 -d '.')
            newdir=$(sed -n '1p' "$file")
            mv "$destin/.jtoc/temp/$dir" "$destin/.jtoc/temp/$newdir"
        done

    ## MOVE processed content to $destin
        mv "$destin/.jtoc/temp/" "$destin"

    ## Remove all temporary processing folders
        rm -rf "$destin/.jtoc"

# \\============= END SCRIPT BODY ==============//
echo "$(basename "$0") complete."
