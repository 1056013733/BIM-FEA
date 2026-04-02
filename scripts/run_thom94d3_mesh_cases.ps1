$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$generated = Join-Path $root "simulations/runs"
$exe = "C:\ansys\ANSYS Inc\v251\ansys\bin\winx64\MAPDL.exe"

if (-not (Test-Path $exe)) {
  throw "MAPDL.exe not found at expected path: $exe"
}

$cases = @("coarse", "medium", "fine")

foreach ($name in $cases) {
  $macro = Join-Path $root "results/summaries" ("thom94d3_{0}.mac" -f $name)
  if (-not (Test-Path $macro)) {
    throw "Missing macro: $macro"
  }

  $runDir = Join-Path $root "results/summaries" ("thom94d3_{0}_run" -f $name)
  New-Item -ItemType Directory -Force -Path $runDir | Out-Null

  $outFile = Join-Path $runDir ("thom94d3_{0}.out" -f $name)
  $errFile = Join-Path $runDir ("thom94d3_{0}.err" -f $name)
  $job = "thd3_$name"

  & $exe -b -dir $runDir -j $job -i $macro -o $outFile 2> $errFile
}

Write-Host "Completed mesh-case runs."
