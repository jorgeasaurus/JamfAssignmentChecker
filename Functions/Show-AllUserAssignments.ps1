function Show-AllUserAssignments {
    <#
    .SYNOPSIS
        Displays assignment information for all users in JAMF Pro.
    
    .DESCRIPTION
        Retrieves all users from JAMF Pro and shows what policies and configuration profiles are assigned to each user.
        Analyzes user-scoped assignments and group memberships that result in policy/profile assignments.
    
    .PARAMETER ExportToCSV
        Export results to CSV file.
    
    .PARAMETER ExportPath
        Path for the exported CSV file.
    #>
    param (
        [Parameter(Mandatory = $false)]
        [switch]$ExportToCSV,
        
        [Parameter(Mandatory = $false)]
        [string]$ExportPath
    )
    
    Write-Host "`n👤 Fetching all users and their assignments..." -ForegroundColor Cyan
    
    try {
        # Get all users
        $allUsers = Get-JamfUsers
        
        if (-not $allUsers -or $allUsers.Count -eq 0) {
            Write-Host "⚠️  No users found in JAMF Pro." -ForegroundColor Yellow
            return @()
        }
        
        Write-Host "Found $($allUsers.Count) users. Analyzing assignments..." -ForegroundColor Green
        
        $allAssignments = @()
        $processedCount = 0
        
        # Get all policies and profiles for user scope analysis
        Write-Host "📋 Loading policies and profiles for user scope analysis..." -ForegroundColor Cyan
        $allPolicies = Get-JamfPolicies
        $allProfiles = Get-JamfConfigurationProfiles
        $allMobileProfiles = Get-JamfMobileDeviceConfigurationProfiles
        
        foreach ($user in $allUsers) {
            $processedCount++
            Write-Progress -Activity "Analyzing user assignments" -Status "Processing $($user.name) ($processedCount of $($allUsers.Count))" -PercentComplete (($processedCount / $allUsers.Count) * 100)
            
            try {
                # Get detailed user information
                $userDetails = Get-JamfUser -UserName $user.name
                $userAssignments = @()
                
                if ($userDetails) {
                    # Check policies for user scope
                    foreach ($policy in $allPolicies) {
                        $policyDetails = Get-JamfPolicyDetails -PolicyId $policy.id
                        
                        if ($policyDetails -and $policyDetails.scope) {
                            $isAssigned = $false
                            $assignmentMethod = ""
                            
                            # Check direct user assignment
                            if ($policyDetails.scope.users.user) {
                                $users = @($policyDetails.scope.users.user)
                                if ($users | Where-Object { $_.id -eq $user.id -or $_.name -eq $user.name }) {
                                    $isAssigned = $true
                                    $assignmentMethod = "Direct User Assignment"
                                }
                            }
                            
                            # Check user group assignments
                            if (-not $isAssigned -and $policyDetails.scope.user_groups.user_group) {
                                $userGroups = @($policyDetails.scope.user_groups.user_group)
                                foreach ($group in $userGroups) {
                                    # Check if user is member of this group
                                    $groupDetails = Get-JamfUserGroup -GroupId $group.id
                                    if ($groupDetails -and $groupDetails.users.user) {
                                        $groupUsers = @($groupDetails.users.user)
                                        if ($groupUsers | Where-Object { $_.id -eq $user.id -or $_.name -eq $user.name }) {
                                            $isAssigned = $true
                                            $assignmentMethod = "User Group: $($group.name)"
                                            break
                                        }
                                    }
                                }
                            }
                            
                            # Check if user is excluded
                            $isExcluded = $false
                            if ($policyDetails.scope.exclusions.users.user) {
                                $excludedUsers = @($policyDetails.scope.exclusions.users.user)
                                if ($excludedUsers | Where-Object { $_.id -eq $user.id -or $_.name -eq $user.name }) {
                                    $isExcluded = $true
                                    $assignmentMethod += " (EXCLUDED)"
                                }
                            }
                            
                            if ($isAssigned) {
                                $userAssignments += [PSCustomObject]@{
                                    ResourceType     = "Policy"
                                    ResourceId       = $policy.id
                                    ResourceName     = $policy.name
                                    AssignmentMethod = $assignmentMethod
                                    IsExcluded       = $isExcluded
                                    Enabled          = $policyDetails.general.enabled -eq "true"
                                }
                            }
                        }
                    }
                    
                    # Check configuration profiles for user scope (mobile device profiles typically)
                    foreach ($profile in $allMobileProfiles) {
                        $profileDetails = Get-JamfMobileDeviceConfigurationProfileDetails -ProfileId $profile.id
                        
                        if ($profileDetails -and $profileDetails.scope) {
                            $isAssigned = $false
                            $assignmentMethod = ""
                            
                            # Check direct user assignment (mobile device profiles use jss_users)
                            if ($profileDetails.scope.jss_users.user) {
                                $users = @($profileDetails.scope.jss_users.user)
                                if ($users | Where-Object { $_.id -eq $user.id -or $_.name -eq $user.name }) {
                                    $isAssigned = $true
                                    $assignmentMethod = "Direct User Assignment"
                                }
                            }
                            
                            # Check user group assignments (mobile device profiles use jss_user_groups)
                            if (-not $isAssigned -and $profileDetails.scope.jss_user_groups.user_group) {
                                $userGroups = @($profileDetails.scope.jss_user_groups.user_group)
                                foreach ($group in $userGroups) {
                                    # Check if user is member of this group
                                    $groupDetails = Get-JamfUserGroup -GroupId $group.id
                                    if ($groupDetails -and $groupDetails.users.user) {
                                        $groupUsers = @($groupDetails.users.user)
                                        if ($groupUsers | Where-Object { $_.id -eq $user.id -or $_.name -eq $user.name }) {
                                            $isAssigned = $true
                                            $assignmentMethod = "User Group: $($group.name)"
                                            break
                                        }
                                    }
                                }
                            }
                            
                            # Check if user is excluded (mobile device profiles use jss_users in exclusions)
                            $isExcluded = $false
                            if ($profileDetails.scope.exclusions.jss_users.user) {
                                $excludedUsers = @($profileDetails.scope.exclusions.jss_users.user)
                                if ($excludedUsers | Where-Object { $_.id -eq $user.id -or $_.name -eq $user.name }) {
                                    $isExcluded = $true
                                    $assignmentMethod += " (EXCLUDED)"
                                }
                            }
                            
                            if ($isAssigned) {
                                $userAssignments += [PSCustomObject]@{
                                    ResourceType     = "Mobile Device Configuration Profile"
                                    ResourceId       = $profile.id
                                    ResourceName     = $profile.name
                                    AssignmentMethod = $assignmentMethod
                                    IsExcluded       = $isExcluded
                                    Enabled          = $true  # Profiles don't have enabled/disabled state
                                }
                            }
                        }
                    }
                    
                    # Add user identification to assignments
                    foreach ($assignment in $userAssignments) {
                        $assignment | Add-Member -NotePropertyName "UserName" -NotePropertyValue $user.name -Force
                        $assignment | Add-Member -NotePropertyName "UserId" -NotePropertyValue $user.id -Force
                        $assignment | Add-Member -NotePropertyName "UserEmail" -NotePropertyValue $(if ($userDetails.email) { $userDetails.email } else { "" }) -Force
                    }
                    
                    # If no assignments, create a record showing the user has no assignments
                    if ($userAssignments.Count -eq 0) {
                        $allAssignments += [PSCustomObject]@{
                            UserName         = $user.name
                            UserId           = $user.id
                            UserEmail        = $(if ($userDetails.email) { $userDetails.email } else { "" })
                            ResourceType     = "No Assignments"
                            ResourceId       = ""
                            ResourceName     = "No policies or profiles assigned"
                            AssignmentMethod = "User has no assignments"
                            IsExcluded       = $false
                            Enabled          = $false
                        }
                    } else {
                        $allAssignments += $userAssignments
                    }
                }
            } catch {
                Write-Host "⚠️  Failed to get assignments for user '$($user.name)': $_" -ForegroundColor Yellow
            }
        }
        
        Write-Progress -Activity "Analyzing user assignments" -Completed
        
        # Display summary
        Write-Host "`n===== ALL USER ASSIGNMENTS SUMMARY =====" -ForegroundColor Yellow
        Write-Host "Total Users Analyzed: $($allUsers.Count)" -ForegroundColor Cyan
        Write-Host "Total Assignment Records: $($allAssignments.Count)" -ForegroundColor Cyan
        
        # Group assignments by type
        $assignmentGroups = $allAssignments | Group-Object ResourceType
        foreach ($group in $assignmentGroups) {
            Write-Host "  $($group.Name): $($group.Count) assignments" -ForegroundColor Gray
        }
        
        # Show users with most assignments
        $userAssignmentCounts = $allAssignments | Group-Object UserName | Sort-Object Count -Descending | Select-Object -First 5
        if ($userAssignmentCounts) {
            Write-Host "`nTop 5 Users by Assignment Count:" -ForegroundColor Cyan
            foreach ($userGroup in $userAssignmentCounts) {
                Write-Host "  $($userGroup.Name): $($userGroup.Count) assignments" -ForegroundColor Gray
            }
        }
        
        # Show unassigned users
        $usersWithAssignments = $allAssignments | Select-Object -Unique UserName
        $unassignedUsers = $allUsers | Where-Object { $_.name -notin $usersWithAssignments.UserName }
        
        if ($unassignedUsers) {
            Write-Host "`n⚠️  Users with NO assignments:" -ForegroundColor Yellow
            foreach ($user in $unassignedUsers | Select-Object -First 10) {
                Write-Host "  - $($user.name)" -ForegroundColor DarkGray
            }
            if ($unassignedUsers.Count -gt 10) {
                Write-Host "  ... and $($unassignedUsers.Count - 10) more" -ForegroundColor DarkGray
            }
        }
        
        # Export if requested
        if ($ExportToCSV) {
            if ([string]::IsNullOrWhiteSpace($ExportPath)) {
                $ExportPath = "$env:temp\JamfAllUserAssignments_$(Get-Date -Format 'yyyyMMdd_HHmmss').csv"
            }
            
            try {
                $allAssignments | Export-Csv -Path $ExportPath -NoTypeInformation -Force
                Write-Host "`n✅ Exported to: $ExportPath" -ForegroundColor Green
                Write-Host "📊 Total records: $($allAssignments.Count)" -ForegroundColor Gray
            } catch {
                Write-Host "❌ Failed to export assignments: $_" -ForegroundColor Red
            }
        }
        
        Write-Host ""
        return $allAssignments
        
    } catch {
        Write-Host "❌ Failed to analyze all user assignments: $_" -ForegroundColor Red
        return @()
    }
}