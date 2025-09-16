function Generate-ProfileTables {
    <#
    .SYNOPSIS
        Generates the configuration profiles tables for the HTML report.
    #>
    param (
        [array]$Profiles
    )
    
    $html = @"
        <!-- Configuration Profiles Overview -->
        <div class="card mb-4">
            <div class="card-header bg-info text-white">
                <h5 class="mb-0"><i class="fas fa-cogs me-2"></i>Configuration Profiles Overview</h5>
            </div>
            <div class="card-body">
                <div class="table-responsive">
                    <table id="profilesTable" class="table table-striped table-hover">
                        <thead class="table-dark">
                            <tr>
                                <th>Profile Name</th>
                                <th>ID</th>
                                <th>Type</th>
                                <th>Devices</th>
                                <th>Device Groups</th>
                                <th>Exclusions</th>
                            </tr>
                        </thead>
                        <tbody>
"@
    
    if ($Profiles.Count -eq 0) {
        $html += @"
                            <tr>
                                <td colspan="6" class="no-data">No configuration profiles found</td>
                            </tr>
"@
    } else {
        foreach ($profile in $Profiles) {
            # Safely get profile properties with null checks
            $profileName = if ($profile.Name) { Escape-Html $profile.Name } else { "[Unknown]" }
            $profileId = if ($profile.Id) { Escape-Html $profile.Id.ToString() } else { "[Unknown]" }
            $typeBadge = if ($profile.Type -eq "macOS Configuration Profile") { "<span class='badge badge-info'>macOS</span>" } else { "<span class='badge badge-warning'>Mobile</span>" }
            
            # Initialize default values
            $devicesCount = "0"
            $groupsCount = "0"
            $exclusionsCount = 0
            
            # Safely calculate counts based on profile type
            if ($profile.Scope) {
                if ($profile.Type -eq "macOS Configuration Profile") {
                    $devicesCount = if ($profile.Scope.AllComputers) { "All" } else { 
                        if ($profile.Scope.Computers) { $profile.Scope.Computers.Count } else { "0" }
                    }
                    $groupsCount = if ($profile.Scope.ComputerGroups) { $profile.Scope.ComputerGroups.Count } else { "0" }
                    
                    if ($profile.Scope.Exclusions) {
                        $exclusionsCount += if ($profile.Scope.Exclusions.Computers) { $profile.Scope.Exclusions.Computers.Count } else { 0 }
                        $exclusionsCount += if ($profile.Scope.Exclusions.ComputerGroups) { $profile.Scope.Exclusions.ComputerGroups.Count } else { 0 }
                    }
                } else {
                    $devicesCount = if ($profile.Scope.AllMobileDevices) { "All" } else { 
                        if ($profile.Scope.MobileDevices) { $profile.Scope.MobileDevices.Count } else { "0" }
                    }
                    $groupsCount = if ($profile.Scope.MobileDeviceGroups) { $profile.Scope.MobileDeviceGroups.Count } else { "0" }
                    
                    if ($profile.Scope.Exclusions) {
                        $exclusionsCount += if ($profile.Scope.Exclusions.MobileDevices) { $profile.Scope.Exclusions.MobileDevices.Count } else { 0 }
                        $exclusionsCount += if ($profile.Scope.Exclusions.MobileDeviceGroups) { $profile.Scope.Exclusions.MobileDeviceGroups.Count } else { 0 }
                    }
                }
            }
            
            $html += @"
                            <tr>
                                <td>$profileName</td>
                                <td>$profileId</td>
                                <td>$typeBadge</td>
                                <td>$devicesCount</td>
                                <td>$groupsCount</td>
                                <td>$(if ($exclusionsCount -gt 0) { "<span class='badge badge-warning'>$exclusionsCount</span>" } else { "0" })</td>
                            </tr>
"@
        }
    }
    
    $html += @"
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
"@
    
    return $html
}
