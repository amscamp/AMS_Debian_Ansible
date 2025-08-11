#!/bin/bash

# Ensure cups-browsed state matches network
NETID_FILE=/run/fnd/network_id
NETID="unknown"
if [[ -f "$NETID_FILE" ]]; then
  NETID=$(<"$NETID_FILE")
fi

if [[ "$NETID" == "ams" ]]; then
  echo "AMS network detected: stopping and disabling cups-browsed"
  systemctl is-active --quiet cups-browsed && systemctl stop cups-browsed || true
  systemctl is-enabled cups-browsed &>/dev/null && systemctl disable cups-browsed || true
else
  echo "Non-AMS network detected: enabling and starting cups-browsed"
  systemctl enable cups-browsed || true
  systemctl start cups-browsed || true
fi

echo "hallo"
PORT=9100
socketArray=()



# add AMS printserver printers (hardcoded list)
declare -A AMSPRINTERS=(
    
["Brother_MFC-L8690CDW___Mono_Simplex"]="http-pdf://ams-print01.ams.local:8888/print?printer=Brother-MFC-L8690CDW-GDI-SW-Simplex"
    ["Brother_MFC-L8690CDW___Farb_Simplex"]="http-pdf://ams-print01.ams.local:8888/print?printer=Brother-MFC-L8690CDW-GDI-Farb-Simplex"
    ["Brother_MFC-L8690CDW___Mono_Duplex"]="http-pdf://ams-print01.ams.local:8888/print?printer=Brother-MFC-L8690CDW-GDI-SW-Duplex"
    ["Brother_MFC-L8690CDW___Farb_Duplex"]="http-pdf://ams-print01.ams.local:8888/print?printer=Brother-MFC-L8690CDW-GDI-Farb-Duplex"
    ["Brother_MFC-L8690CDW___Mono_Simplex_Hohe_Qualität__langsamer"]="http-pdf://ams-print01.ams.local:8888/print?printer=Brother-MFC-L8690CDW-SW-Simplex"
    ["Brother_MFC-L8690CDW___Farb_Simplex_Hohe_Qualität__langsamer"]="http-pdf://ams-print01.ams.local:8888/print?printer=Brother-MFC-L8690CDW-Farb-Simplex"
    ["Brother_MFC-L8690CDW___Mono_Duplex_Hohe_Qualität__langsamer"]="http-pdf://ams-print01.ams.local:8888/print?printer=Brother-MFC-L8690CDW-SW-Duplex"
    ["Brother_MFC-L8690CDW___Farb_Duplex_Hohe_Qualität__langsamer"]="http-pdf://ams-print01.ams.local:8888/print?printer=Brother-MFC-L8690CDW-Farb-Duplex"
)

AMSPRINTERSPPD="/usr/share/ppd/cupsfilters/Generic-PDF_Printer-PDF.ppd"

# Helper: check if a printer queue exists via lpstat -v -- <name>
printer_exists() {
    local name="$1"
    local out
    out=$(lpstat -v -- "$name" 2>/dev/null | head -n1)
    [[ -n "$out" ]]
}

# Helper: get device URI for a queue name (locale-agnostic)
get_printer_uri() {
    local name="$1"
    lpstat -v -- "$name" 2>/dev/null | head -n1 | sed 's/^[^:]*: \(.*\)$/\1/'
}

# handle normal printers if network_id is not set to "ams"
if [[ -f /run/fnd/network_id ]] && [[ $(</run/fnd/network_id) != "ams" ]]; then
    echo "Network ID is not set to 'ams', handling normal printers..."
    
    #get all available socket printers
    for entry in $(lpinfo -v | cut -c 1-); do
        if [[ $entry =~ ^socket://[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        socketArray+=("$entry")
        fi
    done

    #sort and unique output
    socketArray=( `for i in ${socketArray[@]}; do echo $i; done | sort -u` )

    #handle printers
    for i in "${socketArray[@]}"
    do 
    printerip=$(echo $i | sed 's|socket://||g')
    printername=$(nmap -sV --script /ansible_distro/printerdetection/scripts/getprintername.nse -p 9100 $printerip | grep _getprintername | sed 's/|_getprintername: //g')
    availableprinters=$(lpstat -v | grep $printerip | wc -l)
    if [[ $printername == "FS-1128MFP" && $availableprinters -eq 0 ]]; then
            echo $printerip

            lpadmin -p "FS1128MFP" -E -v $i -i /usr/share/ppd/kyocera/Kyocera_FS-1128MFP.ppd

            grep -q "FS1128MFP:$printerip" '/ansible_distro/printerdetection/status' || echo  "FS1128MFP:$printerip" >> /ansible_distro/printerdetection/status

    fi
    done

    echo "Normal printers handled."
fi

# add AMS printserver printers if network_id is set to "ams"
if [[ -f /run/fnd/network_id ]] && [[ $(</run/fnd/network_id) == "ams" ]]; then
    echo "Adding AMS printserver printers..."
    for pname in "${!AMSPRINTERS[@]}"; do
        uri="${AMSPRINTERS[$pname]}"
        echo "Processing printer: $pname with URI: $uri"
        if ! printer_exists "$pname"; then
            echo "Running: lpadmin -p \"$pname\" -E -v \"$uri\" -P \"$AMSPRINTERSPPD\""
            lpadmin -p "$pname" -E -v "$uri" -P "$AMSPRINTERSPPD"
        else
            # ensure URI matches (update if changed)
            echo "Checking URI for printer: $pname"
            current_uri=$(get_printer_uri "$pname" || true)
            echo "Current URI: $current_uri"
            echo "Expected URI: $uri"
            if [[ -n "$current_uri" && "$current_uri" != "$uri" ]]; then
                echo "Updating URI for printer: $pname"
                lpadmin -p "$pname" -v "$uri"
            fi
        fi
    done
fi


#handle cleanup

# remove ams printserver printers if network_id is not set to "ams"
if [[ -f /run/fnd/network_id ]] && [[ $(</run/fnd/network_id) != "ams" ]]; then
    echo "Removing AMS printserver printers..."
    for pname in "${!AMSPRINTERS[@]}"; do
        if printer_exists "$pname"; then
            echo "Removing printer: $pname"
            lpadmin -x "$pname"
        fi
    done
fi


cat /ansible_distro/printerdetection/status | while read line 
do
    printername=$(echo "$line" | cut -d ":" -f 1)
    printerip=$(echo "$line" | cut -d ":" -f 2)
    availableprinters=$(lpstat -v | grep $printerip | wc -l)

    if [[ $availableprinters -eq 1 ]]; then
            echo $printerip

            if ping -c 1 $printerip &> /dev/null
            then
                echo "still reachable"
            else
                lpadmin -x "$printername"
            fi
    fi

done



