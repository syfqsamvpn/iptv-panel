#!/bin/bash
firtsTimeRun() {

    [[ ! -f /usr/bin/jq ]] && {
        apt install jq
    }
    [[ ! -d /root/ottbot ]] && {
        mkdir -p /root/ottbot
        touch /root/ottbot/db.txt
        touch "/root/ottbot/all_id.txt"
    }
    [[ ! -f /root/ottbot/api.sh ]] && {
        wget -qO- api.samhub.my.id/BotAPI.sh >/root/ottbot/api.sh
    }
    [[ ! -f /root/ottbot/bot.conf ]] && {
        echo -ne "Input your Bot TOKEN : "
        read bot_tkn
        echo "Token: $bot_tkn" >/root/ottbot/bot.conf
        echo -ne "Input your Admin ID : "
        read adm_ids
        echo "AdminID: $adm_ids" >>/root/ottbot/bot.conf
    }
}
ipvps=$(curl -s "https://ipv4.icanhazip.com")
if [ "$(curl -s "https://raw.githubusercontent.com/syfqsamvpn/iptv/main/panel_bot.sh" | grep -wc "${ipvps}")" != '0' ]; then
    firtsTimeRun
    if ! crontab -l | grep -q "ott_sam.sh -a"; then
        (
            crontab -l
            echo "0 12 * * * ott_sam.sh -a > /root/t1.log 2>&1"
        ) | crontab -
    fi
    if ! crontab -l | grep -q "ott_sam.sh -b"; then
        (
            crontab -l
            echo "0 13 * * * ott_sam.sh -b > /root/t1.log 2>&1"
        ) | crontab -
    fi
else
    rm -rf "/root/ottbot"
    crontab -l | grep -v 'start_bot.sh' | crontab -
fi
