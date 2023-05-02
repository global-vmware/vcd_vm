## VCD Virtual Machine Terraform Module
This Terraform module will deploy "X" Number of Virtual Machines into Rackspace Technology SDDC Flex VCD Data Center Regions.

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.2 |
| vcd | >= 3.8.2 |

## Resources

| Name | Type |
|------|------|
| [vcd_vm](https://registry.terraform.io/providers/vmware/vcd/latest/docs/resources/vm) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| vdc_org_name | Name of the Data Center Group Organization | string | `"Data Center Group Name Format: <Account_Number>-<Region>-<Account_Name>"` | Yes |
| vdc_group_name | Name of the Data Center Group | string | `"Data Center Group Name Format: <Account_Number>-<Region>-<Account_Name> <datacenter group>"` | Yes |
| vdc_name | Cloud Director VDC Name | string | `"Virtual Data Center Name Format: <Account_Number>-<Region>-<Segment Name>"` | Yes |
| vcd_edge_name | Name of the Data Center Group Edge Gateway | string | `"Edge Gateway Name Format: <Account_Number>-<Region>-<Edge_GW_Identifier>-<edge>"` | Yes |
| vm_sizing_policy_name | Cloud Director VM Sizing Policy Name | string | "gp2.4" | No |
| org_network_name | Cloud Director Organization Network Name | string | "" | Yes |
| catalog_name | Cloud Director Catalog Name | string | `"VCD Catalog Name Format: <Account_Number>-<Region>-<catalog>"` | Yes |
| catalog_template_name | Cloud Director Catalog Template Name | string | "" | Yes |
| vm_name_environment | Environment of the VM | string | "Prod" | No |
| vm_app_role | Role of the application running on the VM | string | "Web" | No |
| vm_computer_name_environment | Environment to be used in computer name | string | "pd" | No |
| vm_computer_name_app_name | Application name to be used in computer name | string | "app" | No |
| vm_computer_name_role | Role to be used in computer name | string | "web" | No |
| vm_cpu_hot_add_enabled | Flag to enable or disable hot adding CPUs to VMs | bool | true | No |
| vm_memory_hot_add_enabled | Flag to enable or disable hot adding memory to VMs | bool | true | No |
| vm_min_cpu | Minimum number of CPUs for each VM | number | 2 | No |
| vm_count | Number of VMs to create | number | 2 | No |
| vm_metadata_entries | List of metadata entries for the VM | list(object({ key = string, value = string, type = string, user_access = string, is_system = bool })) | `[{ key = "Built By", value = "Terraform", type = "MetadataStringValue", user_access = "READWRITE", is_system = false }, { key = "Operating System", value = "Ubuntu Linux (64-Bit)", type = "MetadataStringValue", user_access = "READWRITE", is_system = false }, { key = "Server Role", value = "Web Server", type = "MetadataStringValue", user_access = "READWRITE", is_system = false }]` | No |
| network_type | The type of network adapter to use | string | "org" | No |
| network_adapter_type | The type of network adapter to use | string | "VMXNET3" | No |
| network_ip_allocation_mode | The IP address allocation mode | string | "POOL" | No |
| network_cidr | The CIDR notation for the network | string | "" | Yes |
| vm_ips | List of IP addresses to assign to VMs | list(string) | `["", ""]` | No |
| vm_customization_force | Specifies whether to force the customization even if the VM is powered on | bool | false | No |
| vm_customization_enabled | Specifies whether to enable customization of the VM | bool | true | No |
| vm_customization_change_sid | Specifies whether to generate a new SID for the Windows VM | bool | false | no |
| vm_customization_allow_local_admin_password | Specifies whether to allow the use of local administrator passwords | bool | true | no |
| vm_customization_must_change_password_on_first_login | Specifies whether the user must change the password on the first login | bool | false | no |
| vm_customization_auto_generate_password | Specifies whether to automatically generate a password for the local administrator account | bool | true | no |
| vm_customization_admin_password | The password for the local administrator account | string | "" | no |
| vm_customization_number_of_auto_logons | Number of times to log on automatically. 0 means disabled. | number | 0 | No |
| vm_customization_join_domain | Enable this VM to join a domain. | bool | false | No |
| vm_customization_join_org_domain | Set to true to use organization's domain. | bool | false | No |
| vm_customization_join_domain_name | Set the domain name to override organization's domain name. | string | null | No |
| vm_customization_join_domain_user | User to be used for domain join. | string | null | No |
| vm_customization_join_domain_password | Password to be used for domain join. | string | null | No |
| vm_customization_join_domain_account_ou | Organizational unit to be used for domain join. | string | null | No |
| vm_customization_initscript | Provide initscript to be executed when customization is applied. | string | null | No |

`NOTE:` Each object in the `vm_metadata_entries` list must have the following attributes:

`key:` The key for the metadata entry.
`value:` The value for the metadata entry.
`type:` The type of the metadata value. The acceptable values are `"MetadataStringValue"`, `"MetadataNumberValue"`, `"MetadataDateTimeValue"`, `"MetadataBooleanValue"`.
`user_access:` The level of access granted to users for this metadata entry. The acceptable values are `"READONLY"`, `"READWRITE"`.
`is_system:` Specifies whether the metadata is system-generated or not. The acceptable values are `true`, `false`.

## Outputs

| Name | Description |
|------|-------------|
| vm_names | An array of formatted VM names. |
| vm_ips | An array of IP addresses for each VM. |
| vm_computer_names | An array of formatted computer names for each VM. |
| vm_metadata_entries | An array of metadata entries for each VM. |
| vm_count | The count of VMs created. |
| vm_sizing_policy_name | The name of the sizing policy retrieved from the VCD instance. |

## Example Usage
This is an example of a `main.tf` file that would use the `"github.com/global-vmware/vcd_vm"` Module Source to create a Virtual Application and it's associated Virtual Machines.

The Terraform code example for the main.tf file is below:

```terraform
module "vcd_vm" {
  source                            = "github.com/global-vmware/vcd_vm.git?ref=v1.1.0"
  
  vdc_org_name                      = "<US1-VDC-ORG-NAME>"
  vdc_group_name                    = "<US1-VDC-GRP-NAME>"
  vdc_name                          = "<US1-VDC-NAME>"
  vcd_edgegateway_name              = "<US1-VDC-EDGE-NAME>"
  catalog_name                      = "<US1-CATALOG-NAME>"
  catalog_template_name             = "<US1-CATALOG-TEMPLATE-NAME>"
  org_network_name                  = "US1-Segment-01"
  network_cidr                      = "172.16.0.0/24"
  network_ip_allocation_mode        = "MANUAL"
  vm_ips                            = ["172.16.0.10", "172.16.0.11"]

  vm_count                          = 2
  vm_min_cpu                        = 4
  vm_sizing_policy_name             = "gp4.8"

  vm_name_environment               = "Prod"
  vm_app_name                       = "App"
  vm_app_role                       = "Web Server"
  vm_computer_name_environment      = "pd"
  vm_computer_name_app_name         = "app"
  vm_computer_name_role             = "web"

  vm_metadata_entries = [
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
      key         = "Build Date"
      value       = timestamp()
      type        = "MetadataDateTimeValue"
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
}
```