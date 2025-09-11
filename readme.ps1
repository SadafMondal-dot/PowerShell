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
# Rename files in the "Docs" folder by adding a timestamp (MM-yyyy) to the file name
$docsPath = Join-Path $basePath "Docs"
if (Test-Path $docsPath) {
    Get-ChildItem -Path $docsPath -File | ForEach-Object {
        $timestamp = Get-Date -Format "MM-yyyy"
        $name = $_.BaseName
        $ext = $_.Extension
        $newName = "${name}_$timestamp$ext"
        $newPath = Join-Path $docsPath $newName
        Rename-Item -Path $_.FullName -NewName $newName
        Write-Host "Renamed '$($_.Name)' to '$newName'"
    }
} else {
    Write-Host "'Docs' folder does not exist."
}
