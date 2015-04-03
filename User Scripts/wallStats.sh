#!/bin/bash
# wallStats.sh
# Find the current wallpaper in the shufflepaperDB and prints its entry to
# stdout

. "$(dirname "$(readlink -f "$0")")"/../shufflepaperDB.conf
me=$(basename "$0")

wallURI=$($HOME/bin/getWallURI.sh)
while getopts ":df:hn" opt; do
    case "$opt" in
        "d") delimiter=true
           ;;
        "f") wallURI="${OPTARG}"
           ;;
        "h") cat <<EOS
Usage:
$me [OPTIONS]

Options:
    -d         Print with pipe (|) delimiter
    -f         Use the given file instead of the current wallpaper
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
    if [[ "$(sqlite3 "$wallDB" 'SELECT count(*) FROM Wallpapers WHERE file_path="'"$wallURI"'"')" -eq 0 ]]; then
        # File path must need updating
        list=$(ls -li "$wallURI")
        if [[ "$?" -eq 0 ]]; then
            inode=$(echo "$list" | cut -f 1 -d ' ')
	    sqlite3 "$wallDB" "UPDATE Wallpapers SET file_path=\"$wallURI\" WHERE inode=$inode"
        fi
        result="$(sqlite3 "$wallDB" "SELECT * FROM Wallpapers WHERE inode=$inode")"
        if [[ $? -ne 0 ]]; then
            echo "$me: Error finding wallpaper"
            exit 1
        fi
    else
        result="$(sqlite3 "$wallDB" "SELECT * FROM Wallpapers WHERE file_path=\"$wallURI\"")"
    fi   

    if [[ -z "$noheader" ]]; then
        echo "Inode|File Path|Category|Width|Height|Selected|View Count|Star Rating|User Comments|View Option"
    fi
    echo $result
}

output="$(findWall)"
if [[ "$?" -eq 0 ]]; then 
    if [[ -z "$delimiter" ]]; then
        echo "$output" | column -s\| -t
    else
        echo "$output"
    fi
fi
