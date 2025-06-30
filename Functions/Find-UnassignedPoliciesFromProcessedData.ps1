function Find-UnassignedPoliciesFromProcessedData {
    <#
    .SYNOPSIS
        Finds unassigned policies from raw policy data (for HTML report efficiency).
    #>
    param (
        [Parameter(Mandatory = $true)]
        [array]$Policies
    )
    
    $unassignedPolicies = @()
    
    foreach ($policy in $Policies) {
        $policyDetails = Get-JamfPolicyDetails -PolicyId $policy.id
        
        if ($policyDetails) {
            $hasAssignments = $false
            
            # Check for any assignments
            if ($policyDetails.scope.all_computers -eq "true" -or
                $policyDetails.scope.computers.computer -or
                $policyDetails.scope.computer_groups.computer_group) {
                $hasAssignments = $true
            }
            
            if (-not $hasAssignments) {
                $unassignedPolicies += @{
                    Id      = $policy.id
                    Name    = $policy.name
                    Enabled = $policy.enabled -eq "true"
                }
            }
        }
    }
    
    return $unassignedPolicies
}
