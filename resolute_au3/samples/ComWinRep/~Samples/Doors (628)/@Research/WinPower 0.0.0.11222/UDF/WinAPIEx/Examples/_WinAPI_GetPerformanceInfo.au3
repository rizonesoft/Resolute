#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $Data = _WinAPI_GetPerformanceInfo()

ConsoleWrite('Physical Memory (MB)' & @CR)
ConsoleWrite('--------------------' & @CR)
ConsoleWrite('Total:     ' & Floor($Data[3] / 1024 / 1024) & @CR)
ConsoleWrite('Available: ' & Floor($Data[4] / 1024 / 1024) & @CR)
ConsoleWrite('Cached:    ' & Floor($Data[5] / 1024 / 1024) & @CR)
ConsoleWrite('Free:      ' & Floor($Data[6] / 1024 / 1024) & @CR)

ConsoleWrite(@CR)

ConsoleWrite('Kernel Memory (MB)' & @CR)
ConsoleWrite('--------------------' & @CR)
ConsoleWrite('Paged:     ' & Floor($Data[7] / 1024 / 1024) & @CR)
ConsoleWrite('Nonpaged:  ' & Floor($Data[8] / 1024 / 1024) & @CR)

ConsoleWrite(@CR)

ConsoleWrite('System' & @CR)
ConsoleWrite('--------------------' & @CR)
ConsoleWrite('Handles:   ' & $Data[10] & @CR)
ConsoleWrite('Processes: ' & $Data[11] & @CR)
ConsoleWrite('Threads:   ' & $Data[12] & @CR)
