---
external help file: Wsl-help.xml
Module Name: Wsl
online version:
schema: 2.0.0
---

# Stop-Wsl

## SYNOPSIS
Stops all WSL distributions.

## SYNTAX

```
Stop-Wsl [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
The Stop-Wsl cmdlet terminates all WSL distributions, and for WSL2 also shuts down the lightweight
utility VM.

This cmdlet wraps the functionality of "wsl.exe --shutdown".

## EXAMPLES

### EXAMPLE 1
```
Stop-Wsl
```

Shuts down WSL.

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

### None. This cmdlet does not take any input.
## OUTPUTS

### None. This cmdlet does not generate any output.
## NOTES

## RELATED LINKS
