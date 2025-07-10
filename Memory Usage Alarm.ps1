﻿#Created by: Will Lawrence
#Last Updated: 07/09/25
#Memory Usage Alarm

$Credential = Get-Credential
$servers = @("Sever1", "Sever2", "Sever3", "Sever4", "Sever5", "Sever6", "Sever7", "Sever8", "Sever9", "Sever10", "Sever11", "Sever12", "Sever13", "Sever14", "Sever15", "Sever16")
$memoryThreshold = 90
$alertUrl = "https://www.youtube.com/watch?v=rlxFz29bcyg"
$pauseDuration = 1800  # 30 minutes in seconds

function Get-MemoryUsagePercent {
    param ($server)
    try {
        $os = Get-WmiObject -Class Win32_OperatingSystem -ComputerName $server -ErrorAction Stop
        $total = $os.TotalVisibleMemorySize
        $free = $os.FreePhysicalMemory
        $usedPercent = [math]::Round((($total - $free) / $total) * 100, 2)
        return $usedPercent
    } catch {
        Write-Warning "Failed to query ${server}: $($_)"
        return $null
    }
}

while ($true) {
    $alertTriggered = $false

foreach ($server in $servers) {
    $usage = Get-MemoryUsagePercent -server $server
    if ($usage -ne $null) {
        $timestamp = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
        Write-Host "${timestamp}: Memory Usage on ${server} is ${usage}%"
        Write-Host "--------------------------------------------------"
       
        if ($usage -ge $memoryThreshold) {
            Write-Warning "$server is over the memory threshold ($usage%)"
            $alertTriggered = $true
        }
    }
}


    if ($alertTriggered) {
        Start-Process $alertUrl
        Write-Host "Alert triggered. Pausing for 30 minutes..."
        Start-Sleep -Seconds $pauseDuration
    } else {
        Start-Sleep -Seconds 60  # Check every minute if no alert
    }
} 