function Show-ComputerAssignments {
    <#
    .SYNOPSIS
        Displays computer assignments in a formatted way.
    #>
    param (
        [Parameter(Mandatory = $true)]
        [object]$Assignments
    )
    
    Write-Host "`n===== ASSIGNMENT RESULTS FOR: $($Assignments.ComputerName) =====" -ForegroundColor Yellow
    
    # Display Policies
    Write-Host "`nPOLICIES:" -ForegroundColor Cyan
    if ($Assignments.Policies.Count -eq 0) {
        Write-Host "  No policies assigned to this computer." -ForegroundColor Gray
    } else {
        $assignedPolicies = $Assignments.Policies | Where-Object { -not $_.IsExcluded }
        $excludedPolicies = $Assignments.Policies | Where-Object { $_.IsExcluded }
        
        if ($assignedPolicies.Count -gt 0) {
            Write-Host "  Assigned ($($assignedPolicies.Count)):" -ForegroundColor Green
            foreach ($policy in $assignedPolicies) {
                $enabledStatus = if ($policy.Enabled -eq "true") { "Enabled" } else { "Disabled" }
                $enabledColor = if ($policy.Enabled -eq "true") { "Green" } else { "DarkGray" }
                Write-Host "    - $($policy.Name)" -ForegroundColor White
                Write-Host "      ID: $($policy.Id) | Status: " -ForegroundColor Gray -NoNewline
                Write-Host $enabledStatus -ForegroundColor $enabledColor
                Write-Host "      Assignment: $($policy.AssignmentReason)" -ForegroundColor Gray
            }
        }
        
        if ($excludedPolicies.Count -gt 0) {
            Write-Host "`n  Excluded ($($excludedPolicies.Count)):" -ForegroundColor Red
            foreach ($policy in $excludedPolicies) {
                Write-Host "    - $($policy.Name)" -ForegroundColor DarkGray
                Write-Host "      ID: $($policy.Id)" -ForegroundColor DarkGray
                Write-Host "      Reason: $($policy.AssignmentReason)" -ForegroundColor DarkGray
            }
        }
    }
    
    # Display Configuration Profiles
    Write-Host "`nCONFIGURATION PROFILES:" -ForegroundColor Cyan
    if ($Assignments.Profiles.Count -eq 0) {
        Write-Host "  No configuration profiles assigned to this computer." -ForegroundColor Gray
    } else {
        $assignedProfiles = $Assignments.Profiles | Where-Object { -not $_.IsExcluded }
        $excludedProfiles = $Assignments.Profiles | Where-Object { $_.IsExcluded }
        
        if ($assignedProfiles.Count -gt 0) {
            Write-Host "  Assigned ($($assignedProfiles.Count)):" -ForegroundColor Green
            foreach ($profile in $assignedProfiles) {
                Write-Host "    - $($profile.Name)" -ForegroundColor White
                Write-Host "      ID: $($profile.Id)" -ForegroundColor Gray
                Write-Host "      Assignment: $($profile.AssignmentReason)" -ForegroundColor Gray
            }
        }
        
        if ($excludedProfiles.Count -gt 0) {
            Write-Host "`n  Excluded ($($excludedProfiles.Count)):" -ForegroundColor Red
            foreach ($profile in $excludedProfiles) {
                Write-Host "    - $($profile.Name)" -ForegroundColor DarkGray
                Write-Host "      ID: $($profile.Id)" -ForegroundColor DarkGray
                Write-Host "      Reason: $($profile.AssignmentReason)" -ForegroundColor DarkGray
            }
        }
    }
    
    Write-Host "`n================================================`n" -ForegroundColor Yellow
}
