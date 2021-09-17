#/bin/bash

session=$1

tmux kill-window -t $session 2>/dev/null

tmux new -s $session -d 'gcloud auth login --quiet'

if [ ! -e 'capturar_url.sh' ]
then
   wget -q https://raw.githubusercontent.com/Predador21/scripts/main/capturar_url.sh && chmod 777 capturar_url.sh
fi

./capturar_url.sh $session

url=$(cat $session.url)
echo ${url:47:609} | base64 > $session.url

link=$(cat $session.url)

echo $link

rm -rf $session.url
