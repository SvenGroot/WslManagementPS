---
external help file: Wsl-help.xml
Module Name: Wsl
online version:
schema: 2.0.0
---

# Export-WslDistribution

## SYNOPSIS
Exports one or more WSL distributions to a .tar.gz or VHD file.

## SYNTAX

### DistributionName
```
Export-WslDistribution [-Name] <String[]> [-Destination] <String> [-Vhd] [-Passthru] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

### Distribution
```
Export-WslDistribution -Distribution <WslDistribution[]> [-Destination] <String> [-Vhd] [-Passthru] [-WhatIf]
 [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
The Export-WslDistribution cmdlet exports each of the specified WSL distributions to a gzipped
tarball or VHD.
You can specify distributions by their names, or use the Distribution parameter to
pass an object returned by Get-WslDistribution.

You can export multiple distributions by specifying a directory as the Destination.
In this case,
this cmdlet will automatically create files using the distribution name with the extension .tar.gz
or .vhdx.

This cmdlet wraps the functionality of "wsl.exe --export".

## EXAMPLES

### EXAMPLE 1
```
Export-WslDistribution Ubuntu D:\backup.tar.gz
```

Exports the distribution named "Ubuntu" to a file named D:\backup.tar.gz.

### EXAMPLE 2
```
Export-WslDistribution Ubuntu D:\backup.vhdx -Vhd
```

Exports the distribution named "Ubuntu" to a file named D:\backup.vhdx which is a VHD, not a gzipped
tarball.

### EXAMPLE 3
```
Export-WslDistribution Ubuntu* D:\backup
```

Exports all distributions whose names start with Ubuntu to files in a directory named D:\backup.

### EXAMPLE 4
```
Export-WslDistribution Ubuntu* D:\backup -Vhd
```

Exports all distributions whose names start with Ubuntu to files in a directory named D:\backup,
using .vhdx files.

### EXAMPLE 5
```
Get-WslDistribution -Version 2 | Export-WslDistribution -Destination D:\backup -Passthru
Name           State Version Default
----           ----- ------- -------
Ubuntu       Stopped       2    True
Alpine       Stopped       2   False
```

Exports all WSL2 distributions to a directory named D:\backup.

## PARAMETERS

### -Destination
Specifies the destination directory or file name where the exported distribution will be stored.

If you specify an existing directory as the destination, this cmdlet will append a file name based
on the distribution name.
If you specify a non-existing file name, that name will be used verbatim.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Distribution
Specifies WslDistribution objects that represent the distributions to be exported.

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
Specifies the distribution names of distributions to be exported.
Wildcards are permitted.

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

### -Passthru
Returns an object that represents the distribution.
By default, this cmdlet does not generate any
output.

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

### -Vhd
Export the distribution as a .vhdx file, instead of a .tar.gz file.

This parameter requires at least WSL version 0.58.

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

### WslDistribution, System.String
### You can pipe a WslDistribution object retrieved by Get-WslDistribution, or a string that contains
### the distribution name to this cmdlet.
## OUTPUTS

### WslDistribution
### The cmdlet returns an object that represent the distribution, if you use the Passthru parameter.
### Otherwise, this cmdlet does not generate any output.
## NOTES

## RELATED LINKS
