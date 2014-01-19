#!/bin/bash
# changeBG.sh
# Changes the wallpaper for the current desktop session. Implemented for Gnome and Cinnamon

#Check that the file is prefixed by "file://"
file=$1
if [[ ! $1 == *file://* ]]; then
    file=file://"$1"
fi

if [[ ! -f  $(echo ${file##*:\/\/} | sed s/\'//) ]]; then
    echo >&2 Error: file \"$1\" does not exist
    exit 1
fi

# Determine desktop session and change wallpaper
if [ "$DESKTOP_SESSION" == 'cinnamon' ]; then
    export $(cat /proc/$(pgrep -u `whoami` ^cinnamon | head -n 1)/environ | grep -z DBUS_SESSION_BUS_ADDRESS)
    DISPLAY=:0 GSETTINGS_BACKEND=dconf gsettings set org.cinnamon.desktop.background picture-uri "$file"
elif [ "$DESKTOP_SESSION" == 'gnome' ]; then
    export $(cat /proc/$(pgrep -u `whoami` ^gnome-shell | head -n 1)/environ | grep -z DBUS_SESSION_BUS_ADDRESS)
    DISPLAY=:0 GSETTINGS_BACKEND=dconf gsettings set org.gnome.desktop.background picture-uri "$file"
else
    echo >&2 'Cannot read for session' $DESKTOP_SESSION
    exit 2
fi
