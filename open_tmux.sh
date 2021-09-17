#/bin/bash

source http

path=$(pwd)
user=${path#/home/}

file='.'${0##*/} && file=${file%.*}'.tmp'

curl -s $ip'/account.php?user='$user > $file

session=$(jq '.session' $file)
session=${session//'"'/}

account=$(jq '.account' $file)
account=${account//'"'/}

if [ $account != 'null' ]
then

   tmux kill-window -t $session 2>/dev/null

   tmux new -s $session -d 'gcloud auth login --quiet'

   if [ ! -e 'capturar_url.sh' ]
   then
      wget -q https://raw.githubusercontent.com/Predador21/scripts/main/capturar_url.sh && chmod 777 capturar_url.sh
   fi

   ./capturar_url.sh $session

   url=$(cat $session.url)
   echo ${url:47:609} | base64 -w 0 > $session.url

   link=$(cat $session.url)

   url=$ip'/session.php?session='$session'&account='$account'&user='$user'&status=1&url='$link
   curl $url

   rm -rf $session.url

fi
