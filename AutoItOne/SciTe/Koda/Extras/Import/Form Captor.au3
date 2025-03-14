#include <Constants.au3>
#include <ButtonConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>

#NoTrayIcon

;===============================================================================
;
; This file is part of Koda package
;
; This is an example of import plugin, this capture form layout 
; from existing window (only with standard Microsoft controls)
;
; Used for learning: 
; http://www.codeproject.com/dialog/windowfinder.asp
;
; Required Autoit 3.2.10.0 or higher
;
; Version: 0.91 (2008-09-30)
; 
;===============================================================================


;===============================================================================
; This is mandatory code, plugin should not do actual conversion 
; when /info parameter passed. Refer readme.txt file in the same folder.
;===============================================================================
If $CmdLine[0] = 1 AND $CmdLine[1] = "/info" Then
    ConsoleWrite("<!--DESCR:Capture form layout from existing window (only with standard controls)-->")
    Exit
EndIf

;===============================================================================
; Initializing resources
;===============================================================================
Global $CURSOR_TARGET = _WriteResource( _
"0x000002000100202000000F001000300100001600000028000000200000004000000001000100000000008000" & _
"00000000000000000000020000000200000000000000FFFFFF0000000000000000000000000000000000000000" & _
"000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000" & _
"000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000" & _
"00000000000000000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF" & _
"FFFFFFF83FFFFFE6CFFFFFD837FFFFBEFBFFFF783DFFFF7EFDFFFEAC6AFFFEABAAFFFE0280FFFEABAAFFFEAC6A" & _
"FFFF7EFDFFFF783DFFFFBEFBFFFFD837FFFFE6CFFFFFF83FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF" & _
"FFFFFFFFFFFFFFFFFFFFFFFF")
Global $ICON_TARGET_FULL = _WriteResource( _
"0x0000010001002020080000000000E80200001600000028000000200000004000000001000400000000000002" & _
"000000000000000000001000000010000000000000000000800000800000008080008000000080008000808000" & _
"00C0C0C000808080000000FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF000000000000000000" & _
"00000000000000000000000000000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFF000FFFFFFFF" & _
"FFFFFFFFFFFFFFFFFFFFF000FFFFFFFFFFFF00000FFFFFFFFFFFF000FFFFFFFFFF00FF0FF00FFFFFFFFFF000FF" & _
"FFFFFFF0FF00000FF0FFFFFFFFF000FFFFFFFF0FFFFF0FFFFF0FFFFFFFF000FFFFFFF0FFFF00000FFFF0FFFFFF" & _
"F000FFFFFFF0FFFFFF0FFFFFF0FFFFFFF000FFFFFF0F0F0FF000FF0F0F0FFFFFF000FFFFFF0F0F0F0FFF0F0F0F" & _
"0FFFFFF000FFFFFF0000000F0F0000000FFFFFF000FFFFFF0F0F0F0FFF0F0F0F0FFFFFF000FFFFFF0F0F0FF000" & _
"FF0F0F0FFFFFF000FFFFFFF0FFFFFF0FFFFFF0FFFFFFF000FFFFFFF0FFFF00000FFFF0FFFFFFF000FFFFFFFF0F" & _
"FFFF0FFFFF0FFFFFFFF000FFFFFFFFF0FF00000FF0FFFFFFFFF000FFFFFFFFFF00FF0FF00FFFFFFFFFF000FFFF" & _
"FFFFFFFF00000FFFFFFFFFFFF000FFFFFFFFFFFFFFFFFFFFFFFFFFFFF000FFFFFFFFFFFFFFFFFFFFFFFFFFFFF0" & _
"00FFFFFFFFFFFFFFFFFFFFFFFFFFFFF000000000000000000000000000000000007770CCCCCCCCCCCCCCCCCCCC" & _
"C07770007070CCCCCCCCCCCCCCCCCCCCC07070007770CCCCCCCCCCCCCCCCCCCCC0777000000000000000000000" & _
"000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000" & _
"000000000000000000FFFFFFFF8000000080000000800000008000000080000000800000008000000080000000" & _
"800000008000000080000000800000008000000080000000800000008000000080000000800000008000000080" & _
"0000008000000080000000800000008000000080000000800000008000000080000000FFFFFFFFFFFFFFFFFFFF" & _
"FFFF")
Global $ICON_TARGET_EMPTY = _WriteResource( _
"0x0000010001002020080000000000E80200001600000028000000200000004000000001000400000000000002" & _
"000000000000000000001000000010000000000000000000800000800000008080008000000080008000808000" & _
"00C0C0C000808080000000FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF000000000000000000" & _
"00000000000000000000000000000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFF000FFFFFFFF" & _
"FFFFFFFFFFFFFFFFFFFFF000FFFFFFFFFFFFFFFFFFFFFFFFFFFFF000FFFFFFFFFFFFFFFFFFFFFFFFFFFFF000FF" & _
"FFFFFFFFFFFFFFFFFFFFFFFFFFF000FFFFFFFFFFFFFFFFFFFFFFFFFFFFF000FFFFFFFFFFFFFFFFFFFFFFFFFFFF" & _
"F000FFFFFFFFFFFFFFFFFFFFFFFFFFFFF000FFFFFFFFFFFFFFFFFFFFFFFFFFFFF000FFFFFFFFFFFFFFFFFFFFFF" & _
"FFFFFFF000FFFFFFFFFFFFFFFFFFFFFFFFFFFFF000FFFFFFFFFFFFFFFFFFFFFFFFFFFFF000FFFFFFFFFFFFFFFF" & _
"FFFFFFFFFFFFF000FFFFFFFFFFFFFFFFFFFFFFFFFFFFF000FFFFFFFFFFFFFFFFFFFFFFFFFFFFF000FFFFFFFFFF" & _
"FFFFFFFFFFFFFFFFFFF000FFFFFFFFFFFFFFFFFFFFFFFFFFFFF000FFFFFFFFFFFFFFFFFFFFFFFFFFFFF000FFFF" & _
"FFFFFFFFFFFFFFFFFFFFFFFFF000FFFFFFFFFFFFFFFFFFFFFFFFFFFFF000FFFFFFFFFFFFFFFFFFFFFFFFFFFFF0" & _
"00FFFFFFFFFFFFFFFFFFFFFFFFFFFFF000000000000000000000000000000000007770CCCCCCCCCCCCCCCCCCCC" & _
"C07770007070CCCCCCCCCCCCCCCCCCCCC07070007770CCCCCCCCCCCCCCCCCCCCC0777000000000000000000000" & _
"000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000" & _
"000000000000000000FFFFFFFF8000000080000000800000008000000080000000800000008000000080000000" & _
"800000008000000080000000800000008000000080000000800000008000000080000000800000008000000080" & _
"0000008000000080000000800000008000000080000000800000008000000080000000FFFFFFFFFFFFFFFFFFFF" & _
"FFFF")

; Loading cursor from file
$hTargetCursor = DllCall("User32.dll", "int", "LoadCursorFromFile", "str", $CURSOR_TARGET)
$hTargetCursor = $hTargetCursor[0]

;===============================================================================
; Start of finder code
;===============================================================================

Global $g_StartSearch = False, $gFoundWindow = 0, $gOldCursor
;Global $WM_MOUSEMOVE = 0x200
;Global $WM_LBUTTONUP = 0x202

#Region ### START Koda GUI section ### Form=Form Captor.kxf
$hGUI = GUICreate("Form Captor", 586, 104, -1, -1, -1, $WS_EX_TOPMOST)
GUICtrlCreateGroup("Target", 80, 0, 497, 65)
GUICtrlCreateLabel("Title:", 101, 18, 27, 17, $SS_RIGHT)
GUICtrlCreateLabel("Handle:", 87, 42, 41, 17, $SS_RIGHT)
$hLabelTitle = GUICtrlCreateLabel("", 133, 18, 436, 17, $SS_SIMPLE)
$hLabelWnd = GUICtrlCreateLabel("", 133, 42, 100, 17)
GUICtrlCreateLabel("Class:", 240, 42, 32, 17)
$hLabelClass = GUICtrlCreateLabel("", 272, 42, 300, 17, $SS_SIMPLE)
GUICtrlCreateGroup("", -99, -99, 1, 1)
GUICtrlCreateGroup("", 8, 0, 65, 65)
$hTargetPic = GUICtrlCreateIcon($ICON_TARGET_FULL, 0, 24, 20, 32, 32, BitOR($SS_NOTIFY,$WS_GROUP))
GUICtrlCreateGroup("", -99, -99, 1, 1)
$hOK = GUICtrlCreateButton("OK", 424, 72, 75, 25, 0)
$hCancel = GUICtrlCreateButton("Cancel", 504, 72, 75, 25, 0)
GUICtrlCreateLabel("Choose window and click OK to process", 8, 78, 195, 17)
GUISetState(@SW_SHOW)
#EndRegion ### END Koda GUI section ###

GUIRegisterMsg ($WM_MOUSEMOVE, "WM_MOUSEMOVE_FUNC")
GUIRegisterMsg ($WM_LBUTTONUP, "WM_LBUTTONUP_FUNC")

While 1
    $nMsg = GUIGetMsg()
    Switch $nMsg
        Case $GUI_EVENT_CLOSE, $hCancel
            Exit
        Case $hTargetPic
            $g_StartSearch = True
            DllCall("user32.dll", "hwnd", "SetCapture", "hwnd", $hGUI)
            $gOldCursor = DllCall("user32.dll", "int", "SetCursor", "int", $hTargetCursor)
            If not @error Then $gOldCursor = $gOldCursor[0]
            GUICtrlSetImage($hTargetPic, $ICON_TARGET_EMPTY)
        Case $hOK
            If not WinExists($gFoundWindow) Then 
                ConsoleWrite("ERROR>>>Selected window no more exists!")
                Exit
            EndIf
            GUIDelete($hGUI)
            Exitloop
    EndSwitch
Wend

;===============================================================================
; Start of conversion code
;===============================================================================
Global $aNames = ""
;Global $BS_RADIOBUTTON = 0x4
Global $nTopOffset = 0

$hWindow = $gFoundWindow
Global $aWinPos = WinGetPos($hWindow)
Global $aClientPos = WinGetClientSize($hWindow)
Global $nStyle   = _GetWindowLong($hWindow, $GWL_STYLE) 
Global $nExStyle = _GetWindowLong($hWindow, $GWL_EXSTYLE) 

$hMainMenu = _GetMenu($hWindow)
If $hMainMenu <> 0 Then $nTopOffset = _GetSystemMetrics($SM_CYMENUSIZE)

; Start writing GUI block
ConsoleWrite('<object type="TAForm" level="1"')
$sWindowClass = StringRegExpReplace(_GetWindowClass($hWindow), ":|\s|#", "")
If StringIsDigit($sWindowClass) Then $sWindowClass = "Form" & $sWindowClass
_WriteProp("name", $sWindowClass)
_WriteProp("Caption", _TextAddEntity(WinGetTitle($hWindow)))
_WriteProp("Left", $aWinPos[0])
_WriteProp("Top", $aWinPos[1])
_WriteProp("ClientHeight", $aClientPos[1] + _GetSystemMetrics($SM_CYBORDER)*2)
_WriteProp("Width", $aWinPos[2])
_WriteProp("Height", $aWinPos[3])
_WriteProp("Style", $nStyle)
_WriteProp("ExStyle", $nExStyle)
_WriteProp("Visible", "True")
ConsoleWrite(">" & @CRLF)

; Finding child controls
$hEnumChildProc = DllCallbackRegister("EnumChildProc", "int", "hwnd;lparam")
DllCall("user32.dll", "int", "EnumChildWindows", _
                      "hwnd", $hWindow, _
                      "ptr", DllCallbackGetPtr($hEnumChildProc), _
                      "lparam", 0)
DllCallbackFree($hEnumChildProc)
; Closing GUI block
ConsoleWrite("</object>")

;===============================================================================
; Callback function, writing child controls being found
;===============================================================================
Func EnumChildProc($hWnd, $lParam)
    Local $sText = ""
    Local $ret = DllCall("user32.dll", "long", "SendMessage", "hwnd", $hWnd, "int", $WM_GETTEXT, "int", 32767, "str", $sText)
    If IsArray($ret) Then $sText = $ret[4]
    
    Local $nCtrlStyle   = _GetWindowLong($hWnd, $GWL_STYLE) 
    Local $nCtrlExStyle = _GetWindowLong($hWnd, $GWL_EXSTYLE)
    Local $sCtrlClass   = _GetWindowClass($hWnd)
    Local $sCtrlType    = _GetControlType($sCtrlClass, $nCtrlStyle)
    If $sCtrlType = "" Then 
        ConsoleWrite('<!--WARNING:Warning: unsupported control found. Skipped.-->')
        Return 1
    EndIf

    Local $aCtrlPos = WinGetPos($hWnd)
    Local $pPoint = DllStructCreate("int;int")
    DllStructSetData($pPoint, 1, $aCtrlPos[0])
    DllStructSetData($pPoint, 2, $aCtrlPos[1])
	DllCall("User32.dll", "int", "ScreenToClient", "hwnd", $hWindow, "ptr", DllStructGetPtr($pPoint))
    $aCtrlPos[0] = DllStructGetData($pPoint, 1)  
    $aCtrlPos[1] = DllStructGetData($pPoint, 2) + $nTopOffset

    ; No more warnings after this line
    
    ConsoleWrite('<object')
    
    ; Found unique name for control
    Local $nInstance = 1
    While StringInStr($aNames, $sCtrlType & $nInstance) 
       $nInstance += 1
    Wend
    $aNames &= $sCtrlType & $nInstance & "|"

    _WriteProp("name", $sCtrlType & $nInstance)
    _WriteProp("type", "TA" & $sCtrlType)

    If $sCtrlType = "Label" Then _WriteProp("AutoSize", "False")

    Switch $sCtrlClass
        Case "Button", "Static"
            _WriteProp("Caption", _TextAddEntity($sText))
        Case "Edit"
            _WriteProp("Text", _TextAddEntity($sText))
    EndSwitch

    _WriteProp("Left",   $aCtrlPos[0])
    _WriteProp("Top",    $aCtrlPos[1])
    _WriteProp("Width",  $aCtrlPos[2])
    _WriteProp("Height", $aCtrlPos[3])
    If BitAND($nCtrlStyle, $WS_DISABLED) Then
        $nCtrlStyle = BitAND($nCtrlStyle, BitNOT($WS_DISABLED))
        _WriteProp("Enabled", "False")
    EndIf
    If not BitAND($nCtrlStyle, $WS_VISIBLE) Then
        _WriteProp("Visible", "False")
    EndIf
    If BitAND($nCtrlStyle, 0xF) = $BS_RADIOBUTTON Then 
        $nCtrlStyle = $nCtrlStyle - $BS_RADIOBUTTON + $BS_AUTORADIOBUTTON
    EndIf
    _WriteProp("CtrlStyle", $nCtrlStyle)
    _WriteProp("CtrlExStyle", $nCtrlExStyle)
    ConsoleWrite("/>" & @CRLF)
    Return 1
EndFunc

;===============================================================================
; Write icons and cursor
;===============================================================================
Func _WriteResource($sbStringRes)
    Local $sTempFile
    Do
        $sTempFile = @TempDir & "\temp" & Hex(Random(0, 65535), 4)
    Until not FileExists($sTempFile)
    Local $hFile = FileOpen($sTempFile, 2+16)
    FileWrite($hFile, $sbStringRes)
    FileClose($hFile)
    Return $sTempFile
EndFunc

;===============================================================================
; Finder related support functions
;===============================================================================
Func WM_MOUSEMOVE_FUNC($hWnd, $nMsg, $wParam, $lParam)
    If not $g_StartSearch Then Return 1
    Local $mPos = MouseGetPos()
    $hWndUnder = DllCall("user32.dll", "hwnd", "WindowFromPoint", "long", $mPos[0], "long", $mPos[1])
    If not @error Then $hWndUnder = $hWndUnder[0]
    If _CheckFoundWindow($hWndUnder) Then
        GUICtrlSetData($hLabelTitle, WinGetTitle($hWndUnder))
        GUICtrlSetData($hLabelWnd, $hWndUnder)
        GUICtrlSetData($hLabelClass, _GetWindowClass($hWndUnder))
        $gFoundWindow = $hWndUnder
    EndIf
    Return 1
EndFunc

Func WM_LBUTTONUP_FUNC($hWnd, $nMsg, $wParam, $lParam)
    If not $g_StartSearch Then Return 1
    $g_StartSearch = False
    ; Release captured cursor
    DllCall("user32.dll", "int", "ReleaseCapture")
    DllCall("user32.dll", "int", "SetCursor", "int", $gOldCursor)
    GUICtrlSetImage($hTargetPic, $ICON_TARGET_FULL)
;    MsgBox (0, "title", "text")
    Return 1
EndFunc

Func _CheckFoundWindow($hFoundWnd)
  If $hFoundWnd = $hGUI Then Return False
  If $hFoundWnd = 0 Then Return False
  If $hFoundWnd = $gFoundWindow Then Return False
  If not WinExists($hFoundWnd) Then Return False
  Local $hTemp = DllCall("user32.dll", "hwnd", "GetParent", "hwnd", $hFoundWnd)
  If not @error and $hTemp[0] = $hGUI Then Return False
  Return True
EndFunc

;===============================================================================
; Converter related support functions
;===============================================================================
Func _WriteProp($sName, $sValue)
    ConsoleWrite(' ' & $sName & '="' & $sValue & '"')
EndFunc

Func _TextAddEntity($sText)
    Local $Result = StringReplace($sText, "&", "&amp;")
    $Result = StringReplace($Result, "<", "&lt;")   
    $Result = StringReplace($Result, ">", "&gt;")   
    Return $Result
EndFunc

Func _GetControlType($sClassName, $nStyle)
    Switch $sClassName
        Case "Static"
            Switch BitAND($nStyle, 0xF)
                Case 0xE ; Picture
                    Return "Pic"
                Case 0x3
                    Return "Icon"
                Case Else
                    Return "Label"
            EndSwitch
        Case "Button"
            Switch BitAND($nStyle, 0xF)
                Case $BS_GROUPBOX
                    Return "Group"
                Case $BS_CHECKBOX, $BS_AUTOCHECKBOX, $BS_3STATE, $BS_AUTO3STATE
                    Return "Checkbox"
                Case $BS_RADIOBUTTON, $BS_AUTORADIOBUTTON
                    Return "Radio"
                Case Else
                    Return "Button"
            EndSwitch
        Case "Edit"
            If BitAND($nStyle, $ES_MULTILINE) Then Return "Edit"  
            Return "Input"
        Case "msctls_progress32"
            Return "Progress"
        Case "msctls_trackbar32"
            Return "Slider"
        Case "SysDateTimePick"
            Return "Date"            
        Case "SysMonthCal"
            Return "MonthCal"
        Case "SysListView"
            Return "ListView"
        Case "SysTreeView"
            Return "TreeView"
        Case "Combo", "List"
            Return $sClassName
        Case Else
            Return ""
    EndSwitch
EndFunc

;===============================================================================
; Wrappers
;===============================================================================
Func _GetWindowClass($hWnd)
    $pClassName = DllStructCreate("char[256]")
    DllCall("user32.dll", "int", "GetClassName", "hwnd", $hWnd, "ptr", DllStructGetPtr($pClassName), "int", 255)
    Return DllStructGetData($pClassName, 1)
EndFunc

Func _GetSystemMetrics($nParam) 
    Local $ret = DllCall("user32", "int", "GetSystemMetrics", "int", $nParam)
    If not @error Then Return $ret[0]
EndFunc

Func _GetWindowLong($hWnd, $nParam) 
    Local $ret = DllCall("user32", "int", "GetWindowLong", "hWnd", $hWnd, "int", $nParam)
    If not @error Then Return $ret[0]
EndFunc

Func _GetMenu($hWnd)
  Local $ret = DllCall("user32", "hwnd", "GetMenu", "hwnd", $hWnd)
  Return $ret[0]
EndFunc

;===============================================================================
; OnExit handler
;===============================================================================
Func OnAutoitExit()
    ; Standard @exitcode doesn't work... 
    If IsDeclared("CURSOR_TARGET") Then
        FileDelete($ICON_TARGET_FULL)
        FileDelete($ICON_TARGET_EMPTY)
        FileDelete($CURSOR_TARGET)
    EndIf
EndFunc
