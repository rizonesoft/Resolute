#include-once

Func _ClearProcessesWorkingSet()
	_DisableControls()
	_MemoLogWrite("Optimizing Memory by Clearing Processes Working Set.....")
	$ProcessList = ProcessList()
	For $i = 1 To $ProcessList[0][0]
		_GUICtrlStatusBar_SetText ($hStatus, "Clearing Process " & $i & " Of " & $ProcessList[0][0] & " Working Set.....")
		Sleep(10)
		$ProcessHandle = DllCall("kernel32.dll", "int", "OpenProcess", "int", $PROCESS_ALL_ACCESS, "int", False, "int", $ProcessList[$i][1])
		DllCall("psapi.dll", "int", "EmptyWorkingSet", "int", $ProcessHandle[0])
		DllCall("kernel32.dll", "int", "CloseHandle", "int", $ProcessHandle[0])
		GUICtrlSetData($MemProg, ($i / $ProcessList[0][0]) * 100)
	Next
	$MemStats = MemGetStats()
	GUICtrlSetData($MemProg, $MemStats[0])
	_GUICtrlStatusBar_SetText($hStatus, _GetOSFullVersion(), 0)
	_MemoLogWrite("Memory Optimization complete.", 1)
	_EnableControls()
EndFunc ; ==> _ClearProcessesWorkingSet

Func _FlushFileCache()

	If IsAdmin() Then
		If $GDRIVES[0] > 0 Then
			For $i = 1 to $GDRIVES[0]
				_MemoLogWrite("Flushing File Buffers [" & StringUpper($GDRIVES[$i]) & "].....")
				$hDLLkernel32 = DllOpen("kernel32.dll")
				If $hDLLkernel32 <> -1 Then
					$hDLLOne = $hDLLkernel32
				Else
					$hDLLOne = "kernel32.dll"
				EndIf
				; Open volume handle, GENERIC_READ on a volume requires admin rights
				$hFlush = DllCall($hDLLkernel32, "ptr", "CreateFile", "str", "\\.\" & $GDRIVES[$i], "dword", 0x80000000, "dword", 0x3, "ptr", 0, "dword", 3, "dword", 0, "ptr", 0)
				If @error <> 0 And $hFlush[0] <> -1 Then
					_MemoLogWrite("Could not open handle.", 2)
					DllCall($hDLLOne, "int", "FlushFileBuffers", "ptr", $hFlush[0]) ; Flush file buffers
					If @error <> 0 Then
						_MemoLogWrite("Could not Flush File Buffers.", 2)
						DllCall($hDLLOne, "int", "CloseHandle", "ptr", $hFlush[0]) ; Close volume handle
						If $hDLLkernel32 <> -1 Then DllClose($hDLLkernel32) ; Close DLL handle
					EndIf
					DllCall($hDLLOne, "int", "CloseHandle", "ptr", $hFlush[0]) ; Close volume handle
				EndIf
				If $hDLLkernel32 <> -1 Then DllClose($hDLLkernel32)
				_MemoLogWrite("File Buffers Flushed successfully.", 1)
			Next
		EndIf
	EndIf

EndFunc

Func _ClearSystemCache()
	Local $CleanMemExe = @ScriptDir & "\Bin\CleanMem.exe"

	While ProcessExists("CleanMem.exe")
		ProcessClose("CleanMem.exe")
	WEnd
	FileInstall("Bin\CleanMem.exe", $CleanMemExe, 0)
	If FileExists($CleanMemExe) Then
		ShellExecute($CleanMemExe)
	EndIf
EndFunc

Func _ProcessIdleTasks()
	_DisableControls()
	_MemoLogWrite("Processing Idle Tasks.....")
	_MemoLogWrite("Processing Idle Tasks can take up to 10 minutes to complete.....")
	ShellExecuteWait("rundll32.exe", "advapi32.dll,ProcessIdleTasks")
	_MemoLogWrite("Done Processing Idle Tasks.", 1)
	_EnableControls()
EndFunc

Func _OptimizeRegistry()
	If FileExists($GQRegDefExe) Then
		ShellExecute($GQRegDefExe)
		_MemoLogWrite("Starting [" & $GQRegDefExe & "]")
	Else
	    _MemoLogWrite("Could not locate [" & $GQRegDefExe & "]", 2)
		_StartNTREGOPT()
	EndIf
EndFunc

Func _StartNTREGOPT()
	Local $EXCode
	_DisableControls()
	If FileExists($GNTREGOPTEXE) Then
		_MemoLogWrite("Starting registry optimization.....", 1)
		$EXCode = ShellExecuteWait($GNTREGOPTEXE)
		Select
			Case $EXCode = 0
				_MemoLogWrite("The registry is now optimized.", 1)
				_MemoLogWrite("You need to reboot your computer to activate the optimized registry.", 3)
				_MemoLogWrite("Using the registry optimizer again before rebooting your computer can result in errors.", 3)
			Case $EXCode = 1
				_MemoLogWrite("Registry optimization canceled.")
			Case $EXCode = 2
				_MemoLogWrite("The registry could not be optimized.", 2)
				_MemoLogWrite("A previous optimized registry was not activated. You can activate it by restarting your computer.", 2)
				_MemoLogWrite("Optimizing the registry before restarting your computer, can result in errors.", 2)
			Case Else

		EndSelect
	Else
		_MemoLogWrite("Could not find NTREGOPT.EXE, This file is needed to optimize the registry.", 2)
		_MemoLogWrite("You can download it from http://www.larshederer.homepage.t-online.de/erunt/", 2)
		_MemoLogWrite("After downloading extract all the files to the '" & $GNTREGOPTEXE & "' directory.", 2)
	EndIf
	_EnableControls()
EndFunc
