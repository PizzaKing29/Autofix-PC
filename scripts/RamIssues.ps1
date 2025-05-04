$Ram = Get-CimInstance Win32_PhysicalMemory | Select-Object Speed
$Ram
$RamEventErrors = Get-EventLog -LogName System -Source "MemoryDiagnostics-Results" -EntryType Error -Newest 5 -ErrorAction SilentlyContinue