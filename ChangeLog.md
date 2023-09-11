# What's new in the WSL Management PowerShell module

## Version 2.0

- Improvements to the [`Import-WslDistribution`][] and [`Export-WslDistribution`][] cmdlets.
  - Support importing and exporting VHD files, including importing a VHD in place.
  - [`Export-WslDistribution`][] now returns information about the created files, rather than the
    distributions.
  - The `-Passthru` parameter has been removed from these cmdlets, and they now always return
    values.
  - Accept paths with custom PowerShell drives, as long as they use the file system provider.
- The [`Invoke-WslCommand`][] and [`Enter-WslDistribution`][] cmdlets support specifying the working
  directory and shell type, and support the system distribution.
- The [`Invoke-WslCommand`][] cmdlet supports specifying a command without quoting it, when using
  the `-RawCommand` parameter.
- The [`Invoke-WslCommand`][] cmdlet supports running commands using WSLg.
- Added a [`Get-WslVersion`][] command that returns an object with version information about WSL and
  its components.
- The [`Get-WslDistribution`][] cmdlet no longer throws an exception if there are no installed WSL
  distributions; instead, it just returns no items.
- Added the `WslDistribution.VhdPath` property for WSL2 distributions.
- The `WslDistribution.FileSystemPath` property uses the `\\wsl.localhost` prefix instead of
  `\\wsl$`.
- The module now works if the `WSL_UTF8` environment variable is set.
- Added aliases for several parameters on the cmdlets.
- Various bug fixes.

## Version 1.0 (2019-10-23)

- This is the first release of the WSL Management PowerShell module.

[`Enter-WslDistribution`]: docs/Enter-WslDistribution.md
[`Export-WslDistribution`]: docs/Export-WslDistribution.md
[`Get-WslDistribution`]: docs/Get-WslDistribution.md
[`Get-WslVersion`]: docs/Get-WslVersion.md
[`Import-WslDistribution`]: docs/Import-WslDistribution.md
[`Invoke-WslCommand`]: docs/Invoke-WslCommand.md
