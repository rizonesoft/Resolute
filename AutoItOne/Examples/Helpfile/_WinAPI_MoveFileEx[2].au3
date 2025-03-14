; == Example 2 Running in Admin Mode to use $MOVE_FILE_DELAY_UNTIL_REBOOT to delete the file

#RequireAdmin

#include <APIFilesConstants.au3>
#include <Misc.au3>
#include <WinAPIError.au3>
#include <WinAPIFiles.au3>

Opt('TrayAutoPause', 0)

Example()

Func Example()
	Local $hProgressProc = DllCallbackRegister('_ProgressProc', 'bool', 'uint64;uint64;uint64;uint64;dword;dword;handle;handle;ptr')

	FileDelete(@TempDir & '\Test*.tmp')

	ProgressOn('_WinAPI_MoveFileEx()', 'Bigfile Creation...', '')
	Local $sFile = @TempDir & '\Test.tmp'
	Local $hFile = FileOpen($sFile, 2)
	For $i = 1 To 1000000
		FileWriteLine($hFile, "                                                     ")
	Next
	FileClose($hFile)

	ProgressOn('_WinAPI_MoveFileEx()', 'Moving...', '0%')
	Sleep(500) ; to show the change as moving on same device just rename

;~ 	If Not _WinAPI_MoveFileEx($sFile, @TempDir & '\Test1.tmp', $MOVE_FILE_DELAY_UNTIL_REBOOT, DllCallbackGetPtr($hProgressProc)) Then ; does not rename !!!

	; suppression of the file at the next reboot
	If Not _WinAPI_MoveFileEx($sFile, 0, $MOVE_FILE_DELAY_UNTIL_REBOOT, DllCallbackGetPtr($hProgressProc)) Then
		_WinAPI_ShowLastError('Error moving ' & $sFile)
		Exit
	EndIf

	DllCallbackFree($hProgressProc)

	ProgressOff()

	MsgBox(0, '_WinAPI_MoveFileEx()', $sFile & @CRLF & @CRLF & 'Will be deleted at the next reboot')

EndFunc   ;==>Example

Func _ProgressProc($iTotalFileSize, $iTotalBytesTransferred, $iStreamSize, $iStreamBytesTransferred, $iStreamNumber, $iCallbackReason, $hSourceFile, $hDestinationFile, $pData)
	#forceref $iStreamSize, $iStreamBytesTransferred, $iStreamNumber, $iCallbackReason, $hSourceFile, $hDestinationFile, $pData

	Local $iPercent = Round($iTotalBytesTransferred / $iTotalFileSize * 100)
	If $iPercent = 100 Then
		ProgressSet($iPercent, $iPercent & "%", 'Complete')
		Sleep(2000)
	Else
		ProgressSet($iPercent, $iPercent & "%")
	EndIf
	Sleep(100)

	If _IsPressed('1B') Then
		Return $PROGRESS_CANCEL
	Else
		Return $PROGRESS_CONTINUE
	EndIf
EndFunc   ;==>_ProgressProc
