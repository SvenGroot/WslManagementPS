# Copyright (c) Sven Groot. See LICENSE for details.

# Represents the state of a distribution.
enum WslDistributionState {
    Stopped
    Running
    Installing
    Uninstalling
    Converting
}

# Represents a WSL distribution.
class WslDistribution
{
    WslDistribution()
    {
        $this | Add-Member -Name FileSystemPath -Type ScriptProperty -Value {
            return "\\wsl.localhost\$($this.Name)"
        }

        $defaultDisplaySet = "Name","State","Version","Default"

        #Create the default property display set
        $defaultDisplayPropertySet = New-Object System.Management.Automation.PSPropertySet("DefaultDisplayPropertySet",[string[]]$defaultDisplaySet)
        $PSStandardMembers = [System.Management.Automation.PSMemberInfo[]]@($defaultDisplayPropertySet)
        $this | Add-Member MemberSet PSStandardMembers $PSStandardMembers
    }

    [string] ToString()
    {
        return $this.Name
    }

    [string]$Name
    [WslDistributionState]$State
    [int]$Version
    [bool]$Default
    [Guid]$Guid
    [string]$BasePath
}

# Provides version of various WSL components.
class WslVersionInfo {
    [Version]$Wsl
    [Version]$Kernel
    [Version]$WslG
    [Version]$Msrdc
    [Version]$Direct3D
    [Version]$DXCore
    [Version]$Windows
}

# Ensure IsWindows is set for Windows PowerShell to make future checks easier.
if ($PSVersionTable.PSVersion.Major -lt 6) {
    $IsWindows = $true
}

if ($IsWindows) {
    $wslPath = "$env:windir\system32\wsl.exe"
    if (-not [System.Environment]::Is64BitProcess) {
        # Allow launching WSL from 32 bit powershell
        $wslPath = "$env:windir\sysnative\wsl.exe"
    }

} else {
    # If running inside WSL, rely on wsl.exe being in the path.
    $wslPath = "wsl.exe"
}

function Get-UnresolvedProviderPath([string]$Path)
{
    if ($IsWindows) {
        return $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Path)

    } else {
        # Don't translate on Linux, because absolute Linux paths will never work, and relative ones
        # will.
        return $Path
    }
}

# Helper that will launch wsl.exe, correctly parsing its output encoding, and throwing an error
# if it fails.
function Invoke-Wsl([string[]]$WslArgs, [Switch]$IgnoreErrors)
{
    try {
        if ($IsLinux) {
            # If running inside WSL, we can't reliably determine the value WSL_UTF8 had in Windows,
            # so set it explicitly.
            $originalWslUtf8 = $env:WSL_UTF8
            $originalWslEnv = $env:WSLENV
            $env:WSL_UTF8 = "1"
            $env:WSLENV += ":WSL_UTF8"
        }

        $encoding = [System.Text.Encoding]::Unicode
        if ($env:WSL_UTF8 -eq "1") {
            $encoding = [System.Text.Encoding]::Utf8
        }

        $hasError = $false
        if ($PSVersionTable.PSVersion.Major -lt 6 -or $PSVersionTable.PSVersion.Major -ge 7) {
            try {
                $oldOutputEncoding = [System.Console]::OutputEncoding
                [System.Console]::OutputEncoding = $encoding
                $output = &$wslPath @WslArgs
                if ($LASTEXITCODE -ne 0) {
                    $hasError = $true
                }

            } finally {
                [System.Console]::OutputEncoding = $oldOutputEncoding
            }

        } else {
            # Using Console.OutputEncoding is broken on PowerShell 6, so use an alternative method of
            # starting wsl.exe.
            # See: https://github.com/PowerShell/PowerShell/issues/10789
            $startInfo = New-Object System.Diagnostics.ProcessStartInfo $wslPath
            $WslArgs | ForEach-Object { $startInfo.ArgumentList.Add($_) }
            $startInfo.RedirectStandardOutput = $true
            $startInfo.StandardOutputEncoding = $encoding
            $process = [System.Diagnostics.Process]::Start($startInfo)
            $output = @()
            while ($null -ne ($line = $process.StandardOutput.ReadLine())) {
                if ($line.Length -gt 0) {
                    $output += $line
                }
            }

            $process.WaitForExit()
            if ($process.ExitCode -ne 0) {
                $hasError = $true
            }
        }

    } finally {
        if ($IsLinux) {
            $env:WSL_UTF8 = $originalWslUtf8
            $env:WSLENV = $originalWslEnv
        }
    }

    # $hasError is used so there's no output in case error action is silently continue.
    if ($hasError) {
        if ($IgnoreErrors) {
            return @()
        }

        throw "Wsl.exe failed: $output"
    }

    return $output
}

# Helper to parse the output of wsl.exe --list
function Get-WslDistributionHelper()
{
    Invoke-Wsl "--list","--verbose" -IgnoreErrors | Select-Object -Skip 1 | ForEach-Object {
        $fields = $_.Split(@(" "), [System.StringSplitOptions]::RemoveEmptyEntries) 
        $defaultDistro = $false
        if ($fields.Count -eq 4) {
            $defaultDistro = $true
            $fields = $fields | Select-Object -Skip 1
        }

        [WslDistribution]@{
            "Name" = $fields[0]
            "State" = $fields[1]
            "Version" = [int]$fields[2]
            "Default" = $defaultDistro
        }
    }
}

# Helper to get additional distribution properties from the registry.
function Get-WslDistributionProperties([WslDistribution]$Distribution)
{
    $key = Get-ChildItem "hkcu:\SOFTWARE\Microsoft\Windows\CurrentVersion\Lxss" | Get-ItemProperty | Where-Object { $_.DistributionName -eq $Distribution.Name }
    if ($key) {
        $Distribution.Guid = $key.PSChildName
        $Distribution.BasePath = $key.BasePath
        if ($Distribution.BasePath.StartsWith("\\?\")) {
            $Distribution.BasePath = $Distribution.BasePath.Substring(4)
        }
    }
}

<#
.SYNOPSIS
Gets the WSL distributions installed on the computer.

.DESCRIPTION
The Get-WslDistribution cmdlet gets objects that represent the WSL distributions on the computer.

This cmdlet wraps the functionality of "wsl.exe --list --verbose".

.PARAMETER Name
Specifies the distribution names of distributions to be retrieved. Wildcards are permitted. By
default, this cmdlet gets all of the distributions on the computer.

.PARAMETER Default
Indicates that this cmdlet gets only the default distribution. If this is combined with other
parameters such as Name, nothing will be returned unless the default distribution matches all the
conditions. By default, this cmdlet gets all of the distributions on the computer.

.PARAMETER State
Indicates that this cmdlet gets only distributions in the specified state (e.g. Running). By
default, this cmdlet gets all of the distributions on the computer.

.PARAMETER Version
Indicates that this cmdlet gets only distributions that are the specified version. By default,
this cmdlet gets all of the distributions on the computer.

.INPUTS
System.String

You can pipe a distribution name to this cmdlet.

.OUTPUTS
WslDistribution

The cmdlet returns objects that represent the distributions on the computer.

.EXAMPLE
Get-WslDistribution
Name           State Version Default
----           ----- ------- -------
Ubuntu       Stopped       2    True
Ubuntu-18.04 Running       1   False
Alpine       Running       2   False
Debian       Stopped       1   False

Get all WSL distributions.

.EXAMPLE
Get-WslDistribution -Default
Name           State Version Default
----           ----- ------- -------
Ubuntu       Stopped       2    True

Get the default distribution.

.EXAMPLE
Get-WslDistribution -Version 2 -State Running
Name           State Version Default
----           ----- ------- -------
Alpine       Running       2   False

Get running WSL2 distributions.

.EXAMPLE
Get-WslDistribution Ubuntu* | Stop-WslDistribution

Terminate all distributions that start with Ubuntu

.EXAMPLE
Get-Content distributions.txt | Get-WslDistribution
Name           State Version Default
----           ----- ------- -------
Ubuntu       Stopped       2    True
Debian       Stopped       1   False

Use the pipeline as input.
#>
function Get-WslDistribution
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [SupportsWildcards()]
        [string[]]$Name,
        [Parameter(Mandatory=$false)]
        [Switch]$Default,
        [Parameter(Mandatory=$false)]
        [WslDistributionState]$State,
        [Parameter(Mandatory=$false)]
        [int]$Version
    )

    process {
        $distributions = Get-WslDistributionHelper
        if ($Default) {
            $distributions = $distributions | Where-Object {
                $_.Default
            }
        }

        if ($PSBoundParameters.ContainsKey("State")) {
            $distributions = $distributions | Where-Object {
                $_.State -eq $State
            }
        }

        if ($PSBoundParameters.ContainsKey("Version")) {
            $distributions = $distributions | Where-Object {
                $_.Version -eq $Version
            }
        }

        if ($Name.Length -gt 0) {
            $distributions = $distributions | Where-Object {
                foreach ($pattern in $Name) {
                    if ($_.Name -ilike $pattern) {
                        return $true
                    }
                }
                
                return $false
            }
        }

        # The additional registry properties aren't available if running inside WSL.
        if ($IsWindows) {
            $distributions | ForEach-Object {
                Get-WslDistributionProperties $_
            }
        }

        return $distributions
    }
}

<#
.SYNOPSIS
Stops one or more running WSL distributions.

.DESCRIPTION
The Stop-WslDistribution cmdlet terminates each of the specified WSL distributions. You can specify
distributions by their names, or use the Distribution parameter to pass an object returned by
Get-WslDistribution.

This cmdlet wraps the functionality of "wsl.exe --terminate".

.PARAMETER Name
Specifies the distribution names of distributions to be terminated. Wildcards are permitted.

.PARAMETER Distribution
Specifies WslDistribution objects that represent the distributions to be terminated.

.PARAMETER Passthru
Returns an object that represents the distribution. By default, this cmdlet does not generate any
output.

.INPUTS
WslDistribution, System.String

You can pipe a WslDistribution object retrieved by Get-WslDistribution, or a string that contains
the distribution name to this cmdlet.

.OUTPUTS
WslDistribution

The cmdlet returns an object that represent the distribution, if you use the Passthru parameter.
Otherwise, this cmdlet does not generate any output.

.EXAMPLE
Stop-WslDistribution Ubuntu

Stops the distribution named "Ubuntu".

.EXAMPLE
Stop-WslDistribution Ubuntu*

Terminate all distributions whose names start with Ubuntu

.EXAMPLE
Get-WslDistribution -Version 2 | Stop-WslDistribution -Passthru
Name           State Version Default
----           ----- ------- -------
Ubuntu       Stopped       2    True
Alpine       Stopped       2   False

Stops all WSL2 distributions.
#>
function Stop-WslDistribution
{
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = "DistributionName", Position = 0)]
        [ValidateNotNullOrEmpty()]
        [SupportsWildCards()]
        [string[]]$Name,
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = "Distribution")]
        [WslDistribution[]]$Distribution,
        [Parameter(Mandatory = $false)]
        [Switch]$Passthru
    )

    process
    {
        if ($PSCmdlet.ParameterSetName -eq "DistributionName") {
            $distros = Get-WslDistribution $Name
            if (-not $distros) {
                throw "There is no distribution with the name '$Name'."
            }

        } else {
            $distros = $Distribution
        }

        $distros | ForEach-Object {
            if ($_.State -ne [WslDistributionState]::Running) {
                Write-Warning "Distribution $($_.Name) is not running."

            } elseif ($PSCmdlet.ShouldProcess($_.Name, "Terminate")) {
                Invoke-Wsl "--terminate",$_.Name
            }

            if ($Passthru) {
                # Re-query to get the updated state.
                Get-WslDistribution $_.Name
            }
        }
    }
}

<#
.SYNOPSIS
Configures one or more WSL distributions

.DESCRIPTION
The Set-WslDistribution cmdlet changes the properties of a WSL distribution. You can specify
distributions by their names, or use the Distribution parameter to pass an object returned by
Get-WslDistribution.

This cmdlet wraps the functionality of "wsl.exe --set-default" and "wsl.exe --set-version".

.PARAMETER Name
Specifies the distribution names of distributions to be configured. Wildcards are permitted.

.PARAMETER Distribution
Specifies WslDistribution objects that represent the distributions to be configured.

.PARAMETER Version
When specified, converts the distribution to the specified version. This may take several minutes.

.PARAMETER Default
When specified, sets the distribution as the default distribution. If multiple distributions are
specified as input, the last one processed will be the default after the command finishes.

.PARAMETER Passthru
Returns an object that represents the distribution. By default, this cmdlet does not generate any
output.

.INPUTS
WslDistribution, System.String

You can pipe a WslDistribution object retrieved by Get-WslDistribution, or a string that contains
the distribution name to this cmdlet.

.OUTPUTS
WslDistribution

The cmdlet returns an object that represent the distribution, if you use the Passthru parameter.
Otherwise, this cmdlet does not generate any output.

.EXAMPLE
Set-WslDistribution Ubuntu -Default

Makes the distribution named "Ubuntu" the default.

.EXAMPLE
Get-WslDistribution -Version 1 | Set-WslDistribution -Version 2 -Passthru
Name           State Version Default
----           ----- ------- -------
Ubuntu-18.04 Running       2   False
Debian       Stopped       2   False

Converts all version 1 distributions to version 2.
#>
function Set-WslDistribution
{
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = "DistributionName", Position = 0)]
        [ValidateNotNullOrEmpty()]
        [SupportsWildCards()]
        [string[]]$Name,
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = "Distribution")]
        [WslDistribution[]]$Distribution,
        [Parameter(Mandatory = $false)]
        [int]$Version = 0,
        [Parameter(Mandatory = $false)]
        [Switch]$Default,
        [Parameter(Mandatory = $false)]
        [Switch]$Passthru
    )

    process
    {
        if ($PSCmdlet.ParameterSetName -eq "DistributionName") {
            $distros = Get-WslDistribution $Name
            if (-not $distros) {
                throw "There is no distribution with the name '$Name'."
            }

        } else {
            $distros = $Distribution
        }

        $distros | ForEach-Object {
            if ($Version -ne 0) {
                if ($_.Version -eq $Version) {
                    Write-Warning "The distribution '$($_.Name)' is already the requested version."

                } elseif ($PSCmdlet.ShouldProcess($_.Name, "Set Version")) {
                    # Suppress output since it messes with passthru
                    Invoke-Wsl "--set-version",$_.Name,$Version | Out-Null
                }
            }

            if ($Default) {
                if ($_.Default) {
                    Write-Warning "The distribution '$($_.Name)' is already the default."

                } if ($PSCmdlet.ShouldProcess($_.Name, "Set Default")) {
                    Invoke-Wsl "--set-default",$_.Name | Out-Null
                }
            }

            # Get updated info for pass-through.
            if ($Passthru) {
                Get-WslDistribution $_.Name
            }
        }
    }
}

<#
.SYNOPSIS
Removes one or more WSL distributions from the computer.

.DESCRIPTION
The Remove-WslDistribution cmdlet unregisters each of the specified WSL distributions. You can specify
distributions by their names, or use the Distribution parameter to pass an object returned by
Get-WslDistribution.

This cmdlet wraps the functionality of "wsl.exe --unregister".

.PARAMETER Name
Specifies the distribution names of distributions to be removed. Wildcards are permitted.

.PARAMETER Distribution
Specifies WslDistribution objects that represent the distributions to be removed.

.INPUTS
WslDistribution, System.String

You can pipe a WslDistribution object retrieved by Get-WslDistribution, or a string that contains
the distribution name to this cmdlet.

.OUTPUTS
None. This cmdlet does not generate any output.

.EXAMPLE
Remove-WslDistribution Ubuntu

Unregisters the distribution named "Ubuntu".

.EXAMPLE
Remove-WslDistribution Ubuntu*

Unregisters all distributions whose names start with Ubuntu

.EXAMPLE
Get-WslDistribution -Version 1 | Remove-WslDistribution

Unregisters all WSL1 distributions.

.EXAMPLE
Get-WslDistribution | Where-Object { $_.Name -ine "Ubuntu" } | Remove-WslDistribution

Unregisters all distributions except the one named "Ubuntu".
#>
function Remove-WslDistribution
{
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = "DistributionName", Position = 0)]
        [ValidateNotNullOrEmpty()]
        [SupportsWildCards()]
        [string[]]$Name,
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = "Distribution")]
        [WslDistribution[]]$Distribution
    )

    process
    {
        if ($PSCmdlet.ParameterSetName -eq "DistributionName") {
            $distros = Get-WslDistribution $Name
            if ($distros.Length -eq 0) {
                throw "There is no distribution with the name '$Name'."
            }
    
        } else {
            $distros = $Distribution
        }

        $distros | ForEach-Object {
            if ($PSCmdlet.ShouldProcess($_.Name, "Unregister")) {
                Invoke-Wsl "--unregister",$_.Name | Out-Null
            }
        }
    }
}

<#
.SYNOPSIS
Exports one or more WSL distributions to a .tar.gz file.

.DESCRIPTION
The Export-WslDistribution cmdlet exports each of the specified WSL distributions to a gzipped
tarball. You can specify distributions by their names, or use the Distribution parameter to pass
an object returned by Get-WslDistribution.

You can export multiple distributions by specifying a directory as the Destination. In this case,
this cmdlet will automatically create files using the distribution name with the extension .tar.gz.

This cmdlet wraps the functionality of "wsl.exe --export".

.PARAMETER Name
Specifies the distribution names of distributions to be exported. Wildcards are permitted.

.PARAMETER Distribution
Specifies WslDistribution objects that represent the distributions to be exported.

.PARAMETER Destination
Specifies the destination directory or file name where the exported distribution will be stored.

If you specify an existing directory as the destination, this cmdlet will append a file name based
on the distribution name. If you specify a non-existing file name, that name will be used verbatim.

.PARAMETER Passthru
Returns an object that represents the distribution. By default, this cmdlet does not generate any
output.

.INPUTS
WslDistribution, System.String

You can pipe a WslDistribution object retrieved by Get-WslDistribution, or a string that contains
the distribution name to this cmdlet.

.OUTPUTS
WslDistribution

The cmdlet returns an object that represent the distribution, if you use the Passthru parameter.
Otherwise, this cmdlet does not generate any output.

.EXAMPLE
Export-WslDistribution Ubuntu D:\backup.tar.gz

Exports the distribution named "Ubuntu" to a file named D:\backup.tar.gz.

.EXAMPLE
Export-WslDistribution Ubuntu* D:\backup

Exports all distributions whose names start with Ubuntu to files in a directory named D:\backup.

.EXAMPLE
Get-WslDistribution -Version 2 | Export-WslDistribution -Destination D:\backup -Passthru
Name           State Version Default
----           ----- ------- -------
Ubuntu       Stopped       2    True
Alpine       Stopped       2   False

Exports all WSL2 distributions to a directory named D:\backup.
#>
function Export-WslDistribution
{
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = "DistributionName", Position = 0)]
        [ValidateNotNullOrEmpty()]
        [SupportsWildCards()]
        [string[]]$Name,
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = "Distribution")]
        [WslDistribution[]]$Distribution,
        [Parameter(Mandatory = $true, Position = 1)]
        [string]$Destination,
        [Parameter(Mandatory = $false)]
        [Switch]$Passthru
    )

    process
    {
        if ($PSCmdlet.ParameterSetName -eq "DistributionName") {
            $distros = Get-WslDistribution $Name
            if (-not $distros) {
                throw "There is no distribution with the name '$Name'."
            }

        } else {
            $distros = $Distribution
        }

        $distros | ForEach-Object {
            $fullPath = $Destination
            if (Test-Path $Destination -PathType Container) {
                $fullPath = Join-Path $Destination "$($_.Name).tar.gz"
            }

            if (Test-Path $fullPath) {
                throw "The path '$fullPath' already exists."
            }

            #$fullPath = Get-UnresolvedProviderPath $fullPath
            if ($PSCmdlet.ShouldProcess("Name: $($_.Name), Path: $fullPath", "Export")) {
                Invoke-Wsl "--export",$_.Name,$fullPath | Out-Null
            }

            if ($Passthru) {
                $_
            }
        }
    }
}

<#
.SYNOPSIS
Imports one or more WSL distributions from a .tar.gz file.

.DESCRIPTION
The Import-WslDistribution cmdlet imports each of the specified gzipped tarball files to a WSL
distribution. to a gzipped.

By default, this cmdlet derives the distribution name from the input file name, and appends that
name to the destination path. This allows you to import multiple distributions.

This cmdlet wraps the functionality of "wsl.exe --import".

.PARAMETER Path
Specifies the path to a .tar.gz file to import. Wildcards are permitted.

.PARAMETER LiteralPath
Specifies the path to a .tar.gz file to import. The value of LiteralPath is used exactly as it is
typed. No characters are interpreted as wildcards.

.PARAMETER Destination
Specifies the destination directory or file name where the imported distribution will be stored. The
distribution name will be appended to this path (e.g. if you specify "D:\wsl" and the distribution
is named "Ubuntu", the distribution will be stored in "D:\wsl\Ubuntu"), unless the RawDestination
parameter is specified.

.PARAMETER Name
Specifies the name of the imported WSL distribution.

By default, this cmdlet uses the base name of the file being imported (e.g. "Ubuntu" if the file
is "Ubuntu.tar.gz"). Note that distribution names can only contain letters, numbers, dashes and
underscores. If the file contains any other characters, you must specify a distribution name.

If you specify a distribution name, you cannot import multiple distributions with one command.

.PARAMETER Version
Specifies the WSL version to use for the imported distribution. By default, this cmdlet uses the
version set with "wsl.exe --set-default-version".

.PARAMETER RawDestination
Indicates that the destination path should be used as is, without appending the distribution name
to it. By default, the distribution name is appended to the path.

If RawDestination is specified, you cannot import multiple distributions with one command.

.PARAMETER Passthru
Returns an object that represents the distribution. By default, this cmdlet does not generate any
output.

.INPUTS
System.String

You can pipe a string that contains a path to this cmdlet.

.OUTPUTS
WslDistribution

The cmdlet returns an object that represent the distribution, if you use the Passthru parameter.
Otherwise, this cmdlet does not generate any output.

.EXAMPLE
Import-WslDistribution D:\backup.tar.gz D:\wsl Ubuntu

Imports the file named D:\backup.tar.gz as a distribution named "Ubuntu" stored in D:\wsl\Ubuntu.

.EXAMPLE
Import-WslDistribution D:\backup.tar.gz D:\wsl\mydistro Ubuntu -RawDestination

Imports the file named D:\backup.tar.gz as a distribution named "Ubuntu" stored in D:\wsl\mydistro.

.EXAMPLE
Import-WslDistribution D:\backup\*.tar.gz D:\wsl

Imports all .tar.gz files from D:\backup to distributions with names based on the file names, stored
in subdirectories of D:\wsl.

.EXAMPLE
Get-Item D:\backup\*.tar.gz -Exclude Ubuntu* | Import-WslDistribution -Destination D:\wsl -Version 2 -Passthru
Name           State Version Default
----           ----- ------- -------
Alpine       Stopped       2   False
Debian       Stopped       2   False

Imports all .tar.gz files, except those whose names start with Ubuntu, as WSL2 distributions stored
in subdirectories of D:\wsl.
#>
function Import-WslDistribution
{
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(Mandatory = $true, Position = 0, ParameterSetName = "Path", ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [SupportsWildcards()]
        [string[]] $Path,
        [Parameter(Mandatory = $true, ParameterSetName = "LiteralPath", ValueFromPipelineByPropertyName = $true)]
        [Alias("PSPath")]
        [ValidateNotNullOrEmpty()]
        [string[]] $LiteralPath,
        [Parameter(Mandatory = $true, Position = 1)]
        [ValidateNotNullOrEmpty()]
        [string]$Destination,
        [Parameter(Mandatory = $false)]
        [string]$Name,
        [Parameter(Mandatory = $false)]
        [int]$Version = 0,
        [Parameter(Mandatory = $false)]
        [Switch]$RawDestination,
        [Parameter(Mandatory = $false)]
        [Switch]$Passthru
    )

    process {
        if ($PSCmdlet.ParameterSetName -eq "Path") {
            $files = Get-Item $Path
        } else {
            $files = Get-Item -LiteralPath $LiteralPath
        }    

        $files | ForEach-Object {
            $distributionName = $Name
            if ($distributionName -eq "") {
                $distributionName = $_.BaseName
                # If the file name is .tar.gz, the base name isn't what we want.
                if ($distributionName.EndsWith(".tar", "OrdinalIgnoreCase")) {
                    $distributionName = $distributionName.Substring(0, $distributionName.Length - 4)
                }
            }

            $distributionDestination = $Destination
            if (-not $RawDestination) {
                $distributionDestination = Join-Path $distributionDestination $distributionName
            }

            $distributionDestination = Get-UnresolvedProviderPath $distributionDestination
            if ($PSCmdlet.ShouldProcess("Path: $($_.FullName), Destination: $distributionDestination, Name: $distributionName", "Import")) {
                $wslArgs = @("--import", $distributionName, $distributionDestination, $_.FullName)
                if ($Version -ne 0) {
                    $wslArgs += @("--version", $Version)
                }

                Invoke-Wsl $wslArgs | Out-Null
            }

            if ($Passthru) {
                Get-WslDistribution $DistributionName
            }
        }
    }
}

<#
.SYNOPSIS
Runs a command in one or more WSL distributions.

.DESCRIPTION
The Invoke-WslCommand cmdlet executes the specified command on the specified distributions, and
then exits.

This cmdlet will raise an error if executing wsl.exe failed (e.g. there is no distribution with
the specified name) or if the command itself failed.

This cmdlet wraps the functionality of "wsl.exe <command>".

.PARAMETER Command
Specifies the command to run.

.PARAMETER DistributionName
Specifies the distribution names of distributions to run the command in. Wildcards are permitted.
By default, the command is executed in the default distribution.

.PARAMETER Distribution
Specifies WslDistribution objects that represent the distributions to run the command in.
By default, the command is executed in the default distribution.

.PARAMETER User
Specifies the name of a user in the distribution to run the command as. By default, the
distribution's default user is used.

.INPUTS
WslDistribution, System.String

You can pipe a WslDistribution object retrieved by Get-WslDistribution, or a string that contains
the distribution name to this cmdlet.

.OUTPUTS
System.String

This command outputs the result of the command you executed, as text.

.EXAMPLE
Invoke-WslCommand 'ls /etc'

Runs a command in the default distribution.

.EXAMPLE
Invoke-WslCommand 'whoami' -DistributionName Ubuntu* -User root

Runs a command in all distributions whose names start with Ubuntu, as the "root" user.

.EXAMPLE
Get-WslDistribution -Version 2 | Invoke-WslCommand 'echo $(whoami) in $WSL_DISTRO_NAME'

Runs a command in all WSL2 distributions.
#>
function Invoke-WslCommand
{
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]$Command,
        [Parameter(Mandatory = $false, ValueFromPipeline = $true, ParameterSetName = "DistributionName", Position = 1)]
        [ValidateNotNullOrEmpty()]
        [SupportsWildCards()]
        [string[]]$DistributionName,
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = "Distribution")]
        [WslDistribution[]]$Distribution,
        [Parameter(Mandatory = $false, Position = 2)]
        [ValidateNotNullOrEmpty()]
        [string]$User
    )

    process {
        if ($PSCmdlet.ParameterSetName -eq "DistributionName") {
            if ($DistributionName) {
                $distros = Get-WslDistribution $DistributionName
                if (-not $distros) {
                    throw "There is no distribution with the name '$DistributionName'."
                }

            } else {
                $distros = Get-WslDistribution -Default
                if (-not $distros) {
                    throw "There is no default distribution."
                }
            }

        } else {
            $distros = $Distribution
        }

        $distros | ForEach-Object {
            $wslArgs = @("--distribution", $_.Name)
            if ($User) {
                $wslArgs += @("--user", $User)
            }

            # Invoke /bin/sh so the whole command can be passed as a single argument.
            $wslArgs += @("/bin/sh", "-c", $Command)

            if ($PSCmdlet.ShouldProcess($_.Name, "Invoke Command")) {
                &$wslPath $wslArgs
                if ($LASTEXITCODE -ne 0) {
                    # Note: this could be the exit code of wsl.exe, or of the launched command.
                    throw "Wsl.exe returned exit code $LASTEXITCODE"
                }    
            }
        }
    }
}

<#
.SYNOPSIS
Enters a session in a WSL distribution.

.DESCRIPTION
The Enter-WslDistribution cmdlet starts an interactive shell in the specified distribution.

This cmdlet will raise an error if executing wsl.exe failed (e.g. there is no distribution with
the specified name) or if the session exited with an error code.

This cmdlet wraps the functionality of "wsl.exe" with no arguments other than possibly
"--distribution" or "--user".

.PARAMETER Name
Specifies the name of the distribution to enter. Wildcards are NOT permitted.
By default, the command enters the default distribution.

.PARAMETER Distribution
Specifies a WslDistribution object that represent the distributions to enter.
By default, the command is executed in the default distribution.

.PARAMETER User
Specifies the name of a user in the distribution to enter as. By default, the
distribution's default user is used.

.INPUTS
WslDistribution, System.String

You can pipe a WslDistribution object retrieved by Get-WslDistribution, or a string that contains
the distribution name to this cmdlet.

.OUTPUTS
None. This cmdlet does not return any output.

.EXAMPLE
Enter-WslDistribution

Start a shell in the default distribution.

.EXAMPLE
Enter-WslDistribution Ubuntu root

Starts a shell in the distribution named "Ubuntu" using the "root" user.

.EXAMPLE
Import-WslDistribution D:\backup\Alpine.tar.gz D:\wsl -Passthru | Enter-WslDistribution

Imports a WSL distribution and immediately opens a shell in that distribution.
#>
function Enter-WslDistribution
{
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(Mandatory = $false, ValueFromPipeline = $true, ParameterSetName = "DistributionName", Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = "Distribution")]
        [WslDistribution]$Distribution,
        [Parameter(Mandatory = $false, Position = 1)]
        [ValidateNotNullOrEmpty()]
        [string]$User
    )

    process {
        if ($PSCmdlet.ParameterSetName -eq "Distribution") {
            $Name = $Distribution.Name
        }

        $wslArgs = @()
        if ($Name) {
            $wslArgs = @("--distribution", $Name)
        }

        if ($User) {
            $wslArgs = @("--user", $User)
        }

        if ($PSCmdlet.ShouldProcess($Name, "Enter WSL")) {
            &$wslPath $wslArgs
            if ($LASTEXITCODE -ne 0) {
                # Note: this could be the exit code of wsl.exe, or of the shell.
                throw "Wsl.exe returned exit code $LASTEXITCODE"
            }    
        }
    }
}

<#
.SYNOPSIS
Stops all WSL distributions.

.DESCRIPTION
The Stop-Wsl cmdlet terminates all WSL distributions, and for WSL2 also shuts down the lightweight
utility VM.

This cmdlet wraps the functionality of "wsl.exe --shutdown".

.INPUTS
None. This cmdlet does not take any input.

.OUTPUTS
None. This cmdlet does not generate any output.

.EXAMPLE
Stop-Wsl

Shuts down WSL.
#>
function Stop-Wsl
{
    [CmdletBinding(SupportsShouldProcess=$true)]
    param()

    if ($PSCmdlet.ShouldProcess("Wsl", "Shutdown")) {
        Invoke-Wsl "--shutdown"
    }
}

<#
.SYNOPSIS
Returns version information about the Windows Subsystem for Linux.

.DESCRIPTION
Returns the version of the WSL store app, as well as other WSL components such as the Linux kernel
and WSLg.

If WSL is not installed from the Microsoft store and the inbox version of WSL is used, all the
versions will be $null, except for the OS version.

This cmdlet wraps the functionality of "wsl.exe --version".

.INPUTS
None. This cmdlet does not take any input.

.OUTPUTS
WslVersionInfo

The cmdlet returns an object whose properties represent the versions of WSL components.

.EXAMPLE
Get-WslVersion

Wsl      : 1.2.5.0
Kernel   : 5.15.90.1
WslG     : 1.0.51
Msrdc    : 1.2.3770
Direct3D : 1.608.2
DXCore   : 10.0.25131.1002
Windows  : 10.0.22621.2215

Gets WSL version information.
#>
function Get-WslVersion
{
    $output = Invoke-Wsl "--version" -IgnoreErrors | ForEach-Object {
        $value = $_
        $index = $_.LastIndexOf(':')
        if ($index -ge 0) {
            $value = $_.Substring($index + 1).Trim()
        }

        $index = $value.IndexOf('-')
        if ($index -ge 0) {
            $value = $value.Substring(0, $index)
        }

        [Version]::Parse($value)
    }

    $result = [WslVersionInfo]::new()
    if ($output) {
        # This relies on the order of the items returned, which is very fragile, but unfortunately
        # the names are localized so there is no reliable way to determine which items is which.
        $result.Wsl = $output[0]
        $result.Kernel = $output[1]
        $result.WslG = $output[2]
        $result.Msrdc = $output[3]
        $result.Direct3D = $output[4]
        $result.DXCore = $output[5]
        $result.Windows = $output[6]

    } else {
        $result.Windows = [Environment]::OSVersion.Version
    }

    return $result
}

$tabCompletionScript = {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    (Get-WslDistributionHelper).Name | Where-Object { $_ -ilike "$wordToComplete*" } | Sort-Object
}

Register-ArgumentCompleter -CommandName Get-WslDistribution,Stop-WslDistribution,Set-WslDistribution,Remove-WslDistribution,Export-WslDistribution,Enter-WslDistribution -ParameterName Name -ScriptBlock $tabCompletionScript
Register-ArgumentCompleter -CommandName Invoke-WslCommand -ParameterName DistributionName -ScriptBlock $tabCompletionScript

Export-ModuleMember Get-WslDistribution
Export-ModuleMember Stop-WslDistribution
Export-ModuleMember Set-WslDistribution
Export-ModuleMember Remove-WslDistribution
Export-ModuleMember Export-WslDistribution
Export-ModuleMember Import-WslDistribution
Export-ModuleMember Invoke-WslCommand
Export-ModuleMember Enter-WslDistribution
Export-ModuleMember Stop-Wsl
Export-ModuleMember Get-WslVersion
