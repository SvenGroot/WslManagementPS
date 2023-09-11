---
external help file: Wsl-help.xml
Module Name: Wsl
online version: https://github.com/SvenGroot/WslManagementPS/blob/main/docs/Enter-WslDistribution.md
schema: 2.0.0
---

# Enter-WslDistribution

## SYNOPSIS

Starts an interactive session in a WSL distribution.

## SYNTAX

### DistributionName

```
Enter-WslDistribution [[-Name] <String>] [[-User] <String>] [-WorkingDirectory <String>] [-ShellType <String>]
 [-System] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### Distribution

```
Enter-WslDistribution -Distribution <WslDistribution> [[-User] <String>] [-WorkingDirectory <String>]
 [-ShellType <String>] [-System] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION

The `Enter-WslDistribution` cmdlet starts an interactive shell in a WSL distribution. During the
session, all commands that you type run inside the WSL distribution. You can have only one
interactive session at a time.

The distribution to enter can be specified by name, or piped in from the `Get-WslDistribution`
cmdlet. If no distribution is specified, the default distribution will be used.

This cmdlet will throw an exception if executing `wsl.exe` failed (e.g. if there is no distribution
with the specified name), or if the session exited with an non-zero exit code.

This cmdlet wraps the functionality of `wsl.exe` without specifying a command.

## EXAMPLES

### EXAMPLE 1

```powershell
Enter-WslDistribution
```

This example starts a shell in the default distribution.

### EXAMPLE 2

```powershell
Enter-WslDistribution Ubuntu root -WorkingDirectory "~"
```

This example starts a shell in the distribution named "Ubuntu", using the "root" user. The starting
directory will be the Linux user's home directory.

### EXAMPLE 3

```powershell
Import-WslDistribution D:\backup\Alpine.tar.gz D:\wsl | Enter-WslDistribution
```

This example imports a WSL distribution, and immediately starts an interactive session in that
distribution.

## PARAMETERS

### -Distribution

Specifies the distribution to enter.

```yaml
Type: WslDistribution
Parameter Sets: Distribution
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Name

Specifies the name of a distribution to enter. Unlike with other cmdlets in this module, this
parameter does not accept wildcards.

```yaml
Type: String
Parameter Sets: DistributionName
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -ShellType

Specifies the shell type to use for the interactive session, either `Standard` or `Login`.

This parameter requires at least WSL version 0.64.1.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -System

Specifies that the interactive session should use the system distribution.

This parameter requires at least WSL version 0.47.1.

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

### -User

Specifies the Linux user to run the interactive session as. If omitted, the default user for the
distribution is used.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -WorkingDirectory

Specifies the working directory to use for the session. Use `~` for the Linux user's home path. If
the path starts with a `/` character, it will be interpreted as an absolute Linux path. Otherwise,
the value must be a Windows path.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm

Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf

Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### WslDistribution

You can pipe an object retrieved by `Get-WslDistribution` to this cmdlet.

### System.String

You can pipe a distribution name to this cmdlet.

## OUTPUTS

## NOTES

## RELATED LINKS

[Get-WslDistribution](Get-WslDistribution.md)

[Invoke-WslCommand](Invoke-WslCommand.md)
