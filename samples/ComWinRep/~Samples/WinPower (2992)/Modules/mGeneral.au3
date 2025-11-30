#include-once

Func _OpenTextFile($TXTFiName)
	If FileExists($TXTFiName) Then
		_MemoLogWrite("Opening [" & $TXTFiName & "]")
		If FileExists($GNote2Exe) Then
			ShellExecute($GNote2Exe, $TXTFiName)
		Else
			_MemoLogWrite("Could not locate [" & $GNote2Exe & "].", 3)
			_MemoLogWrite("The file will now be opened in your default text editor.")
			ShellExecute($TXTFiName)
		EndIf
	Else
		_MemoLogWrite("Could not find the [" & $TXTFiName & "] file.", 2)
	EndIf
EndFunc

Func _PowerLogStart()
	Local $MemArr = MemGetStats()

_MemoLogWrite("----------------------------------------------------------------------", 0, 0, 1, 0)
_MemoLogWrite($PowerTitle & " " & $PowerVer, 0, 0, 1, 0)
_MemoLogWrite(_GetOSFullVersion() & " Build: " & @OSBuild & " (" & @OSArch & ")", 0, 0, 1, 0)
_MemoLogWrite("----------------------------------------------------------------------", 0, 0, 1, 0)
_MemoLogWrite("", 0, 0, 0)
_MemoLogWrite("----------------------------------------------------------------------", 0, 0, 0)
_MemoLogWrite($PowerTitle, 0, 0, 0)
_MemoLogWrite("----------------------------------------------------------------------", 0, 0, 0)
_MemoLogWrite("", 0, 0, 0)
_MemoLogWrite("Version                : " & $PowerVer, 0, 0, 0)
_MemoLogWrite("Release Date           : " & $PowerRelDate, 0, 0, 0)
_MemoLogWrite("User Name              : " & @UserName, 0, 0, 0)
_MemoLogWrite("Computer Name          : " & @ComputerName, 0, 0, 0)
_MemoLogWrite("OS Version             : " & _GetOSFullVersion() & " Build: " & @OSBuild & " (" & @OSArch & ")", 0, 0, 0)
_MemoLogWrite("Memory                 : " & Round($MemArr[1] / 1024, 0) & " MB", 0, 0, 0)
_MemoLogWrite("Memory Free            : " & Round($MemArr[2] / 1024, 0) & " MB", 0, 0, 0)
_MemoLogWrite("PageFile               : " & Round($MemArr[3] / 1024, 0) & " MB", 0, 0, 0)
_MemoLogWrite("PageFile Free          : " & Round($MemArr[4] / 1024, 0) & " MB", 0, 0, 0)
_MemoLogWrite("Virtual Memory         : " & Round($MemArr[5] / 1024, 0) & " MB", 0, 0, 0)
_MemoLogWrite("Virtual Memory Free    : " & Round($MemArr[6] / 1024, 0) & " MB", 0, 0, 0)
_MemoLogWrite("Time Stamp             : " & @YEAR & "/" & @MON & "/" & @MDAY & ", " & @HOUR & ":" & @MIN, 0, 0, 0)
_MemoLogWrite("", 0, 0, 0)
_MemoLogWrite("----------------------------------------------------------------------", 0, 0, 0)
_MemoLogWrite("", 0, 0, 0)
EndFunc

Func _GetOSFullVersion()
	Local $OSInfoKeyName = "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows NT\CurrentVersion"
	Local $OSProductName
	Local $OSEditionID

	$OSProductName = RegRead($OSInfoKeyName, "ProductName")
	$OSEditionID = RegRead($OSInfoKeyName, "EditionID")

	If $OSEditionID <> "" Then
		Return $OSProductName & " " & $OSEditionID
	Else
		Return $OSProductName
	EndIf
EndFunc


Func _GetAMPM($HOUR = "")
	If $HOUR > 0 And $HOUR < 12 Then
		Return "AM"
	Else
		Return "PM"
	EndIf
EndFunc

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

Func _ReduceMemory($i_PID = -1)
	If $i_PID <> -1 Then
		Local $ai_Handle = DllCall("kernel32.dll", 'int', 'OpenProcess', 'int', 0x1f0fff, 'int', False, 'int', $i_PID)
		Local $ai_Return = DllCall("psapi.dll", 'int', 'EmptyWorkingSet', 'long', $ai_Handle[0])
		DllCall('kernel32.dll', 'int', 'CloseHandle', 'int', $ai_Handle[0])
	Else
		Local $ai_Return = DllCall("psapi.dll", 'int', 'EmptyWorkingSet', 'long', -1)
	EndIf
	Return $ai_Return[0]
EndFunc   ;==>_ReduceMemory

Func _ReregisterDLL($FPATH)
		_MemoLogWrite("RegSvr32.exe: Registering " & $FPATH & ".....")
		Local $RSVR32Error = ShellExecuteWait("regsvr32.exe", " /s " & $FPATH, "")

		Switch $RSVR32Error
			Case 0
				_MemoLogWrite("RegSvr32.exe: " & $FPATH & " registration succeeded.", 1)
			Case 3
				_MemoLogWrite("RegSvr32.exe: Registration failed: Specified module not found", 2)
			Case 5
				_MemoLogWrite("RegSvr32.exe: Registration failed: Error number: 0x80070005", 2)
		EndSwitch
	EndFunc   ;==>_ReregisterDLL


Func _Initialize()
	If Not IsAdmin() Then
		$iMBoxAnswer = MsgBox(4, $GPWinTitle, $PowerTitle & " is running with limited privileges. Some operations require administrative privileges. " & _
											  "To run " & $PowerTitle & " with administrative privileges, select no to exit and right-click on " & @ScriptName & _
											  "and select 'Run as administrator'. Would you like to continue without administrative privileges?", 10)
		If $iMBoxAnswer = 7 Then
			_PowerCLosedClicked()
		EndIf
	EndIf
EndFunc
