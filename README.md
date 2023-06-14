# VCD Virtual Machine Terraform Module

This Terraform module will deploy "X" Number of Virtual Machines into an existing VMware Cloud Director (VCD) Environment.  This module can be used to provsion new Virtual Machines into [Rackspace Technology SDDC Flex](https://www.rackspace.com/cloud/private/software-defined-data-center-flex) VCD Data Center Regions.

## Requirements

| Name | Version |
|------|---------|
| terraform | ~> 1.2 |
| vcd | ~> 3.8.2 |

## Resources

| Name | Type |
|------|------|
| [vcd_vdc_group](https://registry.terraform.io/providers/vmware/vcd/latest/docs/data-sources/vdc_group) | data source |
| [vcd_nsxt_edgegateway](https://registry.terraform.io/providers/vmware/vcd/latest/docs/data-sources/nsxt_edgegateway) | data source |
| [vcd_network_routed_v2](https://registry.terraform.io/providers/vmware/vcd/latest/docs/data-sources/network_routed_v2) | data source |
| [vcd_vm_sizing_policy](https://registry.terraform.io/providers/vmware/vcd/latest/docs/data-sources/vm_sizing_policy) | data source |
| [vcd_catalog](https://registry.terraform.io/providers/vmware/vcd/latest/docs/data-sources/catalog) | data source |
| [vcd_catalog_vapp_template](https://registry.terraform.io/providers/vmware/vcd/latest/docs/data-sources/catalog_vapp_template) | data source |
| [vcd_vm](https://registry.terraform.io/providers/vmware/vcd/latest/docs/resources/vm) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| vdc_org_name | The name of the Data Center Group Organization in VCD | string | `"Organization Name Format: <Account_Number>-<Region>-<Account_Name>"` | yes |
| vdc_group_name | The name of the Data Center Group in VCD | string | `"Data Center Group Name Format: <Account_Number>-<Region>-<Account_Name> <datacenter group>"` | yes |
| vdc_name | Cloud Director VDC Name | string | `"Virtual Data Center Name Format: <Account_Number>-<Region>-<Segment Name>"` | Yes |
| vcd_edge_name | Name of the Data Center Group Edge Gateway | string | `"Edge Gateway Name Format: <Account_Number>-<Region>-<Edge_GW_Identifier>-<edge>"` | Yes |
| vm_sizing_policy_name | Cloud Director VM Sizing Policy Name | string | "gp2.4" | no |
| org_networks | List of Org network names | list(object({ name = string })) | [] | yes |
catalog_name | Cloud Director Catalog Name | string | `"VCD Catalog Name Format: <Account_Number>-<Region>-<catalog>"` | Yes |
| catalog_template_name | Cloud Director Catalog Template Name | string | "" | Yes |
| vm_name_format | Format for the VM name | string | "%s %02d" | no |
| vm_name | List of VM names | list(string) | [] | no |
| computer_name_format | Format for the computer name | string | "%s-%02d" | no |
| computer_name | List of computer names | list(string) | [] | no |
| vm_cpu_hot_add_enabled | Flag to enable or disable hot adding CPUs to VMs | bool | true | no |
| vm_memory_hot_add_enabled | Flag to enable or disable hot adding memory to VMs | bool | true | no |
| vm_min_cpu | Minimum number of CPUs for each VM | number | 2 | no |
| vm_count | Number of VMs to create | number | 2 | no |
| vm_metadata_entries | List of metadata entries for the VM | list(object({ key = string, value = string, type = string, user_access = string, is_system = bool })) | `[{ key = "Built By", value = "Terraform", type = "MetadataStringValue", user_access = "READWRITE", is_system = false }, { key = "Operating System", value = "Ubuntu Linux (64-Bit)", type = "MetadataStringValue", user_access = "READWRITE", is_system = false }, { key = "Server Role", value = "Web Server", type = "MetadataStringValue", user_access = "READWRITE", is_system = false }]` | No |
| disks_per_vm | Number of disks to assign to each VM | number | 0 | no |
| vm_disks | List of disks per virtual machine | list(object({ name = string, bus_number = number, unit_number = number })) | [] | no |
| network_interfaces | List of network interfaces for the VM | list(object({ type = string, adapter_type = string, name = string, ip_allocation_mode = string, ip = string, is_primary = bool })) | [...] | no |
| vm_ips_index_multiplier | Number of network interfaces for each VM deployment | number | 1 | no |
| vm_ips | List of IP addresses to assign to VMs | list(string) | `["", ""]` | no |
| override_template_disks | A list of disks to override in the vApp template | list(object({ bus_type = string, size_in_mb = number, bus_number = number, unit_number = number, iops = number, storage_profile = string })) | [] | no |
| vm_customization_force | Specifies whether to force the customization even if the VM is powered on | bool | false | no |
| vm_customization_enabled | Specifies whether to enable customization of the VM | bool | true | no |
| vm_customization_change_sid | Specifies whether to generate a new SID for the Windows VM | bool | false | no |
| vm_customization_allow_local_admin_password | Specifies whether to allow the use of local administrator passwords | bool | true | no |
| vm_customization_must_change_password_on_first_login | Specifies whether the user must change the password on the first login | bool | false | no |
| vm_customization_auto_generate_password | Specifies whether to automatically generate a password for the local administrator account | bool | true | no |
| vm_customization_admin_password | The password for the local administrator account | string | null | no |
| vm_customization_number_of_auto_logons | Number of times to log on automatically. 0 means disabled. | number | 0 | no |
| vm_customization_join_domain | Enable this VM to join a domain. | bool | false | no |
| vm_customization_join_org_domain | Set to true to use organization's domain. | bool | false | no |
| vm_customization_join_domain_name | Set the domain name to override organization's domain name. | string | null | no |
| vm_customization_join_domain_user | User to be used for domain join. | string | null | no |
| vm_customization_join_domain_password | Password to be used for domain join. | string | null | no |
| vm_customization_join_domain_account_ou | Organizational unit to be used for domain join. | string | null | no |
| vm_customization_initscript | Provide initscript to be executed when customization is applied. | string | null | no |

`NOTE:` Each object in the `vm_metadata_entries` list must have the following attributes:

`key:` The key for the metadata entry.
`value:` The value for the metadata entry.
`type:` The type of the metadata value. The acceptable values are `"MetadataStringValue"`, `"MetadataNumberValue"`, `"MetadataDateTimeValue"`, `"MetadataBooleanValue"`.
`user_access:` The level of access granted to users for this metadata entry. The acceptable values are `"READONLY"`, `"READWRITE"`.
`is_system:` Specifies whether the metadata is system-generated or not. The acceptable values are `true`, `false`.

## Outputs

| Name | Description |
|------|-------------|
| all_vm_info | An array of objects containing information about each VM.  This includes VM Name, IP's, Computer Name, Metadata Entries, VM Sizing Policy and Named Disks that were Attached to the VM.|
| vm_count | The number of VMs created. |

## Example Usage

This is an example of a `main.tf` file that would use the `"github.com/global-vmware/vcd_vm"` Module Source to deploy Virtual Machines into an existing VCD Environment.

The Terraform code example for the main.tf file is below:

```terraform
module "vcd_vm" {
  source                            = "github.com/global-vmware/vcd_vm.git?ref=v2.0.0"

  vdc_org_name                      = "<US1-VDC-ORG-NAME>"
  vdc_group_name                    = "<US1-VDC-GRP-NAME>"
  vdc_name                          = "<US1-VDC-NAME>"
  vdc_edge_name                     = "<US1-VDC-EDGE-NAME>"

  catalog_name                      = "<US1-CATALOG-NAME>"
  catalog_template_name             = "<US1-CATALOG-TEMPLATE-NAME>"

  vm_sizing_policy_name             = "gp4.8"
  vm_min_cpu                        = "4"

  vm_count                          = 2

  org_networks                 = [
    { name = "US1-Segment-01" },
    { name = "US1-Segment-02" },
  ]

  vm_name                           = ["Production App Web Server"]
  vm_name_format                    = "%s %02d"
  
  computer_name                     = ["pd-app-web"]
  computer_name_format              = "%s-%02d"

  vm_metadata_entries               = [
    {
      key         = "Cost Center"
      value       = "IT Department - 1001"
      type        = "MetadataStringValue"
      user_access = "READWRITE"
      is_system   = false
    },
    {
      key         = "Operating System"
      value       = "Ubuntu Linux (64-Bit)"
      type        = "MetadataStringValue"
      user_access = "READWRITE"
      is_system   = false
    },
    {
      key         = "Server Role"
      value       = "Web Server"
      type        = "MetadataStringValue"
      user_access = "READWRITE"
      is_system   = false
    },
    {
      key         = "Built By"
      value       = "Build Engineering Team"
      type        = "MetadataStringValue"
      user_access = "READWRITE"
      is_system   = false
    }
  ]
  
  network_interfaces      = [
    {
    type                  = "org"
    adapter_type          = "VMXNET3"
    name                  = "US1-Segment-01"
    ip_allocation_mode    = "POOL"
    ip                    = ""
    is_primary            = true
    },
    {
    type                  = "org"
    adapter_type          = "VMXNET3"
    name                  = "US1-Segment-02"
    ip_allocation_mode    = "POOL"
    ip                    = ""
    is_primary            = false
    }
  ]
}
```

## Authors

This module is maintained by the [Global VMware Cloud Automation Services Team](https://github.com/global-vmware).