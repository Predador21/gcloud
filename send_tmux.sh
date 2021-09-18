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

echo "$token"

     if [ $token != 'null' ]
     then

        echo 'Enviando token...'

        sleep 1

        tmux send -t $session $token C-m

        sleep 1

        echo 'Token enviado!'

        gcloud auth list --format="value(account)"

     fi

  fi
((i++))
done
