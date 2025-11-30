#include-once

; #INDEX# ============================================================================================================
; Title .........: GUIExtender
; AutoIt Version : v3.3 or higher
; Language ......: English
; Description ...: Extends and retracts user-defined sections of a GUI either vertically or horizontally
; Remarks .......:
; Note ..........:
; Author(s) .....: Melba23
; ====================================================================================================================

;#AutoIt3Wrapper_au3check_parameters=-d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6 -w 7

; #GLOBAL VARIABLES# =================================================================================================
; Declare array to hold section data
Global $aGUIExt_Section_Data[1][9] = [[0, 0, 1, 0, "", 9999]]
; [0][0] = Section count                                            [n][0] = Initial section X/Y-coord
; [0][1] = Orientation - 0 = Vertical, 1 = Horizontal               [n][1] = Section height/width (inc border)
; [0][2] = All state - 0 = all retracted, 1 = at least 1 extended   [n][2] = Section state - 0 = Retracted, 1 = extended, 2 = static
; [0][3] = GUI handle                                               [n][3] = Section anchor ControlID (invisible disabled label)
; [0][4] = Fixed point - 0 = Left/Top, 1 = Centre, 2 = Right/Bottom [n][4] = Section final ControlID
; [0][5] = Action all button ControlID                              [n][5] = Section action button ControlID
; [0][6] = Action all button extended text                          [n][6] = Section action button extended text
; [0][7] = Action all button retracted text                         [n][7] = Section action button retracted text
; [0][8] = Action all button type                                   [n][8] = Section action button type

; Declare array to hold data about embedded objects
Global $aGUIExt_Obj_Data[1][2] = [[0]]
; [0][0] = Object count
; [n][0] = Embedded object ControlID
; [n][1] = Original object handle

; Declare flag for section action
Global $fGUIExt_SectionAction = False

; #CURRENT# ==========================================================================================================
; _GUIExtender_Init:           Initialises the GUI containing the sections and sets orientation and fixed point
; _GUIExtender_Section_Start:  Marks the start point of GUI section
; _GUIExtender_Section_End:    Marks the end of a GUI section
; _GUIExtender_Section_Action: Creates normal or push buttons to action extension or retraction of GUI sections
; _GUIExtender_Action:         Used in GUIGetMsg loops to detect clicks on section action buttons
; _GUIExtender_Restore:        Used reset GUI after a MINIMIZE and RESTORE
; _GUIExtender_Section_Extend: Actions section extension or retraction programatically or via section action buttons
; _GUIExtender_Section_State:  Returns state of section
; _GUIExtender_UDFCtrlCheck:   Hides/Shows and moves UDF-created controls when sections are extended/retracted
; _GUIExtender_ActionCheck:    Indicates when sections are extended/retracted so that _GUIExtender_UDFCtrlCheck can be called
; _GUIExtender_Obj_Data:       Store additional info on embedded objects
; _GUIExtender_Clear:          Called on GUI deletion to clear the data array ready for a new GUI to be initialised
; ====================================================================================================================

; #INTERNAL_USE_ONLY#=================================================================================================
; _GUIExtender_Section_All_Extend:   Actions all moveable sections
; _GUIExtender_Section_Action_Event: Used to detect clicks on section action buttons in OnEvent mode
; ====================================================================================================================

; #FUNCTION# =========================================================================================================
; Name...........: _GUIExtender_Init
; Description ...: Initialises the GUI containing the sections and sets orientation and fixed point
; Syntax.........: _GUIExtender_Init($hWnd[, $iOrient = 0[, $iFixed = 0]])
; Parameters ....: $hWnd - Handle of GUI containing the sections
;                  $iOrient - 0 = Vert - GUI extends and retracts in vertical sense
;                             1 = Horz - GUI extends and retracts in horizontal sense
;                  $iFixed  - 0 = GUI Left/Top fixed (Default)
;                             1 = GUI centre fixed
;                             2 = GUI Right/Bottom fixed
; Requirement(s).: v3.3 +
; Return values .: Success:  Returns 1
;                  Failure:  Returns 0 and sets @error as follows:
;                  1 = Invalid handle
;                  2 = Existing initialisation
;                  3 = Invalid parameter with @extended set: 1 = $iOrient, 2 $iFixed
; Author ........: Melba23
; Remarks .......: This function should be called before any controls are created within the GUI
;                  Only one GUI can be initialised at any one time.  _GUIExtender_Clear must be called before a second
;                  GUI can be initialised.  The previous GUI loses all extension/retraction ability
; Example........: Yes
;=====================================================================================================================
Func _GUIExtender_Init($hWnd, $iOrient = 0, $iFixed = 0)

	; Check valid handle
	If Not IsHWnd($hWnd) Then Return SetError(1, 0, 0)

	; Check for existing initialisation
	If $aGUIExt_Section_Data[0][3] Then Return SetError(2, 0, 0)

	; Check for valid parameters
	Switch $iOrient
		Case 0, 1
			; Valid
		Case Else
			Return SetError(3, 1, 0)
	EndSwitch
	Switch $iFixed
		Case 0, 1, 2
			; Valid
		Case Else
			Return SetError(3, 2, 0)
	EndSwitch

	; Store GUI handle
	$aGUIExt_Section_Data[0][3] = $hWnd
	; Store orientation
	$aGUIExt_Section_Data[0][1] = $iOrient
	; Store fixed point
	$aGUIExt_Section_Data[0][4] = $iFixed
	; Set resizing mode to prevent resizing of controls
	Opt("GUIResizeMode", $GUI_DOCKALL)
	; Set automatic restore function for OnEvent mode scripts
	GUISetOnEvent($GUI_EVENT_RESTORE, "_GUIExtender_Restore")

	Return 1

EndFunc

; #FUNCTION# =========================================================================================================
; Name...........: _GUIExtender_Section_Start
; Description ...: Marks the start point of GUI section
; Syntax.........: _GUIExtender_Section_Start($iSection_Coord, $iSection_Size)
; Parameters ....: $iSection_Coord - Coordinates of left/top edge of section depending on orientation
;                  $iSection_Size  - Width/Height of section
; Requirement(s).: v3.3 +
; Return values .: Success:  Returns section ID
;                  Failure:  Returns 0 and sets @error as follows:
;                  1 = Section overlaps with previous section
; Author ........: Melba23
; Remarks .......: The function creates a disabled label to act as an anchor for the section position
;                  The function must be called BEFORE any controls in the section have been cretaed
; Example........: Yes
;=====================================================================================================================
Func _GUIExtender_Section_Start($iSection_Coord, $iSection_Size)

	If $aGUIExt_Section_Data[0][0] > 1 Then
		; Check section start is after previous section end
		If $aGUIExt_Section_Data[$aGUIExt_Section_Data[0][0] - 1][0] + $aGUIExt_Section_Data[$aGUIExt_Section_Data[0][0] - 1][1] > $iSection_Coord Then Return SetError(1, 0, 0)
	EndIf
	; Add new section
	$aGUIExt_Section_Data[0][0] += 1
	; ReDim array if required
	If UBound($aGUIExt_Section_Data) < $aGUIExt_Section_Data[0][0] + 1 Then
		ReDim $aGUIExt_Section_Data[$aGUIExt_Section_Data[0][0] + 1][9]
	EndIf
	; Store passed position and size parameters
	$aGUIExt_Section_Data[$aGUIExt_Section_Data[0][0]][0] = $iSection_Coord
	$aGUIExt_Section_Data[$aGUIExt_Section_Data[0][0]][1] = $iSection_Size
	; Set state to static if not already set
	If $aGUIExt_Section_Data[$aGUIExt_Section_Data[0][0]][2] = "" Then $aGUIExt_Section_Data[$aGUIExt_Section_Data[0][0]][2] = 2
	; Create a zero size disabled label to act as an anchor for the section
	If $aGUIExt_Section_Data[0][1] Then ; Depending on orientation
		$aGUIExt_Section_Data[$aGUIExt_Section_Data[0][0]][3] = GUICtrlCreateLabel("", $iSection_Coord, 0, 1, 1)
	Else
		$aGUIExt_Section_Data[$aGUIExt_Section_Data[0][0]][3] = GUICtrlCreateLabel("", 0, $iSection_Coord, 1, 1)
	EndIf
	GUICtrlSetBkColor(-1, -2) ; $GUI_BKCOLOR_TRANSPARENT
	GUICtrlSetState(-1, 128) ; $GUI_DISABLE
	; Set dummy action ControlID if needed
	If $aGUIExt_Section_Data[$aGUIExt_Section_Data[0][0]][5] = "" Then $aGUIExt_Section_Data[$aGUIExt_Section_Data[0][0]][5] = 9999

	; Return section ID
	Return $aGUIExt_Section_Data[0][0]

EndFunc

; #FUNCTION# =========================================================================================================
; Name...........: _GUIExtender_Section_End
; Description ...: Marks the end point of GUI section
; Syntax.........: _GUIExtender_Section_End()
; Parameters ....: None
; Requirement(s).: v3.3 +
; Return values .: None
; Author ........: Melba23
; Remarks .......: The function must be called AFTER all the controls in the section have been created
; Example........: Yes
;=====================================================================================================================
Func _GUIExtender_Section_End()

	; Determine End ControlID for the section
	$aGUIExt_Section_Data[$aGUIExt_Section_Data[0][0]][4] = GUICtrlCreateDummy() - 1

EndFunc

; #FUNCTION# =========================================================================================================
; Name...........: _GUIExtender_Section_Action
; Description ...: Creates controls to action extension or retraction of GUI sections
; Syntax.........: _GUIExtender_Section_Action($iSection[, $sText_Extended = ""[, $sText_Retracted = ""[, $iX = 0[, $iY = 0[, $iW = 0[, $iH = 0[, $iType = 0[, $iEventMode = 0]]]]]]]]])
; Parameters ....: $iSection      - Section to action - 0 = all extendable sections
;                  $sText_Extended - Text on button when section is extended - default: small up/left arrow
;                  $sText_Retracted - Text on button when section is retracted - default: small down/right arrow
;                  $iX - Left side of the button
;                  $iY - Top of the button
;                  $iW - Width of the button
;                  $iH - Height of the button
;                  $iType - Type of button:
;                           0 = pushbutton (default)
;                           1 = normal button
;                  $iEventMode - Set to 1 if using OnEvent mode
;                           In this case, the control is automatically linked to the _GUIExtender_Section_Action_Event function
; Requirement(s).: v3.3 +
; Return values .: Success:  Returns 1
;                  Failure:  Returns 0 and sets @error as follows:
;                  1 = Control not created
; Author ........: Melba23
; Remarks .......: Sections are static unless an action control has been set
;                  Omitting all optional parameters creates a section which can be actioned programmatically
; Example........: Yes
;=====================================================================================================================
Func _GUIExtender_Section_Action($iSection, $sText_Extended = "", $sText_Retracted = "", $iX = 0, $iY = 0, $iW = 1, $iH = 1, $iType = 0, $iEventMode = 0)

	; ReDim array if required
	If $iSection > 1 And UBound($aGUIExt_Section_Data) < $iSection + 1 Then
		ReDim $aGUIExt_Section_Data[$iSection + 1][9]
	EndIf
	; Set state to extended indicating a extendable section
	$aGUIExt_Section_Data[$iSection][2] = 1
	; If default arrows required
	Local $iDef_Arrows = 0
	If $sText_Extended = "" And $sText_Retracted = "" Then
		$iDef_Arrows = 1
		If $aGUIExt_Section_Data[0][1] Then ; Dependiing on orientation
			$sText_Extended = 3
			$sText_Retracted = 4
		Else
			$sText_Extended = 5
			$sText_Retracted = 6
		EndIf
	EndIf
	; What type of button?
	Switch $iType
		; Pushbutton
		Case 0
			; Create normal button
			$aGUIExt_Section_Data[$iSection][5] = GUICtrlCreateButton($sText_Extended, $iX, $iY, $iW, $iH)
		Case Else
			; Create pushbutton
			$aGUIExt_Section_Data[$iSection][5] = GUICtrlCreateCheckBox($sText_Extended, $iX, $iY, $iW, $iH, 0x1000) ; $BS_PUSHLIKE
			; Set button state
			GUICtrlSetState(-1, 1) ; $GUI_CHECKED
	EndSwitch
	; Check for error
	If $aGUIExt_Section_Data[$iSection][5] = 0 Then Return SetError(2, 0, 0)
	; Change font if default arrows required
	If $iDef_Arrows Then GUICtrlSetFont($aGUIExt_Section_Data[$iSection][5], 10, 400, 0, "Webdings")
	; Set event function if required
	If $iEventMode Then GUICtrlSetOnEvent($aGUIExt_Section_Data[$iSection][5], "_GUIExtender_Section_Action_Event")
	; Store required text
	$aGUIExt_Section_Data[$iSection][6] = $sText_Extended
	$aGUIExt_Section_Data[$iSection][7] = $sText_Retracted
	; Store button type
	$aGUIExt_Section_Data[$iSection][8] = $iType

	Return 1

EndFunc

; #FUNCTION# =========================================================================================================
; Name...........: _GUIExtender_Action
; Description ...: Used in GUIGetMsg loops to detect clicks on section action buttons and $GUI_EVENT_RESTORE events
; Syntax.........: _GUIExtender_Action($iMsg)
; Parameters ....: $iMsg - Return from GUIGetMsg
; Requirement(s).: v3.3 +
; Return values .: None
; Author ........: Melba23
; Remarks .......: The return from GUIGetMsg is passed to this function to determine if a section action control was clicked
; Example........: Yes
;=====================================================================================================================
Func _GUIExtender_Action($iMsg)

	; If GUI is restored, run the restore function
	If $iMsg = -5 Then _GUIExtender_Restore() ; $GUI_EVENT_RESTORE
	; Check if an action control has been clicked
	For $i = 0 To $aGUIExt_Section_Data[0][0]
		; If action button clicked
		If $iMsg = $aGUIExt_Section_Data[$i][5] Then
			; Check current state
			Switch $aGUIExt_Section_Data[$i][2]
				Case 0
					_GUIExtender_Section_Extend($i, True)
				Case Else
					_GUIExtender_Section_Extend($i, False)
			EndSwitch
			; Set flag for section action occurring
			$fGUIExt_SectionAction = True
		EndIf
	Next

EndFunc

; #FUNCTION# =========================================================================================================
; Name...........: _GUIExtender_Restore
; Description ...: Used to reset GUI after a MINIMIZE and RESTORE
; Syntax.........: _GUIExtender_Restore()
; Parameters ....: None
; Requirement(s).: v3.3 +
; Return values .: None
; Author ........: Melba23
; Remarks .......: The GUI is not correctly restored after a MINIMIZE if a section is retracted.  This function cycles
;                  the highest extendable section to reset the correct position of the controls
; Example........: Yes
;=====================================================================================================================
Func _GUIExtender_Restore()

	; Hide the GUI to prevent excess flicker
	GUISetState(@SW_HIDE, $aGUIExt_Section_Data[0][3])
	; Look for the highest extendable function
	For $i = UBound($aGUIExt_Section_Data) - 1 To 1 Step -1
		If $aGUIExt_Section_Data[$i][2] <> 2 Then
			; Depending on current state, cycle extendable section
			Switch $aGUIExt_Section_Data[$i][2]
				Case 0
					_GUIExtender_Section_Extend($i)
					_GUIExtender_Section_Extend($i, False)
				Case 1
					_GUIExtender_Section_Extend($i, False)
					_GUIExtender_Section_Extend($i)
			EndSwitch
			ExitLoop
		EndIf
	Next
	; Show GUI again
	GUISetState(@SW_SHOW, $aGUIExt_Section_Data[0][3])

EndFunc

; #FUNCTION# =========================================================================================================
; Name...........: _GUIExtender_Section_Extend
; Description ...: Actions section extension or retraction programatically or via section action buttons
; Syntax.........: _GUIExtender_Section_Extend($iSection[, $fExtend = True[, $iFixed]])
; Parameters ....: $iSection - Section to action - 0 = all moveable sections
;                  $fExtend  - True = extend; False = retract
;                  $iFixed    - 0 = Left/Top fixed
;                               1 = Expand/contract centred
;                               2 = Right/bottom fixed
;                               Any other value = Default as set by _GUIExtender_Init (default)
; Requirement(s).: v3.3 +
; Return values .: Success:  Returns 1
;                  Failure:  Returns 0 and sets @error as follows:
;                  1 = Invalid section ID (@extended: 1 = not in array, 2 = no _Start function used)
;                  2 = Section already in required state
;                  3 = GUI minimized
; Author ........: Melba23
; Remarks .......: This function is called by the UDF when the section action buttons are clicked,
;                  but can also be called programatically
; Example........: Yes
;=====================================================================================================================
Func _GUIExtender_Section_Extend($iSection, $fExtend = True, $iFixed = 9)

	Local $aPos, $iCID, $iDelta_GUI

	; Check GUI is not minimized
	If BitAND(WinGetState($aGUIExt_Section_Data[0][3]), 16) Then Return SetError(3, 0, 0)

	; Check if all sections to be actioned
	If $iSection = 0 Then
		_GUIExtender_Section_All_Extend($fExtend)
		Return 1
	EndIf

	; Check for invalid section (either outside array or no _Start function called)
	If $iSection > UBound($aGUIExt_Section_Data) - 1 Then Return SetError(1, 1, 0)
	If $aGUIExt_Section_Data[$iSection][1] = "" Then Return SetError(1, 2, 0)

	; Check if state already matches demand
	If ($aGUIExt_Section_Data[$iSection][2] = 1 And $fExtend = True) Or ($aGUIExt_Section_Data[$iSection][2] = 0 And $fExtend = False) Then Return SetError(2, 0, 0)

	; Check Move state
	Switch $iFixed
		Case 0, 1, 2
			; Do nothing
		Case Else
			; Set default value
			$iFixed = $aGUIExt_Section_Data[0][4]
	EndSwitch

	; Get current GUI size and set function calculation values
	Local $aGUIPos = WinGetPos($aGUIExt_Section_Data[0][3])
	Local $iGUI_Fixed = $aGUIPos[2]
	Local $iGUI_Adjust = $aGUIPos[3]
	If $aGUIExt_Section_Data[0][1] Then ; If Horz orientation
		$iGUI_Fixed = $aGUIPos[3]
		$iGUI_Adjust = $aGUIPos[2]
	EndIf

	; Determine action required
	If $fExtend Then
		; Change button text
		GUICtrlSetData($aGUIExt_Section_Data[$iSection][5], $aGUIExt_Section_Data[$iSection][6])
		; Force action control state if needed
		If $aGUIExt_Section_Data[$iSection][8] = 1 Then GUICtrlSetState($aGUIExt_Section_Data[$iSection][5], 1) ; $GUI_CHECKED
		; Set section state
		$aGUIExt_Section_Data[$iSection][2] = 1
		; Add size of section being extended
		$iGUI_Adjust += $aGUIExt_Section_Data[$iSection][1]
	Else
		; Change button text
		GUICtrlSetData($aGUIExt_Section_Data[$iSection][5], $aGUIExt_Section_Data[$iSection][7])
		; Force action control state if needed
		If $aGUIExt_Section_Data[$iSection][8] = 1 Then GUICtrlSetState($aGUIExt_Section_Data[$iSection][5], 4) ; $GUI_UNCHECKED
		; Set section state
		$aGUIExt_Section_Data[$iSection][2] = 0
		; Subtract size of section being hidden
		$iGUI_Adjust -= $aGUIExt_Section_Data[$iSection][1]
	EndIf

	; Hide all sections to prevent ghosting when changing GUI size
	For $i = $aGUIExt_Section_Data[1][3] To $aGUIExt_Section_Data[$aGUIExt_Section_Data[0][0]][4]
		;GUICtrlSetState($i, 32) ; $GUI_HIDE
	Next

	; Resize and possibly move GUI
	If $aGUIExt_Section_Data[0][1] Then ; Depending on orientation
		; Calculate change in GUI size
		$iDelta_GUI = $aGUIPos[2] - $iGUI_Adjust
		; Check GUI fixed point
		Switch $iFixed
			Case 0
				WinMove($aGUIExt_Section_Data[0][3], "", Default, Default, $iGUI_Adjust, $iGUI_Fixed)
			Case 1
				WinMove($aGUIExt_Section_Data[0][3], "", $aGUIPos[0] + Int($iDelta_GUI / 2), Default, $iGUI_Adjust, $iGUI_Fixed)
			Case 2
				WinMove($aGUIExt_Section_Data[0][3], "", $aGUIPos[0] + $iDelta_GUI, Default, $iGUI_Adjust, $iGUI_Fixed)
		EndSwitch
	Else
		$iDelta_GUI = $aGUIPos[3] - $iGUI_Adjust
		Switch $iFixed
			Case 0
				WinMove($aGUIExt_Section_Data[0][3], "", Default, Default, $iGUI_Fixed, $iGUI_Adjust)
			Case 1
				WinMove($aGUIExt_Section_Data[0][3], "", Default, $aGUIPos[1] + Int($iDelta_GUI / 2), $iGUI_Fixed, $iGUI_Adjust)
			Case 2
				WinMove($aGUIExt_Section_Data[0][3], "", Default, $aGUIPos[1] + $iDelta_GUI, $iGUI_Fixed, $iGUI_Adjust)
		EndSwitch
	EndIf

	; Initial section position = section 1 start
	Local $iNext_Coord = $aGUIExt_Section_Data[1][0]
	; Move sections to required position
	Local $iAdjust_X = 0, $iAdjust_Y = 0
	For $i = 1 To $aGUIExt_Section_Data[0][0]
		; Is this section visible?
		If $aGUIExt_Section_Data[$i][2] > 0 Then
			; Get current position of section anchor
			$aPos = ControlGetPos($aGUIExt_Section_Data[0][3], "", $aGUIExt_Section_Data[$i][3])
			If $aGUIExt_Section_Data[0][1] Then ; Depending on orientation
				; Determine required change in X position for section controls
				$iAdjust_X = $aPos[0] - $iNext_Coord
				; Determine if controls need to be moved back into the GUI
				If $aPos[1] > $iGUI_Fixed Then $iAdjust_Y = $iGUI_Fixed
			Else
				; Determine required change in Y position for section controls
				$iAdjust_Y = $aPos[1] - $iNext_Coord
				; Determine if controls need to be moved back into the GUI
				If $aPos[0] > $iGUI_Fixed Then $iAdjust_X = $iGUI_Fixed
			EndIf
			; For all controls in this section
			For $j = $aGUIExt_Section_Data[$i][3] To $aGUIExt_Section_Data[$i][4]
				$iCID = $j
				; Adjust the position
				$aPos = ControlGetPos($aGUIExt_Section_Data[0][3], "", $iCID)
				If @error Then
					For $k = 1 To $aGUIExt_Obj_Data[0][0]
						If $aGUIExt_Obj_Data[$k][0] = $j Then
							$aPos = ControlGetPos($aGUIExt_Section_Data[0][3], "", $aGUIExt_Obj_Data[$k][1])
							$iCID = $aGUIExt_Obj_Data[$k][1]
							ExitLoop
						EndIf
					Next
					; If not an object  see if the ControlID returns a handle (an internal tab will not)
					If $iCID = $j And GUICtrlGetHandle($j) = 0 Then $iCID = "Ignore"
				EndIf
				If Not $iCID = "Ignore" Then
					; Move control
					ControlMove($aGUIExt_Section_Data[0][3], "", $iCID, $aPos[0] - $iAdjust_X, $aPos[1] - $iAdjust_Y)
					; And show the control
					GUICtrlSetState($j, 16) ; $GUI_SHOW
				EndIf
			Next
			; Determine start position for next visible section
			$iNext_Coord += $aGUIExt_Section_Data[$i][1]
		Else
			; Get current position of hidden section anchor
			$aPos = ControlGetPos($aGUIExt_Section_Data[0][3], "", $aGUIExt_Section_Data[$i][3])
			; Determine if controls in this section need to be moved outside GUI to prevent possible overlap
			If $aGUIExt_Section_Data[0][1] Then ; Depending on orientation
				If $aPos[1] < $iGUI_Fixed Then
					For $j = $aGUIExt_Section_Data[$i][3] To $aGUIExt_Section_Data[$i][4]
						$iCID = $j
						; Adjust the position
						$aPos = ControlGetPos($aGUIExt_Section_Data[0][3], "", $j)
						If @error Then
							For $k = 1 To $aGUIExt_Obj_Data[0][0]
								If $aGUIExt_Obj_Data[$k][0] = $j Then
									$aPos = ControlGetPos($aGUIExt_Section_Data[0][3], "", $aGUIExt_Obj_Data[$k][1])
									$iCID = $aGUIExt_Obj_Data[$k][1]
									ExitLoop
								EndIf
							Next
							; If not an object  see if the ControlID returns a handle (an internal tab will not)
							If $iCID = $j And GUICtrlGetHandle($j) = 0 Then $iCID = "Ignore"
						EndIf
						If Not $iCID = "Ignore" Then
							; Move control
							ControlMove($aGUIExt_Section_Data[0][3], "", $iCID, $aPos[0], $aPos[1] + $iGUI_Fixed)
						EndIf
					Next
				EndIf
			Else
				If $aPos[0] < $iGUI_Fixed Then
					For $j = $aGUIExt_Section_Data[$i][3] To $aGUIExt_Section_Data[$i][4]
						$iCID = $j
						; Adjust the position
						$aPos = ControlGetPos($aGUIExt_Section_Data[0][3], "", $j)
						If @error Then
							For $k = 1 To $aGUIExt_Obj_Data[0][0]
								If $aGUIExt_Obj_Data[$k][0] = $j Then
									$aPos = ControlGetPos($aGUIExt_Section_Data[0][3], "", $aGUIExt_Obj_Data[$k][1])
									$iCID = $aGUIExt_Obj_Data[$k][1]
									ExitLoop
								EndIf
							Next
							; If not an object  see if the ControlID returns a handle (an internal tab will not)
							If $iCID = $j And GUICtrlGetHandle($j) = 0 Then $iCID = "Ignore"
						EndIf
						If Not $iCID = "Ignore" Then
							; Move control
							ControlMove($aGUIExt_Section_Data[0][3], "", $iCID, $aPos[0] + $iGUI_Fixed, $aPos[1])
						EndIf
					Next
				EndIf
			EndIf
		EndIf
	Next

	; Set correct "all" state if there is a "all" control
	If $aGUIExt_Section_Data[0][5] <> 9999 Then
		Local $iAll_State = 0
		; Check if any sections extended
		For $i = 1 To $aGUIExt_Section_Data[0][0]
			If $aGUIExt_Section_Data[$i][2] = 1 Then
				$iAll_State = 1
				ExitLoop
			EndIf
		Next
		; Sync "all" sections control
		Switch $iAll_State
			; None extended
			Case 0
				; Clear flag
				$aGUIExt_Section_Data[0][2] = 0
				; Set text
				GUICtrlSetData($aGUIExt_Section_Data[0][5], $aGUIExt_Section_Data[0][7])
				; Set state if required
				If $aGUIExt_Section_Data[0][8] = 1 Then GUICtrlSetState($aGUIExt_Section_Data[0][5], 4) ; $GUI_UNCHECKED
			; Some extended
			Case Else
				; Set flag
				$aGUIExt_Section_Data[0][2] = 1
				; Set text
				GUICtrlSetData($aGUIExt_Section_Data[0][5], $aGUIExt_Section_Data[0][6])
				; Set state if required
				If $aGUIExt_Section_Data[0][8] = 1 Then GUICtrlSetState($aGUIExt_Section_Data[0][5], 1) ; $GUI_CHECKED
		EndSwitch
	EndIf

	Return 1

EndFunc

; #FUNCTION# =========================================================================================================
; Name...........: _GUIExtender_Section_State
; Description ...: Returns current state of section
; Syntax.........: _GUIExtender_Section_State($iSection)
; Parameters ....: $iSection - Section to check
; Requirement(s).: v3.3 +
; Return values .: Success: State of section: 0 = Retracted, 1 = Extended, 2 = Static
;                  Failure: Invalid section returns -1 and sets @error to 1
; Author ........: Melba23
; Remarks .......: This allows additional GUI controls to reflect the section state
; Example........: Yes
;=====================================================================================================================
Func _GUIExtender_Section_State($iSection)

	If $iSection > UBound($aGUIExt_Section_Data) - 1 Then Return SetError(1, 0, -1)
	Return $aGUIExt_Section_Data[$iSection][2]

EndFunc

; #FUNCTION# =========================================================================================================
; Name...........: _GUIExtender_UDFCtrlCheck
; Description ...: Hides/Shows and moves UDF-created controls when sections are extended/retracted
; Syntax.........: _GUIExtender_UDFCtrlCheck($hControl_Handle, $iSection, $iX, $iY)
; Parameters ....: $hControl_Handle - Handle of UDF-created control
;                  $iSection        - Section within which control is situated
;                  $iX, $iY         - Coords of control - relative to section not to GUI
; Requirement(s).: v3.3 +
; Return values .: Success:  Returns 1
;                  Failure:  Returns 0 and sets @error as follows:
;                  1 = Invalid handle
;                  2 = Invalid section
;                  3 = Invalid coordinate value
; Author ........: Melba23
; Remarks .......:
; Example........: Yes
;=====================================================================================================================
Func _GUIExtender_UDFCtrlCheck($hCtrl_Handle, $iSection, $iX, $iY)

	Local $iCtrl_Coord

	; Check parameters
	If Not IsHWnd($hCtrl_Handle) Or Not WinExists($hCtrl_Handle) Then Return SetError(1, 0, 0)
	If $iSection > UBound($aGUIExt_Section_Data) - 1 Then Return SetError(2, 0, 0)
	If Not IsInt($iX) Or Not IsInt($iY) Then Return SetError(3, 0, 0)

	; Is the section visible
	Switch _GUIExtender_Section_State($iSection)
		Case 1
			; If section extended then show the control
			ControlShow($aGUIExt_Section_Data[0][3], "", $hCtrl_Handle)
			; Now check required position within the GUI - set intial value depending on orientation
			If $aGUIExt_Section_Data[0][1] = 0 Then
				$iCtrl_Coord = $iY + $aGUIExt_Section_Data[1][0] ; Set to offset withint section
			Else
				$iCtrl_Coord = $iX + $aGUIExt_Section_Data[1][0]
			EndIf
			; Check which earlier sections are extended
			For $i = 1 To $iSection - 1
				If _GUIExtender_Section_State($i) Then
					; Add add their size if extended
					$iCtrl_Coord += $aGUIExt_Section_Data[$i][1]
				EndIf
			Next
			; Now move control depending on orientation
			If $aGUIExt_Section_Data[0][1] = 0 Then
				WinMove($hCtrl_Handle, "", $iX, $iCtrl_Coord)
			Else
				WinMove($hCtrl_Handle, "", $iCtrl_Coord, $iY)
			EndIf
		Case 0
			; If section retracted hide the control
			ControlHide($aGUIExt_Section_Data[0][3], "", $hCtrl_Handle)
	EndSwitch

	; Clear flag for section action
	$fGUIExt_SectionAction = False

	Return 1

EndFunc

; #FUNCTION# =========================================================================================================
; Name...........: _GUIExtender_ActionCheck
; Description ...: Indicates when sections are extended/retracted so that _GUIExtender_UDFCtrlCheck can be called
; Syntax.........: _GUIExtender_ActionCheck()
; Parameters ....: None
; Requirement(s).: v3.3 +
; Return values .: Returns True if sections have been actioned
;                  Returns False after _GUIExtender_UDFCtrlCheck has been used to adjust UDF-created controls
; Author ........: Melba23
; Remarks .......:
; Example........: Yes
;=====================================================================================================================
Func _GUIExtender_ActionCheck()

	Return $fGUIExt_SectionAction

EndFunc

; #FUNCTION# =========================================================================================================
; Name...........: _GUIExtender_Obj_Data
; Description ...: Store additional info on embedded objects
; Syntax.........: _GUIExtender_Obj_Data($iCID, $oObj)
; Parameters ....: $iCID - Returned ControlID from GUICtrlCreateObj
;                  $iObj - Object reference number from initial object creation
; Requirement(s).: v3.3 +
; Return values .: Success:  Returns 1
;                  Failure:  Returns 0 and sets @error to 1
; Author ........: Melba23, DllCall from trancexx
; Remarks .......: This allows embedded objects to be used in the UDF
; Example........: Yes
;=====================================================================================================================
Func _GUIExtender_Obj_Data($iCID, $iObj)

	; Increase array size
	$aGUIExt_Obj_Data[0][0] += 1
	ReDim $aGUIExt_Obj_Data[$aGUIExt_Obj_Data[0][0] + 1][2]
	; Store ControlID
	$aGUIExt_Obj_Data[$aGUIExt_Obj_Data[0][0]][0] = $iCID
	; Determine and store object handle
	Local $aRet = DllCall("oleacc.dll", "int", "WindowFromAccessibleObject", "idispatch", $iObj, "hwnd*", 0)
	If @error Or $aRet[0] Then Return SetError(1, 0, 0)
	$aGUIExt_Obj_Data[$aGUIExt_Obj_Data[0][0]][1] = $aRet[2]

	Return 1

EndFunc

; #FUNCTION# =========================================================================================================
; Name...........: _GUIExtender_Clear
; Description ...: Called on GUI deletion to clear the data array ready for a new GUI to be initialised
; Syntax.........: _GUIExtender_Clear()
; Requirement(s).: v3.3 +
; Author ........: Melba23
; Remarks .......: If the data array is not cleared the array is corrupted during initialisation and the UDF crashes
; Example........: Yes
;=====================================================================================================================
Func _GUIExtender_Clear()

	; Reset data array
	Global $aGUIExt_Section_Data[1][9] = [[0, 0, 1, 0, "", 9999]]

EndFunc

; #INTERNAL_USE_ONLY#============================================================================================================
; Name...........: _GUIExtender_Section_All_Extend
; Description ...: Actions all moveable sections
; Author ........: Melba23
; Modified.......:
; Remarks .......: This function is used internally by _GUIExtender_Section_Extend when all sections are to be moved
; ===============================================================================================================================
Func _GUIExtender_Section_All_Extend($fExtend = True)

	; Set required state for extendable sections
	Local $iState = 0
	If $fExtend Then $iState = 1

	For $i = 1 To $aGUIExt_Section_Data[0][0]
		; Check if section requires change of state
		If $aGUIExt_Section_Data[$i][2] <> 2 And $aGUIExt_Section_Data[$i][2] = Not($iState) Then
			; Extend/Shrink as required
			_GUIExtender_Section_Extend($i, $fExtend)
			; Set section state to match
			$aGUIExt_Section_Data[$i][2] = $iState
			; Set section action control state
			Switch $fExtend
				Case True
					GUICtrlSetData($aGUIExt_Section_Data[$i][5], $aGUIExt_Section_Data[$i][6])
					If $aGUIExt_Section_Data[$i][8] = 1 Then GUICtrlSetState($aGUIExt_Section_Data[$i][5], 1) ; $GUI_CHECKED
				Case False
					GUICtrlSetData($aGUIExt_Section_Data[$i][5], $aGUIExt_Section_Data[$i][7])
					If $aGUIExt_Section_Data[$i][8] = 1 Then GUICtrlSetState($aGUIExt_Section_Data[$i][5], 4) ; $GUI_UNCHECKED
			EndSwitch
		EndIf
	Next

EndFunc

; #INTERNAL_USE_ONLY#============================================================================================================
; Name...........: _GUIExtender_Section_Action_Event
; Description ...: Used to detect clicks on section action buttons in OnEvent mode
; Author ........: Melba23
; Modified.......:
; Remarks .......: This function is called when section action button are clicked in OnEvent mode
; ===============================================================================================================================
Func _GUIExtender_Section_Action_Event()

	_GUIExtender_Action(@GUI_CTRLID)
	If Not IsDeclared("GuiUpdate") Then Local $GuiUpdate
	$GuiUpdate = True

EndFunc