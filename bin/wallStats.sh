#!/bin/bash
# wallStats.sh
# Find the current wallpaper in the shufflepaper and prints its entry to
# stdout
#  Copyright (C) 2015 Bujiraso

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

me=$(basename "$0")
myDir="$(dirname "$(readlink -f "$0")")"
. "$myDir/../conf/shufflepaper.conf"

wallURI=$("$myDir/getWallURI.sh")
while getopts ":df:hn" opt; do
    case "$opt" in
        "d") delimiter=true
           ;;
        "f") wallURI="$(readlink -f "${OPTARG}")"
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
        if [[ ! -f "$wallURI" ]]; then
            # Wall does not exist.
            exit 1
        fi
        # File path must need updating
        list=$(ls -li "$wallURI")
        if [[ "$?" -eq 0 ]]; then
            inode=$(echo "$list" | cut -f 1 -d ' ')
	    sqlite3 "$wallDB" "UPDATE Wallpapers SET file_path=\"$wallURI\" WHERE inode=$inode"
        fi
        result="$(sqlite3 "$wallDB" "SELECT * FROM Wallpapers WHERE inode=$inode")"
        if [[ -z "$result" ]]; then
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
ret=$?
if [[ "$ret" -eq 0 ]]; then
    if [[ -z "$delimiter" ]]; then
        echo "$output" | column -s\| -t
    else
        echo "$output"
    fi
else
    exit "$ret"
fi
