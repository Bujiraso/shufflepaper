#!/bin/bash
# getWallURI.sh
# Gets the location of the current wallpaper without all the garbage

# Get background
if [ $(pgrep cinnamon | wc -l) -ne 0 ]; then
    url=$(gsettings get org.cinnamon.desktop.background picture-uri | cut -c9- | rev | cut -c2- | rev)
elif [ $(pgrep mate-session | wc -l) -ne 0 ]; then
    url=$(gsettings get org.mate.background picture-filename | cut -c2- | rev | cut -c2- | rev)
elif [ $(pgrep gnome | wc -l) -ne 0 ]; then
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
