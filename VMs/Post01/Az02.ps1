
# Resource Group Configuration Variables
# --------------------------------------------------------------------------

    $ResGrpName = "BasicVMsRG"
    $LocName    = "westeurope"

# (Re)Create ResourceGroup
# --------------------------------------------------------------------------

    if(Get-AzResourceGroup | Where-Object {$_.ResourceGroupName -eq $ResGrpName})
    {
        Get-AzResourceGroup -Name $ResGrpName | Remove-AzResourceGroup -Verbose
    }

    New-AzResourceGroup `
        -Name $ResGrpName `
        -Location $LocName

# VM Configuration Variables
# --------------------------------------------------------------------------
 
    # Config Values
    # --------------------------------------------------------------------------
        $VMName              = 'myFirstVM'
        
        $AdminUser           = "dummyadm"
        $AdminPass           = "MyDummyP@ss"

    # Admin Credential - Create SecureString and PSCredential object
    # --------------------------------------------------------------------------
        $AdminPassSec = ConvertTo-SecureString $AdminPass `
                            -AsPlainText `
                            -Force
        $Credential = New-Object System.Management.Automation.PSCredential ($AdminUser, $AdminPassSec);

# CREATE default Azure VM
# This will also create:
#  - VirtualNetwork
#  - Subnet
#  - SecurityGroup
#  - PublicIpAddress
# Open ports 80,3389 to connect via. HTTP and RDP
# --------------------------------------------------------------------------

    New-AzVm `
        -ResourceGroupName $ResGrpName `
        -Location $LocName `
        -Credential $Credential `
        -Name $VMName `
        -OpenPorts 80,3389 `
        -Verbose

# Check
# --------------------------------------------------------------------------

    Get-AzVM `
        -ResourceGroupName $ResGrpName

    Get-AzVM `
        -ResourceGroupName $ResGrpName `
        -VMName $VMName

# Get the DNS of VM (this works in our demo as only one PublicIp exists)
# --------------------------------------------------------------------------

    $DNS = (Get-AzPublicIpAddress -ResourceGroupName $ResGrpName).DnsSettings.Fqdn

# Open RDP and connect to the DNS using $AdminUser + $AdminPass
# ... or just let PS do that for you
# --------------------------------------------------------------------------
    
    cmdkey /generic:$DNS /user:$AdminUser /pass:$AdminPass
    mstsc /v:$($DNS):3389

# Clean-up
# --------------------------------------------------------------------------

    Remove-AzResourceGroup $ResGrpName -Verbose
