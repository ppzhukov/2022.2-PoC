### Create Wireguard Server

sudo zypper in -y wireguard-tools

sudo bash -c 'cat > /etc/sysctl.d/90-wireguard.conf <<EOF
set net.ipv4.ip_forward=1
EOF'
sudo sysctl net.ipv4.ip_forward=1
sudo firewall-cmd --permanent --zone=public --add-port=51820/udp
sudo firewall-cmd --permanent --zone=public --add-masquerade
sudo firewall-cmd --reload
cd 
sudo wg genkey | sudo tee /etc/wireguard/wg0.key | sudo wg pubkey | sudo tee /etc/wireguard/wg0.pub
ServerPublicKey="$(sudo cat /etc/wireguard/wg0.pub)"
ServerPrivateKey="$(sudo cat /etc/wireguard/wg0.key)"
sudo bash -c "cat > /etc/wireguard/wg0.conf <<EOF
[Interface]
Address = 10.0.0.1/24
ListenPort = 51820
PrivateKey = ${ServerPrivateKey}
EOF"


### Create Wireguard Client Configuration

export client_name=rancher
export client_ip=2


sudo wg genkey | sudo tee /etc/wireguard/${client_name}.key | sudo wg pubkey | sudo tee /etc/wireguard/${client_name}.pub
ClientPSK=$(sudo wg genpsk)
ServerPublicKey="$(sudo cat /etc/wireguard/wg0.pub)"
ClientPublicKey="$(sudo cat /etc/wireguard/${client_name}.pub)"
ClientPrivateKey="$(sudo cat /etc/wireguard/${client_name}.key)"

sudo bash -c "cat > /etc/wireguard/${client_name}.conf <<EOF
[Interface]
Address = 10.2.0.${client_ip}/24
PrivateKey = ${ClientPrivateKey}

[Peer]
PublicKey = ${ServerPublicKey}
PresharedKey = ${ClientPSK}
AllowedIPs = 192.168.14.0/24
Endpoint = 172.17.13.51:51820
PersistentKeepalive = 25
EOF"

sudo bash -c "cat >> /etc/wireguard/wg0.conf <<EOF
[Peer]
PresharedKey =  ${ClientPSK}
PublicKey =  ${ClientPublicKey}
AllowedIPs = 10.2.0.${client_ip}/32
EOF"

sudo systemctl restart wg-quick@wg0
sudo wg show

### Configure Firewall

sudo firewall-cmd --zone=external --permanent --add-port=51820/tcp
sudo firewall-cmd --permanent --zone=internal --add-interface=wg0
sudo systemctl restart firewalld
