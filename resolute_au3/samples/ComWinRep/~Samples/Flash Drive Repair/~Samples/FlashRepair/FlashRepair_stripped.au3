#NoTrayIcon
#OnAutoItStartRegister "_ReBarStartUp"
Opt("CaretCoordMode", 1)
Opt("ExpandEnvStrings", 1)
Opt("ExpandVarStrings", 1)
Opt("GUICloseOnESC", 1)
Opt("GUICoordMode", 1)
Opt("GUIDataSeparatorChar", "|")
Opt("GUIOnEventMode", 1)
Opt("GUIResizeMode", 802)
Opt("GUIEventOptions", 0)
Opt("MouseClickDelay", 10)
Opt("MouseClickDownDelay", 10)
Opt("MouseClickDragDelay", 250)
Opt("MouseCoordMode", 1)
Opt("MustDeclareVars", 1)
Opt("PixelCoordMode", 1)
Opt("SendAttachMode", 0)
Opt("SendCapslockMode", 1)
Opt("SendKeyDelay", 5)
Opt("SendKeyDownDelay", 1)
Opt("TCPTimeout", 100)
Opt("TrayAutoPause", 1)
Opt("TrayIconDebug", 1)
Opt("TrayIconHide", 1)
Opt("TrayMenuMode", 1)
Opt("TrayOnEventMode", 1)
Opt("WinDetectHiddenText", 0)
Opt("WinSearchChildren", 1)
Opt("WinTextMatchMode", 1)
Opt("WinTitleMatchMode", 1)
Opt("WinWaitDelay", 250)
Global Const $LVCF_FMT = 0x0001
Global Const $LVCF_IMAGE = 0x0010
Global Const $LVCF_TEXT = 0x0004
Global Const $LVCF_WIDTH = 0x0002
Global Const $LVCFMT_BITMAP_ON_RIGHT = 0x1000
Global Const $LVCFMT_CENTER = 0x0002
Global Const $LVCFMT_COL_HAS_IMAGES = 0x8000
Global Const $LVCFMT_IMAGE = 0x0800
Global Const $LVCFMT_LEFT = 0x0000
Global Const $LVCFMT_RIGHT = 0x0001
Global Const $LVIF_IMAGE = 0x00000002
Global Const $LVIF_PARAM = 0x00000004
Global Const $LVIF_STATE = 0x00000008
Global Const $LVIF_TEXT = 0x00000001
Global Const $LVIS_FOCUSED = 0x0001
Global Const $LVS_NOCOLUMNHEADER = 0x4000
Global Const $LVS_REPORT = 0x0001
Global Const $LVS_EX_DOUBLEBUFFER = 0x00010000
Global Const $LVS_EX_FULLROWSELECT = 0x00000020
Global Const $LVS_EX_INFOTIP = 0x00000400
Global Const $LVS_EX_SUBITEMIMAGES = 0x00000002
Global Const $LVM_FIRST = 0x1000
Global Const $LVM_DELETEALLITEMS =($LVM_FIRST + 9)
Global Const $LVM_ENSUREVISIBLE =($LVM_FIRST + 19)
Global Const $LVM_GETHEADER =($LVM_FIRST + 31)
Global Const $LVM_GETITEMA =($LVM_FIRST + 5)
Global Const $LVM_GETITEMW =($LVM_FIRST + 75)
Global Const $LVM_GETITEMCOUNT =($LVM_FIRST + 4)
Global Const $LVM_GETUNICODEFORMAT = 0x2000 + 6
Global Const $LVM_INSERTCOLUMNA =($LVM_FIRST + 27)
Global Const $LVM_INSERTCOLUMNW =($LVM_FIRST + 97)
Global Const $LVM_INSERTITEMA =($LVM_FIRST + 7)
Global Const $LVM_INSERTITEMW =($LVM_FIRST + 77)
Global Const $LVM_SETCOLUMNA =($LVM_FIRST + 26)
Global Const $LVM_SETCOLUMNW =($LVM_FIRST + 96)
Global Const $LVM_SETEXTENDEDLISTVIEWSTYLE =($LVM_FIRST + 54)
Global Const $LVM_SETIMAGELIST =($LVM_FIRST + 3)
Global Const $LVM_SETITEMA =($LVM_FIRST + 6)
Global Const $LVM_SETITEMW =($LVM_FIRST + 76)
Global Const $LVSIL_NORMAL = 0
Global Const $LVSIL_SMALL = 1
Global Const $LVSIL_STATE = 2
Global Const $WS_VSCROLL = 0x00200000
Global Const $WS_CAPTION = 0x00C00000
Global Const $WS_POPUPWINDOW = 0x80880000
Global Const $WS_EX_CLIENTEDGE = 0x00000200
Global Const $WS_EX_TOPMOST = 0x00000008
Global Const $BS_DEFPUSHBUTTON = 0x0001
Global Const $BS_AUTORADIOBUTTON = 0x0009
Global Const $SS_RIGHT = 0x2
Global Const $STR_CASESENSE = 1
Global Const $STR_STRIPLEADING = 1
Global Const $STR_STRIPTRAILING = 2
Global Const $STR_STRIPSPACES = 4
Global Const $STR_REGEXPARRAYMATCH = 1
Global Const $GUI_EVENT_CLOSE = -3
Global Const $GUI_CHECKED = 1
Global Const $GUI_UNCHECKED = 4
Global Const $GUI_SHOW = 16
Global Const $GUI_HIDE = 32
Global Const $GUI_ENABLE = 64
Global Const $GUI_DISABLE = 128
Global Const $GUI_FOCUS = 256
Global Const $GUI_DEFBUTTON = 512
Global Const $ES_RIGHT = 2
Global Const $ES_READONLY = 2048
Global Const $ES_NUMBER = 8192
Global Const $ILC_MASK = 0x00000001
Global Const $ILC_COLOR = 0x00000000
Global Const $ILC_COLORDDB = 0x000000FE
Global Const $ILC_COLOR4 = 0x00000004
Global Const $ILC_COLOR8 = 0x00000008
Global Const $ILC_COLOR16 = 0x00000010
Global Const $ILC_COLOR24 = 0x00000018
Global Const $ILC_COLOR32 = 0x00000020
Global Const $ILC_MIRROR = 0x00002000
Global Const $ILC_PERITEMMIRROR = 0x00008000
Global Const $tagRECT = "struct;long Left;long Top;long Right;long Bottom;endstruct"
Global Const $tagSYSTEMTIME = "struct;word Year;word Month;word Dow;word Day;word Hour;word Minute;word Second;word MSeconds;endstruct"
Global Const $tagLVITEM = "struct;uint Mask;int Item;int SubItem;uint State;uint StateMask;ptr Text;int TextMax;int Image;lparam Param;" & "int Indent;int GroupID;uint Columns;ptr pColumns;ptr piColFmt;int iGroup;endstruct"
Global Const $tagREBARBANDINFO = "uint cbSize;uint fMask;uint fStyle;dword clrFore;dword clrBack;ptr lpText;uint cch;" & "int iImage;hwnd hwndChild;uint cxMinChild;uint cyMinChild;uint cx;handle hbmBack;uint wID;uint cyChild;uint cyMaxChild;" & "uint cyIntegral;uint cxIdeal;lparam lParam;uint cxHeader" &((@OSVersion = "WIN_XP") ? "" : ";" & $tagRECT & ";uint uChevronState")
Global Const $tagSECURITY_ATTRIBUTES = "dword Length;ptr Descriptor;bool InheritHandle"
Global Const $STDERR_MERGED = 8
Global Const $TIP_INFOICON = 1
Global Const $TIP_WARNINGICON = 2
Global Const $TIP_BALLOON = 1
Global Const $FO_APPEND = 1
Global Const $FO_FULLFILE_DETECT = 16384
Global Const $FV_COMPANYNAME = "CompanyName"
Global Const $FV_PRODUCTNAME = "ProductName"
Global Const $MB_OK = 0
Global Const $MB_ICONERROR = 16
Global Const $MB_ICONHAND = 16
Global Const $MB_ICONINFORMATION = 64
Global Const $MB_SYSTEMMODAL = 4096
Global Const $SE_PRIVILEGE_ENABLED = 0x00000002
Global Enum $SECURITYANONYMOUS = 0, $SECURITYIDENTIFICATION, $SECURITYIMPERSONATION, $SECURITYDELEGATION
Global Const $TOKEN_QUERY = 0x00000008
Global Const $TOKEN_ADJUST_PRIVILEGES = 0x00000020
Func _WinAPI_GetLastError(Const $_iCurrentError = @error, Const $_iCurrentExtended = @extended)
Local $aResult = DllCall("kernel32.dll", "dword", "GetLastError")
Return SetError($_iCurrentError, $_iCurrentExtended, $aResult[0])
EndFunc
Func _Security__AdjustTokenPrivileges($hToken, $bDisableAll, $tNewState, $iBufferLen, $tPrevState = 0, $pRequired = 0)
Local $aCall = DllCall("advapi32.dll", "bool", "AdjustTokenPrivileges", "handle", $hToken, "bool", $bDisableAll, "struct*", $tNewState, "dword", $iBufferLen, "struct*", $tPrevState, "struct*", $pRequired)
If @error Then Return SetError(@error, @extended, False)
Return Not($aCall[0] = 0)
EndFunc
Func _Security__ImpersonateSelf($iLevel = $SECURITYIMPERSONATION)
Local $aCall = DllCall("advapi32.dll", "bool", "ImpersonateSelf", "int", $iLevel)
If @error Then Return SetError(@error, @extended, False)
Return Not($aCall[0] = 0)
EndFunc
Func _Security__LookupPrivilegeValue($sSystem, $sName)
Local $aCall = DllCall("advapi32.dll", "bool", "LookupPrivilegeValueW", "wstr", $sSystem, "wstr", $sName, "int64*", 0)
If @error Or Not $aCall[0] Then Return SetError(@error, @extended, 0)
Return $aCall[3]
EndFunc
Func _Security__OpenThreadToken($iAccess, $hThread = 0, $bOpenAsSelf = False)
If $hThread = 0 Then
Local $aResult = DllCall("kernel32.dll", "handle", "GetCurrentThread")
If @error Then Return SetError(@error + 10, @extended, 0)
$hThread = $aResult[0]
EndIf
Local $aCall = DllCall("advapi32.dll", "bool", "OpenThreadToken", "handle", $hThread, "dword", $iAccess, "bool", $bOpenAsSelf, "handle*", 0)
If @error Or Not $aCall[0] Then Return SetError(@error, @extended, 0)
Return $aCall[4]
EndFunc
Func _Security__OpenThreadTokenEx($iAccess, $hThread = 0, $bOpenAsSelf = False)
Local $hToken = _Security__OpenThreadToken($iAccess, $hThread, $bOpenAsSelf)
If $hToken = 0 Then
Local Const $ERROR_NO_TOKEN = 1008
If _WinAPI_GetLastError() <> $ERROR_NO_TOKEN Then Return SetError(20, _WinAPI_GetLastError(), 0)
If Not _Security__ImpersonateSelf() Then Return SetError(@error + 10, _WinAPI_GetLastError(), 0)
$hToken = _Security__OpenThreadToken($iAccess, $hThread, $bOpenAsSelf)
If $hToken = 0 Then Return SetError(@error, _WinAPI_GetLastError(), 0)
EndIf
Return $hToken
EndFunc
Func _Security__SetPrivilege($hToken, $sPrivilege, $bEnable)
Local $iLUID = _Security__LookupPrivilegeValue("", $sPrivilege)
If $iLUID = 0 Then Return SetError(@error + 10, @extended, False)
Local Const $tagTOKEN_PRIVILEGES = "dword Count;align 4;int64 LUID;dword Attributes"
Local $tCurrState = DllStructCreate($tagTOKEN_PRIVILEGES)
Local $iCurrState = DllStructGetSize($tCurrState)
Local $tPrevState = DllStructCreate($tagTOKEN_PRIVILEGES)
Local $iPrevState = DllStructGetSize($tPrevState)
Local $tRequired = DllStructCreate("int Data")
DllStructSetData($tCurrState, "Count", 1)
DllStructSetData($tCurrState, "LUID", $iLUID)
If Not _Security__AdjustTokenPrivileges($hToken, False, $tCurrState, $iCurrState, $tPrevState, $tRequired) Then Return SetError(2, @error, False)
DllStructSetData($tPrevState, "Count", 1)
DllStructSetData($tPrevState, "LUID", $iLUID)
Local $iAttributes = DllStructGetData($tPrevState, "Attributes")
If $bEnable Then
$iAttributes = BitOR($iAttributes, $SE_PRIVILEGE_ENABLED)
Else
$iAttributes = BitAND($iAttributes, BitNOT($SE_PRIVILEGE_ENABLED))
EndIf
DllStructSetData($tPrevState, "Attributes", $iAttributes)
If Not _Security__AdjustTokenPrivileges($hToken, False, $tPrevState, $iPrevState, $tCurrState, $tRequired) Then Return SetError(3, @error, False)
Return True
EndFunc
Func _SendMessage($hWnd, $iMsg, $wParam = 0, $lParam = 0, $iReturn = 0, $wParamType = "wparam", $lParamType = "lparam", $sReturnType = "lresult")
Local $aResult = DllCall("user32.dll", $sReturnType, "SendMessageW", "hwnd", $hWnd, "uint", $iMsg, $wParamType, $wParam, $lParamType, $lParam)
If @error Then Return SetError(@error, @extended, "")
If $iReturn >= 0 And $iReturn <= 4 Then Return $aResult[$iReturn]
Return $aResult
EndFunc
Global Const $HGDI_ERROR = Ptr(-1)
Global Const $INVALID_HANDLE_VALUE = Ptr(-1)
Global Const $KF_EXTENDED = 0x0100
Global Const $KF_ALTDOWN = 0x2000
Global Const $KF_UP = 0x8000
Global Const $LLKHF_EXTENDED = BitShift($KF_EXTENDED, 8)
Global Const $LLKHF_ALTDOWN = BitShift($KF_ALTDOWN, 8)
Global Const $LLKHF_UP = BitShift($KF_UP, 8)
Global $__g_aInProcess_WinAPI[64][2] = [[0, 0]]
Func _WinAPI_DestroyIcon($hIcon)
Local $aResult = DllCall("user32.dll", "bool", "DestroyIcon", "handle", $hIcon)
If @error Then Return SetError(@error, @extended, False)
Return $aResult[0]
EndFunc
Func _WinAPI_ExtractIconEx($sFilePath, $iIndex, $paLarge, $paSmall, $iIcons)
Local $aResult = DllCall("shell32.dll", "uint", "ExtractIconExW", "wstr", $sFilePath, "int", $iIndex, "struct*", $paLarge, "struct*", $paSmall, "uint", $iIcons)
If @error Then Return SetError(@error, @extended, 0)
Return $aResult[0]
EndFunc
Func _WinAPI_GetDlgCtrlID($hWnd)
Local $aResult = DllCall("user32.dll", "int", "GetDlgCtrlID", "hwnd", $hWnd)
If @error Then Return SetError(@error, @extended, 0)
Return $aResult[0]
EndFunc
Func _WinAPI_GetWindowThreadProcessId($hWnd, ByRef $iPID)
Local $aResult = DllCall("user32.dll", "dword", "GetWindowThreadProcessId", "hwnd", $hWnd, "dword*", 0)
If @error Then Return SetError(@error, @extended, 0)
$iPID = $aResult[2]
Return $aResult[0]
EndFunc
Func _WinAPI_InProcess($hWnd, ByRef $hLastWnd)
If $hWnd = $hLastWnd Then Return True
For $iI = $__g_aInProcess_WinAPI[0][0] To 1 Step -1
If $hWnd = $__g_aInProcess_WinAPI[$iI][0] Then
If $__g_aInProcess_WinAPI[$iI][1] Then
$hLastWnd = $hWnd
Return True
Else
Return False
EndIf
EndIf
Next
Local $iPID
_WinAPI_GetWindowThreadProcessId($hWnd, $iPID)
Local $iCount = $__g_aInProcess_WinAPI[0][0] + 1
If $iCount >= 64 Then $iCount = 1
$__g_aInProcess_WinAPI[0][0] = $iCount
$__g_aInProcess_WinAPI[$iCount][0] = $hWnd
$__g_aInProcess_WinAPI[$iCount][1] =($iPID = @AutoItPID)
Return $__g_aInProcess_WinAPI[$iCount][1]
EndFunc
Func _WinAPI_InvalidateRect($hWnd, $tRECT = 0, $bErase = True)
Local $aResult = DllCall("user32.dll", "bool", "InvalidateRect", "hwnd", $hWnd, "struct*", $tRECT, "bool", $bErase)
If @error Then Return SetError(@error, @extended, False)
Return $aResult[0]
EndFunc
Func _GUIImageList_AddIcon($hWnd, $sFilePath, $iIndex = 0, $bLarge = False)
Local $iRet, $tIcon = DllStructCreate("handle Handle")
If $bLarge Then
$iRet = _WinAPI_ExtractIconEx($sFilePath, $iIndex, $tIcon, 0, 1)
Else
$iRet = _WinAPI_ExtractIconEx($sFilePath, $iIndex, 0, $tIcon, 1)
EndIf
If $iRet <= 0 Then Return SetError(-1, $iRet, -1)
Local $hIcon = DllStructGetData($tIcon, "Handle")
$iRet = _GUIImageList_ReplaceIcon($hWnd, -1, $hIcon)
_WinAPI_DestroyIcon($hIcon)
If $iRet = -1 Then Return SetError(-2, $iRet, -1)
Return $iRet
EndFunc
Func _GUIImageList_Create($iCX = 16, $iCY = 16, $iColor = 4, $iOptions = 0, $iInitial = 4, $iGrow = 4)
Local Const $aColor[7] = [$ILC_COLOR, $ILC_COLOR4, $ILC_COLOR8, $ILC_COLOR16, $ILC_COLOR24, $ILC_COLOR32, $ILC_COLORDDB]
Local $iFlags = 0
If BitAND($iOptions, 1) <> 0 Then $iFlags = BitOR($iFlags, $ILC_MASK)
If BitAND($iOptions, 2) <> 0 Then $iFlags = BitOR($iFlags, $ILC_MIRROR)
If BitAND($iOptions, 4) <> 0 Then $iFlags = BitOR($iFlags, $ILC_PERITEMMIRROR)
$iFlags = BitOR($iFlags, $aColor[$iColor])
Local $aResult = DllCall("comctl32.dll", "handle", "ImageList_Create", "int", $iCX, "int", $iCY, "uint", $iFlags, "int", $iInitial, "int", $iGrow)
If @error Then Return SetError(@error, @extended, 0)
Return $aResult[0]
EndFunc
Func _GUIImageList_ReplaceIcon($hWnd, $iIndex, $hIcon)
Local $aResult = DllCall("comctl32.dll", "int", "ImageList_ReplaceIcon", "handle", $hWnd, "int", $iIndex, "handle", $hIcon)
If @error Then Return SetError(@error, @extended, -1)
Return $aResult[0]
EndFunc
Global Const $MEM_COMMIT = 0x00001000
Global Const $MEM_RESERVE = 0x00002000
Global Const $PAGE_READWRITE = 0x00000004
Global Const $MEM_RELEASE = 0x00008000
Global Const $PROCESS_VM_OPERATION = 0x00000008
Global Const $PROCESS_VM_READ = 0x00000010
Global Const $PROCESS_VM_WRITE = 0x00000020
Global Const $tagMEMMAP = "handle hProc;ulong_ptr Size;ptr Mem"
Func _MemFree(ByRef $tMemMap)
Local $pMemory = DllStructGetData($tMemMap, "Mem")
Local $hProcess = DllStructGetData($tMemMap, "hProc")
Local $bResult = _MemVirtualFreeEx($hProcess, $pMemory, 0, $MEM_RELEASE)
DllCall("kernel32.dll", "bool", "CloseHandle", "handle", $hProcess)
If @error Then Return SetError(@error, @extended, False)
Return $bResult
EndFunc
Func _MemInit($hWnd, $iSize, ByRef $tMemMap)
Local $aResult = DllCall("user32.dll", "dword", "GetWindowThreadProcessId", "hwnd", $hWnd, "dword*", 0)
If @error Then Return SetError(@error + 10, @extended, 0)
Local $iProcessID = $aResult[2]
If $iProcessID = 0 Then Return SetError(1, 0, 0)
Local $iAccess = BitOR($PROCESS_VM_OPERATION, $PROCESS_VM_READ, $PROCESS_VM_WRITE)
Local $hProcess = __Mem_OpenProcess($iAccess, False, $iProcessID, True)
Local $iAlloc = BitOR($MEM_RESERVE, $MEM_COMMIT)
Local $pMemory = _MemVirtualAllocEx($hProcess, 0, $iSize, $iAlloc, $PAGE_READWRITE)
If $pMemory = 0 Then Return SetError(2, 0, 0)
$tMemMap = DllStructCreate($tagMEMMAP)
DllStructSetData($tMemMap, "hProc", $hProcess)
DllStructSetData($tMemMap, "Size", $iSize)
DllStructSetData($tMemMap, "Mem", $pMemory)
Return $pMemory
EndFunc
Func _MemRead(ByRef $tMemMap, $pSrce, $pDest, $iSize)
Local $aResult = DllCall("kernel32.dll", "bool", "ReadProcessMemory", "handle", DllStructGetData($tMemMap, "hProc"), "ptr", $pSrce, "struct*", $pDest, "ulong_ptr", $iSize, "ulong_ptr*", 0)
If @error Then Return SetError(@error, @extended, False)
Return $aResult[0]
EndFunc
Func _MemWrite(ByRef $tMemMap, $pSrce, $pDest = 0, $iSize = 0, $sSrce = "struct*")
If $pDest = 0 Then $pDest = DllStructGetData($tMemMap, "Mem")
If $iSize = 0 Then $iSize = DllStructGetData($tMemMap, "Size")
Local $aResult = DllCall("kernel32.dll", "bool", "WriteProcessMemory", "handle", DllStructGetData($tMemMap, "hProc"), "ptr", $pDest, $sSrce, $pSrce, "ulong_ptr", $iSize, "ulong_ptr*", 0)
If @error Then Return SetError(@error, @extended, False)
Return $aResult[0]
EndFunc
Func _MemVirtualAllocEx($hProcess, $pAddress, $iSize, $iAllocation, $iProtect)
Local $aResult = DllCall("kernel32.dll", "ptr", "VirtualAllocEx", "handle", $hProcess, "ptr", $pAddress, "ulong_ptr", $iSize, "dword", $iAllocation, "dword", $iProtect)
If @error Then Return SetError(@error, @extended, 0)
Return $aResult[0]
EndFunc
Func _MemVirtualFreeEx($hProcess, $pAddress, $iSize, $iFreeType)
Local $aResult = DllCall("kernel32.dll", "bool", "VirtualFreeEx", "handle", $hProcess, "ptr", $pAddress, "ulong_ptr", $iSize, "dword", $iFreeType)
If @error Then Return SetError(@error, @extended, False)
Return $aResult[0]
EndFunc
Func __Mem_OpenProcess($iAccess, $bInherit, $iProcessID, $bDebugPriv = False)
Local $aResult = DllCall("kernel32.dll", "handle", "OpenProcess", "dword", $iAccess, "bool", $bInherit, "dword", $iProcessID)
If @error Then Return SetError(@error + 10, @extended, 0)
If $aResult[0] Then Return $aResult[0]
If Not $bDebugPriv Then Return 0
Local $hToken = _Security__OpenThreadTokenEx(BitOR($TOKEN_ADJUST_PRIVILEGES, $TOKEN_QUERY))
If @error Then Return SetError(@error + 20, @extended, 0)
_Security__SetPrivilege($hToken, "SeDebugPrivilege", True)
Local $iError = @error
Local $iLastError = @extended
Local $iRet = 0
If Not @error Then
$aResult = DllCall("kernel32.dll", "handle", "OpenProcess", "dword", $iAccess, "bool", $bInherit, "dword", $iProcessID)
$iError = @error
$iLastError = @extended
If $aResult[0] Then $iRet = $aResult[0]
_Security__SetPrivilege($hToken, "SeDebugPrivilege", False)
If @error Then
$iError = @error + 30
$iLastError = @extended
EndIf
Else
$iError = @error + 40
EndIf
DllCall("kernel32.dll", "bool", "CloseHandle", "handle", $hToken)
Return SetError($iError, $iLastError, $iRet)
EndFunc
Global Const $_UDF_STARTID = 10000
Global $__g_hLVLastWnd
Global Const $__LISTVIEWCONSTANT_WM_SETREDRAW = 0x000B
Global Const $tagLVCOLUMN = "uint Mask;int Fmt;int CX;ptr Text;int TextMax;int SubItem;int Image;int Order;int cxMin;int cxDefault;int cxIdeal"
Func _GUICtrlListView_AddColumn($hWnd, $sText, $iWidth = 50, $iAlign = -1, $iImage = -1, $bOnRight = False)
Return _GUICtrlListView_InsertColumn($hWnd, _GUICtrlListView_GetColumnCount($hWnd), $sText, $iWidth, $iAlign, $iImage, $bOnRight)
EndFunc
Func _GUICtrlListView_AddItem($hWnd, $sText, $iImage = -1, $iParam = 0)
Return _GUICtrlListView_InsertItem($hWnd, $sText, -1, $iImage, $iParam)
EndFunc
Func _GUICtrlListView_BeginUpdate($hWnd)
If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)
Return _SendMessage($hWnd, $__LISTVIEWCONSTANT_WM_SETREDRAW, False) = 0
EndFunc
Func _GUICtrlListView_DeleteAllItems($hWnd)
If _GUICtrlListView_GetItemCount($hWnd) = 0 Then Return True
Local $vCID = 0
If IsHWnd($hWnd) Then
$vCID = _WinAPI_GetDlgCtrlID($hWnd)
Else
$vCID = $hWnd
$hWnd = GUICtrlGetHandle($hWnd)
EndIf
If $vCID < $_UDF_STARTID Then
Local $iParam = 0
For $iIndex = _GUICtrlListView_GetItemCount($hWnd) - 1 To 0 Step -1
$iParam = _GUICtrlListView_GetItemParam($hWnd, $iIndex)
If GUICtrlGetState($iParam) > 0 And GUICtrlGetHandle($iParam) = 0 Then
GUICtrlDelete($iParam)
EndIf
Next
If _GUICtrlListView_GetItemCount($hWnd) = 0 Then Return True
EndIf
Return _SendMessage($hWnd, $LVM_DELETEALLITEMS) <> 0
EndFunc
Func _GUICtrlListView_EndUpdate($hWnd)
If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)
Return _SendMessage($hWnd, $__LISTVIEWCONSTANT_WM_SETREDRAW, True) = 0
EndFunc
Func _GUICtrlListView_EnsureVisible($hWnd, $iIndex, $bPartialOK = False)
If IsHWnd($hWnd) Then
Return _SendMessage($hWnd, $LVM_ENSUREVISIBLE, $iIndex, $bPartialOK)
Else
Return GUICtrlSendMsg($hWnd, $LVM_ENSUREVISIBLE, $iIndex, $bPartialOK)
EndIf
EndFunc
Func _GUICtrlListView_GetColumnCount($hWnd)
Return _SendMessage(_GUICtrlListView_GetHeader($hWnd), 0x1200)
EndFunc
Func _GUICtrlListView_GetHeader($hWnd)
If IsHWnd($hWnd) Then
Return HWnd(_SendMessage($hWnd, $LVM_GETHEADER))
Else
Return HWnd(GUICtrlSendMsg($hWnd, $LVM_GETHEADER, 0, 0))
EndIf
EndFunc
Func _GUICtrlListView_GetItemCount($hWnd)
If IsHWnd($hWnd) Then
Return _SendMessage($hWnd, $LVM_GETITEMCOUNT)
Else
Return GUICtrlSendMsg($hWnd, $LVM_GETITEMCOUNT, 0, 0)
EndIf
EndFunc
Func _GUICtrlListView_GetItemEx($hWnd, ByRef $tItem)
Local $bUnicode = _GUICtrlListView_GetUnicodeFormat($hWnd)
Local $iRet
If IsHWnd($hWnd) Then
If _WinAPI_InProcess($hWnd, $__g_hLVLastWnd) Then
$iRet = _SendMessage($hWnd, $LVM_GETITEMW, 0, $tItem, 0, "wparam", "struct*")
Else
Local $iItem = DllStructGetSize($tItem)
Local $tMemMap
Local $pMemory = _MemInit($hWnd, $iItem, $tMemMap)
_MemWrite($tMemMap, $tItem)
If $bUnicode Then
_SendMessage($hWnd, $LVM_GETITEMW, 0, $pMemory, 0, "wparam", "ptr")
Else
_SendMessage($hWnd, $LVM_GETITEMA, 0, $pMemory, 0, "wparam", "ptr")
EndIf
_MemRead($tMemMap, $pMemory, $tItem, $iItem)
_MemFree($tMemMap)
EndIf
Else
Local $pItem = DllStructGetPtr($tItem)
If $bUnicode Then
$iRet = GUICtrlSendMsg($hWnd, $LVM_GETITEMW, 0, $pItem)
Else
$iRet = GUICtrlSendMsg($hWnd, $LVM_GETITEMA, 0, $pItem)
EndIf
EndIf
Return $iRet <> 0
EndFunc
Func _GUICtrlListView_GetItemParam($hWnd, $iIndex)
Local $tItem = DllStructCreate($tagLVITEM)
DllStructSetData($tItem, "Mask", $LVIF_PARAM)
DllStructSetData($tItem, "Item", $iIndex)
_GUICtrlListView_GetItemEx($hWnd, $tItem)
Return DllStructGetData($tItem, "Param")
EndFunc
Func _GUICtrlListView_GetUnicodeFormat($hWnd)
If IsHWnd($hWnd) Then
Return _SendMessage($hWnd, $LVM_GETUNICODEFORMAT) <> 0
Else
Return GUICtrlSendMsg($hWnd, $LVM_GETUNICODEFORMAT, 0, 0) <> 0
EndIf
EndFunc
Func _GUICtrlListView_InsertColumn($hWnd, $iIndex, $sText, $iWidth = 50, $iAlign = -1, $iImage = -1, $bOnRight = False)
Local $aAlign[3] = [$LVCFMT_LEFT, $LVCFMT_RIGHT, $LVCFMT_CENTER]
Local $bUnicode = _GUICtrlListView_GetUnicodeFormat($hWnd)
Local $iBuffer = StringLen($sText) + 1
Local $tBuffer
If $bUnicode Then
$tBuffer = DllStructCreate("wchar Text[" & $iBuffer & "]")
$iBuffer *= 2
Else
$tBuffer = DllStructCreate("char Text[" & $iBuffer & "]")
EndIf
Local $pBuffer = DllStructGetPtr($tBuffer)
Local $tColumn = DllStructCreate($tagLVCOLUMN)
Local $iMask = BitOR($LVCF_FMT, $LVCF_WIDTH, $LVCF_TEXT)
If $iAlign < 0 Or $iAlign > 2 Then $iAlign = 0
Local $iFmt = $aAlign[$iAlign]
If $iImage <> -1 Then
$iMask = BitOR($iMask, $LVCF_IMAGE)
$iFmt = BitOR($iFmt, $LVCFMT_COL_HAS_IMAGES, $LVCFMT_IMAGE)
EndIf
If $bOnRight Then $iFmt = BitOR($iFmt, $LVCFMT_BITMAP_ON_RIGHT)
DllStructSetData($tBuffer, "Text", $sText)
DllStructSetData($tColumn, "Mask", $iMask)
DllStructSetData($tColumn, "Fmt", $iFmt)
DllStructSetData($tColumn, "CX", $iWidth)
DllStructSetData($tColumn, "TextMax", $iBuffer)
DllStructSetData($tColumn, "Image", $iImage)
Local $iRet
If IsHWnd($hWnd) Then
If _WinAPI_InProcess($hWnd, $__g_hLVLastWnd) Then
DllStructSetData($tColumn, "Text", $pBuffer)
$iRet = _SendMessage($hWnd, $LVM_INSERTCOLUMNW, $iIndex, $tColumn, 0, "wparam", "struct*")
Else
Local $iColumn = DllStructGetSize($tColumn)
Local $tMemMap
Local $pMemory = _MemInit($hWnd, $iColumn + $iBuffer, $tMemMap)
Local $pText = $pMemory + $iColumn
DllStructSetData($tColumn, "Text", $pText)
_MemWrite($tMemMap, $tColumn, $pMemory, $iColumn)
_MemWrite($tMemMap, $tBuffer, $pText, $iBuffer)
If $bUnicode Then
$iRet = _SendMessage($hWnd, $LVM_INSERTCOLUMNW, $iIndex, $pMemory, 0, "wparam", "ptr")
Else
$iRet = _SendMessage($hWnd, $LVM_INSERTCOLUMNA, $iIndex, $pMemory, 0, "wparam", "ptr")
EndIf
_MemFree($tMemMap)
EndIf
Else
Local $pColumn = DllStructGetPtr($tColumn)
DllStructSetData($tColumn, "Text", $pBuffer)
If $bUnicode Then
$iRet = GUICtrlSendMsg($hWnd, $LVM_INSERTCOLUMNW, $iIndex, $pColumn)
Else
$iRet = GUICtrlSendMsg($hWnd, $LVM_INSERTCOLUMNA, $iIndex, $pColumn)
EndIf
EndIf
If $iAlign > 0 Then _GUICtrlListView_SetColumn($hWnd, $iRet, $sText, $iWidth, $iAlign, $iImage, $bOnRight)
Return $iRet
EndFunc
Func _GUICtrlListView_InsertItem($hWnd, $sText, $iIndex = -1, $iImage = -1, $iParam = 0)
Local $bUnicode = _GUICtrlListView_GetUnicodeFormat($hWnd)
Local $iBuffer, $tBuffer, $iRet
If $iIndex = -1 Then $iIndex = 999999999
Local $tItem = DllStructCreate($tagLVITEM)
DllStructSetData($tItem, "Param", $iParam)
$iBuffer = StringLen($sText) + 1
If $bUnicode Then
$tBuffer = DllStructCreate("wchar Text[" & $iBuffer & "]")
$iBuffer *= 2
Else
$tBuffer = DllStructCreate("char Text[" & $iBuffer & "]")
EndIf
DllStructSetData($tBuffer, "Text", $sText)
DllStructSetData($tItem, "Text", DllStructGetPtr($tBuffer))
DllStructSetData($tItem, "TextMax", $iBuffer)
Local $iMask = BitOR($LVIF_TEXT, $LVIF_PARAM)
If $iImage >= 0 Then $iMask = BitOR($iMask, $LVIF_IMAGE)
DllStructSetData($tItem, "Mask", $iMask)
DllStructSetData($tItem, "Item", $iIndex)
DllStructSetData($tItem, "Image", $iImage)
If IsHWnd($hWnd) Then
If _WinAPI_InProcess($hWnd, $__g_hLVLastWnd) Or($sText = -1) Then
$iRet = _SendMessage($hWnd, $LVM_INSERTITEMW, 0, $tItem, 0, "wparam", "struct*")
Else
Local $iItem = DllStructGetSize($tItem)
Local $tMemMap
Local $pMemory = _MemInit($hWnd, $iItem + $iBuffer, $tMemMap)
Local $pText = $pMemory + $iItem
DllStructSetData($tItem, "Text", $pText)
_MemWrite($tMemMap, $tItem, $pMemory, $iItem)
_MemWrite($tMemMap, $tBuffer, $pText, $iBuffer)
If $bUnicode Then
$iRet = _SendMessage($hWnd, $LVM_INSERTITEMW, 0, $pMemory, 0, "wparam", "ptr")
Else
$iRet = _SendMessage($hWnd, $LVM_INSERTITEMA, 0, $pMemory, 0, "wparam", "ptr")
EndIf
_MemFree($tMemMap)
EndIf
Else
Local $pItem = DllStructGetPtr($tItem)
If $bUnicode Then
$iRet = GUICtrlSendMsg($hWnd, $LVM_INSERTITEMW, 0, $pItem)
Else
$iRet = GUICtrlSendMsg($hWnd, $LVM_INSERTITEMA, 0, $pItem)
EndIf
EndIf
Return $iRet
EndFunc
Func _GUICtrlListView_SetColumn($hWnd, $iIndex, $sText, $iWidth = -1, $iAlign = -1, $iImage = -1, $bOnRight = False)
Local $bUnicode = _GUICtrlListView_GetUnicodeFormat($hWnd)
Local $aAlign[3] = [$LVCFMT_LEFT, $LVCFMT_RIGHT, $LVCFMT_CENTER]
Local $iBuffer = StringLen($sText) + 1
Local $tBuffer
If $bUnicode Then
$tBuffer = DllStructCreate("wchar Text[" & $iBuffer & "]")
$iBuffer *= 2
Else
$tBuffer = DllStructCreate("char Text[" & $iBuffer & "]")
EndIf
Local $pBuffer = DllStructGetPtr($tBuffer)
Local $tColumn = DllStructCreate($tagLVCOLUMN)
Local $iMask = $LVCF_TEXT
If $iAlign < 0 Or $iAlign > 2 Then $iAlign = 0
$iMask = BitOR($iMask, $LVCF_FMT)
Local $iFmt = $aAlign[$iAlign]
If $iWidth <> -1 Then $iMask = BitOR($iMask, $LVCF_WIDTH)
If $iImage <> -1 Then
$iMask = BitOR($iMask, $LVCF_IMAGE)
$iFmt = BitOR($iFmt, $LVCFMT_COL_HAS_IMAGES, $LVCFMT_IMAGE)
Else
$iImage = 0
EndIf
If $bOnRight Then $iFmt = BitOR($iFmt, $LVCFMT_BITMAP_ON_RIGHT)
DllStructSetData($tBuffer, "Text", $sText)
DllStructSetData($tColumn, "Mask", $iMask)
DllStructSetData($tColumn, "Fmt", $iFmt)
DllStructSetData($tColumn, "CX", $iWidth)
DllStructSetData($tColumn, "TextMax", $iBuffer)
DllStructSetData($tColumn, "Image", $iImage)
Local $iRet
If IsHWnd($hWnd) Then
If _WinAPI_InProcess($hWnd, $__g_hLVLastWnd) Then
DllStructSetData($tColumn, "Text", $pBuffer)
$iRet = _SendMessage($hWnd, $LVM_SETCOLUMNW, $iIndex, $tColumn, 0, "wparam", "struct*")
Else
Local $iColumn = DllStructGetSize($tColumn)
Local $tMemMap
Local $pMemory = _MemInit($hWnd, $iColumn + $iBuffer, $tMemMap)
Local $pText = $pMemory + $iColumn
DllStructSetData($tColumn, "Text", $pText)
_MemWrite($tMemMap, $tColumn, $pMemory, $iColumn)
_MemWrite($tMemMap, $tBuffer, $pText, $iBuffer)
If $bUnicode Then
$iRet = _SendMessage($hWnd, $LVM_SETCOLUMNW, $iIndex, $pMemory, 0, "wparam", "ptr")
Else
$iRet = _SendMessage($hWnd, $LVM_SETCOLUMNA, $iIndex, $pMemory, 0, "wparam", "ptr")
EndIf
_MemFree($tMemMap)
EndIf
Else
Local $pColumn = DllStructGetPtr($tColumn)
DllStructSetData($tColumn, "Text", $pBuffer)
If $bUnicode Then
$iRet = GUICtrlSendMsg($hWnd, $LVM_SETCOLUMNW, $iIndex, $pColumn)
Else
$iRet = GUICtrlSendMsg($hWnd, $LVM_SETCOLUMNA, $iIndex, $pColumn)
EndIf
EndIf
Return $iRet <> 0
EndFunc
Func _GUICtrlListView_SetExtendedListViewStyle($hWnd, $iExStyle, $iExMask = 0)
Local $iRet
If IsHWnd($hWnd) Then
$iRet = _SendMessage($hWnd, $LVM_SETEXTENDEDLISTVIEWSTYLE, $iExMask, $iExStyle)
_WinAPI_InvalidateRect($hWnd)
Else
$iRet = GUICtrlSendMsg($hWnd, $LVM_SETEXTENDEDLISTVIEWSTYLE, $iExMask, $iExStyle)
_WinAPI_InvalidateRect(GUICtrlGetHandle($hWnd))
EndIf
Return $iRet
EndFunc
Func _GUICtrlListView_SetImageList($hWnd, $hHandle, $iType = 0)
Local $aType[3] = [$LVSIL_NORMAL, $LVSIL_SMALL, $LVSIL_STATE]
If IsHWnd($hWnd) Then
Return _SendMessage($hWnd, $LVM_SETIMAGELIST, $aType[$iType], $hHandle, 0, "wparam", "handle", "handle")
Else
Return Ptr(GUICtrlSendMsg($hWnd, $LVM_SETIMAGELIST, $aType[$iType], $hHandle))
EndIf
EndFunc
Func _GUICtrlListView_SetItemEx($hWnd, ByRef $tItem)
Local $bUnicode = _GUICtrlListView_GetUnicodeFormat($hWnd)
Local $iRet
If IsHWnd($hWnd) Then
Local $iItem = DllStructGetSize($tItem)
Local $iBuffer = DllStructGetData($tItem, "TextMax")
Local $pBuffer = DllStructGetData($tItem, "Text")
If $bUnicode Then $iBuffer *= 2
Local $tMemMap
Local $pMemory = _MemInit($hWnd, $iItem + $iBuffer, $tMemMap)
Local $pText = $pMemory + $iItem
DllStructSetData($tItem, "Text", $pText)
_MemWrite($tMemMap, $tItem, $pMemory, $iItem)
If $pBuffer <> 0 Then _MemWrite($tMemMap, $pBuffer, $pText, $iBuffer)
If $bUnicode Then
$iRet = _SendMessage($hWnd, $LVM_SETITEMW, 0, $pMemory, 0, "wparam", "ptr")
Else
$iRet = _SendMessage($hWnd, $LVM_SETITEMA, 0, $pMemory, 0, "wparam", "ptr")
EndIf
_MemFree($tMemMap)
Else
Local $pItem = DllStructGetPtr($tItem)
If $bUnicode Then
$iRet = GUICtrlSendMsg($hWnd, $LVM_SETITEMW, 0, $pItem)
Else
$iRet = GUICtrlSendMsg($hWnd, $LVM_SETITEMA, 0, $pItem)
EndIf
EndIf
Return $iRet <> 0
EndFunc
Func _GUICtrlListView_SetItemFocused($hWnd, $iIndex, $bEnabled = True)
Local $iState = 0
If $bEnabled Then $iState = $LVIS_FOCUSED
Return _GUICtrlListView_SetItemState($hWnd, $iIndex, $iState, $LVIS_FOCUSED)
EndFunc
Func _GUICtrlListView_SetItemState($hWnd, $iIndex, $iState, $iStateMask)
Local $tItem = DllStructCreate($tagLVITEM)
DllStructSetData($tItem, "Mask", $LVIF_STATE)
DllStructSetData($tItem, "Item", $iIndex)
DllStructSetData($tItem, "State", $iState)
DllStructSetData($tItem, "StateMask", $iStateMask)
Return _GUICtrlListView_SetItemEx($hWnd, $tItem) <> 0
EndFunc
Global Const $tagOSVERSIONINFO = 'struct;dword OSVersionInfoSize;dword MajorVersion;dword MinorVersion;dword BuildNumber;dword PlatformId;wchar CSDVersion[128];endstruct'
Global Const $__WINVER = __WINVER()
Func __WINVER()
Local $tOSVI = DllStructCreate($tagOSVERSIONINFO)
DllStructSetData($tOSVI, 1, DllStructGetSize($tOSVI))
Local $aRet = DllCall('kernel32.dll', 'bool', 'GetVersionExW', 'struct*', $tOSVI)
If @error Or Not $aRet[0] Then Return SetError(@error, @extended, 0)
Return BitOR(BitShift(DllStructGetData($tOSVI, 2), -8), DllStructGetData($tOSVI, 3))
EndFunc
Func _AutoIt3Script_GetDirectiveValue($sAu3Script_In, $sParam)
Local $aScript_In
Local $iCurrLine
Local $iCurrLine_Param
Local $iCurrLine_Value
Local $sReturn_Value
Local $hFileOpen = FileOpen($sAu3Script_In, $FO_FULLFILE_DETECT)
If $hFileOpen = -1 Then Return SetError(1, 0, 0)
Local $sFileRead = FileRead($hFileOpen)
FileClose($hFileOpen)
If StringInStr($sFileRead, @LF) Then
$aScript_In = StringSplit(StringStripCR($sFileRead), @LF)
ElseIf StringInStr($sFileRead, @CR) Then
$aScript_In = StringSplit($sFileRead, @CR)
Else
If StringLen($sFileRead) Then
$sFileRead &= @LF
$aScript_In = StringSplit(StringStripCR($sFileRead), @LF)
Else
Return SetError(2, 0, 0)
EndIf
EndIf
Local $IsCommentBlock = False
Local $IsRunBlock
For $iLine = 1 To $aScript_In[0]
$iCurrLine = $aScript_In[$iLine]
$iCurrLine = StringStripWS($iCurrLine, 1)
If StringLeft($iCurrLine, 3) = "#CS" Or StringLeft($iCurrLine, 13) = "Comment_Start" Then $IsCommentBlock = True
If StringLeft($iCurrLine, 3) = "#CE" Or StringLeft($iCurrLine, 11) = "Comment_End" Then $IsCommentBlock = False
If $IsCommentBlock Then ContinueLoop
If StringLeft($iCurrLine, 1) = ";" Then ContinueLoop
If StringInStr($iCurrLine, "#AutoIt3Wrapper_If_Run") Then $IsRunBlock = True
If StringInStr($iCurrLine, "#Autoit3Wrapper_If_Compile") Then $IsRunBlock = False
If $IsRunBlock Then ContinueLoop
If StringLeft($iCurrLine, 16) <> "#AutoIt3Wrapper_" And StringLeft($iCurrLine, 5) <> "#Run_" And StringLeft($iCurrLine, 6) <> "#Tidy_" And StringLeft($iCurrLine, 12) <> "#Obfuscator_" And StringLeft($iCurrLine, 13) <> "#Au3Stripper_" Then
ContinueLoop
EndIf
If StringInStr($iCurrLine, ";") Then
$iCurrLine = StringLeft($iCurrLine, StringInStr($iCurrLine, ";") - 1)
EndIf
$iCurrLine = StringStripWS($iCurrLine, 3)
$iCurrLine_Param = StringLeft($iCurrLine, StringInStr($iCurrLine & "=", "=") - 1)
$iCurrLine_Param = StringStripWS($iCurrLine_Param, 3)
$iCurrLine_Value = StringTrimLeft($iCurrLine, StringInStr($iCurrLine, "="))
$iCurrLine_Value = StringStripWS($iCurrLine_Value, 3)
$iCurrLine_Value = StringReplace($iCurrLine_Value, Chr(34), "")
If $sParam = $iCurrLine_Param Then
$sReturn_Value = $iCurrLine_Value
ExitLoop
EndIf
Next
Return $sReturn_Value
EndFunc
Func _AutoIt3Script_GetFilename($sScriptFullPath)
Local $sDrive = "", $sDir = "", $sFileName = "", $sExtension = ""
Local $aPathSplit = _PathSplit($sScriptFullPath, $sDrive, $sDir, $sFileName, $sExtension)
Return StringReplace($sFileName, "_X64", "")
EndFunc
Func _AutoIt3Script_GetVersion($sAu3ScriptIn, $index = 0)
Local $sReturn = _AutoIt3Script_GetDirectiveValue($sAu3ScriptIn, "#AutoIt3Wrapper_Res_Fileversion")
Local $sAutoIncrement = _AutoIt3Script_GetDirectiveValue($sAu3ScriptIn, "#AutoIt3Wrapper_Res_FileVersion_AutoIncrement")
Local $sFirstIncrement = _AutoIt3Script_GetDirectiveValue($sAu3ScriptIn, "#AutoIt3Wrapper_Res_FileVersion_First_Increment")
If $sAutoIncrement == "Y" Then
If $sFirstIncrement == "Y" Then
Return __GetVersionFromString($sReturn, $index, 0)
Else
Return __GetVersionFromString($sReturn, $index, 1)
EndIf
Else
Return __GetVersionFromString($sReturn, $index, 0)
EndIf
EndFunc
Func __DisplayNullString($string)
If StringStripWS($string, 8) == "" Then
Return 0
Else
Return $string
EndIf
EndFunc
Func __GetVersionFromString($sVersion, $index = 0, $Increment = 0)
Local $sReturn = ""
Local $sPltReturn = StringSplit($sVersion, ".")
If IsArray($sPltReturn) Then
If StringIsInt($sPltReturn[$sPltReturn[0]]) Then
$sPltReturn[$sPltReturn[0]] = $sPltReturn[$sPltReturn[0]] - $Increment
EndIf
If $index <= $sPltReturn[0] And $index > 0 Then
$sReturn = __DisplayNullString($sPltReturn[$index])
Else
For $x = 1 To $sPltReturn[0]
If $x = 1 Then
$sReturn &= __DisplayNullString($sPltReturn[$x])
Else
$sReturn &= "." & __DisplayNullString($sPltReturn[$x])
EndIf
Next
EndIf
EndIf
Return $sReturn
EndFunc
Global $g_ReBarProgName = FileGetVersion(@ScriptFullPath, $FV_PRODUCTNAME)
Global $g_ReBarShortName = _AutoIt3Script_GetFilename(@ScriptFullPath)
Global $g_ReBarCompName = FileGetVersion(@ScriptFullPath, $FV_COMPANYNAME)
Global $g_ReBarExitCode = 0
Global $g_ReBarTitleShowAdmin = 1
Global $g_ReBarTitleShowAutoIt = 1
Global $g_ReBarTitleShowArch = 1
Global $g_ReBarTitleShowVersion = 1
Global $g_ReBarTitleShowBuild = 1
Global $g_ReBarRunCompName = "Rizonesoft"
Global $g_ReBarRunProgName = "ReBar Framework"
Global $g_ReBarRunIcon = @ScriptDir & "\Themes\Icons\ReBar.ico"
Global $g_ReBarRunIconHover = @ScriptDir & "\Themes\Icons\ReBarH.ico"
Global $g_ReBarRunVersion = 0
Global $g_ReBarWorkingDir = @ScriptDir
Global $g_ReBarIniFileName = $g_ReBarShortName & ".ini"
Global $g_ReBarPathIni = $g_ReBarWorkingDir & "\" & $g_ReBarIniFileName
Global $g_ReBarAppDataParent = @AppDataDir & "\" & $g_ReBarCompName
Global $g_ReBarAppDataPath = $g_ReBarAppDataParent & "\" & $g_ReBarShortName
Global $g_ReBarCacheEnabled = 1
Global $g_ReBarClearCacheOnExit = 0
Global $g_ReBarCacheBase = $g_ReBarWorkingDir & "\Cache"
Global $g_ReBarCachePath = $g_ReBarCacheBase & "\" & $g_ReBarShortName
Global $g_ReBarUpdateURL
Global $g_ReBarUpdateGUI
Global $g_ReBarUpdateURLBase = "http://www.rizonesoft.com/update/"
Global $g_ReBarUpdateRemote = $g_ReBarUpdateURLBase & $g_ReBarShortName & ".ru"
Global Const $g_ReBarLogVersion = "1.2"
Global $g_ReBarLogFileWrite = 0
Global $g_ReBarLogEnabled = 1
Global $g_ReBarLogStorage = 5242880
Global $g_ReBarLogFilename = $g_ReBarShortName & ".log"
Global $g_ReBarLogBase = $g_ReBarWorkingDir & "\Logging\" & $g_ReBarShortName
Global $g_ReBarLogPath = $g_ReBarLogBase & "\" & $g_ReBarLogFilename
Global $g_ReBarCoreGui
Global $g_ReBarGuiTitle = "ReBar Framework 0"
Global $g_ReBarSingleton = True
Global $g_ReBarGuiIcon
Global $g_ReBarIcon = @ScriptFullPath
Global $g_ReBarIconHover = @ScriptFullPath
Global $g_ReBarIcoHovering = 0
Global $g_ReBarFormWidth = 750
Global $g_ReBarFormHeight = 530
Global $g_ReBarFontName = "Verdana"
Global $g_ReBarFontSize = 8.5
Global $g_ReBarMsgTimeout = 60
Global $g_ReBarHasTrayIcon = False
Global $g_ReBarResFugue = @ScriptDir & "\Fugue.dll"
Global $g_ReBarResDoors = @ScriptDir & "\DoorsShell.dll"
Global $g_ReBarAboutGui
Global $g_ReBarAboutMenu
Global $g_ReBarAboutButton
Global $g_ReBarAboutTray
Global $g_ReBarAboutHome = "http://www.rizonesoft.com"
Global $g_ReBarAboutCredits = "Derick Payne (Rizonesoft), Brian J Christy (Beege), " & "G Sandler (MrCreatoR), Holger Kotsch, KaFu, LarsJ, nickston, ProgAndy, Yashied"
Global $g_ReBarAboutDonate = "https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=7UGGCSDUZJPFE"
Global $g_ReBarAboutCountry = "http://www.rizonesoft.com"
Global $g_ReBarAboutFacebook = "https://www.facebook.com/rizonesoft"
Global $g_ReBarAboutTwitter = "https://twitter.com/rizonesoft"
Global $g_ReBarAboutGoogle = "https://plus.google.com/+Rizonesoftsa/posts"
Global $g_ReBarAboutSupport = "http://www.rizonesoft.com/contact/"
Global $g_ReBarPrefsGui
Global $g_ReBarChkLogEnabled
Global $g_ReBarInLogSize
Global $g_ReBarChkCacheOnExit
Global $g_ReBarInLogSizeTemp
Global $g_ReBarLabelLogSize
Global $g_ReBarLabelCacheSize
Global $g_ReBarBtnClearLog
Global $g_ReBarBtnClearCache
Global $g_ReBarBtnSavePrefs
Global $g_LabelPrefsMessage
Global $g_ReBarShowLogging = 1
Global Const $INET_FORCERELOAD = 1
Global Const $INET_DOWNLOADBACKGROUND = 1
Global Const $INET_DOWNLOADREAD = 0
Global Const $INET_DOWNLOADCOMPLETE = 2
Func _WinAPI_GetTempFileName($sFilePath, $sPrefix = '')
Local $aRet = DllCall('kernel32.dll', 'uint', 'GetTempFileNameW', 'wstr', $sFilePath, 'wstr', $sPrefix, 'uint', 0, 'wstr', '')
If @error Or Not $aRet[0] Then Return SetError(@error + 10, @extended, '')
Return $aRet[4]
EndFunc
Func _PathSplit($sFilePath, ByRef $sDrive, ByRef $sDir, ByRef $sFileName, ByRef $sExtension)
Local $aArray = StringRegExp($sFilePath, "^\h*((?:\\\\\?\\)*(\\\\[^\?\/\\]+|[A-Za-z]:)?(.*[\/\\]\h*)?((?:[^\.\/\\]|(?(?=\.[^\/\\]*\.)\.))*)?([^\/\\]*))$", $STR_REGEXPARRAYMATCH)
If @error Then
ReDim $aArray[5]
$aArray[0] = $sFilePath
EndIf
$sDrive = $aArray[1]
If StringLeft($aArray[2], 1) == "/" Then
$sDir = StringRegExpReplace($aArray[2], "\h*[\/\\]+\h*", "\/")
Else
$sDir = StringRegExpReplace($aArray[2], "\h*[\/\\]+\h*", "\\")
EndIf
$aArray[2] = $sDir
$sFileName = $aArray[3]
$sExtension = $aArray[4]
Return $aArray
EndFunc
Func _GetWindowsVersion()
Local $sReturn = ""
Local $sWinVersion = @OSVersion
If StringRegExp(FileGetVersion('winver.exe'), "^10\.\d") Then $sWinVersion = "WIN_10"
$sReturn = StringReplace($sWinVersion, "WIN_", "Windows ", $STR_CASESENSE)
Return $sReturn
EndFunc
Func _AutoItGetArchitecture()
If @AutoItX64 Then
Return 64
Else
Return 32
EndIf
EndFunc
Func _CheckResources($sResFile)
If Not IsDeclared("REBAR_PROG_NAME") Then Global $REBAR_PROG_NAME
If Not IsDeclared("REBAR_MSG_TIMEOUT") Then Global $REBAR_MSG_TIMEOUT
If Not FileExists($sResFile) Then
If Not IsDeclared("iMsgBoxAnswer") Then Local $iMsgBoxAnswer
$iMsgBoxAnswer = MsgBox($MB_OK + $MB_ICONHAND, "Required resources missing!", "A required resource file (" & $sResFile & ") " & "is missing. This file keeps all the pretty icons. Why somebody would not like pretty icons is beyond me? " & "What would you do with all this extra space?" & $REBAR_PROG_NAME, $REBAR_MSG_TIMEOUT)
Select
Case $iMsgBoxAnswer = -1
Case Else
EndSelect
EndIf
EndFunc
Func _ReBarRebootWindows()
Local $iMBox = MsgBox(65, "Rebooting Windows!", "Make sure your work is saved before continuing. " & "Answer 'OK' to reboot your computer or 'Cancel' if you would like to reboot later." & @CRLF & @CRLF & "Your computer will reboot automatically in 60 seconds.", 60)
Switch $iMBox
Case 1, -1
Shutdown(18)
Case 2
Return
EndSwitch
EndFunc
Func _GetProgramVersion($iFlag = 1)
Local $sReturn = ""
If @Compiled Then
$sReturn = _GetProgramVersionFromFile(@ScriptFullPath, $iFlag)
If @error Then Return SetError(1, 0, 0)
Else
$sReturn = _AutoIt3Script_GetVersion(@ScriptFullPath, $iFlag)
EndIf
Return $sReturn
EndFunc
Func _GetProgramVersionFromFile($sFileName, $iFlag = 1)
Local $sReturn = ""
Local $sFullVersion = FileGetVersion($sFileName)
If $iFlag == 0 Then
$sReturn = $sFullVersion
EndIf
Local $sPltReturn = StringSplit($sFullVersion, ".")
If $iFlag <= $sPltReturn[0] Then
$sReturn = $sPltReturn[$iFlag]
Else
Return SetError(1, 0, 0)
EndIf
Return $sReturn
EndFunc
Func _GUIGetTitle($sGUIName)
Local $sReturn = ""
Local $sAdminInstance = ""
Local $sProgamVersion = ""
Local $sProgramBuild = ""
Local $sAutoItArch = ""
Local $sAutoItVers = ""
If IsAdmin() And $g_ReBarTitleShowAdmin == 1 Then $sAdminInstance = "Administrator ~ "
If $g_ReBarTitleShowArch == 1 Then $sAutoItArch = " : " & _AutoItGetArchitecture() & "-Bit"
If @Compiled Then
Local $sReturn = FileGetVersion(@ScriptFullPath)
Local $sPltReturn = StringSplit($sReturn, ".")
If IsArray($sPltReturn) Then
If $g_ReBarTitleShowVersion == 1 Then $sProgamVersion = Chr(32) & $sPltReturn[1]
If $g_ReBarTitleShowBuild == 1 Then $sProgramBuild = " : Build " & $sPltReturn[$sPltReturn[0]]
$sReturn = $sAdminInstance & $sGUIName & $sProgamVersion & $sProgramBuild & $sAutoItArch
EndIf
Else
If $g_ReBarTitleShowVersion == 1 Then $sProgamVersion = Chr(32) & _AutoIt3Script_GetVersion(@ScriptFullPath, 1)
If $g_ReBarTitleShowBuild == 1 Then $sProgramBuild = " : Build " & _AutoIt3Script_GetVersion(@ScriptFullPath, 4)
If $g_ReBarTitleShowAutoIt == 1 Then $sAutoItVers = " : using AutoIt version " & @AutoItVersion
$sReturn = $sAdminInstance & $sGUIName & $sProgamVersion & $sProgramBuild & $sAutoItVers & $sAutoItArch
EndIf
Return $sReturn
EndFunc
Func _SoftwareUpdateCheck()
Local $sLocalFile = _WinAPI_GetTempFileName($g_ReBarCachePath, "u_")
Local $hDownload = InetGet($g_ReBarUpdateRemote, $sLocalFile, $INET_FORCERELOAD, $INET_DOWNLOADBACKGROUND)
Do
Sleep(250)
Until InetGetInfo($hDownload, $INET_DOWNLOADCOMPLETE)
Local $iBytesSize = InetGetInfo($hDownload, $INET_DOWNLOADREAD)
Local $iUpdateFileSize = FileGetSize($sLocalFile)
InetClose($hDownload)
If $iBytesSize = $iUpdateFileSize Then
Local $iLocalBuild = Number(_GetProgramVersion(4))
Local $iRemoteBuild = IniRead($sLocalFile, "Update", "LatestBuild", $iLocalBuild)
$g_ReBarUpdateURL = IniRead($sLocalFile, "Update", "UpdateURL", $g_ReBarAboutHome)
If $iLocalBuild < Number($iRemoteBuild) Then
Local $icoUpdate, $lblUpdateDesc, $lblBuild1, $lblBuild2, $lblUpdate
$g_ReBarUpdateGUI = GUICreate("Update Available", 265, 180, -1, -1)
GUISetIcon($g_ReBarResDoors, 108, $g_ReBarUpdateGUI)
GUISetFont($g_ReBarFontSize, 400, -1, $g_ReBarFontName, $g_ReBarUpdateGUI)
GUISetState(@SW_SHOW, $g_ReBarUpdateGUI)
GUISetOnEvent($GUI_EVENT_CLOSE, "_CloseUpdateDialog", $g_ReBarUpdateGUI)
$icoUpdate = GUICtrlCreateIcon($g_ReBarResDoors, 108, 10, 10, 64, 64)
GUICtrlSetCursor($icoUpdate, 0)
$lblUpdateDesc = GUICtrlCreateLabel($g_ReBarProgName & " update available.", 84, 10, 180, 64)
GUICtrlSetFont($lblUpdateDesc, 10)
GUICtrlCreateLabel("Current Build:", 10, 89, 95, 18, $SS_RIGHT)
GUICtrlCreateLabel("Update Build:", 10, 107, 95, 18, $SS_RIGHT)
$lblBuild1 = GUICtrlCreateLabel($iLocalBuild, 110, 87, 50, 18)
GUICtrlSetColor($lblBuild1, 0xE81123)
GUICtrlSetFont($lblBuild1, 10)
$lblBuild2 = GUICtrlCreateLabel($iRemoteBuild, 110, 105, 50, 18)
GUICtrlSetColor($lblBuild2, 0x0000FF)
GUICtrlSetCursor($lblBuild2, 0)
GUICtrlSetFont($lblBuild2, 10)
$lblUpdate = GUICtrlCreateLabel("Click here to download " & $g_ReBarProgName & " Build " & $iRemoteBuild & " now.", 10, 135, 245, 30)
GUICtrlSetColor($lblUpdate, 0x0000FF)
GUICtrlSetCursor($lblUpdate, 0)
GUICtrlSetOnEvent($icoUpdate, "_OpenUpdateURL")
GUICtrlSetOnEvent($lblBuild2, "_OpenUpdateURL")
GUICtrlSetOnEvent($lblUpdate, "_OpenUpdateURL")
EndIf
EndIf
FileDelete($sLocalFile)
EndFunc
Func _CloseUpdateDialog()
GUIDelete($g_ReBarUpdateGUI)
EndFunc
Func _OpenUpdateURL()
ShellExecute($g_ReBarUpdateURL)
EndFunc
Global Const $DMW_SHORTNAME = 1
Global Const $DMW_LOCALE_LONGNAME = 2
Global Const $LOCALE_SDATE = 0x001D
Global Const $LOCALE_STIME = 0x001E
Global Const $LOCALE_SSHORTDATE = 0x001F
Global Const $LOCALE_SLONGDATE = 0x0020
Global Const $LOCALE_STIMEFORMAT = 0x1003
Global Const $LOCALE_S1159 = 0x0028
Global Const $LOCALE_S2359 = 0x0029
Global Const $LOCALE_INVARIANT = 0x007F
Global Const $LOCALE_USER_DEFAULT = 0x0400
Func _WinAPI_GetDateFormat($iLCID = 0, $tSYSTEMTIME = 0, $iFlags = 0, $sFormat = '')
If Not $iLCID Then $iLCID = 0x0400
Local $sTypeOfFormat = 'wstr'
If Not StringStripWS($sFormat, $STR_STRIPLEADING + $STR_STRIPTRAILING) Then
$sTypeOfFormat = 'ptr'
$sFormat = 0
EndIf
Local $aRet = DllCall('kernel32.dll', 'int', 'GetDateFormatW', 'dword', $iLCID, 'dword', $iFlags, 'struct*', $tSYSTEMTIME, $sTypeOfFormat, $sFormat, 'wstr', '', 'int', 2048)
If @error Or Not $aRet[0] Then Return SetError(@error, @extended, '')
Return $aRet[5]
EndFunc
Func _WinAPI_GetLocaleInfo($iLCID, $iType)
Local $aRet = DllCall('kernel32.dll', 'int', 'GetLocaleInfoW', 'dword', $iLCID, 'dword', $iType, 'wstr', '', 'int', 2048)
If @error Or Not $aRet[0] Then Return SetError(@error + 10, @extended, '')
Return $aRet[3]
EndFunc
Func _DateDayOfWeek($iDayNum, $iFormat = Default)
Local Const $MONDAY_IS_NO1 = 128
If $iFormat = Default Then $iFormat = 0
$iDayNum = Int($iDayNum)
If $iDayNum < 1 Or $iDayNum > 7 Then Return SetError(1, 0, "")
Local $tSYSTEMTIME = DllStructCreate($tagSYSTEMTIME)
DllStructSetData($tSYSTEMTIME, "Year", BitAND($iFormat, $MONDAY_IS_NO1) ? 2007 : 2006)
DllStructSetData($tSYSTEMTIME, "Month", 1)
DllStructSetData($tSYSTEMTIME, "Day", $iDayNum)
Return _WinAPI_GetDateFormat(BitAND($iFormat, $DMW_LOCALE_LONGNAME) ? $LOCALE_USER_DEFAULT : $LOCALE_INVARIANT, $tSYSTEMTIME, 0, BitAND($iFormat, $DMW_SHORTNAME) ? "ddd" : "dddd")
EndFunc
Func _DateIsLeapYear($iYear)
If StringIsInt($iYear) Then
Select
Case Mod($iYear, 4) = 0 And Mod($iYear, 100) <> 0
Return 1
Case Mod($iYear, 400) = 0
Return 1
Case Else
Return 0
EndSelect
EndIf
Return SetError(1, 0, 0)
EndFunc
Func __DateIsMonth($iNumber)
$iNumber = Int($iNumber)
Return $iNumber >= 1 And $iNumber <= 12
EndFunc
Func _DateIsValid($sDate)
Local $asDatePart[4], $asTimePart[4]
_DateTimeSplit($sDate, $asDatePart, $asTimePart)
If Not StringIsInt($asDatePart[1]) Then Return 0
If Not StringIsInt($asDatePart[2]) Then Return 0
If Not StringIsInt($asDatePart[3]) Then Return 0
$asDatePart[1] = Int($asDatePart[1])
$asDatePart[2] = Int($asDatePart[2])
$asDatePart[3] = Int($asDatePart[3])
Local $iNumDays = _DaysInMonth($asDatePart[1])
If $asDatePart[1] < 1000 Or $asDatePart[1] > 2999 Then Return 0
If $asDatePart[2] < 1 Or $asDatePart[2] > 12 Then Return 0
If $asDatePart[3] < 1 Or $asDatePart[3] > $iNumDays[$asDatePart[2]] Then Return 0
If $asTimePart[0] < 1 Then Return 1
If $asTimePart[0] < 2 Then Return 0
If $asTimePart[0] = 2 Then $asTimePart[3] = "00"
If Not StringIsInt($asTimePart[1]) Then Return 0
If Not StringIsInt($asTimePart[2]) Then Return 0
If Not StringIsInt($asTimePart[3]) Then Return 0
$asTimePart[1] = Int($asTimePart[1])
$asTimePart[2] = Int($asTimePart[2])
$asTimePart[3] = Int($asTimePart[3])
If $asTimePart[1] < 0 Or $asTimePart[1] > 23 Then Return 0
If $asTimePart[2] < 0 Or $asTimePart[2] > 59 Then Return 0
If $asTimePart[3] < 0 Or $asTimePart[3] > 59 Then Return 0
Return 1
EndFunc
Func _DateTimeFormat($sDate, $sType)
Local $asDatePart[4], $asTimePart[4]
Local $sTempDate = "", $sTempTime = ""
Local $sAM, $sPM, $sTempString = ""
If Not _DateIsValid($sDate) Then
Return SetError(1, 0, "")
EndIf
If $sType < 0 Or $sType > 5 Or Not IsInt($sType) Then
Return SetError(2, 0, "")
EndIf
_DateTimeSplit($sDate, $asDatePart, $asTimePart)
Switch $sType
Case 0
$sTempString = _WinAPI_GetLocaleInfo($LOCALE_USER_DEFAULT, $LOCALE_SSHORTDATE)
If Not @error And Not($sTempString = '') Then
$sTempDate = $sTempString
Else
$sTempDate = "M/d/yyyy"
EndIf
If $asTimePart[0] > 1 Then
$sTempString = _WinAPI_GetLocaleInfo($LOCALE_USER_DEFAULT, $LOCALE_STIMEFORMAT)
If Not @error And Not($sTempString = '') Then
$sTempTime = $sTempString
Else
$sTempTime = "h:mm:ss tt"
EndIf
EndIf
Case 1
$sTempString = _WinAPI_GetLocaleInfo($LOCALE_USER_DEFAULT, $LOCALE_SLONGDATE)
If Not @error And Not($sTempString = '') Then
$sTempDate = $sTempString
Else
$sTempDate = "dddd, MMMM dd, yyyy"
EndIf
Case 2
$sTempString = _WinAPI_GetLocaleInfo($LOCALE_USER_DEFAULT, $LOCALE_SSHORTDATE)
If Not @error And Not($sTempString = '') Then
$sTempDate = $sTempString
Else
$sTempDate = "M/d/yyyy"
EndIf
Case 3
If $asTimePart[0] > 1 Then
$sTempString = _WinAPI_GetLocaleInfo($LOCALE_USER_DEFAULT, $LOCALE_STIMEFORMAT)
If Not @error And Not($sTempString = '') Then
$sTempTime = $sTempString
Else
$sTempTime = "h:mm:ss tt"
EndIf
EndIf
Case 4
If $asTimePart[0] > 1 Then
$sTempTime = "hh:mm"
EndIf
Case 5
If $asTimePart[0] > 1 Then
$sTempTime = "hh:mm:ss"
EndIf
EndSwitch
If $sTempDate <> "" Then
$sTempString = _WinAPI_GetLocaleInfo($LOCALE_USER_DEFAULT, $LOCALE_SDATE)
If Not @error And Not($sTempString = '') Then
$sTempDate = StringReplace($sTempDate, "/", $sTempString)
EndIf
Local $iWday = _DateToDayOfWeek($asDatePart[1], $asDatePart[2], $asDatePart[3])
$asDatePart[3] = StringRight("0" & $asDatePart[3], 2)
$asDatePart[2] = StringRight("0" & $asDatePart[2], 2)
$sTempDate = StringReplace($sTempDate, "d", "@")
$sTempDate = StringReplace($sTempDate, "m", "#")
$sTempDate = StringReplace($sTempDate, "y", "&")
$sTempDate = StringReplace($sTempDate, "@@@@", _DateDayOfWeek($iWday, 0))
$sTempDate = StringReplace($sTempDate, "@@@", _DateDayOfWeek($iWday, 1))
$sTempDate = StringReplace($sTempDate, "@@", $asDatePart[3])
$sTempDate = StringReplace($sTempDate, "@", StringReplace(StringLeft($asDatePart[3], 1), "0", "") & StringRight($asDatePart[3], 1))
$sTempDate = StringReplace($sTempDate, "####", _DateToMonth($asDatePart[2], 0))
$sTempDate = StringReplace($sTempDate, "###", _DateToMonth($asDatePart[2], 1))
$sTempDate = StringReplace($sTempDate, "##", $asDatePart[2])
$sTempDate = StringReplace($sTempDate, "#", StringReplace(StringLeft($asDatePart[2], 1), "0", "") & StringRight($asDatePart[2], 1))
$sTempDate = StringReplace($sTempDate, "&&&&", $asDatePart[1])
$sTempDate = StringReplace($sTempDate, "&&", StringRight($asDatePart[1], 2))
EndIf
If $sTempTime <> "" Then
$sTempString = _WinAPI_GetLocaleInfo($LOCALE_USER_DEFAULT, $LOCALE_S1159)
If Not @error And Not($sTempString = '') Then
$sAM = $sTempString
Else
$sAM = "AM"
EndIf
$sTempString = _WinAPI_GetLocaleInfo($LOCALE_USER_DEFAULT, $LOCALE_S2359)
If Not @error And Not($sTempString = '') Then
$sPM = $sTempString
Else
$sPM = "PM"
EndIf
$sTempString = _WinAPI_GetLocaleInfo($LOCALE_USER_DEFAULT, $LOCALE_STIME)
If Not @error And Not($sTempString = '') Then
$sTempTime = StringReplace($sTempTime, ":", $sTempString)
EndIf
If StringInStr($sTempTime, "tt") Then
If $asTimePart[1] < 12 Then
$sTempTime = StringReplace($sTempTime, "tt", $sAM)
If $asTimePart[1] = 0 Then $asTimePart[1] = 12
Else
$sTempTime = StringReplace($sTempTime, "tt", $sPM)
If $asTimePart[1] > 12 Then $asTimePart[1] = $asTimePart[1] - 12
EndIf
EndIf
$asTimePart[1] = StringRight("0" & $asTimePart[1], 2)
$asTimePart[2] = StringRight("0" & $asTimePart[2], 2)
$asTimePart[3] = StringRight("0" & $asTimePart[3], 2)
$sTempTime = StringReplace($sTempTime, "hh", StringFormat("%02d", $asTimePart[1]))
$sTempTime = StringReplace($sTempTime, "h", StringReplace(StringLeft($asTimePart[1], 1), "0", "") & StringRight($asTimePart[1], 1))
$sTempTime = StringReplace($sTempTime, "mm", StringFormat("%02d", $asTimePart[2]))
$sTempTime = StringReplace($sTempTime, "ss", StringFormat("%02d", $asTimePart[3]))
$sTempDate = StringStripWS($sTempDate & " " & $sTempTime, $STR_STRIPLEADING + $STR_STRIPTRAILING)
EndIf
Return $sTempDate
EndFunc
Func _DateTimeSplit($sDate, ByRef $aDatePart, ByRef $iTimePart)
Local $sDateTime = StringSplit($sDate, " T")
If $sDateTime[0] > 0 Then $aDatePart = StringSplit($sDateTime[1], "/-.")
If $sDateTime[0] > 1 Then
$iTimePart = StringSplit($sDateTime[2], ":")
If UBound($iTimePart) < 4 Then ReDim $iTimePart[4]
Else
Dim $iTimePart[4]
EndIf
If UBound($aDatePart) < 4 Then ReDim $aDatePart[4]
For $x = 1 To 3
If StringIsInt($aDatePart[$x]) Then
$aDatePart[$x] = Int($aDatePart[$x])
Else
$aDatePart[$x] = -1
EndIf
If StringIsInt($iTimePart[$x]) Then
$iTimePart[$x] = Int($iTimePart[$x])
Else
$iTimePart[$x] = 0
EndIf
Next
Return 1
EndFunc
Func _DateToDayOfWeek($iYear, $iMonth, $iDay)
If Not _DateIsValid($iYear & "/" & $iMonth & "/" & $iDay) Then
Return SetError(1, 0, "")
EndIf
Local $i_FactorA = Int((14 - $iMonth) / 12)
Local $i_FactorY = $iYear - $i_FactorA
Local $i_FactorM = $iMonth +(12 * $i_FactorA) - 2
Local $i_FactorD = Mod($iDay + $i_FactorY + Int($i_FactorY / 4) - Int($i_FactorY / 100) + Int($i_FactorY / 400) + Int((31 * $i_FactorM) / 12), 7)
Return $i_FactorD + 1
EndFunc
Func _DateToMonth($iMonNum, $iFormat = Default)
If $iFormat = Default Then $iFormat = 0
$iMonNum = Int($iMonNum)
If Not __DateIsMonth($iMonNum) Then Return SetError(1, 0, "")
Local $tSYSTEMTIME = DllStructCreate($tagSYSTEMTIME)
DllStructSetData($tSYSTEMTIME, "Year", @YEAR)
DllStructSetData($tSYSTEMTIME, "Month", $iMonNum)
DllStructSetData($tSYSTEMTIME, "Day", 1)
Return _WinAPI_GetDateFormat(BitAND($iFormat, $DMW_LOCALE_LONGNAME) ? $LOCALE_USER_DEFAULT : $LOCALE_INVARIANT, $tSYSTEMTIME, 0, BitAND($iFormat, $DMW_SHORTNAME) ? "MMM" : "MMMM")
EndFunc
Func _NowDate()
Return _DateTimeFormat(@YEAR & "/" & @MON & "/" & @MDAY, 0)
EndFunc
Func _NowTime($sType = 3)
If $sType < 3 Or $sType > 5 Then $sType = 3
Return _DateTimeFormat(@YEAR & "/" & @MON & "/" & @MDAY & " " & @HOUR & ":" & @MIN & ":" & @SEC, $sType)
EndFunc
Func _DaysInMonth($iYear)
Local $aDays = [12, 31,(_DateIsLeapYear($iYear) ? 29 : 28), 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
Return $aDays
EndFunc
Func _WinAPI_SetWindowTheme($hWnd, $sName = 0, $sList = 0)
Local $sTypeOfName = 'wstr', $sTypeOfList = 'wstr'
If Not IsString($sName) Then
$sTypeOfName = 'ptr'
$sName = 0
EndIf
If Not IsString($sList) Then
$sTypeOfList = 'ptr'
$sList = 0
EndIf
Local $aRet = DllCall('uxtheme.dll', 'long', 'SetWindowTheme', 'hwnd', $hWnd, $sTypeOfName, $sName, $sTypeOfList, $sList)
If @error Then Return SetError(@error, @extended, 0)
If $aRet[0] Then Return SetError(10, $aRet[0], 0)
Return 1
EndFunc
If Not IsDeclared("g_ListStatus") Then Global $g_ListStatus = ""
If Not IsDeclared("g_ImgStatus") Then Global $g_ImgStatus = ""
Func _LoggingInitialize()
If $g_ReBarLogEnabled == 1 Then
If DriveGetType(StringLeft(@ScriptFullPath, 3)) = "CDROM" Then
$g_ReBarLogFileWrite = 0
Else
If BitAND(__LoggingDirCreate(), __LoggingFileReset()) Then
$g_ReBarLogFileWrite = 1
_LoggingWrite("", False)
_LoggingWrite("", False)
_LoggingWrite("                                            ./", False)
_LoggingWrite("                                          (o o)", False)
_LoggingWrite("--------------------------------------oOOo-(-)-oOOo--------------------------------------", False)
_LoggingWrite("", False)
_LoggingGetSystemInfo()
Else
$g_ReBarLogFileWrite = 0
EndIf
EndIf
EndIf
EndFunc
Func _StartLogging($sMessage)
_ClearLogging()
_EditLoggingWrite($sMessage)
_LoggingWrite("------------------------------------------------------------------------------------------", False)
EndFunc
Func _EndLogging()
_EditLoggingWrite("Finished!")
_LoggingWrite("------------------------------------------------------------------------------------------", False)
EndFunc
Func _ClearLogging()
_GUICtrlListView_BeginUpdate($g_ListStatus)
_GUICtrlListView_DeleteAllItems($g_ListStatus)
_GUICtrlListView_EndUpdate($g_ListStatus)
EndFunc
Func _EditLoggingWrite($sMessage = "", $bTimePrex = True, $UseListBox = True)
Local $sTimeStamp = ""
If Not IsDeclared("g_EditInfo") Then Global $g_EditInfo
GUICtrlSetState($g_ListStatus, $GUI_SHOW)
GUICtrlSetState($g_EditInfo, $GUI_HIDE)
If $bTimePrex Then
$sTimeStamp = "[" & @HOUR & ":" & @MIN & ":" & @SEC & ":" & @MSEC & "] "
EndIf
If $UseListBox Then
Local $iImage = 0
If _ValidateError($sMessage) Then
$iImage = 2
ElseIf _ValidateSuccess($sMessage) Then
$iImage = 1
ElseIf StringLeft($sMessage, 9) = "Finished!" Then
Switch @MON
Case 10
$iImage = 4
Case 12
$iImage = 5
Case Else
$iImage = 3
EndSwitch
ElseIf StringLeft($sMessage, 1) = "^" Or  _ValidateWarning($sMessage) Then
$iImage = 6
ElseIf StringStripWS($sMessage, 8) = "" Then
$iImage = 10
EndIf
_GUICtrlListView_AddItem($g_ListStatus, Chr(32) & $sMessage, $iImage)
_GUICtrlListView_SetItemFocused($g_ListStatus, _GUICtrlListView_GetItemCount($g_ListStatus) - 1)
_GUICtrlListView_EnsureVisible($g_ListStatus, _GUICtrlListView_GetItemCount($g_ListStatus) - 1)
Else
_GUICtrlListView_AddItem($g_ListStatus, Chr(32) & $sMessage, $iImage)
_GUICtrlListView_SetItemFocused($g_ListStatus, _GUICtrlListView_GetItemCount($g_ListStatus) - 1)
_GUICtrlListView_EnsureVisible($g_ListStatus, _GUICtrlListView_GetItemCount($g_ListStatus) - 1)
EndIf
_LoggingWrite($sMessage, $bTimePrex)
EndFunc
Func _ValidateSuccess($sMessage)
Local $sSuccessStrings = "success|Response Received|Successfully|OK!|Registration succeeded|Initiated"
Local $aSuccessStrings = StringSplit($sSuccessStrings, "|")
For $s = 1 To $aSuccessStrings[0]
If StringInStr($sMessage, $aSuccessStrings[$s]) Then
Return True
EndIf
Next
EndFunc
Func _ValidateError($sMessage)
Local $sErrorStrings = "error:|error |failed|1 error"
Local $aErrorStrings = StringSplit($sErrorStrings, "|")
For $s = 1 To $aErrorStrings[0]
If StringInStr($sMessage, $aErrorStrings[$s]) Then
Return True
EndIf
Next
EndFunc
Func _ValidateWarning($sMessage)
Local $sWarningStrings = "Access is denied|No operation can be performed"
Local $aWarningStrings = StringSplit($sWarningStrings, "|")
For $s = 1 To $aWarningStrings[0]
If StringInStr($sMessage, $aWarningStrings[$s]) Then
Return True
EndIf
Next
EndFunc
Func _LoggingWrite($sData = "", $bTimePrex = True)
If $g_ReBarLogEnabled = 1 Then
If __LoggingFileReset() And $g_ReBarLogFileWrite = 1 Then
Local $hLogOpen = FileOpen($g_ReBarLogPath, $FO_APPEND)
If $hLogOpen = -1 Then
$g_ReBarLogFileWrite = 0
Return 0
EndIf
Local $sTimePrex= ""
If $bTimePrex Then $sTimePrex = __GenerateTimePrefix(0) & Chr(32)
FileWriteLine($hLogOpen, $sTimePrex & $sData & @CRLF)
FileClose($hLogOpen)
EndIf
$g_ReBarLogFileWrite = 1
Return 1
EndIf
EndFunc
Func _LoggingGetSystemInfo()
Local $aRAMStats = MemGetStats()
_LoggingWrite(StringFormat( "DATE:              %s", __GenerateTimePrefix(0, False)))
_LoggingWrite(StringFormat( "PROGRAM:           %s", $g_ReBarProgName & Chr(32) & FileGetVersion(@ScriptFullPath)))
_LoggingWrite(StringFormat( "PROGRAM PATH:      %s", "[" & @ScriptFullPath & "]"))
_LoggingWrite(StringFormat( "COMPILED:          %s", __StringFromBoolean(@Compiled)))
If Not @Compiled Then
_LoggingWrite(StringFormat( "AUTOIT VERSION:    %s", @AutoItVersion))
_LoggingWrite(StringFormat( "AUTOIT 64-BIT:     %s", __StringFromBoolean(@AutoItX64)))
EndIf
_LoggingWrite(StringFormat( "WINDOWS VERSION:   %s", _GetWindowsVersion() & " " & @OSServicePack))
_LoggingWrite(StringFormat( "SYSTEM TYPE:       %s", StringReplace(@OSArch, "X", "") & "-Bit Operating System"))
_LoggingWrite(StringFormat( "MEMORY (RAM):      %s", Round(($aRAMStats[1] /1024), 2) & " MB"))
_LoggingWrite(StringFormat( "PROGRAM FILES:     %s", @ProgramFilesDir))
_LoggingWrite(StringFormat( "WINDOWS DIRECTORY: %s", @WindowsDir))
_LoggingWrite("-----------------------------------------------------------------------------------------", False)
_LoggingWrite("", False)
EndFunc
Func __StringFromBoolean($bBoolean)
If $bBoolean = 1 Then
Return "YES"
ElseIf $bBoolean = 0 Then
Return "NO"
EndIf
EndFunc
Func __GenerateTimePrefix($iFlag = 0, $bFormat = 1)
Local $sReturn = ""
Switch $iFlag
Case 0
$sReturn = _NowDate() & " " & _NowTime(5)
Case 1
$sReturn = _NowDate()
Case 2
$sReturn = _NowTime(5)
Case 3
$sReturn = _NowTime(5) & ":" & @MSEC
EndSwitch
If $bFormat Then
Return StringFormat("[ %s ]", $sReturn)
Else
Return $sReturn
EndIf
EndFunc
Func _OpenLoggingDirectory()
_StartLogging("Opening logging Directory.")
_EditLoggingWrite("[" & $g_ReBarLogBase & "]")
ShellExecute($g_ReBarLogBase)
If @error Then
_EditLoggingWrite("Error: Could not open [" & $g_ReBarLogBase & "].")
Else
_EditLoggingWrite("Success: The 'logging' directory should now be open.")
EndIf
_EndLogging()
EndFunc
Func _OpenLoggingFile()
_StartLogging("Opening the logging file.")
_EditLoggingWrite("[" & $g_ReBarLogPath & "]")
If FileExists($g_ReBarLogPath) Then
ShellExecute($g_ReBarLogPath)
_EditLoggingWrite("Success: Showing [" & $g_ReBarLogPath & "] file.")
Else
_EditLoggingWrite("Error: Could not find the [" & $g_ReBarLogPath & "] file.")
EndIf
_EndLogging()
EndFunc
Func __LoggingFileCreate()
If $g_ReBarLogEnabled = 1 Then
If FileExists($g_ReBarLogPath) Then
Return 1
Else
If FileWrite($g_ReBarLogPath, "=========================================================================================" & @CRLF & " " & StringUpper($g_ReBarProgName) & " VERSION " & $g_ReBarLogVersion & @CRLF & "=========================================================================================" & @CRLF & "") Then
Return 1
EndIf
EndIf
Return 0
EndIf
EndFunc
Func __LoggingFileReset()
If FileExists($g_ReBarLogPath) Then
If FileGetSize($g_ReBarLogPath) >= $g_ReBarLogStorage Then
If FileDelete($g_ReBarLogPath) Then Return 1
Else
If FileSetAttrib($g_ReBarLogPath, "-RSH") Then Return 1
EndIf
Else
If __LoggingFileCreate() Then Return 1
EndIf
Return 0
EndFunc
Func __LoggingDirCreate()
If FileExists($g_ReBarWorkingDir) Then
If FileExists($g_ReBarLogBase) Then
Return 1
Else
If DirCreate($g_ReBarLogBase) Then Return 1
EndIf
Return 0
Else
Return 0
EndIf
EndFunc
$g_ReBarTitleShowAdmin = 0
$g_ReBarTitleShowAutoIt = 0
$g_ReBarRunProgName = "Flash Drive Repair"
$g_ReBarRunIcon = @ScriptDir & "\Themes\Icons\DVDRepair.ico"
$g_ReBarRunIconHover = @ScriptDir & "\Themes\Icons\DVDRepairH.ico"
$g_ReBarFormWidth = 450
$g_ReBarFormHeight = 450
$g_ReBarShowLogging = 1
Func _ConfigureWindowsService($sServiceName, $iConfig = 2)
Local $sRegService = "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\" & $sServiceName
RegRead($sRegService, "Start")
If Not @error Then
_RegistryWrite($sRegService, "Start", "REG_DWORD", $iConfig)
Else
Return SetError(1, 0, "")
EndIf
EndFunc
Func _RegistryDelete($hKey, $hValue = "REG_NONE")
If $hValue = "REG_NONE" Then
RegDelete($hKey)
Else
RegDelete($hKey, $hValue)
EndIf
Local $nError = @error
If $nError Then
If $hValue = "REG_NONE" Then
Else
EndIf
__ReturnRegistryError($nError, "delete")
EndIf
EndFunc
Func _RegistryWrite($hKey, $hValueName = "REG_NONE", $hRegType = "REG_SZ", $hValue = "")
If $hValueName = "REG_NONE" Then
RegWrite($hKey)
Else
RegWrite($hKey, $hValueName, $hRegType, $hValue)
EndIf
Local $nError = @error
If $nError Then
If $hValueName = "REG_NONE" Then
_EditLoggingWrite("Error: Could not write to [" & $hKey & "]")
Else
_EditLoggingWrite("Error: Could not write to [" & $hKey & " --> " & $hValueName & " --> " & $hRegType & " --> " & $hValue & "]")
EndIf
__ReturnRegistryError($nError, "write")
Else
Return True
EndIf
Return False
EndFunc
Func __ReturnRegistryError($nError, $sIO = "write")
If $sIO == "write" Then
Switch $nError
Case 1
_EditLoggingWrite("Unable to open requested key!")
Case 2
_EditLoggingWrite("Unable to open requested main key!")
Case -1
_EditLoggingWrite("Unable to open requested value!")
Case -2
_EditLoggingWrite("Value type not supported!")
EndSwitch
ElseIf $sIO == "delete" Then
Switch $nError
Case -1
_EditLoggingWrite("Unable to delete requested value!")
Case -2
_EditLoggingWrite("Unable to delete requested key/value!")
EndSwitch
EndIf
EndFunc
Func _RunCommand($sCommand)
Local $iCMD = Run(@ComSpec & " /c " & $sCommand, @SystemDir, @SW_HIDE, $STDERR_MERGED)
Local $sOutput, $sSuccess = ""
While 1
$sOutput = StdoutRead($iCMD)
If @error Then
ExitLoop
EndIf
Local $aOutput = StringSplit($sOutput, @CRLF)
For $x = 1 To $aOutput[0]
If __HasOutput($aOutput[$x]) Then
_EditLoggingWrite(StringStripWS(__FormatRunOutput($aOutput[$x]), $STR_STRIPLEADING + $STR_STRIPTRAILING))
Sleep(50)
EndIf
Next
WEnd
EndFunc
Func __HasOutput($sOutput)
$sOutput = StringStripWS($sOutput, $STR_STRIPLEADING + $STR_STRIPTRAILING + $STR_STRIPSPACES)
Switch $sOutput
Case "", ".", ".."
Return False
Case Else
Return True
EndSwitch
EndFunc
Func __FormatRunOutput($sOutput)
Local $sReturn = $sOutput
Local $sBadStrings = "Resetting , failed.|Sucessfully"
Local $sGoodStrings = "Resetting, failed.|Successfully"
Local $aBadStrings = StringSplit($sBadStrings, "|")
Local $aGoodStrings = StringSplit($sGoodStrings, "|")
If $aBadStrings[0] = $aGoodStrings[0] Then
For $x = 1 To $aBadStrings[0]
$sReturn = StringReplace($sReturn, $aBadStrings[$x], $aGoodStrings[$x])
Next
EndIf
Return $sReturn
EndFunc
Global Const $CLEARTYPE_QUALITY = 5
Func _Singleton($sOccurrenceName, $iFlag = 0)
Local Const $ERROR_ALREADY_EXISTS = 183
Local Const $SECURITY_DESCRIPTOR_REVISION = 1
Local $tSecurityAttributes = 0
If BitAND($iFlag, 2) Then
Local $tSecurityDescriptor = DllStructCreate("byte;byte;word;ptr[4]")
Local $aRet = DllCall("advapi32.dll", "bool", "InitializeSecurityDescriptor", "struct*", $tSecurityDescriptor, "dword", $SECURITY_DESCRIPTOR_REVISION)
If @error Then Return SetError(@error, @extended, 0)
If $aRet[0] Then
$aRet = DllCall("advapi32.dll", "bool", "SetSecurityDescriptorDacl", "struct*", $tSecurityDescriptor, "bool", 1, "ptr", 0, "bool", 0)
If @error Then Return SetError(@error, @extended, 0)
If $aRet[0] Then
$tSecurityAttributes = DllStructCreate($tagSECURITY_ATTRIBUTES)
DllStructSetData($tSecurityAttributes, 1, DllStructGetSize($tSecurityAttributes))
DllStructSetData($tSecurityAttributes, 2, DllStructGetPtr($tSecurityDescriptor))
DllStructSetData($tSecurityAttributes, 3, 0)
EndIf
EndIf
EndIf
Local $aHandle = DllCall("kernel32.dll", "handle", "CreateMutexW", "struct*", $tSecurityAttributes, "bool", 1, "wstr", $sOccurrenceName)
If @error Then Return SetError(@error, @extended, 0)
Local $aLastError = DllCall("kernel32.dll", "dword", "GetLastError")
If @error Then Return SetError(@error, @extended, 0)
If $aLastError[0] = $ERROR_ALREADY_EXISTS Then
If BitAND($iFlag, 1) Then
DllCall("kernel32.dll", "bool", "CloseHandle", "handle", $aHandle[0])
If @error Then Return SetError(@error, @extended, 0)
Return SetError($aLastError[0], $aLastError[0], 0)
Else
Exit -1
EndIf
EndIf
Return $aHandle[0]
EndFunc
OnAutoItExitRegister("_OnReBarExit")
If Not @Compiled Then
$g_ReBarCompName = $g_ReBarRunCompName
$g_ReBarProgName = $g_ReBarRunProgName
$g_ReBarIcon = $g_ReBarRunIcon
$g_ReBarIconHover = $g_ReBarRunIconHover
$g_ReBarRunVersion = _AutoIt3Script_GetVersion(@ScriptFullPath, 0)
Else
$g_ReBarRunVersion = FileGetVersion(@ScriptFullPath)
EndIf
$g_ReBarGuiTitle = _GUIGetTitle($g_ReBarProgName)
If _Singleton($g_ReBarGuiTitle, 1) = 0 And $g_ReBarSingleton = True Then
MsgBox($MB_SYSTEMMODAL + $MB_ICONINFORMATION, "Warning", "Another occurence of " & $g_ReBarProgName & " is already running. This message will self-destruct in " & $g_ReBarMsgTimeout & " seconds.", $g_ReBarMsgTimeout)
Exit
EndIf
Func _SetWorkingDirectories()
If IniRead($g_ReBarPathIni, $g_ReBarShortName, "PortableEdition", 1) = 0 Then
_SetAppDataDirectory()
Else
If Not _GenerateIniFile($g_ReBarPathIni) Then
_SetAppDataDirectory()
Else
_ResetWorkingDirectories()
EndIf
EndIf
EndFunc
Func _SetAppDataDirectory()
_CreateAppDataDirectories()
$g_ReBarAppDataParent = @AppDataDir & "\" & $g_ReBarCompName
$g_ReBarAppDataPath = $g_ReBarAppDataParent & "\" & $g_ReBarShortName
$g_ReBarWorkingDir = $g_ReBarAppDataPath
_ResetWorkingDirectories()
_GenerateIniFile($g_ReBarPathIni, 0)
EndFunc
Func _ResetWorkingDirectories()
$g_ReBarIniFileName = $g_ReBarShortName & ".ini"
$g_ReBarPathIni = $g_ReBarWorkingDir & "\" & $g_ReBarIniFileName
$g_ReBarCacheBase = $g_ReBarWorkingDir & "\Cache"
$g_ReBarCachePath = $g_ReBarCacheBase & "\" & $g_ReBarShortName
$g_ReBarLogFilename = $g_ReBarShortName & ".log"
$g_ReBarLogBase = $g_ReBarWorkingDir & "\Logging\" & $g_ReBarShortName
$g_ReBarLogPath = $g_ReBarLogBase & "\" & $g_ReBarLogFilename
If $g_ReBarCacheEnabled == 1 Then DirCreate($g_ReBarCachePath)
EndFunc
Func _GenerateIniFile($iniPath, $bPortable = 1)
Local $iResult
$iResult = IniWrite($iniPath, $g_ReBarShortName, "PortableEdition", $bPortable)
Return $iResult
EndFunc
Func _CreateAppDataDirectories()
DirCreate($g_ReBarAppDataParent)
DirCreate($g_ReBarAppDataPath)
EndFunc
Global $g_MenuFile, $g_MenuTools, $g_MenuHelp
Global $g_ChkResetAutorun, $g_ChkProtectAutorun, $g_BtnRepair, $g_InpStatus
Global $g_ChkResetMachine, $g_ChkProtectMachine, $g_ChkDoNothing
Global $g_SetResetAutorun = 0, $g_SetProtectAutorun = 0, $g_SetDisableExtras = 0
Global $g_SetResetMachine = 0, $g_SetProtectMachine = 0
If Not @AutoItX64 And @OSArch = "X64" Then
If FileExists(@ScriptDir & "\DriveRepair_x64.exe") Then
ShellExecute(@ScriptDir & "\DriveRepair_x64.exe")
Exit
Else
MsgBox($MB_OK + $MB_ICONERROR, "Warning", "Unfortuantely " & $g_ReBarProgName & " 32 Bit is not compatible " & "with your Windows version. Please download " & $g_ReBarProgName & " 64 Bit from " & $g_ReBarAboutHome, 60)
ShellExecute($g_ReBarAboutHome)
Exit
EndIf
Else
_ReBar_LoadPreferences()
_LoadOptions()
$g_SetResetMachine = IniRead($g_ReBarPathIni, "Options", "ResetAutorunMachine", 1)
$g_SetProtectMachine = IniRead($g_ReBarPathIni, "Options", "ProtectAutorunMachine", 1)
_SetWorkingDirectories()
_LoggingInitialize()
_CheckResources($g_ReBarResFugue)
_CheckResources($g_ReBarResDoors)
_StartCoreGUI()
EndIf
Func _LoadPrefsExtended()
EndFunc
Func _SavePrefsExtended()
EndFunc
Func _LoadOptions()
$g_SetResetAutorun = Int(IniRead($g_ReBarPathIni, $g_ReBarShortName, "ResetAutorun", 1))
$g_SetProtectAutorun = Int(IniRead($g_ReBarPathIni, $g_ReBarShortName, "ProtectAutorun", 0))
$g_SetProtectMachine = Int(IniRead($g_ReBarPathIni, $g_ReBarShortName, "ProtectAutorunMachine", 1))
$g_SetDisableExtras = Int(IniRead($g_ReBarPathIni, $g_ReBarShortName, "DisableExtras", 0))
EndFunc
Func _SaveOptions()
IniWrite($g_ReBarPathIni, $g_ReBarShortName, "ResetAutorun", $g_SetResetAutorun)
IniWrite($g_ReBarPathIni, $g_ReBarShortName, "ProtectAutorun", $g_SetProtectAutorun)
IniWrite($g_ReBarPathIni, $g_ReBarShortName, "ProtectAutorunMachine", $g_SetProtectMachine)
IniWrite($g_ReBarPathIni, $g_ReBarShortName, "DisableExtras", $g_SetDisableExtras)
EndFunc
Func _StartCoreGUI()
_ReBar_LoadPreferences()
$g_ReBarCoreGui = GUICreate($g_ReBarGuiTitle, $g_ReBarFormWidth, $g_ReBarFormHeight, -1, -1, -1)
GUISetFont($g_ReBarFontSize, 400, -1, $g_ReBarFontName, $g_ReBarCoreGui, $CLEARTYPE_QUALITY)
If Not @Compiled Then
GUISetIcon($g_ReBarIcon, 0, $g_ReBarCoreGui)
EndIf
Local $miFileClose, $miFileReboot
Local $miFilePrefs, $mnuLogging, $miLogDir, $miOpenLog
Local $miSysRestore, $miDeviceManager
Local $miHlpHome, $miHlpSupport
$g_MenuFile = GUICtrlCreateMenu("&File")
$g_MenuTools = GUICtrlCreateMenu("&Tools")
$g_MenuHelp = GUICtrlCreateMenu("&Help")
$miFilePrefs = GUICtrlCreateMenuItem("&Preferences", $g_MenuFile)
GUICtrlCreateMenuItem("", $g_MenuFile)
$mnuLogging = GUICtrlCreateMenu("&Logging", $g_MenuFile)
$miLogDir = GUICtrlCreateMenuItem("Open logging &Directory", $mnuLogging)
$miOpenLog = GUICtrlCreateMenuItem("Open logging &File", $mnuLogging)
GUICtrlCreateMenuItem("", $g_MenuFile)
$miFileReboot = GUICtrlCreateMenuItem("&Reboot Windows", $g_MenuFile)
$miFileClose = GUICtrlCreateMenuItem("&Close" & @TAB & "Esc", $g_MenuFile)
GUICtrlSetOnEvent($miFilePrefs, "_ShowPreferencesDlg")
GUICtrlSetOnEvent($miLogDir, "_OpenLoggingDirectory")
GUICtrlSetOnEvent($miOpenLog, "_OpenLoggingFile")
GUICtrlSetOnEvent($miFileReboot, "_ReBarRebootWindows")
GUICtrlSetOnEvent($miFileClose, "_ShutdownProgram")
$miSysRestore = GUICtrlCreateMenuItem("System &Restore", $g_MenuTools)
GUICtrlCreateMenuItem("", $g_MenuTools)
$miDeviceManager = GUICtrlCreateMenuItem("&Device Manager", $g_MenuTools)
GUICtrlSetOnEvent($miSysRestore, "_OpenSystemProtection")
GUICtrlSetOnEvent($miDeviceManager, "_OpenDeviceManager")
$g_ReBarAboutMenu = GUICtrlCreateMenuItem("&About " & $g_ReBarProgName, $g_MenuHelp)
GUICtrlCreateMenuItem("", $g_MenuHelp)
$miHlpHome = GUICtrlCreateMenuItem($g_ReBarCompName & " &Home", $g_MenuHelp)
GUICtrlCreateMenuItem("", $g_MenuHelp)
$miHlpSupport = GUICtrlCreateMenuItem($g_ReBarCompName & " &Support", $g_MenuHelp)
GUICtrlSetOnEvent($g_ReBarAboutMenu, "_ShowAboutDialog")
GUICtrlSetOnEvent($miHlpHome, "_OpenHomePageLink")
GUICtrlSetOnEvent($miHlpSupport, "_OpenSupportLink")
$g_ReBarGuiIcon = GUICtrlCreateIcon($g_ReBarIcon, 99, 5, 5, 128, 128)
GUICtrlSetTip($g_ReBarGuiIcon, "Version " & $g_ReBarRunVersion & @CRLF & "Build with AutoIt version " & @AutoItVersion & @CRLF & "Copyright © " & @YEAR & " " & $g_ReBarCompName, "About " & $g_ReBarProgName, $TIP_INFOICON, $TIP_BALLOON)
GUICtrlSetCursor($g_ReBarGuiIcon, 0)
GUICtrlSetOnEvent($g_ReBarGuiIcon, "_ShowAboutDialog")
GUICtrlCreateLabel("If your USB Drives is missing from " & _GetWindowsVersion() & " or it is not recognized by" & " some applications, click 'Repair USB Drives' and restart your computer." & " Remember to create a System Restore Point before you continue.", 140, 10, 285, 80)
$g_ChkResetAutorun = GUICtrlCreateCheckbox("Reset Autorun Options", 20, 160, 230, 15, $BS_AUTORADIOBUTTON)
$g_ChkDoNothing = GUICtrlCreateCheckbox("Just Repair", 250, 160, 200, 15)
GUICtrlSetTip($g_ChkDoNothing, "Disable reset and protect options.", "Disable extra processing.", $TIP_INFOICON)
$g_ChkProtectAutorun = GUICtrlCreateCheckbox("Protect against Autorun Malware", 20, 180, 230, 15, $BS_AUTORADIOBUTTON)
GUICtrlSetTip($g_ChkProtectAutorun, "This option disables autorun functionality for all removable drives!" & @CRLF & "Select " & Chr(34) & "Reset Autorun Options" & Chr(34) & " to enable autorun.", "Warning", $TIP_WARNINGICON)
$g_ChkProtectMachine = GUICtrlCreateCheckbox("Including Local Machine", 250, 180, 200, 15)
$g_BtnRepair = GUICtrlCreateButton("Repair USB Drives",($g_ReBarFormWidth - 250) / 2, 210, 250, 40)
GUICtrlSetFont($g_BtnRepair, 10, 700, 2)
GUICtrlSetState($g_BtnRepair, $GUI_DEFBUTTON)
$g_ListStatus = GUICtrlCreateListView("", 10, 265, 430, 125, BitOR($LVS_REPORT, $LVS_NOCOLUMNHEADER))
_GUICtrlListView_SetExtendedListViewStyle($g_ListStatus, BitOR($LVS_EX_FULLROWSELECT, $LVS_EX_DOUBLEBUFFER, $LVS_EX_SUBITEMIMAGES, $LVS_EX_INFOTIP, $WS_EX_CLIENTEDGE))
_GUICtrlListView_AddColumn($g_ListStatus, "", 680)
_WinAPI_SetWindowTheme(GUICtrlGetHandle($g_ListStatus), "Explorer")
$g_ImgStatus = _GUIImageList_Create(16, 16, 5, 1, 8, 8)
_GUIImageList_AddIcon($g_ImgStatus, $g_ReBarResFugue, -103)
_GUIImageList_AddIcon($g_ImgStatus, $g_ReBarResFugue, -130)
_GUIImageList_AddIcon($g_ImgStatus, $g_ReBarResFugue, -122)
_GUIImageList_AddIcon($g_ImgStatus, $g_ReBarResFugue, -134)
_GUIImageList_AddIcon($g_ImgStatus, $g_ReBarResFugue, -133)
_GUIImageList_AddIcon($g_ImgStatus, $g_ReBarResFugue, -135)
_GUIImageList_AddIcon($g_ImgStatus, $g_ReBarResFugue, -136)
_GUIImageList_AddIcon($g_ImgStatus, $g_ReBarResFugue, -138)
_GUIImageList_AddIcon($g_ImgStatus, $g_ReBarResFugue, -159)
_GUIImageList_AddIcon($g_ImgStatus, $g_ReBarResFugue, -999)
_GUICtrlListView_SetImageList($g_ListStatus, $g_ImgStatus, 1)
GUICtrlSetFont($g_ListStatus, 9, -1, -1, "Courier New")
GUICtrlSetColor($g_ListStatus, 0x222222)
GUICtrlSetOnEvent($g_BtnRepair, "_RepairUSBDrives")
GUICtrlSetOnEvent($g_ReBarAboutButton, "_ShowAboutDialog")
GUICtrlSetOnEvent($g_ChkResetAutorun, "_SetOptions")
GUICtrlSetOnEvent($g_ChkDoNothing, "_SetOptions")
GUICtrlSetOnEvent($g_ChkProtectAutorun, "_SetOptions")
GUICtrlSetOnEvent($g_ChkProtectMachine, "_SetOptions")
GUICtrlSetState($g_ChkResetAutorun, $g_SetResetAutorun)
GUICtrlSetState($g_ChkDoNothing, $g_SetDisableExtras)
GUICtrlSetState($g_ChkProtectAutorun, $g_SetProtectAutorun)
GUICtrlSetState($g_ChkProtectMachine, $g_SetProtectMachine)
_SetOptions()
GUISetState(@SW_SHOW, $g_ReBarCoreGui)
GUISetOnEvent($GUI_EVENT_CLOSE, "_ShutdownProgram", $g_ReBarCoreGui)
AdlibRegister("_OnMainIconHover", 50)
_SoftwareUpdateCheck()
While 1
Sleep(55)
WEnd
EndFunc
Func _OpenSystemProtection()
Run("systempropertiesprotection")
EndFunc
Func _OpenDeviceManager()
EndFunc
Func _SetOptions()
If GUICtrlRead($g_ChkDoNothing) = $GUI_CHECKED Then
GUICtrlSetState($g_ChkResetAutorun, $GUI_DISABLE)
GUICtrlSetState($g_ChkProtectAutorun, $GUI_DISABLE)
GUICtrlSetState($g_ChkProtectMachine, $GUI_DISABLE)
$g_SetDisableExtras = 1
Else
GUICtrlSetState($g_ChkResetAutorun, $GUI_ENABLE)
GUICtrlSetState($g_ChkProtectAutorun, $GUI_ENABLE)
$g_SetDisableExtras = 0
If GUICtrlRead($g_ChkResetAutorun) = $GUI_CHECKED Then
$g_SetResetAutorun = 1
$g_SetProtectAutorun = 0
GUICtrlSetState($g_ChkProtectMachine, $GUI_DISABLE)
ElseIf GUICtrlRead($g_ChkProtectAutorun) = $GUI_CHECKED Then
$g_SetProtectAutorun = 1
$g_SetResetAutorun = 0
GUICtrlSetState($g_ChkProtectMachine, $GUI_ENABLE)
EndIf
If GUICtrlRead($g_ChkProtectMachine) = $GUI_CHECKED Then
$g_SetProtectMachine = 1
Else
$g_SetProtectMachine = 0
EndIf
EndIf
EndFunc
Func _OnMainIconHover()
Local $iCursor = GUIGetCursorInfo()
If Not @error Then
If $iCursor[4] = $g_ReBarGuiIcon And $g_ReBarIcoHovering = 1 Then
$g_ReBarIcoHovering = 0
GUICtrlSetImage($g_ReBarGuiIcon, $g_ReBarIconHover, 201)
ElseIf $iCursor[4] <> $g_ReBarGuiIcon And $g_ReBarIcoHovering = 0 Then
$g_ReBarIcoHovering = 1
GUICtrlSetImage($g_ReBarGuiIcon, $g_ReBarIcon, 99)
EndIf
EndIf
EndFunc
Func _RepairUSBDrives()
GUICtrlSetState($g_BtnRepair, $GUI_DISABLE)
GUICtrlSetState($g_ChkResetAutorun, $GUI_DISABLE)
GUICtrlSetState($g_ChkProtectAutorun, $GUI_DISABLE)
GUICtrlSetState($g_ChkDoNothing, $GUI_DISABLE)
_StartLogging("Repairing USB Drives...")
_ConfigureWindowsService("ShellHWDetection", 2)
_RunCommand("sc config ShellHWDetection start= auto obj= LocalSystem")
_RunCommand("net start ShellHWDetection")
_EditLoggingWrite("Resetting Upper and Lower Filters")
_RegistryDelete("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Class\{4D36E965-E325-11CE-BFC1-08002BE10318}", "UpperFilters")
_RegistryDelete("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Class\{4D36E965-E325-11CE-BFC1-08002BE10318}", "LowerFilters")
If $g_SetDisableExtras = 0 Then
If $g_SetResetAutorun = 1 Then
_EditLoggingWrite("Resetting Autorun Settings.")
_RegistryWrite("HKEY_LOCAL_MACHINE\System\CurrentControlSet\Services\CDRom", "AutoRun", "REG_DWORD", 1)
_RegistryDelete("HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer", "DontSetAutoplayCheckbox")
_RegistryDelete("HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer", "NoAutorun")
_RegistryDelete("HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer", "NoDriveTypeAutoRun")
_RegistryDelete("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer", "DontSetAutoplayCheckbox")
_RegistryDelete("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer", "NoAutorun")
_RegistryDelete("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer", "NoDriveTypeAutoRun")
If @OSVersion = "WIN_XP" Then
_RegistryDelete("HKEY_LOCAL_MACHINE\Software\Microsoft\Windows NT\CurrentVersion\IniFileMapping\Autorun.inf", "")
EndIf
ElseIf $g_SetProtectAutorun = 1 Then
_RegistryWrite("HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer", "NoAutorun", "REG_DWORD", 1)
If @OSVersion = "WIN_XP" Then
_RegistryWrite("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\IniFileMapping\Autorun.inf", "", "REG_SZ", "@SYS:DoesNotExist")
Else
_RegistryWrite("HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer", "DontSetAutoplayCheckbox", "REG_DWORD", 1)
_RegistryWrite("HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer", "NoDriveTypeAutoRun", "REG_DWORD", 255)
If $g_SetProtectMachine = 1 Then
_RegistryWrite("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer", "NoAutorun", "REG_DWORD", 1)
_RegistryWrite("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer", "DontSetAutoplayCheckbox", "REG_DWORD", 1)
_RegistryWrite("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer", "NoDriveTypeAutoRun", "REG_DWORD", 255)
EndIf
EndIf
EndIf
EndIf
GUICtrlSetState($g_BtnRepair, $GUI_ENABLE)
GUICtrlSetState($g_ChkResetAutorun, $GUI_ENABLE)
GUICtrlSetState($g_ChkProtectAutorun, $GUI_ENABLE)
GUICtrlSetState($g_ChkDoNothing, $GUI_ENABLE)
_EditLoggingWrite("Processing Finished.")
_EditLoggingWrite("Reboot required! File -> Reboot Windows.")
_EndLogging()
EndFunc
Func _OnCoreClosing()
_SaveOptions()
AdlibUnRegister("_OnMainIconHover")
EndFunc
Func _PreferencesExtended()
EndFunc
Func _CheckPrefsChangeExtended()
EndFunc
Func _ReBar_LoadPreferences()
_LoadPrefsExtended()
$g_ReBarClearCacheOnExit = IniRead($g_ReBarIniFileName, $g_ReBarShortName, "ClearCacheOnExit", 0)
$g_ReBarLogEnabled = IniRead($g_ReBarIniFileName, $g_ReBarShortName, "LoggingEnabled", 1)
$g_ReBarLogStorage = IniRead($g_ReBarIniFileName, $g_ReBarShortName, "LoggingStorageSize", 5242880)
EndFunc
Func _ReBar_SavePreferences()
If GUICtrlRead($g_ReBarChkLogEnabled) = $GUI_CHECKED Then
$g_ReBarLogEnabled = 1
ElseIf GUICtrlRead($g_ReBarChkLogEnabled) = $GUI_UNCHECKED Then
$g_ReBarLogEnabled = 0
EndIf
If GUICtrlRead($g_ReBarChkCacheOnExit) = $GUI_CHECKED Then
$g_ReBarClearCacheOnExit = 1
ElseIf GUICtrlRead($g_ReBarChkCacheOnExit) = $GUI_UNCHECKED Then
$g_ReBarClearCacheOnExit = 0
EndIf
$g_ReBarLogStorage = Int(GUICtrlRead($g_ReBarInLogSize)) * 1024
_SavePrefsExtended()
IniWrite($g_ReBarIniFileName, $g_ReBarShortName, "ClearCacheOnExit", $g_ReBarClearCacheOnExit)
IniWrite($g_ReBarIniFileName, $g_ReBarShortName, "LoggingEnabled", $g_ReBarLogEnabled)
IniWrite($g_ReBarIniFileName, $g_ReBarShortName, "LoggingStorageSize", $g_ReBarLogStorage)
GUICtrlSetData($g_LabelPrefsMessage, "Preferences Saved")
GUICtrlSetState($g_LabelPrefsMessage, $GUI_SHOW)
GUICtrlSetState($g_ReBarBtnSavePrefs, $GUI_DISABLE)
EndFunc
Func _ShowPreferencesDlg()
_ReBar_LoadPreferences()
Local $BtnSettCancel
WinSetTrans($g_ReBarCoreGui, Default, 200)
GUISetState(@SW_DISABLE, $g_ReBarCoreGui)
$g_ReBarPrefsGui = GUICreate($g_ReBarProgName & " Preferences", 450, 500, -1, -1, BitOR($WS_CAPTION, $WS_POPUPWINDOW), $WS_EX_TOPMOST)
GUISetFont($g_ReBarFontSize, 400, 0, $g_ReBarFontName, $g_ReBarPrefsGui, 5)
GUISetIcon($g_ReBarResFugue, 131)
GUISetOnEvent($GUI_EVENT_CLOSE, "_CloseOptionsDlg", $g_ReBarPrefsGui)
GUICtrlCreateTab(10, 10, 430, 430)
_PreferencesExtended()
GUICtrlCreateTabItem(" Cache ")
GUICtrlCreateGroup("Cache", 25, 50, 400, 100)
GUICtrlSetFont(-1, 10, 700, 2)
$g_ReBarChkCacheOnExit = GUICtrlCreateCheckbox(" Clear Cache on Exit", 35, 80, 200, 20)
GUICtrlSetState($g_ReBarChkCacheOnExit, $g_ReBarClearCacheOnExit)
GUICtrlCreateLabel("Cache Size:", 255, 80, 75, 20)
GUICtrlSetColor(-1, 0x555555)
$g_ReBarLabelCacheSize = GUICtrlCreateLabel(Round(DirGetSize($g_ReBarCachePath) / 1024, 2) & " KB", 330, 80, 100, 20)
GUICtrlSetColor($g_ReBarLabelCacheSize, 0x008000)
$g_ReBarBtnClearCache = GUICtrlCreateButton("Clear Cache", 255, 100, 150, 30)
GUICtrlCreateGroup("", -99, -99, 1, 1)
If $g_ReBarShowLogging = 1 Then
GUICtrlCreateGroup("Logging", 25, 160, 400, 180)
GUICtrlSetFont(-1, 10, 700, 2)
$g_ReBarChkLogEnabled = GUICtrlCreateCheckbox(" Enable logging", 35, 200, 200, 20)
GUICtrlCreateLabel("Log size must not exceed :", 35, 230, 160, 20)
$g_ReBarInLogSize = GUICtrlCreateInput(Round($g_ReBarLogStorage / 1024, 2), 195, 228, 100, 20)
GUICtrlSetStyle($g_ReBarInLogSize, BitOr($ES_RIGHT, $ES_NUMBER))
GUICtrlSetFont(-1, 9, 400, 0, "Verdana")
GUICtrlCreateLabel("KB", 305, 230, 50, 20)
$g_ReBarInLogSizeTemp = Int(GUICtrlRead($g_ReBarInLogSize))
GUICtrlCreateLabel("Logging Size:", 255, 270, 80, 20)
GUICtrlSetColor(-1, 0x555555)
$g_ReBarLabelLogSize = GUICtrlCreateLabel("0 KB", 338, 270, 100, 20)
_SetLoggingSizeLabel()
GUICtrlSetColor($g_ReBarLabelLogSize, 0x008000)
$g_ReBarBtnClearLog = GUICtrlCreateButton("Clear Logging", 255, 290, 150, 30)
GUICtrlCreateGroup("", -99, -99, 1, 1)
GUICtrlSetOnEvent($g_ReBarChkCacheOnExit, "_CheckPreferenceChange")
GUICtrlSetOnEvent($g_ReBarChkLogEnabled, "_CheckPreferenceChange")
GUICtrlSetOnEvent($g_ReBarBtnClearLog, "_RemoveLoggingFile")
GUICtrlSetState($g_ReBarChkLogEnabled, $g_ReBarLogEnabled)
EndIf
GUICtrlCreateTabItem("")
$g_LabelPrefsMessage = GUICtrlCreateLabel("Preferences Updated", 25, 455, 200, 20)
GUICtrlSetColor($g_LabelPrefsMessage, 0x008000)
GUICtrlSetState($g_LabelPrefsMessage, $GUI_HIDE)
$g_ReBarBtnSavePrefs = GUICtrlCreateButton("Save", 210, 450, 100, 30)
$BtnSettCancel = GUICtrlCreateButton("Cancel", 320, 450, 100, 30)
GUICtrlSetState($g_ReBarBtnSavePrefs, $GUI_FOCUS)
GUICtrlSetState($g_ReBarBtnSavePrefs, $GUI_DISABLE)
GUICtrlSetOnEvent($g_ReBarBtnClearCache, "_ClearCacheFolder")
GUICtrlSetOnEvent($g_ReBarBtnSavePrefs, "_ReBar_SavePreferences")
GUICtrlSetOnEvent($BtnSettCancel, "_CloseOptionsDlg")
GUISetState(@SW_SHOW, $g_ReBarPrefsGui)
_CheckPreferenceChange()
AdlibRegister("_CheckLogSizeChange", 1000)
EndFunc
Func _CloseOptionsDlg()
AdlibUnRegister("_CheckLogSizeChange")
GUIDelete($g_ReBarPrefsGui)
WinSetTrans($g_ReBarCoreGui, Default, 255)
GUISetState(@SW_ENABLE, $g_ReBarCoreGui)
WinActivate($g_ReBarCoreGui)
EndFunc
Func _CheckLogSizeChange()
Local $iLogTemp = Int(GUICtrlRead($g_ReBarInLogSize))
If $g_ReBarInLogSizeTemp <> $iLogTemp Then
GUICtrlSetState($g_ReBarBtnSavePrefs, $GUI_ENABLE)
$g_ReBarInLogSizeTemp = $iLogTemp
EndIf
EndFunc
Func _CheckPreferenceChange()
If _CheckBoxChanged("ClearCacheOnExit", $g_ReBarChkCacheOnExit) = True Or  _CheckBoxChanged("LoggingEnabled", $g_ReBarChkLogEnabled) = True Then
GUICtrlSetState($g_ReBarBtnSavePrefs, $GUI_ENABLE)
Else
GUICtrlSetState($g_ReBarBtnSavePrefs, $GUI_DISABLE)
EndIf
_CheckPrefsChangeExtended()
If GUICtrlRead($g_ReBarChkLogEnabled) = $GUI_CHECKED Then
GUICtrlSetState($g_ReBarInLogSize, $GUI_ENABLE)
GUICtrlSetState($g_ReBarBtnClearLog, $GUI_ENABLE)
Else
GUICtrlSetState($g_ReBarInLogSize, $GUI_DISABLE)
GUICtrlSetState($g_ReBarBtnClearLog, $GUI_DISABLE)
EndIf
EndFunc
Func _SetLoggingSizeLabel()
If FileExists($g_ReBarLogBase) Then
GUICtrlSetData($g_ReBarLabelLogSize, Round(DirGetSize($g_ReBarLogBase) / 1024, 2) & " KB")
Else
GUICtrlSetData($g_ReBarLabelLogSize, "0 KB")
EndIf
EndFunc
Func _CheckBoxChanged($sPreference, $hCheckBox)
Local $iTmp = IniRead($g_ReBarIniFileName, $g_ReBarShortName, $sPreference, -1)
If $iTmp > -1 Then
If GUICtrlRead($hCheckBox) = $iTmp Or GUICtrlRead($hCheckBox) =($iTmp + 4) Then
Return False
Else
Return True
EndIf
Else
Return True
EndIf
EndFunc
Func _ClearCacheFolder()
GUICtrlSetState($g_ReBarBtnClearCache, $GUI_DISABLE)
DirRemove($g_ReBarCachePath, 1)
If $g_ReBarCacheEnabled == 1 Then DirCreate($g_ReBarCachePath)
GUICtrlSetData($g_ReBarLabelCacheSize, Round(DirGetSize($g_ReBarCachePath) / 1024, 2) & " KB")
GUICtrlSetData($g_LabelPrefsMessage, "Cache cleared")
GUICtrlSetState($g_LabelPrefsMessage, $GUI_SHOW)
GUICtrlSetState($g_ReBarBtnClearCache, $GUI_ENABLE)
EndFunc
Func _RemoveLoggingFile()
GUICtrlSetState($g_ReBarBtnClearLog, $GUI_DISABLE)
DirRemove($g_ReBarLogBase, 1)
If $g_ReBarLogEnabled = 1 Then
_LoggingInitialize()
EndIf
_SetLoggingSizeLabel()
GUICtrlSetData($g_LabelPrefsMessage, "Logging file cleared")
GUICtrlSetState($g_LabelPrefsMessage, $GUI_SHOW)
GUICtrlSetState($g_ReBarBtnClearLog, $GUI_ENABLE)
EndFunc
If Not IsDeclared("iEventError") Then Global $iEventError
If Not IsDeclared("oErrorHandler") Then Global $oErrorHandler
Func _ShutdownProgram()
_OnCoreClosing()
If $g_ReBarClearCacheOnExit == 1 Then DirRemove($g_ReBarCachePath, 1)
WinSetTrans($g_ReBarCoreGui, Default, 255)
If $g_ReBarHasTrayIcon Then TraySetState(2)
If $g_ReBarSingleton Then
Local $iPID = ProcessExists(@ScriptName)
If $iPID Then ProcessClose($iPID)
EndIf
Exit($g_ReBarExitCode)
EndFunc
Func _ShowAboutDialog()
GUICtrlSetState($g_ReBarAboutMenu, $GUI_DISABLE)
GUICtrlSetState($g_ReBarAboutButton, $GUI_DISABLE)
If $g_ReBarHasTrayIcon Then GUICtrlSetState($g_ReBarAboutTray, $GUI_DISABLE)
WinSetTrans($g_ReBarCoreGui, Default, 200)
GUISetState(@SW_DISABLE, $g_ReBarCoreGui)
Local $abTitle, $abVersion, $abCopyright, $abHome
Local $abSpaceLabel, $abSpaceProg, $abBtnOK, $abGNU, $abSupport, $abCountry
Local $abPayPal, $abFacebook, $abTwittter, $abGoogle
Local $abReBar
$g_ReBarAboutGui = GUICreate("About " & $g_ReBarProgName, 400, 480, -1, -1, BitOR($WS_CAPTION, $WS_POPUPWINDOW), $WS_EX_TOPMOST)
GUISetFont($g_ReBarFontSize, 400, 0, $g_ReBarFontName, $g_ReBarAboutGui, 5)
GUISetIcon($g_ReBarResFugue, 103, $g_ReBarAboutGui)
GUISetIcon($g_ReBarResDoors, -111, $g_ReBarAboutGui)
GUISetOnEvent($GUI_EVENT_CLOSE, "_CloseAboutDlg", $g_ReBarAboutGui)
GUICtrlCreateIcon($g_ReBarIcon, 99, 10, 10, 64, 64)
$abTitle = GUICtrlCreateLabel($g_ReBarProgName, 88, 16, 220, 18)
GUICtrlSetFont($abTitle, 11, 700)
GUICtrlCreateLabel("Version " & $g_ReBarRunVersion, 88, 40, 230, 15)
GUICtrlCreateLabel("Build with AutoIt version " & @AutoItVersion, 88, 55, 230, 15)
GUICtrlCreateLabel("Copyright © " & @YEAR & " " & $g_ReBarCompName, 88, 75, 230, 15)
GUICtrlSetColor(-1, 0x666666)
$abPayPal = GUICtrlCreateIcon($g_ReBarResDoors, 101, 326, 0, 64, 64)
GUICtrlSetTip($abPayPal, "Help us keep our software free.")
GUICtrlSetCursor($abPayPal, 0)
GUICtrlCreateLabel("", 10, 105, 380, 1)
GUICtrlSetBkColor(-1, 0xA0A0A0)
GUICtrlCreateLabel("", 10, 106, 380, 1)
GUICtrlSetBkColor(-1, 0xFFFFFF)
GUICtrlCreateLabel(" Home: ", 10, 120, 60, 15, $SS_RIGHT)
$abHome = GUICtrlCreateLabel($g_ReBarAboutHome, 75, 120, 300, 15)
GUICtrlSetFont($abHome, 8.5, -1, 4)
GUICtrlSetColor($abHome, 0x0000FF)
GUICtrlSetCursor($abHome, 0)
GUICtrlCreateLabel("License: ", 10, 138, 60, 15, $SS_RIGHT)
$abGNU = GUICtrlCreateLabel("GNU General Public License 3", 75, 138, 300, 15)
GUICtrlSetColor($abGNU, 0x666666)
GUICtrlCreateLabel("Support: ", 10, 156, 60, 15, $SS_RIGHT)
$abSupport = GUICtrlCreateLabel($g_ReBarAboutSupport, 75, 156, 300, 15)
GUICtrlSetFont($abSupport, 8.5, -1, 4)
GUICtrlSetColor($abSupport, 0x0000FF)
GUICtrlSetCursor($abSupport, 0)
$abCountry = GUICtrlCreateIcon($g_ReBarResDoors, 102, 334, 165, 48, 48)
GUICtrlSetTip($abCountry, "This software was proudly made in South Africa.", "Proudly South African", $TIP_INFOICON)
GUICtrlSetCursor($abCountry, 0)
GUICtrlCreateGroup("Contributors", 10, 205, 380, 130)
GUICtrlSetFont(-1, 10, 700, 2)
GUICtrlCreateEdit($g_ReBarAboutCredits, 15, 230, 370, 90, BitOR($WS_VSCROLL, $ES_READONLY), $WS_EX_CLIENTEDGE)
GUICtrlSetColor(-1, 0x333333)
GUICtrlSetFont(-1, 8.5, -1, 2)
GUICtrlCreateGroup("", -99, -99, 1, 1)
Local $sDrive = "", $sDir = "", $sFileName = "", $sExtension = ""
_PathSplit(@ScriptDir, $sDrive, $sDir, $sFileName, $sExtension)
Local $drvSpaceUsed = DriveSpaceTotal($sDrive) - DriveSpaceFree($sDrive)
$abSpaceLabel = GUICtrlCreateLabel("(" & $sDrive & ") " & Round(DriveSpaceFree($sDrive) / 1024, 2) & " GB FREE OF " & Round(DriveSpaceTotal($sDrive) / 1024, 2) & " GB", 15, 380, 300, 15)
GUICtrlSetFont($abSpaceLabel, 8.5, 700)
GUICtrlSetColor($abSpaceLabel, 0x333333)
$abSpaceProg = GUICtrlCreateProgress(15, 400, 370, 15)
GUICtrlSetData($abSpaceProg,($drvSpaceUsed / DriveSpaceTotal($sDrive)) * 100)
$abBtnOK = GUICtrlCreateButton("OK", 260, 435, 130, 33, $BS_DEFPUSHBUTTON)
$abFacebook = GUICtrlCreateIcon($g_ReBarResDoors, 103, 20, 435, 32, 32)
GUICtrlSetTip($abFacebook, "Like us on Facebook.")
GUICtrlSetCursor($abFacebook, 0)
$abTwittter = GUICtrlCreateIcon($g_ReBarResDoors, 104, 55, 435, 32, 32)
GUICtrlSetTip($abTwittter, "Follow us on Twitter.")
GUICtrlSetCursor($abTwittter, 0)
$abGoogle = GUICtrlCreateIcon($g_ReBarResDoors, 106, 90, 435, 32, 32)
GUICtrlSetTip($abGoogle, "Find us on Google.")
GUICtrlSetCursor($abGoogle, 0)
GUICtrlSetOnEvent($abBtnOK, "_CloseAboutDlg")
GUICtrlSetOnEvent($abHome, "_OpenHomePageLink")
GUICtrlSetOnEvent($abSupport, "_OpenSupportLink")
GUICtrlSetOnEvent($abPayPal, "_OpenDonateLink")
GUICtrlSetOnEvent($abCountry, "_OpenCountryLink")
GUICtrlSetOnEvent($abReBar, "_OpenReBarLink")
GUICtrlSetOnEvent($abFacebook, "_OpenFacebookLink")
GUICtrlSetOnEvent($abTwittter, "_OpenTwitterLink")
GUICtrlSetOnEvent($abGoogle, "_OpenGoogleLink")
GUISetState(@SW_SHOW, $g_ReBarAboutGui)
EndFunc
Func _OpenCountryLink()
ShellExecute($g_ReBarAboutCountry)
EndFunc
Func _OpenDonateLink()
ShellExecute($g_ReBarAboutDonate)
EndFunc
Func _OpenFacebookLink()
ShellExecute($g_ReBarAboutFacebook)
EndFunc
Func _OpenGoogleLink()
ShellExecute($g_ReBarAboutGoogle)
EndFunc
Func _OpenHomePageLink()
ShellExecute($g_ReBarAboutHome)
EndFunc
Func _OpenReBarLink()
ShellExecute($g_ReBarAboutHome)
EndFunc
Func _OpenSupportLink()
ShellExecute($g_ReBarAboutSupport)
EndFunc
Func _OpenTwitterLink()
ShellExecute($g_ReBarAboutTwitter)
EndFunc
Func _CloseAboutDlg()
GUICtrlSetState($g_ReBarAboutMenu, $GUI_ENABLE)
GUICtrlSetState($g_ReBarAboutButton, $GUI_ENABLE)
If $g_ReBarHasTrayIcon Then GUICtrlSetState($g_ReBarAboutTray, $GUI_ENABLE)
GUIDelete($g_ReBarAboutGui)
WinSetTrans($g_ReBarCoreGui, Default, 255)
GUISetState(@SW_ENABLE, $g_ReBarCoreGui)
WinActivate($g_ReBarCoreGui)
EndFunc
Func _OnReBarExit()
EndFunc
