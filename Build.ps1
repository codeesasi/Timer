# ============================================================
#  Build.ps1 — Compile Timer.ps1 into Timer.exe using ps2exe
# ============================================================

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$source    = Join-Path $scriptDir "Timer.ps1"
$output    = Join-Path $scriptDir "Timer.exe"

# Check if ps2exe is installed
if (-not (Get-Module -ListAvailable -Name ps2exe)) {
    Write-Host "[*] Installing ps2exe module..." -ForegroundColor Cyan
    Install-Module -Name ps2exe -Scope CurrentUser -Force -AllowClobber
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Building Timer.exe" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "[*] Source:  $source" -ForegroundColor Gray
Write-Host "[*] Output:  $output" -ForegroundColor Gray
Write-Host ""

# Compile
try {
    Invoke-PS2EXE -InputFile $source `
                  -OutputFile $output `
                  -NoConsole `
                  -Title "Focus Timer" `
                  -Description "Focus Timer with Logout, Shutdown, and Hypermode" `
                  -Company "NoFap" `
                  -Version "1.0.0.0" `
                  -Copyright "(c) 2026" `
                  -RequireAdmin

    if (Test-Path $output) {
        Write-Host ""
        Write-Host "[✓] Build successful!" -ForegroundColor Green
        Write-Host "[✓] Output: $output" -ForegroundColor Green
        Write-Host "[✓] Size: $([math]::Round((Get-Item $output).Length / 1KB, 1)) KB" -ForegroundColor Green
        Write-Host ""
    }
} catch {
    Write-Host ""
    Write-Host "[✗] Build failed: $_" -ForegroundColor Red
    Write-Host ""
    exit 1
}
