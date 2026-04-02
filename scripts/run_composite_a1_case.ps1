$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$generated = Join-Path $root "simulations/runs"
$macro = Join-Path $root "results/summaries" "composite_A1_beam188.mac"
$runDir = Join-Path $root "results/summaries" "composite_A1_run"
New-Item -ItemType Directory -Force -Path $runDir | Out-Null

$exe = "C:\ansys\ANSYS Inc\v251\ansys\bin\winx64\MAPDL.exe"
if (-not (Test-Path $exe)) {
  throw "MAPDL.exe not found at expected path: $exe"
}

$outFile = Join-Path $runDir "composite_A1.out"
$errFile = Join-Path $runDir "composite_A1.err"
& $exe -b -dir $runDir -j compA1 -i $macro -o $outFile 2> $errFile

Write-Host "Composite case complete."
Write-Host "Output: $outFile"
