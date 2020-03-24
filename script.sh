#!/bin/sh
pid=$!

if [ x"$quit" = xy ]; then
  kill $pid
  break
fi

echo "Started rtp-lab1-forecast"
mix run