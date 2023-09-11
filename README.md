# WSL Management for PowerShell [![PowerShell Gallery](https://img.shields.io/powershellgallery/v/Wsl)](https://www.powershellgallery.com/packages/Wsl)

WSL Management for PowerShell is a PowerShell module that allows you to manage the Windows Subsystem
for Linux (WSL), and its distributions. It provides PowerShell-friendly ways to retrieve information
about distributions, change their settings, import and export them, terminate them, and remove them.

This module wraps the various functions of `wsl.exe` in PowerShell cmdlets, making it easier to
script each operation. In addition, it provides *tab completion* of distribution names for all the
commands.

This module has been tested using the inbox WSL version of Windows 10 21h2 (the oldest version still
in mainstream support as of this writing), and using the most recent version of WSL from the
Microsoft Store (version 1.2.5 as of this writing). If you find any problems with other versions
(especially newer store versions), please file an
[issue](https://github.com/SvenGroot/WslManagementPS/issues).

This module supports both Windows PowerShell and cross-platform
[PowerShell](https://github.com/PowerShell/PowerShell). It can also be run on PowerShell on Linux
inside WSL itself, although not all features are available in this mode.

## Why use this module?

This module offers the following advantages over plain `wsl.exe`:

- Provides information in PowerShell objects to make it easier to access, filter, and script.
- Provides additional distribution information such as the the installation folder and VHD location.
- Tab completion and wildcard support for distribution names.
- Easily perform operations on multiple distributions (e.g. stop or export/import multiple
  distributions with a single command, or run a Linux command on multiple distributions).

## Installing the module

The WSL PowerShell module is available on [PowerShell Gallery](https://www.powershellgallery.com/packages/Wsl),
and can be installed with the `Install-Module` command:

```powershell
Install-Module Wsl
```

You can also download the the project from a GitHub release, and copy the files to a folder named
Wsl somewhere in your `$env:PSModulePath`.

## Provided commands

Below, all the commands provided by the module are briefly explained. For more detailed information,
including all parameters and additional examples, follow links for each command or use `Get-Help`
in PowerShell.

### Get-WslDistribution

The [`Get-WslDistribution`][] cmdlet gets information about WSL distributions installed for the
current user.

This cmdlet wraps the functionality of `wsl.exe --list --verbose`.

Without parameters, it returns all installed distributions.

```powershell
Get-WslDistribution
```

Which could provide the following output, for example:

```text
Name           State Version Default
----           ----- ------- -------
Ubuntu       Stopped       2    True
Ubuntu-22.04 Running       1   False
Alpine       Running       2   False
Debian       Stopped       1   False
```

You can also filter the output using the parameters, by name, version, or state.

The name supports wildcards; for example, you can retrieve all distributions whose name starts with
"Ubuntu".

```powershell
Get-WslDistribution "Ubuntu*"
```

> Note: all cmdlets in this module support wildcards and tab completion on the distribution name.

To return all running distributions:

```powershell
Get-WslDistribution -State Running
```

To return all WSL2 distributions.

```powershell
Get-WslDistribution -Version 2
```

You can also get only the default distribution.

```powershell
Get-WslDistribution -Default
```

The returned object's type is a custom `WslDistribution` class defined by the module. It has the
following properties:

Property         | Type                 | Value
-----------------|----------------------|-------------------------------------------------------------------------------------------------------------------------------------------
`Name`           | System.String        | The distribution name.
`State`          | WslDistributionState | An enumeration that indicates the current state of the distribution (`Stopped`, `Running`, `Installing`, `Uninstalling`, or `Converting`).
`Version`        | System.Int32         | Indicates whether this distribution uses WSL1 or WSL2.
`Default`        | System.Boolean       | Indicates whether this is the default distribution.
`Guid`           | System.Guid          | The identifier for the distribution used in the registry and by WSL internally.
`BasePath`       | System.String        | The full path to the install location of the distribution.
`VhdPath`        | System.String        | The full path to the distribution's VHD file. This is only set for WSL2 distributions.
`FileSystemPath` | System.String        | The UNC path to use to access the distribution's file system, in the form `\\wsl.localhost\<distro>`.

### Set-WslDistribution

The [`Set-WslDistribution`][] cmdlet changes the settings of a WSL distribution. You can set a
distribution as default, or convert it between WSL1 and WSL2.

This cmdlet wraps the functionality of `wsl.exe --set-default` and `wsl.exe --set-version`.

For example, to set Debian as the default:

```powershell
Set-WslDistribution "Debian" -Default
```

To convert all WSL1 distributions to WSL2

```powershell
Get-WslDistribution -Version 1 | Set-WslDistribution -Version 2
```

### Stop-WslDistribution

The [`Stop-WslDistribution`][] cmdlet terminates a WSL distribution.

This cmdlet wraps the functionality of `wsl.exe --terminate`.

For example, to stop all distributions whose name starts with Ubuntu:

```powershell
Stop-WslDistribution "Ubuntu*"
```

To stop all running distributions (this avoids showing a warning for non-running distributions):

```powershell
Get-WslDistribution -State Running | Stop-WslDistribution
```

### Remove-WslDistribution

The [`Remove-WslDistribution`][] cmdlet unregisters a WSL distribution.

This cmdlet wraps the functionality of `wsl.exe --unregister`.

:warning: This cmdlet will permanently remove a distribution and all the data stored in its file
system without prompting for confirmation, unless you use `-Confirm`. You can use the `-WhatIf`
parameter to test a command without actually removing anything.

For example, to remove the distribution named "Ubuntu":

```powershell
Remove-WslDistribution "Ubuntu"
```

To remove all WSL1 distributions:

```powershell
Get-WslDistribution -Version 1 | Remove-WslDistribution
```

### Export-WslDistribution

The [`Export-WslDistribution`][] cmdlet Exports a WSL distribution to a gzipped tarball (`.tar.gz`)
or VHD (`.vhdx`) file.

You can export multiple distributions in a single command by specifying an existing directory as the
destination. In this case, this cmdlet will automatically create files using the distribution name
with the extension `.tar.gz` or `.vhdx`.

This cmdlet wraps the functionality of `wsl.exe --export`.

For example, to export all WS1 distributions to a directory (the directory `D:\backup` has to exist
before running the command):

```powershell
Get-WslDistribution -Version 1 | Export-WslDistribution -Destination D:\backup
```

WSL2 distributions can also be exported in VHD format.

```powershell
Get-WslDistribution -Version 2 | Export-WslDistribution -Destination D:\backup -Format "Vhd"
```

### Import-WslDistribution

The [`Import-WslDistribution`][] cmdlet imports a WSL distribution from a gzipped tarball
(`.tar.gz`) or VHD (`.vhdx`) file.

By default, this cmdlet derives the distribution name from the input file name, and appends that
name to the destination path. This allows you to import multiple distributions using a single
command.

This cmdlet wraps the functionality of `wsl.exe --import`.

For example, to import all `.tar.gz` files from a directory, storing them in subdirectories under
`D:\wsl`:

```powershell
Import-WslDistribution D:\backup\*.tar.gz D:\wsl
```

When importing VHD files, you can choose to copy them to a destination, or you can register them
in place:

```powershell
Import-WslDistribution D:\backup\*.vhdx -InPlace
```

### Invoke-WslCommand

The [`Invoke-WslCommand`][] cmdlet runs a command in a WSL distribution, returning the output as
strings.

This cmdlet will throw an exception if executing `wsl.exe` failed (e.g. there is no distribution
with the specified name) or if the command returned a non-zero exit code.

This cmdlet wraps the functionality of `wsl.exe <command>`.

You can use the cmdlet's parameters to specify the distribution name, Linux user, working directory,
and shell type.

For example, run a command in all WSL2 distributions as the Linux "root" user:

```powershell
Get-WslDistribution -Version 2 | Invoke-WslCommand 'echo $(whoami) in $WSL_DISTRO_NAME' -User root
```

Instead of providing a single quoted command, you can also use the `-RawCommand` parameter to
specify the command without quoting it, similar to how `wsl.exe` itself works:

```powershell
Get-WslDistribution -Version 2 | Invoke-WslCommand -RawCommand -User root -- echo $`(whoami`) in `$WSL_DISTRO_NAME
```

Using `--` is not required, but it ensures that nothing after it is interpreted as a parameter to
the cmdlet itself.

### Enter-WslDistribution

The [`Enter-WslDistribution`][] cmdlet starts an interactive session in a WSL distribution.

This cmdlet will raise an error if executing `wsl.exe` failed (e.g. there is no distribution with
the specified name) or if the session exited with a non-zero exit code.

This cmdlet wraps the functionality of `wsl.exe` without specifying a command.

The main advantage of using this cmdlet over plain `wsl.exe` is the availability of tab completion
on the distribution name, or the ability to pipe in a `WslDistribution` retrieved from another
command.

For example, to enter the Ubuntu distribution as the user root:

```powershell
Enter-WslDistribution Ubuntu root
```

To import a distribution and immediately start a session in it:

```powershell
Import-WslDistribution D:\backup\Alpine.tar.gz D:\wsl | Enter-WslDistribution
```

### Get-WslVersion

The [`Get-WslVersion`][] cmdlet provides version information about the Windows Subsystem for Linux
and its components. It also indicates whether WSL1 or WSL2 is the default.

For example:

```powershell
Get-WslVersion
```

Which outputs:

```text
Wsl                  : 1.2.5.0
Kernel               : 5.15.90.1
WslG                 : 1.0.51
Msrdc                : 1.2.3770
Direct3D             : 1.608.2
DXCore               : 10.0.25131.1002
Windows              : 10.0.22621.2215
DefaultDistroVersion : 2
```

The output of this command is a `WslVersionInfo` object, with the properties shown above. All
properties use the type `System.Version`, except for `DefaultDistroVersion` which is a
`System.Int32`.

If you are using the inbox version of WSL, all properties except for `Windows` and
`DefaultDistroVersion` will be null.

### Stop-Wsl

The [`Stop-Wsl`][] cmdlet terminates all WSL distributions, and for WSL2 also shuts down the
lightweight utility VM.

This cmdlet wraps the functionality of `wsl.exe --shutdown`.

There is no benefit to using this over `wsl.exe --shutdown`. It is provided purely for the sake of
completionism.

## Testing and documentation

This module uses tests written using [Pester](https://pester.dev/). To execute the tests, clone the
repository and run `Invoke-Pester` in the repository's root directory.

:warning: The tests assume that the current user does not have any WSL distributions installed prior
to running the tests. If there are pre-existing distributions, you will see a bunch of test failures.

The tests are written so that pre-existing distributions should not be deleted, unless you have
distributions whose name starts with "wslps_". However, if you are testing changes, bugs in the
module or the tests could cause data loss, so it's strongly recommended to ensure you have no
existing distributions before executing the tests.

The tests download a tarball for the Alpine distribution, which is used to create distributions for
testing. You can also use a custom tarball by invoking `Wsl.Tests.ps1` directly, using the
`-TestDistroPath` parameter.

This module uses [PlatyPS](https://github.com/PowerShell/platyPS) to generate an external
documentation file. Markdown sources for the documentation are in the [docs](docs/) directory.

[`Enter-WslDistribution`]: docs/Enter-WslDistribution.md
[`Export-WslDistribution`]: docs/Export-WslDistribution.md
[`Get-WslDistribution`]: docs/Get-WslDistribution.md
[`Get-WslVersion`]: docs/Get-WslVersion.md
[`Import-WslDistribution`]: docs/Import-WslDistribution.md
[`Invoke-WslCommand`]: docs/Invoke-WslCommand.md
[`Remove-WslDistribution`]: docs/Remove-WslDistribution.md
[`Set-WslDistribution`]: docs/Set-WslDistribution.md
[`Stop-Wsl`]: docs/Stop-Wsl.md
[`Stop-WslDistribution`]: docs/Stop-WslDistribution.md
