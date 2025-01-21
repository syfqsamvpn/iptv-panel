#!/bin/bash

clear

# Function to install packages if not already installed
install_packages() {
    for package in "$@"; do
        if ! dpkg -s "$package" &>/dev/null; then
            apt install -y "$package"
        fi
    done
}

# Function to install Python packages
install_python_packages() {
    for package in "$@"; do
        pip3 install "$package"
    done
}

# Function to create directories and files if not exist
ensure_dir_and_files() {
    local dir="$1"
    shift
    [[ ! -d "$dir" ]] && mkdir -p "$dir"
    for file in "$@"; do
        [[ ! -f "$dir/$file" ]] && touch "$dir/$file"
    done
}

# Function to download files
download_file() {
    local url="$1"
    local dest="$2"
    curl -s "$url" -o "$dest"
}

# Install necessary packages
install_packages vnstat bc

# Install necessary Python packages
install_python_packages pycryptodome flask_cors Flask[async] Flask-Limiter flask_limiter

# Ensure required directories and files exist
ensure_dir_and_files "/root/iptv-panel/templates"
ensure_dir_and_files "/root/iptv-panel/module"
ensure_dir_and_files "/root/iptv-panel/banned" "banned_userid.txt" "banned_ip.txt" "banned_useragent.txt"
ensure_dir_and_files "/root/enc" "pytransform"

# Download specific files
download_file "https://raw.githubusercontent.com/syfqsamvpn/iptv-panel/main/templates/reseller_users.html" "/root/iptv-panel/templates/reseller_users.html"
download_file "https://raw.githubusercontent.com/syfqsamvpn/iptv-panel/main/menu.sh" "/usr/bin/menu" && chmod +x /usr/bin/menu
download_file "https://raw.githubusercontent.com/syfqsamvpn/iptv-panel/main/start_bot.sh" "/usr/bin/start_bot.sh" && chmod +x /usr/bin/start_bot.sh

# Check Debian version and download specific files accordingly
if [[ "$(grep -o 'VERSION_ID="[^"]*' /etc/os-release | grep -o '[^"]*$')" == "10" ]]; then
    echo "Please Upgrade to DEBIAN 11"
    exit 0
else
    BASE_URL="https://raw.githubusercontent.com/syfqsamvpn/iptv-panel/main"
    DEST_DIR="/root/iptv-panel"
    FILES=(
        "pytransform/__init__.py"
        "pytransform/_pytransform.so"
        "main.py"
        "reseller.py"
        "sam_secure.py"
        "vod.py"
        "module/__init__.py"
        "module/system_ott.py"
        "module/sam_enc.py"
    )
    for file in "${FILES[@]}"; do
        mkdir -p "$DEST_DIR/$(dirname "$file")" # Ensure target directory exists
        download_file "$BASE_URL/$file" "$DEST_DIR/$file"
    done
fi

# Download guardian script
download_file "http://api.samhub.my.id/enc/guardian.sh" "/root/enc/guardian.sh" && chmod +x /root/enc/guardian.sh

# Ensure data.txt has required configurations
DATA_FILE="/root/iptv-panel/data.txt"
declare -A CONFIGS=(
    ["REFF_STAT"]='REFF_STAT = "on"                                                                        # Should be on/off (case sensitive)'
    ["TELEGRAM_ADMIN_ID"]='TELEGRAM_ADMIN_ID = "input_id_tele"                                             # telegram admin id'
    ["VOD_FILE"]='VOD_FILE = "vod.m3u"                                                                    # change this to change vod'
    ["PASSWORD_SEC"]='PASSWORD_SEC = "on"                                                                 # Should be on/off (case sensitive)'
    ["OFFLINE_REDIRECT"]='OFFLINE_REDIRECT = "https://d25tgymtnqzu8s.cloudfront.net/smil:tv1/playlist.m3u8?id=1"  # Redirect link'
    ["FREEMIUM_FILE"]='FREEMIUM_FILE = "freemium.m3u"                                                     # change this to change freemium playlist'
    ["SHORT_LINK"]='SHORT_LINK = "off"                                                                    # Should be off/short_domain (case sensitive)'
    ["VOD_SHORT"]='VOD_SHORT = "vod_short.json"                                                           # vod links'
    ["BUYOTT_FILE"]='BUYOTT_FILE = "buy_ott.m3u"                                                          # change this to change buy ott playlist'
)
for key in "${!CONFIGS[@]}"; do
    if ! grep -qw "$key" "$DATA_FILE"; then
        echo "${CONFIGS[$key]}" >>"$DATA_FILE"
    fi
done

# Additional directories and files
ensure_dir_and_files "/root/iptv-panel/secure"
ensure_dir_and_files "/root/iptv-panel/static/var"
[[ ! -f "/root/iptv-panel/expired.json" ]] && touch "/root/iptv-panel/expired.json" && echo 'EXPIRED_DATA = "expired.json" # Expired data' >>"$DATA_FILE"
[[ ! -f "/root/iptv-panel/vod.m3u" ]] && touch "/root/iptv-panel/vod.m3u"
