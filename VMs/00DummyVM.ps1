
#   Create a simple Win VM
#   Everything set to default
#   
# -------------------------

#   Connect to Azure + Set Subscription
# -------------------------

    #Connect-AzAccount

    Get-AzSubscription
    Set-AzContext -Subscription 'Visual Studio Enterprise'

# -------------------------

    Get-AzResourceGroup | Select-Object ResourceGroupName, Location
    Get-AzResource | Select-Object Name, ResourceType, ResourceGroupName
    Get-AzVm | Format-Table

#   Variables
# -------------------------

    $LocName    = "westeurope"
    $ResGrpName = "RGVMs"
    $AdminUser  = "xtokoadm"
    $AdminPass  = "xtokodummyP@ss"

#   (Re)Create ResourceGroup
# -------------------------

    $LocName = "westeurope"
    $ResGrpName = "RGVMs"

    if(Get-AzResourceGroup | Where-Object {$_.ResourceGroupName -eq $ResGrpName})
    {Get-AzResourceGroup -Name $ResGrpName | Remove-AzResourceGroup -Verbose}

    New-AzResourceGroup `
        -Name $ResGrpName `
        -Location $LocName

#   Configuration
# -------------------------
 
    #/Config Values
        $VMName              = 'myFirstVM'
        $VirtualNetworkName  = 'myFirstVirtualNetworkName'
        $SubnetName          = 'myFirstSubnetName'
        $SecurityGroupName   = 'myFirstSecurityGroupName'

    #/Admin Credential
        $AdminPassSec = ConvertTo-SecureString $AdminPass `
                            -AsPlainText `
                            -Force
        $Credential = New-Object System.Management.Automation.PSCredential ($AdminUser, $AdminPassSec);

#   CREATE AzVm
# -------------------------

    New-AzVm `
        -ResourceGroupName $ResGrpName `
        -Location $LocName `
        -Credential $Credential `
        -Name $VMName `
        -VirtualNetworkName $VirtualNetworkName `
        -SubnetName $SubnetName `
        -SecurityGroupName $SecurityGroupName `
        -PublicIpAddressName $PublicIpAddressName `
        -OpenPorts 80,3389 `
        -Verbose

#   Check
# -------------------------

    Get-AzVM `
        -ResourceGroupName $ResGrpName

    Get-AzVM `
        -ResourceGroupName $ResGrpName `
        -VMName $VMName