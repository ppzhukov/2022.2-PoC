output "stend_ids" {
  value = {
    lan_id = resource.vsphere_distributed_port_group.dpg.id
  }
}