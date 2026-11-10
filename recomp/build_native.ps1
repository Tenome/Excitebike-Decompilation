# Build the native Windows executable (static recompilation via NESRecomp) for one version.
#   .\recomp\build_native.ps1 -Version us -NesRecomp C:\path\to\nesrecomp [-Headless]
# Needs: Python 3.11+, CMake, Visual Studio with C++ (adjust -Generator), a clone of https://github.com/mstan/nesrecomp,
# and your ROM at orig\excitebike_<version>.nes. Output: build\native\<version>\excitebike-<version>.exe
param([ValidateSet('us','eu')][string]$Version = 'us', [Parameter(Mandatory)][string]$NesRecomp,
      [string]$Generator = 'Visual Studio 17 2022', [switch]$Headless)
$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$rom  = (Join-Path $root "orig\excitebike_$Version.nes").Replace('\','/')
$work = Join-Path $root "build\native\$Version"; New-Item -ItemType Directory -Force $work | Out-Null
$seeds = Join-Path $work 'seeds.txt'
python (Join-Path $root 'tools\make_seeds.py') --version $Version $seeds
$toml = Join-Path $work 'game.toml'
@"
[game]
output_prefix = "excitebike-$Version"
cycle_accurate = true
cycle_seed_file = "$($seeds.Replace('\','/'))"
"@ | Set-Content $toml -Encoding ascii
$bd = Join-Path $work 'cmake'
$cfg = @('-S', (Join-Path $NesRecomp 'runner\cyc\project'), '-B', $bd, '-G', $Generator, '-A', 'x64',
         "-DNESRECOMP_ROM=$rom", "-DNESRECOMP_GAME_CONFIG=$($toml.Replace('\','/'))")
if ($Headless) { $cfg += '-DNESRECOMP_HEADLESS=ON' }
cmake @cfg
cmake --build $bd --config Release --parallel
Copy-Item (Join-Path $bd 'Release\nes_game.exe') (Join-Path $work "excitebike-$Version.exe") -Force
"Built $work\excitebike-$Version.exe  (run it with your ROM: excitebike-$Version.exe `"$($rom.Replace('/','\'))`")"
