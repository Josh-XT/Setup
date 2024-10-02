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

# Updated function to set Firefox preferences
set_firefox_preferences() {
    echo "Setting Firefox preferences"
    FIREFOX_DIR="/home/kids/.mozilla/firefox"
    mkdir -p "$FIREFOX_DIR"
    chown kids:kids "$FIREFOX_DIR"
    
    # Create a new Firefox profile
    PROFILE_NAME="kids_profile"
    sudo -u kids firefox -CreateProfile "$PROFILE_NAME $FIREFOX_DIR/$PROFILE_NAME"
    
    PROFILE_DIR="$FIREFOX_DIR/$PROFILE_NAME"
    PREFS_FILE="$PROFILE_DIR/prefs.js"
    USER_JS_FILE="$PROFILE_DIR/user.js"
    
    # Define homepage
    HOMEPAGE="http://devxt-nas01:31437"
    
    # Create user.js file to override default preferences
    cat > "$USER_JS_FILE" << EOF
user_pref("browser.startup.homepage", "$HOMEPAGE");
user_pref("browser.startup.page", 1);
user_pref("browser.startup.homepage_override.mstone", "ignore");
user_pref("browser.newtabpage.enabled", false);
user_pref("browser.startup.firstrunSkipsHomepage", false);
user_pref("trailhead.firstrun.didSeeAboutWelcome", true);
user_pref("browser.shell.checkDefaultBrowser", false);
user_pref("datareporting.policy.dataSubmissionEnabled", false);
user_pref("browser.newtabpage.activity-stream.showSponsoredTopSites", false);
user_pref("browser.uitour.enabled", false);
EOF
    chown kids:kids "$USER_JS_FILE"
    
    # Append to prefs.js file as well
    echo "user_pref(\"browser.startup.homepage\", \"$HOMEPAGE\");" >> "$PREFS_FILE"
    chown kids:kids "$PREFS_FILE"
    
    # Create a policies.json file for system-wide Firefox policies
    POLICIES_DIR="/usr/lib/firefox/distribution"
    mkdir -p "$POLICIES_DIR"
    cat > "$POLICIES_DIR/policies.json" << EOF
{
  "policies": {
    "Homepage": {
      "URL": "$HOMEPAGE",
      "Locked": true,
      "Additional": [""]
    },
    "NewTabPage": false
  }
}
EOF
    
    # Update Firefox desktop file to use the new profile
    DESKTOP_FILE="/usr/share/applications/firefox.desktop"
    if [ -f "$DESKTOP_FILE" ]; then
        sed -i "s|Exec=firefox %u|Exec=firefox -P $PROFILE_NAME %u|" "$DESKTOP_FILE"
    else
        echo "Firefox desktop file not found at $DESKTOP_FILE"
    fi
    
    # Update the Firefox autostart file
    AUTOSTART_DIR="/home/kids/.config/autostart"
    mkdir -p "$AUTOSTART_DIR"
    chown kids:kids "$AUTOSTART_DIR"
    AUTOSTART_FILE="$AUTOSTART_DIR/firefox-fullscreen.desktop"
    cat > "$AUTOSTART_FILE" << EOF
[Desktop Entry]
Type=Application
Exec=firefox -P $PROFILE_NAME --kiosk $HOMEPAGE
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name[en_US]=Firefox Fullscreen
Name=Firefox Fullscreen
Comment[en_US]=Start Firefox in fullscreen mode
Comment=Start Firefox in fullscreen mode
EOF
    chown kids:kids "$AUTOSTART_FILE"
}

# Function to enable on-screen keyboard with voice input
enable_onscreen_keyboard() {
    echo "Enabling on-screen keyboard with voice input"
    if command -v gsettings &> /dev/null; then
        sudo -u kids gsettings set org.gnome.desktop.a11y.applications screen-keyboard-enabled true
        sudo -u kids gsettings set org.gnome.desktop.a11y.applications screen-reader-enabled true
    else
        echo "gsettings command not found. Skipping GNOME settings."
    fi
    
    # Install onboard (on-screen keyboard) and speech-dispatcher (for voice input)
    apt-get update
    apt-get install -y onboard speech-dispatcher
    
    # Create autostart entry for onboard
    AUTOSTART_DIR="/home/kids/.config/autostart"
    mkdir -p "$AUTOSTART_DIR"
    chown kids:kids "$AUTOSTART_DIR"
    cat > "$AUTOSTART_DIR/onboard.desktop" << EOF
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
    chown kids:kids "$AUTOSTART_DIR/onboard.desktop"
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

# Main script execution
check_sudo
create_kids_user
configure_auto_login
set_firefox_preferences
enable_onscreen_keyboard
modify_hosts_file

echo "Setup complete. Please reboot the system to apply changes."