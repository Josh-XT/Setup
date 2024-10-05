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
        echo "Existing 'kids' user found. Preparing for removal..."
        
        # Kill all processes owned by the 'kids' user
        pkill -u kids
        
        # Wait a moment to ensure processes are terminated
        sleep 2
        
        # Force logout of 'kids' user if logged in
        pkill -KILL -u kids
        
        # Delete the user and their home directory
        echo "Deleting existing 'kids' user"
        userdel -r kids
    fi
    echo "Creating 'kids' user"
    adduser --disabled-password --gecos "" kids
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

# Function to set up Chromium
setup_chromium() {
    echo "Setting up Chromium"
    
    # Install Chromium
    apt-get update
    apt-get install -y chromium-browser

    # Define homepage
    HOMEPAGE="http://devxt-nas01:31437"

    # Create Chromium policies directory
    POLICIES_DIR="/etc/chromium-browser/policies/managed"
    mkdir -p "$POLICIES_DIR"

    # Create policy file to set homepage and other settings
    cat > "$POLICIES_DIR/kids_policy.json" << EOF
{
    "HomepageLocation": "$HOMEPAGE",
    "HomepageIsNewTabPage": false,
    "NewTabPageLocation": "$HOMEPAGE",
    "RestoreOnStartup": 4,
    "RestoreOnStartupURLs": ["$HOMEPAGE"],
    "BookmarkBarEnabled": false,
    "IncognitoModeAvailability": 1,
    "BrowserSignin": 0,
    "SyncDisabled": true,
    "SearchSuggestEnabled": false
}
EOF

    # Create autostart directory for kids user
    AUTOSTART_DIR="/home/kids/.config/autostart"
    mkdir -p "$AUTOSTART_DIR"
    chown kids:kids "$AUTOSTART_DIR"

    # Create autostart entry for Chromium in kiosk mode
    cat > "$AUTOSTART_DIR/chromium-kiosk.desktop" << EOF
[Desktop Entry]
Type=Application
Exec=chromium-browser --kiosk --no-first-run --disable-pinch --overscroll-history-navigation=0 --disable-features=TranslateUI --no-default-browser-check $HOMEPAGE
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name[en_US]=Chromium Kiosk
Name=Chromium Kiosk
Comment=Start Chromium in kiosk mode
EOF
    chown kids:kids "$AUTOSTART_DIR/chromium-kiosk.desktop"
}

# Function to modify hosts file for redirecting websites
modify_hosts_file() {
    echo "Modifying hosts file to redirect certain websites"
    
    # Define the websites to be redirected
    WEBSITES=(
        "www.youtube.com"
        "youtube.com"
        "youtu.be"
        "www.facebook.com"
        "facebook.com"
        "www.tiktok.com"
        "tiktok.com"
        # Add more websites as needed
    )
    
    # Backup the original hosts file
    cp /etc/hosts /etc/hosts.backup
    
    # Add redirects to the hosts file
    for site in "${WEBSITES[@]}"; do
        if ! grep -q "$site" /etc/hosts; then
            echo "127.0.0.1 $site" >> /etc/hosts
        fi
    done
    
    echo "Hosts file modified. Specified websites will be redirected to localhost."
}

# Function to disable Ubuntu initial setup
disable_initial_setup() {
    echo "Disabling Ubuntu initial setup"
    if [ -f /etc/xdg/autostart/gnome-initial-setup-first-login.desktop ]; then
        echo "X-GNOME-Autostart-enabled=false" >> /etc/xdg/autostart/gnome-initial-setup-first-login.desktop
    fi
    if [ -f /etc/xdg/autostart/gnome-welcome-tour.desktop ]; then
        echo "X-GNOME-Autostart-enabled=false" >> /etc/xdg/autostart/gnome-welcome-tour.desktop
    fi
}

# Function to create a script that disables Windows key and sidebar
create_disable_script() {
    echo "Creating script to disable Windows key and sidebar"
    SCRIPT_PATH="/home/kids/.config/disable_winkey_sidebar.sh"
    
    cat > "$SCRIPT_PATH" << EOF
#!/bin/bash
gsettings set org.gnome.mutter overlay-key ''
gsettings set org.gnome.shell disabled-extensions "['ubuntu-dock@ubuntu.com']"
gsettings set org.gnome.desktop.interface enable-hot-corners false
EOF
    
    chmod +x "$SCRIPT_PATH"
    chown kids:kids "$SCRIPT_PATH"

    # Add the script to autostart
    AUTOSTART_DIR="/home/kids/.config/autostart"
    mkdir -p "$AUTOSTART_DIR"
    
    cat > "$AUTOSTART_DIR/disable_winkey_sidebar.desktop" << EOF
[Desktop Entry]
Type=Application
Exec=/home/kids/.config/disable_winkey_sidebar.sh
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name[en_US]=Disable Windows Key and Sidebar
Name=Disable Windows Key and Sidebar
Comment=Disables Windows key and sidebar for kids user
EOF
    
    chown -R kids:kids "$AUTOSTART_DIR"
}

# Main script execution
check_sudo
sudo apt update --fix-missing -y && sudo apt upgrade -y
create_kids_user
configure_auto_login
setup_chromium
modify_hosts_file
disable_initial_setup
create_disable_script

echo "Setup complete. Please reboot the system to apply changes."