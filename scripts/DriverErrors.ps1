$drivers = Get-WmiObject Win32_PnPSignedDriver | Select-Object DeviceName, DriverVersion, Manufacturer, Status
Clear-Host

foreach ($Driver in $Drivers)
{
    Write-Host "Checking driver for: $($Driver.DeviceName)" -ForegroundColor Cyan

    $DriverVersion = if ($Driver.DriverVersion -match ",")
    {
        $Driver.DriverVersion.Split(',')[0]
    }
    else
    {
        $Driver.DriverVersion
    }
    Write-Host "Driver Version: $DriverVersion" -ForegroundColor Yellow

    if ($Driver.Status -ne "OK")
    {
        Write-Host "Updating driver for $($Driver.DeviceName)..." -ForegroundColor Yellow

        try
        {
            $DeviceID = $Diver.DeviceID
            Write-Host "Running pnputil to update driver for device ID: $DeviceId" -ForegroundColor Green
            $UpdateCommand = "pnputil /add-driver $DeviceId /install"
            Invoke-Expression $UpdateCommand
            Write-Host "Driver update command executed." -ForegroundColor Green
        }
        catch
        {
            Write-Host "Error updating driver: $_" -ForegroundColor Red
        }
    }
    else
    {
        Write-Host "Driver is up to date for $($Driver.DeviceName)." -ForegroundColor Green
    }
}
powershell -NoLogo -noexit