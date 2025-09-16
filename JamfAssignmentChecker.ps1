#Requires -Version 7.0

<#
.SYNOPSIS
    Checks JAMF Pro policy and configuration profile assignments for computers, users, and groups.

.DESCRIPTION
    This script helps IT administrators analyze and audit JAMF Pro assignments by:
    - Checking assignments for specific computers, users, or groups
    - Showing all policies and profiles with their assignments

.NOTES
    Version:        1.1.0
    Author:         Jorgeasaurus
    Creation Date:  2024-12-29
    Last Modified:  2025-09-16
    
    Version History:
    1.1.0 - Added group assignment analysis feature (Option 3)
            Support for analyzing how computer and mobile device groups are used
            Added Export-GroupAssignmentsToCSV for detailed reporting
    1.0.0 - Initial release with computer and mobile device assignment checking
    - Finding policies and profiles without assignments
    - Identifying empty groups in assignments
    - Analyzing smart group memberships and their impact
    - Exporting results to CSV and HTML formats

.PARAMETER CheckComputer
    Check assignments for specific computers.

.PARAMETER ComputerNames
    Computer names to check, comma-separated.

.PARAMETER CheckUser
    Check assignments for specific users.

.PARAMETER UserNames
    User names to check, comma-separated.

.PARAMETER CheckGroup
    Check assignments for specific groups.

.PARAMETER GroupNames
    Group names to check, comma-separated.

.PARAMETER CheckMobileDevice
    Check assignments for specific mobile devices.

.PARAMETER MobileDeviceNames
    Mobile device names to check, comma-separated.

.PARAMETER ShowAllPolicies
    Show all policies and their assignments.

.PARAMETER ShowAllProfiles
    Show all configuration profiles and their assignments.

.PARAMETER FindUnassignedPolicies
    Find policies without any assignments.

.PARAMETER FindUnassignedProfiles
    Find configuration profiles without any assignments.

.PARAMETER FindEmptyGroups
    Check for empty groups in assignments.

.PARAMETER ShowAllComputerAssignments
    Show assignments for ALL computers in the environment.

.PARAMETER ShowAllUserAssignments
    Show assignments for ALL users in the environment.

.PARAMETER GenerateHTMLReport
    Generate comprehensive HTML report.

.PARAMETER ExportToCSV
    Export results to CSV file.

.PARAMETER ExportPath
    Path for the exported CSV/HTML file.

.PARAMETER Server
    JAMF Pro server URL (e.g., company.jamfcloud.com).

.PARAMETER Username
    Username for JAMF Pro authentication (Basic Auth).

.PARAMETER Password
    Password for JAMF Pro authentication (Basic Auth).

.PARAMETER ClientId
    Client ID for OAuth authentication.

.PARAMETER ClientSecret
    Client Secret for OAuth authentication.

.EXAMPLE
    .\JamfAssignmentChecker.ps1 -CheckComputer -ComputerNames "MacBook-001" -Server "company.jamfcloud.com" -Username "admin" -Password "pass"
    Checks assignments for the specified computer using basic authentication.

.EXAMPLE
    .\JamfAssignmentChecker.ps1 -CheckUser -UserNames "john.doe" -Server "company.jamfcloud.com" -ClientId "client" -ClientSecret "secret"
    Checks assignments for the specified user using OAuth authentication.

.EXAMPLE
    .\JamfAssignmentChecker.ps1 -CheckMobileDevice -MobileDeviceNames "iPad-001" -ExportToCSV -ExportPath "C:\Reports\MobileAssignments.csv"
    Checks assignments for the specified mobile device and exports the results to CSV.

.EXAMPLE
    .\JamfAssignmentChecker.ps1 -ShowAllPolicies -ExportToCSV -ExportPath "C:\Reports\JamfPolicies.csv"
    Shows all policies and exports the results to CSV.

.AUTHOR
    Jorge Suarez (@jorgeasaurus)
    Based on IntuneAssignmentChecker by Ugur Koc (@ugurkocde)
    GitHub: https://github.com/jorgeasaurus/JamfAssignmentChecker

.REQUIRED PERMISSIONS
    - Read access to Computers and Computer Groups
    - Read access to Users and User Groups
    - Read access to Policies
    - Read access to Configuration Profiles
    - Read access to PreStages (if checking prestage assignments)
#>


param(
    [Parameter(Mandatory = $false, HelpMessage = "Check assignments for specific computers")]
    [switch]$CheckComputer,
    
    [Parameter(Mandatory = $false, HelpMessage = "Computer names to check, comma-separated")]
    [string]$ComputerNames,
    
    [Parameter(Mandatory = $false, HelpMessage = "Check assignments for specific users")]
    [switch]$CheckUser,
    
    [Parameter(Mandatory = $false, HelpMessage = "User names to check, comma-separated")]
    [string]$UserNames,
    
    [Parameter(Mandatory = $false, HelpMessage = "Check assignments for specific groups")]
    [switch]$CheckGroup,
    
    [Parameter(Mandatory = $false, HelpMessage = "Group names to check, comma-separated")]
    [string]$GroupNames,
    
    [Parameter(Mandatory = $false, HelpMessage = "Check assignments for specific mobile devices")]
    [switch]$CheckMobileDevice,
    
    [Parameter(Mandatory = $false, HelpMessage = "Mobile device names to check, comma-separated")]
    [string]$MobileDeviceNames,
    
    [Parameter(Mandatory = $false, HelpMessage = "Show all policies and their assignments")]
    [switch]$ShowAllPolicies,
    
    [Parameter(Mandatory = $false, HelpMessage = "Show all configuration profiles and their assignments")]
    [switch]$ShowAllProfiles,
    
    [Parameter(Mandatory = $false, HelpMessage = "Find policies without assignments")]
    [switch]$FindUnassignedPolicies,
    
    [Parameter(Mandatory = $false, HelpMessage = "Find configuration profiles without assignments")]
    [switch]$FindUnassignedProfiles,
    
    [Parameter(Mandatory = $false, HelpMessage = "Check for empty groups in assignments")]
    [switch]$FindEmptyGroups,
    
    [Parameter(Mandatory = $false, HelpMessage = "Show assignments for ALL computers")]
    [switch]$ShowAllComputerAssignments,
    
    [Parameter(Mandatory = $false, HelpMessage = "Show assignments for ALL users")]
    [switch]$ShowAllUserAssignments,
    
    [Parameter(Mandatory = $false, HelpMessage = "Generate HTML report")]
    [switch]$GenerateHTMLReport,
    
    [Parameter(Mandatory = $false, HelpMessage = "Export results to CSV")]
    [switch]$ExportToCSV,
    
    [Parameter(Mandatory = $false, HelpMessage = "Path for the exported CSV/HTML file")]
    [string]$ExportPath,
    
    [Parameter(Mandatory = $false, HelpMessage = "JAMF Pro server URL")]
    [string]$BaseUrl,
    
    [Parameter(Mandatory = $false, HelpMessage = "Username for JAMF Pro authentication")]
    [string]$Username,
    
    [Parameter(Mandatory = $false, HelpMessage = "Password for JAMF Pro authentication")]
    [string]$Password,
    
    [Parameter(Mandatory = $false, HelpMessage = "Client ID for OAuth authentication")]
    [string]$ClientId,
    
    [Parameter(Mandatory = $false, HelpMessage = "Client Secret for OAuth authentication")]
    [string]$ClientSecret
)

# Script version
$script:Version = "1.1.0"

# Check if any command-line parameters were provided
$parameterMode = $false
$selectedOption = $null

if ($CheckComputer) { $parameterMode = $true; $selectedOption = '1' }
elseif ($CheckUser) { $parameterMode = $true; $selectedOption = '2' }
elseif ($CheckGroup) { $parameterMode = $true; $selectedOption = '3' }
elseif ($CheckMobileDevice) { $parameterMode = $true; $selectedOption = '4' }
elseif ($ShowAllComputerAssignments) { $parameterMode = $true; $selectedOption = '5' }
elseif ($ShowAllUserAssignments) { $parameterMode = $true; $selectedOption = '6' }
elseif ($ShowAllPolicies) { $parameterMode = $true; $selectedOption = '7' }
elseif ($ShowAllProfiles) { $parameterMode = $true; $selectedOption = '8' }
elseif ($FindUnassignedPolicies) { $parameterMode = $true; $selectedOption = '9' }
elseif ($FindUnassignedProfiles) { $parameterMode = $true; $selectedOption = '10' }
elseif ($FindEmptyGroups) { $parameterMode = $true; $selectedOption = '11' }
elseif ($GenerateHTMLReport) { $parameterMode = $true; $selectedOption = '12' }

# Display header
Write-Host ""
Write-Host ""
Write-Host "🔍 JAMF ASSIGNMENT CHECKER" -ForegroundColor Cyan
Write-Host "Made by Jorgeasaurus 🚀 | Version $script:Version | Last updated: 2025-09-16"
Write-Host ""
Write-Host "Inspired by Ugur Koc's IntuneAssignmentChecker" -ForegroundColor Gray
Write-Host ""


# Load the PowerShell functions (force reload)
$Functions = Get-ChildItem -Path "$(Get-Location)\Functions\*.ps1" -ErrorAction SilentlyContinue
foreach ($function in $Functions) {
    try {
        # Force reload by removing any existing function definition first
        $functionName = [System.IO.Path]::GetFileNameWithoutExtension($function.Name)
        if (Get-Command $functionName -ErrorAction SilentlyContinue) {
            Remove-Item "Function:\$functionName" -ErrorAction SilentlyContinue
        }
        . $function.FullName
    } catch {
        Write-Error "Failed to import function $($function.FullName): $_"
    }
}

# Script configuration hashtable (will be populated from config.ps1 or user input)
$script:Config = @{
    BaseUrl      = ""
    Username     = ""
    Password     = ""
    ClientId     = ""
    ClientSecret = ""
    Token        = ""
    ApiVersion   = "classic"  # Default to classic API
    DataFolder   = ""         # For compatibility with imported functions
}


# Establish JAMF Pro connection
if (-not (Connect-JamfPro)) {
    Write-Host "Failed to establish connection to JAMF Pro. Exiting." -ForegroundColor Red
    exit 1
}

# Main execution logic
if ($parameterMode) {
    # Execute based on command-line parameters
    switch ($selectedOption) {
        '1' {
            # Check Computer Assignments
            if ([string]::IsNullOrWhiteSpace($ComputerNames)) {
                Write-Host "ERROR: ComputerNames parameter is required when using -CheckComputer" -ForegroundColor Red
                exit 1
            }
            
            $computers = $ComputerNames -split ','
            $allAssignments = @()
            
            foreach ($computerName in $computers) {
                $computerName = $computerName.Trim()
                Write-Host "`nSearching for computer: $computerName" -ForegroundColor Cyan
                
                $computer = Get-JamfComputer -ComputerName $computerName
                
                if ($computer) {
                    $assignments = Get-ComputerAssignments -Computer $computer
                    Show-ComputerAssignments -Assignments $assignments
                    $allAssignments += $assignments
                } else {
                    Write-Host "Computer '$computerName' not found!" -ForegroundColor Red
                }
            }
            
            # Export if requested
            if ($ExportToCSV -and $allAssignments.Count -gt 0) {
                Export-AssignmentsToCSV -Assignments $allAssignments -FilePath $ExportPath
            }
        }
        '2' {
            # Check User Assignments
            Write-Host "User assignment checking not yet implemented." -ForegroundColor Yellow
        }
        '3' {
            # Check Group Assignments
            if ([string]::IsNullOrWhiteSpace($GroupNames)) {
                if (-not $parameterMode) {
                    Write-Host "`nEnter group name(s) to check (comma-separated for multiple):" -ForegroundColor Cyan
                    $GroupNames = Read-Host
                }
                
                if ([string]::IsNullOrWhiteSpace($GroupNames)) {
                    Write-Host "ERROR: Group name(s) required" -ForegroundColor Red
                    if ($parameterMode) { exit 1 }
                    continue
                }
            }
            
            # Ask for group type if not in parameter mode
            $groupType = "Computer"
            if (-not $parameterMode) {
                Write-Host "`nSelect group type:" -ForegroundColor Cyan
                Write-Host "  [1] Computer Group (default)" -ForegroundColor White
                Write-Host "  [2] Mobile Device Group" -ForegroundColor White
                $typeChoice = Read-Host "Choice (1 or 2)"
                
                if ($typeChoice -eq "2") {
                    $groupType = "MobileDevice"
                }
            }
            
            $groups = $GroupNames -split ','
            $allAssignments = @()
            
            foreach ($groupName in $groups) {
                $groupName = $groupName.Trim()
                Write-Host "`nAnalyzing group: $groupName ($groupType)" -ForegroundColor Cyan
                
                $assignments = Get-GroupAssignments -GroupName $groupName -GroupType $groupType
                
                if ($assignments) {
                    Show-GroupAssignments -Assignments $assignments
                    $allAssignments += $assignments
                } else {
                    Write-Host "Failed to analyze group '$groupName'" -ForegroundColor Red
                }
            }
            
            # Export if requested
            if ($ExportToCSV -and $allAssignments.Count -gt 0) {
                if ([string]::IsNullOrWhiteSpace($ExportPath)) {
                    $ExportPath = ".\GroupAssignments_$(Get-Date -Format 'yyyyMMdd_HHmmss').csv"
                }
                Export-GroupAssignmentsToCSV -Assignments $allAssignments -FilePath $ExportPath
            }
            
            if (-not $parameterMode) {
                Read-Host "`nPress Enter to continue"
            }
        }
        '4' {
            # Check Mobile Device Assignments
            if ([string]::IsNullOrWhiteSpace($MobileDeviceNames)) {
                Write-Host "ERROR: MobileDeviceNames parameter is required when using -CheckMobileDevice" -ForegroundColor Red
                exit 1
            }
            
            $mobileDevices = $MobileDeviceNames -split ','
            $allAssignments = @()
            
            foreach ($mobileDeviceName in $mobileDevices) {
                $mobileDeviceName = $mobileDeviceName.Trim()
                Write-Host "`nSearching for mobile device: $mobileDeviceName" -ForegroundColor Cyan
                
                $mobileDevice = Get-JamfMobileDevice -MobileDeviceName $mobileDeviceName
                
                if ($mobileDevice) {
                    $assignments = Get-MobileDeviceAssignments -MobileDevice $mobileDevice
                    Show-MobileDeviceAssignments -Assignments $assignments
                    $allAssignments += $assignments
                } else {
                    Write-Host "Mobile device '$mobileDeviceName' not found!" -ForegroundColor Red
                }
            }
            
            # Export if requested
            if ($ExportToCSV -and $allAssignments.Count -gt 0) {
                Export-MobileDeviceAssignmentsToCSV -Assignments $allAssignments -FilePath $ExportPath
            }
        }
        '5' {
            # Show ALL Computer Assignments
            $allAssignments = Show-AllComputerAssignments -ExportToCSV:$ExportToCSV -ExportPath $ExportPath
        }
        '6' {
            # Show ALL User Assignments
            $allAssignments = Show-AllUserAssignments -ExportToCSV:$ExportToCSV -ExportPath $ExportPath
        }
        '7' {
            # Show All Policies
            $allPolicies = Show-AllPolicies -IncludeDisabled:$false
            
            if ($ExportToCSV) {
                if ([string]::IsNullOrWhiteSpace($ExportPath)) {
                    $ExportPath = "$env:temp\JamfAllPolicies_$(Get-Date -Format 'yyyyMMdd_HHmmss').csv"
                }
                Export-PoliciesToCSV -Policies $allPolicies -FilePath $ExportPath
            }
        }
        '8' {
            # Show All Profiles
            $allProfiles = Show-AllProfiles
            
            if ($ExportToCSV) {
                if ([string]::IsNullOrWhiteSpace($ExportPath)) {
                    $ExportPath = "$env:temp\JamfAllProfiles_$(Get-Date -Format 'yyyyMMdd_HHmmss').csv"
                }
                Export-ProfilesToCSV -Profiles $allProfiles -FilePath $ExportPath
            }
        }
        '9' {
            # Find Unassigned Policies
            $unassignedPolicies = Find-UnassignedPolicies
            
            if ($ExportToCSV -and $unassignedPolicies.Count -gt 0) {
                if ([string]::IsNullOrWhiteSpace($ExportPath)) {
                    $ExportPath = "$env:temp\JamfUnassignedPolicies_$(Get-Date -Format 'yyyyMMdd_HHmmss').csv"
                }
                $unassignedPolicies | Export-Csv -Path $ExportPath -NoTypeInformation -Force
                Write-Host "Exported to: $ExportPath" -ForegroundColor Green
            }
        }
        '10' {
            # Find Unassigned Profiles
            $unassignedProfiles = Find-UnassignedProfiles
            
            if ($ExportToCSV -and $unassignedProfiles.Count -gt 0) {
                if ([string]::IsNullOrWhiteSpace($ExportPath)) {
                    $ExportPath = "$env:temp\JamfUnassignedProfiles_$(Get-Date -Format 'yyyyMMdd_HHmmss').csv"
                }
                $unassignedProfiles | Export-Csv -Path $ExportPath -NoTypeInformation -Force
                Write-Host "Exported to: $ExportPath" -ForegroundColor Green
            }
        }
        '11' {
            # Find Empty Groups
            Write-Host "Find empty groups not yet implemented." -ForegroundColor Yellow
        }
        '12' {
            # Generate HTML Report
            if ([string]::IsNullOrWhiteSpace($ExportPath)) {
                $ExportPath = "$env:temp\JamfAssignmentReport_$(Get-Date -Format 'yyyyMMdd_HHmmss').html"
            }
            Export-JamfHTMLReport -FilePath $ExportPath
        }
    }
} else {
    # Interactive mode
    do {
        $choice = Show-MainMenu
        
        switch ($choice) {
            '1' {
                # Check Computer Assignments
                $computerName = Read-Host "Enter computer name"
                $computer = Get-JamfComputer -ComputerName $computerName
                
                if ($computer) {
                    $assignments = Get-ComputerAssignments -Computer $computer
                    Show-ComputerAssignments -Assignments $assignments
                    
                    $export = Read-Host "`nExport to CSV? (y/n)"
                    if ($export -eq 'y') {
                        $path = Read-Host "Enter export path (e.g., C:\Reports\assignments.csv)"
                        Export-AssignmentsToCSV -Assignments @($assignments) -FilePath $path
                    }
                } else {
                    Write-Host "Computer not found!" -ForegroundColor Red
                }
                
                Read-Host "`nPress Enter to continue"
            }
            '2' {
                # Check User Assignments
                Write-Host "User assignment checking not yet implemented." -ForegroundColor Yellow
            }
            '3' {
                # Check Group Assignments
                Write-Host "Group assignment checking not yet implemented." -ForegroundColor Yellow
            }
            '4' {
                # Check Mobile Device Assignments
                $mobileDeviceName = Read-Host "Enter mobile device name"
                $mobileDevice = Get-JamfMobileDevice -MobileDeviceName $mobileDeviceName
                
                if ($mobileDevice) {
                    $assignments = Get-MobileDeviceAssignments -MobileDevice $mobileDevice
                    Show-MobileDeviceAssignments -Assignments $assignments
                    
                    $export = Read-Host "`nExport to CSV? (y/n)"
                    if ($export -eq 'y') {
                        $path = Read-Host "Enter export path (e.g., C:\Reports\mobile-assignments.csv)"
                        Export-MobileDeviceAssignmentsToCSV -Assignments @($assignments) -FilePath $path
                    }
                } else {
                    Write-Host "Mobile device not found!" -ForegroundColor Red
                }
                
                Read-Host "`nPress Enter to continue"
            }
            '5' {
                # Show ALL Computer Assignments
                Write-Host "⚠️  This will analyze ALL computers in your environment and may take some time." -ForegroundColor Yellow
                $confirm = Read-Host "Do you want to continue? (y/n)"
                
                if ($confirm -eq 'y') {
                    $export = Read-Host "Export to CSV? (y/n)"
                    $exportPath = $null
                    if ($export -eq 'y') {
                        $exportPath = Read-Host "Enter export path (e.g., C:\Reports\all-computer-assignments.csv)"
                    }
                    
                    $allAssignments = Show-AllComputerAssignments -ExportToCSV:($export -eq 'y') -ExportPath $exportPath
                }
                
                Read-Host "`nPress Enter to continue"
            }
            '6' {
                # Show ALL User Assignments
                Write-Host "⚠️  This will analyze ALL users in your environment and may take some time." -ForegroundColor Yellow
                $confirm = Read-Host "Do you want to continue? (y/n)"
                
                if ($confirm -eq 'y') {
                    $export = Read-Host "Export to CSV? (y/n)"
                    $exportPath = $null
                    if ($export -eq 'y') {
                        $exportPath = Read-Host "Enter export path (e.g., C:\Reports\all-user-assignments.csv)"
                    }
                    
                    $allAssignments = Show-AllUserAssignments -ExportToCSV:($export -eq 'y') -ExportPath $exportPath
                }
                
                Read-Host "`nPress Enter to continue"
            }
            '7' {
                # Show All Policies
                $includeDisabled = Read-Host "Include disabled policies? (y/n)"
                $allPolicies = Show-AllPolicies -IncludeDisabled:($includeDisabled -eq 'y')
                
                $export = Read-Host "`nExport to CSV? (y/n)"
                if ($export -eq 'y') {
                    $path = Read-Host "Enter export path (e.g., C:\Reports\policies.csv)"
                    Export-PoliciesToCSV -Policies $allPolicies -FilePath $path
                }
                
                Read-Host "`nPress Enter to continue"
            }
            '8' {
                # Show All Profiles
                $allProfiles = Show-AllProfiles
                
                $export = Read-Host "`nExport to CSV? (y/n)"
                if ($export -eq 'y') {
                    $path = Read-Host "Enter export path (e.g., C:\Reports\profiles.csv)"
                    Export-ProfilesToCSV -Profiles $allProfiles -FilePath $path
                }
                
                Read-Host "`nPress Enter to continue"
            }
            '9' {
                # Find Unassigned Policies
                $unassignedPolicies = Find-UnassignedPolicies
                
                if ($unassignedPolicies.Count -gt 0) {
                    $export = Read-Host "`nExport to CSV? (y/n)"
                    if ($export -eq 'y') {
                        $path = Read-Host "Enter export path (e.g., C:\Reports\unassigned-policies.csv)"
                        $unassignedPolicies | Export-Csv -Path $path -NoTypeInformation -Force
                        Write-Host "Exported to: $path" -ForegroundColor Green
                    }
                }
                
                Read-Host "`nPress Enter to continue"
            }
            '10' {
                # Find Unassigned Profiles
                $unassignedProfiles = Find-UnassignedProfiles
                
                if ($unassignedProfiles.Count -gt 0) {
                    $export = Read-Host "`nExport to CSV? (y/n)"
                    if ($export -eq 'y') {
                        $path = Read-Host "Enter export path (e.g., C:\Reports\unassigned-profiles.csv)"
                        $unassignedProfiles | Export-Csv -Path $path -NoTypeInformation -Force
                        Write-Host "Exported to: $path" -ForegroundColor Green
                    }
                }
                
                Read-Host "`nPress Enter to continue"
            }
            '11' {
                # Find Empty Groups
                Write-Host "Find empty groups not yet implemented." -ForegroundColor Yellow
                Read-Host "`nPress Enter to continue"
            }
            '12' {
                # Generate HTML Report
                $ExportPath = Read-Host "Enter export path for HTML report (e.g., C:\Reports\jamf-report.html)"
                if ([string]::IsNullOrWhiteSpace($ExportPath)) {
                    $ExportPath = ".\JamfAssignmentReport_$(Get-Date -Format 'yyyyMMdd_HHmmss').html"
                }
                Export-JamfHTMLReport -FilePath $ExportPath

                Read-Host "`nPress Enter to continue"
            }
            '0' {
                Write-Host "`nThank you for using JAMF Assignment Checker! 👋" -ForegroundColor Green
                break
            }
            default {
                Write-Host "Invalid choice. Please try again." -ForegroundColor Red
                Start-Sleep -Seconds 1
            }
        }
    } while ($choice -ne '0')
}
