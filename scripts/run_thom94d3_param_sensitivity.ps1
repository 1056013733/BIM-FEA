$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$generated = Join-Path $root "simulations/runs"
$caseDir = Join-Path $root "results/summaries" "param_sensitivity"
$exe = "C:\ansys\ANSYS Inc\v251\ansys\bin\winx64\ANSYS251.exe"
$localAppData = Join-Path $root ".ansys_appdata"
$localRoaming = Join-Path $localAppData "Roaming"
$localAnsys = Join-Path $localRoaming "Ansys"

if (-not (Test-Path $exe)) {
  throw "ANSYS251.exe not found at expected path: $exe"
}

New-Item -ItemType Directory -Force -Path $localAnsys | Out-Null

$macros = Get-ChildItem $caseDir -Filter "*.mac" | Sort-Object Name
foreach ($macro in $macros) {
  $job = [System.IO.Path]::GetFileNameWithoutExtension($macro.Name)
  $runDir = Join-Path $caseDir $job
  New-Item -ItemType Directory -Force -Path $runDir | Out-Null
  $outFile = Join-Path $runDir "$job.out"
  # Let ANSYS own the .err file; external stderr redirection can lock it.
  $env:APPDATA = $localRoaming
  & $exe -smp -np 4 -b -dir $runDir -j $job -i $macro.FullName -o $outFile
}

Write-Host "Completed parameter sensitivity runs."
