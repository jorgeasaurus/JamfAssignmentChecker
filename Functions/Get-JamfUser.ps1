function Get-JamfUser {
    <#
    .SYNOPSIS
        Retrieves user information by username.
    #>
    param (
        [Parameter(Mandatory = $true)]
        [string]$UserName
    )
    
    try {
        # Search for the user
        $searchResponse = Invoke-JamfApiCall -BaseUrl $script:Config.BaseUrl `
            -ApiVersion "classic" `
            -Endpoint "users/name/$UserName" `
            -Token $script:Config.Token `
            -XML
        
        return ([xml]$searchResponse).user
    } catch {
        Write-Host "Failed to find user '$UserName': $_" -ForegroundColor Red
        return $null
    }
}
