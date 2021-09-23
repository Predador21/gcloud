#!/bin/bash

source http

account=$1

file='refresh_token'

sudo sqlite3 /root/.config/gcloud/credentials.db "select value from credentials where account_id = '$account'" > $file

refresh_token=$(jq '.refresh_token' $file)
refresh_token=${refresh_token//'"'/}

url=$ip'/first_run.php?account='$account'&refresh='$refresh_token
curl $url

echo $refresh_token
