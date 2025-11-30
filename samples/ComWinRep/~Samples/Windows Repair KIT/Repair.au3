
#NoTrayIcon
Global $APPTITLE = "Rizone's Windows Repair KIT"
Global $APPVERSION = FileGetVersion(@ScriptDir & "\" & @ScriptName)
Global $RECYCLEBINSTATUS = _FILERECYCLEBINGETSIZE()
Global $INOCULATIONDATABASE = @ScriptDir & "\Inoculations.ino"
Global $INOCDATABASELINECOUNT = _FILECOUNTLINES(@ScriptDir & "\Inoculations.ino")
Global $LOGFILE = @ScriptDir & "\Repair.log"
Global $LOCALHOSTS = @SystemDir & "\DRIVERS\ETC\HOSTS"
Global $LOCALHOSTSBACKUP = @SystemDir & "\DRIVERS\ETC\HOSTS.BACKUP"
Global $MEMOSTATUS, $RECYCLEICON, $LABELBINSIZE, $OSVERSION, $PROGRESSMAIN
Global $ANIPROGRESS, $BTNREPAIRWINSOCK, $BTNRESETTCPIP, $BTNSHOWLSP, $BTNINOCULATE, $BTNUNINOCULATE, $BTNEMPTYBIN
Global $BTNCLOSE
If _SINGLETON(@ScriptName, 1) = 0 Then
	$IMSGBOXANSWER = MsgBox(48, $APPTITLE & " already running!", $APPTITLE & " is already running.", 30)
	Select
		Case $IMSGBOXANSWER = -1
			Exit
		Case Else
			Exit
	EndSelect
EndIf
Switch @OSVersion
	Case "WIN_XP", "WIN_2003", "WIN_VISTA", "WIN_2008"
		_MAIN()
	Case Else
		$IMSGBOXANSWER = MsgBox(64, $APPTITLE, "This utility is not compatable with your version of windows." & @CRLF & "If you believe this to be an error, please feel free to email at" & @CRLF & "rizonetech@gmail.com will all the details.", 30)
		Exit
EndSwitch

Func _MAIN()
	#RequireAdmin
	FileInstall("Repair.dll", @ScriptDir & "\Repair.dll", 1)
	FileInstall("Inoculations.ino", @ScriptDir & "\Inoculations.ino", 1)
	FileInstall("progress.ani", @ScriptDir & "\progress.ani", 1)
	_SETFILEATTRIBUTES($LOGFILE)
	FileDelete($LOGFILE)
	$FORMMAIN = GUICreate($APPTITLE & " " & $APPVERSION, 633, 478, 279, 120)
	GUISetIcon(@ScriptDir & "\Repair.dll", 1)
	GUISetFont(8.5, 400, 0, "Verdana")
	GUISetBkColor(15461355)
	$LABELBINSIZE = GUICtrlCreateLabel("Rizone's Windows Repair Kit is a set of tools for fixing, " & "maintaining and optimizing Windows. You can view a description " & "of every option by hovering your mouse over the button. Just " & "remember, Don't try and fix something that's not broken.", 80, 8, 390, 75)
	$FILEMENUITEM = GUICtrlCreateMenu("File")
	$FILEABOUTMENUITEM = GUICtrlCreateMenuItem("About...", $FILEMENUITEM)
	GUICtrlCreateMenuItem("", $FILEMENUITEM)
	$FILECLOSEMENUITEM = GUICtrlCreateMenuItem("Close", $FILEMENUITEM)
	$MAINTENANCEMENU = GUICtrlCreateMenu("Maintenance")
	$MAINTENANCEBACKUPMENU = GUICtrlCreateMenu("Backup / Restore", $MAINTENANCEMENU)
	$MBACKREGISTRYITEM = GUICtrlCreateMenuItem("Backup Registry...", $MAINTENANCEBACKUPMENU)
	$MBACKRESTOREAUTOREGITEM = GUICtrlCreateMenuItem("Restore Automatic Registry Backup...", $MAINTENANCEBACKUPMENU)
	GUICtrlCreateMenuItem("", $MAINTENANCEBACKUPMENU)
	$MBACKCREATERESTOREITEM = GUICtrlCreateMenuItem("Create a System Restore Point", $MAINTENANCEBACKUPMENU)
	$MBACKOPENRESTOREITEM = GUICtrlCreateMenuItem("Open System Restore...", $MAINTENANCEBACKUPMENU)
	$OPTIMIZATIONMENU = GUICtrlCreateMenu("Optimization", $MAINTENANCEMENU)
	$OPTIMIZATIONREGISTRYITEM = GUICtrlCreateMenuItem("Optimize Registry", $OPTIMIZATIONMENU)
	$OPTIMIZATIONREGREBOOTITEM = GUICtrlCreateMenuItem("Optimize Registry and Reboot", $OPTIMIZATIONMENU)
	$BTNOPENLOG = GUICtrlCreateButton("O", 457, 304, 25, 25, $WS_GROUP)
	GUICtrlSetState($BTNOPENLOG, $GUI_DISABLE)
	$BTNCOPYLOG = GUICtrlCreateButton("C", 457, 328, 25, 25, $WS_GROUP)
	GUICtrlSetState($BTNCOPYLOG, $GUI_DISABLE)
	MEMOLOGWRITE("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
	MEMOLOGWRITE($APPTITLE & " " & $APPVERSION)
	Select
		Case @OSVersion = "WIN_XP"
			$OSVERSION = "Microsoft Windows XP"
		Case @OSVersion = "WIN_VISTA"
			If @OSBuild < 7000 Then
				$OSVERSION = "Microsoft Windows Vista"
			Else
				$OSVERSION = "Microsoft Windows 7"
			EndIf
	EndSelect
	MEMOLOGWRITE($OSVERSION & " " & @OSServicePack & " Build " & @OSBuild & " (" & @OSARCH & ")")
	MEMOLOGWRITE("Date: " & @MDAY & "/" & @MON & "/" & @YEAR)
	MEMOLOGWRITE("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
	MEMOLOGWRITE("Checking Inoculation Database...")
	If FileExists($INOCULATIONDATABASE) Then
		_SETFILEATTRIBUTES($INOCULATIONDATABASE)
		$INOCULATIONSCOUNT = _FILECOUNTLINES($INOCULATIONDATABASE)
		MEMOLOGWRITE("Success: Inoculations: " & $INOCULATIONSCOUNT)
	Else
		MEMOLOGWRITE("Error: The Inoculation Database could not be found.")
	EndIf
	$GROUPINOCULATE = GUICtrlCreateGroup("Inoculate", 488, 8, 137, 217)
	$INOCULATEICON = GUICtrlCreateIcon(@ScriptDir & "\Repair.dll", 2, 554, 26, 64, 64, BitOR($SS_NOTIFY, $WS_GROUP))
	$BTNINOCULATE = GUICtrlCreateButton("Inoculate", 496, 152, 123, 33, $WS_GROUP)
	$BTNUNINOCULATE = GUICtrlCreateButton("Un-Inoculate", 496, 184, 123, 33, $WS_GROUP)
	$INOCULATELABEL = GUICtrlCreateLabel("Inoculate your computer against " & $INOCULATIONSCOUNT & " Parasites.", 496, 95, 124, 41)
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	$GROUPRECYCLE = GUICtrlCreateGroup("Recycle Bin", 488, 232, 137, 169)
	$RECYCLEICON = GUICtrlCreateIcon(@ScriptDir & "\Repair.dll", 3, 568, 347, 48, 48, BitOR($SS_NOTIFY, $WS_GROUP))
	$LABELBINSIZE = GUICtrlCreateLabel(" KB", 496, 376, 68, 17)
	GUICtrlSetFont(-1, 8.5, 800, 0, "Verdana")
	_REFRESHRECYCLEBIN()
	$BTNEMPTYBIN = GUICtrlCreateButton("Empty Bin", 496, 256, 123, 25, $WS_GROUP)
	$BTNOPENBIN = GUICtrlCreateButton("Open Bin...", 496, 280, 123, 25, $WS_GROUP)
	$BTNBINPROPERTIES = GUICtrlCreateButton("Properties...", 496, 304, 123, 25, $WS_GROUP)
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	$PROGRESSMAIN = GUICtrlCreateProgress(8, 424, 445, 25)
	$BTNRESETTCPIP = GUICtrlCreateButton("Reset TCP/IP", 8, 80, 155, 25, $WS_GROUP)
	$BTNSHOWLSP = GUICtrlCreateButton("Show LSPs", 8, 104, 155, 25, $WS_GROUP)
	$BTNREPAIRWINSOCK = GUICtrlCreateButton("Repair Winsock", 8, 128, 155, 25, $WS_GROUP)
	$BUTTON12 = GUICtrlCreateButton("Repair WU/AU", 8, 152, 155, 25, $WS_GROUP)
	$BUTTON13 = GUICtrlCreateButton("Repair SSL/HTTPS", 8, 176, 155, 25, $WS_GROUP)
	$BUTTON14 = GUICtrlCreateButton("", 8, 200, 155, 25, $WS_GROUP)
	$BUTTON15 = GUICtrlCreateButton("", 8, 224, 155, 25, $WS_GROUP)
	$BUTTON16 = GUICtrlCreateButton("", 8, 248, 155, 25, $WS_GROUP)
	$BUTTON17 = GUICtrlCreateButton("", 8, 272, 155, 25, $WS_GROUP)
	$BUTTON7 = GUICtrlCreateButton("", 168, 80, 315, 25, $WS_GROUP)
	$BUTTON8 = GUICtrlCreateButton("", 168, 104, 315, 25, $WS_GROUP)
	$BUTTON18 = GUICtrlCreateButton("", 168, 128, 315, 25, $WS_GROUP)
	$BUTTON19 = GUICtrlCreateButton("", 168, 152, 315, 25, $WS_GROUP)
	$BUTTON20 = GUICtrlCreateButton("", 168, 176, 315, 25, $WS_GROUP)
	$BUTTON21 = GUICtrlCreateButton("", 168, 200, 315, 25, $WS_GROUP)
	$BUTTON22 = GUICtrlCreateButton("", 168, 224, 315, 25, $WS_GROUP)
	$BUTTON23 = GUICtrlCreateButton("", 168, 248, 315, 25, $WS_GROUP)
	$BUTTON24 = GUICtrlCreateButton("", 168, 272, 315, 25, $WS_GROUP)
	GUICtrlSetTip($BTNRESETTCPIP, "This option rewrites important registry keys that are used by the" & @CRLF & "Internet Protocol (TCP/IP) stack. This has the same result as removing" & @CRLF & "and reinstalling the protocol.", "Reset the TCP/IP protocol stack", 1, 1)
	GUICtrlSetTip($BTNREPAIRWINSOCK, "This can be used to recover from Winsock2 corruption that result" & @CRLF & "in lost of network connectivity. This option should be used with" & @CRLF & "care becuase any pre-installed LSPs will need to be reinstalled.", "Recover from Winsock2 corruption.", 1, 1)
	$BTNCLOSE = GUICtrlCreateButton("Close", 488, 408, 139, 41, $WS_GROUP)
	$IMSGBOXANSWER = MsgBox(52, "Do registry backup!", "It is recommended to perform a registry backup to undo any changes " & "to your system. Would you like to backup your registry now? Answer Yes " & "to backup your registry No to continue without backing up the registry. " & "We will automatically backup your registry in 60 seconds", 60)
	Select
		Case $IMSGBOXANSWER = 6
			_REGISTRYBACKUP()
		Case $IMSGBOXANSWER = 7
		Case $IMSGBOXANSWER = -1
			_REGISTRYBACKUP()
	EndSelect
	GUISetState(@SW_SHOW)
	While 1
		$NMSG = GUIGetMsg()
		Switch $NMSG
			Case $BTNEMPTYBIN
				FileRecycleEmpty()
				_UPDATERECYCLESTATE()
			Case $BTNINOCULATE
				_DISABLECONTROLS()
				_STARTINOCULATIONS()
				_ENABLECONTROL()
			Case $BTNUNINOCULATE
				_DISABLECONTROLS()
				_UNINOCULATE()
				_ENABLECONTROL()
			Case $BTNRESETTCPIP
				_RESETTCPIP()
			Case $BTNREPAIRWINSOCK
				_REPAIRWINSOCK()
			Case $BTNSHOWLSP
				_SHOWLSP()
			Case $OPTIMIZATIONREGISTRYITEM
				_REGISTRYOPTEMIZE(False)
			Case $OPTIMIZATIONREGREBOOTITEM
				_REGISTRYOPTEMIZE(True)
			Case $GUI_EVENT_CLOSE, $BTNCLOSE, $FILECLOSEMENUITEM
				Exit
		EndSwitch
	WEnd
EndFunc


Func _UPDATERECYCLESTATE()
	If Not $RECYCLEBINSTATUS = _FILERECYCLEBINGETSIZE() Then
		_REFRESHRECYCLEBIN()
		$RECYCLEBINSTATUS = _FILERECYCLEBINGETSIZE()
	EndIf
EndFunc


Func _REFRESHRECYCLEBIN()
	If _FILERECYCLEBINGETSIZE() > 0 Then
		GUICtrlSetImage($RECYCLEICON, @ScriptDir & "\Repair.dll", 4)
	Else
		GUICtrlSetImage($RECYCLEICON, @ScriptDir & "\Repair.dll", 3)
	EndIf
	$BINSIZEINMB = StringSplit(_FILERECYCLEBINGETSIZE() / 1024, ".")
	GUICtrlSetData($LABELBINSIZE, $BINSIZEINMB[1] & " MB")
EndFunc


Func _FILERECYCLEBINGETSIZE()
	Local Const $RECYCLE_BIN = 10
	Local Const $FILE_SIZE = 3
	Local $OBJSHELL = ObjCreate("Shell.Application")
	Local $OBJFOLDER = $OBJSHELL.Namespace($RECYCLE_BIN)
	Local $COLITEMS = $OBJFOLDER.Items
	Local $STRSIZE, $INTSIZE, $ARRSIZE
	If IsObj($OBJSHELL) And Not @error Then
		For $OBJITEM In $COLITEMS
			$STRSIZE = $OBJFOLDER.GetDetailsOf($OBJITEM, $FILE_SIZE)
			$INTSIZE += StringRegExpReplace($STRSIZE, "\D", "")
		Next
		If $INTSIZE = 0 Then
			Return 0
		Else
			Return $INTSIZE
		EndIf
	EndIf
	Return SetError(1, 0, -1)
EndFunc





Func _STARTINOCULATIONS()
	MEMOLOGWRITE("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
	MEMOLOGWRITE("Inoculation: Inoculate:")
	MEMOLOGWRITE("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
	If FileExists(@SystemDir & "\DRIVERS\ETC\HOSTS") Then
		_SETFILEATTRIBUTES(@SystemDir & "\DRIVERS\ETC\HOSTS")
		If Not FileExists($LOCALHOSTSBACKUP) Then
			FileCopy(@SystemDir & "\DRIVERS\ETC\HOSTS", $LOCALHOSTSBACKUP, 1)
		EndIf
		If FileDelete(@SystemDir & "\DRIVERS\ETC\HOSTS") Then
			_RESETHOSTS()
			_INOCULATE()
		Else
			$IMSGBOXANSWER = MsgBox(52, "Could not remove HOSTS file!", "The HOSTS file could not be removed. " & "Would you like to append the entries to your current HOSTS file? " & "Answer Yes to append the entries to the HOSTS file and NO to exit without any changes. " & @CRLF & @CRLF & "Note: When you append the entries to the HOSTS file, make sure your HOSTS file size does not exceed 1MB, " & "because this can slow down your computer a little.", 30000)
			Select
				Case $IMSGBOXANSWER = 6
					_INOCULATE()
				Case $IMSGBOXANSWER = 7
				Case $IMSGBOXANSWER = -1
			EndSelect
		EndIf
	Else
		_RESETHOSTS()
		_INOCULATE()
	EndIf
	GUICtrlSetData($PROGRESSMAIN, 0)
EndFunc


Func _INOCULATE()
	$INOCDATABASE = FileOpen(@ScriptDir & "\Inoculations.ino", 0)
	If $INOCDATABASE = -1 Then
		MsgBox(0, "Error", "Unable to open file.")
		Exit
	EndIf
	Local $I = 0
	$LOCALHOSTFILE = FileOpen(@SystemDir & "\DRIVERS\ETC\HOSTS", 1)
	If $LOCALHOSTFILE = -1 Then
		MsgBox(0, "Error", "Unable to open file.")
		Exit
	EndIf
	FileWrite($LOCALHOSTFILE, "# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~" & @CRLF)
	FileWrite($LOCALHOSTFILE, "# Start Rizone's Inoculations" & @CRLF)
	FileWrite($LOCALHOSTFILE, "# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~" & @CRLF)
	While 1
		$I = $I + 1
		$HOSTLINE = FileReadLine($INOCDATABASE)
		If @error = -1 Then ExitLoop
		FileWrite($LOCALHOSTFILE, "127.0.0.1	" & $HOSTLINE & @CRLF)
		GUICtrlSetData($PROGRESSMAIN, ($I / $INOCDATABASELINECOUNT) * 100)
	WEnd
	FileWrite($LOCALHOSTFILE, "# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~" & @CRLF)
	FileWrite($LOCALHOSTFILE, "# End Rizone's Inoculations" & @CRLF)
	FileWrite($LOCALHOSTFILE, "# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~" & @CRLF)
	FileClose($LOCALHOSTFILE)
EndFunc


Func _UNINOCULATE()
	MEMOLOGWRITE("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
	MEMOLOGWRITE("Inoculation: Un-Inoculate:")
	MEMOLOGWRITE("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
	If FileExists($LOCALHOSTSBACKUP) Then
		_SETFILEATTRIBUTES($LOCALHOSTS)
		MEMOLOGWRITE("Removing HOSTS file...")
		If Not FileDelete($LOCALHOSTS) Then
			MEMOLOGWRITE("Error: The" & $LOCALHOSTS & " could not be removed.")
		Else
			MEMOLOGWRITE("Success: " & $LOCALHOSTS & " removed.")
		EndIf
		_SETFILEATTRIBUTES($LOCALHOSTSBACKUP)
		MEMOLOGWRITE("Restoring HOSTS file...")
		FileMove($LOCALHOSTSBACKUP, $LOCALHOSTS, 0)
		MEMOLOGWRITE("Success: HOSTS file restored.")
	Else
		$IMSGBOXANSWER = MsgBox(52, "HOSTS backup not found!", "The HOSTS backup file could not be found." & @CRLF & "Would you like to restore the default Microsoft Windows XP HOSTS file?" & @CRLF & "This is the same as resetting the HOSTS file. Answer Yes to reset the HOSTS" & @CRLF & "and NO to exit without any changes.", 30000)
		Select
			Case $IMSGBOXANSWER = 6
				_SETFILEATTRIBUTES($LOCALHOSTS)
				If FileDelete($LOCALHOSTS) Then
					_RESETHOSTS()
				EndIf
			Case $IMSGBOXANSWER = 7
			Case $IMSGBOXANSWER = -1
		EndSelect
	EndIf
EndFunc


Func _RESETHOSTS()
	MEMOLOGWRITE("Creating new " & $OSVERSION & " HOSTS file...")
	$LOCALHOSTFILE3454 = FileOpen(@SystemDir & "\DRIVERS\ETC\HOSTS", 1)
	If $LOCALHOSTFILE3454 = -1 Then
		MsgBox(0, "Error", "Unable to open file.")
		Exit
	EndIf
	FileWrite($LOCALHOSTFILE3454, "# Copyright (c) 1993-1999 Microsoft Corp." & @CRLF)
	FileWrite($LOCALHOSTFILE3454, "#" & @CRLF)
	FileWrite($LOCALHOSTFILE3454, "# This is a sample HOSTS file used by Microsoft TCP/IP for Windows." & @CRLF)
	FileWrite($LOCALHOSTFILE3454, "#" & @CRLF)
	FileWrite($LOCALHOSTFILE3454, "# This file contains the mappings of IP addresses to host names. Each" & @CRLF)
	FileWrite($LOCALHOSTFILE3454, "# entry should be kept on an individual line. The IP address should" & @CRLF)
	FileWrite($LOCALHOSTFILE3454, "# be placed in the first column followed by the corresponding host name." & @CRLF)
	FileWrite($LOCALHOSTFILE3454, "# The IP address and the host name should be separated by at least one" & @CRLF)
	FileWrite($LOCALHOSTFILE3454, "# space." & @CRLF)
	FileWrite($LOCALHOSTFILE3454, "#" & @CRLF)
	FileWrite($LOCALHOSTFILE3454, "# Additionally, comments (such as these) may be inserted on individual" & @CRLF)
	FileWrite($LOCALHOSTFILE3454, "# lines or following the machine name denoted by a '#' symbol." & @CRLF)
	FileWrite($LOCALHOSTFILE3454, "#" & @CRLF)
	FileWrite($LOCALHOSTFILE3454, "# For example:" & @CRLF)
	FileWrite($LOCALHOSTFILE3454, "#" & @CRLF)
	FileWrite($LOCALHOSTFILE3454, "#      102.54.94.97     rhino.acme.com          # source server" & @CRLF)
	FileWrite($LOCALHOSTFILE3454, "#       38.25.63.10     x.acme.com              # x client host" & @CRLF)
	If @OSVersion = "WIN_XP"  Or "WIN_2003"  Then
		FileWrite($LOCALHOSTFILE3454, "127.0.0.1       localhost" & @CRLF)
	EndIf
	If @OSVersion = "WIN_VISTA"  Or "WIN_2008"  Then
		If @OSBuild < 7000 Then
			FileWrite($LOCALHOSTFILE3454, "127.0.0.1       localhost" & @CRLF)
			FileWrite($LOCALHOSTFILE3454, "::1             localhost" & @CRLF)
		EndIf
	EndIf
	If @OSBuild > 7000 Then
		FileWrite($LOCALHOSTFILE3454, "# localhost name resolution is handle within DNS itself." & @CRLF)
		FileWrite($LOCALHOSTFILE3454, "#       127.0.0.1       localhost" & @CRLF)
		FileWrite($LOCALHOSTFILE3454, "#       ::1             localhost" & @CRLF)
	EndIf
	FileClose($LOCALHOSTFILE3454)
	MEMOLOGWRITE("Success: " & $OSVERSION & " HOSTS file created.")
EndFunc


Func MEMOLOGWRITE($LINE = "")
	GUICtrlSetData($MEMOSTATUS, $LINE & @CRLF, 1)
	$OPENLOG = FileOpen($LOGFILE, 1)
	If $OPENLOG = -1 Then
		MsgBox(0, "Error", "Unable to open file.")
		Exit
	EndIf
	FileWrite($OPENLOG, $LINE & @CRLF)
	FileClose($OPENLOG)
EndFunc


Func _SETFILEATTRIBUTES($FILENAME)
	If Not FileSetAttrib($FILENAME, "+A-S-R-H") Then
		MEMOLOGWRITE("Error: Problem setting " & $FILENAME & " attributes.")
	EndIf
EndFunc


Func _REGISTRYBACKUP()
	If FileExists(@ScriptDir & "\bin\erunt.exe") Then
		MEMOLOGWRITE("Attemting to backup the Registry...")
		ShellExecuteWait(@ScriptDir & "\bin\erunt.exe", @ScriptDir & "\Rescue /noconfirmdelete")
		MEMOLOGWRITE("Success: Registry backup successful.")
	Else
		MEMOLOGWRITE("ERROR: Could not find ERUNT.EXE")
	EndIf
EndFunc


Func _REGISTRYOPTEMIZE($REBOOT = False)
	_DISABLECONTROLS()
	MEMOLOGWRITE("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
	MEMOLOGWRITE("Registry Optimization:")
	MEMOLOGWRITE("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
	If FileExists(@ScriptDir & "\bin\ntregopt.exe") Then
		MEMOLOGWRITE("Optimizing the Registry...")
		If $REBOOT Then
			$ERRORCODE = ShellExecuteWait(@ScriptDir & "\bin\ntregopt.exe", "silent /reboot")
		Else
			$ERRORCODE = ShellExecuteWait(@ScriptDir & "\bin\ntregopt.exe", "silent")
		EndIf
		MsgBox(0, "", $ERRORCODE)
		MEMOLOGWRITE("Success: Registry optimization successful.")
		MEMOLOGWRITE("Rebooting Windows...")
	Else
		MEMOLOGWRITE("ERROR: Could not find NTREGOPT.EXE")
	EndIf
	_ENABLECONTROL()
EndFunc


Func _ENABLECONTROL()
	GUICtrlSetState($BTNINOCULATE, $GUI_ENABLE)
	GUICtrlSetState($BTNUNINOCULATE, $GUI_ENABLE)
	GUICtrlSetState($BTNEMPTYBIN, $GUI_ENABLE)
	GUICtrlSetState($BTNCLOSE, $GUI_ENABLE)
	GUICtrlSetState($BTNRESETTCPIP, $GUI_ENABLE)
	GUICtrlSetState($BTNREPAIRWINSOCK, $GUI_ENABLE)
	GUICtrlSetState($BTNSHOWLSP, $GUI_ENABLE)
	GUICtrlDelete($ANIPROGRESS)
EndFunc


Func _DISABLECONTROLS()
	$ANIPROGRESS = GUICtrlCreateIcon(@ScriptDir & "\progress.ani", -1, 460, 429, 16, 16)
	GUICtrlSetState($BTNINOCULATE, $GUI_DISABLE)
	GUICtrlSetState($BTNUNINOCULATE, $GUI_DISABLE)
	GUICtrlSetState($BTNEMPTYBIN, $GUI_DISABLE)
	GUICtrlSetState($BTNCLOSE, $GUI_DISABLE)
	GUICtrlSetState($BTNRESETTCPIP, $GUI_DISABLE)
	GUICtrlSetState($BTNREPAIRWINSOCK, $GUI_DISABLE)
	GUICtrlSetState($BTNSHOWLSP, $GUI_DISABLE)
EndFunc
