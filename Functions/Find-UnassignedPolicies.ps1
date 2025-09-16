function Find-UnassignedPolicies {
    <#
    .SYNOPSIS
        Finds policies without any assignments.
    #>
    
    Write-Host "`nSearching for unassigned policies..." -ForegroundColor Cyan
    
    $policies = Get-JamfPolicies
    $unassignedPolicies = @()
    
    foreach ($policy in $policies) {
        $policyDetails = Get-JamfPolicyDetails -PolicyId $policy.id
        
        if ($policyDetails) {
            $hasAssignments = $false
            
            # Check for any assignments
            if ($policyDetails.scope.all_computers -eq "true" -or
                $policyDetails.scope.computers.computer -or
                $policyDetails.scope.computer_groups.computer_group -or
                $policyDetails.scope.users.user -or
                $policyDetails.scope.user_groups.user_group) {
                $hasAssignments = $true
            }
            
            if (-not $hasAssignments) {
                $unassignedPolicies += @{
                    Id      = $policyDetails.general.id
                    Name    = $policyDetails.general.name
                    Enabled = $policyDetails.general.enabled -eq "true"
                }
            }
        }
    }
    
    # Display results
    Write-Host "`n===== POLICIES WITHOUT ASSIGNMENTS =====" -ForegroundColor Yellow
    Write-Host "Found $($unassignedPolicies.Count) unassigned policies" -ForegroundColor Cyan
    Write-Host ""
    
    if ($unassignedPolicies.Count -eq 0) {
        Write-Host "All policies have at least one assignment!" -ForegroundColor Green
    } else {
        foreach ($policy in $unassignedPolicies | Sort-Object Name) {
            $statusColor = if ($policy.Enabled) { "Yellow" } else { "DarkGray" }
            $statusText = if ($policy.Enabled) { "ENABLED" } else { "DISABLED" }
            
            Write-Host "- $($policy.Name)" -ForegroundColor White
            Write-Host "  ID: $($policy.Id) | Status: " -ForegroundColor Gray -NoNewline
            Write-Host $statusText -ForegroundColor $statusColor
        }
    }
    
    Write-Host ""
    return $unassignedPolicies
}
