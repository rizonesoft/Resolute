#include <MsgBoxConstants.au3>
#include <WinAPIError.au3>
#include <WinAPIShellEx.au3>

Local $sFile = InputBox('Run', 'Type the name of a program, folder, document, or Internet resource to open it', '', '', 368, 152)

If $sFile Then
	_WinAPI_ShellExecute($sFile, '', '', 'open')
	If @error Then
		Local $iError = @error
		Local $iExtended = @extended
		MsgBox(($MB_ICONERROR + $MB_SYSTEMMODAL), 'Error = ' & $iError, 'Unable to open "' & $sFile & '".' & @CRLF & @CRLF & _WinAPI_GetErrorMessage($iExtended))
	EndIf
EndIf
