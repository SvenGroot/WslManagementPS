---
external help file: Wsl-help.xml
Module Name: Wsl
online version: https://github.com/SvenGroot/WslManagementPS/blob/main/docs/Invoke-WslCommand.md
schema: 2.0.0
---

# Invoke-WslCommand

## SYNOPSIS

Runs a command in a WSL distribution.

## SYNTAX

### DistributionName

```
Invoke-WslCommand [-Command] <String> [[-DistributionName] <String[]>] [[-User] <String>]
 [-WorkingDirectory <String>] [-ShellType <String>] [-System] [-Graphical] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

### Distribution

```
Invoke-WslCommand [-Command] <String> -Distribution <WslDistribution[]> [[-User] <String>]
 [-WorkingDirectory <String>] [-ShellType <String>] [-System] [-Graphical] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

### DistributionRaw

```
Invoke-WslCommand [-RawCommand] -Distribution <WslDistribution[]> [[-User] <String>]
 [-WorkingDirectory <String>] [-ShellType <String>] [-System] [-Graphical] -Remaining <String[]> [-WhatIf]
 [-Confirm] [<CommonParameters>]
```

### DistributionNameRaw

```
Invoke-WslCommand [-RawCommand] [[-DistributionName] <String[]>] [[-User] <String>]
 [-WorkingDirectory <String>] [-ShellType <String>] [-System] [-Graphical] -Remaining <String[]> [-WhatIf]
 [-Confirm] [<CommonParameters>]
```

## DESCRIPTION

The `Invoke-WslCommand` cmdlet executes a command in a WSL distribution, returning the output of the
command as a string. The distribution to run the command in can be specified by name, or piped in
from the `Get-WslDistribution` cmdlet. If no distribution is specified, the command is executed in
the default distribution.

This cmdlet will throw an exception if executing wsl.exe failed (e.g. if there is no distribution
with the specified name), or if the command exited with an non-zero exit code.

The command to execute can be specified in two ways. The default is using the **Command** parameter,
where you provide the command in a single string, that will be passed to `/bin/sh -c` to execute it.

Alternatively, you can use the **RawCommand** parameter to use all remaining parameters which do not
match a known parameter for this cmdlet as the command. You can use the `--` separator to pass
everything after to the WSL command. In this case, the command will be interpreted by the default
shell configured in the distribution, rather than `/bin/sh`. See the examples for an example of this
usage.

This cmdlet wraps the functionality of `wsl.exe <command>`. If using the **Graphical** parameter, it
instead wraps `wslg.exe <command>`.

## EXAMPLES

### EXAMPLE 1

```powershell
Invoke-WslCommand "ls /etc"
```

This example runs a command in the default distribution.

### EXAMPLE 2

```powershell
Invoke-WslCommand "whoami" -DistributionName "Ubuntu*" -User "root"
```

This example runs a command in all distributions whose name starts with "Ubuntu", as the "root"
Linux user.

### EXAMPLE 3

```powershell
Get-WslDistribution -Version 2 | Invoke-WslCommand 'echo $(whoami) in $WSL_DISTRO_NAME'
```

This example runs a command in all WSL2 distributions. Single quotes are used to prevent the dollar
sign from being interpreted by PowerShell without needing to escape them, instead passing them to
the Linux shell.

### EXAMPLE 4

```powershell
Invoke-WslCommand -RawCommand echo Hello, $`(whoami`)
```

This example uses the **RawCommand** parameter, so all unrecognized remaining parameters will form
the command, without needing to quote it. Characters that would be interpreted by PowerShell need to
be escaped with a backtick.

### EXAMPLE 5

```powershell
Invoke-WslCommand -RawCommand -- ls -u
```

This example uses the **RawCommand** parameter, and uses the `--` separator to use everything after
it as part of the Linux command, even if it's a valid parameter for `Invoke-WslCommand`. This
prevents `-u` from being interpreted as an alias for the **User** argument.

## PARAMETERS

### -Command

Specifies the command to run.

```yaml
Type: String
Parameter Sets: DistributionName, Distribution
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Distribution

Specifies the distribution to run the command in.

```yaml
Type: WslDistribution[]
Parameter Sets: Distribution, DistributionRaw
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -DistributionName

Specifies the name of a distribution to run the command in.

```yaml
Type: String[]
Parameter Sets: DistributionName, DistributionNameRaw
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: True
```

### -Graphical

Specifies that the command should be executed using WSLg. Using this option prevents blocking the
terminal while running GUI applications.

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

### -RawCommand

Specifies that all remaining unrecognized parameters to this cmdlet are used as the command to run.

```yaml
Type: SwitchParameter
Parameter Sets: DistributionRaw, DistributionNameRaw
Aliases:

Required: True
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Remaining

Collects the remaining arguments for the RawCommand switch.

```yaml
Type: String[]
Parameter Sets: DistributionRaw, DistributionNameRaw
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ShellType

Specifies the shell type to use for the command, either `Standard`, `Login`, or `None`. Note that if
you are not using the **RawCommand** parameter, the command is still executed using `/bin/sh` on top
of the selected shell type.

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

Specifies that the command should be executed in the system distribution.

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

Specifies the Linux user to run the command as.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -WorkingDirectory

Specifies the working directory to use for the command. Use `~` for the Linux user's home path. If
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

### System.String

This cmdlet returns the output of the command, as text.

## NOTES

## RELATED LINKS

[Get-WslDistribution](Get-WslDistribution.md)
[Enter-WslDistribution](Enter-WslDistribution.md)
