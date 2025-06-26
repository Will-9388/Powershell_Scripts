#Created by: Will Lawrence
#Last Updated: 12/20/2024
#Blank server/service names version for profile
#Service Alarm

# Array of remote servers
$servers = @("Sever1", "Sever2", "Sever3", "Sever4", "Sever5", "Sever6", "Sever7", "Sever8", "Sever9", "Sever10", "Sever11", "Sever12", "Sever13", "Sever14", "Sever15", "Sever16")

# Array of service names to check
$serviceNames = @("Service1", "Service2")

# Prompt user for credentials
$credential = Get-Credential -Message "Enter your credentials"

while ($true) {
    foreach ($remoteServer in $servers) {
        foreach ($serviceName in $serviceNames) {
            # Define the script block to run on the remote server
            $scriptBlock = {
                param($serviceName)
                Get-Service -Name $serviceName | Select-Object -ExpandProperty Status
            }

            # Execute the script block on the remote server
            $status = Invoke-Command -ComputerName $remoteServer -ScriptBlock $scriptBlock -ArgumentList $serviceName -Credential $credential

            # Display Output
            Write-Host "Service status on $($remoteServer)\$($serviceName): $($status)"

            # Check if the status is not 4 (Running)
            if ($status -ne 4) {
                Write-Host "!!!ALERT!!!"
                Start-Process https://www.youtube.com/watch?v=rlxFz29bcyg
                Write-Host "Pausing for 30 Minutes..."
                Start-Sleep -Seconds 1800
            }

            Write-Host "---------------------------------------------"

        }
    }

    Write-Output "Sleeping for 60 Seconds..."
    Start-Sleep -Seconds 60
}