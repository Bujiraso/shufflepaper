#!/bin/bash
# refreshBG.sh
# Gets the current wallpaper and refreshes it. Useful when changing displays loses the background image (bug in gnome)

if ["$DESKTOP_SESSSION" =='gnome' ]; then
    bg=$(DISPLAY=:0 GSETTINGS_BACKEND=dconf gsettings get org.gnome.desktop.background picture-uri)
elif ["$DESKTOP_SESSION" =='cinnamon']; then
    bg=$(DISPLAY=:0 GSETTINGS_BACKEND=dconf gsettings get org.cinnamon.picture-uri)
else
    echo 'Unable to parse Desktop Session'
fi

$(cd "$(dirname "$0")" && pwd)/changeBG.sh "$bg"
