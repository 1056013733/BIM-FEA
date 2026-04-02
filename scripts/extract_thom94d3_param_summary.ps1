$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$generated = Join-Path $root "simulations/runs"
$caseDir = Join-Path $root "simulations/runs" "param_sensitivity"
$summary = Join-Path $root "results/summaries" "thom94d3_param_summary.csv"

$rows = @()
$outs = Get-ChildItem $caseDir -Recurse -Filter "*.out"
foreach ($out in $outs) {
  $name = [System.IO.Path]::GetFileNameWithoutExtension($out.Name)
  $warningCount = (Select-String -Path $out.FullName -Pattern '*** WARNING ***' -SimpleMatch | Measure-Object).Count
  $errorCount = (Select-String -Path $out.FullName -Pattern '*** ERROR ***' -SimpleMatch | Measure-Object).Count
  $lastStep = (Select-String -Path $out.FullName -Pattern 'LOAD STEP' | Select-Object -Last 1).Line
  $cpLine = (Select-String -Path $out.FullName -Pattern 'CP Time' -SimpleMatch | Select-Object -Last 1).Line
  $elapsedLine = (Select-String -Path $out.FullName -Pattern 'Elapsed Time (sec)' -SimpleMatch | Select-Object -Last 1).Line
  $rows += [PSCustomObject]@{
    case_name = $name
    warning_count = $warningCount
    error_count = $errorCount
    last_step = $lastStep
    cp_line = $cpLine
    elapsed_line = $elapsedLine
  }
}

$rows | Export-Csv -NoTypeInformation -Path $summary -Encoding UTF8
Write-Host "Wrote parameter summary: $summary"
