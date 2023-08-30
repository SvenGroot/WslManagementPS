#Requires -Modules @{ ModuleName="Pester"; ModuleVersion="5.0" }
param(
    [Parameter(Mandatory=$false)][string]$TestDistroPath
)

BeforeAll {
    Import-Module "$PSScriptRoot/Wsl.psd1" -Force

    function Test-Distro($Distro, [string]$Name, [string]$Version, [string]$State, [string]$BasePath)
    {
        $Distro | Should -Not -BeNullOrEmpty
        $Distro.Name | Should -Be $Name
        $Distro.Version | Should -Be $Version
        $Distro.State | Should -Be $State
        $Distro.Guid | Should -Not -BeNullOrEmpty
        if (-not $BasePath) {
            $BasePath = "$TestDrive\wsl\$Name"
        }

        $Distro.BasePath | Should -Be $BasePath
        $Distro.FileSystemPath | Should -Be "\\wsl$\$Name"
    }

    Write-Warning "These tests should be run on a machine with no existing distributions."

    # TODO: Arm64 support
    $testDistroUrl = "https://dl-cdn.alpinelinux.org/alpine/v3.18/releases/x86_64/alpine-minirootfs-3.18.3-x86_64.tar.gz"
    $testDistroFile = "TestDrive:/wslps_test.tar.gz"

    if ($TestDistroPath) {
        Copy-Item $TestDistroPath $testDistroFile
    } else {
        Invoke-WebRequest $testDistroUrl -OutFile $testDistroFile
    }

    New-Item TestDrive:/wsl -ItemType Directory | Out-Null
}

AfterAll {
    try {
        Remove-WslDistribution "wslps_*" | Should -Throw
    } catch {
        # Don't care about exceptions here.
    }
}

Describe "Wsl" {
    It "Can list with no distributions" {
        Get-WslDistribution | Should -BeNullOrEmpty
    }

    It "Throws when removing a non-existing distribution" {
        { Remove-WslDistribution "wslps_bogus" } | Should -Throw
    }

    It "Can import a distribution" {
        # TODO: Default version
        $distro = Import-WslDistribution $testDistroFile -Destination "TestDrive:/wsl" -Version 1 -Passthru
        Test-Distro $distro "wslps_test" 1 "Stopped"
        Test-Distro (Get-WslDistribution "wslps_test") "wslps_test" 1 "Stopped"
        # Specific name
        $distro = Import-WslDistribution $testDistroFile -Name "wslps_test2" -Destination "TestDrive:/wsl" -Version 2 -Passthru
        Test-Distro $distro "wslps_test2" 2 "Stopped"
        Test-Distro (Get-WslDistribution "wslps_test2") "wslps_test2" 2 "Stopped"
        # Raw destination
        New-Item "TestDrive:/wsl/raw" -ItemType Directory
        $distro = Import-WslDistribution $testDistroFile -Name "wslps_raw" -Destination "TestDrive:/wsl/raw" -RawDestination -Version 2 -Passthru
        Test-Distro $distro "wslps_raw" 2 "Stopped" "$TestDrive\wsl\raw"
        Test-Distro (Get-WslDistribution "wslps_raw") "wslps_raw" 2 "Stopped" "$TestDrive\wsl\raw"
    }
}
