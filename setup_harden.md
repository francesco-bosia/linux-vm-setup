## Setup machine

### Info over user

whoami
id
lsb_release -a || cat /etc/os-release
ip a | sed -n '1,120p'
sudo -n true && echo "Passwordless sudo: YES" || echo "Passwordless sudo: NO (or needs password)"



Important when created with cloud init:
check /etc/sudoers and /etc/sudoers.d/ if user is granted passwordless sudo
e.g. in /etc/sudoers.d/90-cloud-init-users
Plain Text
username ALL=(ALL) NOPASSWD: ALL


needs to be adapted with visudo to ask for PW
Plain Text
sudo visudo -f /etc/sudoers.d/90-cloud-init-users


change to kai ALL=(ALL) PASSWD: ALL
if password not know, ssh into the device as root and use passwd kai (kai is user with the pw to be changed)
if there is no sudo or non-root user yet:
if sudo is not installed
add user with adduser username
add user to sudo group with usermod -aG sudo username
sudo whoami should now return root and groups $USER should also show sudo
apt update && apt install sudo -y
run
sudo apt update && sudo apt full-upgrade -ysudo apt install -y curl vim git ufw fail2ban unattended-upgrades apt-listchangessudo reboot
enable unattended upgrades
dpkg-reconfigure --priority=low unattended-upgrades
add sudo vim /etc/ssh/sshd_config.d/99-bastion.conf with content
change settings if needed (according to needs and document for each VM)
Plain Text
# Keys only, no passwordsPasswordAuthentication no
KbdInteractiveAuthentication no
ChallengeResponseAuthentication no
PubkeyAuthentication yes# No root SSHPermitRootLogin no
# Reduce attack surface (adjust if you actively use sftp/scp)Subsystem sftp internal-sftp
# Modern-ish MACs/KEX (leave defaults if unsure)#MACs hmac-sha2-512,hmac-sha2-256#KexAlgorithms curve25519-sha256,curve25519-sha256@libssh.org# Optional: limit to specific users#AllowUsers kai bastion# Slightly stricter login behaviourLoginGraceTime 20MaxAuthTries 3MaxSessions 5


disable pw login sudo passwd -l kai
disable ssh (only in pve guests that can be reached through alternative means or if tailscale has proven to work)
Shell
systemctl disable --now ssh


block port 22 on Ethernet/Wi-Fi and allow it only on the tailscale0 interface
configuration can be adapted but must be documented
Plain Text
# Reset UFW and set sane defaultssudo ufw --force resetsudo ufw default deny incomingsudo ufw default allow outgoing
# Allow inbound SSH *only* from Tailscale#sudo ufw allow in on tailscale0 to any port 22 proto tcp# Allow local SSH (can be changed/hardened later)sudo ufw allow OpenSSH
# Optional: if you want LAN SSH temporarily, allow your LAN (edit CIDR)# sudo ufw allow from 192.168.0.0/16 to any port 22 proto tcp# Allow Tailscale’s own UDP traffic (WireGuard over UDP 41641)sudo ufw allow 41641/udp
sudo ufw enablesudo ufw status verbose


setup fail2ban (works for tailscale ssh too) sudo vim /etc/fail2ban/jail.local add
Plain Text
[DEFAULT]bantime = 30m
findtime = 10m
maxretry = 5backend = systemd
[sshd]enabled = trueport    = sshlogpath = %(sshd_log)s
 


enable
Shell
sudo systemctl enable --now fail2bansudo fail2ban-client status sshd


persistent journal
Shell
sudo mkdir -p /var/log/journalsudo systemd-tmpfiles --create --prefix /var/log/journalsudo systemctl restart systemd-journald


Not security-relevant change
foot does not render well if ssh host has not set the right TERM
add the following to ~/.bashrc
Plain Text
export TERM=xterm
