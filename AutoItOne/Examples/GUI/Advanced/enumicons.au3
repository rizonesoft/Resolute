Global $g_FileVersion = "2.1.0.0"

#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.14.3
 Author:         YDY (Lazycat)
 Modified:       Jon, Jpm

 Script Function:
	Show all icons in the given file

#ce ----------------------------------------------------------------------------

#Region ### Version History
#cs ----------------------------------------------------------------------------

 Version History
	2.1.0.0 (2021/12/06)
		Added: Scrollbar and optimisation of by name
	2.0.1.0 (2007/11/14)
		Updated: simplification by Jon
	2.0.0.0 (2007/08/02)
		Updated:  use DllCallback.au3
	1.0.0.0 (2006/06/20)
		Added: Initial version
#ce ----------------------------------------------------------------------------
#EndRegion ### Version History

#include <ButtonConstants.au3>
#include <GUIConstantsEx.au3>
#include <GuiScrollBars.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>

; Setting variables
Global $g_aidIcons[30], $g_aidLabels[30]
Global $g_iStartIndex = 1 ; 63001 ; to skip to last valid page for "name" for testing
Global $g_iPrevIndex = 1 - 30
;~ Global $g_sFilename = @SystemDir & "\imageres.dll" ; Default file is "shell32.dll"
Global $g_sFilename = @SystemDir & "\shell32.dll" ; Default file is "shell32.dll"
Global $g_iOrdinal = -1

Global $g_idPrev

Global $g_iDir = 1, $g_nIcons

_Main()

Func _Main()
	Local $iMsg, $sCurFilename, $sTmpFile

	$g_nIcons = GetIconNumber($g_sFilename)
	; Creating GUI and controls
	Local $hGui = GUICreate("Icon Selector by Ordinal value - v" & $g_FileVersion, 395, 435, @DesktopWidth / 2 - 192, _
			@DesktopHeight / 2 - 235, BitOR($GUI_SS_DEFAULT_GUI, $WS_VSCROLL), $WS_EX_ACCEPTFILES)
	GUICtrlCreateGroup("", 5, 1, 385, 40)
	GUICtrlCreateGroup("", 5, 50, 385, 380)
	Local $idFile = GUICtrlCreateInput($g_sFilename, 12, 15, 325, 16, -1, $WS_EX_STATICEDGE)
	GUICtrlSetState(-1, $GUI_DROPACCEPTED)
	GUICtrlSetTip(-1, "You can drop files from shell here...")
	Local $idFileSel = GUICtrlCreateButton("...", 345, 14, 26, 18)
	$g_idPrev = GUICtrlCreateButton("Previous", 10, 45, 60, 24, $BS_FLAT)
	GUICtrlSetState(-1, $GUI_DISABLE)
	Local $idNext = GUICtrlCreateButton("Next", 75, 45, 60, 24, $BS_FLAT)
	Local $idToggle = GUICtrlCreateButton("by Name", 300, 45, 60, 24, $BS_FLAT)

	; This code build two arrays of ID's of icons and labels for easily update
	Local $iCurIndex
	For $iCntRow = 0 To 4
		For $iCntCol = 0 To 5
			$iCurIndex = $iCntRow * 6 + $iCntCol
			$g_aidIcons[$iCurIndex] = GUICtrlCreateIcon($g_sFilename, $g_iOrdinal * ($iCurIndex + 1), _
					60 * $iCntCol + 25, 70 * $iCntRow + 80)
			$g_aidLabels[$iCurIndex] = GUICtrlCreateLabel($g_iOrdinal * ($iCurIndex + 1), _
					60 * $iCntCol + 11, 70 * $iCntRow + 115, 60, 20, $SS_CENTER)
		Next
	Next

	GUIRegisterMsg($WM_VSCROLL, "WM_VSCROLL")

	GUISetState()
	WM_VSCROLL($hGui, 0, 0, 0)

	While 1
		$iMsg = GUIGetMsg()
		; Code below will check if the file is dropped (or selected)
		$sCurFilename = GUICtrlRead($idFile)
		If $sCurFilename <> $g_sFilename Then
			$g_iOrdinal = -1
			$g_iDir = 1
			$g_iStartIndex = 1
			$g_sFilename = $sCurFilename
			$g_nIcons = GetIconNumber($g_sFilename)
			_GUIUpdate(0)
		EndIf
		; Main "Select" statement that handles other events
		Select
			Case $iMsg = $idFileSel
				$sTmpFile = FileOpenDialog("Select file:", "::{20D04FE0-3AEA-1069-A2D8-08002B30309D}", "Executables & dll's (*.exe;*.dll;*.ocx;*.icl)")
				If @error Then ContinueLoop
				GUICtrlSetData($idFile, $sTmpFile) ; GUI will be updated at next iteration
			Case $iMsg = $g_idPrev
				$g_iDir = -1
				If $g_iOrdinal = -1 And $g_iStartIndex > $g_nIcons Then
					$g_iStartIndex = 31
				Else
					$g_iStartIndex = $g_iPrevIndex + 30
				EndIf
				_GUIUpdate($g_iDir)
			Case $iMsg = $idNext
				$g_iDir = 1
				_GUIUpdate($g_iDir)
			Case $iMsg = $idToggle
				If $g_iOrdinal = -1 Then
					$g_iOrdinal = 1
					GUICtrlSetData($idToggle, "by Ordinal")
					WinSetTitle($hGui, "", "Icon Selector by Name value - v" & $g_FileVersion)
				Else
					$g_iOrdinal = -1
					GUICtrlSetData($idToggle, "by Name")
					WinSetTitle($hGui, "", "Icon Selector by Ordinal value - v" & $g_FileVersion)
					If $g_iStartIndex > $g_nIcons Then $g_iStartIndex = 1
				EndIf
				_GUIUpdate(0)
			Case $iMsg = $GUI_EVENT_CLOSE
				Exit
		EndSelect
	WEnd
EndFunc   ;==>_Main

; Just updates GUI icons, labels and set state of "Previous" button
Func _GUIUpdate($iDir)
	ToolTip("")
	If $g_iOrdinal = 1 Then GUICtrlSetState($g_idPrev, $GUI_DISABLE)
	Local $iCurIndex, $iSet, $iNoIcon, $iIndex
	$g_iStartIndex += $iDir * 30
	If $g_iOrdinal = -1 And $g_iStartIndex > $g_nIcons Then
		$g_iStartIndex -= $iDir * 30 ; stay on current page
	EndIf
	If $g_iStartIndex < 1 Then $g_iStartIndex = 1 ; display first page
	$g_iPrevIndex = $g_iStartIndex - 30

	GUISetCursor(15, $GUI_CURSOR_OVERRIDE) ; wait cursor
	While 1
		$iNoIcon = 0 ; to count number of no icon in the page
		Local $iStartIndex = $g_iStartIndex
		For $iCntRow = 0 To 4
			For $iCntCol = 0 To 5
				$iCurIndex = $iCntRow * 6 + $iCntCol
				$iIndex = $iCurIndex + $iStartIndex
				If ($iIndex >= 2 ^ 16) Or ($iIndex < 1) Then
					$iSet = 0 ; to avoid label invalid display
				Else
					While 1
						$iSet = GUICtrlSetImage($g_aidIcons[$iCurIndex], $g_sFilename, $g_iOrdinal * ($iIndex))
						If $iSet Then ExitLoop
						If $g_iOrdinal = -1 Then ExitLoop
						$iIndex += 1
						$iStartIndex += 1
						If $iIndex >= 2 ^ 16 Then ExitLoop
					WEnd
				EndIf
				If $iSet = 0 Then
					$iNoIcon += 1
					GUICtrlSetData($g_aidLabels[$iCurIndex], "")
				EndIf
				If $g_iOrdinal = -1 Then
					If $iSet Then GUICtrlSetData($g_aidLabels[$iCurIndex], -($iIndex))
				Else
					If ($iIndex >= 2 ^ 16) Then
						$iSet = GUICtrlSetImage($g_aidIcons[$iCurIndex], $g_sFilename, $g_iOrdinal * (2 ^ 16))
						GUICtrlSetData($g_aidLabels[$iCurIndex], "") ; avoid display label
					Else
						GUICtrlSetData($g_aidLabels[$iCurIndex], '"' & ($iIndex) & '"')
					EndIf
				EndIf
			Next
		Next

		$g_iStartIndex = $iStartIndex
		; display a page with defined icon, try next pages
		If $iNoIcon < 30 Then
			If $g_iOrdinal = 1 And $iIndex >= 2 ^ 16 Then
				; no more by name entries
				$g_iStartIndex = 1 - 30
			EndIf
			ExitLoop
		EndIf
		$g_iStartIndex += $iDir * 30

		If $g_iOrdinal = -1 Then
			If $g_iStartIndex > $g_nIcons Then
				$g_iStartIndex -= $iDir * 30 ; stay on the current page
				ExitLoop
			EndIf
		Else
			If $iIndex >= 2 ^ 16 Then
				; to stop searching icons
				$g_iStartIndex = 1 - 30 ; display first page by name
				ExitLoop
			EndIf
		EndIf
	WEnd
	GUISetCursor(2, $GUI_CURSOR_OVERRIDE) ; arrow cursor

	; This is because we don't want negative values
	If $g_iStartIndex = 1 Then
		GUICtrlSetState($g_idPrev, $GUI_DISABLE)
	Else
		If $g_iOrdinal = -1 Then GUICtrlSetState($g_idPrev, $GUI_ENABLE)
	EndIf

EndFunc   ;==>_GUIUpdate

Func WM_VSCROLL($hWnd, $iMsg, $wParam, $lParam)
	#forceref $iMsg, $lParam
	Local $iScrollCode = BitAND($wParam, 0x0000FFFF)
	Local $iMin, $iMax, $iPage, $iPos, $iTrackPos

	; Get all the vertical scroll bar information
	Local $tSCROLLINFO = _GUIScrollBars_GetScrollInfoEx($hWnd, $SB_VERT)
	$iMin = 0
	$iMax = 100
	; no move after click on scrollbar
	$iPage = 0
	; Set middle position
	$iPos = 50
	$iTrackPos = DllStructGetData($tSCROLLINFO, "nTrackPos")

	Switch $iScrollCode
		Case $SB_TOP ; user clicked the HOME keyboard key
			DllStructSetData($tSCROLLINFO, "nPos", $iMin)

		Case $SB_BOTTOM ; user clicked the END keyboard key
			DllStructSetData($tSCROLLINFO, "nPos", $iMax)

		Case $SB_LINEUP ; user clicked the top arrow
			DllStructSetData($tSCROLLINFO, "nPos", $iPos - 1)

		Case $SB_LINEDOWN ; user clicked the bottom arrow
			DllStructSetData($tSCROLLINFO, "nPos", $iPos + 1)

		Case $SB_PAGEUP ; user clicked the scroll bar shaft above the scroll box
			DllStructSetData($tSCROLLINFO, "nPos", $iPos - $iPage)
			If $g_iOrdinal = -1 Then
				_GUIUpdate(-1) ; avoid page prev usage if display by name
			Else
				ToolTip("Due to implementation restriction Prev page cannot be used")
			EndIf

		Case $SB_PAGEDOWN ; user clicked the scroll bar shaft below the scroll box
			DllStructSetData($tSCROLLINFO, "nPos", $iPos + $iPage)
			; trick to have the circular mouse icon during scrolldown with the scrollbar
			; _GUIUpdate(-1) is not enough
			Local $iMouseCoordSav = Opt("MouseCoordMode", 2)
			Local $aMouse = MouseGetPos()
			MouseClick('left', 105, 53, 2, 0)
			MouseMove($aMouse[0], $aMouse[1], 0)
			Opt("MouseCoordMode", $iMouseCoordSav)

		Case $SB_THUMBTRACK ; user dragged the scroll box
			DllStructSetData($tSCROLLINFO, "nPos", $iTrackPos)
	EndSwitch

	; // Set the position
	DllStructSetData($tSCROLLINFO, "fMask", $SIF_POS)
	_GUIScrollBars_SetScrollInfo($hWnd, $SB_VERT, $tSCROLLINFO)

	Return $GUI_RUNDEFMSG
EndFunc   ;==>WM_VSCROLL

Func GetIconNumber($sFilePath)
	Local $aResult = DllCall("shell32.dll", "uint", "ExtractIconExW", "wstr", $sFilePath, "int", -1, "struct*", 0, _
			"struct*", 0, "uint", 0)
	If @error Then Return SetError(@error, @extended, 0)

	Return $aResult[0]
EndFunc   ;==>GetIconNumber
