#!/bin/bash

# buildWallList.sh
# Creates a shuffled list of files in a folder
#  Copyright (C) 2014 Bujiraso

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

conf="${XDG_DATA_HOME:-$HOME/.local/share}/shufflepaper/shufflepaper.conf"
listFile="${XDG_DATA_HOME:-$HOME/.local/share}/shufflepaper/walls.shuf"

# Check that the wallpaper folder is present
checkDir() {
    if [[ "$1" == \#* || "$1" == "" ]]; then
        return 1
    fi
    if [[ ! -d "$1" ]]; then
        echo >&2 "Cannot find wallpaper location: $1"
        exit 1
    fi
}

# Create a shuffle file if one does not exist
if [ ! -f "$listFile" ] || [ "$(head "$listFile")" == "" ]; then
    echo "No wall list found. Creating new wall list"
    while read wallDir; do
        checkDir "$wallDir"
        if [[ $? -ne 0 ]]; then
            continue
        fi
        find "$wallDir" -type f >> "$listFile"
    done < "$conf"
    shuf "$listFile" > "$listFile".tmp
    mv "$listFile"{.tmp,}
else
    while read wallDir; do
        checkDir "$wallDir"
        if [[ $? -ne 0 ]]; then
            continue
        fi
        newFiles=$(diff <(sort "$listFile" | grep "$wallDir") <(find "$wallDir" -type f | sort) | grep -v \< | grep "$wallDir" | cut -c 1-2 --complement | shuf)
        if [[ ! $newFiles =~ ^\ ?$ ]];  then
            echo "$newFiles" >> "$listFile"
        fi
    done < "$conf"
fi
