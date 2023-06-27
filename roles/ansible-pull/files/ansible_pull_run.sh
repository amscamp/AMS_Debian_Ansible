#!/bin/bash

if ! kdialog --warningcontinuecancel 'Soll die Aktualisierung jetzt ausgeführt werden?'; then
exit;
fi

sudo /bin/systemctl start ansible-pull.service