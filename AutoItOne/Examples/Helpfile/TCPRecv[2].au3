; I am the client, start me after the server! (Start first the example 2 of the TCPSend function).

#include <AutoItConstants.au3>
#include <FileConstants.au3>
#include <MsgBoxConstants.au3>
#include <WinAPIError.au3>

Example()

Func Example()
	Local $sMsgBoxTitle = "AutoItVersion = " & @AutoItVersion

	TCPStartup() ; Start the TCP service.

	; Register OnAutoItExit to be called when the script is closed.
	OnAutoItExitRegister("OnAutoItExit")

	; Assign Local variables the loopback IP Address and the Port.
	Local $sIPAddress = "127.0.0.1" ; This IP Address only works for testing on your own computer.
	Local $iPort = 65432 ; Port used for the connection.

	; Assign a Local variable the socket and connect to a listening socket with the IP Address and Port specified.
	Local $iSocket = TCPConnect($sIPAddress, $iPort)

	; If an error occurred display the error code and return False.
	If @error Then
		; The server is probably offline/port is not opened on the server.
		MsgBox(($MB_SYSTEMMODAL + $MB_ICONHAND), $sMsgBoxTitle, "Client: Could not connect" & @CRLF & " Error code: " & @error & @CRLF & @CRLF & _WinAPI_GetErrorMessage(@error))
		Return False
	EndIf

	; Assign a Local variable the path of the file which will be received.
	Local $sFilePath = @TempDir & "\temp.dat"
	FileDelete($sFilePath)

	; If an error occurred display the error code and return False.
	If @error Then
		MsgBox(($MB_SYSTEMMODAL + $MB_ICONEXCLAMATION), $sMsgBoxTitle, "Client: Invalid file chosen" & @CRLF & " Error code: " & @error & @CRLF & @CRLF & _WinAPI_GetErrorMessage(@error))
		Return False
	EndIf

	; Assign a Local variable the handle of the file opened in binary overwrite mode.
	Local $hFile = FileOpen($sFilePath, BitOR($FO_BINARY, $FO_OVERWRITE))

	; Assign Locales Constant variables the number representing 4 KiB; the binary code for the end of the file and the length of the binary code.
	Local $i4KiB = 4096
	If $CmdLine[0] Then $i4KiB = $CmdLine[1]

	Local $dData, $nReceivedBytes = 0, $n = 0, $fDiffTime, $hTimer = TimerInit()
	#forceref $dData
	While 1
		$dData = TCPRecv($iSocket, $i4KiB, $TCP_DATA_BINARY)

		; If an error occurred display the error code and return False.
		If @error Then
			MsgBox(($MB_SYSTEMMODAL + $MB_ICONHAND), $sMsgBoxTitle, "Client: Connection lost n=" & $n & @CRLF & " Error code: " & @error & @CRLF & @CRLF & _WinAPI_GetErrorMessage(@error))
			Return False
		ElseIf @extended = 1 Or BinaryLen($dData) = 0 Then
			; If nothing is received
			ExitLoop
		EndIf

		$nReceivedBytes += BinaryLen($dData)
		$n += 1
;~ 		FileWrite($hFile, $dData) ; to be uncommented if file content to be written
	WEnd
	$fDiffTime = TimerDiff($hTimer)
	; Close the file handle.
	FileClose($hFile)

	; Display the successful message.
;~ 	MsgBox($MB_SYSTEMMODAL, "", "Client:" & @CRLF & "File received nbBytes=" & & FileGetSize($sFilePath))
	MsgBox($MB_SYSTEMMODAL, $sMsgBoxTitle, "Client: receivedBytes = " & $nReceivedBytes & " packetSize = " & $i4KiB & @CRLF & "File received TCPRecv = " & Int($fDiffTime / $n * 1000) & "µs Total = " & Int($fDiffTime) & "ms nPacket = " & $n)

	; Close the socket.
	TCPCloseSocket($iSocket)
EndFunc   ;==>Example

Func OnAutoItExit()
	TCPShutdown() ; Close the TCP service.
EndFunc   ;==>OnAutoItExit
