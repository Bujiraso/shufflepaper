#!/bin/bash
# findWallInDB.sh
# Find the current wallpaper in the shufflepaperDB

. "$(dirname "$(readlink -f $0)")/../shufflepaperDB.conf"
me=$(basename "$0")

wallURI=$(getWallURI.sh)
while getopts ":f:hn" opt; do
    case "$opt" in
        "f") wallURI="${OPTARG}"
           ;;
        "h") cat <<EOS
Usage:
$me [OPTIONS]

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

findWall() {
    if [[ "$(sqlite3 "$wallDB" 'SELECT count(*) FROM Wallpapers WHERE file_path="$wallURI"')" -eq 0 ]]; then
        result="$(updateWall.sh "$wallURI")"
    else
        result="$(sqlite3 "$wallDB" "SELECT * FROM Wallpapers WHERE file_path=\"$wallURI\"")"
    fi   

    if [[ -z "$noheader" ]]; then
        echo "Inode|File Path|Category|Width|Height|Selected|View Count|Star Rating|User Comments|View Option"
    fi
    echo "$result"
}

output="$(findWall)"
if [[ "$?" -eq 0 ]]; then 
    echo "$output" | column -s\| -t
fi
