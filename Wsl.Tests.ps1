#Requires -Modules @{ ModuleName="Pester"; ModuleVersion="5.0" }
param(
    [Parameter(Mandatory=$false)][string]$TestDistroPath
)

BeforeAll {
    Import-Module "$PSScriptRoot/Wsl.psd1" -Force

    function Test-Distro($Distro, [string]$Name, [string]$Version, [string]$State, [string]$BasePath, [Switch]$Default)
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
        $Distro.Default | Should -Be $Default
    }

    function Test-DistroEqual($Expected, $Actual)
    {
        $Expected | Should -Not -BeNullOrEmpty
        $Actual | Should -Not -BeNullOrEmpty
        $Actual.Name | Should -Be $Expected.Name
        $Actual.Version | Should -Be $Expected.Version
        $Actual.State | Should -Be $Expected.State
        $Actual.Guid | Should -Be $Expected.Guid
        $Actual.BasePath | Should -Be $Expected.BasePath
        $Actual.FileSystemPath | Should -Be $Expected.FileSystemPath
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
        Remove-WslDistribution "wslps_*"
    } catch {
        # Don't care about exceptions here.
    }
}

Describe "WslManagementPS" {
    It "Can list with no distributions" {
        Get-WslDistribution | Should -BeNullOrEmpty
    }

    It "Can accept empty collections as pipes" {
        Get-WslDistribution | Remove-WslDistribution
        Get-WslDistribution | Stop-WslDistribution
        Get-WslDistribution | Export-WslDistribution -Destination "TestDrive:/wsl"
        Get-WslDistribution | Invoke-WslCommand "echo foo"
        Get-WslDistribution | Set-WslDistribution -Version 2
    }

    It "Throws when removing a non-existing distribution" {
        { Remove-WslDistribution "wslps_bogus" } | Should -Throw "There is no distribution with the name 'wslps_bogus'."
    }

    It "Can import and export distributions" {
        # TODO: Default version
        $distro = Import-WslDistribution $testDistroFile -Destination "TestDrive:/wsl" -Version 1 -Passthru
        Test-Distro $distro "wslps_test" 1 "Stopped" -Default
        Test-DistroEqual $distro (Get-WslDistribution "wslps_test")

        # Already exists
        { Import-WslDistribution $testDistroFile -Destination "TestDrive:/" -Version 1 } | Should -Throw

        # Specific name
        $distro = Import-WslDistribution $testDistroFile -Name "wslps_test2" -Destination "TestDrive:/wsl" -Version 2 -Passthru
        Test-Distro $distro "wslps_test2" 2 "Stopped"
        Test-DistroEqual $distro (Get-WslDistribution "wslps_test2")
        # Raw destination
        New-Item "TestDrive:/wsl/raw" -ItemType Directory
        $distro = Import-WslDistribution $testDistroFile -Name "wslps_raw" -Destination "TestDrive:/wsl/raw" -RawDestination -Version 2 -Passthru
        Test-Distro $distro "wslps_raw" 2 "Stopped" "$TestDrive\wsl\raw"
        Test-DistroEqual $distro (Get-WslDistribution "wslps_raw")

        # Export single distro to file.
        $exported = Export-WslDistribution "wslps_test2" "TestDrive:/wslps_exported.tar.gz" -Passthru
        Test-DistroEqual (Get-WslDistribution "wslps_test2") $exported
        Test-Path "TestDrive:/wslps_exported.tar.gz" -PathType Leaf | Should -Be $true

        # Export multiple distros using wildcards
        New-Item "TestDrive:/exported" -ItemType Container
        Export-WslDistribution "wslps_test*" "TestDrive:/exported"
        Test-Path "TestDrive:/exported/wslps_test.tar.gz" -PathType Leaf | Should -Be $true
        Test-Path "TestDrive:/exported/wslps_test2.tar.gz" -PathType Leaf | Should -Be $true
        "TestDrive:/exported/wslps_raw.tar.gz" | Should -Not -Exist

        # Export multiple distros using pipeline
        Remove-Item "TestDrive:/exported/*"
        Get-WslDistribution -Version 2 | Export-WslDistribution -Destination "TestDrive:/exported"
        Test-Path "TestDrive:/exported/wslps_test2.tar.gz" -PathType Leaf | Should -Be $true
        Test-Path "TestDrive:/exported/wslps_raw.tar.gz" -PathType Leaf | Should -Be $true
        "TestDrive:/exported/wslps_test.tar.gz" | Should -Not -Exist

        # Export non-existant
        { Export-WslDistribution "wslps_bogus" "TestDrive:/exported" } | Should -Throw "There is no distribution with the name 'wslps_bogus'."

        Remove-WslDistribution "wslps_test2","wslps_raw"

        # Import multiple distributions using pipeline
        $distros = Get-ChildItem "TestDrive:/exported" | Import-WslDistribution -Destination "TestDrive:/wsl" -Version 2 -Passthru
        $distros | Should -HaveCount 2
        Test-Distro $distros[0] "wslps_raw" 2 "Stopped"
        Test-Distro $distros[1] "wslps_test2" 2 "Stopped"
    }

    It "Can list distributions" {
        # Invoke a command to start one of the distros.
        Invoke-WslCommand "echo foo" "wslps_test2" *> $null
        $distros = Get-WslDistribution
        $distros | Should -HaveCount 3
        Test-Distro ($distros | Where-Object { $_.Name -eq "wslps_test" }) "wslps_test" 1 "Stopped" -Default
        Test-Distro ($distros | Where-Object { $_.Name -eq "wslps_raw" }) "wslps_raw" 2 "Stopped"
        Test-Distro ($distros | Where-Object { $_.Name -eq "wslps_test2" }) "wslps_test2" 2 "Running"

        $distros = Get-WslDistribution -Default
        $distros | Should -HaveCount 1
        Test-Distro ($distros | Where-Object { $_.Name -eq "wslps_test" }) "wslps_test" 1 "Stopped" -Default

        $distros = Get-WslDistribution -Version 2
        $distros | Should -HaveCount 2
        Test-Distro ($distros | Where-Object { $_.Name -eq "wslps_raw" }) "wslps_raw" 2 "Stopped"
        Test-Distro ($distros | Where-Object { $_.Name -eq "wslps_test2" }) "wslps_test2" 2 "Running"

        $distros = Get-WslDistribution -State Running
        $distros | Should -HaveCount 1
        Test-Distro ($distros | Where-Object { $_.Name -eq "wslps_test2" }) "wslps_test2" 2 "Running"

        $distros = Get-WslDistribution -State Stopped -Version 2
        $distros | Should -HaveCount 1
        Test-Distro ($distros | Where-Object { $_.Name -eq "wslps_raw" }) "wslps_raw" 2 "Stopped"
    }

    It "Can stop distributions" {
        # Invoke a command to start the distros.
        Invoke-WslCommand "echo foo" "wslps_*" *> $null

        (Get-WslDistribution "wslps_test").State | Should -Be "Running"
        (Get-WslDistribution "wslps_test2").State | Should -Be "Running"
        (Get-WslDistribution "wslps_raw").State | Should -Be "Running"

        # Wildcards
        Stop-WslDistribution "wslps_test*"
        (Get-WslDistribution "wslps_test").State | Should -Be "Stopped"
        (Get-WslDistribution "wslps_test2").State | Should -Be "Stopped"
        (Get-WslDistribution "wslps_raw").State | Should -Be "Running"
        
        # Exact name
        $distro = Stop-WslDistribution "wslps_raw" -Passthru
        Test-Distro $distro "wslps_raw" 2 "Stopped"

        # Non-existent
        { Stop-WslDistribution "wslps_bogus" } | Should -Throw "There is no distribution with the name 'wslps_bogus'."
    }
}
