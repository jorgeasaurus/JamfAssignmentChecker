function Get-JamfComputer {
    <#
    .SYNOPSIS
        Retrieves computer information by name or id.
    #>
    param (
        [string]$ComputerName,
        [string]$ComputerId
    )
    
    try {

        if ($ComputerId) {
            $Endpoint = "computers/id/$ComputerId"
            $Response = Invoke-JamfApiCall -BaseUrl $script:Config.BaseUrl `
                -ApiVersion "classic" `
                -Endpoint $Endpoint `
                -Token $script:Config.Token

            $computers = $Response.computer
        } else {
            $Endpoint = "computers/match/$ComputerName"
            # First, search for the computer
            $searchResponse = Invoke-JamfApiCall -BaseUrl $script:Config.BaseUrl `
                -ApiVersion "classic" `
                -Endpoint $Endpoint `
                -Token $script:Config.Token `
                -XML
        
            $computers = ([xml]$searchResponse).computers.computer
        }


        
        if ($computers) {
            # If we used ComputerId, we already have the full computer object
            if ($ComputerId) {
                return $computers
            }
            
            # For ComputerName search, we need to get details
            # If multiple matches, try exact match
            if ($computers.Count -gt 1) {
                $exactMatch = $computers | Where-Object { $_.name -eq $ComputerName }
                if ($exactMatch) {
                    return Get-JamfComputerDetails -ComputerId $exactMatch.id
                }
            }
            
            # Return first match
            if ($computers.Count -gt 1) {
                return Get-JamfComputerDetails -ComputerId $computers[0].id
            } else {
                return Get-JamfComputerDetails -ComputerId $computers.id
            }
        }
        
        return $null
    } catch {
        Write-Host "Failed to find computer '$ComputerName': $_" -ForegroundColor Red
        return $null
    }
}
