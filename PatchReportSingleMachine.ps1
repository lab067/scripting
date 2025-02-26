<#
.SYNOPSIS
    Reports patch levels (installed updates) on a remote computer.
.DESCRIPTION
    Queries a remote computer for installed Windows updates using the Get-HotFix cmdlet
    and generates a summary of installed patches, their count, and the latest update.
#>

# Function to check patch levels on a remote computer
function Get-PatchLevel {
    param (
        [string]$RemoteComputer
    )

    Write-Output "Checking patch levels on: $RemoteComputer"

    # Test if the remote computer is reachable
    if (-not (Test-Connection -ComputerName $RemoteComputer -Count 1 -Quiet)) {
        Write-Error "The computer '$RemoteComputer' is not reachable. Check the network connection."
        return
    }

    try {
        # Get installed updates using Get-HotFix
        $Updates = Get-HotFix -ComputerName $RemoteComputer -ErrorAction Stop

        if ($Updates) {
            # Display summary
            $TotalUpdates = $Updates.Count
            $LatestUpdate = $Updates | Sort-Object InstalledOn -Descending | Select-Object -First 1

            Write-Output "`nInstalled Updates Summary:"
            Write-Output "--------------------------"
            Write-Output "Total Updates Installed: $TotalUpdates"
            Write-Output "Latest Update: $($LatestUpdate.HotFixID) on $($LatestUpdate.InstalledOn.ToShortDateString())"
            Write-Output "`nDetailed List of Installed Updates:"
            Write-Output "----------------------------------"
            $Updates | Sort-Object -Descending | Format-Table HotFixID, Description, InstalledOn, InstalledBy -AutoSize
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

# Get the remote computer name from the user
$RemoteComputer = Read-Host "Enter the remote computer name or IP address"

# Run the function to check patch levels
Get-PatchLevel -RemoteComputer $RemoteComputer
