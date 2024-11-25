# Ensure BurntToast module is loaded
Import-Module BurntToast

# Check if Scoop is installed
if (-not (Get-Command "scoop" -ErrorAction SilentlyContinue)) {
    Write-Host "[ERROR] Scoop is not installed."
    exit
}

# Check for updates to Scoop and applications
Write-Host "Checking for updates..."

try {
    # Get status of all apps and check if there's an update available
    $status = scoop status | Out-String
    if ($status -match "\[update\]") {
        # Pop a notification if updates are available
        New-BurntToastNotification -Text "Scoop Updates Available", "There are updates available for Scoop and its applications. Run 'scoop update *' to update."
    } else {
        New-BurntToastNotification -Text "All applications are up to date."
    }
} catch {
    Write-Host "[ERROR] Failed to check for updates."
}
