resource "vsphere_host_virtual_switch" "switch" {
    count = "${var.stand_count}"
    name        = "Module_A${format("%d", count.index + 1)}"
    host_system_id = "${data.vsphere_host.esxi1_host.id}"
    network_adapters = []
    active_nics = []
    standby_nics = []

}

resource "vsphere_host_port_group" "Servers" {
  count = "${var.stand_count}"
  name                = "Servers${format("%d", count.index + 1)}"
  host_system_id      = "${data.vsphere_host.esxi1_host.id}"
  virtual_switch_name = "${vsphere_host_virtual_switch.switch[count.index].name}"
  allow_promiscuous    = true
  vlan_id = 10
}

resource "vsphere_host_port_group" "Clients" {
  count = "${var.stand_count}"
  name                = "Clients${format("%d", count.index + 1)}"
  host_system_id      = "${data.vsphere_host.esxi1_host.id}"
  virtual_switch_name = "${vsphere_host_virtual_switch.switch[count.index].name}"
  allow_promiscuous    = true
  vlan_id = 20
}

resource "vsphere_host_port_group" "inet" {
  count = "${var.stand_count}"
  name                = "inet${format("%d", count.index + 1)}"
  host_system_id      = "${data.vsphere_host.esxi1_host.id}"
  virtual_switch_name = "${vsphere_host_virtual_switch.switch[count.index].name}"
  allow_promiscuous    = true
  vlan_id = 30
}

resource "vsphere_host_port_group" "App" {
  count = "${var.stand_count}"
  name                = "App${format("%d", count.index + 1)}"
  host_system_id      = "${data.vsphere_host.esxi1_host.id}"
  virtual_switch_name = "${vsphere_host_virtual_switch.switch[count.index].name}"
  allow_promiscuous    = true
  vlan_id = 40
}

data "vsphere_network" "Servers" {
  count = "${var.stand_count}"
  name          = "Servers${format("%d", count.index + 1)}"
  datacenter_id = data.vsphere_datacenter.dc.id
  depends_on    = [vsphere_host_port_group.Servers]  #зависимость от port_group, ждет пока не создаться
}

data "vsphere_network" "Clients" {
  count = "${var.stand_count}"
  name          = "Clients${format("%d", count.index + 1)}"
  datacenter_id = data.vsphere_datacenter.dc.id
  depends_on    = [vsphere_host_port_group.Clients]  #зависимость от port_group, ждет пока не создаться
}

data "vsphere_network" "inet" {
  count = "${var.stand_count}"
  name          = "inet${format("%d", count.index + 1)}"
  datacenter_id = data.vsphere_datacenter.dc.id
  depends_on    = [vsphere_host_port_group.inet]  #зависимость от port_group, ждет пока не создаться
}

data "vsphere_network" "App" {
  count = "${var.stand_count}"
  name          = "App${format("%d", count.index + 1)}"
  datacenter_id = data.vsphere_datacenter.dc.id
  depends_on    = [vsphere_host_port_group.App]  #зависимость от port_group, ждет пока не создаться
}