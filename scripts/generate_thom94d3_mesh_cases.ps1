$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$generated = Join-Path $root "simulations/runs"
$baseMacro = Join-Path $root "results/summaries" "thom94d3_beam188.mac"

if (-not (Test-Path $baseMacro)) {
  throw "Missing base macro: $baseMacro"
}

$cases = @(
  @{ Name = "coarse"; MeshMm = 50 },
  @{ Name = "medium"; MeshMm = 30 },
  @{ Name = "fine"; MeshMm = 25 }
)

$baseText = Get-Content $baseMacro -Raw

foreach ($case in $cases) {
  $text = $baseText -replace "lesize,all,25", ("lesize,all,{0}" -f $case.MeshMm)
  $text = $text -replace "thom94d3", ("thom94d3_{0}" -f $case.Name)
  $outPath = Join-Path $root "results/summaries" ("thom94d3_{0}.mac" -f $case.Name)
  $text | Set-Content -Path $outPath -Encoding UTF8
}

Write-Host "Generated mesh-case macros in $generated"
