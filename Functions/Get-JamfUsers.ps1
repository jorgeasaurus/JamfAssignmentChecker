function Get-JamfUsers {
    <#
    .SYNOPSIS
        Gets all users from JAMF Pro.
    
    .DESCRIPTION
        Retrieves a list of all users from JAMF Pro using the Classic API.
        Returns basic user information including ID, name, and email.
    #>
    
    Write-Host "👥 Fetching all users from JAMF Pro..." -ForegroundColor Cyan
    
    try {
        $response = Invoke-JamfApiCall -Endpoint "users" -Method "GET"
        
        if ($response -and $response.users) {
            # The users are directly in the array, not in a .user property
            $users = @($response.users)
            Write-Host "✅ Found $($users.Count) users" -ForegroundColor Green
            return $users
        } else {
            Write-Host "⚠️  No users found in JAMF Pro" -ForegroundColor Yellow
            return @()
        }
    } catch {
        Write-Host "❌ Failed to retrieve users: $_" -ForegroundColor Red
        throw $_
    }
}