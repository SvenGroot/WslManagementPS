# When adding new functionality, you should:
# - Write tests for the new functionality.
# - Run the tests on both PowerShell Core and Windows PowerShell.
# - Run the tests against the latest WSL store version.
# - Run the tests against the oldest supported WSL inbox version, which should be the oldest Windows
#   version still in mainstream support.
#   - See https://learn.microsoft.com/lifecycle/products/windows-10-home-and-pro
#
# These tests are not designed to run in PowerShell on Linux inside WSL; only run them directly in
# Windows.

#Requires -Modules @{ ModuleName="Pester"; ModuleVersion="5.0" }
param(
    [Parameter(Mandatory=$false)][string]$TestDistroPath
)

BeforeDiscovery {
    Import-Module "$PSScriptRoot/Wsl.psd1" -Force
    $wslVersion = (Get-WslVersion).Wsl
}

BeforeAll {
   function Test-Distro($Distro, [string]$Name, [string]$Version, [string]$State, [string]$BasePath, [string]$VhdFile = "ext4.vhdx", [Switch]$Default)
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
        $Distro.FileSystemPath | Should -Be "\\wsl.localhost\$Name"
        $Distro.Default | Should -Be $Default
        if ($Distro.Version -eq 2) {
            $Distro.VhdPath | Should -Be (Join-Path $BasePath $VhdFile)

        } else {
            $Distro.VhdPath | Should -BeNullOrEmpty
        }
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
        $Actual.Default | Should -Be $Expected.Default
        $Actual.VhdPath | Should -Be $Expected.VhdPath
    }

    Write-Warning "These tests should be run on a machine with no existing distributions."

    # This check for arm64 requires cross-platform PowerShell; you can still run the tests with
    # Windows PowerShell using the -TestDistroPath parameter.
    if ([System.Runtime.InteropServices.RuntimeInformation]::OSArchitecture -eq "Arm64") {
        $testDistroUrl = "https://dl-cdn.alpinelinux.org/alpine/v3.18/releases/aarch64/alpine-minirootfs-3.18.3-aarch64.tar.gz"

    } else {
        $testDistroUrl = "https://dl-cdn.alpinelinux.org/alpine/v3.18/releases/x86_64/alpine-minirootfs-3.18.3-x86_64.tar.gz"
    }

    $testDistroFile = "TestDrive:/wslps_test.tar.gz"
    if ($TestDistroPath) {
        Copy-Item $TestDistroPath $testDistroFile

    } else {
        Invoke-WebRequest $testDistroUrl -OutFile $testDistroFile
    }

    New-Item TestDrive:/wsl -ItemType Directory | Out-Null
    $originalWslUtf8 = $env:WSL_UTF8
    if (Test-Path env:WSL_UTF8) {
        Remove-Item env:WSL_UTF8
    }
}

AfterAll {
    try {
        Remove-WslDistribution "wslps_*"
    } catch {
        # Don't care about exceptions here.
    }

    $env:WSL_UTF8 = $originalWslUtf8
}

Describe "WslManagementPS" {
    It "Can list with no distributions" {
        Get-WslDistribution | Should -BeNullOrEmpty
    }

    It "Can accept empty collections as pipes" {
        # Use the filter string to avoid affecting other distributions if someone ran this test on a
        # system that has distributions by mistake.
        Get-WslDistribution "wslps_*" | Remove-WslDistribution
        Get-WslDistribution "wslps_*" | Stop-WslDistribution
        Get-WslDistribution "wslps_*" | Export-WslDistribution -Destination "TestDrive:/wsl"
        Get-WslDistribution "wslps_*" | Invoke-WslCommand "echo foo"
        Get-WslDistribution "wslps_*" | Set-WslDistribution -Version 2
    }

    It "Throws when removing a non-existing distribution" {
        { Remove-WslDistribution "wslps_bogus" } | Should -Throw "There is no distribution with the name 'wslps_bogus'."
    }

    # A bunch of the below tests depend on this one, so if this one fails, expect more to fail.
    It "Can import and export distributions" {
        $distro = Import-WslDistribution $testDistroFile -Destination "TestDrive:/wsl" -Version 1
        Test-Distro $distro "wslps_test" 1 "Stopped" -Default
        Test-DistroEqual $distro (Get-WslDistribution "wslps_test")

        # Already exists
        { Import-WslDistribution $testDistroFile -Destination "TestDrive:/" -Version 1 } | Should -Throw

        # Specific name
        $distro = Import-WslDistribution $testDistroFile -Name "wslps_test2" -Destination "TestDrive:/wsl" -Version 2
        Test-Distro $distro "wslps_test2" 2 "Stopped"
        Test-DistroEqual $distro (Get-WslDistribution "wslps_test2")
        # Raw destination
        New-Item "TestDrive:/wsl/raw" -ItemType Directory
        $distro = Import-WslDistribution $testDistroFile -Name "wslps_raw" -Destination "TestDrive:/wsl/raw" -RawDestination -Version 2
        Test-Distro $distro "wslps_raw" 2 "Stopped" "$TestDrive\wsl\raw"
        Test-DistroEqual $distro (Get-WslDistribution "wslps_raw")

        # Export single distro to file.
        $exported = Export-WslDistribution "wslps_test2" "TestDrive:/wslps_exported.tar.gz"
        $exported.FullName | Should -Be "$TestDrive\wslps_exported.tar.gz"
        Test-Path "TestDrive:/wslps_exported.tar.gz" -PathType Leaf | Should -Be $true
        $exported.Length | Should -Not -Be (Get-Item (Get-WslDistribution "wslps_test2").VhdPath).Length

        # Export multiple distros using wildcards
        New-Item "TestDrive:/exported" -ItemType Container
        Export-WslDistribution "wslps_test*" "TestDrive:/exported" | Out-Null
        Test-Path "TestDrive:/exported/wslps_test.tar.gz" -PathType Leaf | Should -Be $true
        Test-Path "TestDrive:/exported/wslps_test2.tar.gz" -PathType Leaf | Should -Be $true
        (Get-Item "TestDrive:/exported/wslps_test2.tar.gz").Length | Should -Not -Be (Get-Item (Get-WslDistribution "wslps_test2").VhdPath).Length
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
        $distros = Get-ChildItem "TestDrive:/exported" | Import-WslDistribution -Destination "TestDrive:/wsl" -Version 2
        $distros | Should -HaveCount 2
        Test-Distro $distros[0] "wslps_raw" 2 "Stopped"
        Test-Distro $distros[1] "wslps_test2" 2 "Stopped"

        # Use the default version
        $distro = Import-WslDistribution $testDistroFile -Name wslps_default -Destination "TestDrive:/wsl"
        $version = Get-WslVersion
        Test-Distro $distro "wslps_default" $version.DefaultDistroVersion "Stopped"
        { Remove-WslDistribution "wslps_default" } | Should -Not -Throw
    }

    It "Can import and export VHDs" -Skip:($wslVersion -lt ([Version]::new(0, 58))) {
        try {
            Stop-Wsl # Otherwise export may fail due to files in use.
            $exported = Export-WslDistribution "wslps_test2" "TestDrive:/exported" -Format "Vhd"
            $exported.FullName | Should -Be "$TestDrive\exported\wslps_test2.vhdx"
            "TestDrive:/exported/wslps_test2.vhdx" | Should -Exist
            $vhdSize = (Get-Item (Get-WslDistribution "wslps_test2").VhdPath).Length
            $exported.Length | Should -Be $vhdSize

            # Auto export as VHD based on extension
            $exported = Export-WslDistribution "wslps_test2" "TestDrive:/exported/test.vhdx"
            $exported.FullName | Should -Be "$TestDrive\exported\test.vhdx"
            $exported.Length | Should -Be $vhdSize

            # -Format overrides extension.
            $exported = Export-WslDistribution "wslps_test2" "TestDrive:/exported/test2.vhdx" -Format "Tar"
            $exported.FullName | Should -Be "$TestDrive\exported\test2.vhdx"
            $exported.Length | Should -Not -Be $vhdSize

            # Import VHDs
            $distro = Import-WslDistribution "TestDrive:/exported/wslps_test2.vhdx" "TestDrive:/wsl" "wslps_vhd1"
            Test-Distro $distro "wslps_vhd1" 2 "Stopped"
            $distro = Import-WslDistribution -InPlace "TestDrive:/exported/wslps_test2.vhdx" "wslps_vhd2"
            Test-Distro $distro "wslps_vhd2" 2 "Stopped" "$TestDrive\exported" "wslps_test2.vhdx"

            # -Format overrides extension on import
            $distro = Import-WslDistribution "TestDrive:/exported/test2.vhdx" "TestDrive:/wsl" "wslps_vhd3" -Format "tar"
            Test-Distro $distro "wslps_vhd3" 2 "Stopped"

        } finally {
            try { Remove-WslDistribution "wslps_vhd*" } catch {}
        }
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

    It "Can list online distributions" {
        # Tests that there are online distributions available
        $distrosOnline = Get-WslDistributionOnline
        $distrosOnline | Should -Not -BeNullOrEmpty
    }

    It "Has no missing Name or FriendlyName values" {
        # Tests that there are no null or empty values in either Name or FriendlyName
        Get-WslDistributionOnline | ForEach-Object {
            $_.Name | Should -Not -BeNullOrEmpty
            $_.FriendlyName | Should -Not -BeNullOrEmpty
        }
    }    

    It "Supports WSL_UTF8" -Skip:($wslVersion -lt ([Version]::new(0, 64))) {
        $env:WSL_UTF8 = "1"
        try {
            $distros = Get-WslDistribution
            $distros | Should -HaveCount 3
            Test-Distro ($distros | Where-Object { $_.Name -eq "wslps_test" }) "wslps_test" 1 "Stopped" -Default
            Test-Distro ($distros | Where-Object { $_.Name -eq "wslps_raw" }) "wslps_raw" 2 "Stopped"
            Test-Distro ($distros | Where-Object { $_.Name -eq "wslps_test2" }) "wslps_test2" 2 "Running"
    
        } finally {
            Remove-Item env:WSL_UTF8
        }
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
        
        # Exact name and passthru
        $distro = Stop-WslDistribution "wslps_raw" -Passthru
        Test-Distro $distro "wslps_raw" 2 "Stopped"

        # Pipeline input
        Invoke-WslCommand "echo foo" "wslps_*" *> $null
        (Get-WslDistribution "wslps_test").State | Should -Be "Running"
        (Get-WslDistribution "wslps_test2").State | Should -Be "Running"
        (Get-WslDistribution "wslps_raw").State | Should -Be "Running"
        Get-WslDistribution -Version 2 | Stop-WslDistribution
        (Get-WslDistribution "wslps_test").State | Should -Be "Running"
        (Get-WslDistribution "wslps_test2").State | Should -Be "Stopped"
        (Get-WslDistribution "wslps_raw").State | Should -Be "Stopped"

        # Non-existent
        { Stop-WslDistribution "wslps_bogus" } | Should -Throw "There is no distribution with the name 'wslps_bogus'."
    }

    It "Can run commands" {
        # Default distro
        # Redirect stderr to avoid printing warnings if the current directory can't be translated.
        Invoke-WslCommand "whoami" 2> $null | Should -Be "root"
        
        $uncPrefix = "wsl.localhost"

        # Specific distro
        $output = Invoke-WslCommand "cd; wslpath -w ." "wslps_raw" 2> $null
        if ($output -eq "\\wsl$\wslps_raw\root") {
            # Older WSL versions use this as the prefix.
            $uncPrefix = "wsl$"

        } else {
            $output | Should -Be "\\wsl.localhost\wslps_raw\root"
        }

        # Wildcards
        $output = Invoke-WslCommand "cd; wslpath -w ." "wslps_test*" 2> $null
        $output | Should -HaveCount 2
        $output | Should -Contain "\\$uncPrefix\wslps_test\root"
        $output | Should -Contain "\\$uncPrefix\wslps_test2\root"

        # Pipeline input
        $output = Get-WslDistribution -Version 2 | Invoke-WslCommand "cd; wslpath -w ." 2> $null
        $output | Should -HaveCount 2
        $output | Should -Contain "\\$uncPrefix\wslps_raw\root"
        $output | Should -Contain "\\$uncPrefix\wslps_test2\root"

        # Set starting directory
        Invoke-WslCommand "pwd" -WorkingDirectory "~" 2> $null | Should -Be "/root"
        if ((Get-WslVersion).Wsl -gt [Version]::new(0, 56, 1)) {
            Invoke-WslCommand "mkdir ~/foo" 2> $null
            Invoke-WslCommand "pwd" -WorkingDirectory "~/foo" 2> $null | Should -Be "/root/foo"
        }

        Invoke-WslCommand "pwd" -WorkingDirectory "/etc" 2> $null | Should -Be "/etc"
        Invoke-WslCommand "pwd" -WorkingDirectory "C:\Windows" 2> $null | Should -Be "/mnt/c/windows"
        Invoke-WslCommand "pwd" -WorkingDirectory "C:\" 2> $null | Should -Be "/mnt/c"
        $testPath = Invoke-WslCommand "wslpath '$TestDrive\wsl'" 2> $null
        Invoke-WslCommand "pwd" -WorkingDirectory "TestDrive:/wsl" 2> $null | Should -Be $testPath

        # Raw command
        Invoke-WslCommand -RawCommand -- echo foo`; whoami | Should -Be "foo","root"

        # Shell type (only tests if the argument is accepted; testing it if had any effect is not
        # trivial).
        if ((Get-WslVersion).Wsl -gt [Version]::new(0, 61, 4)) {
            Invoke-WslCommand "echo foo" -ShellType none 2> $null | Should -Be "foo"
            Invoke-WslCommand "echo foo" -ShellType login 2> $null | Should -Be "foo"
            Invoke-WslCommand -ShellType Standard -RawCommand -- echo foo 2> $null | Should -Be "foo"
        }

        # System distribution
        if ((Get-WslVersion).Wsl -gt [Version]::new(0, 47, 1)) {
            Invoke-WslCommand "whoami" "wslps_test2" -System 2> $null | Should -Be "wslg"
            Invoke-WslCommand -DistributionName "wslps_test2" -System -RawCommand whoami 2> $null | Should -Be "wslg"
        }

        # Non-existent
        { Invoke-WslCommand "whoami" "wslps_bogus" } | Should -Throw "There is no distribution with the name 'wslps_bogus'."
    }

    It "Can set distribution properties" {
        # Specific distro
        $distro = Set-WslDistribution "wslps_test" -Version 2 -Passthru
        Test-Distro $distro "wslps_test" 2 "Stopped" -Default

        # Wildcards
        $distros = Set-WslDistribution "wslps_test*" -Version 1 -Passthru
        Test-Distro $distros[0] "wslps_test" 1 "Stopped" -Default
        Test-Distro $distros[1] "wslps_test2" 1 "Stopped"

        # Pipeline input
        Get-WslDistribution -Version 1 | Set-WslDistribution -Version 2
        Get-WslDistribution -Version 2 | Should -HaveCount 3

        # Change default
        Set-WslDistribution "wslps_test2" -Default
        (Get-WslDistribution -Default).Name | Should -Be "wslps_test2"

        # Non-existent
        { Set-WslDistribution "wslps_bogus" -Version 2 } | Should -Throw "There is no distribution with the name 'wslps_bogus'."
    }

    It "Can return version information" {
        $version = Get-WslVersion
        if ($version.Wsl) {
            $packageVersion = (Get-AppxPackage -Name "MicrosoftCorporationII.WindowsSubsystemforLinux").Version
            $version.Wsl | Should -Be $packageVersion
            $kernelVersion = Invoke-WslCommand "uname -r" 2> $null
            $index = $kernelVersion.IndexOf("-")
            if ($index -ge 0) {
                $kernelVersion = $kernelVersion.Substring(0, $index)
            }

            $kernelVersion = [Version]::Parse($kernelVersion)
            $version.Kernel | Should -Be $kernelVersion
            $version.WslG | Should -BeGreaterThan ([Version]::new())
            $version.Msrdc | Should -BeGreaterThan ([Version]::new())
            $version.Direct3D | Should -BeGreaterThan ([Version]::new())
            $version.DXCore | Should -BeGreaterThan ([Version]::new())

        } else {
            $version.Wsl | Should -BeNullOrEmpty
            $version.Kernel | Should -BeNullOrEmpty
            $version.WslG | Should -BeNullOrEmpty
            $version.Msrdc | Should -BeNullOrEmpty
            $version.Direct3D | Should -BeNullOrEmpty
            $version.DXCore | Should -BeNullOrEmpty
        }

        # Environment.OSVersion always has 0 as the revision so don't compare it.
        $version.Windows.Major | Should -Be ([Environment]::OSVersion.Version.Major)
        $version.Windows.Minor | Should -Be ([Environment]::OSVersion.Version.Minor)
        $version.Windows.Build | Should -Be ([Environment]::OSVersion.Version.Build)

        $version.DefaultDistroVersion -eq 1 -or $version.DefaultDistroVersion -eq 2 | Should -BeTrue
    }

    It "Can stop WSL" {
        # Invoke a command to start the distros.
        Invoke-WslCommand "echo foo" "wslps_*" *> $null
        Stop-WSL
        Get-WslDistribution -State "Stopped" | Should -HaveCount 3
        # Can't really test if the utility VM was stopped.
    }

    It "Can remove distributions" {
        # Remove explicit name was tested in import/export test.
        
        # Wildcards
        Remove-WslDistribution "wslps_test*"
        $distros = Get-WslDistribution
        $distros | Should -HaveCount 1
        $distros[0].Name | Should -Be "wslps_raw"
        
        # Pipeline input
        Get-WslDistribution | Remove-WslDistribution
        Get-WslDistribution | Should -BeNullOrEmpty

        # Non-existent
        { Remove-WslDistribution "wslps_bogus" } | Should -Throw "There is no distribution with the name 'wslps_bogus'."
    }
}
