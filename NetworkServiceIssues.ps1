Clear-Host

$NetworkServices = Get-EventLog -LogName System | Where-Object {
    $_.Source -in @(
        "Tcpip",
        "Dhcp-Client",
        "DNS Client",
        "NetBT",
        "Service Control Manager"
        )
    } | Select-Object -First 20
    
$NetworkServicesCompleted = 0
$NetworkErrorsFound = 0
$TotalNetworkServices = $NetworkServices.Count
$ProcessedServices = @()

function RestartNetworkLogError ([Parameter(Mandatory = $true)] [System.Diagnostics.EventLogEntry]$LogEntry)
{
    if ($LogEntry.Message -match "The (.+?) service") 
    {
        $ServiceName = $matches[1].Trim()
        $Service = Get-Service | Where-Object { $_.DisplayName -like "$ServiceName*" }

        if($Service)
        {
            try 
            {
                Write-Host "`n[INFO] Attempting to restart service: $ServiceName" -ForegroundColor Cyan
                Restart-Service -Name $ServiceName -Force -ErrorAction Stop
                Write-Host "[SUCCESS] Successfully restarted service: $ServiceName" -ForegroundColor Green
                return $true
            } 
            catch 
            {
                Write-Host "[ERROR] Failed to restart service: $ServiceName" -ForegroundColor Red
                Write-Host "Details: $($_.Exception.Message)" -ForegroundColor DarkRed
                return $false
            }
        }
    } 
    else 
    {
        Write-Host "[WARNING] Could not extract a service name from the log message." -ForegroundColor Yellow
        return $false
    }
}

foreach ($NetworkService in $NetworkServices)
{
    $NetworkErrors = @()
    $NetworkServicesCompleted++
    $ServiceName = $NetworkService.Source

    if($ProcessedServices -notcontains $ServiceName)
    {
        Write-Host "Checking for Network Errors for Service: $ServiceName - Completed: $NetworkServicesCompleted/$TotalNetworkServices"
        $NetworkErrors = Get-EventLog -LogName System -Source $NetworkService.Source -EntryType Error -Newest 5 -ErrorAction SilentlyContinue

        if ($NetworkErrors)
        {
            $NetworkErrorsFound++
            Write-Host " Found Errors in System Log:"
            foreach ($NetworkError in $NetworkErrors)
            {
                Write-Host "    Time Generated: $($NetworkError.TimeGenerated)"
                Write-Host "    Message: $($NetworkError.Message)"
                Write-Host "    -------------------------"

                RestartNetworkLogError -LogEntry $NetworkError | Out-Null
            }
        }
        else
        {
            Write-Host "  No recent Network Errors found in System Log"
        }

        $ProcessedServices += $ServiceName
    }
    else 
    {
        Write-Host "Skipping Service: $ServiceName (already processed)"
    }
}
Write-Host "You Have found $($NetworkErrorsFound) Error/s!"
powershell -NoLogo -noexit