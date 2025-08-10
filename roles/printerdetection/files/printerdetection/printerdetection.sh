#!/bin/bash

PORT=9100
socketArray=()

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

# add AMS printserver printers (hardcoded list)
declare -A PRINTERS=(
    ["Brother MFC-L8690CDW - S/W Simplex"]="http-pdf://ams-print01.ams.local:8888/print?printer=Brother-MFC-L8690CDW-GDI-SW-Simplex"
    ["Brother MFC-L8690CDW - Farb Simplex"]="http-pdf://ams-print01.ams.local:8888/print?printer=Brother-MFC-L8690CDW-GDI-Farb-Simplex"
    ["Brother MFC-L8690CDW - S/W Duplex"]="http-pdf://ams-print01.ams.local:8888/print?printer=Brother-MFC-L8690CDW-GDI-SW-Duplex"
    ["Brother MFC-L8690CDW - Farb Duplex"]="http-pdf://ams-print01.ams.local:8888/print?printer=Brother-MFC-L8690CDW-GDI-Farb-Duplex"
    ["Brother MFC-L8690CDW - S/W Simplex Hohe Qualität (langsamer)"]="http-pdf://ams-print01.ams.local:8888/print?printer=Brother-MFC-L8690CDW-SW-Simplex"
    ["Brother MFC-L8690CDW - Farb Simplex Hohe Qualität (langsamer)"]="http-pdf://ams-print01.ams.local:8888/print?printer=Brother-MFC-L8690CDW-Farb-Simplex"
    ["Brother MFC-L8690CDW - S/W Duplex Hohe Qualität (langsamer)"]="http-pdf://ams-print01.ams.local:8888/print?printer=Brother-MFC-L8690CDW-SW-Duplex"
    ["Brother MFC-L8690CDW - Farb Duplex Hohe Qualität (langsamer)"]="http-pdf://ams-print01.ams.local:8888/print?printer=Brother-MFC-L8690CDW-Farb-Duplex"
)

PPD="/usr/share/ppd/cupsfilters/Generic-PDF_Printer-PDF.ppd"

for pname in "${!PRINTERS[@]}"; do
    uri="${PRINTERS[$pname]}"

    if ! lpstat -v 2>/dev/null | grep -q "^device for $pname:"; then
        lpadmin -p "$pname" -E -v "$uri" -P "$PPD"
    else
        # ensure URI matches (update if changed)
        current_uri=$(lpstat -v 2>/dev/null | awk -v p="$pname" '$3==p":" {print $NF}')
        if [[ "$current_uri" != "$uri" ]]; then
            lpadmin -p "$pname" -v "$uri"
        fi
    fi
done


#handle cleanup
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



