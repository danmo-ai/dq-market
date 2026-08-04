# Windows uninstall entry — removes CodeGraph CLI from $env:DANMO_HOME\bin.
$ErrorActionPreference = "Stop"

if (-not $env:DANMO_HOME -or $env:DANMO_HOME.Trim() -eq "") {
  throw "DANMO_HOME is required"
}
$BinDir = Join-Path $env:DANMO_HOME "bin"
$removed = $false
foreach ($name in @("codegraph.exe", "codegraph", "codegraph.zip", "codegraph.tar.gz", "CODEGRAPH_VERSION")) {
  $p = Join-Path $BinDir $name
  if (Test-Path $p) {
    Remove-Item -Force $p
    Write-Host "removed $p"
    $removed = $true
  }
}
if (-not $removed) {
  Write-Host "==> No CodeGraph artifacts under $BinDir"
} else {
  Write-Host "==> CodeGraph cleanup done"
}
