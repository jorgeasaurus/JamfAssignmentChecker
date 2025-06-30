function Get-JamfPolicies {
    <#
    .SYNOPSIS
        Retrieves all policies from JAMF Pro.
    #>
    try {
        Write-Host "Fetching policies..." -ForegroundColor Cyan -NoNewline
        
        $response = Invoke-JamfApiCall -BaseUrl $script:Config.BaseUrl `
            -ApiVersion "classic" `
            -Endpoint "policies" `
            -Token $script:Config.Token `
            -XML
        
        $policies = ([xml]$response).policies.policy
        Write-Host " Found $($policies.Count) policies" -ForegroundColor Green
        return $policies
    } catch {
        Write-Host " Failed!" -ForegroundColor Red
        Write-Host "Error: $_" -ForegroundColor Red
        return @()
    }
}
