#!/bin/bash


if [ -f /ansiblepull/disabletemporaryuntil ]
then
    pull_disabled=1
    pull_disabled_until=$(cat /ansiblepull/disabletemporaryuntil)
    let pull_disabled_until_difference=($(date +%s -d @$pull_disabled_until)-$(date +%s))/86400

else
    pull_disabled=0
fi





if [ $pull_disabled ]
then
    echo "( $pull_disabled_until_difference ) | iconName=vcs-conflicting"
else
    echo " | iconName=vcs-normal"
fi