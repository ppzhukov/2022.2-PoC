variable "vm_common_parameters" {
  type             = object({
  adapter_type     = string
  scsi_type        = string
  thin_provisioned = bool
  guest_id         = string
  firmware         = string
  template_id      = string
  })
}

variable "vm_parameters" {
  type             = object({ 
  name             = string
  enable_wan       = bool
  disk_size        = number
  cpu              = number
  memory           = number
  metadata         = string
  userdata         = string
  network_map      = list(string)
  })
}


variable "stend_environment" {
  type = object({
  host_system_id   = string
  resource_pool_id = string
  datastore_id     = string
  folder           = string
  })
}