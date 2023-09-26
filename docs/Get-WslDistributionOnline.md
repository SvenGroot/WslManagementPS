---
external help file: Wsl-help.xml
Module Name: Wsl
online version: https://github.com/SvenGroot/WslManagementPS/blob/main/docs/Get-WslDistributionOnline.md
schema: 2.0.0
---

# Get-WslDistributionOnline

## SYNOPSIS

Gets information about WSL distributions available from online sources.

## SYNTAX

```
Get-WslDistributionOnline [<CommonParameters>]
```

## DESCRIPTION

The `Get-WslDistributionOnline` cmdlet gets information about all the WSL distributions available from online sources.

This cmdlet wraps the functionality of `wsl.exe --list --online`.

## EXAMPLES

### EXAMPLE 1

```powershell
Get-WslDistributionOnline
```

```Output
Name                                FriendlyName
----                                ------------
Ubuntu                              Ubuntu
Debian                              Debian GNU/Linux
kali-linux                          Kali Linux Rolling
Ubuntu-18.04                        Ubuntu 18.04 LTS
Ubuntu-20.04                        Ubuntu 20.04 LTS
Ubuntu-22.04                        Ubuntu 22.04 LTS
OracleLinux_7_9                     Oracle Linux 7.9
OracleLinux_8_7                     Oracle Linux 8.7
OracleLinux_9_1                     Oracle Linux 9.1
openSUSE-Leap-15.5                  openSUSE Leap 15.5
SUSE-Linux-Enterprise-Server-15-SP4 SUSE Linux Enterprise Server 15 SP4
SUSE-Linux-Enterprise-15-SP5        SUSE Linux Enterprise 15 SP5
openSUSE-Tumbleweed                 openSUSE Tumbleweed
```

This example lists all WSL distributions available from online sources.

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

None

## OUTPUTS

### WslDistributionOnline

This cmdlet returns objects that represent the distributions available from online sources. This object has the
following properties:

- `Name`: The distribution name.
- `FriendlyName`: The Friendly Name for the distribution.

## NOTES

## RELATED LINKS

[Get-WslDistribution](Get-WslDistribution.md)

[Enter-WslDistribution](Enter-WslDistribution.md)

[Export-WslDistribution](Export-WslDistribution.md)

[Import-WslDistribution](Import-WslDistribution.md)

[Invoke-WslCommand](Invoke-WslCommand.md)

[Remove-WslDistribution](Remove-WslDistribution.md)

[Set-WslDistribution](Remove-WslDistribution.md)

[Stop-WslDistribution](Remove-WslDistribution.md)
