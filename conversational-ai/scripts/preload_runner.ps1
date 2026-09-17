param([string]$Log = "preload.log")
$root = Split-Path $PSScriptRoot -Parent
$py = Join-Path $root "venv\Scripts\python.exe"
$script = Join-Path $PSScriptRoot "preload_models.py"
& $py $script *>> (Join-Path $root $Log)
"PRELOAD_EXITCODE=$LASTEXITCODE" | Out-File -FilePath (Join-Path $root $Log) -Append -Encoding utf8