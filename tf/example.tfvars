vsphere_environment = {
    datacenter         = "DC01"
    datastore          = "vhost01_Datastore_02"
    cluster            = "Cluster"
    host               = "172.17.0.1"
    dvs                = "DSwitch 01"
    dpg                = "DPG_TF_LAB_VLAN1302"
    dpg_vlan_id        = "1302"
    wan                = "DPG_VLAN13"
    folder             = "rancher/rancher-tf"
}

nodes_settings = {
    nodes_hostname         = "tf"
    vm_node_name           = "tf"
    router_ip              = "192.168.14.1"
    username               = "geeko"
    domain                 = "stend.test"
    network                = "192.168.14"
    netmask                = "24"
    wan_router_ip          = "172.17.13.51"
    wan_netmask            = "24"
    wan_gateway            = "172.17.13.254"
    wan_nameservers        = [ "172.17.13.254", "8.8.8.8" ] 
}

rancher_nodes_ip = [
    "21",
    "22",
    "23",
]

template = {
    template_name       = "SLES15SP4-minimal"
    vmdk_file_name      = "SLES15-SP4-Minimal-Rancher.x86_64-15.4.0.vmdk"
    network_name        = "VM Network"
    folder              = "Rancher"
}
