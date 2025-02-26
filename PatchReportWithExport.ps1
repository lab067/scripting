<#
.SYNOPSIS
    Reports patch levels (installed updates) on multiple remote computers.
.DESCRIPTION
    Reads a list of computer names from "Computers.txt", queries each for installed updates, 
    and exports results to a CSV file named "PatchReport_<ComputerName>.csv".
#>

# Function to check patch levels on a remote computer and export to CSV
function Get-PatchLevel {
    param (
        [string]$RemoteComputer
    )

    Write-Output "Checking patch levels on: $RemoteComputer"

    # Test if the remote computer is reachable
    if (-not (Test-Connection -ComputerName $RemoteComputer -Count 1 -Quiet)) {
        Write-Output "The computer '$RemoteComputer' is not reachable. Skipping..."
        return
    }

    try {
        # Get installed updates using Get-HotFix
        $Updates = Get-HotFix -ComputerName $RemoteComputer -ErrorAction Stop

        if ($Updates) {
            # Process updates for export
            $UpdatesReport = $Updates | Sort-Object InstalledOn -Descending | Select-Object HotFixID, Description, InstalledOn, InstalledBy

            # Export to CSV
            $CsvFile = "PatchReport_$RemoteComputer.csv"
            $UpdatesReport | Export-Csv -Path $CsvFile -NoTypeInformation
            Write-Output "Report saved: $CsvFile"
        }
        else {
            Write-Output "No updates found on $RemoteComputer."
        }
    }
    catch {
        Write-Error "Failed to query updates on $RemoteComputer. Error: $_"
    }
}

# Main script
Clear-Host
Write-Output "Patch Level Report Script"
Write-Output "-------------------------"

# Check if Computers.txt exists
$ComputerListFile = "Computers.txt"
if (-not (Test-Path $ComputerListFile)) {
    Write-Error "Error: '$ComputerListFile' not found. Please create the file with a list of computer names."
    exit
}

# Read the list of computers
$ComputerNames = Get-Content -Path $ComputerListFile

# Iterate over each computer and check patch levels
foreach ($Computer in $ComputerNames) {
    if ($Computer -match "^\s*$") { continue }  # Skip empty lines
    Get-PatchLevel -RemoteComputer $Computer.Trim()
}

Write-Output "Processing complete."
