#Include <APIConstants.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $Data = _WinAPI_AssocQueryString('.txt', $ASSOCSTR_DEFAULTICON)
Global $Icon = _WinAPI_PathParseIconLocation($Data)

If IsArray($Icon) Then
	ConsoleWrite('DefaultIcon: ' & $Data & @CR)
	ConsoleWrite('Icon: ' & $Icon[0] & @CR)
	ConsoleWrite('Index: ' & $Icon[1] & @CR)
EndIf
