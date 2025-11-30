#Include <APIConstants.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $File = FileOpenDialog('Select File', @ScriptDir, 'All Files (*.*)', 1 + 2)

If Not $File Then
	Exit
EndIf

Switch _WinAPI_GetCompression($File)
	Case -1
		MsgBox(16, 'Compression File', 'Unable to perform operation.')
	Case $COMPRESSION_FORMAT_NONE
		If _WinAPI_SetCompression($File, $COMPRESSION_FORMAT_DEFAULT) Then
			MsgBox(64, 'Compression File', 'The file compressed is successfully.')
		Else
			MsgBox(16, 'Compression File', 'Unable to compress file.')
		EndIf
	Case Else
		If MsgBox(36, 'Compression File', 'The file is already compressed.' & @CR & @CR & 'Decompress?') = 6 Then
			If _WinAPI_SetCompression($File, $COMPRESSION_FORMAT_NONE) Then
				MsgBox(64, 'Compression File', 'The file decompressed is successfully.')
			Else
				MsgBox(16, 'Compression File', 'Unable to decompress file.')
			EndIf
		EndIf
EndSwitch
