
1. Install Terraform cli
2. Configure Terraform Mirror for Terraform Registry if you need.


3. Export secret variable
```bash
  export TF_VAR_tf_ssh_key='{ public_key="public key", private_key_b64="base64 private key without line break" }'
  export TF_VAR_ssh_public_key="ssh-rsa base64_data user@host-name"
  export TF_VAR_registry='{ key="AA-BB-CC", email="my_name@my-domain.com" }'
  export TF_VAR_vsphere_credetial='{ user="administrator", password="password", server="vsphere.stend.test" }'
  export TF_VAR_password="linux"
```
4. Run
```bash
cd ./tf
terraform -chdir=./template init
terraform -chdir=./template plan -var-file ../your.tfvars
terraform -chdir=./template apply -auto-approve -var-file ../your.tfvars
```
5. Wait creating VM and automatic switch off.
6. Run
```bash
cd ./tf
mkdir rancher/files/
touch rancher/files/salt.zip
terraform -chdir=./rancher init
terraform -chdir=./rancher plan -var-file ../your.tfvars
terraform -chdir=./rancher apply -auto-approve -var-file ../your.tfvars
```

7. on router run
```bash
sudo mkdir -p /srv/salt/rke2/

sudo curl -L https://github.com/rancher/rke2/releases/download/v1.24.2%2Brke2r/rke2.linux-amd64.tar.gz --output /srv/salt/rke2/rke2.linux-amd64.tar.gz

sudo salt-cp -G "roles:rancher" --chunked --no-compression /srv/salt/rke2/rke2.linux-amd64.tar.gz /tmp/
sudo salt -G "roles:rancher" cmd.run 'tar xzf "/tmp/rke2.linux-amd64.tar.gz" -C "/usr/local"'
sudo salt -G "roles:rancher" cmd.run 'mkdir -p /etc/rancher/rke2'
sudo salt -C "G@roles:rancher and *-0" test.ping
sudo salt -C "G@roles:rancher and *-0" cmd.run 'systemctl enable rke2-server --now'

RKE2_SERVER="192.168.14.21"
RKE2_TOKEN=$(sudo salt -C "G@roles:rancher and *-0" cmd.run "cat /var/lib/rancher/rke2/server/node-token" | tail -1 | sed "s/^\s*\(.*\)/\\1/")

sudo cat  <<EOF > /tmp/config.yaml
server: https://${RKE2_SERVER}:9345
token: ${RKE2_TOKEN}
EOF

sudo salt-cp -G "roles:rancher" /tmp/config.yaml /etc/rancher/rke2/config.yaml

sudo salt -C "G@roles:rancher" cmd.run 'systemctl enable rke2-server --now'
```

```bash
curl -L https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl -o ~/bin/kubectl
chmod +x ~/bin/kubectl

scp 192.168.14.21:/etc/rancher/rke2/rke2.yaml kubeconfig-rancher.yaml
sed -i 's/127.0.0.1/192.168.14.21/' ./kubeconfig-rancher.yaml
export KUBECONFIG=~/kubeconfig-rancher.yaml

curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
sudo ./get_helm.sh -v v3.9.4

kubectl create namespace cert-manager
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.7.1/cert-manager.crds.yaml
helm repo add jetstack https://charts.jetstack.io
helm repo update
helm install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --version v1.7.1



helm repo add rancher-stable https://releases.rancher.com/server-charts/stable


kubectl create namespace cattle-system

helm install rancher rancher-stable/rancher \
  --namespace cattle-system \
  --set hostname=192.168.14.21.sslip.io \
  --version 2.6.8
```













## 

- [Main](#main)
    - [Using as standalone Terraform configuration](#using-as-standalone-terraform-configuration)


# Main

https://helm.sh/docs/topics/version_skew/

## Using as standalone Terraform configuration

The configuration is done through Terraform variables. Example *tfvars* file is part of this repo and is named `example.tfvars`. Change the variables to match your environment / requirements before running `terraform apply ...`.

| Option | Explanation | Example |
|--------|-------------|---------|
|**vsphere_environment**|vSphere Environment Object|-|
|datacenter|Name of the Data Center|DC01_Local|
|datastore|Name of the Data Store|vhost01_Datastore_02|
|cluster|Name of the Cluster|Cluster|
|#pool|Name of the Pool *if you use them*|Office|
|host|Name of the Host|172.29.192.21|
|dvs|Name of the Distributed Virtual Switch for the stand|DSwitch 01|
|dpg|Name of the Distributed Port Group|DPG_PZhukov_Ranchers_TF_LAB_VLAN1302|
|dpg_vlan_id|VLAN ID|1302|
|wan|Name of the Distributed Virtual Switch for WAN|DPG_Zhukov_Lab_VLAN13|
|folder|Name of the Folder|PZhukov/pzhukov-rancher-tf|

