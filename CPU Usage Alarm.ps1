#Created by: Will Lawrence
#Last Updated: 02/24/25
#Notes: Updated to lessen the WimRM connection failures generating false positives
#Blank server version for profile
#CPU Usage Alarm

# List of remote server names
$RemoteComputers = @("Sever1", "Sever2", "Sever3", "Sever4", "Sever5", "Sever6", "Sever7", "Sever8", "Sever9", "Sever10", "Sever11", "Sever12", "Sever13", "Sever14", "Sever15", "Sever16")

# Credential prompt for accessing the remote machines
$Credential = Get-Credential

# URL to open if CPU usage exceeds the threshold or server doesn't respond
$HighCPUURL = https://www.youtube.com/watch?v=rlxFz29bcyg

# CPU usage threshold (percentage) to trigger the pause and web page
$CPUThreshold = 90

# Function to get CPU usage from a remote machine
function Get-RemoteCPUUsage {
    param (
        [string]$ComputerName,
        [pscredential]$Credential
    )
   
    try {
        Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock {
            $cpuUsage = (Get-Counter -Counter "\Processor(_Total)\% Processor Time").CounterSamples[0].CookedValue
            return [math]::Round($cpuUsage, 2)
        }
    } catch {
        # Check for specific WinRM server name resolution failure in five different ways
        $errorMessage = $_.Exception.Message

        # Redundancy checks for WinRM name resolution failure
        if ($errorMessage -match "The WinRM client cannot process the request because the server name cannot be resolved") {
            Write-Output ("Info: Server name resolution failed for {0}. Skipping this server." -f $ComputerName)
            return $null  # Return null to prevent triggering high CPU
        }
        elseif ($errorMessage -match "Could not resolve the host") {
            Write-Output ("Info: Host resolution failed for {0}. Skipping this server." -f $ComputerName)
            return $null  # Skip for resolution failure
        }
        elseif ($errorMessage -match "The computer name could not be found") {
            Write-Output ("Info: Computer name not found for {0}. Skipping this server." -f $ComputerName)
            return $null  # Skip when name is not found
        }
        elseif ($errorMessage -match "No such host is known") {
            Write-Output ("Info: No such host for {0}. Skipping this server." -f $ComputerName)
            return $null  # Skip when no host is known
        }
        elseif ($errorMessage -match "DNS name does not exist") {
            Write-Output ("Info: DNS resolution failed for {0}. Skipping this server." -f $ComputerName)
            return $null  # Skip for DNS failure
        }
        else {
            # If other errors are encountered, log them and treat them as high CPU or server non-responsive
            Write-Output ("Error accessing {0}: {1}" -f $ComputerName, $errorMessage)
            return $null  # Return null for any other error (non-responsive)
        }
    }
}

# Function to pause and open the web page
function PauseAndOpenWebPage {
    Write-Output "$(Get-Date): Pausing monitoring for 30 minutes due to high CPU usage or server not responding."
    # Open the web page
    Start-Process -FilePath "cmd.exe" -ArgumentList "/c start $HighCPUURL"
    # Pause for 30 minutes (1800 seconds)
    Start-Sleep -Seconds 1800
}

# Continuous monitoring every minute
while ($true) {
    $HighCPUDetected = $false # Flag to detect high CPU usage or server non-responsiveness
    foreach ($RemoteComputer in $RemoteComputers) {
        $cpuUsage = Get-RemoteCPUUsage -ComputerName $RemoteComputer -Credential $Credential
        if ($cpuUsage -ne $null) {
            Write-Output "$(Get-Date): CPU Usage on $RemoteComputer is $cpuUsage%"
            Write-Output ("-" * 50)  # Add a line of dashes after CPU output

            # Check if CPU usage exceeds threshold
            if ($cpuUsage -gt $CPUThreshold) {
                Write-Host "$(Get-Date): High CPU usage detected on $RemoteComputer ($cpuUsage%)." -ForegroundColor Red
                Write-Output ("-" * 50)  # Add a line of dashes after detecting high CPU
                $HighCPUDetected = $true
            }
        } else {
            # If no CPU usage data returned, assume server is non-responsive
            Write-Output "$(Get-Date): Unable to retrieve CPU usage from $RemoteComputer. Treating as high CPU usage."
            Write-Output ("-" * 50)  # Add a line of dashes after server non-response
            $HighCPUDetected = $true
        }
    }

    # If high CPU usage or server non-responsiveness is detected, pause and open the web pag
    if ($HighCPUDetected) {
        PauseAndOpenWebPage
    }


    # Wait 1 minute before the next check
    Write-Output ("$(Get-Date): Pausing for 1 minute before the next check.")
    Write-Output ("-" * 50)  # Add a line of dashes before the next check
    Start-Sleep -Seconds 60
}