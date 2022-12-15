resource "vsphere_virtual_machine" "vm" {
  name             = var.vm_parameters.name
  host_system_id   = var.stend_environment.host_system_id
  resource_pool_id = var.stend_environment.resource_pool_id  
  datastore_id     = var.stend_environment.datastore_id
  folder           = var.stend_environment.folder

  num_cpus = var.vm_parameters.cpu
  memory   = var.vm_parameters.memory
  cpu_hot_add_enabled  = true
  cpu_hot_remove_enabled  = true
  memory_hot_add_enabled  = true

  dynamic "network_interface" {
    for_each = var.vm_parameters.network_map
    content {
      network_id = network_interface.value
      adapter_type = var.vm_common_parameters.adapter_type
    }
  }

  wait_for_guest_net_timeout = -1
  wait_for_guest_ip_timeout  = -1
  
  scsi_type = var.vm_common_parameters.scsi_type

  disk {
    label            = "disk0"
    size             = var.vm_parameters.disk_size
    thin_provisioned = var.vm_common_parameters.thin_provisioned
    eagerly_scrub = true
  }

    guest_id = var.vm_common_parameters.guest_id
    firmware = var.vm_common_parameters.firmware

  clone {
    template_uuid = var.vm_common_parameters.template_id
  }

  extra_config = {
    "guestinfo.metadata"          = base64gzip(var.vm_parameters.metadata)
    "guestinfo.metadata.encoding" = "gzip+base64"
    "guestinfo.userdata"          = base64gzip(var.vm_parameters.userdata)
    "guestinfo.userdata.encoding" = "gzip+base64"
  }

}