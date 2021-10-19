provider "vsphere" {
	user		= "${var.vsphere_user}"
	password	= "${var.vsphere_password}"
	vsphere_server	= "${var.vsphere_server}"
	allow_unverified_ssl = true
}
data "vsphere_datacenter" "dc" {
  name = "WSR"                     ##must changed
}

data "vsphere_datastore" "datastore" {
  name          = "Datastore 6"     ##must changed
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "router_network" {
  name          = "router"          ##must changed
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_virtual_machine" "template_CentOS_Stream" {
  name              = "Template_CentOS_Stream"
  datacenter_id     = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_virtual_machine" "template_ISP" {
  name              = "Template_ISP"
  datacenter_id     = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_virtual_machine" "template_Ubuntu" {
  name              = "Template_Ubuntu20Desk"
  datacenter_id     = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_virtual_machine" "template_WinCli" {
  name              = "WinCLI10"
  datacenter_id     = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_virtual_machine" "template_WinServ" {
  name              = "WinServ2019"
  datacenter_id     = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_host" "esxi1_host" {
  name          = "esxi4.almetpt.local"          ##must changed
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

