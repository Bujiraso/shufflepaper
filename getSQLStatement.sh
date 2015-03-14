#!/bin/bash
# getSQLStatement.sh
# Returns the SQL statment for the given wallpaper inode or file path

me=$(basename "$0")

# Check args
if [[ "$#" -eq 0 ]]; then
    echo >&2 "$me: Missing args"
    exit 1
fi

# Setup vars
string=""
. "$(dirname $0)"/shufflepaperDB.conf
wallDims=~/bin/wallDims.sh

# Function: Get category
categorize() {
    num=$(echo "$(readlink -f "$1")" | sed 's,.*/\([0-9]\)/.*,\1,')
    if [[ "$num" =~ ^[0-9]$ ]]; then
        echo $num
    else
        echo $uncategorized
    fi
}

isSelected() {
    if [[ "$file" == "*/Unselected/*" ]]; then
        echo 0
    else
        echo 1
    fi
}

# Function: Compile an SQL Insert statement
buildInsert(){
    file="$1"

    # Insert syntax
    string="INSERT OR REPLACE INTO Wallpapers(inode, file_path, category, width, height, selected) VALUES("
    # Inode
    string="$string""$(stat "$file" --printf "%i, ")"
    # File path
    string="$string""\"$file\", "
    # Category
    string="$string""$(categorize "$file"), "
    # Dimensions
    dims=$("$wallDims" -n -f "$file")
    if [[ $? -ne 0 ]]; then
        echo "$me: Failed to build insert for $1" > /dev/stderr
        exit 2
    fi
    string="$string""$(echo $dims | tr -d '\n' | sed 's/ /, /'), "
    # Selectedness
    string="$string""$(isSelected "$file")"");"

    echo $string
}

# Function: Compile an SQL Update statement
buildUpdate() {
    inode="$1"
    file="$(find "$wallDir" -inum "$inode")"
    if [[ -f "$file" ]]; then # and the argument is a file
        # Update syntax
        string="UPDATE Wallpapers SET "
        # File path
        string="$string""file_path = \"$file\", "
        # Category
        string="$string""category = $(categorize "$file"), "
        # Dimensions
        string="$string""width = $("$wallDims" -n -f "$file" | tr -d '\n' | sed 's/ /, height = /'), "
        # Selectedness
        string="$string""selected = $(isSelected "$file") "
        # WHERE syntax
        string="$string""WHERE inode = $inode;"
    else # Remove the file path and deselect the wallpaper if it cannot be found
        string="UPDATE Wallpapers SET file_path = null, selected = 0 WHERE inode = $inode"
    fi
    echo $string
}

if [[ "$1" =~ ^[0-9]+$ ]]; then # Argument is an inode
    inode="$1"
    # Find file
    file=$(readlink -f "$(find $wallDir -inum $inode)")

    if [[ -f "$file" ]]; then # No entry, but file exists
        string="$(buildInsert "$file")"
    else
        echo "$me: File not found for inode $1" > /dev/stderr
    fi
else # Argument is not numerical
    file="$1"
    if [[ -f "$file" ]]; then
        string="$(buildInsert "$file")"
    fi
fi

if [[ ! -z "$string" ]]; then
    echo $string
fi
