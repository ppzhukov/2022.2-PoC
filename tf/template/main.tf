provider "vsphere" {
  vsphere_server = var.vsphere_credetial.server
  user           = var.vsphere_credetial.user
  password       = var.vsphere_credetial.password
  # If you have a self-signed cert
  allow_unverified_ssl = true
}

module "get_ids" {
    source        = "../terraform-vsphere-vaquero-modules/get_ids"
    vsphere_environment = var.vsphere_environment
}

data "vsphere_network" "network" {
  name          = var.template.network_name
  datacenter_id = module.get_ids.vsphere_ids.datacenter_id
}

## Create template
resource "vsphere_file" "sles_vmdk_upload" {
  datacenter         = var.vsphere_environment.datacenter
  datastore          = var.vsphere_environment.datastore
  source_file        = "${path.module}/files/${var.template.vmdk_file_name}"
  destination_file   = "/${var.template.template_name}-template/${var.template.vmdk_file_name}"
  create_directories = true
}

resource "vsphere_virtual_machine" "template" {
  depends_on       = [ resource.vsphere_file.sles_vmdk_upload ]
  name             = var.template.template_name
  host_system_id   = module.get_ids.vsphere_ids.vsphere_host_id
  resource_pool_id = module.get_ids.vsphere_ids.resource_pool_id  
  datastore_id     = module.get_ids.vsphere_ids.datastore_id
  folder           = var.template.folder

  num_cpus = 1
  memory   = 1024

  cpu_hot_add_enabled  = true
  cpu_hot_remove_enabled  = true
  memory_hot_add_enabled  = true

  network_interface {
    network_id = data.vsphere_network.network.id
    adapter_type = "vmxnet3"
  }

  wait_for_guest_net_timeout = -1
  wait_for_guest_ip_timeout  = -1
 
  scsi_type = "lsilogic"

  disk {
    label              = "disk0"
    attach             = "true"
    datastore_id       = module.get_ids.vsphere_ids.datastore_id
    path               = "/${var.template.template_name}-template/${var.template.vmdk_file_name}"
  }
  guest_id = "sles12_64Guest"
  firmware = "efi" # efi/bios

  extra_config = {
    "guestinfo.metadata"          = base64encode(file("${path.module}/files/meta-data"))
    "guestinfo.metadata.encoding" = "base64"
    "guestinfo.userdata"          = base64encode(file("${path.module}/files/user-data"))
    "guestinfo.userdata.encoding" = "base64"
  }
}
