function Get-JamfComputerDetails {
    <#
    .SYNOPSIS
        Retrieves detailed information for a specific computer.
    #>
    param (
        [Parameter(Mandatory = $true)]
        [string]$ComputerId
    )
    
    try {
        $response = Invoke-JamfApiCall -BaseUrl $script:Config.BaseUrl `
            -ApiVersion "classic" `
            -Endpoint "computers/id/$ComputerId" `
            -Token $script:Config.Token `
            -XML
        
        return ([xml]$response).computer
    } catch {
        Write-Host "Failed to get computer details for ID $ComputerId : $_" -ForegroundColor Red
        return $null
    }
}
