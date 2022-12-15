data "vsphere_datacenter" "dc" {
  name = var.vsphere_environment.datacenter
}

data "vsphere_compute_cluster" "cluster" {
  name          = var.vsphere_environment.cluster
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_datastore" "datastore" {
  name          = var.vsphere_environment.datastore
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_host" "host" {
  name          = var.vsphere_environment.host
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_distributed_virtual_switch" "dvs" {
  name          = var.vsphere_environment.dvs
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "wan" {
  name          = var.vsphere_environment.wan
  datacenter_id = data.vsphere_datacenter.dc.id
}
