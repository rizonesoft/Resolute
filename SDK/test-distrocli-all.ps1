# Test DistroCLI by generating documentation for all Resolute programs
# This script tests the DistroCLI tool by running docs generation for all 13 programs

$DistroCLI = "R:\Resolute\SDK\DistroCLI.exe"
$Programs = @(
    "BiosCodes",
    "Chromin",
    "ComIntRep",
    "DistroCLI",
    "Distro",
    "DVDRepair",
    "Edgemin",
    "Firemin",
    "MemBoost",
    "Ownership",
    "PixRepair",
    "ReBar",
    "Rescue",
    "Resolute",
    "USBRepair",
    "Watermin"
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "DistroCLI Test - Documentation Generation" -ForegroundColor Cyan
Write-Host "Testing all $($Programs.Count) programs" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$SuccessCount = 0
$FailCount = 0
$Results = @()

foreach ($Program in $Programs) {
    $SniFile = "R:\Resolute\SDK\Concrete\$Program\$Program.sni"
    
    if (Test-Path $SniFile) {
        Write-Host "[$Program] Generating docs..." -ForegroundColor Yellow
        
        $Output = & $DistroCLI docs $SniFile 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "[$Program] SUCCESS" -ForegroundColor Green
            $SuccessCount++
            $Results += [PSCustomObject]@{
                Program = $Program
                Status = "SUCCESS"
                Output = $Output -join "`n"
            }
        } else {
            Write-Host "[$Program] FAILED" -ForegroundColor Red
            Write-Host "Error: $Output" -ForegroundColor Red
            $FailCount++
            $Results += [PSCustomObject]@{
                Program = $Program
                Status = "FAILED"
                Output = $Output -join "`n"
            }
        }
    } else {
        Write-Host "[$Program] SKIPPED - SNI file not found" -ForegroundColor Magenta
        $Results += [PSCustomObject]@{
            Program = $Program
            Status = "SKIPPED"
            Output = "SNI file not found: $SniFile"
        }
    }
    
    Write-Host ""
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Summary" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Total Programs: $($Programs.Count)" -ForegroundColor White
Write-Host "Successful: $SuccessCount" -ForegroundColor Green
Write-Host "Failed: $FailCount" -ForegroundColor $(if ($FailCount -gt 0) { "Red" } else { "Green" })
Write-Host ""

# Show detailed results
$Results | Format-Table -Property Program, Status -AutoSize

Write-Host ""
Write-Host "Test completed!" -ForegroundColor Cyan
