
#   Create a Linux Ubuntu VM
#   
# -------------------------

    #to-do
    # - auto shutdown
    # - configure DNS

#   Connect
# -------------------------

    Connect-AzAccount

    Get-AzSubscription
    Set-AzContext -Subscription 'Visual Studio Enterprise'

# -------------------------

    Get-AzResourceGroup | Select-Object ResourceGroupName, Location
    Get-AzResource | Select-Object Name, ResourceType, ResourceGroupName
    Get-AzVm | Format-Table

#   Variables
# -------------------------

    $LocName      = "westeurope"
    $ResGrpName   = "RGVMs"

    $VNSubnetName = "VNSubnet"
    $VNetName     = "myVNET"
    $VMName       = "LinuxVM"

    $AdminUser    = "xtokoadm"
    $AdminPass    = "xtokodummyP@ss"


#   (Re)Create ResourceGroup
# -------------------------

    if(Get-AzResourceGroup | Where-Object {$_.ResourceGroupName -eq $ResGrpName})
    {
        Get-AzResourceGroup -Name $ResGrpName | 
            Remove-AzResourceGroup -Verbose
    }

    New-AzResourceGroup `
        -Name $ResGrpName `
        -Location $LocName


#   SubNet, VNet, PublicIP
# -------------------------

    # Create a subnet configuration
    # -------------------------
        $subnetConfig = New-AzVirtualNetworkSubnetConfig `
          -Name $VNSubnetName `
          -AddressPrefix 192.168.1.0/24

    # Create a virtual network
    # -------------------------
        $vnet = New-AzVirtualNetwork `
          -ResourceGroupName $ResGrpName `
          -Location $LocName `
          -Name $VNetName `
          -AddressPrefix 192.168.0.0/16 `
          -Subnet $subnetConfig

    # Create a public IP address and specify a DNS name
    # -------------------------
        $pip = New-AzPublicIpAddress `
          -ResourceGroupName $ResGrpName `
          -Location $LocName `
          -AllocationMethod Static `
          -IdleTimeoutInMinutes 4 `
          -Name "mypublicdns$(Get-Random)"

#   Network Security
# -------------------------
 
    # Create an inbound network security group rule for port 22
    # -------------------------
        $nsgRuleSSH = New-AzNetworkSecurityRuleConfig `
          -Name "myNetworkSecurityGroupRuleSSH"  `
          -Protocol "Tcp" `
          -Direction "Inbound" `
          -Priority 1000 `
          -SourceAddressPrefix * `
          -SourcePortRange * `
          -DestinationAddressPrefix * `
          -DestinationPortRange 22 `
          -Access "Allow"

    # Create an inbound network security group rule for port 80
    # -------------------------
        $nsgRuleWeb = New-AzNetworkSecurityRuleConfig `
          -Name "myNetworkSecurityGroupRuleWWW"  `
          -Protocol "Tcp" `
          -Direction "Inbound" `
          -Priority 1001 `
          -SourceAddressPrefix * `
          -SourcePortRange * `
          -DestinationAddressPrefix * `
          -DestinationPortRange 80 `
          -Access "Allow"

    # Create a network security group
    # -------------------------
        $nsg = New-AzNetworkSecurityGroup `
          -ResourceGroupName $ResGrpName `
          -Location $LocName `
          -Name "myNetworkSecurityGroup" `
          -SecurityRules $nsgRuleSSH,$nsgRuleWeb

#   NetworkInterface
# -------------------------

    # Create a virtual network card and associate with public IP address and NSG
    # -------------------------
        $nic = New-AzNetworkInterface `
          -Name "myNic" `
          -ResourceGroupName $ResGrpName `
          -Location $LocName `
          -SubnetId $vnet.Subnets[0].Id `
          -PublicIpAddressId $pip.Id `
          -NetworkSecurityGroupId $nsg.Id

#   VMConfig
# -------------------------
    

    # Define a credential object
    # -------------------------
        $AdminPassSec = ConvertTo-SecureString $AdminPass `
                            -AsPlainText `
                            -Force
        $cred = New-Object System.Management.Automation.PSCredential ($AdminUser, $AdminPassSec)

    # Create a VM configuration
    # -------------------------
        $vmConfig = New-AzVMConfig `
          -VMName $VMName `
          -VMSize "Standard_D2s_v3" | `
        Set-AzVMOperatingSystem `
          -Linux `
          -ComputerName $VMName `
          -Credential $cred | `
        Set-AzVMSourceImage `
          -PublisherName "Canonical" `
          -Offer "UbuntuServer" `
          -Skus "16.04-LTS" `
          -Version "latest" | `
        Add-AzVMNetworkInterface `
          -Id $nic.Id


    # Create a VM configuration
    # -------------------------
        New-AzVM `
          -ResourceGroupName $ResGrpName  `
          -Location $LocName `
          -VM $vmConfig

#   Check
# -------------------------

    Get-AzVM `
        -ResourceGroupName $ResGrpName

    Get-AzVM `
        -ResourceGroupName $ResGrpName `
        -VMName $VMName