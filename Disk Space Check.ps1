#Created by: Will Lawrence
#Last Updated: 10/29/2024
#Blank version for profile
#Disk Space

# Prompt user for credentials
$credential = Get-Credential -Message "Enter your credentials"

# Define an array of remote server names or IP addresses
$remoteServers = @("Sever1", "Sever2", "Sever3", "Sever4", "Sever5", "Sever6", "Sever7", "Sever8", "Sever9", "Sever10", "Sever11", "Sever12", "Sever13", "Sever14", "Sever15", "Sever16")

# Initialize an array to hold results
$results = @()

# Loop through each server and check disk space
foreach ($server in $remoteServers) {
    $serverResults = @()
    foreach ($drive in @("C", "E")) {
        $result = Invoke-Command -ComputerName $server -Credential $credential -ScriptBlock {
            param ($driveLetter)
            $disk = Get-PSDrive -Name $driveLetter
            if ($disk) {
                return [PSCustomObject]@{
                    Drive       = $disk.Name
                    UsedSpace   = [math]::round($disk.Used / 1GB, 2)
                    FreeSpace   = [math]::round($disk.Free / 1GB, 2)
                    TotalSpace  = [math]::round(($disk.Used + $disk.Free) / 1GB, 2)
                }
            } else {
                return [PSCustomObject]@{
                    Drive       = $driveLetter
                    UsedSpace   = "N/A"
                    FreeSpace   = "N/A"
                    TotalSpace  = "N/A"
                }
            
        } -ArgumentList $drive -ErrorAction SilentlyContinue
        
        # Add the result to the server's results
        if ($result) {
            $serverResults += $result
        } else {
            $serverResults += [PSCustomObject]@{
                Drive       = $drive
                UsedSpace   = "N/A"
                FreeSpace   = "N/A"
                TotalSpace  = "N/A"
            }
        }
    }

    # Add server name to each result and store in the overall results
    foreach ($entry in $serverResults) {
        $results += [PSCustomObject]@{
            ServerName  = $server
            Drive       = $entry.Drive
            UsedSpace   = $entry.UsedSpace
            FreeSpace   = $entry.FreeSpace
            TotalSpace  = $entry.TotalSpace
        }
    }
}

# Output the results under the same header
$results | Format-Table -AutoSize