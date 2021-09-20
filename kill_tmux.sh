#!/bin/bash

#Timeout
expiration=60 #10 minutos

session_name=($(tmux list-sessions -F "#{session_name}"))
session_created=($(tmux list-sessions -F "#{session_created}"))

i=0

while [ $i -lt ${#session_name[@]} ]
do

 datetime=$(date '+%s')
 limite=$((datetime-expiration))

 session=${session_name[i]}

 if [[ $session =~ "fenix_" ]] && [ ${session_created[i]} -lt $limite ]
 then

    tmux kill-window -t $session > /dev/null

    echo
    echo "Session" $session "finalizada por time-out (9)."
 fi

  ((i++))
done
