#!/bin/bash


if [ -f /ansiblepull/status/disabletemporaryuntil ]
then
    pull_disabled_until=$(cat /ansiblepull/status/disabletemporaryuntil)
    let pull_disabled_until_difference=($(date +%s -d @$pull_disabled_until)-$(date +%s))/86400
    echo "( $pull_disabled_until_difference ) | iconName=vcs-conflicting"


    echo "---"
    echo "Aktualisierungsmechanismus ist deaktiviert bis $(date -d @$pull_disabled_until)"
    echo "Aktualisierungsmechanismus aktivieren | iconName=vcs-push bash=/ansiblepull/scripts/ansible_pull_reenable_user.sh "


else
    echo " | iconName=vcs-normal"

    echo "---"
    echo "Aktualisierungsmechanismus ist aktiviert"
    echo "Aktualisierungsmechanismus deaktivieren | iconName=vcs-pull bash=/ansiblepull/scripts/ansible_pull_disable.sh "
fi


