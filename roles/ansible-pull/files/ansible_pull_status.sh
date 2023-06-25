#!/bin/bash



let last_run=($(date +%s)-$(date +%s -d "$(systemctl show ansible-pull.service --property=ActiveExitTimestamp | sed 's|ActiveEnterTimestamp=||g')" ))/86400

if [[ $last_run -ge 1 ]]
then
    runtime="($last_run)"
else
    runtime=" "
fi

systemctl is-active ansible-pull.service --quiet
is_active=$?
systemctl is-failed ansible-pull.service --quiet
is_failed=$?


if [[ $is_active -eq 0 ]]
then
    echo " | iconName=vcs-update-required" 

    echo "---"
    echo "Die Aktualisierung käuft gerade!"
fi

if [[ $is_active -eq 3 && $is_failed -eq 1 ]]
then
    echo "$runtime | iconName=vcs-normal" 

    echo "---"
    echo "Die letzte Aktualisierung wurde am $(date -d \"$(systemctl show ansible-pull.service --property=ActiveExitTimestamp | sed 's|ActiveEnterTimestamp=||g')\") erfolgreich beendet. "
fi

if [[ $is_active -eq 3 && $is_failed -eq 0 ]]
then

    echo "$runtime | iconName=vcs-removed" 
    echo "---"
    echo "Die letzte Aktualisierung wurde am $(date -d \"$(systemctl show ansible-pull.service --property=ActiveExitTimestamp | sed 's|ActiveEnterTimestamp=||g')\") mit Fehlern beendet. "
fi

