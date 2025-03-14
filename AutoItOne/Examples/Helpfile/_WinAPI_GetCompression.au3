#include <APISysConstants.au3>
#include <MsgBoxConstants.au3>
#include <WinAPIFiles.au3>

Local $sFile = FileOpenDialog('Select File', @ScriptDir, 'All Files (*.*)', BitOR($FD_FILEMUSTEXIST, $FD_PATHMUSTEXIST))
If @error Then Exit

Switch _WinAPI_GetCompression($sFile)
	Case -1
		MsgBox(($MB_ICONERROR + $MB_SYSTEMMODAL), 'Compression File', 'Unable to perform operation.')
	Case $COMPRESSION_FORMAT_NONE
		If _WinAPI_SetCompression($sFile, $COMPRESSION_FORMAT_DEFAULT) Then
			MsgBox(($MB_ICONINFORMATION + $MB_SYSTEMMODAL), 'Compression File', 'The file compressed is successfully.')
		Else
			MsgBox(($MB_ICONERROR + $MB_SYSTEMMODAL), 'Compression File', 'Unable to compress file.')
		EndIf
	Case Else
		If MsgBox(($MB_YESNO + $MB_ICONQUESTION + $MB_SYSTEMMODAL), 'Compression File', 'The file is already compressed.' & @CRLF & @CRLF & 'Decompress?') = 6 Then
			If _WinAPI_SetCompression($sFile, $COMPRESSION_FORMAT_NONE) Then
				MsgBox(($MB_ICONINFORMATION + $MB_SYSTEMMODAL), 'Compression File', 'The file decompressed is successfully.')
			Else
				MsgBox(($MB_ICONERROR + $MB_SYSTEMMODAL), 'Compression File', 'Unable to decompress file.')
			EndIf
		EndIf
EndSwitch
