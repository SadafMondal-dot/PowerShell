# Define the folder names
$folders = @("Docs", "Scripts", "Backups")

# Set the base path to the current directory
$basePath = Get-Location

# Create each folder if it doesn't exist
foreach ($folder in $folders) {
    $fullPath = Join-Path $basePath $folder
    if (-not (Test-Path $fullPath)) {
        New-Item -Path $fullPath -ItemType Directory | Out-Null
        Write-Host "Created folder: $folder"
    } else {
        Write-Host "Folder already exists: $folder"
    }
}