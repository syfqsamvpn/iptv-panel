#!/bin/bash
clear
domain=$(sed -n '1p' /root/iptv-panel/domain.txt)
if [ "$1" ]; then
    cpu="$1"
else
    cpu=$(nproc)
fi
cd /root
pkill -f "gunicorn.*main:app" >/dev/null 2>&1
screen -r -S "panel_bot" -X quit >/dev/null 2>&1
bash -c "cd '/root/iptv-panel' && gunicorn -w ${cpu} -b 0.0.0.0:443 --keyfile /etc/letsencrypt/live/${domain}/privkey.pem --certfile /etc/letsencrypt/live/${domain}/fullchain.pem --preload main:app --daemon"
screen -dmS panel_bot ott_sam.sh
