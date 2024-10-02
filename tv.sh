#!/bin/bash

# Function to check if the script is run with sudo privileges
check_sudo() {
    if [ "$EUID" -ne 0 ]; then
        echo "Please run this script with sudo privileges"
        exit 1
    fi
}

# Function to create the "kids" user if it doesn't exist
create_kids_user() {
    if id "kids" &>/dev/null; then
        echo "User 'kids' already exists"
    else
        echo "Creating 'kids' user"
        adduser --disabled-password --gecos "" kids
    fi
}

# Function to configure auto-login for the "kids" user
configure_auto_login() {
    echo "Configuring auto-login for 'kids' user"
    if [ -f /etc/gdm3/custom.conf ]; then
        sed -i '/AutomaticLoginEnable/d' /etc/gdm3/custom.conf
        sed -i '/AutomaticLogin/d' /etc/gdm3/custom.conf
        sed -i '/\[daemon\]/a AutomaticLoginEnable=true\nAutomaticLogin=kids' /etc/gdm3/custom.conf
    else
        echo "[daemon]" > /etc/gdm3/custom.conf
        echo "AutomaticLoginEnable=true" >> /etc/gdm3/custom.conf
        echo "AutomaticLogin=kids" >> /etc/gdm3/custom.conf
    fi
}

# Function to set Firefox preferences
set_firefox_preferences() {
    echo "Setting Firefox preferences"
    FIREFOX_DIR="/home/kids/.mozilla/firefox"
    mkdir -p "$FIREFOX_DIR"
    if [ ! -d "$FIREFOX_DIR"/*.default ]; then
        PROFILE_DIR="$FIREFOX_DIR/profile.default"
        mkdir -p "$PROFILE_DIR"
    else
        PROFILE_DIR=$(find "$FIREFOX_DIR" -maxdepth 1 -type d -name "*.default" | head -n 1)
    fi
    PREFS_FILE="$PROFILE_DIR/prefs.js"
    touch "$PREFS_FILE"
    echo 'user_pref("browser.startup.homepage", "http://devxt-nas01:31437");' >> "$PREFS_FILE"
    echo 'user_pref("browser.startup.page", 1);' >> "$PREFS_FILE"
    echo 'user_pref("browser.startup.homepage_override.mstone", "ignore");' >> "$PREFS_FILE"
    chown -R kids:kids "$FIREFOX_DIR"
}

# Function to create a startup script for Firefox in full-screen mode
create_firefox_startup_script() {
    echo "Creating Firefox startup script"
    mkdir -p /home/kids/.config/autostart
    cat > /home/kids/.config/autostart/firefox-fullscreen.desktop << EOF
[Desktop Entry]
Type=Application
Exec=firefox --kiosk
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name[en_US]=Firefox Fullscreen
Name=Firefox Fullscreen
Comment[en_US]=Start Firefox in fullscreen mode
Comment=Start Firefox in fullscreen mode
EOF
    chown -R kids:kids /home/kids/.config
}

# Function to enable on-screen keyboard with voice input
enable_onscreen_keyboard() {
    echo "Enabling on-screen keyboard with voice input"
    if command -v gsettings &> /dev/null; then
        gsettings set org.gnome.desktop.a11y.applications screen-keyboard-enabled true
        gsettings set org.gnome.desktop.a11y.applications screen-reader-enabled true
    else
        echo "gsettings command not found. Skipping GNOME settings."
    fi
    
    # Install onboard (on-screen keyboard) and speech-dispatcher (for voice input)
    apt-get update
    apt-get install -y onboard speech-dispatcher
    
    # Create autostart entry for onboard
    mkdir -p /home/kids/.config/autostart
    cat > /home/kids/.config/autostart/onboard.desktop << EOF
[Desktop Entry]
Type=Application
Exec=onboard
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name[en_US]=Onboard
Name=Onboard
Comment[en_US]=Start Onboard on-screen keyboard
Comment=Start Onboard on-screen keyboard
EOF
    chown -R kids:kids /home/kids/.config
}

# Main script execution
check_sudo
create_kids_user
configure_auto_login
set_firefox_preferences
create_firefox_startup_script
enable_onscreen_keyboard

echo "Setup complete. Please reboot the system to apply changes."