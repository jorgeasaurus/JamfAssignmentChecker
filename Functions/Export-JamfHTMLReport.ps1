function Export-JamfHTMLReport {
    param (
        [Parameter(Mandatory = $true)]
        [string]$FilePath
    )

    # HTML template with placeholders for JAMF-specific content
    $htmlTemplate = @"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>JAMF Assignment Report</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.datatables.net/1.13.7/css/dataTables.bootstrap5.min.css" rel="stylesheet">
    <link href="https://cdn.datatables.net/buttons/2.4.2/css/buttons.bootstrap5.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css" rel="stylesheet">
    <style>
        :root {
            --bg-color: #f5f7fa;
            --text-color: #000;
            --card-bg: #fff;
            --table-bg: #fff;
            --hover-bg: #f8f9fa;
            --border-color: #dee2e6;
        }

        [data-theme="dark"] {
            --bg-color: #1a1a1a;
            --text-color: #fff;
            --card-bg: #2d2d2d;
            --table-bg: #2d2d2d;
            --hover-bg: #3d3d3d;
            --border-color: #404040;
        }

        body {
            padding: 20px;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: var(--bg-color);
            color: var(--text-color);
            transition: background-color 0.3s ease, color 0.3s ease;
        }
        .card {
            margin-bottom: 20px;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
            border-radius: 10px;
            background-color: var(--card-bg);
            transition: transform 0.2s, background-color 0.3s ease;
            border-color: var(--border-color);
        }
        .card:hover {
            transform: translateY(-2px);
        }
        .badge-all-computers {
            background-color: #28a745;
            color: white;
            padding: 5px 10px;
            border-radius: 15px;
        }
        .badge-computer-group {
            background-color: #17a2b8;
            color: white;
            padding: 5px 10px;
            border-radius: 15px;
        }
        .badge-computer {
            background-color: #6f42c1;
            color: white;
            padding: 5px 10px;
            border-radius: 15px;
        }
        .badge-user-group {
            background-color: #ffc107;
            color: black;
            padding: 5px 10px;
            border-radius: 15px;
        }
        .badge-user {
            background-color: #fd7e14;
            color: white;
            padding: 5px 10px;
            border-radius: 15px;
        }
        .badge-none {
            background-color: #dc3545;
            color: white;
            padding: 5px 10px;
            border-radius: 15px;
        }
        .badge-exclude {
            background-color: #6c757d;
            color: white;
            padding: 5px 10px;
            border-radius: 15px;
        }
        .badge-mobile-device-group {
            background-color: #e83e8c;
            color: white;
            padding: 5px 10px;
            border-radius: 15px;
        }
        .badge-building {
            background-color: #795548;
            color: white;
            padding: 5px 10px;
            border-radius: 15px;
        }
        .summary-card {
            background-color: #f8f9fa;
            border: none;
        }
        .table-container {
            margin-top: 20px;
            background: var(--table-bg);
            padding: 20px;
            border-radius: 10px;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
            transition: background-color 0.3s ease;
        }

        .table {
            color: var(--text-color) !important;
        }

        .table thead th {
            color: var(--text-color) !important;
        }

        .table tbody tr:hover {
            background-color: var(--hover-bg) !important;
        }

        .dataTables_info, .dataTables_length, .dataTables_filter label {
            color: var(--text-color) !important;
        }
        .nav-tabs {
            margin-bottom: 20px;
            border-bottom: 2px solid var(--border-color);
        }
        .nav-tabs .nav-link {
            border: none;
            color: #6c757d;
            padding: 10px 20px;
            margin-right: 5px;
            border-radius: 5px 5px 0 0;
        }
        .nav-tabs .nav-link.active {
            color: #0d6efd;
            border-bottom: 2px solid #0d6efd;
            font-weight: 500;
        }
        .tab-content {
            padding: 20px;
            border: 1px solid var(--border-color);
            border-top: none;
            border-radius: 0 0 10px 10px;
            background-color: var(--card-bg);
        }
        .chart-container {
            margin: 10px 0;
            padding: 15px;
            background: var(--card-bg);
            border-radius: 10px;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
            height: 300px;
            display: flex;
            justify-content: center;
            align-items: center;
        }
        .search-box {
            margin: 20px 0;
            padding: 20px;
            background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
            border-radius: 10px;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
        }
        .policy-table {
            width: 100% !important;
        }
        .policy-table thead th {
            background-color: #f8f9fa;
            font-weight: 600;
        }
        .report-header {
            background: linear-gradient(135deg, #ff6b35 0%, #f7931e 100%);
            color: white;
            padding: 30px;
            border-radius: 10px;
            margin-bottom: 30px;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
            animation: fadeIn 0.5s ease-in-out;
            position: relative;
        }

        .theme-toggle {
            position: absolute;
            top: 20px;
            right: 20px;
            background: none;
            border: none;
            color: white;
            font-size: 1.5rem;
            cursor: pointer;
            transition: transform 0.3s ease;
        }

        .theme-toggle:hover {
            transform: scale(1.1);
        }

        @media print {
            body {
                background-color: white !important;
                color: black !important;
            }
            .card, .table-container, .tab-content {
                background-color: white !important;
                color: black !important;
                box-shadow: none !important;
            }
            .theme-toggle, .buttons-collection {
                display: none !important;
            }
            .table {
                color: black !important;
            }
            .table thead th {
                color: black !important;
                background-color: #f8f9fa !important;
            }
        }
        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(-20px); }
            to { opacity: 1; transform: translateY(0); }
        }
        .search-box input {
            border: 2px solid #dee2e6;
            transition: border-color 0.3s ease;
        }
        .search-box input:focus {
            border-color: #ff6b35;
            box-shadow: 0 0 0 0.2rem rgba(255, 107, 53, 0.25);
        }
        .report-header h1 {
            margin: 0;
            font-weight: 300;
        }
        .report-header p {
            margin: 10px 0 0 0;
            opacity: 0.9;
        }
        .summary-stat {
            text-align: center;
            padding: 20px;
        }
        .summary-stat h3 {
            font-size: 2rem;
            font-weight: 300;
            margin: 10px 0;
            color: #ff6b35;
        }
        .summary-stat p {
            color: #6c757d;
            margin: 0;
        }
        #assignmentTypeFilter {
            border: 2px solid #dee2e6;
            border-radius: 5px;
            padding: 8px;
            transition: all 0.3s ease;
            background-color: var(--card-bg);
            color: var(--text-color);
        }
        #assignmentTypeFilter:focus {
            border-color: #ff6b35;
            box-shadow: 0 0 0 0.2rem rgba(255, 107, 53, 0.25);
            outline: none;
        }
        .form-label {
            color: var(--text-color);
            margin-bottom: 0.5rem;
            font-weight: 500;
        }
    </style>
</head>
<body>
    <div class="container-fluid">
        <div class="report-header">
            <h1>JAMF Assignment Report</h1>
            <p>Generated on $(Get-Date -Format "MMMM dd, yyyy HH:mm")</p>
        </div>

        <div class="row mb-4">
            <div class="col-md-12">
                <div class="card summary-card">
                    <div class="card-body">
                        <h5 class="card-title">Summary</h5>
                        <div class="row" id="summary-stats">
                            <!-- Summary stats will be inserted here -->
                        </div>
                    </div>
                </div>
                <!-- Policy overview chart placeholder -->
            </div>
        </div>

        <div class="search-box">
            <div class="row align-items-end">
                <div class="col-md-6">
                    <div class="form-group">
                        <label for="groupSearch">Search by Group Name:</label>
                        <input type="text" class="form-control" id="groupSearch" placeholder="Enter group name...">
                    </div>
                </div>
                <div class="col-md-6">
                    <div class="form-group">
                        <label for="assignmentTypeFilter" class="form-label">Filter by Assignment Type:</label>
                        <select class="form-select" id="assignmentTypeFilter">
                            <option value="all">All Types</option>
                            <option value="All Computers">All Computers</option>
                            <option value="Computer Group">Computer Group</option>
                            <option value="Computer">Computer</option>
                            <option value="Mobile Device Group">Mobile Device Group</option>
                            <option value="User Group">User Group</option>
                            <option value="User">User</option>
                            <option value="Building">Building</option>
                            <option value="None">None</option>
                        </select>
                    </div>
                </div>
            </div>
        </div>

        <ul class="nav nav-tabs" id="assignmentTabs" role="tablist">
            <!-- Tab headers will be inserted here -->
        </ul>

        <div class="tab-content" id="assignmentTabContent">
            <!-- Tab content will be inserted here -->
        </div>
    </div>

    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://cdn.datatables.net/1.11.5/js/jquery.dataTables.min.js"></script>
    <script src="https://cdn.datatables.net/1.11.5/js/dataTables.bootstrap5.min.js"></script>
    <script src="https://cdn.datatables.net/buttons/2.2.2/js/dataTables.buttons.min.js"></script>
    <script src="https://cdn.datatables.net/buttons/2.2.2/js/buttons.bootstrap5.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jszip/3.1.3/jszip.min.js"></script>
    <script src="https://cdn.datatables.net/buttons/2.2.2/js/buttons.html5.min.js"></script>
    <script>
        jQuery(document).ready(function() {
            // Initialize DataTables
            var tables = jQuery('.policy-table').DataTable({
                dom: 'Blfrtip',
                buttons: [
                    'copyHtml5',
                    'excelHtml5',
                    'csvHtml5'
                ],
                pageLength: 10,
                lengthMenu: [[10, 25, 50, -1], [10, 25, 50, "All"]],
                ordering: false,
                columnDefs: [
                    {
                        targets: '_all',
                        orderable: false
                    }
                ]
            });

            // Assignment Type Filter
            jQuery('#assignmentTypeFilter').on('change', function() {
                const filterValue = jQuery(this).val();
                jQuery('.policy-table').each(function() {
                    const dataTable = jQuery(this).DataTable();
                    if (filterValue === 'all') {
                        dataTable.search('').columns().search('').draw();
                    } else {
                        // Find the column index for "Assignment Type"
                        let assignmentTypeColumn = -1;
                        jQuery(this).find('thead th').each(function(index) {
                            if (jQuery(this).text().trim() === 'Assignment Type') {
                                assignmentTypeColumn = index;
                                return false; // break the loop
                            }
                        });
                        
                        if (assignmentTypeColumn >= 0) {
                            // Use exact match for badge text content
                            dataTable.column(assignmentTypeColumn).search('^' + filterValue + '$', true, false).draw();
                        }
                    }
                });
            });

            jQuery('#groupSearch').on('keyup', function() {
                const searchTerm = this.value.toLowerCase();
                jQuery('.policy-table').each(function() {
                    jQuery(this).DataTable().search(searchTerm).draw();
                });
            });

            // Show the first tab by default
            const firstTab = document.querySelector('.nav-tabs .nav-link');
            const firstPane = document.querySelector('.tab-pane');
            if (firstTab) firstTab.classList.add('active');
            if (firstPane) firstPane.classList.add('show', 'active');
        });
    </script>
</body>
</html>
"@

    # Initialize collections for JAMF resources
    $jamfResources = @{
        Policies                          = @()
        ConfigurationProfiles             = @()
        MobileDeviceConfigurationProfiles = @()
        ComputerGroups                    = @()
        MobileDeviceGroups                = @()
        UnassignedPolicies                = @()
        UnassignedProfiles                = @()
    }

    # Fetch all JAMF policies
    Write-Host "Fetching JAMF Policies..." -ForegroundColor Yellow
    $policies = Get-JamfPolicies
    foreach ($policy in $policies) {
        Write-Host "Processing policy: $($policy.name)" -ForegroundColor Gray
        $policyDetails = Get-JamfPolicyDetails -PolicyId $policy.id
        if ($policyDetails) {
            $assignmentInfo = Get-JamfAssignmentInfo -PolicyOrProfile $policyDetails
            $jamfResources.Policies += @{
                Name           = $policy.name
                ID             = $policy.id
                Type           = "Policy"
                AssignmentType = $assignmentInfo.Type
                AssignedTo     = $assignmentInfo.Target
                Exclusions     = $assignmentInfo.Exclusions
                Enabled        = $policyDetails.general.enabled
            }
        }
    }

    # Fetch all Configuration Profiles
    Write-Host "Fetching Configuration Profiles..." -ForegroundColor Yellow
    $configProfiles = Get-JamfConfigurationProfiles
    foreach ($profile in $configProfiles) {
        Write-Host "Processing profile: $($profile.name)" -ForegroundColor Gray
        $profileDetails = Get-JamfConfigurationProfileDetails -ProfileId $profile.id
        if ($profileDetails) {
            $assignmentInfo = Get-JamfAssignmentInfo -PolicyOrProfile $profileDetails
            $jamfResources.ConfigurationProfiles += @{
                Name           = $profile.name
                ID             = $profile.id
                Type           = "Configuration Profile"
                AssignmentType = $assignmentInfo.Type
                AssignedTo     = $assignmentInfo.Target
                Exclusions     = $assignmentInfo.Exclusions
            }
        }
    }

    # Fetch Mobile Device Configuration Profiles
    Write-Host "Fetching Mobile Device Configuration Profiles..." -ForegroundColor Yellow
    $mobileProfiles = Get-JamfMobileDeviceConfigurationProfiles
    foreach ($profile in $mobileProfiles) {
        Write-Host "Processing mobile profile: $($profile.name)" -ForegroundColor Gray
        $profileDetails = Get-JamfMobileDeviceConfigurationProfileDetails -ProfileId $profile.id
        if ($profileDetails) {
            $assignmentInfo = Get-JamfAssignmentInfo -PolicyOrProfile $profileDetails
            $jamfResources.MobileDeviceConfigurationProfiles += @{
                Name           = $profile.name
                ID             = $profile.id
                Type           = "Mobile Device Configuration Profile"
                AssignmentType = $assignmentInfo.Type
                AssignedTo     = $assignmentInfo.Target
                Exclusions     = $assignmentInfo.Exclusions
            }
        }
    }

    # Find unassigned resources
    Write-Host "Finding unassigned policies..." -ForegroundColor Yellow
    $jamfResources.UnassignedPolicies = Find-UnassignedPoliciesFromProcessedData -Policies $jamfResources.Policies

    Write-Host "Finding unassigned profiles..." -ForegroundColor Yellow
    $jamfResources.UnassignedProfiles = Find-UnassignedProfilesFromProcessedData -Profiles $jamfResources.ConfigurationProfiles

    # Generate summary statistics
    $summaryStats = @{
        TotalPolicies = $jamfResources.Policies.Count
        TotalProfiles = $jamfResources.ConfigurationProfiles.Count + $jamfResources.MobileDeviceConfigurationProfiles.Count
        AllComputers  = ($jamfResources.Policies + $jamfResources.ConfigurationProfiles + $jamfResources.MobileDeviceConfigurationProfiles | Where-Object { $_.AssignmentType -eq "All Computers" }).Count
        ComputerGroup = ($jamfResources.Policies + $jamfResources.ConfigurationProfiles + $jamfResources.MobileDeviceConfigurationProfiles | Where-Object { $_.AssignmentType -eq "Computer Group" }).Count
        UserGroup     = ($jamfResources.Policies + $jamfResources.ConfigurationProfiles + $jamfResources.MobileDeviceConfigurationProfiles | Where-Object { $_.AssignmentType -eq "User Group" }).Count
        Computer      = ($jamfResources.Policies + $jamfResources.ConfigurationProfiles + $jamfResources.MobileDeviceConfigurationProfiles | Where-Object { $_.AssignmentType -eq "Computer" }).Count
        User          = ($jamfResources.Policies + $jamfResources.ConfigurationProfiles + $jamfResources.MobileDeviceConfigurationProfiles | Where-Object { $_.AssignmentType -eq "User" }).Count
        Unassigned    = ($jamfResources.Policies + $jamfResources.ConfigurationProfiles + $jamfResources.MobileDeviceConfigurationProfiles | Where-Object { $_.AssignmentType -eq "None" }).Count
    }

    $categories = @(
        @{ Key = 'all'; Name = 'All Policies & Profiles' },
        @{ Key = 'Policies'; Name = 'Policies' },
        @{ Key = 'ConfigurationProfiles'; Name = 'Configuration Profiles' },
        @{ Key = 'MobileDeviceConfigurationProfiles'; Name = 'Mobile Device Configuration Profiles' },
        @{ Key = 'UnassignedPolicies'; Name = 'Unassigned Policies' },
        @{ Key = 'UnassignedProfiles'; Name = 'Unassigned Profiles' }
    )

    # Build dynamic tab headers and tab content
    $tabHeaders = ""
    $tabContent = ""

    foreach ($category in $categories) {
        $isActive = ($category -eq $categories[0])
        $categoryId = $category.Key.ToLower()

        $tabHeaders += @"
<li class='nav-item' role='presentation'>
    <button class='nav-link$(if($isActive -and $category.Key -ne 'all'){ ' active' } else { '' })'
            id='$categoryId-tab'
            data-bs-toggle='tab'
            data-bs-target='#$categoryId'
            type='button'
            role='tab'
            aria-controls='$categoryId'
            aria-selected='$(if($isActive -and $category.Key -ne 'all'){ 'true' } else { 'false' })'>
        $($category.Name)
    </button>
</li>
"@

        if ($category.Key -eq 'all') {
            $allTableRows = foreach ($cat in $categories | Where-Object { $_.Key -ne 'all' -and $_.Key -notlike 'Unassigned*' }) {
                if ($jamfResources.ContainsKey($cat.Key)) {
                    $categoryResources = $jamfResources[$cat.Key]
                    if ($categoryResources) {
                        foreach ($resource in $categoryResources) {
                            $badgeClass = switch ($resource.AssignmentType) {
                                'All Computers' { 'badge-all-computers' }
                                'Computer Group' { 'badge-computer-group' }
                                'Computer' { 'badge-computer' }
                                'Mobile Device Group' { 'badge-mobile-device-group' }
                                'User Group' { 'badge-user-group' }
                                'User' { 'badge-user' }
                                'Building' { 'badge-building' }
                                'Exclude' { 'badge-exclude' }
                                default { 'badge-none' }
                            }
                            "<tr>
                                <td>$($resource.Name)</td>
                                <td>$($resource.Type)</td>
                                <td><span class='badge $badgeClass'>$($resource.AssignmentType)</span></td>
                                <td>$($resource.AssignedTo)</td>
                                <td>$($resource.Exclusions)</td>
                            </tr>"
                        }
                    }
                }
            }
            $tabContent += @"
<div class='tab-pane fade$(if($isActive){ ' show active' } else { '' })'
     id='$categoryId'
     role='tabpanel'
     aria-labelledby='$categoryId-tab'>
    <div class='table-container'>
        <table class='table table-striped policy-table'>
            <thead>
                <tr>
                    <th>Name</th>
                    <th>Type</th>
                    <th>Assignment Type</th>
                    <th>Assigned To</th>
                    <th>Exclusions</th>
                </tr>
            </thead>
            <tbody>
                $($allTableRows -join "`n")
            </tbody>
        </table>
    </div>
</div>
"@
        } else {
            $tableRows = ""
            if ($jamfResources.ContainsKey($category.Key)) {
                $currentCategoryResources = $jamfResources[$category.Key]
                if ($currentCategoryResources) {
                    $tableRows = foreach ($resource in $currentCategoryResources) {
                        $badgeClass = switch ($resource.AssignmentType) {
                            'All Computers' { 'badge-all-computers' }
                            'Computer Group' { 'badge-computer-group' }
                            'Computer' { 'badge-computer' }
                            'Mobile Device Group' { 'badge-mobile-device-group' }
                            'User Group' { 'badge-user-group' }
                            'User' { 'badge-user' }
                            'Building' { 'badge-building' }
                            'Exclude' { 'badge-exclude' }
                            default { 'badge-none' }
                        }
                        
                        # Add enabled column for policies
                        if ($resource.Type -eq "Policy") {
                            "<tr>
                                <td>$($resource.Name)</td>
                                <td><span class='badge $badgeClass'>$($resource.AssignmentType)</span></td>
                                <td>$($resource.AssignedTo)</td>
                                <td>$($resource.Exclusions)</td>
                                <td>$(if($resource.Enabled -eq 'true') { '<span class="badge bg-success">Enabled</span>' } else { '<span class="badge bg-secondary">Disabled</span>' })</td>
                            </tr>"
                        } else {
                            "<tr>
                                <td>$($resource.Name)</td>
                                <td><span class='badge $badgeClass'>$($resource.AssignmentType)</span></td>
                                <td>$($resource.AssignedTo)</td>
                                <td>$($resource.Exclusions)</td>
                            </tr>"
                        }
                    }
                }
            }
            
            # Determine table headers based on category
            $tableHeaders = if ($category.Key -eq 'Policies') {
                "<tr>
                    <th>Name</th>
                    <th>Assignment Type</th>
                    <th>Assigned To</th>
                    <th>Exclusions</th>
                    <th>Status</th>
                </tr>"
            } else {
                "<tr>
                    <th>Name</th>
                    <th>Assignment Type</th>
                    <th>Assigned To</th>
                    <th>Exclusions</th>
                </tr>"
            }
            
            $tabContent += @"
<div class='tab-pane fade$(if($isActive -and $category.Key -ne 'all'){ ' show active' } else { '' })'
     id='$categoryId'
     role='tabpanel'
     aria-labelledby='$categoryId-tab'>
    <div class='table-container'>
        <table class='table table-striped policy-table'>
            <thead>
                $tableHeaders
            </thead>
            <tbody>
                $($tableRows -join "`n")
            </tbody>
        </table>
    </div>
</div>
"@
        }
    }

    # Summary cards
    $summaryCards = @"
<div class='col'>
    <div class='card text-center summary-card'>
        <div class='card-body'>
            <i class='fas fa-shield-alt mb-3' style='font-size:2rem;color:#ff6b35;'></i>
            <h5 class='card-title'>Total Policies</h5>
            <h3 class='card-text'>$($summaryStats.TotalPolicies)</h3>
            <p class='text-muted small'>JAMF Pro policies</p>
        </div>
    </div>
</div>
<div class='col'>
    <div class='card text-center summary-card'>
        <div class='card-body'>
            <i class='fas fa-cogs mb-3' style='font-size:2rem;color:#28a745;'></i>
            <h5 class='card-title'>Total Profiles</h5>
            <h3 class='card-text'>$($summaryStats.TotalProfiles)</h3>
            <p class='text-muted small'>Configuration profiles</p>
        </div>
    </div>
</div>
<div class='col'>
    <div class='card text-center summary-card'>
        <div class='card-body'>
            <i class='fas fa-desktop mb-3' style='font-size:2rem;color:#17a2b8;'></i>
            <h5 class='card-title'>All Computers</h5>
            <h3 class='card-text'>$($summaryStats.AllComputers)</h3>
            <p class='text-muted small'>Assigned to all computers</p>
        </div>
    </div>
</div>
<div class='col'>
    <div class='card text-center summary-card'>
        <div class='card-body'>
            <i class='fas fa-object-group mb-3' style='font-size:2rem;color:#ffc107;'></i>
            <h5 class='card-title'>Group Assigned</h5>
            <h3 class='card-text'>$($summaryStats.ComputerGroup + $summaryStats.UserGroup)</h3>
            <p class='text-muted small'>Assigned to groups</p>
        </div>
    </div>
</div>
<div class='col'>
    <div class='card text-center summary-card'>
        <div class='card-body'>
            <i class='fas fa-exclamation-triangle mb-3' style='font-size:2rem;color:#dc3545;'></i>
            <h5 class='card-title'>Unassigned</h5>
            <h3 class='card-text'>$($summaryStats.Unassigned)</h3>
            <p class='text-muted small'>Not assigned to any target</p>
        </div>
    </div>
</div>
"@

    # Insert chart container + Chart.js script
    $chartBlock = @"
<div class='row'>
    <div class='col-md-6'>
        <div class='chart-container'>
            <canvas id='policyDistributionChart'></canvas>
        </div>
    </div>
    <div class='col-md-6'>
        <div class='chart-container'>
            <canvas id='policyTypesChart'></canvas>
        </div>
    </div>
</div>
<script src='https://cdn.jsdelivr.net/npm/chart.js'></script>
<script>
    // Policy Distribution Pie Chart
    var ctx1 = document.getElementById('policyDistributionChart').getContext('2d');
    var policyDistributionChart = new Chart(ctx1, {
        type: 'pie',
        data: {
            labels: ['All Computers', 'Computer Groups', 'User Groups', 'Direct Assignments', 'Unassigned'],
            datasets: [{
                data: [$($summaryStats.AllComputers), $($summaryStats.ComputerGroup), $($summaryStats.UserGroup), $($summaryStats.Computer + $summaryStats.User), $($summaryStats.Unassigned)],
                backgroundColor: ['#28a745', '#17a2b8', '#ffc107', '#6f42c1', '#dc3545'],
                hoverOffset: 4
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: true,
            plugins: {
                legend: {
                    position: 'bottom',
                    labels: { font: { size: 10 } }
                },
                title: {
                    display: true,
                    text: 'JAMF Assignment Distribution',
                    font: { size: 14 }
                }
            }
        }
    });

    // Policy Types Bar Chart
    var ctx2 = document.getElementById('policyTypesChart').getContext('2d');
    var policyTypesChart = new Chart(ctx2, {
        type: 'bar',
        data: {
            labels: ['Policies', 'Configuration Profiles', 'Mobile Device Profiles'],
            datasets: [{
                label: 'Number of Resources',
                data: [
                    $($jamfResources.Policies.Count),
                    $($jamfResources.ConfigurationProfiles.Count),
                    $($jamfResources.MobileDeviceConfigurationProfiles.Count)
                ],
                backgroundColor: [
                    '#ff6b35', '#28a745', '#17a2b8'
                ]
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: true,
            plugins: {
                legend: {
                    display: false
                },
                title: {
                    display: true,
                    text: 'JAMF Resource Types Distribution',
                    font: { size: 14 }
                }
            },
            scales: {
                y: {
                    beginAtZero: true,
                    ticks: { font: { size: 10 } }
                },
                x: {
                    ticks: { font: { size: 10 } }
                }
            }
        }
    });
</script>
"@

    # Final HTML
    $htmlContent = $htmlTemplate `
        -replace '<!-- Tab headers will be inserted here -->', $tabHeaders `
        -replace '<!-- Tab content will be inserted here -->', $tabContent `
        -replace '<!-- Summary stats will be inserted here -->', $summaryCards `
        -replace '<!-- Policy overview chart placeholder -->', $chartBlock

    # Output file
    $htmlContent | Out-File -FilePath $FilePath -Encoding UTF8
    Write-Host "JAMF HTML report exported to: $FilePath" -ForegroundColor Green
}

# Example usage:
# Export-JamfHTMLReport -FilePath "$(get-location)\JAMF-Assignment-Report.html"