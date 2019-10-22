enum WslDistributionState {
    Stopped
    Running
    Installing
    Uninstalling
    Converting
}

class WslDistribution
{
    WslDistribution()
    {
        $this | Add-Member -Name FileSystemPath -Type ScriptProperty -Value {
            return "\\wsl$\$($this.Name)"
        }

        $defaultDisplaySet = "Name","State","Version","Default"

        #Create the default property display set
        $defaultDisplayPropertySet = New-Object System.Management.Automation.PSPropertySet("DefaultDisplayPropertySet",[string[]]$defaultDisplaySet)
        $PSStandardMembers = [System.Management.Automation.PSMemberInfo[]]@($defaultDisplayPropertySet)
        $this | Add-Member MemberSet PSStandardMembers $PSStandardMembers
    }

    [string]$Name
    [WslDistributionState]$State
    [int]$Version
    [bool]$Default
    [Guid]$Guid
    [string]$BasePath
}

$wslPath = "$env:windir\system32\wsl.exe"
if (-not [System.Environment]::Is64BitProcess) {
    # Allow launching WSL from 32 bit powershell
    $wslPath = "$env:windir\sysnative\wsl.exe"
}

function Invoke-Wsl
{
    $hasError = $false
    if ($PSVersionTable.PSVersion.Major -lt 6) {
        try {
            $oldOutputEncoding = [System.Console]::OutputEncoding
            [System.Console]::OutputEncoding = [System.Text.Encoding]::Unicode
            $output = &$wslPath $args
            if ($LASTEXITCODE -ne 0) {
                throw "Wsl.exe failed, exit code: $($LASTEXITCODE). Message: $output"
                $hasError = $true
            }

        } finally {
            [System.Console]::OutputEncoding = $oldOutputEncoding
        }

    } else {
        # Using Console.OutputEncoding is currently broken on PowerShell Core, so use an alternative
        # method of starting wsl.exe.
        # See: https://github.com/PowerShell/PowerShell/issues/10789
        $startInfo = New-Object System.Diagnostics.ProcessStartInfo $wslPath
        $args | ForEach-Object { $startInfo.ArgumentList.Add($_) }
        $startInfo.RedirectStandardOutput = $true
        $startInfo.StandardOutputEncoding = [System.Text.Encoding]::Unicode
        $process = [System.Diagnostics.Process]::Start($startInfo)
        $output = @()
        while ($null -ne ($line = $process.StandardOutput.ReadLine())) {
            if ($line.Length -gt 0) {
                $output += $line
            }
        }

        $process.WaitForExit()
        if ($process.ExitCode -ne 0) {
            throw "Wsl.exe failed, exit code: $($process.ExitCode). Message: $output"
            $hasError = $true
        }
    }

    # $hasError is used so there's no output in case error action is silently continue.
    if (-not $hasError) {
        return $output
    }
}

function Get-WslDistributionHelper()
{
    # Use --verbose if it's available.
    if ([System.Environment]::OSVersion.Version.Build -ge 18917) {
        Invoke-Wsl --list --verbose | Select-Object -Skip 1 | ForEach-Object { 
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

    } else {
        # Fall back to the old command line (version will always be 1 in this case).
        # N.B. This is intended for Windows 10 version 1903; this script won't work on older
        #      versions that use wslconfig.exe
        $running = Invoke-Wsl --list --running
        Invoke-Wsl --list | Select-Object -Skip 1 | ForEach-Object {
            $name = $_
            $defaultDistro = $false
            $distroState = [WslDistributionState]::Stopped

            # "Default" is localized to just match on the (), which is illegal in a distribution name.
            $index = $name.IndexOf("(")
            if ($index -ge 0) {
                $defaultDistro = $true
                $name = $name.Substring(0, $index).Trim()
            }

            # Check if it's running.
            # N.B. Other states such as 
            if ($running.Contains($_)) {
                $distroState = [WslDistributionState]::Running
            }

            [WslDistribution]@{
                "Name" = $name
                "State" = $distroState
                "Version" = 1
                "Default" = $defaultDistro
            }
        }
    }
}

function Get-WslDistributionProperties([WslDistribution]$Distribution)
{
    $key = Get-ChildItem "hkcu:\SOFTWARE\Microsoft\Windows\CurrentVersion\Lxss" | Get-ItemProperty | Where-Object { $_.DistributionName -eq $Distribution.Name }
    if ($key.Length -eq 1) {
        $Distribution.DistroGuid = $key.PSChildName
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
Specifies the distribution names of distributions to be retrieved. Wildcards are permited. By
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

        $distributions | ForEach-Object {
            Get-WslDistributionProperties $_
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
Specifies the distribution names of distributions to be terminated. Wildcards are permited.

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
            $Distribution = Get-WslDistribution $Name
        }

        $Distribution | ForEach-Object {
            if ($Distribution.State -ne [WslDistributionState]::Running) {
                Write-Warning "Distribution $($_.Name) is not running."

            } elseif ($PSCmdlet.ShouldProcess($_.Name, "Terminate")) {
                Invoke-Wsl --terminate $_.Name
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
Specifies the distribution names of distributions to be configured. Wildcards are permited.

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
            $Distribution = Get-WslDistribution $Name
        }

        $Distribution | ForEach-Object {
            if ($Version -ne 0) {
                if ($Distribution.Version -eq $Version) {
                    Write-Warning "The distribution '$($Distribution.Name)' is already the requested version."

                } elseif ($PSCmdlet.ShouldProcess($Distribution.Name, "Set Version")) {
                    # Suppress output since it messes with passthru
                    Invoke-Wsl --set-version $Distribution.Name $Version | Out-Null
                }
            }

            if ($Default) {
                if ($Distribution.Default) {
                    Write-Warning "The distribution '$($Distribution.Name)' is already the default."

                } if ($PSCmdlet.ShouldProcess($Distribution.Name, "Set Default")) {
                    Invoke-Wsl --set-default $Distribution.Name | Out-Null
                }
            }

            # Get updated info for pass-through.
            if ($Passthru) {
                Get-WslDistribution $Distribution.Name
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
Specifies the distribution names of distributions to be removed. Wildcards are permited.

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
            $Distribution = Get-WslDistribution $Name
        }

        $Distribution | ForEach-Object {
            if ($PSCmdlet.ShouldProcess($_.Name, "Unregister")) {
                Invoke-Wsl --unregister $_.Name | Out-Null
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
Specifies the distribution names of distributions to be exported. Wildcards are permited.

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
            $Distribution = Get-WslDistribution $Name
        }

        $Distribution | ForEach-Object {
            $fullPath = $Destination
            if (Test-Path $Destination -PathType Container) {
                $fullPath = Join-Path $Destination "$($_.Name).tar.gz"
            }

            if (Test-Path $fullPath) {
                throw "The path '$fullPath' already exists."
            }

            if ($PSCmdlet.ShouldProcess("Name: $($_.Name), Path: $fullPath", "Export")) {
                Invoke-Wsl --export $_.Name $fullPath
            }

            if ($Passthru) {
                $Distribution
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
Specifies the path to a .tar.gz file to import. Wildcards are permited.

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
            $DistributionName = $Name
            if ($DistributionName -eq "") {
                $DistributionName = $_.BaseName
                # If the file name is .tar.gz, the base name isn't what we want.
                if ($DistributionName.EndsWith(".tar", "OrdinalIgnoreCase")) {
                    $DistributionName = $DistributionName.Substring(0, $DistributionName.Length - 4)
                }
            }

            $DistributionDestination = $Destination
            if (-not $RawDestination) {
                $DistributionDestination = Join-Path $DistributionDestination $DistributionName
            }

            if ($PSCmdlet.ShouldProcess("Path: $($_.FullName), Destination: $DistributionDestination, Name: $DistributionName", "Import")) {
                $args = @("--import", $DistributionName, $DistributionDestination, $_.FullName)
                if ($Version -ne 0) {
                    $args += @("--version", $Version)
                }

                Invoke-Wsl @args
            }

            if ($Passthru) {
                Get-WslDistribution $DistributionName
            }
        }
    }
}

function Stop-Wsl
{
    [CmdletBinding(SupportsShouldProcess=$true)]
    param()

    if ($PSCmdlet.ShouldProcess("Wsl", "Shutdown")) {
        Invoke-Wsl --shutdown
    }
}

$tabCompletionScript = {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    (Get-WslDistributionHelper).Name | Where-Object { $_ -ilike "$wordToComplete*" } | Sort-Object
}

Register-ArgumentCompleter -CommandName Get-WslDistribution,Stop-WslDistribution,Set-WslDistribution,Remove-WslDistribution,Export-WslDistribution -ParameterName Name -ScriptBlock $tabCompletionScript

Export-ModuleMember Get-WslDistribution
Export-ModuleMember Stop-WslDistribution
Export-ModuleMember Set-WslDistribution
Export-ModuleMember Remove-WslDistribution
Export-ModuleMember Export-WslDistribution
Export-ModuleMember Import-WslDistribution
Export-ModuleMember Stop-Wsl
