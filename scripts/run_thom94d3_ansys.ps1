$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$generated = Join-Path $root "simulations/runs"
$macro = Join-Path $root "results/summaries" "thom94d3_beam188.mac"
$runDir = Join-Path $root "results/summaries" "thom94d3_run"
New-Item -ItemType Directory -Force -Path $runDir | Out-Null

$candidates = @(
  "C:\ansys\ANSYS Inc\v251\ansys\bin\winx64\MAPDL.exe",
  "C:\ansys\ANSYS Inc\v251\ansys\bin\winx64\ANSYS251.exe",
  "C:\ansys\ANSYS Inc\v251\Framework\bin\Win64\RunWB2.exe",
  "C:\Program Files\ANSYS Inc\v251\ansys\bin\winx64\MAPDL.exe",
  "C:\Program Files\ANSYS Inc\v251\ansys\bin\winx64\ansys251.exe",
  "C:\Program Files\ANSYS Inc\v251\commonfiles\launcherQT\source\bin\winx64\LauncherQt.exe"
)

$exe = $candidates | Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $exe) {
  throw "No ANSYS solver executable found. Install MAPDL/Mechanical first."
}

if ($exe -like "*LauncherQt.exe") {
  throw "LauncherQt was found, but this script expects a direct MAPDL executable."
}

$outFile = Join-Path $runDir "thom94d3.out"
$errFile = Join-Path $runDir "thom94d3.err"

& $exe -b -dir $runDir -j thom94d3 -i $macro -o $outFile 2> $errFile

Write-Host "ANSYS run complete."
Write-Host "Output: $outFile"
Write-Host "Errors: $errFile"
