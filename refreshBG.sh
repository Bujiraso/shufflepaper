#!/bin/bash
# refreshBG.sh
# Gets the current wallpaper and refreshes it. Useful when changing displays
# loses the background image (bug in gnome when switching screens)
#  Copyright (C) 2014 Bujiraso

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

# Determine desktop session and change wallpaper
if [ $(pgrep cinnamon | wc -l) -ne 0 ]; then
    bg=$(DISPLAY=:0 GSETTINGS_BACKEND=dconf gsettings get org.cinnamon.desktop.background picture-uri)
elif [ $(pgrep mate-session | wc -l) -ne 0 ]; then
    bg=$(DISPLAY=:0 GSETTINGS_BACKEND=dconf gsettings get org.mate.background picture-filename | sed s/\'//g)
elif [ $(pgrep gnome | wc -l) -ne 0 ]; then
    bg=$(DISPLAY=:0 GSETTINGS_BACKEND=dconf gsettings get org.gnome.desktop.background picture-uri)
else
    echo >&2 "Cannot read for session $DESKTOP_SESSION"
    exit 2
fi

$(cd "$(dirname "$0")" && pwd)/changeBG.sh "$bg"
