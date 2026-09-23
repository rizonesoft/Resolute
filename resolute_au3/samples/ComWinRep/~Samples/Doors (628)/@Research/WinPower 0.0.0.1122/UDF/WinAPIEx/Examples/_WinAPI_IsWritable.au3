#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $Text, $Drive = DriveGetDrive('ALL')

If IsArray($Drive) Then
	For $i = 1 To $Drive[0]
		If _WinAPI_IsWritable($Drive[$i]) Then
			$Text = 'Writable'
		Else
			$Text = 'Not writable'
		EndIf
		If Not @error Then
			ConsoleWrite(StringUpper($Drive[$i]) & ' => ' & $Text & @CR)
		EndIf
	Next
EndIf
