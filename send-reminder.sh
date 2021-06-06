#!/usr/bin/env bash
set -e
shopt -s nullglob

cat addresses.tsv | while read -r DETAILS
do
       NAME=$(echo "$DETAILS" | cut -f1)
    ADDRESS=$(echo "$DETAILS" | cut -f2)
    echo "Sending to $NAME at $ADDRESS" 1>&2
    sed -e "s/TONAME/$NAME/g" -e "s/TOADDRESS/$ADDRESS/g" < reminder-2021-06-05.raw |
        msmtp -a gmail --read-envelope-from --read-recipients
done
