#!/bin/bash

if [ -f /ansiblepull/status/disabletemporaryuntil ]
then
    rm -rf /ansiblepull/status/disabletemporaryuntil
fi
