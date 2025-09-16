function Get-JamfComputers {
    <#
    .SYNOPSIS
        Gets all computers from JAMF Pro.
    
    .DESCRIPTION
        Retrieves a list of all computers from JAMF Pro using the Classic API.
        Returns basic computer information including ID, name, and serial number.
    #>
    
    Write-Host "📋 Fetching all computers from JAMF Pro..." -ForegroundColor Cyan
    
    try {
        $response = Invoke-JamfApiCall -Endpoint "computers" -Method "GET"
        
        if ($response -and $response.computers) {
            # The computers are directly in the array, not in a .computer property
            $computers = @($response.computers)
            Write-Host "✅ Found $($computers.Count) computers" -ForegroundColor Green
            return $computers
        } else {
            Write-Host "⚠️  No computers found in JAMF Pro" -ForegroundColor Yellow
            return @()
        }
    } catch {
        Write-Host "❌ Failed to retrieve computers: $_" -ForegroundColor Red
        throw $_
    }
}