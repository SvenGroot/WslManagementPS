---
external help file: Wsl-help.xml
Module Name: Wsl
online version: https://github.com/SvenGroot/WslManagementPS/blob/main/docs/Stop-WslDistribution.md
schema: 2.0.0
---

# Stop-WslDistribution

## SYNOPSIS

Terminates a WSL distribution.

## SYNTAX

### DistributionName

```
Stop-WslDistribution [-Name] <String[]> [-Passthru] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### Distribution

```
Stop-WslDistribution -Distribution <WslDistribution[]> [-Passthru] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION

The `Stop-WslDistribution` cmdlet terminates a WSL distribution. The distribution to stop can be
specified by name, or piped in from the `Get-WslDistribution` cmdlet.

This cmdlet wraps the functionality of `wsl.exe --terminate`.

## EXAMPLES

### EXAMPLE 1

```powershell
Stop-WslDistribution "Ubuntu"
```

This example stops the distribution named "Ubuntu".

### EXAMPLE 2

```powershell
Stop-WslDistribution "Ubuntu*"
```

This example terminates all distributions whose name starts with "Ubuntu".

### EXAMPLE 3

```powershell
Get-WslDistribution -Version 2 | Stop-WslDistribution -Passthru
```

```Output
Name           State Version Default
----           ----- ------- -------
Ubuntu       Stopped       2    True
Alpine       Stopped       2   False
```

This example terminates all WSL2 distributions. It uses the **Passthru** parameter to return the
WslDistribution objects for the affected distributions.

## PARAMETERS

### -Distribution

Specifies the distribution to be terminated.

```yaml
Type: WslDistribution[]
Parameter Sets: Distribution
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Name

Specifies the name of a distribution to be terminated.

```yaml
Type: String[]
Parameter Sets: DistributionName
Aliases: DistributionName

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: True
```

### -Passthru

Specifies that a WslDistribution object is to be passed through to the pipeline representing the
distribution to be shutdown.

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

### None by default; WslDistribution if PassThru is specified

See `Get-WslDistribution` for more information.

## NOTES

## RELATED LINKS

[Get-WslDistribution](Get-WslDistribution.md)
