function Export-GroupAssignmentsToCSV {
    <#
    .SYNOPSIS
        Exports group assignment data to a CSV file.
    
    .DESCRIPTION
        Creates a CSV file containing all policies and profiles that use the specified group,
        including usage type (inclusion/exclusion) and other details.
    
    .PARAMETER Assignments
        The assignments object(s) returned from Get-GroupAssignments.
    
    .PARAMETER FilePath
        The path where the CSV file should be saved.
    #>
    param (
        [Parameter(Mandatory = $true)]
        [object[]]$Assignments,
        
        [Parameter(Mandatory = $true)]
        [string]$FilePath
    )
    
    try {
        $csvData = @()
        
        foreach ($assignment in $Assignments) {
            if (-not $assignment) { continue }
            
            # Add policy entries
            foreach ($policy in $assignment.Policies) {
                $csvData += [PSCustomObject]@{
                    GroupName = $assignment.GroupName
                    GroupType = $assignment.GroupType
                    GroupID = $assignment.GroupId
                    GroupMembers = $assignment.Statistics.TotalMembers
                    IsSmart = $assignment.Statistics.IsSmart
                    ResourceType = "Policy"
                    ResourceName = $policy.Name
                    ResourceID = $policy.Id
                    Enabled = $policy.Enabled
                    UsageType = $policy.UsageType
                    ScopeDetails = $policy.ScopeDetails
                    ExportDate = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
                }
            }
            
            # Add configuration profile entries
            foreach ($profile in $assignment.Profiles) {
                $csvData += [PSCustomObject]@{
                    GroupName = $assignment.GroupName
                    GroupType = $assignment.GroupType
                    GroupID = $assignment.GroupId
                    GroupMembers = $assignment.Statistics.TotalMembers
                    IsSmart = $assignment.Statistics.IsSmart
                    ResourceType = "Configuration Profile"
                    ResourceName = $profile.Name
                    ResourceID = $profile.Id
                    Enabled = "N/A"
                    UsageType = $profile.UsageType
                    ScopeDetails = $profile.ScopeDetails
                    ExportDate = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
                }
            }
            
            # Add mobile device profile entries
            foreach ($profile in $assignment.MobileProfiles) {
                $csvData += [PSCustomObject]@{
                    GroupName = $assignment.GroupName
                    GroupType = $assignment.GroupType
                    GroupID = $assignment.GroupId
                    GroupMembers = $assignment.Statistics.TotalMembers
                    IsSmart = "N/A"
                    ResourceType = "Mobile Device Profile"
                    ResourceName = $profile.Name
                    ResourceID = $profile.Id
                    Enabled = "N/A"
                    UsageType = $profile.UsageType
                    ScopeDetails = $profile.ScopeDetails
                    ExportDate = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
                }
            }
            
            # If no policies or profiles use this group, add a single row indicating that
            if ($assignment.Policies.Count -eq 0 -and $assignment.Profiles.Count -eq 0 -and $assignment.MobileProfiles.Count -eq 0) {
                $csvData += [PSCustomObject]@{
                    GroupName = $assignment.GroupName
                    GroupType = $assignment.GroupType
                    GroupID = $assignment.GroupId
                    GroupMembers = $assignment.Statistics.TotalMembers
                    IsSmart = if ($assignment.GroupType -eq "Computer") { $assignment.Statistics.IsSmart } else { "N/A" }
                    ResourceType = "None"
                    ResourceName = "Group not used in any policies or profiles"
                    ResourceID = "N/A"
                    Enabled = "N/A"
                    UsageType = "Not Used"
                    ScopeDetails = "This group is not referenced in any policy or profile scope"
                    ExportDate = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
                }
            }
        }
        
        if ($csvData.Count -gt 0) {
            # Ensure directory exists
            $directory = Split-Path -Path $FilePath -Parent
            if ($directory -and -not (Test-Path $directory)) {
                New-Item -ItemType Directory -Path $directory -Force | Out-Null
            }
            
            # Export to CSV
            $csvData | Export-Csv -Path $FilePath -NoTypeInformation -Force
            
            Write-Host "`n✅ Group assignment data exported to: $FilePath" -ForegroundColor Green
            Write-Host "   Total rows exported: $($csvData.Count)" -ForegroundColor Gray
            
            # Display summary
            $groupCount = ($csvData | Select-Object -ExpandProperty GroupName -Unique).Count
            $policyCount = ($csvData | Where-Object { $_.ResourceType -eq "Policy" }).Count
            $profileCount = ($csvData | Where-Object { $_.ResourceType -eq "Configuration Profile" }).Count
            $mobileProfileCount = ($csvData | Where-Object { $_.ResourceType -eq "Mobile Device Profile" }).Count
            
            Write-Host "`n   Export Summary:" -ForegroundColor Cyan
            Write-Host "   - Groups analyzed: $groupCount" -ForegroundColor Gray
            Write-Host "   - Policy assignments: $policyCount" -ForegroundColor Gray
            Write-Host "   - Configuration profile assignments: $profileCount" -ForegroundColor Gray
            if ($mobileProfileCount -gt 0) {
                Write-Host "   - Mobile device profile assignments: $mobileProfileCount" -ForegroundColor Gray
            }
            
            # Count usage types
            $inclusions = ($csvData | Where-Object { $_.UsageType -eq "Inclusion" }).Count
            $exclusions = ($csvData | Where-Object { $_.UsageType -eq "Exclusion" }).Count
            $both = ($csvData | Where-Object { $_.UsageType -eq "Both" }).Count
            $notUsed = ($csvData | Where-Object { $_.UsageType -eq "Not Used" }).Count
            
            if ($inclusions -gt 0 -or $exclusions -gt 0 -or $both -gt 0) {
                Write-Host "`n   Usage Types:" -ForegroundColor Cyan
                if ($inclusions -gt 0) { Write-Host "   - Inclusions: $inclusions" -ForegroundColor Green }
                if ($exclusions -gt 0) { Write-Host "   - Exclusions: $exclusions" -ForegroundColor Red }
                if ($both -gt 0) { Write-Host "   - Both (inclusion and exclusion): $both" -ForegroundColor Yellow }
                if ($notUsed -gt 0) { Write-Host "   - Not used: $notUsed" -ForegroundColor Gray }
            }
            
            return $true
        } else {
            Write-Host "`n⚠️  No data to export" -ForegroundColor Yellow
            return $false
        }
        
    } catch {
        Write-Host "`n❌ Failed to export group assignments to CSV: $_" -ForegroundColor Red
        Write-Host $_.Exception.StackTrace -ForegroundColor Red
        return $false
    }
}