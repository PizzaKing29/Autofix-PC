$Drives = Get-WmiObject -Namespace root\wmi -Class MSStorageDriver_FailurePredictStatus
Clear-Host

foreach($Drive in $Drives)
{
    try
    {
        Write-Host "--------- CHECKING DRIVE HEALTH ---------" -ForegroundColor Yellow
        $Status = if ($Drive.PredictFailure)
        {
            "⚠️ Failing"
        }
        else
        {
            "✅ Healthy"
        }
        Write-Host "Drive: $($Drive.InstanceName)" -ForegroundColor Cyan
        Write-Host "Status: $Status" -ForegroundColor (if ($Drive.PredictFailure){ "Red" } else { "Green" })
    }
    catch
    {
        Write-Host "[ERROR] There Was an error attemping to check drive health..." -ForegroundColor Red
    }
}