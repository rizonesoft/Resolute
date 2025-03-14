; I am the server, start me first! (Start in second the example 2 of the TCPRecv function).

#include <FileConstants.au3>
#include <MsgBoxConstants.au3>
#include <WinAPIError.au3>

Example()

Func Example()
	Local $sMsgBoxTitle = "AutoItVersion = " & @AutoItVersion

	; Assign a Local variable the path of a file chosen through a dialog box.
	Local $sFilePath = FileOpenDialog("Select a file to send", @MyDocumentsDir, "All types (*.*)", BitOR($FD_FILEMUSTEXIST, $FD_PATHMUSTEXIST))

	; Note: Choose a file bigger than 4 kiB otherwise the first example is enough.

	; If an error occurred display the error code and return False.
	If @error Then
		MsgBox(($MB_SYSTEMMODAL + $MB_ICONEXCLAMATION), $sMsgBoxTitle, "Server: Invalid file chosen" & @CRLF & " Error code: " & @error)
		Return False
	EndIf

	TCPStartup() ; Start the TCP service.

	; Register OnAutoItExit to be called when the script is closed.
	OnAutoItExitRegister("OnAutoItExit")

	; Assign Local variables the loopback IP Address and the Port.
	Local $sIPAddress = "127.0.0.1" ; This IP Address only works for testing on your own computer.
	Local $iPort = 65432 ; Port used for the connection.

	; Assign a Local variable the socket and bind to the IP Address and Port specified with a maximum of 100 pending connexions.
	Local $iListenSocket = TCPListen($sIPAddress, $iPort, 100)

	; If an error occurred display the error code and return False.
	If @error Then
		; Someone is probably already listening on this IP Address and Port (script already running?).
		MsgBox(($MB_SYSTEMMODAL + $MB_ICONHAND), $sMsgBoxTitle, "Server: Could not listen" & @CRLF & " Error code: " & @error & @CRLF & @CRLF & _WinAPI_GetErrorMessage(@error))
		Return False
	EndIf

	; Assign a Local variable to be used by the Client socket.
	Local $iSocket = 0

	Do ; Wait for someone to connect (Unlimited).
		; Accept incomming connexions if present (Socket to close when finished; one socket per client).
		$iSocket = TCPAccept($iListenSocket)

		; If an error occurred display the error code and return False.
		If @error Then
			MsgBox(($MB_SYSTEMMODAL + $MB_ICONHAND), $sMsgBoxTitle, "Server: Could not accept the incoming connection" & @CRLF & " Error code: " & @error & @CRLF & _WinAPI_GetErrorMessage(@error))
			Return False
		EndIf
	Until $iSocket <> -1 ;if different from -1 a client is connected.

	; Close the Listening socket to allow afterward binds.
	TCPCloseSocket($iListenSocket)

	; Assign a Local variable the size of the file previously chosen.
	Local $iFileSize = FileGetSize($sFilePath)

	; Assign a Local variable the handle of the file opened in binary mode.
	Local $hFile = FileOpen($sFilePath, $FO_BINARY)

	; Assign a Local variable the offset of the file being read.
	Local $iOffset = 0

	; Assign a Local variable the number representing 4 KiB.
	Local $i4KiB = 4096
	If $CmdLine[0] Then $i4KiB = $CmdLine[1]

	; Note: The file is send by parts of 4 KiB.

	; Send the binary data of the file to the server.
	Do
		; Set the file position to the current offset.
		FileSetPos($hFile, $iOffset, $FILE_BEGIN)

		; The file is read from the position set to 4 KiB and directly wrapped into the TCPSend function.
		TCPSend($iSocket, FileRead($hFile, $i4KiB))

		; If an error occurred display the error code and return False.
		If @error Then
			MsgBox(($MB_SYSTEMMODAL + $MB_ICONHAND), $sMsgBoxTitle, "Server: Could not send the data" & @CRLF & " Error code: " & @error & @CRLF & _WinAPI_GetErrorMessage(@error))

			; Close the socket.
			TCPCloseSocket($iSocket)
			Return False
		EndIf

		; Increment the offset of 4 KiB to send the next 4 KiB data.
		$iOffset += $i4KiB
	Until $iOffset >= $iFileSize

	; Close the file handle.
	FileClose($hFile)

	; Display the successful message.
	If $CmdLine[0] = 0 Then MsgBox($MB_SYSTEMMODAL, $sMsgBoxTitle, "Server:" & @CRLF & "File sent nbBytes=" & FileGetSize($sFilePath), 2)

	; Close the socket.
	TCPCloseSocket($iSocket)
EndFunc   ;==>Example

Func OnAutoItExit()
	TCPShutdown() ; Close the TCP service.
EndFunc   ;==>OnAutoItExit
