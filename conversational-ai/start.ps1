# start.ps1 - Launch the local conversational AI
#   .\start.ps1             -> CLI mode (speak into mic)
#   .\start.ps1 -Web        -> Web UI at http://127.0.0.1:5000
param([switch]$Web)
$ErrorActionPreference = "Stop"
$root = $PSScriptRoot
Set-Location $root

function Need($msg) { Write-Host "[setup] $msg" -ForegroundColor Yellow }

# ---- sanity checks -----------------------------------------------------
$server = Join-Path $root "tools\llama.cpp\llama-server.exe"
$model  = Join-Path $root "models\Llama-3.2-3B-Instruct-Q4_K_M.gguf"
if (-not (Test-Path $server)) { Need "llama.cpp is missing. Run:  .\setup.ps1"; exit 1 }
if (-not (Test-Path $model))  { Need "the LLM model is missing. Run:  .\setup.ps1"; exit 1 }
if (-not (Test-Path (Join-Path $root "venv\Scripts\python.exe"))) { Need "venv missing. Run:  .\setup.ps1"; exit 1 }

# CUDA runtime DLLs must live next to llama-server.exe
$cudartDir = Join-Path $root "tools\cudart"
$cublas = Join-Path (Split-Path $server) "cublas64_12.dll"
if (-not (Test-Path $cublas) -and (Test-Path (Join-Path $cudartDir "cublas64_12.dll"))) {
    Copy-Item (Join-Path $cudartDir "*.dll") (Split-Path $server) -Force
}

# ---- start llama.cpp server (if not already up) -----------------------
$health = "http://127.0.0.1:8080/health"
$up = $false
try { $r = Invoke-WebRequest -Uri $health -UseBasicParsing -TimeoutSec 3; $up = $r.StatusCode -eq 200 } catch {}
if (-not $up) {
    Write-Host "[setup] starting llama.cpp server..." -ForegroundColor Cyan
    $logDir = Join-Path $root "logs"; New-Item -ItemType Directory -Force -Path $logDir | Out-Null
    $p = Start-Process -FilePath $server `
        -ArgumentList "-m", ("`"$model`""), "--host", "127.0.0.1", "--port", "8080", `
                      "-ngl", "99", "-c", "4096", "--no-webui" `
        -RedirectStandardOutput (Join-Path $logDir "llama-server.out.log") `
        -RedirectStandardError  (Join-Path $logDir "llama-server.err.log") `
        -WindowStyle Hidden -PassThru
    Set-Content -Path (Join-Path $root "logs\llama.pid") -Value $p.Id
    $t = 0
    while ($t -lt 180) {
        Start-Sleep -Seconds 2; $t += 2
        try { $r = Invoke-WebRequest -Uri $health -UseBasicParsing -TimeoutSec 3
              if ($r.StatusCode -eq 200) { $up = $true; break } } catch {}
        if ($p.HasExited) { Write-Host "[setup] llama.cpp exited! See logs\llama-server.err.log" -ForegroundColor Red
                            Get-Content (Join-Path $logDir "llama-server.err.log") -Tail 15; exit 1 }
    }
    if (-not $up) { Write-Host "[setup] llama.cpp did not respond in time" -ForegroundColor Red; exit 1 }
    Write-Host "[setup] llama.cpp server ready." -ForegroundColor Green
} else {
    Write-Host "[setup] llama.cpp server already running." -ForegroundColor Green
}

# ---- launch app --------------------------------------------------------
$py = Join-Path $root "venv\Scripts\python.exe"
if ($Web) {
    Write-Host "[setup] Web UI: http://127.0.0.1:5000  (Ctrl+C to stop)" -ForegroundColor Green
    & $py -m server.app
} else {
    & $py -m server.cli
}