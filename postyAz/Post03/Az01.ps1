
# Resource Group Configuration Variables
# --------------------------------------------------------------------------

    $ResGrpName = "SqlRG01"
    $LocName    = "westeurope"
    $EPNameDTU  = "myElasticPool_DTU"
    $EPNameVCr  = "myElasticPool_vCore"

    $Srv = Get-AzSqlServer `
            -ResourceGroupName $ResGrpName |
                Select-Object -First 1

    $SrvName = $Srv.ServerName

# Create Elastic Pool (DTU)
# https://docs.microsoft.com/pl-pl/azure/azure-sql/database/elastic-pool-overview
# 
# The default values for the different DTU editions are as follows:
#  - Basic. 100 DTUs
#  - Standard. 100 DTUs
#  - Premium. 125 DTUs
# --------------------------------------------------------------------------

    New-AzSqlElasticPool `
        -ResourceGroupName $ResGrpName `
        -ServerName $SrvName `
        -ElasticPoolName $EPNameDTU `
        -Edition "Standard" `
        -Dtu 50 `
        -DatabaseDtuMin 10 `
        -DatabaseDtuMax 20

# Create Elastic Pool (vCore)
# 
#  - GeneralPurpose
#  - BusinessCritical
# --------------------------------------------------------------------------

    New-AzSqlElasticPool `
        -ResourceGroupName $ResGrpName `
        -ServerName $SrvName `
        -ElasticPoolName $EPNameVCr `
        -Edition "GeneralPurpose" `
        -vCore 2 `
        -ComputeGeneration Gen5

# Verify
# --------------------------------------------------------------------------

    Get-AzSqlElasticPool `
        -ResourceGroupName $ResGrpName `
        -ServerName $SrvName | Select-Object -Property ResourceGroupName, ServerName, ElasticPoolName | Format-Table
    
    # Remove-AzSqlElasticPool `
    #     -ResourceGroupName $ResGrpName `
    #     -ServerName $SrvName `
    #     -ElasticPoolName $EPNameDTU

# Create Database
# AdventureWorksLT is a build in Sample DB in Azure - Like on-prem Contoso/AW 
# --------------------------------------------------------------------------

    @(1,2,3) | ForEach-Object {$d = New-AzSqlDatabase `
                                        -ResourceGroupName $ResGrpName `
                                        -ServerName $SrvName `
                                        -DatabaseName "myDatabaseEP$($_)" `
                                        -SampleName "AdventureWorksLT" `
                                        -ElasticPoolName $EPNameDTU
                                
                                    Write-Information "database $($_) created." `
                                        -InformationAction 'Continue'
                                }

    @(7,8,9) | ForEach-Object {$d = New-AzSqlDatabase `
                                        -ResourceGroupName $ResGrpName `
                                        -ServerName $SrvName `
                                        -DatabaseName "myDatabaseEP$($_)" `
                                        -SampleName "AdventureWorksLT" `
                                        -ElasticPoolName $EPNameVCr
                                
                                    Write-Information "database $($_) created." `
                                        -InformationAction 'Continue'
                                }
# Verify
# --------------------------------------------------------------------------

    Get-AzSqlDatabase  `
        -ResourceGroupName $ResGrpName `
        -ServerName $SrvName |
            Select-Object -Property ResourceGroupName, ServerName, DatabaseName, Edition, ElasticPoolName |
            Format-Table


# Clean-up
# --------------------------------------------------------------------------

    Remove-AzResourceGroup $ResGrpName -Verbose
