# Windows deps entry — installs CodeGraph CLI into $env:DANMO_HOME\bin.
$ErrorActionPreference = "Stop"

$Version = if ($env:CODEGRAPH_VERSION) { $env:CODEGRAPH_VERSION.TrimStart("v") } else { "0.42.6" }
if (-not $env:DANMO_HOME -or $env:DANMO_HOME.Trim() -eq "") {
  throw "DANMO_HOME is required"
}
$BinDir = Join-Path $env:DANMO_HOME "bin"
New-Item -ItemType Directory -Force -Path $BinDir | Out-Null

$Arch = [System.Runtime.InteropServices.RuntimeInformation]::OSArchitecture.ToString().ToLowerInvariant()
switch ($Arch) {
  "arm64" {
    $Target = "aarch64-pc-windows-msvc"
    $Sha256 = "5df0543075301377e9b3d08416243066b2219e89a51c24ea8b1fe8df36450b9b"
  }
  "x64" {
    $Target = "x86_64-pc-windows-msvc"
    $Sha256 = "6785468ecab16f0ffd1cc672147f5db8fd8084d3c7f5b79d00b0063092ce6341"
  }
  default { throw "Unsupported arch: $Arch" }
}

$Asset = "codegraph-$Version-$Target.zip"
$DestBin = Join-Path $BinDir "codegraph.exe"
$DestArchive = Join-Path $BinDir "codegraph.zip"
$VersionFile = Join-Path $BinDir "CODEGRAPH_VERSION"
$BaseUrl = if ($env:CODEGRAPH_BASE_URL) { $env:CODEGRAPH_BASE_URL } else { "https://github.com/sunerpy/codegraph-rust/releases/download/v$Version" }
$Url = "$BaseUrl/$Asset"

$needFetch = $true
if ($env:CODEGRAPH_FORCE -ne "1" -and (Test-Path $DestBin) -and (Test-Path $VersionFile)) {
  $cur = (Get-Content $VersionFile -Raw).Trim()
  if ($cur -eq $Version) { $needFetch = $false }
}
if (-not $needFetch) {
  Write-Host "==> CodeGraph already installed: $DestBin (v$Version)"
  exit 0
}

$Tmp = Join-Path ([System.IO.Path]::GetTempPath()) ("codegraph-" + [guid]::NewGuid().ToString("n"))
New-Item -ItemType Directory -Force -Path $Tmp | Out-Null
try {
  $Archive = Join-Path $Tmp $Asset
  Write-Host "==> Downloading CodeGraph-Rust v$Version ($Target)"
  Write-Host "    $Url"
  Invoke-WebRequest -Uri $Url -OutFile $Archive -UseBasicParsing
  $Got = (Get-FileHash -Algorithm SHA256 -Path $Archive).Hash.ToLowerInvariant()
  if ($Got -ne $Sha256.ToLowerInvariant()) {
    throw "sha256 mismatch: want $Sha256 got $Got"
  }
  Copy-Item -Force $Archive $DestArchive
  $Out = Join-Path $Tmp "out"
  Expand-Archive -Path $DestArchive -DestinationPath $Out -Force
  $Found = Get-ChildItem -Path $Out -Recurse -Filter "codegraph.exe" | Select-Object -First 1
  if (-not $Found) { throw "codegraph.exe not found in archive" }
  Copy-Item -Force $Found.FullName $DestBin
  Set-Content -Path $VersionFile -Value $Version -NoNewline
  Write-Host "==> Installed $DestBin (v$Version)"
} finally {
  Remove-Item -Recurse -Force $Tmp -ErrorAction SilentlyContinue
}
