function Show-AllProfiles {
    <#
    .SYNOPSIS
        Displays all configuration profiles with their assignments (both macOS and mobile device profiles).
    #>
    
    Write-Host "`nFetching all configuration profiles and their assignments..." -ForegroundColor Cyan
    
    $allProfileData = @()
    $processedCount = 0
    
    # Process macOS Configuration Profiles
    Write-Host "Processing macOS configuration profiles..." -ForegroundColor Gray
    $macOSProfiles = Get-JamfConfigurationProfiles
    
    foreach ($profile in $macOSProfiles) {
        $processedCount++
        Write-Progress -Activity "Processing profiles" -Status "macOS: $processedCount of $($macOSProfiles.Count)" -PercentComplete (($processedCount / ($macOSProfiles.Count + 1)) * 50)
        
        $profileDetails = Get-JamfConfigurationProfileDetails -ProfileId $profile.id
        
        if ($profileDetails) {
            $profileData = @{
                Id    = $profileDetails.general.id
                Name  = $profileDetails.general.name
                Type  = "macOS Configuration Profile"
                Scope = @{
                    AllComputers   = $profileDetails.scope.all_computers -eq "true"
                    Computers      = @()
                    ComputerGroups = @()
                    Users          = @()
                    UserGroups     = @()
                    Exclusions     = @{
                        Computers      = @()
                        ComputerGroups = @()
                        Users          = @()
                        UserGroups     = @()
                    }
                }
            }
            
            # Process computer assignments
            if ($profileDetails.scope.computers.computer) {
                $computers = @($profileDetails.scope.computers.computer)
                foreach ($comp in $computers) {
                    $profileData.Scope.Computers += @{
                        Id   = $comp.id
                        Name = $comp.name
                    }
                }
            }
            
            # Process computer group assignments
            if ($profileDetails.scope.computer_groups.computer_group) {
                $groups = @($profileDetails.scope.computer_groups.computer_group)
                foreach ($group in $groups) {
                    $profileData.Scope.ComputerGroups += @{
                        Id   = $group.id
                        Name = $group.name
                    }
                }
            }
            
            # Process exclusions
            if ($profileDetails.scope.exclusions.computers.computer) {
                $exclComputers = @($profileDetails.scope.exclusions.computers.computer)
                foreach ($comp in $exclComputers) {
                    $profileData.Scope.Exclusions.Computers += @{
                        Id   = $comp.id
                        Name = $comp.name
                    }
                }
            }
            
            if ($profileDetails.scope.exclusions.computer_groups.computer_group) {
                $exclGroups = @($profileDetails.scope.exclusions.computer_groups.computer_group)
                foreach ($group in $exclGroups) {
                    $profileData.Scope.Exclusions.ComputerGroups += @{
                        Id   = $group.id
                        Name = $group.name
                    }
                }
            }
            
            $allProfileData += $profileData
        }
    }
    
    # Process Mobile Device Configuration Profiles
    Write-Host "Processing mobile device configuration profiles..." -ForegroundColor Gray
    $mobileProfiles = Get-JamfMobileDeviceConfigurationProfiles
    $mobileProcessedCount = 0
    
    foreach ($profile in $mobileProfiles) {
        $mobileProcessedCount++
        Write-Progress -Activity "Processing profiles" -Status "Mobile: $mobileProcessedCount of $($mobileProfiles.Count)" -PercentComplete (50 + (($mobileProcessedCount / ($mobileProfiles.Count + 1)) * 50))
        
        $profileDetails = Get-JamfMobileDeviceConfigurationProfileDetails -ProfileId $profile.id
        
        if ($profileDetails) {
            $profileData = @{
                Id    = $profileDetails.general.id
                Name  = $profileDetails.general.name
                Type  = "Mobile Device Configuration Profile"
                Scope = @{
                    AllMobileDevices   = $profileDetails.scope.all_mobile_devices -eq "true"
                    MobileDevices      = @()
                    MobileDeviceGroups = @()
                    Users              = @()
                    UserGroups         = @()
                    Exclusions         = @{
                        MobileDevices      = @()
                        MobileDeviceGroups = @()
                        Users              = @()
                        UserGroups         = @()
                    }
                }
            }
            
            # Process mobile device assignments
            if ($profileDetails.scope.mobile_devices.mobile_device) {
                $devices = @($profileDetails.scope.mobile_devices.mobile_device)
                foreach ($device in $devices) {
                    $profileData.Scope.MobileDevices += @{
                        Id   = $device.id
                        Name = $device.name
                    }
                }
            }
            
            # Process mobile device group assignments
            if ($profileDetails.scope.mobile_device_groups.mobile_device_group) {
                $groups = @($profileDetails.scope.mobile_device_groups.mobile_device_group)
                foreach ($group in $groups) {
                    $profileData.Scope.MobileDeviceGroups += @{
                        Id   = $group.id
                        Name = $group.name
                    }
                }
            }
            
            # Process exclusions
            if ($profileDetails.scope.exclusions.mobile_devices.mobile_device) {
                $exclDevices = @($profileDetails.scope.exclusions.mobile_devices.mobile_device)
                foreach ($device in $exclDevices) {
                    $profileData.Scope.Exclusions.MobileDevices += @{
                        Id   = $device.id
                        Name = $device.name
                    }
                }
            }
            
            if ($profileDetails.scope.exclusions.mobile_device_groups.mobile_device_group) {
                $exclGroups = @($profileDetails.scope.exclusions.mobile_device_groups.mobile_device_group)
                foreach ($group in $exclGroups) {
                    $profileData.Scope.Exclusions.MobileDeviceGroups += @{
                        Id   = $group.id
                        Name = $group.name
                    }
                }
            }
            
            $allProfileData += $profileData
        }
    }
    
    Write-Progress -Activity "Processing profiles" -Completed
    
    # Display results
    Write-Host "`n===== ALL CONFIGURATION PROFILES AND ASSIGNMENTS =====" -ForegroundColor Yellow
    Write-Host "Total Profiles: $($allProfileData.Count)" -ForegroundColor Cyan
    
    $macOSProfileCount = ($allProfileData | Where-Object { $_.Type -eq "macOS Configuration Profile" }).Count
    $mobileProfileCount = ($allProfileData | Where-Object { $_.Type -eq "Mobile Device Configuration Profile" }).Count
    
    Write-Host "macOS Profiles: $macOSProfileCount | Mobile Profiles: $mobileProfileCount" -ForegroundColor Gray
    Write-Host ""
    
    # Group and display by type
    $macOSProfileData = $allProfileData | Where-Object { $_.Type -eq "macOS Configuration Profile" } | Sort-Object Name
    $mobileProfileData = $allProfileData | Where-Object { $_.Type -eq "Mobile Device Configuration Profile" } | Sort-Object Name
    
    # Display macOS profiles
    if ($macOSProfileData.Count -gt 0) {
        Write-Host "MACOS CONFIGURATION PROFILES:" -ForegroundColor Cyan
        foreach ($profile in $macOSProfileData) {
            Write-Host "$($profile.Name)" -ForegroundColor White
            Write-Host "  ID: $($profile.Id)" -ForegroundColor Gray
            
            # Display scope
            if ($profile.Scope.AllComputers) {
                Write-Host "  Scope: ALL COMPUTERS" -ForegroundColor Cyan
            } else {
                if ($profile.Scope.Computers.Count -gt 0) {
                    Write-Host "  Direct Computers ($($profile.Scope.Computers.Count)):" -ForegroundColor Cyan
                    foreach ($comp in $profile.Scope.Computers) {
                        Write-Host "    - $($comp.Name) (ID: $($comp.Id))" -ForegroundColor Gray
                    }
                }
                
                if ($profile.Scope.ComputerGroups.Count -gt 0) {
                    Write-Host "  Computer Groups ($($profile.Scope.ComputerGroups.Count)):" -ForegroundColor Cyan
                    foreach ($group in $profile.Scope.ComputerGroups) {
                        Write-Host "    - $($group.Name) (ID: $($group.Id))" -ForegroundColor Gray
                    }
                }
            }
            
            # Display exclusions
            $hasExclusions = $profile.Scope.Exclusions.Computers.Count -gt 0 -or $profile.Scope.Exclusions.ComputerGroups.Count -gt 0
            
            if ($hasExclusions) {
                Write-Host "  Exclusions:" -ForegroundColor Red
                
                if ($profile.Scope.Exclusions.Computers.Count -gt 0) {
                    Write-Host "    Computers:" -ForegroundColor Red
                    foreach ($comp in $profile.Scope.Exclusions.Computers) {
                        Write-Host "      - $($comp.Name) (ID: $($comp.Id))" -ForegroundColor DarkGray
                    }
                }
                
                if ($profile.Scope.Exclusions.ComputerGroups.Count -gt 0) {
                    Write-Host "    Computer Groups:" -ForegroundColor Red
                    foreach ($group in $profile.Scope.Exclusions.ComputerGroups) {
                        Write-Host "      - $($group.Name) (ID: $($group.Id))" -ForegroundColor DarkGray
                    }
                }
            }
            
            # Show if no assignments
            if (-not $profile.Scope.AllComputers -and 
                $profile.Scope.Computers.Count -eq 0 -and 
                $profile.Scope.ComputerGroups.Count -eq 0) {
                Write-Host "  ⚠️  NO ASSIGNMENTS" -ForegroundColor Yellow
            }
            
            Write-Host ""
        }
    }
    
    # Display mobile device profiles
    if ($mobileProfileData.Count -gt 0) {
        Write-Host "MOBILE DEVICE CONFIGURATION PROFILES:" -ForegroundColor Cyan
        foreach ($profile in $mobileProfileData) {
            Write-Host "$($profile.Name)" -ForegroundColor White
            Write-Host "  ID: $($profile.Id)" -ForegroundColor Gray
            
            # Display scope
            if ($profile.Scope.AllMobileDevices) {
                Write-Host "  Scope: ALL MOBILE DEVICES" -ForegroundColor Cyan
            } else {
                if ($profile.Scope.MobileDevices.Count -gt 0) {
                    Write-Host "  Direct Mobile Devices ($($profile.Scope.MobileDevices.Count)):" -ForegroundColor Cyan
                    foreach ($device in $profile.Scope.MobileDevices) {
                        Write-Host "    - $($device.Name) (ID: $($device.Id))" -ForegroundColor Gray
                    }
                }
                
                if ($profile.Scope.MobileDeviceGroups.Count -gt 0) {
                    Write-Host "  Mobile Device Groups ($($profile.Scope.MobileDeviceGroups.Count)):" -ForegroundColor Cyan
                    foreach ($group in $profile.Scope.MobileDeviceGroups) {
                        Write-Host "    - $($group.Name) (ID: $($group.Id))" -ForegroundColor Gray
                    }
                }
            }
            
            # Display exclusions
            $hasExclusions = $profile.Scope.Exclusions.MobileDevices.Count -gt 0 -or $profile.Scope.Exclusions.MobileDeviceGroups.Count -gt 0
            
            if ($hasExclusions) {
                Write-Host "  Exclusions:" -ForegroundColor Red
                
                if ($profile.Scope.Exclusions.MobileDevices.Count -gt 0) {
                    Write-Host "    Mobile Devices:" -ForegroundColor Red
                    foreach ($device in $profile.Scope.Exclusions.MobileDevices) {
                        Write-Host "      - $($device.Name) (ID: $($device.Id))" -ForegroundColor DarkGray
                    }
                }
                
                if ($profile.Scope.Exclusions.MobileDeviceGroups.Count -gt 0) {
                    Write-Host "    Mobile Device Groups:" -ForegroundColor Red
                    foreach ($group in $profile.Scope.Exclusions.MobileDeviceGroups) {
                        Write-Host "      - $($group.Name) (ID: $($group.Id))" -ForegroundColor DarkGray
                    }
                }
            }
            
            # Show if no assignments
            if (-not $profile.Scope.AllMobileDevices -and 
                $profile.Scope.MobileDevices.Count -eq 0 -and 
                $profile.Scope.MobileDeviceGroups.Count -eq 0) {
                Write-Host "  ⚠️  NO ASSIGNMENTS" -ForegroundColor Yellow
            }
            
            Write-Host ""
        }
    }
    
    return $allProfileData
}
