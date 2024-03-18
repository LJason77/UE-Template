Push-Location $PSScriptRoot\..

try { Get-ChildItem Binaries,Build,DerivedDataCache,Intermediate,PackageGame,Releases,Saved\StagedBuilds -Recurse | Remove-Item -Force -Recurse -ErrorAction stop }
catch [System.Management.Automation.ItemNotFoundException] { $null }

Pop-Location
