#!/bin/bash

file='refresh_token'

$account = $_GET['account'];

sudo sqlite3 /root/.config/gcloud/credentials.db "select value from credentials where account_id = '$1'" > $file

refresh_token=$(jq '.refresh_token' $file)
refresh_token=${refresh_token//'"'/}

echo $refresh_token
