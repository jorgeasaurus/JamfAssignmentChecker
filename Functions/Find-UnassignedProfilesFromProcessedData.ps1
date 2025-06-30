function Find-UnassignedProfilesFromProcessedData {
    <#
    .SYNOPSIS
        Finds unassigned profiles from already processed profile data (for HTML report efficiency).
    #>
    param (
        [Parameter(Mandatory = $true)]
        [array]$Profiles
    )
    
    $unassignedProfiles = @()
    
    foreach ($profile in $Profiles) {
        $hasAssignments = $false
        
        if ($profile.Scope) {
            if ($profile.Type -eq "macOS Configuration Profile") {
                # Check macOS assignments
                if ($profile.Scope.AllComputers -or 
                    $profile.Scope.Computers.Count -gt 0 -or 
                    $profile.Scope.ComputerGroups.Count -gt 0 -or 
                    $profile.Scope.Users.Count -gt 0 -or 
                    $profile.Scope.UserGroups.Count -gt 0) {
                    $hasAssignments = $true
                }
            } elseif ($profile.Type -eq "Mobile Device Configuration Profile") {
                # Check mobile device assignments
                if ($profile.Scope.AllMobileDevices -or 
                    $profile.Scope.MobileDevices.Count -gt 0 -or 
                    $profile.Scope.MobileDeviceGroups.Count -gt 0 -or 
                    $profile.Scope.Users.Count -gt 0 -or 
                    $profile.Scope.UserGroups.Count -gt 0) {
                    $hasAssignments = $true
                }
            }
        }
        
        if (-not $hasAssignments) {
            $unassignedProfiles += @{
                Id   = $profile.Id
                Name = $profile.Name
                Type = $profile.Type
            }
        }
    }
    
    return $unassignedProfiles
}
