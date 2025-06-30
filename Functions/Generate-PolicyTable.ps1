function Generate-PolicyTable {
    <#
    .SYNOPSIS
        Generates the policies table for the HTML report.
    #>
    param (
        [array]$Policies
    )
    
    $html = @"
        <!-- Policies Overview -->
        <div class="card mb-4">
            <div class="card-header bg-primary text-white">
                <h5 class="mb-0"><i class="fas fa-clipboard-list me-2"></i>Policies Overview</h5>
            </div>
            <div class="card-body">
                <div class="table-responsive">
                    <table id="policiesTable" class="table table-striped table-hover">
                        <thead class="table-dark">
                            <tr>
                                <th>Policy Name</th>
                                <th>ID</th>
                                <th>Enabled</th>
                                <th>Computers</th>
                                <th>Computer Groups</th>
                                <th>Users</th>
                                <th>Exclusions</th>
                            </tr>
                        </thead>
                        <tbody>
"@
    
    if ($Policies.Count -eq 0) {
        $html += @"
                            <tr>
                                <td colspan="7" class="no-data">No policies found</td>
                            </tr>
"@
    } else {
        foreach ($policy in $Policies) {
            # Safely get policy properties with null checks
            $policyName = if ($policy.Name) { Escape-Html $policy.Name } else { "[Unknown]" }
            $policyId = if ($policy.Id) { Escape-Html $policy.Id.ToString() } else { "[Unknown]" }
            $enabledBadge = if ($policy.Enabled) { "<span class='badge badge-success'>Enabled</span>" } else { "<span class='badge badge-danger'>Disabled</span>" }
            
            # Safely calculate counts using the processed scope data
            $computersCount = if ($policy.AllComputers) { "All" } else { 
                if ($policy.ComputerCount) { $policy.ComputerCount.ToString() } else { "0" }
            }
            $groupsCount = if ($policy.ComputerGroupCount) { $policy.ComputerGroupCount.ToString() } else { "0" }
            $usersCount = if ($policy.UserCount) { $policy.UserCount.ToString() } else { "0" }
            $exclusionsCount = if ($policy.ExclusionCount) { $policy.ExclusionCount } else { 0 }
            
            $html += @"
                            <tr>
                                <td>$policyName</td>
                                <td>$policyId</td>
                                <td>$enabledBadge</td>
                                <td>$computersCount</td>
                                <td>$groupsCount</td>
                                <td>$usersCount</td>
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
