#Include <APIConstants.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $Data = _WinAPI_GetCurrentThemeName()

If IsArray($Data) Then
	ConsoleWrite('File:    ' & $Data[0] & @CR)
	ConsoleWrite('Color:   ' & $Data[1] & @CR)
	ConsoleWrite('Size:    ' & $Data[2] & @CR)
	ConsoleWrite('Name:    ' & _WinAPI_GetThemeDocumentationProperty($Data[0], $SZ_THDOCPROP_CANONICALNAME) & @CR)
	ConsoleWrite('Display: ' & _WinAPI_GetThemeDocumentationProperty($Data[0], $SZ_THDOCPROP_DISPLAYNAME) & @CR)
	ConsoleWrite('Tooltip: ' & _WinAPI_GetThemeDocumentationProperty($Data[0], $SZ_THDOCPROP_TOOLTIP) & @CR)
	ConsoleWrite('Author:  ' & _WinAPI_GetThemeDocumentationProperty($Data[0], $SZ_THDOCPROP_AUTHOR) & @CR)
EndIf
