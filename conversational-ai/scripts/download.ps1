param(
    [Parameter(Mandatory=$true)][string]$Url,
    [Parameter(Mandatory=$true)][string]$Out,
    [string]$Log = ""
)
$ErrorActionPreference = "Continue"
if ($Log -eq "") { $Log = "$Out.log" }
"START $Url -> $Out" | Out-File -FilePath $Log -Encoding utf8
& curl.exe -sS -L -o $Out $Url 2>&1 | Out-File -FilePath $Log -Append -Encoding utf8
"EXITCODE=$LASTEXITCODE" | Out-File -FilePath $Log -Append -Encoding utf8