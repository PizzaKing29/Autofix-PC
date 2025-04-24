Clear-Host
$Drives = Get-PhysicalDisk

foreach($Drive in $Drives)
{
    try
    {
        Write-Host "--------- CHECKING DRIVE HEALTH ---------" -ForegroundColor Yellow

        $Status = "✅ Healthy"
        $Color = "Green"

        if ($Drive.PredictFailure)
        {
            $Status = "⚠️ Failing"
            $Color = "Red"
        }

        if (-not $Drive.PredictFailure -and $Drive.HealthStatus)
        {
            $Status = "Health: $($Drive.HealthStatus)"
            $Color = if ($Drive.HealthStatus -ne "Healthy") { "red" } else { "Green" }
        }

        Write-Host "Drive: $($Drive.InstanceName)" -ForegroundColor Cyan
        Write-Host "Status: $Status" -ForegroundColor $Color
        Write-Host "Operational Status: $($Drive.OperationalStatus)" -ForegroundColor Gray
        Write-Host ""
    }
    catch
    {
        Write-Host "[ERROR] There Was an error attemping to check drive health..." -ForegroundColor Red
        Write-Error $_.Exception.ToString()
    }
}
powershell -NoLogo -noexit