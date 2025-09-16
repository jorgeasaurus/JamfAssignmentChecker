function Export-AssignmentsToCSV {
    <#
    .SYNOPSIS
        Exports assignment data to CSV format.
    #>
    param (
        [Parameter(Mandatory = $true)]
        [array]$Assignments,
        
        [Parameter(Mandatory = $true)]
        [string]$FilePath
    )
    
    try {
        # Ensure directory exists
        $directory = Split-Path -Path $FilePath -Parent
        if (-not [string]::IsNullOrWhiteSpace($directory) -and -not (Test-Path $directory)) {
            New-Item -ItemType Directory -Path $directory -Force | Out-Null
        }
        
        # Create CSV data
        $csvData = @()
        
        foreach ($assignment in $Assignments) {
            # Export Policies
            foreach ($policy in $assignment.Policies) {
                $csvData += [PSCustomObject]@{
                    ComputerName     = $assignment.ComputerName
                    ComputerId       = $assignment.ComputerId
                    Type             = "Policy"
                    ItemId           = $policy.Id
                    ItemName         = $policy.Name
                    Enabled          = $policy.Enabled
                    AssignmentReason = $policy.AssignmentReason
                    IsExcluded       = $policy.IsExcluded
                    ExportDate       = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                }
            }
            
            # Export Configuration Profiles
            foreach ($profile in $assignment.Profiles) {
                $csvData += [PSCustomObject]@{
                    ComputerName     = $assignment.ComputerName
                    ComputerId       = $assignment.ComputerId
                    Type             = "Configuration Profile"
                    ItemId           = $profile.Id
                    ItemName         = $profile.Name
                    Enabled          = "N/A"
                    AssignmentReason = $profile.AssignmentReason
                    IsExcluded       = $profile.IsExcluded
                    ExportDate       = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                }
            }
        }
        
        # Export to CSV
        $csvData | Export-Csv -Path $FilePath -NoTypeInformation -Force
        
        Write-Host "`nSuccessfully exported to: $FilePath" -ForegroundColor Green
        Write-Host "Total records: $($csvData.Count)" -ForegroundColor Gray
        
    } catch {
        Write-Host "Failed to export to CSV: $_" -ForegroundColor Red
    }
}
