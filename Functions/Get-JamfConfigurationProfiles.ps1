function Get-JamfConfigurationProfiles {
    <#
    .SYNOPSIS
        Retrieves all macOS configuration profiles from JAMF Pro.
    #>
    try {
        Write-Host "Fetching macOS configuration profiles..." -ForegroundColor Cyan -NoNewline
        
        $response = Invoke-JamfApiCall -BaseUrl $script:Config.BaseUrl `
            -ApiVersion "classic" `
            -Endpoint "osxconfigurationprofiles" `
            -Token $script:Config.Token `
            -XML
        
        $profiles = ([xml]$response).os_x_configuration_profiles.os_x_configuration_profile
        Write-Host " Found $($profiles.Count) profiles" -ForegroundColor Green
        return $profiles
    } catch {
        Write-Host " Failed!" -ForegroundColor Red
        Write-Host "Error: $_" -ForegroundColor Red
        return @()
    }
}
