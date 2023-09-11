---
external help file: Wsl-help.xml
Module Name: Wsl
online version: https://github.com/SvenGroot/WslManagementPS/blob/main/docs/Set-WslDistribution.md
schema: 2.0.0
---

# Set-WslDistribution

## SYNOPSIS

Changes the settings of a WSL distribution.

## SYNTAX

### DistributionName

```
Set-WslDistribution [-Name] <String[]> [-Version <Int32>] [-Default] [-Passthru] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

### Distribution

```
Set-WslDistribution -Distribution <WslDistribution[]> [-Version <Int32>] [-Default] [-Passthru] [-WhatIf]
 [-Confirm] [<CommonParameters>]
```

## DESCRIPTION

The `Set-WslDistribution` cmdlet changes the settings of a WSL distribution. The distribution can be
specified by name, or piped in from the `Get-WslDistribution` cmdlet.

This cmdlet wraps the functionality of `wsl.exe --set-default` and `wsl.exe --set-version`.

## EXAMPLES

### EXAMPLE 1

```powershell
Set-WslDistribution Ubuntu -Default
```

This example makes the distribution named "Ubuntu" the default.

### EXAMPLE 2

```powershell
Get-WslDistribution -Version 1 | Set-WslDistribution -Version 2 -Passthru
```

```Output
Name           State Version Default
----           ----- ------- -------
Ubuntu-18.04 Running       2   False
Debian       Stopped       2   False
```

This example converts all version 1 distributions to version 2.  It uses the **Passthru** parameter
to return the WslDistribution objects for the affected distributions.

## PARAMETERS

### -Default

Specifies that the distribution should be made the default distribution. If the input specifies
multiple distributions, the last one processed will be the default after the command finishes.

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

### -Distribution

Specifies the distribution whose settings to change.

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

Specifies the name of a distribution whose settings to change.

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
distribution whose settings were changed.

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

### -Version

Specifies the WSL distribution version to convert the distribution to, either 1 or 2. Converting
a distribution may take several minutes.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: 0
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
