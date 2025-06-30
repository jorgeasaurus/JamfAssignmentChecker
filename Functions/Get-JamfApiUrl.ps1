function Get-JamfApiUrl {
    # Function to construct Jamf API URLs based on version and endpoint
    param (
        [string]$BaseUrl, # Base URL of the Jamf instance
        [string]$ApiVersion, # API version to use (v1, v2, v3, or classic)
        [string]$Endpoint      # API endpoint to call
    )
    # Return appropriate URL format based on API version
    switch ($ApiVersion) {
        "v1" { "$BaseUrl/api/v1/$Endpoint" }      # Modern v1 API format
        "v2" { "$BaseUrl/api/v2/$Endpoint" }      # Modern v2 API format 
        "v3" { "$BaseUrl/api/v3/$Endpoint" }      # Modern v3 API format
        "classic" { "$BaseUrl/JSSResource/$Endpoint" }  # Legacy API format
        default { throw "Invalid ApiVersion. Use 'v1', 'v2', or 'classic'." }
    }
}
