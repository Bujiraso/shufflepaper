#!/bin/bash
# createWallDB.sh
# Creates the wallDB

# Vars
. "$(dirname $0)"/shufflepaper.conf
me="$(basename "$0")"

# Ensure data directory exists
if [[ ! -d "$dataDir" ]]; then
    mkdir -p "$dataDir"
fi

# Set up database
sqlite3 "$dataDir"/walls.db < "$installDir"/dbSetup.sql

cat > "$dataDir"/user.conf << EOS
#!/bin/bash
# user.conf
# Update your wallpaper folder here

wallDir=~/Pictures/Wallpapers
EOS
