#!/usr/bin/env bash
# updateWallInDB.sh
# Updates various modifiable aspects of a wallpaper in the shufflepaper database
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

me=$(basename "$0")
myDir="$(dirname "$(readlink -f "$0")")"
. "$myDir/../conf/shufflepaper.conf"
wallURI=$("$myDir/getWallURI.sh")
log="/tmp/shufflepaper.log"

# The file needs to be asserted first, out of all the arguments
count=1
while [[ "$count" -le "$#" ]]; do
    if [[ "${!count}" == "-f" ]]; then
      # Check that the wall file is not being set multiple times
      if [[ -z "$set" ]]; then
          set=true
          count=$((count+1))
          wallURI=${!count}
      else
          echo "$me: Wall file cannot be set twice." >&2
          exit 3
      fi
    fi
    count=$((count + 1))
done

#Get inode so that if /anything/ else changes we can still update
inode=$("$myDir/wallStats.sh" -n -f "$wallURI" | cut -d ' ' -f 1)

if [[ "$#" -ne 0 && -z "$inode" ]]; then
    echo "$me: Fatal error: no inode found for $wallURI" >&2
    exit 4
fi

# If the file path is currently wrong, find the file by inode
if [[ ! -f "$wallURI" ]]; then
    newURI="$(find "$wallDir" -inum "$inode")"
    if [[ -f "$newURI" ]]; then
        echo "$me: File path $wallURI is incorrect. Using $newURI instead." >&2
        sqlChanges="$sqlChanges"" file_path=\"$newURI\","
        wallURI="$newURI"
    else
        echo "$me: Cannot find file $file or inode $inode" >&2
        exit 5
    fi
fi

while getopts ":a:c:df:hm:p:s:t:u:v:" opt; do
    case "$opt" in
        "a")
           comments="$(sqlite3 "$wallDB" "SELECT user_comments FROM Wallpapers WHERE inode=$inode")"
           if [[ -z "$sqlChanges" ]]; then
               comments=","
           fi
           comments=",${OPTARG}"
           sqlChanges="$sqlChanges"" user_comments = \"$comments\","
           ;;
        "d")
           dims=($("$myDir/wallDims.sh" -n -f "$wallURI"))
           if [[ ${dims[0]} -eq 0 || ${dims[1]} -eq 0 ]]; then
               echo "$me: Cannot get dimensions for $wallURI." >&2
               exit 6
           fi
           sqlChanges="$sqlChanges"" width = ${dims[0]}, height = ${dims[1]},"
           ;;
        "h")
           cat<<EOS
Usage: $me OPTIONS...

Options
  -a           Add user comment (appends comma, then argument)
  -d           Refresh the dimensions of the wallpaper
  -f           Use a given file, not the current wallpaper
  -h           Display this help message
  -m           Update the view mode of the wallpaper
                 (use hyphen to select from options)
  -p           Update the path of the wallpaper
  -s           Update the star rating of the wallpaper
  -t           Update the selection of the wallpaper
  -u           Update user comments (use hyphen to edit existing in EDITOR)
  -v           Update the view count of the wallpaper
EOS
          exit 0
          ;;
        "m")
          OPTIONS="centered scaled spanned zoom stretched wallpaper"
          if [[ "${OPTARG}" == - ]]; then
              select choice in $OPTIONS; do
                  sqlChanges="$sqlChanges"" view_mode =\"$choice\","
                  break
              done
          else
              case ${OPTARG} in
                  "centered"|"scaled"|"spanned"|"zoom"|"stretched"|"wallpaper")
                      sqlChanges="$sqlChanges"" view_mode =\"${OPTARG}\","
                  ;;
                  *) #Invalid view option
                      echo "$me: Invalid picture option ${OPTARG}" >&2
                      exit 8
                  ;;
              esac
          fi
          ;;
        "p")
           sqlChanges="$sqlChanges"" file_path = ${OPTARG},"
          ;;
        "s")
           if [[ "${OPTARG}" =~ ^[1-5]$ || "${OPTARG}" == "NULL" ]]; then
               sqlChanges="$sqlChanges"" star_rating = ${OPTARG},"
           else
               echo "$me: Invalid star rating ${OPTARG}" >&2
               exit 10
           fi
          ;;
        "t")
           case "${OPTARG}" in
               "0"|"false"|"off"|"f"|"no"|"F"|"unselected") sel=0 ;;
               "1"|"true"|"on"|"t"|"yes"|"T"|"selected") sel=1 ;;
               *) echo "$me: Invalid selectedness ${OPTARG}" >&2
                  exit 7
               ;;
           esac
           sqlChanges="$sqlChanges"" selected = $sel,"
          ;;
        "u")
           if [[ "${OPTARG}" == "-" ]]; then
               tempFile="/tmp/alterWallInDB.$(date +%s).comments"
               sqlite3 "$wallDB" "SELECT user_comments FROM Wallpapers WHERE inode=$inode" > $tempFile
               $EDITOR $tempFile
               comments=$(cat "$tempFile")
               sqlChanges="$sqlChanges""user_comments = \"$comments\","
           else
               sqlChanges="$sqlChanges""user_comments = \"${OPTARG}\","
           fi
           ;;
        "v")
          if [[ "${OPTARG}" =~ ^[0-9]+$ ]];then
              sqlChanges="$sqlChanges"" view_count = ${OPTARG},"
          else
              echo "$me: Cannot update view count on non-integer." >&2
              exit 9
          fi
          ;;
        \?) # Invalid option
           echo "$me: Invalid option -$OPTARG" >&2
           exit 1
          ;;
        :)
           echo "$me: Option -$OPTARG requires an argument." >&2
           exit 2
          ;;
    esac
done

if [[ ! -z "$sqlChanges" ]]; then
    sqlStmt="UPDATE Wallpapers SET ${sqlChanges%,} WHERE inode=$inode"
    echo "$(date +%Y-%m-%d-%T): $me: Running $sqlStmt" >> "$log"
    sqlite3 "$wallDB" "$sqlStmt"
    if [[ $? -ne 0 ]]; then
        echo "$me: Errors occurred updating $wallURI while running $sqlStmt" > >(tee -a "$log" >&2)
    fi
else
    echo "$(date +%Y-%m-%d-%T): $me: No changes to make" >> "$log"
fi
