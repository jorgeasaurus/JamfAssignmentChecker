function Connect-JamfPro {
    <#
    .SYNOPSIS
        Establishes connection to JAMF Pro using provided credentials or config.ps1.
    
    .DESCRIPTION
        Authenticates to JAMF Pro using either username/password or OAuth client credentials.
        Prioritizes config.ps1 settings, then command-line parameters, then interactive prompts.
        Stores the authentication token for subsequent API calls.
    #>
    param (
        [string]$configFile = "$(Get-Location)\config.ps1",
        [string]$BaseUrl = $BaseUrl,
        [string]$Username = $Username,
        [string]$Password = $Password,
        [string]$ClientId = $ClientId,
        [string]$ClientSecret = $ClientSecret
    )
    
    # Try to load from config file first
    $script:Config = $null
    
    if (Test-Path $configFile) {
        Write-Host "📁 Loading configuration from config.ps1..." -ForegroundColor Cyan
        try {
            . $configFile
            Write-Host "✅ Configuration loaded successfully!" -ForegroundColor Green
        } catch {
            Write-Host "⚠️  Warning: Failed to load config.ps1: $_" -ForegroundColor Yellow
        }
    }
    
    # Set BaseUrl (Priority: Parameter > Config > Interactive)
    if ([string]::IsNullOrWhiteSpace($BaseUrl) -and $script:Config -and $script:Config.BaseUrl) {
        $BaseUrl = $script:Config.BaseUrl
    }
    
    if ([string]::IsNullOrWhiteSpace($BaseUrl)) {
        $BaseUrl = Read-Host "Enter JAMF Pro server URL (e.g., company.jamfcloud.com)"
    }
    
    # Ensure proper URL format
    if ($BaseUrl -notlike "https://*") {
        $script:Config.BaseUrl = "https://$BaseUrl"
    } else {
        $script:Config.BaseUrl = $BaseUrl
    }
    
    # Determine authentication method and credentials
    $useOAuth = $false
    $useBasicAuth = $false
    
    # Check for OAuth credentials (Priority: Parameters > Config > Interactive)
    if ($ClientId -and $ClientSecret) {
        $useOAuth = $true
    } elseif ($script:Config -and 
        $script:Config.ContainsKey('ClientId') -and $script:Config.ContainsKey('ClientSecret') -and
        -not [string]::IsNullOrWhiteSpace($script:Config.ClientId) -and 
        -not [string]::IsNullOrWhiteSpace($script:Config.ClientSecret)) {
        $ClientId = $script:Config.ClientId
        $ClientSecret = $script:Config.ClientSecret
        $useOAuth = $true
    }
    
    # Check for Basic Auth credentials (Priority: Parameters > Config > Interactive)
    if (-not $useOAuth) {
        if ($Username -and $Password) {
            $useBasicAuth = $true
        } elseif ($script:Config -and 
            $script:Config.ContainsKey('Username') -and $script:Config.ContainsKey('Password') -and
            -not [string]::IsNullOrWhiteSpace($script:Config.Username) -and 
            -not [string]::IsNullOrWhiteSpace($script:Config.Password)) {
            $Username = $script:Config.Username
            $Password = $script:Config.Password
            $useBasicAuth = $true
        }
    }
    
    # If no authentication method determined, prompt user
    if (-not $useOAuth -and -not $useBasicAuth) {
        Write-Host "`nNo authentication credentials found in config.ps1 or parameters." -ForegroundColor Yellow
        Write-Host "Choose authentication method:" -ForegroundColor Cyan
        Write-Host "  [1] Username/Password (Basic Auth)" -ForegroundColor White
        Write-Host "  [2] Client ID/Secret (OAuth)" -ForegroundColor White
        
        $authChoice = Read-Host "Select authentication method"
        
        switch ($authChoice) {
            '1' {
                $Username = Read-Host "Enter username"
                $securePassword = Read-Host "Enter password" -AsSecureString
                $Password = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
                    [Runtime.InteropServices.Marshal]::SecureStringToBSTR($securePassword)
                )
                $useBasicAuth = $true
            }
            '2' {
                $ClientId = Read-Host "Enter Client ID"
                $secureSecret = Read-Host "Enter Client Secret" -AsSecureString
                $ClientSecret = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
                    [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secureSecret)
                )
                $useOAuth = $true
            }
            default {
                Write-Host "Invalid choice. Exiting." -ForegroundColor Red
                exit 1
            }
        }
    }
    
    # Set credentials in script config
    if ($useOAuth) {
        $script:Config.ClientId = $ClientId
        $script:Config.ClientSecret = $ClientSecret
        $script:Config.Username = ""
        $script:Config.Password = ""
        Write-Host "🔑 Using OAuth authentication" -ForegroundColor Cyan
    } elseif ($useBasicAuth) {
        $script:Config.Username = $Username
        $script:Config.Password = $Password
        $script:Config.ClientId = ""
        $script:Config.ClientSecret = ""
        Write-Host "🔑 Using Basic authentication" -ForegroundColor Cyan
    }
    
    try {
        # Get authentication token
        Write-Host "`n🌐 Connecting to JAMF Pro..." -ForegroundColor Cyan
        $tokenParams = @{
            BaseUrl      = $script:Config.BaseUrl
            Username     = $script:Config.Username
            Password     = $script:Config.Password
            ClientId     = $script:Config.ClientId
            ClientSecret = $script:Config.ClientSecret
        }
        $script:Config.Token = Get-JamfToken @tokenParams
        
        Write-Host "✅ Successfully connected to JAMF Pro!" -ForegroundColor Green
        Write-Host "🖥️  Server: $($script:Config.BaseUrl)" -ForegroundColor Gray
        Write-Host ""
        return $true
    } catch {
        Write-Host "❌ Failed to connect to JAMF Pro: $_" -ForegroundColor Red
        Write-Host "⚠️  Please verify your credentials and server URL." -ForegroundColor Yellow
        return $false
    }
}
