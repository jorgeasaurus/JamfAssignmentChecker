function Get-JamfUserGroup {
    <#
    .SYNOPSIS
        Gets detailed information about a specific user group from JAMF Pro.
    
    .DESCRIPTION
        Retrieves detailed information about a user group including its members.
    
    .PARAMETER GroupId
        The ID of the user group to retrieve.
    
    .PARAMETER GroupName
        The name of the user group to retrieve.
    #>
    param (
        [Parameter(Mandatory = $false)]
        [string]$GroupId,
        
        [Parameter(Mandatory = $false)]
        [string]$GroupName
    )
    
    try {
        if ($GroupId) {
            $endpoint = "usergroups/id/$GroupId"
        } elseif ($GroupName) {
            $endpoint = "usergroups/name/$GroupName"
        } else {
            throw "Either GroupId or GroupName must be specified"
        }
        
        $response = Invoke-JamfApiCall -Endpoint $endpoint -Method "GET"
        
        if ($response -and $response.user_group) {
            return $response.user_group
        } else {
            Write-Host "⚠️  User group not found" -ForegroundColor Yellow
            return $null
        }
    } catch {
        Write-Host "❌ Failed to retrieve user group: $_" -ForegroundColor Red
        return $null
    }
}