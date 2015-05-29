#!/bin/bash
# changeBG.sh
# Changes the wallpaper for the current desktop session. Implemented for Cinnamon, Gnome and Mate
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
if [[ $# -eq 0 ]]; then
    echo >&2 "$me: No args given."
    exit 1
fi

file="$1"

#Check that the file is prefixed by "file://"
function prefixURI {
    if [[ ! -f  "$(echo "${file##*:\/\/}" | sed s/^\'// | sed s/\'$//)" ]]; then
        echo >&2 "$me: File \"$file\" does not exist"
        exit 2
    fi

    if [[ ! "$file" = *"file://"* ]]; then
        tmp="file://""$(readlink -f "$file")"
        file="$tmp"
    fi
} 

# Determine desktop session and change wallpaper
if [ $(pgrep cinnamon | wc -l) -ne 0 ]; then
    prefixURI
    export $(cat /proc/$(pgrep -u `whoami` ^cinnamon | head -n 1)/environ | grep -z DBUS_SESSION_BUS_ADDRESS)
    DISPLAY=:0 gsettings set org.cinnamon.desktop.background picture-uri "$file"
elif [ $(pgrep mate-session | wc -l) -ne 0 ]; then
    export $(cat /proc/$(pgrep -u `whoami` ^mate-session | head -n 1)/environ | grep -z DBUS_SESSION_BUS_ADDRESS)
    DISPLAY=:0 gsettings set org.mate.background picture-filename "$file"
elif [ $(pgrep gnome | wc -l) -ne 0 ]; then
    prefixURI
    export "$(cat /proc/$(pgrep -u `whoami` ^gnome-shell | head -n 1)/environ | grep -z DBUS_SESSION_BUS_ADDRESS)"
    DISPLAY=:0 gsettings set org.gnome.desktop.background picture-uri "$file"
else
    echo >&2 "$me: Cannot read for session $DESKTOP_SESSION"
    exit 3
fi
