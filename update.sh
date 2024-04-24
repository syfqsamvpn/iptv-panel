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
curl -s "https://raw.githubusercontent.com/syfqsamvpn/iptv-panel/main/ott_sam.sh" >/usr/bin/ott_sam.sh && chmod +x /usr/bin/ott_sam.sh
curl -s "https://raw.githubusercontent.com/syfqsamvpn/iptv-panel/main/main.py" >/root/iptv-panel/main.py
curl -s "https://raw.githubusercontent.com/syfqsamvpn/iptv-panel/main/system_ott.py" >/root/iptv-panel/system_ott.py
curl -s "https://raw.githubusercontent.com/syfqsamvpn/iptv-panel/main/reseller.py" >/root/iptv-panel/reseller.py
curl -s "https://raw.githubusercontent.com/syfqsamvpn/iptv-panel/main/pytransform/__init__.py" >/root/iptv-panel/pytransform/__init__.py
curl -s "https://raw.githubusercontent.com/syfqsamvpn/iptv-panel/main/pytransform/_pytransform.so" >/root/iptv-panel/pytransform/_pytransform.so
