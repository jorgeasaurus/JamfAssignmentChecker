function Get-JamfObject {
    param (
        [string]$Id, # Unique identifier of the Jamf object
        [string]$Resource   # Type of resource (e.g., policies, scripts, computer-prestages)
    )

    # Determine API version - computer-prestages uses v3, others use classic API
    $apiVersion = if ($Resource -eq "computer-prestages") { "v3" } else { "classic" }
    
    # Build endpoint URL - computer-prestages has different format than other resources
    $endpoint = if ($Resource -eq "computer-prestages") { "$Resource/$Id" } else { "$Resource/id/$Id" }
    
    # Make API call - use XML format for classic API, JSON for v2/v3
    $response = Invoke-JamfApiCall -Endpoint $endpoint -Method "GET" -ApiVersion $apiVersion -XML:($apiVersion -eq "classic")

    # Handle modern API responses (v2/v3)
    if ($apiVersion -match "v2|v3") {
        return @{
            name    = $response.displayName    # Get display name from response
            payload = $response | ConvertTo-Json -Depth 5  # Convert response to JSON
        }
    } 
    # Handle classic API responses
    else {
        $xml = [xml]$response  # Convert response to XML object
        $payload = $xml.DocumentElement.FirstChild.payloads  # Extract payloads
        $name = $xml.SelectSingleNode("//name").InnerText   # Get object name

        # Extract script content if it's a script-related resource
        $script = if ($Resource -eq "scripts") { 
            $xml.SelectSingleNode("//script_contents").InnerText 
        } elseif ($Resource -eq "computerextensionattributes") { 
            $xml.SelectSingleNode("//input_type/script").InnerText 
        } else { 
            $null 
        }

        # Return structured data including name, payload, original XML, and script content
        return @{
            name    = $name
            payload = $payload
            plist   = $response 
            script  = $script
        }
    }
}
