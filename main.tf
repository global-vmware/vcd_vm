terraform {
  required_version = "~> 1.2"

  required_providers {
    vcd = {
      source  = "vmware/vcd"
      version = "~> 3.8"
    }
  }
}

data "vcd_vdc_group" "vdc_group" {
  org       = var.vdc_org_name
  name      = var.vdc_group_name
}

data "vcd_nsxt_edgegateway" "edge_gateway" {
  org       = var.vdc_org_name
  owner_id  = data.vcd_vdc_group.vdc_group.id
  name      = var.vdc_edge_name
}

locals {
  network_data = { for net in var.org_networks : net.name => net }
}

data "vcd_network_routed_v2" "segment_routed" {
  for_each        = { for name, net in local.network_data : name => net if net.type == "routed" }
  org             = var.vdc_org_name
  edge_gateway_id = data.vcd_nsxt_edgegateway.edge_gateway.id
  name            = each.value.name
}

data "vcd_network_isolated_v2" "segment_isolated" {
  for_each = { for name, net in local.network_data : name => net if net.type == "isolated" }
  org      = var.vdc_org_name
  owner_id = data.vcd_vdc_group.vdc_group.id
  name     = each.value.name
}

data "vcd_vm_sizing_policy" "sizing_policy" {
  name = var.vm_sizing_policy_name
}

data "vcd_catalog" "template_catalog" {
  org   = var.catalog_org_name
  name  = var.catalog_name
}

data "vcd_catalog_vapp_template" "template" {
  count       = length(var.catalog_template_name) > 0 ? 1 : 0
  org         = var.vdc_org_name
  catalog_id  = data.vcd_catalog.template_catalog.id
  name        = var.catalog_template_name
}

data "vcd_catalog" "boot_catalog" {
  for_each = var.boot_catalog_name != "" ? { "boot_catalog" = var.boot_catalog_name } : {}
  org      = var.boot_catalog_org_name
  name     = each.value
}

data "vcd_catalog_media" "inserted_media_iso" {
  for_each   = var.inserted_media_iso_name != "" ? { "inserted_media_iso" = var.inserted_media_iso_name } : {}
  org        = var.catalog_org_name
  catalog_id = var.boot_catalog_name != "" ? data.vcd_catalog.boot_catalog["boot_catalog"].id : null
  name       = each.value
}

data "vcd_catalog_media" "boot_image_iso" {
  count      = var.boot_iso_image_name != "" ? 1 : 0
  org        = var.catalog_org_name
  catalog_id = var.boot_catalog_name != "" ? data.vcd_catalog.boot_catalog["boot_catalog"].id : null
  name       = var.boot_iso_image_name
}

resource "vcd_inserted_media" "media_iso" {
  for_each    = var.inserted_media_iso_name != "" ? zipmap(var.vm_name, var.vm_name) : {}
  org         = var.vdc_org_name
  catalog     = var.boot_catalog_name
  name        = var.inserted_media_iso_name
  vapp_name   = vcd_vm.vm[each.key].vapp_name
  vm_name     = vcd_vm.vm[each.key].name

  eject_force = var.inserted_media_eject_force

  depends_on = [vcd_vm.vm]
}

resource "vcd_vm_internal_disk" "internal_disk" {
  for_each = {
  for idx, disk in flatten([
    for vm_index, vm in vcd_vm.vm : [
      for disk in var.internal_disks : {
        vm_index       = vm_index
        vm_name        = vm.name
        size_in_mb     = disk.size_in_mb
        bus_number     = disk.bus_number
        unit_number    = disk.unit_number
        bus_type       = disk.bus_type
        iops           = disk.iops
        storage_profile = disk.storage_profile
      }
    ]
  ]) : "${disk.vm_index}-${disk.unit_number}" => disk
}

  org         = var.vdc_org_name
  vdc         = var.vdc_name
  vapp_name   = vcd_vm.vm[each.value.vm_index].vapp_name
  vm_name     = each.value.vm_name
  size_in_mb  = each.value.size_in_mb
  bus_number  = each.value.bus_number
  unit_number = each.value.unit_number
  bus_type    = each.value.bus_type
  iops        = each.value.iops
  storage_profile = each.value.storage_profile
  allow_vm_reboot = var.vm_internal_disk_allow_vm_reboot

  depends_on = [vcd_vm.vm]
}

resource "vcd_vm" "vm" {
  for_each = { for i in range(var.vm_count) : i => i }
  org                     = var.vdc_org_name
  vdc                     = var.vdc_name
  name                    = var.vm_name_format != "" ? format(var.vm_name_format, var.vm_name[each.key % length(var.vm_name)], each.key + 1) : var.vm_name[each.key % length(var.vm_name)]
  computer_name           = var.computer_name_format != "" ? format(var.computer_name_format, var.computer_name[each.key % length(var.computer_name)], each.key + 1) : var.computer_name[each.key % length(var.computer_name)]
  vapp_template_id        = length(var.catalog_template_name) > 0 ? data.vcd_catalog_vapp_template.template[0].id : null
  cpu_hot_add_enabled     = var.vm_cpu_hot_add_enabled
  memory_hot_add_enabled  = var.vm_memory_hot_add_enabled
  sizing_policy_id        = data.vcd_vm_sizing_policy.sizing_policy.id
  cpus                    = var.vm_min_cpu
  os_type                 = var.vm_os_type
  hardware_version        = var.vm_hw_version
  firmware                = var.vm_firmware

  boot_options {
    boot_delay          = var.vm_boot_delay
    boot_retry_enabled  = var.vm_boot_retry_enabled
    boot_retry_delay    = var.vm_boot_retry_delay
    efi_secure_boot     = var.vm_efi_secure_boot
    enter_bios_setup_on_next_boot = var.vm_enter_bios_setup_on_next_boot

  }

  boot_image_id = var.boot_iso_image_name != "" ? data.vcd_catalog_media.boot_image_iso[0].id : null
  
  dynamic "metadata_entry" {
    for_each              = var.vm_metadata_entries

    content {
      key                 = metadata_entry.value.key
      value               = metadata_entry.value.value
      type                = metadata_entry.value.type
      user_access         = metadata_entry.value.user_access
      is_system           = metadata_entry.value.is_system
    }
  }

  dynamic "disk" {
    for_each = can(var.vm_disks) ? slice(var.vm_disks, each.key * var.disks_per_vm, (each.key + 1) * var.disks_per_vm) : []

    content {
      name        = can(disk.value) ? disk.value.name : null
      bus_number  = can(disk.value) ? disk.value.bus_number : null
      unit_number = can(disk.value) ? disk.value.unit_number : null
    }
  }

  dynamic "network" {
  for_each = var.network_interfaces

    content {
      type                = network.value.type
      name                = network.value.name
      ip_allocation_mode  = network.value.ip_allocation_mode
      ip                  = network.value.ip_allocation_mode == "MANUAL" ? element(var.vm_ips, each.key * var.vm_ips_index_multiplier + network.key) : ""
      is_primary          = network.value.is_primary
    }
  }

  dynamic "override_template_disk" {
    for_each = var.override_template_disks

    content {
      bus_type        = override_template_disk.value.bus_type
      size_in_mb      = override_template_disk.value.size_in_mb
      bus_number      = override_template_disk.value.bus_number
      unit_number     = override_template_disk.value.unit_number
      iops            = override_template_disk.value.iops
      storage_profile = override_template_disk.value.storage_profile
    }
  }  

  customization {
    force                               = var.vm_customization_force
    enabled                             = var.vm_customization_enabled
    change_sid                          = var.vm_customization_change_sid
    allow_local_admin_password          = var.vm_customization_allow_local_admin_password
    must_change_password_on_first_login = var.vm_customization_must_change_password_on_first_login
    auto_generate_password              = var.vm_customization_auto_generate_password
    admin_password                      = var.vm_customization_admin_password
    number_of_auto_logons               = var.vm_customization_number_of_auto_logons
    join_domain                         = var.vm_customization_join_domain
    join_org_domain                     = var.vm_customization_join_org_domain
    join_domain_name                    = var.vm_customization_join_domain_name
    join_domain_user                    = var.vm_customization_join_domain_user
    join_domain_password                = var.vm_customization_join_domain_password
    join_domain_account_ou              = var.vm_customization_join_domain_account_ou
    initscript                          = var.vm_customization_initscript
  }
}