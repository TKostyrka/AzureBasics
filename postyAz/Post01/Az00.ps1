# Check which Az.* modules are installed
# --------------------------------------------------------------------------

    Get-Module -ListAvailable | Where-Object {$_.Name -like 'Az.*'}

# Install missing modules
# --------------------------------------------------------------------------
# Az.Accounts:  Manages credentials and common configuration for all Azure modules.
# Az.Resources: Manages subscriptions, tenants, resource groups, deployment templates...
# Az.Compute:   Manages virtual machines, hosted services, and related resources...
# Az.Network:   Networking service cmdlets
# Az.Sql:       SQL service cmdlets
# --------------------------------------------------------------------------

    Install-Module Az.Accounts -Force
    Install-Module Az.Resources -Force
    Install-Module Az.Compute -Force
    Install-Module Az.Network -Force
    Install-Module Az.Sql -Force

# You can also install everything at once using:
# --------------------------------------------------------------------------

    Install-Module Az -Force

# To uninstall a Module:
# --------------------------------------------------------------------------
    
    Uninstall-Module Az.Sql