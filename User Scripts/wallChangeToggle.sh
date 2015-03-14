#!/bin/bash
# wallChangeToggle.sh
# Toggles whether or not wallpapers will change

off(){
    if [[ $(grep ON <(crontab -l)) ]]; then
        crontab <(crontab -l | sed 's/ON/OFF/' | sed "`crontab -l | grep -n randomBG.sh | cut -d\: -f 1`"s/^/\#/)
    fi
}

on(){
    if [[ $(grep OFF <(crontab -l)) ]]; then
        crontab <(crontab -l | sed 's/OFF/ON/' | sed "`crontab -l | grep -n randomBG.sh | cut -d\: -f 1`"s/^\#//)
    fi
}

me=$(basename "$0")

if [[ $# -eq 0 ]]; then
    if [[ $(grep ON <(crontab -l)) ]]; then
        off
    else
        on
    fi
    exit 0
fi

case "$1" in
    "--check" | "-c")
        if crontab -l | grep ON > /dev/null; then
            echo "$me: Wall rotation is on."
        elif crontab -l | grep OFF > /dev/null; then
            echo "$me: Wall rotation is off."
        else
            echo "$me: Cannot read wall rotation state." >&2
        fi
    ;;
    "--help" | "-h")
        cat <<EOS
Usage $me [options/args]
 Options
  -c --check	Checks the current state
  -h --help	Print this message
  -n --neat	Print only the mode, neatly (programmatic use)
 Arguments
   off		Turns off rotation
   on		Turns on rotation
EOS
    ;;
    "--neat" | "-n")
        if crontab -l | grep ON > /dev/null; then
            echo "on"
        elif crontab -l | grep OFF > /dev/null; then
            echo "off"
        else
            echo "$me: Cannot read wall rotation state." >&2
            exit 1
        fi
    ;;
    "off")
        off
    ;;
    "on")
        on
    ;;
    *)
        echo >&2 "$me: Unknown argument."
        exit 1
    ;;
esac
