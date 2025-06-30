function Export-ProfilesToCSV {
    <#
    .SYNOPSIS
        Exports profile data to CSV format (both macOS and mobile device profiles).
    #>
    param (
        [Parameter(Mandatory = $true)]
        [array]$Profiles,
        
        [Parameter(Mandatory = $true)]
        [string]$FilePath
    )
    
    try {
        # Ensure directory exists
        $directory = Split-Path -Path $FilePath -Parent
        if (-not [string]::IsNullOrWhiteSpace($directory) -and -not (Test-Path $directory)) {
            New-Item -ItemType Directory -Path $directory -Force | Out-Null
        }
        
        # Create unified CSV data - one row per assignment relationship
        $csvData = @()
        
        foreach ($profile in $Profiles) {
            $hasAssignments = $false
            
            # Handle macOS Configuration Profiles
            if ($profile.Type -eq "macOS Configuration Profile") {
                # All computers assignment
                if ($profile.Scope.AllComputers) {
                    $csvData += [PSCustomObject]@{
                        ProfileId        = $profile.Id
                        ProfileName      = $profile.Name
                        ProfileType      = $profile.Type
                        AssignmentType   = "All Computers"
                        AssignmentTarget = "All Computers"
                        TargetId         = "ALL"
                        IsExclusion      = $false
                        ExportDate       = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                    }
                    $hasAssignments = $true
                }
                
                # Direct computer assignments
                foreach ($comp in $profile.Scope.Computers) {
                    $csvData += [PSCustomObject]@{
                        ProfileId        = $profile.Id
                        ProfileName      = $profile.Name
                        ProfileType      = $profile.Type
                        AssignmentType   = "Computer"
                        AssignmentTarget = $comp.Name
                        TargetId         = $comp.Id
                        IsExclusion      = $false
                        ExportDate       = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                    }
                    $hasAssignments = $true
                }
                
                # Computer group assignments
                foreach ($group in $profile.Scope.ComputerGroups) {
                    $csvData += [PSCustomObject]@{
                        ProfileId        = $profile.Id
                        ProfileName      = $profile.Name
                        ProfileType      = $profile.Type
                        AssignmentType   = "Computer Group"
                        AssignmentTarget = $group.Name
                        TargetId         = $group.Id
                        IsExclusion      = $false
                        ExportDate       = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                    }
                    $hasAssignments = $true
                }
                
                # Computer exclusions
                foreach ($comp in $profile.Scope.Exclusions.Computers) {
                    $csvData += [PSCustomObject]@{
                        ProfileId        = $profile.Id
                        ProfileName      = $profile.Name
                        ProfileType      = $profile.Type
                        AssignmentType   = "Excluded Computer"
                        AssignmentTarget = $comp.Name
                        TargetId         = $comp.Id
                        IsExclusion      = $true
                        ExportDate       = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                    }
                }
                
                # Computer group exclusions
                foreach ($group in $profile.Scope.Exclusions.ComputerGroups) {
                    $csvData += [PSCustomObject]@{
                        ProfileId        = $profile.Id
                        ProfileName      = $profile.Name
                        ProfileType      = $profile.Type
                        AssignmentType   = "Excluded Computer Group"
                        AssignmentTarget = $group.Name
                        TargetId         = $group.Id
                        IsExclusion      = $true
                        ExportDate       = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                    }
                }
            }
            
            # Handle Mobile Device Configuration Profiles
            elseif ($profile.Type -eq "Mobile Device Configuration Profile") {
                # All mobile devices assignment
                if ($profile.Scope.AllMobileDevices) {
                    $csvData += [PSCustomObject]@{
                        ProfileId        = $profile.Id
                        ProfileName      = $profile.Name
                        ProfileType      = $profile.Type
                        AssignmentType   = "All Mobile Devices"
                        AssignmentTarget = "All Mobile Devices"
                        TargetId         = "ALL"
                        IsExclusion      = $false
                        ExportDate       = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                    }
                    $hasAssignments = $true
                }
                
                # Direct mobile device assignments
                foreach ($device in $profile.Scope.MobileDevices) {
                    $csvData += [PSCustomObject]@{
                        ProfileId        = $profile.Id
                        ProfileName      = $profile.Name
                        ProfileType      = $profile.Type
                        AssignmentType   = "Mobile Device"
                        AssignmentTarget = $device.Name
                        TargetId         = $device.Id
                        IsExclusion      = $false
                        ExportDate       = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                    }
                    $hasAssignments = $true
                }
                
                # Mobile device group assignments
                foreach ($group in $profile.Scope.MobileDeviceGroups) {
                    $csvData += [PSCustomObject]@{
                        ProfileId        = $profile.Id
                        ProfileName      = $profile.Name
                        ProfileType      = $profile.Type
                        AssignmentType   = "Mobile Device Group"
                        AssignmentTarget = $group.Name
                        TargetId         = $group.Id
                        IsExclusion      = $false
                        ExportDate       = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                    }
                    $hasAssignments = $true
                }
                
                # Mobile device exclusions
                foreach ($device in $profile.Scope.Exclusions.MobileDevices) {
                    $csvData += [PSCustomObject]@{
                        ProfileId        = $profile.Id
                        ProfileName      = $profile.Name
                        ProfileType      = $profile.Type
                        AssignmentType   = "Excluded Mobile Device"
                        AssignmentTarget = $device.Name
                        TargetId         = $device.Id
                        IsExclusion      = $true
                        ExportDate       = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                    }
                }
                
                # Mobile device group exclusions
                foreach ($group in $profile.Scope.Exclusions.MobileDeviceGroups) {
                    $csvData += [PSCustomObject]@{
                        ProfileId        = $profile.Id
                        ProfileName      = $profile.Name
                        ProfileType      = $profile.Type
                        AssignmentType   = "Excluded Mobile Device Group"
                        AssignmentTarget = $group.Name
                        TargetId         = $group.Id
                        IsExclusion      = $true
                        ExportDate       = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                    }
                }
            }
            
            # If profile has no assignments, create a record showing it's unassigned
            if (-not $hasAssignments) {
                $csvData += [PSCustomObject]@{
                    ProfileId        = $profile.Id
                    ProfileName      = $profile.Name
                    ProfileType      = $profile.Type
                    AssignmentType   = "Unassigned"
                    AssignmentTarget = "No Assignments"
                    TargetId         = ""
                    IsExclusion      = $false
                    ExportDate       = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                }
            }
        }
        
        # Export to CSV
        $csvData | Export-Csv -Path $FilePath -NoTypeInformation -Force
        
        Write-Host "`nSuccessfully exported to: $FilePath" -ForegroundColor Green
        Write-Host "Total records: $($csvData.Count)" -ForegroundColor Gray
        
    } catch {
        Write-Host "Failed to export profiles to CSV: $_" -ForegroundColor Red
    }
}
