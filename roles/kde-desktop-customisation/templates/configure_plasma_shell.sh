echo "executed on $(date)" 
qdbus org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "$(</home/{{ desktop_username }}/.config/ansible_distro/configure_plasma_shell.js)"