    
    #Get-Module -ListAvailable | Where-Object{$_.Name -like "Az*"}
    #Install-Module Az.Storage -Force

    #Connect-AzAccount
    Get-AzSubscription
    Set-AzContext -Subscription 'Visual Studio Enterprise'

# --------------------------------------------------------------------------

    $LocName      = "westeurope"
    $ResGrpName   = "RGStorAcc"
    $AccountName  = "mystoreacc$(Get-Random)"
    
    New-AzResourceGroup `
        -Name $ResGrpName `
        -Location $LocName

    Get-AzResourceGroup | `
        Select-Object ResourceGroupName, Location, ProvisioningState | `
        Format-Table

# --------------------------------------------------------------------------

    New-AzStorageAccount `
        -ResourceGroupName $ResGrpName `
        -AccountName $AccountName `
        -Location $LocName `
        -Kind StorageV2 `
        -SkuName Standard_GRS `
        -AccessTier Hot

    Get-AzStorageAccount `
        -ResourceGroupName $ResGrpName | `
        Select-Object StorageAccountName, ResourceGroupName, Kind, AccessTier | `
        Format-Table

# --------------------------------------------------------------------------
    
    $st = Get-AzStorageAccount `
            -ResourceGroupName $ResGrpName `
            -Name $AccountName

    ("01","02","03") | ForEach-Object {
                            New-AzStorageContainer `
                                -Name "blobcont$($_)" `
                                -Context $st.Context `
                                -Permission blob
                            }
                
    Get-AzStorageContainer `
        -Context $st.Context


    