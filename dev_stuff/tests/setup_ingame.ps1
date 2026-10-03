<#
.SYNOPSIS
  Sets up local in-game ZBSpec tests for The Only Cure.

.DESCRIPTION
  - initializes the vendored ZBSpec submodule and applies our Windows patch
  - creates the game config dir for the configured version
  - checks Ruby and the gems ZBSpec needs

  Linux/macOS users: use setup_ingame.sh instead.
#>
[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$Root = (Resolve-Path (Join-Path $ScriptDir '..\..')).Path
$Vendor = Join-Path $Root 'dev_stuff\vendor\ZBSpec'
$Patch = Join-Path $Root 'dev_stuff\vendor\zbspec-windows.patch'

Write-Host '==> Initializing ZBSpec submodule'
git -C $Root submodule update --init --recursive dev_stuff/vendor/ZBSpec

Write-Host '==> Applying Windows/Linux compatibility patch'
git -C $Vendor apply --check $Patch 2>$null
if ($LASTEXITCODE -eq 0) {
    git -C $Vendor apply $Patch
    Write-Host '    applied'
} else {
    Write-Host '    already applied (or conflicts); skipping'
}

Write-Host '==> Ensuring game config dir'
$configFile = Join-Path $Root 'spec\zbspec.yml'
$version = '42.21'
$m = Select-String -Path $configFile -Pattern 'game_version:\s*"?([0-9]+\.[0-9]+)' | Select-Object -First 1
if ($m) { $version = $m.Matches[0].Groups[1].Value }
$configDir = Join-Path $Vendor "configs\$version"
if (-not (Test-Path $configDir)) {
    Write-Host "    creating configs/$version from configs/42.13"
    Copy-Item -Recurse (Join-Path $Vendor 'configs\42.13') $configDir
} else {
    Write-Host "    configs/$version already exists"
}

Write-Host '==> Installing ZombieBuddy 2.3.4 (Windows: ZombieBuddy.jar + zbNative.dll)'
$zbVersion = '2.3.4'
$zbSha = 'eb79b9876332010733a8e0d7ce4fe0377846059a9e28859029e2a0fb449f6cf2'

$gamePath = $null
$m = Select-String -Path $configFile -Pattern '^\s*game_path:\s*"?([^"#]+)' | Select-Object -First 1
if ($m) { $gamePath = $m.Matches[0].Groups[1].Value.Trim() }if (-not $gamePath) {
    foreach ($c in @(
        "${env:ProgramFiles(x86)}\Steam\steamapps\common\ProjectZomboid",
        "$env:ProgramFiles\Steam\steamapps\common\ProjectZomboid"
    )) { if (Test-Path $c) { $gamePath = $c; break } }
}
if (-not $gamePath -or -not (Test-Path $gamePath)) {
    Write-Error 'Could not locate the Project Zomboid install. Set game_path in spec/zbspec.yml.'
}
Write-Host "    game folder: $gamePath"

$zbJar = Join-Path $gamePath 'ZombieBuddy.jar'
$needJar = $true
if (Test-Path $zbJar) {
    $hash = (Get-FileHash $zbJar -Algorithm SHA256).Hash.ToLower()
    if ($hash -eq $zbSha) { Write-Host '    ZombieBuddy.jar already present and verified'; $needJar = $false }
}
if ($needJar) {
    $url = "https://github.com/zed-0xff/ZombieBuddy/releases/download/v$zbVersion/ZombieBuddy.jar"
    Invoke-WebRequest -Uri $url -OutFile $zbJar
    $hash = (Get-FileHash $zbJar -Algorithm SHA256).Hash.ToLower()
    if ($hash -ne $zbSha) { Remove-Item $zbJar; Write-Error 'ZombieBuddy.jar checksum mismatch; aborting.' }
    Write-Host '    installed ZombieBuddy.jar (verified)'
}

$zbDll = Join-Path $gamePath 'zbNative.dll'
if (-not (Test-Path $zbDll)) {
    $url = "https://github.com/zed-0xff/ZombieBuddy/releases/download/v$zbVersion/zbNative.dll"
    Invoke-WebRequest -Uri $url -OutFile $zbDll
    Write-Host '    installed zbNative.dll'
} else {
    Write-Host '    zbNative.dll already present'
}

Write-Host '==> Checking Ruby'
if (-not (Get-Command ruby -ErrorAction SilentlyContinue)) {
    Write-Error 'Ruby not found. Install Ruby 2.7+ (https://rubyinstaller.org/) then re-run.'
}
ruby --version

Write-Host '==> Checking gems (amazing_print, sugar_png)'
if (Get-Command gem -ErrorAction SilentlyContinue) {
    $gems = @('amazing_print', 'sugar_png')
    foreach ($g in $gems) {
        gem list -i $g *> $null
        if ($LASTEXITCODE -ne 0) { gem install $g }
    }
}

Write-Host ''
Write-Host 'Setup complete. Then run: dev_stuff\tests\run.ps1 sp'
