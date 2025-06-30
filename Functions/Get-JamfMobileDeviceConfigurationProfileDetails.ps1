function Get-JamfMobileDeviceConfigurationProfileDetails {
    <#
    .SYNOPSIS
        Retrieves detailed information for a specific mobile device configuration profile.
    #>
    param (
        [Parameter(Mandatory = $true)]
        [string]$ProfileId
    )
    
    try {
        $response = Invoke-JamfApiCall -BaseUrl $script:Config.BaseUrl `
            -ApiVersion "classic" `
            -Endpoint "mobiledeviceconfigurationprofiles/id/$ProfileId" `
            -Token $script:Config.Token `
            -XML
        
        return ([xml]$response).configuration_profile
    } catch {
        Write-Host "Failed to get mobile profile details for ID $ProfileId : $_" -ForegroundColor Red
        return $null
    }
}
