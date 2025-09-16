function Format-XML {
    param (
        [string]$FilePath, # Path to the input XML file
        [string]$OutputPath = $FilePath    # Path for the formatted output, defaults to input path
    )

    try {
        # Read the entire file as a single string
        $content = Get-Content -Path $FilePath -Raw

        # Remove any non-printable characters except tab, newline, and carriage return
        $cleanContent = $content -replace '[^\x09\x0A\x0D -~]', ''

        # Convert the cleaned string to XML object
        $xml = [xml]$cleanContent

        # Create XML writer with UTF-8 encoding
        $xmlWriter = New-Object System.Xml.XmlTextWriter($OutputPath, [System.Text.Encoding]::UTF8)

        # Configure writer to use indented format
        $xmlWriter.Formatting = [System.Xml.Formatting]::Indented
        $xmlWriter.Indentation = 4    # Set indent to 4 spaces

        # Save the formatted XML to file
        $xml.Save($xmlWriter)

        # Clean up by closing the writer
        $xmlWriter.Close()
    } catch {
        Write-Error "Failed to format XML: $_"
    }
}
