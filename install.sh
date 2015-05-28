#!/bin/bash
# createWallDB.sh
# Creates the wallDB

# Vars
. "$(dirname "$0")"/shufflepaper.conf
me="$(basename "$0")"

# Ensure data directory exists
if [[ ! -d "$dataDir" ]]; then
    mkdir -p "$dataDir"
fi

# Set up database
if [[ ! -f "$wallDB" ]]; then
    sqlite3 "$wallsDB" < "$installDir"/dbSetup.sql
else
    echo "$me: Error - walls.db exists at $wallsDB. Script will not install in place of existing files"
fi

if [[ ! -f "$userConf" ]]; then
    cat > "$userConf" << EOS
#!/bin/bash
# user.conf
# Update your wallpaper folder here

wallDir=\$HOME/Pictures/Wallpapers
EOS
else
    echo "$me: Error - user configuration exists at $userConf. Script will not install in place of existing files"
fi
