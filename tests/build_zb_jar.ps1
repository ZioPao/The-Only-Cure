<#
.SYNOPSIS
  Builds ZombieBuddy from master (3.0.0-beta1) for the ZBSpec harness, on Windows.

.DESCRIPTION
  Mirrors dev_stuff/tests/build_zb_jar.sh. The released v2.3.4 jar is not
  compatible with ZBSpec on Build 42.21 (Linux SIGINFO abort, JDK 25
  LuaHandler NPE, and below the required ZBVersionMin), so we build master.

  Requires: git, a JDK 25 (auto-downloaded if absent), and network access.

.EXAMPLE
  dev_stuff\tests\build_zb_jar.ps1 "C:\Program Files (x86)\Steam\steamapps\common\ProjectZomboid"
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$GamePath
)

$ErrorActionPreference = 'Stop'

$ZbRepo = 'https://github.com/zed-0xff/ZombieBuddy.git'
$GradleVersion = '9.3.1'
$JdkVersion = '25.30.17-ca-jdk25.0.1'
$GradleUrl = "https://services.gradle.org/distributions/gradle-$GradleVersion-bin.zip"
$JdkUrl = "https://cdn.azul.com/zulu/bin/zulu$JdkVersion-win_x64.zip"

if (-not (Test-Path $GamePath)) { throw "game folder not found: $GamePath" }

$Work = if ($env:WORK) { $env:WORK } else { Join-Path $env:TEMP 'zbbuild' }
New-Item -ItemType Directory -Force -Path $Work | Out-Null
Set-Location $Work

# --- JDK ---
$JdkHome = $env:JAVA_HOME
if (-not $JdkHome -or -not (Test-Path (Join-Path $JdkHome 'bin\javac.exe'))) {
    $existing = Get-ChildItem -Path $Work -Directory -Filter 'zulu25*' -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($existing) {
        $JdkHome = $existing.FullName
    } else {
        Write-Host '==> Downloading Zulu JDK 25 (Windows)'
        Invoke-WebRequest -Uri $JdkUrl -OutFile 'zulu25.zip'
        Expand-Archive -Path 'zulu25.zip' -DestinationPath $Work -Force
        $JdkHome = (Get-ChildItem -Path $Work -Directory -Filter 'zulu25*' | Select-Object -First 1).FullName
    }
}
$env:JAVA_HOME = $JdkHome
$env:PATH = (Join-Path $JdkHome 'bin') + ';' + $env:PATH
Write-Host "==> JDK: $(& (Join-Path $JdkHome 'bin\javac.exe') -version 2>&1)"

# --- Gradle ---
$GradleHome = Join-Path $Work "gradle-$GradleVersion"
if (-not (Test-Path $GradleHome)) {
    Write-Host "==> Downloading Gradle $GradleVersion"
    Invoke-WebRequest -Uri $GradleUrl -OutFile 'gradle.zip'
    Expand-Archive -Path 'gradle.zip' -DestinationPath $Work -Force
}
$Gradle = Join-Path $GradleHome 'bin\gradle.bat'

# --- ZombieBuddy source ---
$ZbDir = Join-Path $Work 'ZombieBuddy'
if (-not (Test-Path $ZbDir)) {
    Write-Host '==> Cloning ZombieBuddy master'
    git clone --depth 1 $ZbRepo $ZbDir
}

# --- Game jar ---
$GameJar = Join-Path $GamePath 'projectzomboid\projectzomboid.jar'
if (-not (Test-Path $GameJar)) { $GameJar = Join-Path $GamePath 'projectzomboid.jar' }
if (-not (Test-Path $GameJar)) { throw "projectzomboid.jar not found under $GamePath" }

Write-Host '==> Building ZombieBuddy shadowJar'
Push-Location (Join-Path $ZbDir 'java')
try {
    & $Gradle shadowJar "-PgameClasspath=$GameJar" --no-daemon --console=plain
    if ($LASTEXITCODE -ne 0) { throw 'gradle build failed' }
} finally {
    Pop-Location
}

$Built = Get-ChildItem -Path (Join-Path $ZbDir 'java') -Recurse -Filter 'ZombieBuddy.jar' |
    Where-Object { $_.FullName -match 'libs' } | Select-Object -First 1
if (-not $Built) { throw 'build produced no ZombieBuddy.jar' }

Write-Host "==> Installing into $GamePath"
foreach ($target in @((Join-Path $GamePath 'ZombieBuddy.jar'), (Join-Path $GamePath 'projectzomboid\ZombieBuddy.jar'))) {
    $dir = Split-Path -Parent $target
    if (-not (Test-Path $dir)) { continue }
    $orig = "$target.orig"
    if ((Test-Path $target) -and -not (Test-Path $orig)) { Copy-Item $target $orig }
    Copy-Item $Built.FullName $target -Force
    Write-Host "    $target"
}

Write-Host '==> Done'
