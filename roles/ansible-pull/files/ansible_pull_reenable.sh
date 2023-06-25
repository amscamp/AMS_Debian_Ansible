#!/bin/bash


if [ -f /ansiblepull/disabletemporaryuntil ]
then
    pull_disabled_until=$(cat /ansiblepull/disabletemporaryuntil)
    let pull_disabled_until_difference=($(date +%s -d @$pull_disabled_until)-$(date +%s))

    if [ $pull_disabled_until_difference -le 0 ];
    then
        rm -rf /ansiblepull/disabletemporaryuntil
    fi
fi

