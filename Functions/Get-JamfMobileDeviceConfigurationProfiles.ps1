function Get-JamfMobileDeviceConfigurationProfiles {
    <#
    .SYNOPSIS
        Retrieves all mobile device configuration profiles from JAMF Pro.
    #>
    try {
        Write-Host "Fetching mobile device configuration profiles..." -ForegroundColor Cyan -NoNewline
        
        $response = Invoke-JamfApiCall -BaseUrl $script:Config.BaseUrl `
            -ApiVersion "classic" `
            -Endpoint "mobiledeviceconfigurationprofiles" `
            -Token $script:Config.Token `
            -XML
        
        $profiles = ([xml]$response).configuration_profiles.configuration_profile
        Write-Host " Found $($profiles.Count) profiles" -ForegroundColor Green
        return $profiles
    } catch {
        Write-Host " Failed!" -ForegroundColor Red
        Write-Host "Error: $_" -ForegroundColor Red
        return @()
    }
}
