function Show-GroupAssignments {
    <#
    .SYNOPSIS
        Displays group assignments in a formatted way.
    
    .DESCRIPTION
        Shows all policies and configuration profiles that use the specified group,
        including whether the group is used for inclusion or exclusion.
    
    .PARAMETER Assignments
        The assignments object returned from Get-GroupAssignments.
    #>
    param (
        [Parameter(Mandatory = $true)]
        [object]$Assignments
    )
    
    if (-not $Assignments) {
        Write-Host "`nNo assignment data to display." -ForegroundColor Red
        return
    }
    
    Write-Host "`n===== GROUP ASSIGNMENT ANALYSIS: $($Assignments.GroupName) =====" -ForegroundColor Yellow
    
    # Display group information
    Write-Host "`nGROUP DETAILS:" -ForegroundColor Cyan
    Write-Host "  Group Name: $($Assignments.GroupName)" -ForegroundColor White
    Write-Host "  Group Type: $($Assignments.GroupType)" -ForegroundColor Gray
    if ($Assignments.GroupId) {
        Write-Host "  Group ID: $($Assignments.GroupId)" -ForegroundColor Gray
    }
    if ($Assignments.Statistics.IsSmart -ne $null) {
        Write-Host "  Type: $(if ($Assignments.Statistics.IsSmart) { 'Smart Group' } else { 'Static Group' })" -ForegroundColor Gray
    }
    if ($Assignments.Statistics.TotalMembers -ge 0) {
        $memberColor = if ($Assignments.Statistics.TotalMembers -eq 0) { "Yellow" } else { "Green" }
        Write-Host "  Members: " -ForegroundColor Gray -NoNewline
        Write-Host "$($Assignments.Statistics.TotalMembers)" -ForegroundColor $memberColor
    }
    
    # Display summary statistics
    Write-Host "`nSUMMARY:" -ForegroundColor Cyan
    $totalUsage = $Assignments.Statistics.TotalPolicies + $Assignments.Statistics.TotalProfiles
    
    if ($Assignments.GroupType -eq "Computer") {
        Write-Host "  Total Policies Using This Group: $($Assignments.Statistics.TotalPolicies)" -ForegroundColor White
        Write-Host "  Total Configuration Profiles Using This Group: $($Assignments.Statistics.TotalProfiles)" -ForegroundColor White
    } else {
        Write-Host "  Total Mobile Device Profiles Using This Group: $($Assignments.Statistics.TotalProfiles)" -ForegroundColor White
    }
    
    if ($totalUsage -eq 0) {
        Write-Host "`n  ⚠️  This group is not used in any policies or profiles!" -ForegroundColor Yellow
    }
    
    # Display Policies (for Computer groups only)
    if ($Assignments.GroupType -eq "Computer" -and $Assignments.Policies.Count -gt 0) {
        Write-Host "`nPOLICIES USING THIS GROUP ($($Assignments.Policies.Count)):" -ForegroundColor Cyan
        
        # Group by usage type
        $inclusions = $Assignments.Policies | Where-Object { $_.UsageType -eq "Inclusion" }
        $exclusions = $Assignments.Policies | Where-Object { $_.UsageType -eq "Exclusion" }
        $both = $Assignments.Policies | Where-Object { $_.UsageType -eq "Both" }
        
        if ($inclusions.Count -gt 0) {
            Write-Host "`n  ✅ Included in Scope ($($inclusions.Count)):" -ForegroundColor Green
            foreach ($policy in $inclusions) {
                $enabledStatus = if ($policy.Enabled -eq "true") { "[Enabled]" } else { "[Disabled]" }
                $enabledColor = if ($policy.Enabled -eq "true") { "Green" } else { "DarkGray" }
                Write-Host "    - $($policy.Name) " -ForegroundColor White -NoNewline
                Write-Host $enabledStatus -ForegroundColor $enabledColor
                Write-Host "      ID: $($policy.Id) | $($policy.ScopeDetails)" -ForegroundColor Gray
            }
        }
        
        if ($exclusions.Count -gt 0) {
            Write-Host "`n  ❌ Used for Exclusion ($($exclusions.Count)):" -ForegroundColor Red
            foreach ($policy in $exclusions) {
                $enabledStatus = if ($policy.Enabled -eq "true") { "[Enabled]" } else { "[Disabled]" }
                $enabledColor = if ($policy.Enabled -eq "true") { "Green" } else { "DarkGray" }
                Write-Host "    - $($policy.Name) " -ForegroundColor White -NoNewline
                Write-Host $enabledStatus -ForegroundColor $enabledColor
                Write-Host "      ID: $($policy.Id) | $($policy.ScopeDetails)" -ForegroundColor Gray
            }
        }
        
        if ($both.Count -gt 0) {
            Write-Host "`n  ⚠️  In Both Scope and Exclusions ($($both.Count)):" -ForegroundColor Yellow
            foreach ($policy in $both) {
                $enabledStatus = if ($policy.Enabled -eq "true") { "[Enabled]" } else { "[Disabled]" }
                $enabledColor = if ($policy.Enabled -eq "true") { "Green" } else { "DarkGray" }
                Write-Host "    - $($policy.Name) " -ForegroundColor White -NoNewline
                Write-Host $enabledStatus -ForegroundColor $enabledColor
                Write-Host "      ID: $($policy.Id) | $($policy.ScopeDetails)" -ForegroundColor Gray
            }
        }
    }
    
    # Display Configuration Profiles (for Computer groups)
    if ($Assignments.GroupType -eq "Computer" -and $Assignments.Profiles.Count -gt 0) {
        Write-Host "`nCONFIGURATION PROFILES USING THIS GROUP ($($Assignments.Profiles.Count)):" -ForegroundColor Cyan
        
        # Group by usage type
        $inclusions = $Assignments.Profiles | Where-Object { $_.UsageType -eq "Inclusion" }
        $exclusions = $Assignments.Profiles | Where-Object { $_.UsageType -eq "Exclusion" }
        $both = $Assignments.Profiles | Where-Object { $_.UsageType -eq "Both" }
        
        if ($inclusions.Count -gt 0) {
            Write-Host "`n  ✅ Included in Scope ($($inclusions.Count)):" -ForegroundColor Green
            foreach ($profile in $inclusions) {
                Write-Host "    - $($profile.Name)" -ForegroundColor White
                Write-Host "      ID: $($profile.Id) | $($profile.ScopeDetails)" -ForegroundColor Gray
            }
        }
        
        if ($exclusions.Count -gt 0) {
            Write-Host "`n  ❌ Used for Exclusion ($($exclusions.Count)):" -ForegroundColor Red
            foreach ($profile in $exclusions) {
                Write-Host "    - $($profile.Name)" -ForegroundColor White
                Write-Host "      ID: $($profile.Id) | $($profile.ScopeDetails)" -ForegroundColor Gray
            }
        }
        
        if ($both.Count -gt 0) {
            Write-Host "`n  ⚠️  In Both Scope and Exclusions ($($both.Count)):" -ForegroundColor Yellow
            foreach ($profile in $both) {
                Write-Host "    - $($profile.Name)" -ForegroundColor White
                Write-Host "      ID: $($profile.Id) | $($profile.ScopeDetails)" -ForegroundColor Gray
            }
        }
    }
    
    # Display Mobile Device Profiles (for Mobile Device groups)
    if ($Assignments.GroupType -eq "MobileDevice" -and $Assignments.MobileProfiles.Count -gt 0) {
        Write-Host "`nMOBILE DEVICE PROFILES USING THIS GROUP ($($Assignments.MobileProfiles.Count)):" -ForegroundColor Cyan
        
        Write-Host "`n  ✅ Included in Scope:" -ForegroundColor Green
        foreach ($profile in $Assignments.MobileProfiles) {
            Write-Host "    - $($profile.Name)" -ForegroundColor White
            Write-Host "      ID: $($profile.Id) | $($profile.ScopeDetails)" -ForegroundColor Gray
        }
    }
    
    # Display group members if available and not too many
    if ($Assignments.GroupDetails -and $Assignments.Statistics.TotalMembers -gt 0 -and $Assignments.Statistics.TotalMembers -le 20) {
        Write-Host "`nGROUP MEMBERS ($($Assignments.Statistics.TotalMembers)):" -ForegroundColor Cyan
        
        $members = if ($Assignments.GroupDetails.computers.computer -is [array]) {
            $Assignments.GroupDetails.computers.computer
        } else {
            @($Assignments.GroupDetails.computers.computer)
        }
        
        foreach ($member in $members) {
            Write-Host "  - $($member.name) (ID: $($member.id))" -ForegroundColor Gray
        }
    } elseif ($Assignments.Statistics.TotalMembers -gt 20) {
        Write-Host "`nGROUP MEMBERS: $($Assignments.Statistics.TotalMembers) members (too many to display)" -ForegroundColor Gray
    }
    
    Write-Host "`n================================================`n" -ForegroundColor Yellow
}