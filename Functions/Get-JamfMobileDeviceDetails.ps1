function Get-JamfMobileDeviceDetails {
    <#
    .SYNOPSIS
        Retrieves detailed information for a specific mobile device.
    #>
    param (
        [Parameter(Mandatory = $true)]
        [string]$MobileDeviceId
    )
    
    try {
        $response = Invoke-JamfApiCall -BaseUrl $script:Config.BaseUrl `
            -ApiVersion "classic" `
            -Endpoint "mobiledevices/id/$MobileDeviceId" `
            -Token $script:Config.Token `
            -XML
        
        return ([xml]$response).mobile_device
    } catch {
        Write-Host "Failed to get mobile device details for ID $MobileDeviceId : $_" -ForegroundColor Red
        return $null
    }
}
