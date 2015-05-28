#!/bin/bash
# Selects a random wallpaper from the database

# export DBUS_SESSION_BUS_ADDRESS environment variable to access current gnome wallpaper
export DBUS_SESSION_BUS_ADDRESS=$(grep -z DBUS_SESSION_BUS_ADDRESS "/proc/$(pgrep -u "$(whoami)" ^gnome-shell$)/environ" | cut -d= -f2-)
me="$(basename "$0")"
myDir="$(dirname "$(readlink -f "$0")")"
. "$myDir/shufflepaper.conf"
changeBG="$myDir/User Scripts/changeBG.sh"
alterWallInDB="$myDir/alterWallInDB.sh"

list=$(sqlite3 "$wallDB" 'SELECT file_path,view_count,view_mode FROM Wallpapers WHERE '"$whereClause"')')
SAVEIFS=$IFS
IFS='|'
result=($(echo "$list" | shuf | head -n 1))
wall=${result[0]}
count=${result[1]}
viewMode=${result[2]}
IFS=$SAVEIFS

if [[ -z "$wall" ]]; then
    echo "$me: No wall found" >&2
    exit 1
else
    if [[ -f "$wall" ]]; then
        if [[ ! "$wall" =~ .*/$mode/.* ]]; then
            echo "$me: Error. Wallpaper $wall is miscategorized as $mode."
            "$(readlink -f "$0")" "$*"
            exit 4
        fi
        "$changeBG" "$wall"
        if [[ -z "$viewMode" ]]; then
            DISPLAY=:0 "$myDir/User Scripts/wallOption.sh" "scaled"
        else
            DISPLAY=:0 "$myDir/User Scripts/wallOption.sh" "$viewMode"
        fi
    else
        location=$(find "$wallDir" -inum "$(sqlite3 "$wallDB" "SELECT inode FROM Wallpapers WHERE file_path=\"$wall\"")")
        if [[ -f "$location" ]]; then
            "$changeBG" "$location"
        else
            "Could not find $wall. Please locate and update the database."
            exit 5
        fi
    fi
fi

if [[ -z "$count" ]]; then
    "$alterWallInDB" -dv 1
else
    "$alterWallInDB" -dv "$((count + 1))"
fi
