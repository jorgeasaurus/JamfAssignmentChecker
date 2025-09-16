function Invoke-JamfApiCall {
    # Function to make API calls to Jamf Pro
    param (
        [string]$BaseUrl = $script:Config.BaseUrl,
        [string]$ApiVersion = $script:Config.ApiVersion,
        [string]$Endpoint,
        [string]$Method = "GET",
        [string]$Body,
        [string]$Token = $script:Config.Token,
        [switch]$XML
    )

    # Validate token exists
    if (-not $Token) { throw "No token provided." }

    # Build the full API URL
    $urlSplat = @{
        BaseUrl    = $BaseUrl
        ApiVersion = $ApiVersion
        Endpoint   = $Endpoint
    }
    $fullUrl = Get-JamfApiUrl @urlSplat

    # Set content type based on XML switch
    $contentType = if ($XML) { "application/xml" } else { "application/json" }
    $accept = if ($XML) { "text/xml" } else { "application/json" }

    # Prepare request headers
    $headers = @{
        "Authorization" = "Bearer $Token"
        "Content-Type"  = $contentType
        "Accept"        = $accept
    }

    # Build API request parameters
    $apiSplat = @{
        URI             = $fullUrl
        Method          = $Method
        Headers         = $headers
        UseBasicParsing = $true
    }
    
    # Add body if provided
    if ($Body) {
        $apiSplat.Add("Body", $Body)
    }

    try {
        # Make the API request
        $response = Invoke-WebRequest @apiSplat

        # Return response based on format
        if ($XML) {
            return $response.Content
        } else {
            return ($response.Content | ConvertFrom-Json)
        }
    } catch {
        # Handle token expiration
        if ($_.Exception.Response.StatusCode -eq 401) {
            Write-Host "Token expired. Renewing token..."
            $script:Config.Token = Get-JamfToken -BaseUrl $BaseUrl
            $headers["Authorization"] = "Bearer $script:Config.Token"
            $apiSplat["Headers"] = $headers

            try {
                # Retry request with new token
                $response = Invoke-WebRequest @apiSplat

                if ($XML) {
                    return $response.Content
                } else {
                    return ($response.Content | ConvertFrom-Json)
                }
            } catch {
                throw "API Error ($Method $fullUrl): $_"
            }
        } else {
            throw "API Error ($Method $fullUrl): $_"
        }
    }
}
