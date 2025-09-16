function Export-MobileDeviceAssignmentsToCSV {
    <#
    .SYNOPSIS
        Exports mobile device assignment data to CSV format.
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
            # Export Configuration Profiles
            foreach ($profile in $assignment.Profiles) {
                $csvData += [PSCustomObject]@{
                    MobileDeviceName = $assignment.MobileDeviceName
                    MobileDeviceId   = $assignment.MobileDeviceId
                    DeviceType       = $assignment.DeviceType
                    OSVersion        = $assignment.OSVersion
                    Type             = "Configuration Profile"
                    ItemId           = $profile.Id
                    ItemName         = $profile.Name
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
        Write-Host "Failed to export mobile device assignments to CSV: $_" -ForegroundColor Red
    }
}
