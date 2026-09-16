#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $Number = '123456789'

ConsoleWrite(_WinAPI_GetNumberFormat(0, $Number) & @CR)
ConsoleWrite(_WinAPI_GetNumberFormat(0, $Number, _WinAPI_CreateNumberFormatInfo(0, 1, 3, '', ',', 1)) & @CR)
