
# Resource Group Configuration Variables
# --------------------------------------------------------------------------

    $ResGrpName = "BasicSQLRG"
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

# SQL Configuration Variables
# --------------------------------------------------------------------------

    $SrvName = "myfirstsqlsrvxtoko"    
    $DBName  = "myFirstSQLDB"
    $AdmUser = "SqlAdmin"
    $AdmPass = "P@ssword#123"


# Admin Credential - Create SecureString and PSCredential object
# --------------------------------------------------------------------------

    $AdmPassSec = ConvertTo-SecureString `
                    -String $AdmPass `
                    -AsPlainText `
                    -Force

    $Creds = New-Object `
                -TypeName System.Management.Automation.PSCredential `
                -ArgumentList $AdmUser, $AdmPassSec

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


# Create Database
# AdventureWorksLT is a build in Sample DB in Azure - Like on-prem Contoso/AW 
# --------------------------------------------------------------------------

    $database = New-AzSqlDatabase  `
                    -ResourceGroupName $ResGrpName `
                    -ServerName $SrvName `
                    -DatabaseName $DBName `
                    -RequestedServiceObjectiveName "S0" `
                    -SampleName "AdventureWorksLT"

# Verify
# --------------------------------------------------------------------------

    Get-AzSqlDatabase  `
        -ResourceGroupName $ResGrpName `
        -ServerName $SrvName |
            Select-Object -Property ResourceGroupName, ServerName, DatabaseName, Edition |
            Format-Table

# Get the FullyQualifiedDomainName of SQL Server
# connect in SSMS with $AdmUser & $AdmPass
# use SQL Server Authentication
# --------------------------------------------------------------------------

    $FQDN = (Get-AzSqlServer).FullyQualifiedDomainName
    $FQDN

# Clean-up
# --------------------------------------------------------------------------

    Remove-AzResourceGroup $ResGrpName -Verbose
