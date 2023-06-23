#!/usr/bin/env sh

if [ "$(command nm-online | grep Connecting | cut -f5 -d' ')" = "[online]" ]; then
  # connected
  echo "+"
else
  # not connected
  echo "-"
fi
