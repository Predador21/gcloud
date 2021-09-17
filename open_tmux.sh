#/bin/bash

source http

session=$1
account=$2

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

url=$protocolo$ip'/session.php?session='$session'&account='$account'&status=1&url='$link
curl $url

rm -rf $session.url
