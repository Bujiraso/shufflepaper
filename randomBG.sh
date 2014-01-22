#!/bin/bash
# randomBG.sh
# Changes the wallpaper to a random image in the defined folder

# Get local folder
localFolder="$(cd "$(dirname "$0")" && pwd)"

# Open config file for wallpaper location and shuffled list location
. $localFolder/shufflepaper.conf

# Check that the wallpaper folder is present
if [ ! -d "$WallLocation" ]; then
    echo >&2 'Cannot find wallpaper location'
    exit 1
fi
WallListFile=$localFolder/walls.shuf

# Create a shuffle file if one does not exist
if [ ! -f $WallListFile ] || [ "$(head "$WallListFile")" == "" ]; then
    (find "$WallLocation" -type f | shuf) > $WallListFile
else #if one does, then make sure all new pictures are added
    echo "$(diff <(sort walls.shuf) <(find $WallLocation -type f | sort) | grep $WallLocation | cut -c 1-2 --complement | shuf)" >> $WallListFile
fi

# Get first image from the list
ImagePath=$(head -n1 $WallListFile)

# If it isn't a file then keep iterating, add the missing files to a missing list
while [ ! -f "$ImagePath" ]; do
    echo $ImagePath >> $localFolder/walls.missing
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
