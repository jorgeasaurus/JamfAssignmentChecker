function Get-JamfComputerGroups {
    <#
    .SYNOPSIS
        Retrieves all computer groups from JAMF Pro with member counts.
    #>
    param (
        [switch]$IncludeMemberCounts = $true
    )
    
    try {
        Write-Host "Fetching computer groups..." -ForegroundColor Cyan -NoNewline
        
        $response = Invoke-JamfApiCall -BaseUrl $script:Config.BaseUrl `
            -ApiVersion "classic" `
            -Endpoint "computergroups" `
            -Token $script:Config.Token `
            -XML
        
        $basicGroups = ([xml]$response).computer_groups.computer_group
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
        
        Write-Host "Fetching group details..." -ForegroundColor Cyan
        
        foreach ($group in $basicGroups) {
            $progressCount++
            Write-Progress -Activity "Getting group details" -Status "Processing group $progressCount of $($basicGroups.Count)" -PercentComplete (($progressCount / $basicGroups.Count) * 100)
            
            try {
                $groupDetails = Get-JamfComputerGroupDetails -GroupId $group.id
                
                if ($groupDetails) {
                    # Create enhanced group object with size information
                    $enhancedGroup = [PSCustomObject]@{
                        Id = $group.id
                        Name = $group.name
                        IsSmart = $groupDetails.is_smart -eq "true"
                        Size = if ($groupDetails.computers.computer) { 
                            if ($groupDetails.computers.computer -is [array]) { 
                                $groupDetails.computers.computer.Count 
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
                Write-Host "Warning: Failed to get details for group $($group.name): $_" -ForegroundColor Yellow
                # Add group with default values if details fetch fails
                $enhancedGroups += [PSCustomObject]@{
                    Id = $group.id
                    Name = $group.name
                    IsSmart = $false
                    Size = 0
                }
            }
        }
        
        Write-Progress -Activity "Getting group details" -Completed
        Write-Host "Enhanced $($enhancedGroups.Count) groups with member counts" -ForegroundColor Green
        
        return $enhancedGroups
    } catch {
        Write-Host " Failed!" -ForegroundColor Red
        Write-Host "Error: $_" -ForegroundColor Red
        return @()
    }
}
