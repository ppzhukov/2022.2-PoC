variable "stend_environment" {
  type = object({
    datacenter = string
    dvs = string
    dpg = string
    dpg_vlan_id = string
    folder = string
  })
}
