function Get-JamfPolicyDetails {
    <#
    .SYNOPSIS
        Retrieves detailed information for a specific policy.
    #>
    param (
        [Parameter(Mandatory = $true)]
        [string]$PolicyId
    )
    
    try {
        $response = Invoke-JamfApiCall -BaseUrl $script:Config.BaseUrl `
            -ApiVersion "classic" `
            -Endpoint "policies/id/$PolicyId" `
            -Token $script:Config.Token `
            -XML
        
        return ([xml]$response).policy
    } catch {
        Write-Host "Failed to get policy details for ID $PolicyId : $_" -ForegroundColor Red
        return $null
    }
}
