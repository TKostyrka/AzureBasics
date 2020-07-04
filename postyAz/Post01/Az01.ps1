
# Connect to Azure
# You'll receive a sign-in dialog to provide a username and password for your Azure account
# You can connect from outside of your SaxoVM but 2FA will be required in this case
# --------------------------------------------------------------------------

    Connect-AzAccount

# List all available subscriptions
# Pick the subscription used in current session
# MSDN owners can acticvate a 'Visual Studio Enterprise' subscription with 950 DKKs per month
# --------------------------------------------------------------------------

    Get-AzSubscription
    Set-AzContext -Subscription 'Visual Studio Enterprise'

# Check all the available Resource Groups & Resources
# --------------------------------------------------------------------------

    Get-AzResourceGroup | `
        Select-Object ResourceGroupName, Location
    
    Get-AzResource | `
        Select-Object Name, ResourceType, ResourceGroupName

# Create a new Resource Group in WestEurope
# Verify if the RG was created correctly
# --------------------------------------------------------------------------

    New-AzResourceGroup `
        -Name "MyDummyRG" `
        -Location "westeurope"
    
    Get-AzResourceGroup | `
        Select-Object ResourceGroupName, Location

# Drop RG, -Force flag to run without asking for user confirmation.
# Verify
# --------------------------------------------------------------------------

    Remove-AzResourceGroup "MyDummyRG" -Force

    Get-AzResourceGroup | `
        Select-Object ResourceGroupName, Location