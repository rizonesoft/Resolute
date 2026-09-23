#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $Data = _WinAPI_GetVolumeInformation()

ConsoleWrite('Volume name: ' & $Data[0] & @CR)
ConsoleWrite('File system: ' & $Data[4] & @CR)
ConsoleWrite('Serial number: ' & $Data[1] & @CR)
ConsoleWrite('File name length: ' & $Data[2] & @CR)
ConsoleWrite('Flags: 0x' & Hex($Data[3]) & @CR)
