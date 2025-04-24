$Drives = Get-WmiObject -Namespace root\wmi -Class MSStorageDriver_FailurePredictStatus
Clear-Host

foreach($Drive in $Drives)
{
    $Status = if ($Drive.PredictFaliure)
    {
        "⚠️ Failing"
    }
    else
    {
        "✅ Healthy"
    }
    Write-Host "Drive: $($Drive.InstanceName)" -ForegroundColor Cyan
    Write-Host "Status: $Status" -ForegroundColor (if ($Drive.PredictFaliure){ "Red" } else { "Green" })
}
powershell -NoLogo -noexit