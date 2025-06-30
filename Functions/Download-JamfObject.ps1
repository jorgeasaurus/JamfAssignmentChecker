function Download-JamfObject {
    # Downloads and saves Jamf objects with their associated files
    param (
        [string]$Id,
        [string]$Resource,
        [string]$DownloadDirectory
    )

    try {
        # Validate token status before proceeding
        Test-AndRenewAPIToken -BaseUrl $script:Config.BaseUrl -Token $script:Config.Token
        
        # Get object details from Jamf
        $jamfObject = Get-JamfObject -Id $Id -Resource $Resource
        $extension = if ($Resource -eq "computer-prestages") { "json" } else { "xml" }
        $displayName = Get-SanitizedDisplayName -Id $Id -Name $jamfObject.name

        # Define resources that can be organized by site
        $siteBasedResources = @(
            "computergroups",
            "computers",
            "macapplications",
            "mobiledeviceapplications",
            "mobiledeviceconfigurationprofiles",
            "mobiledevicegroups",
            "osxconfigurationprofiles",
            "policies",
            "restrictedsoftware"
        )

        $subfolder = ""
        $targetDir = $DownloadDirectory  # default target directory

        if ($jamfObject.plist) {
            # Parse XML content
            [xml]$xml = $jamfObject.plist

            # Set subfolder based on group type (smart vs static)
            if ($Resource -in @("computergroups", "mobiledevicegroups")) {
                $subfolder = if ($xml.SelectSingleNode("//is_smart").InnerText -eq 'true') { "smart" } else { "static" }
            } 
            # Organize by site if applicable
            elseif ($siteBasedResources -contains $Resource) {
                $siteName = switch ($Resource) {
                    "computergroups" { $xml.computer_group.site.name }
                    "computers" { $xml.computer.general.site.name }
                    "macapplications" { $xml.mac_application.general.site.name }
                    "mobiledeviceapplications" { $xml.mobile_device_application.general.site.name }
                    "mobiledeviceconfigurationprofiles" { $xml.mobile_device_configuration_profile.general.site.name }
                    "mobiledevicegroups" { $xml.mobile_device_group.site.name }
                    "osxconfigurationprofiles" { $xml.os_x_configuration_profile.general.site.name }
                    "policies" { $xml.policy.general.site.name }
                    "restrictedsoftware" { $xml.restricted_software.general.site.name }
                }

                # Set site-based subfolder if site exists and isn't 'NONE'
                if (-not [string]::IsNullOrWhiteSpace($siteName)) {
                    $subfolder = if ($siteName -ne 'NONE') { $siteName }
                }
            }

            # Create and use subfolder if specified
            if ($subfolder) {
                $targetDir = Join-Path -Path $DownloadDirectory -ChildPath $subfolder
            }

            # Save plist file
            Ensure-DirectoryExists -DirectoryPath $targetDir
            $plistFilePath = Join-Path -Path $targetDir -ChildPath "$displayName.plist"
            $jamfObject.plist | Out-File -FilePath $plistFilePath -Encoding utf8
            Format-XML -FilePath $plistFilePath
        }

        # Save payload file if it exists
        if ($jamfObject.payload) {
            Ensure-DirectoryExists -DirectoryPath $targetDir
            $payloadFilePath = Join-Path -Path $targetDir -ChildPath "$displayName.$extension"
            $jamfObject.payload | Out-File -FilePath $payloadFilePath -Encoding utf8
            if ($extension -eq "xml") {
                Format-XML -FilePath $payloadFilePath
            }
        }

        # Save script content if it exists
        if ($jamfObject.script) {
            # Remove .sh extension if present in display name
            if ($displayName -like "*.sh") {
                $displayName = $displayName -replace '\.sh$', ''
            }

            $scriptFilePath = Join-Path -Path $DownloadDirectory -ChildPath "$displayName.sh"
            $jamfObject.script | Out-File -FilePath $scriptFilePath -Encoding utf8
        }
    } catch {
        Write-Error "Error downloading $Resource : ID $Id - $_"
    }
}
