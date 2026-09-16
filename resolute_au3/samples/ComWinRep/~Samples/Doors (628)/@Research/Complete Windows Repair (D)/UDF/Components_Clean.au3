#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.8.0
 Author:         Rizonesoft

 Script Function:
	Clean Computer Function.

#ce ----------------------------------------------------------------------------


#include-once
#include <CoreWinRepair.au3>


Global Const $MOVEFILE_DELAY_UNTIL_REBOOT = 0x04


Func _FileUnlockDelete($sSource)

	If FileExists($sSource) Then
		Local $fileExten = StringRight($sSource, 3)

		_MemoLoggingWrite("Malicious file found @ [" & $sSource & "]. Removing it now...", 2)
		If $fileExten = "dll"  Or $fileExten = "ocx" Then
			_MemoLoggingWrite("Unregistering file @ [" & $sSource & "]")
			ShellExecuteWait("regsvr32.exe", " /u /s " & Chr(34) & $sSource & Chr(34), "")
		EndIf

		If Not FileDelete($sSource) Then
			FileSetAttrib($sSource, "-RASHNOT")
			Sleep(500)
			If Not FileDelete($sSource) Then
				_KillProcessFromPath($sSource)
				Sleep(500)
				If Not FileDelete($sSource) Then
					_FileDeleteOnReboot($sSource)
					_MemoLoggingWrite("Could not remove [" & $sSource & "]. Will attempt to remove it on reboot.", 3)
				Else
					_MemoLoggingWrite("Malicious file terminated.", 1)
				EndIf
			Else
				_MemoLoggingWrite("Malicious file terminated.", 1)
			EndIf
		Else
			_MemoLoggingWrite("Malicious file terminated.", 1)
		EndIf

	EndIf

EndFunc


Func _DirectoryUnlockDelete($dirPath)

	If FileExists($dirPath) Then _MemoLoggingWrite("Malicious directory found @ [" & $dirPath & "]. Clearing it now...", 2)

	Local $searchHandle = FileFindFirstFile($dirPath & "\*.*")
    If $searchHandle == -1 Or @error == 1 Then
		Return
    EndIf

	If Not _ScanFolder($searchHandle, $dirPath) Then
		FileClose($searchHandle)
		Sleep(100)
		DirRemove($dirPath, 1)
		Return
	EndIf

EndFunc


Func _ScanFolder($searchHandle, $searchLocation)

	Local $return, $fileName, $secondSearch

    While (True)

        $fileName = FileFindNextFile($searchHandle)
        If @error Then ExitLoop

		$return &= $searchLocation & "\" & $fileName
		If StringInStr(FileGetAttrib($searchLocation & "\" & $fileName), "D") Then
			$secondSearch = FileFindFirstFile($searchLocation & "\" & $fileName & "\*.*")
            $return &= _ScanFolder($secondSearch, $searchLocation & "\" & $fileName)
			FileClose($secondSearch)
		Else
			_FileUnlockDelete($return)
		EndIf

		$return = ""

	WEnd

	Return $return

EndFunc


Func _FileDeleteOnReboot($sSource)
	Local $Return
    $Return = DllCall('kernel32.dll', 'int', 'MoveFileExW', 'wstr', $sSource, 'ptr', 0, 'dword', $MOVEFILE_DELAY_UNTIL_REBOOT)
    Return $Return[0]
EndFunc


Func _KillProcessFromPath($fileName)

	If FileExists($fileName) Then

		Local $Plist = ProcessList()
		For $i = 1 To $Plist[0][0]
			If _ProcessGetPath($Plist[$i][0]) = $fileName Then
				If ProcessExists($Plist[$i][0]) Then ProcessClose($Plist[$i][0])
			EndIf
		Next

	EndIf

EndFunc


Func _KillProcessList($sProc)

	Local $Plist = ProcessList($sProc)
	For $i = 1 To $Plist[0][0]
		If ProcessExists($Plist[$i][0]) Then
			If _KillProcess($Plist[$i][1]) Then
				_MemoLoggingWrite("Killed " & $Plist[$i][0] & " : " & $Plist[$i][1], 1)
			EndIf
		EndIf
	Next

EndFunc


Func _KillProcess($PID)

	If ProcessClose($PID) Then
		Return True
	Else
		Switch @error
			Case 1
				_MemoLoggingWrite("(OpenProcess failed)", 3)
			Case 2
				_MemoLoggingWrite("(AdjustTokenPrivileges Failed)", 3)
			Case 3
				_MemoLoggingWrite("(TerminateProcess Failed)", 3)
			Case 4
				_MemoLoggingWrite("(Cannot verify if process exists)", 3)
		EndSwitch
		Return False
	EndIf

EndFunc


Func _ProcessGetPath($PID)
    If IsString($PID) Then $PID = ProcessExists($PID)
    Local $Path = DllStructCreate('char[1000]')
    Local $dll = DllOpen('Kernel32.dll')
    Local $handle = DllCall($dll, 'int', 'OpenProcess', 'dword', 0x0400 + 0x0010, 'int', 0, 'dword', $PID)
    Local $ret = DllCall('Psapi.dll', 'long', 'GetModuleFileNameEx', 'long', $handle[0], 'int', 0, 'ptr', DllStructGetPtr($Path), 'long', DllStructGetSize($Path))
    $ret = DllCall($dll, 'int', 'CloseHandle', 'hwnd', $handle[0])
    DllClose($dll)
    Return DllStructGetData($Path, 1)
EndFunc


Func _RemoveMalwareAndTraces()

	_StartLogging("Removing common malware and traces left behind, please wait...")

	_MemoLoggingWrite("Restoring critical functionality required for cleaning Malware.")
	RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\Classes\batfile\shell\open\command", "", "REG_SZ", Chr(34) & "%1" & Chr(34) & " %*")
	RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\Classes\comfile\shell\open\command", "", "REG_SZ", Chr(34) & "%1" & Chr(34) & " %*")
	RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\Classes\exefile\shell\open\command", "", "REG_SZ", Chr(34) & "%1" & Chr(34) & " %*")
	RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\Classes\piffile\shell\open\command", "", "REG_SZ", Chr(34) & "%1" & Chr(34) & " %*")
	RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\Classes\regfile\shell\open\command", "", "REG_SZ", "regedit.exe " & Chr(34) & "%1" & Chr(34))
	RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\Classes\scrfile\shell\open\command", "", "REG_SZ", Chr(34) & "%1" & Chr(34) & " %*")

	_MemoLoggingWrite("Killing malicious processes. (20)")
	_KillProcessList("__ARESTRA__best.exe")
	_KillProcessList("AdobeR.exe")
	_KillProcessList("AVRSYS.EXE")
	_KillProcessList("Bunga_X.exe")
	_KillProcessList("desktop.exe")
	_KillProcessList("EraleuH.exe")
	_KillProcessList("filesrv32.exe")
	_KillProcessList("flashy.exe")
	_KillProcessList("Knight.exe")
	_KillProcessList("iexplore.exe")
	_KillProcessList("RavMonE.exe")
	_KillProcessList("rvhost.exe")
	_KillProcessList("schedl.exe")
	_KillProcessList("SCVVHSOT.exe")
	_KillProcessList("Server.exe")
	_KillProcessList("w32sys.exe")
	_KillProcessList("wscript.exe")

	_KillProcessFromPath(@WindowsDir & "\system\svchost.exe")
	_KillProcessFromPath(@WindowsDir & "\svchost.exe")
	_KillProcessFromPath("B:\Recycler\ctfmon.exe")
	;ShellExecute(@WindowsDir)

	_MemoLoggingWrite("Finding and removing malicious files. (30)")
	_FileUnlockDelete(@AppDataDir & "\Internet Security Guard\cookies.sqlite")
	_FileUnlockDelete(@AppDataDir & "\Internet Security Guard\Instructions.ini")
	_DirectoryUnlockDelete(@AppDataDir & "\Internet Security Guard")
	_FileUnlockDelete(@AppDataDir & "\Microsoft\Internet Explorer\Quick Launch\Internet Security Guard.lnk")
	_FileUnlockDelete(@AppDataCommonDir & "\79b35\ISa76.exe")
	_FileUnlockDelete(@AppDataCommonDir & "\79b35\ISG.ico")
	_DirectoryUnlockDelete(@AppDataCommonDir & "\79b35")
	_FileUnlockDelete(@AppDataCommonDir & "\ISEUG\ISKIYFOAG.cfg")
	_DirectoryUnlockDelete(@AppDataCommonDir & "\ISEUG")
	_FileUnlockDelete(@UserProfileDir & "\Desktop\Internet Security Guard.lnk")
	_FileUnlockDelete(@UserProfileDir & "\Recent\ANTIGEN.exe")
	_FileUnlockDelete(@UserProfileDir & "\Recent\cb.drv")
	_FileUnlockDelete(@UserProfileDir & "\Recent\CLSV.dll")
	_FileUnlockDelete(@UserProfileDir & "\Recent\eb.dll")
	_FileUnlockDelete(@UserProfileDir & "\Recent\energy.exe")
	_FileUnlockDelete(@UserProfileDir & "\Recent\energy.tmp")
	_FileUnlockDelete(@UserProfileDir & "\Recent\fan.sys")
	_FileUnlockDelete(@UserProfileDir & "\Recent\fix.sys")
	_FileUnlockDelete(@UserProfileDir & "\Recent\FW.drv")
	_FileUnlockDelete(@UserProfileDir & "\Recent\gid.dll")
	_FileUnlockDelete(@UserProfileDir & "\Recent\PE.exe")
	_FileUnlockDelete(@UserProfileDir & "\Recent\ppal.sys")
	_FileUnlockDelete(@UserProfileDir & "\Recent\SICKBOY.tmp")
	_FileUnlockDelete(@UserProfileDir & "\Recent\sld.sys")
	_FileUnlockDelete(@UserProfileDir & "\Recent\SM.dll")
	_FileUnlockDelete(@UserProfileDir & "\Recent\SM.exe")
	_FileUnlockDelete(@UserProfileDir & "\Recent\snl2w.drv")
	_FileUnlockDelete(@UserProfileDir & "\Recent\tjd.tmp")
	_FileUnlockDelete(@UserProfileDir & "\Start Menu\Internet Security Guard.lnk")
	_FileUnlockDelete(@UserProfileDir & "\Start Menu\Programs\Internet Security Guard.lnk")

	_MemoLoggingWrite("Some of the pests should be gone now.", 1)
	_EndLogging()

EndFunc