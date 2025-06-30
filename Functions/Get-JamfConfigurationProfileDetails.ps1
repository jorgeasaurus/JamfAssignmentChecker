function Get-JamfConfigurationProfileDetails {
    <#
    .SYNOPSIS
        Retrieves detailed information for a specific configuration profile.
    #>
    param (
        [Parameter(Mandatory = $true)]
        [string]$ProfileId
    )
    
    try {
        $response = Invoke-JamfApiCall -BaseUrl $script:Config.BaseUrl `
            -ApiVersion "classic" `
            -Endpoint "osxconfigurationprofiles/id/$ProfileId" `
            -Token $script:Config.Token `
            -XML
        
        return ([xml]$response).os_x_configuration_profile
    } catch {
        Write-Host "Failed to get profile details for ID $ProfileId : $_" -ForegroundColor Red
        return $null
    }
}
