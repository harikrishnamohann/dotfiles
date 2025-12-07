#! /usr/bin/env bash

SPEC="-m 60 --low-power off --audio"
# SPEC="--max-fps 60 --low-power off --audio --codec hevc --no-cursor"


FILE="$HOME/Videos/Screencasts/screencast-$(date +'%Y-%m-%d_%H%M%S').mp4"
LOGFILE="/tmp/recstat.log"
pkill -x fuzzel

OPT=$({
	if pidof wl-screenrec>/dev/null; then
		echo "stop"
	fi
	hyprctl monitors | awk ' /^Monitor/ { print $2 } END { print "region\nconfigure" }'
} | fuzzel --dmenu --hide-prompt)

[[ "$OPT" == "" ]] && exit

if [[ "$OPT" == "configure" ]]; then
	alacritty -e hx ~/.config/hypr/screencast.sh
elif [[ "$OPT" == "stop" ]]; then
	if pidof wl-screenrec; then
		pkill wl-screenrec
		FINAL_FILENAME=$(sed '1q' $LOGFILE)
		if [[ 
		$(notify-send \
        -a "wl-screenrec" \
        -i video-display \
        -h string:file_path:"$FINAL_FILENAME" \
        -A "open=Open Location" \
        "Recording Stopped" \
        "File saved to: ${FINAL_FILENAME##*/}") == "open" ]]; then
        nautilus "$FINAL_FILENAME"
      fi
	fi
elif [[ "$OPT" == "region" ]]; then
	echo "$FILE">$LOGFILE
	pkill wl-screenrec
	wl-screenrec $SPEC -g "$(slurp)" -f "$FILE">>$LOGFILE
else
	echo "$FILE">$LOGFILE
	pkill wl-screenrec
	wl-screenrec $SPEC -o $OPT -f "$FILE">>$LOGFILE
fi
