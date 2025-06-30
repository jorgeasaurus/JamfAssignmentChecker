function Generate-GroupTables {
    <#
    .SYNOPSIS
        Generates the groups tables for the HTML report.
    #>
    param (
        [array]$ComputerGroups,
        [array]$MobileDeviceGroups
    )
    
    $html = @"
        <div class="section">
            <div class="section-header">
                👥 Groups Overview
            </div>
            <div class="section-content">
                <div class="filter-container">
                    <input type="text" id="groupFilter" class="filter-input" placeholder="Search groups...">
                </div>
"@
    
    # Computer Groups
    if ($ComputerGroups.Count -gt 0) {
        $html += @"
                <h4>Computer Groups ($($ComputerGroups.Count))</h4>
                <div class="table-container">
                    <table id="groupsTable">
                        <thead>
                            <tr>
                                <th>Group Name</th>
                                <th>ID</th>
                                <th>Type</th>
                                <th>Members</th>
                            </tr>
                        </thead>
                        <tbody>
"@
        
        foreach ($group in $ComputerGroups) {
            $groupName = if ($group.Name) { Escape-Html $group.Name } else { "[Unknown]" }
            $groupId = if ($group.Id) { Escape-Html $group.Id.ToString() } else { "[Unknown]" }
            $groupSize = if ($group.Size -ne $null) { $group.Size } else { "0" }
            $typeBadge = if ($group.IsSmart) { "<span class='badge badge-info'>Smart</span>" } else { "<span class='badge badge-success'>Static</span>" }
            $html += @"
                            <tr>
                                <td>$groupName</td>
                                <td>$groupId</td>
                                <td>$typeBadge</td>
                                <td>$groupSize</td>
                            </tr>
"@
        }
        
        $html += @"
                        </tbody>
                    </table>
                </div>
"@
    }
    
    # Mobile Device Groups
    if ($MobileDeviceGroups.Count -gt 0) {
        $html += @"
                <h4>Mobile Device Groups ($($MobileDeviceGroups.Count))</h4>
                <div class="table-container">
                    <table>
                        <thead>
                            <tr>
                                <th>Group Name</th>
                                <th>ID</th>
                                <th>Type</th>
                                <th>Members</th>
                            </tr>
                        </thead>
                        <tbody>
"@
        
        foreach ($group in $MobileDeviceGroups) {
            $groupName = if ($group.Name) { Escape-Html $group.Name } else { "[Unknown]" }
            $groupId = if ($group.Id) { Escape-Html $group.Id.ToString() } else { "[Unknown]" }
            $groupSize = if ($group.Size -ne $null) { $group.Size } else { "0" }
            $typeBadge = if ($group.IsSmart) { "<span class='badge badge-info'>Smart</span>" } else { "<span class='badge badge-success'>Static</span>" }
            $html += @"
                            <tr>
                                <td>$groupName</td>
                                <td>$groupId</td>
                                <td>$typeBadge</td>
                                <td>$groupSize</td>
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
