#Include <APIConstants.au3>
#Include <Misc.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)
Opt('TrayAutoPause', 0)

Global $hProgressProc = DllCallbackRegister('_ProgressProc', 'dword', 'uint64;uint64;uint64;uint64;dword;dword;ptr;ptr;long_ptr')

ProgressOn('_WinAPI_CopyFileEx', 'Copying...', '', -1, -1, 2)

_WinAPI_CopyFileEx('D:\Test.tmp', 'C:\Test.tmp', 0, DllCallBackGetPtr($hProgressProc))
If @error Then
	_WinAPI_ShowLastError()
EndIf

DllCallbackFree($hProgressProc)

ProgressOff()

Func _ProgressProc($iTotalFileSize, $iTotalBytesTransferred, $iStreamSize, $iStreamBytesTransferred, $iStreamNumber, $iCallbackReason, $hSourceFile, $hDestinationFile, $iData)

	Local $Percent = Round($iTotalBytesTransferred / $iTotalFileSize * 100)

	If $Percent = 100 Then
		ProgressSet($Percent, '', 'Complete')
	Else
		ProgressSet($Percent)
	EndIf
	If _IsPressed('1B') Then
		Return $PROGRESS_CANCEL
	Else
		Return $PROGRESS_CONTINUE
	EndIf
EndFunc   ;==>_ProgressProc
