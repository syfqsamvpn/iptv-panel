#!/bin/bash

domain=$(sed -n '1p' /root/iptv-panel/domain.txt)
API_BASE_URL="https://${domain}"
admin_password=$(grep -o 'admin_pass = "[^"]*' "/root/iptv-panel/data.txt" | grep -o '[^"]*$' | sed -n '1p')
OFFLINE_REDIRECT=$(grep -o 'OFFLINE_REDIRECT = "[^"]*' "/root/iptv-panel/data.txt" | grep -o '[^"]*$' | sed -n '1p')

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
    if [ "$status_code" != "200" ]; then
        echo "OFFLINE ❌"
    else
        echo "ONLINE ✅"
    fi
}

function check_all_secureshort() {
    clear
    json_file="/root/iptv-panel/secure_short.json"

    keys=$(jq -r 'keys[]' "$json_file")

    for key in $keys; do
        value=$(jq -r --arg k "$key" '.[$k]' "$json_file")
        checker_result=$(astro_checker "$value")
        echo "${key}: ${checker_result}"
        if [ "$(echo "$checker_result" | grep -ic "OFFLINE")" != '0' ]; then
            edit_offline=$(req_edit_secureshort "$key" "$OFFLINE_REDIRECT")
        fi
        echo "--------------------"
    done
}
if [[ "$1" == "-c" || "$1" == "--checker" ]]; then
    check_all_secureshort
    exit 0
else
    while true; do
        clear
        echo "========= API Interaction Script ========="
        echo "1. Register Reseller"
        echo "2. Add User"
        echo "3. Delete User"
        echo "4. Get User Data"
        echo "5. Get User Data (By short link)"
        echo "6. Get Users by Reseller"
        echo "7. Check User Multilogin"
        echo "8. Check All Multilogin"
        echo "9. Renew User"
        echo "10.Add Balance"
        echo "11. Add User Custom"
        echo "12. Renew User Custom"
        echo "13. Get All Resellers"
        echo "14. Get All Agents"
        echo "15. Add Secure URL"
        echo "16. Edit Secure URL"
        echo "17. Check Shortlink"
        echo "18. Unban Multilogin"
        echo "19. Unban Sniffer"
        echo "20. Restart Services"
        echo "21. Manual Backup"
        echo "22. Change Secure Stat"
        echo "23. Change UUID Stat"
        echo "24. Change IP Stat"
        echo "25. Clear All Expired"
        echo "26. Ban sniffer"
        echo "27. Check Suspicious Log"
        echo "28. Check All Secure Short Status"
        echo "29. Exit"
        echo "=========================================="
        read -p "Select an option (1-29): " choice

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
            check_shortlink
            ;;
        18)
            unban_multi
            ;;
        19)
            unban_sniffer
            ;;
        20)
            restart_api
            ;;
        21)
            ott_sam.sh -b
            ;;
        22)
            change_secure_stat
            ;;
        23)
            change_uuid_stat
            ;;
        24)
            change_ip_stat
            ;;
        25)
            cleardata
            ;;
        26)
            ban_sniffer
            ;;
        27)
            guardian
            ;;
        28)
            check_all_secureshort
            ;;
        29)
            echo "Exiting..."
            exit 0
            ;;
        *)
            echo "Invalid choice. Please enter a number between 1 and 29."
            ;;
        esac

        read -p "Press enter to continue..."
    done
fi
