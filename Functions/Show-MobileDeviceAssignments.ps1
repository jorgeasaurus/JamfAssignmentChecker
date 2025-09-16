function Show-MobileDeviceAssignments {
    <#
    .SYNOPSIS
        Displays mobile device assignments in a formatted way.
    #>
    param (
        [Parameter(Mandatory = $true)]
        [object]$Assignments
    )
    
    Write-Host "`n===== ASSIGNMENT RESULTS FOR: $($Assignments.MobileDeviceName) =====" -ForegroundColor Yellow
    Write-Host "Device Type: $($Assignments.DeviceType)" -ForegroundColor Gray
    Write-Host "OS Version: $($Assignments.OSVersion)" -ForegroundColor Gray
    
    # Display Configuration Profiles
    Write-Host "`nCONFIGURATION PROFILES:" -ForegroundColor Cyan
    if ($Assignments.Profiles.Count -eq 0) {
        Write-Host "  No configuration profiles assigned to this mobile device." -ForegroundColor Gray
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
