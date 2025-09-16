function Get-GroupAssignments {
    <#
    .SYNOPSIS
        Analyzes all policy and profile assignments where a specific group is used.
    
    .DESCRIPTION
        This function finds all policies and configuration profiles that include 
        the specified group in their scope (either as an inclusion or exclusion).
    
    .PARAMETER GroupName
        The name of the computer group to analyze.
    
    .PARAMETER GroupType
        The type of group (Computer or MobileDevice). Defaults to Computer.
    #>
    param (
        [Parameter(Mandatory = $true)]
        [string]$GroupName,
        
        [Parameter()]
        [ValidateSet("Computer", "MobileDevice")]
        [string]$GroupType = "Computer"
    )
    
    $assignments = @{
        GroupName = $GroupName
        GroupType = $GroupType
        GroupId = $null
        GroupDetails = $null
        Policies = @()
        Profiles = @()
        MobileProfiles = @()
        Statistics = @{
            TotalPolicies = 0
            TotalProfiles = 0
            TotalMembers = 0
            IsSmart = $false
        }
    }
    
    try {
        # Get group details based on type
        if ($GroupType -eq "Computer") {
            # Find the group by name
            Write-Host "`nSearching for computer group: $GroupName" -ForegroundColor Cyan
            
            $allGroups = Get-JamfComputerGroups -IncludeMemberCounts:$false
            $targetGroup = $allGroups | Where-Object { $_.Name -eq $GroupName }
            
            if (-not $targetGroup) {
                Write-Host "Computer group '$GroupName' not found!" -ForegroundColor Red
                Write-Host "Available groups:" -ForegroundColor Yellow
                $allGroups | Select-Object -First 10 | ForEach-Object {
                    Write-Host "  - $($_.Name)" -ForegroundColor Gray
                }
                if ($allGroups.Count -gt 10) {
                    Write-Host "  ... and $($allGroups.Count - 10) more" -ForegroundColor Gray
                }
                return $null
            }
            
            # Get detailed group information
            Write-Host "Found group: $($targetGroup.Name) (ID: $($targetGroup.Id))" -ForegroundColor Green
            $groupDetails = Get-JamfComputerGroupDetails -GroupId $targetGroup.Id
            
            if ($groupDetails) {
                $assignments.GroupId = $targetGroup.Id
                $assignments.GroupDetails = $groupDetails
                $assignments.Statistics.IsSmart = ($groupDetails.is_smart -eq "true")
                
                # Count members
                if ($groupDetails.computers.computer) {
                    $assignments.Statistics.TotalMembers = if ($groupDetails.computers.computer -is [array]) { 
                        $groupDetails.computers.computer.Count 
                    } else { 
                        1 
                    }
                } else {
                    $assignments.Statistics.TotalMembers = 0
                }
                
                Write-Host "Group Type: $(if ($assignments.Statistics.IsSmart) { 'Smart Group' } else { 'Static Group' })" -ForegroundColor Gray
                Write-Host "Members: $($assignments.Statistics.TotalMembers)" -ForegroundColor Gray
            }
            
            # Check all policies for this group
            Write-Host "`nAnalyzing policy assignments..." -ForegroundColor Cyan
            $policies = Get-JamfPolicies
            
            foreach ($policy in $policies) {
                Write-Progress -Activity "Analyzing policies" -Status "Checking policy: $($policy.name)" -PercentComplete (($policies.IndexOf($policy) / $policies.Count) * 100)
                
                $policyDetails = Get-JamfPolicyDetails -PolicyId $policy.id
                
                if ($policyDetails) {
                    $groupUsage = @{
                        Id = $policy.id
                        Name = $policy.name
                        Enabled = $policyDetails.general.enabled
                        UsageType = $null
                        ScopeDetails = ""
                    }
                    
                    # Check if group is in scope inclusions
                    $inInclusion = $false
                    if ($policyDetails.scope.computer_groups.computer_group) {
                        $scopeGroups = if ($policyDetails.scope.computer_groups.computer_group -is [array]) {
                            $policyDetails.scope.computer_groups.computer_group
                        } else {
                            @($policyDetails.scope.computer_groups.computer_group)
                        }
                        
                        $matchingGroup = $scopeGroups | Where-Object { $_.id -eq $targetGroup.Id -or $_.name -eq $GroupName }
                        if ($matchingGroup) {
                            $inInclusion = $true
                            $groupUsage.UsageType = "Inclusion"
                            $groupUsage.ScopeDetails = "Assigned to group"
                        }
                    }
                    
                    # Check if group is in exclusions
                    $inExclusion = $false
                    if ($policyDetails.scope.exclusions.computer_groups.computer_group) {
                        $excludeGroups = if ($policyDetails.scope.exclusions.computer_groups.computer_group -is [array]) {
                            $policyDetails.scope.exclusions.computer_groups.computer_group
                        } else {
                            @($policyDetails.scope.exclusions.computer_groups.computer_group)
                        }
                        
                        $matchingExclusion = $excludeGroups | Where-Object { $_.id -eq $targetGroup.Id -or $_.name -eq $GroupName }
                        if ($matchingExclusion) {
                            $inExclusion = $true
                            if ($inInclusion) {
                                $groupUsage.UsageType = "Both"
                                $groupUsage.ScopeDetails = "In scope AND exclusions (check configuration)"
                            } else {
                                $groupUsage.UsageType = "Exclusion"
                                $groupUsage.ScopeDetails = "Excluded from policy"
                            }
                        }
                    }
                    
                    # Add to results if group is used
                    if ($inInclusion -or $inExclusion) {
                        $assignments.Policies += $groupUsage
                    }
                }
            }
            Write-Progress -Activity "Analyzing policies" -Completed
            $assignments.Statistics.TotalPolicies = $assignments.Policies.Count
            
            # Check all configuration profiles for this group
            Write-Host "Analyzing configuration profile assignments..." -ForegroundColor Cyan
            $profiles = Get-JamfConfigurationProfiles
            
            foreach ($profile in $profiles) {
                Write-Progress -Activity "Analyzing profiles" -Status "Checking profile: $($profile.name)" -PercentComplete (($profiles.IndexOf($profile) / $profiles.Count) * 100)
                
                $profileDetails = Get-JamfConfigurationProfileDetails -ProfileId $profile.id
                
                if ($profileDetails) {
                    $groupUsage = @{
                        Id = $profile.id
                        Name = $profile.name
                        UsageType = $null
                        ScopeDetails = ""
                    }
                    
                    # Check if group is in scope inclusions
                    $inInclusion = $false
                    if ($profileDetails.scope.computer_groups.computer_group) {
                        $scopeGroups = if ($profileDetails.scope.computer_groups.computer_group -is [array]) {
                            $profileDetails.scope.computer_groups.computer_group
                        } else {
                            @($profileDetails.scope.computer_groups.computer_group)
                        }
                        
                        $matchingGroup = $scopeGroups | Where-Object { $_.id -eq $targetGroup.Id -or $_.name -eq $GroupName }
                        if ($matchingGroup) {
                            $inInclusion = $true
                            $groupUsage.UsageType = "Inclusion"
                            $groupUsage.ScopeDetails = "Assigned to group"
                        }
                    }
                    
                    # Check if group is in exclusions
                    $inExclusion = $false
                    if ($profileDetails.scope.exclusions.computer_groups.computer_group) {
                        $excludeGroups = if ($profileDetails.scope.exclusions.computer_groups.computer_group -is [array]) {
                            $profileDetails.scope.exclusions.computer_groups.computer_group
                        } else {
                            @($profileDetails.scope.exclusions.computer_groups.computer_group)
                        }
                        
                        $matchingExclusion = $excludeGroups | Where-Object { $_.id -eq $targetGroup.Id -or $_.name -eq $GroupName }
                        if ($matchingExclusion) {
                            $inExclusion = $true
                            if ($inInclusion) {
                                $groupUsage.UsageType = "Both"
                                $groupUsage.ScopeDetails = "In scope AND exclusions (check configuration)"
                            } else {
                                $groupUsage.UsageType = "Exclusion"
                                $groupUsage.ScopeDetails = "Excluded from profile"
                            }
                        }
                    }
                    
                    # Add to results if group is used
                    if ($inInclusion -or $inExclusion) {
                        $assignments.Profiles += $groupUsage
                    }
                }
            }
            Write-Progress -Activity "Analyzing profiles" -Completed
            $assignments.Statistics.TotalProfiles = $assignments.Profiles.Count
            
        } elseif ($GroupType -eq "MobileDevice") {
            # Mobile device group handling
            Write-Host "`nSearching for mobile device group: $GroupName" -ForegroundColor Cyan
            
            $allGroups = Get-JamfMobileDeviceGroups
            $targetGroup = $allGroups | Where-Object { $_.Name -eq $GroupName }
            
            if (-not $targetGroup) {
                Write-Host "Mobile device group '$GroupName' not found!" -ForegroundColor Red
                return $null
            }
            
            $assignments.GroupId = $targetGroup.Id
            Write-Host "Found mobile device group: $($targetGroup.Name) (ID: $($targetGroup.Id))" -ForegroundColor Green
            
            # Check mobile device configuration profiles
            Write-Host "`nAnalyzing mobile device profile assignments..." -ForegroundColor Cyan
            $mobileProfiles = Get-JamfMobileDeviceConfigurationProfiles
            
            foreach ($profile in $mobileProfiles) {
                $profileDetails = Get-JamfMobileDeviceConfigurationProfileDetails -ProfileId $profile.id
                
                if ($profileDetails) {
                    # Check if group is in scope
                    if ($profileDetails.scope.mobile_device_groups.mobile_device_group) {
                        $scopeGroups = if ($profileDetails.scope.mobile_device_groups.mobile_device_group -is [array]) {
                            $profileDetails.scope.mobile_device_groups.mobile_device_group
                        } else {
                            @($profileDetails.scope.mobile_device_groups.mobile_device_group)
                        }
                        
                        $matchingGroup = $scopeGroups | Where-Object { $_.id -eq $targetGroup.Id -or $_.name -eq $GroupName }
                        if ($matchingGroup) {
                            $assignments.MobileProfiles += @{
                                Id = $profile.id
                                Name = $profile.name
                                UsageType = "Inclusion"
                                ScopeDetails = "Assigned to mobile device group"
                            }
                        }
                    }
                }
            }
            
            $assignments.Statistics.TotalProfiles = $assignments.MobileProfiles.Count
        }
        
        return $assignments
        
    } catch {
        Write-Host "Error analyzing group assignments: $_" -ForegroundColor Red
        Write-Host $_.Exception.StackTrace -ForegroundColor Red
        return $null
    }
}