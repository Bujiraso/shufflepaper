#!/bin/bash
# removeWall.sh
# Removes a wallpaper by inode or file path
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

# Check args
if [[ $# -eq 0 ]]; then
    echo "$me: Missing argument. An inode or file path is required."
    exit 1
fi

# Setup vars
. "$(dirname "$(readlink -f "$0")")/../conf/shufflepaper.conf"
file="$(readlink -f "$1")"
me=$(basename "$0")

# Compile SQL statement
string="DELETE FROM Wallpapers WHERE ("

# Match inode or file path
if [[ $1 =~ ^[0-9]+$ ]]; then
    string="$string""inode = \"$1\");"
else
    string="$string""file_path = \"$file\");"
fi

# Run SQL command
sqlite3 "$wallDB" "$string"

# Report any errors
if [[ $? -ne 0 ]]; then
    echo "$me: Failed to remove wallpaper using command: $string"
    exit 2
fi