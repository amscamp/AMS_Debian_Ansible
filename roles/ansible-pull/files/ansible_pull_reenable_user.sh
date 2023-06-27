#!/bin/bash

if ! kdialog --warningcontinuecancel 'Soll der Aktualisierungmechanismus wieder aktiviert werden?'; then
exit;
fi

if [ -f /ansiblepull/status/disabletemporaryuntil ]
then
    rm -rf /ansiblepull/status/disabletemporaryuntil
fi
