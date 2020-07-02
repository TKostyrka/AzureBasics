    
    $ResGrpName   = "RGVMs2"
    $VMName       = "MyLinuxVM"

    $vm = Get-AzVM `
        -ResourceGroupName $ResGrpName `
        -VMName $VMName

# This command gets available sizes for the existing virtual machine named ($VMName).
# You can resize this virtual machine to the sizes that this command gets.
# -----------------------------------------------------------------------------

    $vm | Get-AzVMSize

    # ... ale nie ma gwarancji "does not support the storage account type Premium_LRS"

# -----------------------------------------------------------------------------

    
    $vm | Stop-AzVM -Force       
    $vm.HardwareProfile.VmSize = "Standard_D4s_v3"

    $vm | Update-AzVM
    $vm | Start-AzVM