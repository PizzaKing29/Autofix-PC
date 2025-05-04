<# Security Enhancements

- Check for known malware domains in hosts file
- Run Defender full scan instead of quick scan
- Detect and disable suspicious startup items #>
$HostsDir = "C:\Windows\System32\drivers\etc\hosts"

# Known Suspicous Domains
$SuspiciousDomains = @(
    "example-malicious.com",
    "malware-redirect.com",
    "bad-website.org"
    )
    
function CheckDomains ($Line, $Domain)
{
        
    if ($Line -match $domain)
    {
        Write-Host "Suspicious entry detected: $Line" -ForegroundColor Red
        $FoundSuspicious = $true
    }
}

if (Test-Path $HostsDir) # Checks if the Hosts Directory Exists
{
    $HostsContent = Get-Content -Path $HostsDir | Where-Object { $_ -notmatch '^\s*#' -and $_.Trim() -ne "" }

    if ($HostsContent.Count -eq 0)
    {
        Write-Host "No suspicious entries found in hosts file." -ForegroundColor Green
    }
    else
    {
        Write-Host "Checking for suspicious entries in hosts file..." -ForegroundColor Yellow
        $FoundSuspicious = $false

        foreach ($Line in $HostsContent)
        {
            # Check for any suspicious domains or IPs
            foreach ($Domain in $SuspiciousDomains)
            {
                CheckDomains $Line $Domain
            }
        }
        if (-not $FoundSuspicious)
        {
            Write-Host "No suspicious domains found in hosts file." -ForegroundColor Green
        }
    }
}
else
{
    Write-Host "The hosts file wasnt found." -ForegroundColor Red
}

powershell -NoLogo -noexit