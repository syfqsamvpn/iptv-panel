#!/bin/bash
clear

ipvps=$(curl -s https://ipv4.icanhazip.com)

# Fetch the panel IP from the provided URL
panel_ips=$(curl -s https://raw.githubusercontent.com/syfqsamvpn/iptv/main/panel_access.txt)

# Check if the current server's IP matches the panel IP
if [ "$(echo "${panel_ips}" | grep -wc "${ipvps}")" != '0' ]; then
    read -p "Input Domain: " domain

    sudo apt update
    sudo apt upgrade -y
    timedatectl set-timezone Asia/Kuala_Lumpur
    sudo apt install jq -y
    sudo apt install zip -y
    sudo apt install -y python3-pip
    sudo apt install git -y
    apt install screen -y
    apt install vnstat -y
    sudo apt install certbot -y
    sudo certbot certonly --standalone -d ${domain}
    git clone https://github.com/syfqsamvpn/iptv-panel.git
    echo "$domain" >/root/iptv-panel/domain.txt
    cd /root/iptv-panel
    pip3 install -r requirements.txt
    pip3 install Flask[async]

    mv /root/iptv-panel/menu.sh /usr/bin/menu
    mv /root/iptv-panel/run.sh /usr/bin/run.sh
    mv /root/iptv-panel/ott_sam.sh /usr/bin/ott_sam.sh
    mv /root/iptv-panel/start_bot.sh /usr/bin/start_bot.sh

    chmod +x /usr/bin/menu
    chmod +x /usr/bin/run.sh
    chmod +x /usr/bin/ott_sam.sh
    chmod +x /usr/bin/start_bot.sh
    mkdir /root/iptv-panel/static
    mkdir /root/iptv-panel/static/var
    echo "menu" >>"/root/.profile"
    (
        crontab -l
        echo "0 0 * * * reboot"
    ) | crontab -
    run.sh
    cd /root

    cat >/etc/systemd/system/rc-local.service <<-END
[Unit]
Description=/etc/rc.local
ConditionPathExists=/etc/rc.local
[Service]
Type=forking
ExecStart=/etc/rc.local start
TimeoutSec=0
StandardOutput=tty
RemainAfterExit=yes
SysVStartPriority=99
[Install]
WantedBy=multi-user.target
END

    # nano /etc/rc.local
    cat >/etc/rc.local <<-END
#!/bin/sh -e
# rc.local
# By default this script does nothing.
exit 0
END

    chmod +x /etc/rc.local
    sed -i '$ i\run.sh' /etc/rc.local >/dev/null 2>&1
    systemctl enable rc-local >/dev/null 2>&1
    systemctl start rc-local.service >/dev/null 2>&1
    rm -rf /root/iptv-panel/setup.sh
    sudo -i
else
    echo "Access denied. Panel IP matches server IP."
    exit 1
fi
