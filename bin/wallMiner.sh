#!/usr/bin/env bash
# wallMiner.sh
# Mines in the user's wallpaper directory for pictures and adds them to the
# database
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

# Vars
me="$(basename "${0}")"
myDir="$(dirname "${0}")"
. "${myDir}/../conf/shufflepaper.conf"

diffFile=/tmp/inodeList.diff
inodeList="${dataDir}"/inode.list
logFile=/tmp/shufflepaper.log
tempList="/tmp/inode.list"
txnFile=/tmp/"${me}".txn

# Ensure data directory exists
if [[ ! -d "${dataDir}" ]]; then
    "${myDir}"/install.sh
fi

# Create inode list from database
sqlite3 "${wallDB}" "SELECT inode FROM Wallpapers;" | sort > "${inodeList}"

# Update all wallpapers that have been modified since last run
time=$(date +%s)
timeSince=$(( (${last_updated} - ${time}) / 86400 ))
while read line; do
    # Skip empty lines
    if [[ -z "${line}" ]]; then
        continue
    fi
    # If the inode is not present in the database, skip it, it will be added later
    if ! grep "${line}" "${inodeList}" > /dev/null; then
        continue
    fi
    file=$(sqlite3 "${HOME}/.local/share/shufflepaper/walls.db" 'SELECT file_path FROM Wallpapers WHERE inode ='"${line}")
    # Updating dims also checks file path
    "${myDir}/alterWallInDB.sh" -d -f "${file}"
done <<<"$(find "${wallDir}" \( -name "*jpg" -o -name "*png" \) -mtime "${timeSince}" -printf "%i\n" | sort)"
# When finished update lastUpdated time
sed -i 's/^\(last_updated=\).*$/\1'"$(date +%s)"'/' "${userConf}"

# Empty transaction file
echo -n > "${txnFile}"

# Create new list from files
find "${wallDir}" \( -name "*jpg" -o -name "*png" \) -printf "%i\n" | sort > "${tempList}"

# If an inode list exists compare with it
if [[ -f "${inodeList}" ]]; then
    change=false
    diff --speed-large-files "${inodeList}" "${tempList}" | grep [\>\<] > "${diffFile}"

    # Wallpaper removed condition
    if grep \< "${diffFile}" > /dev/null 2> /dev/null; then
        numRemoved=$(grep \< "${diffFile}" | wc -l)
        count=0
        while read line; do
             # Compile SQL statement
             string="DELETE FROM Wallpapers WHERE (inode = \"${line}\");"
             echo ${string} >> "${txnFile}"
             count=$((${count} + 1))
             echo -ne "Removing ${count} out of ${numRemoved}\r"
        done <<< "$(grep \< ${diffFile} | sed 's/^< //')"
        echo
        change=true
    fi

    if [[ -s "${txnFile}" ]]; then
        sqlite3 "${wallDB}" < "${txnFile}"
        echo > "${txnFile}"
        # If deletion fails, don't press on -- user needs to work it out
        if [[ ${?} -ne 0 ]]; then
            echo "${me}: $(date +%D.%T) Failed to execute transaction" | tee -a ${logFile} >> /dev/stderr
            exit 1
        fi
    fi

    # Wallpaper added condition
    if grep \> "${diffFile}"> /dev/null 2> /dev/null; then
        numRemoved=$(grep \> "${diffFile}" | wc -l)
        count=0
        while read line; do
             "${myDir}"/getSQLStatement.sh "${line}" >> "${txnFile}"
             count=$((${count} + 1))
             echo -ne "Compiling transaction (${count} of ${numRemoved})\r"
        done <<< "$(grep \> ${diffFile} | sed 's/^> //')"
        echo
        change=true
    fi

    rm "${diffFile}"

    # Update backgrounds with modification newer than the wallDB
    while read line; do
        change=true
        "${myDir}"/getSQLStatement.sh "${line}" >> "${txnFile}"
    done <<< "$(find "${wallDir}" -newer "${wallDB}" -type f \( -name "*png" -o -name "*jpg" \) -printf "%i\n" | sort)"

    if ! "${change}"; then
        echo "${me}: $(date +%D.%T) No changes to wallpapers detected." >> ${logFile}
    fi

else # If no inode list exists, add all wallpapers
    while read line; do
        "${myDir}"/getSQLStatement.sh "${line}" >> "${txnFile}"
    done <<< "$(cat ${tempList})"
fi

if [[ -s "${txnFile}" ]]; then
    echo "Running update transaction"
    sqlite3 "${wallDB}" < "${txnFile}"

    # On fail: warn and exit
    if [[ ${?} -ne 0 ]]; then
        echo "${me}: $(date +%D.%T) Failed to execute transaction" | tee -a ${logFile} >> /dev/stderr
        exit 1
    else
        echo "Transaction complete."
    fi
else
    echo "Nothing to do."
fi

rm "${txnFile}"
exit 0
