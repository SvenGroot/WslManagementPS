---
external help file: Wsl-help.xml
Module Name: Wsl
online version: https://github.com/SvenGroot/WslManagementPS/blob/main/docs/Stop-Wsl.md
schema: 2.0.0
---

# Stop-Wsl

## SYNOPSIS

Terminates all WSL distributions, and shuts down the WSL2 lightweight utility VM.

## SYNTAX

```
Stop-Wsl [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION

The `Stop-Wsl` cmdlet terminates all WSL distributions, and shuts down the WSL2 lightweight utility
VM.

This cmdlet wraps the functionality of `wsl.exe --shutdown`.

## EXAMPLES

### EXAMPLE 1

```powershell
Stop-Wsl
```

This example terminates all WSL distributions, and shuts down the WSL2 lightweight utility VM.

## PARAMETERS

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

## OUTPUTS

## NOTES

## RELATED LINKS
