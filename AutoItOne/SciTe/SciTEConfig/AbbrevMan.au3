
#region ; Includes

	#include <GUIConstantsEx.au3>
	#include <ListViewConstants.au3>
	#include <WindowsConstants.au3>
	#include <StaticConstants.au3>
	#include <ButtonConstants.au3>
	#include <GUIListView.au3>
	#include <Constants.au3>
	#include <GuiEdit.au3>
	#include <Array.au3>
	#include <File.au3>

	#include <SciTE_Reload_Props.au3>

#endregion ; Includes

Func _AbbrevManager()

	Local $aSciTE_Abbrev, $aUser_Abbrev, $aUser_Backup
	Local $fReinstall = True, $fUser = True, $fChange = False
	Local $iLV_Index, $sAbbrev_Name
	Local $aGUI_Control[10]
	; 0 = Abbrev input		5 = Edit/Override button
	; 1 = User radio		6 = Rename button
	; 2 = SciTE radio		7 = Delete button
	; 3 = Search button		8 = Cancel button
	; 4 = Create button		9 = Save button

	#region ; Check if running

		If WinExists("SciTE Abbreviation Manager") Then Return

	#endregion ; Check if running
	#region ; Paths

		; Get main path for SciTE files
		Local $sSciTEFilePath = EnvGet("SCITE_USERHOME")
		If Not $sSciTEFilePath Then
			$sSciTEFilePath = EnvGet("SCITE_HOME")
			If Not $sSciTEFilePath Then
				$sSciTEFilePath = @UserProfileDir
			EndIf
		EndIf
		; Set KeyWord and Abbrev file paths
		Local $sUser_KeyWordPath = $sSciTEFilePath & "\au3.keywords.user.abbreviations.properties"
		Local $sSciTE_AbbrevPath = $sSciTEFilePath & "\au3abbrev.properties"
		Local $sUser_AbbrevPath = $sSciTEFilePath & "\au3userabbrev.properties"

		; Set user backup file path
		Local $sUser_BackUpPath = EnvGet("SCITE_USERHOME")
		If Not $sUser_BackUpPath Then
			$sUser_BackUpPath = EnvGet("SCITE_HOME")
			If Not $sUser_BackUpPath Then
				$sUser_BackUpPath = @ScriptDir
			EndIf
		EndIf
		If Not FileExists($sUser_BackUpPath & "\AbbrevMan") Then DirCreate($sUser_BackUpPath & "\AbbrevMan")
		$sUser_BackUpPath = $sUser_BackUpPath & "\AbbrevMan\Abbrev.txt"

	#endregion ; Paths
	#region ; Read in Files

		; Read in abbrev files
		_FileReadToArray($sSciTE_AbbrevPath, $aSciTE_Abbrev)
		If @error Then
			Local $aSciTE_Abbrev[1] = [0]
		EndIf

		_FileReadToArray($sUser_AbbrevPath, $aUser_Abbrev)
		If @error Then
			Local $aUser_Abbrev[1] = [0]
		Else
			_ArraySort($aUser_Abbrev, 0, 1)
		EndIf

		; Read in backup file
		_FileReadToArray($sUser_BackUpPath, $aUser_Backup)
		If @error Then
			Local $aUser_Backup[1] = [0]
			$fReinstall = False
		EndIf

	#endregion ; Read in Files
	#region ; Create GUI

		Local $iGUI_Height = @DesktopHeight - 200
		If $iGUI_Height > 660 Then
			$iGUI_Height = 660
		EndIf

		; Create Main GUI
		Local $hMain_GUI = GUICreate("SciTE Abbreviation Manager", 800, $iGUI_Height)
		GUISetBkColor(0xCECECE)

		; Create menu
		Local $mFile_Menu = GUICtrlCreateMenu("&File")
		Local $cReinstall_Menu_Item = GUICtrlCreateMenuItem("&Reinstall", $mFile_Menu)
		If $fReinstall = False Then GUICtrlSetState($cReinstall_Menu_Item, $GUI_DISABLE)
		GUICtrlCreateMenuItem("", $mFile_Menu)
		Local $cExit_Menu_Item = GUICtrlCreateMenuItem("&Exit", $mFile_Menu)
		Local $mHelp_Menu = GUICtrlCreateMenu("&Help")
		Local $cInfo_Menu_Item = GUICtrlCreateMenuItem("&About", $mHelp_Menu)

		; Create abbreviation name input
		$aGUI_Control[0] = GUICtrlCreateInput("", 15, 15, 140, 20, $ES_LOWERCASE)

		; Create Area group
		GUICtrlCreateGroup("", 15, $iGUI_Height - 65, 250, 35)
		$aGUI_Control[1] = GUICtrlCreateRadio(" User Abbreviations", 20, $iGUI_Height - 55, 120, 20)
		GUICtrlSetState($aGUI_Control[1], $GUI_CHECKED)
		$aGUI_Control[2] = GUICtrlCreateRadio(" SciTE Abbreviations", 140, $iGUI_Height - 55, 120, 20)
		GUICtrlCreateGroup("", -99, -99, 1, 1)

		; Create buttons
		$aGUI_Control[3] = GUICtrlCreateButton("Search", 170, 10, 115, 30, $BS_DEFPUSHBUTTON)
		$aGUI_Control[4] = GUICtrlCreateButton("Create", 295, 10, 115, 30)
		$aGUI_Control[5] = GUICtrlCreateButton("Edit", 420, 10, 115, 30)
		$aGUI_Control[6] = GUICtrlCreateButton("Rename", 545, 10, 115, 30)
		$aGUI_Control[7] = GUICtrlCreateButton("Delete", 670, 10, 115, 30)
		$aGUI_Control[8] = GUICtrlCreateButton("Cancel", 485, $iGUI_Height - 60, 140, 30)
		$aGUI_Control[9] = GUICtrlCreateButton("Save", 645, $iGUI_Height - 60, 140, 30)
		GUICtrlSetState($aGUI_Control[9], $GUI_DISABLE)

		; Create a listview
		$gABM_cListView = GUICtrlCreateListView("Abbreviation|Code", 15, 50, 770, $iGUI_Height - 120, $GUI_SS_DEFAULT_LISTVIEW)
		GUICtrlSetBkColor($gABM_cListView, $GUI_BKCOLOR_LV_ALTERNATE)
		GUICtrlSetBkColor($gABM_cListView, 0xE0FFFF)
		_GUICtrlListView_SetColumnWidth($gABM_cListView, 0, 100)
		_GUICtrlListView_SetColumnWidth($gABM_cListView, 1, 645)

		; Fill ListView
		_ListView_Fill($aUser_Abbrev, $aSciTE_Abbrev, $fUser)

		; Create a dummy for item selection change
		$gABM_cSelChange = GUICtrlCreateDummy()

		; Create a dummy for doubleclicks
		$gABM_cClicked = GUICtrlCreateDummy()

		; Set buttons for user abbrevs
		_UserButton_Set($aGUI_Control, $fReinstall, $cReinstall_Menu_Item)

		GUISetState(@SW_SHOW, $hMain_GUI)

		; Register WM_NOTIFY for clicks and selection changes
		GUIRegisterMsg($WM_NOTIFY, "_ABM_WM_NOTIFY")

	#endregion ; Create GUI
	#region ; Main Loop

		While 1

			Switch GUIGetMsg()
				Case $GUI_EVENT_CLOSE, $aGUI_Control[8], $cExit_Menu_Item
					If $fChange = True Then
						If MsgBox($MB_YESNO + $MB_ICONWARNING + $MB_SYSTEMMODAL, "Warning", "Discard changes made?") = 7 Then
							_Save_Exit_Abb($sUser_KeyWordPath, $sUser_AbbrevPath, $sUser_BackUpPath, $aUser_Abbrev, $hMain_GUI)
						EndIf
					EndIf
					GUIDelete($hMain_GUI)
					Return
				Case $aGUI_Control[9]
					If $fChange Then
						_Save_Exit_Abb($sUser_KeyWordPath, $sUser_AbbrevPath, $sUser_BackUpPath, $aUser_Abbrev, $hMain_GUI)
					EndIf
					GUIDelete($hMain_GUI)
					Return
				Case $gABM_cSelChange
					$iLV_Index = Number(_GUICtrlListView_GetSelectedIndices($gABM_cListView))
					$sAbbrev_Name = _GUICtrlListView_GetItemText($gABM_cListView, $iLV_Index)
					GUICtrlSetData($aGUI_Control[0], $sAbbrev_Name)
				Case $gABM_cClicked
					_GUICtrlListView_GetSelectedIndices($gABM_cListView)
					$iLV_Index = Number(_GUICtrlListView_GetSelectedIndices($gABM_cListView))
					$sAbbrev_Name = _GUICtrlListView_GetItemText($gABM_cListView, $iLV_Index)
					GUICtrlSetData($aGUI_Control[0], $sAbbrev_Name)
					Create_Code_GUI(0, $aGUI_Control, $aUser_Abbrev, $aSciTE_Abbrev, $sAbbrev_Name, $fUser, $fChange, $hMain_GUI)
				Case $aGUI_Control[3]
					_Search($aGUI_Control, $fUser)
				Case $aGUI_Control[4]
					_Create($aGUI_Control, $aUser_Abbrev, $aSciTE_Abbrev, $fUser, $fChange, $hMain_GUI)
				Case $aGUI_Control[5]
					_Ed_Ovrd($aGUI_Control, $aUser_Abbrev, $aSciTE_Abbrev, $fUser, $fChange, $hMain_GUI)
				Case $aGUI_Control[6]
					_Rename($aGUI_Control, $aUser_Abbrev, $aSciTE_Abbrev, $fUser, $fChange, $hMain_GUI)
				Case $aGUI_Control[7]
					_Delete($aGUI_Control, $aUser_Abbrev, $aSciTE_Abbrev, $fUser, $fChange)
				Case $aGUI_Control[1], $aGUI_Control[2]
					If BitAND(GUICtrlRead($aGUI_Control[1]), $GUI_CHECKED) Then
						$fUser = True
						_Reload($aGUI_Control, $aUser_Abbrev, $aSciTE_Abbrev, $fUser, $fReinstall, $cReinstall_Menu_Item)
						GUICtrlSetData($aGUI_Control[5], "Edit")
					Else
						If MsgBox($MB_YESNO + $MB_ICONWARNING + $MB_SYSTEMMODAL, "Warning", "The standard SciTE Abbreviations will now be displayed" & @CRLF & @CRLF & _
								"You can choose to override them with a User Abbreviation." & @CRLF & @CRLF & _
								"Are you sure you wish to continue?") = 6 Then
							$fUser = False
							_Reload($aGUI_Control, $aUser_Abbrev, $aSciTE_Abbrev, $fUser, $fReinstall, $cReinstall_Menu_Item)
							GUICtrlSetData($aGUI_Control[5], "Override")
						Else
							GUICtrlSetState($aGUI_Control[1], $GUI_CHECKED)
						EndIf
					EndIf
				Case $cReinstall_Menu_Item
					_Reinstall($aGUI_Control, $aUser_Abbrev, $aUser_Backup, $fUser, $fChange)
				Case $cInfo_Menu_Item
					MsgBox($MB_OK + $MB_ICONINFORMATION + $MB_SYSTEMMODAL, "About", "SciTE Abbreviation Manager" & @CRLF & @CRLF & "Melba23" & @CRLF & @CRLF & _
							"Based on some original code by BugFix")
			EndSwitch

		WEnd

	#endregion ; Main Loop

EndFunc   ;==>_AbbrevManager

#region ; Primary Buttons

	Func _Search($aGUI_Control, $fUser)

		Local $iIndex

		; Determine how many items are displayed - and just do it once
		Static $iVis_Count = 0
		If $iVis_Count = 0 Then
			Local $aItem_Rect = _GUICtrlListView_GetItemRect($gABM_cListView, 0)
			Local $aLV_Rect = WinGetPos(GUICtrlGetHandle($gABM_cListView))
			$iVis_Count = Int($aLV_Rect[3] / ($aItem_Rect[3] - $aItem_Rect[1]) / 2)
		EndIf

		Local $iTop_Index = _GUICtrlListView_GetItemCount($gABM_cListView) - 1
		If $iTop_Index = -1 Then Return

		Local $sAbbrev_Name = GUICtrlRead($aGUI_Control[0])
		If StringStripWS($sAbbrev_Name, 8) = "" Then Return

		; Unselect all
		_GUICtrlListView_SetItemSelected($gABM_cListView, -1, False)
		; Reset ListView to top
		_GUICtrlListView_EnsureVisible($gABM_cListView, 0)
		; Find index of abbrev in ListView
		For $iIndex = 0 To $iTop_Index
			If StringInStr(_GUICtrlListView_GetItemText($gABM_cListView, $iIndex), $sAbbrev_Name) Then
				ExitLoop
			EndIf
		Next
		; If not found
		If $iIndex > $iTop_Index Then
			Local $sMsg = (($fUser) ? ("User") : ("SciTE"))
			MsgBox($MB_OK + $MB_ICONERROR + $MB_SYSTEMMODAL, "Error", "The " & $sMsg & " Abbreviation" & @CRLF & @CRLF & $sAbbrev_Name & @CRLF & @CRLF & "does not exist.")
			Return
		EndIf

		; Get item focused - in the middle of the ListView if possible
		_GUICtrlListView_SetItemState($gABM_cListView, $iIndex, $LVIS_SELECTED, $LVIS_SELECTED)
		_GUICtrlListView_EnsureVisible($gABM_cListView, $iTop_Index) ; Scroll down
		Local $iVis_Index = 0
		If $iVis_Count < $iIndex Then
			$iVis_Index = $iIndex - $iVis_Count ; Set index for scroll back up
		EndIf
		_GUICtrlListView_EnsureVisible($gABM_cListView, $iVis_Index) ; And do it
		GUICtrlSetState($gABM_cListView, $GUI_FOCUS)

	EndFunc   ;==>_Search

	Func _Create($aGUI_Control, ByRef $aUser_Abbrev, ByRef $aSciTE_Abbrev, $fUser, ByRef $fChange, $hMain_GUI)

		Local $iState = 1

		; Double check
		If Not $fUser Then Return

		Local $sAbbrev_Name = GUICtrlRead($aGUI_Control[0])
		If StringStripWS($sAbbrev_Name, 8) = "" Then
			Return MsgBox($MB_OK + $MB_ICONERROR + $MB_SYSTEMMODAL, "Error", "No Abbreviation selected.")
		EndIf
		If $sAbbrev_Name = "" Then Return MsgBox($MB_OK + $MB_ICONERROR + $MB_SYSTEMMODAL, "Error", "No User Abbreviation name.")
		; Check if name already taken
		If _SearchArray($aUser_Abbrev, $sAbbrev_Name) >= 0 Then
			MsgBox($MB_OK + $MB_ICONERROR + $MB_SYSTEMMODAL, "Error", "The User Abbreviation" & @CRLF & @CRLF & $sAbbrev_Name & @CRLF & @CRLF & "already exists.")
			Return
		EndIf
		; Check if standard abbreviation
		If _SearchArray($aSciTE_Abbrev, $sAbbrev_Name) >= 0 Then
			If MsgBox($MB_YESNO + $MB_ICONWARNING + $MB_SYSTEMMODAL, _
					"Warning", "The SciTE Abbreviation" & @CRLF & @CRLF & $sAbbrev_Name & @CRLF & @CRLF & "already exists." & @CRLF & @CRLF & _
					"Do you wish to override the SciTE abbreviation?") = 7 Then
				Return
			Else
				$iState = 3
			EndIf
		EndIf

		; Create code GUI for creation
		Create_Code_GUI($iState, $aGUI_Control, $aUser_Abbrev, $aSciTE_Abbrev, $sAbbrev_Name, $fUser, $fChange, $hMain_GUI)

	EndFunc   ;==>_Create

	Func _Ed_Ovrd($aGUI_Control, ByRef $aUser_Abbrev, ByRef $aSciTE_Abbrev, $fUser, ByRef $fChange, $hMain_GUI)

		Local $iIndex, $iState = 2

		; Sanity check
		Local $iTop_Index = _GUICtrlListView_GetItemCount($gABM_cListView) - 1
		If $iTop_Index = -1 Then Return

		Local $sAbbrev_Name = GUICtrlRead($aGUI_Control[0])
		If StringStripWS($sAbbrev_Name, 8) = "" Then Return
		If $sAbbrev_Name = "" Then Return MsgBox($MB_OK + $MB_ICONERROR + $MB_SYSTEMMODAL, "Error", "No Abbreviation selected.")

		If $fUser Then
			; Check abbreviation exists
			$iIndex = _SearchArray($aUser_Abbrev, $sAbbrev_Name)
			If $iIndex = -1 Then
				MsgBox($MB_OK + $MB_ICONERROR + $MB_SYSTEMMODAL, "Error", "The User Abbreviation" & @CRLF & @CRLF & $sAbbrev_Name & @CRLF & @CRLF & "does not exist.")
				Return
			EndIf
		Else
			; Check if abbreviation already overridden
			$iIndex = _SearchArray($aUser_Abbrev, $sAbbrev_Name)
			If $iIndex <> -1 Then
				MsgBox($MB_OK + $MB_ICONERROR + $MB_SYSTEMMODAL, "Error", "The SciTE Abbreviation" & @CRLF & @CRLF & $sAbbrev_Name & @CRLF & @CRLF & _
						"has already been overridden." & @CRLF & @CRLF & "Select the User abbreviations page to edit it")
				Return
			EndIf
			; Check if abbreviation exists
			$iIndex = _SearchArray($aSciTE_Abbrev, $sAbbrev_Name)
			If $iIndex = -1 Then
				MsgBox($MB_OK + $MB_ICONERROR + $MB_SYSTEMMODAL, "Error", "The SciTE Abbreviation" & @CRLF & @CRLF & $sAbbrev_Name & @CRLF & @CRLF & "does not exist.")
				Return
			EndIf
			; Set override flag
			$iState = 3
		EndIf

		; Create code GUI for editing
		Create_Code_GUI($iState, $aGUI_Control, $aUser_Abbrev, $aSciTE_Abbrev, $sAbbrev_Name, $fUser, $fChange, $hMain_GUI)

	EndFunc   ;==>_Ed_Ovrd

	Func _Rename($aGUI_Control, ByRef $aUser_Abbrev, ByRef $aSciTE_Abbrev, $fUser, ByRef $fChange, $hMain_GUI)

		Local $aMsg

		; Get current abbrev name
		Local $Curr_Name = GUICtrlRead($aGUI_Control[0])
		If StringStripWS($Curr_Name, 8) = "" Then
			Return MsgBox($MB_OK + $MB_ICONERROR + $MB_SYSTEMMODAL, "Error", "No Abbreviation selected.")
		EndIf

		; Create dialog
		Local $hRename_GUI = GUICreate("Rename Abbreviation", 250, 110, -1, -1, Default, Default, $hMain_GUI)
		GUISetBkColor(0xCECECE)

		GUICtrlCreateLabel("Current Name:", 10, 10, 100, 20)
		GUICtrlCreateLabel($Curr_Name, 110, 10, 130, 20)
		GUICtrlSetBkColor($hRename_GUI, 0xE0E0E0)
		GUICtrlCreateLabel("New name:", 10, 40, 100, 20)
		Local $cInput = GUICtrlCreateInput("", 110, 40, 130, 20)

		Local $cButton_Save = GUICtrlCreateButton("Save", 70, 70, 80, 30, $BS_DEFPUSHBUTTON)
		Local $cButton_Can = GUICtrlCreateButton("Cancel", 160, 70, 80, 30)

		GUISetState()

		While 1

			$aMsg = GUIGetMsg(1)
			Switch $aMsg[1]
				Case $hRename_GUI
					Switch $aMsg[0]
						Case $GUI_EVENT_CLOSE, $cButton_Can
							ExitLoop
						Case $cButton_Save
							Local $sNew_Name = GUICtrlRead($cInput)
							If $sNew_Name Then
								; Check if already exists
								If _SearchArray($aUser_Abbrev, $sNew_Name) >= 0 Then
									MsgBox($MB_OK + $MB_ICONERROR + $MB_SYSTEMMODAL, "Error", "The User Abbreviation" & @CRLF & @CRLF & $sNew_Name & @CRLF & @CRLF & "already exists.")
									ExitLoop
								EndIf
								If _SearchArray($aSciTE_Abbrev, $sNew_Name) >= 0 Then
									If MsgBox($MB_YESNO + $MB_ICONWARNING + $MB_SYSTEMMODAL, _
											"Warning", "The SciTE Abbreviation" & @CRLF & @CRLF & $sNew_Name & @CRLF & @CRLF & "already exists." & @CRLF & @CRLF & _
											"Do you want to override the SciTE abbreviation?") = 7 Then
										ExitLoop
									EndIf
								EndIf
								; Rename abbreviation
								Local $iArray_Index = _SearchArray($aUser_Abbrev, $Curr_Name)
								Local $aSplit = StringRegExp($aUser_Abbrev[$iArray_Index], "(?U)^.*=(.*)$", 3)
								$aUser_Abbrev[$iArray_Index] = $sNew_Name & "=" & $aSplit[0]
								_ArraySort($aUser_Abbrev, 0, 1)
								GUICtrlSetData($aGUI_Control[0], $sNew_Name)
								; Set change flag
								$fChange = True
								GUICtrlSetState($aGUI_Control[9], $GUI_ENABLE)
								ExitLoop
							EndIf
							GUICtrlSetState($cInput, $GUI_FOCUS)
					EndSwitch
			EndSwitch

		WEnd

		; Delete dialog
		GUIDelete($hRename_GUI)
		; Redraw ListView
		_ListView_Fill($aUser_Abbrev, $aSciTE_Abbrev, $fUser)
		; Highlight line
		_Search($aGUI_Control, $fUser)

	EndFunc   ;==>_Rename

	Func _Delete($aGUI_Control, ByRef $aUser_Abbrev, ByRef $aSciTE_Abbrev, $fUser, ByRef $fChange)

		; Sanity check
		If (Not $fUser) Or _GUICtrlListView_GetItemCount($gABM_cListView) = 0 Then Return

		Local $sAbbrev_Name = GUICtrlRead($aGUI_Control[0])
		If StringStripWS($sAbbrev_Name, 8) = "" Then
			Return MsgBox($MB_OK + $MB_ICONERROR + $MB_SYSTEMMODAL, "Error", "No User Abbreviation selected.")
		EndIf
		; Check name exists
		Local $iArray_Index = _SearchArray($aUser_Abbrev, $sAbbrev_Name)
		If $iArray_Index = -1 Then
			MsgBox($MB_OK + $MB_ICONERROR + $MB_SYSTEMMODAL, "Error", "The User Abbreviation" & @CRLF & @CRLF & $sAbbrev_Name & @CRLF & @CRLF & "does not exist.")
			Return
		Else
			If MsgBox($MB_YESNO + $MB_ICONWARNING + $MB_SYSTEMMODAL, "Warning", "Are you sure that you want to delete User Abbreviation" & @CRLF & @CRLF & $sAbbrev_Name) = 7 Then Return
			_ArrayDelete($aUser_Abbrev, $iArray_Index)
			$aUser_Abbrev[0] -= 1
		EndIf

		; If no user abbrevs, disable buttons
		If $aUser_Abbrev[0] = 0 Then
			GUICtrlSetState($aGUI_Control[5], $GUI_DISABLE)
			GUICtrlSetState($aGUI_Control[6], $GUI_DISABLE)
			GUICtrlSetState($aGUI_Control[7], $GUI_DISABLE)
			GUICtrlSetState($aGUI_Control[3], $GUI_DISABLE)
		EndIf

		; Reset ListView
		GUICtrlSetData($aGUI_Control[0], "")
		_ListView_Fill($aUser_Abbrev, $aSciTE_Abbrev, $fUser)

		; Set change flag
		$fChange = True
		GUICtrlSetState($aGUI_Control[9], $GUI_ENABLE)

	EndFunc   ;==>_Delete

#endregion ; Primary Buttons
#region ; Code GUI

	Func Create_Code_GUI($iState, $aGUI_Control, ByRef $aUser_Abbrev, ByRef $aSciTE_Abbrev, $sAbbrev_Name, $fUser, ByRef $fChange, $hMain_GUI)

		Local $iIndex, $aMsg, $cCode_Add_Button, $cCode_Cancel_Button, $cCode_Edit

		Local $hCode_GUI = GUICreate("", 700, 400, -1, -1, Default, Default, $hMain_GUI)

		; Get index of abbreviation
		If $fUser And $iState <> 3 Then ; If in User mode and not overriding
			$iIndex = _SearchArray($aUser_Abbrev, $sAbbrev_Name)
		Else
			$iIndex = _SearchArray($aSciTE_Abbrev, $sAbbrev_Name)
		EndIf

		If $iState = 0 Then ; Show GUI
			$cCode_Add_Button = 9999
			$cCode_Cancel_Button = GUICtrlCreateButton("Close", 310, 360, 80, 30)
			$cCode_Edit = GUICtrlCreateEdit("", 10, 10, 680, 345, BitOR($GUI_SS_DEFAULT_EDIT, $ES_READONLY))
			GUICtrlSetFont($cCode_Edit, 10, 400, 0, "Lucida Console")
			GUICtrlSetBkColor($cCode_Edit, 0xC8F8F8)
			If $fUser Then
				GUICtrlSetData($cCode_Edit, _Abbrev2Code($aUser_Abbrev[$iIndex]))
			Else
				GUICtrlSetData($cCode_Edit, _Abbrev2Code($aSciTE_Abbrev[$iIndex]))
			EndIf
			WinSetTitle($hCode_GUI, "", "Abbreviation Code for >> " & GUICtrlRead($aGUI_Control[0]) & " <<")
		Else ; Common Create/Edit/Override GUI
			$cCode_Cancel_Button = GUICtrlCreateButton("Cancel", 360, 360, 80, 30)
			GUICtrlCreateLabel("Press Ctrl-TAB to enter TAB", 10, 370, 150, 20)
			$cCode_Edit = GUICtrlCreateEdit("", 10, 10, 680, 345, BitOR($WS_HSCROLL, $WS_VSCROLL, $ES_MULTILINE, $ES_WANTRETURN))
			GUICtrlSetFont($cCode_Edit, 10, 400, 0, "Lucida Console")
			Switch $iState
				Case 3 ; Override GUI
					GUICtrlSetBkColor($cCode_Edit, 0xFCC441)
					GUICtrlSetData($cCode_Edit, _Abbrev2Code($aSciTE_Abbrev[$iIndex]))
					WinSetTitle($hCode_GUI, "", "Override Existing Abbreviation Code for >> " & GUICtrlRead($aGUI_Control[0]) & " <<")
					$cCode_Add_Button = GUICtrlCreateButton("Save", 270, 360, 80, 30)
				Case 2 ; Edit GUI
					GUICtrlSetBkColor($cCode_Edit, 0xFFD8D0)
					GUICtrlSetData($cCode_Edit, _Abbrev2Code($aUser_Abbrev[$iIndex]))
					WinSetTitle($hCode_GUI, "", "Edit Existing Abbreviation Code for >> " & GUICtrlRead($aGUI_Control[0]) & " <<")
					$cCode_Add_Button = GUICtrlCreateButton("Save", 270, 360, 80, 30)
				Case 1 ; Create GUI
					GUICtrlSetBkColor($cCode_Edit, 0xF8F090)
					GUICtrlSetData($cCode_Edit, "")
					WinSetTitle($hCode_GUI, "", "Enter New Abbreviation Code for >> " & GUICtrlRead($aGUI_Control[0]) & " <<")
					$cCode_Add_Button = GUICtrlCreateButton("Add", 270, 360, 80, 30)
			EndSwitch
		EndIf

		GUICtrlSetState($cCode_Edit, $GUI_FOCUS)
		GUISetState(@SW_SHOW, $hCode_GUI)

		While 1

			$aMsg = GUIGetMsg(1)
			Switch $aMsg[1]
				Case $hCode_GUI
					Switch $aMsg[0]
						Case $GUI_EVENT_CLOSE, $cCode_Cancel_Button
							$iState = 0
							ExitLoop
						Case $cCode_Add_Button
							Local $sAbbrev_Text = GUICtrlRead($cCode_Edit)
							If $sAbbrev_Text <> "" Then
								Switch $iState
									Case 2 ; Edit
										_Add_EditedAbbrev($aGUI_Control, $aUser_Abbrev, $aSciTE_Abbrev, $sAbbrev_Name, $sAbbrev_Text, $fUser, $fChange)
									Case Else
										_Add_NewAbbrev($aGUI_Control, $aUser_Abbrev, $aSciTE_Abbrev, $sAbbrev_Name, $sAbbrev_Text, $fUser, $fChange)
								EndSwitch
							EndIf
							ExitLoop
					EndSwitch
			EndSwitch

		WEnd

		GUIDelete($hCode_GUI)

		If $iState = 3 Then
			MsgBox($MB_OK + $MB_ICONINFORMATION + $MB_SYSTEMMODAL, "Info", "The override has been stored as a User abbreviations" & @CRLF & @CRLF & _
					"Select the User abbreviations page to edit it")
		EndIf

	EndFunc   ;==>Create_Code_GUI

#endregion ; Code GUI
#region ; Abbreviation Functions

	Func _Add_NewAbbrev($aGUI_Control, ByRef $aUser_Abbrev, ByRef $aSciTE_Abbrev, $sAbbrev_Name, $sAbbrev_Text, $fUser, ByRef $fChange)

		Local $sAbbr

		$sAbbr = _Code2Abbrev($sAbbrev_Text)
		; Insert abbrev
		_ArrayAdd($aUser_Abbrev, $sAbbrev_Name & "=" & $sAbbr, Default, Default, Default, $ARRAYFILL_FORCE_SINGLEITEM)
		$aUser_Abbrev[0] += 1
		_ArraySort($aUser_Abbrev, 0, 1)

		; Redraw ListView if required
		If $fUser Then
			_ListView_Fill($aUser_Abbrev, $aSciTE_Abbrev, $fUser)
		EndIf
		; Highlight line
		_Search($aGUI_Control, $fUser)

		; Set change flag
		$fChange = True
		GUICtrlSetState($aGUI_Control[9], $GUI_ENABLE)
		GUICtrlSetState($aGUI_Control[5], $GUI_ENABLE)
		GUICtrlSetState($aGUI_Control[6], $GUI_ENABLE)
		If $fUser Then GUICtrlSetState($aGUI_Control[7], $GUI_ENABLE)
		GUICtrlSetState($aGUI_Control[3], $GUI_ENABLE)

	EndFunc   ;==>_Add_NewAbbrev

	Func _Add_EditedAbbrev($aGUI_Control, ByRef $aUser_Abbrev, ByRef $aSciTE_Abbrev, $sAbbrev_Name, $sAbbrev_Text, $fUser, ByRef $fChange)

		Local $iArray_Index, $sAbbr

		$sAbbr = _Code2Abbrev($sAbbrev_Text)
		; Find abbrev and replace
		$iArray_Index = _SearchArray($aUser_Abbrev, $sAbbrev_Name)
		$aUser_Abbrev[$iArray_Index] = $sAbbrev_Name & "=" & $sAbbr

		; Redraw ListView
		_ListView_Fill($aUser_Abbrev, $aSciTE_Abbrev, $fUser)
		; Highlight line
		_Search($aGUI_Control, $fUser)
		; Set change flag
		$fChange = True
		GUICtrlSetState($aGUI_Control[9], $GUI_ENABLE)

	EndFunc   ;==>_Add_EditedAbbrev

#endregion ; Abbreviation Functions
#region ; Exit Function

	Func _Save_Exit_Abb($sUser_KeyWordPath, $sUser_AbbrevPath, $sUser_BackUpPath, $aUser_Abbrev, $hMain_GUI)

		Local $aSplit

		; User abbrevs
		FileCopy($sUser_AbbrevPath, $sUser_AbbrevPath & ".bak", 1)
		_FileWriteFromArray($sUser_AbbrevPath, $aUser_Abbrev, 1)

		; User backup
		FileCopy($sUser_BackUpPath, $sUser_BackUpPath & ".bak", 1)
		_FileWriteFromArray($sUser_BackUpPath, $aUser_Abbrev, 1)

		; User Keywords
		FileCopy($sUser_KeyWordPath, $sUser_KeyWordPath & ".bak", 1)
		Local $sUser_KeyWord = ""
		Local $sLine = "au3.keywords.userabbrev="
		For $i = 1 To $aUser_Abbrev[0]
			$aSplit = StringSplit($aUser_Abbrev[$i], "=")
			If Not @error Then
				$sLine &= $aSplit[1]
				If $i = $aUser_Abbrev[0] Then
					$sUser_KeyWord &= $sLine
					ExitLoop
				Else
					If StringLen($sLine) > 100 Then
						$sLine &= " \" & @CRLF
						$sUser_KeyWord &= $sLine
						$sLine = @TAB
					Else
						$sLine &= " "
					EndIf
				EndIf
			EndIf
		Next
		Local $cFile = FileOpen($sUser_KeyWordPath, 2)
		FileWrite($cFile, $sUser_KeyWord)
		FileClose($cFile)

		_SciTE_ReloadProps($hMain_GUI)

		Return

	EndFunc   ;==>_Save_Exit_Abb

#endregion ; Exit Function
#region ; Reinstall and Reload

	Func _Reinstall($aGUI_Control, ByRef $aUser_Abbrev, $aUser_Backup, $fUser, ByRef $fChange)

		; Sanity check
		If Not $aUser_Backup[0] Then Return

		; Reset array
		$aUser_Abbrev = $aUser_Backup

		; Set change flag
		$fChange = True
		GUICtrlSetState($aGUI_Control[9], $GUI_ENABLE)
		GUICtrlSetState($aGUI_Control[5], $GUI_ENABLE)
		GUICtrlSetState($aGUI_Control[6], $GUI_ENABLE)
		GUICtrlSetState($aGUI_Control[7], $GUI_ENABLE)
		GUICtrlSetState($aGUI_Control[3], $GUI_ENABLE)

		GUICtrlSetData($aGUI_Control[0], "")
		_ListView_Fill($aUser_Abbrev, "", $fUser)

		GUICtrlSetState($aGUI_Control[3], $GUI_FOCUS)

	EndFunc   ;==>_Reinstall

	Func _Reload($aGUI_Control, $aUser_Abbrev, $aSciTE_Abbrev, $fUser, $fReinstall, $cReinstall_Menu_Item)

		_ListView_Fill($aUser_Abbrev, $aSciTE_Abbrev, $fUser)

		; Set up buttons
		If $fUser Then
			_UserButton_Set($aGUI_Control, $fReinstall, $cReinstall_Menu_Item)
		Else
			GUICtrlSetState($aGUI_Control[3], $GUI_ENABLE)
			GUICtrlSetState($aGUI_Control[5], $GUI_ENABLE)
			GUICtrlSetState($aGUI_Control[6], $GUI_DISABLE)
			GUICtrlSetState($aGUI_Control[4], $GUI_DISABLE)
			GUICtrlSetState($aGUI_Control[7], $GUI_DISABLE)
			GUICtrlSetState($cReinstall_Menu_Item, $GUI_DISABLE)
		EndIf

		GUICtrlSetState($aGUI_Control[3], $GUI_FOCUS)

	EndFunc   ;==>_Reload

#endregion ; Reinstall and Reload
#region ; Internal Functions

	Func _UserButton_Set($aGUI_Control, $fReinstall, $cReinstall_Menu_Item)

		; Set up buttons for User abbrevs
		GUICtrlSetState($aGUI_Control[4], $GUI_ENABLE)
		If $fReinstall Then GUICtrlSetState($cReinstall_Menu_Item, $GUI_ENABLE)

		If _GUICtrlListView_GetItemCount($gABM_cListView) = 0 Then
			GUICtrlSetState($aGUI_Control[5], $GUI_DISABLE)
			GUICtrlSetState($aGUI_Control[6], $GUI_DISABLE)
			GUICtrlSetState($aGUI_Control[7], $GUI_DISABLE)
			GUICtrlSetState($aGUI_Control[3], $GUI_DISABLE)
			; If reinstall possible
			If $fReinstall Then
				MsgBox($MB_OK + $MB_ICONINFORMATION + $MB_SYSTEMMODAL, "Info", "No User Abbreviations exist" & @CRLF & "Only Create and Reinstall functions available")
			Else
				MsgBox($MB_OK + $MB_ICONINFORMATION + $MB_SYSTEMMODAL, "Info", "No User Abbreviations exist" & @CRLF & "Only Create function available")
			EndIf
		Else
			GUICtrlSetState($aGUI_Control[5], $GUI_ENABLE)
			GUICtrlSetState($aGUI_Control[6], $GUI_ENABLE)
			GUICtrlSetState($aGUI_Control[7], $GUI_ENABLE)
			GUICtrlSetState($aGUI_Control[3], $GUI_ENABLE)
		EndIf


	EndFunc   ;==>_UserButton_Set

	Func _Abbrev2Code($sFull_Abbrev)

		Local $sCode = ""
		; Remove name
		Local $sAbbrev = StringRegExpReplace($sFull_Abbrev, "(?U)^(.*=)", "")
		; Split into lines
		Local $aSplit = StringSplit($sAbbrev, "\n", 1)
		For $i = 1 To UBound($aSplit) - 1
			If StringInStr($aSplit[$i], "\t", 1) Then $aSplit[$i] = StringReplace($aSplit[$i], "\t", @TAB)
			If $i = UBound($aSplit) - 1 Then
				$sCode &= $aSplit[$i]
			Else
				$sCode &= $aSplit[$i] & @CRLF
			EndIf
		Next

		Return $sCode

	EndFunc   ;==>_Abbrev2Code

	Func _Code2Abbrev($sAbbrev_Text)

		Local $sAbbr = "", $sLine

		; Split text
		Local $aLines = StringSplit($sAbbrev_Text, @CRLF, 1)
		For $i = 1 To $aLines[0]
			$sLine = $aLines[$i]
			If StringInStr($sLine, @TAB, 1) Then $sLine = StringReplace($sLine, @TAB, "\t")
			If $i = $aLines[0] Then
				$sAbbr &= $sLine
			Else
				$sAbbr &= $sLine & "\n"
			EndIf
		Next

		Return $sAbbr

	EndFunc   ;==>_Code2Abbrev

	Func _ListView_Fill($aUser_Abbrev, $aSciTE_Abbrev, $fUser)

		Local $aSort, $iAbbrev_Count = 0, $iSplit, $cItem

		_GUICtrlListView_DeleteAllItems(GUICtrlGetHandle($gABM_cListView))

		_GUICtrlListView_BeginUpdate($gABM_cListView)

		If $fUser Then
			For $i = 1 To $aUser_Abbrev[0]
				If (StringLeft($aUser_Abbrev[$i], 1) = "#") Or (Not StringInStr($aUser_Abbrev[$i], "=")) Then ContinueLoop
				$iSplit = StringInStr($aUser_Abbrev[$i], "=")
				$cItem = GUICtrlCreateListViewItem('|', $gABM_cListView)
				GUICtrlSetBkColor($cItem, 0xCCFFCC)
				_GUICtrlListView_SetItemText($gABM_cListView, $iAbbrev_Count, StringMid($aUser_Abbrev[$i], 1, $iSplit - 1), 0)
				_GUICtrlListView_SetItemText($gABM_cListView, $iAbbrev_Count, StringMid($aUser_Abbrev[$i], $iSplit + 1), 1)
				$iAbbrev_Count += 1
			Next
		Else
			For $i = 1 To $aSciTE_Abbrev[0]
				If (StringLeft($aSciTE_Abbrev[$i], 1) = "#") Or (Not StringInStr($aSciTE_Abbrev[$i], "=")) Then ContinueLoop
				$iSplit = StringInStr($aSciTE_Abbrev[$i], "=")
				$cItem = GUICtrlCreateListViewItem('|', $gABM_cListView)
				GUICtrlSetBkColor($cItem, 0xCCFFCC)
				_GUICtrlListView_SetItemText($gABM_cListView, $iAbbrev_Count, StringMid($aSciTE_Abbrev[$i], 1, $iSplit - 1), 0)
				_GUICtrlListView_SetItemText($gABM_cListView, $iAbbrev_Count, StringMid($aSciTE_Abbrev[$i], $iSplit + 1), 1)
				$iAbbrev_Count += 1
			Next
		EndIf

		If $fUser Then _GUICtrlListView_SimpleSort($gABM_cListView, $aSort, 0)

		_GUICtrlListView_EndUpdate($gABM_cListView)

		_GUICtrlListView_ClickItem($gABM_cListView, 0)

	EndFunc   ;==>_ListView_Fill

	Func _SearchArray($aArray, $sAbbrev_Name)

		For $i = 1 To $aArray[0]

			Local $iIndex = StringInStr($aArray[$i], "=")
			If $iIndex <> 0 Then
				If StringLeft($aArray[$i], $iIndex - 1) = $sAbbrev_Name Then
					Return $i
				EndIf
			EndIf

		Next
		Return -1

	EndFunc   ;==>_SearchArray

	Func _ABM_WM_NOTIFY($hWnd, $iMsg, $wParam, $lParam)

		#forceref $hWnd, $iMsg

		Switch $wParam
			Case $gABM_cListView
				Local $tStruct = DllStructCreate($tagNMHDR, $lParam)
				If @error Then Return
				Switch DllStructGetData($tStruct, 3)
					Case $NM_DBLCLK
						GUICtrlSendToDummy($gABM_cClicked)
					Case $LVN_ITEMCHANGING
						GUICtrlSendToDummy($gABM_cSelChange)
				EndSwitch
		EndSwitch

	EndFunc   ;==>_ABM_WM_NOTIFY

#endregion ; Internal Functions
