---
external help file: Wsl-help.xml
Module Name: Wsl
online version:
schema: 2.0.0
---

# Import-WslDistribution

## SYNOPSIS
Imports one or more WSL distributions from a .tar.gz or VHD file.

## SYNTAX

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

### Path
```
Import-WslDistribution [-Path] <String[]> [-Destination] <String> [[-Name] <String>] [[-Version] <Int32>]
 [-RawDestination] [-Vhd] [-Passthru] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### LiteralPath
```
Import-WslDistribution -LiteralPath <String[]> [-Destination] <String> [[-Name] <String>] [[-Version] <Int32>]
 [-RawDestination] [-Vhd] [-Passthru] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
The Import-WslDistribution cmdlet imports each of the specified gzipped tarball files to a WSL
distribution.
to a gzipped.

By default, this cmdlet derives the distribution name from the input file name, and appends that
name to the destination path.
This allows you to import multiple distributions.

This cmdlet wraps the functionality of "wsl.exe --import".

## EXAMPLES

### EXAMPLE 1
```
Import-WslDistribution D:\backup.tar.gz D:\wsl Ubuntu
```

Imports the file named D:\backup.tar.gz as a distribution named "Ubuntu" stored in D:\wsl\Ubuntu.

### EXAMPLE 2
```
Import-WslDistribution D:\backup.tar.gz D:\wsl\mydistro Ubuntu -RawDestination
```

Imports the file named D:\backup.tar.gz as a distribution named "Ubuntu" stored in D:\wsl\mydistro.

### EXAMPLE 3
```
Import-WslDistribution D:\backup\*.tar.gz D:\wsl
```

Imports all .tar.gz files from D:\backup to distributions with names based on the file names, stored
in subdirectories of D:\wsl.

### EXAMPLE 4
```
Import-WslDistribution D:\backup\*.vhdx D:\wsl -Vhd
```

Imports all .vhdx files from D:\backup to distributions with names based on the file names, stored
in subdirectories of D:\wsl.
The Vhd parameter is required to indicate the input files are VHDs.

### EXAMPLE 5
```
Import-WslDistribution -InPlace D:\wsl\Ubuntu.vhdx
```

Imports the file named D:\wsl\Ubuntu.vhdx as a distribution named "Ubuntu", using the file at its
present location.

### EXAMPLE 6
```
Get-Item D:\backup\*.tar.gz -Exclude Ubuntu* | Import-WslDistribution -Destination D:\wsl -Version 2 -Passthru
Name           State Version Default
----           ----- ------- -------
Alpine       Stopped       2   False
Debian       Stopped       2   False
```

Imports all .tar.gz files, except those whose names start with Ubuntu, as WSL2 distributions stored
in subdirectories of D:\wsl.

## PARAMETERS

### -Destination
Specifies the destination directory or file name where the imported distribution will be stored.
The
distribution name will be appended to this path (e.g.
if you specify "D:\wsl" and the distribution
is named "Ubuntu", the distribution will be stored in "D:\wsl\Ubuntu"), unless the RawDestination
parameter is specified.

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

### -InPlace
Registers the specified file as a WSL distribution in its current location, without copying it.
The
input must be a .vhdx file when importing in place.

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
Specifies the path to a .tar.gz or .vhdx file to import.
The value of LiteralPath is used exactly as
it is typed.
No characters are interpreted as wildcards.

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

By default, this cmdlet uses the base name of the file being imported (e.g.
"Ubuntu" if the file
is "Ubuntu.tar.gz").
Note that distribution names can only contain letters, numbers, dashes and
underscores.
If the file contains any other characters, you must specify a distribution name.

If you specify a distribution name, you cannot import multiple distributions with one command.

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

### -Path
Specifies the path to a .tar.gz or .vhdx file to import.
Wildcards are permitted.

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
Indicates that the destination path should be used as is, without appending the distribution name
to it.
By default, the distribution name is appended to the path.

If RawDestination is specified, you cannot import multiple distributions with one command.

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
Specifies the WSL version to use for the imported distribution.
By default, this cmdlet uses the
version set with "wsl.exe --set-default-version".

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

### -Vhd
Indicates that the input file is a .vhdx file that will be copied to the destination.

This parameter requires at least WSL version 0.58.

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
### You can pipe a string that contains a path to this cmdlet.
## OUTPUTS

### WslDistribution
### The cmdlet returns an object that represent the distribution, if you use the Passthru parameter.
### Otherwise, this cmdlet does not generate any output.
## NOTES

## RELATED LINKS
