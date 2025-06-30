function Show-AllPolicies {
    <#
    .SYNOPSIS
        Displays all policies with their assignments.
    #>
    param (
        [Parameter(Mandatory = $false)]
        [switch]$IncludeDisabled
    )
    
    Write-Host "`nFetching all policies and their assignments..." -ForegroundColor Cyan
    
    $policies = Get-JamfPolicies
    $allPolicyData = @()
    $processedCount = 0
    
    foreach ($policy in $policies) {
        $processedCount++
        Write-Progress -Activity "Processing policies" -Status "$processedCount of $($policies.Count)" -PercentComplete (($processedCount / $policies.Count) * 100)
        
        $policyDetails = Get-JamfPolicyDetails -PolicyId $policy.id
        
        if ($policyDetails) {
            # Skip disabled policies if not requested
            if ($policyDetails.general.enabled -ne "true" -and -not $IncludeDisabled) {
                continue
            }
            
            $policyData = @{
                Id      = $policyDetails.general.id
                Name    = $policyDetails.general.name
                Enabled = $policyDetails.general.enabled -eq "true"
                Scope   = @{
                    AllComputers   = $policyDetails.scope.all_computers -eq "true"
                    Computers      = @()
                    ComputerGroups = @()
                    Users          = @()
                    UserGroups     = @()
                    Exclusions     = @{
                        Computers      = @()
                        ComputerGroups = @()
                        Users          = @()
                        UserGroups     = @()
                    }
                }
            }
            
            # Process direct computer assignments
            if ($policyDetails.scope.computers.computer) {
                $computers = @($policyDetails.scope.computers.computer)
                foreach ($comp in $computers) {
                    $policyData.Scope.Computers += @{
                        Id   = $comp.id
                        Name = $comp.name
                    }
                }
            }
            
            # Process computer group assignments
            if ($policyDetails.scope.computer_groups.computer_group) {
                $groups = @($policyDetails.scope.computer_groups.computer_group)
                foreach ($group in $groups) {
                    $policyData.Scope.ComputerGroups += @{
                        Id   = $group.id
                        Name = $group.name
                    }
                }
            }
            
            # Process exclusions
            if ($policyDetails.scope.exclusions.computers.computer) {
                $exclComputers = @($policyDetails.scope.exclusions.computers.computer)
                foreach ($comp in $exclComputers) {
                    $policyData.Scope.Exclusions.Computers += @{
                        Id   = $comp.id
                        Name = $comp.name
                    }
                }
            }
            
            if ($policyDetails.scope.exclusions.computer_groups.computer_group) {
                $exclGroups = @($policyDetails.scope.exclusions.computer_groups.computer_group)
                foreach ($group in $exclGroups) {
                    $policyData.Scope.Exclusions.ComputerGroups += @{
                        Id   = $group.id
                        Name = $group.name
                    }
                }
            }
            
            $allPolicyData += $policyData
        }
    }
    
    Write-Progress -Activity "Processing policies" -Completed
    
    # Display results
    Write-Host "`n===== ALL POLICIES AND ASSIGNMENTS =====" -ForegroundColor Yellow
    Write-Host "Total Policies: $($allPolicyData.Count)" -ForegroundColor Cyan
    
    $enabledCount = ($allPolicyData | Where-Object { $_.Enabled }).Count
    $disabledCount = ($allPolicyData | Where-Object { -not $_.Enabled }).Count
    
    Write-Host "Enabled: $enabledCount | Disabled: $disabledCount" -ForegroundColor Gray
    Write-Host ""
    
    foreach ($policy in $allPolicyData | Sort-Object Name) {
        $statusColor = if ($policy.Enabled) { "Green" } else { "DarkGray" }
        $statusText = if ($policy.Enabled) { "ENABLED" } else { "DISABLED" }
        
        Write-Host "$($policy.Name)" -ForegroundColor White
        Write-Host "  ID: $($policy.Id) | Status: " -ForegroundColor Gray -NoNewline
        Write-Host $statusText -ForegroundColor $statusColor
        
        # Display scope
        if ($policy.Scope.AllComputers) {
            Write-Host "  Scope: ALL COMPUTERS" -ForegroundColor Cyan
        } else {
            if ($policy.Scope.Computers.Count -gt 0) {
                Write-Host "  Direct Computers ($($policy.Scope.Computers.Count)):" -ForegroundColor Cyan
                foreach ($comp in $policy.Scope.Computers) {
                    Write-Host "    - $($comp.Name) (ID: $($comp.Id))" -ForegroundColor Gray
                }
            }
            
            if ($policy.Scope.ComputerGroups.Count -gt 0) {
                Write-Host "  Computer Groups ($($policy.Scope.ComputerGroups.Count)):" -ForegroundColor Cyan
                foreach ($group in $policy.Scope.ComputerGroups) {
                    Write-Host "    - $($group.Name) (ID: $($group.Id))" -ForegroundColor Gray
                }
            }
        }
        
        # Display exclusions
        $hasExclusions = $policy.Scope.Exclusions.Computers.Count -gt 0 -or $policy.Scope.Exclusions.ComputerGroups.Count -gt 0
        
        if ($hasExclusions) {
            Write-Host "  Exclusions:" -ForegroundColor Red
            
            if ($policy.Scope.Exclusions.Computers.Count -gt 0) {
                Write-Host "    Computers:" -ForegroundColor Red
                foreach ($comp in $policy.Scope.Exclusions.Computers) {
                    Write-Host "      - $($comp.Name) (ID: $($comp.Id))" -ForegroundColor DarkGray
                }
            }
            
            if ($policy.Scope.Exclusions.ComputerGroups.Count -gt 0) {
                Write-Host "    Computer Groups:" -ForegroundColor Red
                foreach ($group in $policy.Scope.Exclusions.ComputerGroups) {
                    Write-Host "      - $($group.Name) (ID: $($group.Id))" -ForegroundColor DarkGray
                }
            }
        }
        
        # Show if no assignments
        if (-not $policy.Scope.AllComputers -and 
            $policy.Scope.Computers.Count -eq 0 -and 
            $policy.Scope.ComputerGroups.Count -eq 0) {
            Write-Host "  ⚠️  NO ASSIGNMENTS" -ForegroundColor Yellow
        }
        
        Write-Host ""
    }
    
    return $allPolicyData
}
