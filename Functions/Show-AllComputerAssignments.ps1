function Show-AllComputerAssignments {
    <#
    .SYNOPSIS
        Displays assignment information for all computers in JAMF Pro.
    
    .DESCRIPTION
        Retrieves all computers from JAMF Pro and shows what policies and configuration profiles are assigned to each computer.
        Provides comprehensive assignment analysis across the entire computer inventory.
    
    .PARAMETER ExportToCSV
        Export results to CSV file.
    
    .PARAMETER ExportPath
        Path for the exported CSV file.
    #>
    param (
        [Parameter(Mandatory = $false)]
        [switch]$ExportToCSV,
        
        [Parameter(Mandatory = $false)]
        [string]$ExportPath
    )
    
    Write-Host "`n💻 Fetching all computers and their assignments..." -ForegroundColor Cyan
    
    try {
        # Get all computers
        $allComputers = Get-JamfComputers
        
        if (-not $allComputers -or $allComputers.Count -eq 0) {
            Write-Host "⚠️  No computers found in JAMF Pro." -ForegroundColor Yellow
            return @()
        }
        
        Write-Host "Found $($allComputers.Count) computers. Analyzing assignments..." -ForegroundColor Green
        
        $allAssignments = @()
        $processedCount = 0
        
        foreach ($computer in $allComputers) {
            $processedCount++
            Write-Progress -Activity "Analyzing computer assignments" -Status "Processing $($computer.name) ($processedCount of $($allComputers.Count))" -PercentComplete (($processedCount / $allComputers.Count) * 100)
            
            try {
                # Get detailed computer information
                $computerDetails = Get-JamfComputerDetails -ComputerId $computer.id
                
                if ($computerDetails) {
                    $assignments = Get-ComputerAssignments -Computer $computerDetails
                    
                    # Create flattened assignment records for CSV export
                    # Process policies
                    foreach ($policy in $assignments.Policies) {
                        $allAssignments += [PSCustomObject]@{
                            ComputerName     = $computer.name
                            ComputerId       = $computer.id
                            SerialNumber     = $computerDetails.general.serial_number
                            ResourceType     = "Policy"
                            ResourceId       = $policy.Id
                            ResourceName     = $policy.Name
                            AssignmentReason = $policy.AssignmentReason
                            IsExcluded       = $policy.IsExcluded
                            AssignmentType   = if ($policy.IsExcluded) { "Exclusion" } else { "Assignment" }
                        }
                    }
                    
                    # Process profiles
                    foreach ($profile in $assignments.Profiles) {
                        $allAssignments += [PSCustomObject]@{
                            ComputerName     = $computer.name
                            ComputerId       = $computer.id
                            SerialNumber     = $computerDetails.general.serial_number
                            ResourceType     = "Configuration Profile"
                            ResourceId       = $profile.Id
                            ResourceName     = $profile.Name
                            AssignmentReason = $profile.AssignmentReason
                            IsExcluded       = $profile.IsExcluded
                            AssignmentType   = if ($profile.IsExcluded) { "Exclusion" } else { "Assignment" }
                        }
                    }
                    
                    # If no assignments, create a record showing the computer has no assignments
                    if ($assignments.Policies.Count -eq 0 -and $assignments.Profiles.Count -eq 0) {
                        $allAssignments += [PSCustomObject]@{
                            ComputerName     = $computer.name
                            ComputerId       = $computer.id
                            SerialNumber     = $computerDetails.general.serial_number
                            ResourceType     = "No Assignments"
                            ResourceId       = ""
                            ResourceName     = "No policies or profiles assigned"
                            AssignmentReason = "Computer has no assignments"
                            IsExcluded       = $false
                            AssignmentType   = "None"
                        }
                    }
                }
            } catch {
                Write-Host "⚠️  Failed to get assignments for computer '$($computer.name)': $_" -ForegroundColor Yellow
            }
        }
        
        Write-Progress -Activity "Analyzing computer assignments" -Completed
        
        # Display summary
        Write-Host "`n===== ALL COMPUTER ASSIGNMENTS SUMMARY =====" -ForegroundColor Yellow
        Write-Host "Total Computers Analyzed: $($allComputers.Count)" -ForegroundColor Cyan
        Write-Host "Total Assignment Records: $($allAssignments.Count)" -ForegroundColor Cyan
        
        # Group assignments by resource type
        $resourceGroups = $allAssignments | Where-Object { $_.ResourceType -ne "No Assignments" } | Group-Object ResourceType
        foreach ($group in $resourceGroups) {
            Write-Host "  $($group.Name): $($group.Count) assignments" -ForegroundColor Gray
        }
        
        # Show assignment types
        $assignmentTypeGroups = $allAssignments | Where-Object { $_.ResourceType -ne "No Assignments" } | Group-Object AssignmentType
        foreach ($group in $assignmentTypeGroups) {
            Write-Host "  $($group.Name): $($group.Count) assignments" -ForegroundColor Gray
        }
        
        # Show computers with most assignments
        $computerAssignmentCounts = $allAssignments | Where-Object { $_.ResourceType -ne "No Assignments" } | Group-Object ComputerName | Sort-Object Count -Descending | Select-Object -First 5
        if ($computerAssignmentCounts) {
            Write-Host "`nTop 5 Computers by Assignment Count:" -ForegroundColor Cyan
            foreach ($computerGroup in $computerAssignmentCounts) {
                Write-Host "  $($computerGroup.Name): $($computerGroup.Count) assignments" -ForegroundColor Gray
            }
        }
        
        # Show unassigned computers
        $unassignedComputers = $allAssignments | Where-Object { $_.ResourceType -eq "No Assignments" }
        
        if ($unassignedComputers) {
            Write-Host "`n⚠️  Computers with NO assignments:" -ForegroundColor Yellow
            foreach ($computer in $unassignedComputers | Select-Object -First 10) {
                Write-Host "  - $($computer.ComputerName)" -ForegroundColor DarkGray
            }
            if ($unassignedComputers.Count -gt 10) {
                Write-Host "  ... and $($unassignedComputers.Count - 10) more" -ForegroundColor DarkGray
            }
        }
        
        # Export if requested
        if ($ExportToCSV) {
            if ([string]::IsNullOrWhiteSpace($ExportPath)) {
                $ExportPath = "$env:temp\JamfAllComputerAssignments_$(Get-Date -Format 'yyyyMMdd_HHmmss').csv"
            }
            
            try {
                $allAssignments | Export-Csv -Path $ExportPath -NoTypeInformation -Force
                Write-Host "`n✅ Exported to: $ExportPath" -ForegroundColor Green
                Write-Host "📊 Total records: $($allAssignments.Count)" -ForegroundColor Gray
            } catch {
                Write-Host "❌ Failed to export assignments: $_" -ForegroundColor Red
            }
        }
        
        Write-Host ""
        return $allAssignments
        
    } catch {
        Write-Host "❌ Failed to analyze all computer assignments: $_" -ForegroundColor Red
        return @()
    }
}