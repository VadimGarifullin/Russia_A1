resource "vsphere_folder" "root_folder" {          #Основная папка с другими папками путь stands
  path          = "Module_A"
  type          = "vm"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}
resource "vsphere_folder" "folder" {                #Подпапки для хранения VM, путь stands/stand1
  count = "${var.stand_count}"
  path          = "${vsphere_folder.root_folder.path}/A_1${format("%d", count.index + 1)}"
  type          = "vm"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

resource "vsphere_resource_pool" "pool_root" {
  name                    = "Module_A"
  parent_resource_pool_id = "${data.vsphere_host.esxi1_host.resource_pool_id}"
}

resource "vsphere_resource_pool" "pool_stand" {
  count = "${var.stand_count}"
  name                    = "A_1${format("%d", count.index + 1)}"
  parent_resource_pool_id = "${vsphere_resource_pool.pool_root.id}"
}

data "vsphere_resource_pool" "pool_stand" {
  count = "${var.stand_count}"
  name          = "A_1${format("%d", count.index + 1)}"
  datacenter_id = data.vsphere_datacenter.dc.id
  depends_on    = [vsphere_resource_pool.pool_stand]
}

resource "vsphere_virtual_machine" "DC" {
    count = "${var.stand_count}"
    name = "DC"       #VMName у виртупльной машины, надо менять
    resource_pool_id    = "${data.vsphere_resource_pool.pool_stand[count.index].id}"
    datastore_id        = "${data.vsphere_datastore.datastore.id}"
    folder = "${vsphere_folder.folder[count.index].path}"                #путь к подпапке с номером стенда
      num_cpus = 2
      memory   = 2048    #4096
      wait_for_guest_net_timeout    = "0"
      wait_for_guest_ip_timeout    = "0"
      wait_for_guest_net_routable = "0"
      guest_id = "${data.vsphere_virtual_machine.template_WinServ.guest_id}"
      firmware = "efi"                                    
      network_interface {
        network_id = "${data.vsphere_network.Servers[count.index].id}"
        adapter_type = "${data.vsphere_virtual_machine.template_WinServ.network_interface_types[0]}"
    
      }

  disk {
    label = "disk0"
    size             = "${data.vsphere_virtual_machine.template_WinServ.disks.0.size}"
    eagerly_scrub    = "${data.vsphere_virtual_machine.template_WinServ.disks.0.eagerly_scrub}"
    thin_provisioned = "${data.vsphere_virtual_machine.template_WinServ.disks.0.thin_provisioned}"
  }
  clone {
    template_uuid = "${data.vsphere_virtual_machine.template_WinServ.id}"
  } 
}

resource "vsphere_virtual_machine" "SRV" {
    count = "${var.stand_count}"
    name = "SRV"
    resource_pool_id    = "${data.vsphere_resource_pool.pool_stand[count.index].id}"
    datastore_id        = "${data.vsphere_datastore.datastore.id}"
    folder = "${vsphere_folder.folder[count.index].path}"                #путь к подпапке с номером стенда
      num_cpus = 2
      memory   = 1024
      wait_for_guest_net_timeout    = "0"
      wait_for_guest_ip_timeout    = "0"
      wait_for_guest_net_routable = "0"
      guest_id = "${data.vsphere_virtual_machine.template_CentOS_Stream.guest_id}"
      firmware = "efi"                                     # У Template CentOS8 UEFI стандарт, ставим efi, по умолчанию bios
      network_interface {
        network_id = "${data.vsphere_network.Servers[count.index].id}"
        adapter_type = "${data.vsphere_virtual_machine.template_CentOS_Stream.network_interface_types[0]}"
    
      }
  disk {
    label = "disk0"
    size             = "${data.vsphere_virtual_machine.template_CentOS_Stream.disks.0.size}"
    eagerly_scrub    = "${data.vsphere_virtual_machine.template_CentOS_Stream.disks.0.eagerly_scrub}"
    thin_provisioned = "${data.vsphere_virtual_machine.template_CentOS_Stream.disks.0.thin_provisioned}"
  }
  clone {
    template_uuid = "${data.vsphere_virtual_machine.template_CentOS_Stream.id}"
}
}

resource "vsphere_virtual_machine" "APP-GW" {
    count = "${var.stand_count}"
    name = "APP-GW"
    resource_pool_id    = "${data.vsphere_resource_pool.pool_stand[count.index].id}"
    datastore_id        = "${data.vsphere_datastore.datastore.id}"
    folder = "${vsphere_folder.folder[count.index].path}"                #путь к подпапке с номером стенда
      num_cpus = 2
      memory   = 1024
      wait_for_guest_net_timeout    = "0"
      wait_for_guest_ip_timeout    = "0"
      wait_for_guest_net_routable = "0"
      guest_id = "${data.vsphere_virtual_machine.template_CentOS_Stream.guest_id}"
      firmware = "efi"                                     # У Template CentOS8 UEFI стандарт, ставим efi, по умолчанию bios
      network_interface {
        network_id = "${data.vsphere_network.inet[count.index].id}"
        adapter_type = "${data.vsphere_virtual_machine.template_CentOS_Stream.network_interface_types[0]}"
      }
      network_interface {
        network_id = "${data.vsphere_network.App[count.index].id}"
        adapter_type = "${data.vsphere_virtual_machine.template_CentOS_Stream.network_interface_types[0]}"
      }
  disk {
    label = "disk0"
    size             = "${data.vsphere_virtual_machine.template_CentOS_Stream.disks.0.size}"
    eagerly_scrub    = "${data.vsphere_virtual_machine.template_CentOS_Stream.disks.0.eagerly_scrub}"
    thin_provisioned = "${data.vsphere_virtual_machine.template_CentOS_Stream.disks.0.thin_provisioned}"
  }
  clone {
    template_uuid = "${data.vsphere_virtual_machine.template_CentOS_Stream.id}"
}
}

resource "vsphere_virtual_machine" "APP-VM1" {
    count = "${var.stand_count}"
    name = "APP-VM1"
    resource_pool_id    = "${data.vsphere_resource_pool.pool_stand[count.index].id}"
    datastore_id        = "${data.vsphere_datastore.datastore.id}"
    folder = "${vsphere_folder.folder[count.index].path}"                #путь к подпапке с номером стенда
      num_cpus = 2
      memory   = 1024
      wait_for_guest_net_timeout    = "0"
      wait_for_guest_ip_timeout    = "0"
      wait_for_guest_net_routable = "0"
      guest_id = "${data.vsphere_virtual_machine.template_CentOS_Stream.guest_id}"
      firmware = "efi"                                     # У Template CentOS8 UEFI стандарт, ставим efi, по умолчанию bios
      network_interface {
        network_id = "${data.vsphere_network.App[count.index].id}"
        adapter_type = "${data.vsphere_virtual_machine.template_CentOS_Stream.network_interface_types[0]}"
    
      }
  disk {
    label = "disk0"
    size             = "${data.vsphere_virtual_machine.template_CentOS_Stream.disks.0.size}"
    eagerly_scrub    = "${data.vsphere_virtual_machine.template_CentOS_Stream.disks.0.eagerly_scrub}"
    thin_provisioned = "${data.vsphere_virtual_machine.template_CentOS_Stream.disks.0.thin_provisioned}"
  }
  clone {
    template_uuid = "${data.vsphere_virtual_machine.template_CentOS_Stream.id}"
}
}

resource "vsphere_virtual_machine" "APP-VM2" {
    count = "${var.stand_count}"
    name = "APP-VM2"
    resource_pool_id    = "${data.vsphere_resource_pool.pool_stand[count.index].id}"
    datastore_id        = "${data.vsphere_datastore.datastore.id}"
    folder = "${vsphere_folder.folder[count.index].path}"                #путь к подпапке с номером стенда
      num_cpus = 2
      memory   = 1024
      wait_for_guest_net_timeout    = "0"
      wait_for_guest_ip_timeout    = "0"
      wait_for_guest_net_routable = "0"
      guest_id = "${data.vsphere_virtual_machine.template_CentOS_Stream.guest_id}"
      firmware = "efi"                                     # У Template CentOS8 UEFI стандарт, ставим efi, по умолчанию bios
      network_interface {
        network_id = "${data.vsphere_network.App[count.index].id}"
        adapter_type = "${data.vsphere_virtual_machine.template_CentOS_Stream.network_interface_types[0]}"
    
      }
  disk {
    label = "disk0"
    size             = "${data.vsphere_virtual_machine.template_CentOS_Stream.disks.0.size}"
    eagerly_scrub    = "${data.vsphere_virtual_machine.template_CentOS_Stream.disks.0.eagerly_scrub}"
    thin_provisioned = "${data.vsphere_virtual_machine.template_CentOS_Stream.disks.0.thin_provisioned}"
  }
  clone {
    template_uuid = "${data.vsphere_virtual_machine.template_CentOS_Stream.id}"
}
}

resource "vsphere_virtual_machine" "FW" {
    count = "${var.stand_count}"
    name = "FW"
    resource_pool_id    = "${data.vsphere_resource_pool.pool_stand[count.index].id}"
    datastore_id        = "${data.vsphere_datastore.datastore.id}"
    folder = "${vsphere_folder.folder[count.index].path}"                #путь к подпапке с номером стенда
      num_cpus = 2
      memory   = 1024
      wait_for_guest_net_timeout    = "0"
      wait_for_guest_ip_timeout    = "0"
      wait_for_guest_net_routable = "0"
      guest_id = "${data.vsphere_virtual_machine.template_CentOS_Stream.guest_id}"
      firmware = "efi"                                     # У Template CentOS8 UEFI стандарт, ставим efi, по умолчанию bios
      network_interface {
        network_id = "${data.vsphere_network.inet[count.index].id}"
        adapter_type = "${data.vsphere_virtual_machine.template_CentOS_Stream.network_interface_types[0]}"
    
      }
      network_interface {
        network_id = "${data.vsphere_network.Servers[count.index].id}"
        adapter_type = "${data.vsphere_virtual_machine.template_CentOS_Stream.network_interface_types[0]}"
      }
      network_interface {
        network_id = "${data.vsphere_network.Clients[count.index].id}"
        adapter_type = "${data.vsphere_virtual_machine.template_CentOS_Stream.network_interface_types[0]}"
      }

  disk {
    label = "disk0"
    size             = "${data.vsphere_virtual_machine.template_CentOS_Stream.disks.0.size}"
    eagerly_scrub    = "${data.vsphere_virtual_machine.template_CentOS_Stream.disks.0.eagerly_scrub}"
    thin_provisioned = "${data.vsphere_virtual_machine.template_CentOS_Stream.disks.0.thin_provisioned}"
  }
  clone {
    template_uuid = "${data.vsphere_virtual_machine.template_CentOS_Stream.id}"  
  }
}
##########################################################
resource "vsphere_virtual_machine" "CLI-W" {
    count = "${var.stand_count}"
    name = "CLI-W"       #VMName у виртупльной машины, надо менять
    resource_pool_id    = "${data.vsphere_resource_pool.pool_stand[count.index].id}"
    datastore_id        = "${data.vsphere_datastore.datastore.id}"
    folder = "${vsphere_folder.folder[count.index].path}"                #путь к подпапке с номером стенда
      num_cpus = 2
      memory   = 2048
      wait_for_guest_net_timeout    = "0"
      wait_for_guest_ip_timeout    = "0"
      wait_for_guest_net_routable = "0"
      guest_id = "${data.vsphere_virtual_machine.template_WinCli.guest_id}"
      firmware = "efi"                                     # У Template CentOS8 UEFI стандарт, ставим efi, по умолчанию bios
      network_interface {
        network_id = "${data.vsphere_network.Clients[count.index].id}"
        adapter_type = "${data.vsphere_virtual_machine.template_WinCli.network_interface_types[0]}"
      }

  disk {
    label = "disk0"
    size             = "${data.vsphere_virtual_machine.template_WinCli.disks.0.size}"
    eagerly_scrub    = "${data.vsphere_virtual_machine.template_WinCli.disks.0.eagerly_scrub}"
    thin_provisioned = "${data.vsphere_virtual_machine.template_WinCli.disks.0.thin_provisioned}"
  }
  clone {
    template_uuid = "${data.vsphere_virtual_machine.template_WinCli.id}"
  } 
}

resource "vsphere_virtual_machine" "CLI-OUT" {
    count = "${var.stand_count}"
    name = "CLI-OUT"
    resource_pool_id    = "${data.vsphere_resource_pool.pool_stand[count.index].id}"
    datastore_id        = "${data.vsphere_datastore.datastore.id}"
    folder = "${vsphere_folder.folder[count.index].path}"                #путь к подпапке с номером стенда
      num_cpus = 2
      memory   = 1024
      wait_for_guest_net_timeout    = "0"
      wait_for_guest_ip_timeout    = "0"
      wait_for_guest_net_routable = "0"
      guest_id = "${data.vsphere_virtual_machine.template_Ubuntu.guest_id}"
      firmware = "efi"                                     # У Template CentOS8 UEFI стандарт, ставим efi, по умолчанию bios
      network_interface {
        network_id = "${data.vsphere_network.inet[count.index].id}"
        adapter_type = "${data.vsphere_virtual_machine.template_Ubuntu.network_interface_types[0]}"
    
      }
  disk {
    label = "disk0"
    size             = "${data.vsphere_virtual_machine.template_Ubuntu.disks.0.size}"
    eagerly_scrub    = "${data.vsphere_virtual_machine.template_Ubuntu.disks.0.eagerly_scrub}"
    thin_provisioned = "${data.vsphere_virtual_machine.template_Ubuntu.disks.0.thin_provisioned}"
  }
  clone {
    template_uuid = "${data.vsphere_virtual_machine.template_Ubuntu.id}"
}
}

resource "vsphere_virtual_machine" "CLI-L" {
    count = "${var.stand_count}"
    name = "CLI-L"
    resource_pool_id    = "${data.vsphere_resource_pool.pool_stand[count.index].id}"
    datastore_id        = "${data.vsphere_datastore.datastore.id}"
    folder = "${vsphere_folder.folder[count.index].path}"                #путь к подпапке с номером стенда
      num_cpus = 2
      memory   = 1024
      wait_for_guest_net_timeout    = "0"
      wait_for_guest_ip_timeout    = "0"
      wait_for_guest_net_routable = "0"
      guest_id = "${data.vsphere_virtual_machine.template_Ubuntu.guest_id}"
      firmware = "efi"                              
      network_interface {
        network_id = "${data.vsphere_network.Clients[count.index].id}"
        adapter_type = "${data.vsphere_virtual_machine.template_Ubuntu.network_interface_types[0]}"
    
      }
  disk {
    label = "disk0"
    size             = "${data.vsphere_virtual_machine.template_Ubuntu.disks.0.size}"
    eagerly_scrub    = "${data.vsphere_virtual_machine.template_Ubuntu.disks.0.eagerly_scrub}"
    thin_provisioned = "${data.vsphere_virtual_machine.template_Ubuntu.disks.0.thin_provisioned}"
  }
  clone {
    template_uuid = "${data.vsphere_virtual_machine.template_Ubuntu.id}"
}
}




resource "vsphere_virtual_machine" "ISP" {
    count = "${var.stand_count}"
    name = "ISP"
    resource_pool_id    = "${data.vsphere_resource_pool.pool_stand[count.index].id}"
    datastore_id        = "${data.vsphere_datastore.datastore.id}"
    folder = "${vsphere_folder.folder[count.index].path}"                #путь к подпапке с номером стенда
      num_cpus = 2
      memory   = 1024
      wait_for_guest_net_timeout    = "0"
      wait_for_guest_ip_timeout    = "0"
      wait_for_guest_net_routable = "0"
      guest_id = "${data.vsphere_virtual_machine.template_ISP.guest_id}"
      firmware = "efi"                                     # У Template CentOS8 UEFI стандарт, ставим efi, по умолчанию bios
      network_interface {
        network_id = "${data.vsphere_network.router_network.id}"
        adapter_type = "${data.vsphere_virtual_machine.template_ISP.network_interface_types[0]}"
    
      }
      network_interface {
        network_id = "${data.vsphere_network.inet[count.index].id}"
        adapter_type = "${data.vsphere_virtual_machine.template_ISP.network_interface_types[0]}"
    
      }

  disk {
    label = "disk0"
    size             = "${data.vsphere_virtual_machine.template_ISP.disks.0.size}"
    eagerly_scrub    = "${data.vsphere_virtual_machine.template_ISP.disks.0.eagerly_scrub}"
    thin_provisioned = "${data.vsphere_virtual_machine.template_ISP.disks.0.thin_provisioned}"
  }
  clone {
    template_uuid = "${data.vsphere_virtual_machine.template_ISP.id}"
#    timeout = "10"
    
}
}

