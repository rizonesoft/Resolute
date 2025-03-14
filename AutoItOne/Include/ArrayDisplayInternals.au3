#include-once

#include "AutoItConstants.au3"
#include "MsgBoxConstants.au3"
#include "StringConstants.au3"

; #INDEX# =======================================================================================================================
; Title .........: Internal UDF Library for AutoIt3 _ArrayDisplay() and _DebugArrayDisplay()
; AutoIt Version : 3.3.16.1
; Description ...: Internal functions for the Array.au3 and Debug.au3
; Author(s) .....: Melba23, jpm, LarsJ, pixelsearch
; ===============================================================================================================================

#Region Global Variables and Constants

; #VARIABLES# ===================================================================================================================
; for use with the notify handler

Global $_g_ArrayDisplay_bUserFunc = False
Global $_g_ArrayDisplay_hListView
Global $_g_ArrayDisplay_iTranspose
Global $_g_ArrayDisplay_iDisplayRow
Global $_g_ArrayDisplay_aArray
Global $_g_ArrayDisplay_iDims
Global $_g_ArrayDisplay_nRows
Global $_g_ArrayDisplay_nCols
Global $_g_ArrayDisplay_iItem_Start
Global $_g_ArrayDisplay_iItem_End
Global $_g_ArrayDisplay_iSubItem_Start
Global $_g_ArrayDisplay_iSubItem_End
Global $_g_ArrayDisplay_aIndex
Global $_g_ArrayDisplay_aIndexes[1]
Global $_g_ArrayDisplay_iSortDir
Global $_g_ArrayDisplay_asHeader
Global $_g_ArrayDisplay_aNumericSort

Global $ARRAYDISPLAY_ROWPREFIX = "#"
Global $ARRAYDISPLAY_NUMERICSORT = "*"
; ===============================================================================================================================

; #CONSTANTS# ===================================================================================================================
Global Const $ARRAYDISPLAY_COLALIGNLEFT = 0 ; (default) Column text alignment - left
Global Const $ARRAYDISPLAY_TRANSPOSE = 1 ; Transposes the array (2D only)
Global Const $ARRAYDISPLAY_COLALIGNRIGHT = 2 ; Column text alignment - right
Global Const $ARRAYDISPLAY_COLALIGNCENTER = 4 ; Column text alignment - center
Global Const $ARRAYDISPLAY_VERBOSE = 8 ; Verbose - display MsgBox on error and splash screens during processing of large arrays
Global Const $ARRAYDISPLAY_NOROW = 64 ; No 'Row' column displayed
Global Const $ARRAYDISPLAY_CHECKERROR = 128 ; return if @error <> 0

Global Const $_ARRAYCONSTANT_tagLVITEM = "struct;uint Mask;int Item;int SubItem;uint State;uint StateMask;ptr Text;int TextMax;int Image;lparam Param;" & _
		"int Indent;int GroupID;uint Columns;ptr pColumns;ptr piColFmt;int iGroup;endstruct"
; ===============================================================================================================================

#EndRegion Global Variables and Constants

#Region Functions list

; #CURRENT# =====================================================================================================================
; ===============================================================================================================================

; #INTERNAL_USE_ONLY# ===========================================================================================================
; __ArrayDisplay_Share
; __ArrayDisplay_SortIndexes
; ___ArrayDisplay_NotifyHandler
; __ArrayDisplay_GetSortColStruct
; __ArrayDisplay_SortArrayStruct
; __ArrayDisplay_Transpose
; __ArrayDisplay_HeaderSetItemFormat
; __ArrayDisplay_GetItemText
; __ArrayDisplay_GetItemTextStringSelected
; __ArrayDisplay_JustifyColumn
; ===============================================================================================================================

#EndRegion Functions list

Func __ArrayDisplay_Share(Const ByRef $aArray, $sTitle = Default, $sArrayRange = Default, $iFlags = Default, $vUser_Separator = Default, $sHeader = Default, $iDesired_Colwidth = Default, $hUser_Function = Default, $bDebug = True, Const $_iScriptLineNumber = @ScriptLineNumber, Const $_iCallerError = @error, Const $_iCallerExtended = @extended)
	Local $sMsgBoxTitle = (($bDebug) ? ("_DebugArrayDisplay") : ("_ArrayDisplay"))

	; to avoid user_function using _DebugAArrayDislay() recursion
	If $_g_ArrayDisplay_bUserFunc Then
		$hUser_Function = Default
		$bDebug = False
	EndIf
	If Not IsKeyword($hUser_Function) = $KEYWORD_DEFAULT Then
		$_g_ArrayDisplay_bUserFunc = True
	EndIf

	; Default values
	If $sTitle = Default Then $sTitle = $sMsgBoxTitle
	If $sArrayRange = Default Then $sArrayRange = ""
	If $iFlags = Default Then $iFlags = 0
	If $vUser_Separator = Default Then $vUser_Separator = ""
	If $sHeader = Default Then $sHeader = ""

	Local $iMin_ColWidth = 55
	Local $iMax_ColWidth = 350
;~  If $iDesired_Colwidth = Default Then ; do not change predefined $iMin_ColWidth, $iMax_ColWidth
	If $iDesired_Colwidth > 0 Then $iMax_ColWidth = $iDesired_Colwidth
	If $iDesired_Colwidth < 0 Then $iMin_ColWidth = -$iDesired_Colwidth
	If $iMax_ColWidth = Default Then $iMax_ColWidth = 350
	If $iMax_ColWidth > 4095 Then $iMax_ColWidth = 4095 ; needed as the structure inside the notify handler is declared as Static
	If $hUser_Function = Default Then $hUser_Function = 0

	; Check for transpose, column align, verbosity and "Row" column visibility
	$_g_ArrayDisplay_iTranspose = BitAND($iFlags, $ARRAYDISPLAY_TRANSPOSE)
	Local $iColAlign = BitAND($iFlags, 6) ; 0 = Left (default); 2 = Right; 4 = Center
	Local $iVerbose = Int(BitAND($iFlags, $ARRAYDISPLAY_VERBOSE))
	$_g_ArrayDisplay_iDisplayRow = Int(BitAND($iFlags, $ARRAYDISPLAY_NOROW) = 0)

	; Set lower button border
	Local $iButtonBorder = (($bDebug) ? (40) : (20))

	#Region Check valid array

	Local $sMsg = "", $iRet = 1
	Local $fTimer = 0
	If IsArray($aArray) Then
		$_g_ArrayDisplay_aArray = $aArray
		$_g_ArrayDisplay_iDims = UBound($_g_ArrayDisplay_aArray, $UBOUND_DIMENSIONS)
		If $_g_ArrayDisplay_iDims = 1 Then $_g_ArrayDisplay_iTranspose = 0
		$_g_ArrayDisplay_nRows = UBound($_g_ArrayDisplay_aArray, $UBOUND_ROWS)
		$_g_ArrayDisplay_nCols = ($_g_ArrayDisplay_iDims = 2) ? UBound($_g_ArrayDisplay_aArray, $UBOUND_COLUMNS) : 1

		; Split custom header on separator
		Dim $_g_ArrayDisplay_aNumericSort[$_g_ArrayDisplay_nCols]

		; Dimension checking
		If $_g_ArrayDisplay_iDims > 2 Then
			$sMsg = "Larger than 2D array passed to function"
			$iRet = 2
		EndIf
		If $_iCallerError Then
			If $bDebug Then
				; Call _DebugReport() if available
				If IsDeclared("__g_sReportCallBack_DebugReport_Debug") Then
					$sMsg = "@@ Debug( " & $_iScriptLineNumber & ") : @error = " & $_iCallerError & " in " & $sMsgBoxTitle & "( '" & $sTitle & "' )"
					Execute('$__g_sReportCallBack_DebugReport_Debug("' & $sMsg & '")')
				EndIf
				$iRet = 3
			ElseIf BitAND($iFlags, $ARRAYDISPLAY_CHECKERROR) Then
				$sMsg = "@error = " & $_iCallerError & " when calling the function"
				If $_iScriptLineNumber > 0 Then $sMsg &= " at line " & $_iScriptLineNumber
				$iRet = 3
			EndIf
		EndIf
	Else
		$sMsg = "No array variable passed to function"
	EndIf
	If $sMsg Then
		If $iVerbose And MsgBox($MB_SYSTEMMODAL + $MB_ICONERROR + $MB_YESNO, _
				$sMsgBoxTitle & "() Error: " & $sTitle, $sMsg & @CRLF & @CRLF & "Exit the script?") = $IDYES Then
			Exit
		Else
			Return SetError($iRet, 0, 0)
		EndIf
	EndIf

	#EndRegion Check valid array

	#Region Check array range

	; Determine copy separator
	Local $iCW_ColWidth = Number($vUser_Separator)

	; Get current separator character
	Local $sCurr_Separator = Opt("GUIDataSeparatorChar")

	; Set default user separator if required
	If $vUser_Separator = "" Then $vUser_Separator = $sCurr_Separator

	; Declare variables
	$_g_ArrayDisplay_iItem_Start = 0
	$_g_ArrayDisplay_iItem_End = $_g_ArrayDisplay_nRows - 1
	$_g_ArrayDisplay_iSubItem_Start = 0
	$_g_ArrayDisplay_iSubItem_End = (($_g_ArrayDisplay_iDims = 2) ? ($_g_ArrayDisplay_nCols - 1) : (0))

	Local $avRangeSplit
	; Check for range settings
	If $sArrayRange Then
		; Split into separate dimension sections
		Local $vTmp, $aArray_Range = StringRegExp($sArrayRange & "||", "(?U)(.*)\|", $STR_REGEXPARRAYGLOBALMATCH)
		; Rows range
		If $aArray_Range[0] Then
			$avRangeSplit = StringSplit($aArray_Range[0], ":")
			If @error Then
				$_g_ArrayDisplay_iItem_End = Number($aArray_Range[0])
			Else
				$_g_ArrayDisplay_iItem_Start = Number($avRangeSplit[1])
				If $avRangeSplit[2] <> "" Then
					$_g_ArrayDisplay_iItem_End = Number($avRangeSplit[2])
				EndIf
			EndIf
		EndIf
		; Check row bounds
		If $_g_ArrayDisplay_iItem_Start < 0 Then $_g_ArrayDisplay_iItem_Start = 0
		If $_g_ArrayDisplay_iItem_End >= $_g_ArrayDisplay_nRows Then $_g_ArrayDisplay_iItem_End = $_g_ArrayDisplay_nRows - 1
		If ($_g_ArrayDisplay_iItem_Start > $_g_ArrayDisplay_iItem_End) And ($_g_ArrayDisplay_iItem_End > 0) Then
			$vTmp = $_g_ArrayDisplay_iItem_Start
			$_g_ArrayDisplay_iItem_Start = $_g_ArrayDisplay_iItem_End
			$_g_ArrayDisplay_iItem_End = $vTmp
		EndIf

		; Columns range
		If $_g_ArrayDisplay_iDims = 2 And $aArray_Range[1] Then
			$avRangeSplit = StringSplit($aArray_Range[1], ":")
			If @error Then
				$_g_ArrayDisplay_iSubItem_End = Number($aArray_Range[1])
			Else
				$_g_ArrayDisplay_iSubItem_Start = Number($avRangeSplit[1])
				If $avRangeSplit[2] <> "" Then
					$_g_ArrayDisplay_iSubItem_End = Number($avRangeSplit[2])
				EndIf
			EndIf
			; Check column bounds
			If $_g_ArrayDisplay_iSubItem_Start > $_g_ArrayDisplay_iSubItem_End Then
				$vTmp = $_g_ArrayDisplay_iSubItem_Start
				$_g_ArrayDisplay_iSubItem_Start = $_g_ArrayDisplay_iSubItem_End
				$_g_ArrayDisplay_iSubItem_End = $vTmp
			EndIf
			If $_g_ArrayDisplay_iSubItem_Start < 0 Then $_g_ArrayDisplay_iSubItem_Start = 0
			If $_g_ArrayDisplay_iSubItem_End >= $_g_ArrayDisplay_nCols Then $_g_ArrayDisplay_iSubItem_End = $_g_ArrayDisplay_nCols - 1
		EndIf
	EndIf

	; Create data display
	Local $sDisplayData = "[" & $_g_ArrayDisplay_nRows & "]"
	If $_g_ArrayDisplay_iDims = 2 Then
		$sDisplayData &= " [" & $_g_ArrayDisplay_nCols & "]"
	EndIf

	; Create tooltip data
	Local $sTipData = ""
	If $sArrayRange Then
		If $sTipData Then $sTipData &= " - "
		$sTipData &= "Range set " & $sArrayRange
	EndIf
	If $_g_ArrayDisplay_iTranspose Then
		If $sTipData Then $sTipData &= " - "
		$sTipData &= "Transposed"
	EndIf

	If $sArrayRange Or $_g_ArrayDisplay_iTranspose Then $_g_ArrayDisplay_aArray = __ArrayDisplay_CreateSubArray()

	#EndRegion Check array range

	#Region Check custom header

	; Split custom header on separator
	$_g_ArrayDisplay_asHeader = StringSplit($sHeader, $sCurr_Separator, $STR_NOCOUNT) ; No count element
	If UBound($_g_ArrayDisplay_asHeader) = 0 Then Dim $_g_ArrayDisplay_asHeader[1] = [""]
	$sHeader = "Row"
	Local $iIndex = $_g_ArrayDisplay_iSubItem_Start
	If $_g_ArrayDisplay_iTranspose Then
		; All default headers
		$sHeader = "Row"
		For $j = 0 To $_g_ArrayDisplay_nCols - 1
			$sHeader &= $sCurr_Separator & $ARRAYDISPLAY_ROWPREFIX & " " & $j + $_g_ArrayDisplay_iSubItem_Start
		Next
	Else
		; Create custom header with available items
		If $_g_ArrayDisplay_asHeader[0] Then
			; Set as many as available
			For $iIndex = $_g_ArrayDisplay_iSubItem_Start To $_g_ArrayDisplay_iSubItem_End
				; Check custom header available
				If $iIndex >= UBound($_g_ArrayDisplay_asHeader) Then ExitLoop
				If StringRight($_g_ArrayDisplay_asHeader[$iIndex], 1) = $ARRAYDISPLAY_NUMERICSORT Then
					$_g_ArrayDisplay_asHeader[$iIndex] = StringTrimRight($_g_ArrayDisplay_asHeader[$iIndex], 1) ; remove "*" from right
					$_g_ArrayDisplay_aNumericSort[$iIndex - $_g_ArrayDisplay_iSubItem_Start] = 1 ; 1 (numeric sort) or empty (natural sort)
				EndIf

				$sHeader &= $sCurr_Separator & $_g_ArrayDisplay_asHeader[$iIndex]
			Next
		EndIf
		; Add default headers to fill to end
		For $j = $iIndex To $_g_ArrayDisplay_iSubItem_End
			$sHeader &= $sCurr_Separator & "Col " & $j
		Next
	EndIf
	; Remove "Row" header if not needed
	If Not $_g_ArrayDisplay_iDisplayRow Then $sHeader = StringTrimLeft($sHeader, 4)

	#EndRegion Check custom header

	#Region Generate Sort index for columns

	__ArrayDisplay_SortIndexes(0, -1)

	; compute the time to generate one colum info to to the sorting
	Local $hTimer = TimerInit()
	__ArrayDisplay_SortIndexes(1, 1)
	$fTimer = TimerDiff($hTimer)
	If $fTimer * $_g_ArrayDisplay_nCols < 1000 Then
		; 		__ArrayDisplay_SortIndexes(-1)
		__ArrayDisplay_SortIndexes(2, $_g_ArrayDisplay_nCols)
;~ 		If $bDebug Then ConsoleWrite("Sorting all indexes = " & TimerDiff($hTimer) & @CRLF & @CRLF)
	Else
;~ 		If $bDebug Then ConsoleWrite("Sorting one index = " & TimerDiff($hTimer) & @CRLF)
	EndIf

	#EndRegion Generate Sort index for columns

	#Region GUI and Listview generation

	; Display splash dialog if required
	If $iVerbose And ($_g_ArrayDisplay_nRows * $_g_ArrayDisplay_nCols) > 1000 Then
		SplashTextOn($sMsgBoxTitle, "Preparing display" & @CRLF & @CRLF & "Please be patient", 300, 100)
	EndIf

	; GUI Constants
	Local Const $_ARRAYCONSTANT_GUI_DOCKBOTTOM = 64
	Local Const $_ARRAYCONSTANT_GUI_DOCKBORDERS = 102
	Local Const $_ARRAYCONSTANT_GUI_DOCKHEIGHT = 512
	Local Const $_ARRAYCONSTANT_GUI_DOCKLEFT = 2
	Local Const $_ARRAYCONSTANT_GUI_DOCKRIGHT = 4
	Local Const $_ARRAYCONSTANT_GUI_DOCKHCENTER = 8
	Local Const $_ARRAYCONSTANT_GUI_EVENT_CLOSE = -3
	Local Const $_ARRAYCONSTANT_GUI_EVENT_ARRAY = 1
	Local Const $_ARRAYCONSTANT_GUI_FOCUS = 256
	Local Const $_ARRAYCONSTANT_SS_CENTER = 0x1
	Local Const $_ARRAYCONSTANT_SS_CENTERIMAGE = 0x0200
	Local Const $_ARRAYCONSTANT_LVM_GETITEMRECT = (0x1000 + 14)
	Local Const $_ARRAYCONSTANT_LVM_GETITEMSTATE = (0x1000 + 44)
	Local Const $_ARRAYCONSTANT_LVM_GETSELECTEDCOUNT = (0x1000 + 50)
	Local Const $_ARRAYCONSTANT_LVM_SETEXTENDEDLISTVIEWSTYLE = (0x1000 + 54)
	Local Const $_ARRAYCONSTANT_LVS_EX_GRIDLINES = 0x1
	Local Const $_ARRAYCONSTANT_LVIS_SELECTED = 0x0002
	Local Const $_ARRAYCONSTANT_LVS_SHOWSELALWAYS = 0x8
	Local Const $_ARRAYCONSTANT_LVS_OWNERDATA = 0x1000
	Local Const $_ARRAYCONSTANT_LVS_EX_FULLROWSELECT = 0x20
	Local Const $_ARRAYCONSTANT_LVS_EX_DOUBLEBUFFER = 0x00010000 ; Paints via double-buffering, which reduces flicker
	Local Const $_ARRAYCONSTANT_WS_EX_CLIENTEDGE = 0x0200
	Local Const $_ARRAYCONSTANT_WS_MAXIMIZEBOX = 0x00010000
	Local Const $_ARRAYCONSTANT_WS_MINIMIZEBOX = 0x00020000
	Local Const $_ARRAYCONSTANT_WS_SIZEBOX = 0x00040000

	; Set coord mode 1
	Local $iCoordMode = Opt("GUICoordMode", 1)

	; Create GUI
	Local $iOrgWidth = 210, $iHeight = 200, $iMinSize = 250
	Local $hGUI = GUICreate($sTitle, $iOrgWidth, $iHeight, Default, Default, BitOR($_ARRAYCONSTANT_WS_SIZEBOX, $_ARRAYCONSTANT_WS_MINIMIZEBOX, $_ARRAYCONSTANT_WS_MAXIMIZEBOX))
	Local $aiGUISize = WinGetClientSize($hGUI)
	; Create ListView
	Local $idListView = GUICtrlCreateListView($sHeader, 0, 0, $aiGUISize[0], $aiGUISize[1] - $iButtonBorder, BitOR($_ARRAYCONSTANT_LVS_SHOWSELALWAYS, $_ARRAYCONSTANT_LVS_OWNERDATA))
	$_g_ArrayDisplay_hListView = GUICtrlGetHandle($idListView)
	GUICtrlSendMsg($idListView, $_ARRAYCONSTANT_LVM_SETEXTENDEDLISTVIEWSTYLE, $_ARRAYCONSTANT_LVS_EX_GRIDLINES, $_ARRAYCONSTANT_LVS_EX_GRIDLINES)
	GUICtrlSendMsg($idListView, $_ARRAYCONSTANT_LVM_SETEXTENDEDLISTVIEWSTYLE, $_ARRAYCONSTANT_LVS_EX_FULLROWSELECT, $_ARRAYCONSTANT_LVS_EX_FULLROWSELECT)
	GUICtrlSendMsg($idListView, $_ARRAYCONSTANT_LVM_SETEXTENDEDLISTVIEWSTYLE, $_ARRAYCONSTANT_LVS_EX_DOUBLEBUFFER, $_ARRAYCONSTANT_LVS_EX_DOUBLEBUFFER)
	GUICtrlSendMsg($idListView, $_ARRAYCONSTANT_LVM_SETEXTENDEDLISTVIEWSTYLE, $_ARRAYCONSTANT_WS_EX_CLIENTEDGE, $_ARRAYCONSTANT_WS_EX_CLIENTEDGE)
	Local $hHeader = HWnd(GUICtrlSendMsg($idListView, (0x1000 + 31), 0, 0)) ; $LVM_GETHEADER _GUICtrlListView_GetHeader($idListView)
	; Set resizing
	GUICtrlSetResizing($idListView, $_ARRAYCONSTANT_GUI_DOCKBORDERS)

	; Fill listview
	Local $iColFill = $_g_ArrayDisplay_nCols + $_g_ArrayDisplay_iDisplayRow
	; Align columns if required - $iColAlign = 2 for Right and 4 for Center
	If $iColAlign Then
		; Loop through columns
		For $i = 0 To $iColFill - 1
			__ArrayDisplay_JustifyColumn($idListView, $i, $iColAlign / 2)
		Next
	EndIf

	GUICtrlSendMsg($idListView, (0x1000 + 47), $_g_ArrayDisplay_nRows, 0) ; $LVM_SETITEMCOUNT

	; Get row height
	Local $tRECT = DllStructCreate("struct; long Left;long Top;long Right;long Bottom; endstruct") ; $tagRECT
	DllCall("user32.dll", "struct*", "SendMessageW", "hwnd", $_g_ArrayDisplay_hListView, "uint", $_ARRAYCONSTANT_LVM_GETITEMRECT, "wparam", 0, "struct*", $tRECT)
	; Set required GUI height
	Local $aiWin_Pos = WinGetPos($hGUI)
	Local $aiLV_Pos = ControlGetPos($hGUI, "", $idListView)
	$iHeight = (($_g_ArrayDisplay_nRows + 3) * (DllStructGetData($tRECT, "Bottom") - DllStructGetData($tRECT, "Top"))) + $aiWin_Pos[3] - $aiLV_Pos[3]
	; Check min/max height
	If $iHeight > @DesktopHeight - 100 Then
		$iHeight = @DesktopHeight - 100
	ElseIf $iHeight < $iMinSize Then
		$iHeight = $iMinSize
	EndIf

	If $iVerbose Then SplashOff()

	; Sorting information
	$_g_ArrayDisplay_iSortDir = 0x00000400 ; $HDF_SORTUP
	Local $iColumn = 0, $iColumnPrev = -1
	If $_g_ArrayDisplay_iDisplayRow Then
		$iColumnPrev = $iColumn
		__ArrayDisplay_HeaderSetItemFormat($hHeader, $iColumn, 0x00004000 + $_g_ArrayDisplay_iSortDir + $iColAlign / 2) ; $HDF_STRING
	EndIf
	$_g_ArrayDisplay_aIndex = $_g_ArrayDisplay_aIndexes[0]

	#EndRegion GUI and Listview generation

	; Register WM_NOTIFY message handler through subclassing
	Local $p__ArrayDisplay_NotifyHandler = DllCallbackGetPtr(DllCallbackRegister("__ArrayDisplay_NotifyHandler", "lresult", "hwnd;uint;wparam;lparam;uint_ptr;dword_ptr"))
	DllCall("comctl32.dll", "bool", "SetWindowSubclass", "hwnd", $hGUI, "ptr", $p__ArrayDisplay_NotifyHandler, "uint_ptr", 0, "dword_ptr", 0)   ; $iSubclassId = 0, $pData = 0

	#Region Adjust dialog width

	Local $iWidth = 40, $iColWidth = 0, $aiColWidth[$iColFill]
	; Get required column widths to fit items
	Local $iColWidthHeader, $iMin_ColW = 55
	For $i = 0 To $iColFill - 1
		If $i > 0 Then $iMin_ColW = $iMin_ColWidth ; to be use only for #col > 0
		GUICtrlSendMsg($idListView, (0x1000 + 30), $i, -1)                            ; $LVM_SETCOLUMNWIDTH $LVSCW_AUTOSIZE
		$iColWidth = GUICtrlSendMsg($idListView, (0x1000 + 29), $i, 0)                    ; $LVM_GETCOLUMNWIDTH
		; Check width of header if set
		If $sHeader <> "" Then
			If $iColWidth = 0 Then ExitLoop
			GUICtrlSendMsg($idListView, (0x1000 + 30), $i, -2)                            ; $LVM_SETCOLUMNWIDTH $LVSCW_AUTOSIZE_USEHEADER
			$iColWidthHeader = GUICtrlSendMsg($idListView, (0x1000 + 29), $i, 0)              ; $GETCOLUMNWIDTH
			; Set minimum if required
			If $iColWidth < $iMin_ColW And $iColWidthHeader < $iMin_ColW Then
				GUICtrlSendMsg($idListView, (0x1000 + 30), $i, $iMin_ColW)                ; $LVM_SETCOLUMNWIDTH
				$iColWidth = $iMin_ColW
			ElseIf $iColWidthHeader < $iColWidth Then
				GUICtrlSendMsg($idListView, (0x1000 + 30), $i, $iColWidth)                    ; $LVM_SETCOLUMNWIDTH
			Else
				$iColWidth = $iColWidthHeader
			EndIf
		Else
			; Set minimum if required
			If $iColWidth < $iMin_ColW Then
				GUICtrlSendMsg($idListView, (0x1000 + 30), $i, $iMin_ColW)                ; $LVM_SETCOLUMNWIDTH
				$iColWidth = $iMin_ColW
			EndIf
		EndIf
		; Add to total width
		$iWidth += $iColWidth
		; Store  value
		$aiColWidth[$i] = $iColWidth
	Next
	; Now check max size
	If $iWidth > @DesktopWidth - 100 Then
		; Apply max col width limit to reduce width
		$iWidth = 40
		For $i = 0 To $iColFill - 1
			If $aiColWidth[$i] > $iMax_ColWidth Then
				; Reset width
				GUICtrlSendMsg($idListView, (0x1000 + 30), $i, $iMax_ColWidth)        ; $LVM_SETCOLUMNWIDTH
				$iWidth += $iMax_ColWidth
			Else
				; Retain width
				$iWidth += $aiColWidth[$i]
			EndIf
			If $i < 20 And $bDebug Then ConsoleWrite('@@ Debug(' & @ScriptLineNumber & ') : $iWidth = ' & $iWidth & " $i = " & $i & @CRLF)                      ;### Debug Console
		Next
	EndIf

	; Check max/min width
	If $iWidth > @DesktopWidth - 100 Then
		$iWidth = @DesktopWidth - 100
	ElseIf $iWidth < $iMinSize Then
		$iWidth = $iMinSize
	EndIf

	#EndRegion Adjust dialog width

	; Allow for borders with vertical scrollbar
	Local $iScrollBarSize = 0
	If $iHeight = (@DesktopHeight - 100) Then $iScrollBarSize = 15

	; Resize dialog
	WinMove($hGUI, "", (@DesktopWidth - $iWidth + $iScrollBarSize) / 2, (@DesktopHeight - $iHeight) / 2, $iWidth + $iScrollBarSize, $iHeight)

	; Resize ListView
	$aiGUISize = WinGetClientSize($hGUI)
	GUICtrlSetPos($idListView, 0, 0, $iWidth, $aiGUISize[1] - $iButtonBorder)

	#Region Create bottom infos

	Local $iButtonWidth_1 = $aiGUISize[0] / 2
	Local $iButtonWidth_2 = $aiGUISize[0] / 3
	Local $idCopy_ID = 9999, $idCopy_Data = 99999, $idData_Label = 99999, $idUser_Func = 99999, $idExit_Script = 99999
	If $bDebug Then
		; Create buttons
		$idCopy_ID = GUICtrlCreateButton("Copy Data && Hdr/Row", 0, $aiGUISize[1] - $iButtonBorder, $iButtonWidth_1, 20)
		$idCopy_Data = GUICtrlCreateButton("Copy Data Only", $iButtonWidth_1, $aiGUISize[1] - $iButtonBorder, $iButtonWidth_1, 20)
		Local $iButtonWidth_Var = $iButtonWidth_1
		Local $iOffset = $iButtonWidth_1
		If IsFunc($hUser_Function) Then
			; Create UserFunc button if function passed
			$idUser_Func = GUICtrlCreateButton("Run User Func", $iButtonWidth_2, $aiGUISize[1] - 20, $iButtonWidth_2, 20)
			$iButtonWidth_Var = $iButtonWidth_2
			$iOffset = $iButtonWidth_2 * 2
		EndIf
		; Create Exit button and data label
		$idExit_Script = GUICtrlCreateButton("Exit Script", $iOffset, $aiGUISize[1] - 20, $iButtonWidth_Var, 20)
		$idData_Label = GUICtrlCreateLabel($sDisplayData, 0, $aiGUISize[1] - 20, $iButtonWidth_Var, 18, BitOR($_ARRAYCONSTANT_SS_CENTER, $_ARRAYCONSTANT_SS_CENTERIMAGE))
	Else
		$idData_Label = GUICtrlCreateLabel($sDisplayData, 0, $aiGUISize[1] - 20, $aiGUISize[0], 18, BitOR($_ARRAYCONSTANT_SS_CENTER, $_ARRAYCONSTANT_SS_CENTERIMAGE))
	EndIf
	; Change label colour and create tooltip if required
	If $_g_ArrayDisplay_iTranspose Or $sArrayRange Then
		GUICtrlSetColor($idData_Label, 0xFF0000)
		GUICtrlSetTip($idData_Label, $sTipData)
	EndIf
	GUICtrlSetResizing($idCopy_ID, $_ARRAYCONSTANT_GUI_DOCKLEFT + $_ARRAYCONSTANT_GUI_DOCKBOTTOM + $_ARRAYCONSTANT_GUI_DOCKHEIGHT)
	GUICtrlSetResizing($idCopy_Data, $_ARRAYCONSTANT_GUI_DOCKRIGHT + $_ARRAYCONSTANT_GUI_DOCKBOTTOM + $_ARRAYCONSTANT_GUI_DOCKHEIGHT)
	GUICtrlSetResizing($idData_Label, $_ARRAYCONSTANT_GUI_DOCKLEFT + $_ARRAYCONSTANT_GUI_DOCKBOTTOM + $_ARRAYCONSTANT_GUI_DOCKHEIGHT)
	GUICtrlSetResizing($idUser_Func, $_ARRAYCONSTANT_GUI_DOCKHCENTER + $_ARRAYCONSTANT_GUI_DOCKBOTTOM + $_ARRAYCONSTANT_GUI_DOCKHEIGHT)
	GUICtrlSetResizing($idExit_Script, $_ARRAYCONSTANT_GUI_DOCKRIGHT + $_ARRAYCONSTANT_GUI_DOCKBOTTOM + $_ARRAYCONSTANT_GUI_DOCKHEIGHT)

	#EndRegion Create bottom infos

	; Display dialog
	GUISetState(@SW_SHOW, $hGUI)

	; Check if sort clicking can take a while
	If $fTimer > 1000 And Not $sArrayRange Then
		Beep(750, 250)
		ToolTip("Sorting Action can take as long as " & Ceiling($fTimer / 1000) & " sec" & @CRLF & @CRLF & "Please be patient when you click to sort a column", 50, 50, $sMsgBoxTitle, $TIP_WARNINGICON, $TIP_BALLOON)
		Sleep(3000)
		ToolTip("")
	EndIf

	#Region GUI Handling events

	; Switch to GetMessage mode
	Local $iOnEventMode = Opt("GUIOnEventMode", 0), $aMsg

	While 1

		$aMsg = GUIGetMsg($_ARRAYCONSTANT_GUI_EVENT_ARRAY) ; Variable needed to check which "Copy" button was pressed
		If $aMsg[1] = $hGUI Then
			Switch $aMsg[0]
				Case $_ARRAYCONSTANT_GUI_EVENT_CLOSE
					ExitLoop

				Case $idCopy_ID, $idCopy_Data
					; Count selected rows
					Local $iSel_Count = GUICtrlSendMsg($idListView, $_ARRAYCONSTANT_LVM_GETSELECTEDCOUNT, 0, 0)
					; Display splash dialog if required
					If $iVerbose And (Not $iSel_Count) And ($_g_ArrayDisplay_iItem_End - $_g_ArrayDisplay_iItem_Start) * ($_g_ArrayDisplay_iSubItem_End - $_g_ArrayDisplay_iSubItem_Start) > 10000 Then
						SplashTextOn($sMsgBoxTitle, "Copying data" & @CRLF & @CRLF & "Please be patient", 300, 100)
					EndIf
					; Generate clipboard text
					Local $sClip = "", $sItem, $aSplit, $iFirstCol = 0
					If $aMsg[0] = $idCopy_Data And $_g_ArrayDisplay_iDisplayRow Then $iFirstCol = 1
					; Add items
					For $i = 0 To GUICtrlSendMsg($idListView, 0X1004, 0, 0) - 1 ; $LVM_GETITEMCOUNT
						; Skip if copying selected rows and item not selected
						If $iSel_Count And Not (GUICtrlSendMsg($idListView, $_ARRAYCONSTANT_LVM_GETITEMSTATE, $i, $_ARRAYCONSTANT_LVIS_SELECTED) <> 0) Then
							ContinueLoop
						EndIf
						$sItem = __ArrayDisplay_GetItemTextStringSelected($idListView, $i, $iFirstCol)
						If $aMsg[0] = $idCopy_ID And Not $_g_ArrayDisplay_iDisplayRow Then
							; Add row data
							$sItem = $ARRAYDISPLAY_ROWPREFIX & " " & ($i + $_g_ArrayDisplay_iItem_Start) & $sCurr_Separator & $sItem
						EndIf
						If $iCW_ColWidth Then
							; Expand columns
							$aSplit = StringSplit($sItem, $sCurr_Separator)
							$sItem = ""
							For $j = 1 To $aSplit[0]
								$sItem &= StringFormat("%-" & $iCW_ColWidth + 1 & "s", StringLeft($aSplit[$j], $iCW_ColWidth))
							Next
						Else
							; Use defined separator
							$sItem = StringReplace($sItem, $sCurr_Separator, $vUser_Separator)
						EndIf
						$sClip &= $sItem & @CRLF
					Next
					$sItem = $sHeader
					; Add header line if required
					If $aMsg[0] = $idCopy_ID Then
						$sItem = $sHeader
						If Not $_g_ArrayDisplay_iDisplayRow Then
							; Add "Row" to header
							$sItem = "Row" & $sCurr_Separator & $sItem
						EndIf
						If $iCW_ColWidth Then
							$aSplit = StringSplit($sItem, $sCurr_Separator)
							$sItem = ""
							For $j = 1 To $aSplit[0]
								$sItem &= StringFormat("%-" & $iCW_ColWidth + 1 & "s", StringLeft($aSplit[$j], $iCW_ColWidth))
							Next
						Else
							$sItem = StringReplace($sItem, $sCurr_Separator, $vUser_Separator)
						EndIf
						$sClip = $sItem & @CRLF & $sClip
					EndIf
					;Send to clipboard
					ClipPut($sClip)
					; Remove splash if used
					SplashOff()
					; Refocus ListView
					GUICtrlSetState($idListView, $_ARRAYCONSTANT_GUI_FOCUS)

				Case $idListView
					$iColumn = GUICtrlGetState($idListView)
					If Not IsArray($_g_ArrayDisplay_aIndexes[$iColumn + Not $_g_ArrayDisplay_iDisplayRow]) Then
						; in case all indexes have not been set during start creation
						__ArrayDisplay_SortIndexes($iColumn + Not $_g_ArrayDisplay_iDisplayRow)
					EndIf

					If $iColumn <> $iColumnPrev Then
						__ArrayDisplay_HeaderSetItemFormat($hHeader, $iColumnPrev, 0x00004000 + $iColAlign / 2) ; $HDF_STRING
						If $_g_ArrayDisplay_iDisplayRow And $iColumn = 0 Then
							$_g_ArrayDisplay_aIndex = $_g_ArrayDisplay_aIndexes[0]
						Else
							$_g_ArrayDisplay_aIndex = $_g_ArrayDisplay_aIndexes[$iColumn + Not $_g_ArrayDisplay_iDisplayRow]
						EndIf
					EndIf
					; $_g_ArrayDisplay_iSortDir = ($iColumn = $iColumnPrev) ? $_g_ArrayDisplay_iSortDir = $HDF_SORTUP ? $HDF_SORTDOWN : $HDF_SORTUP : $HDF_SORTUP
					$_g_ArrayDisplay_iSortDir = ($iColumn = $iColumnPrev) ? $_g_ArrayDisplay_iSortDir = 0x00000400 ? 0x00000200 : 0x00000400 : 0x00000400 ; $HDF_SORTUP
					__ArrayDisplay_HeaderSetItemFormat($hHeader, $iColumn, 0x00004000 + $_g_ArrayDisplay_iSortDir + $iColAlign / 2)  ; $HDF_STRING
					GUICtrlSendMsg($idListView, (0x1000 + 140), $iColumn, 0) ; $LVM_SETSELECTEDCOLUMN
					GUICtrlSendMsg($idListView, (0x1000 + 47), $_g_ArrayDisplay_nRows, 0) ; $LVM_SETITEMCOUNT
					$iColumnPrev = $iColumn

				Case $idUser_Func
					; Get selected indices
					Local $aiSelItems[1] = [0]
					For $i = 0 To GUICtrlSendMsg($idListView, 0x1004, 0, 0) - 1 ; $LVM_GETITEMCOUNT
						If (GUICtrlSendMsg($idListView, $_ARRAYCONSTANT_LVM_GETITEMSTATE, $i, $_ARRAYCONSTANT_LVIS_SELECTED) <> 0) Then
							$aiSelItems[0] += 1
							ReDim $aiSelItems[$aiSelItems[0] + 1]
							$aiSelItems[$aiSelItems[0]] = $i + $_g_ArrayDisplay_iItem_Start
						EndIf
					Next

					; Pass array and selection to user function
					$hUser_Function($_g_ArrayDisplay_aArray, $aiSelItems)
					$_g_ArrayDisplay_bUserFunc = False

					__ArrayDisplay_CleanUp($hGUI, $iCoordMode, $iOnEventMode, $_iCallerError, $_iCallerExtended, $p__ArrayDisplay_NotifyHandler)
					;;__ArrayDisplay_Share($aArray, $sTitle, $sArrayRange, $iFlags, $vUser_Separator, $sHeader, $iMax_ColWidth, $hUser_Function, $bDebug, $_iScriptLineNumber, $_iCallerError, $_iCallerExtended)
					Return SetError($_iCallerError, $_iCallerExtended, -1)

				Case $idExit_Script
					; Clear up
					GUIDelete($hGUI)
					Exit
			EndSwitch
		EndIf
	WEnd

	#EndRegion GUI Handling events

	__ArrayDisplay_CleanUp($hGUI, $iCoordMode, $iOnEventMode, $_iCallerError, $_iCallerExtended, $p__ArrayDisplay_NotifyHandler)

	Return SetError($_iCallerError, $_iCallerExtended, 1)
EndFunc   ;==>__ArrayDisplay_Share

Func __ArrayDisplay_CleanUp($hGUI, $iCoordMode, $iOnEventMode, $_iCallerError, $_iCallerExtended, $p__ArrayDisplay_NotifyHandler)
	; Cleanup
	DllCall("comctl32.dll", "bool", "RemoveWindowSubclass", "hwnd", $hGUI, "ptr", $p__ArrayDisplay_NotifyHandler, "uint_ptr", 0)   ; $iSubclassId = 0

	; Release resources in case of big array used
	$_g_ArrayDisplay_aIndex = 0
	Dim $_g_ArrayDisplay_aIndexes[1]

	GUIDelete($hGUI)
	Opt("GUICoordMode", $iCoordMode) ; Reset original Coord mode
	Opt("GUIOnEventMode", $iOnEventMode) ; Reset original GUI mode

	Return SetError($_iCallerError, $_iCallerExtended, 1)
EndFunc   ;==>__ArrayDisplay_CleanUp

; #ADDITIONAL Functions to speed up _ArrayDisplay() or _DebugArrayDisplay()# ====================================================
; Thanks Larsj

Func __ArrayDisplay_NotifyHandler($hWnd, $iMsg, $wParam, $lParam, $iSubclassId, $pData)
	If $iMsg <> 0x004E Then Return DllCall("comctl32.dll", "lresult", "DefSubclassProc", "hwnd", $hWnd, "uint", $iMsg, "wparam", $wParam, "lparam", $lParam)[0]   ; 0x004E = $WM_NOTIFY

	Local Static $tagNMHDR = "struct;hwnd hWndFrom;uint_ptr IDFrom;INT Code;endstruct"
	Local Static $tagNMLVDISPINFO = $tagNMHDR & ";" & $_ARRAYCONSTANT_tagLVITEM

	Local $tNMLVDISPINFO = DllStructCreate($tagNMLVDISPINFO, $lParam)
	Switch HWnd(DllStructGetData($tNMLVDISPINFO, "hWndFrom"))
		Case $_g_ArrayDisplay_hListView
			Switch DllStructGetData($tNMLVDISPINFO, "Code")
				Case -177 ; $LVN_GETDISPINFOW
					Local Static $tText = DllStructCreate("wchar[4096]"), $pText = DllStructGetPtr($tText)
					Local $iItem = DllStructGetData($tNMLVDISPINFO, "Item")
					Local $iRow = ($_g_ArrayDisplay_iSortDir = 0x00000400) ? $_g_ArrayDisplay_aIndex[$iItem] : $_g_ArrayDisplay_aIndex[$_g_ArrayDisplay_nRows - 1 - $iItem]
					Local $iCol = DllStructGetData($tNMLVDISPINFO, "SubItem")

;~ 					ConsoleWrite('@@ Debug(' & @ScriptLineNumber & ') : $iRow = ' & $iRow & '  $iCol= ' & $iCol & '  $iItem = ' & $iItem & @CRLF) ;### Debug Console

					Local $sTemp
					If $_g_ArrayDisplay_iDisplayRow = 0 Then
						$sTemp = __ArrayDisplay_GetData($iRow, $iCol)
						DllStructSetData($tText, 1, $sTemp)
						DllStructSetData($tNMLVDISPINFO, "Text", $pText)
					Else
						If $iCol = 0 Then
							If $_g_ArrayDisplay_iTranspose Then
								Local $sCaptionCplt = ""
								If $iRow + $_g_ArrayDisplay_iItem_Start < UBound($_g_ArrayDisplay_asHeader) _
										And StringStripWS($_g_ArrayDisplay_asHeader[$iRow + $_g_ArrayDisplay_iItem_Start], 1 + 2) <> "" Then
									$sCaptionCplt = " (" & StringStripWS($_g_ArrayDisplay_asHeader[$iRow + $_g_ArrayDisplay_iItem_Start], 1 + 2)
									If StringRight($sCaptionCplt, 1) = $ARRAYDISPLAY_NUMERICSORT Then $sCaptionCplt = StringTrimRight($sCaptionCplt, 1)
									$sCaptionCplt &= ")"
								EndIf
								DllStructSetData($tText, 1, "Col " & ($iRow + $_g_ArrayDisplay_iItem_Start) & $sCaptionCplt)
							Else
								DllStructSetData($tText, 1, $ARRAYDISPLAY_ROWPREFIX & " " & $iRow + $_g_ArrayDisplay_iItem_Start)
							EndIf
							DllStructSetData($tNMLVDISPINFO, "Text", $pText)
						Else
							$sTemp = __ArrayDisplay_GetData($iRow, $iCol - 1)
							DllStructSetData($tText, 1, $sTemp)
							DllStructSetData($tNMLVDISPINFO, "Text", $pText)
						EndIf
					EndIf
					Return

			EndSwitch
	EndSwitch

	Return DllCall("comctl32.dll", "lresult", "DefSubclassProc", "hwnd", $hWnd, "uint", $iMsg, "wparam", $wParam, "lparam", $lParam)[0]
	#forceref $iSubclassId, $pData
EndFunc   ;==>__ArrayDisplay_NotifyHandler

Func __ArrayDisplay_GetData($iRow, $iCol)
	Local $sTemp
	If $_g_ArrayDisplay_iDims = 2 Then
		$sTemp = $_g_ArrayDisplay_aArray[$iRow][$iCol]
	Else
		$sTemp = $_g_ArrayDisplay_aArray[$iRow]
	EndIf
	Switch VarGetType($sTemp)
		Case "Array"
			Local $sSubscript = ""
			For $i = 1 To UBound($sTemp, 0)
				$sSubscript = "[" & UBound($sTemp, $i) & "]"
			Next

			$sTemp = "{Array" & $sSubscript & "}"
		Case "Map"
			$sTemp = "{Map[" & UBound($sTemp) & "]}"
		Case "Object"
			$sTemp = "{Object}"
	EndSwitch
	If StringLen($sTemp) > 4095 Then $sTemp = StringLeft($sTemp, 4095)

	Return $sTemp
EndFunc   ;==>__ArrayDisplay_GetData

Func __ArrayDisplay_SortIndexes($iColStart, $iColEnd = $iColStart)
	Dim $_g_ArrayDisplay_aIndex[$_g_ArrayDisplay_nRows]
;~ 	Local $hTimer
	If $iColEnd = -1 Then
		; column (0) already sorted
		Dim $_g_ArrayDisplay_aIndexes[$_g_ArrayDisplay_nCols + $_g_ArrayDisplay_iDisplayRow + 1]
;~ 		$hTimer = TimerInit()

		For $i = 0 To $_g_ArrayDisplay_nRows - 1
			$_g_ArrayDisplay_aIndex[$i] = $i
		Next

		$_g_ArrayDisplay_aIndexes[0] = $_g_ArrayDisplay_aIndex
;~ 		ConsoleWrite("Sorting array col#0 = " & TimerDiff($hTimer) & @CRLF)
	EndIf

	If $iColStart = -1 Then
		; to index all columns
		$iColStart = 1
		$iColEnd = $_g_ArrayDisplay_nCols
	EndIf

	If $iColStart Then
		; Index aArray columns
		Local $tIndex
		For $i = $iColStart To $iColEnd
;~ 			$hTimer = TimerInit()
			$tIndex = __ArrayDisplay_GetSortColStruct($_g_ArrayDisplay_aArray, $i - 1)

			For $j = 0 To $_g_ArrayDisplay_nRows - 1
				$_g_ArrayDisplay_aIndex[$j] = DllStructGetData($tIndex, 1, $j + 1)
			Next

			$_g_ArrayDisplay_aIndexes[$i] = $_g_ArrayDisplay_aIndex
;~ 			If $i < 20 Then ConsoleWrite("Sorting array col#" & $i & " = " & TimerDiff($hTimer) & @CRLF)
		Next
	EndIf

EndFunc   ;==>__ArrayDisplay_SortIndexes

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __ArrayDisplay_GetSortColStruct
; Description ...: Index based sorting of a 2D array by one or more columns
; Syntax.........: __ArrayDisplay_GetSortColStruct( $aArray, $iCol )
; Parameters ....: $aArray The 2D array to be sorted by index
;					$iCol Index column used in sorting
; Return values .: the sorting index as a DllStruct of integers
; Author ........: Larj : FAS_Sort2DArrayAu3()
; Modified.......: jpm : extension to  1D Array
; Remarks .......:
; ===============================================================================================================================
Func __ArrayDisplay_GetSortColStruct(Const ByRef $aArray, $iCol)

	If UBound($aArray, $UBOUND_DIMENSIONS) < 1 Or UBound($aArray, $UBOUND_DIMENSIONS) > 2 Then
;~ 		ConsoleWrite("$aArray is not a 1D or 2D array variable" & @CRLF)
		Return SetError(6, 0, 0)
	EndIf

	Return __ArrayDisplay_SortArrayStruct($aArray, $iCol)
EndFunc   ;==>__ArrayDisplay_GetSortColStruct

Func __ArrayDisplay_SortArrayStruct(Const ByRef $aArray, $iCol)
	Local $iDims = UBound($aArray, $UBOUND_DIMENSIONS)
	Local $tIndex = DllStructCreate("uint[" & $_g_ArrayDisplay_nRows & "]")
	Local $pIndex = DllStructGetPtr($tIndex)
	Static $hDll = DllOpen("kernel32.dll")
	Static $hDllComp = DllOpen("shlwapi.dll")

	Local $lo, $hi, $mi, $r, $nVal1, $nVal2

	; Sorting by one column
	For $i = 1 To $_g_ArrayDisplay_nRows - 1
		$lo = 0
		$hi = $i - 1
		Do
			$mi = Int(($lo + $hi) / 2)
			If Not $_g_ArrayDisplay_iTranspose And $_g_ArrayDisplay_aNumericSort[$iCol] Then ; Numeric sort
				If $iDims = 1 Then
					$nVal1 = Number($aArray[$i])
					$nVal2 = Number($aArray[DllStructGetData($tIndex, 1, $mi + 1)])
				Else
					$nVal1 = Number($aArray[$i][$iCol])
					$nVal2 = Number($aArray[DllStructGetData($tIndex, 1, $mi + 1)][$iCol])
				EndIf
				$r = $nVal1 < $nVal2 ? -1 : $nVal1 > $nVal2 ? 1 : 0
			Else ; Natural sort
				If $iDims = 1 Then
					$r = DllCall($hDllComp, 'int', 'StrCmpLogicalW', 'wstr', String($aArray[$i]), 'wstr', String($aArray[DllStructGetData($tIndex, 1, $mi + 1)]))[0]
				Else
					$r = DllCall($hDllComp, 'int', 'StrCmpLogicalW', 'wstr', String($aArray[$i][$iCol]), 'wstr', String($aArray[DllStructGetData($tIndex, 1, $mi + 1)][$iCol]))[0]
				EndIf
			EndIf
			Switch $r
				Case -1
					$hi = $mi - 1
				Case 1
					$lo = $mi + 1
				Case 0
					ExitLoop
			EndSwitch
		Until $lo > $hi
		DllCall($hDll, "none", "RtlMoveMemory", "struct*", $pIndex + ($mi + 1) * 4, "struct*", $pIndex + $mi * 4, "ulong_ptr", ($i - $mi) * 4)
		DllStructSetData($tIndex, 1, $i, $mi + 1 + ($lo = $mi + 1))
	Next

	Return $tIndex
EndFunc   ;==>__ArrayDisplay_SortArrayStruct

Func __ArrayDisplay_CreateSubArray()
	; the returned subarray is transposed
	Local $nRows = $_g_ArrayDisplay_iItem_End - $_g_ArrayDisplay_iItem_Start + 1
	Local $nCols = $_g_ArrayDisplay_iSubItem_End - $_g_ArrayDisplay_iSubItem_Start + 1

	Local $iRow = -1, $iCol, $iTemp, $aTemp
	If $_g_ArrayDisplay_iTranspose Then
		Dim $aTemp[$nCols][$nRows]
		For $i = $_g_ArrayDisplay_iItem_Start To $_g_ArrayDisplay_iItem_End
			$iRow += 1
			$iCol = -1
			For $j = $_g_ArrayDisplay_iSubItem_Start To $_g_ArrayDisplay_iSubItem_End
				$iCol += 1
				$aTemp[$iCol][$iRow] = $_g_ArrayDisplay_aArray[$i][$j]
			Next
		Next

		$iTemp = $_g_ArrayDisplay_iItem_Start
		$_g_ArrayDisplay_iItem_Start = $_g_ArrayDisplay_iSubItem_Start
		$_g_ArrayDisplay_iSubItem_Start = $iTemp

		$iTemp = $_g_ArrayDisplay_iItem_End
		$_g_ArrayDisplay_iItem_End = $_g_ArrayDisplay_iSubItem_End
		$_g_ArrayDisplay_iSubItem_End = $iTemp

		$_g_ArrayDisplay_nRows = $nCols
		$_g_ArrayDisplay_nCols = $nRows
	Else
		If $_g_ArrayDisplay_iDims = 1 Then
			Dim $aTemp[$nRows]
			For $i = $_g_ArrayDisplay_iItem_Start To $_g_ArrayDisplay_iItem_End
				$iRow += 1
				$aTemp[$iRow] = $_g_ArrayDisplay_aArray[$i]
			Next
		Else
			Dim $aTemp[$nRows][$nCols]
			For $i = $_g_ArrayDisplay_iItem_Start To $_g_ArrayDisplay_iItem_End
				$iRow += 1
				$iCol = -1
				For $j = $_g_ArrayDisplay_iSubItem_Start To $_g_ArrayDisplay_iSubItem_End
					$iCol += 1
					$aTemp[$iRow][$iCol] = $_g_ArrayDisplay_aArray[$i][$j]
				Next
			Next

			$_g_ArrayDisplay_nCols = $nCols
		EndIf

		$_g_ArrayDisplay_nRows = $nRows
	EndIf

;~ 	_DebugArrayDisplay($aTemp, "Subarray")
	Return $aTemp
EndFunc   ;==>__ArrayDisplay_CreateSubArray

; #DUPLICATED Functions to avoid big #include "GuiHeader.au3"# ==================================================================
; Functions have been simplified (unicode inprocess) according to __ArrayDisplay_Share() needs

Func __ArrayDisplay_HeaderSetItemFormat($hWnd, $iIndex, $iFormat)
	Local Static $tHDItem = DllStructCreate("uint Mask;int XY;ptr Text;handle hBMP;int TextMax;int Fmt;lparam Param;int Image;int Order;uint Type;ptr pFilter;uint State") ; $tagHDITEM
	DllStructSetData($tHDItem, "Mask", 0x00000004) ; $HDI_FORMAT
	DllStructSetData($tHDItem, "Fmt", $iFormat)
	Local $aResult = DllCall("user32.dll", "lresult", "SendMessageW", "hwnd", $hWnd, "uint", 0x120C, "wparam", $iIndex, "struct*", $tHDItem) ; $HDM_SETITEMW
	Return $aResult[0] <> 0
EndFunc   ;==>__ArrayDisplay_HeaderSetItemFormat

; #DUPLICATED Functions to avoid big #include "GuiListView.au3"# ================================================================
; Functions have been simplified (unicode inprocess) according to __ArrayDisplay_Share() needs

Func __ArrayDisplay_GetItemText($idListView, $iIndex, $iSubItem = 0)
	Local $tBuffer = DllStructCreate("wchar Text[4096]")
	Local $pBuffer = DllStructGetPtr($tBuffer)
	Local $tItem = DllStructCreate($_ARRAYCONSTANT_tagLVITEM)
	DllStructSetData($tItem, "SubItem", $iSubItem)
	DllStructSetData($tItem, "TextMax", 4096)
	DllStructSetData($tItem, "Text", $pBuffer)
	;Global Const $LVM_GETITEMTEXTW = (0x1000 + 115) ; 0X1073
	If IsHWnd($idListView) Then
		DllCall("user32.dll", "lresult", "SendMessageW", "hwnd", $idListView, "uint", 0x1073, "wparam", $iIndex, "struct*", $tItem)
	Else
		Local $pItem = DllStructGetPtr($tItem)
		GUICtrlSendMsg($idListView, 0x1073, $iIndex, $pItem)
	EndIf

	Return DllStructGetData($tBuffer, "Text")
EndFunc   ;==>__ArrayDisplay_GetItemText

Func __ArrayDisplay_GetItemTextStringSelected($idListView, $iItem, $iFirstCol)
	Local $sRow = "", $sSeparatorChar = Opt('GUIDataSeparatorChar')
	Local $iSelected = $iItem ; get row

	; GetColumnCount
	Local $hHeader = HWnd(GUICtrlSendMsg($idListView, 0x101F, 0, 0)) ; $LVM_GETHEADER
	Local $nCol = DllCall("user32.dll", "lresult", "SendMessageW", "hwnd", $hHeader, "uint", 0x1200, "wparam", 0, "lparam", 0)[0] ; $HDM_GETITEMCOUNT

	For $x = $iFirstCol To $nCol - 1
		$sRow &= __ArrayDisplay_GetItemText($idListView, $iSelected, $x) & $sSeparatorChar
	Next

	Return StringTrimRight($sRow, 1)
EndFunc   ;==>__ArrayDisplay_GetItemTextStringSelected

Func __ArrayDisplay_JustifyColumn($idListView, $iIndex, $iAlign = -1)
	;Local $aAlign[3] = [$LVCFMT_LEFT, $LVCFMT_RIGHT, $LVCFMT_CENTER]

	Local $tColumn = DllStructCreate("uint Mask;int Fmt;int CX;ptr Text;int TextMax;int SubItem;int Image;int Order;int cxMin;int cxDefault;int cxIdeal") ; $tagLVCOLUMN
	If $iAlign < 0 Or $iAlign > 2 Then $iAlign = 0
	DllStructSetData($tColumn, "Mask", 0x01) ; $LVCF_FMT
	DllStructSetData($tColumn, "Fmt", $iAlign)
	Local $pColumn = DllStructGetPtr($tColumn)
	Local $iRet = GUICtrlSendMsg($idListView, 0x1060, $iIndex, $pColumn)  ; $_ARRAYCONSTANT_LVM_SETCOLUMNW
	Return $iRet <> 0
EndFunc   ;==>__ArrayDisplay_JustifyColumn
