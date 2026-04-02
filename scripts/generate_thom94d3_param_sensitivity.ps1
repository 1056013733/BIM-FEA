$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$generated = Join-Path $root "simulations/runs"
$baseMacro = Join-Path $root "results/summaries" "thom94d3_beam188.mac"
$outDir = Join-Path $root "results/summaries" "param_sensitivity"
New-Item -ItemType Directory -Force -Path $outDir | Out-Null

if (-not (Test-Path $baseMacro)) {
  throw "Missing base macro: $baseMacro"
}

$baseText = Get-Content $baseMacro -Raw

$cases = @(
  @{ Param = "fc"; Label = "m20"; Scale = 0.8 },
  @{ Param = "fc"; Label = "m10"; Scale = 0.9 },
  @{ Param = "fc"; Label = "base"; Scale = 1.0 },
  @{ Param = "fc"; Label = "p10"; Scale = 1.1 },
  @{ Param = "fc"; Label = "p20"; Scale = 1.2 },
  @{ Param = "E";  Label = "m20"; Scale = 0.8 },
  @{ Param = "E";  Label = "m10"; Scale = 0.9 },
  @{ Param = "E";  Label = "base"; Scale = 1.0 },
  @{ Param = "E";  Label = "p10"; Scale = 1.1 },
  @{ Param = "E";  Label = "p20"; Scale = 1.2 },
  @{ Param = "fy"; Label = "m20"; Scale = 0.8 },
  @{ Param = "fy"; Label = "m10"; Scale = 0.9 },
  @{ Param = "fy"; Label = "base"; Scale = 1.0 },
  @{ Param = "fy"; Label = "p10"; Scale = 1.1 },
  @{ Param = "fy"; Label = "p20"; Scale = 1.2 }
)

foreach ($case in $cases) {
  $text = $baseText
  $tag = "thom94d3_{0}_{1}" -f $case.Param, $case.Label
  $text = $text -replace "thom94d3", $tag

  switch ($case.Param) {
    "fc" {
      $text = $text -replace "\*set,fc_mpa,71.2", ("*set,fc_mpa,{0}" -f (71.2 * $case.Scale).ToString("0.####", [System.Globalization.CultureInfo]::InvariantCulture))
    }
    "E" {
      $text = $text -replace "\*set,E_scale,1.0", ("*set,E_scale,{0}" -f $case.Scale.ToString("0.####", [System.Globalization.CultureInfo]::InvariantCulture))
    }
    "fy" {
      $text = $text -replace "\*set,fy_mpa,414", ("*set,fy_mpa,{0}" -f (414 * $case.Scale).ToString("0.####", [System.Globalization.CultureInfo]::InvariantCulture))
    }
  }

  $path = Join-Path $outDir ("{0}.mac" -f $tag)
  $text | Set-Content -Path $path -Encoding UTF8
}

Write-Host "Generated parameter sensitivity macros in $outDir"
