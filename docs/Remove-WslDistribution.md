---
external help file: Wsl-help.xml
Module Name: Wsl
online version: https://github.com/SvenGroot/WslManagementPS/blob/main/docs/Remove-WslDistribution.md
schema: 2.0.0
---

# Remove-WslDistribution

## SYNOPSIS

Unregisters a WSL distribution.

## SYNTAX

### DistributionName

```
Remove-WslDistribution [-Name] <String[]> [-WhatIf] [-Confirm] [<CommonParameters>]
```

### Distribution

```
Remove-WslDistribution -Distribution <WslDistribution[]> [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION

The `Remove-WslDistribution` cmdlet unregisters a WSL distribution. The distribution to remove can
be specified by name, or piped in from the `Get-WslDistribution` cmdlet.

Removing a WSL distribution deletes its file system and all the data it contained.

This cmdlet wraps the functionality of `wsl.exe --unregister`.

## EXAMPLES

### EXAMPLE 1

```powershell
Remove-WslDistribution Ubuntu
```

This example unregisters the distribution named "Ubuntu".

### EXAMPLE 2

```powershell
Remove-WslDistribution "Ubuntu*"
```

This example unregisters all distributions whose name starts with "Ubuntu".

### EXAMPLE 3

```powershell
Get-WslDistribution -Version 1 | Remove-WslDistribution
```

This example unregisters all WSL1 distributions.

### EXAMPLE 4

```powershell
Get-WslDistribution | Where-Object { $_.Name -ine "Ubuntu" } | Remove-WslDistribution
```

This example unregisters all distributions except the one named "Ubuntu".

## PARAMETERS

### -Distribution

Specifies the distribution to be removed.

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

Specifies the name of a distribution to be removed.

```yaml
Type: String[]
Parameter Sets: DistributionName
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: True
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
