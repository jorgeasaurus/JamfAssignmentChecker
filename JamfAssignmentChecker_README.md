# JAMF Assignment Checker

A PowerShell tool for analyzing and auditing JAMF Pro policy and configuration profile assignments. This tool helps IT administrators efficiently analyze assignments for specific computers, users, or groups, identify unassigned policies, and audit the overall assignment landscape in JAMF Pro environments.

## Features

### Currently Implemented
- ✅ **Computer Assignment Analysis**: Check all policies and profiles assigned to specific computers
- ✅ **Policy Management**: View all policies with their assignments and find unassigned policies
- ✅ **Profile Management**: Find unassigned configuration profiles
- ✅ **Multi-Authentication**: Support for both username/password and OAuth client credentials
- ✅ **CSV Export**: Export assignment data to CSV format for further analysis
- ✅ **Scope Analysis**: Analyze inclusion and exclusion scopes for policies and profiles
- ✅ **Interactive and Command-Line Modes**: Use interactively or with command-line parameters

### Coming Soon
- 🚧 User assignment analysis
- 🚧 Group assignment analysis
- 🚧 Empty group detection
- 🚧 HTML report generation
- 🚧 Smart group evaluation
- 🚧 Show all configuration profiles functionality

## Prerequisites

- PowerShell 7.0 or later
- JAMF Pro server access with appropriate API permissions
- `JamfBackupRestoreFunctions.ps1` in the same directory

### Required JAMF Pro Permissions

The tool requires a JAMF Pro user account or API client with the following minimum permissions:

#### Read Permissions Required:
- **Computers**: Read access to computer inventory and group memberships
- **Computer Groups**: Read access to static and smart computer groups
- **Policies**: Read access to policy configuration and scope
- **macOS Configuration Profiles**: Read access to configuration profiles and scope

## Installation

1. Download both files to the same directory:
   - `JamfAssignmentChecker.ps1`
   - `JamfBackupRestoreFunctions.ps1`

2. (Optional) Copy `config.ps1.template` to `config.ps1` and configure your credentials:
   ```powershell
   cp config.ps1.template config.ps1
   # Edit config.ps1 with your JAMF Pro credentials
   ```

## Authentication

The tool supports two authentication methods:

### 1. Username/Password (Basic Auth)
```powershell
.\JamfAssignmentChecker.ps1 -Server "company.jamfcloud.com" -Username "admin" -Password "password"
```

### 2. OAuth Client Credentials
```powershell
.\JamfAssignmentChecker.ps1 -Server "company.jamfcloud.com" -ClientId "client_id" -ClientSecret "client_secret"
```

### 3. Configuration File
Create a `config.ps1` file in the same directory:
```powershell
$Config = @{
    BaseUrl = "company.jamfcloud.com"
    Username = "admin"
    Password = "password"
    # OR use OAuth
    ClientId = ""
    ClientSecret = ""
}
```

## Usage Examples

### Interactive Mode
Simply run the script without parameters:
```powershell
.\JamfAssignmentChecker.ps1
```

### Command-Line Mode

#### Check Computer Assignments
```powershell
# Single computer
.\JamfAssignmentChecker.ps1 -CheckComputer -ComputerNames "MacBook-001" -Server "company.jamfcloud.com" -Username "admin" -Password "pass"

# Multiple computers
.\JamfAssignmentChecker.ps1 -CheckComputer -ComputerNames "MacBook-001,MacBook-002,MacBook-003"

# With CSV export
.\JamfAssignmentChecker.ps1 -CheckComputer -ComputerNames "MacBook-001" -ExportToCSV -ExportPath "C:\Reports\assignments.csv"
```

#### Show All Policies
```powershell
# View all policies and their assignments
.\JamfAssignmentChecker.ps1 -ShowAllPolicies

# Export to CSV
.\JamfAssignmentChecker.ps1 -ShowAllPolicies -ExportToCSV -ExportPath "C:\Reports\all_policies.csv"
```

#### Find Unassigned Resources
```powershell
# Find policies without assignments
.\JamfAssignmentChecker.ps1 -FindUnassignedPolicies

# Find profiles without assignments
.\JamfAssignmentChecker.ps1 -FindUnassignedProfiles

# Export unassigned policies to CSV
.\JamfAssignmentChecker.ps1 -FindUnassignedPolicies -ExportToCSV -ExportPath "C:\Reports\unassigned.csv"
```

## Output Formats

### Console Output
The tool provides color-coded console output:
- ✅ **Green**: Active assignments
- 🔴 **Red**: Exclusions
- 🟡 **Yellow**: Warnings (e.g., no assignments)
- ⚪ **Gray**: Additional information

### CSV Export
Export data includes:
- Computer/Policy/Profile names and IDs
- Assignment reasons (direct, group membership, all computers)
- Enabled/Disabled status
- Exclusion information
- Export timestamp

## Example Output

```
🔍 JAMF ASSIGNMENT CHECKER
Version 1.0.0
Based on IntuneAssignmentChecker by Ugur Koc

Analyzing assignments for computer: MacBook-001
Computer ID: 42
Group Memberships: 3

===== ASSIGNMENT RESULTS FOR: MacBook-001 =====

POLICIES:
  Assigned (5):
    - Software Updates Policy
      ID: 101 | Status: Enabled
      Assignment: All Computers
    - Security Settings
      ID: 102 | Status: Enabled
      Assignment: Group: IT Department
    - Development Tools
      ID: 103 | Status: Enabled
      Assignment: Direct computer assignment

  Excluded (1):
    - Legacy Software
      ID: 104
      Reason: Excluded: Group Marketing

CONFIGURATION PROFILES:
  Assigned (3):
    - Wi-Fi Configuration
      ID: 201
      Assignment: All Computers
    - FileVault Settings
      ID: 202
      Assignment: Group: All Managed Computers
```

## Troubleshooting

### Common Issues

1. **Authentication Failed**
   - Verify your credentials are correct
   - Ensure the user has the required API permissions
   - Check if your JAMF Pro server URL is correct (with or without https://)

2. **JamfBackupRestoreFunctions.ps1 not found**
   - Ensure both files are in the same directory
   - Check file permissions

3. **No assignments found**
   - Verify the computer/user/group name is correct
   - Check if the resource exists in JAMF Pro
   - Ensure you have read permissions for the resources

### Debug Mode
For troubleshooting, you can check the API responses by modifying the script's verbosity or adding debug output.

## Contributing

This tool is based on the IntuneAssignmentChecker project and adapted for JAMF Pro environments. Contributions are welcome!

## Credits

- Based on [IntuneAssignmentChecker](https://github.com/ugurkocde/IntuneAssignmentChecker) by Ugur Koc
- Uses API patterns from [PsJamfBackupRestore](https://github.com/jorgeasaurus/PsJamfBackupRestore)

## License

This project follows the same license as the original IntuneAssignmentChecker project.

## Version History

- **v1.0.0** (2024-12-29)
  - Initial release
  - Computer assignment checking
  - Policy and profile management
  - CSV export functionality
  - Multi-authentication support