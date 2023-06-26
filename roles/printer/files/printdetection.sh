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

        lpadmin -p FS-1128MFP -E -v socket://$printerip -m /usr/share/ppd/kyocera/Kyocera_FS-1128MFP.ppd
   fi

done



