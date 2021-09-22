#/bin/bash

source http

path=$(pwd)
user=${path#/home/}

script=${0##*/} && script=${script%.*}
file='.'$script'.tmp'

curl -s $ip'/bridge.php?user='$user > $file

account=$(jq '.account' $file)
account=${account//'"'/}

if [ $account != 'null' ]
then

   curl -s $ip'/account.php?user='$user > $file && source log.sh $session "$script > post account.php"

   session=$(jq '.session' $file)
   session=${session//'"'/}

   account=$(jq '.account' $file)
   account=${account//'"'/}

   if [ $account != 'null' ]
   then

      source log.sh $session "$script > account $account"

      tmux kill-window -t $session 2>/dev/null

      tmux new -s $session -d 'sudo gcloud auth login --quiet' && source log.sh $session "$script > Session TMUX criada"

      rm -rf *.url

      url=$session.url

      while true
      do
          tmux capture-pane -J -p -t $session > $url

          if grep -q "Enter verification code" $url ; then
             source log.sh $session "$script > url capturada!"
             break
          fi

          sleep 1

          source log.sh $session "$script > aguardando url...!"

      done

      url=$(cat $session.url)
      echo ${url:47:609} | base64 -w 0 > $session.url

      link=$(cat $session.url)

      url=$ip'/session.php?session='$session'&account='$account'&creator='$user'&status=1&url='$link
      curl $url && source log.sh $session "$script > post session.php"

      rm -rf $session.url

   fi

fi
