#!/usr/bin/env bash
# changeBG.sh
# Changes the wallpaper for the current desktop session. Implemented for Cinnamon, Gnome and Mate
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

me="change-wall"

#Check that the file is prefixed by "file://"
function __sfp_prefixURI() {
    pfpath="${1}"
    if [[ ! -f  "$(echo "${pfpath##*:\/\/}" | sed s/^\'// | sed s/\'$//)" ]]; then
        echo >&2 "${me}: File \"${pfpath}\" does not exist"
        exit 2
    fi

    if [[ ! "${pfpath}" = *"file://"* ]]; then
        pfpath="file://""$(readlink -f "${pfpath}")"
    fi
    echo "${pfpath}"
} 
export -f __sfp_prefixURI

function __sfp-change-wall() {
    myDir="$(dirname "$(readlink -f "${0}")")"
    source "${XDG_CONFIG_HOME}/shufflepaper/shufflepaper.conf"

    if [[ ${#} -eq 0 ]]; then
        echo >&2 "${me}: No args given. Exiting without change."
        exit 1
    fi

    fpath="${1}"


    # Determine desktop session and change wallpaper
    if pgrep cinnamon > /dev/null; then
        pfpath=$(__sfp_prefixURI "${fpath}")
        # TODO: This won't always be DISPLAY=:0
        DISPLAY=:0 gsettings set org.cinnamon.desktop.background picture-uri "${pfpath}"
    elif pgrep mate-session > /dev/null; then
        DISPLAY=:0 gsettings set org.mate.background picture-filename "${fpath}"
    elif pgrep 'gnome-shell$' > /dev/null; then
        if [[ -z ${DBUS_SESSION_BUS_ADDRESS+x} ]]; then
            export $(dbus-launch --exit-with-session gnome-session)
        fi
        pfpath=$(__sfp_prefixURI "${fpath}")
        DISPLAY=:0 gsettings set org.gnome.desktop.background picture-uri "${pfpath}"
    else
        echo >&2 "${me}: Cannot read for session ${DESKTOP_SESSION}"
        exit 3
    fi

    echo "$(date +%Y-%m-%d-%T): ${me}: Wallpaper set to ${fpath}" >> ${logFile}
}

sfp-change-wall () {
    __sfp-change-wall "${*}"
}
