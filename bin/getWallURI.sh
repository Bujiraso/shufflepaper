#!/usr/bin/env bash
# getWallURI.sh
# Gets the location of the current wallpaper without all the garbage
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

# Get background
if [ $(pgrep cinnamon | wc -l) -ne 0 ]; then
    url=$(gsettings get org.cinnamon.desktop.background picture-uri | cut -c9- | rev | cut -c2- | rev)
elif [ $(pgrep mate-session | wc -l) -ne 0 ]; then
    url=$(gsettings get org.mate.background picture-filename | cut -c2- | rev | cut -c2- | rev)
elif [ $(pgrep gnome | wc -l) -ne 0 ]; then
    export $(cat /proc/$(pgrep -u $(whoami) ^gnome-shell$ | head -n 1)/environ | grep -z DBUS_SESSION_BUS_ADDRESS | tr -d \\0)
    urlUncut=$(gsettings get org.gnome.desktop.background picture-uri)
    if [[ "$urlUncut" == "'file://"* || "$urlUncut" == \"file://* ]]; then
        url=$(echo "$urlUncut" | cut -c9- | rev | cut -c2- | rev)
    elif [[ "$urlUncut" == \'* ]]; then
        url="$(echo "$urlUncut" | cut -c2- | rev | cut -c2- | rev)"
    else
        url="$urlUncut"
    fi
else
    echo >&2 "Cannot read for session $DESKTOP_SESSION"
    exit 2
fi
echo "$url"
