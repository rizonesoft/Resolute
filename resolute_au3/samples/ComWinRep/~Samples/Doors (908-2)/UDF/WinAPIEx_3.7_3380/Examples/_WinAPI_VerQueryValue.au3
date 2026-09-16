#Include <Array.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $aData, $pData = 0

If Not _WinAPI_GetFileVersionInfo(@SystemDir & '\shell32.dll', $pData) Then
	Exit
EndIf

$aData = _WinAPI_VerQueryValue($pData)

_ArrayDisplay($aData, '_WinAPI_VerQueryValue')

_WinAPI_FreeMemory($pData)
