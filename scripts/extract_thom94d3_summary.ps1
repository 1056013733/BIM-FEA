$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$generated = Join-Path $root "simulations/runs"
$runDir = Join-Path $generated "thom94d3_run"
$outFile = Join-Path $runDir "thom94d3.out"
$summaryDir = Join-Path $root "results/summaries"
$summaryFile = Join-Path $summaryDir "thom94d3_run_summary.txt"

if (-not (Test-Path $outFile)) {
  throw "Run output not found: $outFile"
}

$lines = Get-Content $outFile
$picked = $lines | Where-Object {
  $_ -match "TIME=" -or
  $_ -match "LOAD STEP" -or
  $_ -match "SUBSTEP" -or
  $_ -match "\*\*\* ERROR \*\*\*" -or
  $_ -match "\*\*\* WARNING \*\*\*"
}

$picked | Set-Content -Path $summaryFile -Encoding UTF8
Write-Host "Wrote summary: $summaryFile"
