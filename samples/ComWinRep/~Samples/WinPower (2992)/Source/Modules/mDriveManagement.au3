Global $CDDrvCombo, $CDChkFixErrors, $CDChkDispMsg, $CDChkFixBSect, $CDChkFoVolDis, $CDChkIncIndex, $CDChkSkipCycle, $CDInpCom
Global $CDBtnRefresh, $ChkDskCom = ""

; Start Disk Cleanup
Func _StartDiskCleanup()
	ShellExecute("cleanmgr")
EndFunc

; Start Windows Defrag
Func _StartWindowsDefrag()
	If @OSVersion = "WIN_VISTA" Or @OSVersion = "WIN_2008" Then
		ShellExecute("dfrgui.exe", "", @SystemDir)
	Else
		ShellExecute("mmc", "dfrg.msc", @SystemDir)
	EndIf
EndFunc

; Start Disk Management
Func _StartDiskManagement()
	ShellExecute("diskmgmt.msc")
	If @error Then
		_MemoLogWrite("Could not start Disk Management.", 2)
	EndIf
EndFunc

; Start Partition Manager
Func _StartPartitionManager()
	ShellExecute("diskpart")
EndFunc

Func _FormatSelectedDrive()
	_WinAPI_FormatDriveDlg($GDRIVESELECTED, 0)
EndFunc

; Open Selected Drive
Func _OpenSelectedDrive()
	ShellExecute($GDRIVESELECTED & "\")
	If @error Then
		_MemoLogWrite("An error occurred.", 2)
		_MemoLogWrite("Could not open [" & $GDRIVESELECTED & "] drive", 2)
	EndIf
EndFunc

; Explore Selected Drive
Func _ExploreSelectedDrive()
	ShellExecute("explorer.exe", "/e,"& $GDRIVESELECTED & "\")
	If @error Then
		_MemoLogWrite("An error occurred.", 2)
		_MemoLogWrite("Could not open Windows Explorer.", 2)
	EndIf
EndFunc

Func _GetDriveBusType($DRIVE)
	Local $ReturnBus
		$Bus = _WinAPI_GetDriveBusType($DRIVE)
		Switch $Bus
			Case $DRIVE_BUS_TYPE_UNKNOWN
				$ReturnBus = 'UNKNOWN'
			Case $DRIVE_BUS_TYPE_SCSI
				$ReturnBus = 'SCSI'
			Case $DRIVE_BUS_TYPE_ATAPI
				$ReturnBus = 'ATAPI'
			Case $DRIVE_BUS_TYPE_ATA
				$ReturnBus = 'ATA'
			Case $DRIVE_BUS_TYPE_1394
				$ReturnBus = '1394'
			Case $DRIVE_BUS_TYPE_SSA
				$ReturnBus = 'SSA'
			Case $DRIVE_BUS_TYPE_FIBRE
				$ReturnBus = 'FIBRE'
			Case $DRIVE_BUS_TYPE_USB
				$ReturnBus = 'USB'
			Case $DRIVE_BUS_TYPE_RAID
				$ReturnBus = 'RAID'
			Case $DRIVE_BUS_TYPE_ISCSI
				$ReturnBus = 'ISCSI'
			Case $DRIVE_BUS_TYPE_SAS
				$ReturnBus = 'SAS'
			Case $DRIVE_BUS_TYPE_SATA
				$ReturnBus = 'SATA'
			Case $DRIVE_BUS_TYPE_SD
				$ReturnBus = 'SD'
			Case $DRIVE_BUS_TYPE_MMC
				$ReturnBus = 'MMC'
		EndSwitch
		Return $ReturnBus
EndFunc

Func _CheckDiskGUI()

	$CDChkDskGUI = GUICreate("Check Disk GUI", 350, 260, 192, 124)
	GUISetIcon($GPowerRes, 5, $CDChkDskGUI)
	GUISetFont(8.5, 400, 0, "Verdana")
	GUISetBkColor(0xEBEBEB)
	GUISetHelp("cmd.exe /K " & Chr(34) & "ChkDsk.exe /?" & Chr(34))
	$CDLbSelDrive = GUICtrlCreateLabel("Select drive:", 10, 16, 90, 17)
	GUICtrlSetFont($CDLbSelDrive, 8.5, 800, 0, "")
	GUICtrlSetColor($CDLbSelDrive, 0x4051A0)
	$CDDrvCombo = GUICtrlCreateCombo("", 100, 12, 100, 25)
	$CDBtnRefresh = GUICtrlCreateButton("Refresh", 205, 10, 100, 25)
	GUICtrlCreateGroup("Command Line Options", 8, 40, 330, 140)
	$CDChkFixErrors = GUICtrlCreateCheckbox("Fix errors on the disk.", 16, 69, 310, 17)
	$CDChkFixBSect = GUICtrlCreateCheckbox("Fix bad sectors nad recover readable info.", 16, 85, 310, 17)
	$CDChkFoVolDis = GUICtrlCreateCheckbox("Force volume to dismount first if necessary.", 16, 101, 310, 17)
	$CDChkDispMsg = GUICtrlCreateCheckbox("Display cleanup messages if any.", 16, 117, 310, 17)
	$CDChkIncIndex = GUICtrlCreateCheckbox("Perform less vigorous check of index entries.", 16, 133, 310, 17)
	$CDChkSkipCycle = GUICtrlCreateCheckbox("Skip cycle checking in folder structure.", 16, 149, 310, 17)
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	$CDBChkDskClose = GUICtrlCreateButton("Close", 8, 190, 100, 30)
	$CDBChkDskHelp = GUICtrlCreateButton("Help (F1)", 108, 190, 100, 30)
	$CDBChkDskRun = GUICtrlCreateButton("Run", 240, 190, 100, 30, $BS_DEFPUSHBUTTON)
	GUICtrlSetFont($CDBChkDskRun, 8.5, 800, 0, "")
	$CDInpCom = GUICtrlCreateInput("", 85, 230, 253, 21, $ES_READONLY)
	$CDLbCom = GUICtrlCreateLabel("Command:", 8, 233, 77, 17)
	GUICtrlSetFont($CDLbCom, 8.5, 800, 0, "")
	GUICtrlSetColor($CDLbCom, 0x4051A0)

	; Load Settings
	If IniRead($PowerSettings, "CheckDiskUI", "FixErrors", 1) = 1 Then GUICtrlSetState($CDChkFixErrors, $GUI_CHECKED)
	If IniRead($PowerSettings, "CheckDiskUI", "FixBadSectors", 0) = 1 Then GUICtrlSetState($CDChkFixBSect, $GUI_CHECKED)
	If IniRead($PowerSettings, "CheckDiskUI", "ForceVolumeDismount", 0) = 1 Then GUICtrlSetState($CDChkFoVolDis, $GUI_CHECKED)
	If IniRead($PowerSettings, "CheckDiskUI", "DisplayMessages", 1) = 1 Then GUICtrlSetState($CDChkDispMsg, $GUI_CHECKED)
	If IniRead($PowerSettings, "CheckDiskUI", "LessIndexCheck", 0) = 1 Then GUICtrlSetState($CDChkIncIndex, $GUI_CHECKED)
	If IniRead($PowerSettings, "CheckDiskUI", "SkipCycleCheck", 0) = 1 Then GUICtrlSetState($CDChkSkipCycle, $GUI_CHECKED)

	_PopulateChkDskUIDrivesCombo()

	GUISetState(@SW_SHOW)

	GUISetOnEvent($GUI_EVENT_CLOSE, "_CheckDiskGUICloseClicked", $CDChkDskGUI)
	GUICtrlSetOnEvent($CDDrvCombo, "_SetChkDskCommand")
	GUICtrlSetOnEvent($CDBtnRefresh, "_PopulateChkDskUIDrivesCombo")
	GUICtrlSetOnEvent($CDChkFixErrors, "_SetChkDskCommand")
	GUICtrlSetOnEvent($CDChkDispMsg, "_SetChkDskCommand")
	GUICtrlSetOnEvent($CDChkFixBSect, "_SetChkDskCommand")
	GUICtrlSetOnEvent($CDChkFoVolDis, "_SetChkDskCommand")
	GUICtrlSetOnEvent($CDChkIncIndex, "_SetChkDskCommand")
	GUICtrlSetOnEvent($CDChkSkipCycle, "_SetChkDskCommand")
	GUICtrlSetOnEvent($CDBChkDskClose, "_CheckDiskGUICloseClicked")
	GUICtrlSetOnEvent($CDBChkDskHelp, "_OpenChkDskHelp")
	GUICtrlSetOnEvent($CDBChkDskRun, "_RunChkDskCommand")

EndFunc

Func _CheckDiskGUICloseClicked()
	GUIDelete(@GUI_WinHandle)
EndFunc

Func _SetChkDskCommand()
	$ChkDskCom = ""
	$ChkDskCom = $ChkDskCom & GUICtrlRead($CDDrvCombo)
	If GUICtrlRead($CDChkFixErrors) = 1 Then $ChkDskCom = $ChkDskCom & " /F"
	If GUICtrlRead($CDChkDispMsg) = 1 Then $ChkDskCom = $ChkDskCom & " /V"
	If GUICtrlRead($CDChkFixErrors) = 1 Then
		If GUICtrlRead($CDChkFixBSect) = 1 Then $ChkDskCom = $ChkDskCom & " /R"
		GuiCtrlSetState($CDChkFixBSect, $GUI_ENABLE)
		If GUICtrlRead($CDChkFoVolDis) = 1 Then $ChkDskCom = $ChkDskCom & " /X"
		GuiCtrlSetState($CDChkFoVolDis, $GUI_ENABLE)
	Else
		GuiCtrlSetState($CDChkFixBSect, $GUI_DISABLE)
		GuiCtrlSetState($CDChkFixBSect, $GUI_UNCHECKED)
		GuiCtrlSetState($CDChkFoVolDis, $GUI_DISABLE)
		GuiCtrlSetState($CDChkFoVolDis, $GUI_UNCHECKED)
	EndIf
	If GUICtrlRead($CDChkIncIndex) = 1 Then $ChkDskCom = $ChkDskCom & " /I"
	If GUICtrlRead($CDChkSkipCycle) = 1 Then $ChkDskCom = $ChkDskCom & " /C"
	GuiCtrlSetData($CDInpCom, "ChkDsk.exe " & $ChkDskCom)
	Switch DriveGetFileSystem(GUICtrlRead($CDDrvCombo))
		Case "FAT", "FAT32"
			GUICtrlSetData($CDChkDispMsg, "Display full path and name of every file.")
			_EnableChkDskUIControls()
		Case "NTFS"
			GUICtrlSetData($CDChkDispMsg, "Display cleanup messages if any.")
			_EnableChkDskUIControls()
		Case Else
			_DisableChkDskUIControls()
	EndSwitch
EndFunc

Func _OpenChkDskHelp()
	ShellExecute("cmd", "/K " & Chr(34) & "ChkDsk.exe /?" & Chr(34))
EndFunc

Func _RunChkDskCommand()
	ShellExecute("cmd", "/K " & Chr(34) & GuiCtrlRead($CDInpCom) & Chr(34))
EndFunc

Func _PopulateChkDskUIDrivesCombo()
	_DisableChkDskUIControls()
	GUICtrlSetData($CDDrvCombo, "")
	Local $DRIVES = DriveGetDrive("ALL")
	For $i = 1 to $DRIVES[0]
		If DriveStatus($DRIVES[$i]) = "READY" Then
			If DriveGetType($DRIVES[$i]) = "FIXED" Then ;Or DriveGetType($DRIVES[$i]) = "REMOVABLE"
				GUICtrlSetData($CDDrvCombo, StringUpper($DRIVES[$i]) & "|", $GDRIVESELECTED)
			EndIf
		EndIf
	Next
	_SetChkDskCommand()
	_EnableChkDskUIControls()
EndFunc

Func _DisableChkDskUIControls()
	;GuiCtrlSetState($CDDrvCombo, $GUI_DISABLE)
	GuiCtrlSetState($CDBtnRefresh, $GUI_DISABLE)
EndFunc

Func _EnableChkDskUIControls()
	;GuiCtrlSetState($CDDrvCombo, $GUI_ENABLE)
	GuiCtrlSetState($CDBtnRefresh, $GUI_ENABLE)
EndFunc

Func _DefragDrive()
	Local $DM = 0, $DrvToDefrag = StringLeft(GUICtrlRead($HDDCombo), 2)

	Select
		Case GuiCtrlRead($HDDDMethod) = "Analyze Only"
			_DisableControls()
			_MemoLogWrite("Please wait while your [" & $DrvToDefrag & "] drive is being analyzed.....")
			RunWait($GJKDEXE & " -l " & '"' & $GJKDLOG & '"' & " -q -a 1 " & StringLeft(GUICtrlRead($HDDCombo), 2))
			_GetDiskFragmentation()
			_EnableControls()
		Case GuiCtrlRead($HDDDMethod) = "Defragment Only"
			$DM = 2
		Case GuiCtrlRead($HDDDMethod) = "Defragment and Fast Optimize"
			$DM = 3
		Case GuiCtrlRead($HDDDMethod) = "Force Together"
			$DM = 5
		Case GuiCtrlRead($HDDDMethod) = "Move to end of Disk"
			$DM = 6
		Case GuiCtrlRead($HDDDMethod) = "Optimize Files by Name (Folder + Filename)"
			$DM = 7
		Case GuiCtrlRead($HDDDMethod) = "Optimize Files by Size (Smallest First)"
			$DM = 8
		Case GuiCtrlRead($HDDDMethod) = "Optimize Files by Last Access (Newest First)"
			$DM = 9
		Case GuiCtrlRead($HDDDMethod) = "Optimize Files by Last Change (Oldest First)"
			$DM = 10
		Case GuiCtrlRead($HDDDMethod) = "Optimize Files by Creation Time (Oldest First)"
			$DM = 11
	EndSelect

	If Not $DM = 0 Then
		If FileExists($GJKDEXE) <> 1 Then
			MsgBox(16, $PowerTitle, "The required '" & $GJKDEXE & "' could not be found. This file is required for normal operation.")
		Else
			Run($GJKDEXE & " -l " & '"' & $GJKDLOG & '"' & " -q -a " & $DM & " " & StringLeft(GUICtrlRead($HDDCombo), 2))
		EndIf
	EndIf

EndFunc

Func _GetDiskFragmentation()
	Local Const $LHDD = StringLeft(GUICtrlRead($HDDCombo), 2)

	If FileExists($GJKDLOG) Then ; Read % Fragmentation from the log file
		$OJKDLOG = FileOpen($GJKDLOG, 0)
		While 1
			$JKLINE = FileReadLine($OJKDLOG)
			If @error Then ExitLoop
			If StringInStr($JKLINE, "Total size of fragmented items:") Then
				$JKLINE = StringTrimRight($JKLINE, 8)
				ExitLoop
			EndIf
		WEnd
		If StringRight($JKLINE, 1) = "%" Then
			$JKLINE = StringTrimRight($JKLINE, 1)
			Select
				Case StringIsFloat(StringRight($JKLINE, 8)) = 1
					$JKLINE = StringRight($JKLINE, 8)
				Case StringIsFloat(StringRight($JKLINE, 7)) = 1
					$JKLINE = StringRight($JKLINE, 7)
				Case StringIsFloat(StringRight($JKLINE, 6)) = 1
					$JKLINE = StringRight($JKLINE, 6)
			EndSelect
			_MemoLogWrite( "Your [" & $LHDD & "] drive is " & Round($JKLINE, 2) & " % fragmented.", 1)
			If $JKLINE > 5 Then
				_MemoLogWrite("It is recommended that you defrag this drive to maximise your computer’s performance.", 3)
			Else
				_MemoLogWrite("You don't need to defrag this drive.", 1)
			EndIf
		EndIf
		FileClose($OJKDLOG)
	EndIf
EndFunc

Func _ShowJKLegend()

	If Not WinExists(" Legend", "Free Space") Then

		$FrmLegend = GUICreate(" Legend", 148, 190, 192, 124, BitOr($WS_CAPTION, $WS_POPUPWINDOW), BitOr($WS_EX_TOOLWINDOW, $WS_EX_TOPMOST))
		GUISetFont(8.5, 400, 0, "Verdana")
		GUICtrlCreateIcon($GPowerRes16, 4, 8, 8, 16, 16)
		GUICtrlCreateLabel("Free Space", 32, 9, 100, 15)
		GUICtrlCreateIcon($GPowerRes16, 5, 8, 24, 16, 16)
		GUICtrlCreateLabel("Unfragmented", 32, 25, 100, 15)
		GUICtrlCreateIcon($GPowerRes16, 6, 8, 40, 16, 16)
		GUICtrlCreateLabel("Space Hogs", 32, 41, 100, 15)
		GUICtrlCreateIcon($GPowerRes16, 7, 8, 56, 16, 16)
		GUICtrlCreateLabel("Fragmented", 32, 57, 100, 15)
		GUICtrlCreateIcon($GPowerRes16, 8, 8, 72, 16, 16)
		GUICtrlCreateLabel("Unmovable", 32, 73, 100, 15)
		GUICtrlCreateIcon($GPowerRes16, 9, 8, 88, 16, 16)
		GUICtrlCreateLabel("Busy", 32, 89, 100, 15)
		GUICtrlCreateIcon($GPowerRes16, 10, 8, 104, 16, 16)
		GUICtrlCreateLabel("Master File Table", 32, 105, 100, 15)
		GUICtrlCreateIcon($GPowerRes16, 11, 8, 120, 16, 16)
		GUICtrlCreateLabel("In Use", 32, 121, 100, 15)

		$BtnCloseLeg = GUICtrlCreateButton("Close", 8, 155, 130, 30)

		GUISetState(@SW_SHOW, $FrmLegend)

		GUISetOnEvent($GUI_EVENT_CLOSE, "_JKLegendCloseClicked", $FrmLegend)
		GUICtrlSetOnEvent($BtnCloseLeg, "_JKLegendCloseClicked")
	Else
		WinActivate(" Legend", "Free Space")
	EndIf


EndFunc

Func _JKLegendCloseClicked()
	GUIDelete(@GUI_WinHandle)
EndFunc

Func _DriveGeometryDialog()
	Local $tDISKGEOMETRYEX
	$tDISKGEOMETRYEX = _WinAPI_GetDriveGeometryEx($GDRIVENUMBER)

	$FDriveInfo = GUICreate(" Drive Geometry (Drive " & $GDRIVENUMBER & ")", 430, 300, 195, 124, BitOr($WS_CAPTION, $WS_POPUPWINDOW), BitOr($WS_EX_TOOLWINDOW, $WS_EX_TOPMOST))
	GUISetFont(8.5, 400, 0, "Verdana")

	$lDInfo = GUICtrlCreateListView("", 8, 8, 417, 240)
	_GUICtrlListView_SetExtendedListViewStyle($lDInfo, BitOR($LVS_EX_FULLROWSELECT, $LVS_EX_GRIDLINES))
	; Add columns
	_GUICtrlListView_InsertColumn($lDInfo, 0, "", 150)
	_GUICtrlListView_InsertColumn($lDInfo, 1, "", 150)
	_GUICtrlListView_InsertItem($lDInfo, "Drive Number", -1)
    _GUICtrlListView_AddSubItem($lDInfo, 0, $GDRIVENUMBER, 1)
	_GUICtrlListView_InsertItem($lDInfo, "Bus Type", -1)
    _GUICtrlListView_AddSubItem($lDInfo, 1, _GetDriveBusType("C:"), 1)
    _GUICtrlListView_InsertItem($lDInfo, "Cylinders", -1)
    _GUICtrlListView_AddSubItem($lDInfo, 2, DllStructGetData($tDISKGEOMETRYEX, 'Cylinders'), 1)
	_GUICtrlListView_InsertItem($lDInfo, "Tracks per Cylinder", -1)
    _GUICtrlListView_AddSubItem($lDInfo, 3, DllStructGetData($tDISKGEOMETRYEX, 'TracksPerCylinder'), 1)
	_GUICtrlListView_InsertItem($lDInfo, "Sectors per Track", -1)
    _GUICtrlListView_AddSubItem($lDInfo, 4, DllStructGetData($tDISKGEOMETRYEX, 'SectorsPerTrack'), 1)
	_GUICtrlListView_InsertItem($lDInfo, "Bytes per Sector", -1)
    _GUICtrlListView_AddSubItem($lDInfo, 5, DllStructGetData($tDISKGEOMETRYEX, 'BytesPerSector'), 1)
	_GUICtrlListView_InsertItem($lDInfo, "Disk Size", -1)
    _GUICtrlListView_AddSubItem($lDInfo, 6, DllStructGetData($tDISKGEOMETRYEX, 'DiskSize'), 1)

	GUISetState(@SW_SHOW, $FDriveInfo)
	GUISetOnEvent($GUI_EVENT_CLOSE, "DriveInfoCLOSEClicked", $FDriveInfo)

EndFunc

Func DriveInfoCLOSEClicked()
	GuiDelete(@GUI_WinHandle)
EndFunc
