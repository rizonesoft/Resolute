#AutoIt3Wrapper_icon=Resources\EBGNuke.ico
#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_Res_Fileversion=0.0.0.180
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=y
#AutoIt3Wrapper_Res_requestedExecutionLevel=requireAdministrator
#AutoIt3Wrapper_Res_Icon_Add=Resources\Drive.ico
#AutoIt3Wrapper_Res_Icon_Add=Resources\Burn.ico

;~ #include <TreeViewConstants.au3>
#include <WindowsConstants.au3>
#include <GUIConstantsEx.au3>
#include <GuiImageList.au3>
#include <GuiListView.au3>
#Include <GuiButton.au3>
;~ #include <GuiEdit.au3>
;~ #Include <String.au3>

#include <UDF\SecureDelete.au3>


Opt("TrayMenuMode", 1) ;~ Default tray menu items (Script Paused/Exit) will not be shown.
Opt("MustDeclareVars", 1)
Opt("GUIOnEventMode", 1)

Global Const $GUI_DISABLE_Ex = 128
Global Const $GUI_ENABLE_Ex = 64

Global $mForm, $TabNFree, $TabNFiles, $lblWipe, $WipeProg
Global $GFSm, $GOHPage, $LogMaxSize, $LogEnabled, $Drives
Global $FileList, $hFileList, $hDrivesList, $DrivesList, $BtnRefresh, $BtnNukeNow, $wFile
Global $BtnAddFiles, $BtnRemItem, $BtnRemAll, $BtnNukeFiles, $WipeFProg
Global $Cancel = 0

_LoadSettings()
_Main()

Func _LoadSettings()

	$GFSm = IniRead(@ScriptDir & "\WinPower.ini", "Global", "FontSmoothing", 5)
	$GOHPage = IniRead(@ScriptDir & "\WinPower.ini", "Global", "OpenHomePage", 1)
	$LogMaxSize = IniRead(@ScriptDir & "\CIntRep.ini", "Logging", "LogMaxSize", 2048)
	$LogEnabled = IniRead(@ScriptDir & "\CIntRep.ini", "Logging", "LogEnabled", 1)

EndFunc

Func _Main()


	Local $hFImage, $hImage, $DriveCap, $DriveSpace

	$mForm = GUICreate("Rizone Evidence Be-Gone Nuke", 620, 490, -1, -1)
	GuiSetFont(8.5, 400, 0, "Verdana")

	GUICtrlCreateTab(10, 10, 600, 420)

	$TabNFiles = GUICtrlCreateTabItem("  Nuke Files  ")
	GUICtrlCreateLabel(	"Destroy sensitive data so that they can't be recovered and viewed by others. " & _
						"This tool uses the American DOD 5220.22-M method (US Department " & _
						"of Defence) method to securely remove the data.", 25, 50, 565, 50)
	$FileList = GUICtrlCreateListView("", 25, 100, 565, 220, BitOR($LVS_SHOWSELALWAYS, $LVS_SINGLESEL), _
	BitOR($LVS_EX_FULLROWSELECT, $LVS_EX_GRIDLINES, $LVS_EX_DOUBLEBUFFER, $WS_EX_CLIENTEDGE))

	_GUICtrlListView_InsertColumn($FileList, 0, "Name", 450)
	_GUICtrlListView_InsertColumn($FileList, 1, "Size", 90)

	$hFImage = _GUIImageList_Create(16, 16, 5, 3)
	_GUIImageList_AddIcon($hFImage, @ScriptFullPath, -202)
	_GUICtrlListView_SetImageList($FileList, $hFImage, 1)

	GuiCtrlSetFont($FileList, 8.5, 400, 0, "Verdana", 5)
	$BtnAddFiles = GUICtrlCreateButton("Add Files", 25, 375, 130, 30)
	GuiCtrlSetFont($BtnAddFiles, 8.5, 400, 0, "Verdana", $GFSm)
	$BtnRemItem = GUICtrlCreateButton("Remove", 160, 375, 130, 30)
	GuiCtrlSetFont($BtnRemItem, 8.5, 400, 0, "Verdana", $GFSm)
	$BtnRemAll = GUICtrlCreateButton("Remove All", 295, 375, 130, 30)
	GuiCtrlSetFont($BtnRemAll, 8.5, 400, 0, "Verdana", $GFSm)
	$BtnNukeFiles = GUICtrlCreateButton("Nuke Files", 460, 375, 130, 30)
	GuiCtrlSetFont($BtnNukeFiles, 8.5, 400, 0, "Verdana", $GFSm)
	$WipeFProg = GUICtrlCreateProgress(25, 350, 565, 20)
	GUICtrlCreateTabItem("")

	GUICtrlSetOnEvent($BtnAddFiles, "_AddFiles")
	GUICtrlSetOnEvent($BtnRemItem, "_RemoveItem")

	$TabNFree = GUICtrlCreateTabItem("  Nuke Free Space  ")
	GuiCtrlCreateIcon(@ScriptFullPath, 99, 20, 50, 64, 64)
	GUICtrlCreateLabel(	"When files are deleted and emptied from the Recycle Bin they are not truly removed " & _
						"from the hard disk. The files can easily be recovered by data recovery software. " & _
						"To ensure your files are deleted totally you should wipe the free space of your " & _
						"hard disk regularly. This option destroys such files which are already deleted by " & _
						"you so that they can not be recovered.", 100, 50, 490, 100)
	GuiCtrlSetFont(-1, 8.5, 400, 0, "Verdana", $GFSm)
	GUICtrlCreateLabel(	"Select the drive you want to wipe:", 25, 130, 520, 15)
	GuiCtrlSetFont(-1, 8.5, 400, 0, "Verdana", $GFSm)
	$DrivesList = GUICtrlCreateListView("", 25, 145, 565, 170, BitOR($LVS_SHOWSELALWAYS, $LVS_SINGLESEL), _
	BitOR($LVS_EX_FULLROWSELECT, $LVS_EX_GRIDLINES, $LVS_EX_CHECKBOXES, $LVS_EX_DOUBLEBUFFER, $WS_EX_CLIENTEDGE))
	GuiCtrlSetFont($DrivesList, 8.5, 400, 0, "Verdana", 5)

	_GUICtrlListView_InsertColumn($DrivesList, 0, "Name", 300)
	_GUICtrlListView_InsertColumn($DrivesList, 1, "Total Size", 90)
	_GUICtrlListView_InsertColumn($DrivesList, 2, "Free Space", 90)
	_GUICtrlListView_InsertColumn($DrivesList, 3, "Type", 75)

	$hImage = _GUIImageList_Create(16, 16, 5, 3)
	_GUIImageList_AddIcon($hImage, @ScriptFullPath, -201)
	_GUICtrlListView_SetImageList($DrivesList, $hImage, 1)

	$lblWipe = GUICtrlCreateLabel("", 25, 325, 565, 20)
	GuiCtrlSetFont($lblWipe, 10, 400, 0, "Verdana", $GFSm)
	GUICtrlSetColor($lblWipe, 0x8C8C8C)
	$WipeProg = GUICtrlCreateProgress(25, 350, 565, 20)
	$BtnRefresh = GUICtrlCreateButton("Refresh", 25, 375, 150, 35)
	GuiCtrlSetFont($BtnRefresh, 9, 400, 0, "Verdana", $GFSm)
	$BtnNukeNow = GUICtrlCreateButton("Nuke Now", 180, 375, 150, 35)
	GuiCtrlSetFont($BtnNukeNow, 9, 400, 0, "Verdana", $GFSm)

	GUICtrlCreateTabItem("")

	$Drives = DriveGetDrive("Fixed")
	For $i = 1 To $Drives[0]
		$DriveCap = Round(DriveSpaceTotal($Drives[$i]) / 1024, 1)
		$DriveSpace = Round(DriveSpaceFree($Drives[$i]) / 1024, 1)
		If DriveGetLabel($Drives[$i]) <> "" Then
			GUICtrlCreateListViewItem(	DriveGetLabel($Drives[$i]) & " (" & StringUpper($Drives[$i]) & ")|" & _
										$DriveCap & " GB" & "|" & $DriveSpace & " GB" & "|" & _
										DriveGetFileSystem($Drives[$i]), $DrivesList)
		Else
			GUICtrlCreateListViewItem(	"(" & StringUpper($Drives[$i]) & ")|" & _
										$DriveCap & " GB" & "|" & $DriveSpace & " GB" & "|" & _
										DriveGetFileSystem($Drives[$i]), $DrivesList)
		EndIf
		_GUICtrlListView_SetItemImage($DrivesList, $i - 1, 0)
	Next

	GUICtrlSetOnEvent($BtnNukeNow, "_NukeNow")

	GUISetState(@SW_SHOW)

	GUISetOnEvent($GUI_EVENT_CLOSE, "_CloseClicked")
	GUIRegisterMsg($WM_NOTIFY, "WM_NOTIFY")
	GUIRegisterMsg($WM_COMMAND, "MY_WM_COMMAND")

	While 1
		Sleep(25)
	WEnd

EndFunc


Func _CloseClicked()

	GuiDelete($mForm)

	IniWrite(@ScriptDir & "\WinPower.ini", "Global", "OpenHomePage", 0)

	Local $PID = ProcessExists(@ScriptName) ; Will return the PID or 0 if the process isn't found.
	If $PID Then ProcessClose(@ScriptName)
	Exit

EndFunc

Func MY_WM_COMMAND($hWnd, $iMsg, $wParam, $lParam)

    Switch BitAND($wParam, 0xFFFF) ;LoWord = IDFrom
         Case $BtnNukeNow
            Switch BitShift($wParam, 16) ;HiWord = Code
				Case $BN_CLICKED
					If GUICtrlRead($BtnNukeNow) = "Stop Nuking" Then
						_Cancel()
					EndIf
            EndSwitch
    EndSwitch

    Return $GUI_RUNDEFMSG
EndFunc;==>WM_COMMAND

Func WM_NOTIFY($hWnd, $iMsg, $iwParam, $ilParam)
    #forceref $hWnd, $iMsg, $iwParam
    Local $hWndFrom, $iIDFrom, $iCode, $tNMHDR, $hWndListView, $tInfo
 Local $tBuffer
    $hWndListView = $hFileList
    If Not IsHWnd($hFileList) Then $hWndListView = GUICtrlGetHandle($FileList)

    $tNMHDR = DllStructCreate($tagNMHDR, $ilParam)
    $hWndFrom = HWnd(DllStructGetData($tNMHDR, "hWndFrom"))
    $iIDFrom = DllStructGetData($tNMHDR, "IDFrom")
    $iCode = DllStructGetData($tNMHDR, "Code")
    Switch $hWndFrom
        Case $hWndListView
            Switch $iCode
                Case $NM_CLICK ; Sent by a list-view control when the user clicks an item with the left mouse button
                    ;$tInfo = DllStructCreate($tagNMITEMACTIVATE, $ilParam)
					Local $iSel = _GUICtrlListView_GetSelectedIndices($hWndListView, True)
					If $iSel[0] > 0 Then
						GUICtrlSetState($BtnRemItem, $GUI_ENABLE_Ex)
					Else
						GUICtrlSetState($BtnRemItem, $GUI_DISABLE_Ex)
					EndIf
					;_DisplayListViewItemInfo(DllStructGetData($tInfo, "Index"))
				Case $NM_DBLCLK ; Sent by a list-view control when the user double-clicks an item with the left mouse button
                    ;$tInfo = DllStructCreate($tagNMITEMACTIVATE, $ilParam)
				Case $LVN_KEYDOWN ; A key has been pressed
                    ;$tInfo = DllStructCreate($tagNMLVKEYDOWN, $ilParam)
					;Local $iSel = _GUICtrlListView_GetSelectedIndices($hWndListView, True)
					;If $iSel[0] > 0 Then _DisplayListViewItemInfo($iSel[1])
            EndSwitch
    EndSwitch
    Return $GUI_RUNDEFMSG
EndFunc   ;==>WM_NOTIFY

Func _AddFiles()
	Local $ODialog = FileOpenDialog("Choose The File(s) (Max 4000)", "", "(*.*)", 7)
	If $ODialog <> "" Then
		If StringInStr($ODialog, "|") > 0 Then
			Local $StrSplTmp = StringSplit($ODialog, "|")
			For $n = 2 To $StrSplTmp[0]
				If StringRight($StrSplTmp[1], 1) == "\" Then
					If _GUICtrlListView_FindText($FileList, $StrSplTmp[1] & $StrSplTmp[$n], -1, False, True) = -1 Then
						GUICtrlCreateListViewItem($StrSplTmp[1] & $StrSplTmp[$n] & "|" & _
						Round(FileGetSize($StrSplTmp[1] & $StrSplTmp[$n]) / 1024, 1) & " KB", $FileList)
					EndIf
				Else
					If _GUICtrlListView_FindText($FileList, $StrSplTmp[1] & "\" & $StrSplTmp[$n], -1, False, True) = -1 Then
						GUICtrlCreateListViewItem($StrSplTmp[1] & "\" & $StrSplTmp[$n] & "|" & _
						Round(FileGetSize($StrSplTmp[1] & "\" & $StrSplTmp[$n]) / 1024, 1) & " KB", $FileList)
					EndIf
				EndIf
			Next
		Else
			If _GUICtrlListView_FindText($FileList, $ODialog, -1, False, True) = -1 Then
				GUICtrlCreateListViewItem($ODialog & "|" & Round(FileGetSize($ODialog) / 1024, 1) & "KB", $FileList)
			EndIf
		EndIf
		For $m = 0 To _GUICtrlListView_GetItemCount($FileList) - 1
			_GUICtrlListView_SetItemImage($FileList, $m, 0)
		Next

	EndIf
EndFunc

Func _RemoveItem()
	Local $LSelected = _GUICtrlListView_GetNextItem($FileList)
	_GUICtrlListView_DeleteItem($FileList, $LSelected)
EndFunc

Func _NukeNow()
	Local $DriveChecked, $Drive, $DriveType, $FreeSpace, $Password, $SpaceUsed, $SpaceUsedPos, $Calc
	Local $lblUpdate = 0

	GUICtrlSetState($BtnRefresh, $GUI_DISABLE_Ex)
	GUICtrlSetData($BtnNukeNow, "Stop Nuking")
	$Cancel = 0
	GUICtrlSetOnEvent($BtnNukeNow, "_Cancel")
	If Not IsHWnd($hDrivesList) Then $hDrivesList = GUICtrlGetHandle($DrivesList)
	For $u = 0 To _GUICtrlListView_GetItemCount($hDrivesList)
		$DriveChecked = _GUICtrlListView_GetItemChecked($hDrivesList, $u)
		If $DriveChecked = 1 Then
			$Drive = _GUICtrlListView_GetItemText($hDrivesList, $u)
			$Drive = StringTrimRight($Drive, 1)
			$Drive = StringRight($Drive, 2)
			$DriveType = _GUICtrlListView_GetItemText($hDrivesList, $u, 3)
			If $DriveType = "NTFS" Then
				$wFile = $Drive & "\~REBGN" & Random(1, 1000000, 1)
				$FreeSpace = DriveSpaceFree($Drive)
				$Password = _Randomize(1000000)
				$SpaceUsed = Round(DriveSpaceTotal($Drive), 1) - Round(DriveSpaceFree($Drive), 1)
				$Calc = Round(DriveSpaceFree($Drive))
				While $Cancel = 0
					If Round(DriveSpaceFree($Drive)) >= 10 Then
						FileWrite($wFile, $Password)
						$SpaceUsedPos = (Round(DriveSpaceTotal($Drive), 1) - Round(DriveSpaceFree($Drive), 1)) - Round($SpaceUsed)
						If TimerDiff($lblUpdate) >= 500 Then
							GUICtrlSetData($lblWipe, 	"Nuking (" & $Drive & ") - " & _
														Round($SpaceUsedPos / $Calc * 100, 2) & "%")
							GUICtrlSetData($WipeProg, Round($SpaceUsedPos / $Calc * 100))
							$lblUpdate = TimerInit()
						EndIf
					Else

						ExitLoop
					EndIf
				WEnd
				_EraseTempFile()
				FileClose($wFile)
			EndIf
		EndIf
	Next
	;If GUICtrlRead($ShutDown) = $GUI_CHECKED_Ex And StringInStr(GUICtrlRead($Label_S), "100%") Then
		;Shutdown(9)
	;Else
		GUICtrlSetData($lblWipe, "Do something")
	;EndIf
	GUICtrlSetState($BtnRefresh, $GUI_ENABLE_Ex)
	GUICtrlSetOnEvent($BtnNukeNow, "_NukeNow")
	GUICtrlSetData($BtnNukeNow, "Nuke Now")
	$Cancel = 0

EndFunc

Func _Randomize($cL)
	Local $Chr1, $Password

    $Chr1 = Chr(Random(33, 255, 1))
    For $x = 1 To $cL
     $Password &= $Chr1 & $Chr1
     Next
     Return $Password

EndFunc   ;==>_Randomize

Func _Cancel()
	$Cancel = 1
EndFunc

Func _EraseTempFile()
	$Drives = DriveGetDrive("Fixed")
	For $i = 1 To $Drives[0]
		FileDelete($Drives[$i] & "\~REBGN*")
	Next
EndFunc