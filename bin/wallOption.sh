#!/usr/bin/env bash
# wallOption.sh
# Changes the Picture Option of the wallpaper displayed in Gnome
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

me="$(basename "$0")"
OPTIONS="centered scaled spanned zoom stretched wallpaper"

help() {
    cat << EOS
Usage: $me [OPTIONS...] <ARGUMENT>
    -h        Print this help message and exit
    -n        No update of wallpaper in DB
Argument can be one of: $OPTIONS
EOS
    exit 0
}

if [[ $# -eq 0 ]]; then
    help
fi

while getopts "hn" opt; do
    case "$opt" in
        "h")
            help
            ;;
        "n")
            noUpdate=1
            ;;
    esac
    shift
done

arg=$1
case "$arg" in
    "centered"|"scaled"|"spanned"|"zoom"|"stretched"|"wallpaper")
        export $(cat /proc/$(pgrep -u `whoami` ^gnome-shell | head -n 1)/environ | grep -z DBUS_SESSION_BUS_ADDRESS | tr -d \\0)
        DISPLAY=:0 gsettings set org.gnome.desktop.background picture-options "$arg"
        if [[ -z "$noUpdate" ]]; then
            "$(dirname $(readlink -f "$0"))/alterWallInDB.sh" -m "$arg"
        fi
    ;;
    *) #Invalid view option
        echo "$me: Invalid argument - $arg" >&2
        exit 1
    ;;
esac
