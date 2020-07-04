
# Resource Group Configuration Variables
# --------------------------------------------------------------------------

    $ResGrpName = "SqlRG01"
    $LocName    = "westeurope"

# Create ResourceGroup
# --------------------------------------------------------------------------

    New-AzResourceGroup `
        -Name $ResGrpName `
        -Location $LocName

# SQL Configuration Variables
# --------------------------------------------------------------------------

    $SrvName    = "mysrv$(Get-Random)"    
    $DBName     = "mydb"
    $AdminUser  = "dummyadm"
    $AdminPass  = "MyDummyP@ss"

# Admin Credential - Create SecureString and PSCredential object
# --------------------------------------------------------------------------

    $AdmPassSec = ConvertTo-SecureString `
                    -String $AdminPass `
                    -AsPlainText `
                    -Force

    $Creds = New-Object `
                -TypeName System.Management.Automation.PSCredential `
                -ArgumentList $AdminUser, $AdmPassSec

# Create SQL Server (PAAS) with Admin Credentials defined before
# --------------------------------------------------------------------------

    $SrvInstance = New-AzSqlServer `
                    -ResourceGroupName $ResGrpName `
                    -ServerName $SrvName `
                    -Location $LocName `
                    -SqlAdministratorCredentials $Creds

# Verify
# --------------------------------------------------------------------------
    
    Get-AzSqlServer `
        -ResourceGroupName $ResGrpName |
            Select-Object -Property ResourceGroupName, ServerName, SqlAdministratorLogin, Location |
            Format-Table

    $SrvInstance.FullyQualifiedDomainName

# Set Firewall rule to enable access to the server
# NEVER set this kind of IP boundaries (0 - 255) on TST/LIVE servers
# --------------------------------------------------------------------------
    
    $IpFrom  = "0.0.0.0"
    $IpTo    = "255.255.255.255"

    $serverFirewallRule = New-AzSqlServerFirewallRule `
                            -ResourceGroupName $ResGrpName `
                            -ServerName $SrvName `
                            -FirewallRuleName "AllowedIPs" `
                            -StartIpAddress $IpFrom `
                            -EndIpAddress $IpTo

# Verify
# --------------------------------------------------------------------------

    Get-AzSqlServerFirewallRule `
        -ResourceGroupName $ResGrpName `
        -ServerName $SrvName