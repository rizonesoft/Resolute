#include-once

#include <StringConstants.au3>


Func _GUIGetTitle($sGUIName)

	Local $sReturn = ""

	If @Compiled Then

		Local $sReturn = FileGetVersion(@ScriptFullPath)

		Local $sPltReturn = StringSplit($sReturn, ".")
		If IsArray($sPltReturn) Then
			$sReturn = $sGUIName & " " & $sPltReturn[1] & " : Build " & $sPltReturn[$sPltReturn[0]]
		EndIf

	Else

		$sReturn = $sGUIName & " : using AutoIt version: " & @AutoItVersion & " " & _AutoItGetArchitecture() & "-Bit"

	EndIf

	Return $sReturn

EndFunc


Func _GetWindowsVersion($sWinVer)

	Local $sReturn = ""
	$sReturn = StringReplace($sWinVer, "WIN_", "Windows ",  $STR_CASESENSE)
	Return $sReturn

EndFunc


Func _AutoItGetArchitecture()

	If @AutoItX64 Then
		Return 64
	Else
		Return 32
	EndIf

EndFunc