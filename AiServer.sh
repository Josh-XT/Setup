#!/bin/bash
echo "alias update='sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y && sudo snap refresh'" >> ~/.bashrc
sudo timedatectl set-timezone America/New_York
sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y
sudo apt remove docker docker-engine docker.io containerd runc -y
sudo apt update
sudo apt install ca-certificates curl gnupg lsb-release -y
mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io docker-compose -y
sudo service docker start
sudo apt install python3-full python3-pip -y
sudo snap install powershell --classic
git clone https://github.com/Josh-XT/AGiXT
git clone https://github.com/DevXT-LLC/ezlocalai
cd AGiXT
if [[ ! -f ".env" ]]; then
    clear
    echo "${BOLD}${CYAN}"
    echo "    ___   _______ _  ________"
    echo "   /   | / ____(_) |/ /_  __/"
    echo "  / /| |/ / __/ /|   / / /   "
    echo " / ___ / /_/ / //   | / /    "
    echo "/_/  |_\____/_//_/|_|/_/     "
    echo "                              "
    echo "----------------------------------------------------${RESET}"
    echo "${BOLD}${MAGENTA}Visit our documentation at https://AGiXT.com ${RESET}"
    echo "${BOLD}${MAGENTA}Welcome to the AGiXT and ezLocalai Environment Setup!${RESET}"
    read -p "Set your AGiXT and ezLocalai API key (default: None): " api_key
    read -p "Set your AGiXT URI (default: http://localhost:7437): " agixt_uri
    read -p "Set your ezLocalai URI (default: http://localhost:8091): " ezlocalai_uri
    read -p "Use experimental AGiXT database? (default: No, Y/N): " db
    if [[ "$agixt_uri" == "" ]]; then
        agixt_uri="http://localhost:7437"
    fi
    if [[ "$ezlocalai_uri" == "" ]]; then
        ezlocalai_uri="http://localhost:8091"
    fi
    echo "AGIXT_URI=${agixt_uri:-http://localhost:7437}" >> .env
    echo "AGIXT_API_KEY=${api_key:-}" >> .env
    echo "UVICORN_WORKERS=10" >> .env
    if [[ "$db" == "Y" || "$db" == "y" || "$db" == "Yes" || "$db" == "yes" ]]; then
        echo "DB_CONNECTED=true" >> .env
        echo "DB_PASSWORD=${api_key:-postgres}" >> .env
        echo "USING_JWT=true" >> .env
    fi
    if [[ "$api_key" != "" ]]; then
        sed -i "s/EZLOCALAI_API_KEY=/EZLOCALAI_API_KEY=${api_key}/g" ../ezlocalai/.env
    fi
fi
echo "Starting AGiXT and ezLocalai, this will take several minutes..."
docker-compose -f docker-compose-dev.yml down
docker-compose -f docker-compose-dev.yml pull
docker-compose -f docker-compose-dev.yml up -d
cd ../ezlocalai
sudo pwsh start.ps1