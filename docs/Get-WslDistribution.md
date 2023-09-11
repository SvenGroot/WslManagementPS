---
external help file: Wsl-help.xml
Module Name: Wsl
online version: https://github.com/SvenGroot/WslManagementPS/blob/main/docs/Stop-WslDistribution.md
schema: 2.0.0
---

# Get-WslDistribution

## SYNOPSIS

Gets information about WSL distributions installed for the current user.

## SYNTAX

```
Get-WslDistribution [[-Name] <String[]>] [-Default] [[-State] <WslDistributionState>] [[-Version] <Int32>]
 [<CommonParameters>]
```

## DESCRIPTION

The `Get-WslDistribution` cmdlet gets information about all the WSL distributions installed for the
current user.

You can filter the output using the parameters of this cmdlet. Use the **Name** parameter to only
return distributions with the specified name, supporting wildcards. Use the **Default** parameter to
return only the default distribution. The **State** parameter filters by states such as `Running` or
`Stopped`, and the **Version** parameter selects only WSL1 or WSL2 distributions.

This cmdlet wraps the functionality of `wsl.exe --list --verbose`.

## EXAMPLES

### EXAMPLE 1

```powershell
Get-WslDistribution
```

```Output
Name           State Version Default
----           ----- ------- -------
Ubuntu       Stopped       2    True
Ubuntu-22.04 Running       1   False
Alpine       Running       2   False
Debian       Stopped       1   False
```

This example lists all WSL distributions.

### EXAMPLE 2

```powershell
Get-WslDistribution -Default
```

```Output
Name           State Version Default
----           ----- ------- -------
Ubuntu       Stopped       2    True
```

This example retrieves only the default distribution.

### EXAMPLE 3

```powershell
Get-WslDistribution -Version 2 -State Running
```

```Output
Name           State Version Default
----           ----- ------- -------
Alpine       Running       2   False
```

This example gets only those distribution which are running, and are using WSL2.

### EXAMPLE 4

```powershell
Get-WslDistribution "Ubuntu*" | Stop-WslDistribution
```

This example get all distributions whose name starts with `Ubuntu`, and then terminates them.

### EXAMPLE 5

```powershell
Get-Content "distributions.txt" | Get-WslDistribution
```

```Output
Name           State Version Default
----           ----- ------- -------
Ubuntu       Stopped       2    True
Debian       Stopped       1   False
```

This example pipes the contents of a file, containing the names of distributions, to the
`Get-WslDistribution` cmdlet. Only the distributions that are listed in the file are returned.

## PARAMETERS

### -Default

Specifies that only the default distribution should be returned. If combined with other filter
parameters, the default distribution is only returned if it also matches the other filters;
otherwise, nothing is returned.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Name

Specifies the name of a distribution to get detailed information about.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: DistributionName

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: True
```

### -State

Specifies the distribution state (`Stopped`, `Running`, `Installing`, `Uninstalling`, or
`Converting`) to filter the results by. Only distributions in the specified state are returned.

```yaml
Type: WslDistributionState
Parameter Sets: (All)
Aliases:
Accepted values: Stopped, Running, Installing, Uninstalling, Converting

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Version

Specifies the WSL distribution version (1 or 2) to filter the results by. Only distributions using
either WSL1 or WSL2 are returned.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String

You can pipe a distribution name to this cmdlet.

## OUTPUTS

### WslDistribution

This cmdlet returns objects that represent the distributions on the computer. This object has the
following properties:

- `Name`: The distribution name.
- `State`: The current state of the distribution (`Stopped`, `Running`, `Installing`, `Uninstalling`, or `Converting`).
- `Version`: Indicates whether this distribution uses WSL1 or WSL2.
- `Default`: A boolean that indicates whether this is the default distribution.
- `Guid`: The identifier for the distribution used in the registry and by WSL internally.
- `BasePath`: The install location of the distribution.
- `FileSystemPath`: The path to use to access the distribution's file system, in the form `\\wsl.localhost\distro`.
- `VhdPath`: For WSL2 distributions, the path to the VHD file containing the distribution's file system.

The `Guid`, `BasePath`, and `VhdPath` properties will be null if this cmdlet was invoked from
Linux PowerShell inside a WSL distribution.

## NOTES

## RELATED LINKS

[Enter-WslDistribution](Enter-WslDistribution.md)

[Export-WslDistribution](Export-WslDistribution.md)

[Import-WslDistribution](Import-WslDistribution.md)

[Invoke-WslCommand](Invoke-WslCommand.md)

[Remove-WslDistribution](Remove-WslDistribution.md)

[Set-WslDistribution](Remove-WslDistribution.md)

[Stop-WslDistribution](Remove-WslDistribution.md)
