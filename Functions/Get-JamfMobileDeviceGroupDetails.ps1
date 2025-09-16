function Get-JamfMobileDeviceGroupDetails {
    <#
    .SYNOPSIS
        Retrieves detailed information for a specific mobile device group.
    #>
    param (
        [Parameter(Mandatory = $true)]
        [string]$GroupId
    )
    
    try {
        $response = Invoke-JamfApiCall -BaseUrl $script:Config.BaseUrl `
            -ApiVersion "classic" `
            -Endpoint "mobiledevicegroups/id/$GroupId" `
            -Token $script:Config.Token `
            -XML
        
        return ([xml]$response).mobile_device_group
    } catch {
        Write-Host "Failed to get mobile device group details for ID $GroupId : $_" -ForegroundColor Red
        return $null
    }
}
