#NoTrayIcon
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=Desktop.ico
#AutoIt3Wrapper_Outfile=ICU_32bit.exe
#AutoIt3Wrapper_Outfile_x64=ICU_64bit.exe
#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_UseUpx=n
#AutoIt3Wrapper_Compile_Both=y
#AutoIt3Wrapper_UseX64=y
#AutoIt3Wrapper_Res_Comment=© ICU - Icon Configuration Utility 2009-2013 by Karsten Funk. All rights reserved. http://www.funk.eu
#AutoIt3Wrapper_Res_Description=Icon Configuration Utility
#AutoIt3Wrapper_Res_Fileversion=5.0.0.0
#AutoIt3Wrapper_Res_LegalCopyright=Creative Commons License "by-nc-sa 3.0", this program is freeware under Creative Commons License "by-nc-sa 3.0" (http://creativecommons.org/licenses/by-nc-sa/3.0/us/)
#AutoIt3Wrapper_Res_requestedExecutionLevel=asInvoker
#AutoIt3Wrapper_Res_Field=ProductName|ICU
#AutoIt3Wrapper_Res_Field=AutoIt Version|%AutoItVer%
#AutoIt3Wrapper_Res_Field=Compile Date|%date% %time%
#AutoIt3Wrapper_Res_Field=Made By|Karsten Funk
#AutoIt3Wrapper_Run_AU3Check=n
#AutoIt3Wrapper_Tidy_Stop_OnError=n
#Obfuscator_Parameters=/sf /sv /om /cs=0 /cn=0
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

#region DllOpen_PostProcessor START
Global $0 = DllOpen("kernel32.dll")
Global $1 = DllOpen("user32.dll")
Global $2 = DllOpen("advapi32.dll")
Global $3 = DllOpen("gdi32.dll")
Global $4 = DllOpen("ole32.dll")
Global $5 = DllOpen("oleaut32.dll")
Global $6 = DllOpen("Crypt32.dll")
#region DllOpen_PostProcessor END
Global $7 = $CmdLineRaw
Global $8[$CmdLine[0] + 1]
$8[0] = $CmdLine[0]
For $9 = 1 To $8[0]
$8[$9] = $CmdLine[$9]
Next
Global $a
Global $b = "ICU - Icon Configuration Utility v5"
Global $c = "ICU_v_5"
Global $d, $e, $f
Global $g = False, $h = False
Opt("GUICloseOnESC", 0)
Opt("TrayOnEventMode", 1)
Opt("TrayMenuMode", 1 + 2 + 4 + 8)
Opt("TrayAutoPause", 0)
If @OSArch = "X64" And Not @AutoItX64 Then
_3e("Fatal Error" & @CRLF & "This version of ICU is 32bit compiled and will not run correctly with a 64bit OS.")
ElseIf @OSArch <> "X64" And @AutoItX64 Then
_3e("Fatal Error" & @CRLF & "This version of ICU is 64bit compiled and will not run correctly with a 32bit OS.")
EndIf
If Not @AutoItX64 Then
$b &= " - 32bit"
Else
$b &= " - 64bit"
EndIf
If Not @Compiled Then $7 = ""
If Not StringLen($7) Or StringInStr($7, "minimized") Then
If StringInStr($7, "minimized") Then
$8[0] = 0
$7 = "minimized"
EndIf
_2m('398cba7a-eca3-4470-a937-f0960a4595cb')
Else
_2m('498cba7a-eca3-4470-a937-f0960a4595cb')
EndIf
If StringInStr($7, "%resolution%") Then
$7 = StringReplace($7, "%resolution%", @DesktopWidth & "x" & @DesktopHeight & "x" & @DesktopDepth)
For $9 = 1 To $8[0]
$8[$9] = StringReplace($8[$9], "%resolution%", @DesktopWidth & "x" & @DesktopHeight & "x" & @DesktopDepth)
Next
EndIf
Global $i = 0xFF4500
Global $j = 0x32CD32
Global Const $k = 64
Global Const $l = 128
Global Const $m = 2048
Global Const $n = 4096
Global Const $o = 0x00200000
Global Const $p = 0x00100000
Global Const $q = BitOR($n, $o, $p, $k, $l)
Global Const $r = -3
Global Const $s = -4
Global Const $t = 'GUI_RUNDEFMSG'
Global Const $u = 1
Global Const $v = 4
Global Const $w = 64
Global Const $x = 128
Global Const $y = 512
Global Const $0z = -2
Global Const $10 = 0xFE000000
Global Const $11 = 0x1
Global Const $12 = 0x0100
Global Const $13 = 0x0200
Global Const $14 = 0x40
Global Const $15 = 0x2
Global Const $16 = 0x3
Global Const $17 = 0x00200000
Global Const $18 = BitOR($15, $14, $17)
Global Const $19 = 0x00020000
Global Const $1a = 0x00080000
Global Const $1b = 0x00200000
Global Const $1c = 0x00C00000
Global Const $1d = 0x80000000
Global Const $1e = 0x00000080
Global Const $1f = 0x00000008
Global Const $1g = 0x00080000
Global Const $1h = 0x004E
Global Const $1i = 0x007B
Global Const $1j = 0x0111
Global Const $1k = 0x0201
Global Const $1l = 0x0202
Global Const $1m = BitOR($19, $1c, $1d, $1a)
Global Const $1n = 0x0100
Global Const $1o = 0x0004
Global Const $1p = 0x00000020
Global Const $1q = 0x00080000
Global Const $1r = 0x00000008
Global Const $1s = 0x00000010
Global Const $1t = 0x00000001
Global Const $1u = 0x00000002
Global Const $1v = 0x00000004
Global Const $1w = 0x00000008
Global Const $1x = 0x00000040
Global Const $1y = 0x00000020
Global Const $1z = BitOR($1u, $1v, $1w)
Global Const $20 = 0x10000000
Global Const $21 = 0x20000000
Global Const $22 = 0x40000000
Global Const $23 = 0x80000000
Global Const $24 = 0x01000000
Global Const $25 = 0x02000000
Global Const $26 = BitOR($23, $22, $21, $20, $24, $25)
Global Const $27 = 0x00000100
Global Const $28 = 0x00000002
Global Const $29 = 0x00000010
Global Const $2a = 0x00000004
Global Const $2b = 0x00000008
Global Const $2c = 0x0004
Global Const $2d = 0x0008
Global Const $2e = 0x0001
Global Const $2f = 0x0F00
Global Const $2g = 0x0002
Global Const $2h = 0xF000
Global Const $2i = 0x1000
Global Const $2j =($2i + 9)
Global Const $2k =($2i + 55)
Global Const $2l =($2i + 5)
Global Const $2m =($2i + 75)
Global Const $2n =($2i + 4)
Global Const $2o =($2i + 16)
Global Const $2p =($2i + 44)
Global Const $2q =($2i + 45)
Global Const $2r =($2i + 115)
Global Const $2s = 0x2000 + 6
Global Const $2t =($2i + 18)
Global Const $2u =($2i + 30)
Global Const $2v =($2i + 15)
Global Const $2w =($2i + 43)
Global Const $2x = -100
Global Const $2y =($2x - 14)
Global Const $2z = -2
Global Const $30 = 0x0002
Global Const $31 = 0x00001000
Global Const $32 = 0x00002000
Global Const $33 = 0x00000004
Global Const $34 = 0x00008000
Global Const $35 = "struct;long X;long Y;endstruct"
Global Const $36 = "struct;long Left;long Top;long Right;long Bottom;endstruct"
Global Const $37 = "struct;hwnd hWndFrom;uint_ptr IDFrom;INT Code;endstruct"
Global Const $38 = "uint Width;uint Height;int Stride;int Format;ptr Scan0;uint_ptr Reserved"
Global Const $39 = "uint Version;ptr Callback;bool NoThread;bool NoCodecs"
Global Const $3a = $35 & ";uint Flags;int Item;int SubItem;int iGroup"
Global Const $3b = "struct;uint Mask;int Item;int SubItem;uint State;uint StateMask;ptr Text;int TextMax;int Image;lparam Param;" & "int Indent;int GroupID;uint Columns;ptr pColumns;ptr piColFmt;int iGroup;endstruct"
Global Const $3c = "dword Count;align 4;int64 LUID;dword Attributes"
Global Const $3d = "dword Size;INT Mask;dword Style;uint YMax;handle hBack;dword ContextHelpID;ulong_ptr MenuData"
Global Const $3e = "uint Size;uint Mask;uint Type;uint State;uint ID;handle SubMenu;handle BmpChecked;handle BmpUnchecked;" & "ulong_ptr ItemData;ptr TypeData;uint CCH;handle BmpItem"
Global Const $3f = 0x00000008
Global Const $3g = 0x00000010
Global Const $3h = 0x00000020
Global Const $3i = 1008
Global Const $3j = 0x00000002
Global Enum $3k = 0, $3l, $3m, $3n
Global Const $3o = 0x00000008
Global Const $3p = 0x00000020
Func _5($3q = @error, $3r = @extended)
Local $3s = DllCall("kernel32.dll", "dword", "GetLastError")
Return SetError($3q, $3r, $3s[0])
EndFunc
Func _6($3t, $3u, $3v = 0, $3w = 0, $3x = 0, $3y = "wparam", $3z = "lparam", $40 = "lresult")
Local $3s = DllCall("user32.dll", $40, "SendMessageW", "hwnd", $3t, "uint", $3u, $3y, $3v, $3z, $3w)
If @error Then Return SetError(@error, @extended, "")
If $3x >= 0 And $3x <= 4 Then Return $3s[$3x]
Return $3s
EndFunc
Global $41[64][2] = [[0, 0]]
Global Const $42 = Ptr(-1)
Global Const $43 = Ptr(-1)
Global Const $44 = 14
Global Const $45 = 0x0100
Global Const $46 = 0x2000
Global Const $47 = 0x8000
Global Const $48 = BitShift($45, 8)
Global Const $49 = BitShift($46, 8)
Global Const $4a = BitShift($47, 8)
Func _7($4b, $4c, $3v, $3w)
Local $3s = DllCall("user32.dll", "lresult", "CallNextHookEx", "handle", $4b, "int", $4c, "wparam", $3v, "lparam", $3w)
If @error Then Return SetError(@error, @extended, -1)
Return $3s[0]
EndFunc
Func _8($4d)
Local $3s = DllCall("gdi32.dll", "bool", "DeleteObject", "handle", $4d)
If @error Then Return SetError(@error, @extended, False)
Return $3s[0]
EndFunc
Func _9($3t)
If Not IsHWnd($3t) Then $3t = GUICtrlGetHandle($3t)
Local $3s = DllCall("user32.dll", "int", "GetClassNameW", "hwnd", $3t, "wstr", "", "int", 4096)
If @error Then Return SetError(@error, @extended, False)
Return SetExtended($3s[0], $3s[2])
EndFunc
Func _a()
Local $3s = DllCall("kernel32.dll", "handle", "GetCurrentThread")
If @error Then Return SetError(@error, @extended, 0)
Return $3s[0]
EndFunc
Func _b($4e)
Local $4f = "wstr"
If $4e = "" Then
$4e = 0
$4f = "ptr"
EndIf
Local $3s = DllCall("kernel32.dll", "handle", "GetModuleHandleW", $4f, $4e)
If @error Then Return SetError(@error, @extended, 0)
Return $3s[0]
EndFunc
Func _c($4g = False, $3t = 0)
Local $4h = Opt("MouseCoordMode", 1)
Local $4i = MouseGetPos()
Opt("MouseCoordMode", $4h)
Local $4j = DllStructCreate($35)
DllStructSetData($4j, "X", $4i[0])
DllStructSetData($4j, "Y", $4i[1])
If $4g Then
_k($3t, $4j)
If @error Then Return SetError(@error, @extended, 0)
EndIf
Return $4j
EndFunc
Func _d($4g = False, $3t = 0)
Local $4j = _c($4g, $3t)
If @error Then Return SetError(@error, @extended, 0)
Return DllStructGetData($4j, "X")
EndFunc
Func _e($4g = False, $3t = 0)
Local $4j = _c($4g, $3t)
If @error Then Return SetError(@error, @extended, 0)
Return DllStructGetData($4j, "Y")
EndFunc
Func _f($3t, $4k)
Local $4l = "GetWindowLongW"
If @AutoItX64 Then $4l = "GetWindowLongPtrW"
Local $3s = DllCall("user32.dll", "long_ptr", $4l, "hwnd", $3t, "int", $4k)
If @error Then Return SetError(@error, @extended, 0)
Return $3s[0]
EndFunc
Func _g($3t, ByRef $4m)
Local $3s = DllCall("user32.dll", "dword", "GetWindowThreadProcessId", "hwnd", $3t, "dword*", 0)
If @error Then Return SetError(@error, @extended, 0)
$4m = $3s[2]
Return $3s[0]
EndFunc
Func _h($3t, ByRef $4n)
If $3t = $4n Then Return True
For $4o = $41[0][0] To 1 Step -1
If $3t = $41[$4o][0] Then
If $41[$4o][1] Then
$4n = $3t
Return True
Else
Return False
EndIf
EndIf
Next
Local $4p
_g($3t, $4p)
Local $4q = $41[0][0] + 1
If $4q >= 64 Then $4q = 1
$41[0][0] = $4q
$41[$4q][0] = $3t
$41[$4q][1] =($4p = @AutoItPID)
Return $41[$4q][1]
EndFunc
Func _i($3t, $4r)
Local $4s = Opt("GUIDataSeparatorChar")
Local $4t = StringSplit($4r, $4s)
If Not IsHWnd($3t) Then $3t = GUICtrlGetHandle($3t)
Local $4u = _9($3t)
For $4v = 1 To UBound($4t) - 1
If StringUpper(StringMid($4u, 1, StringLen($4t[$4v]))) = StringUpper($4t[$4v]) Then Return True
Next
Return False
EndFunc
Func _j($4w, $4x)
Return BitOR(BitShift($4x, -16), BitAND($4w, 0xFFFF))
EndFunc
Func _k($3t, ByRef $4j)
Local $3s = DllCall("user32.dll", "bool", "ScreenToClient", "hwnd", $3t, "struct*", $4j)
If @error Then Return SetError(@error, @extended, False)
Return $3s[0]
EndFunc
Func _l($3t, $4y, $4z = 255, $50 = 0x03, $51 = False)
If $50 = Default Or $50 = "" Or $50 < 0 Then $50 = 0x03
If Not $51 Then
$4y = Int(BinaryMid($4y, 3, 1) & BinaryMid($4y, 2, 1) & BinaryMid($4y, 1, 1))
EndIf
Local $3s = DllCall("user32.dll", "bool", "SetLayeredWindowAttributes", "hwnd", $3t, "dword", $4y, "byte", $4z, "dword", $50)
If @error Then Return SetError(@error, @extended, False)
Return $3s[0]
EndFunc
Func _m($52, $53, $54, $55 = 0)
Local $3s = DllCall("user32.dll", "handle", "SetWindowsHookEx", "int", $52, "ptr", $53, "handle", $54, "dword", $55)
If @error Then Return SetError(@error, @extended, 0)
Return $3s[0]
EndFunc
Func _n($4b)
Local $3s = DllCall("user32.dll", "bool", "UnhookWindowsHookEx", "handle", $4b)
If @error Then Return SetError(@error, @extended, False)
Return $3s[0]
EndFunc
Func _o($56, $57, $58, $59, $5a = 0, $5b = 0)
Local $5c = DllCall("advapi32.dll", "bool", "AdjustTokenPrivileges", "handle", $56, "bool", $57, "struct*", $58, "dword", $59, "struct*", $5a, "struct*", $5b)
If @error Then Return SetError(1, @extended, False)
Return Not($5c[0] = 0)
EndFunc
Func _p($5d = $3m)
Local $5c = DllCall("advapi32.dll", "bool", "ImpersonateSelf", "int", $5d)
If @error Then Return SetError(1, @extended, False)
Return Not($5c[0] = 0)
EndFunc
Func _q($5e, $5f)
Local $5c = DllCall("advapi32.dll", "bool", "LookupPrivilegeValueW", "wstr", $5e, "wstr", $5f, "int64*", 0)
If @error Or Not $5c[0] Then Return SetError(1, @extended, 0)
Return $5c[3]
EndFunc
Func _r($5g, $5h = 0, $5i = False)
If $5h = 0 Then $5h = _a()
If @error Then Return SetError(1, @extended, 0)
Local $5c = DllCall("advapi32.dll", "bool", "OpenThreadToken", "handle", $5h, "dword", $5g, "bool", $5i, "handle*", 0)
If @error Or Not $5c[0] Then Return SetError(2, @extended, 0)
Return $5c[4]
EndFunc
Func _s($5g, $5h = 0, $5i = False)
Local $56 = _r($5g, $5h, $5i)
If $56 = 0 Then
If _5() <> $3i Then Return SetError(3, _5(), 0)
If Not _p() Then Return SetError(1, _5(), 0)
$56 = _r($5g, $5h, $5i)
If $56 = 0 Then Return SetError(2, _5(), 0)
EndIf
Return $56
EndFunc
Func _t($56, $5j, $5k)
Local $5l = _q("", $5j)
If $5l = 0 Then Return SetError(1, @extended, False)
Local $5m = DllStructCreate($3c)
Local $5n = DllStructGetSize($5m)
Local $5o = DllStructCreate($3c)
Local $5p = DllStructGetSize($5o)
Local $5q = DllStructCreate("int Data")
DllStructSetData($5m, "Count", 1)
DllStructSetData($5m, "LUID", $5l)
If Not _o($56, False, $5m, $5n, $5o, $5q) Then Return SetError(2, @error, False)
DllStructSetData($5o, "Count", 1)
DllStructSetData($5o, "LUID", $5l)
Local $5r = DllStructGetData($5o, "Attributes")
If $5k Then
$5r = BitOR($5r, $3j)
Else
$5r = BitAND($5r, BitNOT($3j))
EndIf
DllStructSetData($5o, "Attributes", $5r)
If Not _o($56, False, $5o, $5p, $5m, $5q) Then _
Return SetError(3, @error, False)
Return True
EndFunc
Global Const $5s = "handle hProc;ulong_ptr Size;ptr Mem"
Func _u(ByRef $5t)
Local $5u = DllStructGetData($5t, "Mem")
Local $5v = DllStructGetData($5t, "hProc")
Local $5w = _12($5v, $5u, 0, $34)
DllCall("kernel32.dll", "bool", "CloseHandle", "handle", $5v)
If @error Then Return SetError(@error, @extended, False)
Return $5w
EndFunc
Func _v($5x, $5y = 0)
Local $3s = DllCall("kernel32.dll", "handle", "GlobalAlloc", "uint", $5y, "ulong_ptr", $5x)
If @error Then Return SetError(@error, @extended, 0)
Return $3s[0]
EndFunc
Func _w($5z)
Local $3s = DllCall("kernel32.dll", "ptr", "GlobalLock", "handle", $5z)
If @error Then Return SetError(@error, @extended, 0)
Return $3s[0]
EndFunc
Func _x($5z)
Local $3s = DllCall("kernel32.dll", "bool", "GlobalUnlock", "handle", $5z)
If @error Then Return SetError(@error, @extended, 0)
Return $3s[0]
EndFunc
Func _y($3t, $60, ByRef $5t)
Local $3s = DllCall("User32.dll", "dword", "GetWindowThreadProcessId", "hwnd", $3t, "dword*", 0)
If @error Then Return SetError(@error, @extended, 0)
Local $4p = $3s[2]
If $4p = 0 Then Return SetError(1, 0, 0)
Local $5g = BitOR($3f, $3g, $3h)
Local $5v = _13($5g, False, $4p, True)
Local $61 = BitOR($32, $31)
Local $5u = _11($5v, 0, $60, $61, $33)
If $5u = 0 Then Return SetError(2, 0, 0)
$5t = DllStructCreate($5s)
DllStructSetData($5t, "hProc", $5v)
DllStructSetData($5t, "Size", $60)
DllStructSetData($5t, "Mem", $5u)
Return $5u
EndFunc
Func _0z(ByRef $5t, $62, $63, $60)
Local $3s = DllCall("kernel32.dll", "bool", "ReadProcessMemory", "handle", DllStructGetData($5t, "hProc"), _
"ptr", $62, "struct*", $63, "ulong_ptr", $60, "ulong_ptr*", 0)
If @error Then Return SetError(@error, @extended, False)
Return $3s[0]
EndFunc
Func _10(ByRef $5t, $62, $63 = 0, $60 = 0, $64 = "struct*")
If $63 = 0 Then $63 = DllStructGetData($5t, "Mem")
If $60 = 0 Then $60 = DllStructGetData($5t, "Size")
Local $3s = DllCall("kernel32.dll", "bool", "WriteProcessMemory", "handle", DllStructGetData($5t, "hProc"), _
"ptr", $63, $64, $62, "ulong_ptr", $60, "ulong_ptr*", 0)
If @error Then Return SetError(@error, @extended, False)
Return $3s[0]
EndFunc
Func _11($5v, $65, $60, $66, $67)
Local $3s = DllCall("kernel32.dll", "ptr", "VirtualAllocEx", "handle", $5v, "ptr", $65, "ulong_ptr", $60, "dword", $66, "dword", $67)
If @error Then Return SetError(@error, @extended, 0)
Return $3s[0]
EndFunc
Func _12($5v, $65, $60, $68)
Local $3s = DllCall("kernel32.dll", "bool", "VirtualFreeEx", "handle", $5v, "ptr", $65, "ulong_ptr", $60, "dword", $68)
If @error Then Return SetError(@error, @extended, False)
Return $3s[0]
EndFunc
Func _13($5g, $69, $4p, $6a = False)
Local $3s = DllCall("kernel32.dll", "handle", "OpenProcess", "dword", $5g, "bool", $69, "dword", $4p)
If @error Then Return SetError(@error, @extended, 0)
If $3s[0] Then Return $3s[0]
If Not $6a Then Return 0
Local $56 = _s(BitOR($3p, $3o))
If @error Then Return SetError(@error, @extended, 0)
_t($56, "SeDebugPrivilege", True)
Local $6b = @error
Local $6c = @extended
Local $6d = 0
If Not @error Then
$3s = DllCall("kernel32.dll", "handle", "OpenProcess", "dword", $5g, "bool", $69, "dword", $4p)
$6b = @error
$6c = @extended
If $3s[0] Then $6d = $3s[0]
_t($56, "SeDebugPrivilege", False)
If @error Then
$6b = @error
$6c = @extended
EndIf
EndIf
DllCall("kernel32.dll", "bool", "CloseHandle", "handle", $56)
Return SetError($6b, $6c, $6d)
EndFunc
Func _14($6e, $6f = @ScriptLineNumber, $6g = @error, $6h = @extended)
ConsoleWrite( _
"!===========================================================" & @CRLF & _
"+======================================================" & @CRLF & _
"-->Line(" & StringFormat("%04d", $6f) & "):" & @TAB & $6e & @CRLF & _
"+======================================================" & @CRLF)
Return SetError($6g, $6h, 1)
EndFunc
Func _15($3t, $6i)
_14("This is for debugging only, set the debug variable to false before submitting")
If _i($3t, $6i) Then Return True
Local $4s = Opt("GUIDataSeparatorChar")
$6i = StringReplace($6i, $4s, ",")
_14("Invalid Class Type(s):" & @LF & @TAB & "Expecting Type(s): " & $6i & @LF & @TAB & "Received Type : " & _9($3t))
Exit
EndFunc
Global $6j
Global $6k = False
Global Const $6l = "SysListView32"
Global Const $6m = 0x000B
Func _16($3t)
If $6k Then _15($3t, $6l)
If Not IsHWnd($3t) Then $3t = GUICtrlGetHandle($3t)
Return _6($3t, $6m) = 0
EndFunc
Func _17($3t)
If $6k Then _15($3t, $6l)
If _1b($3t) == 0 Then Return True
If IsHWnd($3t) Then
Return _6($3t, $2j) <> 0
Else
Local $6n
For $6o = _1b($3t) - 1 To 0 Step -1
$6n = _1d($3t, $6o)
If $6n Then GUICtrlDelete($6n)
Next
If _1b($3t) == 0 Then Return True
EndIf
Return False
EndFunc
Func _18($3t)
If $6k Then _15($3t, $6l)
If Not IsHWnd($3t) Then $3t = GUICtrlGetHandle($3t)
Return _6($3t, $6m, 1) = 0
EndFunc
Func _19($3t)
If $6k Then _15($3t, $6l)
If IsHWnd($3t) Then
Return _6($3t, $2k)
Else
Return GUICtrlSendMsg($3t, $2k, 0, 0)
EndIf
EndFunc
Func _1a($3t, $4k, $6p = 0)
Local $6q[8]
Local $6r = DllStructCreate($3b)
DllStructSetData($6r, "Mask", BitOR($27, $28, $29, $2a, $2b))
DllStructSetData($6r, "Item", $4k)
DllStructSetData($6r, "SubItem", $6p)
DllStructSetData($6r, "StateMask", -1)
_1c($3t, $6r)
Local $6s = DllStructGetData($6r, "State")
If BitAND($6s, $2c) <> 0 Then $6q[0] = BitOR($6q[0], 1)
If BitAND($6s, $2d) <> 0 Then $6q[0] = BitOR($6q[0], 2)
If BitAND($6s, $2e) <> 0 Then $6q[0] = BitOR($6q[0], 4)
If BitAND($6s, $2g) <> 0 Then $6q[0] = BitOR($6q[0], 8)
$6q[1] = _1j($6s)
$6q[2] = _1n($6s)
$6q[3] = _1f($3t, $4k, $6p)
$6q[4] = DllStructGetData($6r, "Image")
$6q[5] = DllStructGetData($6r, "Param")
$6q[6] = DllStructGetData($6r, "Indent")
$6q[7] = DllStructGetData($6r, "GroupID")
Return $6q
EndFunc
Func _1b($3t)
If $6k Then _15($3t, $6l)
If IsHWnd($3t) Then
Return _6($3t, $2n)
Else
Return GUICtrlSendMsg($3t, $2n, 0, 0)
EndIf
EndFunc
Func _1c($3t, ByRef $6r)
If $6k Then _15($3t, $6l)
Local $6t = _1h($3t)
Local $6d
If IsHWnd($3t) Then
If _h($3t, $6j) Then
$6d = _6($3t, $2m, 0, $6r, 0, "wparam", "struct*")
Else
Local $6u = DllStructGetSize($6r)
Local $5t
Local $5u = _y($3t, $6u, $5t)
_10($5t, $6r)
If $6t Then
_6($3t, $2m, 0, $5u, 0, "wparam", "ptr")
Else
_6($3t, $2l, 0, $5u, 0, "wparam", "ptr")
EndIf
_0z($5t, $5u, $6r, $6u)
_u($5t)
EndIf
Else
Local $6v = DllStructGetPtr($6r)
If $6t Then
$6d = GUICtrlSendMsg($3t, $2m, 0, $6v)
Else
$6d = GUICtrlSendMsg($3t, $2l, 0, $6v)
EndIf
EndIf
Return $6d <> 0
EndFunc
Func _1d($3t, $4k)
Local $6r = DllStructCreate($3b)
DllStructSetData($6r, "Mask", $2a)
DllStructSetData($6r, "Item", $4k)
_1c($3t, $6r)
Return DllStructGetData($6r, "Param")
EndFunc
Func _1e($3t, $4k)
If $6k Then _15($3t, $6l)
Local $6w[2], $6d
Local $4j = DllStructCreate($35)
If IsHWnd($3t) Then
If _h($3t, $6j) Then
If Not _6($3t, $2o, $4k, $4j, 0, "wparam", "struct*") Then Return $6w
Else
Local $6x = DllStructGetSize($4j)
Local $5t
Local $5u = _y($3t, $6x, $5t)
If Not _6($3t, $2o, $4k, $5u, 0, "wparam", "ptr") Then Return $6w
_0z($5t, $5u, $4j, $6x)
_u($5t)
EndIf
Else
$6d = GUICtrlSendMsg($3t, $2o, $4k, DllStructGetPtr($4j))
If Not $6d Then Return $6w
EndIf
$6w[0] = DllStructGetData($4j, "X")
$6w[1] = DllStructGetData($4j, "Y")
Return $6w
EndFunc
Func _1f($3t, $4k, $6p = 0)
If $6k Then _15($3t, $6l)
Local $6t = _1h($3t)
Local $6y
If $6t Then
$6y = DllStructCreate("wchar Text[4096]")
Else
$6y = DllStructCreate("char Text[4096]")
EndIf
Local $6z = DllStructGetPtr($6y)
Local $6r = DllStructCreate($3b)
DllStructSetData($6r, "SubItem", $6p)
DllStructSetData($6r, "TextMax", 4096)
If IsHWnd($3t) Then
If _h($3t, $6j) Then
DllStructSetData($6r, "Text", $6z)
_6($3t, $2r, $4k, $6r, 0, "wparam", "struct*")
Else
Local $6u = DllStructGetSize($6r)
Local $5t
Local $5u = _y($3t, $6u + 4096, $5t)
Local $70 = $5u + $6u
DllStructSetData($6r, "Text", $70)
_10($5t, $6r, $5u, $6u)
If $6t Then
_6($3t, $2r, $4k, $5u, 0, "wparam", "ptr")
Else
_6($3t, $2q, $4k, $5u, 0, "wparam", "ptr")
EndIf
_0z($5t, $70, $6y, 4096)
_u($5t)
EndIf
Else
Local $6v = DllStructGetPtr($6r)
DllStructSetData($6r, "Text", $6z)
If $6t Then
GUICtrlSendMsg($3t, $2r, $4k, $6v)
Else
GUICtrlSendMsg($3t, $2q, $4k, $6v)
EndIf
EndIf
Return DllStructGetData($6y, "Text")
EndFunc
Func _1g($3t, $71 = False)
If $6k Then _15($3t, $6l)
Local $72, $73[1] = [0]
Local $6d, $4q = _1b($3t)
For $6u = 0 To $4q
If IsHWnd($3t) Then
$6d = _6($3t, $2p, $6u, $2g)
Else
$6d = GUICtrlSendMsg($3t, $2p, $6u, $2g)
EndIf
If $6d Then
If(Not $71) Then
If StringLen($72) Then
$72 &= "|" & $6u
Else
$72 = $6u
EndIf
Else
ReDim $73[UBound($73) + 1]
$73[0] = UBound($73) - 1
$73[UBound($73) - 1] = $6u
EndIf
EndIf
Next
If(Not $71) Then
Return String($72)
Else
Return $73
EndIf
EndFunc
Func _1h($3t)
If $6k Then _15($3t, $6l)
If IsHWnd($3t) Then
Return _6($3t, $2s) <> 0
Else
Return GUICtrlSendMsg($3t, $2s, 0, 0) <> 0
EndIf
EndFunc
Func _1i($3t, $74 = -1, $75 = -1)
If $6k Then _15($3t, $6l)
Local $76[10]
Local $4h = Opt("MouseCoordMode", 1)
Local $4i = MouseGetPos()
Opt("MouseCoordMode", $4h)
Local $4j = DllStructCreate($35)
DllStructSetData($4j, "X", $4i[0])
DllStructSetData($4j, "Y", $4i[1])
Local $3s = DllCall("user32.dll", "bool", "ScreenToClient", "hwnd", $3t, "struct*", $4j)
If @error Then Return SetError(@error, @extended, 0)
If $3s[0] = 0 Then Return 0
If $74 = -1 Then $74 = DllStructGetData($4j, "X")
If $75 = -1 Then $75 = DllStructGetData($4j, "Y")
Local $77 = DllStructCreate($3a)
DllStructSetData($77, "X", $74)
DllStructSetData($77, "Y", $75)
If IsHWnd($3t) Then
If _h($3t, $6j) Then
$76[0] = _6($3t, $2t, 0, $77, 0, "wparam", "struct*")
Else
Local $78 = DllStructGetSize($77)
Local $5t
Local $5u = _y($3t, $78, $5t)
_10($5t, $77, $5u, $78)
$76[0] = _6($3t, $2t, 0, $5u, 0, "wparam", "ptr")
_0z($5t, $5u, $77, $78)
_u($5t)
EndIf
Else
$76[0] = GUICtrlSendMsg($3t, $2t, 0, DllStructGetPtr($77))
EndIf
Local $5y = DllStructGetData($77, "Flags")
$76[1] = BitAND($5y, $1t) <> 0
$76[2] = BitAND($5y, $1u) <> 0
$76[3] = BitAND($5y, $1v) <> 0
$76[4] = BitAND($5y, $1w) <> 0
$76[5] = BitAND($5y, $1z) <> 0
$76[6] = BitAND($5y, $1r) <> 0
$76[7] = BitAND($5y, $1s) <> 0
$76[8] = BitAND($5y, $1x) <> 0
$76[9] = BitAND($5y, $1y) <> 0
Return $76
EndFunc
Func _1j($79)
Return BitShift(BitAND($2f, $79), 8)
EndFunc
Func _1k($3t, $7a, $7b)
If $6k Then _15($3t, $6l)
If IsHWnd($3t) Then
Return _6($3t, $2u, $7a, $7b)
Else
Return GUICtrlSendMsg($3t, $2u, $7a, $7b)
EndIf
EndFunc
Func _1l($3t, $4k, $7c, $7d)
If $6k Then _15($3t, $6l)
If IsHWnd($3t) Then
Return _6($3t, $2v, $4k, _j($7c, $7d)) <> 0
Else
Return GUICtrlSendMsg($3t, $2v, $4k, _j($7c, $7d)) <> 0
EndIf
EndFunc
Func _1m($3t, $4k, $7e = True, $7f = False)
If $6k Then _15($3t, $6l)
Local $7g = DllStructCreate($3b)
Local $6d, $7h = 0, $7i = 0, $60, $5t, $5u
If($7e = True) Then $7h = $2g
If($7f = True And $4k <> -1) Then $7i = $2e
DllStructSetData($7g, "Mask", $2b)
DllStructSetData($7g, "Item", $4k)
DllStructSetData($7g, "State", BitOR($7h, $7i))
DllStructSetData($7g, "StateMask", BitOR($2g, $7i))
$60 = DllStructGetSize($7g)
If IsHWnd($3t) Then
$5u = _y($3t, $60, $5t)
_10($5t, $7g, $5u, $60)
$6d = _6($3t, $2w, $4k, $5u)
_u($5t)
Else
$6d = GUICtrlSendMsg($3t, $2w, $4k, DllStructGetPtr($7g))
EndIf
Return $6d <> 0
EndFunc
Func _1n($79)
Return BitShift(BitAND($79, $2h), 12)
EndFunc
Func _1o()
Return(@YEAR & "/" & @MON & "/" & @MDAY & " " & @HOUR & ":" & @MIN & ":" & @SEC)
EndFunc
Func _1p($7j, $7k = "*", $7l = 0)
Local $7m, $7n, $7o, $7p = "|"
$7j = StringRegExpReplace($7j, "[\\/]+\z", "") & "\"
If Not FileExists($7j) Then Return SetError(1, 1, "")
If StringRegExp($7k, "[\\/:><\|]|(?s)\A\s*\z") Then Return SetError(2, 2, "")
If Not($7l = 0 Or $7l = 1 Or $7l = 2) Then Return SetError(3, 3, "")
$7m = FileFindFirstFile($7j & $7k)
If @error Then Return SetError(4, 4, "")
While 1
$7n = FileFindNextFile($7m)
If @error Then ExitLoop
If($7l + @extended = 2) Then ContinueLoop
$7o &= $7p & $7n
WEnd
FileClose($7m)
If Not $7o Then Return SetError(4, 4, "")
Return StringSplit(StringTrimLeft($7o, 1), "|")
EndFunc
Global Const $7q = 0xFFFFFFF0
Global Const $7r = 0
Global Const $7s = 128
Global Const $7t = -7
Global Const $7u = 0x00000008
Global Const $7v = 0x00000800
Global Const $7w = $7u
Global Const $7x = $7v
Global Const $7y = 0x00000001
Global Const $7z = 0x00000002
Global Const $80 = 0x00000004
Global Const $81 = 0x0000003F
Global Const $82 = 0x00000040
Global Const $83 = 0x00000100
Global Const $84 = 0x00000010
Global Const $85 = 0x0
Global Const $86 = 0x0
Global Const $87 = 0x0
Global Const $88 = 0x00000002
Global Const $89 = 0x00000004
Global Const $8a = 0x00000008
Global Const $8b = 0x00000010
Global Const $8c = 0x00000020
Global Const $8d = 0x00000080
Global Const $8e = 0x00000100
Func _1q($8f = 8)
Local $3s = DllCall("User32.dll", "handle", "CreateMenu")
If @error Then Return SetError(@error, @extended, 0)
If $3s[0] = 0 Then Return SetError(10, 0, 0)
_1z($3s[0], $8f)
Return $3s[0]
EndFunc
Func _1r($8f = 8)
Local $3s = DllCall("User32.dll", "handle", "CreatePopupMenu")
If @error Then Return SetError(@error, @extended, 0)
If $3s[0] = 0 Then Return SetError(10, 0, 0)
_1z($3s[0], $8f)
Return $3s[0]
EndFunc
Func _1s($8g)
Local $3s = DllCall("User32.dll", "bool", "DestroyMenu", "handle", $8g)
If @error Then Return SetError(@error, @extended, False)
Return $3s[0]
EndFunc
Func _1t($8g, $6u, $8h = True)
Local $8i = DllStructCreate($3e)
DllStructSetData($8i, "Size", DllStructGetSize($8i))
DllStructSetData($8i, "Mask", $81)
Local $3s = DllCall("User32.dll", "bool", "GetMenuItemInfo", "handle", $8g, "uint", $6u, "bool", $8h, "struct*", $8i)
If @error Then Return SetError(@error, @extended, 0)
Return SetExtended($3s[0], $8i)
EndFunc
Func _1u($8g, $6u, $8h = True)
Local $8i = _1t($8g, $6u, $8h)
Return DllStructGetData($8i, "State")
EndFunc
Func _1v($8g, $4k, $6e, $8j = 0, $8k = 0)
Local $8l = DllStructCreate($3e)
DllStructSetData($8l, "Size", DllStructGetSize($8l))
DllStructSetData($8l, "Mask", BitOR($7z, $82, $80))
DllStructSetData($8l, "ID", $8j)
DllStructSetData($8l, "SubMenu", $8k)
If $6e = "" Then
DllStructSetData($8l, "Mask", $83)
DllStructSetData($8l, "Type", $7x)
Else
DllStructSetData($8l, "Mask", BitOR($7z, $82, $80))
Local $8m = DllStructCreate("wchar Text[" & StringLen($6e) + 1 & "]")
DllStructSetData($8m, "Text", $6e)
DllStructSetData($8l, "TypeData", DllStructGetPtr($8m))
EndIf
Local $3s = DllCall("User32.dll", "bool", "InsertMenuItemW", "handle", $8g, "uint", $4k, "bool", True, "struct*", $8l)
If @error Then Return SetError(@error, @extended, False)
Return $3s[0]
EndFunc
Func _1w($8g, $6u, ByRef $8i, $8h = True)
DllStructSetData($8i, "Size", DllStructGetSize($8i))
Local $3s = DllCall("User32.dll", "bool", "SetMenuItemInfoW", "handle", $8g, "uint", $6u, "bool", $8h, "struct*", $8i)
If @error Then Return SetError(@error, @extended, False)
Return $3s[0]
EndFunc
Func _1x($8g, $6u, $6s, $8n = True, $8h = True)
Local $7l = _1u($8g, $6u, $8h)
If $8n Then
$6s = BitOR($7l, $6s)
Else
$6s = BitAND($7l, BitNOT($6s))
EndIf
Local $8i = DllStructCreate($3e)
DllStructSetData($8i, "Size", DllStructGetSize($8i))
DllStructSetData($8i, "Mask", $7y)
DllStructSetData($8i, "State", $6s)
Return _1w($8g, $6u, $8i, $8h)
EndFunc
Func _1y($8g, ByRef $8i)
DllStructSetData($8i, "Size", DllStructGetSize($8i))
Local $3s = DllCall("User32.dll", "bool", "SetMenuInfo", "handle", $8g, "struct*", $8i)
If @error Then Return SetError(@error, @extended, False)
Return $3s[0]
EndFunc
Func _1z($8g, $8f)
Local $8i = DllStructCreate($3d)
DllStructSetData($8i, "Mask", $84)
DllStructSetData($8i, "Style", $8f)
Return _1y($8g, $8i)
EndFunc
Func _20($8g, $3t, $74 = -1, $75 = -1, $8o = 1, $8p = 1, $8q = 0, $8r = 0)
If $74 = -1 Then $74 = _d()
If $75 = -1 Then $75 = _e()
Local $5y = 0
Switch $8o
Case 1
$5y = BitOR($5y, $86)
Case 2
$5y = BitOR($5y, $8a)
Case Else
$5y = BitOR($5y, $89)
EndSwitch
Switch $8p
Case 1
$5y = BitOR($5y, $87)
Case 2
$5y = BitOR($5y, $8b)
Case Else
$5y = BitOR($5y, $8c)
EndSwitch
If BitAND($8q, 1) <> 0 Then $5y = BitOR($5y, $8d)
If BitAND($8q, 2) <> 0 Then $5y = BitOR($5y, $8e)
Switch $8r
Case 1
$5y = BitOR($5y, $88)
Case Else
$5y = BitOR($5y, $85)
EndSwitch
Local $3s = DllCall("User32.dll", "bool", "TrackPopupMenu", "handle", $8g, "uint", $5y, "int", $74, "int", $75, "int", 0, "hwnd", $3t, "ptr", 0)
If @error Then Return SetError(@error, @extended, 0)
Return $3s[0]
EndFunc
Global Const $8s = _22()
Global Const $8t = 'align 2;dword_ptr Size;hwnd hOwner;ptr hDevMode;ptr hDevNames;hwnd hDC;dword Flags;ushort FromPage;ushort ToPage;ushort MinPage;ushort MaxPage;' & _21(@AutoItX64, 'uint', 'ushort') & ' Copies;ptr hInstance;lparam lParam;ptr PrintHook;ptr SetupHook;ptr PrintTemplateName;ptr SetupTemplateName;ptr hPrintTemplate;ptr hSetupTemplate;'
Func _21($8u, $8v, $8w)
If $8u Then
Return $8v
Else
Return $8w
EndIf
EndFunc
Func _22()
Local $8x = DllStructCreate('dword;dword;dword;dword;dword;wchar[128]')
DllStructSetData($8x, 1, DllStructGetSize($8x))
Local $8y = DllCall('kernel32.dll', 'int', 'GetVersionExW', 'ptr', DllStructGetPtr($8x))
If(@error) Or(Not $8y[0]) Then
Return SetError(1, 0, 0)
EndIf
Return BitOR(BitShift(DllStructGetData($8x, 2), -8), DllStructGetData($8x, 3))
EndFunc
Global Const $8z = 0x0001
Global Const $90 = 0x00022009
Global Const $91 = 0x0026200A
Global $92 = 0
Global $93 = 0
Global $94 = 0
Func _23($95)
Local $3s = DllCall($92, "int", "GdipDisposeImage", "handle", $95)
If @error Then Return SetError(@error, @extended, False)
Return $3s[0] = 0
EndFunc
Func _24($95, $96, $97, $7b, $98, $5y = $8z, $99 = $90)
Local $9a = DllStructCreate($38)
Local $9b = DllStructCreate($36)
DllStructSetData($9b, "Left", $96)
DllStructSetData($9b, "Top", $97)
DllStructSetData($9b, "Right", $7b)
DllStructSetData($9b, "Bottom", $98)
Local $3s = DllCall($92, "int", "GdipBitmapLockBits", "handle", $95, "struct*", $9b, "uint", $5y, "int", $99, "struct*", $9a)
If @error Then Return SetError(@error, @extended, 0)
Return SetExtended($3s[0], $9a)
EndFunc
Func _25($95, $9c)
Local $3s = DllCall($92, "int", "GdipBitmapUnlockBits", "handle", $95, "struct*", $9c)
If @error Then Return SetError(@error, @extended, False)
Return $3s[0] = 0
EndFunc
Func _26()
If $92 = 0 Then Return SetError(-1, -1, False)
$93 -= 1
If $93 = 0 Then
DllCall($92, "none", "GdiplusShutdown", "ptr", $94)
DllClose($92)
$92 = 0
EndIf
Return True
EndFunc
Func _27()
$93 += 1
If $93 > 1 Then Return True
$92 = DllOpen("GDIPlus.dll")
If $92 = -1 Then
$93 = 0
Return SetError(1, 2, False)
EndIf
Local $9d = DllStructCreate($39)
Local $9e = DllStructCreate("ulong_ptr Data")
DllStructSetData($9d, "Version", 1)
Local $3s = DllCall($92, "int", "GdiplusStartup", "struct*", $9e, "struct*", $9d, "ptr", 0)
If @error Then Return SetError(@error, @extended, False)
$94 = DllStructGetData($9e, "Data")
Return $3s[0] = 0
EndFunc
Global Const $9f = 0x0172
Global $9g = -1, $9h = -1
Global $9i
Global $9j, $9k = @ScriptDir, $9l
Global $9m, $9n
$9o = TimerInit()
While TimerDiff($9o) < 30000
$9m = _2u()
$9n = HWnd(@extended)
If _1b($9n) Then ExitLoop
$9n = ""
Sleep(10)
WEnd
If Not IsHWnd($9n) Then
_3e("Desktop Window not found. ICU will exit now.")
EndIf
If BitAND(_f($9n, $7q), $1n) Then
If IniRead($9k & "\ICU.ini", "Settings", "Checkbox_Warning_AutoArrange", $u) = $u Then
TraySetState()
TrayTip($b & " - Warning", "Icon ""Auto Arrange"" is activated for the Desktop. This might prevent ICU from restoring the Icon positions properly. Deactivate ""Auto Arrange"" when restore does not work as intended.", 5, 1)
Sleep(1000)
EndIf
EndIf
If BitAND(_19($9n), $1q) Then
If IniRead($9k & "\ICU.ini", "Settings", "Checkbox_Warning_AlignToGrid", $u) = $u Then
TraySetState()
TrayTip($b & " - Warning", "Icon ""Align to Grid"" is activated for the Desktop. This will might ICU from restoring the Icon positions properly. Deactivate ""Align to Grid"" when restore does not work as intended.", 5, 1)
Sleep(1000)
EndIf
EndIf
Global $9p = _1p($9k, "*.icf", 1)
If $8s > 0x0600 Then
If Not IniRead($9k & "\ICU.ini", "Settings", "Version", "") Then
IniWrite($9k & "\ICU.ini", "Settings", "Version", $c)
If MsgBox(4 + 32 + 262144, $b & " - Install", "" & _
"Do you want to enable ICU Desktop Contextmenu" & @CRLF & _
"Integration (will write settings to registy / settings" & @CRLF & _
"can be removed on main screen)?") = 6 Then
IniWrite($9k & "\ICU.ini", "Settings", "Desktop_Contextmenu_Integration", 1)
If _2n(True) Then MsgBox(64 + 262144, $b & " - Install", "Desktop Contextmenu Integration IS enabled.")
Else
IniWrite($9k & "\ICU.ini", "Settings", "Desktop_Contextmenu_Integration", 0)
If _2n(False) Then MsgBox(64 + 262144, $b & " - Install", "Desktop Contextmenu Integration NOT enabled.")
EndIf
EndIf
Else
If Not IniRead($9k & "\ICU.ini", "Settings", "Version", "") Then IniWrite($9k & "\ICU.ini", "Settings", "Version", $c)
EndIf
Global $9q = _2o()
_27()
OnAutoItExitRegister("_2s")
Global $9r, $9s, $9t, $9u, $9v, $9w, $9x, $9y
Global $9z, $a0 = 1, $a1 = 1
Global $a2, $a3, $a4
$a5 = TrayCreateItem("Save")
$a6 = TrayCreateMenu("Restore Config")
$a7 = TrayCreateItem("Settings")
$a8 = TrayCreateItem("Exit")
Global $a9[1] = [0]
If $8s > 0x0600 Then
$a = GUICreate($b, 470, 337)
_2w(8.25, 400, 0, "Arial", $a)
$9r = GUICtrlCreateButton("Save", 10, 175, 82, 25)
$9s = GUICtrlCreateButton("Restore", 102, 175, 82, 25)
$9t = GUICtrlCreateButton("Delete", 194, 175, 82, 25)
$9u = GUICtrlCreateButton("Duplicate", 286, 175, 82, 25)
$9v = GUICtrlCreateButton("About", 378, 175, 82, 25)
GUICtrlCreateLabel("List of saved layouts (*.icf files), right click to edit", 10, 8, 400, 20)
$9w = GUICtrlCreateLabel("Ready", 380, 7, 80, 16, $11 + $13)
GUICtrlSetBkColor(-1, $j)
$9x = GUICtrlCreateListView("#|Name|Date|Resolution|Move unknown Icons", 10, 30, 450, 135, $1o, $1p)
GUICtrlSetBkColor(-1, $10)
$9y = GUICtrlGetHandle($9x)
_1k($9y, 0, 20)
_1k($9y, 1, 80 + 48 + 46)
_1k($9y, 2, $2z)
_1k($9y, 3, $2z)
_1k($9y, 4, 80)
If IsArray($9p) Then
_2k()
Else
GUICtrlCreateListViewItem("|No Layouts saved", $9x)
GUICtrlSetState($9s, $x)
GUICtrlSetState($9t, $x)
EndIf
$aa = GUICtrlCreateCheckbox(" Create Shortcut on Save", 323, 206 + 15, 250, 17)
GUICtrlSetState(-1, IniRead($9k & "\ICU.ini", "Settings", "Checkbox_Autosave", $u))
GUICtrlSetTip(-1, "ICU will automatically create a shortcut in" & @CRLF & "the program directory on saving a layout")
GUICtrlCreateLabel("Command line usage ", 10, 208, 150, 13)
_2v(-1, 7, 600, 0, "Arial")
GUICtrlCreateLabel("See ""About"" for details", 127, 208, 100, 13)
_2v(-1, 7, 400, 0, "Arial")
GUICtrlCreateLabel("Warning on ", 10, 208 + 15, 70, 13)
_2v(-1, 7, 600, 0, "Arial")
$ab = GUICtrlCreateCheckbox(" Auto Arrange", 80, 206 + 15, 85, 17)
GUICtrlSetState(-1, IniRead($9k & "\ICU.ini", "Settings", "Checkbox_Warning_AutoArrange", $u))
GUICtrlSetTip(-1, "If the Desktop ""Auto Arrange"" feature is activated, ICU will post a warning Message Box on start")
$ac = GUICtrlCreateCheckbox(" Align to Grid", 170, 206 + 15, 100, 17)
GUICtrlSetState(-1, IniRead($9k & "\ICU.ini", "Settings", "Checkbox_Warning_AlignToGrid", $u))
GUICtrlSetTip(-1, "If the Desktop ""Align to Grid"" feature is activated, ICU will post a warning Message Box on start")
GUICtrlCreateGroup(" ICU Desktop Contextmenu Integration (DCI) ", 10, 230 + 15, 450, 59)
$9z = GUICtrlCreateLabel("", 24, 258, 100, 15)
_2v($9z, 9.5, 600, 0, "Arial")
$a0 = GUICtrlCreateButton("Install DCI", 125 + 20, 252 + 15, 120, 25)
GUICtrlSetTip(-1, "Adds ICU to the right click menu on the desktop." & @CRLF & "DCI settings are added to / deleted from the registry." & @CRLF & @CRLF & "Uninstall DCI before removing ICU from your computer.", "Desktop Contextmenu Integration", 1, 1)
$a1 = GUICtrlCreateButton("Uninstall DCI", 245 + 40, 252 + 15, 120, 25)
Switch IniRead($9k & "\ICU.ini", "Settings", "Desktop_Contextmenu_Integration", 0)
Case 0
GUICtrlSetState($a0, $w)
GUICtrlSetState($a1, $x)
GUICtrlSetData($9z, "Not Installed")
GUICtrlSetColor($9z, $i)
Case 1
GUICtrlSetState($a0, $x)
GUICtrlSetState($a1, $w)
GUICtrlSetData($9z, "Is Installed")
GUICtrlSetColor($9z, $j)
EndSwitch
GUICtrlCreateGroup("", -99, -99, 1, 1)
$a2 = GUICtrlCreatePic("", 10, 231 + 70 + 15, 80, 15, $12)
GUICtrlSetCursor($a2, 0)
GUICtrlSetBkColor(-1, 0x00ff00)
GUICtrlCreateLabel("For support visit ", 163, 234 + 70 + 15, 74, 17)
_2v(-1, 7, 400, 0, "Arial")
GUICtrlSetBkColor(-1, $0z)
$a3 = GUICtrlCreateLabel('http://www.funk.eu', 236, 234 + 70 + 15, 78, 17)
_2v(-1, 7, 400, 0, "Arial")
GUICtrlSetBkColor(-1, $0z)
GUICtrlSetColor(-1, 0x1111CC)
GUICtrlSetCursor(-1, 0)
$a4 = GUICtrlCreatePic("", 360, 228 + 70 + 15, 100, 20, $12)
GUICtrlSetCursor($a4, 0)
GUICtrlSetBkColor(-1, 0x00ff00)
Local $ad = _32(_34(), True)
_8(GUICtrlSendMsg($a2, $9f, $7r, $ad))
_8($ad)
Local $ae = _32(_35(), True)
_8(GUICtrlSendMsg($a4, $9f, $7r, $ae))
_8($ae)
Else
$a = GUICreate($b, 470, 267)
_2w(8.25, 400, 0, "Arial", $a)
$9r = GUICtrlCreateButton("Save", 10, 175, 82, 25)
$9s = GUICtrlCreateButton("Restore", 102, 175, 82, 25)
$9t = GUICtrlCreateButton("Delete", 194, 175, 82, 25)
$9u = GUICtrlCreateButton("Duplicate", 286, 175, 82, 25)
$9v = GUICtrlCreateButton("About", 378, 175, 82, 25)
GUICtrlCreateLabel("List of saved layouts (*.icf files), right click to edit", 10, 8, 400, 20)
$9w = GUICtrlCreateLabel("Ready", 380, 7, 80, 16, $11 + $13)
GUICtrlSetBkColor(-1, $j)
$9x = GUICtrlCreateListView("#|Name|Date|Resolution|Move unknown Icons", 10, 30, 450, 135, $1o, $1p)
GUICtrlSetBkColor(-1, $10)
$9y = GUICtrlGetHandle($9x)
_1k($9y, 0, 20)
_1k($9y, 1, 80 + 48 + 46)
_1k($9y, 2, $2z)
_1k($9y, 3, $2z)
_1k($9y, 4, 80)
If IsArray($9p) Then
_2k()
Else
GUICtrlCreateListViewItem("|No Layouts saved", $9x)
GUICtrlSetState($9s, $x)
GUICtrlSetState($9t, $x)
EndIf
$aa = GUICtrlCreateCheckbox(" Create Shortcut on Save", 323, 206 + 15, 250, 17)
GUICtrlSetState(-1, IniRead($9k & "\ICU.ini", "Settings", "Checkbox_Autosave", $u))
GUICtrlSetTip(-1, "ICU will automatically create a shortcut in" & @CRLF & "the program directory on saving a layout")
GUICtrlCreateLabel("Command line usage ", 10, 208, 150, 13)
_2v(-1, 7, 600, 0, "Arial")
GUICtrlCreateLabel("See ""About"" for details", 127, 208, 100, 13)
_2v(-1, 7, 400, 0, "Arial")
GUICtrlCreateLabel("Warning on ", 10, 208 + 15, 70, 13)
_2v(-1, 7, 600, 0, "Arial")
$ab = GUICtrlCreateCheckbox(" Auto Arrange", 80, 206 + 15, 85, 17)
GUICtrlSetState(-1, IniRead($9k & "\ICU.ini", "Settings", "Checkbox_Warning_AutoArrange", $u))
GUICtrlSetTip(-1, "If the Desktop ""Auto Arrange"" feature is activated, ICU will post a warning Message Box on start")
$ac = GUICtrlCreateCheckbox(" Align to Grid", 170, 206 + 15, 100, 17)
GUICtrlSetState(-1, IniRead($9k & "\ICU.ini", "Settings", "Checkbox_Warning_AlignToGrid", $u))
GUICtrlSetTip(-1, "If the Desktop ""Align to Grid"" feature is activated, ICU will post a warning Message Box on start")
$a2 = GUICtrlCreatePic("", 10, 231 + 15, 80, 15, $12)
GUICtrlSetCursor($a2, 0)
GUICtrlSetBkColor(-1, 0x00ff00)
GUICtrlCreateLabel("For support visit ", 163, 234 + 15, 74, 17)
_2v(-1, 7, 400, 0, "Arial")
GUICtrlSetBkColor(-1, $0z)
$a3 = GUICtrlCreateLabel('http://www.funk.eu', 236, 234 + 15, 78, 17)
_2v(-1, 7, 400, 0, "Arial")
GUICtrlSetBkColor(-1, $0z)
GUICtrlSetColor(-1, 0x1111CC)
GUICtrlSetCursor(-1, 0)
$a4 = GUICtrlCreatePic("", 360, 228 + 15, 100, 20, $12)
GUICtrlSetCursor($a4, 0)
GUICtrlSetBkColor(-1, 0x00ff00)
Local $ad = _32(_34(), True)
_8(GUICtrlSendMsg($a2, $9f, $7r, $ad))
_8($ad)
Local $ae = _32(_35(), True)
_8(GUICtrlSendMsg($a4, $9f, $7r, $ae))
_8($ae)
EndIf
If $8[0] = 3 And StringLower($8[1]) = "toggle" Then
If Not IsArray($9p) Then _2r()
Global $af, $ag
Global $ah, $ai
Global $aj, $ak
Global $al
For $am = 2 To 3
$al = False
If IsInt($8[$am]) Then
For $9 = 1 To $9p[0]
If Number(StringLeft($9p[$9], 3)) = Number($8[$am]) Then
$9j = $9k & "\" & $9p[$9]
If FileExists($9j) Then
$al = True
ExitLoop
EndIf
EndIf
Next
Else
For $9 = 1 To $9p[0]
If StringInStr($9p[$9], $8[$am]) Then
$9j = $9k & "\" & $9p[$9]
If FileExists($9j) Then
$al = True
ExitLoop
EndIf
EndIf
Next
EndIf
If $al = False Then _3e("Fatal Error" & @CRLF & "ICU could not find called config """ & $8[$am] & """")
If $am = 2 Then
$af = $9j
$ag = $8[$am]
Else
$aj = $9j
$ak = $8[$am]
EndIf
Next
If IniRead($af, "Data", "Timestamp", 0) > IniRead($aj, "Data", "Timestamp", 0) Then
$ah = $af
$af = $aj
$aj = $ah
$ai = $ag
$ag = $ak
$ak = $ai
EndIf
_2c(True, $ag)
If $9q Then _2p()
$9j = $aj
_2h()
_2r()
EndIf
If $8[0] = 2 And StringLower($8[1]) = "restore" Then
If Not IsArray($9p) Then _2r()
If IsInt($8[2]) Then
For $9 = 1 To $9p[0]
If Number(StringLeft($9p[$9], 3)) = Number($8[2]) Then
$9j = $9k & "\" & $9p[$9]
If FileExists($9j) Then _2h()
_2r()
EndIf
Next
Else
For $9 = 1 To $9p[0]
If StringInStr($9p[$9], $8[2]) Then
$9j = $9k & "\" & $9p[$9]
If FileExists($9j) Then _2h()
_2r()
EndIf
Next
EndIf
_3e("Fatal Error" & @CRLF & "ICU could not find called config """ & $8[2] & """")
ElseIf $8[0] = 1 And StringLower($8[1]) = "autosave" Then
_2c(True)
If $9q Then _2p()
_2r()
ElseIf $8[0] = 1 And StringLower($8[1]) = "save" Then
_2c()
If $9q Then _2p()
_2r()
ElseIf $8[0] = 2 And StringLower($8[1]) = "savereplace" Then
_2c(True, $8[2])
If $9q Then _2p()
_2r()
EndIf
Global Enum $an = 1000, $ao, $ap, $aq, $ar, $as
Global Enum $at = 2000, $au, $av, $aw, $ax
Global $ay = False
GUIRegisterMsg($1h, "_2z")
GUIRegisterMsg($1j, "_31")
GUIRegisterMsg($1i, "_30")
_3d()
If Not StringInStr($7, "minimized") Then GUISetState(@SW_SHOW, $a)
TraySetClick(8)
TraySetState()
TraySetToolTip("ICU - Icon Configuration Utility")
TrayItemSetOnEvent($a5, "_28")
TraySetOnEvent($7t, "_29")
TrayItemSetOnEvent($a7, "_29")
TrayItemSetOnEvent($a8, "_2r")
$az = GUICtrlCreateDummy()
Global $b0[1][2] = [["{ESC}", $az]]
GUISetAccelerators($b0, $a)
While 1
$b1 = GUIGetMsg(1)
Switch $b1[1]
Case $a
Switch $b1[0]
Case $aa
IniWrite($9k & "\ICU.ini", "Settings", "Checkbox_Autosave", GUICtrlRead($aa))
Case $s, $az
_2a()
Case $r
_2r()
Case $9r
_2c()
If $9q Then _2p()
Case $9s
_2e()
Case $9u
_2f()
Case $9t
_2i()
Case $9v
_3c()
Case $a0
If $8s > 0x0600 Then
If _2n(True) Then
GUICtrlSetState($a0, $x)
GUICtrlSetState($a1, $w)
GUICtrlSetData($9z, "installed")
GUICtrlSetColor($9z, $j)
EndIf
EndIf
Case $a1
If $8s > 0x0600 Then
If _2n(False) Then
GUICtrlSetState($a0, $w)
GUICtrlSetState($a1, $x)
GUICtrlSetData($9z, "not installed")
GUICtrlSetColor($9z, $i)
EndIf
EndIf
EndSwitch
EndSwitch
If $ay Then
$ay = False
_2e()
EndIf
WEnd
_2r()
Func _28()
If BitAND(WinGetState($d), 2) Then
$g = True
$h = True
Else
_2c()
If $9q Then _2p()
EndIf
EndFunc
Func _29()
$g = True
GUISetState(@SW_SHOW, $a)
GUISetState(@SW_RESTORE, $a)
EndFunc
Func _2a()
GUISetState(@SW_HIDE, $a)
EndFunc
Func _2b()
For $9 = 1 To $a9[0]
If @TRAY_ID = $a9[$9] Then
_1m($9y, $9 - 1)
_2e()
EndIf
Next
EndFunc
Func _2c($b2 = False, $b3 = "")
Local $b4, $b5, $b6, $b7
Local $b8, $b9, $ba, $bb
GUISetState(@SW_HIDE, $a)
If Not $b2 Then
While 1
$b4 = False
$b8 = GUICreate($b, 260, 117)
_2w(8.25, 400, 0, "Arial", $b8)
GUICtrlCreateLabel("Enter a name for the new Icon Configuration File", 15, 7, 250)
$b9 = GUICtrlCreateInput("", 15, 23, 230)
GUICtrlCreateLabel("Move unknown Icons to", 23, 56, 110, 13)
$bc = GUICtrlCreateCombo("Top-Left", 145, 52, 100, 20, BitOR($16, $14))
GUICtrlSetData(-1, "Bottom-Right|Custom Position|Ask per Icon|Off-Screen", IniRead($9k & "\ICU.ini", "Settings", "Default_Unknown_Icon_Handling", "Top-Left"))
$ba = GUICtrlCreateButton("Save", 33, 80, 80, 30)
$bb = GUICtrlCreateButton("Cancel", 146, 80, 80, 30)
GUICtrlSetState($ba, $y)
GUISetState(@SW_SHOW, $b8)
While 1
Switch GUIGetMsg()
Case $r
$b4 = True
ExitLoop
Case $bb
$b4 = True
ExitLoop
Case $ba
If GUICtrlRead($b9) Then
If GUICtrlRead($bc) = "Custom Position" Then
Local $4i = _37()
If $4i[0] <> -1 Then
$b6 = "Custom-Position," & $4i[0] & "," & $4i[1]
IniWrite($9k & "\ICU.ini", "Settings", "Default_Unknown_Icon_Handling", "Custom Position")
ExitLoop
Else
GUISetState(@SW_RESTORE, $b8)
EndIf
Else
IniWrite($9k & "\ICU.ini", "Settings", "Default_Unknown_Icon_Handling", $b6)
ExitLoop
EndIf
Else
MsgBox(64 + 262144, $b, "Enter a name or cancel save.", 0, $b8)
EndIf
EndSwitch
WEnd
$b5 = StringRegExpReplace(GUICtrlRead($b9), '[\Q\/:?*"<>|\E]', '')
If Not $b6 Then $b6 = GUICtrlRead($bc)
If Not StringInStr($7, "save") Then GUISetState(@SW_SHOW, $a)
GUIDelete($b8)
If $b4 Then
GUICtrlSetData($9w, "Ready")
GUICtrlSetBkColor($9w, $j)
GUICtrlSetState($9s, $w)
GUICtrlSetState($9t, $w)
Return
EndIf
GUICtrlSetData($9w, "Working")
GUICtrlSetBkColor($9w, 0xFF4500)
$9j = ""
If IsArray($9p) Then
$b7 = 0
For $9 = 0 To UBound($9p) - 1
If StringLen($9p[$9]) > 4 Then
If Number(StringLeft($9p[$9], 3)) >= $b7 Then $b7 = Number(StringLeft($9p[$9], 3)) + 1
If $b5 = StringMid($9p[$9], 5, StringLen($9p[$9]) - 8) Then
Switch MsgBox(3 + 32 + 262144, $b, "A config file named '" & $b5 & "' already exists." & @CRLF & @CRLF & "Do you want to replace this config (yes) or create a new one (no)?", 0, $a)
Case 6
$9j = $9k & "\" & $9p[$9]
$b7 = Int(StringLeft($9p[$9], 3))
ExitLoop
Case 7
$9j = ""
ExitLoop
Case 2
GUICtrlSetData($9w, "Ready")
GUICtrlSetBkColor($9w, $j)
GUICtrlSetState($9s, $w)
GUICtrlSetState($9t, $w)
Return
EndSwitch
EndIf
EndIf
Next
If Not StringLen($9j) Then $9j = $9k & "\" & StringFormat("%03i", $b7) & "_" & $b5 & ".icf"
Else
$b7 = 1
$9j = $9k & "\001_" & $b5 & ".icf"
EndIf
If $9j Then ExitLoop
WEnd
Else
If $b3 Then
$9j = ""
$b5 = ""
If IsInt($b3) Then
For $9 = 1 To $9p[0]
If Number(StringLeft($9p[$9], 3)) = Number($b3) Then
$9j = $9k & "\" & $9p[$9]
EndIf
Next
If Not $9j Then $9j = $9k & "\" & StringFormat("%03i", Number($b3)) & "_" & @YEAR & "_" & @MON & "_" & @MDAY & "_" & @HOUR & @MIN & @SEC & ".icf"
Else
For $9 = 1 To $9p[0]
If StringInStr($9p[$9], $b3) Then
$9j = $9k & "\" & $9p[$9]
EndIf
Next
If Not $9j Then $9j = $9k & "\" & StringFormat("%03i", 99) & "_" & $b3 & ".icf"
EndIf
$b6 = IniRead($9j, "Data", "Unknown_Icon_Handling", "Top-Left")
$b5 = IniRead($9j, "Data", "Type", $b5)
If Not $b5 Then
If IsInt($b3) Then
$b5 = @YEAR & "_" & @MON & "_" & @MDAY & "_" & @HOUR & @MIN & @SEC
Else
$b5 = $b3
EndIf
EndIf
Else
$b6 = "Top-Left"
$b5 = @YEAR & "_" & @MON & "_" & @MDAY & "_" & @HOUR & @MIN & @SEC
If IsArray($9p) Then
$b7 = 0
For $9 = 0 To UBound($9p) - 1
If StringLen($9p[$9]) > 4 Then
If Number(StringLeft($9p[$9], 3)) >= $b7 Then $b7 = Number(StringLeft($9p[$9], 3)) + 1
If $b5 = StringMid($9p[$9], 5, StringLen($9p[$9]) - 8) Then
Switch MsgBox(3 + 32 + 262144, $b, "A config file named '" & $b5 & "' already exists." & @CRLF & @CRLF & "Do you want to replace this config (yes) or create a new one (no)?", 0, $a)
Case 6
$9j = $9k & "\" & $9p[$9]
$b7 = Int(StringLeft($9p[$9], 3))
ExitLoop
Case 7
$9j = ""
ExitLoop
Case 2
GUICtrlSetData($9w, "Ready")
GUICtrlSetBkColor($9w, $j)
GUICtrlSetState($9s, $w)
GUICtrlSetState($9t, $w)
Return
EndSwitch
EndIf
EndIf
Next
If Not StringLen($9j) Then $9j = $9k & "\" & StringFormat("%03i", $b7) & "_" & $b5 & ".icf"
Else
$b7 = 1
$9j = $9k & "\001_" & $b5 & ".icf"
EndIf
EndIf
EndIf
FileDelete($9j)
IniWrite($9j, "Data", "Type", $b5)
IniWrite($9j, "Data", "Date", _1o())
IniWrite($9j, "Data", "Timestamp", _3f(@YEAR & "/" & @MON & "/" & @MDAY & " " & @HOUR & ":" & @MIN & ":" & @SEC))
Local $bd = DllCall($1, "int", "GetSystemMetrics", "int", 78)
Local $be = DllCall($1, "int", "GetSystemMetrics", "int", 79)
IniWrite($9j, "Data", "Resolution", $bd[0] & "x" & $be[0])
IniWrite($9j, "Data", "Unknown_Icon_Handling", $b6)
If BitAND(IniRead($9k & "\ICU.ini", "Settings", "Checkbox_Autosave", $u), $u) Then
Local $bf = StringTrimRight(@ScriptDir, StringLen(@ScriptDir) - StringInStr(@ScriptDir, "\", 0, -1)) & "\ICU - Restore Layout - " & $b5 & ".lnk"
Do
$bf = StringReplace($bf, "\\", "\")
Until Not @extended
FileDelete($bf)
FileCreateShortcut(@ScriptDir & "\" & @ScriptName, $bf, @ScriptDir, "restore " & $b7, "ICU - Restore Layout " & $b5, @ScriptDir & "\" & @ScriptName, "", 0, @SW_MINIMIZE)
EndIf
_2d()
_2k()
GUICtrlSetData($9w, "Ready")
GUICtrlSetBkColor($9w, $j)
GUICtrlSetState($9s, $w)
GUICtrlSetState($9t, $w)
EndFunc
Func _2d()
If Not IsHWnd($9n) Then
_3e("Error _Save_Locations_Desktop()" & @CRLF & "Desktop Window Handle not found.")
EndIf
Local $bg = _2t()
If Not IsArray($bg) Or UBound($bg, 2) <> 4 Then
_3e("Error _Save_Locations_Desktop()" & @CRLF & "_Desktop_to_Array() returned wrong dimension." & @CRLF & @CRLF & "Dim-1: " & UBound($bg) & @CRLF & "Dim-2: " & UBound($bg, 2), False)
EndIf
For $9 = 0 To UBound($bg) - 1
IniWrite($9j, "Desktop", _2l($bg[$9][0] & $bg[$9][1] & $bg[$9][2]), $bg[$9][3])
Next
EndFunc
Func _2e()
GUICtrlSetData($9w, "Working")
GUICtrlSetBkColor($9w, 0xFF4500)
Local $4k = _1g($9y, True)
If $4k[0] <> 1 Then
ReDim $4k[2]
$4k[0] = 1
$4k[1] = 0
EndIf
If $4k[0] = 1 Then
$9j = $9k & "\" & $9p[$4k[1] + 1]
_2h()
ControlListView($a, "", $9y, "SelectClear")
EndIf
GUICtrlSetData($9w, "Ready")
GUICtrlSetBkColor($9w, $j)
EndFunc
Func _2f()
GUICtrlSetData($9w, "Working")
GUICtrlSetBkColor($9w, 0xFF4500)
Local $4k = _1g($9y, True)
If $4k[0] <> 1 Then
ReDim $4k[2]
$4k[0] = 1
$4k[1] = 0
EndIf
If $4k[0] = 1 Then
$9j = $9k & "\" & $9p[$4k[1] + 1]
For $9 = 1 To 999
If Not FileExists($9k & "\" & StringFormat("%03i", $9) & "*.icf") Then
FileCopy($9j, $9k & "\" & StringFormat("%03i", $9) & "_" & StringTrimLeft($9p[$4k[1] + 1], 4))
ExitLoop
EndIf
Next
ControlListView($a, "", $9y, "SelectClear")
EndIf
_2k()
GUICtrlSetData($9w, "Ready")
GUICtrlSetBkColor($9w, $j)
EndFunc
Func _2g($bh)
GUICtrlSetData($9w, "Working")
GUICtrlSetBkColor($9w, 0xFF4500)
Local $4k = _1g($9y, True)
If $4k[0] <> 1 Then
ReDim $4k[2]
$4k[0] = 1
$4k[1] = 0
EndIf
If $4k[0] = 1 Then
$9j = $9k & "\" & $9p[$4k[1] + 1]
Switch $bh
Case $ao
IniWrite($9j, "Data", "Unknown_Icon_Handling", "Top-Left")
Case $ap
IniWrite($9j, "Data", "Unknown_Icon_Handling", "Bottom-Right")
Case $aq
Local $4i = _37()
If $4i[0] <> -1 Then IniWrite($9j, "Data", "Unknown_Icon_Handling", "Custom-Position," & $4i[0] & "," & $4i[1])
WinMinimizeAllUndo()
Case $ar
IniWrite($9j, "Data", "Unknown_Icon_Handling", "Ask per Icon")
Case $as
IniWrite($9j, "Data", "Unknown_Icon_Handling", "Off-Screen")
EndSwitch
ControlListView($a, "", $9y, "SelectClear")
EndIf
_2k()
GUICtrlSetData($9w, "Ready")
GUICtrlSetBkColor($9w, $j)
EndFunc
Func _2h()
If Not IsHWnd($9n) Then
_3e("Fatal Error in _Set_Locations_Desktop()" & @CRLF & "Desktop Window Handle not found.")
EndIf
Local $bi = 0, $bj, $bk, $4i, $bl
Local $bg = _2t()
If Not IsArray($bg) Or UBound($bg, 2) <> 4 Then
_3e("Error _Set_Locations_Desktop()" & @CRLF & "_Desktop_to_Array() returned wrong dimension." & @CRLF & @CRLF & "Dim-1: " & UBound($bg) & @CRLF & "Dim-2: " & UBound($bg, 2), False)
EndIf
_16($9n)
Local $bd = DllCall($1, "int", "GetSystemMetrics", "int", 78)
Local $be = DllCall($1, "int", "GetSystemMetrics", "int", 79)
Local $bm = IniRead($9j, "Data", "Unknown_Icon_Handling", "Top-Left")
If $bm = "Ask per Icon" Then _18($9n)
Local $bn
If StringInStr($bm, "Custom-Position") Then
$bn = StringSplit($bm, ",")
$bm = "Custom-Position"
$bn[2] = Int($bn[2])
$bn[3] = Int($bn[3])
If Not IsInt($bn[2]) Or Not IsInt($bn[3]) Then
IniWrite($9j, "Data", "Unknown_Icon_Handling", "Top-Left")
$bm = "Top-Left"
EndIf
EndIf
For $9 = 0 To UBound($bg) - 1
$bk = IniRead($9j, "Desktop", _2l($bg[$9][0] & $bg[$9][1] & $bg[$9][2]), "")
If $bk Then
$4i = StringSplit($bk, ":")
If UBound($4i) = 3 Then
_1l($9n, $9, $4i[1], $4i[2])
Else
_3e("Error _Set_Locations_Desktop()" & @CRLF & "Saved Postion is not in the right format." & @CRLF & @CRLF & $bg[$9][0] & @CRLF & $bk, False)
EndIf
Else
Switch $bm
Case "Custom-Position"
_1l($9n, $9, $bn[2], $bn[3])
Case "Off-Screen"
_1l($9n, $9, 9999, 9999)
Case "Ask per Icon"
$bl = _37($bg[$9][0])
If $bl[0] = -1 Then ExitLoop
_1l($9n, $9, $bl[0], $bl[1])
Case "Bottom-Right"
_1l($9n, $9, $bd[0] - 48, $be[0] - 48)
Case Else
_1l($9n, $9, 0, 0)
EndSwitch
EndIf
Next
_18($9n)
EndFunc
Func _2i()
Local $4k = _1g($9y, True)
If $4k[0] = 1 Then
If MsgBox(4 + 16 + 256 + 262144, $b, "Are you sure you want to delete the config file """ & _1f($9y, $4k[1], 1) & """?", 0, $a) = 6 Then _2j()
ControlListView($a, "", $9y, "SelectClear")
EndIf
If $9q Then _2p()
EndFunc
Func _2j()
GUICtrlSetData($9w, "Deleting")
GUICtrlSetBkColor($9w, 0xFF4500)
Local $bo, $bf
Local $4k = _1g($9y, True)
If $4k[0] = 1 Then
$9j = $9k & "\" & $9p[$4k[1] + 1]
$bo = _1f($9y, $4k[1], 1)
Local $bf = StringTrimRight(@ScriptDir, StringLen(@ScriptDir) - StringInStr(@ScriptDir, "\", 0, -1)) & "\ICU - Restore Layout - " & $bo & ".lnk"
Do
$bf = StringReplace($bf, "\\", "\")
Until Not @extended
FileRecycle($bf)
FileRecycle($9j)
ControlListView($a, "", $9y, "SelectClear")
EndIf
_2k()
GUICtrlSetData($9w, "Ready")
GUICtrlSetBkColor($9w, $j)
EndFunc
Func _2k()
For $9 = 1 To $a9[0]
TrayItemDelete($a9[$9])
Next
_17($9y)
$9p = _1p($9k, "*.icf", 1)
Local $bp, $bq, $br, $bs
If Not IsArray($9p) Then
GUICtrlCreateListViewItem("|No Layouts saved", $9x)
GUICtrlSetState($9s, $x)
GUICtrlSetState($9t, $x)
ReDim $a9[2]
$a9[0] = 1
$a9[1] = TrayCreateItem("No Layouts saved", $a6)
TrayItemSetState($a9[1], $7s)
Else
ReDim $a9[$9p[0] + 1]
$a9[0] = $9p[0]
For $9 = 1 To $9p[0]
$bp = IniRead($9k & "\" & $9p[$9], "Data", "Type", "Unknown")
$bq = IniRead($9k & "\" & $9p[$9], "Data", "Date", "Unknown")
$br = IniRead($9k & "\" & $9p[$9], "Data", "Resolution", "Unknown")
$bs = IniRead($9k & "\" & $9p[$9], "Data", "Unknown_Icon_Handling", "Unknown")
GUICtrlCreateListViewItem(Number(StringLeft($9p[$9], 3)) & "|" & $bp & "|" & $bq & "|" & $br & "|" & $bs, $9x)
GUICtrlSetBkColor(-1, 0xefefef)
$a9[$9] = TrayCreateItem("#" & Number(StringLeft($9p[$9], 3)) & " - " & $bp, $a6)
TrayItemSetOnEvent(-1, "_2b")
Next
EndIf
_1k($9y, 0, 20)
_1k($9y, 1, 80 + 48 + 46)
_1k($9y, 2, $2z)
_1k($9y, 3, $2z)
_1k($9y, 4, 80)
EndFunc
Func _2l($bt)
Local $bu = StringSplit(BinaryToString(StringToBinary($bt, 4), 1), "")
Local $bv
$bt = ""
For $9 = 1 To $bu[0]
$bv = Asc($bu[$9])
Switch $bv
Case 45, 46, 48 - 57, 65 To 90, 95, 97 To 122, 126
$bt &= $bu[$9]
Case 32
$bt &= "+"
Case Else
$bt &= "%" & Hex($bv, 2)
EndSwitch
Next
Return $bt
EndFunc
Func _2m($bw)
If $bw = "" Then Return SetError(1, '', 1)
Local $bx = WinGetHandle($bw)
If IsHWnd($bx) Then
WinClose($bx)
WinWaitClose($bx, "", 2)
EndIf
AutoItWinSetTitle($bw)
Return WinGetHandle($bw)
EndFunc
Func _2n($by = True)
Switch $by
Case True
IniWrite($9k & "\ICU.ini", "Settings", "Desktop_Contextmenu_Integration", 1)
_2p()
If @error Then
_3e("Error _DCI_Enable()" & @CRLF & "ICU could not install DCI settings." & @CRLF & "Error code: " & @error & @CRLF & "Extended error code: " & @extended, False)
Return SetError(1)
EndIf
Case False
IniWrite($9k & "\ICU.ini", "Settings", "Desktop_Contextmenu_Integration", 0)
_2p()
If @error Then
_3e("Error _DCI_Enable()" & @CRLF & "ICU could not uninstall DCI settings." & @CRLF & "Error code: " & @error & @CRLF & "Extended error code: " & @extended, False)
Return SetError(1)
EndIf
EndSwitch
$9q = _2o()
Return 1
EndFunc
Func _2o()
Return IniRead($9k & "\ICU.ini", "Settings", "Desktop_Contextmenu_Integration", 0)
EndFunc
Func _2p()
Switch IniRead($9k & "\ICU.ini", "Settings", "Desktop_Contextmenu_Integration", 0)
Case 1
_2q()
If @error Then Return SetError(@error, @extended)
RegWrite("HKEY_CURRENT_USER\Software\Classes\DesktopBackground\shell\ICU_ContextMenu_Anchor", "MUIVerb", "REG_SZ", "ICU")
RegWrite("HKEY_CURRENT_USER\Software\Classes\DesktopBackground\shell\ICU_ContextMenu_Anchor", "Position", "REG_SZ", "Bottom")
RegWrite("HKEY_CURRENT_USER\Software\Classes\DesktopBackground\shell\ICU_ContextMenu_Anchor", "Icon", "REG_EXPAND_SZ", @ScriptFullPath & ",0")
RegWrite("HKEY_CURRENT_USER\Software\Classes\DesktopBackground\shell\ICU_ContextMenu_Anchor", "ExtendedSubCommandsKey", "REG_SZ", "DesktopBackground\ContextMenus\ICU")
RegWrite("HKEY_CURRENT_USER\Software\Classes\DesktopBackground\ContextMenus\ICU\Shell\001_ICU", "Icon", "REG_EXPAND_SZ", "shell32.dll,-22")
RegWrite("HKEY_CURRENT_USER\Software\Classes\DesktopBackground\ContextMenus\ICU\Shell\001_ICU", "MUIVerb", "REG_SZ", "Settings")
RegWrite("HKEY_CURRENT_USER\Software\Classes\DesktopBackground\ContextMenus\ICU\Shell\001_ICU\command", "", "REG_EXPAND_SZ", @ScriptFullPath)
RegWrite("HKEY_CURRENT_USER\Software\Classes\DesktopBackground\ContextMenus\ICU\Shell\002_ICU", "Icon", "REG_EXPAND_SZ", "shell32.dll,-7")
RegWrite("HKEY_CURRENT_USER\Software\Classes\DesktopBackground\ContextMenus\ICU\Shell\002_ICU", "MUIVerb", "REG_SZ", "Save Desktop Layout")
RegWrite("HKEY_CURRENT_USER\Software\Classes\DesktopBackground\ContextMenus\ICU\Shell\002_ICU", "CommandFlags", "REG_DWORD", 0x40)
RegWrite("HKEY_CURRENT_USER\Software\Classes\DesktopBackground\ContextMenus\ICU\Shell\002_ICU\command", "", "REG_EXPAND_SZ", @ScriptFullPath & " save")
Local $9p = _1p($9k, "*.icf", 1), $bz, $bp, $br
If IsArray($9p) Then
For $9 = 1 To $9p[0]
$bz = StringFormat("%03i", $9 + 2)
$bp = IniRead($9k & "\" & $9p[$9], "Data", "Type", "Unknown")
$br = IniRead($9k & "\" & $9p[$9], "Data", "Resolution", "Unknown")
RegWrite("HKEY_CURRENT_USER\Software\Classes\DesktopBackground\ContextMenus\ICU\Shell\" & $bz & "_ICU", "Icon", "REG_EXPAND_SZ", "shell32.dll,-167")
RegWrite("HKEY_CURRENT_USER\Software\Classes\DesktopBackground\ContextMenus\ICU\Shell\" & $bz & "_ICU", "MUIVerb", "REG_EXPAND_SZ", "Restore Layout #" & Number(StringLeft($9p[$9], 3)) & " - " & $bp & " @ " & $br)
RegWrite("HKEY_CURRENT_USER\Software\Classes\DesktopBackground\ContextMenus\ICU\Shell\" & $bz & "_ICU\command", "", "REG_EXPAND_SZ", @ScriptFullPath & " restore " & Number(StringLeft($9p[$9], 3)))
Next
EndIf
Case 0
_2q()
If @error Then Return SetError(@error, @extended)
EndSwitch
EndFunc
Func _2q()
If RegDelete("HKEY_CURRENT_USER\Software\Classes\DesktopBackground\ContextMenus\ICU") = 2 Then Return SetError(@error, @extended)
If RegDelete("HKEY_CURRENT_USER\Software\Classes\DesktopBackground\shell\ICU_ContextMenu_Anchor") = 2 Then Return SetError(@error, @extended)
Return 1
EndFunc
Func _2r()
AutoItWinSetTitle("")
Exit
EndFunc
Func _2s()
If $8s > 0x0600 Then
If IniRead($9k & "\ICU.ini", "Settings", "Desktop_Contextmenu_Integration", 0) = 1 Then
_2n(False)
_2n(True)
EndIf
EndIf
_26()
DllClose($0)
DllClose($1)
DllClose($2)
DllClose($3)
DllClose($4)
DllClose($5)
DllClose($6)
EndFunc
Func _2t()
Local $c0, $c1
Local $c2 = _1b($9n)
If Not $c2 Then
_3e("Error _Desktop_to_Array()" & @CRLF & "Desktop SysListView32 does not seem to contain any icons.", False)
Return
EndIf
Local $bg[$c2][4]
Local $c3
Local $c4
For $9 = 0 To $c2 - 1
$c0 = _1a($9n, $9, 0)
$bg[$9][0] = $c0[3]
If FileExists(@DesktopDir & "\" & $bg[$9][0]) And Not StringInStr($c3, ";" & $bg[$9][0] & ";") Then
$bg[$9][1] = @DesktopDir & "\" & $bg[$9][0]
$c3 &= ";" & $bg[$9][0] & ";"
If StringInStr(FileGetAttrib($bg[$9][1]), "D") Then
$bg[$9][2] = "|_Dir"
Else
$bg[$9][2] = "|_File"
EndIf
ElseIf FileExists(@DesktopCommonDir & "\" & $bg[$9][0]) Then
$bg[$9][1] = @DesktopCommonDir & "\" & $bg[$9][0]
$c4 &= ";" & $bg[$9][0] & ";"
If StringInStr(FileGetAttrib($bg[$9][1]), "D") Then
$bg[$9][2] = "|_Dir"
Else
$bg[$9][2] = "|_File"
EndIf
ElseIf FileExists(@DesktopDir & "\" & $bg[$9][0] & ".lnk") And Not StringInStr($c3, ";" & $bg[$9][0] & ".lnk" & ";") Then
$bg[$9][1] = @DesktopDir & "\" & $bg[$9][0] & ".lnk"
$c3 &= ";" & $bg[$9][0] & ".lnk" & ";"
$bg[$9][2] = "|_lnk"
ElseIf FileExists(@DesktopDir & "\" & $bg[$9][0] & ".url") And Not StringInStr($c3, ";" & $bg[$9][0] & ".url" & ";") Then
$bg[$9][1] = @DesktopDir & "\" & $bg[$9][0] & ".url"
$c3 &= ";" & $bg[$9][0] & ".url" & ";"
$bg[$9][2] = "|_url"
ElseIf FileExists(@DesktopCommonDir & "\" & $bg[$9][0] & ".lnk") Then
$bg[$9][1] = @DesktopCommonDir & "\" & $bg[$9][0] & ".lnk"
$c4 &= ";" & $bg[$9][0] & ".lnk" & ";"
$bg[$9][2] = "|_lnk"
ElseIf FileExists(@DesktopCommonDir & "\" & $bg[$9][0] & ".url") Then
$bg[$9][1] = @DesktopCommonDir & "\" & $bg[$9][0] & ".url"
$c4 &= ";" & $bg[$9][0] & ".url" & ";"
$bg[$9][2] = "|_url"
EndIf
$c1 = _1e($9n, $9)
$bg[$9][3] = $c1[0] & ":" & $c1[1]
Next
Return $bg
EndFunc
Func _2u()
Local $9, $9m, $c5, $9y
$9m = WinGetHandle("[CLASS:Progman]")
$c5 = ControlGetHandle($9m, '', '[CLASS:SHELLDLL_DefView; INSTANCE:1]')
If $9m = '' Or $c5 = '' Then
$c6 = WinList("[CLASS:WorkerW]")
For $9 = 1 To $c6[0][0]
$c5 = ControlGetHandle($c6[$9][1], '', '[CLASS:SHELLDLL_DefView; INSTANCE:1]')
If $c5 <> '' Then
$9m = $c6[$9][1]
ExitLoop
EndIf
Next
EndIf
$9y = ControlGetHandle($c5, '', '[CLASS:SysListView32; INSTANCE:1]')
If $9y = '' Then Return SetError(-1, 0, '')
Return SetExtended($9y, $9m)
EndFunc
Func _2v($c7 = -1, $60 = 8.5, $c8 = 400, $c9 = 0, $ca = Default, $cb = 2)
If IsKeyword($ca) Then
Local $cc = _2x()
$ca = $cc[3]
EndIf
If Not IsDeclared("__i_SetFont_DPI_Ratio") Then
Global $cd = _2y()
$cd = $cd[2]
EndIf
GUICtrlSetFont($c7, $60 / $cd, $c8, $c9, $ca, $cb)
EndFunc
Func _2w($60 = 8.5, $c8 = 400, $c9 = 0, $ca = Default, $3t = Default, $cb = 2)
If Not IsHWnd($3t) Then $3t = GUISwitch(0)
If IsKeyword($ca) Then
Local $cc = _2x()
$ca = $cc[3]
EndIf
If Not IsDeclared("cd") Then
Global $cd = _2y()
$cd = $cd[2]
EndIf
GUISetFont($60 / $cd, $c8, $c9, $ca, $3t, $cb)
EndFunc
Func _2x()
Local $ce[5] = [8.5, 400, 0, "Tahoma", 2]
Local $3t = WinGetHandle(AutoItWinGetTitle())
Local $cf = DllOpen("uxtheme.dll")
Local $cg = DllCall($cf, 'ptr', 'OpenThemeData', 'hwnd', $3t, 'wstr', "Static")
If @error Then Return $ce
$cg = $cg[0]
Local $ch = DllStructCreate("long;long;long;long;long;byte;byte;byte;byte;byte;byte;byte;byte;wchar[32]")
Local $ci = DllStructGetPtr($ch)
DllCall($cf, 'long', 'GetThemeSysFont', 'HANDLE', $cg, 'int', 805, 'ptr', $ci)
If @error Then Return $ce
Local $cj = DllCall("user32.dll", "handle", "GetDC", "hwnd", $3t)
If @error Then Return $ce
$cj = $cj[0]
Local $ck = DllCall("gdi32.dll", "int", "GetDeviceCaps", "handle", $cj, "int", 90)
If Not @error Then
$ck = $ck[0]
$ce[0] = Int(2 *(.25 - DllStructGetData($ch, 1) * 72 / $ck)) / 2
EndIf
DllCall("user32.dll", "int", "ReleaseDC", "hwnd", $3t, "handle", $cj)
$ce[3] = DllStructGetData($ch, 14)
$ce[1] = DllStructGetData($ch, 5)
$ce[4] = DllStructGetData($ch, 12)
If DllStructGetData($ch, 6) Then $ce[2] += 2
If DllStructGetData($ch, 7) Then $ce[2] += 4
If DllStructGetData($ch, 8) Then $ce[2] += 8
Return $ce
EndFunc
Func _2y()
Local $cl[3]
Local $cm, $cn, $co = 90, $3t = 0
Local $cj = DllCall($1, "long", "GetDC", "long", $3t)
Local $cp = DllCall($3, "long", "GetDeviceCaps", "long", $cj[0], "long", $co)
Local $cj = DllCall($1, "long", "ReleaseDC", "long", $3t, "long", $cj)
$cm = $cp[0]
Select
Case $cm = 0
$cm = 96
$cn = 94
Case $cm < 84
$cn = $cm / 105
Case $cm < 121
$cn = $cm / 96
Case $cm < 145
$cn = $cm / 95
Case Else
$cn = $cm / 94
EndSelect
$cl[0] = 2
$cl[1] = $cm
$cl[2] = $cn
Return $cl
EndFunc
Func _2z($3t, $3u, $cq, $cr)
Local $cs = DllStructCreate($37, $cr)
Local $ct = HWnd(DllStructGetData($cs, "hWndFrom"))
Local $cu = DllStructGetData($cs, "IDFrom")
Local $4c = DllStructGetData($cs, "Code")
Switch $ct
Case $9y
Switch $4c
Case $2y
$ay = True
Return $t
EndSwitch
EndSwitch
Return $t
EndFunc
Func _30($3t, $3u, $cq, $cr)
$6u = _1i($9y)
If $6u[0] < 0 Then Return
Local $cv = $6u[0] + 1
Local $cw = $9p[$6u[0] + 1]
Local $9j = $9k & "\" & $9p[$6u[0] + 1]
Local $cx = _1q(32)
_1v($cx, 0, "Top-Left", $ao)
_1v($cx, 1, "Bottom-Right", $ap)
_1v($cx, 2, "Custom Position", $aq)
_1v($cx, 3, "Ask per Icon", $ar)
_1v($cx, 4, "Off-Screen", $as)
Local $8g = _1r(32)
_1v($8g, 0, "Move unkown Icons", $an, $cx)
_1v($8g, 1, "")
_1v($8g, 2, "Restore", $at)
_1v($8g, 3, "Delete", $au)
_1v($8g, 4, "Duplicate", $av)
_1v($8g, 5, "")
_1v($8g, 6, "Move Config File to #", $ax)
_1v($8g, 7, "Show Config File", $aw)
Switch IniRead($9j, "Data", "Unknown_Icon_Handling", "Top-Left")
Case "Off-Screen"
_1x($cx, 4, $7w)
Case "Ask per Icon"
_1x($cx, 3, $7w)
Case "Bottom-Right"
_1x($cx, 1, $7w)
Case "Top-Left"
_1x($cx, 0, $7w)
Case Else
_1x($cx, 2, $7w)
EndSwitch
Local $cy = _20($8g, $cq, -1, -1, 1, 1, 2)
Switch $cy
Case $ao To $as
_2g($cy)
Case $at
_2e()
Case $au
_2i()
Case $av
_2f()
Case $aw
Run("notepad.exe " & $9j)
Case $ax
Local $cz = InputBox($b, "Enter a new # position number for the config file", Default, Default, 300, 130, Default, Default, 0, $a)
If Not @error Then
$cz = Int($cz)
If $cz And $cv <> $cz Then
FileMove($9k & "\" & $cw, $9k & "\" & "x_" & StringTrimLeft($cw, 4))
If $cz > $9p[0] Then $cz = $9p[0]
If $cz > $cv Then
For $9 = $cv + 1 To $cz
FileMove($9k & "\" & $9p[$9], $9k & "\" & StringFormat("%03i", $9 - 1) & "_" & StringTrimLeft($9p[$9], 4))
Next
Else
For $9 = $cz To $cv - 1
FileMove($9k & "\" & $9p[$9], $9k & "\" & StringFormat("%03i", $9 + 1) & "_" & StringTrimLeft($9p[$9], 4))
Next
EndIf
FileMove($9k & "\" & "x_" & StringTrimLeft($cw, 4), $9k & "\" & StringFormat("%03i", $cz) & "_" & StringTrimLeft($cw, 4))
_2k()
EndIf
EndIf
EndSwitch
_1s($8g)
_1s($cx)
Return True
EndFunc
Func _31($3t, $b1, $3v, $3w)
Switch BitAND($3v, 0x0000FFFF)
Case $a3
ShellExecute('http://www.funk.eu')
Case $a4
ShellExecute("https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=smf%40funk%2eeu&item_name=Thank%20you%20for%20your%20donation%20to%20ICU...&no_shipping=0&no_note=1&tax=0&currency_code=EUR&lc=US&bn=PP%2dDonationsBF&charset=UTF%2d8")
Case $a2
ShellExecute("http://creativecommons.org/licenses/by-nc-nd/3.0/us/")
Case $ab
If BitAND(GUICtrlRead($ab), $u) Then
IniWrite($9k & "\ICU.ini", "Settings", "Checkbox_Warning_AutoArrange", $u)
Else
IniWrite($9k & "\ICU.ini", "Settings", "Checkbox_Warning_AutoArrange", $v)
EndIf
Case $ac
If BitAND(GUICtrlRead($ac), $u) Then
IniWrite($9k & "\ICU.ini", "Settings", "Checkbox_Warning_AlignToGrid", $u)
Else
IniWrite($9k & "\ICU.ini", "Settings", "Checkbox_Warning_AlignToGrid", $v)
EndIf
EndSwitch
Return $t
EndFunc
Func _32($d0, $d1 = False)
If Not IsBinary($d0) Then Return SetError(1, 0, 0)
Local $3s
Local Const $d2 = Binary($d0)
Local Const $d3 = BinaryLen($d2)
Local Const $d4 = _v($d3, $30)
Local Const $d5 = _w($d4)
Local $d6 = DllStructCreate("byte[" & $d3 & "]", $d5)
DllStructSetData($d6, 1, $d2)
_x($d4)
$3s = DllCall("ole32.dll", "int", "CreateStreamOnHGlobal", "handle", $d5, "int", True, "ptr*", 0)
If @error Then SetError(2, 0, 0)
Local Const $d7 = $3s[3]
$3s = DllCall($92, "uint", "GdipCreateBitmapFromStream", "ptr", $d7, "int*", 0)
If @error Then SetError(3, 0, 0)
Local Const $95 = $3s[2]
Local $d8 = DllStructCreate("word vt;word r1;word r2;word r3;ptr data; ptr")
DllCall("oleaut32.dll", "long", "DispCallFunc", "ptr", $d7, "dword", 8 + 8 * @AutoItX64, _
"dword", 4, "dword", 23, "dword", 0, "ptr", 0, "ptr", 0, "ptr", DllStructGetPtr($d8))
$d6 = 0
$d8 = 0
If $d1 Then
Local Const $d9 = _33($95)
_23($95)
Return $d9
EndIf
Return $95
EndFunc
Func _33($95)
Local $da, $8y, $9a, $db, $dc = 0
$8y = DllCall($92, 'uint', 'GdipGetImageDimension', 'ptr', $95, 'float*', 0, 'float*', 0)
If(@error) Or($8y[0]) Then Return 0
$9a = _24($95, 0, 0, $8y[2], $8y[3], $8z, $91)
$db = DllStructGetData($9a, 'Scan0')
If Not $db Then Return 0
$da = DllStructCreate('dword;long;long;ushort;ushort;dword;dword;long;long;dword;dword')
DllStructSetData($da, 1, DllStructGetSize($da))
DllStructSetData($da, 2, $8y[2])
DllStructSetData($da, 3, $8y[3])
DllStructSetData($da, 4, 1)
DllStructSetData($da, 5, 32)
DllStructSetData($da, 6, 0)
$dc = DllCall('gdi32.dll', 'ptr', 'CreateDIBSection', 'hwnd', 0, 'ptr', DllStructGetPtr($da), 'uint', 0, 'ptr*', 0, 'ptr', 0, 'dword', 0)
If(Not @error) And($dc[0]) Then
DllCall('gdi32.dll', 'dword', 'SetBitmapBits', 'ptr', $dc[0], 'dword', $8y[2] * $8y[3] * 4, 'ptr', DllStructGetData($9a, 'Scan0'))
$dc = $dc[0]
Else
$dc = 0
EndIf
_25($95, $9a)
Return $dc
EndFunc
Func _34()
Local $dd
$dd &= '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'
$dd &= '8V/Gq1pR/wCpemu/+UAkQ01o64+C+VJ8w93dhPjs1Prom+zHdmImMv479NnkMo/LzsVJgJ85bLQZ2Bk+GP3dpAey7YH4MZMTQxTHRUlZnrHRaaCa7kOyHtWY5V7jJWpA40SuAdRWZLFuVCZVa9ejUcK2YmWxEeuXWygGBaIhYJ8jkixddfqADpBLr9sq2QkP1L01l/kAjxVhklGlBfFneYcnpYvyhZMAuGfs8GtimIT7f7kdkIgg0IyV0gF+NP5xCwIPrrS7q0AmB8MX6kWi8kDitl7GQdqkcr/MPWdQcknGkwuSROzU6wEVu2UcmBLNhXlwk01TDksUOgJkPj4IvowWAP8AXBdVdq+WtFtzPSaoDQ/5AvsrR9eq1b9EvzswO7AUdsMgVxBQWZnUOWS/0vmsBmjOOTkyw9GYeKh/sJLZkP8AU9dfMB//2Q=='
Return Binary(_36($dd))
EndFunc
Func _35()
Local $dd
$dd &= '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'
$dd &= 'BiQ59DpqaiDMpwyyGil/y8jUtzKbs/XrPX6NlzA0Fq9foqA7EYddkKhhvXqW68nIhK5YUDZtCRlS7vKubCww2f7X/TgI1DZypAvt745Zrq74ep06A04y+0pt1F1bySLEccF+jURppamw3nU66shA/CMyjYfkMcs11d8cs11d8cs11d8cs11d8cs11d8cs11d8cs11d8cs11d8Ba0JFk2ATj/xAAhEAEBAAIBBAMBAQAAAAAAAAABEQAhMUFRwfAQYYEwof/aAAgBAQABPyEjt9Sm/s/3N+Tk+N6dyqu8mReAF6bkuL1MpnVzvVlo7AqyBemOUCl5I/rA1zcI+CNmEtSUVQ1UcJJoLXlVWoB1XFfjR6R6E0baz3zxnvnjPfPGe+eMZyioRfoyh7AlLRBxx0Y9fYp5BYPjlNbM3zC89jUAzgcl1jFNRJVIbnTaCMoSXOMHNplE/ebvkZqiniGi6pQMOwXSyBsltvCZrjmxfqQOYTU5cYHHXXboKYjzWwqMDtY+1CcxjDHwUapL28PdaZMZtBUj17bWB0rfAr2lMK3QJ0+BKVrGNKgsovGWlRShRN77Bo7H8SSSSSSSSeQQ0SVeq98//9oADAMBAAIAAwAAABDAku1tuYBXOASefb//AP8A/wD/xAAgEQEAAgMAAwADAQAAAAAAAAABABEhMWFBUXEggZHw/9oACAEDAQE/EGaGz+EoW4bwH5dpAusuwJ3zn7UA+J7ZrEQo1yxVPj7v5UQk7q2U5HNV8jtsKNsr8FeJZQMC8efM4E4E4E4EI0eIgKKKGhaLLwZ1DgZkDAivLnOaxCzhob76iivWv5Eprxv0m2u9VXuz3AL4FFaV0XWcueREhdpuA4aY158foJSxO4Ha0owa/LR8gwUTgRkERKf9cXDHW1x6ys4E4E4E4E4E4E4E4EQtn//EACARAQACAwADAQADAAAAAAAAAAEAESExYUFRcYEgkaH/2gAIAQIBAT8QPi4D+2pbmlshfyj3f7F2yqlDzxRfpZ7Caye28cr7BwNXQHLTqvtwltur1YaTA39xAAVmmGvNvO9NagBpyaz4vH+Tozozozoxjb5gKuCEWhdEMqG0fyFpfDtZXwYaKvMpBd/BcG2/eVmbKuz7Ji/6v0D6j2ZQEWDbV4wYfcKUmEFZGGxm8efcGwjSTZgBvCmefy2fYsts6MvwiWONn5AyUu9Bn3gLZ0Z0Z0Z0Z0Z0Z0Z0YBRP/8QAHxABAQEBAAEEAwAAAAAAAAAAAREAIUEQMVFhIDCB/9oACAEBAAE/EA7IDlu0yqo+V+Tmt+pO4G+dFuUcCWCR+2mANAWCYKrl4BIJSsFTgNojpCgkkEl9M/VLL492YIQQnADPN1OCQCmEfnpz/mV+Bz8a1atWW6/IRWA7A79ZqmiliF92jvmTJYuvyADJaRCNKNQSxgjJSMKADB6m3aWsmWIMbGxEELhbhBEuNQ5gAwW0qo35faywmYAHZlpg/JwoBjx9RwQCmMeLBHdYu/DRlHPCo+zcdS3zApEBFyyKnpPfN/JUlwjiSD7mGoKUCQYWJYHsHpILSTWoQ4JUJaI9y6S1Rh6CGiKI8P0SSSSSSSSTAMD5k7LX53//2Q=='
Return Binary(_36($dd))
EndFunc
Func _36($de)
Local $df = DllStructCreate("int")
Local $dg = DllCall("Crypt32.dll", "int", "CryptStringToBinary", "str", $de, "int", 0, "int", 1, "ptr", 0, "ptr", DllStructGetPtr($df, 1), "ptr", 0, "ptr", 0)
If @error Or Not $dg[0] Then Return SetError(1, 0, "")
Local $dh = DllStructCreate("byte[" & DllStructGetData($df, 1) & "]")
$dg = DllCall("Crypt32.dll", "int", "CryptStringToBinary", "str", $de, "int", 0, "int", 1, "ptr", DllStructGetPtr($dh), "ptr", DllStructGetPtr($df, 1), "ptr", 0, "ptr", 0)
If @error Or Not $dg[0] Then Return SetError(2, 0, "")
Return DllStructGetData($dh, 1)
EndFunc
Func _37($di = "")
$9i = 0
_39()
OnAutoItExitRegister("_3a")
Send("#m")
HotKeySet("{Esc}", "_38")
Local $bd = DllCall("user32.dll", "int", "GetSystemMetrics", "int", 78)
Local $be = DllCall("user32.dll", "int", "GetSystemMetrics", "int", 79)
Local $dj = GUICreate("GUI", $bd[0], $be[0], 0, 0, $1d, BitOR($1e, $1f, $1g))
GUISetBkColor(0xABABAB)
_l($dj, 0x010101, 0)
GUISetCursor(3)
GUISetState()
Local $dk, $dl
$dk = MouseGetPos()
$dl = $dk
If Not $di Then
ToolTip("Select Desktop Position with left mouseclick (ESC to Exit)", Default, Default, "ICU", 1, 4)
Else
ToolTip(@CRLF & $di & @CRLF & @CRLF & $dk[0] & "x" & $dk[1] & ", Press ESC to exit", Default, Default, "ICU - Move unkown Icon", 1, 4)
EndIf
While Sleep(10)
If $9i Then ExitLoop
$dk = MouseGetPos()
If $dk[0] <> $dl[0] Or $dk[1] <> $dl[1] Then
$dl = $dk
If $di Then
ToolTip(@CRLF & $di & @CRLF & @CRLF & $dk[0] & "x" & $dk[1] & ", Press ESC to exit", Default, Default, "ICU - Move unkown Icon", 1, 4)
Else
ToolTip($dk[0] & "x" & $dk[1])
EndIf
EndIf
WEnd
ToolTip("")
GUIDelete($dj)
HotKeySet("{Esc}")
_3a()
OnAutoItExitUnRegister("_3a")
If $9i = 2 Then
$dk[0] = -1
$dk[1] = -1
EndIf
Return $dk
EndFunc
Func _38()
$9i = 2
EndFunc
Func _39()
If $9h = -1 Then
$9h = DllCallbackRegister("_3b", "int", "uint;wparam;lparam")
EndIf
If $9g = -1 Then
Local $dm = _b(0)
$9g = _m($44, DllCallbackGetPtr($9h), $dm, 0)
EndIf
EndFunc
Func _3a()
If $9g <> -1 Then
_n($9g)
$9g = -1
EndIf
If $9h <> -1 Then
DllCallbackFree($9h)
$9h = -1
EndIf
EndFunc
Func _3b($dn, $3v, $3w)
#forceref $dn, $3v, $3w
If $dn < 0 Then Return _7($9g, $dn, $3v, $3w)
Switch $3v
Case $1k
Return -1
Case $1l
$9i = 1
Return -1
EndSwitch
Return _7($9g, $dn, $3v, $3w)
EndFunc
Func _3c()
$g = False
GUISetState(@SW_HIDE, $a)
GUISetState(@SW_SHOW, $d)
Opt("GUICloseOnESC", 1)
Local $b1
While 1
$b1 = GUIGetMsg(1)
Switch $b1[1]
Case $d
Switch $b1[0]
Case $r
ExitLoop
Case $e
ShellExecute("http://creativecommons.org/licenses/by-nc-sa/3.0/", "", "", "open")
Case $f
ShellExecute('http://www.funk.eu')
EndSwitch
EndSwitch
If $g = True Then ExitLoop
WEnd
Opt("GUICloseOnESC", 0)
GUISetState(@SW_HIDE, $d)
GUISetState(@SW_SHOW, $a)
If $h Then
$h = False
_2c()
If $9q Then _2p()
EndIf
EndFunc
Func _3d()
$d = GUICreate($b, 600, 330, Default, Default, $1a)
_2w(8, 400, 0, "Arial")
GUISetBkColor(0xEEF1F6)
WinSetOnTop($d, "", 1)
GUICtrlCreateIcon(@ScriptName, 99, 20, 40, 48, 48)
GUICtrlSetCursor(-1, 0)
GUICtrlCreateLabel($b, 80 + 10, 10, 380, 20)
_2v(-1, 9, 800, 0, "Arial")
GUICtrlCreateLabel('This program is freeware under a Creative Commons License "by-nc-sa 3.0":', 80 + 10, 40 - 10, 380, 20)
GUICtrlCreateLabel('- Attribution' & @CRLF _
& '- Noncommercial' & @CRLF _
& '- Share Alike', 80 + 20, 60 - 10, 380, 50)
_2v(-1, 8.5, 800, 0, "Arial")
$e = GUICtrlCreateLabel("http://creativecommons.org/licenses/by-nc-sa/3.0/", 80 + 34, 110 - 10, 230, 20)
GUICtrlSetColor(-1, 0x0000FF)
GUICtrlSetCursor(-1, 0)
GUICtrlCreateLabel('Visit                                                                               for details.', 80 + 10, 110 - 10, 380, 20)
GUICtrlSetBkColor(-1, $0z)
GUICtrlCreateEdit('I share this program with NO WARRANTIES and NO LIABILITY FOR DAMAGES!' & @CRLF _
& @CRLF _
& 'Special thanks goes to Melba23 for helping with the initial program version.' & @CRLF & @CRLF _
& 'Saved config files can be changed with the "right-click" contextmenu on the listview.' & @CRLF & @CRLF _
& 'ICU supports the following commandline parameters:' & @CRLF & @CRLF _
& '"icu.exe restore 2"' & @CRLF & 'Will restore the config #2 in the list.' & @CRLF & @CRLF _
& '"icu.exe restore NameX"' & @CRLF & 'Will restore the first config with "NameX" in the name.' & @CRLF & @CRLF _
& '"icu.exe restore %resolution%"' & @CRLF & '%resolution% as a wildcard will be replaced with the current resolution and bit depth (e.g. "1440x900x32"). Will restore the first config that matches the wildcard name name.' & @CRLF & @CRLF _
& '"icu.exe autosave"' & @CRLF & 'Saves the config to a timestamped file (e.g. for autostart usage).' & @CRLF & @CRLF _
& '"icu.exe save"' & @CRLF & 'Will bring up the ICU save config dialog.' & @CRLF & @CRLF _
& '"icu.exe savereplace 2"' & @CRLF & 'Will replace the saved config #2 with a new save, will NOT bring up save config dialog but use most recent settings.' & @CRLF & @CRLF _
& '"icu.exe savereplace NameX"' & @CRLF & 'Will replace the first config with "NameX" in the name with a new save, will NOT bring up save config dialog but use most recent settings.' & @CRLF & @CRLF _
& '"icu.exe savereplace %resolution%"' & @CRLF & '%resolution% as a wildcard will be replaced with the current resolution and bit depth (e.g. "1440x900x32"). Will replace the first config that matches the new save name.' & @CRLF & @CRLF _
& '"icu.exe minimized"' & @CRLF & 'Will start ICU in minimized mode / adds an ICU icon to tray. Useful for "Autostart" (esp. on XP without DCI) usage.' & @CRLF & @CRLF _
& '"icu.exe toggle 1 2"' & @CRLF & '"icu.exe toggle Config_A Config_B"' & @CRLF & 'Both configs must exist. The configs have a "last saved timestamp", ICU will evaluate which timestamp is older. The older one will be replaced with the current config and the newer one will be restored. CAUTION: ICU might get confused which config to restore if other configs are used in parallel. Always create a duplicate of the respective config files before trying the "toggle" switch.' & @CRLF & @CRLF _
& 'For commerical usage contact me via my homepage at http://www.funk.eu.' & @CRLF & @CRLF _
& '© ICU - Icon Configuration Utility 2009-2013 by Karsten Funk. All rights reserved.' _
& '', 10, 140, 575, 140, BitOR($1b, $m))
GUICtrlSetBkColor(-1, 0xffffff)
EndFunc
Func _3e($6e, $do = True)
TraySetState(1 + 4)
TraySetToolTip("ICU")
TraySetIcon("stop")
TrayTip($b & " - Error", $6e, 10, 3)
If $do Then
Sleep(5000)
AutoItWinSetTitle("")
Exit
EndIf
Sleep(3000)
TraySetState(8)
TraySetIcon(@ScriptDir, 0)
TraySetState(2)
EndFunc
Func _3f($dp)
Local $dq = StringSplit($dp, " ")
If $dq[0] - 2 Then
Return SetError(1, 0, "")
EndIf
Local $dr = StringSplit($dq[1], "/")
Local $ds = StringSplit($dq[2], ":")
If $dr[0] - 3 Or $ds[0] - 3 Then
Return SetError(1, 0, "")
EndIf
If $dr[2] < 3 Then
$dr[2] += 12
$dr[1] -= 1
EndIf
Local $dt = Int($dr[1] / 100)
Local $du = Int($dt / 4)
Local $dv = 2 - $dt + $du
Local $dw = Int(1461 *($dr[1] + 4716) / 4)
Local $dx = Int(153 *($dr[2] + 1) / 5)
Local $dy = $dv + $dr[3] + $dw + $dx - 2442112
Local $dz = $ds[1] * 3600 + $ds[2] * 60 + $ds[3]
Return SetError(0, 0, $dy * 86400 + $dz)
EndFunc
