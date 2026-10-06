<#
.SYNOPSIS
  The Only Cure — test entry point (Windows).

.EXAMPLE
  tests\run.ps1 lint   # syntax + unresolved-require checks (no game)
  tests\run.ps1 unit   # mocked pure-Lua unit tests (no game)
  tests\run.ps1 sp     # in-game singleplayer specs (ZBSpec)
  tests\run.ps1 mp     # in-game multiplayer specs (ZBSpec)
  tests\run.ps1 all    # lint + unit + sp
#>
[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [ValidateSet('lint', 'unit', 'sp', 'mp', 'all')]
    [string]$Mode = 'all'
)

$ErrorActionPreference = 'Stop'

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$Root = (Resolve-Path (Join-Path $ScriptDir '..')).Path
Set-Location $Root

$LuaBin = $env:LUA_BIN
if (-not $LuaBin) {
    foreach ($candidate in @('luajit', 'lua54', 'lua53', 'lua')) {
        $cmd = Get-Command $candidate -ErrorAction SilentlyContinue
        if ($cmd) { $LuaBin = $candidate; break }
    }
}

function Invoke-Lint {
    if (-not $LuaBin) { throw 'no Lua interpreter found (need luajit or lua5.x)' }
    Write-Host '==> lint (syntax + requires)'
    $files = Get-ChildItem -Path '42/media/lua', 'common/media/lua' -Recurse -Filter '*.lua' |
        ForEach-Object { $_.FullName }
    $files | & $LuaBin (Join-Path $ScriptDir 'lint.lua')
    if ($LASTEXITCODE -ne 0) { throw 'lint failed' }
}

function Invoke-Unit {
    if (-not $LuaBin) { throw 'no Lua interpreter found (need luajit or lua5.x)' }
    Write-Host '==> unit tests (mock harness)'
    & $LuaBin (Join-Path $ScriptDir 'run_unit.lua')
    if ($LASTEXITCODE -ne 0) { throw 'unit tests failed' }
}

function Invoke-Zbspec([string]$zbspecMode) {
    $vendor = Join-Path $Root 'tests\vendor\ZBSpec'
    if (-not (Test-Path (Join-Path $vendor 'lib'))) {
        throw 'vendored ZBSpec not found. Run tests\setup_ingame.ps1 first.'
    }
    if (-not (Get-Command ruby -ErrorAction SilentlyContinue)) {
        throw 'ruby not found (need Ruby 2.7+ for ZBSpec).'
    }
    # -v lists every executed spec (name + pass/fail); without it ZBSpec only
    # prints per-section counts, which hides which specs actually ran.
    $config = Join-Path $Root 'tests\spec\zbspec.yml'
    & ruby "-I$($vendor -replace '\\','/')/lib" (Join-Path $vendor 'bin\zbspec') --mod-dir $Root --config $config -v $zbspecMode
    if ($LASTEXITCODE -ne 0) { throw "zbspec $zbspecMode failed" }
}

switch ($Mode) {
    'lint' { Invoke-Lint }
    'unit' { Invoke-Unit }
    'sp'   { Invoke-Zbspec '--sp' }
    'mp'   { Invoke-Zbspec '--mp' }
    'all'  { Invoke-Lint; Invoke-Unit; Invoke-Zbspec '--sp' }
}
