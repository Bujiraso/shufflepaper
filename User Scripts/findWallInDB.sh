#!/bin/bash
# findWallInDB.sh
# Find the current wallpaper in the shufflepaperDB

. "$(dirname "$(readlink -f $0)")/../shufflepaperDB.conf"

wallURI=$(getWallURI.sh)
while getopts ":f:hn" opt; do
    case "$opt" in
        "f") wallURI="${OPTARG}"
           ;;
        "h") cat <<EOS
Usage:
$(basename "$0") [OPTIONS]

Options:
    -h         Print this help
    -n         Do not print the header column line
EOS
              exit 0
           ;;
        "n") noheader=true
           ;;
    esac
done

if [[ -z "$noheader" ]]; then
    echo "Inode | File Path | Category | Width | Height | Selected | View Count | Star Rating | User Comments | View Option"
fi
sqlite3 "$wallDB" "SELECT * FROM Wallpapers WHERE file_path=\"$wallURI\""
