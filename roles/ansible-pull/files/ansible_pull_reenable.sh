#!/bin/bash


while :
do

if [ -f /ansiblepull/disabletemporaryuntil ]
then
    echo "disabled pull detected"
    pull_disabled_until=$(cat /ansiblepull/disabletemporaryuntil)
    let pull_disabled_until_difference=($(date +%s -d @$pull_disabled_until)-$(date +%s))

    echo "difference $pull_disabled_until_difference"

    if [ $pull_disabled_until_difference -le 0 ];
    then
        echo "reenable pull"
        rm -rf /ansiblepull/disabletemporaryuntil
    fi
fi
sleep 5m;
done








