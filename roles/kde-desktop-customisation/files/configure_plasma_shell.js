// This sets up the panel items/order/settings

widgets = ['org.kde.plasma.systemmonitor.cpu',
           'org.kde.plasma.systemmonitor.memory',
           'org.kde.plasma.panelspacer',
           'org.kde.kargos',
        //    'org.kde.plasma.panelspacer',
           'org.kde.kargos',
           'org.kde.plasma.panelspacer',
           'org.kde.plasma.systemmonitor.net',]
        //    'org.kde.plasma.panelspacer',]
           
widgets2 = ['org.kde.plasma.kickoff',
            'org.kde.plasma.taskmanager',
            'org.kde.plasma.systemtray',
            'org.kde.plasma.digitalclock',
            'org.kde.plasma.showdesktop']

while (panelIds.length > 0) {
    panelById(panelIds[panelIds.length - 1]).remove()
}
if (panelIds.length == 0) {
    panel = new Panel()
} else {
    panel = panelById(panelIds[0])
}
if (panelIds.length == 1) {
    panel2 = new Panel()
} else {
    panel2 = panelById(panelIds[1])
}
panel.location = 'top'

// // Remove extraneous widgets
// widgetsSeen = []
// for (i=panel.widgetIds.length-1; i>=0; i--) {
//     widget = panel.widgetById(panel.widgetIds[i])
//     if ((widgets.indexOf(widget.type) == -1) ||
//             (widgetsSeen.indexOf(widget.type) != -1)) {
//         widget.remove()
//     }
//     widgetsSeen.push(widget.type)
// }

// // Make sure widgets has no duplicates
// widgets = widgets.filter(function(elem, pos, arr) {
//     return arr.indexOf(elem) == pos
// })

// currentWidgets = []
// for (i=0; i<panel.widgetIds.length; i++) {
//     currentWidgets.push(panel.widgetById(panel.widgetIds[i]).type)
// }

for (i=0; i<widgets.length; i++) {
    // if (currentWidgets.indexOf(widgets[i]) == -1) {
        panel.addWidget(widgets[i])
    //     currentWidgets.push(widgets[i])
    // }
}

AppletOrder = []
for (i=0; i<widgets.length; i++) {
    for (j=0; j<panel.widgetIds.length; j++) {
        if (panel.widgetById(panel.widgetIds[j]).type == widgets[i]) {
            AppletOrder.push(panel.widgetIds[j])
            break
        }
    }
}
panel.writeConfig('AppletOrder', AppletOrder)
kargoscount=0;
for (i=0; i<panel.widgetIds.length; i++) {
    widget = panel.widgetById(panel.widgetIds[i])
    if (widget.type == 'org.kde.plasma.systemmonitor.cpu') {
        widget.currentConfigGroup = new Array('General')
        widget.writeConfig('sources', 'cpu%2Fsystem%2FTotalLoad')
    } else if (widget.type == 'org.kde.plasma.systemmonitor.memory') {
        widget.currentConfigGroup = new Array('General')
        widget.writeConfig('sources', 'mem%2Fphysical%2Fapplication')
    } else if (widget.type == 'org.kde.kargos' && kargoscount == 0) {
        widget.currentConfigGroup = new Array('General')
        widget.writeConfig('command', '/ansiblepull/scripts/ansible_pull_disable_status.sh')
        widget.writeConfig('interval', '2')
        kargoscount=1;
    } else if (widget.type == 'org.kde.kargos' && kargoscount == 1) {
        widget.currentConfigGroup = new Array('General')
        widget.writeConfig('command', '/ansiblepull/scripts/ansible_pull_status.sh')
        widget.writeConfig('interval', '2')
    } else if (widget.type == 'org.kde.plasma.systemmonitor.net') {
        widget.currentConfigGroup = new Array('General')
        widget.writeConfig('sources', 'enp6s0,network%2Finterfaces%2Fenp6s0%2Ftransmitter%2Fdata')
    } 

}


panel2.location = 'bottom'

// Remove extraneous widgets2
widgets2Seen = []
for (i=panel2.widgetIds.length-1; i>=0; i--) {
    widget = panel2.widgetById(panel2.widgetIds[i])
    if ((widgets2.indexOf(widget.type) == -1) ||
            (widgets2Seen.indexOf(widget.type) != -1)) {
        widget.remove()
    }
    widgets2Seen.push(widget.type)
}

// Make sure widgets2 has no duplicates
widgets2 = widgets2.filter(function(elem, pos, arr) {
    return arr.indexOf(elem) == pos
})

currentwidgets2 = []
for (i=0; i<panel2.widgetIds.length; i++) {
    currentwidgets2.push(panel2.widgetById(panel2.widgetIds[i]).type)
}

for (i=0; i<widgets2.length; i++) {
    if (currentwidgets2.indexOf(widgets2[i]) == -1) {
        panel2.addWidget(widgets2[i])
        currentwidgets2.push(widgets2[i])
    }
}

AppletOrder = []
for (i=0; i<widgets2.length; i++) {
    for (j=0; j<panel2.widgetIds.length; j++) {
        if (panel2.widgetById(panel2.widgetIds[j]).type == widgets2[i]) {
            AppletOrder.push(panel2.widgetIds[j])
            break
        }
    }
}
panel2.writeConfig('AppletOrder', AppletOrder)

for (i=0; i<panel2.widgetIds.length; i++) {
    widget = panel2.widgetById(panel2.widgetIds[i])
    if (widget.type == 'org.kde.plasma.digitalclock') {
        widget.currentConfigGroup = new Array('Appearance')
        widget.writeConfig('showDate', 'true')
    } else if (widget.type == 'org.kde.plasma.kickoff') {
        widget.globalShortcut = 'Meta+F12'
    }

}


var allDesktops = desktops();
    // print (allDesktops);
    for (i=0;i<allDesktops.length;i++) {{
        d = allDesktops[i];
        d.wallpaperPlugin = "org.kde.image";
        d.currentConfigGroup = Array("Wallpaper",
                                     "org.kde.image",
                                     "General");
        d.writeConfig("Image", "file:///ansible_distro/KDE-Plasma-Dark-960-HD-WL.jpg")
    }}