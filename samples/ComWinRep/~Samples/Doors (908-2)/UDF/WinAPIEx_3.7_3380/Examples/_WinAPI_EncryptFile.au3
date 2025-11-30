#Include <APIConstants.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $File = FileOpenDialog('Select File', @ScriptDir, 'All Files (*.*)', 1 + 2)

If Not $File Then
	Exit
EndIf

Switch _WinAPI_FileEncryptionStatus($File)
	Case $FILE_ENCRYPTABLE
		If _WinAPI_EncryptFile($File) Then
			MsgBox(64, 'Encryption File', 'The file encrypted is successfully.')
		Else
			MsgBox(16, 'Encryption File', 'Unable to encrypt file.')
		EndIf
	Case $FILE_IS_ENCRYPTED
		If MsgBox(36, 'Encryption File', 'The file is already encrypted.' & @CR & @CR & 'Decrypt?') = 6 Then
			If _WinAPI_DecryptFile($File) Then
				MsgBox(64, 'Encryption File', 'The file decrypted is successfully.')
			Else
				MsgBox(16, 'Encryption File', 'Unable to decrypt file.')
			EndIf
		EndIf
	Case Else
		MsgBox(16, 'Encryption File', 'Unable to perform operation.')
EndSwitch
