function Generate-UnassignedResourcesSection {
    <#
    .SYNOPSIS
        Generates the unassigned resources section for the HTML report.
    #>
    param (
        [array]$UnassignedPolicies,
        [array]$UnassignedProfiles
    )
    
    $html = @"
        <div class="section">
            <div class="section-header">
                ⚠️ Unassigned Resources
            </div>
            <div class="section-content">
"@
    
    if ($UnassignedPolicies.Count -gt 0) {
        $html += @"
                <h4>Unassigned Policies ($($UnassignedPolicies.Count))</h4>
                <div class="table-container">
                    <table>
                        <thead>
                            <tr>
                                <th>Policy Name</th>
                                <th>ID</th>
                                <th>Enabled</th>
                            </tr>
                        </thead>
                        <tbody>
"@
        
        foreach ($policy in $UnassignedPolicies) {
            $policyName = if ($policy.Name) { Escape-Html $policy.Name } else { "[Unknown]" }
            $policyId = if ($policy.Id) { Escape-Html $policy.Id.ToString() } else { "[Unknown]" }
            $enabledBadge = if ($policy.Enabled) { "<span class='badge badge-success'>Enabled</span>" } else { "<span class='badge badge-danger'>Disabled</span>" }
            $html += @"
                            <tr>
                                <td>$policyName</td>
                                <td>$policyId</td>
                                <td>$enabledBadge</td>
                            </tr>
"@
        }
        
        $html += @"
                        </tbody>
                    </table>
                </div>
"@
    }
    
    if ($UnassignedProfiles.Count -gt 0) {
        $html += @"
                <h4>Unassigned Configuration Profiles ($($UnassignedProfiles.Count))</h4>
                <div class="table-container">
                    <table>
                        <thead>
                            <tr>
                                <th>Profile Name</th>
                                <th>ID</th>
                                <th>Type</th>
                            </tr>
                        </thead>
                        <tbody>
"@
        
        foreach ($profile in $UnassignedProfiles) {
            $profileName = if ($profile.Name) { Escape-Html $profile.Name } else { "[Unknown]" }
            $profileId = if ($profile.Id) { Escape-Html $profile.Id.ToString() } else { "[Unknown]" }
            $typeBadge = if ($profile.Type -eq "macOS Configuration Profile") { "<span class='badge badge-info'>macOS</span>" } else { "<span class='badge badge-warning'>Mobile</span>" }
            $html += @"
                            <tr>
                                <td>$profileName</td>
                                <td>$profileId</td>
                                <td>$typeBadge</td>
                            </tr>
"@
        }
        
        $html += @"
                        </tbody>
                    </table>
                </div>
"@
    }
    
    $html += @"
            </div>
        </div>
"@
    
    return $html
}
