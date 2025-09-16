function Ensure-DirectoryExists {
    # Creates a directory if it doesn't exist
    param (
        [string]$DirectoryPath
    )
    if (-not (Test-Path $DirectoryPath)) {
        New-Item -Path $DirectoryPath -ItemType Directory -Force | Out-Null
    }
}
