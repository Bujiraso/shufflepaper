#!/bin/bash
# wallMode
# Changes the current wallpaper "mode". A "mode" is a set of directories that wallpapers are shuffled from

printHelp() {
    cat <<EOS
Usage:
 $me [options] [arguments]
 -d     Delete tag
 -e	Edit the current conf file
 -h	Display this help
 -l     List tags
 -n	Print the mode neatly (programmatic use)
EOS
}
swap() {
    if [[ $mode == $1 ]]; then
        echo "$me: Already in \"$mode\" mode" >/dev/stderr
        exit 3
    fi

    mv "$conf"{,."$mode"}
    mv "$list"{,."$mode"}
    if [[ -f "$conf.$1" ]]; then
        mv "$conf"{."$1",}
    else
        read -p "$me: No conf found. Do you wish to create one? (y/n)" -n1
        echo
        if [[ "$REPLY" == "y" ]]; then
            cp "$conf"{."$mode",}
            sed -i "s/$mode/$1/" "$conf"
            vim "$conf"
            "$insDir"/buildWallList.sh
        else
            mv "$conf"{."$mode",}
            mv "$list"{."$mode",}
        fi
    fi
    if [[ -f "$list.$1" ]]; then
        mv "$list"{."$1",}
    fi
}

me=$(basename $0)

# Help
if [[ "$1" == "-h" ]]; then
    printHelp
    exit 0
fi

insDir="$XDG_DATA_HOME/shufflepaper"
conf="$insDir/shufflepaper.conf"
list="$insDir/walls.shuf"

if [[ ! -f "$conf" ]]; then
    echo >&2 "$me: No conf found. No mode set. Please manually fix, and -- if you see this message frequently -- upgrade this $me script."
    exit 1
fi

mode=$(head -n 1 "$conf" | cut -c 3-)

if [[ $# -eq 0 ]]; then
    echo "$me: Current mode is $mode"
    exit 0
elif [[ $# -gt 2 ]]; then
    echo >&2 "$me: Too many arguments."
    exit 2
else case "$1" in
        "-d")
            rm "$insDir/"*".$2"
        ;;
        "-e")
            vim "$conf"
        ;;
        "-h")
            # Case covered above!
        ;;
        "-l")
            echo Tags are: $(find "$insDir" -type f -name "shufflepaper.conf*" -execdir head -n 1 {} \; | sed 's/^# //' | sort)
        ;;
        "-n")
            echo "$mode"
        ;;
        *)
            swap "$1"
        ;;
    esac
fi
