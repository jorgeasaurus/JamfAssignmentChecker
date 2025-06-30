function Get-JamfComputerGroupDetails {
    <#
    .SYNOPSIS
        Retrieves detailed information for a specific computer group.
    #>
    param (
        [Parameter(Mandatory = $true)]
        [string]$GroupId
    )
    
    try {
        $response = Invoke-JamfApiCall -BaseUrl $script:Config.BaseUrl `
            -ApiVersion "classic" `
            -Endpoint "computergroups/id/$GroupId" `
            -Token $script:Config.Token `
            -XML
        
        return ([xml]$response).computer_group
    } catch {
        Write-Host "Failed to get group details for ID $GroupId : $_" -ForegroundColor Red
        return $null
    }
}
