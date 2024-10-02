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
    cat > /etc/gdm3/custom.conf << EOF
[daemon]
AutomaticLoginEnable=true
AutomaticLogin=kids
EOF
}

# Function to set Firefox preferences
set_firefox_preferences() {
    echo "Setting Firefox preferences"
    FIREFOX_PREFS="/home/kids/.mozilla/firefox/*.default/prefs.js"
    mkdir -p "$(dirname "$FIREFOX_PREFS")"
    touch "$FIREFOX_PREFS"
    echo 'user_pref("browser.startup.homepage", "http://devxt-nas01:31437");' >> "$FIREFOX_PREFS"
    echo 'user_pref("browser.startup.page", 1);' >> "$FIREFOX_PREFS"
    echo 'user_pref("browser.startup.homepage_override.mstone", "ignore");' >> "$FIREFOX_PREFS"
    chown -R kids:kids /home/kids/.mozilla
}

# Function to create a startup script for Firefox in full-screen mode
create_firefox_startup_script() {
    echo "Creating Firefox startup script"
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
    chown kids:kids /home/kids/.config/autostart/firefox-fullscreen.desktop
}

# Function to enable on-screen keyboard with voice input
enable_onscreen_keyboard() {
    echo "Enabling on-screen keyboard with voice input"
    gsettings set org.gnome.desktop.a11y.applications screen-keyboard-enabled true
    gsettings set org.gnome.desktop.a11y.applications screen-reader-enabled true
    
    # Install onboard (on-screen keyboard) and speech-dispatcher (for voice input)
    apt-get update
    apt-get install -y onboard speech-dispatcher
    
    # Create autostart entry for onboard
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
    chown kids:kids /home/kids/.config/autostart/onboard.desktop
}

# Main script execution
check_sudo
create_kids_user
configure_auto_login
set_firefox_preferences
create_firefox_startup_script
enable_onscreen_keyboard

echo "Setup complete. Please reboot the system to apply changes."