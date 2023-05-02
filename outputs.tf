output "vm_info" {
  value = [
    for vm in vcd_vm.vm : {
      name              = vm.name
      ip                = vm.network[*].ip
      computer_name     = vm.computer_name
      metadata_entries  = vm.metadata_entry
    }
  ]
}

output "all_vm_info" {
  value = [
    for vm in vcd_vm.vm : {
      name              = vm.name
      ip                = vm.network[*].ip
      computer_name     = vm.computer_name
      metadata_entries  = vm.metadata_entry
      sizing_policy     = data.vcd_vm_sizing_policy.sizing_policy.name
    }
  ]
}
