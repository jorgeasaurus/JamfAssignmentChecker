function Get-JamfMobileDeviceGroups {
    <#
    .SYNOPSIS
        Retrieves all mobile device groups from JAMF Pro with member counts.
    #>
    param (
        [switch]$IncludeMemberCounts = $true
    )
    
    try {
        Write-Host "Fetching mobile device groups..." -ForegroundColor Cyan -NoNewline
        
        $response = Invoke-JamfApiCall -BaseUrl $script:Config.BaseUrl `
            -ApiVersion "classic" `
            -Endpoint "mobiledevicegroups" `
            -Token $script:Config.Token `
            -XML
        
        $basicGroups = ([xml]$response).mobile_device_groups.mobile_device_group
        Write-Host " Found $($basicGroups.Count) groups" -ForegroundColor Green
        
        # If member counts not requested, return basic group info
        if (-not $IncludeMemberCounts) {
            return $basicGroups | ForEach-Object {
                [PSCustomObject]@{
                    Id = $_.id
                    Name = $_.name
                    IsSmart = $false  # We don't know without details
                    Size = "N/A"      # Not fetched for performance
                }
            }
        }
        
        # Enhance groups with detailed information including member counts
        $enhancedGroups = @()
        $progressCount = 0
        
        Write-Host "Fetching mobile device group details..." -ForegroundColor Cyan
        
        foreach ($group in $basicGroups) {
            $progressCount++
            Write-Progress -Activity "Getting mobile device group details" -Status "Processing group $progressCount of $($basicGroups.Count)" -PercentComplete (($progressCount / $basicGroups.Count) * 100)
            
            try {
                $groupDetails = Get-JamfMobileDeviceGroupDetails -GroupId $group.id
                
                if ($groupDetails) {
                    # Create enhanced group object with size information
                    $enhancedGroup = [PSCustomObject]@{
                        Id = $group.id
                        Name = $group.name
                        IsSmart = $groupDetails.is_smart -eq "true"
                        Size = if ($groupDetails.mobile_devices.mobile_device) { 
                            if ($groupDetails.mobile_devices.mobile_device -is [array]) { 
                                $groupDetails.mobile_devices.mobile_device.Count 
                            } else { 
                                1 
                            } 
                        } else { 
                            0 
                        }
                    }
                    $enhancedGroups += $enhancedGroup
                }
            } catch {
                Write-Host "Warning: Failed to get details for mobile device group $($group.name): $_" -ForegroundColor Yellow
                # Add group with default values if details fetch fails
                $enhancedGroups += [PSCustomObject]@{
                    Id = $group.id
                    Name = $group.name
                    IsSmart = $false
                    Size = 0
                }
            }
        }
        
        Write-Progress -Activity "Getting mobile device group details" -Completed
        Write-Host "Enhanced $($enhancedGroups.Count) mobile device groups with member counts" -ForegroundColor Green
        
        return $enhancedGroups
    } catch {
        Write-Host " Failed!" -ForegroundColor Red
        Write-Host "Error: $_" -ForegroundColor Red
        return @()
    }
}
