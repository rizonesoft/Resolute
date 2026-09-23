#Include <APIConstants.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $i = 0, $Data

While 1
	$Data = _WinAPI_EnumDisplaySettings('', $i)
	If IsArray($Data) Then
		ConsoleWrite($Data[0] & ' x ' & $Data[1] & ' x ' & $Data[2] & ' bit' & @CR)
	Else
		ExitLoop
	EndIf
	$i += 1
WEnd

$Data = _WinAPI_EnumDisplaySettings('', $ENUM_CURRENT_SETTINGS)
ConsoleWrite('-------------------------------' & @CR)
ConsoleWrite('Current settings: ' & $Data[0] & ' x ' & $Data[1] & ' x ' & $Data[2] & ' bit' & @CR)
