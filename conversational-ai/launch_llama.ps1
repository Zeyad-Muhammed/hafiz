# Internal helper: runs llama-server as a detached, logged process.
param([string]$Model, [string]$LogFile)
$root = $PSScriptRoot
$pidFile = Join-Path $root "logs\llama.pid"
New-Item -ItemType Directory -Force -Path (Split-Path $pidFile) | Out-Null
Set-Content -Path $pidFile -Value $PID
$exe = Join-Path $root "tools\llama.cpp\llama-server.exe"
& $exe -m $Model --host 127.0.0.1 --port 8080 -ngl 99 -c 4096 --no-webui 2>&1 | Out-File -FilePath $LogFile -Encoding utf8