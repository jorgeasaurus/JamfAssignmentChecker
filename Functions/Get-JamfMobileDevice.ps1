function Get-JamfMobileDevice {
    <#
    .SYNOPSIS
        Retrieves mobile device information by name.
    #>
    param (
        [Parameter(Mandatory = $true)]
        [string]$MobileDeviceName
    )
    
    try {
        # First, search for the mobile device
        $searchResponse = Invoke-JamfApiCall -BaseUrl $script:Config.BaseUrl `
            -ApiVersion "classic" `
            -Endpoint "mobiledevices/match/$MobileDeviceName" `
            -Token $script:Config.Token `
            -XML
        
        $mobileDevices = ([xml]$searchResponse).mobile_devices.mobile_device
        
        if ($mobileDevices) {
            # If multiple matches, try exact match
            if ($mobileDevices.Count -gt 1) {
                $exactMatch = $mobileDevices | Where-Object { $_.name -eq $MobileDeviceName }
                if ($exactMatch) {
                    return Get-JamfMobileDeviceDetails -MobileDeviceId $exactMatch.id
                }
            }
            
            # Return first match
            if ($mobileDevices.Count) {
                return Get-JamfMobileDeviceDetails -MobileDeviceId $mobileDevices[0].id
            } else {
                return Get-JamfMobileDeviceDetails -MobileDeviceId $mobileDevices.id
            }
        }
        
        return $null
    } catch {
        Write-Host "Failed to find mobile device '$MobileDeviceName': $_" -ForegroundColor Red
        return $null
    }
}
