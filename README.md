# WSL Management PowerShell module

This is a PowerShell module that allows you to manage the WSL (Windows Subsystem for Linux)
distributions on your computer. It lets you retrieve information about the distributions,
change their configuration, import/export them, terminate them, and remove them, in a
PowerShell-friendly way.

Essentially, this module wraps the various command-line arguments of "wsl.exe" in PowerShell cmdlets,
making it easier to script the various options. In addition, it provides _tab completion_ of
distribution names for all the commands.

This module suppors both Windows PowerShell and PowerShell Core. It can also be run on PowerShell
Core for Linux in WSL itself, although a few features aren't available.

# Why use this module?

This module offers the following advantages over plain wsl.exe:

- Parses the output of wsl.exe into PowerShell objects to make the information easier to access.
- Makes it easy to access additional distribution information such as the the install folder.
- Tab completion and wildcard support for distribution names on the command line.
- Easily perform operations on multiple distributions (e.g. stop or export/import multiple
  distributions with a single command, or run a Linux command on multiple distributions).

## Installing the module

Download the the project as a ZIP file, and copy the files to a folder named Wsl in your `$PSModulePath`.

## Provided commands

The following cmdlets are provided. More information and examples are provided by running `Get-Help`
for each cmdlet.

### Get-WslDistribution

The **Get-WslDistribution** cmdlet gets objects that represent the WSL distributions on the computer.

This cmdlet wraps the functionality of `wsl.exe --list --verbose`.

For example:

```powershell
Get-WslDistribution

Name           State Version Default
----           ----- ------- -------
Ubuntu       Stopped       2    True
Ubuntu-18.04 Running       1   False
Alpine       Running       2   False
Debian       Stopped       1   False
```

You can also filter the output using the arguments, by version, state, or default.

For example, to return the default distribution

```powershell
Get-WslDistribution -Default
```

To return all running distributions:

```powershell
Get-WslDistribution -State Running
```

To return all distributions whose name starts with "Ubuntu".

```powershell
Get-WslDistribution Ubuntu*
```

> Note: all cmdlets in this module support wildcards and tab completion on the distribution name.

The returned object is a custom `WslDistribution` class defined by the module. It has the following
properties:

- `Name`: The distribution name.
- `State`: An enumeration that indicates the current state of the distribution.
- `Version`: Indicates whether this distribution uses WSL1 or WSL2.
- `Default`: A boolean that indicates whether this is the default distribution.
- `Guid`: The identifier for the distribution used in the registry and by WSL internally. This
    property is not available if you use this module in Linux PowerShell Core under WSL.
- `BasePath`: The install location of the distribution. This property is not available if you use
    this module in Linux PowerShell Core under WSL.
    > Note: for WSL1 distributions, it's *strongly* not recommended to access your Linux files
      through this path.
- `FileSystemPath`: The path to use to access the distribution's file system, in the form `\\wsl$\distro`.

### Set-WslDistribution

The **Set-WslDistribution** cmdlet changes the properties of a WSL distribution. You can set a
distribution as default, or convert it from WSL1 to WSL2 or vice versa.

This cmdlet wraps the functionality of `wsl.exe --set-default` and `wsl.exe --set-version`.

For example, to set Debian as the default:

```powershell
Set-WslDistribution Debian -Default
```

To convert all WSL1 distributions to WSL2

```powershell
Get-WslDistribution -Version 1 | Set-WslDistribution -Version 2
```

### Stop-WslDistribution

The **Stop-WslDistribution** cmdlet terminates each of the specified WSL distributions.

This cmdlet wraps the functionality of `wsl.exe --terminate`.

For example, to stop all distributions starting with Ubuntu:

```powershell
Stop-WslDistribution Ubuntu*
```

To stop all running distributions (this avoids the warning for non-running distributions):

```powershell
Get-WslDistribution -State Running | Stop-WslDistribution
```

### Remove-WslDistribution

The **Remove-WslDistribution** cmdlet unregisters each of the specified WSL distributions.

This cmdlet wraps the functionality of `wsl.exe --unregister`.

For example, to remove the Ubuntu distribution:

```powershell
Remove-WslDistribution Ubuntu
```

To remove all WSL1 distributions

```powershell
Get-WslDistribution -Version 1 | Remove-WslDistribution
```

### Export-WslDistribution

The **Export-WslDistribution** cmdlet exports each of the specified WSL distributions to a gzipped
tarball (.tar.gz file).

You can export multiple distributions by specifying a directory as the Destination. In this case,
this cmdlet will automatically create files using the distribution name with the extension .tar.gz.

This cmdlet wraps the functionality of `wsl.exe --export`.

For example, to export all WSL2 distributions to a directory:

```powershell
Get-WslDistribution -Version 2 | Export-WslDistribution -Destination D:\backup
```

### Import-WslDistribution

The **Import-WslDistribution** cmdlet imports each of the specified gzipped tarball files to a WSL
distribution. to a gzipped.

By default, this cmdlet derives the distribution name from the input file name, and appends that
name to the destination path. This allows you to import multiple distributions.

This cmdlet wraps the functionality of `wsl.exe --import`.

For example, to import all .tar.gz files from a directory, storing them in subdirectories under
D:\\wsl:

```powershell
Import-WslDistribution D:\backup\*.tar.gz D:\wsl
```

### Invoke-WslCommand

The **Invoke-WslCommand** cmdlet executes the specified command on the specified distributions, and
then exist.

This cmdlet will raise an error if executing wsl.exe failed (e.g. there is no distribution with
the specified name) or if the command itself failed.

This cmdlet wraps the functionality of `wsl.exe <command>`.

You can use the arguments to specify the distribution name and user.

For example, run a command in all WSL2 distributions:

```powershell
Get-WslDistribution -Version 2 | Invoke-WslCommand 'echo $(whoami) in $WSL_DISTRO_NAME' -User root
```

### Stop-Wsl

The **Stop-Wsl** cmdlet terminates all WSL distributions, and for WSL2 also shuts down the lightweight
utility VM.

This cmdlet wraps the functionality of `wsl.exe --shutdown`.