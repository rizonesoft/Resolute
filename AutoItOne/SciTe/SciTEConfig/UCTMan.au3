
#Region ; Includes

#include <GUIConstantsEx.au3>
#include <ListviewConstants.au3>
#include <WindowsConstants.au3>
#include <EditConstants.au3>
#include <Constants.au3>
#include <GUIComboBox.au3>
#include <GUIListView.au3>
#include <Constants.au3>
#include <Array.au3>
#include <File.au3>

#include <StringSize.au3>
#include <SciTE_Reload_Props.au3>

#EndRegion ; Includes

Func _CallTipManager()

	Local $aCallTip, $aUser_Backup, $aSciTECallTip, $aStandardUDF[1] = [0]
	Local $fReinstall = True, $fStandardFolder, $fStandardUDF, $fChange = False, $sInclude_Name
	Local $aGUI_Control[16]
	;  0 = Header radio			 8 = Exit button
	;  1 = Browse button		 9 = Save Button
	;  2 = Parse button			10 = Folder combo
	;  3 = Add button			11 = UDF combo
	;  4 = Remove button		12 = Syntax edit
	;  5 = Skip button			13 = Description edit
	;  6 = Cancel button		14 = Syntax label
	;  7 = View button			15 = Description label

	#Region ; Check if running

	If WinExists("SciTE User CallTip Manager") Then Return

	#EndRegion ; Check if running
	#Region ; Folder Paths

	; Create Include folder list
	Local $sInclude_Folders
	Local $sUser_Folder = RegRead("HKEY_CURRENT_USER\Software\AutoIt v3\AutoIt", "Include")
	Local $aUser_Folder = StringSplit($sUser_Folder, ";")
	For $i = 1 To $aUser_Folder[0]
		If $aUser_Folder[$i] <> "" Then
			$sInclude_Folders &= $aUser_Folder[$i] & "\|"
		EndIf
	Next
	Local $sAutoIt_Path = RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\AutoIt3.exe", "")
	Local $sAutoIt_Folder = StringRegExpReplace($sAutoIt_Path, "(^.*\\)(.*)", "$1")
	$sInclude_Folders &= $sAutoIt_Folder & "Include\"

	#EndRegion ; Folder Paths
	#Region ; File Paths

	Local $SciTEUserDir
	; Check for SCITE_USERHOME Env variable and used that when specified.
	; Else when OS is better than Winxp we use the INI from LocalAPPDATA
	If EnvGet("SCITE_USERHOME") <> "" And FileExists(EnvGet("SCITE_USERHOME")) Then
		$SciTEUserDir = EnvGet("SCITE_USERHOME")
	ElseIf EnvGet("SCITE_HOME") <> "" And FileExists(EnvGet("SCITE_HOME")) Then
		$SciTEUserDir = EnvGet("SCITE_HOME")
	Else
		$SciTEUserDir = @UserProfileDir ; original sciTE default location
	EndIf
	; Set paths for CallTip and Keyword files
	Local $sCallTipPath = $SciTEUserDir & "\au3.user.calltips.api"
	Local $sKeyWordPath = $SciTEUserDir & "\au3.userudfs.properties"
	Local $sAPIPath = $sAutoIt_Folder & "Scite\api\au3.api"

	Local $sUserPath
	; See if app is in Program Files folder
	;### Jos => this needs checking !!!!!
	If StringInStr(@ScriptDir, @ProgramFilesDir) Then
		; Need to save user files elsewhere
		If Not FileExists($SciTEUserDir & "\SciTEConfig\UCTMan") Then DirCreate(@AppDataDir & "\SciTEConfig\UCTMan")
		$sUserPath = $SciTEUserDir & "\SciTEConfig\UCTMan\UCT.txt"
	Else
		; Can use working directory
		$sUserPath = @ScriptDir & "\UCT.txt"
	EndIf

	#EndRegion ; File Paths
	#Region ; Read in Files

	; Read in existing CallTip file
	_FileReadToArray($sCallTipPath, $aCallTip)
	If @error Then
		Local $aCallTip[1] = [0]
	EndIf

	; Read in backup file
	_FileReadToArray($sUserPath, $aUser_Backup)
	If @error Then
		$aUser_Backup = $aCallTip
		$fReinstall = False
	EndIf

	; Sort array
	_ArraySort($aCallTip, 0, 1)

	; Read in SciTE calltip file
	_FileReadToArray($sAPIPath, $aSciTECallTip)
	; Extract standard UDF filenames
	For $i = 1 To $aSciTECallTip[0]
		If StringInStr($aSciTECallTip[$i], "#include <") Then
			$sInclude_Name = StringRegExpReplace($aSciTECallTip[$i], "^.*<(.*)>.*$", "$1")
			If _ArraySearch($aStandardUDF, $sInclude_Name, 1) = -1 Then
				$aStandardUDF[0] += 1
				ReDim $aStandardUDF[$aStandardUDF[0] + 1]
				$aStandardUDF[$aStandardUDF[0]] = $sInclude_Name
			EndIf
		EndIf
	Next

	#EndRegion ; Read in Files
	#Region ; Create GUI

	; Create GUI
	Local $hMain_GUI = GUICreate("SciTE User CallTip Manager", 800, 310)
	GUISetBkColor(0xCECECE)

	; Create menu
	Local $mFile_Menu = GUICtrlCreateMenu("&File")
	Local $cReinstall_Menu_Item = GUICtrlCreateMenuItem("&Reinstall", $mFile_Menu)
	If $fReinstall = False Then GUICtrlSetState(-1, $GUI_DISABLE)
	GUICtrlCreateMenuItem("", $mFile_Menu)
	Local $cExit_Menu_Item = GUICtrlCreateMenuItem("&Exit", $mFile_Menu)
	Local $mHelp_Menu = GUICtrlCreateMenu("&Help")
	Local $cInfo_Menu_Item = GUICtrlCreateMenuItem("&About", $mHelp_Menu)

	; Create radio group
	GUICtrlCreateGroup("", 685, 2, 105, 90)
	$aGUI_Control[0] = GUICtrlCreateRadio("Header Mode", 695, 10, 85, 20)
	GUICtrlSetState(-1, $GUI_CHECKED)
	GUICtrlCreateRadio("Direct Mode", 695, 30, 85, 20)

	; Create buttons
	$aGUI_Control[1] = GUICtrlCreateButton("Browse", 260, 15, 50, 20)
	$aGUI_Control[2] = GUICtrlCreateButton("Parse", 695, 55, 80, 30)
	GUICtrlSetState(-1, $GUI_DISABLE)
	$aGUI_Control[3] = GUICtrlCreateButton("Add", 10, 250, 80, 30)
	GUICtrlSetState(-1, $GUI_DISABLE)
	$aGUI_Control[4] = GUICtrlCreateButton("Remove", 110, 250, 80, 30)
	GUICtrlSetState(-1, $GUI_DISABLE)
	$aGUI_Control[5] = GUICtrlCreateButton("Skip", 210, 250, 80, 30)
	GUICtrlSetState(-1, $GUI_DISABLE)
	$aGUI_Control[6] = GUICtrlCreateButton("Cancel", 310, 250, 80, 30)
	GUICtrlSetState(-1, $GUI_DISABLE)
	$aGUI_Control[7] = GUICtrlCreateButton("View Tips", 460, 250, 80, 30)
	$aGUI_Control[8] = GUICtrlCreateButton("Exit", 610, 250, 80, 30)
	$aGUI_Control[9] = GUICtrlCreateButton("Save", 710, 250, 80, 30)
	GUICtrlSetState(-1, $GUI_DISABLE)

	; Create combos
	Local $sUDF_Combo_Data = "First Select Include Folder"
	$aGUI_Control[10] = GUICtrlCreateCombo("", 10, 40, 300, 20, BitOR($CBS_DROPDOWNLIST, $WS_VSCROLL))
	GUICtrlSetData(-1, $sInclude_Folders)
	$aGUI_Control[11] = GUICtrlCreateCombo($sUDF_Combo_Data, 350, 40, 300, 20, BitOR($CBS_DROPDOWNLIST, $WS_VSCROLL))
	GUICtrlSetState(-1, $GUI_DISABLE)

	; Create inputs
	$aGUI_Control[12] = GUICtrlCreateEdit("", 10, 100, 780, 50, $ES_READONLY)
	GUICtrlSetFont(-1, 10)
	$aGUI_Control[13] = GUICtrlCreateEdit("", 10, 185, 780, 50, 0)
	GUICtrlSetFont(-1, 10)
	GUICtrlSetState(-1, $GUI_DISABLE)

	; Create labels
	GUICtrlCreateLabel("Include Folder", 10, 20, 80, 20)
	GUICtrlCreateLabel("UDF", 350, 20, 80, 20)
	$aGUI_Control[14] = GUICtrlCreateLabel("The function syntax:", 10, 80, 200, 20)
	GUICtrlSetState(-1, $GUI_DISABLE)
	$aGUI_Control[15] = GUICtrlCreateLabel("The function description:", 10, 165, 300, 20)
	GUICtrlSetState(-1, $GUI_DISABLE)

	GUISetState(@SW_SHOW, $hMain_GUI)

	#EndRegion ; Create GUI
	#Region ; Main Loop

	While 1

		Switch GUIGetMsg()
			Case $GUI_EVENT_CLOSE, $aGUI_Control[8], $cExit_Menu_Item
				If $fChange Then
					If MsgBox($MB_YESNO + $MB_ICONQUESTION + $MB_SYSTEMMODAL, "WARNING", "Discard changes made?") = 7 Then
						_Save_Exit_UCT($hMain_GUI, $aCallTip, $sCallTipPath, $sKeyWordPath, $sUserPath)
					EndIf
				EndIf
				GUIDelete($hMain_GUI)
				Return
			Case $aGUI_Control[9]
				If $fChange Then
					_Save_Exit_UCT($hMain_GUI, $aCallTip, $sCallTipPath, $sKeyWordPath, $sUserPath)
				EndIf
				GUIDelete($hMain_GUI)
				Return
			Case $aGUI_Control[2]
				Local $fExit = _Parse_UDF($aGUI_Control, $aStandardUDF, $aSciTECallTip, $aCallTip, $fStandardFolder, $fStandardUDF, $fChange)
				If $fExit Then
					If $fChange Then
						If MsgBox($MB_YESNO + $MB_ICONQUESTION + $MB_SYSTEMMODAL, "WARNING", "Discard changes made?") = 7 Then
							_Save_Exit_UCT($hMain_GUI, $aCallTip, $sCallTipPath, $sKeyWordPath, $sUserPath)
						EndIf
					EndIf
					GUIDelete($hMain_GUI)
					Return
				Else
					; Sort array
					_ArraySort($aCallTip, 0, 1)
				EndIf
			Case $aGUI_Control[1]
				_Browse($sInclude_Folders, $aGUI_Control)
			Case $aGUI_Control[7]
				_View_Tips($hMain_GUI, $aGUI_Control, $aCallTip, $fChange)
			Case $aGUI_Control[10]
				Local $sUDF_Folder = GUICtrlRead($aGUI_Control[10])
				If $sUDF_Folder <> $sUDF_Combo_Data Then
					GUICtrlSetData($aGUI_Control[11], _List_UDFs($sUDF_Folder, $aGUI_Control))
					$sUDF_Combo_Data = $sUDF_Folder
				EndIf
				$fStandardFolder = False
				If $sUDF_Folder = $sAutoIt_Folder & "Include\" Then
					$fStandardFolder = True
				EndIf
			Case $aGUI_Control[11]
				If StringInStr(GUICtrlRead($aGUI_Control[11]), ".au3") <> 0 And BitAND(GUICtrlGetState($aGUI_Control[2]), $GUI_DISABLE) = $GUI_DISABLE Then
					GUICtrlSetState($aGUI_Control[2], $GUI_ENABLE)
				EndIf
			Case $cReinstall_Menu_Item
				; Copy backup array to calltip array
				$aCallTip = $aUser_Backup
				; Sort array
				_ArraySort($aCallTip, 0, 1)
				; Set change flag
				$fChange = True
				GUICtrlSetState($aGUI_Control[9], $GUI_ENABLE)
			Case $cInfo_Menu_Item
				MsgBox(64 + $MB_SYSTEMMODAL, "About", "SciTE User CallTip Manager" & @CRLF & @CRLF & "Copyright (c) Melba23 UK 2009-13")
		EndSwitch

	WEnd

	#EndRegion ; Main Loop

EndFunc   ;==>_CallTipManager
#Region ; File management Functions

Func _List_UDFs($sUDF_Folder, $aGUI_Control)

	If FileExists($sUDF_Folder) = 0 Then Return

	GUICtrlSetState($aGUI_Control[11], $GUI_ENABLE)

	Local $sUDF_List = ""
	Local $aUDF_List = _FileListToArray($sUDF_Folder, "*.au3", 1)
	If Not @error Then
		For $i = 1 To $aUDF_List[0]
			$sUDF_List &= "|" & $aUDF_List[$i]
		Next
	EndIf

	Return $sUDF_List

EndFunc   ;==>_List_UDFs

Func _Browse($sInclude_Folders, $aGUI_Control)

	Local $sSelection = FileSelectFolder("Select include folder", "")
	If Not @error Then
		If StringRight($sSelection, 1) <> "\" Then
			$sSelection &= "\"
		EndIf
		$sInclude_Folders &= "|" & $sSelection
		GUICtrlSetData($aGUI_Control[10], "")
		GUICtrlSetData($aGUI_Control[10], $sInclude_Folders, $sSelection)
		GUICtrlSetData($aGUI_Control[11], "")
		GUICtrlSetData($aGUI_Control[11], _List_UDFs($sSelection, $aGUI_Control))
	EndIf

EndFunc   ;==>_Browse

#EndRegion ; File management Functions
#Region ; Parse functions

Func _Parse_UDF($aGUI_Control, $aStandardUDF, $aSciTECallTip, ByRef $aCallTip, ByRef $fStandardFolder, ByRef $fStandardUDF, ByRef $fChange)

	Local $fExit = False, $aUDF_Array

	Local $sUDF_Folder = GUICtrlRead($aGUI_Control[10])
	Local $sUDF_Name = GUICtrlRead($aGUI_Control[11])
	If StringInStr($sUDF_Name, ".au3") = 0 Then Return

	$fStandardUDF = False
	If $fStandardFolder Then
		_ArraySearch($aStandardUDF, GUICtrlRead($aGUI_Control[11]), 1)
		If Not @error Then
			$fStandardUDF = True
		EndIf
	EndIf

	GUICtrlSetState($aGUI_Control[2], $GUI_DISABLE)
	GUICtrlSetState($aGUI_Control[7], $GUI_DISABLE)

	Local $aUDF_Split = StringSplit($sUDF_Name, "\")
	_FileReadToArray($sUDF_Folder & $sUDF_Name, $aUDF_Array)

	If $fStandardUDF Then
		$fExit = _Standard_Parse($aGUI_Control, $aUDF_Array, $aSciTECallTip)
	Else
		If BitAND(GUICtrlRead($aGUI_Control[0]), $GUI_CHECKED) = $GUI_CHECKED Then
			GUICtrlSetData($aGUI_Control[15], "The function description can be amended if required:")
			$fExit = _Header_Parse($aGUI_Control, $aCallTip, $aUDF_Array, $aUDF_Split, $fChange)
		Else
			GUICtrlSetData($aGUI_Control[15], "Insert a function description:")
			$fExit = _Direct_Parse($aGUI_Control, $aCallTip, $aUDF_Array, $aUDF_Split, $fChange)
		EndIf
	EndIf

	If Not $fExit Then
		Local $sMsg = "Please select another UDF"
		If $fChange Then
			$sMsg &= ", Save changes or Exit"
		Else
			$sMsg &= " or Exit"
		EndIf
		MsgBox($MB_OK + $MB_SYSTEMMODAL, "Parsing Complete", $sMsg)
		GUICtrlSetState($aGUI_Control[2], $GUI_ENABLE)
		GUICtrlSetState($aGUI_Control[7], $GUI_ENABLE)
	EndIf

	Return $fExit

EndFunc   ;==>_Parse_UDF

Func _Standard_Parse($aGUI_Control, $aUDF_Array, $aSciTECallTip)

	Local $fExit = False
	Local $sFuncLine, $sUDF_Title, $iIndex, $sUDF_Line, $sUDF_Syntax, $sUDF_Descrip

	; Warn about read only
	MsgBox(48 + $MB_SYSTEMMODAL, "Warning", "This is a core AutoIt UDF and" & @CRLF & "the CallTips are read only")

	; Set control state
	GUICtrlSetState($aGUI_Control[14], $GUI_ENABLE)
	GUICtrlSetState($aGUI_Control[15], $GUI_ENABLE)
	GUICtrlSetData($aGUI_Control[14], "The function syntax:")
	GUICtrlSetData($aGUI_Control[15], "The function description:")
	GUICtrlSetState($aGUI_Control[5], $GUI_ENABLE)
	GUICtrlSetState($aGUI_Control[6], $GUI_ENABLE)

	; Move through file checking for functions
	For $i = 1 To $aUDF_Array[0]

		; Read line
		$sUDF_Line = $aUDF_Array[$i]
		; If first line of header
		If StringLeft($sUDF_Line, 12) == "; #FUNCTION#" Then
			; Extract Function name
			Do
				$i += 1
			Until StringLeft($aUDF_Array[$i], 4) = "Func"
			$sFuncLine = $aUDF_Array[$i]
			$sUDF_Title = StringRegExpReplace($sFuncLine, "(?i)^(.*)?func(\s)+(.*)\(.*$", "$3")
			; Find function in api file
			$iIndex = _ArraySearch($aSciTECallTip, $sUDF_Title & " (", 1, 0, 0, 1)
			If Not @error Then
				$sFuncLine = $aSciTECallTip[$iIndex]
				; Extract syntax and description
				$sUDF_Syntax = StringRegExpReplace($sFuncLine, "(?i)(?U)^(.*\)).*$", "$1")
				$sUDF_Descrip = StringRegExpReplace($sFuncLine, "(?i)(?U)^.*\)(\s)+(.*)(\s)+\(.*$", "$2")
				; Place Syntax and Description in edit boxes
				GUICtrlSetData($aGUI_Control[12], $sUDF_Syntax)
				GUICtrlSetData($aGUI_Control[13], $sUDF_Descrip)
				While 1
					Switch GUIGetMsg()
						Case $GUI_EVENT_CLOSE, $aGUI_Control[8]
							$fExit = True
							ExitLoop 2
						Case $aGUI_Control[6]
							ExitLoop 2
						Case $aGUI_Control[5]
							ExitLoop
					EndSwitch
				WEnd
			EndIf
		EndIf

		; Reset for next function
		$sUDF_Syntax = ""
		$sUDF_Descrip = ""
		GUICtrlSetData($aGUI_Control[12], "")
		GUICtrlSetData($aGUI_Control[13], "")

	Next
	; Reset for next UDF
	$sUDF_Syntax = ""
	$sUDF_Descrip = ""
	GUICtrlSetState($aGUI_Control[14], $GUI_DISABLE)
	GUICtrlSetState($aGUI_Control[15], $GUI_DISABLE)
	GUICtrlSetState($aGUI_Control[5], $GUI_DISABLE)
	GUICtrlSetState($aGUI_Control[6], $GUI_DISABLE)
	GUICtrlSetData($aGUI_Control[12], "")
	GUICtrlSetData($aGUI_Control[13], "")

	Return $fExit

EndFunc   ;==>_Standard_Parse

Func _Header_Parse($aGUI_Control, ByRef $aCallTip, $aUDF_Array, $aUDF_Split, ByRef $fChange)

	Local $fExit = False, $sUDF_Line, $sUDF_Syntax, $sUDF_Descrip, $sUDF_Title

	; Set control state
	GUICtrlSetState($aGUI_Control[13], $GUI_ENABLE)
	GUICtrlSetState($aGUI_Control[14], $GUI_ENABLE)
	GUICtrlSetState($aGUI_Control[15], $GUI_ENABLE)
	GUICtrlSetState($aGUI_Control[3], $GUI_ENABLE)
	GUICtrlSetState($aGUI_Control[4], $GUI_ENABLE)
	GUICtrlSetState($aGUI_Control[5], $GUI_ENABLE)
	GUICtrlSetState($aGUI_Control[6], $GUI_ENABLE)

	; Move through file checking for functions
	For $i = 1 To $aUDF_Array[0]

		; Read line
		$sUDF_Line = $aUDF_Array[$i]
		; If first line of header
		If StringLeft($sUDF_Line, 12) == "; #FUNCTION#" Then
			; Loop through header
			For $j = $i + 1 To $aUDF_Array[0]
				$sUDF_Line = $aUDF_Array[$j]
				; Read syntax line
				If StringLeft($sUDF_Line, 8) == "; Syntax" Then
					$sUDF_Syntax = StringRegExpReplace($sUDF_Line, "(?U)^.*:\s+(.*\))(.*)?$", "$1")
				EndIf
				; Read description line
				If StringLeft($sUDF_Line, 13) == "; Description" Then
					$sUDF_Descrip = StringRegExpReplace($sUDF_Line, "(?U)^.*:\s+(.*)(\..*)?$", "$1.")
					GUICtrlSetData($aGUI_Control[15], "The function description can now be amended:")
				EndIf
				; If both lines read or end of header
				If ($sUDF_Syntax And $sUDF_Descrip) Or StringLeft(StringStripWS($sUDF_Line, 1), 4) = "Func" Then
					ExitLoop
				EndIf
			Next
			; If syntax value not set
			If $sUDF_Syntax = "" Then
				Do
					$i += 1
				Until StringLeft(StringStripWS($aUDF_Array[$i], 1), 4) = "Func"
				$sUDF_Syntax = StringRegExpReplace($aUDF_Array[$i], "(?i)^.*func\s++(.*)$", "$1")
				$sUDF_Title = StringRegExpReplace($sUDF_Syntax, "(?i)^(.*)\s++\(.*$", "$1")
				GUICtrlSetData($aGUI_Control[15], "Insert a function description:")
			EndIf
			; Place values in edit boxes
			GUICtrlSetData($aGUI_Control[12], $sUDF_Syntax)
			GUICtrlSetData($aGUI_Control[13], $sUDF_Descrip)
			; Extract Function name
			$sUDF_Title = StringRegExpReplace($sUDF_Syntax, "(?i)^(.*)\s++\(.*$", "$1")

			While 1
				Switch GUIGetMsg()
					Case $GUI_EVENT_CLOSE, $aGUI_Control[8]
						$fExit = True
						ExitLoop 2
					Case $aGUI_Control[6]
						ExitLoop 2
					Case $aGUI_Control[3]
						; Create CallTip
						$sUDF_Descrip = GUICtrlRead($aGUI_Control[13])
						; Force trailing .
						If StringRight($sUDF_Descrip, 1) <> "." Then
							$sUDF_Descrip &= "."
						EndIf
						Local $sUDF_Text = $sUDF_Syntax & " " & $sUDF_Descrip & " (Requires: #include <" & $aUDF_Split[$aUDF_Split[0]] & ">)"
						_Write_CallTip($aCallTip, $sUDF_Title, $sUDF_Text)
						; Set change flag
						$fChange = True
						GUICtrlSetState($aGUI_Control[9], $GUI_ENABLE)
						ExitLoop
					Case $aGUI_Control[4]
						If _Delete_CallTip($aCallTip, $sUDF_Title) Then
							; Set change flag
							$fChange = True
							GUICtrlSetState($aGUI_Control[9], $GUI_ENABLE)
						EndIf
						ExitLoop
					Case $aGUI_Control[5]
						ExitLoop
				EndSwitch
			WEnd

			; Reset values for next function
			$sUDF_Syntax = ""
			$sUDF_Descrip = ""
			GUICtrlSetData($aGUI_Control[12], "")
			GUICtrlSetData($aGUI_Control[13], "")

		EndIf

	Next

	; Reset for next UDF
	$sUDF_Syntax = ""
	$sUDF_Descrip = ""
	GUICtrlSetState($aGUI_Control[13], $GUI_DISABLE)
	GUICtrlSetState($aGUI_Control[14], $GUI_DISABLE)
	GUICtrlSetState($aGUI_Control[15], $GUI_DISABLE)
	GUICtrlSetState($aGUI_Control[3], $GUI_DISABLE)
	GUICtrlSetState($aGUI_Control[4], $GUI_DISABLE)
	GUICtrlSetState($aGUI_Control[5], $GUI_DISABLE)
	GUICtrlSetState($aGUI_Control[6], $GUI_DISABLE)
	GUICtrlSetData($aGUI_Control[12], "")
	GUICtrlSetData($aGUI_Control[13], "")
	GUICtrlSetData($aGUI_Control[15], "The function description:")

	Return $fExit

EndFunc   ;==>_Header_Parse

Func _Direct_Parse($aGUI_Control, ByRef $aCallTip, $aUDF_Array, $aUDF_Split, ByRef $fChange)

	Local $fExit = False, $sUDF_Line, $sUDF_Syntax, $sUDF_Descrip, $sUDF_Title

	GUICtrlSetState($aGUI_Control[13], $GUI_ENABLE)
	GUICtrlSetState($aGUI_Control[14], $GUI_ENABLE)
	GUICtrlSetState($aGUI_Control[15], $GUI_ENABLE)
	GUICtrlSetState($aGUI_Control[3], $GUI_ENABLE)
	GUICtrlSetState($aGUI_Control[4], $GUI_ENABLE)
	GUICtrlSetState($aGUI_Control[5], $GUI_ENABLE)
	GUICtrlSetState($aGUI_Control[6], $GUI_ENABLE)
	GUICtrlSetData($aGUI_Control[15], "Insert a function description:")

	; Move through file checking for functions
	For $i = 1 To $aUDF_Array[0]

		; Read line
		$sUDF_Line = $aUDF_Array[$i]
		; If Func statement
		If StringLeft($sUDF_Line, 5) = "Func " Then

			$sUDF_Syntax = StringTrimLeft($sUDF_Line, 5)
			; Place Syntax in edit box
			GUICtrlSetData($aGUI_Control[12], $sUDF_Syntax)

			; Extract Function name
			$sUDF_Title = StringLeft($sUDF_Syntax, StringInStr($sUDF_Syntax, "(") - 1)

			; Set focus to Description editbox
			GUICtrlSetState($aGUI_Control[13], $GUI_FOCUS)

			While 1

				Switch GUIGetMsg()
					Case $GUI_EVENT_CLOSE, $aGUI_Control[8]
						$fExit = True
						ExitLoop 2
					Case $aGUI_Control[6]
						ExitLoop 2
					Case $aGUI_Control[3]
						; Create CallTip
						$sUDF_Descrip = GUICtrlRead($aGUI_Control[13])
						Local $sUDF_Text = $sUDF_Syntax & " " & $sUDF_Descrip & " (Requires: #Include <" & $aUDF_Split[$aUDF_Split[0]] & ">)"
						_Write_CallTip($aCallTip, $sUDF_Title, $sUDF_Text)
						; Set change flag
						$fChange = True
						GUICtrlSetState($aGUI_Control[9], $GUI_ENABLE)
						ExitLoop
					Case $aGUI_Control[4]
						If _Delete_CallTip($aCallTip, $sUDF_Title) Then
							; Set change flag
							$fChange = True
							GUICtrlSetState($aGUI_Control[9], $GUI_ENABLE)
						EndIf
						ExitLoop
					Case $aGUI_Control[5]
						ExitLoop
				EndSwitch

			WEnd

			; Reset for next function
			$sUDF_Syntax = ""
			$sUDF_Descrip = ""
			GUICtrlSetData($aGUI_Control[12], "")
			GUICtrlSetData($aGUI_Control[13], "")

		EndIf

	Next

	; Reset for next UDF
	$sUDF_Syntax = ""
	$sUDF_Descrip = ""
	GUICtrlSetState($aGUI_Control[13], $GUI_DISABLE)
	GUICtrlSetState($aGUI_Control[14], $GUI_DISABLE)
	GUICtrlSetState($aGUI_Control[15], $GUI_DISABLE)
	GUICtrlSetState($aGUI_Control[3], $GUI_DISABLE)
	GUICtrlSetState($aGUI_Control[4], $GUI_DISABLE)
	GUICtrlSetState($aGUI_Control[5], $GUI_DISABLE)
	GUICtrlSetState($aGUI_Control[6], $GUI_DISABLE)
	GUICtrlSetData($aGUI_Control[12], "")
	GUICtrlSetData($aGUI_Control[13], "")
	GUICtrlSetData($aGUI_Control[15], "The function description:")

	Return $fExit

EndFunc   ;==>_Direct_Parse

#EndRegion ; Parse functions
#Region ; Exit Function

Func _Save_Exit_UCT($hMain_GUI, $aCallTip, $sCallTipPath, $sKeyWordPath, $sUserPath)

	Local $aSplit

	; Save backups and write changed files

	; Calltip file
	FileMove($sCallTipPath, $sCallTipPath & ".bak", 1)
	_FileWriteFromArray($sCallTipPath, $aCallTip, 1)
	; Keyword file
	FileCopy($sKeyWordPath, $sKeyWordPath & ".bak", 1)
	Local $sUser_KeyWord = ""
	Local $sLine = "au3.keywords.user.udfs="
	For $i = 1 To $aCallTip[0]
		$aSplit = StringSplit($aCallTip[$i], "(")
		If Not @error Then
			$sLine &= StringLower($aSplit[1])
			If $i = $aCallTip[0] Then
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
	Local $cFile = FileOpen($sKeyWordPath, 2)
	FileWrite($cFile, $sUser_KeyWord)
	FileClose($cFile)

	; Backup file
	FileMove($sUserPath, $sUserPath & ".bak", 1)
	_FileWriteFromArray($sUserPath, $aCallTip, 1)

	_SciTE_ReloadProps($hMain_GUI)

	Return

EndFunc   ;==>_Save_Exit_UCT

#EndRegion ; Exit Function
#Region ; Add & Delete CallTip Functions

Func _Write_CallTip(ByRef $aCallTip, $sUDF_Title, $sUDF_Text)

	; Look for Function name in existing file
	Local $iCallTip_Line = -1
	For $i = 1 To $aCallTip[0]
		If StringLeft($aCallTip[$i], StringLen($sUDF_Title)) = $sUDF_Title Then
			$iCallTip_Line = $i
			ExitLoop
		EndIf
	Next
	If $iCallTip_Line = -1 Then
		; If not found then add
		_ArrayAdd($aCallTip, $sUDF_Text)
		$aCallTip[0] += 1
	Else
		; Ask if should replace
		If MsgBox($MB_YESNO + $MB_ICONQUESTION + $MB_SYSTEMMODAL, "Replace?", "Function CallTip already exists" & @CRLF & @CRLF & _
				"Replace the existing version?") = 6 Then
			; Replace if required
			$aCallTip[$iCallTip_Line] = $sUDF_Text
		EndIf
	EndIf

EndFunc   ;==>_Write_CallTip

Func _Delete_CallTip(ByRef $aCallTip, $sUDF_Title)

	Local $fChanged = True

	; Look for Function name in existing file
	Local $iCallTip_Line = _ArraySearch($aCallTip, $sUDF_Title, 0, $aCallTip[0], 0, 1)
	If $iCallTip_Line = -1 Then
		; If not found then return
		MsgBox($MB_ICONASTERISK + $MB_SYSTEMMODAL, "Not Found", "Function CallTip does not exist")
		$fChanged = False
	Else
		; Delete CallTip
		_ArrayDelete($aCallTip, $iCallTip_Line)
		$aCallTip[0] -= 1
	EndIf

	Return $fChanged

EndFunc   ;==>_Delete_CallTip

#EndRegion ; Add & Delete CallTip Functions
#Region ; Show, View, Delete Functions

Func _View_Tips($hMain_GUI, $aGUI_Control, ByRef $aCallTip, ByRef $fChange)

	Local $aMsg, $iGUI_Size = @DesktopHeight - 200
	If $iGUI_Size > 600 Then
		$iGUI_Size = 600
	EndIf

	; Create List GUI
	Local $hList_GUI = GUICreate("SciTE User CallTip List", 800, $iGUI_Size, -1, -1, Default, Default, $hMain_GUI)
	GUISetBkColor(0xCECECE)

	; Create buttons
	Local $cDelete_Button = GUICtrlCreateButton("Delete", 310, $iGUI_Size - 40, 80, 30)
	Local $cClose_Button = GUICtrlCreateButton("Close", 410, $iGUI_Size - 40, 80, 30)

	; Create a tip list
	$gCTM_cListView = GUICtrlCreateListView(" | ", 15, 10, 770, $iGUI_Size - 60, $LVS_NOCOLUMNHEADER + $LVS_SINGLESEL, $LVS_EX_FULLROWSELECT)
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_LV_ALTERNATE)
	GUICtrlSetBkColor(-1, 0xE0FFFF)
	_GUICtrlListView_SetColumnWidth(-1, 0, 375)
	_GUICtrlListView_SetColumnWidth(-1, 1, 375)

	_Fill_List($gCTM_cListView, $aCallTip)

	; Create a dummy for ListView doubleclick
	$gCTM_cDblClick = GUICtrlCreateDummy()

	GUISetState(@SW_SHOW, $hList_GUI)

	; Look for DblClick on ListView
	GUIRegisterMsg($WM_NOTIFY, "_WM_NOTIFY")

	While 1
		$aMsg = GUIGetMsg(1)
		Switch $aMsg[1]
			Case $hList_GUI
				Switch $aMsg[0]
					Case $GUI_EVENT_CLOSE, $cClose_Button
						; Clear message
						GUIRegisterMsg($WM_NOTIFY, "")
						GUIDelete($hList_GUI)
						$gCTM_cListView = 9999
						$gCTM_cDblClick = 9999
						Return
					Case $cDelete_Button
						_Del_Tip($aGUI_Control, $aCallTip, $gCTM_cListView, Number(_GUICtrlListView_GetSelectedIndices($gCTM_cListView)), $fChange)
					Case $gCTM_cDblClick
						_Show_Tip($gCTM_cListView, Number(_GUICtrlListView_GetSelectedIndices($gCTM_cListView)), $hList_GUI)
				EndSwitch
		EndSwitch
	WEnd

EndFunc   ;==>_View_Tips

Func _Show_Tip($gCTM_cListView, $iIndex, $hList_GUI)

	Local $aMsg

	; Size CallTip parts
	Local $sLine1 = _GUICtrlListView_GetItemText($gCTM_cListView, $iIndex, 0)
	Local $aLine1 = _StringSize($sLine1, 9, Default, Default, "Courier New")
	Local $sLine2 = _GUICtrlListView_GetItemText($gCTM_cListView, $iIndex, 1)
	Local $aLine2 = _StringSize($sLine2, 9, Default, Default, "Courier New")
	Local $iLine_Width = $aLine1[2]
	If $aLine2[2] > $aLine1[2] Then $iLine_Width = $aLine2[2]

	; Create GUI
	Local $hShow_GUI = GUICreate("Show CallTip", $iLine_Width + 20, 110, -1, -1, Default, Default, $hList_GUI)

	GUICtrlCreateLabel($sLine1 & @CRLF & @CRLF & $sLine2, 10, 10, $iLine_Width, 60)
	GUICtrlSetFont(-1, 9, Default, Default, "Courier New")
	Local $cShut_Button = GUICtrlCreateButton("Close", ($iLine_Width - 60) / 2, 70, 80, 30)

	GUISetState(@SW_SHOW, $hShow_GUI)

	While 1
		$aMsg = GUIGetMsg(1)
		Switch $aMsg[1]
			Case $hShow_GUI
				Switch $aMsg[0]
					Case $GUI_EVENT_CLOSE, $cShut_Button
						GUIDelete($hShow_GUI)
						Return
				EndSwitch
		EndSwitch
	WEnd

EndFunc   ;==>_Show_Tip

Func _Del_Tip($aGUI_Control, ByRef $aCallTip, $gCTM_cListView, $iIndex, ByRef $fChange)

	Local $sText = _GUICtrlListView_GetItemText($gCTM_cListView, $iIndex)
	Local $aSplit = StringSplit($sText, "(")
	If Not @error Then
		If MsgBox($MB_YESNO + $MB_ICONQUESTION + $MB_SYSTEMMODAL, "Query", "Are you sure you want to delete the CallTip for" & @CRLF & @CRLF & $aSplit[1]) = 6 Then
			_ArrayDelete($aCallTip, $iIndex + 1)
			$aCallTip[0] -= 1
			$fChange = True
			GUICtrlSetState($aGUI_Control[9], $GUI_ENABLE)
			_Fill_List($gCTM_cListView, $aCallTip)
		EndIf
	EndIf

EndFunc   ;==>_Del_Tip

Func _Fill_List($gCTM_cListView, $aCallTip)

	Local $aSplit_Tip
	_GUICtrlListView_DeleteAllItems($gCTM_cListView)
	_GUICtrlListView_BeginUpdate($gCTM_cListView)
	For $i = 1 To $aCallTip[0]
		If $aCallTip[$i] <> "" Then
			GUICtrlCreateListViewItem(' | ', $gCTM_cListView)
			GUICtrlSetBkColor(-1, 0xCCFFCC)
			$aSplit_Tip = StringSplit($aCallTip[$i], ") ", 1)
			_GUICtrlListView_SetItemText($gCTM_cListView, $i - 1, $aSplit_Tip[1] & ")", 0)
			If $aSplit_Tip[0] >= 2 Then
				_GUICtrlListView_SetItemText($gCTM_cListView, $i - 1, $aSplit_Tip[2], 1)
			EndIf
		EndIf
	Next
	_GUICtrlListView_EndUpdate($gCTM_cListView)

EndFunc   ;==>_Fill_List

#EndRegion ; Show, View, Delete Functions
#Region ; Message handler and SciTE reload properties

Func _WM_NOTIFY($hWnd, $iMsg, $wParam, $lParam)

	#forceref $hWnd, $iMsg

	Local $tStruct, $iCode

	Switch $wParam
		Case $gCTM_cListView
			$tStruct = DllStructCreate("struct;hwnd;uint_ptr;int_ptr;int;int;endstruct", $lParam)
			If @error Then Return
			$iCode = DllStructGetData($tStruct, 3)
			Switch $iCode
				Case $NM_DBLCLK
					GUICtrlSendToDummy($gCTM_cDblClick, DllStructGetData($tStruct, 4))
			EndSwitch
	EndSwitch

EndFunc   ;==>_WM_NOTIFY

#EndRegion ; Message handler and SciTE reload properties
