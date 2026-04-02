$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$downloads = Join-Path $root "data/raw"
$normalized = Join-Path $root "data/processed"
New-Item -ItemType Directory -Force -Path $normalized | Out-Null

$rcProps = Join-Path $downloads "peer_rectangular_properties.txt"
$rcData = Join-Path $downloads "peer_thom94d3_force_displacement.txt"
$srcCsv = Join-Path $downloads "composite_src_c_pbc.csv"

if (-not (Test-Path $rcProps)) { throw "Missing $rcProps" }
if (-not (Test-Path $rcData)) { throw "Missing $rcData" }
if (-not (Test-Path $srcCsv)) { throw "Missing $srcCsv" }

$rcSelected = @()
$lines = Get-Content $rcProps
foreach ($line in $lines) {
  if ($line -match "Thomsen and Wallace 1994, D3") {
    $rcSelected += [PSCustomObject]@{
      specimen_id = "thom94d3"
      source = "PEER SPD rectangular_properties"
      raw_row = $line
    }
  }
}
$rcSelected | ConvertTo-Csv -NoTypeInformation | Set-Content -Path (Join-Path $normalized "peer_selected_specimen_rows.csv") -Encoding UTF8

$fdRows = @()
$fd = Get-Content $rcData
for ($i = 2; $i -lt $fd.Count; $i++) {
  $parts = $fd[$i] -split "\s+"
  if ($parts.Count -ge 2) {
    $disp = $parts[0].Trim()
    $force = $parts[1].Trim()
    if ($disp -ne "" -and $force -ne "") {
      $fdRows += [PSCustomObject]@{
        specimen_id = "thom94d3"
        displacement_mm = [double]$disp
        lateral_load_kN = [double]$force
      }
    }
  }
}
$fdRows | Export-Csv -NoTypeInformation -Path (Join-Path $normalized "peer_thom94d3_force_displacement.csv") -Encoding UTF8

$srcRows = Import-Csv $srcCsv | Select-Object -First 20
$srcRows | Export-Csv -NoTypeInformation -Path (Join-Path $normalized "composite_src_preview.csv") -Encoding UTF8

Write-Host "Prepared normalized files under $normalized"
