# Download and install nvm:
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
# in lieu of restarting the shell
\. "$HOME/.nvm/nvm.sh"
# Download and install Node.js:
nvm install latest
# Verify the Node.js version:
node -v # Should print "v24.13.0".
# Verify npm version:
npm -v # Should print "11.6.2".
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
\. "$HOME/.nvm/nvm.sh"
# Install xrdp to allow remote sessions via remote desktop
sudo apt install lubuntu-desktop
vi ~/.xsession
chmod +x ~/.xsession
sudo systemctl restart xrdp
systemctl status xrdp
# Get the host IP for rdp
ip a
# Restart the VM
exit

# Install neovim
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz && sudo rm -rf /opt/nvim-linux-x86_64 && sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz
nviminterpreter
# Install LazyVim
git clone https://github.com/LazyVim/starter ~/.config/nvim
rm -rf ~/.config/nvim/.git
# Add export PATH="$PATH:/opt/nvim-linux-x86_64/bin" to bashrc
# Install lazyvim dependencies
sudo apt install ripgrep lua5.4 liblua5.4-dev
npm install --global @ast-grep/cli
wget https://luarocks.org/releases/luarocks-3.13.0.tar.gz
tar zxpf luarocks-3.13.0.tar.gz
cd luarocks-3.13.0
./configure && make && sudo make install
cd
# Install Docker. Please look at the documentation to know the exact commands, including EOF script
sudo apt update
sudo apt install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
#sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo systemctl status docker
# Install mcp-gateway
# Clone the repository
git clone https://github.com/docker/mcp-gateway.git
cd mcp-gateway
mkdir -p "$HOME/.docker/cli-plugins/"
make docker-mcp
# Install go, which is required for compiling docker-mcp
sudo apt update
sudo apt install golang
sudo apt install make
make docker-mcp
# Save the current compose.yml and create a new one for docker-mcp.
# The current compose.yml is in the github repo
mv compose.yml compose.yml.bkp
nvim compose.yml
# Add user to docker group
sudo useradd docker
sudo usermod -aG docker $USER
docker compose up
