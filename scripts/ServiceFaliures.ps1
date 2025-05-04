Clear-Host
$Services
do
{
    $CheckStoppedServices = Read-Host "Would You Like to check stopped services? or all services? (1 = Stoppped Services    2 = All Services)"
    switch ($CheckStoppedServices)
    {
        "1" 
        { 
            $Services = Get-Service | Where-Object { $_.Status -eq 'Stopped' }
        }
        "2" 
        { 
            $Services = Get-Service 
        }
        default
        {
            Write-Host "Input answer is invalid, please try again..." -ForegroundColor Red
        }
    }
}
until ($CheckStoppedServices -eq "1" -or $CheckStoppedServices -eq "2")



$TotalServices = $Services.Count

Write-Host "Total Services to Check: $TotalServices"
$ServicesCompleted = 0

foreach ($Service in $Services)
{
    $ServicesCompleted++
    Write-Host "Checking for Errors for Service: $($Service.DisplayName) ($($Service.ServiceName)) - " -NoNewline
    Write-Host "Completed: $ServicesCompleted/$TotalServices" -ForegroundColor Green
    $SystemErrors = Get-EventLog -LogName System -Source $Service.ServiceName -EntryType Error -Newest 5 -ErrorAction SilentlyContinue

    if ($SystemErrors)
    {
        Write-Host " Found Errors in System Log:"
        foreach ($Error in $SystemErrors)  # EROR in Windows Event log
        {
            Write-Host "    Time Generated: $($Error.TimeGenerated)" -ForegroundColor Cyan
            Write-Host "    Message: $($Error.Message)" -ForegroundColor Red
            Write-Host "    -------------------------"
        }
    }
    else
    {
        Write-Host "  No recent errors found in System Log" -ForegroundColor Green
    }

    $ApplicationErrors = Get-EventLog -LogName Application -Source $Service.ServiceName -EntryType Error -Newest 5 -ErrorAction SilentlyContinue

    if ($ApplicationErrors)
    {
        Write-Host " Found Errors in Application Log:"
        foreach($Error in $ApplicationErrors) # ERROPR Volume Shadow Copy (Cannot overrite variable errore beacuase it is read only or constant)
        {
            Write-Host "    Time Generated: $($Error.TimeGenerated)" -ForegroundColor Cyan
            Write-Host "    Message: $($Error.Message)" -ForegroundColor Red
            Write-Host "    -------------------------"
        }
    }
    else
    {
        Write-Host " No recent errors found in Application Log" -ForegroundColor Green
    }

    Write-Host ""
}
powershell -NoLogo -noexit