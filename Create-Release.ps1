# Compiles the help, and copies the module files to a folder that can be published using
# Publish-Module.

#Requires -Modules @{ ModuleName="platyps"; ModuleVersion="0.14.2" }
$outputPath = Join-Path $PSScriptRoot "release" "Wsl"
$docsPath = Join-Path $PSScriptRoot "docs"
New-Item $outputPath -ItemType Directory -Force | Out-Null
Copy-Item "Wsl.psd1","Wsl.psm1" $outputPath
New-ExternalHelp $docsPath -OutputPath $outputPath -Force | Out-Null
