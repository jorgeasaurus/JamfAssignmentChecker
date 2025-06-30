function Get-SanitizedDisplayName {
    # Sanitizes object names by replacing non-alphanumeric chars with underscores
    param (
        [string]$Id,
        [string]$Name
    )
    $sanitizedName = $Name -replace '[^\x30-\x39\x41-\x5A\x61-\x7A]+', '_'
    return "$($id)_$sanitizedName"
}
