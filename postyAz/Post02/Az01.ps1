
# Create a Linux Ubuntu Server VM
# --------------------------------------------------------------------------

    #to-do
    # - auto shutdown
    # - no backup

# Connect & Set Subscription Context
# --------------------------------------------------------------------------

    #Connect-AzAccount

    Get-AzSubscription
    Set-AzContext -Subscription 'Visual Studio Enterprise'

# Configuration Variables
# --------------------------------------------------------------------------

    $LocName      = "westeurope"
    $ResGrpName   = "RGVMs"

    $VMName       = "MyLinuxVM"
    $VMDomainName = "mylinuxvm$(Get-Random)"
    $VNetName     = "$($VMName)VNet"
    $VNSubnetName = "$($VMName)VNetSubnet"

    $AdminUser    = "dummyadm"
    $AdminPass    = "MyDummyP@ss"


# (Re)Create ResourceGroup
# --------------------------------------------------------------------------

    #if(Get-AzResourceGroup | Where-Object {$_.ResourceGroupName -eq $ResGrpName})
    #{
    #    Get-AzResourceGroup -Name $ResGrpName | 
    #        Remove-AzResourceGroup -Verbose
    #}
    
    New-AzResourceGroup `
        -Name $ResGrpName `
        -Location $LocName

# Create Resources
# --------------------------------------------------------------------------
 
    # Microsoft.Network/virtualNetworks 
    # Microsoft.Network/publicIPAddresses   
    # Microsoft.Network/networkSecurityGroups
    # Microsoft.Network/networkInterfaces   

# Virtual Network
# --------------------------------------------------------------------------
# https://docs.microsoft.com/en-us/azure/virtual-network/virtual-networks-overview
# --------------------------------------------------------------------------

    $sNetConfig = New-AzVirtualNetworkSubnetConfig `
                        -Name $VNSubnetName `
                        -AddressPrefix 192.168.1.0/24

    $vNet = New-AzVirtualNetwork `
                -ResourceGroupName $ResGrpName `
                -Location $LocName `
                -Name $VNetName `
                -AddressPrefix 192.168.0.0/16 `
                -Subnet $sNetConfig

# Public IP address
# --------------------------------------------------------------------------
# Public IP addresses allow Internet resources to communicate inbound to Azure resources.
# https://docs.microsoft.com/en-us/azure/virtual-network/virtual-network-ip-addresses-overview-arm
# --------------------------------------------------------------------------

    $PublicIp = New-AzPublicIpAddress `
                    -ResourceGroupName $ResGrpName `
                    -Location $LocName `
                    -Name "$($VMName)PublicIp$(Get-Random)" `
                    -DomainNameLabel $VMDomainName `
                    -AllocationMethod Static `
                    -IdleTimeoutInMinutes 4 

# Network Security Rules
# --------------------------------------------------------------------------
# Create an inbound network security group rule for port 22 
# to enable connection via SSH
# --------------------------------------------------------------------------

    $NSRuleSSH = New-AzNetworkSecurityRuleConfig `
                        -Name "NSGroupRuleSSH"  `
                        -Protocol "Tcp" `
                        -Direction "Inbound" `
                        -Priority 1000 `
                        -SourceAddressPrefix * `
                        -SourcePortRange * `
                        -DestinationAddressPrefix * `
                        -DestinationPortRange 22 `
                        -Access "Allow"

# Create an inbound network security group rule for port 80 
# to enable connection via HTTP
# --------------------------------------------------------------------------

    $NSRuleWeb = New-AzNetworkSecurityRuleConfig `
                        -Name "NSGroupRuleWWW"  `
                        -Protocol "Tcp" `
                        -Direction "Inbound" `
                        -Priority 1001 `
                        -SourceAddressPrefix * `
                        -SourcePortRange * `
                        -DestinationAddressPrefix * `
                        -DestinationPortRange 80 `
                        -Access "Allow"

# Create an inbound network security group rule for port 3389 
# to enable connection via RDP
# --------------------------------------------------------------------------

    $NSRuleRDP = New-AzNetworkSecurityRuleConfig `
                        -Name "NSGroupRuleRDP"  `
                        -Protocol "*" `
                        -Direction "Inbound" `
                        -Priority 1002 `
                        -SourceAddressPrefix * `
                        -SourcePortRange * `
                        -DestinationAddressPrefix * `
                        -DestinationPortRange 3389 `
                        -Access "Allow"

# Create an inbound network security group rule for port 443 
# to enable connection via SSL
# --------------------------------------------------------------------------

    $NSRuleSSL = New-AzNetworkSecurityRuleConfig `
                        -Name "NSGroupRuleSSL"  `
                        -Protocol "*" `
                        -Direction "Inbound" `
                        -Priority 1003 `
                        -SourceAddressPrefix * `
                        -SourcePortRange * `
                        -DestinationAddressPrefix * `
                        -DestinationPortRange 443 `
                        -Access "Allow"

# Network Security Group
# --------------------------------------------------------------------------
# https://azure.microsoft.com/pl-pl/blog/network-security-groups/
# https://docs.microsoft.com/en-us/azure/virtual-network/virtual-network-vnet-plan-design-arm
# --------------------------------------------------------------------------

    $NetSG = New-AzNetworkSecurityGroup `
                -ResourceGroupName $ResGrpName `
                -Location $LocName `
                -Name "$($VMName)NetworkSG" `
                -SecurityRules $NSRuleSSH,$NSRuleWeb,$NSRuleRDP,$NSRuleSSL

# Network Interface
# --------------------------------------------------------------------------
# A Network Interface (NIC) is an interconnection between a Virtual Machine and the underlying software network.
# An Azure Virtual Machine (VM) has one or more network interfaces (NIC) attached to it. 
# Any NIC can have one or more static or dynamic public and private IP addresses assigned to it.
# Create a virtual network card and associate it with Public IP Address and Network Security Group
# --------------------------------------------------------------------------

    $NInt = New-AzNetworkInterface `
                -Name "$($VMName)Nic" `
                -ResourceGroupName $ResGrpName `
                -Location $LocName `
                -SubnetId $vNet.Subnets[0].Id `
                -PublicIpAddressId $PublicIp.Id `
                -NetworkSecurityGroupId $NetSG.Id

# Define a credential object
# --------------------------------------------------------------------------

    $AdminPassSec = ConvertTo-SecureString $AdminPass `
                        -AsPlainText `
                        -Force
    $cred = New-Object System.Management.Automation.PSCredential ($AdminUser, $AdminPassSec)

# VMConfig
# --------------------------------------------------------------------------
# The New-AzVMConfig cmdlet creates a configurable local virtual machine object for Azure. 
# Other cmdlets can be used to configure a virtual machine object, such as:
#  - Set-AzVMOperatingSystem
#  - Set-AzVMSourceImage
#  - Add-AzVMNetworkInterface
#  - Set-AzVMOSDisk.
# --------------------------------------------------------------------------
    
    $vmConfig = New-AzVMConfig `
                    -VMName $VMName `
                    -VMSize "Standard_D2s_v3" | 
                Set-AzVMOperatingSystem `
                    -Linux `
                    -ComputerName $VMName `
                    -Credential $cred | 
                Set-AzVMSourceImage `
                    -PublisherName "Canonical" `
                    -Offer "UbuntuServer" `
                    -Skus "16.04-LTS" `
                    -Version "latest" | 
                Add-AzVMNetworkInterface `
                    -Id $NInt.Id |
                Set-AzVMOSDisk `
                    -Name "$($VMName)Disc" `
                    -Caching ReadWrite `
                    -CreateOption FromImage

# Create VM
# --------------------------------------------------------------------------
# The New-AzVM cmdlet creates a virtual machine in Azure. 
# This cmdlet takes a virtual machine object as input. 
# Use the New-AzVMConfig cmdlet to create a virtual machine object.
# --------------------------------------------------------------------------
    
    New-AzVM `
        -ResourceGroupName $ResGrpName  `
        -Location $LocName `
        -VM $vmConfig

#   Check
# --------------------------------------------------------------------------

    Get-AzResource `
        -ResourceGroupName $ResGrpName | Format-Table

    Get-AzVM `
        -ResourceGroupName $ResGrpName `
        -VMName $VMName