#!/bin/bash

if ! kdialog --warningcontinuecancel 'Soll der Aktualisierungmechanismus wirklich für (weitere) 7 Tage deaktiviert werden?'; then
exit;
fi

if [ -f /ansiblepull/status/disabletemporaryuntil ]
then
    echo "$(date -d '+7 days' '+%s')" > /ansiblepull/status/disabletemporaryuntil
else
    touch /ansiblepull/status/disabletemporaryuntil
    echo "$(date -d '+7 days' '+%s')" > /ansiblepull/status/disabletemporaryuntil
fi