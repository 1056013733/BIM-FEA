$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$generated = Join-Path $root "simulations/runs"
$summaryPath = Join-Path $root "results/summaries" "thom94d3_mesh_summary.csv"

$rows = @()
foreach ($name in @("coarse", "medium", "fine")) {
  $outFile = Join-Path $root "simulations/runs" ("thom94d3_{0}_run\\thom94d3_{0}.out" -f $name)
  if (-not (Test-Path $outFile)) {
    continue
  }

  $item = Get-Item $outFile
  $tail = Get-Content $outFile | Select-Object -Last 400
  $lastStep = ($tail | Select-String -Pattern 'LOAD STEP').Line | Select-Object -Last 1
  $lastTime = ($tail | Select-String -Pattern 'TIME =').Line | Select-Object -Last 1
  $warnings = (Select-String -Path $outFile -Pattern '*** WARNING ***' -SimpleMatch | Measure-Object).Count
  $errors = (Select-String -Path $outFile -Pattern '*** ERROR ***' -SimpleMatch | Measure-Object).Count

  $rows += [PSCustomObject]@{
    case_name = $name
    out_file = $outFile
    bytes = $item.Length
    last_write_time = $item.LastWriteTime
    last_load_step_line = $lastStep
    last_time_line = $lastTime
    warning_count = $warnings
    error_count = $errors
  }
}

$rows | Export-Csv -NoTypeInformation -Path $summaryPath -Encoding UTF8
Write-Host "Wrote mesh summary: $summaryPath"
