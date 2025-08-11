#!/bin/bash

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

AMSAMSPRINTERSPPD="/usr/share/ppd/cupsfilters/Generic-PDF_Printer-PDF.ppd"

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

# add AMS printserver printers if network_id is set to "ams"
if [[ -f /run/fnd/network_id ]] && [[ $(</run/fnd/network_id) == "ams" ]]; then
    echo "Adding AMS printserver printers..."
    for pname in "${!AMSPRINTERS[@]}"; do
        uri="${AMSPRINTERS[$pname]}"
        echo "Processing printer: $pname with URI: $uri"
        if ! lpstat -v 2>/dev/null | grep -Fq "device for $pname:"; then
            echo "Running: lpadmin -p \"$pname\" -E -v \"$uri\" -P \"$AMSAMSPRINTERSPPD\""
            lpadmin -p "$pname" -E -v "$uri" -P "$AMSAMSPRINTERSPPD"
        else
            # ensure URI matches (update if changed)
            echo "Checking URI for printer: $pname"
            echo "Current URI: $(lpstat -v -- "$pname" 2>/dev/null | sed -n 's/^device for .*: //p')"
            echo "Expected URI: $uri"
            # get current URI
            current_uri=$(lpstat -v -- "$pname" 2>/dev/null | sed -n 's/^device for .*: //p')
            if [[ "$current_uri" != "$uri" ]]; then
                echo "Updating URI for printer: $pname"
                lpadmin -p "$pname" -v "$uri"
            fi
        fi
    done
fi


#handle cleanup

# remove ams printserver printers if network_id is not set to "ams"
if [[ -f /run/fnd/network_id ]] && [[ $(</run/fnd/network_id) == "unknown" ]]; then
    echo "Removing AMS printserver printers..."
    for pname in "${!AMSPRINTERS[@]}"; do
        if lpstat -v 2>/dev/null | grep -Fq "device for $pname:"; then
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



