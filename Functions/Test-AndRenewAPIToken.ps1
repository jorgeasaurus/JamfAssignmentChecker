function Test-AndRenewAPIToken {
    # Function to test if current API token is valid and renew if needed
    param (
        [string]$BaseUrl = $script:Config.BaseUrl,
        [string]$ApiVersion = "v1",
        [string]$Token = $script:Config.Token
    )

    try {
        # Attempt to keep the current token alive
        $keepAliveSplat = @{
            BaseUrl    = $BaseUrl
            ApiVersion = $ApiVersion
            Endpoint   = "auth/keep-alive"
            Method     = "POST"
            Token      = $Token
        }
        $response = Invoke-JamfApiCall @keepAliveSplat
        # If successful, update the token in config
        if ($response.token) {
            $script:Config.Token = $response.token
        } else {
            throw "No token returned from keep-alive request."
        }
    } catch {
        # If keep-alive fails, get a new token
        Write-Host "Attempting to refresh token..."
        $script:Config.Token = Get-JamfToken -BaseUrl $BaseUrl
    }
}
