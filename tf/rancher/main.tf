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

## Template data

data "vsphere_virtual_machine" "template" {
  name          = "${var.template.template_name}"
  datacenter_id = module.get_ids.vsphere_ids.datacenter_id
}

locals {
vm_common_parameters = {
  adapter_type     = data.vsphere_virtual_machine.template.network_interface_types[0]
  scsi_type        = data.vsphere_virtual_machine.template.scsi_type
  thin_provisioned = data.vsphere_virtual_machine.template.disks.0.thin_provisioned
  guest_id         = data.vsphere_virtual_machine.template.guest_id
  firmware         = data.vsphere_virtual_machine.template.firmware
  template_id      = data.vsphere_virtual_machine.template.id
}

stend_environment = {
  host_system_id   = module.get_ids.vsphere_ids.vsphere_host_id
  resource_pool_id = module.get_ids.vsphere_ids.resource_pool_id  
  datastore_id     = module.get_ids.vsphere_ids.datastore_id
  folder           = var.vsphere_environment.folder
}
}

module "stend_environment" {
    depends_on       = [module.get_ids]
    source        = "../terraform-vsphere-vaquero-modules/stend_environment"
    stend_environment = var.vsphere_environment
}

## Deploy Router
module "router" {
  depends_on = [module.get_ids, module.stend_environment]
  source        = "../terraform-vsphere-vaquero-modules/vm"

  vm_common_parameters = local.vm_common_parameters
  stend_environment = local.stend_environment
  
  vm_parameters = {
    name             = "${var.nodes_settings.vm_node_name}-router"
    enable_wan       = true
    disk_size        = 24
    cpu              = 1
    memory           = 2048
    metadata         = data.template_file.metadata_router.rendered
    userdata         = data.template_file.userdata_router.rendered
    network_map      = [ module.stend_environment.stend_ids.lan_id, module.get_ids.vsphere_ids.wan_id ]
  }
}
## Deploy Rancher Nodes
module "rancher" {
  count = length(var.rancher_nodes_ip)
  
  depends_on = [module.get_ids, module.stend_environment, resource.null_resource.wait_cloud_init_router]
  source        = "../terraform-vsphere-vaquero-modules/vm"

  vm_common_parameters = local.vm_common_parameters
  stend_environment = local.stend_environment
  
  vm_parameters = {
    name             = "${var.nodes_settings.vm_node_name}-rancher-${count.index}"
    enable_wan       = true
    disk_size        = 64
    cpu              = 4
    memory           = 8192
    metadata         = data.template_file.metadata_rancher[count.index].rendered
    userdata         = data.template_file.userdata_rancher.rendered
    network_map      = [ module.stend_environment.stend_ids.lan_id ]
  }
}

resource "null_resource" "wait_cloud_init_router" {
 depends_on = [module.router]
 connection {
   type        = "ssh"
   user        = "${var.nodes_settings.username}"
   private_key = base64decode(var.tf_ssh_key.private_key_b64)
   host        = var.nodes_settings.wan_router_ip
#    bastion_host = var.nodes_settings.wan_router_ip
#    bastion_private_key = "${var.tf_ssh_key.private_key_b64}"
 }

 provisioner "remote-exec" {
   inline = [
           "sudo cloud-init status --wait",
   ]
 }
}


resource "null_resource" "wait_cloud_init_rancher" {
 depends_on = [module.rancher]
 count = length(var.rancher_nodes_ip)
 connection {
   type        = "ssh"
   user        = "${var.nodes_settings.username}"
   private_key = base64decode(var.tf_ssh_key.private_key_b64)
   host        = "${var.nodes_settings.network}.${var.rancher_nodes_ip[count.index]}"
   bastion_host = var.nodes_settings.wan_router_ip
   bastion_private_key = base64decode(var.tf_ssh_key.private_key_b64)
 }

 provisioner "remote-exec" {
   inline = [
           "sudo cloud-init status --wait",
           "sudo salt-call state.apply queue=True",
   ]
 }
}

resource "null_resource" "rke2_install" {
 depends_on = [resource.null_resource.wait_cloud_init_rancher]
 count = length(var.rancher_nodes_ip)
 connection {
   type        = "ssh"
   user        = "${var.nodes_settings.username}"
   private_key = base64decode(var.tf_ssh_key.private_key_b64)
   host        = var.nodes_settings.wan_router_ip
#    bastion_host = var.nodes_settings.wan_router_ip
#    bastion_private_key = "${var.tf_ssh_key.private_key_b64}"
 }
 provisioner "file" {
    source      = "rke2.sh"
    destination = "/tmp/rke2.sh"
 }
 
 provisioner "remote-exec" {
   inline = [
           "sudo chmod +x /tmp/rke2.sh",
           "sudo /tmp/rke2.sh",
   ]
 }
}


