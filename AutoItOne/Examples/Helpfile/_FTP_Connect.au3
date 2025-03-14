#include <FTPEx.au3>
#include <MsgBoxConstants.au3>

_Example()

Func _Example()
;~ 	Local $sServer = 'ftp.cs.brown.edu' ; Brown Computer Science
	Local $sServer = 'speedtest.tele2.net' ; Tele2 Speedtest Service
	Local $sUsername = ''
	Local $sPass = ''

	Local $hOpen = _FTP_Open('MyFTP Control')
	Local $hConn = _FTP_Connect($hOpen, $sServer, $sUsername, $sPass)
	If @error Then
		MsgBox($MB_SYSTEMMODAL, '_FTP_Connect', 'ERROR=' & @error)
	Else
		Local $iErr = @error, $sFTP_Message
		_FTP_GetLastResponseInfo($iErr, $sFTP_Message)
		ConsoleWrite('$iErr=' & $iErr & '   $sFTP_Message:' & @CRLF & $sFTP_Message & @CRLF)
		; do something ...
	EndIf
	_FTP_Close($hConn)
	_FTP_Close($hOpen)
EndFunc   ;==>_Example
