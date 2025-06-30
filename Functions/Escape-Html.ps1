function Escape-Html {
    <#
    .SYNOPSIS
        Escapes HTML special characters to prevent XSS and HTML injection.
    #>
    param (
        [string]$Text
    )
    
    if ([string]::IsNullOrEmpty($Text)) {
        return ""
    }
    
    return $Text -replace '&', '&amp;' -replace '<', '&lt;' -replace '>', '&gt;' -replace '"', '&quot;' -replace "'", '&#39;'
}
