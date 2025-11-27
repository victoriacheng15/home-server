#!/usr/bin/env bash
set -euo pipefail

info()  { echo "[setup] $*"; }
error() { echo "[setup] ERROR: $*" >&2; exit 1; }

main() {
    # Update and upgrade system packages
    info "Updating system packages..."
    sudo apt update && sudo apt upgrade -y

    # Install essential tools
    info "Installing essential tools..."
    sudo apt install -y btop samba

    info "Setup complete."
    info "Next steps:"
    info "  - Run './create_volume.sh' to create Docker volumes"
    info "  - Configure Samba using instructions at the end of this file (search 'SAMBA SETUP')"
    info "  - Run 'make up' to start your Docker services"
    info "  - Launch 'btop' in terminal for live system monitoring"
}

main "$@"

# === SAMBA SETUP INSTRUCTIONS (SECURE & RECOMMENDED) ===
# This config uses 'root:sambashare' for safe, authenticated sharing.
# Run these steps AFTER this script finishes:
#
# 1. Create the shared directory (if not exists):
#      sudo mkdir -p /srv/shared
#
# 2. Create the 'sambashare' group and add your user (replace 'youruser'):
# Note: youruser is the Linux username you log in with
#      sudo groupadd -f sambashare
#      sudo usermod -aG sambashare youruser
#
# 3. Set secure ownership & permissions:
#      sudo chown root:sambashare /srv/shared
#      sudo chmod 2775 /srv/shared    # setgid: new files inherit group
#
# 4. Set a Samba password for your user (required!):
#      sudo smbpasswd -a youruser
#
# 5. Edit Samba config:
#      sudo nano /etc/samba/smb.conf
#
#    Add this share section at the BOTTOM of the file:
#      [shared]
#        path = /srv/shared
#        browseable = yes
#        writable = yes
#        guest ok = no                # ← no anonymous access
#        valid users = @sambashare    # ← only group members
#        force create mode = 0664
#        force directory mode = 2775
#
# 6. Restart Samba:
#      sudo systemctl restart smbd nmbd
#
# 7. (Optional) Allow through firewall:
#      sudo ufw allow samba
#
# ✅ Now connect from another device:
#    - Windows:     \\[server-ip]\shared
#    - macOS:       smb://[server-ip]/shared
#    - Linux:       smb://[server-ip]/shared
#    → Log in with your Linux username & Samba password