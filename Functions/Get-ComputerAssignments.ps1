function Get-ComputerAssignments {
    <#
    .SYNOPSIS
        Analyzes all policy and profile assignments for a specific computer.
    #>
    param (
        [Parameter(Mandatory = $true)]
        [object]$Computer
    )
    
    $assignments = @{
        ComputerName = $Computer.general.name
        ComputerId   = $Computer.general.id
        Policies     = @()
        Profiles     = @()
    }
    
    # Get computer's group memberships
    $computerGroups = @()
    if ($Computer.groups_accounts.computer_group_memberships.group) {
        $computerGroups = $Computer.groups_accounts.computer_group_memberships.group
    }
    
    Write-Host "`nAnalyzing assignments for computer: $($Computer.general.name)" -ForegroundColor Cyan
    Write-Host "Computer ID: $($Computer.general.id)" -ForegroundColor Gray
    Write-Host "Group Memberships: $($computerGroups.Count)" -ForegroundColor Gray
    
    # Check all policies
    $policies = Get-JamfPolicies
    $matchedPolicies = 0
    
    foreach ($policy in $policies) {
        $policyDetails = Get-JamfPolicyDetails -PolicyId $policy.id
        
        if ($policyDetails) {
            $isAssigned = $false
            $assignmentReason = ""
            
            # Check if computer is in scope
            # Direct computer assignment
            if ($policyDetails.scope.computers.computer.id -contains $Computer.general.id) {
                $isAssigned = $true
                $assignmentReason = "Direct computer assignment"
            }
            # All computers
            elseif ($policyDetails.scope.all_computers -eq "true") {
                $isAssigned = $true
                $assignmentReason = "All Computers"
            }
            # Group assignment
            else {
                foreach ($group in $computerGroups) {
                    if ($policyDetails.scope.computer_groups.computer_group.id -contains $group) {
                        $isAssigned = $true
                        $groupDetails = Get-JamfComputerGroupDetails -GroupId $group
                        $assignmentReason = "Group: $($groupDetails.name)"
                        break
                    }
                }
            }
            
            # Check exclusions
            if ($isAssigned) {
                # Direct computer exclusion
                if ($policyDetails.scope.exclusions.computers.computer.id -contains $Computer.general.id) {
                    $isAssigned = $false
                    $assignmentReason = "Excluded: Direct computer exclusion"
                }
                # Group exclusion
                else {
                    foreach ($group in $computerGroups) {
                        if ($policyDetails.scope.exclusions.computer_groups.computer_group.id -contains $group) {
                            $isAssigned = $false
                            $groupDetails = Get-JamfComputerGroupDetails -GroupId $group
                            $assignmentReason = "Excluded: Group $($groupDetails.name)"
                            break
                        }
                    }
                }
            }
            
            if ($isAssigned -or $assignmentReason -like "Excluded:*") {
                $matchedPolicies++
                $assignments.Policies += @{
                    Id               = $policyDetails.general.id
                    Name             = $policyDetails.general.name
                    Enabled          = $policyDetails.general.enabled
                    AssignmentReason = $assignmentReason
                    IsExcluded       = $assignmentReason -like "Excluded:*"
                }
            }
        }
    }
    
    # Check all configuration profiles
    $profiles = Get-JamfConfigurationProfiles
    $matchedProfiles = 0
    
    foreach ($profile in $profiles) {
        $profileDetails = Get-JamfConfigurationProfileDetails -ProfileId $profile.id
        
        if ($profileDetails) {
            $isAssigned = $false
            $assignmentReason = ""
            
            # Check if computer is in scope
            # Direct computer assignment
            if ($profileDetails.scope.computers.computer.id -contains $Computer.general.id) {
                $isAssigned = $true
                $assignmentReason = "Direct computer assignment"
            }
            # All computers
            elseif ($profileDetails.scope.all_computers -eq "true") {
                $isAssigned = $true
                $assignmentReason = "All Computers"
            }
            # Group assignment
            else {
                foreach ($group in $computerGroups) {
                    if ($profileDetails.scope.computer_groups.computer_group.id -contains $group) {
                        $isAssigned = $true
                        $groupDetails = Get-JamfComputerGroupDetails -GroupId $group
                        $assignmentReason = "Group: $($groupDetails.name)"
                        break
                    }
                }
            }
            
            # Check exclusions
            if ($isAssigned) {
                # Direct computer exclusion
                if ($profileDetails.scope.exclusions.computers.computer.id -contains $Computer.general.id) {
                    $isAssigned = $false
                    $assignmentReason = "Excluded: Direct computer exclusion"
                }
                # Group exclusion
                else {
                    foreach ($group in $computerGroups) {
                        if ($profileDetails.scope.exclusions.computer_groups.computer_group.id -contains $group) {
                            $isAssigned = $false
                            $groupDetails = Get-JamfComputerGroupDetails -GroupId $group
                            $assignmentReason = "Excluded: Group $($groupDetails.name)"
                            break
                        }
                    }
                }
            }
            
            if ($isAssigned -or $assignmentReason -like "Excluded:*") {
                $matchedProfiles++
                $assignments.Profiles += @{
                    Id               = $profileDetails.general.id
                    Name             = $profileDetails.general.name
                    AssignmentReason = $assignmentReason
                    IsExcluded       = $assignmentReason -like "Excluded:*"
                }
            }
        }
    }
    
    Write-Host "Found $matchedPolicies relevant policies" -ForegroundColor Gray
    Write-Host "Found $matchedProfiles relevant profiles" -ForegroundColor Gray
    
    return $assignments
}
