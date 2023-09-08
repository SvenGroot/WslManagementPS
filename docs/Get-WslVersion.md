---
external help file: Wsl-help.xml
Module Name: Wsl
online version:
schema: 2.0.0
---

# Get-WslVersion

## SYNOPSIS
Returns version information about the Windows Subsystem for Linux.

## SYNTAX

```
Get-WslVersion
```

## DESCRIPTION
Returns the version of the WSL store app, as well as other WSL components such as the Linux kernel
and WSLg.

The DefaultDistroVersion property of the returned object is not a version number, but instead
indicates whether WSL1 or WSL2 will be used for newly created distributions that don't explicitly
set their version.

If WSL is not installed from the Microsoft store and the inbox version of WSL is used, all the
versions will be $null, except for the Windows version and DefaultDistroVersion.

This cmdlet wraps the functionality of "wsl.exe --version".

## EXAMPLES

### EXAMPLE 1
```
Get-WslVersion
```

Wsl                  : 1.2.5.0
Kernel               : 5.15.90.1
WslG                 : 1.0.51
Msrdc                : 1.2.3770
Direct3D             : 1.608.2
DXCore               : 10.0.25131.1002
Windows              : 10.0.22621.2215
DefaultDistroVersion : 2

Gets WSL version information.

## PARAMETERS

## INPUTS

### None. This cmdlet does not take any input.
## OUTPUTS

### WslVersionInfo
### The cmdlet returns an object whose properties represent the versions of WSL components.
## NOTES

## RELATED LINKS
