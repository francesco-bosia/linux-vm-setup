# Setup Machine

## User Information

```bash
whoami
id
lsb_release -a || cat /etc/os-release
ip a | sed -n '1,120p'
sudo -n true && echo "Passwordless sudo: YES" || echo "Passwordless sudo: NO (or needs password)"
```

---

## Cloud-Init: Check Passwordless sudo

Important when created with cloud-init:  
Check `/etc/sudoers` and `/etc/sudoers.d/` if the user is granted passwordless sudo.

Example in `/etc/sudoers.d/90-cloud-init-users`:

```
username ALL=(ALL) NOPASSWD: ALL
```

Needs to be adapted with visudo to ask for password:

```bash
sudo visudo -f /etc/sudoers.d/90-cloud-init-users
```

Change to:

```
kai ALL=(ALL) ALL
```

If the password is not known, SSH into the device as root and use:

```bash
passwd kai
```

If there is no sudo or non-root user yet:

```bash
adduser username
usermod -aG sudo username
```

Verify:

```bash
sudo whoami        # should return root
groups $USER       # should show sudo
```

If sudo is not installed:

```bash
apt update && apt install sudo -y
```

---

## Base System Update

```bash
sudo apt update
sudo apt full-upgrade -y
sudo apt install -y curl vim git ufw fail2ban unattended-upgrades apt-listchanges
sudo reboot
```

---

## Enable Unattended Upgrades

```bash
dpkg-reconfigure --priority=low unattended-upgrades
```

---

## SSH Hardening

Create configuration:

```bash
sudo vim /etc/ssh/sshd_config.d/99-bastion.conf
```

Content (adjust if needed per VM):

```
# Keys only, no passwords
PasswordAuthentication no
KbdInteractiveAuthentication no
ChallengeResponseAuthentication no
PubkeyAuthentication yes

# No root SSH
PermitRootLogin no

# Reduce attack surface
Subsystem sftp internal-sftp

# Optional MACs/KEX (leave defaults if unsure)
# MACs hmac-sha2-512,hmac-sha2-256
# KexAlgorithms curve25519-sha256,curve25519-sha256@libssh.org

# Optional: limit to specific users
# AllowUsers kai bastion

# Slightly stricter login behaviour
LoginGraceTime 20
MaxAuthTries 3
MaxSessions 5
```

Disable local password login (optional):

```bash
sudo passwd -l kai
```

Disable SSH completely  
(only in PVE guests that can be reached through alternative means  
or if Tailscale has proven to work):

```bash
systemctl disable --now ssh
```

---

## Firewall – Restrict SSH

Block port 22 on Ethernet/Wi-Fi and allow it only on the tailscale0 interface.  
Configuration can be adapted but must be documented.

```bash
# Reset UFW and set sane defaults
sudo ufw --force reset
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Allow inbound SSH only from Tailscale
# sudo ufw allow in on tailscale0 to any port 22 proto tcp

# Allow local SSH (can be changed/hardened later)
sudo ufw allow OpenSSH

# Optional: allow LAN temporarily
# sudo ufw allow from 192.168.0.0/16 to any port 22 proto tcp

# Allow Tailscale UDP traffic (WireGuard)
sudo ufw allow 41641/udp
