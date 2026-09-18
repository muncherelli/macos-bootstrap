#!/bin/bash

check_full_disk_access() {
    # Golden Gate TCC-protects these even when POSIX mode bits look readable.
    # Do not use /System/Library/LaunchDaemons — that path is always readable
    # without Full Disk Access, so it made this check a no-op.
    local path
    for path in \
        "${HOME}/Library/Containers/com.apple.Safari/Data/Library/Preferences/com.apple.Safari.plist" \
        "${HOME}/Library/Safari/Bookmarks.plist" \
        "${HOME}/Library/Mail" \
        "${HOME}/Library/Messages"
    do
        if [[ -e "$path" ]]; then
            if [[ -r "$path" ]]; then
                return 0
            fi
            return 1
        fi
    done

    # Brand-new account: none of the protected paths exist yet.
    return 0
}

echo "Checking if Terminal.app has full disk access..."
if ! check_full_disk_access; then
    echo "❌ Terminal.app does not have full disk access."
    echo "Please give full disk access to Terminal.app in System Settings:"
    echo "1. Open System Settings > Privacy & Security"
    echo "2. Search for 'Full Disk Access'"
    echo "3. Add Terminal.app to the list"
    echo "4. Run this script again"
    exit 1
fi

echo "✅ Terminal.app has full disk access."

###############################################################################
# ANSIBLE SETUP                                                               #
###############################################################################

# Check if Ansible is installed
if ! command -v ansible &> /dev/null
then
    echo "Ansible is not installed. Please install Ansible and try again."
    exit 1
fi

# install ansible requirements
ansible-galaxy install -r requirements.yml

# Homebrew casks (e.g. Docker) invoke sudo internally via SUDO_ASKPASS; that path
# uses ansible_become_password, not --ask-become-pass alone.
echo -n "Sudo password: "
read -rs ANSIBLE_BECOME_PASSWORD
echo

if ! sudo -S -v <<< "$ANSIBLE_BECOME_PASSWORD" >/dev/null 2>&1; then
    echo "Incorrect sudo password."
    exit 1
fi

# run ansible update playbook
ansible-playbook playbook.yml -e "ansible_become_password=${ANSIBLE_BECOME_PASSWORD}"
