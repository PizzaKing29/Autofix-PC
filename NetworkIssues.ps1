Clear-Host
# Write-Host "Checking IP Config..."
# ipconfig /all > $null 2>&1


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

foreach ($NetworkService in $NetworkServices)
{
    $NetworkServicesCompleted++
    Write-Host "Checking for Network Errors for Service: $($NetworkService.DisplayName) ($($NetworkService.ServiceName)) - Completed: $NetworkServicesCompleted/$TotalNetworkServices"

    $NetworkErrors = Get-EventLog -LogName System -Source $NetworkService.Source -EntryType Error -Newest 5 -ErrorAction SilentlyContinue

    if ($NetworkErrors)
    {
        $NetworkErrorsFound++
        Write-Host " Found Errors in System Log:"
        foreach ($Error in $NetworkErrors)
        {
            Write-Host "    Time Generated: $($Error.TimeGenerated)"
            Write-Host "    Message: $($Error.Message)"
            Write-Host "    -------------------------"
        }
    }
    else
    {
        Write-Host "  No recent Network Errors found in System Log"
    }
}
Write-Host "You Have found $($NetworkErrorsFound) Errors!"
powershell -NoLogo -noexit