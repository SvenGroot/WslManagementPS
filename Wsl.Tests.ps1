#Requires -Modules Pester

BeforeAll {
    Write-Warning "These tests should be run on a machine with no existing distributions."

    # TODO: Arm64 support
    $testDistroUrl = "https://dl-cdn.alpinelinux.org/alpine/v3.18/releases/x86_64/alpine-minirootfs-3.18.3-x86_64.tar.gz"

    Invoke-WebRequest $testDistroUrl -OutFile TestDrive:/wslps_alpine.tar.gz
    New-Item TestDrive:/wsl -ItemType Directory | Out-Null
    Import-Module "$PSScriptRoot/Wsl.psd1" -Force
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
        Import-WslDistribution "$TestDrive/wslps_alpine.tar.gz" -Destination "$TestDrive/wsl"
    }
}