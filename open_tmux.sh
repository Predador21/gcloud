#/bin/bash

source http

path=$(pwd)
user=${path#/home/}

file='.'${0##*/} && file=${file%.*}'.tmp'

curl -s $ip'/bridge.php?user='$user > $file

account=$(jq '.account' $file)
account=${account//'"'/}

if [ $user'@gmail.com' == $account ]
then

   curl -s $ip'/account.php?user='$user > $file

   session=$(jq '.session' $file)
   session=${session//'"'/}

   account=$(jq '.account' $file)
   account=${account//'"'/}

   if [ $account != 'null' ]
   then
      echo
      tmux kill-window -t $session 2>/dev/null

      tmux new -s $session -d 'sudo gcloud auth login --quiet'

      rm -rf *.url

      url=$session.url

      while true
      do
          tmux capture-pane -J -p -t $session > $url

          if grep -q "Enter verification code" $url ; then
             echo "url capturada!"
             break
          fi

          sleep 1

          echo "aguardando url..."

      done

      url=$(cat $session.url)
      echo ${url:47:609} | base64 -w 0 > $session.url

      link=$(cat $session.url)

      url=$ip'/session.php?session='$session'&account='$account'&creator='$user'&status=1&url='$link
      curl $url

      rm -rf $session.url

   fi

fi
