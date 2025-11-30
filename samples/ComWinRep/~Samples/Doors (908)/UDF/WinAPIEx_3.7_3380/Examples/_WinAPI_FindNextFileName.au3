#Include <Array.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global Const $sFile = @DesktopDir & '\@' & StringRegExpReplace(_WinAPI_PathFindFileName(@ScriptName), '\A_+', '')

Global $hSearch, $sLink

; Create hard link to the current file with prefix "@" on your Desktop
_WinAPI_CreateHardLink($sFile, @ScriptFullPath)
If @error Then
	MsgBox(16, 'Error', 'Unable to create hard link.')
	Exit
EndIf

; Enumerate all hard links to the file

$hSearch = _WinAPI_FindFirstFileName($sFile, $sLink)
While Not @error
	ConsoleWrite(_WinAPI_PathAppend(_WinAPI_PathStripToRoot($sFile), $sLink) & @CR)
	_WinAPI_FindNextFileName($hSearch, $sLink)
WEnd

Switch @extended
	Case 38 ; ERROR_HANDLE_EOF

	Case Else
		MsgBox(16, @extended, _WinAPI_GetErrorMessage(@extended))
EndSwitch

FileDelete($sFile)
