#!/bin/bash
# updateWallInDB.sh
# Updates various modifiable aspects of a wallpaper in the shufflepaperDB

. "$(dirname "$(readlink -f "$0")")/shufflepaperDB.conf"
me=$(basename "$0")
wallURI=$(getWallURI.sh)

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
inode=$(findWallInDB.sh -n -f "$wallURI" | cut -d ' ' -f 1)

if [[ "$#" -ne 0 && -z "$inode" ]]; then
    echo "Fatal error: no inode"
    #exit 4
fi

while getopts ":a:c:df:hp:s:t:u:v:" opt; do
    case "$opt" in
        "a")
           comments="$(sqlite3 "$wallDB" "SELECT user_comments FROM Wallpapers WHERE inode=$inode")"
           if [[ -z "$sqlChanges" ]]; then
               comments=","
           fi
           comments=",${OPTARG}"
           sqlChanges="$sqlChanges""user_comments = \"$comments\","
           ;;
        "c")
           newCategory=${OPTARG}
           trgDir="$(dirname "$wallURI" | sed "s,/[0-9]/,/$newCategory/,")"
           if [[ ! -d "$trgDir" ]]; then
               echo "Target directory $trgDir does not exist. Create it?"
           else
               moveBG.sh -f "$wallURI" -t "$trgDir" < /dev/tty
               if [[ ! -f "$wallURI" ]]; then
                   expectedURI="$trgDir/$(basename "$wallURI")"
                   if [[ -f "$expectedURI" ]]; then
                       wallURI="$expectedURI"
                       sqlChanges="$sqlChanges""file_path=\"$expectedURI\", category=$newCategory,"
                   else
                       echo "The wallpaper has been lost."
                       echo "Please search for it at $wallURI and $expectedURI, or in $trgDir"
                       exit 9
                   fi
               fi
           fi
           ;;
        "d")
           sqlChanges="$sqlChanges"" width = $(wallDims -n -f "$wallURI" | tr -d '\n' | sed 's/ /, height = /'),"
           ;;
        "h")
           cat<<EOS
Usage:
$me [OPTIONS]...

Options
  -a           Add user comment (appends comma, then argument)
  -c           Update the category of this wallpaper
  -d           Refresh the dimensions of the wallpaper
  -f           Use a given file, not the current wallpaper
  -h           Display this help message
  -p           Update the path of the wallpaper
  -s           Update the star rating of the wallpaper
  -t           Update the selection of the wallpaper
  -u           Update user comments (use hyphen to edit existing in EDITOR)
  -v           Update the view count of the wallpaper
EOS
          exit 0
          ;;
        "p")
           sqlChanges="$sqlChanges"" file_path = ${OPTARG},"
          ;;
        "s")
           sqlChanges="$sqlChanges"" star_rating = ${OPTARG},"
          ;;
        "t")
           case "${OPTARG}" in
               "0"|"false"|"off"|"f"|"no"|"F"|"unselected") sel=0 ;;
               "1"|"true"|"on"|"t"|"yes"|"T"|"selected") sel=0 ;;
               *) echo "Invalid option -${OPTARG}"
                  exit 5
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
              echo "Cannot update view count on non-integer." >&2
              exit 6
          fi
          ;;
        \?) # Invalid option
           echo "$me: Invalid option -$OPTARG"
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
    echo "Running $sqlStmt"
    sqlite3 "$wallDB" "$sqlStmt"
else
    echo "No changes to make"
fi
