#include <GUIConstantsEx.au3>
#include <GuiMenu.au3>
#include <WinAPIConv.au3>
#include <WindowsConstants.au3>

Global $g_idMemo, $g_hStyle, $g_iStyle, $g_idTimeLabel
Global Enum $e_idNew = 1000, $e_idOpen, $e_idSave, $e_idExit, $e_idMNS_CHECKORBMP, $e_idMNS_AUTODISMISS, $e_idMNS_MODELESS, $e_idMNS_NOCHECK, $e_idAbout

Global $g_hGUI, $g_hFile, $g_hHelp, $g_hMain

Example()

Func Example()
	$g_iStyle = $MNS_CHECKORBMP ; default mode

	$g_hGUI = GUICreate("Menu", 400, 300)

	CreateMenus()

	GUICtrlCreateLabel("After setting the Style to MNS_MODELESS" & @CRLF & _
			"the time will display continuously during the click on Menu", 20, 2, 290, 60)
	$g_idTimeLabel = GUICtrlCreateLabel("", 300, 2, 160, 40)

	; Create memo control
	$g_idMemo = GUICtrlCreateEdit("", 2, 30 + 2, 396, 276 - 30)
	GUICtrlSetFont($g_idMemo, 9, 400, 0, "Courier New")

	SetStyles() ; to set checkmenu style items

	GUISetState(@SW_SHOW)

	MemoWrite("starting with styles: " & @CRLF & @TAB & ConvStyles())

	; Register Windows Message ID
	GUIRegisterMsg($WM_COMMAND, "WM_COMMAND")
	AdlibRegister("DisplayTime", 1000)

	; Loop until the user exits.
	Do
		Sleep(10)
	Until GUIGetMsg() = $GUI_EVENT_CLOSE

	GUIDelete()
EndFunc   ;==>Example

Func CreateMenus()
	GUISetState(@SW_LOCK)

	; remove previous menus
	_GUICtrlMenu_DestroyMenu($g_hFile)
	_GUICtrlMenu_DestroyMenu($g_hStyle)
	_GUICtrlMenu_DestroyMenu($g_hHelp)
	_GUICtrlMenu_DestroyMenu($g_hMain)

	; Create File menu
	$g_hFile = _GUICtrlMenu_CreateMenu()
	_GUICtrlMenu_InsertMenuItem($g_hFile, 0, "&New", $e_idNew)
	_GUICtrlMenu_InsertMenuItem($g_hFile, 1, "&Open", $e_idOpen)
	_GUICtrlMenu_InsertMenuItem($g_hFile, 2, "&Save", $e_idSave)
	_GUICtrlMenu_InsertMenuItem($g_hFile, 3, "", 0)
	_GUICtrlMenu_InsertMenuItem($g_hFile, 4, "E&xit", $e_idExit)

	; Create Style menu
	$g_hStyle = _GUICtrlMenu_CreateMenu()
	_GUICtrlMenu_InsertMenuItem($g_hStyle, 0, "MNS_CHECKORBMP", $e_idMNS_CHECKORBMP)
	_GUICtrlMenu_InsertMenuItem($g_hStyle, 1, "MNS_AUTODISMISS", $e_idMNS_AUTODISMISS)
	_GUICtrlMenu_InsertMenuItem($g_hStyle, 2, "MNS_MODELESS", $e_idMNS_MODELESS)
	_GUICtrlMenu_InsertMenuItem($g_hStyle, 3, "MNS_NOCHECK", $e_idMNS_NOCHECK)

	; Create Help menu
	$g_hHelp = _GUICtrlMenu_CreateMenu()
	_GUICtrlMenu_InsertMenuItem($g_hHelp, 0, "&About", $e_idAbout)

	; Create Main menu
	$g_hMain = _GUICtrlMenu_CreateMenu($g_iStyle) ; ..for MNS_MODELESS, only this "main menu" is needed.
	_GUICtrlMenu_InsertMenuItem($g_hMain, 0, "&File", 0, $g_hFile)
	_GUICtrlMenu_InsertMenuItem($g_hMain, 1, "&Style", 0, $g_hStyle)
	_GUICtrlMenu_InsertMenuItem($g_hMain, 2, "&Help", 0, $g_hHelp)

	; Set window menu
	_GUICtrlMenu_SetMenu($g_hGUI, $g_hMain)

	GUISetState(@SW_UNLOCK)
EndFunc   ;==>CreateMenus

; Handle menu commands
Func WM_COMMAND($hWnd, $iMsg, $wParam, $lParam)
	#forceref $hWnd, $iMsg, $lParam
	Switch _WinAPI_LoWord($wParam)
		Case $e_idNew
			MemoWrite("New")
		Case $e_idOpen
			MemoWrite("Open")
		Case $e_idSave
			MemoWrite("Save")
		Case $e_idExit
			GUIDelete()
			Exit
		Case $e_idMNS_CHECKORBMP
			UpdateStyles($MNS_CHECKORBMP)
		Case $e_idMNS_AUTODISMISS
			UpdateStyles($MNS_AUTODISMISS)
		Case $e_idMNS_MODELESS
			UpdateStyles($MNS_MODELESS)
		Case $e_idMNS_NOCHECK
			UpdateStyles($MNS_NOCHECK)
		Case $e_idAbout
			MemoWrite("About")
	EndSwitch

	Return $GUI_RUNDEFMSG
EndFunc   ;==>WM_COMMAND

Func UpdateStyles($nStyle)
	If BitAND($g_iStyle, $nStyle) Then
		; reset the style
		$g_iStyle = BitAND($g_iStyle, BitNOT($nStyle))
	Else
		; set the style
		$g_iStyle = BitOR($g_iStyle, $nStyle)
	EndIf

	; recreate the menu with new styles as the modidications of $MNS_MODELESS cannot not be dynamic
	CreateMenus()
	MemoWrite("restarting with styles: " & @CRLF & @TAB & ConvStyles())
	SetStyles()
EndFunc   ;==>UpdateStyles

Func ConvStyles()
	Local $sStyle = ""
	If BitAND($g_iStyle, $MNS_CHECKORBMP) Then $sStyle &= " MNS_CHECKORBMP"
	If BitAND($g_iStyle, $MNS_AUTODISMISS) Then $sStyle &= " MNS_AUTODISMISS"
	If BitAND($g_iStyle, $MNS_MODELESS) Then $sStyle &= " MNS_MODELESS"
	If BitAND($g_iStyle, $MNS_NOCHECK) Then $sStyle &= " MNS_NOCHECK"

	If $g_iStyle = 0 Then
		$g_iStyle = $MNS_CHECKORBMP ; default mode
		$sStyle = " MNS_CHECKORBMP"
	EndIf

	Return $sStyle
EndFunc   ;==>ConvStyles

Func SetStyles()
	If BitAND($g_iStyle, $MNS_CHECKORBMP) Then _GUICtrlMenu_SetItemState($g_hStyle, $e_idMNS_CHECKORBMP, $MFS_CHECKED, True, False)
	If BitAND($g_iStyle, $MNS_AUTODISMISS) Then _GUICtrlMenu_SetItemState($g_hStyle, $e_idMNS_AUTODISMISS, $MFS_CHECKED, True, False)
	If BitAND($g_iStyle, $MNS_MODELESS) Then _GUICtrlMenu_SetItemState($g_hStyle, $e_idMNS_MODELESS, $MFS_CHECKED, True, False)
	If BitAND($g_iStyle, $MNS_NOCHECK) Then _GUICtrlMenu_SetItemState($g_hStyle, $e_idMNS_NOCHECK, $MFS_CHECKED, True, False)

	If $g_iStyle = 0 Then
		$g_iStyle = $MNS_CHECKORBMP ; default mode
		_GUICtrlMenu_SetItemState($g_hStyle, $e_idMNS_CHECKORBMP, $MFS_CHECKED, True, False)
	EndIf
EndFunc   ;==>SetStyles

; Display new time in label.
Func DisplayTime()
	GUICtrlSetData($g_idTimeLabel, "Time =   " & @HOUR & ":" & @MIN & ":" & @SEC)
EndFunc   ;==>DisplayTime

; Write message to memo
Func MemoWrite($sMessage)
	GUICtrlSetData($g_idMemo, $sMessage & @CRLF, 1)
EndFunc   ;==>MemoWrite
