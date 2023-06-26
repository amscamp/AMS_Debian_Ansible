#!/bin/bash

PORT=9100
socketArray=()
for entry in $(lpinfo -v | cut -c 1-); do

if [[ $entry =~ ^socket://[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  socketArray+=("$entry")
fi


done


socketArray=( `for i in ${socketArray[@]}; do echo $i; done | sort -u` )


for i in "${socketArray[@]}"
do 
   printerip=$(echo $i | sed 's|socket://||g')
   printername=$(nmap -sV --script getprintername.nse -p 9100 $printerip | grep _getprintername | sed 's/|_getprintername: //g')
   availableprinters=$(lpstat -v | grep $printerip | wc -l)
   if [[ $printername == "FS-1128MFP" && $availableprinters -eq 0 ]]; then
        echo $printerip

        lpadmin -p "FS1128MFP" -E -v $i -i /usr/share/ppd/kyocera/Kyocera_FS-1128MFP.ppd
   fi
   if [[ $printername == "FS-1128MFP" && $availableprinters -eq 1 ]]; then
        echo $printerip

        if ping -c 1 $printerip &> /dev/null
        then
            echo "success"
        else
            lpadmin -x "FS1128MFP"
        fi
   fi

done



