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



