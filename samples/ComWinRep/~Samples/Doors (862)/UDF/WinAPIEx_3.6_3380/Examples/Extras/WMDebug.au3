#Region Header

#cs

    Title:          Window Messages (WM) Debugger UDF Library for AutoIt3
    Filename:       WMDebug.au3
    Description:    Helper debug function that used in some examples from the WinAPIEx UDF library package
    Author:         Yashied
    Version:        3.6 / 3.3.6.1
    Requirements:   AutoIt v3.3 +, Developed/Tested on Windows XP Pro Service Pack 2 and Windows Vista/7
    Uses:           None
    Note:           -

    Available functions:

    _WM_Debug

#ce

#Include-once

#EndRegion Header

#Region Global Variables and Constants

Global Const $WMD_HWND = 0x0001
Global Const $WMD_ID = 0x0002
Global Const $WMD_WPARAM = 0x0004
Global Const $WMD_LPARAM = 0x0008
Global Const $WMD_MSG = 0x0010
Global Const $WMD_ALL = BitOR($WMD_HWND, $WMD_ID, $WMD_WPARAM, $WMD_LPARAM, $WMD_MSG)
Global Const $WMD_DEFAULT = BitOR($WMD_WPARAM, $WMD_LPARAM, $WMD_MSG)

#EndRegion Global Variables and Constants

#Region Local Variables and Constants

Global Const $__tInt64 = DllStructCreate('int64')
Global Const $__tDWord = DllStructCreate('dword;dword', DllStructGetPtr($__tInt64))
Global Const $__WM = __WMGetArray()

#EndRegion Local Variables and Constants

#Region Public Functions

; #FUNCTION# ====================================================================================================================
; Name...........: _WM_Debug
; Description....: Writes a values of the specified parameters to the STDOUT stream as the pre-formatted string.
; Syntax.........: _WM_Debug ($iVal1, $iVal2, $iVal3, $iVal4, $iFlags [, $aInclude [, $aExclude]] )
; Parameters.....: $iVal1...$iVal4 - This parameters must contain the values of the parameters known as "hWnd", "iMsg", "wParam",
;                                    and "lParam" that are passed to the typical Window Message (WM) procedure. This parameters
;                                    should be of the any integer type or a pointers.
;                  $iFlags         - A set of bit flags that specifies which parameters should be used. This parameter can be
;                                    one or more of the following values.
;
;                                    $WMD_ALL
;                                    $WMD_DEFAULT
;                                    $WMD_HWND
;                                    $WMD_ID
;                                    $WMD_WPARAM
;                                    $WMD_LPARAM
;                                    $WMD_MSG
;
;                  $aInclude       - An array that contains an integer values of the Window Messages ($WM_*) which to be processed.
;                                    The messages that are not included in this array will be ignored. If this parameter is not
;                                    an array, the all messages will be processed.
;                  $aExclude       - An array that contains an integer values of the Window Messages ($WM_*) which to be ignored.
;                                    The messages that are not included in this array will be processed. This can be useful to
;                                    exclude frequent messages such as WM_MOUSEMOVE, WM_SETCURSOR, etc.
; Return values..: None
; Author.........: Yashied
; Modified.......:
; Remarks........: The _WM_Debug() function generally need to call directly from the hook or window callback procedure and pass it
;                  parameters of this procedure.
; Related........:
; Link...........: None
; Example........: Yes
; ===============================================================================================================================

Func _WM_Debug($iVal1, $iVal2, $iVal3, $iVal4, $iFlags = 0x001C, $aInclude = 0, $aExclude = 0)

	Local $Param, $Prev = 0, $Pattern = ''

	If IsArray($aInclude) Then
		Do
			For $i = 0 To UBound($aInclude) - 1
				If $aInclude[$i] = $iVal2 Then
					ExitLoop 2
				EndIf
			Next
			Return
		Until 1
	EndIf
	If IsArray($aExclude) Then
		Do
			For $i = 0 To UBound($aExclude) - 1
				If $aExclude[$i] = $iVal2 Then
					Return
				EndIf
			Next
		Until 1
	EndIf
	$Param = StringSplit('HWND = 0x%s|MSG = 0x%04X|WP = 0x%s|LP = 0x%s|', '|', 2)
	For $i = 0 To 3
		If BitAND($iFlags, BitShift(1, -$i)) Then
			If $Prev Then
				$Pattern &= ' | '
			EndIf
			$Pattern &= $Param[$i]
			$Param[$i] = Eval('iVal' & ($i + 1))
			$Prev = 1
		Else
			$Pattern &= '%s'
			$Param[$i] = ''
		EndIf
	Next
	If BitAND($iFlags, 0x0010) Then
		If $Prev Then
			$Pattern &= ' | '
		EndIf
		If ($iVal2 < UBound($__WM)) And ($__WM[$iVal2]) Then
			$Param[4] = $__WM[$iVal2]
			$Pattern &= '%s'
		Else
			$Param[4] = $iVal2
			$Pattern &= '0x%04X'
		EndIf
	EndIf
	ConsoleWrite(StringFormat($Pattern, __WMHex64($Param[0]), $Param[1], __WMHex64($Param[2]), __WMHex64($Param[3]), $Param[4]) & @CR)
EndFunc   ;==>_WM_Debug

#EndRegion Public Functions

#Region Internal Functions

Func __WMGetArray()

	Local $WM[0x0400]

	$WM[0x0000] = 'WM_NULL'
	$WM[0x0001] = 'WM_CREATE'
	$WM[0x0002] = 'WM_DESTROY'
	$WM[0x0003] = 'WM_MOVE'
	$WM[0x0004] = 'WM_SIZEWAIT'
	$WM[0x0005] = 'WM_SIZE'
	$WM[0x0006] = 'WM_ACTIVATE'
	$WM[0x0007] = 'WM_SETFOCUS'
	$WM[0x0008] = 'WM_KILLFOCUS'
	$WM[0x0009] = 'WM_SETVISIBLE'
	$WM[0x000A] = 'WM_ENABLE'
	$WM[0x000B] = 'WM_SETREDRAW'
	$WM[0x000C] = 'WM_SETTEXT'
	$WM[0x000D] = 'WM_GETTEXT'
	$WM[0x000E] = 'WM_GETTEXTLENGTH'
	$WM[0x000F] = 'WM_PAINT'
	$WM[0x0010] = 'WM_CLOSE'
	$WM[0x0011] = 'WM_QUERYENDSESSION'
	$WM[0x0012] = 'WM_QUIT'
	$WM[0x0013] = 'WM_QUERYOPEN'
	$WM[0x0014] = 'WM_ERASEBKGND'
	$WM[0x0015] = 'WM_SYSCOLORCHANGE'
	$WM[0x0016] = 'WM_ENDSESSION'
	$WM[0x0017] = 'WM_SYSTEMERROR'
	$WM[0x0018] = 'WM_SHOWWINDOW'
	$WM[0x0019] = 'WM_CTLCOLOR'
	$WM[0x001A] = 'WM_SETTINGCHANGE'
	$WM[0x001B] = 'WM_DEVMODECHANGE'
	$WM[0x001C] = 'WM_ACTIVATEAPP'
	$WM[0x001D] = 'WM_FONTCHANGE'
	$WM[0x001E] = 'WM_TIMECHANGE'
	$WM[0x001F] = 'WM_CANCELMODE'
	$WM[0x0020] = 'WM_SETCURSOR'
	$WM[0x0021] = 'WM_MOUSEACTIVATE'
	$WM[0x0022] = 'WM_CHILDACTIVATE'
	$WM[0x0023] = 'WM_QUEUESYNC'
	$WM[0x0024] = 'WM_GETMINMAXINFO'
	$WM[0x0025] = 'WM_LOGOFF'
	$WM[0x0026] = 'WM_PAINTICON'
	$WM[0x0027] = 'WM_ICONERASEBKGND'
	$WM[0x0028] = 'WM_NEXTDLGCTL'
	$WM[0x0029] = 'WM_ALTTABACTIVE'
	$WM[0x002A] = 'WM_SPOOLERSTATUS'
	$WM[0x002B] = 'WM_DRAWITEM'
	$WM[0x002C] = 'WM_MEASUREITEM'
	$WM[0x002D] = 'WM_DELETEITEM'
	$WM[0x002E] = 'WM_VKEYTOITEM'
	$WM[0x002F] = 'WM_CHARTOITEM'
	$WM[0x0030] = 'WM_SETFONT'
	$WM[0x0031] = 'WM_GETFONT'
	$WM[0x0032] = 'WM_SETHOTKEY'
	$WM[0x0033] = 'WM_GETHOTKEY'
	$WM[0x0034] = 'WM_FILESYSCHANGE'
	$WM[0x0035] = 'WM_ISACTIVEICON'
	$WM[0x0036] = 'WM_QUERYPARKICON'
	$WM[0x0037] = 'WM_QUERYDRAGICON'
	$WM[0x0038] = 'WM_WINHELP'
	$WM[0x0039] = 'WM_COMPAREITEM'
	$WM[0x003A] = 'WM_FULLSCREEN'
	$WM[0x003B] = 'WM_CLIENTSHUTDOWN'
	$WM[0x003C] = 'WM_DDEMLEVENT'
	$WM[0x003D] = 'WM_GETOBJECT'
	$WM[0x003F] = 'WM_CALCSCROLL'
	$WM[0x0040] = 'WM_TESTING'
	$WM[0x0041] = 'WM_COMPACTING'
	$WM[0x0042] = 'WM_OTHERWINDOWCREATED'
	$WM[0x0043] = 'WM_OTHERWINDOWDESTROYED'
	$WM[0x0044] = 'WM_COMMNOTIFY'
	$WM[0x0045] = 'WM_MEDIASTATUSCHANGE'
	$WM[0x0046] = 'WM_WINDOWPOSCHANGING'
	$WM[0x0047] = 'WM_WINDOWPOSCHANGED'
	$WM[0x0048] = 'WM_POWER'
	$WM[0x0049] = 'WM_COPYGLOBALDATA'
	$WM[0x004A] = 'WM_COPYDATA'
	$WM[0x004B] = 'WM_CANCELJOURNAL'
	$WM[0x004C] = 'WM_LOGONNOTIFY'
	$WM[0x004D] = 'WM_KEYF1'
	$WM[0x004E] = 'WM_NOTIFY'
	$WM[0x004F] = 'WM_ACCESS_WINDOW'
	$WM[0x0050] = 'WM_INPUTLANGCHANGEREQUEST'
	$WM[0x0051] = 'WM_INPUTLANGCHANGE'
	$WM[0x0052] = 'WM_TCARD'
	$WM[0x0053] = 'WM_HELP'
	$WM[0x0054] = 'WM_USERCHANGED'
	$WM[0x0055] = 'WM_NOTIFYFORMAT'
	$WM[0x0060] = 'WM_QM_ACTIVATE'
	$WM[0x0061] = 'WM_HOOK_DO_CALLBACK'
	$WM[0x0062] = 'WM_SYSCOPYDATA'
	$WM[0x0070] = 'WM_FINALDESTROY'
	$WM[0x0071] = 'WM_MEASUREITEM_CLIENTDATA'
	$WM[0x007B] = 'WM_CONTEXTMENU'
	$WM[0x007C] = 'WM_STYLECHANGING'
	$WM[0x007D] = 'WM_STYLECHANGED'
	$WM[0x007E] = 'WM_DISPLAYCHANGE'
	$WM[0x007F] = 'WM_GETICON'
	$WM[0x0080] = 'WM_SETICON'
	$WM[0x0081] = 'WM_NCCREATE'
	$WM[0x0082] = 'WM_NCDESTROY'
	$WM[0x0083] = 'WM_NCCALCSIZE'
	$WM[0x0084] = 'WM_NCHITTEST'
	$WM[0x0085] = 'WM_NCPAINT'
	$WM[0x0086] = 'WM_NCACTIVATE'
	$WM[0x0087] = 'WM_GETDLGCODE'
	$WM[0x0088] = 'WM_SYNCPAINT'
	$WM[0x0089] = 'WM_SYNCTASK'
	$WM[0x008B] = 'WM_KLUDGEMINRECT'
	$WM[0x008C] = 'WM_LPKDRAWSWITCHWND'
	$WM[0x0090] = 'WM_UAHDESTROYWINDOW'
	$WM[0x0091] = 'WM_UAHDRAWMENU'
	$WM[0x0092] = 'WM_UAHDRAWMENUITEM'
	$WM[0x0093] = 'WM_UAHINITMENU'
	$WM[0x0094] = 'WM_UAHMEASUREMENUITEM'
	$WM[0x0095] = 'WM_UAHNCPAINTMENUPOPUP'
	$WM[0x00A0] = 'WM_NCMOUSEMOVE'
	$WM[0x00A1] = 'WM_NCLBUTTONDOWN'
	$WM[0x00A2] = 'WM_NCLBUTTONUP'
	$WM[0x00A3] = 'WM_NCLBUTTONDBLCLK'
	$WM[0x00A4] = 'WM_NCRBUTTONDOWN'
	$WM[0x00A5] = 'WM_NCRBUTTONUP'
	$WM[0x00A6] = 'WM_NCRBUTTONDBLCLK'
	$WM[0x00A7] = 'WM_NCMBUTTONDOWN'
	$WM[0x00A8] = 'WM_NCMBUTTONUP'
	$WM[0x00A9] = 'WM_NCMBUTTONDBLCLK'
	$WM[0x00AB] = 'WM_NCXBUTTONDOWN'
	$WM[0x00AC] = 'WM_NCXBUTTONUP'
	$WM[0x00AD] = 'WM_NCXBUTTONDBLCLK'
	$WM[0x00AE] = 'WM_NCUAHDRAWCAPTION'
	$WM[0x00AF] = 'WM_NCUAHDRAWFRAME'
	$WM[0x00FE] = 'WM_INPUT_DEVICE_CHANGE'
	$WM[0x00FF] = 'WM_INPUT'
	$WM[0x0100] = 'WM_KEYDOWN'
	$WM[0x0101] = 'WM_KEYUP'
	$WM[0x0102] = 'WM_CHAR'
	$WM[0x0103] = 'WM_DEADCHAR'
	$WM[0x0104] = 'WM_SYSKEYDOWN'
	$WM[0x0105] = 'WM_SYSKEYUP'
	$WM[0x0106] = 'WM_SYSCHAR'
	$WM[0x0107] = 'WM_SYSDEADCHAR'
	$WM[0x0108] = 'WM_YOMICHAR'
	$WM[0x0109] = 'WM_UNICHAR'
	$WM[0x010A] = 'WM_CONVERTREQUEST'
	$WM[0x010B] = 'WM_CONVERTRESULT'
	$WM[0x010C] = 'WM_IM_INFO'
	$WM[0x010D] = 'WM_IME_STARTCOMPOSITION'
	$WM[0x010E] = 'WM_IME_ENDCOMPOSITION'
	$WM[0x010F] = 'WM_IME_COMPOSITION'
	$WM[0x0110] = 'WM_INITDIALOG'
	$WM[0x0111] = 'WM_COMMAND'
	$WM[0x0112] = 'WM_SYSCOMMAND'
	$WM[0x0113] = 'WM_TIMER'
	$WM[0x0114] = 'WM_HSCROLL'
	$WM[0x0115] = 'WM_VSCROLL'
	$WM[0x0116] = 'WM_INITMENU'
	$WM[0x0117] = 'WM_INITMENUPOPUP'
	$WM[0x0118] = 'WM_SYSTIMER'
	$WM[0x0119] = 'WM_GESTURE'
	$WM[0x011A] = 'WM_GESTURENOTIFY'
	$WM[0x011B] = 'WM_GESTUREINPUT'
	$WM[0x011C] = 'WM_GESTURENOTIFIED'
	$WM[0x011F] = 'WM_MENUSELECT'
	$WM[0x0120] = 'WM_MENUCHAR'
	$WM[0x0121] = 'WM_ENTERIDLE'
	$WM[0x0122] = 'WM_MENURBUTTONUP'
	$WM[0x0123] = 'WM_MENUDRAG'
	$WM[0x0124] = 'WM_MENUGETOBJECT'
	$WM[0x0125] = 'WM_UNINITMENUPOPUP'
	$WM[0x0126] = 'WM_MENUCOMMAND'
	$WM[0x0127] = 'WM_CHANGEUISTATE'
	$WM[0x0128] = 'WM_UPDATEUISTATE'
	$WM[0x0129] = 'WM_QUERYUISTATE'
	$WM[0x0131] = 'WM_LBTRACKPOINT'
	$WM[0x0132] = 'WM_CTLCOLORMSGBOX'
	$WM[0x0133] = 'WM_CTLCOLOREDIT'
	$WM[0x0134] = 'WM_CTLCOLORLISTBOX'
	$WM[0x0135] = 'WM_CTLCOLORBTN'
	$WM[0x0136] = 'WM_CTLCOLORDLG'
	$WM[0x0137] = 'WM_CTLCOLORSCROLLBAR'
	$WM[0x0138] = 'WM_CTLCOLORSTATIC'
	$WM[0x0200] = 'WM_MOUSEMOVE'
	$WM[0x0201] = 'WM_LBUTTONDOWN'
	$WM[0x0202] = 'WM_LBUTTONUP'
	$WM[0x0203] = 'WM_LBUTTONDBLCLK'
	$WM[0x0204] = 'WM_RBUTTONDOWN'
	$WM[0x0205] = 'WM_RBUTTONUP'
	$WM[0x0206] = 'WM_RBUTTONDBLCLK'
	$WM[0x0207] = 'WM_MBUTTONDOWN'
	$WM[0x0208] = 'WM_MBUTTONUP'
	$WM[0x0209] = 'WM_MBUTTONDBLCLK'
	$WM[0x020A] = 'WM_MOUSEWHEEL'
	$WM[0x020B] = 'WM_XBUTTONDOWN'
	$WM[0x020C] = 'WM_XBUTTONUP'
	$WM[0x020D] = 'WM_XBUTTONDBLCLK'
	$WM[0x020E] = 'WM_MOUSEHWHEEL'
	$WM[0x0210] = 'WM_PARENTNOTIFY'
	$WM[0x0211] = 'WM_ENTERMENULOOP'
	$WM[0x0212] = 'WM_EXITMENULOOP'
	$WM[0x0213] = 'WM_NEXTMENU'
	$WM[0x0214] = 'WM_SIZING'
	$WM[0x0215] = 'WM_CAPTURECHANGED'
	$WM[0x0216] = 'WM_MOVING'
	$WM[0x0218] = 'WM_POWERBROADCAST'
	$WM[0x0219] = 'WM_DEVICECHANGE'
	$WM[0x0220] = 'WM_MDICREATE'
	$WM[0x0221] = 'WM_MDIDESTROY'
	$WM[0x0222] = 'WM_MDIACTIVATE'
	$WM[0x0223] = 'WM_MDIRESTORE'
	$WM[0x0224] = 'WM_MDINEXT'
	$WM[0x0225] = 'WM_MDIMAXIMIZE'
	$WM[0x0226] = 'WM_MDITILE'
	$WM[0x0227] = 'WM_MDICASCADE'
	$WM[0x0228] = 'WM_MDIICONARRANGE'
	$WM[0x0229] = 'WM_MDIGETACTIVE'
	$WM[0x022A] = 'WM_DROPOBJECT'
	$WM[0x022B] = 'WM_QUERYDROPOBJECT'
	$WM[0x022C] = 'WM_BEGINDRAG'
	$WM[0x022D] = 'WM_DRAGLOOP'
	$WM[0x022E] = 'WM_DRAGSELECT'
	$WM[0x022F] = 'WM_DRAGMOVE'
	$WM[0x0230] = 'WM_MDISETMENU'
	$WM[0x0231] = 'WM_ENTERSIZEMOVE'
	$WM[0x0232] = 'WM_EXITSIZEMOVE'
	$WM[0x0233] = 'WM_DROPFILES'
	$WM[0x0234] = 'WM_MDIREFRESHMENU'
	$WM[0x0240] = 'WM_TOUCH'
	$WM[0x0281] = 'WM_IME_SETCONTEXT'
	$WM[0x0282] = 'WM_IME_NOTIFY'
	$WM[0x0283] = 'WM_IME_CONTROL'
	$WM[0x0284] = 'WM_IME_COMPOSITIONFULL'
	$WM[0x0285] = 'WM_IME_SELECT'
	$WM[0x0286] = 'WM_IME_CHAR'
	$WM[0x0287] = 'WM_IME_SYSTEM'
	$WM[0x0288] = 'WM_IME_REQUEST'
	$WM[0x0290] = 'WM_IME_KEYDOWN'
	$WM[0x0291] = 'WM_IME_KEYUP'
	$WM[0x02A0] = 'WM_NCMOUSEHOVER'
	$WM[0x02A1] = 'WM_MOUSEHOVER'
	$WM[0x02A2] = 'WM_NCMOUSELEAVE'
	$WM[0x02A3] = 'WM_MOUSELEAVE'
	$WM[0x02B1] = 'WM_WTSSESSION_CHANGE'
	$WM[0x02C0] = 'WM_TABLET_FIRST'
	$WM[0x02DF] = 'WM_TABLET_LAST'
	$WM[0x0300] = 'WM_CUT'
	$WM[0x0301] = 'WM_COPY'
	$WM[0x0302] = 'WM_PASTE'
	$WM[0x0303] = 'WM_CLEAR'
	$WM[0x0304] = 'WM_UNDO'
	$WM[0x0305] = 'WM_RENDERFORMAT'
	$WM[0x0306] = 'WM_RENDERALLFORMATS'
	$WM[0x0307] = 'WM_DESTROYCLIPBOARD'
	$WM[0x0308] = 'WM_DRAWCLIPBOARD'
	$WM[0x0309] = 'WM_PAINTCLIPBOARD'
	$WM[0x030A] = 'WM_VSCROLLCLIPBOARD'
	$WM[0x030B] = 'WM_SIZECLIPBOARD'
	$WM[0x030C] = 'WM_ASKCBFORMATNAME'
	$WM[0x030D] = 'WM_CHANGECBCHAIN'
	$WM[0x030E] = 'WM_HSCROLLCLIPBOARD'
	$WM[0x030F] = 'WM_QUERYNEWPALETTE'
	$WM[0x0310] = 'WM_PALETTEISCHANGING'
	$WM[0x0311] = 'WM_PALETTECHANGED'
	$WM[0x0312] = 'WM_HOTKEY'
	$WM[0x0313] = 'WM_SYSMENU'
	$WM[0x0314] = 'WM_HOOKMSG'
	$WM[0x0315] = 'WM_EXITPROCESS'
	$WM[0x0316] = 'WM_WAKETHREAD'
	$WM[0x0317] = 'WM_PRINT'
	$WM[0x0318] = 'WM_PRINTCLIENT'
	$WM[0x0319] = 'WM_APPCOMMAND'
	$WM[0x031A] = 'WM_THEMECHANGED'
	$WM[0x031B] = 'WM_UAHINIT'
	$WM[0x031C] = 'WM_DESKTOPNOTIFY'
	$WM[0x031D] = 'WM_CLIPBOARDUPDATE'
	$WM[0x031E] = 'WM_DWMCOMPOSITIONCHANGED'
	$WM[0x031F] = 'WM_DWMNCRENDERINGCHANGED'
	$WM[0x0320] = 'WM_DWMCOLORIZATIONCOLORCHANGED'
	$WM[0x0321] = 'WM_DWMWINDOWMAXIMIZEDCHANGE'
	$WM[0x0322] = 'WM_DWMEXILEFRAME'
	$WM[0x0323] = 'WM_DWMSENDICONICTHUMBNAIL'
	$WM[0x0324] = 'WM_MAGNIFICATION_STARTED'
	$WM[0x0325] = 'WM_MAGNIFICATION_ENDED'
	$WM[0x0326] = 'WM_DWMSENDICONICLIVEPREVIEWBITMAP'
	$WM[0x0327] = 'WM_DWMTHUMBNAILSIZECHANGED'
	$WM[0x0328] = 'WM_MAGNIFICATION_OUTPUT'
	$WM[0x0330] = 'WM_MEASURECONTROL'
	$WM[0x0331] = 'WM_GETACTIONTEXT'
	$WM[0x0333] = 'WM_FORWARDKEYDOWN'
	$WM[0x0334] = 'WM_FORWARDKEYUP'
	$WM[0x033F] = 'WM_GETTITLEBARINFOEX'
	$WM[0x0340] = 'WM_NOTIFYWOW'
	$WM[0x0358] = 'WM_HANDHELDFIRST'
	$WM[0x035F] = 'WM_HANDHELDLAST'
	$WM[0x0360] = 'WM_AFXFIRST'
	$WM[0x037F] = 'WM_AFXLAST'
	$WM[0x0380] = 'WM_PENWINFIRST'
	$WM[0x038F] = 'WM_PENWINLAST'
	$WM[0x03E0] = 'WM_DDE_INITIATE'
	$WM[0x03E1] = 'WM_DDE_TERMINATE'
	$WM[0x03E2] = 'WM_DDE_ADVISE'
	$WM[0x03E3] = 'WM_DDE_UNADVISE'
	$WM[0x03E4] = 'WM_DDE_ACK'
	$WM[0x03E5] = 'WM_DDE_DATA'
	$WM[0x03E6] = 'WM_DDE_REQUEST'
	$WM[0x03E7] = 'WM_DDE_POKE'
	$WM[0x03E8] = 'WM_DDE_EXECUTE'
	$WM[0x03FD] = 'WM_DBNOTIFICATION'
	$WM[0x03FE] = 'WM_NETCONNECT'
	$WM[0x03FF] = 'WM_HIBERNATE'
	Return $WM
EndFunc   ;==>__WMGetArray

Func __WMHex64(ByRef $iValue)
	If Not StringLen($iValue) Then
		Return ''
	EndIf
	DllStructSetData($__tInt64, 1, $iValue)
	If @AutoItX64 Then
		Return StringRight(Hex(DllStructGetData($__tDWord, 2)) & Hex(DllStructGetData($__tDWord, 1)), 16)
	Else
		Return StringRight(Hex(DllStructGetData($__tDWord, 2)) & Hex(DllStructGetData($__tDWord, 1)), 8)
	EndIf
EndFunc   ;==>__WMHex64

#EndRegion Internal Functions
