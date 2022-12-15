output "vsphere_ids" {
  value = {
    vsphere_host_id = data.vsphere_host.host.id
    resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
    datastore_id = data.vsphere_datastore.datastore.id
    datacenter_id = data.vsphere_datacenter.dc.id
    wan_id = data.vsphere_network.wan.id
  }
}