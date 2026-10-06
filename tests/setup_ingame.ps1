<#
.SYNOPSIS
  Sets up local in-game ZBSpec tests for The Only Cure.

.DESCRIPTION
  - initializes the vendored ZBSpec submodule (fork: ZioPao/ZBSpec)
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

Write-Host '==> Initializing ZBSpec submodule'
git -C $Root submodule update --init --recursive dev_stuff/vendor/ZBSpec

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

$gamePath = $null
$m = Select-String -Path $configFile -Pattern '^\s*game_path:\s*"?([^"#]+)' | Select-Object -First 1
if ($m) { $gamePath = $m.Matches[0].Groups[1].Value.Trim() }
if (-not $gamePath) {
    foreach ($c in @(
        "${env:ProgramFiles(x86)}\Steam\steamapps\common\ProjectZomboid",
        "$env:ProgramFiles\Steam\steamapps\common\ProjectZomboid"
    )) { if (Test-Path $c) { $gamePath = $c; break } }
}
if (-not $gamePath -or -not (Test-Path $gamePath)) {
    Write-Error 'Could not locate the Project Zomboid install. Set game_path in spec/zbspec.yml.'
}
Write-Host "    game folder: $gamePath"

# The released ZombieBuddy (v2.3.4) is incompatible with ZBSpec on Build 42.21.
# Build master instead (3.0.0-beta1).
Write-Host '==> Building ZombieBuddy from master'
& (Join-Path $ScriptDir 'build_zb_jar.ps1') $gamePath

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
