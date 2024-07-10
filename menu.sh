#!/bin/bash

ipvps=$(curl -s "https://ipv4.icanhazip.com")
domain=$(sed -n '1p' /root/iptv-panel/domain.txt)
API_BASE_URL="https://${domain}"
admin_password=$(grep -o 'admin_pass = "[^"]*' "/root/iptv-panel/data.txt" | grep -o '[^"]*$' | sed -n '1p')
OFFLINE_REDIRECT=$(grep -o 'OFFLINE_REDIRECT = "[^"]*' "/root/iptv-panel/data.txt" | grep -o '[^"]*$' | sed -n '1p')

END="\033[0m"
BLUE="\033[1;34m"
GREEN="\033[1;92m"
CYAN="\033[1;96m"
BLACK="\033[1;90m"
RED="\033[1;91m"
B_YELLOW="\033[43m"
function register_reseller() {
    read -p "Enter reseller username: " reseller_username
    read -p "Enter reseller balance: " reseller_balance

    response=$(curl -s --request POST \
        --url "$API_BASE_URL/api/register_reseller" \
        --header 'Content-Type: application/json' \
        --data '{
            "password": "'"$admin_password"'",
            "balance": '"$reseller_balance"',
            "username": "'"$reseller_username"'"
        }')

    echo "$response" | jq -C .
}

function add_user() {
    reseller_username=$(grep -o 'ADMIN_RES_USER = "[^"]*' "/root/iptv-panel/data.txt" | grep -o '[^"]*$' | sed -n '1p')
    reseller_password=$(grep -o 'ADMIN_RES_PASS = "[^"]*' "/root/iptv-panel/data.txt" | grep -o '[^"]*$' | sed -n '1p')
    read -p "Enter username: " username
    read -p "Enter package: " package

    response=$(curl -s --request POST \
        --url "$API_BASE_URL/api/add_user" \
        --header 'Content-Type: application/json' \
        --data '{
            "username": "'"$username"'",
            "reseller_username": "'"$reseller_username"'",
            "reseller_password": "'"$reseller_password"'",
            "package": "'"$package"'",
            "admin_password": "'"$admin_password"'"
        }')
    date=$(echo "${response}" | grep -o '"expiration_date":"[^"]*' | grep -o '[^"]*$' | awk '{print $1}')
    link=$(echo "${response}" | grep -o '"link":"[^"]*' | grep -o '[^"]*$')
    username=$(echo "${response}" | grep -o '"username":"[^"]*' | grep -o '[^"]*$')
    uuid=$(echo "${response}" | grep -o '"uuid":"[^"]*' | grep -o '[^"]*$')
    template_file="/root/iptv-panel/add_template.txt"
    template=$(<"$template_file")
    template=$(echo "${template}" | sed 's/<code>//g; s/<\/code>//g')
    template=$(echo "${template}" | sed "s|\${date}|${date}|g")
    template=$(echo "${template}" | sed "s|\${link}|${link}|g")
    template=$(echo "${template}" | sed "s|\${username}|${username}|g")
    template=$(echo "${template}" | sed "s|\${uuid}|${uuid}|g")
    msg="$template"
    clear
    echo "$msg"
    echo ""
}

function renew_user() {
    reseller_username=$(grep -o 'ADMIN_RES_USER = "[^"]*' "/root/iptv-panel/data.txt" | grep -o '[^"]*$' | sed -n '1p')
    reseller_password=$(grep -o 'ADMIN_RES_PASS = "[^"]*' "/root/iptv-panel/data.txt" | grep -o '[^"]*$' | sed -n '1p')
    read -p "Enter user UUID to renew: " user_uuid
    read -p "Enter package: " package

    response=$(curl -s --request POST \
        --url "$API_BASE_URL/api/renew_user" \
        --header 'Content-Type: application/json' \
        --data '{
            "reseller_username": "'"$reseller_username"'",
            "reseller_password": "'"$reseller_password"'",
            "uuid": "'"$user_uuid"'",
            "package": "'"$package"'"
        }')
    date=$(echo "${response}" | grep -o '"new_expiration_date":"[^"]*' | grep -o '[^"]*$' | awk '{print $1}')
    username=$(echo "${response}" | grep -o '"username":"[^"]*' | grep -o '[^"]*$')
    uuid=$(echo "${response}" | grep -o '"uuid":"[^"]*' | grep -o '[^"]*$')
    template_file="/root/iptv-panel/renew_template.txt"
    template=$(<"$template_file")
    template=$(echo "${template}" | sed 's/<code>//g; s/<\/code>//g')
    template=$(echo "${template}" | sed "s|\${date}|${date}|g")
    template=$(echo "${template}" | sed "s|\${username}|${username}|g")
    template=$(echo "${template}" | sed "s|\${uuid}|${uuid}|g")
    msg="$template"
    clear
    echo "$msg"
    echo ""
}

function add_reseller_balance() {
    read -p "Enter reseller username to add balance: " username
    read -p "Enter amount to add: " amount

    response=$(curl -s --request POST \
        --url "$API_BASE_URL/api/add_reseller_balance" \
        --header 'Content-Type: application/json' \
        --data '{
            "username": "'"$username"'",
            "amount": '"$amount"',
            "password": "'"$admin_password"'"
        }')

    echo "$response" | jq -C .
}

function delete_user() {
    read -p "Enter username: " username
    read -p "Enter user UUID: " user_uuid

    response=$(curl -s --request POST \
        --url "$API_BASE_URL/api/delete_user" \
        --header 'Content-Type: application/json' \
        --data '{
            "username": "'"$username"'",
            "uuid": "'"$user_uuid"'",
            "admin_password": "'"$admin_password"'"
        }')

    echo "$response" | jq -C .
}

function get_user_data() {
    read -p "Enter user UUID: " user_uuid

    response=$(curl -s "$API_BASE_URL/api/get_user_data?user_uuid=$user_uuid&password_input=$admin_password")

    echo "$response" | jq -C .
}

function get_users_by_reseller() {
    read -p "Enter reseller username: " reseller_username

    response=$(curl -s "$API_BASE_URL/api/get_users_by_reseller?reseller_username=$reseller_username&password_input=$admin_password")

    echo "$response" | jq -C .
}

function add_user_custom() {
    reseller_username=$(grep -o 'ADMIN_RES_USER = "[^"]*' "/root/iptv-panel/data.txt" | grep -o '[^"]*$' | sed -n '1p')
    reseller_password=$(grep -o 'ADMIN_RES_PASS = "[^"]*' "/root/iptv-panel/data.txt" | grep -o '[^"]*$' | sed -n '1p')
    read -p "Enter username: " username
    read -p "Enter number of days: " days

    response=$(curl -s --request POST \
        --url "$API_BASE_URL/api/add_user_custom" \
        --header 'Content-Type: application/json' \
        --data '{
            "admin_password": "'"$admin_password"'",
            "reseller_username": "'"$reseller_username"'",
            "reseller_password": "'"$reseller_password"'",
            "username": "'"$username"'",
            "days": '"$days"'
        }')

    echo "$response" | jq -C .
}

function renew_user_custom() {
    reseller_username=$(grep -o 'ADMIN_RES_USER = "[^"]*' "/root/iptv-panel/data.txt" | grep -o '[^"]*$' | sed -n '1p')
    reseller_password=$(grep -o 'ADMIN_RES_PASS = "[^"]*' "/root/iptv-panel/data.txt" | grep -o '[^"]*$' | sed -n '1p')
    read -p "Enter UUID: " uuid
    read -p "Enter number of days: " days

    response=$(curl -s --request POST \
        --url "$API_BASE_URL/api/renew_user_custom" \
        --header 'Content-Type: application/json' \
        --data '{
            "admin_password": "'"$admin_password"'",
            "reseller_username": "'"$reseller_username"'",
            "reseller_password": "'"$reseller_password"'",
            "uuid": "'"$uuid"'",
            "days": '"$days"'
        }')

    echo "$response" | jq -C .
}

function check_shortlink() {
    read -p "Enter UUID: " uuid

    response=$(curl -s --request POST \
        --url "$API_BASE_URL/api/check_shortlink" \
        --header 'Content-Type: application/json' \
        --data '{
            "admin_password": "'"$admin_password"'",
            "uuid": "'"$uuid"'"
        }')

    echo "$response" | jq -C .
}

function unban_multi() {
    read -p "Enter UUID: " uuid

    response=$(curl -s --request POST \
        --url "$API_BASE_URL/api/unban_multi" \
        --header 'Content-Type: application/json' \
        --data '{
            "admin_password": "'"$admin_password"'",
            "uuid": "'"$uuid"'"
        }')

    echo "$response" | jq -C .
}

function unban_sniffer() {
    read -p "Enter UUID: " uuid

    response=$(curl -s --request POST \
        --url "$API_BASE_URL/api/unban_sniffer" \
        --header 'Content-Type: application/json' \
        --data '{
            "admin_password": "'"$admin_password"'",
            "uuid": "'"$uuid"'"
        }')

    echo "$response" | jq -C .
}

function get_all_resellers() {
    response=$(curl -s "$API_BASE_URL/api/get_all_resellers?password_input=$admin_password")

    echo "$response" | jq -C .
}

function get_all_agents() {
    response=$(curl -s "$API_BASE_URL/api/get_all_agents?password_input=$admin_password")

    echo "$response" | jq -C .
}

function add_secure_url() {
    read -p "Enter short ID: " short_id
    read -p "Enter URL: " url

    response=$(curl -s --request POST \
        --url "$API_BASE_URL/secure" \
        --header 'Content-Type: application/json' \
        --data '{
            "short_id": "'"$short_id"'",
            "url": "'"$url"'"
        }')

    echo "$response" | jq -C .
}

req_edit_secureshort() {
    short_id=$1
    new_url=$2
    response=$(curl -s --request POST \
        --url "$API_BASE_URL/secure_edit" \
        --header 'Content-Type: application/json' \
        --data '{
            "short_id": "'"$short_id"'",
            "url": "'"$new_url"'"
        }')

    echo "$response" | jq -C .
}

add_secure_vod() {
    read -p "Enter VOD Link : " link

    response=$(curl -s --request POST \
        --url "$API_BASE_URL/vod/add" \
        --header 'Content-Type: application/json' \
        --data '{
            "admin_pass": "'"$admin_password"'",
            "url": "'"$link"'"
        }')

    echo "$response" | jq -C .
}

function edit_secure_url() {
    read -p "Enter short ID to edit: " short_id
    read -p "Enter new URL: " new_url
    req_edit_secureshort "$short_id" "$new_url"
}

function check_multilogin() {
    read -p "Enter user UUID: " user_uuid

    response=$(curl -s "$API_BASE_URL/api/check_multilogin?user_uuid=$user_uuid&password_input=$admin_password")

    echo "$response" | jq -C .
}

function check_all_multilogin() {

    response=$(curl -s "$API_BASE_URL/api/check_all_multilogin?password_input=$admin_password")

    echo "$response" | jq -C .
}

function restart_api() {
    run.sh
}

function change_secure_stat() {
    curl --request POST \
        --url "$API_BASE_URL/api/secure_stat"
}

function change_uuid_stat() {
    curl --request POST \
        --url "$API_BASE_URL/api/secure_uuid"
}

function change_ip_stat() {
    curl --request POST \
        --url "$API_BASE_URL/api/secure_ip"
}

function cleardata() {
    curl --request POST \
        --url "$API_BASE_URL/api/cleardata"
}

function ban_sniffer() {
    read -p "Enter user uuid: " input_uuid

    response=$(curl -s --request POST \
        --url "$API_BASE_URL/api/ban_sniffer" \
        --header 'Content-Type: application/json' \
        --data '{
            "admin_password": "'"$admin_password"'",
            "uuid": "'"$input_uuid"'"
        }')

    echo "$response" | jq -C .
}

function guardian() {
    respond=$(curl -s --request POST \
        --url "$API_BASE_URL/guardian" \
        --header 'Content-Type: application/json' \
        --data '{
            "admin_password": "'"$admin_password"'"
        }')

    echo "$respond"
}

function get_data_short() {
    read -p "Input User Short Link : " short_link
    short_id=$(echo "$short_link" | grep -o '/[^ ]*' | grep -o '[^/]*$')
    user_uuid=$(jq -r --arg short_id "$short_id" '.[$short_id]' /root/iptv-panel/short_links.json | grep -o 'uuid=[^ ]*$' | grep -o '[^=]*$')
    response=$(curl -s "$API_BASE_URL/api/get_user_data?user_uuid=$user_uuid&password_input=$admin_password")

    echo "$response" | jq -C .
}

astro_checker() {
    url=$1
    status_code=$(curl -s --request POST \
        --url "$API_BASE_URL/astro/checker?url=$url" | jq '.status_code' | tr -d '\n' | sed 's/"//g')
    echo "$status_code"
}

function check_all_secureshort() {
    if [ "$(curl -s "https://raw.githubusercontent.com/syfqsamvpn/iptv/main/xtro.txt" | grep -wc "${ipvps}")" != '0' ]; then
        clear
        json_file="/root/iptv-panel/secure_short.json"

        keys=$(jq -r 'keys[]' "$json_file")

        for key in $keys; do
            value=$(jq -r --arg k "$key" '.[$k]' "$json_file")
            if [ "$value" != "$OFFLINE_REDIRECT" ]; then
                checker_result=$(astro_checker "$value")
                if [[ ${checker_result} ]]; then
                    if [ "$checker_result" != "200" ]; then
                        token_status="OFFLINE ❌"
                    else
                        token_status="ONLINE ✅"
                    fi
                    echo "${key}: ${token_status}"
                    if [ "$(echo "$value" | grep -ic "astro.com.my")" == '0' ] && [ "$(echo "$value" | grep -ic "amazonaws.com")" == '0' ]; then
                        edit_offline=$(req_edit_secureshort "$key" "$OFFLINE_REDIRECT")
                    fi
                    if [ "$checker_result" != "200" ]; then
                        edit_offline=$(req_edit_secureshort "$key" "$OFFLINE_REDIRECT")
                    fi
                fi
            else
                echo "${key}: DEFAULT"
            fi
            echo "--------------------"
        done
    else
        echo "Dont Has Access"
    fi
}

update_bearer() {
    read -p "Input Bearer: " bearer
    echo "$bearer" >"/root/iptv-panel/static/var/bearer"
    echo "Done Update Bearer"
}

if [[ "$1" == "-c" || "$1" == "--checker" ]]; then
    check_all_secureshort
    exit 0
else
    while true; do
        req_head="${BLUE} ━━━━━━━━━━━━━━━━${END} ${GREEN}BY SAMSFX${END} ${BLUE}━━━━━━━━━━━━━━━━${END}"
        clear
        total_user=$(grep -o '"uuid"' "/root/iptv-panel/user_iptv.json" | wc -l)
        echo -e "${BLUE}╔══════════════════════════════════════════╗${END}"
        echo -e "${BLUE}║\E[0m              • OTT SYSTEM •              ${BLUE}║\E[0m"
        echo -e "${BLUE}╚══════════════════════════════════════════╝${END}"
        echo -e "${BLUE}╔══${END}"
        echo -e "${BLUE}╠${END} ${CYAN}DOMAIN${END}     : ${GREEN}${domain}${END}"
        echo -e "${BLUE}╠${END} ${CYAN}IP SERVER${END}  : ${GREEN}${ipvps}${END}"
        echo -e "${BLUE}╠${END} ${CYAN}TOTAL USER${END} : ${GREEN}${total_user} Users${END}"
        echo -e "${BLUE}╚══${END}"
        echo -e "${BLUE}╠${END} ${GREEN}[ 1]${END}. ${CYAN}Register Reseller${END}"
        echo -e "${BLUE}╠${END} ${GREEN}[ 2]${END}. ${CYAN}Add User${END}"
        echo -e "${BLUE}╠${END} ${GREEN}[ 3]${END}. ${CYAN}Delete User${END}"
        echo -e "${BLUE}╠${END} ${GREEN}[ 4]${END}. ${CYAN}Get User Data${END}"
        echo -e "${BLUE}╠${END} ${GREEN}[ 5]${END}. ${CYAN}Get User Data (By short link)${END}"
        echo -e "${BLUE}╠${END} ${GREEN}[ 6]${END}. ${CYAN}Get Users by Reseller${END}"
        echo -e "${BLUE}╠${END} ${GREEN}[ 7]${END}. ${CYAN}Check User Multilogin${END}"
        echo -e "${BLUE}╠${END} ${GREEN}[ 8]${END}. ${CYAN}Check All Multilogin${END}"
        echo -e "${BLUE}╠${END} ${GREEN}[ 9]${END}. ${CYAN}Renew User${END}"
        echo -e "${BLUE}╠${END} ${GREEN}[10]${END}. ${CYAN}Add Balance${END}"
        echo -e "${BLUE}╠${END} ${GREEN}[11]${END}. ${CYAN}Add User Custom${END}"
        echo -e "${BLUE}╠${END} ${GREEN}[12]${END}. ${CYAN}Renew User Custom${END}"
        echo -e "${BLUE}╠${END} ${GREEN}[13]${END}. ${CYAN}Get All Resellers${END}"
        echo -e "${BLUE}╠${END} ${GREEN}[14]${END}. ${CYAN}Get All Agents${END}"
        echo -e "${BLUE}╠${END} ${GREEN}[15]${END}. ${CYAN}Add Secure URL${END}"
        echo -e "${BLUE}╠${END} ${GREEN}[16]${END}. ${CYAN}Edit Secure URL${END}"
        echo -e "${BLUE}╠${END} ${GREEN}[17]${END}. ${CYAN}Add Secure VOD${END}"
        echo -e "${BLUE}╠${END} ${GREEN}[18]${END}. ${CYAN}Check Shortlink${END}"
        echo -e "${BLUE}╠${END} ${GREEN}[19]${END}. ${CYAN}Unban Multilogin${END}"
        echo -e "${BLUE}╠${END} ${GREEN}[20]${END}. ${CYAN}Unban Sniffer${END}"
        echo -e "${BLUE}╠${END} ${GREEN}[21]${END}. ${CYAN}Restart Services${END}"
        echo -e "${BLUE}╠${END} ${GREEN}[22]${END}. ${CYAN}Manual Backup${END}"
        echo -e "${BLUE}╠${END} ${GREEN}[23]${END}. ${CYAN}Change Secure Stat${END}"
        echo -e "${BLUE}╠${END} ${GREEN}[24]${END}. ${CYAN}Change UUID Stat${END}"
        echo -e "${BLUE}╠${END} ${GREEN}[25]${END}. ${CYAN}Change IP Stat${END}"
        echo -e "${BLUE}╠${END} ${GREEN}[26]${END}. ${CYAN}Clear All Expired${END}"
        echo -e "${BLUE}╠${END} ${GREEN}[27]${END}. ${CYAN}Ban sniffer${END}"
        echo -e "${BLUE}╠${END} ${GREEN}[28]${END}. ${CYAN}Check Suspicious Log${END}"
        echo -e "${BLUE}╠${END} ${GREEN}[29]${END}. ${CYAN}Check All Secure Short Status${END}"
        echo -e "${BLUE}╠${END} ${GREEN}[30]${END}. ${CYAN}Update Bearer [Sooka]${END}"
        echo -e "${BLUE}╚${END} ${GREEN}[31]${END}. ${RED}Exit${END}"
        echo -e "${BLUE}╚${END} ${GREEN}[U]${END} . ${BLUE}UPDATE${END}"
        echo -e ""
        echo -e "${BLUE} ━━━━━━━━━━━━━━━━${END} ${GREEN}BY SAMSFX${END} ${BLUE}━━━━━━━━━━━━━━━━${END}"
        echo -e ""
        read -p "Select an option (1-31): " choice
        clear
        echo -e "$req_head"
        echo ""
        case $choice in
        1)
            register_reseller
            ;;
        2)
            add_user
            ;;
        3)
            delete_user
            ;;
        4)
            get_user_data
            ;;
        5)
            get_data_short
            ;;
        6)
            get_users_by_reseller
            ;;
        7)
            check_multilogin
            ;;
        8)
            check_all_multilogin
            ;;
        9)
            renew_user
            ;;
        10)
            add_reseller_balance
            ;;
        11)
            add_user_custom
            ;;
        12)
            renew_user_custom
            ;;
        13)
            get_all_resellers
            ;;
        14)
            get_all_agents
            ;;
        15)
            add_secure_url
            ;;
        16)
            edit_secure_url
            ;;
        17)
            add_secure_vod
            ;;
        18)
            check_shortlink
            ;;
        19)
            unban_multi
            ;;
        20)
            unban_sniffer
            ;;
        21)
            restart_api
            ;;
        22)
            ott_sam.sh -b
            ;;
        23)
            change_secure_stat
            ;;
        24)
            change_uuid_stat
            ;;
        25)
            change_ip_stat
            ;;
        26)
            cleardata
            ;;
        27)
            ban_sniffer
            ;;
        28)
            guardian
            ;;
        29)
            check_all_secureshort
            ;;
        30)
            update_bearer
            ;;
        31)
            echo "Exiting..."
            exit 0
            ;;
        u | U)
            echo "Updating..."
            bash <(curl -s https://raw.githubusercontent.com/syfqsamvpn/iptv-panel/main/update.sh)
            run.sh
            echo "Done Update"
            ;;
        *)
            echo "Invalid choice. Please enter a number between 1 and 29."
            ;;
        esac

        read -p "Press enter to continue..."
    done
fi
