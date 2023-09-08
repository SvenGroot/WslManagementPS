---
external help file: Wsl-help.xml
Module Name: Wsl
online version:
schema: 2.0.0
---

# Invoke-WslCommand

## SYNOPSIS
Runs a command in one or more WSL distributions.

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
The Invoke-WslCommand cmdlet executes the specified command on the specified distributions, and
then exits.

This cmdlet will raise an error if executing wsl.exe failed (e.g.
there is no distribution with
the specified name) or if the command itself failed.

The command to execute can be specified in two ways.
The default is using the Command argument,
which provides it as a single string that will be passed to /bin/sh to execute.
Alternatively, you
can use the RawCommand argument to use all remaining arguments which do not match an argument to
this cmdlet as the command.
You can use the -- separator to pass everything after to the WSL command.
See the examples for an example of this usage.

This cmdlet wraps the functionality of "wsl.exe \<command\>".

## EXAMPLES

### EXAMPLE 1
```
Invoke-WslCommand 'ls /etc'
```

Runs a command in the default distribution.

### EXAMPLE 2
```
Invoke-WslCommand 'whoami' -DistributionName Ubuntu* -User root
```

Runs a command in all distributions whose names start with Ubuntu, as the "root" user.

### EXAMPLE 3
```
Get-WslDistribution -Version 2 | Invoke-WslCommand 'echo $(whoami) in $WSL_DISTRO_NAME'
```

Runs a command in all WSL2 distributions.

### EXAMPLE 4
```
Invoke-WslCommand -RawCommand echo Hello, $`(whoami`)
```

Uses the remaining arguments as the command.
Characters that would be interpreted by PowerShell need
to be escaped.

### EXAMPLE 5
```
Invoke-WslCommand -RawCommand -- ls -u
```

Uses the remaining arguments as the command.
The -- separator makes sure the -u token is part of the
command, and not interpreted by PowerShell as an alias for the User argument.

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
Specifies WslDistribution objects that represent the distributions to run the command in.
By default, the command is executed in the default distribution.

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
Specifies the distribution names of distributions to run the command in.
Wildcards are permitted.
By default, the command is executed in the default distribution.

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
Run the command using WSLg.
Using this option prevents blocking the terminal while running GUI
applications.

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
Uses all remaining arguments to this cmdlet as the command to run.

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
Specifies the shell type to use for the command, either "Standard", "Login", or "None".
Note that if
you are not using the RawCommand switch, the command is still executed using /bin/sh on top of the
selected shell type.

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
Specifies the name of a user in the distribution to run the command as.
By default, the
distribution's default user is used.

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
Specifies the working directory to use for the command.
Use "~" for the Linux user's home path.
If
the path starts with a "/" character, it will be interpreted as an absolute Linux path.
Otherwise,
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

### WslDistribution, System.String
### You can pipe a WslDistribution object retrieved by Get-WslDistribution, or a string that contains
### the distribution name to this cmdlet.
## OUTPUTS

### System.String
### This command outputs the result of the command you executed, as text.
## NOTES

## RELATED LINKS
