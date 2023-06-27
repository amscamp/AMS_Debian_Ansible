#!/bin/bash



let last_run=($(date +%s)-$(date +%s -d "$(systemctl show ansible-pull.service --property=ActiveExitTimestamp | sed 's|ActiveExitTimestamp=||g')" ))/86400

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
    echo " ▼ | iconName=vcs-update-required" 

    echo "---"
    echo "Die Aktualisierung läuft seit $(date -d "$(systemctl show ansible-pull.service --property=ActiveEnterTimestamp | sed 's|ActiveEnterTimestamp=||g')") !"
fi

if [[ $is_active -eq 3 && $is_failed -eq 1 ]]
then
    echo "$runtime ▼ | iconName=vcs-normal" 

    echo "---"
    echo "Die letzte Aktualisierung wurde am $(date -d "$(systemctl show ansible-pull.service --property=ActiveExitTimestamp | sed 's|ActiveExitTimestamp=||g')") erfolgreich beendet. "
fi

if [[ $is_active -eq 3 && $is_failed -eq 0 ]]
then

    echo "$runtime ▼ | iconName=vcs-removed" 
    echo "---"
    echo "Die letzte Aktualisierung wurde am $(date -d "$(systemctl show ansible-pull.service --property=ActiveExitTimestamp | sed 's|ActiveExitTimestamp=||g')") mit Fehlern beendet. "
fi



if [[ $is_active -eq 3 ]]
then

    if [ -f /ansiblepull/status/disabletemporaryuntil ]
    then
        echo "Der automatische Aktualisierungsmechanismus ist deaktiviert. Um die Aktualisierung von Hand starten zu können, muss dieser aktiviert sein."

    else
        echo "Aktualisierung jetzt ausführen | iconName=run-install bash=/ansiblepull/scripts/ansible_pull_run.sh "
    fi
fi