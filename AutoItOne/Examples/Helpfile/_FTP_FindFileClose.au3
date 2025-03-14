#include <FTPEx.au3>

;~ Local $sServer = 'ftp.cs.brown.edu' ; Brown Computer Science
Local $sServer = 'speedtest.tele2.net' ; Tele2 Speedtest Service
Local $sUsername = ''
Local $sPass = ''

Local $hOpen = _FTP_Open('MyFTP Control')
Local $hConn = _FTP_Connect($hOpen, $sServer, $sUsername, $sPass)

Local $h_Handle
;~ Local $aFile = _FTP_FindFileFirst($hConn, "/pub/papers/graphics/research/", $h_Handle)
Local $aFile = _FTP_FindFileFirst($hConn, "/", $h_Handle)

Local $iFindClose = _FTP_FindFileClose($h_Handle)
ConsoleWrite('$iFindClose = ' & $iFindClose & '  -> Error code: ' & @error & @CRLF)

Local $iFtpc = _FTP_Close($hConn)
Local $iFtpo = _FTP_Close($hOpen)
