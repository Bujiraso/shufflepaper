#!/bin/bash
# wallMinusOne
# Moves the last item to the top, but does not change the wallpaper.
# This means this script can be run as many times as necessary in order
# to roll back any missed wallpapers.

# Get shuffle file
listFile=${XDG_DATA_HOME:-$HOME/.local/share}/shufflepaper/walls.shuf
MissingList=${XDG_DATA_HOME:-$HOME/.local/share}/shufflepaper/walls.missing

# Get last image from the list
imageURI=$(tail -n1 "$listFile")

# Until a file is found, keep iterating and add the missing files to a missing list
while [[ ! -f "$imageURI" && ! "$imageURI" == "" ]]; do
    if [[ ! "$imageURI" =~ ^\ ?$ ]]; then #Don't echo empty lines
        echo "$imageURI" >> "$MissingList"
    fi
    # Strip the last line, since it is not a file anymore
    head -n -2 "$listFile" >> "$listFile.tmp"
    mv "$listFile.tmp" "$listFile"
    imageURI=$(tail -n1 "$listFile")
done

# Move the last item of the shuffle to the top
echo "$imageURI" >> "$listFile.tmp"
head -n -1 "$listFile" >> "$listFile.tmp"
mv "$listFile.tmp" "$listFile"
