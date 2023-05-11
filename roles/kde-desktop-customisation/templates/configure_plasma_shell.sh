#!/bin/bash
exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1>/home/{{ desktop_username }}/configurelog 2>&1

echo "executed on $(date)" 
sleep 20
echo "after sleep $(date)" 
qdbus org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "$(</home/{{ desktop_username }}/.config/ansible_distro/configure_plasma_shell.js)"
echo "finish" 