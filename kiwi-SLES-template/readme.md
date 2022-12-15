# KIWI VMware vSphere SLES template
Use current file or:
1. Install kiwi.
```bash
sudo SUSEConnect --product sle-module-desktop-applications/15.4/x86_64
sudo SUSEConnect --product sle-module-development-tools/15.4/x86_64
sudo zypper install -y python3-kiwi
sudo zypper in -y kiwi-templates-Minimal
```
4. Download SUSE SLES 15SP4 full iso.
```
SLE-15-SP4-Full-x86_64-GM-Media1.iso
```
5. Make directory /media/suse
```bash
sudo mkdir -p /media/suse
```
6. Mount the iso to the directory.
```bash
sudo mount SLE-15-SP4-Full-x86_64-GM-Media1.iso /media/suse/
```
7. Run below command for for create images:
```bash
sudo kiwi-ng  --profile VMware system build --description ./kiwi-SLES-template/ --target-dir /tmp/out
```
8. Run below command to copy image to ../tf/template/files/
```bash
cp /tmp/out/SLES15-SP4-Minimal-Rancher.x86_64-15.4.0.vmdk ./tf/template/files/
```