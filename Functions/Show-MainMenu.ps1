function Show-MainMenu {
    <#
    .SYNOPSIS
        Displays the main menu for interactive mode.
    #>
    
    Write-Host ""
    Write-Host "Assignment Checks:" -ForegroundColor Cyan
    Write-Host "  [1] Check assignments for specific computer(s)" -ForegroundColor White
    Write-Host "  [2] Check assignments for specific user(s)" -ForegroundColor White
    Write-Host "  [3] Check assignments for specific group(s)" -ForegroundColor White
    Write-Host "  [4] Check assignments for specific mobile device(s)" -ForegroundColor White
    Write-Host ""
    Write-Host "Bulk Assignment Analysis:" -ForegroundColor Cyan
    Write-Host "  [5] Show assignments for ALL computers" -ForegroundColor Yellow
    Write-Host "  [6] Show assignments for ALL users" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Policy and Profile Overview:" -ForegroundColor Cyan
    Write-Host "  [7] Show all policies and their assignments" -ForegroundColor White
    Write-Host "  [8] Show all configuration profiles and their assignments" -ForegroundColor White
    Write-Host ""
    Write-Host "Advanced Options:" -ForegroundColor Cyan
    Write-Host "  [9] Find policies without assignments" -ForegroundColor White
    Write-Host "  [10] Find configuration profiles without assignments" -ForegroundColor White
    Write-Host "  [11] Find empty groups in assignments" -ForegroundColor White
    Write-Host "  [12] Generate comprehensive HTML report" -ForegroundColor White
    Write-Host ""
    Write-Host "System:" -ForegroundColor Cyan
    Write-Host "  [0] Exit" -ForegroundColor White
    Write-Host ""
    
    return Read-Host "Select an option"
}
