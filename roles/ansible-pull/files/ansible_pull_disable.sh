#!/bin/bash

if [ -f /ansiblepull/disabletemporaryuntil ]
then
    echo "$(date -d '+7 days' '+%s')" > /ansiblepull/disabletemporaryuntil
else
    touch /ansiblepull/disabletemporaryuntil
    echo "$(date -d '+7 days' '+%s')" > /ansiblepull/disabletemporaryuntil
fi