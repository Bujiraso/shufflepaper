#!/bin/bash
# findBG.sh
# Opens the current desktop wallpaper in an executable (works well with eog or a file manager)
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

url=
if [ $(pgrep cinnamon | wc -l) -ne 0 ]; then
    url=$(gsettings get org.cinnamon.desktop.background picture-uri | cut -c9- | rev | cut -c2- | rev)
#    nemo "$url"
elif [ $(pgrep mate-session | wc -l) -ne 0 ]; then
    url=$(gsettings get org.mate.background picture-filename | cut -c2- | rev | cut -c2- | rev)
#    caja "$url"
elif [ $(pgrep gnome | wc -l) -ne 0 ]; then
    url=$(gsettings get org.gnome.desktop.background picture-uri | cut -c9- | rev | cut -c2- | rev)
#    nautilus "$url"
else
    echo >&2 "Cannot read for session $DESKTOP_SESSION"
    exit 2
fi
if [[ ! "$url" = "" ]]; then
    eog "$url"
fi
