#!/bin/bash

source http

session_name=($(tmux list-sessions -F "#{session_name}"))

file='.'${0##*/} && file=${file%.*}'.tmp'

i=0

while [ $i -lt ${#session_name[@]} ]
do

  session=${session_name[i]}

  if [[ $session =~ "fenix_" ]]
  then

     curl -s $ip'/token.php?session='$session > $file

     token=$(jq '.token' $file)
     token=${token//'"'/}

     echo $token
  fi
((i++))
done
