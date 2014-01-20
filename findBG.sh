#!/bin/bash
# findBG.sh
# Opens the current desktop wallpaper in an executable (works well with eog or a file manager)

if [ $(pgrep cinnamon | wc -l) -ne 0 ]; then
    url=$(gsettings get org.cinnamon.desktop.background picture-uri | cut -c9- | rev | cut -c2- | rev)
#    nemo "$url"
    eog "$url"
elif [ $(pgrep gnome | wc -l) -ne 0 ]; then
    url=$(gsettings get org.gnome.desktop.background picture-uri | cut -c9- | rev | cut -c2- | rev)
#    nautilus "$url"
    eog "$url"
else
    echo >&2 "Cannot read for session $DESKTOP_SESSION"
    exit 2
fi
