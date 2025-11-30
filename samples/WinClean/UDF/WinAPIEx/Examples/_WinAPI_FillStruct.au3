#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $tStruct = DllStructCreate('dword[8]')

_WinAPI_FillStruct($tStruct, -1, 4)

For $i = 1 To 8
	ConsoleWrite('0x' & Hex(DllStructGetData($tStruct, 1)) & @CR)
Next
