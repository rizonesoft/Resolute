#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $Data = _WinAPI_GetProcessMemoryInfo()

ConsoleWrite('Number of page faults: ' & $Data[0] & @CR)
ConsoleWrite('Peak working set size: ' & $Data[1] & ' bytes' & @CR)
ConsoleWrite('Current working set size: ' & $Data[2] & ' bytes' & @CR)
ConsoleWrite('Peak paged pool usage: ' & $Data[3] & ' bytes' & @CR)
ConsoleWrite('Current paged pool usage: ' & $Data[4] & ' bytes' & @CR)
ConsoleWrite('Peak nonpaged pool usage: ' & $Data[5] & ' bytes' & @CR)
ConsoleWrite('Current nonpaged pool usage: ' & $Data[6] & ' bytes' & @CR)
ConsoleWrite('Current space allocated for the pagefile: ' & $Data[7] & ' bytes' & @CR)
ConsoleWrite('Peak space allocated for the pagefile: ' & $Data[8] & ' bytes' & @CR)
ConsoleWrite('Current private space: ' & $Data[9] & ' bytes' & @CR)
