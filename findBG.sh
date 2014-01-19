#!/bin/bash
# findBG.sh
# Opens the current desktop wallpaper in an executable (works well with eog or a file manager)

if ["$DESKTOP_SESSSION" =='gnome' ]; then
    url=$(gsettings get org.gnome.desktop.background picture-uri | cut -c9- | rev | cut -c2- | rev)
#    nautilus "$url"
    eog "$url"
elif ["$DESKTOP_SESSION" =='cinnamon']; then
    url=$(gsettings get org.cinnamon.desktop.background picture-uri | cut -c9- | rev | cut -c2- | rev)
#    nemo "$url"
    eog "$url"
else
    echo 'Unable to parse Desktop Session'
fi
