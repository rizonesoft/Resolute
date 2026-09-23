#include-once

;Vista Rename Enhancement
Func _VistaRename()
	HotKeySet("{F2}"); prevent infinite loop gotcha
	Send("{F2}")
	If (_WinGetClass(WinGetTitle('')) = "CabinetWClass") Or _
		(_WinGetClass(WinGetTitle('')) = "Progman") Then
		Local $OldClip = ClipGet()
		Sleep(100)
		Send("^c")
		Local $sFilename = ClipGet()
		Local $iExtPosition = StringInStr($sFilename, ".", 0, -1)
		If $iExtPosition <> 0 Then
			Local $iPosition = StringLen($sFilename) - $iExtPosition
			Local $i = 0
			Send("^{HOME}")
			Do
				Send("+{RIGHT}")
				$i += 1
			Until $i = ($iExtPosition - 1)
			Send("{SHIFTDOWN}{SHIFTUP}")
		EndIf
		ClipPut($OldClip)
	EndIf
	HotKeySet("{F2}", "_VistaRename"); re-enable hotkey
EndFunc

Func _WinGetClass($hWnd)
    If IsHWnd($hWnd) = 0 And WinExists($hWnd) Then $hWnd = WinGetHandle($hWnd)
    Local $aGCNDLL = DllCall('User32.dll', 'int', 'GetClassName', 'hwnd', $hWnd, 'str', '', 'int', 4095)
    If @error = 0 Then Return $aGCNDLL[2]
    Return SetError(1, 0, '')
EndFunc



Func _GetProgramVersion($File, $VerCount = 1)

	Local $VReturn = ""

	$Ver = FileGetVersion($File)
	$Data = StringSplit($Ver, ".")
	$i = 0
	Do
		$i = $i + 1
		$VReturn &= $Data[$i]
		$VReturn &= "."
	Until $i = $VerCount Or $i = $Data[0]
	$VReturn = StringTrimRight($VReturn, 1)
	Return $VReturn

EndFunc
