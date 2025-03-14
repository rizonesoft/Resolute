; Script to launch both sender and receiver

; packet size to send or receive
Local $iPacketSize = 4096

Run(@AutoItExe & " TCPSend[2].au3 " & $iPacketSize)

; wait file selection to be transmit
WinWait("Select")
WinWaitClose("Select")

Run(@AutoItExe & " TCPRecv[2].au3 " & $iPacketSize)
