---
external help file: Wsl-help.xml
Module Name: Wsl
online version: https://github.com/SvenGroot/WslManagementPS/blob/main/docs/Get-WslVersion.md
schema: 2.0.0
---

# Get-WslVersion

## SYNOPSIS

Gets version information about the Windows Subsystem for Linux and its components.

## SYNTAX

```
Get-WslVersion
```

## DESCRIPTION

The `Get-WslVersion` cmdlet gets the version of the WSL store app, as well as other WSL components
such as the Linux kernel and WSLg.

The returned information includes the default distribution version, which is not a version number,
but a number that indicates whether WSL1 or WSL2 is used by default for newly registered
distributions.

If WSL is not installed from the Microsoft Store, and the inbox version of WSL is used, all the
versions will be null, except for the `Windows` version and `DefaultDistroVersion`.

This cmdlet wraps the functionality of `wsl.exe --version`.

## EXAMPLES

### EXAMPLE 1

```powershell
Get-WslVersion
```

```Output
Wsl                  : 1.2.5.0
Kernel               : 5.15.90.1
WslG                 : 1.0.51
Msrdc                : 1.2.3770
Direct3D             : 1.608.2
DXCore               : 10.0.25131.1002
Windows              : 10.0.22621.2215
DefaultDistroVersion : 2
```

This example gets information about the installed version of WSL.

## PARAMETERS

## INPUTS

## OUTPUTS

### WslVersionInfo

The cmdlet returns an object whose properties represent the versions of WSL components. It has the
following properties:

- `Wsl`: The version of the WSL app from the Microsoft Store.
- `Kernel`: The Linux kernel version.
- `WslG`: The version of the WSLg component.
- `Msrdc`: The version of the Microsoft Remote Desktop Client.
- `Direct3D`: The version of the Direct3D component.
- `DXCore`: The version of the DXCore component.
- `Windows`: The Windows operating system version.
- `DefaultDistroVersion`: The version that newly registered distributions will use. `1` for WSL1, and `2` for WSL2.

## NOTES

## RELATED LINKS
