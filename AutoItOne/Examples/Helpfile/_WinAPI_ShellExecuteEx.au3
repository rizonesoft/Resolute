#include <MsgBoxConstants.au3>
#include <WinAPIError.au3>
#include <WinAPIShellEx.au3>

Local $hWin = _ShowFileProperties('C:\Program Files (x86)\AutoIt3\AutoIt3.exe')
If @error Then
	MsgBox($MB_ICONERROR + $MB_TOPMOST, "Error", "Unable to get the properties of" & @CRLF & _
			"@error = " & @error & " extended = " & @extended)
	Exit
EndIf

While WinExists($hWin)
	; needed as the closing of the script will close the windows open by _ShowFileProperties()
WEnd

Func _ShowFileProperties($sFile, $sVerb = "properties", $hParent = 0)
	; function by Rasim/orbs
	; https://www.autoitscript.com/forum/topic/162302-solved-open-files-properties-via-autoit/?tab=comments#comment-1179632
	; https//www.autoitscript.com/forum/index.php?showtopic=78236&view=findpost&p=565547 by Rasin but no more working

	Local $sPropBuff, $sFileBuff, $tSHELLEXECUTEINFO

	$sPropBuff = DllStructCreate("wchar[256]")
	DllStructSetData($sPropBuff, 1, $sVerb)

	$sFileBuff = DllStructCreate("wchar[256]")
	DllStructSetData($sFileBuff, 1, $sFile)

	$tSHELLEXECUTEINFO = DllStructCreate($tagSHELLEXECUTEINFO)

	$tSHELLEXECUTEINFO.Size = DllStructGetSize($tSHELLEXECUTEINFO)
	$tSHELLEXECUTEINFO.Mask = $SEE_MASK_INVOKEIDLIST
	$tSHELLEXECUTEINFO.hWnd = $hParent
	$tSHELLEXECUTEINFO.Verb = DllStructGetPtr($sPropBuff, 1)
	$tSHELLEXECUTEINFO.File = DllStructGetPtr($sFileBuff, 1)

	Local $iRet = _WinAPI_ShellExecuteEx($tSHELLEXECUTEINFO)

	If @error Then Return SetError(@error, @extended, 0)
	If $iRet = 0 Then Return SetError(10, _WinAPI_GetLastError(), 0)

	Return WinWaitActive("[CLASS:#32770]")
EndFunc   ;==>_ShowFileProperties
