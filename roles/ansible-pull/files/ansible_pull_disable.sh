#!/bin/bash


if [ -f /ansiblepull/status/disabletemporaryuntil ]
then
    echo "$(date -d '+7 days' '+%s')" > /ansiblepull/status/disabletemporaryuntil
else
    touch /ansiblepull/status/disabletemporaryuntil
    echo "$(date -d '+7 days' '+%s')" > /ansiblepull/status/disabletemporaryuntil
fi