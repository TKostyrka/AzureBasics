    Get-AzVMImagePublisher -Location westeurope | 
        Where-Object{$_.PublisherName -eq "Canonical"}

    Get-AzVMImageOffer `
        -Location westeurope `
        -PublisherName "Canonical" |
            Where-Object{$_.Offer -eq "UbuntuServer"}

    # LTS is an abbreviation for “Long Term Support”

    Get-AzVMImageSku `
        -Location westeurope `
        -PublisherName "Canonical" `
        -Offer "UbuntuServer" |
            Where-Object{$_.Skus -eq "18.04-LTS"}

    Get-AzVMImage `
        -Location westeurope `
        -PublisherName "Canonical" `
        -Offer "UbuntuServer" `
        -Skus "18.04-LTS" | Sort-Object Version -Desc | Select-Object -First 1

    Get-AzVMImage `
        -Location westeurope `
        -PublisherName "Canonical" `
        -Offer "UbuntuServer" `
        -Skus "16.04-LTS" `
        -Version "16.04.202006100"

# http://tech-trainer.info/how-to-find-available-vm-sizes/
# -----------------------------------------------------------------------------


    Get-AzVMSize `
        -Location westeurope

    Get-AzComputeResourceSku | Where-Object{ $_.Locations -eq "westeurope" -and                  
                                             $_.ResourceType -eq "virtualMachines" -and            
                                             $_.Restrictions.ReasonCode -ne 'NotAvailableForSubscription'
                                             } | Sort-Object Name

