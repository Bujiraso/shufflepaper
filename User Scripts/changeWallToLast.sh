#!/bin/bash
# changeWallToLast.sh
# Shows the last wallpaper, which should be the second last entry in the
# shuffle file

shuffleFile="${XDG_DATA_HOME:-$HOME/.local/share}/shufflepaper/walls.shuf"
secondLast=$(tail -n 2 $shuffleFile | head -n 1)
changeBG.sh "$secondLast"
