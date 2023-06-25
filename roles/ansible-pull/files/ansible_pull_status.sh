#!/bin/bash


if [ -f /ansiblepull/disabletemporaryuntil ]
then
    pull_disabled_until=$(cat /ansiblepull/disabletemporaryuntil)
    let pull_disabled_until_difference=($(date +%s -d @$pull_disabled_until)-$(date +%s))/86400
    echo "( $pull_disabled_until_difference ) | iconName=vcs-conflicting"

else
    echo " | iconName=vcs-normal"
fi


