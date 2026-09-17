# setup.ps1 - One-time setup: downloads binaries + model, builds venv, installs deps.
# Re-running is safe (idempotent).  Usage:  .\setup.ps1
$ErrorActionPreference = "Continue"
$root = $PSScriptRoot
$models = Join-Path $root "models"
$tools  = Join-Path $root "tools"
New-Item -ItemType Directory -Force -Path $models, $tools | Out-Null
Set-Location $root

function Say($m)   { Write-Host "[setup] $m" -ForegroundColor Cyan }
function Done($m)  { Write-Host "[setup] $m" -ForegroundColor Green }
function WARN($m)  { Write-Host "[setup] $m" -ForegroundColor Yellow }
function Fetch($url, $out, $what) {
    if (Test-Path $out) { Done "$what already present."; return $true }
    Say "downloading $what ..."
    & curl.exe -sS -L --retry 3 -o $out $url
    if ($LASTEXITCODE -ne 0) { WARN "download failed for $what (exit $LASTEXITCODE)"; return $false }
    Done "$what downloaded."
    return $true
}

# 1. llama.cpp binaries (CUDA build)
$llamaZip   = Join-Path $models "llama.cpp.zip"
$cudartZip  = Join-Path $models "cudart.zip"
$llamaBin   = Join-Path $tools "llama.cpp"
$cudartBin  = Join-Path $tools "cudart"
$gguf       = Join-Path $models "Llama-3.2-3B-Instruct-Q4_K_M.gguf"

$llamaOk = Fetch "https://github.com/ggml-org/llama.cpp/releases/download/b10951/llama-b10951-bin-win-cuda-12.4-x64.zip" $llamaZip "llama.cpp (CUDA binaries, 242 MB)"
if ($llamaOk) {
    if (-not (Test-Path (Join-Path $llamaBin "llama-server.exe"))) {
        Say "extracting llama.cpp..."
        Expand-Archive -Path $llamaZip -DestinationPath $llamaBin -Force
        Done "llama.cpp extracted."
    } else { Done "llama.cpp already extracted." }
}

$cudartOk = Fetch "https://github.com/ggml-org/llama.cpp/releases/download/b10951/cudart-llama-bin-win-cuda-12.4-x64.zip" $cudartZip "CUDA runtime (373 MB)"
if ($cudartOk) {
    if (-not (Test-Path (Join-Path $cudartBin "cublas64_12.dll"))) {
        Say "extracting CUDA runtime..."
        New-Item -ItemType Directory -Force -Path $cudartBin | Out-Null
        Expand-Archive -Path $cudartZip -DestinationPath $cudartBin -Force
        Done "CUDA runtime extracted."
    } else { Done "CUDA runtime already extracted." }
}

# 2. LLM model
$mOk = Fetch "https://huggingface.co/bartowski/Llama-3.2-3B-Instruct-GGUF/resolve/main/Llama-3.2-3B-Instruct-Q4_K_M.gguf" $gguf "LLM model (1.9 GB)"
if (-not $mOk) { WARN "Model download failed; you can retry later or download manually." }

# 3. Python venv + dependencies
if (-not (Test-Path (Join-Path $root "venv\Scripts\python.exe"))) {
    Say "creating Python virtual environment..."
    python -m venv venv
    Done "venv created."
} else { Done "venv already exists." }

$py = Join-Path $root "venv\Scripts\python.exe"
Say "installing Python packages (coqui-tts pulls PyTorch; this is the longest step)..."
& $py -m pip install --disable-pip-version-check -r (Join-Path $root "requirements.txt")

Done "Setup complete. Run:"
Done "    .\start.ps1       (CLI, speak into mic)"
Done "    .\start.ps1 -Web  (web UI at http://127.0.0.1:5000)"