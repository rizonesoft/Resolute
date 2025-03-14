#include <Extras\WM_NOTIFY.au3>
#include <GuiComboBox.au3>
#include <GUIConstantsEx.au3>
#include <GuiDateTimePicker.au3>
#include <GuiEdit.au3>
#include <GuiReBar.au3>
#include <GuiToolbar.au3>
#include <WinAPIConstants.au3>
#include <WindowsConstants.au3>

Global $g_hReBar

Example()

Func Example()
	Local $hGui = GUICreate("Rebar Create (v" & @AutoItVersion & ")", 400, 396, -1, -1, BitOR($WS_MINIMIZEBOX, $WS_CAPTION, $WS_POPUP, $WS_SYSMENU, $WS_MAXIMIZEBOX))

	_WM_NOTIFY_Register()

	; create the rebar control
	$g_hReBar = _GUICtrlRebar_Create($hGui, BitOR($CCS_TOP, $WS_BORDER, $RBS_VARHEIGHT, $RBS_AUTOSIZE, $RBS_BANDBORDERS))

	; create a toolbar to put in the rebar
	Local $hToolbar = _GUICtrlToolbar_Create($hGui, BitOR($TBSTYLE_FLAT, $CCS_NORESIZE, $CCS_NOPARENTALIGN))

	; Add standard system bitmaps
	Switch _GUICtrlToolbar_GetBitmapFlags($hToolbar)
		Case 0
			_GUICtrlToolbar_AddBitmap($hToolbar, 1, -1, $IDB_STD_SMALL_COLOR)
		Case 2
			_GUICtrlToolbar_AddBitmap($hToolbar, 1, -1, $IDB_STD_LARGE_COLOR)
	EndSwitch

	; Add buttons
	Local Enum $e_idNew = 1000, $e_idOpen, $e_idSave, $idHelp
	_GUICtrlToolbar_AddButton($hToolbar, $e_idNew, $STD_FILENEW)
	_GUICtrlToolbar_AddButton($hToolbar, $e_idOpen, $STD_FILEOPEN)
	_GUICtrlToolbar_AddButton($hToolbar, $e_idSave, $STD_FILESAVE)
	_GUICtrlToolbar_AddButtonSep($hToolbar)
	_GUICtrlToolbar_AddButton($hToolbar, $idHelp, $STD_HELP)

	; create a combobox to put in the rebar
	Local $hCombo = _GUICtrlComboBox_Create($hGui, "", 0, 0, 120)

	_GUICtrlComboBox_BeginUpdate($hCombo)
	_GUICtrlComboBox_AddDir($hCombo, @WindowsDir & "\*.exe")
	_GUICtrlComboBox_EndUpdate($hCombo)

	; create a date time picker to put in the rebar
	Local $hDTP = _GUICtrlDTP_Create($hGui, 0, 0, 190)

	; create a input box to put in the rebar
	; $hInput = GUICtrlCreateInput("Input control", 0, 0, 120, 20)
	Local $hInput = _GUICtrlEdit_Create($hGui, "Input control", 0, 0, 120, 20)

	; default for add is append

	; add band with control
	_GUICtrlRebar_AddBand($g_hReBar, $hCombo, 120, 200, "Dir *.exe")

	; add band with date time picker
	_GUICtrlRebar_AddBand($g_hReBar, $hDTP, 120)

	; add band with toolbar to beginning of rebar
	_GUICtrlRebar_AddToolBarBand($g_hReBar, $hToolbar, "", 0)

	;add another control
	; _GUICtrlRebar_AddBand($g_hReBar, GUICtrlGetHandle($hInput), 120, 200, "Name:")
	_GUICtrlRebar_AddBand($g_hReBar, $hInput, 120, 200, "Name:")

	Local $idBtnExit = GUICtrlCreateButton("Exit", 150, 360, 100, 25)
	GUISetState(@SW_SHOW)

	While 1
		Switch GUIGetMsg()
			Case $GUI_EVENT_CLOSE, $idBtnExit
				Exit
		EndSwitch
	WEnd
EndFunc   ;==>Example

Func WM_NOTIFY($hWnd, $iMsg, $wParam, $lParam)
	#forceref $hWnd, $iMsg, $wParam

	Local $tNMHDR = DllStructCreate($tagNMHDR, $lParam)
	Local $hWndFrom = HWnd(DllStructGetData($tNMHDR, "hWndFrom"))
	Local $iCode = DllStructGetData($tNMHDR, "Code")
	Switch $hWndFrom
		Case $g_hReBar
			Switch $iCode
				Case $RBN_AUTOBREAK
					; Notifies a rebar's parent that a break will appear in the bar. The parent determines whether to make the break
					_WM_NOTIFY_DebugEvent("$RBN_AUTOBREAK", $tagNMREBARAUTOBREAK, $lParam, "IDFrom,,uBand,wID,lParam,uMsg,fStyleCurrent,fAutoBreak")
					; Return value not used
				Case $RBN_AUTOSIZE
					; Sent by a rebar control created with the $RBS_AUTOSIZE style when the rebar automatically resizes itself
					_WM_NOTIFY_DebugEvent("$RBN_AUTOSIZE", $tagNMRBAUTOSIZE, $lParam, "IDFrom,,fChanged,TargetLeft,TargetTop,TargetRight,TargetBottom,,ActualLeft,ActualTop,ActualRight,ActualBottom")
					; Return value not used
				Case $RBN_BEGINDRAG
					; Sent by a rebar control when the user begins dragging a band
					_WM_NOTIFY_DebugEvent("$RBN_BEGINDRAG", $tagNMREBAR, $lParam, "IDFrom,,dwMask,uBand,fStyle,wID,lParam")
					Return 0 ; to allow the rebar to continue the drag operation
					; Return 1 ; nonzero to abort the drag operation
				Case $RBN_CHEVRONPUSHED
					; Sent by a rebar control when a chevron is pushed
					; When an application receives this notification, it is responsible for displaying a popup menu with items for each hidden tool.
					; Use the rc member of the NMREBARCHEVRON structure to find the correct position for the popup menu
					_WM_NOTIFY_DebugEvent("$RBN_CHEVRONPUSHED", $tagNMREBARCHEVRON, $lParam, "IDFrom,,uBand,wID,lParam,Left,Top,Right,lParamNM")
					; Return value not used
				Case $RBN_CHILDSIZE
					; Sent by a rebar control when a band's child window is resized
					_WM_NOTIFY_DebugEvent("$RBN_CHILDSIZE", $tagNMREBARCHILDSIZE, $lParam, "IDFrom,,uBand,wID,CLeft,CTop,CRight,CBottom,BandLeft,,BTop,BRight,BBottom")
					; Return value not used
				Case $RBN_DELETEDBAND
					; Sent by a rebar control after a band has been deleted
					_WM_NOTIFY_DebugEvent("$RBN_DELETEDBAND", $tagNMREBAR, $lParam, "IDFrom,,dwMask,uBand,fStyle,wID,lParam")
					; Return value not used
				Case $RBN_DELETINGBAND
					; Sent by a rebar control when a band is about to be deleted
					_WM_NOTIFY_DebugEvent("$RBN_DELETINGBAND", $tagNMREBAR, $lParam, "IDFrom,,dwMask,uBand,fStyle,wID,lParam")
					; Return value not used
				Case $RBN_ENDDRAG
					; Sent by a rebar control when the user stops dragging a band
					_WM_NOTIFY_DebugEvent("$RBN_ENDDRAG", $tagNMREBAR, $lParam, "IDFrom,,dwMask,uBand,fStyle,wID,lParam")
					; Return value not used
				Case $RBN_GETOBJECT
					; Sent by a rebar control created with the $RBS_REGISTERDROP style when an object is dragged over a band in the control
					_WM_NOTIFY_DebugEvent("$RBN_GETOBJECT", $tagNMOBJECTNOTIFY, $lParam, "IDFrom,,Item,piid,pObject,Result")
					; Return value not used
				Case $RBN_HEIGHTCHANGE
					; Sent by a rebar control when its height has changed
					; Rebar controls that use the $CCS_VERT style send this notification message when their width changes
					_WM_NOTIFY_DebugEvent("$RBN_HEIGHTCHANGE", $tagNMHDR, $lParam, "hWndFrom,IDFrom")
					; Return value not used
				Case $RBN_LAYOUTCHANGED
					; Sent by a rebar control when the user changes the layout of the control's bands
					_WM_NOTIFY_DebugEvent("$RBN_LAYOUTCHANGED", $tagNMHDR, $lParam, "hWndFrom,IDFrom")
					; Return value not used
				Case $RBN_MINMAX
					; Sent by a rebar control prior to maximizing or minimizing a band
					_WM_NOTIFY_DebugEvent("$RBN_MINMAX", $tagNMHDR, $lParam, "hWndFrom,IDFrom")
					; Return 1 ; a non-zero value to prevent the operation from taking place
					Return 0 ; zero to allow it to continue
			EndSwitch
	EndSwitch
	Return $GUI_RUNDEFMSG
EndFunc   ;==>WM_NOTIFY
