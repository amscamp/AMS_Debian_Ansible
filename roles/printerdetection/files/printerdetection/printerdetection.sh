#!/bin/bash

# Ensure cups-browsed state matches network (use same logic as below)
if [[ -f /run/fnd/network_id ]] && [[ $(</run/fnd/network_id) == "ams" ]]; then
  echo "AMS network detected: stopping and disabling cups-browsed"
  systemctl is-active --quiet cups-browsed && systemctl stop cups-browsed || true
  systemctl is-enabled cups-browsed &>/dev/null && systemctl disable cups-browsed || true
elif [[ -f /run/fnd/network_id ]] && [[ $(</run/fnd/network_id) != "ams" ]]; then
  echo "Non-AMS network detected: enabling and starting cups-browsed"
  systemctl enable cups-browsed || true
  systemctl start cups-browsed || true
fi

echo "hallo"
PORT=9100
socketArray=()



# add AMS printserver printers (hardcoded list)
declare -A AMSPRINTERS=(
    ["Brother_MFC-L8690CDW___Mono_Simplex_Hohe_Qualität__langsamer"]="http-pdf://ams-print01.ams.local:8888/print?printer=Brother_MFC-L8690CDW_Mono_Simplex_STD_A4"
    ["Brother_MFC-L8690CDW___Farb_Simplex_Hohe_Qualität__langsamer"]="http-pdf://ams-print01.ams.local:8888/print?printer=Brother_MFC-L8690CDW_Farb_Simplex_STD_A4"
    ["Brother_MFC-L8690CDW___Mono_Duplex_Hohe_Qualität__langsamer"]="http-pdf://ams-print01.ams.local:8888/print?printer=Brother_MFC-L8690CDW_Mono_Duplex_STD_A4"
    ["Brother_MFC-L8690CDW___Farb_Duplex_Hohe_Qualität__langsamer"]="http-pdf://ams-print01.ams.local:8888/print?printer=Brother_MFC-L8690CDW_Farb_Duplex_STD_A4"
    ["Brother_MFC-L8690CDW___Mono_Simplex"]="http-pdf://ams-print01.ams.local:8888/print?printer=Brother_MFC-L8690CDW_Mono_Simplex_GDI_A4"
    ["Brother_MFC-L8690CDW___Farb_Simplex"]="http-pdf://ams-print01.ams.local:8888/print?printer=Brother_MFC-L8690CDW_Farb_Simplex_GDI_A4"
    ["Brother_MFC-L8690CDW___Mono_Duplex"]="http-pdf://ams-print01.ams.local:8888/print?printer=Brother_MFC-L8690CDW_Mono_Duplex_GDI_A4"
    ["Brother_MFC-L8690CDW___Farb_Duplex"]="http-pdf://ams-print01.ams.local:8888/print?printer=Brother_MFC-L8690CDW_Farb_Duplex_GDI_A4"
    ["Kyocera_FS-1128MFP___Mono_Simplex"]="http-pdf://ams-print01.ams.local:8888/print?printer=Kyocera_FS-1128MFP_Mono_Simplex_STD_A4"
    ["Kyocera_FS-1128MFP___Mono_Duplex"]="http-pdf://ams-print01.ams.local:8888/print?printer=Kyocera_FS-1128MFP_Mono_Duplex_STD_A4"
    ["Kyocera_FS-1300D___Mono_Simplex"]="http-pdf://ams-print01.ams.local:8888/print?printer=Kyocera_FS-1300D_Mono_Simplex_STD_A4"
    ["Kyocera_FS-1300D___Mono_Duplex"]="http-pdf://ams-print01.ams.local:8888/print?printer=Kyocera_FS-1300D_Mono_Duplex_STD_A4"
    ["Brother_MFC-J5730DW___Mono_Simplex"]="http-pdf://ams-print01.ams.local:8888/print?printer=Brother_MFC-J5730DW_Mono_Simplex_STD_A4"
    ["Brother_MFC-J5730DW___Mono_Duplex"]="http-pdf://ams-print01.ams.local:8888/print?printer=Brother_MFC-J5730DW_Mono_Duplex_STD_A4"
    ["Brother_MFC-J5730DW___Farb_Simplex"]="http-pdf://ams-print01.ams.local:8888/print?printer=Brother_MFC-J5730DW_Farb_Simplex_STD_A4"
    ["Brother_MFC-J5730DW___Farb_Duplex"]="http-pdf://ams-print01.ams.local:8888/print?printer=Brother_MFC-J5730DW_Farb_Duplex_STD_A4"
    ["Brother_MFC-J5730DW___Mono_Simplex_A3"]="http-pdf://ams-print01.ams.local:8888/print?printer=Brother_MFC-J5730DW_Mono_Simplex_STD_A3"
    ["Brother_MFC-J5730DW___Farb_Simplex_A3"]="http-pdf://ams-print01.ams.local:8888/print?printer=Brother_MFC-J5730DW_Farb_Simplex_STD_A3"
    ["Brother_MFC-J5730DW___Mono_Duplex_A3"]="http-pdf://ams-print01.ams.local:8888/print?printer=Brother_MFC-J5730DW_Mono_Duplex_STD_A3"
    ["Brother_MFC-J5730DW___Farb_Duplex_A3"]="http-pdf://ams-print01.ams.local:8888/print?printer=Brother_MFC-J5730DW_Farb_Duplex_STD_A3"
    ["HP_Color-Laserjet-pro-M227dw___Mono_Simplex"]="http-pdf://ams-print01.ams.local:8888/print?printer=HP_Color-Laserjet-pro-M227dw_Mono_Simplex_STD_A4"
    ["HP_Color-Laserjet-pro-M227dw___Mono_Duplex"]="http-pdf://ams-print01.ams.local:8888/print?printer=HP_Color-Laserjet-pro-M227dw_Mono_Duplex_STD_A4"
    ["HP_Color-Laserjet-pro-M227dw___Farb_Simplex"]="http-pdf://ams-print01.ams.local:8888/print?printer=HP_Color-Laserjet-pro-M227dw_Farb_Simplex_STD_A4"
    ["HP_Color-Laserjet-pro-M227dw___Farb_Duplex"]="http-pdf://ams-print01.ams.local:8888/print?printer=HP_Color-Laserjet-pro-M227dw_Farb_Duplex_STD_A4"
    ["HP_Color-Laserjet-pro-M227dw___Mono_Simplex_Randlos"]="http-pdf://ams-print01.ams.local:8888/print?printer=HP_Color-Laserjet-pro-M227dw_Mono_Simplex_STD_A4BL"
    ["HP_Color-Laserjet-pro-M227dw___Farb_Simplex_Randlos"]="http-pdf://ams-print01.ams.local:8888/print?printer=HP_Color-Laserjet-pro-M227dw_Farb_Simplex_STD_A4BL"
    ["HP_Color-Laserjet-pro-M227dw___Mono_Duplex_Randlos"]="http-pdf://ams-print01.ams.local:8888/print?printer=HP_Color-Laserjet-pro-M227dw_Mono_Duplex_STD_A4BL"
    ["HP_Color-Laserjet-pro-M227dw___Farb_Duplex_Randlos"]="http-pdf://ams-print01.ams.local:8888/print?printer=HP_Color-Laserjet-pro-M227dw_Farb_Duplex_STD_A4BL"

)

AMSPRINTERSPPD="/usr/share/ppd/cupsfilters/Generic-PDF_Printer-PDF.ppd"

# Helper: check if a printer queue exists via lpstat -p (reliable exit code)
printer_exists() {
    lpstat -p "$1" >/dev/null 2>&1
}

# Helper: get device URI for a queue name (locale-agnostic)
get_printer_uri() {
    local name="$1"
    lpstat -v "$name" 2>/dev/null | head -n1 | sed 's/^[^:]*: \(.*\)$/\1/'
}

# Helper: set paper size based on printer name suffix
set_paper_size() {
    local pname="$1"
    local paper_size="A4"  # default
    
    if [[ "$pname" == *"_A4BL" ]] || [[ "$pname" == *"_Randlos" ]]; then
        paper_size="A4.Borderless"
        echo "Setting paper size to A4 Borderless for printer: $pname"
    elif [[ "$pname" == *"_A3" ]]; then
        paper_size="A3"
        echo "Setting paper size to A3 for printer: $pname"
    else
        paper_size="A4"
        echo "Setting paper size to A4 for printer: $pname"
    fi
    
    # Set the paper size using lpadmin
    lpadmin -p "$pname" -o media="$paper_size" || true
    
    # Also try alternative paper size options if the first fails
    case "$paper_size" in
        "A4.Borderless")
            lpadmin -p "$pname" -o PageSize=A4.Borderless || \
            lpadmin -p "$pname" -o media=iso_a4_210x297mm.borderless || \
            lpadmin -p "$pname" -o PageSize=A4Borderless || true
            ;;
        "A3")
            lpadmin -p "$pname" -o PageSize=A3 || \
            lpadmin -p "$pname" -o media=iso_a3_297x420mm || true
            ;;
        "A4")
            lpadmin -p "$pname" -o PageSize=A4 || \
            lpadmin -p "$pname" -o media=iso_a4_210x297mm || true
            ;;
    esac
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
            # Set appropriate paper size after creating the printer
            set_paper_size "$pname"
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
            # Always ensure correct paper size is set
            set_paper_size "$pname"
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



