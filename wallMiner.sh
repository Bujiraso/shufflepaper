#!/bin/bash
# wallMiner.sh
# Mines in the user's wallpaper directory for pictures and adds them to the
# database

# Vars
. "$(dirname $0)"/shufflepaperDB.conf
me="$(basename "$0")"

diffFile=/tmp/inodeList.diff
inodeList="$dataDir"/inode.list
logFile=/tmp/"$me".log
tempList="/tmp/inode.list"
txnFile=/tmp/"$me".txn

# Ensure data directory exists
if [[ ! -d "$dataDir" ]]; then
    "$installDir"/install.sh
fi

# Empty transaction file
echo -n > "$txnFile"

# Create new list from files
find "$wallDir" \( -name "*jpg" -o -name "*png" \) -printf "%i\n" | sort > "$tempList"

# Refresh old list from DB
sqlite3 "$wallDB" "SELECT inode FROM Wallpapers;" > "$inodeList"

# If an inode list exists compare with it
if [[ -f "$inodeList" ]]; then
    change=false
    diff --speed-large-files "$inodeList" "$tempList" | grep [\>\<] > "$diffFile"

    # Wallpaper removed condition
    if grep \< "$diffFile"> /dev/null 2> /dev/null; then
        while read line; do
             # Compile SQL statement
             string="DELETE FROM Wallpapers WHERE (inode = \"$line\");"
             echo $string >> "$txnFile"

        done <<< "$(grep \< $diffFile | sed 's/^< //')"
        change=true
    fi

    sqlite3 "$wallDB" < "$txnFile"
    echo "Removed walls" > "$logFile"

    # Wallpaper added condition
    if grep \> "$diffFile"> /dev/null 2> /dev/null; then
        while read line; do
             "$installDir"/getSQLStatement.sh "$line" >> "$txnFile"
        done <<< "$(grep \> $diffFile | sed 's/^> //')"
        change=true
    fi

    rm "$diffFile"

    # Update backgrounds with modification newer than the wallDB
    while read line; do
        change=true
        "$installDir"/getSQLStatement.sh "$line" >> "$txnFile"
    done <<< "$(find "$wallDir" -newer "$wallDB" -type f \( -name "*png" -o -name "*jpg" \) -printf "%i\n" | sort)"

    if ! "$change"; then
        echo "$me: $(date +%D.%T) No changes to wallpapers detected." >> $logFile
    fi

else # If no inode list exists, add all wallpapers
    while read line; do
        "$installDir"/getSQLStatement.sh "$line" >> "$txnFile"
    done <<< "$(cat $tempList)"
fi

sqlite3 "$wallDB" < "$txnFile"
# On fail: warn and exit
if [[ $? -ne 0 ]]; then
    echo "$me: $(date +%D.%T) Failed to execute transaction" | tee -a $logFile >> /dev/stderr
    exit 1
fi

# Replace old list with new list, if any exists
mv "$tempList" "$inodeList"
