#!/bin/bash
echo "executed on $(date)" >> /home/{{ desktop_username }}/configurelog
qdbus org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "$(</home/{{ desktop_username }}/.config/ansible_distro/configure_plasma_shell.js)"