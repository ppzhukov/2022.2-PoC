data "vsphere_datacenter" "dc" {
  name = var.stend_environment.datacenter
}

## Deploy DPG
data "vsphere_distributed_virtual_switch" "dvs" {
  name          = var.stend_environment.dvs
  datacenter_id = data.vsphere_datacenter.dc.id
}

resource "vsphere_distributed_port_group" "dpg" {
name                            = var.stend_environment.dpg
distributed_virtual_switch_uuid = data.vsphere_distributed_virtual_switch.dvs.id
vlan_id                         = var.stend_environment.dpg_vlan_id
}

## Deploy Folder
resource "vsphere_folder" "folder" {
path          = "${var.stend_environment.folder}"
datacenter_id = data.vsphere_datacenter.dc.id
type          = "vm"
}
