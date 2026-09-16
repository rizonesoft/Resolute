#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $Data = _WinAPI_GetDiskFreeSpaceEx(@HomeDrive)

ConsoleWrite('Total available free space on ' & @HomeDrive & ' => ' & $Data[0] & ' bytes' & @CR)
ConsoleWrite('Total available space on ' & @HomeDrive & ' => ' & $Data[1] & ' bytes' & @CR)
ConsoleWrite('Total free space on ' & @HomeDrive & ' => ' & $Data[2] & ' bytes' & @CR)
