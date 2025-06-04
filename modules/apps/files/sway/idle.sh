#!/bin/sh
exec swayidle -w \
  timeout 300 "$HOME/.config/sway/lock.sh" \
	before-sleep "$HOME/.config/sway/lock.sh"
