# Write-Host "Checking IP Config..."
# ipconfig /all > $null 2>&1
$ErrorActionPreference = "Stop"
Clear-Host

function TestDNSAndInternet ()
{
    try 
    {

        $ActiveAdapter = Get-NetAdapter | Where-Object { $_.Status -eq "Up" } | Select-Object -First 1
        if ($ActiveAdapter)
        {
            Write-Host "Active network adapter found: $($ActiveAdapter.Name)" -ForegroundColor Green
            $AdapterIP = Get-NetIPAddress -InterfaceAlias $ActiveAdapter.Name | Where-Object { $_.AddressFamily -eq "IPv4" }

            if ($AdapterIP)
            {
                Write-Host "IP address found: $($AdapterIP.IPAddress)" -ForegroundColor Green
            }
            else
            {
                Write-Host "No IPv4 address assigned to the active adapter." -ForegroundColor Red
            }
        }

        $PingResult1 = Test-Connection -ComputerName 8.8.8.8 -Count 1 -Quiet
        if ($PingResult1)
        {
            Write-Host "Successfully pinged 8.8.8.8 (Google DNS)." -ForegroundColor Green
        }
        else
        {
            Write-Host "Failed to ping 8.8.8.8 (Google DNS)." -ForegroundColor Red
        }

        $PingResult2 = Test-Connection -ComputerName google.com -Count 1 -Quiet
        if ($PingResult2) 
        {
            Write-Host "Successfully pinged google.com." -ForegroundColor Green
        } 
        else 
        {
            Write-Host "Failed to ping google.com." -ForegroundColor Red
        }
    }
    catch 
    {
        Write-Host "An error occurred during the test." -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
    }
}
TestDNSAndInternet

Write-Host "[INFO] Performing DNS Lookup for google.com..." -ForegroundColor Cyan

try
{
    $NslookupResult = nslookup google.com 2>&1
}
catch
{
    Write-Host "[ERROR] Couldnt run the command " -NoNewLine -ForegroundColor Red
    Write-Host "nslookup " -NoNewLine
    Write-Host "google.com" -Foregroundcolor Yellow
    Write-Host "Error Message: $_" -ForegroundColor Red
}

if ($NslookupResult -match "timed out" -or $nslookupResult -match "can't find")
{
    Clear-Host
    Write-Host "[ERROR] DNS Lookup Failed..." -ForegroundColor Red
    Write-Host " > Flushing DNS cache..." -ForegroundColor Yellow
    ipconfig /flushdns

    Write-Host " > Attempting to restart DNS Client..." -ForegroundColor Yellow
    try
    {
        Restart-Service -Name "Dnscache" -Force -ErrorAction Stop
        Write-Host " > DNS Client restarted." -ForegroundColor Green
    } 
    catch 
    {
        Write-Host " > [SKIPPED] DNS Client cannot be manually restarted on this system." -ForegroundColor DarkGray
        Write-Host " > To restart manually:" -ForegroundColor Yellow
        Write-Host "    - Open Task Manager (Ctrl + Shift + Esc)" -ForegroundColor Gray
        Write-Host "    - Go to the 'Services' tab" -ForegroundColor Gray
        Write-Host "    - Find 'Dnscache' (might be listed as 'DNS Client')" -ForegroundColor Gray
        Write-Host "    - Right-click and choose 'Restart' (if allowed)" -ForegroundColor Gray
        Write-Host "    - OR: Restart your computer to apply DNS cache changes" -ForegroundColor Gray
    }

    Write-Host " > Setting Google DNS..." -ForegroundColor Yellow
    $Adapter = Get-NetAdapter | Where-Object { $_.Status -eq "Up" } | Select-Object -First 1
    if ($Adapter)
    {
        Set-DnsClientServerAddress -InterfaceAlias $Adapter.Name -ServerAddresses ("8.8.8.8","8.8.4.4")
        Write-Host " > DNS changed to Google (8.8.8.8, 8.8.4.4)" -ForegroundColor Green
    }
    else
    {
        Write-Host "[ERROR] No active network adapter found." -ForegroundColor Red
    }

    Write-Host " > Retesting DNS Lookup..." -ForegroundColor Cyan
    nslookup google.com
}
else
{
    Clear-Host
    Write-Host "[SUCCESS] DNS Lookup Successful..." -ForegroundColor Green
}

powershell -NoLogo -noexit