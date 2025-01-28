# Ensure the log file directory exists
$ServiceLogDir = "C:\Temp\"
if (!(Test-Path $ServiceLogDir)) {
    New-Item -ItemType Directory -Path $ServiceLogDir | Out-Null
}

# Find all stopped services
$StoppedServices = Get-Service | Where-Object { $_.Status -eq 'Stopped' }

# Start stopped services in parallel
$StoppedServices | ForEach-Object -Parallel {
    $ServiceName = $_.Name

    # Define the log file path inside ForEach-Object function
    $ServiceLogFile = "C:\Temp\ServiceLogs.txt"

    # Function to Srore log entry with timestamp inside ForEach-Object function
    function StoreLog {
        param (
            $Message
        )
        $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        "$Timestamp - $Message" | Out-File -FilePath $ServiceLogFile -Append
    }

    try {
        # Attempt to start the service
        Start-Service -Name $ServiceName -ErrorAction Stop
        $Status = "Started"
    }
    catch {
        $Status = "Failed to start: $_"
    }

    # Log the service name and status
    $LogMessage = "Service: $ServiceName, Status: $Status"
    Write-Host $LogMessage -ForegroundColor Blue
    StoreLog -Message $LogMessage
} -ThrottleLimit 100

Write-Host "`nScript ended. Log available at: $ServiceLogFile" -ForegroundColor Cyan
