---
external help file: Wsl-help.xml
Module Name: Wsl
online version: https://github.com/SvenGroot/WslManagementPS/blob/main/docs/Export-WslDistribution.md
schema: 2.0.0
---

# Export-WslDistribution

## SYNOPSIS

Exports a WSL distribution to a .tar.gz or VHD file.

## SYNTAX

### DistributionName

```
Export-WslDistribution [-Name] <String[]> [-Destination] <String> [-Format <WslExportFormat>] [-Passthru]
 [-WhatIf] [-Confirm] [<CommonParameters>]
```

### Distribution

```
Export-WslDistribution -Distribution <WslDistribution[]> [-Destination] <String> [-Format <WslExportFormat>]
 [-Passthru] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION

The `Export-WslDistribution` cmdlet exports a WSL distributions to a gzipped tarball or VHD file.
The distribution to export can be specified by name, or piped in from the `Get-WslDistribution`
cmdlet.

If the **Destination** parameter is an existing directory, the name of the distribution, with the
extension .tar.gz or .vhdx, will be used as the file name. This allows you to export multiple
distributions to a directory using a single command.

The default behavior is to export as a gzipped tarball, unless the **Destination** is a file name
ending in .vhdx. This behavior can be changed using the **Format** parameter.

This cmdlet wraps the functionality of `wsl.exe --export`.

## EXAMPLES

### EXAMPLE 1

```powershell
Export-WslDistribution "Ubuntu" D:\backup.tar.gz
```

This example exports the distribution named "Ubuntu" to a file named `D:\backup.tar.gz`.

### EXAMPLE 2

```powershell
Export-WslDistribution "Ubuntu" D:\backup.vhdx
```

This example exports the distribution named "Ubuntu" to a file named `D:\backup.vhdx` which is a
VHD, not a gzipped tarball. This requires the distribution to use WSL2.

### EXAMPLE 3

```powershell
New-Item D:\backup -ItemType Directory
Export-WslDistribution "Ubuntu*" D:\backup
```

This example exports all distributions whose name starts with Ubuntu to a directory named `D:\backup`.
Separate .tar.gz files will be created for each distribution.

### EXAMPLE 4

```powershell
Get-WslDistribution -Version 2 | Export-WslDistribution -Destination D:\backup -Format "Vhd" -Passthru
```

```Output
    Directory: C:\ubuntu

Mode                 LastWriteTime         Length Name
----                 -------------         ------ ----
-a---            9/8/2023 12:51 PM        62914560 Alpine.vhdx
-a---            9/8/2023 12:51 PM    171853217792 Ubuntu.vhdx
```

This example exports all WSL2 distributions to a directory named `D:\backup`, using VHD format. It
uses the **Passthru** parameter to return the `System.IO.FileInfo` objects for the created files.

## PARAMETERS

### -Destination

Specifies the destination directory or file name where the exported distribution will be stored.

If you specify an existing directory as the destination, a file will be created in that directory
using the distribution name and the extension .tar.gz, or .vhdx if the Vhd parameter is used.

If you specify a non-existing path, that path will be used verbatim as the file for the exported
distribution.

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

### -Format

Specifies the format of the exported distribution. This parameter accepts the following values:
`Auto` exports as a gzipped tarball, unless the **Destination** is a file name ending in `.vhdx`, in
which case VHD format is used; `Tar` exports as a gzipped tarball; and `Vhd` exports as a Virtual
Hard Disk.

Exporting as a VHD is only possible for WSL2 distributions.

This parameter requires at least WSL version 0.58.

```yaml
Type: WslExportFormat
Parameter Sets: (All)
Aliases:
Accepted values: Auto, Tar, Vhd

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Name

Specifies the name of a distribution to be terminated.

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

Specifies that a `System.IO.FileInfo` object is to be passed through to the pipeline for each
exported file.

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

### None by default; System.IO.FileInfo if **PassThru** is specified

The `FileInfo` object contains information about the exported file.

## NOTES

## RELATED LINKS

[Get-WslDistribution](Get-WslDistribution.md)
[Import-WslDistribution](Import-WslDistribution.md)
