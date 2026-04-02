$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$normalized = Join-Path $root "data/processed"
$generated = Join-Path $root "simulations/runs"
New-Item -ItemType Directory -Force -Path $generated | Out-Null

$historyPath = Join-Path $normalized "peer_thom94d3_force_displacement.csv"
if (-not (Test-Path $historyPath)) {
  throw "Missing normalized history: $historyPath"
}

$history = Import-Csv $historyPath
$npts = $history.Count

$sb = New-Object System.Text.StringBuilder
[void]$sb.AppendLine("/clear")
[void]$sb.AppendLine("/prep7")
[void]$sb.AppendLine("! Generated from PEER SPD public data")
[void]$sb.AppendLine("! Specimen: Thomsen and Wallace 1994, D3")
[void]$sb.AppendLine("! Geometry from PEER rectangular properties table")
[void]$sb.AppendLine("")
[void]$sb.AppendLine("*set,B_mm,152.4")
[void]$sb.AppendLine("*set,H_mm,152.4")
[void]$sb.AppendLine("*set,L_mm,596.9")
[void]$sb.AppendLine("*set,fc_mpa,71.2")
[void]$sb.AppendLine("*set,axial_kN,331")
[void]$sb.AppendLine("*set,cover_mm,44.5")
[void]$sb.AppendLine("*set,npts,$npts")
[void]$sb.AppendLine("")
[void]$sb.AppendLine("! Review before production use:")
[void]$sb.AppendLine("! 1. Replace simplified concrete modulus with your calibrated constitutive model.")
[void]$sb.AppendLine("! 2. Confirm reinforcement layout and section definition against the source paper.")
[void]$sb.AppendLine("! 3. Decide whether to keep BEAM188 or upgrade to a detailed solid/fiber model.")
[void]$sb.AppendLine("")
[void]$sb.AppendLine("et,1,beam188")
[void]$sb.AppendLine("mp,ex,1,4.2e10")
[void]$sb.AppendLine("mp,prxy,1,0.2")
[void]$sb.AppendLine("")
[void]$sb.AppendLine("sectype,1,beam,rect")
[void]$sb.AppendLine("secdata,B_mm,H_mm")
[void]$sb.AppendLine("")
[void]$sb.AppendLine("k,1,0,0,0")
[void]$sb.AppendLine("k,2,L_mm,0,0")
[void]$sb.AppendLine("l,1,2")
[void]$sb.AppendLine("lesize,all,,,25")
[void]$sb.AppendLine("lmesh,all")
[void]$sb.AppendLine("")
[void]$sb.AppendLine("d,1,all,0")
[void]$sb.AppendLine("")
[void]$sb.AppendLine("/solu")
[void]$sb.AppendLine("antype,static")
[void]$sb.AppendLine("nlgeom,on")
[void]$sb.AppendLine("autots,on")
[void]$sb.AppendLine("nsubst,10,100,1")
[void]$sb.AppendLine("")
[void]$sb.AppendLine("! Apply constant axial compression placeholder at node 2")
[void]$sb.AppendLine("f,2,fx,-axial_kN")
[void]$sb.AppendLine("")
[void]$sb.AppendLine("*dim,disp_hist,array,npts")
[void]$sb.AppendLine("*dim,load_hist,array,npts")

for ($i = 0; $i -lt $history.Count; $i++) {
  $idx = $i + 1
  $disp = [double]$history[$i].displacement_mm
  $load = [double]$history[$i].lateral_load_kN
  [void]$sb.AppendLine(("disp_hist({0})={1}" -f $idx, $disp.ToString("G17", [System.Globalization.CultureInfo]::InvariantCulture)))
  [void]$sb.AppendLine(("load_hist({0})={1}" -f $idx, $load.ToString("G17", [System.Globalization.CultureInfo]::InvariantCulture)))
}

[void]$sb.AppendLine("")
[void]$sb.AppendLine("! Example displacement-controlled replay of the public cyclic history")
[void]$sb.AppendLine("*do,i,1,npts")
[void]$sb.AppendLine("  d,2,uy,disp_hist(i)")
[void]$sb.AppendLine("  solve")
[void]$sb.AppendLine("*enddo")
[void]$sb.AppendLine("finish")

$macroPath = Join-Path $root "results/summaries" "thom94d3_beam188.mac"
$sb.ToString() | Set-Content -Path $macroPath -Encoding UTF8

$metaPath = Join-Path $root "results/summaries" "thom94d3_metadata.csv"
@(
  "field,value,units"
  "specimen,Thomsen and Wallace 1994 D3,"
  "B,152.4,mm"
  "H,152.4,mm"
  "L,596.9,mm"
  "fc,71.2,MPa"
  "axial_load,331,kN"
  "cover_parallel_or_perpendicular,44.5,mm"
  "history_points,$npts,count"
) | Set-Content -Path $metaPath -Encoding UTF8

Write-Host "Generated APDL macro: $macroPath"
Write-Host "Generated metadata table: $metaPath"
