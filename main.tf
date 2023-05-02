terraform {
  required_version = ">= 1.2"

  required_providers {
    vcd = {
      source = "vmware/vcd"
      version = "3.8.2"
    }
  }
}

data "vcd_vdc_group" "vdc_group" {
  name                    = var.vdc_group_name
}

data "vcd_nsxt_edgegateway" "edge_gateway" {
  org                     = var.vdc_org_name
  owner_id                = data.vcd_vdc_group.vdc_group.id
  name                    = var.vdc_edge_name
}

data "vcd_network_routed_v2" "segment" {
  edge_gateway_id         = data.vcd_nsxt_edgegateway.edge_gateway.id
  name                    = var.org_network_name
}

data "vcd_vm_sizing_policy" "sizing_policy" {
  name                    = var.vm_sizing_policy_name
}

data "vcd_catalog" "catalog" {
  name                    = var.catalog_name
}

data "vcd_catalog_vapp_template" "template" {
  catalog_id              = data.vcd_catalog.catalog.id
  name                    = var.catalog_template_name
}


resource "vcd_vm" "vm" {
  name                    = format("%s %s %s %02d", var.vm_name_environment, var.vm_app_name, var.vm_app_role, count.index + 1)
  computer_name           = format("%s-%s-%s%02d", var.vm_computer_name_environment, var.vm_computer_name_app_name, var.vm_computer_name_role, count.index + 1)
  vapp_template_id        = data.vcd_catalog_vapp_template.template.id
  cpu_hot_add_enabled     = var.vm_cpu_hot_add_enabled
  memory_hot_add_enabled  = var.vm_memory_hot_add_enabled
  sizing_policy_id        = data.vcd_vm_sizing_policy.sizing_policy.id
  cpus                    = var.vm_min_cpu

  count                   = var.vm_count == 0 ? 1 : var.vm_count

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

  network {
    type                = var.network_type
    adapter_type        = var.network_adapter_type
    name                = var.org_network_name
    ip_allocation_mode  = var.network_ip_allocation_mode
    ip                  = var.network_ip_allocation_mode == "DHCP" ? "" : var.network_ip_allocation_mode == "POOL" ? "" : element(var.vm_ips, count.index)
    is_primary          = true
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


