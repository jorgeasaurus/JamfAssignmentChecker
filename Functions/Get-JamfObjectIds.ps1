function Get-JamfObjectIds {
    param (
        [string]$Resource
    )

    # Invoke the Jamf API call to get the response
    $apiVersion = switch ($Resource) {
        "computer-prestages" { "v3" }
        "patch-software-title-configurations" { "v2" }
        default { "classic" }
    }
    $response = Invoke-JamfApiCall -Endpoint $Resource -Method "GET" -ApiVersion $ApiVersion

    if (-not $response) {
        Write-Host "No response received for resource: $Resource" -ForegroundColor Red
        return $null
    }

    # Get the first NoteProperty from the response
    $firstProperty = $response | Get-Member -MemberType NoteProperty | Select-Object -First 1

    if (-not $firstProperty) {
        Write-Host "No NoteProperties found in response for resource: $Resource" -ForegroundColor Yellow
        return $null
    }

    # Extract the value of the first NoteProperty and get the IDs
    $objects = $response.$($firstProperty.Name)

    # Uncomment if you want to export smart groups along with static groups
    # if ($Resource -in "computergroups", "mobiledevicegroups") {
    #     return ($objects | Where-Object { -not $_.is_smart }).id
    # }

    # For computer-prestages, the property is 'results' with a nested structure
    if ($Resource -eq "computer-prestages") {
        return $objects.id
    }

    # Default case: return the IDs directly from the first NoteProperty
    return $objects.id
}
