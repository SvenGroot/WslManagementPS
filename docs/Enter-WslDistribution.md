---
external help file: Wsl-help.xml
Module Name: Wsl
online version:
schema: 2.0.0
---

# Enter-WslDistribution

## SYNOPSIS
Enters a session in a WSL distribution.

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
The Enter-WslDistribution cmdlet starts an interactive shell in the specified distribution.

This cmdlet will raise an error if executing wsl.exe failed (e.g.
there is no distribution with
the specified name) or if the session exited with an error code.

This cmdlet wraps the functionality of "wsl.exe" with no arguments other than possibly
"--distribution" or "--user".

## EXAMPLES

### EXAMPLE 1
```
Enter-WslDistribution
```

Start a shell in the default distribution.

### EXAMPLE 2
```
Enter-WslDistribution Ubuntu root
```

Starts a shell in the distribution named "Ubuntu" using the "root" user.

### EXAMPLE 3
```
Import-WslDistribution D:\backup\Alpine.tar.gz D:\wsl -Passthru | Enter-WslDistribution
```

Imports a WSL distribution and immediately opens a shell in that distribution.

## PARAMETERS

### -Distribution
Specifies a WslDistribution object that represent the distributions to enter.
By default, the command is executed in the default distribution.

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
Specifies the name of the distribution to enter.
Wildcards are NOT permitted.
By default, the command enters the default distribution.

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
Specifies the shell type to use for the command, either "Standard" or "Login".

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
Specifies the name of a user in the distribution to enter as.
By default, the
distribution's default user is used.

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
Specifies the working directory to use for the session.
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

### None. This cmdlet does not return any output.
## NOTES

## RELATED LINKS
