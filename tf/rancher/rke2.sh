sudo mkdir -p /srv/salt/rke2/

sudo curl -L https://github.com/rancher/rke2/releases/download/v1.24.12%2Brke2r1/rke2.linux-amd64.tar.gz --output /srv/salt/rke2/rke2.linux-amd64.tar.gz

sudo /usr/bin/salt-cp -G "roles:rancher" --chunked --no-compression /srv/salt/rke2/rke2.linux-amd64.tar.gz /tmp/
sudo /usr/bin/salt -G "roles:rancher" cmd.run 'tar xzf "/tmp/rke2.linux-amd64.tar.gz" -C "/usr/local"'
sudo /usr/bin/salt -G "roles:rancher" cmd.run 'mkdir -p /etc/rancher/rke2'
sudo /usr/bin/salt -C "G@roles:rancher and *-0" test.ping
sudo /usr/bin/salt -C "G@roles:rancher and *-0" cmd.run 'systemctl enable rke2-server --now'

RKE2_SERVER="192.168.14.21"
RKE2_TOKEN=$(sudo /usr/bin/salt -C "G@roles:rancher and *-0" cmd.run "cat /var/lib/rancher/rke2/server/node-token" | tail -1 | sed "s/^\s*\(.*\)/\\1/")

sudo cat  <<EOF > /tmp/config.yaml
server: https://${RKE2_SERVER}:9345
token: ${RKE2_TOKEN}
EOF

sudo /usr/bin/salt-cp -G "roles:rancher" /tmp/config.yaml /etc/rancher/rke2/config.yaml

sudo /usr/bin/salt -C "G@roles:rancher" cmd.run 'systemctl enable rke2-server --now'

KUBECONFIGDATA=$(sudo /usr/bin/salt -C "G@roles:rancher and *-0" cmd.run "cat /etc/rancher/rke2/rke2.yaml")
echo $KUBECONFIGDATA > /home/geeko/kubeconfig-rancher.yaml