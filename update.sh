#!/bin/bash
clear
apt install vnstat -y
pip3 install pycryptodome
pip3 install flask_cors
pip3 install Flask[async]
[[ ! -d /root/iptv-panel/templates ]] && {
    mkdir /root/iptv-panel/templates
}
curl -s "https://raw.githubusercontent.com/syfqsamvpn/iptv-panel/main/templates/reseller_users.html" >/root/iptv-panel/templates/reseller_users.html
curl -s "https://raw.githubusercontent.com/syfqsamvpn/iptv-panel/main/menu.sh" >/usr/bin/menu && chmod +x /usr/bin/menu
curl -s "https://raw.githubusercontent.com/syfqsamvpn/iptv-panel/main/start_bot.sh" >/usr/bin/start_bot.sh && chmod +x /usr/bin/start_bot.sh
#curl -s "https://raw.githubusercontent.com/syfqsamvpn/iptv-panel/main/ott_sam.sh" >/usr/bin/ott_sam.sh && chmod +x /usr/bin/ott_sam.sh
curl -s "https://raw.githubusercontent.com/syfqsamvpn/iptv-panel/main/epg.txt" >/root/iptv-panel/epg.txt
curl -s "https://raw.githubusercontent.com/syfqsamvpn/iptv-panel/main/main.py" >/root/iptv-panel/main.py
curl -s "https://raw.githubusercontent.com/syfqsamvpn/iptv-panel/main/system_ott.py" >/root/iptv-panel/system_ott.py
curl -s "https://raw.githubusercontent.com/syfqsamvpn/iptv-panel/main/reseller.py" >/root/iptv-panel/reseller.py
curl -s "https://raw.githubusercontent.com/syfqsamvpn/iptv-panel/main/vod.py" >/root/iptv-panel/vod.py
curl -s "https://raw.githubusercontent.com/syfqsamvpn/iptv-panel/main/sam_enc.py" >/root/iptv-panel/sam_enc.py
curl -s "https://raw.githubusercontent.com/syfqsamvpn/iptv-panel/main/sam_secure.py" >/root/iptv-panel/sam_secure.py
curl -s "https://raw.githubusercontent.com/syfqsamvpn/iptv-panel/main/pytransform/__init__.py" >/root/iptv-panel/pytransform/__init__.py
curl -s "https://raw.githubusercontent.com/syfqsamvpn/iptv-panel/main/pytransform/_pytransform.so" >/root/iptv-panel/pytransform/_pytransform.so

if [ "$(grep -wc "REFF_STAT" "/root/iptv-panel/data.txt")" == '0' ]; then
    echo 'REFF_STAT = "on"                                                                        # Should be on/off (case sensitive)' >>"/root/iptv-panel/data.txt"
fi
if [ "$(grep -wc "TELEGRAM_ADMIN_ID" "/root/iptv-panel/data.txt")" == '0' ]; then
    echo 'TELEGRAM_ADMIN_ID = "input_id_tele"                                                     # telegram admin id' >>"/root/iptv-panel/data.txt"
fi
if [ "$(grep -wc "VOD_FILE" "/root/iptv-panel/data.txt")" == '0' ]; then
    echo 'VOD_FILE = "vod.m3u"                                                                    # change this to change vod' >>"/root/iptv-panel/data.txt"
    touch "/root/iptv-panel/vod.m3u"
fi
if [ "$(grep -wc "PASSWORD_SEC" "/root/iptv-panel/data.txt")" == '0' ]; then
    echo 'PASSWORD_SEC = "on"                                                                     # Should be on/off (case sensitive)' >>"/root/iptv-panel/data.txt"
fi

if [ "$(grep -wc "OFFLINE_REDIRECT" "/root/iptv-panel/data.txt")" == '0' ]; then
    echo 'OFFLINE_REDIRECT = "https://d25tgymtnqzu8s.cloudfront.net/smil:tv1/playlist.m3u8?id=1"  # Should be on/off (case sensitive)' >>"/root/iptv-panel/data.txt"
fi

if [ ! -d "/root/iptv-panel/secure/" ]; then
    mkdir -p "/root/iptv-panel/secure/"
fi

if [ ! -d "/root/iptv-panel/static/var/" ]; then
    mkdir -p "/root/iptv-panel/static/var/"
fi

if [ ! -f "/root/iptv-panel/expired.json" ]; then
    touch "/root/iptv-panel/expired.json"
    echo 'EXPIRED_DATA = "expired.json"                                                           # Expired data' >>"/root/iptv-panel/data.txt"
fi
if [ "$(grep -wc "FREEMIUM_FILE" "/root/iptv-panel/data.txt")" == '0' ]; then
    echo 'FREEMIUM_FILE = "freemium.m3u"                                                          # change this to change freemium playlist' >>"/root/iptv-panel/data.txt"
fi

if [ "$(grep -wc "SHORT_LINK" "/root/iptv-panel/data.txt")" == '0' ]; then
    echo 'SHORT_LINK = "off"                                                                      # Should be off/short_domain (case sensitive)' >>"/root/iptv-panel/data.txt"
fi

if [ "$(grep -wc "VOD_SHORT" "/root/iptv-panel/data.txt")" == '0' ]; then
    echo 'VOD_SHORT = "vod_short.json"                                                            # vod links' >>"/root/iptv-panel/data.txt"
fi
