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

output "internal_disks" {
  description = "Details of internal disks added to the VM"
  value       = { for idx, disk in vcd_vm_internal_disk.internal_disk : idx => {
    vm_name         = disk.vm_name
    size_in_mb      = disk.size_in_mb
    bus_number      = disk.bus_number
    unit_number     = disk.unit_number
    bus_type        = disk.bus_type
    iops            = disk.iops
    storage_profile = disk.storage_profile
  } }
}

output "vm_count" {
  value = var.vm_count
}
