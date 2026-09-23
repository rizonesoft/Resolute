#include <array.au3>

$sFile = @ScriptDir & "\ICU - Icon Configuration Utility v5_Obfuscated.au3"

If Not FileExists($sFile) Then Exit 9

Global $aDllOpen_Calls[1][2]

Global $bFirstLineFound = False, $sline
$hfile = FileOpen($sFile)
While 1
	$sline = FileReadLine($hfile)
	If @error = -1 Then ExitLoop
	If $sline = "#region DllOpen_PostProcessor END" Then ExitLoop
	If $sline = "#region DllOpen_PostProcessor START" Then
		$bFirstLineFound = True
		ContinueLoop
	EndIf
	If $bFirstLineFound Then
		ReDim $aDllOpen_Calls[UBound($aDllOpen_Calls) + 1][2]
		$aDllOpen_Calls[0][0] += 1
		$aDllOpen_Calls[UBound($aDllOpen_Calls) - 1][0] = $sline
		$aDllOpen_Calls[UBound($aDllOpen_Calls) - 1][1] = $sline
	EndIf
WEnd
FileClose($hfile)

If Not $aDllOpen_Calls[0][0] Then
	MsgBox(4096, "Exit", "No DllOpen calls found")
	Exit
EndIf

For $i = 1 To $aDllOpen_Calls[0][0]
	$aDllOpen_Calls[$i][0] = StringTrimLeft($aDllOpen_Calls[$i][0], 7)
	$aDllOpen_Calls[$i][0] = StringLeft($aDllOpen_Calls[$i][0], StringInStr($aDllOpen_Calls[$i][0], " ") - 1)
	$aDllOpen_Calls[$i][1] = StringTrimLeft($aDllOpen_Calls[$i][1], StringInStr($aDllOpen_Calls[$i][1], '"', 0, -2))
	$aDllOpen_Calls[$i][1] = StringTrimRight($aDllOpen_Calls[$i][1], 2)
Next

$hfile = FileOpen($sFile)
$sBuffer = FileRead($hfile)
FileClose($hfile)

For $i = 1 To $aDllOpen_Calls[0][0]
	ConsoleWrite(TimerInit() & @TAB & $i & " / " & $aDllOpen_Calls[0][0] & @TAB & $aDllOpen_Calls[$i][1] & @CRLF)
	$sBuffer = StringReplace($sBuffer, 'dllcall("' & $aDllOpen_Calls[$i][1] & '"', 'dllcall(' & $aDllOpen_Calls[$i][0])
	$sBuffer = StringReplace($sBuffer, "dllcall('" & $aDllOpen_Calls[$i][1] & "'", "dllcall(" & $aDllOpen_Calls[$i][0])
Next

FileDelete(StringReplace($sFile, ".au3", "_pp.au3"))
FileWrite(StringReplace($sFile, ".au3", "_pp.au3"), $sBuffer)