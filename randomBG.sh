#!/bin/bash
# randomBG.sh
# Changes the wallpaper to a random image in the defined folder
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


# Get local folder and files
localFolder="$(cd "$(dirname "$0")" && pwd)"
WallListFile=$localFolder/walls.shuf
MissingList=$localFolder/walls.missing

# Get first image from the list
ImagePath=$(head -n1 $WallListFile)

# If it isn't a file then keep iterating, add the missing files to a missing list
while [ ! -f "$ImagePath" ]; do
    if [[ ! $ImagePath =~ ^\ ?$ ]]; then #Don't echo empty lines
        echo $ImagePath >> $MissingList
    fi
    # Strip the first line, since it is not a file
    tail -n +2 $WallListFile >> $WallListFile.tmp
    mv $WallListFile.tmp $WallListFile
    ImagePath=$(head -n1 $WallListFile)
done

# Move the top item of the shuffle to the bottom
tail -n +2 $WallListFile >> $WallListFile.tmp
echo $ImagePath >> $WallListFile.tmp
mv $WallListFile.tmp $WallListFile

# Use change script to change the background
$localFolder/changeBG.sh "$ImagePath"
