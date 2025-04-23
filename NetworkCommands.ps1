# Write-Host "Checking IP Config..."
# ipconfig /all > $null 2>&1
Clear-Host
Write-Host "[INFO] Performing DNS Lookup for google.com..." -ForegroundColor Cyan

$NslookupResult = nslookup google.com 2>&1

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