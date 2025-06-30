function Find-UnassignedProfiles {
    <#
    .SYNOPSIS
        Finds configuration profiles without any assignments (both macOS and mobile device profiles).
    #>
    
    Write-Host "`nSearching for unassigned configuration profiles..." -ForegroundColor Cyan
    
    # Check macOS configuration profiles
    Write-Host "Checking macOS configuration profiles..." -ForegroundColor Gray
    $macOSProfiles = Get-JamfConfigurationProfiles
    $unassignedMacOSProfiles = @()
    
    foreach ($profile in $macOSProfiles) {
        $profileDetails = Get-JamfConfigurationProfileDetails -ProfileId $profile.id
        
        if ($profileDetails) {
            $hasAssignments = $false
            
            # Check for any assignments
            if ($profileDetails.scope.all_computers -eq "true" -or
                $profileDetails.scope.computers.computer -or
                $profileDetails.scope.computer_groups.computer_group -or
                $profileDetails.scope.users.user -or
                $profileDetails.scope.user_groups.user_group) {
                $hasAssignments = $true
            }
            
            if (-not $hasAssignments) {
                $unassignedMacOSProfiles += @{
                    Id   = $profileDetails.general.id
                    Name = $profileDetails.general.name
                    Type = "macOS Configuration Profile"
                }
            }
        }
    }
    
    # Check mobile device configuration profiles
    Write-Host "Checking mobile device configuration profiles..." -ForegroundColor Gray
    $mobileProfiles = Get-JamfMobileDeviceConfigurationProfiles
    $unassignedMobileProfiles = @()
    
    foreach ($profile in $mobileProfiles) {
        $profileDetails = Get-JamfMobileDeviceConfigurationProfileDetails -ProfileId $profile.id
        
        if ($profileDetails) {
            $hasAssignments = $false
            
            # Check for any assignments
            if ($profileDetails.scope.all_mobile_devices -eq "true" -or
                $profileDetails.scope.mobile_devices.mobile_device -or
                $profileDetails.scope.mobile_device_groups.mobile_device_group -or
                $profileDetails.scope.users.user -or
                $profileDetails.scope.user_groups.user_group) {
                $hasAssignments = $true
            }
            
            if (-not $hasAssignments) {
                $unassignedMobileProfiles += @{
                    Id   = $profileDetails.general.id
                    Name = $profileDetails.general.name
                    Type = "Mobile Device Configuration Profile"
                }
            }
        }
    }
    
    # Combine results
    $allUnassignedProfiles = $unassignedMacOSProfiles + $unassignedMobileProfiles
    
    # Display results
    Write-Host "`n===== CONFIGURATION PROFILES WITHOUT ASSIGNMENTS =====" -ForegroundColor Yellow
    Write-Host "Found $($allUnassignedProfiles.Count) unassigned profiles total" -ForegroundColor Cyan
    Write-Host "  macOS Profiles: $($unassignedMacOSProfiles.Count)" -ForegroundColor Gray
    Write-Host "  Mobile Profiles: $($unassignedMobileProfiles.Count)" -ForegroundColor Gray
    Write-Host ""
    
    if ($allUnassignedProfiles.Count -eq 0) {
        Write-Host "All configuration profiles have at least one assignment!" -ForegroundColor Green
    } else {
        # Display macOS profiles
        if ($unassignedMacOSProfiles.Count -gt 0) {
            Write-Host "MACOS CONFIGURATION PROFILES:" -ForegroundColor Cyan
            foreach ($profile in $unassignedMacOSProfiles | Sort-Object Name) {
                Write-Host "  - $($profile.Name)" -ForegroundColor White
                Write-Host "    ID: $($profile.Id)" -ForegroundColor Gray
            }
            Write-Host ""
        }
        
        # Display mobile device profiles
        if ($unassignedMobileProfiles.Count -gt 0) {
            Write-Host "MOBILE DEVICE CONFIGURATION PROFILES:" -ForegroundColor Cyan
            foreach ($profile in $unassignedMobileProfiles | Sort-Object Name) {
                Write-Host "  - $($profile.Name)" -ForegroundColor White
                Write-Host "    ID: $($profile.Id)" -ForegroundColor Gray
            }
        }
    }
    
    Write-Host ""
    return $allUnassignedProfiles
}
