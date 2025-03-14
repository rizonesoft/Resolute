#include-once
#include <Constants.au3>

#cs
	Local $sIncludePath = StringTrimRight(@AutoItExe, StringLen('AutoIt.exe') + 1) & 'Include'
	If @AutoItX64 Then
	$sIncludePath = StringTrimRight(@AutoItExe, StringLen('AutoIt_x64.exe') + 1) & 'Include'
	EndIf
	Local $vArray[2][2] = [[1, 2], ["MYDEF", "'Example'"]]
	Local $sReturn = _PreProcessor(@ScriptDir & '\Before.au3', @ScriptDir & '\After.au3', $vArray, $sIncludePath)
	ConsoleWrite($sReturn)
#ce

Func _PreProcessor($sSourceFile, $sDestination, $vArray = '', $sIncludePath = '')
	; $vArray should be a 2D Array e.g. $vArray[2][2] = [[1, 2], ["Item_1", "Value_2"]]
	; http://www.gnu-darwin.org/www001/ports-1.5a-CURRENT/devel/mcpp/work/mcpp-2.6.4/doc/mcpp-manual.html#2.3
	; Idea by Shaggi - http://www.autoitscript.com/forum/topic/133808-autoit-with-c-preprocessor/
	Local $sDefinitions = ''
	If UBound($vArray) Then
		For $i = 1 To $vArray[0][0]
			$sDefinitions &= ' -D ' & $vArray[$i][0] & '=' & $vArray[$i][1]
		Next
	EndIf
	If FileExists($sIncludePath) Then
		$sIncludePath = ' -I "' & $sIncludePath & '" '
	EndIf

	Local Const $iPID = Run('"' & @ScriptDir & '\mcpp.exe" "' & $sSourceFile & '" "' & $sDestination & '" -a -P -v' & $sIncludePath & $sDefinitions, @ScriptDir, @SW_HIDE, $STDERR_CHILD + $STDOUT_CHILD)
	Local $sOutput = ''
	While 1
		$sOutput &= StderrRead($iPID)
		If @error Then
			ExitLoop
		EndIf
	WEnd
	Return $sOutput
EndFunc   ;==>_PreProcessor
