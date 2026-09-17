param([string]$Log = "pip-install.log")
$ErrorActionPreference = "Continue"
$req = Join-Path (Split-Path $PSScriptRoot -Parent) "requirements.txt"
$py = Join-Path $PSScriptRoot "..\venv\Scripts\python.exe"
"START pip install $req" | Out-File -FilePath $Log -Encoding utf8
& $py -m pip install --disable-pip-version-check -r $req *>> $Log
"PIP_EXITCODE=$LASTEXITCODE" | Out-File -FilePath $Log -Append -Encoding utf8