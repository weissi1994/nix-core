#!/bin/sh

FILENAME="$HOME/Screenshots/$(date +%F-%H%M%S)_$1"

grimshot --notify save "$1" - | swappy -o "$FILENAME" -f -
# notify-desktop "Screenshot taken, saved in $FILENAME" -i $FILENAME
