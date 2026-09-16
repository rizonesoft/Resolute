#Include <APIConstants.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $Icon = RegRead('HKCR\AutoIt3Script\DefaultIcon', '')

If Not @error Then
	RegWrite('HKCR\AutoIt3Script\DefaultIcon', '', 'REG_SZ', @SystemDir & '\shell32.dll,-152')
	_WinAPI_ShellChangeNotify($SHCNE_ASSOCCHANGED, $SHCNF_FLUSH)
	MsgBox(0, '', 'The icon for .au3 files has been changed. Press OK to restore it.')
	RegWrite('HKCR\AutoIt3Script\DefaultIcon', '', 'REG_SZ', $Icon)
	_WinAPI_ShellChangeNotify($SHCNE_ASSOCCHANGED, $SHCNF_FLUSH)
EndIf
