$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$generated = Join-Path $root "simulations/runs"
New-Item -ItemType Directory -Force -Path $generated | Out-Null

$macroPath = Join-Path $root "results/summaries" "composite_A1_beam188.mac"
$metaPath = Join-Path $root "results/summaries" "composite_A1_metadata.csv"

$lines = @(
  "/clear",
  "/prep7",
  "! Public composite benchmark starter case",
  "! Source: Composite Column Database, Stevens 1965, A1",
  "! Units used consistently here: in, kip, ksi",
  "",
  "*set,B_in,6.5",
  "*set,H_in,7.0",
  "*set,L_in,13.0",
  "*set,fc_ksi,2.32",
  "*set,Fy_ksi,41.1",
  "*set,Pexp_kip,352.0",
  "",
  "et,1,beam188",
  "mp,ex,1,4000",
  "mp,prxy,1,0.2",
  "",
  "sectype,1,beam,rect",
  "secdata,B_in,H_in",
  "",
  "k,1,0,0,0",
  "k,2,L_in,0,0",
  "l,1,2",
  "lesize,all,0.5",
  "lmesh,all",
  "",
  "d,1,all,0",
  "",
  "/solu",
  "antype,static",
  "nlgeom,on",
  "autots,on",
  "nsubst,20,100,1",
  "",
  "! Monotonic load ramp to the reported experimental peak load",
  "f,2,fy,-Pexp_kip",
  "solve",
  "finish"
)

$lines | Set-Content -Path $macroPath -Encoding UTF8

@(
  "field,value,units"
  "author,Stevens 1965,"
  "specimen,A1,"
  "B,6.5,in"
  "H,7.0,in"
  "L,13.0,in"
  "fc,2.32,ksi"
  "Fy,41.1,ksi"
  "Pexp,352.0,kip"
) | Set-Content -Path $metaPath -Encoding UTF8

Write-Host "Generated composite macro: $macroPath"
Write-Host "Generated composite metadata: $metaPath"
