#!/bin/bash
# createWallDB.sh
# Creates the wallDB
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
# Update your wallpaper folder and random selection qualifiers here

wallDir=\$HOME/Pictures/Wallpapers
whereClause='selected=1'
EOS
else
    echo "$me: Error - user configuration exists at $userConf. Script will not install in place of existing files"
fi
