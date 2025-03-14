Example()

Func Example()
	; Run Write
	Run("Write.exe")

	; Wait 10 seconds for the Write window to appear.
	Local $hWnd = WinWait("[CLASS:WordPadClass]", "", 10)

	; Set the title of the Write window using the handle returned by WinWait.
	WinSetTitle($hWnd, "", "New WordPad Title - AutoIt")

	; Wait for 2 seconds to display the Write window and the new title.
	Sleep(2000)

	; Close the Write window using the handle returned by WinWait.
	WinClose($hWnd)
EndFunc   ;==>Example
