#!/usr/bin/env bash
# randomBG.sh
# Selects a random wallpaper from the database
#  Copyright (C) 2015 - 2017 Bujiraso

#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  any later version.

#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.

#  You should have received a copy of the GNU General Public License
#  along with this program.  If not, see <http://www.gnu.org/licenses/>.

me="$(basename "$0")"
myDir="$(dirname "$(readlink -f "$0")")"
. "$myDir/../conf/shufflepaper.conf"
changeBG="$myDir/changeBG.sh"
alterWallInDB="$myDir/alterWallInDB.sh"

list=$(sqlite3 "$wallDB" 'SELECT inode,file_path,view_count,view_mode FROM Wallpapers WHERE '"$whereClause")
SAVEIFS=$IFS
IFS='|'
result=($(echo "$list" | shuf | head -n 1))
inode=${result[0]}
wall=${result[1]}
count=${result[2]}
viewMode=${result[3]}
IFS=$SAVEIFS

if [[ -z "$wall" ]]; then
    echo "$me: No wall found" >&2
    exit 1
else
    if [[ -f "$wall" ]]; then
        "$changeBG" "$wall"
        if [[ -z "$viewMode" ]]; then
            DISPLAY=:0 "$myDir/wallOption.sh" "scaled"
        else
            DISPLAY=:0 "$myDir/wallOption.sh" "$viewMode"
        fi
    else
        location=$(find "$wallDir" -inum "$inode")
        if [[ -f "$location" ]]; then
            "$changeBG" "$location"
        else
            "Could not find wallpaper $inode at $wall. Please locate and update the database."
            exit 5
        fi
    fi
fi

if [[ -z "$count" ]]; then
    "$alterWallInDB" -dv 1
else
    "$alterWallInDB" -dv "$((count + 1))"
fi
