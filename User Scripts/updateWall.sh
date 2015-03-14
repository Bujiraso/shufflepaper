#!/bin/bash
# updateWall.sh
# Updates various file system aspects of a wallpaper entry in the database

. "$(dirname "$(readlink -f $0)")/../shufflepaperDB.conf"
me=$(basename "$0")

if [[ "$#" -eq 0 ]]; then
    echo "No arguments." >&2
    exit 1
fi

arg="$1"

if [[ -f "$arg" ]]; then
    if list=$(ls -li "$arg") > /dev/null 2> /dev/null; then
        inode=$(echo "$list" | cut -f 1 -d ' ')
        sqlite3 "$wallDB" "UPDATE Wallpapers SET file_path=\"$arg\" WHERE inode=$inode"
    fi
    result="$(sqlite3 "$wallDB" "SELECT * FROM Wallpapers WHERE inode=$inode")"
    if [[ $? -eq 0 ]]; then
        echo "$result"
    else
        echo "$me: Error finding wallpaper"
        exit 1
    fi
else
    echo "$1 is not a file"
    exit 2
fi
