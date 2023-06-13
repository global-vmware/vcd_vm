output "all_vm_info" {
  value = [
    for index, vm in vcd_vm.vm : {
      name              = vm.name
      ip                = vm.network[*].ip
      computer_name     = vm.computer_name
      metadata_entries  = vm.metadata_entry
      sizing_policy     = data.vcd_vm_sizing_policy.sizing_policy.name
      disks             = can(var.vm_disks) && index < length(var.vm_disks) ? [
        for i in range(index * var.disks_per_vm, (index + 1) * var.disks_per_vm) : {
          name        = var.vm_disks[i].name
          bus_number  = var.vm_disks[i].bus_number
          unit_number = var.vm_disks[i].unit_number
        }
      ] : []
    }
  ]
}

output "vm_count" {
  value = var.vm_count
}
