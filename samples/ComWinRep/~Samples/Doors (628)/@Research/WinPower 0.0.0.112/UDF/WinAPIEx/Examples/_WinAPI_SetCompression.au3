#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $File, $Result

$File = FileOpenDialog('Select File', @ScriptDir, 'All files (*.*)', 1 + 2)

If Not @error Then
	$Result = _WinAPI_GetCompression($File)
	If Not @error Then
		Switch $Result
			Case $COMPRESSION_FORMAT_NONE
				If _WinAPI_SetCompression($File, $COMPRESSION_FORMAT_DEFAULT) Then
					MsgBox(64, 'Compression File', 'The file compressed is successfully.')
				Else
					MsgBox(16, 'Compression File', 'The file can not be compressed.')
				EndIf
			Case Else
				If MsgBox(36, 'Compression File', 'The file is already compressed. Decompress?') = 6 Then
					If _WinAPI_SetCompression($File, $COMPRESSION_FORMAT_NONE) Then
						MsgBox(64, 'Compression File', 'The file decompressed is successfully.')
					Else
						MsgBox(16, 'Compression File', 'The file can not be decompressed.')
					EndIf
				EndIf
		EndSwitch
	EndIf
EndIf
