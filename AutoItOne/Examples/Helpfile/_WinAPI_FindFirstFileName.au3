#include <MsgBoxConstants.au3>
#include <WinAPIError.au3>
#include <WinAPIFiles.au3>
#include <WinAPIShPath.au3>

Local $sFile = @DesktopDir & '\@' & StringRegExpReplace(_WinAPI_PathFindFileName(@ScriptName), '\A_+', '')

; Create hard link to the current file with prefix "@" on your Desktop
If Not _WinAPI_CreateHardLink($sFile, @ScriptFullPath) Then
	MsgBox(($MB_ICONERROR + $MB_SYSTEMMODAL), 'Error', 'Unable to create hard link.')
	Exit
EndIf

; Enumerate all hard links to the file

Local $sLink
Local $hSearch = _WinAPI_FindFirstFileName($sFile, $sLink)
While Not @error
	ConsoleWrite(_WinAPI_PathAppend(_WinAPI_PathStripToRoot($sFile), $sLink) & @CRLF)
	_WinAPI_FindNextFileName($hSearch, $sLink)
WEnd

Switch @extended
	Case 38 ; ERROR_HANDLE_EOF

	Case Else
		MsgBox(($MB_ICONERROR + $MB_SYSTEMMODAL), @extended, _WinAPI_GetErrorMessage(@extended))
EndSwitch

FileDelete($sFile)
