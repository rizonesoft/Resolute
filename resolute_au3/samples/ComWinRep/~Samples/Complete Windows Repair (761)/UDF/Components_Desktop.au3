#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.8.0
 Author:         myName

 Script Function:
	Template AutoIt script.

#ce ----------------------------------------------------------------------------

#include-once


#include <CoreWinRepair.au3>


Global $RUN_TBDESKRESTORE = True
Global $RUN_REBUILDICONCACHE = True
Global $RB_REMDELETEADDRENAME = True


Func _ReturnRemoveDeleteCaption()
	If RegRead("HKEY_CLASSES_ROOT\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}\shell\Delete", "Description") <> "" Or _
		RegRead("HKEY_CLASSES_ROOT\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}\ShellFolder", "Attributes") = "0x50010020" Then
		$RB_REMDELETEADDRENAME = False
		Return " Restore Delete or remove Rename from Recycle Bin"
	Else
		$RB_REMDELETEADDRENAME = True
		Return " Remove Delete or add Rename to Recycle Bin"
	EndIf
EndFunc


Func _RestoreMissingRecycleBin()

	_StartLogging("Restoring missing Recycle Bin, please wait...")
	Switch @OSVersion
		Case "WIN_2008R2", "WIN_7", "WIN_2008", "WIN_VISTA"

			_MemoLoggingWrite("Restoring default configurations.")
			RegWrite("HKEY_CLASSES_ROOT\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}", "", "REG_SZ", "Recycle Bin")
			RegWrite("HKEY_CLASSES_ROOT\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}", "InfoTip", "REG_EXPAND_SZ", "@%SystemRoot%\system32\shell32.dll,-22915")
			RegWrite("HKEY_CLASSES_ROOT\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}", "LocalizedString", "REG_EXPAND_SZ", "@%SystemRoot%\system32\shell32.dll,-8964")
			RegWrite("HKEY_CLASSES_ROOT\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}", "AppID", "REG_EXPAND_SZ", "{E10F6C3A-F1AE-4ADC-AA9D-2FE65525666E}")
			RegWrite("HKEY_CLASSES_ROOT\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}", "SortOrderIndex", "REG_DWORD", "0x00000078")
			RegWrite("HKEY_CLASSES_ROOT\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}\InProcServer32", "", "REG_EXPAND_SZ", "%SystemRoot%\system32\shell32.dll")
			RegWrite("HKEY_CLASSES_ROOT\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}\InProcServer32", "ThreadingModel", "REG_SZ", "Apartment")
			RegWrite("HKEY_CLASSES_ROOT\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}\shellex\ContextMenuHandlers\{645FF040-5081-101B-9F08-00AA002F954E}")
			RegWrite("HKEY_CLASSES_ROOT\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}\shellex\PropertySheetHandlers\{645FF040-5081-101B-9F08-00AA002F954E}")
			RegWrite("HKEY_CLASSES_ROOT\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}\ShellFolder", "Attributes", "REG_BINARY", "0x40010020")
			RegWrite("HKEY_CLASSES_ROOT\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}\ShellFolder", "HideOnDesktopPerUser", "REG_SZ", "")

		Case "WIN_XP", "WIN_2003"

			_MemoLoggingWrite("Restoring default configurations.")
			RegWrite("HKEY_CLASSES_ROOT\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}", "", "REG_SZ", "Recycle Bin")
			RegWrite("HKEY_CLASSES_ROOT\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}", "InfoTip", "REG_EXPAND_SZ", "@%SystemRoot%\system32\SHELL32.dll,-22915")
			RegWrite("HKEY_CLASSES_ROOT\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}", "SortOrderIndex", "REG_DWORD", "0x00000060")
			RegWrite("HKEY_CLASSES_ROOT\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}", "IntroText", "REG_EXPAND_SZ", "@%SystemRoot%\system32\SHELL32.dll,-31748")
			RegWrite("HKEY_CLASSES_ROOT\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}", "LocalizedString", "REG_EXPAND_SZ", "@%SystemRoot%\system32\SHELL32.dll,-8964")
			RegWrite("HKEY_CLASSES_ROOT\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}\InProcServer32", "", "REG_SZ", "shell32.dll")
			RegWrite("HKEY_CLASSES_ROOT\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}\InProcServer32", "ThreadingModel", "REG_SZ", "Apartment")

			_CalculateRecycleBinContext()

		Case "WIN_2000"

			_MemoLoggingWrite("Restoring default configurations.")
			RegWrite("HKEY_CLASSES_ROOT\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}", "", "REG_SZ", "Recycle Bin")
			RegWrite("HKEY_CLASSES_ROOT\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}", "InfoTip", "REG_SZ", "Stores deleted items until you permanently remove them from your computer")
			RegWrite("HKEY_CLASSES_ROOT\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}", "SortOrderIndex", "REG_DWORD", "0x00000060")
			RegWrite("HKEY_CLASSES_ROOT\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}", "LocalizedString", "REG_SZ", "@C:\\WINNT\\system32\\shell32.dll,-8964@1033,Recycle Bin")
			RegWrite("HKEY_CLASSES_ROOT\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}\InProcServer32", "", "REG_SZ", "shell32.dll")
			RegWrite("HKEY_CLASSES_ROOT\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}\InProcServer32", "ThreadingModel", "REG_SZ", "Apartment")
			RegWrite("HKEY_CLASSES_ROOT\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}\shellex\ExtShellFolderViews\{5984FFE0-28D4-11CF-AE66-08002B2E1262}", "PersistMoniker", "REG_SZ", "file://%webdir%\\recycle.htt")

			_CalculateRecycleBinContext()

		Case Else
			_MemoLoggingWrite("Unsupported Operating System", 3)
			_EndLogging()
			Return

	EndSwitch

	_MemoLoggingWrite("Undoing changes made by tweaking programs.")
	RegWrite("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel", "{645FF040-5081-101B-9F08-00AA002F954E}", "REG_DWORD", 0)
	RegWrite("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu", "{645FF040-5081-101B-9F08-00AA002F954E}", "REG_DWORD", 0)
	RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\{645FF040-5081-101B-9F08-00AA002F954E}", "", "REG_SZ", "Recycle Bin")

	_MemoLoggingWrite("Clearing Group Policies.")
	RegDelete("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\NonEnum", "{645FF040-5081-101B-9F08-00AA002F954E}")
	RegDelete("KEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\NonEnum", "{645FF040-5081-101B-9F08-00AA002F954E}")

	_BroadcastChange()

	_MemoLoggingWrite("The Recycle Bin should be restored now we hope.", 1)
	_EndLogging()

EndFunc


Func _CalculateRecycleBinContext()

	If RegRead("HKEY_CLASSES_ROOT\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}\ShellFolder", "Attributes") = "0x50010020" Then
		RegWrite("HKEY_CLASSES_ROOT\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}\ShellFolder", "Attributes", "REG_BINARY", "0x50010020")
		RegWrite("HKEY_CLASSES_ROOT\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}\ShellFolder", "CallForAttributes", "REG_DWORD", "0x00000000")
	Else
		RegWrite("HKEY_CLASSES_ROOT\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}\ShellFolder", "Attributes", "REG_BINARY", "0x40010020")
		RegWrite("HKEY_CLASSES_ROOT\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}\ShellFolder", "CallForAttributes", "REG_DWORD", "0x00000040")
	EndIf

EndFunc


Func _RestoreRecycleBinIcons()

	_StartLogging("Restoring the default Recycle Bin icons, please wait...")
	Switch @OSVersion

		Case "WIN_2008R2", "WIN_7", "WIN_2008", "WIN_VISTA"
			RegWrite("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}\DefaultIcon", "", "REG_EXPAND_SZ", "%SystemRoot%\system32\imageres.dll,-54")
			RegWrite("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}\DefaultIcon", "Full", "REG_EXPAND_SZ", "%SystemRoot%\system32\imageres.dll,-54")
			RegWrite("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}\DefaultIcon", "Empty", "REG_EXPAND_SZ", "%SystemRoot%\system32\imageres.dll,-55")
			RegWrite("HKEY_CLASSES_ROOT\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}\DefaultIcon", "", "REG_EXPAND_SZ", "%SystemRoot%\System32\imageres.dll,-55")
			RegWrite("HKEY_CLASSES_ROOT\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}\DefaultIcon", "Empty", "REG_EXPAND_SZ", "%SystemRoot%\System32\imageres.dll,-55")
			RegWrite("HKEY_CLASSES_ROOT\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}\DefaultIcon", "Full", "REG_EXPAND_SZ", "%SystemRoot%\System32\imageres.dll,-54")

		Case "WIN_XP", "WIN_2003", "WIN_2000"
			RegWrite("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}\DefaultIcon", "", "REG_EXPAND_SZ", "%SystemRoot%\System32\shell32.dll,32")
			RegWrite("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}\DefaultIcon", "Full", "REG_EXPAND_SZ", "%SystemRoot%\System32\shell32.dll,32")
			RegWrite("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}\DefaultIcon", "Empty", "REG_EXPAND_SZ", "%SystemRoot%\System32\shell32.dll,31")
			RegWrite("HKEY_CLASSES_ROOT\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}\DefaultIcon", "", "REG_EXPAND_SZ", "%SystemRoot%\System32\shell32.dll,31")
			RegWrite("HKEY_CLASSES_ROOT\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}\DefaultIcon", "Empty", "REG_EXPAND_SZ", "%SystemRoot%\System32\shell32.dll,31")
			RegWrite("HKEY_CLASSES_ROOT\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}\DefaultIcon", "Full", "REG_EXPAND_SZ", "%SystemRoot%\System32\shell32.dll,32")

		Case Else
			_MemoLoggingWrite("Unsupported Operating System", 3)
			_EndLogging()
			Return

	EndSwitch
	_BroadcastChange()
	_MemoLoggingWrite("The default Recycle Bin icons should now be restored.", 1)
	_EndLogging()

EndFunc


Func _RemoveDeleteAddRename()

	_StartLogging("Removing Delete and adding Rename to the Recycle Bin context menu, please wait...")
	Switch @OSVersion
		Case "WIN_VISTA"

			RegWrite("HKEY_CLASSES_ROOT\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}\shell\Delete", "Description", "REG_SZ", "Overrides the " & Chr(34) & "Delete" & Chr(34) & " option")
			RegWrite("HKEY_CLASSES_ROOT\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}\shell\Delete", "", "REG_SZ", "Search...")
			RegWrite("HKEY_CLASSES_ROOT\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}\shell\Delete\command", "", "REG_EXPAND_SZ", "%windir%\explorer.exe")
			RegWrite("HKEY_CLASSES_ROOT\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}\shell\Delete\ddeexec", "", "REG_SZ", "[FindFolder(\\""%l\\"", %I)]")
			RegWrite("HKEY_CLASSES_ROOT\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}\shell\Delete\ddeexec", "NoActivateHandler", "REG_SZ", "")
			RegWrite("HKEY_CLASSES_ROOT\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}\shell\Delete\ddeexec\Application", "", "REG_SZ", "Folders")
			RegWrite("HKEY_CLASSES_ROOT\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}\shell\Delete\ddeexec\topic", "", "REG_SZ", "AppProperties")

			;RegDelete("HKEY_CLASSES_ROOT\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}\shell\Delete")

			_BroadcastChange()

		Case "WIN_2003", "WIN_XP", "WIN_2000"

			RegWrite("HKEY_CLASSES_ROOT\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}\ShellFolder", "Attributes", "REG_BINARY", "0x50010020")
			RegWrite("HKEY_CLASSES_ROOT\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}\ShellFolder", "CallForAttributes", "REG_DWORD", "0x00000000")
			_BroadcastChange()

		Case Else
			_MemoLoggingWrite("Unsupported Operating System", 3)
			_EndLogging()
			Return

	EndSwitch
	_EndLogging()

EndFunc


;~ Func _RestoreWindowsShell()

;~ 	_MemoLoggingWrite("Restoring the Windows shell (TaskBar, Start Menu and Desktop), please wait...", 0, False)
;~ 	_MemoLoggingWrite("-----------------------------------------------------------------------------------------", 0, False)

;~ 	Local $currShell = RegRead("HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon", "Shell")
;~ 	_MemoLoggingWrite("Windows Shell is set to " & Chr(34) & $currShell & Chr(34) & ".")
;~ 	If $currShell <> "explorer.exe" Then
;~ 		RegWrite("HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon", "Shell", "REG_SZ", "explorer.exe")
;~ 		_MemoLoggingWrite("Windows Shell is restored to " & Chr(34) & $currShell & Chr(34) & ".", 1)
;~ 	Else
;~ 		_MemoLoggingWrite("Nothing to repair here, everything looks okay.", 1)
;~ 	EndIf

;~ 	_MemoLoggingWrite("Removing any malicious Image File Execution Options.")
;~ 	RegDelete("HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution.options\explorer.exe")
;~ 	RegDelete("HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution.options\iexplorer.exe")

;~ 	_RestartShellMessage()

;~ 	_MemoLoggingWrite("", 0, False)
;~ 	_MemoLoggingWrite("-----------------------------------------------------------------------------------------", 0, False)

;~ EndFunc


;~ Func _RepairTaskBar()

;~ 	_MemoLoggingWrite("Restoring the TaskBar and Desktop, please wait...", 0, False)
;~ 	_MemoLoggingWrite("-----------------------------------------------------------------------------------------", 0, False)

;~ 	_MemoLoggingWrite("Doing some stuff with the registry.")
;~ 	RegDelete("HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\StuckRects2")
;~ 	RegDelete("HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Streams\Desktop")
;~ 	RegDelete("HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\StreamsMRU")

;~ 	RegDelete("HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution.options\explorer.exe")
;~ 	RegDelete("HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution.options\iexplorer.exe")

;~ 	RegDelete("HKCU\Software\Microsoft\Internet Explorer\Explorer Bars\{32683183-48a0-441b-a342-7c2a440a9478}\BarSize")
;~ 	RegWrite("HKCU\Software\Microsoft\Internet Explorer\Explorer Bars\{32683183-48a0-441b-a342-7c2a440a9478}", "", "REG_SZ", "Media Band")

;~ 	_MemoLoggingWrite("Clearing some common policies.")
;~ 	RegWrite("HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer", "NoBandCustomize", "REG_DWORD", 0)
;~ 	RegWrite("HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer", "NoMovingBands", "REG_DWORD", 0)
;~ 	RegWrite("HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer", "NoCloseDragDropBands", "REG_DWORD", 0)
;~ 	RegWrite("HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer", "NoSetTaskbar", "REG_DWORD", 0)
;~ 	RegWrite("HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer", "NoToolbarsOnTaskbar", "REG_DWORD", 0)
;~ 	RegWrite("HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer", "NoSaveSettings", "REG_DWORD", 0)
;~ 	RegWrite("HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer", "NoActiveDesktop", "REG_DWORD", 0)
;~ 	RegWrite("HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer", "ClassicShell", "REG_DWORD", 0)

;~ 	RegDelete("HKCU\Software\Microsoft\Windows\CurrentVersion\Group Policy Objects\LocalUser\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer", "NoMovingBands")
;~ 	RegWrite("HKCU\Software\Microsoft\Windows\CurrentVersion\Group Policy Objects\LocalUser\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer", "NoCloseDragDropBands", "REG_DWORD", 0)
;~ 	RegWrite("HKCU\Software\Microsoft\Windows\CurrentVersion\Group Policy Objects\LocalUser\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer", "NoSaveSettings", "REG_DWORD", 0)

;~ 	_BroadcastChange()
;~ 	_MemoLoggingWrite("TaskBar and Desktop should be working now.", 1)
;~ 	_MemoLoggingWrite("", 0, False)
;~ 	_MemoLoggingWrite("-----------------------------------------------------------------------------------------", 0, False)

;~ EndFunc


;~ Func _RepairIconView()

;~ 	_MemoLoggingWrite("Repairing the Icon View, please wait...", 0, False)
;~ 	_MemoLoggingWrite("-----------------------------------------------------------------------------------------", 0, False)

;~ 	Switch @OSVersion
;~ 		Case "WIN_2008R2", "WIN_7", "WIN_2008"
;~ 			RegWrite("HKCU\Software\Microsoft\Windows\Shell\Bags\1\Desktop", "IconSize", "REG_DWORD", 48)
;~ 			_MemoLoggingWrite("Desktop icon sizes restored to 48", 1)
;~ 		Case "WIN_2003", "WIN_XP", "WIN_XPe"
;~ 			RegWrite("HKCU\Control Panel\desktop\WindowMetrics", "Shell Icon BPP", "REG_SZ", "16")
;~ 			RegWrite("HKCU\Control Panel\desktop\WindowMetrics", "Shell Icon Size", "REG_SZ", "32")
;~ 			_MemoLoggingWrite("Desktop icon sizes restored to 32", 1)
;~ 		Case "WIN_2000"
;~ 			RegWrite("HKCU\Control Panel\desktop\WindowMetrics", "Shell Icon BPP", "REG_SZ", "16")
;~ 	EndSwitch

;~ 	RegWrite("HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer", "NoSaveSettings", "REG_DWORD", 0)
;~ 	_BroadcastChange()
;~ 	_MemoLoggingWrite("Icon View repaired, but we could be wrong.", 1)
;~ 	_MemoLoggingWrite("", 0, False)
;~ 	_MemoLoggingWrite("-----------------------------------------------------------------------------------------", 0, False)

;~ EndFunc


;~ Func _SetIconCacheSize()

;~ 	RegWrite("HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer", "Max Cached Icons", "REG_SZ", "4096")
;~ 	If @error Then
;~ 	Else
;~ 		_BroadcastChange()
;~ 		Local $regReturn = RegRead("HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer", "Max Cached Icons")
;~ 		If $regReturn <> "" Then
;~ 			_MemoLoggingWrite("The Icon Cache size should be set to " & $regReturn & " KB now.", 1)
;~ 		Else
;~ 			_MemoLoggingWrite("For some peculiar reason the new Icon Cache size was not set.", 2)
;~ 		EndIf
;~ 	EndIf
;~ 	_MemoLoggingWrite("", 0, False)
;~ 	_MemoLoggingWrite("-----------------------------------------------------------------------------------------", 0, False)

;~ EndFunc


;~ Func _RebuildIconCache()

;~ 	_MemoLoggingWrite("Rebuilding the Icon Cache, please wait...", 0, False)
;~ 	_MemoLoggingWrite("-----------------------------------------------------------------------------------------", 0, False)
;~ 	If _OsVersionTest($OSVER_GREATER_EQUAL, 6) Then

;~ 		Local $iconCacheFile = @UserProfileDir & "\AppData\Local\IconCache.db"

;~ 		;_ConsoleRun("taskkill /IM explorer.exe /F")
;~ 		_MemoLoggingWrite("Removing " & $iconCacheFile)
;~ 		FileDelete($iconCacheFile)
;~ 		;_MemoLoggingWrite("Removing " & $iconCacheFile02)
;~ 		FileDelete(@UserProfileDir & "\AppData\Local\GDOPFONTCACHV1.DAT")
;~ 		FileDelete(@UserProfileDir & "\AppData\Local\GDIPFONTCACHEV1.DAT")
;~ 		_BroadcastChange()
;~ 		;ShellExecute("explorer.exe")


;~ 	ElseIf _OsVersionTest($OSVER_LESS, 6) Then

;~ 		Local $sDataRet = RegRead("HKCU\Control Panel\Desktop\WindowMetrics", "Shell Icon Size"), $eReturn
;~ 		RegWrite("HKCU\Control Panel\Desktop\WindowMetrics", "Shell Icon Size", "REG_SZ", $sDataRet + 1)
;~ 		_BroadcastChange()
;~ 		RegWrite("HKCU\Control Panel\Desktop\WindowMetrics", "Shell Icon Size", "REG_SZ", $sDataRet)
;~ 		_BroadcastChange()

;~ 	EndIf

;~ 	_MemoLoggingWrite("Icons should display correctly after a reboot, but we’ve been wrong before.", 1)
;~ 	_MemoLoggingWrite("", 0, False)
;~ 	_MemoLoggingWrite("-----------------------------------------------------------------------------------------", 0, False)

;~ EndFunc


;~ Func _MissingComputerIcon()
;~ 	_MemoLoggingWrite("Restoring missing Computer icon, please wait...", 0, False)
;~ 	_MemoLoggingWrite("-----------------------------------------------------------------------------------------", 0, False)
;~ 	If RegRead("HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\NonEnum", "{20D04FE0-3AEA-1069-A2D8-08002B30309D}") <> "" Then
;~ 		_MemoLoggingWrite("Malicious data found and removing it.", 3)
;~ 		RegDelete("HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\NonEnum", "{20D04FE0-3AEA-1069-A2D8-08002B30309D}")
;~ 	Else
;~ 		_MemoLoggingWrite("Nothing to repair here, everything looks okay.", 1)
;~ 	EndIf
;~ 	_BroadcastChange()
;~ 	_MemoLoggingWrite("", 0, False)
;~ 	_MemoLoggingWrite("-----------------------------------------------------------------------------------------", 0, False)
;~ EndFunc


;~ Func _RepairCorruptedRecycleBin()

;~ 	_MemoLoggingWrite("Attempting to repair the corrupter Recycle Bin, please wait...", 0, False)
;~ 	_MemoLoggingWrite("-----------------------------------------------------------------------------------------", 0, False)
;~ 	_MemoLoggingWrite("Emptying the Recycle Bin")
;~ 	FileRecycleEmpty()

;~ 	Local $fixedDrives = DriveGetDrive("FIXED"), $remDir, $delReturn
;~ 	If @error Then

;~ 	Else
;~ 		For $i = 1 To $fixedDrives[0]

;~ 			$remDir = StringUpper($fixedDrives[$i]) & "\$Recycle.Bin"
;~ 			_MemoLoggingWrite("Removing " & Chr(34) & $remDir & Chr(34))
;~ 			_ConsoleRun("rd /s /q " & $remDir & "\$Recycle.bin")
;~ 			If Not FileExists($remDir) Then
;~ 				_MemoLoggingWrite("The directory appears to be gone.", 1)
;~ 			Else
;~ 				_MemoLoggingWrite("Error removing the directory (or directory does not exist).", 3)
;~ 			EndIf

;~ 		Next
;~ 	EndIf

;~ 	_MemoLoggingWrite("Emptying the Recycle Bin again, just to make sure.")
;~ 	FileRecycleEmpty()

;~ 	_MemoLoggingWrite("", 0, False)
;~ 	_MemoLoggingWrite("-----------------------------------------------------------------------------------------", 0, False)

;~ EndFunc


;~ Func _ResoreRecycleBinIcons()

;~ 	_MemoLoggingWrite("Restoring the default Recycle Bin icons, please wait...", 0, False)
;~ 	_MemoLoggingWrite("-----------------------------------------------------------------------------------------", 0, False)

;~ 	Switch @OSVersion

;~ 		Case "WIN_2008R2", "WIN_7", "WIN_2008", "WIN_VISTA"

;~ 			RegWrite("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}\DefaultIcon", "", "REG_EXPAND_SZ", "%SystemRoot%\system32\imageres.dll,-54")
;~ 			RegWrite("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}\DefaultIcon", "Full", "REG_EXPAND_SZ", "%SystemRoot%\system32\imageres.dll,-54")
;~ 			RegWrite("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}\DefaultIcon", "Empty", "REG_EXPAND_SZ", "%SystemRoot%\system32\imageres.dll,-55")
;~ 			RegWrite("HKEY_CLASSES_ROOT\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}\DefaultIcon", "", "REG_EXPAND_SZ", "%SystemRoot%\System32\imageres.dll,-55")
;~ 			RegWrite("HKEY_CLASSES_ROOT\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}\DefaultIcon", "Empty", "REG_EXPAND_SZ", "%SystemRoot%\System32\imageres.dll,-55")
;~ 			RegWrite("HKEY_CLASSES_ROOT\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}\DefaultIcon", "Full", "REG_EXPAND_SZ", "%SystemRoot%\System32\imageres.dll,-54")

;~ 		Case "WIN_2003", "WIN_XP", "WIN_XPe", "WIN_2000"

;~ 			RegWrite("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}\DefaultIcon", "", "REG_EXPAND_SZ", "%SystemRoot%\System32\shell32.dll,32")
;~ 			RegWrite("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}\DefaultIcon", "Full", "REG_EXPAND_SZ", "%SystemRoot%\System32\shell32.dll,32")
;~ 			RegWrite("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}\DefaultIcon", "Empty", "REG_EXPAND_SZ", "%SystemRoot%\System32\shell32.dll,31")
;~ 			RegWrite("HKEY_CLASSES_ROOT\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}\DefaultIcon", "", "REG_EXPAND_SZ", "%SystemRoot%\System32\shell32.dll,31")
;~ 			RegWrite("HKEY_CLASSES_ROOT\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}\DefaultIcon", "Empty", "REG_EXPAND_SZ", "%SystemRoot%\System32\shell32.dll,31")
;~ 			RegWrite("HKEY_CLASSES_ROOT\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}\DefaultIcon", "Full", "REG_EXPAND_SZ", "%SystemRoot%\System32\shell32.dll,32")

;~ 	EndSwitch

;~ 	_BroadcastChange()
;~ 	_MemoLoggingWrite("", 0, False)
;~ 	_MemoLoggingWrite("-----------------------------------------------------------------------------------------", 0, False)

;~ EndFunc