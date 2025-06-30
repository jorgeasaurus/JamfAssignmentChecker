function Export-PoliciesToCSV {
    <#
    .SYNOPSIS
        Exports policy data to CSV format.
    #>
    param (
        [Parameter(Mandatory = $true)]
        [array]$Policies,
        
        [Parameter(Mandatory = $true)]
        [string]$FilePath
    )
    
    try {
        # Ensure directory exists
        $directory = Split-Path -Path $FilePath -Parent
        if (-not [string]::IsNullOrWhiteSpace($directory) -and -not (Test-Path $directory)) {
            New-Item -ItemType Directory -Path $directory -Force | Out-Null
        }
        
        # Create CSV data with unified structure
        $csvData = @()
        
        foreach ($policy in $Policies) {
            # Check if policy has All Computers assignment
            if ($policy.Scope.AllComputers -eq "true") {
                $csvData += [PSCustomObject]@{
                    PolicyId         = $policy.Id
                    PolicyName       = $policy.Name
                    Enabled          = $policy.Enabled
                    AssignmentType   = "All Computers"
                    AssignmentTarget = "All Computers"
                    TargetId         = ""
                    IsExclusion      = $false
                    ExportDate       = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                }
            }
            
            # Add direct computer assignments
            if ($policy.Scope.Computers -and $policy.Scope.Computers.Count -gt 0) {
                foreach ($comp in $policy.Scope.Computers) {
                    $csvData += [PSCustomObject]@{
                        PolicyId         = $policy.Id
                        PolicyName       = $policy.Name
                        Enabled          = $policy.Enabled
                        AssignmentType   = "Direct Computer"
                        AssignmentTarget = $comp.Name
                        TargetId         = $comp.Id
                        IsExclusion      = $false
                        ExportDate       = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                    }
                }
            }
            
            # Add computer group assignments
            if ($policy.Scope.ComputerGroups -and $policy.Scope.ComputerGroups.Count -gt 0) {
                foreach ($group in $policy.Scope.ComputerGroups) {
                    $csvData += [PSCustomObject]@{
                        PolicyId         = $policy.Id
                        PolicyName       = $policy.Name
                        Enabled          = $policy.Enabled
                        AssignmentType   = "Computer Group"
                        AssignmentTarget = $group.Name
                        TargetId         = $group.Id
                        IsExclusion      = $false
                        ExportDate       = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                    }
                }
            }
            
            # Add computer exclusions
            if ($policy.Scope.Exclusions.Computers -and $policy.Scope.Exclusions.Computers.Count -gt 0) {
                foreach ($comp in $policy.Scope.Exclusions.Computers) {
                    $csvData += [PSCustomObject]@{
                        PolicyId         = $policy.Id
                        PolicyName       = $policy.Name
                        Enabled          = $policy.Enabled
                        AssignmentType   = "Excluded Computer"
                        AssignmentTarget = $comp.Name
                        TargetId         = $comp.Id
                        IsExclusion      = $true
                        ExportDate       = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                    }
                }
            }
            
            # Add computer group exclusions
            if ($policy.Scope.Exclusions.ComputerGroups -and $policy.Scope.Exclusions.ComputerGroups.Count -gt 0) {
                foreach ($group in $policy.Scope.Exclusions.ComputerGroups) {
                    $csvData += [PSCustomObject]@{
                        PolicyId         = $policy.Id
                        PolicyName       = $policy.Name
                        Enabled          = $policy.Enabled
                        AssignmentType   = "Excluded Group"
                        AssignmentTarget = $group.Name
                        TargetId         = $group.Id
                        IsExclusion      = $true
                        ExportDate       = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                    }
                }
            }
            
            # If policy has no assignments at all, add a "None" record
            $hasAnyAssignment = ($policy.Scope.AllComputers -eq "true") -or 
                              ($policy.Scope.Computers -and $policy.Scope.Computers.Count -gt 0) -or
                              ($policy.Scope.ComputerGroups -and $policy.Scope.ComputerGroups.Count -gt 0)
            
            if (-not $hasAnyAssignment) {
                $csvData += [PSCustomObject]@{
                    PolicyId         = $policy.Id
                    PolicyName       = $policy.Name
                    Enabled          = $policy.Enabled
                    AssignmentType   = "None"
                    AssignmentTarget = "Not Assigned"
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
        Write-Host "Failed to export policies to CSV: $_" -ForegroundColor Red
    }
}
