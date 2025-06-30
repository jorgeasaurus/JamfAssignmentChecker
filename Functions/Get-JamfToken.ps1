function Get-JamfToken {
    # Function to get a Jamf authentication token using either OAuth or Basic auth
    param (
        [Parameter(Mandatory = $true)]
        [string]$BaseUrl = $script:Config.BaseUrl, # Base URL of the Jamf instance
        [string]$Username = $script:Config.Username, # Username for Basic auth
        [string]$Password = $script:Config.Password, # Password for Basic auth
        [string]$ClientId = $script:Config.ClientId, # Client ID for OAuth
        [string]$ClientSecret = $script:Config.ClientSecret  # Client secret for OAuth
    )

    # Determine authentication endpoint and setup based on credentials
    if ($ClientId -and $ClientSecret) {
        # Use OAuth authentication if client credentials are provided
        $tokenUrl = "$BaseUrl/api/oauth/token"
        $body = "client_id=$ClientId"
        $body += "&client_secret=$ClientSecret"
        $body += "&grant_type=client_credentials"
        $headers = @{ "Content-Type" = "application/x-www-form-urlencoded" }
    } elseif ($Username -and $Password) {
        # Use Basic authentication if username/password are provided
        $tokenUrl = "$BaseUrl/api/v1/auth/token"
        $base64Auth = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("$($Username):$($Password)"))
        $headers = @{
            "Authorization" = "Basic $base64Auth"
            "Accept"        = "application/json"
        }
    } else {
        throw "Must provide either Username/Password or ClientId/ClientSecret."
    }

    Write-Host "🔐 Requesting authentication token..." -ForegroundColor Cyan -NoNewline

    try {
        # Make the token request
        $tokenSplat = @{
            Uri             = $tokenUrl
            Method          = 'Post'
            Body            = $body
            Headers         = $headers
            UseBasicParsing = $true
        }
        $response = Invoke-WebRequest @tokenSplat
        # Extract token from response, handling both OAuth and Basic auth response formats
        $token = ($response.Content | ConvertFrom-Json).PSObject.Properties["access_token", "token"].Where({ $_.Value }).Value

        Write-Host " ✅" -ForegroundColor Green
        return $token
    } catch {
        if ($_.Exception.Response.StatusCode -eq 401) {
            Write-Host " ❌" -ForegroundColor Red
            Write-Host "⚠️  Unauthorized access. Please check your credentials." -ForegroundColor Yellow
            throw "Authentication failed: Invalid credentials"
        } else {
            Write-Host " ❌" -ForegroundColor Red
            throw "Authentication error: $_"
        }
    }
}
