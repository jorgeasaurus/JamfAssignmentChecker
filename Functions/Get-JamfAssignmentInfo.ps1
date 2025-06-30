function Get-JamfAssignmentInfo {
    param (
        [Parameter(Mandatory = $true)]
        [AllowNull()]
        [object]$PolicyOrProfile
    )

    if ($null -eq $PolicyOrProfile) {
        return @{
            Type       = "None"
            Target     = "Not Assigned"
            Exclusions = ""
        }
    }

    $types = @()
    $targets = @()
    $exclusions = @()

    # Handle JAMF Policy scope
    if ($PolicyOrProfile.scope) {
        $scope = $PolicyOrProfile.scope
        
        # Check if assigned to all computers
        if ($scope.all_computers -eq "true") {
            $types += "All Computers"
            $targets += "All Computers"
        }
        
        # Check direct computer assignments
        if ($scope.computers.computer) {
            $computers = if ($scope.computers.computer -is [array]) { $scope.computers.computer } else { @($scope.computers.computer) }
            foreach ($computer in $computers) {
                $types += "Computer"
                $targets += $computer.name
            }
        }
        
        # Check computer group assignments
        if ($scope.computer_groups.computer_group) {
            $groups = if ($scope.computer_groups.computer_group -is [array]) { $scope.computer_groups.computer_group } else { @($scope.computer_groups.computer_group) }
            foreach ($group in $groups) {
                $types += "Computer Group"
                $targets += $group.name
            }
        }
        
        # Check user assignments (regular policies)
        if ($scope.users.user) {
            $users = if ($scope.users.user -is [array]) { $scope.users.user } else { @($scope.users.user) }
            foreach ($user in $users) {
                $types += "User"
                $targets += $user.name
            }
        }
        
        # Check JSS user assignments (mobile device profiles)
        if ($scope.jss_users.user) {
            $users = if ($scope.jss_users.user -is [array]) { $scope.jss_users.user } else { @($scope.jss_users.user) }
            foreach ($user in $users) {
                $types += "User"
                $targets += $user.name
            }
        }
        
        # Check user group assignments
        if ($scope.user_groups.user_group) {
            $groups = if ($scope.user_groups.user_group -is [array]) { $scope.user_groups.user_group } else { @($scope.user_groups.user_group) }
            foreach ($group in $groups) {
                $types += "User Group"
                $targets += $group.name
            }
        }
        
        # Check mobile device group assignments (mobile device profiles)
        if ($scope.mobile_device_groups.mobile_device_group) {
            $groups = if ($scope.mobile_device_groups.mobile_device_group -is [array]) { $scope.mobile_device_groups.mobile_device_group } else { @($scope.mobile_device_groups.mobile_device_group) }
            foreach ($group in $groups) {
                $types += "Mobile Device Group"
                $targets += $group.name
            }
        }
        
        # Check building assignments (mobile device profiles)
        if ($scope.buildings.building) {
            $buildings = if ($scope.buildings.building -is [array]) { $scope.buildings.building } else { @($scope.buildings.building) }
            foreach ($building in $buildings) {
                $types += "Building"
                $targets += $building.name
            }
        }
        
        # Check exclusions separately
        if ($scope.exclusions) {
            if ($scope.exclusions.computers.computer) {
                $computers = if ($scope.exclusions.computers.computer -is [array]) { $scope.exclusions.computers.computer } else { @($scope.exclusions.computers.computer) }
                foreach ($computer in $computers) {
                    $exclusions += "Computer: $($computer.name)"
                }
            }
            if ($scope.exclusions.computer_groups.computer_group) {
                $groups = if ($scope.exclusions.computer_groups.computer_group -is [array]) { $scope.exclusions.computer_groups.computer_group } else { @($scope.exclusions.computer_groups.computer_group) }
                foreach ($group in $groups) {
                    $exclusions += "Computer Group: $($group.name)"
                }
            }
            if ($scope.exclusions.users.user) {
                $users = if ($scope.exclusions.users.user -is [array]) { $scope.exclusions.users.user } else { @($scope.exclusions.users.user) }
                foreach ($user in $users) {
                    $exclusions += "User: $($user.name)"
                }
            }
            if ($scope.exclusions.user_groups.user_group) {
                $groups = if ($scope.exclusions.user_groups.user_group -is [array]) { $scope.exclusions.user_groups.user_group } else { @($scope.exclusions.user_groups.user_group) }
                foreach ($group in $groups) {
                    $exclusions += "User Group: $($group.name)"
                }
            }
        }
    }

    # Handle Mobile Device Configuration Profile scope (different structure)
    # Check for JSS user assignments (mobile device profiles)
    if ($PolicyOrProfile.jss_users.user) {
        $users = if ($PolicyOrProfile.jss_users.user -is [array]) { $PolicyOrProfile.jss_users.user } else { @($PolicyOrProfile.jss_users.user) }
        foreach ($user in $users) {
            $types += "User"
            $targets += $user.name
        }
    }

    # Check for mobile device group assignments
    if ($PolicyOrProfile.mobile_device_groups.mobile_device_group) {
        $groups = if ($PolicyOrProfile.mobile_device_groups.mobile_device_group -is [array]) { $PolicyOrProfile.mobile_device_groups.mobile_device_group } else { @($PolicyOrProfile.mobile_device_groups.mobile_device_group) }
        foreach ($group in $groups) {
            $types += "Mobile Device Group"
            $targets += $group.name
        }
    }

    # Check for building assignments (mobile device profiles)
    if ($PolicyOrProfile.buildings.building) {
        $buildings = if ($PolicyOrProfile.buildings.building -is [array]) { $PolicyOrProfile.buildings.building } else { @($PolicyOrProfile.buildings.building) }
        foreach ($building in $buildings) {
            $types += "Building"
            $targets += $building.name
        }
    }

    # If no assignments found
    if ($types.Count -eq 0) {
        return @{
            Type       = "None"
            Target     = "Not Assigned"
            Exclusions = ($exclusions -join "; ")
        }
    }

    # Determine the primary type
    $primaryType = if ($types -contains "All Computers") {
        "All Computers"
    } elseif ($types -contains "Computer Group") {
        "Computer Group"
    } elseif ($types -contains "Computer") {
        "Computer"
    } elseif ($types -contains "Mobile Device Group") {
        "Mobile Device Group"
    } elseif ($types -contains "User Group") {
        "User Group"
    } elseif ($types -contains "User") {
        "User"
    } elseif ($types -contains "Building") {
        "Building"
    } elseif ($types -contains "Exclude") {
        "Exclude"
    } else {
        "None"
    }

    return @{
        Type       = $primaryType
        Target     = ($targets -join "; ")
        Exclusions = ($exclusions -join "; ")
    }
}