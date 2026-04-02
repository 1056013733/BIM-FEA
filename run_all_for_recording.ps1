$ErrorActionPreference = "Stop"
$root = $PSScriptRoot
$scriptsDir = Join-Path $root "scripts"

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host " ANSYS Reproduction Workflow (Recording)  " -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Press enter to start Step 1: Baseline model run..." -ForegroundColor Yellow
Read-Host
& (Join-Path $scriptsDir "run_thom94d3_ansys.ps1")
Write-Host "Step 1 Completed." -ForegroundColor Green
Write-Host ""

Write-Host "Press enter to start Step 2: Mesh sensitivity study..." -ForegroundColor Yellow
Read-Host
Write-Host "Generating mesh cases..."
& (Join-Path $scriptsDir "generate_thom94d3_mesh_cases.ps1")
Write-Host "Running mesh cases..."
& (Join-Path $scriptsDir "run_thom94d3_mesh_cases.ps1")
Write-Host "Extracting mesh summary..."
& (Join-Path $scriptsDir "extract_thom94d3_mesh_summary.ps1")
Write-Host "Step 2 Completed." -ForegroundColor Green
Write-Host ""

Write-Host "Press enter to start Step 3: Material-parameter sensitivity study..." -ForegroundColor Yellow
Read-Host
Write-Host "Generating parameter sensitivity cases..."
& (Join-Path $scriptsDir "generate_thom94d3_param_sensitivity.ps1")
Write-Host "Running parameter sensitivity cases..."
& (Join-Path $scriptsDir "run_thom94d3_param_sensitivity.ps1")
Write-Host "Extracting parameter summary..."
& (Join-Path $scriptsDir "extract_thom94d3_param_summary.ps1")
Write-Host "Step 3 Completed." -ForegroundColor Green
Write-Host ""

Write-Host "Press enter to extract global summary and finish..." -ForegroundColor Yellow
Read-Host
Write-Host "Extracting global summary..."
if (Test-Path (Join-Path $scriptsDir "extract_thom94d3_summary.ps1")) {
    & (Join-Path $scriptsDir "extract_thom94d3_summary.ps1")
}

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host " Workflow full reproduction finished! " -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
