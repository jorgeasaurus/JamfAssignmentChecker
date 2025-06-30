function Get-MobileDeviceAssignments {
    <#
    .SYNOPSIS
        Analyzes all configuration profile assignments for a specific mobile device.
    #>
    param (
        [Parameter(Mandatory = $true)]
        [object]$MobileDevice
    )
    
    $assignments = @{
        MobileDeviceName = $MobileDevice.general.name
        MobileDeviceId   = $MobileDevice.general.id
        DeviceType       = $MobileDevice.general.device_type
        OSVersion        = $MobileDevice.general.os_version
        Profiles         = @()
        Applications     = @()
    }
    
    # Get mobile device's group memberships
    $mobileDeviceGroups = @()
    if ($MobileDevice.mobile_device_groups.mobile_device_group) {
        $mobileDeviceGroups = $MobileDevice.mobile_device_groups.mobile_device_group
    }
    
    Write-Host "`nAnalyzing assignments for mobile device: $($MobileDevice.general.name)" -ForegroundColor Cyan
    Write-Host "Device ID: $($MobileDevice.general.id)" -ForegroundColor Gray
    Write-Host "Device Type: $($MobileDevice.general.device_type)" -ForegroundColor Gray
    Write-Host "OS Version: $($MobileDevice.general.os_version)" -ForegroundColor Gray
    Write-Host "Group Memberships: $($mobileDeviceGroups.Count)" -ForegroundColor Gray
    
    # Check all mobile device configuration profiles
    $profiles = Get-JamfMobileDeviceConfigurationProfiles
    $matchedProfiles = 0
    
    foreach ($profile in $profiles) {
        $profileDetails = Get-JamfMobileDeviceConfigurationProfileDetails -ProfileId $profile.id
        
        if ($profileDetails) {
            $isAssigned = $false
            $assignmentReason = ""
            
            # Check if mobile device is in scope
            # Direct mobile device assignment
            if ($profileDetails.scope.mobile_devices.mobile_device.id -contains $MobileDevice.general.id) {
                $isAssigned = $true
                $assignmentReason = "Direct mobile device assignment"
            }
            # All mobile devices
            elseif ($profileDetails.scope.all_mobile_devices -eq "true") {
                $isAssigned = $true
                $assignmentReason = "All Mobile Devices"
            }
            # Group assignment
            else {
                foreach ($group in $mobileDeviceGroups) {
                    if ($profileDetails.scope.mobile_device_groups.mobile_device_group.id -contains $group) {
                        $isAssigned = $true
                        $groupDetails = Get-JamfMobileDeviceGroupDetails -GroupId $group
                        $assignmentReason = "Group: $($groupDetails.name)"
                        break
                    }
                }
            }
            
            # Check exclusions
            if ($isAssigned) {
                # Direct mobile device exclusion
                if ($profileDetails.scope.exclusions.mobile_devices.mobile_device.id -contains $MobileDevice.general.id) {
                    $isAssigned = $false
                    $assignmentReason = "Excluded: Direct mobile device exclusion"
                }
                # Group exclusion
                else {
                    foreach ($group in $mobileDeviceGroups) {
                        if ($profileDetails.scope.exclusions.mobile_device_groups.mobile_device_group.id -contains $group) {
                            $isAssigned = $false
                            $groupDetails = Get-JamfMobileDeviceGroupDetails -GroupId $group
                            $assignmentReason = "Excluded: Group $($groupDetails.name)"
                            break
                        }
                    }
                }
            }
            
            if ($isAssigned -or $assignmentReason -like "Excluded:*") {
                $matchedProfiles++
                $assignments.Profiles += @{
                    Id               = $profileDetails.general.id
                    Name             = $profileDetails.general.name
                    AssignmentReason = $assignmentReason
                    IsExcluded       = $assignmentReason -like "Excluded:*"
                }
            }
        }
    }
    
    Write-Host "Found $matchedProfiles relevant profiles" -ForegroundColor Gray
    
    return $assignments
}
