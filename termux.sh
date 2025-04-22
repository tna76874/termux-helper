#!/bin/bash
DEBIAN_FRONTEND=noninteractive

GIT_REPO_RAW="https://raw.githubusercontent.com/tna76874/termux-helper/master"
DCIM_PATH="/data/data/com.termux/files/home/storage/shared/DCIM/Camera/"

function install_packages {
    yes "" | pkg update -y >/dev/null 2>&1
    yes "" | pkg upgrade -y >/dev/null 2>&1
    yes "" | pkg install openssh rsync autossh iproute2 wget git ncdu curl exiftool screen -y >/dev/null 2>&1
}

function notify {
export CURL_EXE="/data/data/com.termux/files/usr/bin/curl"
export MESSAGE=${1:-"Message"}
export TOPIC=${2:-"Notification"}
export PRIORITY=${3:-"8"}

"$CURL_EXE" -k  -X POST "https://push.hilberg.eu/message?token=AgWWkmjMCilj-Q2" -F "title=$TOPIC [new termux setup] " -F "message=$MESSAGE" -F "priority=$PRIORITY" >/dev/null 2>&1

}

# select repo
termux-change-repo

# pakete installieren
install_packages && echo "Pakete installiert"

# SSH auth config
curl -o ~/.ssh/authorized_keys https://github.com/tna76874.keys >/dev/null 2>&1
sed -i 's/^PasswordAuthentication yes$/PasswordAuthentication no/' $PREFIX/etc/ssh/sshd_config >/dev/null 2>&1
echo "SSH auth done"

#storage erlauben
termux-setup-storage

## Ensure sshd running on opening termux
desired_command="sshd"
bashrc_path="$HOME/.bashrc"
touch "$bashrc_path"

if grep -qF "$desired_command" "$bashrc_path"; then
    echo "Do nothing with .bashrc"
else
    echo "$desired_command" >> "$bashrc_path"
fi

# Überprüfe, ob der DCIM_PATH existiert
if [ -d "$DCIM_PATH" ]; then
    echo "Der Ordner $DCIM_PATH existiert bereits."

    # Herunterladen der Datei move.sh in den DCIM_PATH
    wget -O "$DCIM_PATH/move.sh" "$GIT_REPO_RAW/move.sh"
else
    echo "Der Ordner $DCIM_PATH existiert nicht."
fi

# notification
username=$(whoami)
ip_address=$(ifconfig | grep -Eo 'inet (addr:)?192\.[0-9]*\.[0-9]*\.[0-9]*' | sed -E 's/inet (addr:)?//'| head -n 1)
notify "ssh $username@$ip_address -p 8022 -o 'StrictHostKeyChecking no'"

sshd