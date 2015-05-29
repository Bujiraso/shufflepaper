#!/bin/bash
# wallDims
# Returns the dimensions of the wallpaper passed in
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

while getopts ":f:hnr" opt; do
    case "$opt" in
        f) wall=${OPTARG}
        ;;
        h) cat << EOS
Usage: $me [OPTION]

    (no option)	       Print the dimensions of the wallpaper (format: width x height)
    -f                 Print the dimensions of the given wallpaper (format: width x height)
    -n                 Print the dimensions of the wallpaper without an x (format: width height)
    -h                 Display this help message
EOS
        exit 0
        ;;
        n) noX=true
        ;;
        r) ratio=true
        ;;
    esac
done

# Use current wallpaper on no args
if [[ -z "$wall" ]]; then
    echo "$me: Using current wallpaper." > /dev/stderr
    wall=$(getWallURI.sh)
fi

# Check file exists
if [[ ! -f $wall ]]; then
    echo "$me: File not found  - \"$wall\""
    exit 1
fi

if [[ "$wall" == *"png" ]]; then
    info=($(file "$wall" 2> /dev/null | sed 's/^.*PNG image data, //' | sed 's/,.*$//' | sed 's/ x//'))
    if [[ $? -ne 0 ]]; then
        echo "$me: Invalid image file \"$wall\""> /dev/stderr
        exit 2
    fi
    width=${info[0]}
    height=${info[1]}
elif [[ "$wall" == *"gif" ]]; then
    info=($(file "$wall" 2> /dev/null | sed 's/^.*GIF image data, //' | sed 's/,.*$//' | sed 's/ x//'))
    if [[ $? -ne 0 ]]; then
        echo "$me: Invalid image file \"$wall\""> /dev/stderr
        exit 3
    fi
    width=${info[1]}
    height=${info[2]}
else # JPG case
    info=($(imginfo -f "$wall" 2> /dev/null))
    if [[ $? -ne 0 ]]; then
        echo "$me: Invalid image file \"$wall\""> /dev/stderr
        exit 4
    fi
    width=${info[2]}
    height=${info[3]}
fi

if [[ $noX ]]; then
    echo $width $height
elif [[ $ratio ]]; then
    echo "$width / $height" | bc -l | sed 's,\.\([0-9][0-9]\).*,.\1,'
else
    echo "$width x $height"
fi
