#Created by: Will Lawrence
#Last Updated: 07/28/2025
#Added dynamic Wildfly check for upgrade cycles
#Added no Apache check for scheduling servers to combine scripts
#Added custom output list instead of basic server aray to keep order with new no apache checks

# Combined ordered server list with Apache check flag
$serversOrdered = @(
    [PSCustomObject]@{ Name = "Server1";   CheckApache = $true },
    [PSCustomObject]@{ Name = "Server2";   CheckApache = $true },
    [PSCustomObject]@{ Name = "Server3";   CheckApache = $true },
    [PSCustomObject]@{ Name = "Server4";   CheckApache = $true },
    [PSCustomObject]@{ Name = "Server5";   CheckApache = $true },
    [PSCustomObject]@{ Name = "Server6";   CheckApache = $true },
    [PSCustomObject]@{ Name = "Server7";   CheckApache = $false },
    [PSCustomObject]@{ Name = "Server8";   CheckApache = $false },
    [PSCustomObject]@{ Name = "Server9";   CheckApache = $true },
    [PSCustomObject]@{ Name = "Server10";   CheckApache = $true },
    [PSCustomObject]@{ Name = "Server11";   CheckApache = $true },
    [PSCustomObject]@{ Name = "Server12";   CheckApache = $true },
    [PSCustomObject]@{ Name = "Server13";   CheckApache = $true },
    [PSCustomObject]@{ Name = "Server14";   CheckApache = $true },
    [PSCustomObject]@{ Name = "Server15";   CheckApache = $false },
    [PSCustomObject]@{ Name = "Server16";    CheckApache = $true },
    [PSCustomObject]@{ Name = "Server17";    CheckApache = $true },
    [PSCustomObject]@{ Name = "Server18";    CheckApache = $true },
    [PSCustomObject]@{ Name = "Server19";    CheckApache = $true }
)

# Services to check
$wildflyServices = @("Wildfly32", "Wildfly34")
$apacheService = "Apache2.4"

# Prompt user for credentials
$credential = Get-Credential -Message "Enter your credentials"

# Function to check Wildfly services
function Check-Wildfly {
    param($remoteServer, $wildflyServices, $credential)

    $wildflyScriptBlock = {
        param($serviceListSerialized)
        $serviceList = $serviceListSerialized -split ';'
        $statuses = @()
        foreach ($svc in $serviceList) {
            try {
                $s = Get-Service -Name $svc -ErrorAction Stop
                $statuses += [PSCustomObject]@{
                    Name = $s.Name
                    Status = $s.Status.ToString()
                }
            } catch {
                continue
            }
        }
        return $statuses
    }

    $serializedServiceList = $wildflyServices -join ';'
    $wildflyStatuses = Invoke-Command -ComputerName $remoteServer -ScriptBlock $wildflyScriptBlock -ArgumentList $serializedServiceList -Credential $credential

    $anyWildflyRunning = $false

    if ($wildflyStatuses.Count -eq 0) {
        Write-Host "No Wildfly services found on ${remoteServer}"
    } else {
        foreach ($svc in $wildflyStatuses) {
            Write-Host "$($svc.Name) on ${remoteServer}: $($svc.Status)"
            if ($svc.Status -eq 'Running') {
                $anyWildflyRunning = $true
            }
        }
    }
    return $anyWildflyRunning
}

# Function to check Apache service
function Check-Apache {
    param($remoteServer, $apacheService, $credential)

    $apacheScriptBlock = {
        param($serviceName)
        try {
            $s = Get-Service -Name $serviceName -ErrorAction Stop
            return [PSCustomObject]@{
                Name = $s.Name
                Status = $s.Status.ToString()
            }
        } catch {
            return $null
        }
    }

    $apacheStatus = Invoke-Command -ComputerName $remoteServer -ScriptBlock $apacheScriptBlock -ArgumentList $apacheService -Credential $credential

    if ($apacheStatus) {
        Write-Host "$($apacheStatus.Name) on ${remoteServer}: $($apacheStatus.Status)"
        if ($apacheStatus.Status -ne 'Running') {
            Write-Host "Apache is not running on ${remoteServer}"
            return $false
        }
        return $true
    } else {
        Write-Host "Apache service not found on ${remoteServer}"
        return $false
    }
}

# Main loop
while ($true) {

    foreach ($serverInfo in $serversOrdered) {
        $server = $serverInfo.Name
        $alertNeeded = $false

        Write-Host "Checking services on $server..."

        # Check Wildfly
        $wildflyRunning = Check-Wildfly -remoteServer $server -wildflyServices $wildflyServices -credential $credential
        if (-not $wildflyRunning) {
            $alertNeeded = $true
            Write-Host "No Wildfly service is running on $server"
        }

        # Check Apache if needed
        if ($serverInfo.CheckApache) {
            $apacheRunning = Check-Apache -remoteServer $server -apacheService $apacheService -credential $credential
            if (-not $apacheRunning) {
                $alertNeeded = $true
            }
        }

        Write-Host "---------------------------------------------"

        if ($alertNeeded) {
            Write-Host "!!!ALERT on $server!!!"
            Start-Process "https://www.youtube.com/watch?v=rlxFz29bcyg"
            Write-Host "Pausing for 30 Minutes..."
            Start-Sleep -Seconds 1800
        }
    }

    Write-Output "Sleeping for 60 Seconds..."
    Start-Sleep -Seconds 60
}
