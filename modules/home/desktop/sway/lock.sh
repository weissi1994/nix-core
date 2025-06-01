#!/bin/sh
swaylock \
	--screenshots \
	--clock \
	--indicator \
	--indicator-radius 80 \
	--indicator-thickness 10 \
	--timestr '%H:%M:%S' \
	--datestr '%Y-%m-%d, %a'\
	--effect-blur 7x5 \
	--effect-vignette 0.5:0.5 \
	--key-hl-color 00FF00 \
	--grace 1 \
	--fade-in 0.1 \
	--font Inter
