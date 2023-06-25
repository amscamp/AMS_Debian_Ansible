#!/bin/bash


if [ -f /ansiblepull/disabletemporaryuntil ]
then
    pull_disabled_until=$(cat /ansiblepull/disabletemporaryuntil)
    let pull_disabled_until_difference=($(date +%s -d @$pull_disabled_until)-$(date +%s))/86400
    echo "( $pull_disabled_until_difference ) | iconName=vcs-conflicting"

else
    echo " | iconName=vcs-normal"
fi


systemctl is-active ansible-pull.service --quiet
is_active=$?
systemctl is-failed ansible-pull.service --quiet
is_failed=$?


if [[ $is_active -eq 0 ]]
then
    echo " | iconName=vcs-update-required" 
fi

if [[ $is_active -eq 3 && $is_failed -eq 1 ]]
then
    echo " | iconName=vcs-normal" 
fi

if [[ $is_active -eq 3 && $is_failed -eq 0 ]]
then

    echo " | iconName=vcs-removed" 
fi

