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

# Open config file for wallpaper location
. $localFolder/shufflepaper.conf

# Check that the wallpaper folder is present
if [ ! -d "$WallLocation" ]; then
    echo >&2 'Cannot find wallpaper location'
    exit 1
fi

# Create a shuffle file if one does not exist
if [ ! -f $WallListFile ] || [ "$(head "$WallListFile")" == "" ]; then
    (find "$WallLocation" -type f | shuf) > $WallListFile
else
    # List the files in the shuffled list that are now missing
    missing="$(diff <(sort $WallListFile) <(find $WallLocation -type f | sort) | grep \< | cut -c 1-2 --complement)"
    if [[ ! $missing =~ ^\ ?$ ]]; then # Don't echo empty lines
        echo "$missing" >> $MissingList
    fi
    # Remove any entries of the missing list from the shuffled list (if one exists)
    if [ -f $MissingList ]; then
        grep -v -f $MissingList $WallListFile > $WallListFile.tmp
        mv $WallListFile{.tmp,}
    fi
    # Update list with new files
    newFiles=$(diff <(sort $WallListFile) <(find $WallLocation -type f | sort) | grep -v \< | grep $WallLocation | cut -c 1-2 --complement | shuf)
    if [[ ! $newFiles =~ ^\ ?$ ]];  then
        echo "$newFiles" >> $WallListFile
    fi
fi

