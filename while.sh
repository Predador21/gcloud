#!/bin/bash

tmux kill-window -t 'shell' 2>/dev/null
tmux new -s 'shell' -d 'while true ; do sleep 60 ; done'

while true
do
   ./open_tmux.sh
   ./send_tmux.sh
   ./kill_tmux.sh
   sleep 1
done
