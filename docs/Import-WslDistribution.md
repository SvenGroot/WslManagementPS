---
external help file: Wsl-help.xml
Module Name: Wsl
online version: https://github.com/SvenGroot/WslManagementPS/blob/main/docs/Import-WslDistribution.md
schema: 2.0.0
---

# Import-WslDistribution

## SYNOPSIS

Imports a WSL distribution from a .tar.gz or VHD file.

## SYNTAX

### Path

```
Import-WslDistribution [-Path] <String[]> [-Destination] <String> [[-Name] <String>] [[-Version] <Int32>]
 [-RawDestination] [-Format <WslExportFormat>] [-Passthru] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### LiteralPath

```
Import-WslDistribution -LiteralPath <String[]> [-Destination] <String> [[-Name] <String>] [[-Version] <Int32>]
 [-RawDestination] [-Format <WslExportFormat>] [-Passthru] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### LiteralPathInPlace

```
Import-WslDistribution [-InPlace] -LiteralPath <String[]> [[-Name] <String>] [-Passthru] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

### PathInPlace

```
Import-WslDistribution [-InPlace] [-Path] <String[]> [[-Name] <String>] [-Passthru] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION

The `Import-WslDistribution` cmdlet imports a WSL distribution that was previously exported to a
gzipped tarball or VHD file, for example using the `Export-WslDistribution` cmdlet.

If you do not specify a distribution name, the name is derived from the input file name. For example,
a file named "Ubuntu.tar.gz" would be imported to a distribution named "Ubuntu".

A directory with the name of the distribution is created as a child of the path specified using the
**Destination** parameter, unless the **RawDestination** parameter is used. This allows multiple
distributions to be imported using a single command.

This cmdlet wraps the functionality of `wsl.exe --import`.

## EXAMPLES

### EXAMPLE 1

```powershell
Import-WslDistribution D:\backup.tar.gz D:\wsl "Ubuntu"
```

This example imports the file named `D:\backup.tar.gz` as a distribution named "Ubuntu", whose
filesystem will be stored in the directory `D:\wsl\Ubuntu`.

### EXAMPLE 2

```powershell
Import-WslDistribution D:\backup.tar.gz D:\wsl\mydistro "Ubuntu" -RawDestination
```

This example imports the file named `D:\backup.tar.gz` as a distribution named "Ubuntu", whose file
system will be stored in the directory `D:\wsl\mydistro`. The name of the distribution is not appended
to this path because the RawDestination parameter was used.

### EXAMPLE 3

```powershell
Import-WslDistribution D:\backup\*.tar.gz D:\wsl
```

This example imports all .tar.gz files from `D:\backup`, using the base name of each file as the name
of the distribution. Each distribution will be stored in a separate subdirectory of `D:\wsl`.

### EXAMPLE 4

```powershell
Import-WslDistribution D:\backup\*.vhdx D:\wsl
```

This example imports all .vhdx files from `D:\backup`, using the base name of each file as the name
of the distribution. Each VHD file will be copied to a separate subdirectory of `D:\wsl`.

### EXAMPLE 5

```powershell
Import-WslDistribution -InPlace D:\wsl\Ubuntu.vhdx
```

This example imports the file named `D:\wsl\Ubuntu.vhdx` as a distribution named "Ubuntu", using the
file at its present location.

### EXAMPLE 6

```powershell
Get-Item D:\backup\*.tar.gz -Exclude "Ubuntu*" | Import-WslDistribution -Destination D:\wsl -Version 2 -Passthru
```

```Output
Name           State Version Default
----           ----- ------- -------
Alpine       Stopped       2   False
Debian       Stopped       2   False
```

This example imports all .tar.gz files, except those whose names start with Ubuntu, as WSL2
distributions stored in subdirectories of `D:\wsl`. It uses the Passthru parameter to return the
WslDistribution objects for the imported distributions.

## PARAMETERS

### -Destination

Specifies the destination directory or file name where the file system for the imported distribution
will be stored.

Unless the RawDestination parameter is used, the name of the distribution will be appended to this
path.

```yaml
Type: String
Parameter Sets: Path, LiteralPath
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Format

Specifies the format of the file to import, which can be either a gzipped tarball or a VHD. This
parameter accepts the following values: `Auto` determines the format based on the file extension;
`Tar` indicates the file is a gzipped tarball; and `Vhd` indicates the file is a Virtual Hard Disk.

When using `Auto`, all files are assumed to be gzipped tarballs, unless their name ends in `.vhdx`.

This parameter requires at least WSL version 0.58.

```yaml
Type: WslExportFormat
Parameter Sets: Path, LiteralPath
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -InPlace

Specifies that the new distribution should use the input file in its current location, without
copying it. The input must be a .vhdx file when importing in place.

This parameter requires at least WSL version 0.58.

```yaml
Type: SwitchParameter
Parameter Sets: LiteralPathInPlace, PathInPlace
Aliases:

Required: True
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -LiteralPath

Specifies the path to a .tar.gz or .vhdx file to import. The value of **LiteralPath** is used exactly
as it is typed. No characters are interpreted as wildcards.

```yaml
Type: String[]
Parameter Sets: LiteralPathInPlace, LiteralPath
Aliases: PSPath

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Name

Specifies the name of the imported WSL distribution.

If you specify am explicit distribution name, you cannot import multiple distributions with a single
command.

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

### -Path

Specifies the path to a .tar.gz or .vhdx file to import. Wildcard characters are permitted.

```yaml
Type: String[]
Parameter Sets: PathInPlace, Path
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: True
```

### -RawDestination

Specifies that the **Destination** path should be used as is, without appending the distribution
name to it.

If **RawDestination** is specified, you cannot import multiple distributions with one command.

```yaml
Type: SwitchParameter
Parameter Sets: Path, LiteralPath
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Version

Specifies the distribution version to use for the imported distribution, either 1 or 2.

If omitted, the currently configured default distribution version is used.

```yaml
Type: Int32
Parameter Sets: Path, LiteralPath
Aliases:

Required: False
Position: 4
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

### System.String

You can pipe a string that contains a path to this cmdlet.

## OUTPUTS

### WslDistribution

### None by default; WslDistribution if PassThru is specified

See `Get-WslDistribution` for more information.

## NOTES

## RELATED LINKS

[Get-WslDistribution](Get-WslDistribution.md)
[Export-WslDistribution](Export-WslDistribution.md)
