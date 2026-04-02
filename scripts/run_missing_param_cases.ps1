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
$env:APPDATA = $localRoaming

$jobs = @(
  "thom94d3_fc_base",
  "thom94d3_fc_p10",
  "thom94d3_fc_p20",
  "thom94d3_fy_m20",
  "thom94d3_fy_m10",
  "thom94d3_fy_base",
  "thom94d3_fy_p10",
  "thom94d3_fy_p20"
)

foreach ($job in $jobs) {
  $macro = Join-Path $caseDir ($job + ".mac")
  if (-not (Test-Path $macro)) {
    throw "Missing macro: $macro"
  }

  $runDir = Join-Path $caseDir ($job + "_fixed")
  New-Item -ItemType Directory -Force -Path $runDir | Out-Null
  $outFile = Join-Path $runDir ($job + ".out")
  & $exe -smp -np 4 -b -dir $runDir -j $job -i $macro -o $outFile
}

Write-Host "Completed missing parameter cases."
