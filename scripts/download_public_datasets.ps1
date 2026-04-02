$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$downloads = Join-Path $root "data/raw"
New-Item -ItemType Directory -Force -Path $downloads | Out-Null

$targets = @(
  @{
    Name = "peer_rectangular_properties.txt"
    Url = "http://nisee.berkeley.edu/spd/rectangular_properties.txt"
  },
  @{
    Name = "peer_search.html"
    Url = "http://nisee.berkeley.edu/spd/search.html"
  },
  @{
    Name = "peer_thom94d3_metadata.html"
    Url = "http://nisee.berkeley.edu/spd/servlet/display?format=html&id=211"
  },
  @{
    Name = "peer_thom94d3_force_displacement.txt"
    Url = "http://depts.washington.edu/columdat/rectcol/txfiles/thom94d3.txt"
  },
  @{
    Name = "composite_src_c_pbc.csv"
    Url = "https://raw.githubusercontent.com/denavit/Composite-Column-Database/master/SRC_C%2BPBC.csv"
  },
  @{
    Name = "composite_rcft_c_pbc.csv"
    Url = "https://raw.githubusercontent.com/denavit/Composite-Column-Database/master/RCFT_C%2BPBC.csv"
  },
  @{
    Name = "composite_ccft_c_pbc.csv"
    Url = "https://raw.githubusercontent.com/denavit/Composite-Column-Database/master/CCFT_C%2BPBC.csv"
  },
  @{
    Name = "composite_repo_readme.md"
    Url = "https://raw.githubusercontent.com/denavit/Composite-Column-Database/master/README.md"
  }
)

$checksumRows = @()

foreach ($target in $targets) {
  $outFile = Join-Path $downloads $target.Name
  & curl.exe --fail --location --silent --show-error --insecure --ssl-no-revoke $target.Url --output $outFile
  $hash = Get-FileHash -Path $outFile -Algorithm SHA256
  $checksumRows += [PSCustomObject]@{
    name = $target.Name
    url = $target.Url
    sha256 = $hash.Hash.ToLower()
    local_file = $outFile
  }
}

$checksumPath = Join-Path $downloads "checksums.json"
$checksumRows | ConvertTo-Json -Depth 3 | Set-Content -Path $checksumPath -Encoding UTF8
Write-Host "Downloaded $($targets.Count) files to $downloads"
Write-Host "Checksum manifest: $checksumPath"
