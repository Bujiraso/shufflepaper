#!/bin/bash
# removeWall.sh
# Removes a wallpaper by inode or file path

# Check args
if [[ $# -eq 0 ]]; then
    echo "$me: Missing argument. An inode or file path is required."
    exit 1
fi

# Setup vars
. "$(dirname "$(readlink -f $0)")/../shufflepaperDB.conf"
file="$(readlink -f "$1")"
me=$(basename "$0")

# Compile SQL statement
string="DELETE FROM Wallpapers WHERE ("

# Match inode or file path
if [[ $1 =~ ^[0-9]+$ ]]; then
    string="$string""inode = \"$1\");"
else
    string="$string""file_path = \"$file\");"
fi

# Run SQL command
sqlite3 "$wallDB" "$string"

# Report any errors
if [[ $? -ne 0 ]]; then
    echo "$me: Failed to remove wallpaper using command: $string"
    exit 2
fi
