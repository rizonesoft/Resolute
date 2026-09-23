#Region Header

#cs

    Title:          WinAPI Extended UDF Library for AutoIt3
    Filename:       WinAPIEx.au3
    Description:    Additional variables, constants and functions for the WinAPI.au3
    Author:         Yashied
    Version:        1.9
    Requirements:   AutoIt v3.3 +, Developed/Tested on WindowsXP Pro Service Pack 2
    Uses:           StructureConstants.au3, WinAPI.au3
    Notes:          -

    Available functions:

    _WinAPI_AboutDlg
    _WinAPI_AddFontResource
    _WinAPI_AlphaBlend
    _WinAPI_AnimateWindow
    _WinAPI_ArrayToStruct
    _WinAPI_AssocQueryString
    _WinAPI_BeginPaint
    _WinAPI_BringWindowToTop
    _WinAPI_CharToOem
    _WinAPI_ChildWindowFromPointEx
    _WinAPI_CloseWindow
    _WinAPI_CopyFileEx
    _WinAPI_CopyImage
    _WinAPI_CopyRect
    _WinAPI_CreateBrushIndirect
    _WinAPI_CreateCompatibleBitmapEx
    _WinAPI_CreateDIBSection
    _WinAPI_CreateEllipticRgn
    _WinAPI_CreateFileEx
    _WinAPI_CreateIconIndirect
    _WinAPI_CreatePolygonRgn
    _WinAPI_CreateRect
    _WinAPI_CreateRectEx
    _WinAPI_CreateRectRgnIndirect
    _WinAPI_CreateSemaphore
    _WinAPI_DefineDosDevice
    _WinAPI_DeleteVolumeMountPoint
    _WinAPI_DeregisterShellHookWindow
    _WinAPI_DllInstall
    _WinAPI_DllUninstall
    _WinAPI_DragAcceptFiles
    _WinAPI_DragFinish
    _WinAPI_DragQueryFileEx
    _WinAPI_DragQueryPoint
    _WinAPI_DrawAnimatedRects
    _WinAPI_DrawBitmap
    _WinAPI_DrawShadowText
    _WinAPI_DuplicateBitmap
    _WinAPI_DuplicateCursor
    _WinAPI_DuplicateIcon
    _WinAPI_EjectMedia
    _WinAPI_Ellipse
    _WinAPI_EmptyWorkingSet
    _WinAPI_EndPaint
    _WinAPI_EnumChildWindows
    _WinAPI_EnumDisplaySettings
    _WinAPI_EnumProcessThreads
    _WinAPI_EnumProcessWindows
    _WinAPI_EnumResourceLanguages
    _WinAPI_EnumResourceNames
    _WinAPI_EnumResourceTypes
    _WinAPI_EqualRect
    _WinAPI_EqualRgn
    _WinAPI_ExtractAssociatedIcon
    _WinAPI_ExtSelectClipRgn
    _WinAPI_FatalExit
    _WinAPI_FileTimeToLocalFileTime
    _WinAPI_FileTimeToSystemTime
   *_WinAPI_FillRect
    _WinAPI_FillRgn
    _WinAPI_FillStruct
    _WinAPI_FindResource
    _WinAPI_FindResourceEx
    _WinAPI_FitToBitmap
    _WinAPI_FormatDriveDlg
   *_WinAPI_FrameRect
    _WinAPI_FrameRgn
    _WinAPI_FreeCursor
    _WinAPI_FreeHandle
    _WinAPI_FreeIcon
    _WinAPI_FreeObject
    _WinAPI_FreeResource
    _WinAPI_GetActiveWindow
    _WinAPI_GetBitmapDimension
    _WinAPI_GetBkColor
    _WinAPI_GetBValue
    _WinAPI_GetClassLong
    _WinAPI_GetCompression
    _WinAPI_GetCurrentDirectory
    _WinAPI_GetCursor
    _WinAPI_GetDefaultPrinter
    _WinAPI_GetDiskFreeSpaceEx
    _WinAPI_GetDriveBusType
    _WinAPI_GetDriveGeometryEx
    _WinAPI_GetDriveNumber
    _WinAPI_GetDriveType
    _WinAPI_GetFontResourceInfo
   *_WinAPI_GetForegroundWindow
    _WinAPI_GetGValue
    _WinAPI_GetHandleInformation
    _WinAPI_GetIconBitmap
    _WinAPI_GetIconDimension
    _WinAPI_GetIconMask
    _WinAPI_GetIdleTime
    _WinAPI_GetKeyboardLayout
    _WinAPI_GetKeyboardLayoutList
    _WinAPI_GetKeyboardState
    _WinAPI_GetKeyNameText
    _WinAPI_GetKeyState
    _WinAPI_GetLayeredWindowAttributes
    _WinAPI_GetLocaleInfo
    _WinAPI_GetModuleFileNameEx
    _WinAPI_GetObjectEx
    _WinAPI_GetObjectType
    _WinAPI_GetPixel
    _WinAPI_GetProcAddress
    _WinAPI_GetProcessCreationTime
    _WinAPI_GetProcessMemoryInfo
    _WinAPI_GetRgnBox
    _WinAPI_GetROP2
    _WinAPI_GetRValue
    _WinAPI_GetSystemPowerStatus
    _WinAPI_GetTempFileName
    _WinAPI_GetTextColor
    _WinAPI_GetTextMetrics
    _WinAPI_GetThemeAppProperties
    _WinAPI_GetThemeColor
    _WinAPI_GetTickCount
    _WinAPI_GetTopWindow
    _WinAPI_GetUserDefaultLCID
    _WinAPI_GetVersionEx
    _WinAPI_GetVolumeNameForVolumeMountPoint
    _WinAPI_GetWindowInfo
    _WinAPI_GetWindowModuleFileName
    _WinAPI_GetWorkArea
    _WinAPI_GradientFill
    _WinAPI_InflateRect
    _WinAPI_IntersectRect
   *_WinAPI_InvalidateRect
    _WinAPI_InvalidateRgn
    _WinAPI_InvertRect
    _WinAPI_InvertRgn
    _WinAPI_IsChild
    _WinAPI_IsDoorOpen
    _WinAPI_IsHungAppWindow
    _WinAPI_IsIconic
    _WinAPI_IsNetworkAlive
    _WinAPI_IsPressed
    _WinAPI_IsRectEmpty
    _WinAPI_IsThemeActive
    _WinAPI_IsWindowEnabled
    _WinAPI_IsWindowUnicode
    _WinAPI_IsWritable
    _WinAPI_IsZoomed
    _WinAPI_Keybd_Event
    _WinAPI_KillTimer
    _WinAPI_LoadCursor
    _WinAPI_LoadCursorFromFile
    _WinAPI_LoadMedia
    _WinAPI_LoadResource
    _WinAPI_LockDevice
    _WinAPI_LockResource
    _WinAPI_LockWorkStation
    _WinAPI_MoveFileEx
    _WinAPI_OemToChar
    _WinAPI_OffsetClipRgn
    _WinAPI_OffsetRect
    _WinAPI_OffsetRgn
    _WinAPI_OpenIcon
    _WinAPI_OpenSemaphore
    _WinAPI_PaintRgn
    _WinAPI_PathCompactPath
    _WinAPI_PathFindOnPath
    _WinAPI_PathIsDirectory
    _WinAPI_PathIsDirectoryEmpty
    _WinAPI_PathMatchSpec
    _WinAPI_PathSearchAndQualify
    _WinAPI_PathYetAnotherMakeUniqueName
    _WinAPI_PickIconDlg
    _WinAPI_Polygon
  **_WinAPI_PrivateExtractIcon
    _WinAPI_PtInRectEx
    _WinAPI_PtInRegion
    _WinAPI_QueryDosDevice
    _WinAPI_Rectangle
    _WinAPI_RegisterShellHookWindow
    _WinAPI_ReleaseSemaphore
    _WinAPI_RemoveFontResource
    _WinAPI_RestartDlg
    _WinAPI_RestoreDC
    _WinAPI_RGB
    _WinAPI_RoundRect
    _WinAPI_SaveDC
    _WinAPI_SetActiveWindow
    _WinAPI_SetClassLong
    _WinAPI_SetCompression
    _WinAPI_SetCurrentDirectory
   *_WinAPI_SetDefaultPrinter
    _WinAPI_SetDCBrushColor
    _WinAPI_SetDCPenColor
    _WinAPI_SetFilePointerEx
    _WinAPI_SetForegroundWindow
   *_WinAPI_SetHandleInformation
    _WinAPI_SetKeyboardLayout
    _WinAPI_SetKeyboardState
    _WinAPI_SetLayeredWindowAttributes
    _WinAPI_SetLibraryColorMode
   *_WinAPI_SetParent
    _WinAPI_SetPixel
    _WinAPI_SetROP2
    _WinAPI_SetStretchBltMode
    _WinAPI_SetSystemCursor
    _WinAPI_SetThemeAppProperties
    _WinAPI_SetTimer
    _WinAPI_SetVolumeMountPoint
    _WinAPI_ShareFolderDlg
    _WinAPI_ShellExtractIcons
    _WinAPI_ShellGetFileInfo
    _WinAPI_ShellGetSpecialFolderPath
    _WinAPI_ShellNotifyIcon
    _WinAPI_ShowLastError
    _WinAPI_ShowOwnedPopups
    _WinAPI_SizeofResource
    _WinAPI_StretchBlt
    _WinAPI_StructToArray
    _WinAPI_SubtractRect
    _WinAPI_SwitchColor
  **_WinAPI_SwitchToThisWindow
    _WinAPI_TransparentBlt
    _WinAPI_TextOut
    _WinAPI_UnionRect
    _WinAPI_ValidateRect
    _WinAPI_ValidateRgn
    _WinAPI_WindowFromDC
    _WinAPI_WinHelp

   * Available in native AutoIt library
  ** Deprecated

#ce

#Include-once

#Include <StructureConstants.au3>
#Include <WinAPI.au3>

#EndRegion Header

#Region Global Variables and Constants

; ===============================================================================================================================
; _WinAPI_AnimateWindow()
; ===============================================================================================================================

Global Const $AW_SLIDE = 0x00040000
Global Const $AW_ACTIVATE = 0x00020000
Global Const $AW_BLEND = 0x00080000
Global Const $AW_HIDE = 0x00010000
Global Const $AW_CENTER = 0x00000010
Global Const $AW_HOR_POSITIVE = 0x00000001
Global Const $AW_HOR_NEGATIVE = 0x00000002
Global Const $AW_VER_POSITIVE = 0x00000004
Global Const $AW_VER_NEGATIVE = 0x00000008

; ===============================================================================================================================
; _WinAPI_AssocQueryString()
; ===============================================================================================================================

Global Const $ASSOCSTR_COMMAND = 1
Global Const $ASSOCSTR_EXECUTABLE = 2
Global Const $ASSOCSTR_FRIENDLYDOCNAME = 3
Global Const $ASSOCSTR_FRIENDLYAPPNAME = 4
Global Const $ASSOCSTR_NOOPEN = 5
Global Const $ASSOCSTR_SHELLNEWVALUE = 6
Global Const $ASSOCSTR_DDECOMMAND = 7
Global Const $ASSOCSTR_DDEIFEXEC = 8
Global Const $ASSOCSTR_DDEAPPLICATION = 9
Global Const $ASSOCSTR_DDETOPIC = 10
Global Const $ASSOCSTR_INFOTIP = 11
Global Const $ASSOCSTR_QUICKTIP = 12
Global Const $ASSOCSTR_TILEINFO = 13
Global Const $ASSOCSTR_CONTENTTYPE = 14
Global Const $ASSOCSTR_DEFAULTICON = 15
Global Const $ASSOCSTR_SHELLEXTENSION = 16

Global Const $ASSOCF_INIT_NOREMAPCLSID = 0x00000001
Global Const $ASSOCF_INIT_BYEXENAME = 0x00000002
Global Const $ASSOCF_OPEN_BYEXENAME = 0x00000002
Global Const $ASSOCF_INIT_DEFAULTTOSTAR = 0x00000004
Global Const $ASSOCF_INIT_DEFAULTTOFOLDER = 0x00000008
Global Const $ASSOCF_NOUSERSETTINGS = 0x00000010
Global Const $ASSOCF_NOTRUNCATE = 0x00000020
Global Const $ASSOCF_VERIFY = 0x00000040
Global Const $ASSOCF_REMAPRUNDLL = 0x00000080
Global Const $ASSOCF_NOFIXUPS = 0x00000100
Global Const $ASSOCF_IGNOREBASECLASS = 0x00000200
Global Const $ASSOCF_INIT_IGNOREUNKNOWN = 0x00000400

; ===============================================================================================================================
; _WinAPI_ChildWindowFromPointEx()
; ===============================================================================================================================

Global Const $CWP_ALL = 0x00
Global Const $CWP_SKIPINVISIBLE = 0x01
Global Const $CWP_SKIPDISABLED = 0x02
Global Const $CWP_SKIPTRANSPARENT = 0x04

; ===============================================================================================================================
; _WinAPI_CreateDIBSection()
; ===============================================================================================================================

Global Const $BI_RGB = 0
Global Const $BI_RLE8 = 1
Global Const $BI_RLE4 = 2
Global Const $BI_BITFIELDS = 3
Global Const $BI_JPEG = 4
Global Const $BI_PNG = 5

; ===============================================================================================================================
; _WinAPI_CopyFileEx()
; ===============================================================================================================================

Global Const $COPY_FILE_ALLOW_DECRYPTED_DESTINATION = 0x00000008
Global Const $COPY_FILE_COPY_SYMLINK = 0x00000800
Global Const $COPY_FILE_FAIL_IF_EXISTS = 0x00000001
Global Const $COPY_FILE_OPEN_SOURCE_FOR_WRITE = 0x00000004
Global Const $COPY_FILE_RESTARTABLE = 0x00000002

Global Const $PROGRESS_CONTINUE = 0
Global Const $PROGRESS_CANCEL = 1
Global Const $PROGRESS_STOP = 2
Global Const $PROGRESS_QUIET = 3

; ===============================================================================================================================
; _WinAPI_CopyImage()
; ===============================================================================================================================

#cs

Global Const $LR_DEFAULTCOLOR = 0x0000
Global Const $LR_DEFAULTSIZE = 0x0040
Global Const $LR_COLOR = 0x0002
Global Const $LR_COPYDELETEORG = 0x0008
Global Const $LR_COPYFROMRESOURCE = 0x4000
Global Const $LR_COPYRETURNORG = 0x0004
Global Const $LR_CREATEDIBSECTION = 0x2000
Global Const $LR_LOADFROMFILE = 0x0010
Global Const $LR_LOADMAP3DCOLORS = 0x1000
Global Const $LR_LOADTRANSPARENT = 0x0020
Global Const $LR_MONOCHROME = 0x0001
Global Const $LR_SHARED = 0x8000
Global Const $LR_VGACOLOR = 0x0080

#ce

; ===============================================================================================================================
; _WinAPI_CreateBrushIndirect()
; ===============================================================================================================================

Global Const $BS_DIBPATTERN = 5
Global Const $BS_DIBPATTERN8X8 = 8
Global Const $BS_DIBPATTERNPT = 6
Global Const $BS_HATCHED = 2
Global Const $BS_HOLLOW = 1
Global Const $BS_NULL = 1
Global Const $BS_PATTERN = 3
Global Const $BS_PATTERN8X8 = 7
Global Const $BS_SOLID = 0

Global Const $DIB_PAL_COLORS = 1
Global Const $DIB_RGB_COLORS = 0

Global Const $HS_BDIAGONAL = 3
Global Const $HS_CROSS = 4
Global Const $HS_DIAGCROSS = 5
Global Const $HS_FDIAGONAL = 2
Global Const $HS_HORIZONTAL = 0
Global Const $HS_VERTICAL = 1

; ===============================================================================================================================
; _WinAPI_CreateFileEx()
; ===============================================================================================================================

#cs

Global Const $CREATE_NEW = 1
Global Const $CREATE_ALWAYS = 2
Global Const $OPEN_EXISTING = 3
Global Const $OPEN_ALWAYS = 4
Global Const $TRUNCATE_EXISTING = 5

Global Const $GENERIC_ALL = 0x10000000
Global Const $GENERIC_EXECUTE = 0x20000000
Global Const $GENERIC_WRITE = 0x40000000
Global Const $GENERIC_READ = 0x80000000

Global Const $FILE_SHARE_READ = 0x01
Global Const $FILE_SHARE_WRITE = 0x02
Global Const $FILE_SHARE_DELETE = 0x04

Global Const $FILE_ATTRIBUTE_READONLY = 0x00000001
Global Const $FILE_ATTRIBUTE_HIDDEN = 0x00000002
Global Const $FILE_ATTRIBUTE_SYSTEM = 0x00000004
Global Const $FILE_ATTRIBUTE_DIRECTORY = 0x00000010
Global Const $FILE_ATTRIBUTE_ARCHIVE = 0x00000020
Global Const $FILE_ATTRIBUTE_DEVICE = 0x00000040
Global Const $FILE_ATTRIBUTE_NORMAL = 0x00000080
Global Const $FILE_ATTRIBUTE_TEMPORARY = 0x00000100
Global Const $FILE_ATTRIBUTE_SPARSE_FILE = 0x00000200
Global Const $FILE_ATTRIBUTE_REPARSE_POINT = 0x00000400
Global Const $FILE_ATTRIBUTE_COMPRESSED = 0x00000800
Global Const $FILE_ATTRIBUTE_OFFLINE = 0x00001000
Global Const $FILE_ATTRIBUTE_NOT_CONTENT_INDEXED = 0x00002000
Global Const $FILE_ATTRIBUTE_ENCRYPTED = 0x00004000

#ce

Global Const $FILE_FLAG_BACKUP_SEMANTICS = 0x02000000
Global Const $FILE_FLAG_DELETE_ON_CLOSE = 0x04000000
Global Const $FILE_FLAG_NO_BUFFERING = 0x20000000
Global Const $FILE_FLAG_OPEN_NO_RECALL = 0x00100000
Global Const $FILE_FLAG_OPEN_REPARSE_POINT = 0x00200000
Global Const $FILE_FLAG_OVERLAPPED = 0x40000000
Global Const $FILE_FLAG_POSIX_SEMANTICS = 0x0100000
Global Const $FILE_FLAG_RANDOM_ACCESS = 0x10000000
Global Const $FILE_FLAG_SEQUENTIAL_SCAN = 0x08000000
Global Const $FILE_FLAG_WRITE_THROUGH = 0x80000000

Global Const $SECURITY_ANONYMOUS = 0x00000000
Global Const $SECURITY_IDENTIFICATION = 0x00010000
Global Const $SECURITY_IMPERSONATION = 0x00020000
Global Const $SECURITY_DELEGATION = 0x00030000
Global Const $SECURITY_CONTEXT_TRACKING = 0x00040000
Global Const $SECURITY_EFFECTIVE_ONLY = 0x00080000

; ===============================================================================================================================
; _WinAPI_CreatePolygonRgn()
; ===============================================================================================================================

Global Const $ALTERNATE = 1
Global Const $WINDING = 2

; ===============================================================================================================================
; _WinAPI_DefineDosDevice()
; ===============================================================================================================================

Global Const $DDD_EXACT_MATCH_ON_REMOVE = 0x04
Global Const $DDD_NO_BROADCAST_SYSTEM = 0x08
Global Const $DDD_RAW_TARGET_PATH = 0x01
Global Const $DDD_REMOVE_DEFINITION = 0x02

; ===============================================================================================================================
; _WinAPI_DrawShadowText()
; ===============================================================================================================================

#cs

Global Const $DT_BOTTOM = 0x00000008
Global Const $DT_CALCRECT = 0x00000400
Global Const $DT_CENTER = 0x00000001
Global Const $DT_EDITCONTROL = 0x00002000
Global Const $DT_END_ELLIPSIS = 0x00008000
Global Const $DT_EXPANDTABS = 0x00000040
Global Const $DT_EXTERNALLEADING = 0x00000200
Global Const $DT_HIDEPREFIX = 0x00100000
Global Const $DT_INTERNAL = 0x00001000
Global Const $DT_LEFT = 0x00000000
Global Const $DT_MODIFYSTRING = 0x00010000
Global Const $DT_NOCLIP = 0x00000100
Global Const $DT_NOFULLWIDTHCHARBREAK = 0x00080000
Global Const $DT_NOPREFIX = 0x00000800
Global Const $DT_PATH_ELLIPSIS = 0x00004000
Global Const $DT_PREFIXONLY = 0x00200000
Global Const $DT_RIGHT = 0x00000002
Global Const $DT_RTLREADING = 0x00020000
Global Const $DT_SINGLELINE = 0x00000020
Global Const $DT_TABSTOP = 0x00000080
Global Const $DT_TOP = 0x00000000
Global Const $DT_VCENTER = 0x00000004
Global Const $DT_WORDBREAK = 0x00000010
Global Const $DT_WORD_ELLIPSIS = 0x00040000

#ce

; ===============================================================================================================================
; _WinAPI_EnumDisplaySettings()
; ===============================================================================================================================

Global Const $ENUM_CURRENT_SETTINGS = -1
Global Const $ENUM_REGISTRY_SETTINGS = -2

Global Const $DM_GRAYSCALE = 0x01
Global Const $DM_INTERLACED = 0x02

; ===============================================================================================================================
; _WinAPI_ExtSelectClipRgn()
; ===============================================================================================================================

#cs

Global Const $RGN_AND = 1
Global Const $RGN_OR = 2
Global Const $RGN_XOR = 3
Global Const $RGN_DIFF = 4
Global Const $RGN_COPY = 5 

#ce

; ===============================================================================================================================
; _WinAPI_FormatDriveDlg()
; ===============================================================================================================================

Global Const $SHFMT_ID_DEFAULT = 0xFFFF

Global Const $SHFMT_OPT_FULL = 0x00
Global Const $SHFMT_OPT_QUICKFORMAT = 0x01
Global Const $SHFMT_OPT_SYSONLY = 0x02

Global Const $SHFMT_ERROR = -1
Global Const $SHFMT_CANCEL = -2
Global Const $SHFMT_NOFORMAT = -3

; ===============================================================================================================================
; _WinAPI_GetClassLong(), _WinAPI_SetClassLong()
; ===============================================================================================================================

Global Const $GCL_CBCLSEXTRA = -20
Global Const $GCL_CBWNDEXTRA = -18
Global Const $GCL_HBRBACKGROUND = -10
Global Const $GCL_HCURSOR = -12
Global Const $GCL_HICON = -14
Global Const $GCL_HICONSM = -34
Global Const $GCL_HMODULE = -16
Global Const $GCL_MENUNAME = -8
Global Const $GCL_STYLE = -26
Global Const $GCL_WNDPROC = -24

; ===============================================================================================================================
; _WinAPI_GetCompression(), _WinAPI_SetCompression()
; ===============================================================================================================================

Global Const $COMPRESSION_FORMAT_NONE = 0
Global Const $COMPRESSION_FORMAT_DEFAULT = 1
Global Const $COMPRESSION_FORMAT_LZNT1 = 2

; ===============================================================================================================================
; _WinAPI_GetDriveBusType()
; ===============================================================================================================================

Global Const $DRIVE_BUS_TYPE_UNKNOWN = 0x00
Global Const $DRIVE_BUS_TYPE_SCSI = 0x01
Global Const $DRIVE_BUS_TYPE_ATAPI = 0x02
Global Const $DRIVE_BUS_TYPE_ATA = 0x03
Global Const $DRIVE_BUS_TYPE_1394 = 0x04
Global Const $DRIVE_BUS_TYPE_SSA = 0x05
Global Const $DRIVE_BUS_TYPE_FIBRE = 0x06
Global Const $DRIVE_BUS_TYPE_USB = 0x07
Global Const $DRIVE_BUS_TYPE_RAID = 0x08
Global Const $DRIVE_BUS_TYPE_ISCSI = 0x09
Global Const $DRIVE_BUS_TYPE_SAS = 0x0A
Global Const $DRIVE_BUS_TYPE_SATA = 0x0B
Global Const $DRIVE_BUS_TYPE_SD = 0x0C
Global Const $DRIVE_BUS_TYPE_MMC = 0x0D

; ===============================================================================================================================
; _WinAPI_GetDriveNumber()
; ===============================================================================================================================

Global Const $FILE_DEVICE_8042_PORT = 0x27
Global Const $FILE_DEVICE_ACPI = 0x32
Global Const $FILE_DEVICE_BATTERY = 0x29
Global Const $FILE_DEVICE_BEEP = 0x01
Global Const $FILE_DEVICE_BUS_EXTENDER = 0x2A
Global Const $FILE_DEVICE_CD_ROM = 0x02
Global Const $FILE_DEVICE_CD_ROM_FILE_SYSTEM = 0x03
Global Const $FILE_DEVICE_CHANGER = 0x30
Global Const $FILE_DEVICE_CONTROLLER = 0x04
Global Const $FILE_DEVICE_DATALINK = 0x05
Global Const $FILE_DEVICE_DFS = 0x06
Global Const $FILE_DEVICE_DFS_FILE_SYSTEM = 0x35
Global Const $FILE_DEVICE_DFS_VOLUME = 0x36
Global Const $FILE_DEVICE_DISK = 0x07
Global Const $FILE_DEVICE_DISK_FILE_SYSTEM = 0x08
Global Const $FILE_DEVICE_DVD = 0x33
Global Const $FILE_DEVICE_FILE_SYSTEM = 0x09
Global Const $FILE_DEVICE_FIPS = 0x3A
Global Const $FILE_DEVICE_FULLSCREEN_VIDEO = 0x34
Global Const $FILE_DEVICE_INPORT_PORT = 0x0A
Global Const $FILE_DEVICE_KEYBOARD = 0x0B
Global Const $FILE_DEVICE_KS = 0x2F
Global Const $FILE_DEVICE_KSEC = 0x39
Global Const $FILE_DEVICE_MAILSLOT = 0x0C
Global Const $FILE_DEVICE_MASS_STORAGE = 0x2D
Global Const $FILE_DEVICE_MIDI_IN = 0x0D
Global Const $FILE_DEVICE_MIDI_OUT = 0x0E
Global Const $FILE_DEVICE_MODEM = 0x2B
Global Const $FILE_DEVICE_MOUSE = 0x0F
Global Const $FILE_DEVICE_MULTI_UNC_PROVIDER = 0x10
Global Const $FILE_DEVICE_NAMED_PIPE = 0x11
Global Const $FILE_DEVICE_NETWORK = 0x12
Global Const $FILE_DEVICE_NETWORK_BROWSER = 0x13
Global Const $FILE_DEVICE_NETWORK_FILE_SYSTEM = 0x14
Global Const $FILE_DEVICE_NETWORK_REDIRECTOR = 0x28
Global Const $FILE_DEVICE_NULL = 0x15
Global Const $FILE_DEVICE_PARALLEL_PORT = 0x16
Global Const $FILE_DEVICE_PHYSICAL_NETCARD = 0x17
Global Const $FILE_DEVICE_PRINTER = 0x18
Global Const $FILE_DEVICE_SCANNER = 0x19
Global Const $FILE_DEVICE_SCREEN = 0x1C
Global Const $FILE_DEVICE_SERENUM = 0x37
Global Const $FILE_DEVICE_SERIAL_MOUSE_PORT = 0x1A
Global Const $FILE_DEVICE_SERIAL_PORT = 0x1B
Global Const $FILE_DEVICE_SMARTCARD = 0x31
Global Const $FILE_DEVICE_SMB = 0x2E
Global Const $FILE_DEVICE_SOUND = 0x1D
Global Const $FILE_DEVICE_STREAMS = 0x1E
Global Const $FILE_DEVICE_TAPE = 0x1F
Global Const $FILE_DEVICE_TAPE_FILE_SYSTEM = 0x20
Global Const $FILE_DEVICE_TERMSRV = 0x38
Global Const $FILE_DEVICE_TRANSPORT = 0x21
Global Const $FILE_DEVICE_UNKNOWN = 0x22
Global Const $FILE_DEVICE_VDM = 0x2C
Global Const $FILE_DEVICE_VIDEO = 0x23
Global Const $FILE_DEVICE_VIRTUAL_DISK = 0x24
Global Const $FILE_DEVICE_WAVE_IN = 0x25
Global Const $FILE_DEVICE_WAVE_OUT = 0x26

; ===============================================================================================================================
; _WinAPI_GetDriveType()
; ===============================================================================================================================

Global Const $DRIVE_UNKNOWN = 0
Global Const $DRIVE_NO_ROOT_DIR = 1
Global Const $DRIVE_REMOVABLE = 2
Global Const $DRIVE_FIXED = 3
Global Const $DRIVE_REMOTE = 4
Global Const $DRIVE_CDROM = 5
Global Const $DRIVE_RAMDISK = 6

; ===============================================================================================================================
; _WinAPI_FindResource(), _WinAPI_FindResourceEx()
; ===============================================================================================================================

Global Const $RT_ACCELERATOR = 9
Global Const $RT_ANICURSOR = 21
Global Const $RT_ANIICON = 22
Global Const $RT_BITMAP = 2
Global Const $RT_CURSOR = 1
Global Const $RT_DIALOG = 5
Global Const $RT_DLGINCLUDE = 17
Global Const $RT_FONT = 8
Global Const $RT_FONTDIR = 7
Global Const $RT_GROUP_CURSOR = 12
Global Const $RT_GROUP_ICON = 14
Global Const $RT_HTML = 23
Global Const $RT_ICON = 3
Global Const $RT_MANIFEST = 24
Global Const $RT_MENU = 4
Global Const $RT_MESSAGETABLE = 11
Global Const $RT_PLUGPLAY = 19
Global Const $RT_RCDATA = 10
Global Const $RT_STRING = 6
Global Const $RT_VERSION = 16
Global Const $RT_VXD = 20

; ===============================================================================================================================
; _WinAPI_FitToBitmap(), _WinAPI_SetStretchBltMode()
; ===============================================================================================================================

Global Const $BLACKONWHITE = 1
Global Const $COLORONCOLOR = 3
Global Const $HALFTONE = 4
Global Const $WHITEONBLACK = 2
Global Const $STRETCH_ANDSCANS = $BLACKONWHITE
Global Const $STRETCH_DELETESCANS = $COLORONCOLOR
Global Const $STRETCH_HALFTONE = $HALFTONE
Global Const $STRETCH_ORSCANS = $WHITEONBLACK

; ===============================================================================================================================
; _WinAPI_GetHandleInformation(), _WinAPI_SetHandleInformation()
; ===============================================================================================================================

Global Const $HANDLE_FLAG_INHERIT = 0x00000001
Global Const $HANDLE_FLAG_PROTECT_FROM_CLOSE = 0x00000002

; ===============================================================================================================================
; _WinAPI_GetLayeredWindowAttributes(), _WinAPI_SetLayeredWindowAttributes()
; ===============================================================================================================================

Global Const $LWA_COLORKEY = 0x01
Global Const $LWA_ALPHA = 0x02

; ===============================================================================================================================
; _WinAPI_GetLocaleInfo()
; ===============================================================================================================================

Global Const $LOCALE_ILANGUAGE              = 0x00000001 ; Language ID
Global Const $LOCALE_SLANGUAGE              = 0x00000002 ; Localized name of language
Global Const $LOCALE_SENGLANGUAGE           = 0x00001001 ; English name of language
Global Const $LOCALE_SABBREVLANGNAME        = 0x00000003 ; Abbreviated language name
Global Const $LOCALE_SNATIVELANGNAME        = 0x00000004 ; Native name of language

Global Const $LOCALE_ICOUNTRY               = 0x00000005 ; Country code
Global Const $LOCALE_SCOUNTRY               = 0x00000006 ; Localized name of country
Global Const $LOCALE_SENGCOUNTRY            = 0x00001002 ; English name of country
Global Const $LOCALE_SABBREVCTRYNAME        = 0x00000007 ; Abbreviated country name
Global Const $LOCALE_SNATIVECTRYNAME        = 0x00000008 ; Native name of country

Global Const $LOCALE_IDEFAULTLANGUAGE       = 0x00000009 ; Default language id
Global Const $LOCALE_IDEFAULTCOUNTRY        = 0x0000000A ; Default country code
Global Const $LOCALE_IDEFAULTCODEPAGE       = 0x0000000B ; Default oem code page
Global Const $LOCALE_IDEFAULTANSICODEPAGE   = 0x00001004 ; Default ansi code page
Global Const $LOCALE_IDEFAULTMACCODEPAGE    = 0x00001011 ; Default mac code page

Global Const $LOCALE_SLIST                  = 0x0000000C ; List item separator
Global Const $LOCALE_IMEASURE               = 0x0000000D ; 0 = Metric, 1 = US

Global Const $LOCALE_SDECIMAL               = 0x0000000E ; Decimal separator
Global Const $LOCALE_STHOUSAND              = 0x0000000F ; Thousand separator
Global Const $LOCALE_SGROUPING              = 0x00000010 ; Digit grouping
Global Const $LOCALE_IDIGITS                = 0x00000011 ; Number of fractional digits
Global Const $LOCALE_ILZERO                 = 0x00000012 ; Leading zeros for decimal
Global Const $LOCALE_INEGNUMBER             = 0x00001010 ; Negative number mode
Global Const $LOCALE_SNATIVEDIGITS          = 0x00000013 ; Native ASCII 0-9

Global Const $LOCALE_SCURRENCY              = 0x00000014 ; Local monetary symbol
Global Const $LOCALE_SINTLSYMBOL            = 0x00000015 ; Intl monetary symbol
Global Const $LOCALE_SMONDECIMALSEP         = 0x00000016 ; Monetary decimal separator
Global Const $LOCALE_SMONTHOUSANDSEP        = 0x00000017 ; Monetary thousand separator
Global Const $LOCALE_SMONGROUPING           = 0x00000018 ; Monetary grouping
Global Const $LOCALE_ICURRDIGITS            = 0x00000019 ; # local monetary digits
Global Const $LOCALE_IINTLCURRDIGITS        = 0x0000001A ; # intl monetary digits
Global Const $LOCALE_ICURRENCY              = 0x0000001B ; Positive currency mode
Global Const $LOCALE_INEGCURR               = 0x0000001C ; Negative currency mode

Global Const $LOCALE_SDATE                  = 0x0000001D ; Date separator
Global Const $LOCALE_STIME                  = 0x0000001E ; Time separator
Global Const $LOCALE_SSHORTDATE             = 0x0000001F ; Short date format string
Global Const $LOCALE_SLONGDATE              = 0x00000020 ; Long date format string
Global Const $LOCALE_STIMEFORMAT            = 0x00001003 ; Time format string
Global Const $LOCALE_IDATE                  = 0x00000021 ; Short date format ordering
Global Const $LOCALE_ILDATE                 = 0x00000022 ; Long date format ordering
Global Const $LOCALE_ITIME                  = 0x00000023 ; Time format specifier
Global Const $LOCALE_ITIMEMARKPOSN          = 0x00001005 ; Time marker position
Global Const $LOCALE_ICENTURY               = 0x00000024 ; Century format specifier (short date)
Global Const $LOCALE_ITLZERO                = 0x00000025 ; Leading zeros in time field
Global Const $LOCALE_IDAYLZERO              = 0x00000026 ; Leading zeros in day field (short date)
Global Const $LOCALE_IMONLZERO              = 0x00000027 ; Leading zeros in month field (short date)
Global Const $LOCALE_S1159                  = 0x00000028 ; AM designator
Global Const $LOCALE_S2359                  = 0x00000029 ; PM designator

Global Const $LOCALE_ICALENDARTYPE          = 0x00001009 ; Type of calendar specifier
Global Const $LOCALE_IOPTIONALCALENDAR      = 0x0000100B ; Additional calendar types specifier
Global Const $LOCALE_IFIRSTDAYOFWEEK        = 0x0000100C ; First day of week specifier
Global Const $LOCALE_IFIRSTWEEKOFYEAR       = 0x0000100D ; First week of year specifier

Global Const $LOCALE_SDAYNAME1              = 0x0000002A ; Long name for Monday
Global Const $LOCALE_SDAYNAME2              = 0x0000002B ; Long name for Tuesday
Global Const $LOCALE_SDAYNAME3              = 0x0000002C ; Long name for Wednesday
Global Const $LOCALE_SDAYNAME4              = 0x0000002D ; Long name for Thursday
Global Const $LOCALE_SDAYNAME5              = 0x0000002E ; Long name for Friday
Global Const $LOCALE_SDAYNAME6              = 0x0000002F ; Long name for Saturday
Global Const $LOCALE_SDAYNAME7              = 0x00000030 ; Long name for Sunday
Global Const $LOCALE_SABBREVDAYNAME1        = 0x00000031 ; Abbreviated name for Monday
Global Const $LOCALE_SABBREVDAYNAME2        = 0x00000032 ; Abbreviated name for Tuesday
Global Const $LOCALE_SABBREVDAYNAME3        = 0x00000033 ; Abbreviated name for Wednesday
Global Const $LOCALE_SABBREVDAYNAME4        = 0x00000034 ; Abbreviated name for Thursday
Global Const $LOCALE_SABBREVDAYNAME5        = 0x00000035 ; Abbreviated name for Friday
Global Const $LOCALE_SABBREVDAYNAME6        = 0x00000036 ; Abbreviated name for Saturday
Global Const $LOCALE_SABBREVDAYNAME7        = 0x00000037 ; Abbreviated name for Sunday
Global Const $LOCALE_SMONTHNAME1            = 0x00000038 ; Long name for January
Global Const $LOCALE_SMONTHNAME2            = 0x00000039 ; Long name for February
Global Const $LOCALE_SMONTHNAME3            = 0x0000003A ; Long name for March
Global Const $LOCALE_SMONTHNAME4            = 0x0000003B ; Long name for April
Global Const $LOCALE_SMONTHNAME5            = 0x0000003C ; Long name for May
Global Const $LOCALE_SMONTHNAME6            = 0x0000003D ; Long name for June
Global Const $LOCALE_SMONTHNAME7            = 0x0000003E ; Long name for July
Global Const $LOCALE_SMONTHNAME8            = 0x0000003F ; Long name for August
Global Const $LOCALE_SMONTHNAME9            = 0x00000040 ; Long name for September
Global Const $LOCALE_SMONTHNAME10           = 0x00000041 ; Long name for October
Global Const $LOCALE_SMONTHNAME11           = 0x00000042 ; Long name for November
Global Const $LOCALE_SMONTHNAME12           = 0x00000043 ; Long name for December
Global Const $LOCALE_SMONTHNAME13           = 0x0000100E ; long name for 13th month (if exists)
Global Const $LOCALE_SABBREVMONTHNAME1      = 0x00000044 ; Abbreviated name for January
Global Const $LOCALE_SABBREVMONTHNAME2      = 0x00000045 ; Abbreviated name for February
Global Const $LOCALE_SABBREVMONTHNAME3      = 0x00000046 ; Abbreviated name for March
Global Const $LOCALE_SABBREVMONTHNAME4      = 0x00000047 ; Abbreviated name for April
Global Const $LOCALE_SABBREVMONTHNAME5      = 0x00000048 ; Abbreviated name for May
Global Const $LOCALE_SABBREVMONTHNAME6      = 0x00000049 ; Abbreviated name for June
Global Const $LOCALE_SABBREVMONTHNAME7      = 0x0000004A ; Abbreviated name for July
Global Const $LOCALE_SABBREVMONTHNAME8      = 0x0000004B ; Abbreviated name for August
Global Const $LOCALE_SABBREVMONTHNAME9      = 0x0000004C ; Abbreviated name for September
Global Const $LOCALE_SABBREVMONTHNAME10     = 0x0000004D ; Abbreviated name for October
Global Const $LOCALE_SABBREVMONTHNAME11     = 0x0000004E ; Abbreviated name for November
Global Const $LOCALE_SABBREVMONTHNAME12     = 0x0000004F ; Abbreviated name for December
Global Const $LOCALE_SABBREVMONTHNAME13     = 0x0000100F ; Abbreviated name for 13th month (if exists)

Global Const $LOCALE_SPOSITIVESIGN          = 0x00000050 ; Positive sign
Global Const $LOCALE_SNEGATIVESIGN          = 0x00000051 ; Negative sign
Global Const $LOCALE_IPOSSIGNPOSN           = 0x00000052 ; Positive sign position
Global Const $LOCALE_INEGSIGNPOSN           = 0x00000053 ; Negative sign position
Global Const $LOCALE_IPOSSYMPRECEDES        = 0x00000054 ; Mon sym precedes pos amt
Global Const $LOCALE_IPOSSEPBYSPACE         = 0x00000055 ; Mon sym sep by space from pos amt
Global Const $LOCALE_INEGSYMPRECEDES        = 0x00000056 ; Mon sym precedes neg amt
Global Const $LOCALE_INEGSEPBYSPACE         = 0x00000057 ; Mon sym sep by space from neg amt

Global Const $LOCALE_FONTSIGNATURE          = 0x00000058 ; Font signature
Global Const $LOCALE_SISO639LANGNAME        = 0x00000059 ; ISO abbreviated language name
Global Const $LOCALE_SISO3166CTRYNAME       = 0x0000005A ; ISO abbreviated country name

Global Const $LOCALE_IDEFAULTEBCDICCODEPAGE = 0x00001012 ; Default ebcdic code page
Global Const $LOCALE_IPAPERSIZE             = 0x0000100A ; 0 = Letter, 1 = A4, 2 = Legal, 3 = A3
Global Const $LOCALE_SENGCURRNAME           = 0x00001007 ; English name of currency
Global Const $LOCALE_SNATIVECURRNAME        = 0x00001008 ; Native name of currency
Global Const $LOCALE_SYEARMONTH             = 0x00001006 ; Year month format string
Global Const $LOCALE_SSORTNAME              = 0x00001013 ; Sort name
Global Const $LOCALE_IDIGITSUBSTITUTION     = 0x00001014 ; 0 = None, 1 = Context, 2 = Native digit

; ===============================================================================================================================
; _WinAPI_GetObjectType()
; ===============================================================================================================================

Global Const $OBJ_BITMAP = 7
Global Const $OBJ_BRUSH = 2
Global Const $OBJ_COLORSPACE = 14
Global Const $OBJ_DC = 3
Global Const $OBJ_ENHMETADC = 12
Global Const $OBJ_ENHMETAFILE = 13
Global Const $OBJ_EXTPEN = 11
Global Const $OBJ_FONT = 6
Global Const $OBJ_MEMDC = 10
Global Const $OBJ_METADC = 4
Global Const $OBJ_METAFILE = 9
Global Const $OBJ_PAL = 5
Global Const $OBJ_PEN = 1
Global Const $OBJ_REGION = 8

; ===============================================================================================================================
; _WinAPI_GetROP2(), _WinAPI_SetROP2()
; ===============================================================================================================================

Global Const $R2_BLACK = 1
Global Const $R2_COPYPEN = 13
Global Const $R2_LAST = 16
Global Const $R2_MASKNOTPEN = 3
Global Const $R2_MASKPEN = 9
Global Const $R2_MASKPENNOT = 5
Global Const $R2_MERGENOTPEN = 12
Global Const $R2_MERGEPEN = 15
Global Const $R2_MERGEPENNOT = 14
Global Const $R2_NOP = 11
Global Const $R2_NOT = 6
Global Const $R2_NOTCOPYPEN = 4
Global Const $R2_NOTMASKPEN = 8
Global Const $R2_NOTMERGEPEN = 2
Global Const $R2_NOTXORPEN = 10
Global Const $R2_WHITE = 16
Global Const $R2_XORPEN = 7

; ===============================================================================================================================
; _WinAPI_GetTextMetrics()
; ===============================================================================================================================

Global Const $TMPF_FIXED_PITCH = 0x01
Global Const $TMPF_VECTOR = 0x02
Global Const $TMPF_TRUETYPE = 0x04
Global Const $TMPF_DEVICE = 0x08

; ===============================================================================================================================
; _WinAPI_GetThemeAppProperties(), _WinAPI_SetThemeAppProperties()
; ===============================================================================================================================

Global Const $STAP_ALLOW_NONCLIENT = 0x01
Global Const $STAP_ALLOW_CONTROLS = 0x02
Global Const $STAP_ALLOW_WEBCONTENT = 0x04

; ===============================================================================================================================
; _WinAPI_GetVersionEx()
; ===============================================================================================================================

Global Const $VER_SUITE_BACKOFFICE = 0x00000004
Global Const $VER_SUITE_BLADE = 0x00000400
Global Const $VER_SUITE_COMPUTE_SERVER = 0x00004000
Global Const $VER_SUITE_DATACENTER = 0x00000080
Global Const $VER_SUITE_ENTERPRISE = 0x00000002
Global Const $VER_SUITE_EMBEDDEDNT = 0x00000040
Global Const $VER_SUITE_PERSONAL = 0x00000200
Global Const $VER_SUITE_SINGLEUSERTS = 0x00000100
Global Const $VER_SUITE_SMALLBUSINESS = 0x00000001
Global Const $VER_SUITE_SMALLBUSINESS_RESTRICTED = 0x00000020
Global Const $VER_SUITE_STORAGE_SERVER = 0x00002000
Global Const $VER_SUITE_TERMINAL = 0x00000010
Global Const $VER_SUITE_WH_SERVER = 0x00008000

Global Const $VER_NT_DOMAIN_CONTROLLER = 0x0000002
Global Const $VER_NT_SERVER = 0x0000003
Global Const $VER_NT_WORKSTATION = 0x0000001

; ===============================================================================================================================
; _WinAPI_IsNetworkAlive()
; ===============================================================================================================================

Global Const $NETWORK_ALIVE_LAN = 0x01
Global Const $NETWORK_ALIVE_WAN = 0x02
Global Const $NETWORK_ALIVE_AOL = 0x04

; ===============================================================================================================================
; _WinAPI_Keybd_Event()
; ===============================================================================================================================

Global Const $KEYEVENTF_EXTENDEDKEY = 0x01
Global Const $KEYEVENTF_KEYUP = 0x02

; ===============================================================================================================================
; _WinAPI_Keybd_Event() and similar
; ===============================================================================================================================

#cs

Global Const $VK_LBUTTON = 0x01
Global Const $VK_RBUTTON = 0x02
Global Const $VK_CANCEL = 0x03
Global Const $VK_MBUTTON = 0x04
Global Const $VK_XBUTTON1 = 0x05
Global Const $VK_XBUTTON2 = 0x06
Global Const $VK_BACK = 0x08
Global Const $VK_TAB = 0x09
Global Const $VK_SHIFT = 0x10
Global Const $VK_CLEAR = 0x0C
Global Const $VK_RETURN = 0x0D
Global Const $VK_CONTROL = 0x11
Global Const $VK_MENU = 0x12
Global Const $VK_PAUSE = 0x13
Global Const $VK_CAPITAL = 0x14
Global Const $VK_ESCAPE = 0x1B
Global Const $VK_SPACE = 0x20
Global Const $VK_PRIOR = 0x21
Global Const $VK_NEXT = 0x22
Global Const $VK_END = 0x23
Global Const $VK_HOME = 0x24
Global Const $VK_LEFT = 0x25
Global Const $VK_UP = 0x26
Global Const $VK_RIGHT = 0x27
Global Const $VK_DOWN = 0x28
Global Const $VK_SELECT = 0x29
Global Const $VK_PRINT = 0x2A
Global Const $VK_EXECUTE = 0x2B
Global Const $VK_SNAPSHOT = 0x2C
Global Const $VK_INSERT = 0x2D
Global Const $VK_DELETE = 0x2E
Global Const $VK_HELP = 0x2F
Global Const $VK_0 = 0x30
Global Const $VK_1 = 0x31
Global Const $VK_2 = 0x32
Global Const $VK_3 = 0x33
Global Const $VK_4 = 0x34
Global Const $VK_5 = 0x35
Global Const $VK_6 = 0x36
Global Const $VK_7 = 0x37
Global Const $VK_8 = 0x38
Global Const $VK_9 = 0x39
Global Const $VK_A = 0x41
Global Const $VK_B = 0x42
Global Const $VK_C = 0x43
Global Const $VK_D = 0x44
Global Const $VK_E = 0x45
Global Const $VK_F = 0x46
Global Const $VK_G = 0x47
Global Const $VK_H = 0x48
Global Const $VK_I = 0x49
Global Const $VK_J = 0x4A
Global Const $VK_K = 0x4B
Global Const $VK_L = 0x4C
Global Const $VK_M = 0x4D
Global Const $VK_N = 0x4E
Global Const $VK_O = 0x4F
Global Const $VK_P = 0x50
Global Const $VK_Q = 0x51
Global Const $VK_R = 0x52
Global Const $VK_S = 0x53
Global Const $VK_T = 0x54
Global Const $VK_U = 0x55
Global Const $VK_V = 0x56
Global Const $VK_W = 0x57
Global Const $VK_X = 0x58
Global Const $VK_Y = 0x59
Global Const $VK_Z = 0x5A
Global Const $VK_LWIN = 0x5B
Global Const $VK_RWIN = 0x5C
Global Const $VK_APPS = 0x5D
Global Const $VK_SLEEP = 0x5F
Global Const $VK_NUMPAD0 = 0x60
Global Const $VK_NUMPAD1 = 0x61
Global Const $VK_NUMPAD2 = 0x62
Global Const $VK_NUMPAD3 = 0x63
Global Const $VK_NUMPAD4 = 0x64
Global Const $VK_NUMPAD5 = 0x65
Global Const $VK_NUMPAD6 = 0x66
Global Const $VK_NUMPAD7 = 0x67
Global Const $VK_NUMPAD8 = 0x68
Global Const $VK_NUMPAD9 = 0x69
Global Const $VK_MULTIPLY = 0x6A
Global Const $VK_ADD = 0x6B
Global Const $VK_SEPARATOR = 0x6C
Global Const $VK_SUBTRACT = 0x6D
Global Const $VK_DECIMAL = 0x6E
Global Const $VK_DIVIDE = 0x6F
Global Const $VK_F1 = 0x70
Global Const $VK_F2 = 0x71
Global Const $VK_F3 = 0x72
Global Const $VK_F4 = 0x73
Global Const $VK_F5 = 0x74
Global Const $VK_F6 = 0x75
Global Const $VK_F7 = 0x76
Global Const $VK_F8 = 0x77
Global Const $VK_F9 = 0x78
Global Const $VK_F10 = 0x79
Global Const $VK_F11 = 0x7A
Global Const $VK_F12 = 0x7B
Global Const $VK_F13 = 0x7C
Global Const $VK_F14 = 0x7D
Global Const $VK_F15 = 0x7E
Global Const $VK_F16 = 0x7F
Global Const $VK_F17 = 0x80
Global Const $VK_F18 = 0x81
Global Const $VK_F19 = 0x82
Global Const $VK_F20 = 0x83
Global Const $VK_F21 = 0x84
Global Const $VK_F22 = 0x85
Global Const $VK_F23 = 0x86
Global Const $VK_F24 = 0x87
Global Const $VK_NUMLOCK = 0x90
Global Const $VK_SCROLL = 0x91
Global Const $VK_LSHIFT = 0xA0
Global Const $VK_RSHIFT = 0xA1
Global Const $VK_LCONTROL = 0xA2
Global Const $VK_RCONTROL = 0xA3
Global Const $VK_LMENU = 0xA4
Global Const $VK_RMENU = 0xA5
Global Const $VK_BROWSER_BACK = 0xA6
Global Const $VK_BROWSER_FORWARD = 0xA7
Global Const $VK_BROWSER_REFRESH = 0xA8
Global Const $VK_BROWSER_STOP = 0xA9
Global Const $VK_BROWSER_SEARCH = 0xAA
Global Const $VK_BROWSER_FAVORITES = 0xAB
Global Const $VK_BROWSER_HOME = 0xAC
Global Const $VK_VOLUME_MUTE = 0xAD
Global Const $VK_VOLUME_DOWN = 0xAE
Global Const $VK_VOLUME_UP = 0xAF
Global Const $VK_MEDIA_NEXT_TRACK = 0xB0
Global Const $VK_MEDIA_PREV_TRACK = 0xB1
Global Const $VK_MEDIA_STOP = 0xB2
Global Const $VK_MEDIA_PLAY_PAUSE = 0xB3
Global Const $VK_LAUNCH_MAIL = 0xB4
Global Const $VK_LAUNCH_MEDIA_SELECT = 0xB5
Global Const $VK_LAUNCH_APP1 = 0xB6
Global Const $VK_LAUNCH_APP2 = 0xB7
Global Const $VK_OEM_1 = 0xBA ; ';:'
Global Const $VK_OEM_PLUS = 0xBB ; '=+'
Global Const $VK_OEM_COMMA = 0xBC ; ',<'
Global Const $VK_OEM_MINUS = 0xBD ; '-_'
Global Const $VK_OEM_PERIOD = 0xBE ; '.>'
Global Const $VK_OEM_2 = 0xBF ; '/?'
Global Const $VK_OEM_3 = 0xC0 ; '`~'
Global Const $VK_OEM_4 = 0xDB ; '[{'
Global Const $VK_OEM_5 = 0xDC ; '\|'
Global Const $VK_OEM_6 = 0xDD ; ']}'
Global Const $VK_OEM_7 = 0xDE ; ''"'
Global Const $VK_OEM_8 = 0xDF
Global Const $VK_OEM_102 = 0xE2
Global Const $VK_ATTN = 0xF6
Global Const $VK_CRSEL = 0xF7
Global Const $VK_EXSEL = 0xF8
Global Const $VK_EREOF = 0xF9
Global Const $VK_PLAY = 0xFA
Global Const $VK_ZOOM = 0xFB
Global Const $VK_NONAME = 0xFC
Global Const $VK_PA1 = 0xFD
Global Const $VK_OEM_CLEAR = 0xFE

#ce

; ===============================================================================================================================
; _WinAPI_LoadCursor()
; ===============================================================================================================================

#cs

Global Const $IDC_APPSTARTING = 32650
Global Const $IDC_HAND = 32649
Global Const $IDC_ARROW = 32512
Global Const $IDC_CROSS = 32515
Global Const $IDC_IBEAM = 32513
Global Const $IDC_ICON = 32641
Global Const $IDC_NO = 32648
Global Const $IDC_SIZE = 32640
Global Const $IDC_SIZEALL = 32646
Global Const $IDC_SIZENESW = 32643
Global Const $IDC_SIZENS = 32645
Global Const $IDC_SIZENWSE = 32642
Global Const $IDC_SIZEWE = 32644
Global Const $IDC_UPARROW = 32516
Global Const $IDC_WAIT = 32514

#ce

; ===============================================================================================================================
; _WinAPI_MoveFileEx()
; ===============================================================================================================================

Global Const $MOVEFILE_COPY_ALLOWED = 0x02
Global Const $MOVEFILE_CREATE_HARDLINK = 0x10
Global Const $MOVEFILE_DELAY_UNTIL_REBOOT = 0x04
Global Const $MOVEFILE_FAIL_IF_NOT_TRACKABLE = 0x20
Global Const $MOVEFILE_REPLACE_EXISTING = 0x01
Global Const $MOVEFILE_WRITE_THROUGH = 0x08

; ===============================================================================================================================
; _WinAPI_OpenSemaphore()
; ===============================================================================================================================

Global Const $SEMAPHORE_ALL_ACCESS = 0x001F0003
Global Const $SEMAPHORE_MODIFY_STATE = 0x00000002

; ===============================================================================================================================
; _WinAPI_RegisterShellHookWindow
; ===============================================================================================================================

Global Const $HSHELL_WINDOWCREATED = 1
Global Const $HSHELL_WINDOWDESTROYED = 2
Global Const $HSHELL_ACTIVATESHELLWINDOW = 3
Global Const $HSHELL_WINDOWACTIVATED = 4
Global Const $HSHELL_GETMINRECT = 5
Global Const $HSHELL_REDRAW = 6
Global Const $HSHELL_TASKMAN = 7
Global Const $HSHELL_LANGUAGE = 8
Global Const $HSHELL_SYSMENU = 9
Global Const $HSHELL_ENDTASK = 10
Global Const $HSHELL_ACCESSIBILITYSTATE = 11
Global Const $HSHELL_APPCOMMAND = 12
Global Const $HSHELL_WINDOWREPLACED = 13
Global Const $HSHELL_WINDOWREPLACING = 14
Global Const $HSHELL_RUDEAPPACTIVATED = 32772
Global Const $HSHELL_FLASH = 32774

; ===============================================================================================================================
; _WinAPI_RestartDlg()
; ===============================================================================================================================

Global Const $EWX_LOGOFF = 0
Global Const $EWX_POWEROFF = 8
Global Const $EWX_REBOOT = 2
Global Const $EWX_SHUTDOWN = 1
Global Const $EWX_FORCE = 4
Global Const $EWX_FORCEIFHUNG = 16

; ===============================================================================================================================
; _WinAPI_SetSystemCursor()
; ===============================================================================================================================

#cs

Global Const $OCR_APPSTARTING = 32650
Global Const $OCR_NORMAL = 32512
Global Const $OCR_CROSS = 32515
Global Const $OCR_HAND = 32649
Global Const $OCR_IBEAM = 32513
Global Const $OCR_NO = 32648
Global Const $OCR_SIZEALL = 32646
Global Const $OCR_SIZENESW = 32643
Global Const $OCR_SIZENS = 32645
Global Const $OCR_SIZENWSE = 32642
Global Const $OCR_SIZEWE = 32644
Global Const $OCR_UP = 32516
Global Const $OCR_WAIT = 32514
Global Const $OCR_ICON = 32641
Global Const $OCR_SIZE = 32640

#ce

Global Const $SHGFI_ATTR_SPECIFIED = 0x00020000
Global Const $SHGFI_ATTRIBUTES = 0x00000800
Global Const $SHGFI_DISPLAYNAME = 0x00000200
Global Const $SHGFI_EXETYPE = 0x00002000
Global Const $SHGFI_ICON = 0x00000100
Global Const $SHGFI_ICONLOCATION = 0x00001000
Global Const $SHGFI_LARGEICON = 0x00000000
Global Const $SHGFI_LINKOVERLAY = 0x00008000
Global Const $SHGFI_OPENICON = 0x00000002
Global Const $SHGFI_OVERLAYINDEX = 0x00000040
Global Const $SHGFI_PIDL = 0x00000008
Global Const $SHGFI_SELECTED = 0x00010000
Global Const $SHGFI_SHELLICONSIZE = 0x00000004
Global Const $SHGFI_SMALLICON = 0x00000001
Global Const $SHGFI_SYSICONINDEX = 0x00004000
Global Const $SHGFI_TYPENAME = 0x00000400
Global Const $SHGFI_USEFILEATTRIBUTES = 0x00000010

; ===============================================================================================================================
; _WinAPI_ShellGetSpecialFolderPath()
; ===============================================================================================================================

Global Const $CSIDL_ADMINTOOLS = 0x0030
Global Const $CSIDL_ALTSTARTUP = 0x001D
Global Const $CSIDL_APPDATA = 0x001A
Global Const $CSIDL_BITBUCKET = 0x000A
Global Const $CSIDL_CDBURN_AREA = 0x003B
Global Const $CSIDL_COMMON_ADMINTOOLS = 0x002F
Global Const $CSIDL_COMMON_ALTSTARTUP = 0x001E
Global Const $CSIDL_COMMON_APPDATA = 0x0023
Global Const $CSIDL_COMMON_DESKTOPDIRECTORY = 0x0019
Global Const $CSIDL_COMMON_DOCUMENTS = 0x002E
Global Const $CSIDL_COMMON_FAVORITES = 0x001F
Global Const $CSIDL_COMMON_MUSIC = 0x0035
Global Const $CSIDL_COMMON_PICTURES = 0x0036
Global Const $CSIDL_COMMON_PROGRAMS = 0x0017
Global Const $CSIDL_COMMON_STARTMENU = 0x0016
Global Const $CSIDL_COMMON_STARTUP = 0x0018
Global Const $CSIDL_COMMON_TEMPLATES = 0x002D
Global Const $CSIDL_COMMON_VIDEO = 0x0037
Global Const $CSIDL_COMPUTERSNEARME = 0x003D
Global Const $CSIDL_CONNECTIONS = 0x0031
Global Const $CSIDL_CONTROLS = 0x0003
Global Const $CSIDL_COOKIES = 0x0021
Global Const $CSIDL_DESKTOP = 0x0000
Global Const $CSIDL_DESKTOPDIRECTORY = 0x0010
Global Const $CSIDL_DRIVES = 0x0011
Global Const $CSIDL_FAVORITES = 0x0006
Global Const $CSIDL_FONTS = 0x0014
Global Const $CSIDL_INTERNET_CACHE = 0x0020
Global Const $CSIDL_HISTORY = 0x0022
Global Const $CSIDL_LOCAL_APPDATA = 0x001C
Global Const $CSIDL_MYMUSIC = 0x000D
Global Const $CSIDL_MYPICTURES = 0x0027
Global Const $CSIDL_MYVIDEO = 0x000E
Global Const $CSIDL_NETHOOD = 0x0013
Global Const $CSIDL_PERSONAL = 0x0005
Global Const $CSIDL_PRINTERS = 0x0004
Global Const $CSIDL_PRINTHOOD = 0x001B
Global Const $CSIDL_PROFILE = 0x0028
Global Const $CSIDL_PROGRAM_FILES = 0x0026
Global Const $CSIDL_PROGRAM_FILES_COMMON = 0x002B
Global Const $CSIDL_PROGRAM_FILES_COMMONX86 = 0x002C
Global Const $CSIDL_PROGRAM_FILESX86 = 0x002A
Global Const $CSIDL_PROGRAMS = 0x0002
Global Const $CSIDL_RECENT = 0x0008
Global Const $CSIDL_SENDTO = 0x0009
Global Const $CSIDL_STARTMENU = 0x000B
Global Const $CSIDL_STARTUP = 0x0007
Global Const $CSIDL_SYSTEM = 0x0025
Global Const $CSIDL_SYSTEMX86 = 0x0029
Global Const $CSIDL_TEMPLATES = 0x0015
Global Const $CSIDL_WINDOWS = 0x0024

; ===============================================================================================================================
; _WinAPI_ShellNotifyIcon()
; ===============================================================================================================================

Global Const $NIM_ADD = 0x00
Global Const $NIM_MODIFY = 0x01
Global Const $NIM_DELETE = 0x02
Global Const $NIM_SETFOCUS = 0x03
Global Const $NIM_SETVERSION = 0x04

Global Const $NIF_MESSAGE = 0x01
Global Const $NIF_ICON = 0x02
Global Const $NIF_TIP = 0x04
Global Const $NIF_STATE = 0x08
Global Const $NIF_INFO = 0x10
Global Const $NIF_GUID = 0x20
Global Const $NIF_REALTIME = 0x40
Global Const $NIF_SHOWTIP = 0x80

Global Const $NIS_HIDDEN = 0x01
Global Const $NIS_SHAREDICON = 0x02

Global Const $NIIF_NONE = 0x00
Global Const $NIIF_INFO = 0x01
Global Const $NIIF_WARNING = 0x02
Global Const $NIIF_ERROR = 0x03
Global Const $NIIF_USER = 0x04
Global Const $NIIF_NOSOUND = 0x10
Global Const $NIIF_LARGE_ICON = 0x10
Global Const $NIIF_RESPECT_QUIET_TIME = 0x80
Global Const $NIIF_ICON_MASK = 0x0F

; ===============================================================================================================================
; _WinAPI_StretchBlt()
; ===============================================================================================================================

#cs

Global Const $BLACKNESS = 0x00000042
Global Const $CAPTUREBLT = 0x40000000
Global Const $DSTINVERT = 0x00550009
Global Const $MERGECOPY = 0x00C000CA
Global Const $MERGEPAINT = 0x00BB0226
Global Const $NOMIRRORBITMAP = 0x80000000
Global Const $NOTSRCCOPY = 0x00330008
Global Const $NOTSRCERASE = 0x001100A6
Global Const $PATCOPY = 0x00F00021
Global Const $PATINVERT = 0x005A0049
Global Const $PATPAINT = 0x00FB0A09
Global Const $SRCAND = 0x008800C6
Global Const $SRCCOPY = 0x00CC0020
Global Const $SRCERASE = 0x00440328
Global Const $SRCINVERT = 0x00660046
Global Const $SRCPAINT = 0x00EE0086
Global Const $WHITENESS = 0x00FF0062

#ce

; ===============================================================================================================================
; _WinAPI_WinHelp()
; ===============================================================================================================================

Global Const $HELP_COMMAND = 0x0102
Global Const $HELP_CONTENTS = 0x0003
Global Const $HELP_CONTEXT = 0x0001
Global Const $HELP_CONTEXTMENU = 0x000A
Global Const $HELP_CONTEXTPOPUP = 0x0008
Global Const $HELP_FINDER = 0x000B
Global Const $HELP_FORCEFILE = 0x0009
Global Const $HELP_HELPONHELP = 0x0004
Global Const $HELP_INDEX = 0x0003
Global Const $HELP_KEY = 0x0101
Global Const $HELP_MULTIKEY = 0x0201
Global Const $HELP_PARTIALKEY = 0x0105
Global Const $HELP_QUIT = 0x0002
Global Const $HELP_SETCONTENTS = 0x0005
Global Const $HELP_SETPOPUP_POS = 0x000D
Global Const $HELP_SETWINPOS = 0x0203
Global Const $HELP_TCARD = 0x8000
Global Const $HELP_WM_HELP = 0x000C

; ===============================================================================================================================
; *Structure constants
; ===============================================================================================================================

Global Const $tagBITMAP = 'long Type;long Width;long Height;long WidthBytes;ushort Planes;ushort BitsPixel;ptr Bits'
Global Const $tagBITMAPINFOHEADER = 'dword Size;long Width;long Height;ushort Planes;ushort BitCount;dword Compression;dword SizeImage;long XPelsPerMeter;long YPelsPerMeter;dword ClrUsed;dword ClrImportant'
Global Const $tagDIBSECTION = $tagBITMAP & ';' & $tagBITMAPINFOHEADER & ';dword Bitfields[3];ptr hSection;dword Offset'
Global Const $tagDISK_GEOMETRY = 'int64 Cylinders;dword MediaType;dword TracksPerCylinder;dword SectorsPerTrack;dword BytesPerSector'
Global Const $tagDISK_GEOMETRY_EX = $tagDISK_GEOMETRY & ';int64 DiskSize;dword Data'
Global Const $tagEXTLOGPEN = 'dword PenStyle;dword Width;uint BrushStyle;dword Color;ulong_ptr Hatch;dword NumEntries' ; & ';dword StyleEntry[n]'
Global Const $tagLOGBRUSH = 'uint Style;dword Color;ulong_ptr Hatch'
Global Const $tagLOGPEN = 'uint Style;dword Width;dword Color'
Global Const $tagNOTIFYICONDATA = 'dword Size;hwnd hWnd;uint ID;uint Flags;uint CallbackMessage;ptr hIcon;wchar Tip[128];dword State;dword StateMask;wchar Info[256];uint Version;wchar InfoTitle[64];dword InfoFlags'
Global Const $tagNOTIFYICONDATA_XP = $tagNOTIFYICONDATA & ';uint GUID'
Global Const $tagNOTIFYICONDATA_VISTA = $tagNOTIFYICONDATA_XP & ';ptr hBalloonIcon'
Global Const $tagSHFILEINFO = 'ptr hIcon;int iIcon;dword Attributes;wchar DisplayName[1024];wchar TypeName[80]'
Global Const $tagOSVERSIONINFO = 'dword OSVersionInfoSize;dword MajorVersion;dword MinorVersion;dword BuildNumber;dword PlatformId;wchar CSDVersion[128]'
Global Const $tagOSVERSIONINFOEX = $tagOSVERSIONINFO & ';short ServicePackMajor;short ServicePackMinor;short SuiteMask;byte ProductType;byte Reserved'
Global Const $tagPAINTSTRUCT = 'hwnd hDC;int fErase;dword rPaint[4];int fRestore;int fIncUpdate;byte rgbReserved[32]'
Global Const $tagPROCESS_MEMORY_COUNTERS = 'dword Size;dword PageFaultCount;long PeakWorkingSetSize;long WorkingSetSize;long QuotaPeakPagedPoolUsage;long QuotaPagedPoolUsage;long QuotaPeakNonPagedPoolUsage;long QuotaNonPagedPoolUsage;long PagefileUsage;long PeakPagefileUsage'
Global Const $tagSTORAGE_DEVICE_NUMBER = 'dword DeviceType;ulong DeviceNumber;ulong PartitionNumber'
Global Const $tagWINDOWINFO = 'dword Size;dword rWindow[4];dword rClient[4];dword Style;dword ExStyle;dword WindowStatus;uint cxWindowBorders;uint cyWindowBorders;ushort atomWindowType;ushort CreatorVersion'

#EndRegion Global Variables and Constants

#Region Local Variables and Constants

Global $__Data, $__RGB = True

#EndRegion Local Variables and Constants

#Region Public Functions

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_AboutDlg
; Description....: Displays an Windows About dialog box.
; Syntax.........: _WinAPI_AboutDlg ( $sTitle, $sName, $sText [, $hIcon [, $hParent]] )
; Parameters.....: $sTitle  - The title of the Windows About dialog box.
;                  $sName   - The first line after the text "Microsoft".
;                  $sText   - The text to be displayed in the dialog box after the version and copyright information.
;                  $hIcon   - Handle to the icon that the function displays in the dialog box.
;                  $hParent - Handle to a parent window.
; Return values..: Success  - 1.
;                  Failure  - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ ShellAbout
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_AboutDlg($sTitle, $sName, $sText, $hIcon = 0, $hParent = 0)

	Local $Ret = DllCall('shell32.dll', 'int', 'ShellAboutW', 'hwnd', $hParent, 'wstr', $sTitle & '#' & $sName, 'wstr', $sText, 'ptr', $hIcon)

	If (@error) Or ($Ret[0] = 0) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_AboutDlg

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_AddFontResource
; Description....: Adds the font resource from the specified file to the system font table.
; Syntax.........: _WinAPI_AddFontResource ( $sFont [, $fNotify] )
; Parameters.....: $sFont   - String that contains a valid font file name. This parameter can specify any of the following files:
;
;                             .fon - Font resource file.
;                             .fnt - Raw bitmap font file.
;                             .ttf - Raw TrueType file.
;                             .ttc - East Asian Windows: TrueType font collection.
;                             .fot - TrueType resource file.
;                             .otf - PostScript OpenType font.
;                             .mmm - Multiple master Type1 font resource file. It must be used with .pfm and .pfb files.
;                             .pfb - Type 1 font bits file. It is used with a .pfm file.
;                             .pfm - Type 1 font metrics file. It is used with a .pfb file.
;
;                             To add a font whose information comes from several resource files, they must be separated by a "|" .
;                             For example, abcxxxxx.pfm | abcxxxxx.pfb.
;
;                  $fNotify - Specifies whether sends a WM_FONTCHANGE message, valid values:
;                  |TRUE    - Send the WM_FONTCHANGE message to all top-level windows in the system after changing the pool of font resources.
;                  |FALSE   - Don`t send. (Default)
; Return values..: Success  - The value specifies the number of fonts added.
;                  Failure  - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: This function installs the font only for the current session. When the system restarts, the font will not be present.
;                  To have the font installed even after restarting the system, the font must be listed in the registry.
; Related........:
; Link...........: @@MsdnLink@@ AddFontResource
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_AddFontResource($sFont, $fNotify = 0)

	Local $Ret = DllCall('gdi32.dll', 'int', 'AddFontResourceW', 'wstr', $sFont)

	If (@error) Or ($Ret[0] = 0) Then
		Return SetError(1, 0, 0)
	EndIf
	If $fNotify Then
		DllCall('user32.dll', 'int', 'SendMessage', 'hwnd', 0xFFFF, 'int', 0x001D, 'int', 0, 'int', 0)
	EndIf
	Return SetError(0, 0, $Ret[0])
EndFunc   ;==>_WinAPI_AddFontResource

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_AlphaBlend
; Description....: Displays bitmaps that have transparent or semitransparent pixels.
; Syntax.........: _WinAPI_AlphaBlend ( $hDestDC, $iXDest, $iYDest, $iWidthDest, $iHeightDest, $hSrcDC, $iXSrc, $iYSrc, $iWidthSrc, $iHeightSrc, $iAlpha [, $fAlpha] )
; Parameters.....: $hDestDC     - Handle to the destination device context.
;                  $iXDest      - The x-coordinate, in logical units, of the upper-left corner of the destination rectangle.
;                  $iYDest      - The y-coordinate, in logical units, of the upper-left corner of the destination rectangle.
;                  $iWidthDest  - The width, in logical units, of the destination rectangle.
;                  $iHeightDest - The height, in logical units, of the destination rectangle.
;                  $hSrcDC      - Handle to the source device context.
;                  $iXSrc       - The x-coordinate, in logical units, of the upper-left corner of the source rectangle.
;                  $iYSrc       - The y-coordinate, in logical units, of the upper-left corner of the source rectangle.
;                  $iWidthSrc   - The width, in logical units, of the source rectangle.
;                  $iHeightSrc  - The height, in logical units, of the source rectangle.
;                  $iAlpha      - The alpha transparency value to be used on the entire source bitmap. This value is combined with
;                                 any per-pixel alpha values in the source bitmap. If you set $iAlpha to 0, it is assumed that
;                                 your image is transparent. Set $iAlpha value to 255 (opaque) when you only want to use per-pixel
;                                 alpha values.
;                  $fAlpha      - Specifies whether uses an Alpha channel from the source bitmap, valid values:
;                  |TRUE        - Use the Alpha channel (that is, per-pixel alpha). Note that the APIs use premultiplied alpha,
;                                 which means that the red, green and blue channel values in the bitmap must be premultiplied with the
;                                 alpha channel value. For example, if the alpha channel value is x, the red, green and blue channels
;                                 must be multiplied by x and divided by 255 prior to the call.
;                  |FALSE       - Do not use the Alpha channel. (Default)
; Return values..: Success      - 1.
;                  Failure      - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: If the source rectangle and destination rectangle are not the same size, the source bitmap is stretched to
;                  match the destination rectangle. If the _WinAPI_SetStretchBltMode() function is used, the stretching mode value
;                  is automatically converted to $COLORONCOLOR for this function (that is, $BLACKONWHITE, $WHITEONBLACK, and
;                  $HALFTONE are changed to $COLORONCOLOR).
;
;                  If destination and source bitmaps do not have the same color format, _WinAPI_AlphaBlend() function converts
;                  the source bitmap to match the destination bitmap.
; Related........:
; Link...........: @@MsdnLink@@ GdiAlphaBlend
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_AlphaBlend($hDestDC, $iXDest, $iYDest, $iWidthDest, $iHeightDest, $hSrcDC, $iXSrc, $iYSrc, $iWidthSrc, $iHeightSrc, $iAlpha, $fAlpha = 0)

	Local $iBlend = BitOR(BitShift(Not ($fAlpha = 0), -24), BitShift(BitAND($iAlpha, 0xFF), -16))
	Local $Ret  = DllCall('gdi32.dll', 'int', 'GdiAlphaBlend', 'hwnd', $hDestDC, 'int', $iXDest, 'int', $iYDest, 'int', $iWidthDest, 'int', $iHeightDest, 'hwnd', $hSrcDC, 'int', $iXSrc, 'int', $iYSrc, 'int', $iWidthSrc, 'int', $iHeightSrc, 'dword', $iBlend)

	If (@error) Or ($Ret[0] = 0) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_AlphaBlend

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_AnimateWindow
; Description....: Enables you to produce special effects when showing or hiding windows.
; Syntax.........: _WinAPI_AnimateWindow ( $hWnd, $iFlags [, $iDuration] )
; Parameters.....: $hWnd      - Handle to the window to animate.
;                  $iFlags    - The flags that specify the type of animation. This parameter can be one or more of the following
;                               values. Note that, by default, these flags take effect when showing a window. To take effect when
;                               hiding a window, use AW_HIDE and a logical OR operator with the appropriate flags.
;
;                               $AW_SLIDE
;                               $AW_ACTIVATE
;                               $AW_BLEND
;                               $AW_HIDE
;                               $AW_CENTER
;                               $AW_HOR_POSITIVE
;                               $AW_HOR_NEGATIVE
;                               $AW_VER_POSITIVE
;                               $AW_VER_NEGATIVE
;
;                  $iDuration - Specifies how long it takes to play the animation, in milliseconds. Default is 1000.
; Return values..: Success    - 1.
;                  Failure    - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ AnimateWindow
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_AnimateWindow($hWnd, $iFlags, $iDuration = 1000)

	Local $Ret = DllCall('user32.dll', 'int', 'AnimateWindow', 'hwnd', $hWnd, 'dword', $iDuration, 'dword', $iFlags)

	If (@error) Or ($Ret[0] = 0) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_AnimateWindow

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_ArrayToStruct
; Description....: Converts an array of strings to the structure.
; Syntax.........: _WinAPI_ArrayToStruct ( $aData [, $iStart [, $iEnd]] )
; Parameters.....: $aData  - The array to convert.
;                  $iStart - The index of array to start converting at.
;                  $iEnd   - The index of array to stop converting at.
; Return values..: Success - The structure of the type "string1;{0};string2;{0}; ... ;stringN;{0};{0}".
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: This function works for Unicode strings only.
; Related........:
; Link...........: None
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_ArrayToStruct($aData, $iStart = 0, $iEnd = -1)

	If Not IsArray($aData) Then
		Return SetError(2, 0, 0)
	EndIf

	Local $tData, $Count, $Struct = ''

	If $iStart < 0 Then
		$iStart = 0
	EndIf
	If ($iEnd < 0) Or ($iEnd > UBound($aData) - 1) Then
		$iEnd = UBound($aData) - 1
	EndIf
	For $i = $iStart To $iEnd
		$Struct &= 'wchar[' & (StringLen($aData[$i]) + 1) & '];'
	Next
	$tData = DllStructCreate($Struct & 'wchar[1]')
	If @error Then
		Return SetError(1, 0, 0)
	EndIf
	$Count = 1
	For $i = $iStart To $iEnd
		DllStructSetData($tData, $Count, $aData[$i])
		$Count += 1
	Next
	DllStructSetData($tData, $Count, ChrW(0))
	Return $tData
EndFunc   ;==>_WinAPI_ArrayToStruct

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_AssocQueryString
; Description....: Searches for and retrieves a file or protocol association-related string from the registry.
; Syntax.........: _WinAPI_AssocQueryString ( $sAssoc, $iType [, $iFlags [, $sExtra]] )
; Parameters.....: $sAssoc - The string that is used to determine the root key. The following four types of strings can be used.
;
;                            The file name extension, such as .txt.
;                            The class identifier (CLSID) GUID in the standard "{GUID}" format.
;                            The application's ProgID, such as Word.Document.8.
;                            The name of an application's .exe file. The $ASSOCF_OPEN_BYEXENAME flag must be set.
;
;                  $iType  - The value that specifies the type of string that is to be returned. This parameter can be one of the
;                            following values.
;
;                            $ASSOCSTR_COMMAND
;                            $ASSOCSTR_EXECUTABLE
;                            $ASSOCSTR_FRIENDLYDOCNAME
;                            $ASSOCSTR_FRIENDLYAPPNAME
;                            $ASSOCSTR_NOOPEN
;                            $ASSOCSTR_SHELLNEWVALUE
;                            $ASSOCSTR_DDECOMMAND
;                            $ASSOCSTR_DDEIFEXEC
;                            $ASSOCSTR_DDEAPPLICATION
;                            $ASSOCSTR_DDETOPIC
;                            $ASSOCSTR_INFOTIP
;                            $ASSOCSTR_QUICKTIP
;                            $ASSOCSTR_TILEINFO
;                            $ASSOCSTR_CONTENTTYPE
;                            $ASSOCSTR_DEFAULTICON
;                            $ASSOCSTR_SHELLEXTENSION
;
;                  $iFlags - The flags that can be used to control the search. It can be any combination of the following
;                            values, except that only one $ASSOCF_INIT_... value can be included.
;
;                            $ASSOCF_INIT_NOREMAPCLSID
;                            $ASSOCF_INIT_BYEXENAME
;                            $ASSOCF_OPEN_BYEXENAME
;                            $ASSOCF_INIT_DEFAULTTOSTAR
;                            $ASSOCF_INIT_DEFAULTTOFOLDER
;                            $ASSOCF_NOUSERSETTINGS
;                            $ASSOCF_NOTRUNCATE
;                            $ASSOCF_VERIFY
;                            $ASSOCF_REMAPRUNDLL
;                            $ASSOCF_NOFIXUPS
;                            $ASSOCF_IGNOREBASECLASS
;                            $ASSOCF_INIT_IGNOREUNKNOWN
;
;                  $sExtra - The optional string with additional information about the location of the string. It is typically
;                            set to a Shell verb such as open.
; Return values..: Success - The string that contains the requested ($ASSOCSTR_...) information.
;                  Failure - Empty string and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ AssocQueryString
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_AssocQueryString($sAssoc, $iType, $iFlags = 0, $sExtra = '')

	Local $TypeOfExtra = 'wstr'

	If StringStripWS($sExtra, 3) = '' Then
		$TypeOfExtra = 'ptr'
		$sExtra = 0
	EndIf

	Local $Ret

	$Ret = DllCall('shlwapi.dll', 'int', 'AssocQueryStringW', 'dword', $iFlags, 'dword', $iType, 'wstr', $sAssoc, $TypeOfExtra, $sExtra, 'ptr', 0, 'dword*', 0)
    If (@error) Or (Not ($Ret[0] = 1)) Then
		Return SetError(1, 0, '')
	EndIf

	Local $tData = DllStructCreate('wchar[' & $Ret[6] & ']')

	$Ret = DllCall('shlwapi.dll', 'int', 'AssocQueryStringW', 'dword', $iFlags, 'dword', $iType, 'wstr', $sAssoc, $TypeOfExtra, $sExtra, 'ptr', DllStructGetPtr($tData), 'dword*', $Ret[6])
    If (@error) Or (Not ($Ret[0] = 0)) Then
		Return SetError(1, 0, '')
	EndIf
	Return DllStructGetData($tData, 1)
EndFunc   ;==>_WinAPI_AssocQueryString

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_BeginPaint
; Description....: Prepares the specified window for painting.
; Syntax.........: _WinAPI_BeginPaint ( $hWnd, ByRef $tPAINTSTRUCT )
; Parameters.....: $hWnd         - Handle to the window to be repainted.
;                  $tPAINTSTRUCT - $tagPAINTSTRUCT structure that will receive painting information.
; Return values..: Success       - Handle to a display device context for the specified window.
;                  Failure       - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: This function automatically sets the clipping region of the device context to exclude any area outside the
;                  update region. The update region is set by the _WinAPI_InvalidateRect() or _WinAPI_InvalidateRgn() function and
;                  by the system after sizing, moving, creating, scrolling, or any other operation that affects the client area.
;                  If the update region is marked for erasing, _WinAPI_BeginPaint() sends a WM_ERASEBKGND message to the window.
;
;                  An application should not call _WinAPI_BeginPaint() except in response to a WM_PAINT message. Each call to
;                  _WinAPI_BeginPaint() must have a corresponding call to the _WinAPI_EndPaint() function.
; Related........:
; Link...........: @@MsdnLink@@ BeginPaint
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_BeginPaint($hWnd, ByRef $tPAINTSTRUCT)

	$tPAINTSTRUCT = DllStructCreate($tagPAINTSTRUCT)

	Local $Ret = DllCall('user32.dll', 'hwnd', 'BeginPaint', 'hwnd', $hWnd, 'ptr', DllStructGetPtr($tPAINTSTRUCT))

	If (@error) Or ($Ret[0] = 0) Then
		$tPAINTSTRUCT = 0
	EndIf
	Return SetError(Int(IsDllStruct($tPAINTSTRUCT)), 0, $Ret[0])
EndFunc   ;==>_WinAPI_BeginPaint

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_BringWindowToTop
; Description....: Brings the specified window to the top of the Z order.
; Syntax.........: _WinAPI_BringWindowToTop ( $hWnd )
; Parameters.....: $hWnd   - Handle to the window to bring to the top of the Z order.
; Return values..: Success - 1.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ BringWindowToTop
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_BringWindowToTop($hWnd)

	Local $Ret = DllCall('user32.dll', 'int', 'BringWindowToTop', 'hwnd', $hWnd)

	If (@error) Or ($Ret[0] = 0) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_BringWindowToTop

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_CharToOem
; Description....: Converts a string into the OEM-defined character set.
; Syntax.........: _WinAPI_CharToOem ( $sStr )
; Parameters.....: $sStr   - The string that must be converted.
; Return values..: Success - The converted string.
;                  Failure - Empty string and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ CharToOem
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_CharToOem($sStr)

	Local $tData = DllStructCreate('char[' & StringLen($sStr) + 1 & ']')
	Local $Ret = DllCall('user32.dll', 'int', 'CharToOem', 'str', $sStr, 'ptr', DllStructGetPtr($tData))

	If (@error) Or ($Ret[0] = 0) Then
		Return SetError(1, 0, '')
	EndIf
	Return DllStructGetData($tData, 1)
EndFunc   ;==>_WinAPI_CharToOem

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_ChildWindowFromPointEx
; Description....: Determines which, if any, of the child windows belonging to the specified parent window contains the specified point.
; Syntax.........: _WinAPI_ChildWindowFromPointEx ( $hWnd, $tPOINT [, $iFlags] )
; Parameters.....: $hWnd   - Handle to the parent window.
;                  $tPOINT - $tagPOINT structure that defines the client coordinates (relative to hwndParent) of the point to
;                            be checked.
;                  $iFlags - The flags that specify which child windows to skip. This parameter can be one or more of the
;                            following values. 
;
;                            $CWP_ALL
;                            $CWP_SKIPINVISIBLE
;                            $CWP_SKIPDISABLED
;                            $CWP_SKIPTRANSPARENT
;
; Return values..: Success - Handle to the first child window. If the point is within the parent window but not within any child
;                            window that meets the criteria, the return value is a handle to the parent window. If the point lies
;                            outside the parent window, the return value is 0.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: The system maintains an internal list that contains the handles of the child windows associated with a
;                  parent window. The order of the handles in the list depends on the Z order of the child windows. If more than
;                  one child window contains the specified point, the system returns a handle to the first window in the list
;                  that contains the point and meets the criteria specified by $iFlags.
; Related........:
; Link...........: @@MsdnLink@@ ChildWindowFromPointEx
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_ChildWindowFromPointEx($hWnd, $tPOINT, $iFlags = 0)

	Local $Ret = DllCall('user32.dll', 'hwnd', 'ChildWindowFromPointEx', 'hwnd', $hWnd, 'int', DllStructGetData($tPOINT, 1), 'int', DllStructGetData($tPOINT, 2), 'uint', $iFlags)

	If @error Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_ChildWindowFromPointEx

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_CloseWindow
; Description....: Minimizes (but does not destroy) the specified window.
; Syntax.........: _WinAPI_CloseWindow ( $hWnd )
; Parameters.....: $hWnd   - Handle to the window to be minimized.
; Return values..: Success - 1.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ CloseWindow
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_CloseWindow($hWnd)

	Local $Ret = DllCall('user32.dll', 'int', 'CloseWindow', 'hwnd', $hWnd)

	If (@error) Or ($Ret[0] = 0) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_CloseWindow

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_CopyFileEx
; Description....: Copies an existing file to a new file, notifying the application of its progress through a callback function.
; Syntax.........: _WinAPI_CopyFileEx ( $sSource, $sDestination, $pProgressRoutine [, $iFlags] )
; Parameters.....: $sSource          - The name of an existing file.
;                  $sDestination     - The name of the new file.
;                  $pProgressRoutine - The address of a callback function that is called each time another portion of the file
;                                      has been copied. This parameter can be 0.
;                  $iFlags           - The flags that specify how the file is to be copied. This parameter can be a combination of
;                                      the following values.
;
;                                      $COPY_FILE_ALLOW_DECRYPTED_DESTINATION
;                                      $COPY_FILE_COPY_SYMLINK
;                                      $COPY_FILE_FAIL_IF_EXISTS
;                                      $COPY_FILE_OPEN_SOURCE_FOR_WRITE
;                                      $COPY_FILE_RESTARTABLE
;
; Return values..: Success           - 1.
;                  Failure           - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ CopyFileEx
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_CopyFileEx($sSource, $sDestination, $pProgressRoutine, $iFlags = 0)

	Local $Ret = DllCall('kernel32.dll', 'int', 'CopyFileExW', 'wstr', $sSource, 'wstr', $sDestination, 'ptr', $pProgressRoutine, 'ptr', 0, 'int', 0, 'int', $iFlags)

	If (@error) Or ($Ret[0] = 0) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_CopyFileEx

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_CopyImage
; Description....: Creates a new image (icon, cursor, or bitmap) and copies the attributes of the specified image to the new one.
; Syntax.........: _WinAPI_CopyImage ( $hImage [, $iType [, $xDesired [, $yDesired [, $iFlags]]]] )
; Parameters.....: $hImage   - Handle to the image to be copied.
;                  $iType    - Specifies the type of image to be copied. This parameter can be one of the following values.
;
;                              $IMAGE_BITMAP
;                              $IMAGE_CURSOR
;                              $IMAGE_ICON
;
;                  $xDesired - Specifies the desired width, in pixels, of the image. If this is zero, then the returned image will
;                              have the same width as the original $hImage.
;                  $yDesired - Specifies the desired height, in pixels, of the image. If this is zero, then the returned image will
;                              have the same height as the original $hImage.
;                  $iFlags   - This parameter can be one or more of the following values.
;
;                              $LR_COPYDELETEORG
;                              $LR_COPYFROMRESOURCE
;                              $LR_COPYRETURNORG
;                              $LR_CREATEDIBSECTION
;                              $LR_DEFAULTSIZE
;                              $LR_MONOCHROME
;
; Return values..: Success   - Handle to the newly created image.
;                  Failure   - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: When you are finished using the resource, you can release its associated memory by calling _WinAPI_Free...
;                  function respectively for bitmaps, cursors, or icons. The system automatically deletes the resource when its
;                  process terminates, however, calling the appropriate function saves memory and decreases the size of the
;                  process's working set.
; Related........:
; Link...........: @@MsdnLink@@ CopyImage
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_CopyImage($hImage, $iType = 0, $xDesired = 0, $yDesired = 0, $iFlags = 0)

	Local $Ret = DllCall('user32.dll', 'ptr', 'CopyImage', 'ptr', $hImage, 'int', $iType, 'int', $xDesired, 'int', $yDesired, 'int', $iFlags)

	If (@error) Or ($Ret[0] = 0) Or ($Ret[0] = Ptr(0)) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_CopyImage

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_CopyRect
; Description....: Copies the coordinates of one rectangle to another.
; Syntax.........: _WinAPI_CopyRect ( $tRECT )
; Parameters.....: $tRECT  - $tagRECT structure whose coordinates are to be copied in logical units.
; Return values..: Success - $tagRECT structure that contains the logical coordinates of the source rectangle.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ CopyRect
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_CopyRect($tRECT)

	Local $tData = DllStructCreate($tagRECT)
	Local $Ret = DllCall('user32.dll', 'int', 'CopyRect ', 'ptr', DllStructGetPtr($tData), 'ptr', DllStructGetPtr($tRECT))

	If (@error) Or ($Ret[0] = 0) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $tData
EndFunc   ;==>_WinAPI_CopyRect

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_CreateBrushIndirect
; Description....: Creates a logical brush that has the specified style, color, and pattern.
; Syntax.........: _WinAPI_CreateBrushIndirect ( $iStyle, $iRGB, $iHatch )
; Parameters.....: $iStyle - The brush style. This parameter can be one of the following styles.
;
;                            $BS_DIBPATTERN
;                            $BS_DIBPATTERN8X8
;                            $BS_DIBPATTERNPT
;                            $BS_HATCHED
;                            $BS_HOLLOW
;                            $BS_NULL
;                            $BS_PATTERN
;                            $BS_PATTERN8X8
;                            $BS_SOLID
;
;                  $iRGB   - The color of a brush, in RGB, or one of the following values.
;
;                            $DIB_PAL_COLORS
;                            $DIB_RGB_COLORS
;
;                  $iHatch - A hatch style. The meaning depends on the brush style defined by $iStyle parameter.
;
;                            $BS_DIBPATTERN
;                            Contains a handle to a packed DIB.
;
;                            $BS_DIBPATTERNPT
;                            Contains a pointer to a packed DIB.
;
;                            $BS_HATCHED
;                            Specifies the orientation of the lines used to create the hatch. It can be one of the orientation constants ($HS_...).
;
;                            $BS_PATTERN
;                            Contains a handle to the bitmap that defines the pattern. The bitmap cannot be a DIB section bitmap.
;
;                            $BS_HOLLOW, $BS_SOLID
;                            Ignored.
;
; Return values..: Success - The value identifies a logical brush.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: After an application creates a brush by calling _WinAPI_CreateBrushIndirect(), it can select it into any
;                  device context by calling the _WinAPI_SelectObject() function. When you no longer need the brush,
;                  call the _WinAPI_DeleteObject() function to delete it.
; Related........:
; Link...........: @@MsdnLink@@ CreateBrushIndirect
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_CreateBrushIndirect($iStyle, $iRGB, $iHatch = 0)

	Local $tLOGBRUSH = DllStructCreate($tagLOGBRUSH)

	DllStructSetData($tLOGBRUSH, 1, $iStyle)
	DllStructSetData($tLOGBRUSH, 2, __CheckColor($iRGB))
	DllStructSetData($tLOGBRUSH, 3, $iHatch)

	Local $Ret = DllCall('gdi32.dll', 'int', 'CreateBrushIndirect', 'ptr', DllStructGetPtr($tLOGBRUSH))

	If (@error) Or ($Ret[0] = 0) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_CreateBrushIndirect

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_CreateCompatibleBitmapEx
; Description....: Creates a bitmap compatible with the device and fills it the specified color.
; Syntax.........: _WinAPI_CreateSolidBitmapEx ( $hDC, $iWidth, $iHeight, $iRGB )
; Parameters.....: $hDC     - Handle to a device context.
;                  $iWidht  - The bitmap width, in pixels.
;                  $iHeight - The bitmap height, in pixels.
;                  $iRGB    - The bitmap color, in RGB.
; Return values..: Success  - Handle to the compatible solid bitmap (DDB).
;                  Failure  - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: The color format of the bitmap created by the _WinAPI_CreateCompatibleBitmapEx() function matches the color
;                  format of the device identified by the hdc parameter. This bitmap can be selected into any memory device context
;                  that is compatible with the original device.
;
;                  When you no longer need the bitmap, call the _WinAPI_FreeObject() function to delete it.
; Related........:
; Link...........: None
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_CreateCompatibleBitmapEx($hDC, $iWidth, $iHeight, $iRGB)

	Local $Ret, $tRECT, $hBmp, $hBrush, $hDestDC, $hDestSv

	$hBrush = _WinAPI_CreateBrushIndirect($BS_SOLID, $iRGB)
	$Ret = DllCall('gdi32.dll', 'hwnd', 'CreateCompatibleDC', 'hwnd', $hDC)
	$hDestDC = $Ret[0]
	$Ret = DllCall('gdi32.dll', 'hwnd', 'CreateCompatibleBitmap', 'hwnd', $hDC, 'int', $iWidth, 'int', $iHeight)
	$hBmp = $Ret[0]
	$Ret = DllCall('gdi32.dll', 'hwnd', 'SelectObject', 'hwnd', $hDestDC, 'ptr', $hBmp)
	$hDestSv = $Ret[0]
	$tRECT = _WinAPI_CreateRectEx(0, 0, $iWidth, $iHeight)
	$Ret = DllCall('user32.dll', 'int', 'FillRect', 'hwnd', $hDestDC, 'ptr', DllStructGetPtr($tRECT), 'ptr', $hBrush)
	If (@error) Or ($Ret[0] = 0) Then
		_WinAPI_FreeObject($hBmp)
		$Ret = 0
	EndIf
	_WinAPI_FreeObject($hBrush)
	DllCall('gdi32.dll', 'ptr', 'SelectObject', 'hwnd', $hDestDC, 'ptr', $hDestSv)
	DllCall('gdi32.dll', 'int', 'DeleteDC', 'hwnd', $hDestDC)
	If Not IsArray($Ret) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $hBmp
EndFunc   ;==>_WinAPI_CreateCompatibleBitmapEx

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_CreateDIBSection
; Description....: Creates a DIB that applications can write to directly.
; Syntax.........: _WinAPI_CreateDIBSection ( $hDC, $tBITMAPINFO, $iUsage, ByRef $pBits [, $hSection [, $iOffset]] )
; Parameters.....: $hDC         - Handle to a device context. If the value of $iUsage is $DIB_PAL_COLORS, the function uses this
;                                 device context's logical palette to initialize the DIB colors.
;                  $tBITMAPINFO - $tagBITMAPINFO structure that specifies various attributes of the DIB, including the bitmap
;                                 dimensions and colors.
;                  $iUsage      - The type of data contained in the $pBits array. (either logical palette indexes or literal RGB values).
;                                 The following values are defined.
;
;                                 $DIB_PAL_COLORS
;                                 $DIB_RGB_COLORS
;
;                  $pBits       - Pointer to a variable that receives a pointer to the location of the DIB bit values.
;                  $hSection    - Handle to a file-mapping object that the function will use to create the DIB.
;                  $iOffset     - The offset from the beginning of the file-mapping object referenced by $hSection where storage
;                                 for the bitmap bit values is to begin. This value is ignored if $hSection is 0.
; Return values..: Success      - Handle to the newly created DIB, and $pBits points to the bitmap bit values. You can create the
;                                 structure by using $pBits pointer to further its filling. For example,
;                                 DllStructCreate('dword[4]', $pBits).
;                  Failure      - 0 and sets the @error flag to non-zero, $pBits also is 0.
; Author.........: Yashied
; Modified.......:
; Remarks........: When you are finished using the icon, destroy it using the _WinAPI_FreeIcon() function.
; Related........:
; Link...........: @@MsdnLink@@ CreateDIBSection
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_CreateDIBSection($hDC, $tBITMAPINFO, $iUsage, ByRef $pBits, $hSection = 0, $iOffset = 0)

	Local $Ret = DllCall('gdi32.dll', 'ptr', 'CreateDIBSection', 'hwnd', $hDC, 'ptr', DllStructGetPtr($tBITMAPINFO), 'uint', $iUsage, 'ptr*', 0, 'ptr', $hSection, 'dword', $iOffset)

	If (@error) Or ($Ret[0] = 0) Then
		$pBits = 0
	Else
		$pBits = $Ret[4]
	EndIf
	Return SetError(Int($Ret[0] = 0), 0, $Ret[0])
EndFunc   ;==>_WinAPI_CreateDIBSection

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_CreateEllipticRgn
; Description....: Creates an elliptical region.
; Syntax.........: _WinAPI_CreateEllipticRgn ( $tRECT )
; Parameters.....: $tRECT  - $tagRECT structure that contains the coordinates of the upper-left and lower-right corners of the
;                            bounding rectangle of the ellipse in logical units.
; Return values..: Success - The handle to the region.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: A bounding rectangle defines the size, shape, and orientation of the region: The long sides of the rectangle
;                  define the length of the ellipse's major axis; the short sides define the length of the ellipse's minor axis;
;                  and the center of the rectangle defines the intersection of the major and minor axes.
;
;                  When you no longer need the HRGN object, call the _WinAPI_FreeObject() function to delete it.
; Related........:
; Link...........: @@MsdnLink@@ CreateEllipticRgn
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_CreateEllipticRgn($tRECT)

	Local $Ret = DllCall('gdi32.dll', 'ptr', 'CreateEllipticRgnIndirect', 'ptr', DllStructGetPtr($tRECT))

	If (@error) Or ($Ret[0] = 0) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_CreateEllipticRgn

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_CreateFileEx
; Description....: Creates or opens a file or I/O device.
; Syntax.........: _WinAPI_CreateFileEx ( $sFile, $iCreation, $iAccess, $iShare [, $iFlagsAndAttributes [, $tSecurity [, $hTemplate]]] )
; Parameters.....: $sFile               - The name of the file or device to be created or opened.
;                  $iCreation           - The action to take on a file or device that exists or does not exist. This parameter
;                                         must be one of the following values, which cannot be combined.
;
;                                         $CREATE_NEW
;                                         $CREATE_ALWAYS
;                                         $OPEN_EXISTING
;                                         $OPEN_ALWAYS
;                                         $TRUNCATE_EXISTING
;
;                  $iAccess             - The requested access to the file or device, which can be summarized as read, write,
;                                         both or neither (zero).
;
;                                         $GENERIC_READ
;                                         $GENERIC_WRITE
;
;                  $iShare              - The requested sharing mode of the file or device, which can be read, write, both,
;                                         delete, all of these, or none. If this parameter is 0 and _WinAPI_CreateFileEx()
;                                         succeeds, the file or device cannot be shared and cannot be opened again until the
;                                         handle to the file or device is closed.
;
;                                         $FILE_SHARE_READ
;                                         $FILE_SHARE_WRITE
;                                         $FILE_SHARE_DELETE
;
;                  $iFlagsAndAttributes - The file or device attributes and flags. This parameter can be one or more of the
;                                         following values.
;
;                                         $FILE_ATTRIBUTE_READONLY
;                                         $FILE_ATTRIBUTE_HIDDEN
;                                         $FILE_ATTRIBUTE_SYSTEM
;                                         $FILE_ATTRIBUTE_DIRECTORY
;                                         $FILE_ATTRIBUTE_ARCHIVE
;                                         $FILE_ATTRIBUTE_DEVICE
;                                         $FILE_ATTRIBUTE_NORMAL
;                                         $FILE_ATTRIBUTE_TEMPORARY
;                                         $FILE_ATTRIBUTE_SPARSE_FILE
;                                         $FILE_ATTRIBUTE_REPARSE_POINT
;                                         $FILE_ATTRIBUTE_COMPRESSED
;                                         $FILE_ATTRIBUTE_OFFLINE
;                                         $FILE_ATTRIBUTE_NOT_CONTENT_INDEXED
;                                         $FILE_ATTRIBUTE_ENCRYPTED
;
;                                         $FILE_FLAG_BACKUP_SEMANTICS
;                                         $FILE_FLAG_DELETE_ON_CLOSE
;                                         $FILE_FLAG_NO_BUFFERING
;                                         $FILE_FLAG_OPEN_NO_RECALL
;                                         $FILE_FLAG_OPEN_REPARSE_POINT
;                                         $FILE_FLAG_OVERLAPPED
;                                         $FILE_FLAG_POSIX_SEMANTICS
;                                         $FILE_FLAG_RANDOM_ACCESS
;                                         $FILE_FLAG_SEQUENTIAL_SCAN
;                                         $FILE_FLAG_WRITE_THROUGH
;
;                                         $SECURITY_ANONYMOUS
;                                         $SECURITY_IDENTIFICATION
;                                         $SECURITY_IMPERSONATION
;                                         $SECURITY_DELEGATION
;                                         $SECURITY_CONTEXT_TRACKING
;                                         $SECURITY_EFFECTIVE_ONLY
;
;                  $tSecurity           - $tagSECURITY_ATTRIBUTES structure that contains two separate but related data members:
;                                         an optional security descriptor, and a Boolean value that determines whether the returned
;                                         handle can be inherited by child processes.
;                  $hTemplate           - Handle to a template file with the $GENERIC_READ access right. The template file supplies
;                                         file attributes and extended attributes for the file that is being created.
; Return values..: Success              - Handle to the specified file, device, named pipe, or mail slot.
;                  Failure              - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ CreateFile
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_CreateFileEx($sFile, $iCreation, $iAccess, $iShare, $iFlagsAndAttributes = 0, $tSecurity = 0, $hTemplate = 0)

	Local $Ret = DllCall('kernel32.dll', 'ptr', 'CreateFileW', 'wstr', $sFile, 'dword', $iAccess, 'dword', $iShare, 'ptr', DllStructGetPtr($tSecurity), 'dword', $iCreation, 'dword', $iFlagsAndAttributes, 'ptr', $hTemplate)

	If (@error) Or ($Ret[0] = -1) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_CreateFileEx

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_CreateIconIndirect
; Description....: Creates an icon or cursor that has the specified size, colors, and bit patterns.
; Syntax.........: _WinAPI_CreateIconIndirect ( $hBitmap, $hMask [, $XHotspot [, $YHotspot [, $fIcon]]] )
; Parameters.....: $hBitmap  - Handle to the icon color bitmap.
;                  $hMask    - Handle to the icon bitmask bitmap.
;                  $XHotspot - Specifies the x-coordinate of a cursor's hot spot. If creates an icon, the hot spot is always in
;                              the center of the icon, and this member is ignored.
;                  $YHotspot - Specifies the y-coordinate of the cursor's hot spot. If creates an icon, the hot spot is always in
;                              the center of the icon, and this member is ignored.
;                  $fIcon    - Specifies whether creates an icon or a cursor, valid values:
;                  |TRUE     - Creates an icon. (Default)
;                  |FALSE    - Creates a cursor.
; Return values..: Success   - Handle to the icon or cursor that is created.
;                  Failure   - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: The system copies the bitmaps before creating the icon or cursor. Because the system may temporarily
;                  select the bitmaps in a device context, $hBitmap and $hMask should not already be selected into a device context.
;                  The application must continue to manage the original bitmaps and delete them by _WinAPI_FreeObject() when they
;                  are no longer necessary.
; Related........:
; Link...........: @@MsdnLink@@ CreateIconIndirect
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_CreateIconIndirect($hBitmap, $hMask, $XHotspot = 0, $YHotspot = 0, $fIcon = 1)

	Local $tICONINFO = DllStructCreate($tagICONINFO)

	DllStructSetData($tICONINFO, 1, $fIcon)
	DllStructSetData($tICONINFO, 2, $XHotspot)
	DllStructSetData($tICONINFO, 3, $YHotspot)
	DllStructSetData($tICONINFO, 4, $hMask)
	DllStructSetData($tICONINFO, 5, $hBitmap)

	Local $Ret = DllCall('user32.dll', 'ptr', 'CreateIconIndirect', 'ptr', DllStructGetPtr($tICONINFO))

	If (@error) Or ($Ret[0] = 0) Or ($Ret[0] = Ptr(0)) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_CreateIconIndirect

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_CreatePolygonRgn
; Description....: Creates a polygonal region.
; Syntax.........: _WinAPI_CreatePolygonRgn ( $aPoint [, $iStart [, $iEnd [, $iMode]]] )
; Parameters.....: $aPoint - The 2D array ([x1, y1], [x2, y2], ... [xN, yN]) that contains the vertices of the polygon in logical
;                            units. The polygon is presumed closed. Each vertex can be specified only once.
;                  $iStart - The index of array to start creating at.
;                  $iEnd   - The index of array to stop creating at.
;                  $iMode  - The fill mode used to determine which pixels are in the region. This parameter can be one of the
;                            following values.
;
;                            $ALTERNATE
;                            $WINDING
;
; Return values..: Success - The handle to the region.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: When you no longer need the HRGN object, call the _WinAPI_FreeObject() function to delete it.
; Related........:
; Link...........: @@MsdnLink@@ CreatePolygonRgn
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_CreatePolygonRgn($aPoint, $iStart = 0, $iEnd = -1, $iMode = 1)

	If UBound($aPoint, 2) < 2  Then
		Return SetError(2, 0, 0)
	EndIf

	Local $Count, $tData, $Struct = ''

	If $iStart < 0 Then
		$iStart = 0
	EndIf
	If ($iEnd < 0) Or ($iEnd > UBound($aPoint) - 1) Then
		$iEnd = UBound($aPoint) - 1
	EndIf
	For $i = $iStart To $iEnd
		$Struct &= 'int[2];'
	Next
	$tData = DllStructCreate(StringTrimRight($Struct, 1))
	If @error Then
		Return SetError(1, 0, 0)
	EndIf
	$Count = 1
	For $i = $iStart To $iEnd
		For $j = 0 To 1
			DllStructSetData($tData, $Count, $aPoint[$i][$j], $j + 1)
		Next
		$Count += 1
	Next

	Local $Ret = DllCall('gdi32.dll', 'ptr', 'CreatePolygonRgn', 'ptr', DllStructGetPtr($tData), 'int', $Count - 1, 'int', $iMode)

	If (@error) Or ($Ret[0] = 0) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_CreatePolygonRgn

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_CreateRect
; Description....: Creates $tagRECT structure with the coordinates of the specified rectangle.
; Syntax.........: _WinAPI_CreateRect ( $iLeft, $iTop, $iRight, $iBottom )
; Parameters.....: $iLeft   - The x-coordinate of the upper-left corner of the rectangle.
;                  $iTop    - The y-coordinate of the upper-left corner of the rectangle.
;                  $iRight  - The x-coordinate of the lower-right corner of the rectangle.
;                  $iBottom - The y-coordinate of the lower-right corner of the rectangle.
; Return values..: Success  - $tagRECT structure that contains the specified rectangle.
;                  Failure  - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: None
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_CreateRect($iLeft, $iTop, $iRight, $iBottom)

	Local $tRECT = DllStructCreate($tagRECT)

	DllStructSetData($tRECT, 1, $iLeft)
	DllStructSetData($tRECT, 2, $iTop)
	DllStructSetData($tRECT, 3, $iRight)
	DllStructSetData($tRECT, 4, $iBottom)

	Return $tRECT
EndFunc   ;==>_WinAPI_CreateRect

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_CreateRectEx
; Description....: Creates $tagRECT structure with the coordinates of the specified rectangle.
; Syntax.........: _WinAPI_CreateRectEx ( $iX, $iY, $iWidth, $iHeight )
; Parameters.....: $iX      - The x-coordinate of the upper-left corner of the rectangle.
;                  $iY      - The y-coordinate of the upper-left corner of the rectangle.
;                  $iWidth  - The width of the rectangle.
;                  $iHeight - The height of the rectangle.
; Return values..: Success  - $tagRECT structure that contains the specified rectangle.
;                  Failure  - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: None
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_CreateRectEx($iX, $iY, $iWidth, $iHeight)

	Local $tRECT = DllStructCreate($tagRECT)

	DllStructSetData($tRECT, 1, $iX)
	DllStructSetData($tRECT, 2, $iY)
	DllStructSetData($tRECT, 3, $iX + $iWidth)
	DllStructSetData($tRECT, 4, $iY + $iHeight)

	Return $tRECT
EndFunc   ;==>_WinAPI_CreateRectEx

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_CreateRectRgnIndirect
; Description....: Creates a rectangular region.
; Syntax.........: _WinAPI_CreateRectRgnIndirect ( $tRECT )
; Parameters.....: $tRECT  - $tagRECT structure that contains the coordinates of the upper-left and lower-right corners of the
;                            rectangle that defines the region in logical units.
; Return values..: Success - The handle to the region.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: When you no longer need the HRGN object, call the _WinAPI_FreeObject() function to delete it.
; Related........:
; Link...........: @@MsdnLink@@ CreateRectRgnIndirect
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_CreateRectRgnIndirect($tRECT)

	Local $Ret = DllCall('gdi32.dll', 'ptr', 'CreateRectRgnIndirect', 'ptr', DllStructGetPtr($tRECT))

	If (@error) Or ($Ret[0] = 0) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_CreateRectRgnIndirect

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_CreateSemaphore
; Description....: Creates or opens a named or unnamed semaphore object.
; Syntax.........: _WinAPI_CreateSemaphore ( $sSemaphore, $iInitial, $iMaximum )
; Parameters.....: $sSemaphore - The name of the semaphore to be opened. Name comparisons are case sensitive.
;                  $iInitial   - The initial count for the semaphore object. This value must be greater than or equal to zero and
;                                less than or equal to $iMaximum.
;                  $iMaximum   - The maximum count for the semaphore object. This value must be greater than zero.
; Return values..: Success - The handle to the semaphore object. If the named semaphore object existed before the function call,
;                            the function returns a handle to the existing object.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: Any process can specify the semaphore-object handle in a call to _WinAPI_WaitFor... functions. The single-object
;                  wait functions return when the state of the specified object is signaled. The multiple-object wait functions can
;                  be instructed to return either when any one or when all of the specified objects are signaled. When a wait function
;                  returns, the waiting process is released to continue its execution.
;
;                  The state of a semaphore object is signaled when its count is greater than zero, and nonsignaled when its count
;                  is equal to zero. The $iInitial parameter specifies the initial count. Each time a waiting process is released
;                  because of the semaphore's signaled state, the count of the semaphore is decreased by one. Use the _WinAPI_ReleaseSemaphore()
;                  function to increment a semaphore's count by a specified amount. The count can never be less than zero or greater
;                  than the value specified in the $iMaximum parameter.
; Link...........: @@MsdnLink@@ CreateSemaphore
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_CreateSemaphore($sSemaphore, $iInitial, $iMaximum)

	Local $Ret = DllCall('kernel32.dll', 'ptr', 'CreateSemaphore', 'ptr', 0, 'int', $iInitial, 'int', $iMaximum, 'str', $sSemaphore)

	If (@error) Or ($Ret[0] = 0) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_CreateSemaphore

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_DefineDosDevice
; Description....: Defines, redefines, or deletes MS-DOS device names.
; Syntax.........: _WinAPI_DefineDosDevice ( $sDevice, $iFlags [, $sPath] )
; Parameters.....: $sDevice - The name of the MS-DOS device.
;                  $iFlags  - This parameter can be one or more of the following values.
;
;                             $DDD_EXACT_MATCH_ON_REMOVE
;                             $DDD_NO_BROADCAST_SYSTEM
;                             $DDD_RAW_TARGET_PATH
;                             $DDD_REMOVE_DEFINITION
;
;                  $sPath   - The path that will implement device.
; Return values..: Success  - 1.
;                  Failure  - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ DefineDosDevice
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_DefineDosDevice($sDevice, $iFlags, $sPath = '')

	Local $TypeOfPath = 'wstr'

	If StringStripWS($sPath, 3) = '' Then
		$TypeOfPath = 'ptr'
		$sPath = 0
	EndIf

	Local $Ret = DllCall('kernel32.dll', 'int', 'DefineDosDeviceW', 'dword', $iFlags, 'wstr', $sDevice, $TypeOfPath, $sPath)

	If (@error) Or ($Ret[0] = 0) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_DefineDosDevice

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_DeleteVolumeMountPoint
; Description....: Deletes a drive letter or mounted folder.
; Syntax.........: _WinAPI_DeleteVolumeMountPoint ( $sPath )
; Parameters.....: $sPath  - The drive letter or mounted folder to be deleted (for example, X:\ or Y:\MountX\).
; Return values..: Success - 1.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: Deleting a mounted folder does not cause the underlying directory to be deleted.
; Related........:
; Link...........: @@MsdnLink@@ DeleteVolumeMountPoint
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_DeleteVolumeMountPoint($sPath)

	Local $Ret = DllCall('kernel32.dll', 'int', 'DeleteVolumeMountPointW', 'wstr', $sPath)

	If (@error) Or ($Ret[0] = 0) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_DeleteVolumeMountPoint

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_DeregisterShellHookWindow
; Description....: Unregisters a specified Shell window that is registered to receive Shell hook messages.
; Syntax.........: _WinAPI_DeregisterShellHookWindow ( $hWnd )
; Parameters.....: $hWnd   - Handle to the window to unregister from receiving Shell hook messages.
; Return values..: Success - 1.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ DeregisterShellHookWindow
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_DeregisterShellHookWindow($hWnd)

	Local $Ret = DllCall('user32.dll', 'int', 'DeregisterShellHookWindow', 'hwnd', $hWnd)

	If (@error) Or ($Ret[0] = 0) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_DeregisterShellHookWindow

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_DllInstall
; Description....: Registers OLE controls such as DLL or ActiveX Controls (OCX) files.
; Syntax.........: _WinAPI_DllInstall ( $sPath )
; Parameters.....: $sPath  - Path to the DLL file that will be registered.
; Return values..: Success - 1.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: None
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_DllInstall($sPath)

    Local $Ret = RunWait(@SystemDir & '\regsvr32.exe /s ' & $sPath)

    If (@error) Or ($Ret) Then
		Return SetError(1, 0, 0)
	EndIf
    Return 1
EndFunc   ;==>_WinAPI_DllInstall

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_DllUninstall
; Description....: Unregisters OLE controls such as DLL or ActiveX Controls (OCX) files.
; Syntax.........: _WinAPI_DllUninstall ( $sPath )
; Parameters.....: $sPath  - Path to the DLL file that will be unregistered.
; Return values..: Success - 1.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: None
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_DllUninstall($sPath)

    Local $Ret = RunWait(@SystemDir & '\regsvr32.exe /s /u ' & $sPath)

    If (@error) Or ($Ret) Then
		Return SetError(1, 0, 0)
	EndIf
    Return 1
EndFunc   ;==>_WinAPI_DllUninstall

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_DragAcceptFiles
; Description....: Registers whether a window accepts dropped files.
; Syntax.........: _WinAPI_DragAcceptFiles ( $hWnd [, $fAccept] )
; Parameters.....: $hWnd    - Handle to the window that is registering whether it will accept dropped files.
;                  $fAccept - Specifies whether a window accepts dropped files, valid values:
;                  |TRUE    - Accept dropped files. (Default)
;                  |FALSE   - Discontinue accepting dropped files.
; Return values..: Success  - 1.
;                  Failure  - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ DragAcceptFiles
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_DragAcceptFiles($hWnd, $fAccept = 1)

	Local $Ret = DllCall('shell32.dll', 'none', 'DragAcceptFiles', 'hwnd', $hWnd, 'int', $fAccept)

	If @error Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_DragAcceptFiles

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_DragFinish
; Description....: Releases memory that the system allocated for use in transferring file names to the application.
; Syntax.........: _WinAPI_DragFinish ( $hDrop )
; Parameters.....: $hDrop  - Handle of the drop structure that describes the dropped file. This parameter is passed to
;                            WM_DROPFILES message with WPARAM parameter.
; Return values..: Success - 1.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ DragFinish
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_DragFinish($hDrop)

	Local $Ret = DllCall('shell32.dll', 'none', 'DragFinish', 'ptr', $hDrop)

	If @error Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_DragFinish

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_DragQueryFileEx
; Description....: Retrieves the names of dropped files that result from a successful drag-and-drop operation.
; Syntax.........: _WinAPI_DragQueryFileEx ( $hDrop [, $iFlag] )
; Parameters.....: $hDrop  - Handle of the drop structure that describes the dropped file. This parameter is passed to
;                            WM_DROPFILES message with WPARAM parameter.
;                  $iFlag  - The flag that specifies whether to return files folders or both, valid values:
;                  |0 - Return both files and folders. (Default)
;                  |1 - Return files only.
;                  |2 - Return folders only.
; Return values..: Success - The array of the names of a dropped files. The zeroth array element contains the number of file
;                            names in array. If no files that satisfy the condition ($iFlag), the function fails.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ DragQueryFile
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_DragQueryFileEx($hDrop, $iFlag = 0)

	Local $Ret, $Count, $Dir, $File, $tData, $aData[1] = [0]

	$Ret = DllCall('shell32.dll', 'int', 'DragQueryFileW', 'ptr', $hDrop, 'uint', -1, 'ptr', 0, 'uint', 0)
	If (@error) Or ($Ret[0] = 0) Then
		Return SetError(1, 0, 0)
	EndIf
	$Count = $Ret[0]
	ReDim $aData[$Count + 1]
	For $i = 0 To $Count - 1
		$Ret = DllCall('shell32.dll', 'int', 'DragQueryFileW', 'ptr', $hDrop, 'uint', $i, 'ptr', 0, 'uint', 0)
		$Ret = $Ret[0] + 1
		$tData = DllStructCreate('wchar[' & $Ret & ']')
		$Ret = DllCall('shell32.dll', 'int', 'DragQueryFileW', 'ptr', $hDrop, 'uint', $i, 'ptr', DllStructGetPtr($tData), 'uint', $Ret)
		If Not $Ret[0] Then
			Return SetError(1, 0, 0)
		EndIf
		$File = DllStructGetData($tData, 1)
		$tData = 0
		If $iFlag Then
			$Dir = _WinAPI_PathIsDirectory($File)
			If Not @error Then
				If (($iFlag = 1) And ($Dir)) Or (($iFlag = 2) And (Not $Dir)) Then
					ContinueLoop
				EndIf
			EndIf
		EndIf
		$aData[$i + 1] = $File
		$aData[0] += 1
	Next
	If $aData[0] = 0 Then
		Return SetError(1, 0, 0)
	EndIf
	ReDim $aData[$aData[0] + 1]
	Return $aData
EndFunc   ;==>_WinAPI_DragQueryFileEx

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_DragQueryPoint
; Description....: Retrieves the position of the mouse pointer at the time a file was dropped during a drag-and-drop operation.
; Syntax.........: _WinAPI_DragQueryPoint ( $hDrop )
; Parameters.....: $hDrop  - Handle of the drop structure that describes the dropped file. This parameter is passed to
;                            WM_DROPFILES message with WPARAM parameter.
; Return values..: Success - $tagPOINT structure that contains the coordinates of the mouse pointer at the time the
;                            file was dropped.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ DragQueryPoint
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_DragQueryPoint($hDrop)

	Local $tPOINT = DllStructCreate($tagPOINT)
	Local $Ret = DllCall('shell32.dll', 'int', 'DragQueryPoint', 'ptr', $hDrop, 'ptr', DllStructGetPtr($tPOINT))

	If @error Then
		Return SetError(1, 0, 0)
	EndIf
	Return $tPOINT
EndFunc   ;==>_WinAPI_DragQueryPoint

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_DrawAnimatedRects
; Description....: Animates the caption of a window to indicate the opening of an icon or the minimizing or maximizing of a window.
; Syntax.........: _WinAPI_DrawAnimatedRects ( $hWnd, $tRectFrom, $tRectTo )
; Parameters.....: $hWnd      - Handle to the window whose caption should be animated on the screen.
;                  $tRectFrom - $tagRECT structure specifying the location and size of the icon or minimized window.
;                  $tRectTo   - $tagRECT structure specifying the location and size of the restored window.
; Return values..: Success    - 1.
;                  Failure    - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: The window caption will animate from the position specified by $tRectFrom to the position specified by $tRectTo.
;                  The effect is similar to minimizing or maximizing a window.
; Related........:
; Link...........: @@MsdnLink@@ DrawAnimatedRects
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_DrawAnimatedRects($hWnd, $tRectFrom, $tRectTo)

	Local $Ret = DllCall('user32.dll', 'int', 'DrawAnimatedRects', 'hwnd', $hWnd, 'int', 3, 'ptr', DllStructGetPtr($tRectFrom), 'ptr', DllStructGetPtr($tRectTo))

	If (@error) Or ($Ret[0] = 0) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_DrawAnimatedRects

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_DrawBitmap
; Description....: Draws a bitmap into the specified device context.
; Syntax.........: _WinAPI_DrawBitmap ( $hDC, $iX, $iY, $hBitmap )
; Parameters.....: $hDC     - Handle to the device context into which the bitmap will be drawn.
;                  $iX      - Specifies the logical x-coordinate of the upper-left corner of the bitmap.
;                  $iY      - Specifies the logical y-coordinate of the upper-left corner of the bitmap.
;                  $hBitmap - Handle to the bitmap to be drawn.
; Return values..: Success  - 1.
;                  Failure  - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: This function does not support bitmaps with Alpha channel, use _WinAPI_AlphaBlend() to work with them.
; Related........:
; Link...........: None
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_DrawBitmap($hDC, $iX, $iY, $hBitmap)

	Local $Ret, $tObj, $_hDC, $hSrcDC, $hSrcSv

    $tObj = DllStructCreate($tagBITMAP)
	$Ret = DllCall('gdi32.dll', 'int', 'GetObject', 'int', $hBitmap, 'int', DllStructGetSize($tObj), 'ptr', DllStructGetPtr($tObj))
	If (@error) Or ($Ret[0] = 0) Then
		Return SetError(1, 0, 0)
	EndIf
	$Ret = DllCall('user32.dll', 'hwnd', 'GetDC', 'hwnd', 0)
	$_hDC = $Ret[0]
	$Ret = DllCall('gdi32.dll', 'hwnd', 'CreateCompatibleDC', 'hwnd', $_hDC)
	$hSrcDC = $Ret[0]
	$Ret = DllCall('gdi32.dll', 'hwnd', 'SelectObject', 'hwnd', $hSrcDC, 'ptr', $hBitmap)
	$hSrcSv = $Ret[0]
	$Ret = DllCall('gdi32.dll', 'int', 'BitBlt', 'hwnd', $hDC, 'int', $iX, 'int', $iY, 'int', DllStructGetData($tObj, 'Width'), 'int', DllStructGetData($tObj, 'Height'), 'hwnd', $hSrcDC, 'int', 0, 'int', 0, 'int', 0x00CC0020)
	If (@error) Or ($Ret[0] = 0) Then
		$Ret = 0
	EndIf
	DllCall('user32.dll', 'int', 'ReleaseDC', 'hwnd', 0, 'hwnd', $_hDC)
	DllCall('gdi32.dll', 'ptr', 'SelectObject', 'hwnd', $hSrcDC, 'ptr', $hSrcSv)
	DllCall('gdi32.dll', 'int', 'DeleteDC', 'hwnd', $hSrcDC)
	If Not IsArray($Ret) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_DrawBitmap

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_DrawShadowText
; Description....: Draws formatted text in the specified rectangle with a drop shadow.
; Syntax.........: _WinAPI_DrawShadowText ( $hDC, $sText, $rgbText, $rgbShadow [, $iXOffset [, $iYOffset [, $tRECT [, $iFlags]]]] )
; Parameters.....: $hDC       - Handle to a device context.
;                  $sText     - The string that contains the text to be drawn.
;                  $rgbText   - The color of the text, in RGB.
;                  $rgbShadow - The color of the shadow, in RGB.
;                  $iXOffset  - The x-coordinate of where the text should begin.
;                  $iYOffset  - The y-coordinate of where the text should begin.
;                  $tRECT     - $tagRECT structure that contains, in logical coordinates, the rectangle in which the text is to
;                               be drawn. If this parameter is 0, the size will be equal size of the device context ($hDC).
;                  $iFlags    - The flags that specifies how the text is to be drawn. This parameter can be a combination of
;                               the formatting text constants ($DT_...).
; Return values..: Success    - 1.
;                  Failure    - 0 and sets the @error flag to non-zero.
; Author.........: Rover
; Modified.......: Yashied
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ DrawShadowText
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_DrawShadowText($hDC, $sText, $rgbText, $rgbShadow, $iXOffset = 0, $iYOffset = 0, $tRECT = 0, $iFlags = 0)

	Local $Ret

	If Not IsDllStruct($tRECT) Then
		$tRECT = DllStructCreate($tagRECT)
		$Ret = DllCall('user32.dll', 'int', 'GetClientRect', 'hwnd', _WinAPI_WindowFromDC($hDC), 'ptr', DllStructGetPtr($tRECT))
		If (@error) Or ($Ret[0] = 0) Then
			Return SetError(1, 0, 0)
		EndIf
	EndIf
	$Ret = DllCall('comctl32.dll', 'int', 'DrawShadowText', 'hwnd', $hDC, 'wstr', $sText, 'uint', -1, 'ptr', DllStructGetPtr($tRECT), 'dword', $iFlags, 'int', __CheckColor($rgbText), 'int', __CheckColor($rgbShadow), 'int', $iXOffset, 'int', $iYOffset)
	If (@error) Or ($Ret[0] = 0) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_DrawShadowText

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_DuplicateBitmap
; Description....: Creates a duplicate of a specified bitmap with a device-independent bitmap (DIB) section.
; Syntax.........: _WinAPI_DuplicateBitmap ( $hBitmap )
; Parameters.....: $hBitmap - Handle to the bitmap to be duplicated.
; Return values..: Success  - Handle to the new bitmap that was created.
;                  Failure  - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: When you are finished using the bitmap, destroy it using the _WinAPI_FreeObject() function.
; Related........:
; Link...........: @@MsdnLink@@ CopyImage
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_DuplicateBitmap($hBitmap)
	Return _WinAPI_CopyImage($hBitmap, 0, 0, 0, 0x2000)
EndFunc   ;==>_WinAPI_DuplicateBitmap

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_DuplicateCursor
; Description....: Creates a duplicate of a specified cursor.
; Syntax.........: _WinAPI_DuplicateCursor ( $hCursor )
; Parameters.....: $hCursor - Handle to the cursor to be duplicated.
; Return values..: Success  - Handle to the new cursor that was created.
;                  Failure  - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: When you are finished using the cursor, destroy it using the _WinAPI_FreeCursor() function.
; Related........:
; Link...........: @@MsdnLink@@ CopyIcon
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_DuplicateCursor($hCursor)
	Return _WinAPI_DuplicateIcon($hCursor)
EndFunc   ;==>_WinAPI_DuplicateCursor

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_DuplicateIcon
; Description....: Creates a duplicate of a specified icon.
; Syntax.........: _WinAPI_DuplicateIcon ( $hIcon )
; Parameters.....: $hIcon  - Handle to the icon to be duplicated.
; Return values..: Success - Handle to the new icon that was created.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: When you are finished using the icon, destroy it using the _WinAPI_FreeIcon() function.
; Related........:
; Link...........: @@MsdnLink@@ CopyIcon
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_DuplicateIcon($hIcon)

	Local $Ret = DllCall('user32.dll', 'ptr', 'CopyIcon', 'ptr', $hIcon)

	If (@error) Or ($Ret[0] = 0) Or ($Ret[0] = Ptr(0)) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_DuplicateIcon

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_EjectMedia
; Description....: Causes the device to eject the media.
; Syntax.........: _WinAPI_EjectMedia ( $sDrive )
; Parameters.....: $sDrive - The drive letter of the CD tray to eject, in the format D:, E:, etc.
; Return values..: Success - 1.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ IOCTL_STORAGE_EJECT_MEDIA
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_EjectMedia($sDrive)

	If Not (_WinAPI_GetDriveType($sDrive) = $DRIVE_CDROM) Then
		Return SetError(1, 0, 0)
	EndIf

	Local $hFile = _WinAPI_CreateFile('\\.\' & $sDrive, 2, 2, 2)

	If $hFile = 0 Then
		Return SetError(1, 0, 0)
	EndIf

	Local $Ret = DllCall('kernel32.dll', 'int', 'DeviceIoControl', 'ptr', $hFile, 'dword', 0x002D4808, 'ptr', 0, 'dword', 0, 'ptr', 0, 'dword', 0, 'dword*', 0, 'ptr', 0)

	If @error Then
		$Ret = 0
	EndIf
	_WinAPI_FreeHandle($hFile)
	If Not IsArray($Ret) Then
		Return SetError(2, 0, 0)
	EndIf
	Return SetError(0, 0, 1)
EndFunc   ;==>_WinAPI_EjectMedia

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_Ellipse
; Description....: Draws an ellipse.
; Syntax.........: _WinAPI_Ellipse ( $hDC, $tRECT )
; Parameters.....: $hDC     - Handle to the device context.
;                  $tRECT   - $tagRECT structure that contains the logical coordinates of the bounding rectangle.
; Return values..: Success  - 1.
;                  Failure  - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: The ellipse is outlined by using the current pen and is filled by using the current brush.
; Related........:
; Link...........: @@MsdnLink@@ Ellipse
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_Ellipse($hDC, $tRECT)

	Local $Ret = DllCall('gdi32.dll', 'int', 'Ellipse', 'hwnd', $hDC, 'int', DllStructGetData($tRECT, 1), 'int', DllStructGetData($tRECT, 2), 'int', DllStructGetData($tRECT, 3), 'int', DllStructGetData($tRECT, 4))

	If (@error) Or ($Ret[0] = 0) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_Ellipse

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_EmptyWorkingSet
; Description....: Removes as many pages as possible from the working set of the specified process.
; Syntax.........: _WinAPI_EmptyWorkingSet ( [$PID] )
; Parameters.....: $PID    - The PID of the process. Default (0) is the current process.
; Return values..: Success - 1.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ EmptyWorkingSet
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_EmptyWorkingSet($PID = 0)

	If Not $PID Then
		$PID = _WinAPI_GetCurrentProcessID()
		If Not $PID Then
			Return SetError(1, 0, 0)
		EndIf
	EndIf

	Local $hProc = DllCall('kernel32.dll', 'ptr', 'OpenProcess', 'dword', 0x001F0FFF, 'int', 0, 'dword', $PID)

	If (@error) Or ($hProc[0] = 0) Then
		Return SetError(1, 0, 0)
	EndIf

	$hProc = $hProc[0]

	Local $Ret = DllCall('psapi.dll', 'int', 'EmptyWorkingSet', 'ptr', $hProc)

	If (@error) Or ($Ret[0] = 0) Then
		$Ret = 0
	EndIf
	_WinAPI_FreeHandle($hProc)
	If Not IsArray($Ret) Then
		Return SetError(1, 0, 0)
	EndIf
	Return SetError(0, 0, 1)
EndFunc   ;==>_WinAPI_EmptyWorkingSet

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_EndPaint
; Description....: Marks the end of painting in the specified window.
; Syntax.........: _WinAPI_EndPaint ( $hWnd, ByRef $tPAINTSTRUCT )
; Parameters.....: $hWnd         - Handle to the window that has been repainted.
;                  $tPAINTSTRUCT - $tagPAINTSTRUCT structure that contains the painting information retrieved by _WinAPI_BeginPaint().
; Return values..: Success       - 1.
;                  Failure       - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: This function is required for each call to the _WinAPI_BeginPaint() function, but only after painting is complete.
; Related........:
; Link...........: @@MsdnLink@@ EndPaint
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_EndPaint($hWnd, ByRef $tPAINTSTRUCT)

	Local $Ret = DllCall('user32.dll', 'int', 'EndPaint', 'hwnd', $hWnd, 'ptr', DllStructGetPtr($tPAINTSTRUCT))

	If (@error) Or ($Ret[0] = 0) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_EndPaint

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_EnumChildWindows
; Description....: Enumerates the child windows that belong to the specified parent window.
; Syntax.........: _WinAPI_EnumChildWindows ( $hWnd [, $fVisible] )
; Parameters.....: $hWnd     - Handle to the parent window whose child windows are to be enumerated. If this parameter is 0,
;                              this function is equivalent to _WinAPI_EnumWindows().
;                  $fVisible - Specifies whether enumerates the invisible window, valid values:
;                  |TRUE     - Enumerate only visible windows. (Default)
;                  |FALSE    - Enumerate all windows.
; Return values..: Success   - The 2D array of the handles to the child windows and classes for the specified parent window.
;                              [0][0] - Number of rows in array (n).
;                              [0][1] - Unused.
;                              [1][0] - Window handle.
;                              [1][1] - Window class name.
;                              [n][0] - Window handle.
;                              [n][1] - Window class name.
;                  Failure   - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ EnumChildWindows
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_EnumChildWindows($hWnd, $fVisible = 1)

	If Not _WinAPI_GetWindow($hWnd, 5) Then
		Return SetError(1, 0, 0)
	EndIf

	Local $hEnumProc = DllCallbackRegister('__EnumWindowsProc','int','hwnd;int')
	Local $Error = 1

	Dim $__Data[101][2] = [[0]]
	DllCall('user32.dll', 'int', 'EnumChildWindows', 'hwnd', $hWnd, 'ptr', DllCallbackGetPtr($hEnumProc), 'int', $fVisible)
	If @error Then
		$__Data = 0
	Else
		$Error = 0
		If $__Data[0][0] Then
			ReDim $__Data[$__Data[0][0] + 1][2]
		Else
			$__Data = 0
		EndIf
	EndIf
	DllCallbackFree($hEnumProc)
	Return SetError($Error, 0, $__Data)
EndFunc   ;==>_WinAPI_EnumResourceLanguages

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_EnumDisplaySettings
; Description....: Retrieves information about one of the graphics modes for a display device.
; Syntax.........: _WinAPI_EnumDisplaySettings ( $sDevice, $iMode )
; Parameters.....: $sDevice - The display device about whose graphics mode the function will obtain information. An empty string
;                             specifies the current display device on the computer on which the calling process is running.
;                  $iMode   - The type of information to be retrieved. This value can be a graphics mode index or one of the
;                             following values.
;
;                             $ENUM_CURRENT_SETTINGS
;                             $ENUM_REGISTRY_SETTINGS
;
;                             Graphics mode indexes start at zero. To obtain information for all of a display device's graphics
;                             modes, make a series of calls to _WinAPI_EnumDisplaySettings(), as follows: Set $iMode to zero for
;                             the first call, and increment $iMode by one for each subsequent call. Continue calling the function
;                             until the return value is zero.
;
;                             When you call _WinAPI_EnumDisplaySettings() with $iMode set to zero, the operating system initializes
;                             and caches information about the display device. When you call _WinAPI_EnumDisplaySettings() with
;                             $iMode set to a non-zero value, the function returns the information that was cached the last time
;                             the function was called with $iMode set to zero.
;
; Return values..: Success  - The array containing the following parameters:
;                             [0] - The width, in pixels, of the visible device surface.
;                             [1] - The height, in pixels, of the visible device surface.
;                             [2] - The color resolution, in bits per pixel, of the display device.
;                             [3] - The frequency, in hertz (cycles per second), of the display device in a particular mode.
;                             [4] - The device's display mode ($DM_...).
;                  Failure  - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ EnumDisplaySettings
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_EnumDisplaySettings($sDevice, $iMode)

	Local $TypeOfDevice = 'wstr'

	If StringStripWS($sDevice, 3) = '' Then
		$TypeOfDevice = 'ptr'
		$sDevice = 0
	EndIf

	Local $tDEVMODE = DllStructCreate('wchar[32];short;short;short;short;dword;dword[2];dword;dword;short;short;short;short;short;wchar[32];short;dword;dword;dword;dword;dword')

	DllStructSetData($tDEVMODE, 4, DllStructGetSize($tDEVMODE))
	DllStructSetData($tDEVMODE, 5, 0)

	Local $Ret = DllCall('user32.dll', 'int', 'EnumDisplaySettingsW', $TypeOfDevice, $sDevice, 'dword', $iMode, 'ptr', DllStructGetPtr($tDEVMODE))

	If (@error) Or ($Ret[0] = 0) Then
		Return SetError(1, 0, 0)
	EndIf

	Local $Result[5]

	$Result[0] = DllStructGetData($tDEVMODE, 18)
	$Result[1] = DllStructGetData($tDEVMODE, 19)
	$Result[2] = DllStructGetData($tDEVMODE, 17)
	$Result[3] = DllStructGetData($tDEVMODE, 21)
	$Result[4] = DllStructGetData($tDEVMODE, 20)

	Return $Result
EndFunc   ;==>_WinAPI_EnumDisplaySettings

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_EnumProcessThreads
; Description....: Enumerates the threads that belong to the specified process.
; Syntax.........: _WinAPI_EnumProcessThreads ( [$PID] )
; Parameters.....: $PID    - The PID of the process. Default (0) is the current process.
; Return values..: Success - The array of threads identifiers (ID). The zeroth array element contains the number of threads.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: None
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_EnumProcessThreads($PID = 0)

	If Not $PID Then
		$PID = _WinAPI_GetCurrentProcessID()
		If Not $PID Then
			Return SetError(1, 0, 0)
		EndIf
	EndIf

	Local $hSnapshot = DllCall('kernel32.dll', 'ptr', 'CreateToolhelp32Snapshot', 'dword', 0x00000004, 'dword', 0)

	If (@error) Or ($hSnapshot[0] = 0) Then
		Return SetError(1, 0, 0)
	EndIf

	Local $tTHREADENTRY32 = DllStructCreate('dword Size;dword Usage;dword ThreadID;dword OwnerProcessID;long BasePri;long DeltaPri;dword Flags')
	Local $pTHREADENTRY32 = DllStructGetPtr($tTHREADENTRY32)
	Local $Ret, $Result[101] = [0]

	$hSnapshot = $hSnapshot[0]
	DllStructSetData($tTHREADENTRY32, 'Size', DllStructGetSize($tTHREADENTRY32))
	$Ret = DllCall('kernel32.dll', 'int', 'Thread32First', 'ptr', $hSnapshot, 'ptr', $pTHREADENTRY32)
	While (Not @error) And ($Ret[0])
		If DllStructGetData($tTHREADENTRY32, 'OwnerProcessID') = $PID Then
			$Result[0] += 1
			If $Result[0] > UBound($Result) - 1 Then
				ReDim $Result[$Result[0] + 100]
			EndIf
			$Result[$Result[0]] = DllStructGetData($tTHREADENTRY32, 'ThreadID')
		EndIf
		$Ret = DllCall('kernel32.dll', 'int', 'Thread32Next', 'ptr', $hSnapshot, 'ptr', $pTHREADENTRY32)
	WEnd
	_WinAPI_FreeHandle($hSnapshot)
	If $Result[0] Then
		ReDim $Result[$Result[0] + 1]
	Else
		Return SetError(1, 0, 0)
	EndIf
	Return $Result
EndFunc   ;==>_WinAPI_EnumProcessThreads

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_EnumProcessWindows
; Description....: Enumerates the windows that belong to the specified process.
; Syntax.........: _WinAPI_EnumProcessWindows ( $PID [, $fVisible] )
; Parameters.....: $PID      - The PID of the process. Default (0) is the current process.
;                  $fVisible - Specifies whether enumerates the invisible window, valid values:
;                  |TRUE     - Enumerate only visible windows. (Default)
;                  |FALSE    - Enumerate all windows.
; Return values..: Success   - The 2D array of the handles to the windows and classes for the specified process.
;                              [0][0] - Number of rows in array (n).
;                              [0][1] - Unused.
;                              [1][0] - Window handle.
;                              [1][1] - Window class name.
;                              [n][0] - Window handle.
;                              [n][1] - Window class name.
;                  Failure   - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: None
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_EnumProcessWindows($PID, $fVisible = 1)

	Local $Threads = _WinAPI_EnumProcessThreads($PID)

	If @error Then
		Return SetError(1, 0, 0)
	EndIf

	Local $hEnumProc = DllCallbackRegister('__EnumWindowsProc','int','hwnd;int')
	Local $Error = 1

	Dim $__Data[101][2] = [[0]]
	For $i = 1 To $Threads[0]
		DllCall('user32.dll', 'int', 'EnumThreadWindows', 'dword', $Threads[$i], 'ptr',  DllCallbackGetPtr($hEnumProc), 'int', $fVisible)
		If @error Then
			$__Data = 0
			ExitLoop
		EndIf
	Next
	If IsArray($__Data) Then
		$Error = 0
		If $__Data[0][0] Then
			ReDim $__Data[$__Data[0][0] + 1][2]
		Else
			$__Data = 0
		EndIf
	EndIf
	DllCallbackFree($hEnumProc)
	Return SetError($Error, 0, $__Data)
EndFunc   ;==>_WinAPI_EnumProcessWindows

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_EnumResourceLanguages
; Description....: Enumerates language-specific resources, of the specified type and name, associated with a binary module.
; Syntax.........: _WinAPI_EnumResourceLanguages ( $sModule, $sType, $sName )
; Parameters.....: $sModule - Handle to a module to search.
;                  $sType   - The type of the resource. This parameter can be string or integer type.
;                  $sName   - The name of the resource. This parameter can be string or integer type.
; Return values..: Success  - Array of the LCIDs for specified resource type and name.
;                  Failure  - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ EnumResourceLanguages
; Example........: Yes
; ===============================================================================================================================

#cs

Func _WinAPI_EnumResourceLanguages($hModule, $sType, $sName, $pEnumFunc, $lParam = 0)

	Local $TypeOfName = 'long', $TypeOfType = 'long'

	If IsString($sName) Then
		$TypeOfName = 'str'
	EndIf
	If IsString($sType) Then
		$TypeOfType = 'str'
	EndIf

	Local $Ret = DllCall('kernel32.dll', 'int', 'EnumResourceLanguages', 'ptr', $hModule, $TypeOfType, $sType, $TypeOfName, $sName, 'ptr', $pEnumFunc, 'ptr', $lParam)

	If (@error) Or ($Ret[0] = 0) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_EnumResourceLanguages

#ce

Func _WinAPI_EnumResourceLanguages($sModule, $sType, $sName)

	Local $Ret, $Result = 0, $hModule, $hEnumProc, $TypeOfName = 'long', $TypeOfType = 'long'

	If IsString($sModule) Then
		If StringStripWS($sModule, 3) = '' Then
			$hModule = DllCall('kernel32.dll', 'ptr', 'GetModuleHandle', 'ptr', 0)
		Else
			$hModule = DllCall('kernel32.dll', 'ptr', 'LoadLibrary', 'str', $sModule)
		EndIf
		If (@error) Or ($hModule[0] = 0) Then
			Return SetError(1, 0, 0)
		EndIf
		$hModule = $hModule[0]
	Else
		$hModule = $sModule
	EndIf
	If IsString($sName) Then
		$TypeOfName = 'str'
	EndIf
	If IsString($sType) Then
		$TypeOfType = 'str'
	EndIf
	Dim $__Data[101] = [0]
	$hEnumProc = DllCallbackRegister('__EnumResLanguagesProc','int','ptr;long;long;long;long')
	$Ret = DllCall('kernel32.dll', 'int', 'EnumResourceLanguages', 'ptr', $hModule, $TypeOfType, $sType, $TypeOfName, $sName, 'ptr', DllCallbackGetPtr($hEnumProc), 'ptr', 0)
	If (@error) Or ($Ret[0] = 0) Then
		$Result = _WinAPI_GetLastError()
		$__Data = 0
	Else
		ReDim $__Data[$__Data[0] + 1]
	EndIf
	DllCallbackFree($hEnumProc)
	If IsString($sModule) Then
		_WinAPI_FreeLibrary($hModule)
	EndIf
	_WinAPI_SetLastError($Result)
	Return SetError(Int($__Data = 0), 0, $__Data)
EndFunc   ;==>_WinAPI_EnumResourceLanguages

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_EnumResourceNames
; Description....: Enumerates resources of a specified type within a binary module.
; Syntax.........: _WinAPI_EnumResourceNames ( $sModule, $sType )
; Parameters.....: $sModule - Handle to a module to search.
;                  $sType   - The type of the resource. This parameter can be string or integer type.
; Return values..: Success  - Array of the names for the specified resource type.
;                  Failure  - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ EnumResourceNames
; Example........: Yes
; ===============================================================================================================================

#cs

Func _WinAPI_EnumResourceNames($hModule, $sType, $pEnumFunc, $lParam = 0)

	Local $TypeOfType = 'long'

	If IsString($sType) Then
		$TypeOfType = 'str'
	EndIf

	Local $Ret = DllCall('kernel32.dll', 'int', 'EnumResourceNames', 'ptr', $hModule, $TypeOfType, $sType, 'ptr', $pEnumFunc, 'ptr', $lParam)

	If (@error) Or ($Ret[0] = 0) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_EnumResourceNames

#ce

Func _WinAPI_EnumResourceNames($sModule, $sType)

	Local $Ret, $Result = 0, $hModule, $hEnumProc, $TypeOfType = 'long'

	If IsString($sModule) Then
		If StringStripWS($sModule, 3) = '' Then
			$hModule = DllCall('kernel32.dll', 'ptr', 'GetModuleHandle', 'ptr', 0)
		Else
			$hModule = DllCall('kernel32.dll', 'ptr', 'LoadLibrary', 'str', $sModule)
		EndIf
		If (@error) Or ($hModule[0] = 0) Then
			Return SetError(1, 0, 0)
		EndIf
		$hModule = $hModule[0]
	Else
		$hModule = $sModule
	EndIf
	If IsString($sType) Then
		$TypeOfType = 'str'
	EndIf
	Dim $__Data[101] = [0]
	$hEnumProc = DllCallbackRegister('__EnumResNamesProc','int','ptr;long;long;long')
	$Ret = DllCall('kernel32.dll', 'int', 'EnumResourceNames', 'ptr', $hModule, $TypeOfType, $sType, 'ptr', DllCallbackGetPtr($hEnumProc), 'ptr', 0)
	If (@error) Or ($Ret[0] = 0) Then
		$Result = _WinAPI_GetLastError()
		$__Data = 0
	Else
		ReDim $__Data[$__Data[0] + 1]
	EndIf
	DllCallbackFree($hEnumProc)
	If IsString($sModule) Then
		_WinAPI_FreeLibrary($hModule)
	EndIf
	_WinAPI_SetLastError($Result)
	Return SetError(Int($__Data = 0), 0, $__Data)
EndFunc   ;==>_WinAPI_EnumResourceNames

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_EnumResourceTypes
; Description....: Enumerates resource types within a binary module.
; Syntax.........: _WinAPI_EnumResourceTypes ( $sModule )
; Parameters.....: $sModule - Handle to a module to search.
; Return values..: Success  - Array of the types of the resources for the specified module.
;                  Failure  - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ EnumResourceTypes
; Example........: Yes
; ===============================================================================================================================

#cs

Func _WinAPI_EnumResourceTypes($hModule, $pEnumFunc, $lParam = 0)

	Local $Ret = DllCall('kernel32.dll', 'int', 'EnumResourceTypes', 'ptr', $hModule, 'ptr', $pEnumFunc, 'ptr', $lParam)

	If (@error) Or ($Ret[0] = 0) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_EnumResourceTypes

#ce

Func _WinAPI_EnumResourceTypes($sModule)

	Local $Ret, $Result = 0, $hModule, $hEnumProc

	If IsString($sModule) Then
		If StringStripWS($sModule, 3) = '' Then
			$hModule = DllCall('kernel32.dll', 'ptr', 'GetModuleHandle', 'ptr', 0)
		Else
			$hModule = DllCall('kernel32.dll', 'ptr', 'LoadLibrary', 'str', $sModule)
		EndIf
		If (@error) Or ($hModule[0] = 0) Then
			Return SetError(1, 0, 0)
		EndIf
		$hModule = $hModule[0]
	Else
		$hModule = $sModule
	EndIf
	Dim $__Data[101] = [0]
	$hEnumProc = DllCallbackRegister('__EnumResTypesProc','int','ptr;long;long')
	$Ret = DllCall('kernel32.dll', 'int', 'EnumResourceTypes', 'ptr', $hModule, 'ptr', DllCallbackGetPtr($hEnumProc), 'ptr', 0)
	If (@error) Or ($Ret[0] = 0) Then
		$Result = _WinAPI_GetLastError()
		$__Data = 0
	Else
		ReDim $__Data[$__Data[0] + 1]
	EndIf
	DllCallbackFree($hEnumProc)
	If IsString($sModule) Then
		_WinAPI_FreeLibrary($hModule)
	EndIf
	_WinAPI_SetLastError($Result)
	Return SetError(Int($__Data = 0), 0, $__Data)
EndFunc   ;==>_WinAPI_EnumResourceTypes

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_EqualRect
; Description....: Determines whether the two specified rectangles are equal.
; Syntax.........: _WinAPI_EqualRect ( $tRECT1, $tRECT2 )
; Parameters.....: $tRECT1 - $tagRECT structure that contains the logical coordinates of the first rectangle.
;                  $tRECT2 - $tagRECT structure that contains the logical coordinates of the second rectangle.
; Return values..: Success - 1 - The two rectangles are identical.
;                            0 - Otherwise.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: This function does not treat empty rectangles as equal if their coordinates are different.
; Related........:
; Link...........: @@MsdnLink@@ EqualRect
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_EqualRect($tRECT1, $tRECT2)

	Local $Ret = DllCall('user32.dll', 'int', 'EqualRect', 'ptr', DllStructGetPtr($tRECT1), 'ptr', DllStructGetPtr($tRECT2))

	If @error Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_EqualRect

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_EqualRgn
; Description....: Checks the two specified regions to determine whether they are identical.
; Syntax.........: _WinAPI_EqualRgn ( $hRgn1, $hRgn2 )
; Parameters.....: $hRgn1  - Handle to a region.
;                  $hRgn2  - Handle to a region.
; Return values..: Success - 1 - The two regions are equal.
;                            0 - Otherwise.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ EqualRgn
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_EqualRgn($hRgn1, $hRgn2)

	Local $Ret = DllCall('gdi32.dll', 'int', 'EqualRgn', 'ptr', $hRgn1, 'ptr', $hRgn2)

	If @error Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_EqualRgn

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_ExtractAssociatedIcon
; Description....: Returns a handle to an indexed icon found in a file or an icon found in an associated executable file.
; Syntax.........: _WinAPI_ExtractAssociatedIcon ( $hInstance, $sIcon, $iIndex )
; Parameters.....: $hInstance - The instance of the application calling the function.
;                  $sIcon     - The full path and file name of the file that contains the icon. The function extracts the icon handle
;                               from that file, or from an executable file associated with that file.
;                  $iIndex    - The index of the icon whose handle is to be obtained.
; Return values..: Success    - The icon handle.
;                  Failure    - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: When you are finished using the icon, destroy it using the _WinAPI_FreeIcon() function.
;
;                  This function first looks for the indexed icon in the specified file. If the function cannot obtain the icon handle
;                  from that file, and the file has an associated executable file, it looks in that executable file for an icon.
;                  Associations with executable files are based on file name extensions, are stored in the per-user part of the registry,
;                  and can be defined using File Manager's Associate command.
; Related........:
; Link...........: @@MsdnLink@@ ExtractAssociatedIcon
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_ExtractAssociatedIcon($hInstance, $sIcon, $iIndex)

	Local $Ret = DllCall('shell32.dll', 'ptr', 'ExtractAssociatedIcon', 'ptr', $hInstance, 'str', $sIcon, 'dword*', $iIndex)

	If (@error) Or ($Ret[0] = 0) Or ($Ret[0] = Ptr(0)) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_ExtractAssociatedIcon

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_ExtSelectClipRgn
; Description....: Combines the specified region with the current clipping region using the specified mode.
; Syntax.........: _WinAPI_ExtSelectClipRgn ( $hDC, $hRgn [, $iMode] )
; Parameters.....: $hDC    - Handle to the device context.
;                  $hRgn   - Handle to the region to be selected. This handle can only be 0 when the $RGN_COPY mode is specified.
;                  $iMode  - The operation to be performed. It must be one of the following values.
;
;                            $RGN_AND
;                            $RGN_COPY
;                            $RGN_DIFF
;                            $RGN_OR
;                            $RGN_XOR
;
; Return values..: Success - The value specifies the new clipping region's complexity; it can be one of the following values.
;
;                            $NULLREGION
;                            $SIMPLEREGION
;                            $COMPLEXREGION
;
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ ExtSelectClipRgn
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_ExtSelectClipRgn($hDC, $hRgn, $iMode = 5)

	Local $Ret = DllCall('gdi32.dll', 'int', 'ExtSelectClipRgn', 'hwnd', $hDC, 'ptr', $hRgn, 'int', $iMode)

	If (@error) Or ($Ret[0] = 0) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_ExtSelectClipRgn

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_FatalExit
; Description....: Transfers execution control to the debugger.
; Syntax.........: _WinAPI_FatalExit ( $iCode )
; Parameters.....: $iCode  - The error code associated with the exit.
; Return values..: Success - 1.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ FatalExit
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_FatalExit($iCode)
	DllCall('kernel32.dll', 'none', 'FatalExit', 'int', $iCode)
	If @error Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_FatalExit

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_FileTimeToLocalFileTime
; Description....: Converts a file time to a local file time.
; Syntax.........: _WinAPI_FileTimeToLocalFileTime ( $tFILETIME )
; Parameters.....: $tFILETIME - $tagFILETIME structure containing the UTC-based file time to be converted into a local file time.
; Return values..: Success    - $tagFILETIME structure that contains the converted local file time.
;                  Failure    - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: This functions uses the current settings for the time zone and daylight saving time. Therefore, if it is daylight
;                  saving time, this function will take daylight saving time into account, even if the time you are converting is
;                  in standard time.
; Related........:
; Link...........: @@MsdnLink@@ FileTimeToLocalFileTime
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_FileTimeToLocalFileTime($tFILETIME)

	Local $tFILETIMELOCAL = DllStructCreate($tagFILETIME)
	Local $Ret = DllCall('kernel32.dll', 'int', 'FileTimeToLocalFileTime', 'ptr', DllStructGetPtr($tFILETIME), 'ptr', DllStructGetPtr($tFILETIMELOCAL))

	If (@error) Or ($Ret[0] = 0) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $tFILETIMELOCAL
EndFunc   ;==>_WinAPI_FileTimeToLocalFileTime

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_FileTimeToSystemTime
; Description....: Converts a file time to system time format.
; Syntax.........: _WinAPI_FileTimeToSystemTime ( $tFILETIME )
; Parameters.....: $tFILETIME - $tagFILETIME structure containing he file time to convert to system date and time format.
; Return values..: Success    - $tagSYSTEMTIME structure that contains the the converted file time.
;                  Failure    - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ FileTimeToSystemTime
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_FileTimeToSystemTime($tFILETIME)

	Local $tSYSTEMTIME = DllStructCreate($tagSYSTEMTIME)
	Local $Ret = DllCall('kernel32.dll', 'int', 'FileTimeToSystemTime', 'ptr', DllStructGetPtr($tFILETIME), 'ptr', DllStructGetPtr($tSYSTEMTIME))

	If (@error) Or ($Ret[0] = 0) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $tSYSTEMTIME
EndFunc   ;==>_WinAPI_FileTimeToSystemTime

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_FillRect
; Description....: Fills a rectangle by using the specified brush.
; Syntax.........: _WinAPI_FillRect ( $hDC, $tRECT, $hBrush )
; Parameters.....: $hDC    - Handle to the device context.
;                  $tRECT  - $tagRECT structure that contains the logical coordinates of the rectangle to be filled.
;                  $hBrush - Handle to the brush used to fill the rectangle.
; Return values..: Success - 1.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ FillRect
; Example........: Yes
; ===============================================================================================================================

#cs

Func _WinAPI_FillRect($hDC, $tRECT, $hBrush)

	Local $Ret = DllCall('user32.dll', 'int', 'FillRect', 'hwnd', $hDC, 'ptr', DllStructGetPtr($tRECT), 'ptr', $hBrush)

	If (@error) Or ($Ret[0] = 0) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_FillRect

#ce

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_FillRgn
; Description....: Fills a region by using the specified brush.
; Syntax.........: _WinAPI_FillRgn ( $hDC, $hRgn, $hBrush )
; Parameters.....: $hDC    - Handle to the device context.
;                  $hRgn   - Handle to the region to be filled. The region's coordinates are presumed to be in logical units.
;                  $hBrush - Handle to the brush to be used to fill the region.
; Return values..: Success - 1.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ FillRgn
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_FillRgn($hDC, $hRgn, $hBrush)

	Local $Ret = DllCall('gdi32.dll', 'int', 'FillRgn', 'hwnd', $hDC, 'ptr', $hRgn, 'ptr', $hBrush)

	If (@error) Or ($Ret[0] = 0) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_FillRgn

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_FillStruct
; Description....: Fills the structure with a specified value in the specified range.
; Syntax.........: _WinAPI_FillStruct ( ByRef $tStruct, $iValue [, $iBytes [, $iStart [, $iEnd]]] )
; Parameters.....: $tStruct - The structure to be filled that returned by DllStructCreate() function. It should contain a single
;                             element or element is an array. For example, "byte[32]", "int[8]", "int64[4]", etc.
;                  $iValue  - The value to be used to fill the structure. $iValue must be an integer, the chars are not allowed.
;                             To fill with a character use the Asc() or AscW() functions.
;                  $iBytes  - The number of bytes for each element required. It can be one of the following values: 1, 2, 4,
;                             or 8. For other values of this parameter the function is fails.
;                  $iStart  - The index of element in the structure to start filling at.
;                  $iEnd    - The index of element in the structure to stop filling at.
; Return values..: Success  - The number of elements that has been filled. If successful, the same ($iEnd - $iStart + 1).
;                  Failure  - 0 and sets the @error flag to one of the following values:
;                  |1 - $tStruct not a correct structure returned by DllStructCreate().
;                  |2 - $iByte value is incorrect.
;                  |3 - $iStart or $iEnd values outside of the structure.
;                  |4 - Failed to allocate the memory.
;                  |5 - Error filling structure.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: None
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_FillStruct(ByRef $tStruct, $iValue, $iBytes = 1, $iStart = 1, $iEnd = -1)

	Local $tData, $sData, $Count, $Size = DllStructGetSize($tStruct)

	If Not IsDllStruct($tStruct) Then
		Return SetError(1, 0, 0)
	EndIf

	Switch $iBytes
		Case 1
			$sData = 'byte'
		Case 2
			$sData = 'short'
		Case 4
			$sData = 'int'
		Case 8
			$sData = 'int64'
		Case Else
			Return SetError(2, 0, 0)
	EndSwitch
	$Count = Int($Size / $iBytes)
	If $iStart < 1 Then
		$iStart = 1
	EndIf
	If $iEnd < 0 Then
		$iEnd = $Count
	EndIf
	If ($iStart > $iEnd) Or ($iEnd > $Count) Then
		Return SetError(3, 0, 0)
	EndIf
	$tData = DllStructCreate($sData & '[' & $Count & ']', DllStructGetPtr($tStruct))
	If @error Then
		Return SetError(4, 0, 0)
	EndIf
	For $i = $iStart To $iEnd
		DllStructSetData($tData, 1, $iValue, $i)
		If @error Then
			Return SetError(5, 0, $i - $iStart)
		EndIf
	Next
	Return $iEnd - $iStart + 1
EndFunc   ;==>_WinAPI_FillStruct

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_FindResource
; Description....: Determines the location of a resource with the specified type and name in the specified module.
; Syntax.........: _WinAPI_FindResource ( $hInstance, $sName, $sType )
; Parameters.....: $hInstance - Handle to the module whose executable file contains the resource. A value of 0 specifies the module
;                               handle associated with the image file that the operating system used to create the current process.
;                  $sName     - The name of the resource. This parameter can be string or integer type.
;                  $sType     - The type of the resource. This parameter can be string or integer type.
; Return values..: Success    - Handle to the specified resource's information block. To obtain a handle to the resource, pass this
;                               handle to the _WinAPI_LoadResource() function.
;                  Failure    - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: If the first character of the string of the $sName or $sType parameter is a pound sign (#), the remaining
;                  characters represent a decimal number that specifies the integer identifier of the resource's name or type.
;                  For example, the string "#258" represents the integer identifier 258.
;
;                  To reduce the amount of memory required for a resource, an application should refer to it by integer identifier
;                  instead of by name.
;
;                  An application can use _WinAPI_FindResource() to find any type of resource, but this function should be used
;                  only if the application must access the binary resource data when making subsequent calls to _WinAPI_LockResource().
; Related........:
; Link...........: @@MsdnLink@@ FindResource
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_FindResource($hInstance, $sName, $sType)

	Local $TypeOfName = 'long', $TypeOfType = 'long'

	If IsString($sName) Then
		$TypeOfName = 'str'
	EndIf
	If IsString($sType) Then
		$TypeOfType = 'str'
	EndIf

	Local $Ret = DllCall('kernel32.dll', 'long', 'FindResource', 'long', $hInstance, $TypeOfName, $sName, $TypeOfType, $sType)

	If (@error) Or ($Ret[0] = 0) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_FindResource

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_FindResourceEx
; Description....: Determines the location of the resource with the specified type, name, and language in the specified module.
; Syntax.........: _WinAPI_FindResourceEx ( $hInstance, $sName, $sType, $iLanguage )
; Parameters.....: $hInstance - Handle to the module whose executable file contains the resource. A value of 0 specifies the module
;                               handle associated with the image file that the operating system used to create the current process.
;                  $sName     - The name of the resource. This parameter can be string or integer type.
;                  $sType     - The type of the resource. This parameter can be string or integer type.
;                  $iLanguage - The language of the resource (LCID constant).
; Return values..: Success    - Handle to the specified resource's information block. To obtain a handle to the resource, pass this
;                               handle to the _WinAPI_LoadResource() function.
;                  Failure    - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: If the first character of the string of the $sName or $sType parameter is a pound sign (#), the remaining
;                  characters represent a decimal number that specifies the integer identifier of the resource's name or type.
;                  For example, the string "#258" represents the integer identifier 258.
;
;                  To reduce the amount of memory required for a resource, an application should refer to it by integer identifier
;                  instead of by name.
;
;                  An application can use _WinAPI_FindResource() to find any type of resource, but this function should be used
;                  only if the application must access the binary resource data when making subsequent calls to _WinAPI_LockResource().
; Related........:
; Link...........: @@MsdnLink@@ FindResourceEx
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_FindResourceEx($hInstance, $sName, $sType, $iLanguage)

	Local $TypeOfName = 'long', $TypeOfType = 'long'

	If IsString($sName) Then
		$TypeOfName = 'str'
	EndIf
	If IsString($sType) Then
		$TypeOfType = 'str'
	EndIf

	Local $Ret = DllCall('kernel32.dll', 'long', 'FindResourceEx', 'long', $hInstance, $TypeOfType, $sType, $TypeOfName, $sName, 'short', $iLanguage)

	If (@error) Or ($Ret[0] = 0) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_FindResourceEx

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_FitToBitmap
; Description....: Changes the size of a bitmap to the specified dimensions.
; Syntax.........: _WinAPI_ResizeBitmap ( $hBitmap, $iWidth, $iHeight [, $iMode] )
; Parameters.....: $hBitmap - Handle to the bitmap to be resized.
;                  $iWidth  - The width, in pixels, in which the bitmap must fit.
;                  $iHeight - The height, in pixels, in which the bitmap must fit.
;                  $iMode   - The resizing mode. This parameter can be one of the following values (same as for
;                             _WinAPI_SetStretchBltMode()).
;
;                             $BLACKONWHITE
;                             $COLORONCOLOR
;                             $HALFTONE
;                             $WHITEONBLACK
;                             $STRETCH_ANDSCANS
;                             $STRETCH_DELETESCANS
;                             $STRETCH_HALFTONE
;                             $STRETCH_ORSCANS
;
; Return values..: Success  - Handle to the new bitmap that was created.
;                  Failure  - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: This function does not support bitmaps with Alpha channel, use _WinAPI_AlphaBlend() to work with them.
;
;                  When you are finished using the bitmap, destroy it using the _WinAPI_FreeObject() function. _WinAPI_ResizeBitmap()
;                  does not destroy the original bitmap, you must to destroy it.
; Related........:
; Link...........: None
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_FitToBitmap($hBitmap, $iWidth, $iHeight, $iMode = 3)

	Local $Ret, $tObj, $hBmp, $hDC, $hDestDC, $hDestSv, $hSrcDC, $hSrcSv

    $tObj = DllStructCreate($tagBITMAP)
	$Ret = DllCall('gdi32.dll', 'int', 'GetObject', 'int', $hBitmap, 'int', DllStructGetSize($tObj), 'ptr', DllStructGetPtr($tObj))
	If (@error) Or ($Ret[0] = 0) Then
		Return SetError(1, 0, 0)
	EndIf
	$Ret = DllCall('user32.dll', 'hwnd', 'GetDC', 'hwnd', 0)
	$hDC = $Ret[0]
	$Ret = DllCall('gdi32.dll', 'hwnd', 'CreateCompatibleDC', 'hwnd', $hDC)
	$hDestDC = $Ret[0]
	$Ret = DllCall('gdi32.dll', 'hwnd', 'CreateCompatibleBitmap', 'hwnd', $hDC, 'int', $iWidth, 'int', $iHeight)
	$hBmp = $Ret[0]
	$Ret = DllCall('gdi32.dll', 'hwnd', 'SelectObject', 'hwnd', $hDestDC, 'ptr', $hBmp)
	$hDestSv = $Ret[0]
	$Ret = DllCall('gdi32.dll', 'hwnd', 'CreateCompatibleDC', 'hwnd', $hDC)
	$hSrcDC = $Ret[0]
	$Ret = DllCall('gdi32.dll', 'hwnd', 'SelectObject', 'hwnd', $hSrcDC, 'ptr', $hBitmap)
	$hSrcSv = $Ret[0]
	_WinAPI_SetStretchBltMode($hDestDC, $iMode)
	$Ret = _WinAPI_StretchBlt($hDestDC, 0, 0, $iWidth, $iHeight, $hSrcDC, 0, 0, DllStructGetData($tObj, 'Width'), DllStructGetData($tObj, 'Height'), 0x00CC0020)
	DllCall('user32.dll', 'int', 'ReleaseDC', 'hwnd', 0, 'hwnd', $hDC)
	DllCall('gdi32.dll', 'ptr', 'SelectObject', 'hwnd', $hDestDC, 'ptr', $hDestSv)
	DllCall('gdi32.dll', 'ptr', 'SelectObject', 'hwnd', $hSrcDC, 'ptr', $hSrcSv)
	DllCall('gdi32.dll', 'int', 'DeleteDC', 'hwnd', $hDestDC)
	DllCall('gdi32.dll', 'int', 'DeleteDC', 'hwnd', $hSrcDC)
	If Not $Ret Then
		Return SetError(1, 0, 0)
	EndIf
	Return $hBmp
EndFunc   ;==>_WinAPI_FitToBitmap

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_FormatDriveDlg
; Description....: Opens the Shell's Format dialog.
; Syntax.........: _WinAPI_FormatDriveDlg ( $sDrive [, $iOption [, $hParent]] )
; Parameters.....: $sDrive  - The drive to format, in the format D:, E:, etc.
;                  $iOption - This parameter must be 0 or one of the following values that alter the default format options in the dialog.
;
;                             $SHFMT_OPT_FULL
;                             $SHFMT_OPT_QUICKFORMAT
;                             $SHFMT_OPT_SYSONLY
;
;                  $hParent - Handle of the parent window of the dialog.
; Return values..: Success  - 1.
;                  Failure  - 0 and sets the @error flag to one of the following constant.
;
;                             $SHFMT_ERROR
;                             $SHFMT_CANCEL
;                             $SHFMT_NOFORMAT
;
; Author.........: Yashied
; Modified.......:
; Remarks........: The format is controlled by the dialog interface. That is, the user must click the OK button to actually begin the
;                  format—the format cannot be started programmatically.
; Related........:
; Link...........: @@MsdnLink@@ SHFormatDrive
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_FormatDriveDlg($sDrive, $iOption = 0, $hParent = 0)

	If Not IsString($sDrive) Then
		Return SetError(-1, 0, 0)
	EndIf
	$sDrive = StringLeft(StringUpper(StringStripWS($sDrive, 1)), 1)
	If $sDrive = '' Then
		Return SetError(-1, 0, 0)
	EndIf
	$sDrive = Asc($sDrive) - 65
	If ($sDrive < 0) Or ($sDrive > 25) Then
		Return SetError(-1, 0, 0)
	EndIf

	Local $Ret = DllCall('shell32.dll', 'int', 'SHFormatDrive', 'hwnd', $hParent, 'uint', $sDrive, 'uint', $SHFMT_ID_DEFAULT, 'uint', $iOption)

	If @error Then
		Return SetError(-1, 0, 0)
	EndIf
	If $Ret[0] < 0 Then
		Return SetError($Ret[0], 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_FormatDriveDlg

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_FrameRect
; Description....: Draws a border around the specified rectangle by using the specified brush.
; Syntax.........: _WinAPI_FrameRect ( $hDC, $tRECT, $hBrush )
; Parameters.....: $hDC    - Handle to the device context in which the border is drawn.
;                  $tRECT  - $tagRECT structure that contains the logical coordinates of the upper-left and lower-right
;                            corners of the rectangle.
;                  $hBrush - Handle to the brush used to draw the border.
; Return values..: Success - 1.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ FrameRect
; Example........: Yes
; ===============================================================================================================================

#cs

Func _WinAPI_FrameRect($hDC, $tRECT, $hBrush)

	Local $Ret = DllCall('user32.dll', 'int', 'FrameRect', 'hwnd', $hDC, 'ptr', DllStructGetPtr($tRECT), 'ptr', $hBrush)

	If (@error) Or ($Ret[0] = 0) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_FrameRect

#ce

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_FrameRgn
; Description....: Draws a border around the specified region by using the specified brush.
; Syntax.........: _WinAPI_FrameRgn ( $hDC, $hRgn, $hBrush, $iWidth, $iHeight )
; Parameters.....: $hDC     - Handle to the device context.
;                  $hRgn    - Handle to the region to be enclosed in a border. The region's coordinates are presumed to be in
;                             logical units.
;                  $hBrush  - Handle to the brush to be used to draw the border.
;                  $iWidth  - The width, in logical units, of vertical brush strokes.
;                  $iHeight - The height, in logical units, of horizontal brush strokes.
; Return values..: Success  - 1.
;                  Failure  - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ FrameRgn
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_FrameRgn($hDC, $hRgn, $hBrush, $iWidth, $iHeight)

	Local $Ret = DllCall('gdi32.dll', 'int', 'FrameRgn', 'hwnd', $hDC, 'ptr', $hRgn, 'ptr', $hBrush, 'int', $iWidth, 'int', $iHeight)

	If (@error) Or ($Ret[0] = 0) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_FrameRgn

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_FreeCursor
; Description....: Destroys a cursor and frees any memory the cursor occupied.
; Syntax.........: _WinAPI_FreeCursor ( $hCursor )
; Parameters.....: $hCursor - Handle to the cursor to be destroyed. The cursor must not be in use.
; Return values..: Success  - 1.
;                  Failure  - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: This function destroys a nonshared cursor. Do not use this function to destroy a shared cursor. A shared cursor
;                  is valid as long as the module from which it was loaded remains in memory.
; Related........:
; Link...........: @@MsdnLink@@ DestroyCursor
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_FreeCursor($hCursor)

	Local $Ret = DllCall('user32.dll', 'int', 'DestroyCursor', 'ptr', $hCursor)

	If (@error) Or ($Ret[0] = 0) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_FreeCursor

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_FreeHandle
; Description....: Closes an open object handle.
; Syntax.........: _WinAPI_FreeHandle ( $hObject )
; Parameters.....: $hObject - Handle to an open object.
; Return values..: Success  - 1.
;                  Failure  - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: The _WinAPI_FreeHandle() function closes handles to the following objects:
;
;                  Access token
;                  Communications device
;                  Console input
;                  Console screen buffer
;                  Event
;                  File
;                  File mapping
;                  I/O completion port
;                  Job
;                  Mailslot
;                  Memory resource notification
;                  Mutex
;                  Named pipe
;                  Pipe
;                  Process
;                  Semaphore
;                  Thread
;                  Transaction
;                  Waitable timer
;
; Related........:
; Link...........: @@MsdnLink@@ CloseHandle
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_FreeHandle($hObject)

	Local $Ret = DllCall('kernel32.dll', 'int', 'CloseHandle', 'ptr', $hObject)

	If (@error) Or ($Ret[0] = 0) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_FreeHandle

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_FreeIcon
; Description....: Destroys an icon and frees any memory the icon occupied.
; Syntax.........: _WinAPI_FreeIcon ( $hIcon )
; Parameters.....: $hIcon  - Handle to the icon to be destroyed.
; Return values..: Success - 1.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: Do not use this function to destroy a shared icon. A shared icon is valid as long as the module from which it
;                  was loaded remains in memory.
; Related........:
; Link...........: @@MsdnLink@@ DestroyIcon
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_FreeIcon($hIcon)

	Local $Ret = DllCall('user32.dll', 'int', 'DestroyIcon', 'ptr', $hIcon)

	If (@error) Or ($Ret[0] = 0) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_FreeIcon

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_FreeObject
; Description....: Deletes a logical pen, brush, font, bitmap, region, or palette.
; Syntax.........: _WinAPI_FreeObject ( $hObject )
; Parameters.....: $hObject - Handle to a logical pen, brush, font, bitmap, region, or palette.
; Return values..: Success  - 1.
;                  Failure  - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: Do not delete a drawing object (pen or brush) while it is still selected into a DC. When a pattern brush is deleted,
;                  the bitmap associated with the brush is not deleted. The bitmap must be deleted independently.
; Related........:
; Link...........: @@MsdnLink@@ DeleteObject
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_FreeObject($hObject)

	Local $Ret = DllCall('gdi32.dll', 'int', 'DeleteObject', 'int', $hObject)

	If (@error) Or ($Ret[0] = 0) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_FreeObject

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_FreeResource
; Description....: Decrements (decreases by one) the reference count of a loaded resource.
; Syntax.........: _WinAPI_FreeResource ( $hData )
; Parameters.....: $hData  - Handle of the resource was created by _WinAPI_LoadResource().
; Return values..: Success - 1.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: The reference count for a resource is incremented (increased by one) each time an application calls the
;                  _WinAPI_LoadResource() function for the resource. This function is obsolete and is only supported for backward
;                  compatibility with 16-bit Microsoft Windows. For 32-bit Windows applications, it is not necessary to free the
;                  resources loaded using function _WinAPI_LoadResource().
; Related........:
; Link...........: @@MsdnLink@@ FreeResource
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_FreeResource($hData)

	Local $Ret = DllCall('kernel32.dll', 'int', 'FreeResource', 'long', $hData)

	If (@error) Or ($Ret[0] = 0) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_FreeResource

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetActiveWindow
; Description....: Retrieves the window handle to the active window attached to the calling process's message queue.
; Syntax.........: _WinAPI_GetActiveWindow ( )
; Parameters.....: None
; Return values..: Success - Handle to the active window attached to the calling process's message queue.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ GetActiveWindow
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_GetActiveWindow()

	Local $Ret = DllCall('user32.dll', 'hwnd', 'GetActiveWindow')

	If @error Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_GetActiveWindow

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetBitmapDimension
; Description....: Retrieves a dimension for the specified bitmap.
; Syntax.........: _WinAPI_GetBitmapDimension ( $hBitmap )
; Parameters.....: $hBitmap - Handle to the bitmap to retrieve dimension.
; Return values..: Success  - $tagSIZE structure that contains the bitmap dimension.
;                  Failure  - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: None
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_GetBitmapDimension($hBitmap)

    Local $tObj = DllStructCreate($tagBITMAP)
	Local $Ret = DllCall('gdi32.dll', 'int', 'GetObject', 'int', $hBitmap, 'int', DllStructGetSize($tObj), 'ptr', DllStructGetPtr($tObj))

	If (@error) Or ($Ret[0] = 0) Then
		Return SetError(1, 0, 0)
	EndIf

	Local $tSIZE = DllStructCreate($tagSIZE)

	DllStructSetData($tSIZE, 'X', DllStructGetData($tObj, 'Width'))
	DllStructSetData($tSIZE, 'Y', DllStructGetData($tObj, 'Height'))

	Return SetError(0, 0, $tSIZE)
EndFunc   ;==>_WinAPI_GetBitmapDimension

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetBkColor
; Description....: Retrieves the current background color for the specified device context.
; Syntax.........: _WinAPI_GetBkColor ( $hDC )
; Parameters.....: $hDC    - Handle to the device context.
; Return values..: Success - The value of the current background color, in RGB.
;                  Failure - (-1) and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ GetBkColor
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_GetBkColor($hDC)

	Local $Ret = DllCall('gdi32.dll', 'int', 'GetBkColor', 'hwnd', $hDC)

	If (@error) Or ($Ret[0] < 0) Then
		Return SetError(1, 0, -1)
	EndIf
	Return __CheckColor($Ret[0])
EndFunc   ;==>_WinAPI_GetBkColor

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetBValue
; Description....: Retrieves an intensity value for the blue component of a 32-bit RGB value.
; Syntax.........: _WinAPI_GetBValue ( $iRGB )
; Parameters.....: $iRGB - The color value, in RGB.
; Return values..: The intensity of the blue component of the specified RGB color.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: None
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_GetBValue($iRGB)
	Return BitAND(__CheckColor($iRGB), 0x0000FF)
EndFunc   ;==>_WinAPI_GetBValue

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetClassLong
; Description....: Retrieves the specified 32-bit (long) value associated with the specified window.
; Syntax.........: _WinAPI_GetClassLong ( $hWnd, $iIndex )
; Parameters.....: $hWnd   - Handle to the window and, indirectly, the class to which the window belongs.
;                  $iIndex - The 32-bit value to retrieve. This parameter can be one of the following values.
;
;                            $GCL_CBCLSEXTRA
;                            $GCL_CBWNDEXTRA
;                            $GCL_HBRBACKGROUND
;                            $GCL_HCURSOR
;                            $GCL_HICON
;                            $GCL_HICONSM
;                            $GCL_HMODULE
;                            $GCL_MENUNAME
;                            $GCL_STYLE
;                            $GCL_WNDPROC
;
; Return values..: Success - The value is the requested 32-bit value.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ GetClassLong
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_GetClassLong($hWnd, $iIndex)

	Local $Ret = DllCall('user32.dll', 'int', 'GetClassLong', 'hwnd', $hWnd, 'int', $iIndex)

	If (@error) Or ($Ret[0] = 0) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_GetClassLong

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetCompression
; Description....: Retrieves the current compression state of a file or directory.
; Syntax.........: _WinAPI_GetCompression ( $sPath )
; Parameters.....: $sPath  - Path to file or directory to retrieve compression state.
; Return values..: Success - The current compression state.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ FSCTL_GET_COMPRESSION
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_GetCompression($sPath)

	Local $hFile = _WinAPI_CreateFileEx($sPath, 3, 0x80000000, 0x01, 0x02000000)

	If Not $hFile Then
		Return SetError(1, 0, 0)
	EndIf

	Local $tData = DllStructCreate('ushort')
	Local $Ret = DllCall('kernel32.dll', 'int', 'DeviceIoControl', 'ptr', $hFile, 'dword', 0x0009003C, 'ptr', 0, 'dword', 0, 'ptr', DllStructGetPtr($tData), 'dword', DllStructGetSize($tData), 'dword*', 0, 'ptr', 0)

	If (@error) Or ($Ret[0] = 0) Then
		$Ret = 0
	EndIf
	_WinAPI_FreeHandle($hFile)
	If Not IsArray($Ret) Then
		Return SetError(2, 0, 0)
	EndIf
	Return SetError(0, 0, DllStructGetData($tData, 1))
EndFunc   ;==>_WinAPI_GetCompression

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetCurrentDirectory
; Description....: Retrieves the current directory for the current process.
; Syntax.........: _WinAPI_GetCurrentDirectory ( )
; Parameters.....: None
; Return values..: Success - The absolute path to the current directory.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ GetCurrentDirectory
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_GetCurrentDirectory()

	Local $tData = DllStructCreate('wchar[1024]')
	Local $Ret = DllCall('kernel32.dll', 'int', 'GetCurrentDirectoryW', 'dword', 1024, 'ptr', DllStructGetPtr($tData))

	If (@error) Or ($Ret[0] = 0) Then
		Return SetError(1, 0, 0)
	EndIf
	Return DllStructGetData($tData, 1)
EndFunc   ;==>_WinAPI_GetCurrentDirectory

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetCursor
; Description....: Retrieves a handle to the current cursor.
; Syntax.........: _WinAPI_GetCursor ( )
; Parameters.....: None
; Return values..: Success - Handle to the current cursor. If there is no cursor, the return value is 0.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ GetCursor
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_GetCursor()

	Local $Ret = DllCall('user32.dll', 'ptr', 'GetCursor')

	If @error Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_GetCursor

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetDefaultPrinter
; Description....: Retrieves the printer name of the default printer for the current user on the local computer.
; Syntax.........: _WinAPI_GetDefaultPrinter ( )
; Parameters.....: None
; Return values..: Success - String containing the default printer name.
;                  Failure - Empty string and sets the @error flag to:
;                            1 - Function fails or not found
;                            2 - No default printer
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ GetDefaultPrinter
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_GetDefaultPrinter()

	Local $Ret

	$Ret = DllCall('winspool.drv', 'int', 'GetDefaultPrinterW', 'ptr', 0, 'dword*', 0)
    If (@error) Or ($Ret[2] = 0) Then
		Return SetError(1 + (_WinAPI_GetLastError() = 0x02), 0, '')
	EndIf

	Local $tData = DllStructCreate('wchar[' & $Ret[2] & ']')

	$Ret = DllCall('winspool.drv', 'int', 'GetDefaultPrinterW', 'ptr', DllStructGetPtr($tData), 'dword*', $Ret[2])
    If (@error) Or ($Ret[0] = 0) Then
		Return SetError(1 + (_WinAPI_GetLastError() = 0x02), 0, '')
	EndIf
    Return DllStructGetData($tData, 1)
EndFunc   ;==>_WinAPI_GetDefaultPrinter

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetDiskFreeSpaceEx
; Description....: Retrieves information about the amount of space that is available on a disk volume.
; Syntax.........: _WinAPI_GetDiskFreeSpaceEx ( $sDrive )
; Parameters.....: $sDrive - The drive to retrieve information, in the format D:, E:, etc.
; Return values..: Success - The array containing the following parameters:
;                            [0] - The total number of available free bytes on a disk. If per-user quotas are being used, this value
;                                  may be less than the total number of free bytes on a disk.
;                            [1] - The total number of available bytes on a disk. If per-user quotas are being used, this value
;                                  may be less than the total number of bytes on a disk.
;                            [2] - The total number of free bytes on a disk.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ GetDiskFreeSpaceEx
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_GetDiskFreeSpaceEx($sDrive)

	Local $tFreeBytesAvailable = DllStructCreate('int64')
	Local $tTotalNumberOfBytes = DllStructCreate('int64')
	Local $tTotalNumberOfFreeBytes = DllStructCreate('int64')
	Local $Ret = DllCall('kernel32.dll', 'int', 'GetDiskFreeSpaceEx', 'str', $sDrive, 'ptr', DllStructGetPtr($tFreeBytesAvailable), 'ptr', DllStructGetPtr($tTotalNumberOfBytes), 'ptr', DllStructGetPtr($tTotalNumberOfFreeBytes))

	If (@error) Or ($Ret[0] = 0) Then
		Return SetError(1, 0, 0)
	EndIf

	Local $Result[3]

	$Result[0] = DllStructGetData($tFreeBytesAvailable, 1)
	$Result[1] = DllStructGetData($tTotalNumberOfBytes, 1)
	$Result[2] = DllStructGetData($tTotalNumberOfFreeBytes, 1)

	Return $Result
EndFunc   ;==>_WinAPI_GetDiskFreeSpaceEx

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetDriveBusType
; Description....: Retrieves a bus type for the specified drive.
; Syntax.........: _WinAPI_GetDriveBusType ( $sDrive )
; Parameters.....: $sDrive - The drive letter to retrieve information, in the format D:, E:, etc.
; Return values..: Success - The bus type constant ($DRIVE_BUS_TYPE_...).
;                  Failure - (-1) and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: This function works with the Plug and Play drivers only.
; Related........:
; Link...........: @@MsdnLink@@ IOCTL_STORAGE_QUERY_PROPERTY
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_GetDriveBusType($sDrive)

	Local $hFile = _WinAPI_CreateFile('\\.\' & $sDrive, 2, 0, 0)

	If $hFile = 0 Then
		Return SetError(1, 0, -1)
	EndIf

	Local $tSTORAGE_PROPERTY_QUERY = DllStructCreate('dword;dword;byte[4]')
	Local $tSTORAGE_DEVICE_DESCRIPTOR = DllStructCreate('ulong;ulong;byte;byte;byte;byte;ulong;ulong;ulong;ulong;dword;ulong;byte[512]')
	Local $Ret = DllCall('kernel32.dll', 'int', 'DeviceIoControl', 'ptr', $hFile, 'dword', 0x002D1400, 'ptr', DllStructGetPtr($tSTORAGE_PROPERTY_QUERY), 'dword', DllStructGetSize($tSTORAGE_PROPERTY_QUERY), 'ptr', DllStructGetPtr($tSTORAGE_DEVICE_DESCRIPTOR), 'dword', DllStructGetSize($tSTORAGE_DEVICE_DESCRIPTOR), 'dword*', 0, 'ptr', 0)

	If (@error) Or ($Ret[0] = 0) Then
		$Ret = 0
	EndIf
	_WinAPI_FreeHandle($hFile)
	If Not IsArray($Ret) Then
		Return SetError(2, 0, -1)
	EndIf
	Return SetError(0, 0, DllStructGetData($tSTORAGE_DEVICE_DESCRIPTOR, 11))
EndFunc   ;==>_WinAPI_GetDriveBusType

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetDriveGeometryEx
; Description....: Retrieves extended information about the disk's geometry.
; Syntax.........: _WinAPI_GetDriveGeometryEx ( $iDrive )
; Parameters.....: $iDrive - The drive letter to retrieve information, in the format D:, E:, etc.
; Return values..: Success - $tagDISK_GEOMETRY_EX structure that contains the information about the disk's geometry.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ IOCTL_DISK_GET_DRIVE_GEOMETRY_EX
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_GetDriveGeometryEx($iDrive)

	Local $hFile = _WinAPI_CreateFile('\\.\PhysicalDrive' & $iDrive, 2, 2, 2)

	If $hFile = 0 Then
		Return SetError(1, 0, 0)
	EndIf

	Local $tDISK_GEOMETRY_EX = DllStructCreate($tagDISK_GEOMETRY_EX)
	Local $Ret = DllCall('kernel32.dll', 'int', 'DeviceIoControl', 'ptr', $hFile, 'dword', 0x000700A0, 'ptr', 0, 'dword', 0, 'ptr', DllStructGetPtr($tDISK_GEOMETRY_EX), 'dword', DllStructGetSize($tDISK_GEOMETRY_EX), 'dword*', 0, 'ptr', 0)

	If (@error) Or ($Ret[0] = 0) Then
		$Ret = 0
	EndIf
	_WinAPI_FreeHandle($hFile)
	If Not IsArray($Ret) Then
		Return SetError(2, 0, 0)
	EndIf
	Return SetError(0, 0, $tDISK_GEOMETRY_EX)
EndFunc   ;==>_WinAPI_GetDriveGeometryEx

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetDriveNumber
; Description....: Retrieves a device type, device number, and partition number for the specified drive.
; Syntax.........: _WinAPI_GetDriveNumber ( $sDrive )
; Parameters.....: $sDrive - The drive letter to retrieve information, in the format D:, E:, etc.
; Return values..: Success - $tagSTORAGE_DEVICE_NUMBER structure that contains the relevant information.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ IOCTL_STORAGE_GET_DEVICE_NUMBER
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_GetDriveNumber($sDrive)

	Local $hFile = _WinAPI_CreateFile('\\.\' & $sDrive, 2, 0, 0)

	If $hFile = 0 Then
		Return SetError(1, 0, 0)
	EndIf

	Local $tSTORAGE_DEVICE_NUMBER = DllStructCreate($tagSTORAGE_DEVICE_NUMBER)
	Local $Ret = DllCall('kernel32.dll', 'int', 'DeviceIoControl', 'ptr', $hFile, 'dword', 0x002D1080, 'ptr', 0, 'dword', 0, 'ptr', DllStructGetPtr($tSTORAGE_DEVICE_NUMBER), 'dword', DllStructGetSize($tSTORAGE_DEVICE_NUMBER), 'dword*', 0, 'ptr', 0)

	If (@error) Or ($Ret[0] = 0) Then
		$Ret = 0
	EndIf
	_WinAPI_FreeHandle($hFile)
	If Not IsArray($Ret) Then
		Return SetError(2, 0, 0)
	EndIf
	Return SetError(0, 0, $tSTORAGE_DEVICE_NUMBER)
EndFunc   ;==>_WinAPI_GetDriveNumber

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetDriveType
; Description....: Determines whether a disk drive is a removable, fixed, CD-ROM, RAM disk, or network drive.
; Syntax.........: _WinAPI_GetDriveType( [$sDrive] )
; Parameters.....: $sDrive - The drive letter to retrieve information, in the format D:, E:, etc.
; Return values..: Success - The type of drive ($DRIVE_...).
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ GetDriveType
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_GetDriveType($sDrive = '')

	Local $tDrive, $pDrive = 0

	$sDrive = StringStripWS($sDrive, 3)
	If $sDrive > '' Then
		$tDrive = DllStructCreate('char[' & StringLen($sDrive) + 1 & ']')
		DllStructSetData($tDrive, 1, $sDrive)
		$pDrive = DllStructGetPtr($tDrive)
	EndIf

	Local $Ret = DllCall('kernel32.dll', 'int', 'GetDriveType', 'ptr', $pDrive)

	If @error Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_GetDriveType

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetFontResourceInfo
; Description....: Retrieves the fontname from the specified font resource file.
; Syntax.........: _WinAPI_GetFontResourceInfo ( $sFont [, $fForce] )
; Parameters.....: $sFont  - String that names a font resource file. To retrieve a fontname whose information comes from several
;                            resource files, they must be separated by a "|" . For example, abcxxxxx.pfm | abcxxxxx.pfb.
;                  $fForce - Specifies whether adds a file to the font table, valid values:
;                  |TRUE   - Forced add the specified file to the system font table and remove it after retrieving the fontname.
;                  |FALSE  - Don`t add and remove. (Default)
; Return values..: Success - The name of the font.
;                  Failure - Empty string and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: None
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_GetFontResourceInfo($sFont, $fForce = 0)

	If $fForce Then
		If Not _WinAPI_AddFontResource($sFont) Then
			Return SetError(1, 0, '')
		EndIf
	EndIf

	Local $tData = DllStructCreate('wchar[1024]')
	Local $Ret = DllCall('gdi32.dll', 'int', 'GetFontResourceInfoW','wstr', $sFont, 'int*', 1024, 'ptr', DllStructGetPtr($tData), 'int', 0x01)

	If (@error) Or ($Ret[0] = 0) Then
		$Ret = 0
	EndIf
	If $fForce Then
		_WinAPI_RemoveFontResource($sFont)
	EndIf
	If Not IsArray($Ret) Then
		Return SetError(1, 0, '')
	EndIf
	Return SetError(0, 0, DllStructGetData($tData, 1))
EndFunc   ;==>_WinAPI_GetFontResourceInfo

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetForegroundWindow
; Description....: Returns a handle to the foreground window.
; Syntax.........: _WinAPI_GetForegroundWindow ( )
; Parameters.....: None
; Return values..: Success - Handle to the foreground window.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ GetForegroundWindow
; Example........: Yes
; ===============================================================================================================================

#cs

Func _WinAPI_GetForegroundWindow()

	Local $Ret = DllCall('user32.dll', 'hwnd', 'GetForegroundWindow')

	If @error Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_GetForegroundWindow

#ce

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetGValue
; Description....: Retrieves an intensity value for the green component of a 32-bit RGB value.
; Syntax.........: _WinAPI_GetGValue ( $iRGB )
; Parameters.....: $iRGB - The color value, in RGB.
; Return values..: The intensity of the green component of the specified RGB color.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: None
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_GetGValue($iRGB)
	Return BitShift(BitAND(__CheckColor($iRGB), 0x00FF00), 8)
EndFunc   ;==>_WinAPI_GetGValue

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetHandleInformation
; Description....: Retrieves certain properties of an object handle.
; Syntax.........: _WinAPI_GetHandleInformation ( $hObject )
; Parameters.....: $hObject - Handle to an object whose information is to be retrieved.
; Return values..: Success  - The value specifies the properties of the object handle ($HANDLE_FLAG_...).
;                  Failure  - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ GetHandleInformation
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_GetHandleInformation($hObject)

	Local $Ret = DllCall('kernel32.dll', 'int', 'GetHandleInformation', 'ptr', $hObject, 'dword*', 0)

	If (@error) Or ($Ret[0] = 0) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[2]
EndFunc   ;==>_WinAPI_GetHandleInformation

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetIconBitmap
; Description....: Retrieves icon color bitmap for the specified icon.
; Syntax.........: _WinAPI_GetIconBitmap ( $hIcon )
; Parameters.....: $hIcon  - Handle to the icon to retrieve bitmap.
; Return values..: Success - Handle to the bitmap.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: The calling application must manage this bitmap and delete when it are no longer necessary.
; Related........:
; Link...........: @@MsdnLink@@ GetIconInfo
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_GetIconBitmap($hIcon)

	Local $tICONINFO = DllStructCreate($tagICONINFO)
	Local $Ret = DllCall('user32.dll', 'int', 'GetIconInfo', 'ptr', $hIcon, 'ptr', DllStructGetPtr($tICONINFO))

	If (@error) Or ($Ret[0] = 0) Then
		Return SetError(1, 0, 0)
	EndIf
	_WinAPI_FreeObject(DllStructGetData($tICONINFO, 4))
	Return SetError(0, 0, DllStructGetData($tICONINFO, 5))
EndFunc   ;==>_WinAPI_GetIconBitmap

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetIconDimension
; Description....: Retrieves a dimension for the specified icon.
; Syntax.........: _WinAPI_GetIconDimension ( $hIcon )
; Parameters.....: $hIcon  - Handle to the icon to retrieve dimension.
; Return values..: Success - $tagSIZE structure that contains the icon dimension.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: None
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_GetIconDimension($hIcon)

	Local $hBitmap = _WinAPI_GetIconBitmap($hIcon)
	Local $tSIZE = _WinAPI_GetBitmapDimension($hBitmap)

	_WinAPI_FreeObject($hBitmap)
	Return SetError(0, 0, $tSIZE)
EndFunc   ;==>_WinAPI_GetIconDimension

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetIconMask
; Description....: Retrieves icon bitmask bitmap for the specified icon.
; Syntax.........: _WinAPI_GetIconMask ( $hIcon )
; Parameters.....: $hIcon  - Handle to the icon to retrieve bitmap.
; Return values..: Success - Handle to the bitmap.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: The calling application must manage this bitmap and delete when it are no longer necessary.
; Related........:
; Link...........: @@MsdnLink@@ GetIconInfo
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_GetIconMask($hIcon)

	Local $tICONINFO = DllStructCreate($tagICONINFO)
	Local $Ret = DllCall('user32.dll', 'int', 'GetIconInfo', 'ptr', $hIcon, 'ptr', DllStructGetPtr($tICONINFO))

	If (@error) Or ($Ret[0] = 0) Then
		Return SetError(1, 0, 0)
	EndIf
	_WinAPI_FreeObject(DllStructGetData($tICONINFO, 5))
	Return SetError(0, 0, DllStructGetData($tICONINFO, 4))
EndFunc   ;==>_WinAPI_GetIconMask

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetIdleTime
; Description....: Retrieves the time that has elapsed since the last input.
; Syntax.........: _WinAPI_GetIdleTime ( )
; Parameters.....: None
; Return values..: Success - The elapsed time, in milliseconds.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ GetLastInputInfo
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_GetIdleTime()

	Local $tLASTINPUTINFO = DllStructCreate('uint;dword')

	DllStructSetData($tLASTINPUTINFO, 1, DllStructGetSize($tLASTINPUTINFO))

	Local $Ret = DllCall('user32.dll', 'int', 'GetLastInputInfo', 'ptr', DllStructGetPtr($tLASTINPUTINFO))

	If (@error) Or ($Ret[0] = 0) Then
		Return SetError(1, 0, 0)
	EndIf
	Return _WinAPI_GetTickCount() - DllStructGetData($tLASTINPUTINFO, 2)
EndFunc   ;==>_WinAPI_GetIdleTime

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetKeyboardLayout
; Description....: Retrieves the active input locale identifier for the specified window.
; Syntax.........: _WinAPI_GetKeyboardLayout ( $hWnd )
; Parameters.....: $hWnd   - Handle to the window to retrieve the input locale identifier.
; Return values..: Success - The input locale identifier.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ GetKeyboardLayout
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_GetKeyboardLayout($hWnd)

	Local $Ret

	$Ret = DllCall('user32.dll', 'long', 'GetWindowThreadProcessId', 'hwnd', $hWnd, 'ptr', 0)
	If (@error) Or ($Ret[0] = 0) Then
		Return SetError(1, 0, 0)
	EndIf
	$Ret = DllCall('user32.dll', 'long', 'GetKeyboardLayout', 'long', $Ret[0])
	If (@error) Or ($Ret[0] = 0) Then
		Return SetError(1, 0, 0)
	EndIf
	Return BitAND($Ret[0], 0xFFFF)
EndFunc   ;==>_WinAPI_GetKeyboardLayout

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetKeyboardLayoutList
; Description....: Retrieves the all input locale identifiers corresponding to the current set of input locales in the system.
; Syntax.........: _WinAPI_GetKeyboardLayoutList ( )
; Parameters.....: None
; Return values..: Success - Array of input locale identifiers. The zeroth array element contains the number of identifiers.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ GetKeyboardLayoutList
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_GetKeyboardLayoutList()

	Local $Ret

	$Ret = DllCall('user32.dll', 'int', 'GetKeyboardLayoutList', 'int', 0, 'ptr', 0)
	If (@error) Or ($Ret[0] = 0) Then
		Return SetError(1, 0, 0)
	EndIf

	Local $tData = DllStructCreate('ptr[' & $Ret[0] & ']')

	$Ret = DllCall('user32.dll', 'int', 'GetKeyboardLayoutList', 'int', $Ret[0], 'ptr', DllStructGetPtr($tData))
	If (@error) Or ($Ret[0] = 0) Then
		Return SetError(1, 0, 0)
	EndIf

	Local $List[$Ret[0] + 1] = [$Ret[0]]

	For $i = 1 To $List[0]
		$List[$i] = BitAND(DllStructGetData($tData, 1, $i), 0xFFFF)
	Next
	Return $List
EndFunc   ;==>_WinAPI_GetKeyboardLayoutList

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetKeyboardState
; Description....: Copies the status of the 256 virtual keys to the specified buffer.
; Syntax.........: _WinAPI_GetKeyboardState ( )
; Parameters.....: None
; Return values..: Success - The structure of "byte[256]" that receives the status data for each virtual key.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: An application can call this function to retrieve the current status of all the virtual keys. The status changes
;                  as a process removes keyboard messages from its message queue. The status does not change as keyboard messages are
;                  posted to the process's message queue, nor does it change as keyboard messages are posted to or retrieved from
;                  message queues of other processes.
;
;                  When the function returns, each member of the array contains status data for a virtual key. If the high-order
;                  bit is 1, the key is down; otherwise, it is up. If the key is a toggle key, for example CAPS LOCK, then the
;                  low-order bit is 1 when the key is toggled and is 0 if the key is untoggled. The low-order bit is meaningless for
;                  non-toggle keys. A toggle key is said to be toggled when it is turned on. A toggle key's indicator light (if any)
;                  on the keyboard will be on when the key is toggled, and off when the key is untoggled.
;
;                  To retrieve status information for an individual key, use the _WinAPI_GetKeyState() function. To retrieve the
;                  current state for an individual key regardless of whether the corresponding keyboard message has been retrieved
;                  from the message queue, use the _WinAPI_GetAsyncKeyState() function.
;
; Related........:
; Link...........: @@MsdnLink@@ GetKeyboardState
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_GetKeyboardState()

	Local $tData = DllStructCreate('byte[256]')
	Local $Ret = DllCall('user32.dll', 'int', 'GetKeyboardState', 'ptr', DllStructGetPtr($tData))

	If (@error) Or ($Ret[0] = 0) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $tData
EndFunc   ;==>_WinAPI_GetKeyboardState

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetKeyNameText
; Description....: Retrieves a string that represents the name of a key.
; Syntax.........: _WinAPI_GetKeyNameText ( $lParam )
; Parameters.....: $lParam - Specifies the second parameter of the keyboard message (such as WM_KEYDOWN) to be processed.
; Return values..: Success - String containing the name of the key.
;                  Failure - Empty string and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: The format of the key-name string depends on the current keyboard layout. The keyboard driver maintains a list
;                  of names in the form of character strings for keys with names longer than a single character. The key name
;                  is translated according to the layout of the currently installed keyboard, thus the function may give different
;                  results for different input locales. The name of a character key is the character itself. The names of dead
;                  keys are spelled out in full.
; Related........:
; Link...........: @@MsdnLink@@ GetKeyNameText
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_GetKeyNameText($lParam)

	Local $tData = DllStructCreate('wchar[128]')
	Local $Ret = DllCall('user32.dll', 'int', 'GetKeyNameTextW', 'long', $lParam, 'ptr', DllStructGetPtr($tData), 'int', 128)

	If (@error) Or ($Ret[0] = 0) Then
		Return SetError(1, 0, '')
	EndIf
	Return DllStructGetData($tData, 1)
EndFunc   ;==>_WinAPI_GetKeyNameText

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetKeyState
; Description....: Retrieves the status of the specified virtual key.
; Syntax.........: _WinAPI_GetKeyState ( $vkCode )
; Parameters.....: $vkCode - Specifies a virtual key ($VK_...). If the desired virtual key is a letter or digit (A through Z,
;                            a through z, or 0 through 9).
; Return values..: Success - The value specifies the status of the specified virtual key. If the high-order bit is 1, the key is
;                            down; otherwise, it is up. If the low-order bit is 1, the key is toggled. A key, such as the
;                            CAPS LOCK key, is toggled if it is turned on. The key is off and untoggled if the low-order bit is 0.
;                            A toggle key's indicator light (if any) on the keyboard will be on when the key is toggled, and off
;                            when the key is untoggled.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: The key status returned from this function changes as a process reads key messages from its message queue.
;                  The status does not reflect the interrupt-level state associated with the hardware. Use the _WinAPI_GetAsyncKeyState()
;                  function to retrieve that information.
; Related........:
; Link...........: @@MsdnLink@@ GetKeyState
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_GetKeyState($vkCode)

	Local $Ret = DllCall('user32.dll', 'int', 'GetKeyState', 'int', $vkCode)

	If @error Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_GetKeyState

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetLayeredWindowAttributes
; Description....: Retrieves the opacity and transparency color key of a layered window.
; Syntax.........: _WinAPI_GetLayeredWindowAttributes ( $hWnd )
; Parameters.....: $hWnd   - Handle to the layered window.
; Return values..: Success - The array containing the following parameters:
;                            [0] - The transparency color key to be used when composing the layered window. All pixels painted
;                                  by the window in this color will be transparent. This can be NULL if the argument is not needed.
;                            [1] - The Alpha value used to describe the opacity of the layered window. When the variable is 0,
;                                  the window is completely transparent. When the variable is 255, the window is opaque.
;                                  This can be 0 if the argument is not needed.
;                            [2] - The layering flag ($LWA...).
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: ProgAndy
; Modified.......: Yashied
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ GetLayeredWindowAttributes
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_GetLayeredWindowAttributes($hWnd)

	Local $Ret = DllCall('user32.dll', 'int', 'GetLayeredWindowAttributes', 'hwnd', $hWnd, 'long*', 0, 'byte*', 0, 'long*', 0)

	If (@error) Or ($Ret[0] = 0) Then
		Return SetError(1, 0, 0)
	EndIf

	Local $Result[3]

	$Result[0] = __CheckColor($Ret[2])
	$Result[1] = $Ret[3]
	$Result[2] = $Ret[4]

	Return $Result
EndFunc   ;==>_WinAPI_GetLayeredWindowAttributes

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetLocaleInfo
; Description....: Retrieves information about a locale specified by identifier.
; Syntax.........: _WinAPI_GetLocaleInfo ( $iLocale, $iType )
; Parameters.....: $iLocale - Locale identifier for which to retrieve information.
;                  $iType   - The one of the locale information constants ($LOCALE_...) to retrieve.
; Return values..: Success  - String containing the requested information.
;                  Failure  - Empty string and sets the @error flag to non-zero.
; Author.........: WideBoyDixon
; Modified.......: Yashied
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ GetLocaleInfo
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_GetLocaleInfo($LCID, $iType)

	Local $Ret

	$Ret = DllCall('kernel32.dll', 'int', 'GetLocaleInfoW', 'int', $LCID, 'int', $iType, 'ptr', 0, 'int', 0)
    If (@error) Or ($Ret[0] = 0) Then
		Return SetError(1, 0, '')
	EndIf

	Local $tData = DllStructCreate('wchar[' & $Ret[0] & ']')

	$Ret = DllCall('kernel32.dll', 'int', 'GetLocaleInfoW', 'int', $LCID, 'int', $iType, 'ptr', DllStructGetPtr($tData), 'int', $Ret[0])
    If (@error) Or ($Ret[0] = 0) Then
		Return SetError(1, 0, '')
	EndIf
    Return DllStructGetData($tData, 1)
EndFunc   ;==>_WinAPI_GetLocaleInfo

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetModuleFileNameEx
; Description....: Retrieves the fully-qualified path for the file associated with the process.
; Syntax.........: _WinAPI_GetModuleFileNameEx ( [$PID] )
; Parameters.....: $PID    - The PID of the process. Default (0) is the current process.
; Return values..: Success - The fully-qualified path to the file.
;                  Failure - Empty string and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ GetModuleFileNameEx
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_GetModuleFileNameEx($PID = 0)

	If Not $PID Then
		$PID = _WinAPI_GetCurrentProcessID()
		If Not $PID Then
			Return SetError(1, 0, 0)
		EndIf
	EndIf

	Local $hProc = DllCall('kernel32.dll', 'ptr', 'OpenProcess', 'dword', 0x00000410, 'int', 0, 'dword', $PID)

	If (@error) Or ($hProc[0] = 0) Then
		Return SetError(1, 0, '')
	EndIf

	$hProc = $hProc[0]

	Local $tPath = DllStructCreate('wchar[1024]')
	Local $Ret = DllCall('psapi.dll', 'int', 'GetModuleFileNameExW', 'ptr', $hProc, 'ptr', 0, 'ptr', DllStructGetPtr($tPath), 'int', 1024)

	If (@error) Or ($Ret[0] = 0) Then
		$Ret = 0
	EndIf
	_WinAPI_FreeHandle($hProc)
	If Not IsArray($Ret) Then
		Return SetError(1, 0, '')
	EndIf
	Return SetError(0, 0, DllStructGetData($tPath, 1))
EndFunc   ;==>_WinAPI_GetModuleFileNameEx

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetObjectEx
; Description....: Retrieves information for the specified graphics object.
; Syntax.........: _WinAPI_GetObjectEx ( $hObject )
; Parameters.....: $hObject - Handle to the graphics object of interest. This can be a handle to one of the following: a logical
;                             bitmap, a brush, a font, a palette, or a pen.
; Return values..: Success  - The structure that depends on the graphics object ($hObject) and @extended flag will contain the value
;                             that identifies the object ($OBJ_...). You do not need to create the desired structure, _WinAPI_GetObjectEx()
;                             function itself will create it. The following table shows the structures that will be returns for
;                             each type of graphics object.
;
;                             $OBJ_BITMAP (HBITMAP)
;                             Returns $tagDIBSECTION structure.
;
;                             $OBJ_BRUSH (HBRUSH)
;                             Returns $tagLOGBRUSH structure.
;
;                             $OBJ_FONT (HFONT)
;                             Returns $tagLOGFONT structure.
;
;                             $OBJ_PAL (HPALETTE)
;                             Returns "ushort" structure that specifies the number of entries in the palette.
;
;                             $OBJ_PEN (HPEN)
;                             Returns $tagLOGPEN (12 bytes) or $tagEXTLOGPEN (24 and more bytes) structure.
;
;                  Failure  - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ GetObject
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_GetObjectEx($hObject)

	Local $Ret, $Size, $Struct, $Type, $Entry, $tData = 0

	$Ret = DllCall('gdi32.dll', 'int', 'GetObject', 'int', $hObject, 'int', 0, 'ptr', 0)
	If (@error) Or ($Ret[0] = 0) Then
		Return SetError(1, 0, 0)
	EndIf
	$Size = $Ret[0]
	$Type = _WinAPI_GetObjectType($hObject)
	Switch $Type
		Case $OBJ_BITMAP
			$Struct = $tagDIBSECTION
		Case $OBJ_BRUSH
			$Struct = $tagLOGBRUSH
		Case $OBJ_FONT
			$Struct = $tagLOGFONT
		Case $OBJ_PAL
			$Struct = 'ushort'
		Case $OBJ_PEN
			If $Size > 12 Then ; SizeOf(LOGPEN)
				$tData = DllStructCreate($tagEXTLOGPEN)
				$Entry = BitShift($Size - DllStructGetSize($tData), 2)
				If $Entry > 0 Then
					$tData = DllStructCreate($tagEXTLOGPEN & ';dword StyleEntry[' & $Entry & ']')
				EndIf
			Else
				$Struct = $tagLOGPEN
			EndIf
		Case Else
			Return SetError(2, 0, 0)
	EndSwitch
	If Not IsDllStruct($tData) Then
		$tData = DllStructCreate($Struct)
	EndIf
	$Ret = DllCall('gdi32.dll', 'int', 'GetObject', 'int', $hObject, 'int', DllStructGetSize($tData), 'ptr', DllStructGetPtr($tData))
	If (@error) Or ($Ret[0] = 0) Then
		Return SetError(1, 0, 0)
	EndIf
	Return SetError(0, $Type, $tData)
EndFunc   ;==>_WinAPI_GetObjectEx

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetObjectType
; Description....: Retrieves the type of the specified object.
; Syntax.........: _WinAPI_GetObjectType ( $hObject )
; Parameters.....: $hObject - Handle to the graphics object.
; Return values..: Success  - The value identifies the object ($OBJ_...).
;                  Failure  - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ GetObjectType
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_GetObjectType($hObject)

	Local $Ret  = DllCall('gdi32.dll', 'dword', 'GetObjectType', 'ptr', $hObject)

	If (@error) Or ($Ret[0] = 0) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_GetObjectType

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetPixel
; Description....: Retrieves the color value of the pixel at the specified coordinates.
; Syntax.........: _WinAPI_GetPixel ( $hDC, $iX, $iY )
; Parameters.....: $hDC    - Handle to the device context.
;                  $iX     - The x-coordinate, in logical units, of the pixel to be examined.
;                  $iY     - The y-coordinate, in logical units, of the pixel to be examined.
; Return values..: Success - The color of the pixel, in RGB.
;                  Failure - (-1) and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ GetPixel
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_GetPixel($hDC, $iX, $iY)

	Local $Ret = DllCall('gdi32.dll', 'dword', 'GetPixel', 'hwnd', $hDC, 'int', $iX, 'int', $iY)

	If (@error) Or ($Ret[0] < 0) Then
		Return SetError(1, 0, -1)
	EndIf
	Return __CheckColor($Ret[0])
EndFunc   ;==>_WinAPI_GetPixel

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetProcAddress
; Description....: Retrieves the address of a function from the specified dynamic-link library (DLL).
; Syntax.........: _WinAPI_GetProcAddress ( $hModule, $sProc )
; Parameters.....: $hModule - Handle to the DLL module that contains the function.
;                  $sProc   - The function name.
; Return values..: Success  - The address of the function.
;                  Failure  - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ GetProcAddress
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_GetProcAddress($hModule, $sProc)

	Local $Ret = DllCall('kernel32.dll', 'ptr', 'GetProcAddress', 'ptr', $hModule, 'str', $sProc)

	If (@error) Or ($Ret[0] = 0) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_GetProcAddress

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetProcessCreationTime
; Description....: Retrieves the creation time of the process.
; Syntax.........: _WinAPI_GetProcessCreationTime( [$PID] )
; Parameters.....: $PID    - The PID of the process. Default (0) is the current process.
; Return values..: Success - $tagSYSTEMTIME structure that contains the creation time of the process.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ GetProcessTimes
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_GetProcessCreationTime($PID = 0)

	If Not $PID Then
		$PID = _WinAPI_GetCurrentProcessID()
		If Not $PID Then
			Return SetError(1, 0, 0)
		EndIf
	EndIf

	Local $hProc = DllCall('kernel32.dll', 'ptr', 'OpenProcess', 'dword', 0x00000400, 'int', 0, 'dword', $PID)

	If (@error) Or ($hProc[0] = 0) Then
		Return SetError(1, 0, 0)
	EndIf

	$hProc = $hProc[0]

	Local $tTime = DllStructCreate('dword;dword')
	Local $Ret = DllCall('kernel32.dll', 'int', 'GetProcessTimes', 'ptr', $hProc, 'ptr', DllStructGetPtr($tTime), 'ptr*', 0, 'ptr*', 0, 'ptr*', 0)

	If (@error) Or ($Ret[0] = 0) Then
		$Ret = 0
	EndIf
	_WinAPI_FreeHandle($hProc)
	If Not IsArray($Ret) Then
		Return SetError(1, 0, 0)
	EndIf
	Return _WinAPI_FileTimeToSystemTime(_WinAPI_FileTimeToLocalFileTime($tTime))
EndFunc   ;==>_WinAPI_GetProcessCreationTime

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetProcessMemoryInfo
; Description....: Retrieves information about the memory usage of the specified process.
; Syntax.........: _WinAPI_GetProcessMemoryInfo ( [$PID] )
; Parameters.....: $PID    - The PID of the process. Default (0) is the current process.
; Return values..: Success - $tagPROCESS_MEMORY_COUNTERS structure that contains the information about the memory usage.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ GetProcessMemoryInfo
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_GetProcessMemoryInfo($PID = 0)

	If Not $PID Then
		$PID = _WinAPI_GetCurrentProcessID()
		If Not $PID Then
			Return SetError(1, 0, 0)
		EndIf
	EndIf

	Local $hProc = DllCall('kernel32.dll', 'ptr', 'OpenProcess', 'dword', 0x00000410, 'int', 0, 'dword', $PID)

	If (@error) Or ($hProc[0] = 0) Then
		Return SetError(1, 0, 0)
	EndIf

	$hProc = $hProc[0]

	Local $tPROCESS_MEMORY_COUNTERS = DllStructCreate($tagPROCESS_MEMORY_COUNTERS)
	Local $Ret = DllCall('psapi.dll', 'int', 'GetProcessMemoryInfo', 'ptr', $hProc, 'ptr', DllStructGetPtr($tPROCESS_MEMORY_COUNTERS), 'int', DllStructGetSize($tPROCESS_MEMORY_COUNTERS))

	If (@error) Or ($Ret[0] = 0) Then
		$Ret = 0
	EndIf
	_WinAPI_FreeHandle($hProc)
	If Not IsArray($Ret) Then
		Return SetError(1, 0, 0)
	EndIf
	Return SetError(0, 0, $tPROCESS_MEMORY_COUNTERS)
EndFunc   ;==>_WinAPI_GetProcessMemoryInfo

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetRgnBox
; Description....: Retrieves the bounding rectangle of the specified region.
; Syntax.........: _WinAPI_GetRgnBox ( $hRgn, ByRef $tRECT )
; Parameters.....: $hRgn   - Handle to the region.
;                  $tRECT  - $tagRECT structure that receives the bounding rectangle in logical units.
; Return values..: Success - The value specifies the region's complexity. It can be one of the following values.
;
;                            $NULLREGION
;                            $SIMPLEREGION
;                            $COMPLEXREGION
;
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ GetRgnBox
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_GetRgnBox($hRgn, ByRef $tRECT)

	Local $Ret = DllCall('gdi32.dll', 'int', 'GetRgnBox', 'ptr', $hRgn, 'ptr', DllStructGetPtr($tRECT))

	If (@error) Or ($Ret[0] = 0) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_GetRgnBox

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetROP2
; Description....: Retrieves the foreground mix mode of the specified device context.
; Syntax.........: _WinAPI_GetROP2 ( $hDC )
; Parameters.....: $hDC    - Handle to the device context.
; Return values..: Success - The value specifies the foreground mix mode ($R2_...).
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ GetROP2
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_GetROP2($hDC)

	Local $Ret = DllCall('gdi32.dll', 'int', 'GetROP2', 'hwnd', $hDC)

	If (@error) Or ($Ret[0] = 0) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_GetROP2

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetRValue
; Description....: Retrieves an intensity value for the red component of a 32-bit RGB value.
; Syntax.........: _WinAPI_GetRValue ( $iRGB )
; Parameters.....: $iRGB - The color value, in RGB.
; Return values..: The intensity of the red component of the specified RGB color.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: None
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_GetRValue($iRGB)
	Return BitShift(BitAND(__CheckColor($iRGB), 0xFF0000), 16)
EndFunc   ;==>_WinAPI_GetRValue

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetSystemPowerStatus
; Description....: 
; Syntax.........: _WinAPI_GetSystemPowerStatus ( )
; Parameters.....: None
; Return values..: Success - The array containing the following parameters:
;                            [0] - The AC power status. This member can be one of the following values.
;                                    0 - Offline
;                                    1 - Online
;                                  255 - Unknown status
;                            [1] - The battery charge status. This member can contain one or more of the following flags.
;                                    0 - The battery is not being charged and the battery capacity is between low and high.
;                                    1 - High - the battery capacity is at more than 66 percent
;                                    2 - Low - the battery capacity is at less than 33 percent
;                                    4 - Critical - the battery capacity is at less than five percent
;                                    8 - Charging
;                                  128 - No system battery
;                                  255 - Unknown status - unable to read the battery flag information
;                            [2] - The percentage of full battery charge remaining. This member can be a value in the range 0 to 100,
;                                  or 255 if status is unknown.
;                            [3] - The number of seconds of battery life remaining, or (–1) if remaining seconds are unknown.
;                            [4] - The number of seconds of battery life when at full charge, or (–1) if full battery
;                                  lifetime is unknown.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ GetSystemPowerStatus
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_GetSystemPowerStatus()

	Local $tSYSTEM_POWER_STATUS = DllStructCreate('byte;byte;byte;byte;dword;dword')
	Local $Ret = DllCall('kernel32.dll', 'int', 'GetSystemPowerStatus', 'ptr', DllStructGetPtr($tSYSTEM_POWER_STATUS))

	If (@error) Or ($Ret[0] = 0) Then
		Return SetError(1, 0, 0)
	EndIf

	Local $Result[5]

	$Result[0] = DllStructGetData($tSYSTEM_POWER_STATUS, 1)
	$Result[1] = DllStructGetData($tSYSTEM_POWER_STATUS, 2)
	$Result[2] = DllStructGetData($tSYSTEM_POWER_STATUS, 3)
	$Result[3] = DllStructGetData($tSYSTEM_POWER_STATUS, 5)
	$Result[4] = DllStructGetData($tSYSTEM_POWER_STATUS, 6)

	Return $Result
EndFunc   ;==>_WinAPI_GetSystemPowerStatus

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetTempFileName
; Description....: Creates a name for a temporary file.
; Syntax.........: _WinAPI_GetTempFileName ( $sPath [, $sPrefix] )
; Parameters.....: $sPath   - The directory path for the file name. Applications typically specify a period (.) for the current directory.
;                  $sPrefix - The prefix string. The function uses up to the first three characters of this string as the prefix of the
;                             file name.
; Return values..: Success  - The temporary file name.
;                  Failure  - Empty string and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: Temporary files whose names have been created by this function are not automatically deleted.
; Related........:
; Link...........: @@MsdnLink@@ GetTempFileName
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_GetTempFileName($sPath, $sPrefix = '')

	Local $tData = DllStructCreate('wchar[1024]')
	Local $Ret = DllCall('kernel32.dll', 'uint', 'GetTempFileNameW', 'wstr', $sPath, 'wstr', $sPrefix, 'uint', 0, 'ptr', DllStructGetPtr($tData))

	If (@error) Or ($Ret[0] = 0) Then
		Return SetError(1, 0, '')
	EndIf
	Return DllStructGetData($tData, 1)
EndFunc   ;==>_WinAPI_GetTempFileName

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetTextColor
; Description....: Retrieves the current text color for the specified device context.
; Syntax.........: _WinAPI_GetTextColor ( $hDC )
; Parameters.....: $hDC    - Handle to the device context.
; Return values..: Success - The value of the current text color, in RGB.
;                  Failure - (-1) and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ GetTextColor
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_GetTextColor($hDC)

	Local $Ret = DllCall('gdi32.dll', 'int', 'GetTextColor', 'hwnd', $hDC)

	If (@error) Or ($Ret[0] < 0) Then
		Return SetError(1, 0, -1)
	EndIf
	Return __CheckColor($Ret[0])
EndFunc   ;==>_WinAPI_GetTextColor

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetTextMetrics
; Description....: Retrieves basic information for the currently selected font.
; Syntax.........: _WinAPI_GetTextMetrics ( $hDC )
; Parameters.....: $hDC    - Handle to the device context.
; Return values..: Success - $tagTEXTMETRIC structure that contains the information about the currently selected font.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ GetTextMetrics
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_GetTextMetrics($hDC)

	Local $tTEXTMETRIC = DllStructCreate($tagTEXTMETRIC)
	Local $Ret = DllCall('gdi32.dll', 'int', 'GetTextMetrics', 'hwnd', $hDC, 'ptr', DllStructGetPtr($tTEXTMETRIC))

	If (@error) Or ($Ret[0] = 0) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $tTEXTMETRIC
EndFunc   ;==>_WinAPI_GetTextMetrics

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetThemeAppProperties
; Description....: Retrieves the property flags that control how visual styles are applied in the current application.
; Syntax.........: _WinAPI_GetThemeAppProperties ( )
; Parameters.....: None
; Return values..: Success - The property bit flags ($STAP_ALLOW_...) combined with a logical OR operator.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: Individual flags can be extracted from the result by combining the result with the logical
;                  AND of the desired flag.
; Related........:
; Link...........: @@MsdnLink@@ GetThemeAppProperties
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_GetThemeAppProperties()

	Local $Ret = DllCall('uxtheme.dll', 'int', 'GetThemeAppProperties')

	If @error Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_GetThemeAppProperties

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetThemeColor
; Description....: Retrieves the value of a color property for the specified window.
; Syntax.........: _WinAPI_GetThemeColor ( $hWnd, $sClass, $iPart, $iState, $iProp )
; Parameters.....: $hWnd   - Handle of the window for which theme data is required.
;                  $sClass - String that contains a semicolon-separated list of classes. For example, "BUTTON", "TAB", etc.
;                  $iPart  - Value that specifies the part that contains the color property.
;                  $iState - Value that specifies the state of the part.
;                  $iProp  - Value that specifies the property to retrieve.
; Return values..: Success - The received color, in RGB.
;                  Failure - (-1) and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ GetThemeColor
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_GetThemeColor($hWnd, $sClass, $iPart, $iState, $iProp)

	Local $hTheme = DllCall('uxtheme.dll', 'ptr', 'OpenThemeData', 'hwnd', $hWnd, 'wstr', $sClass)
	Local $Ret = DllCall('uxtheme.dll', 'lresult', 'GetThemeColor', 'ptr', $hTheme[0], 'int', $iPart, 'int', $iState, 'int', $iProp, 'dword*', 0)

	If (@error) Or ($Ret[0] < 0) Then
		$Ret = -1
	EndIf
	DllCall('uxtheme.dll', 'lresult', 'CloseThemeData', 'ptr', $hTheme[0])
	If $Ret = -1 Then
		Return SetError(1, 0, -1)
	EndIf
	Return SetError(0, 0, __CheckColor($Ret[5]))
EndFunc   ;==>_WinAPI_GetThemeColor

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetTickCount
; Description....: Retrieves the number of milliseconds that have elapsed since the system was started.
; Syntax.........: _WinAPI_GetTickCount ( )
; Parameters.....: None
; Return values..: Success - The number of milliseconds that have elapsed since the system was started.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: The time will wrap around to zero if the system is run continuously for 49.7 days. You should check for an
;                  overflow condition when comparing times. To obtain the time elapsed since the computer was started, retrieve the
;                  System Up Time counter in the performance data in the registry key HKEY_PERFORMANCE_DATA.
; Related........:
; Link...........: @@MsdnLink@@ GetTickCount
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_GetTickCount()

	Local $Ret = DllCall('kernel32.dll', 'dword', 'GetTickCount')

    If @error Then
		Return SetError(1, 0, 0)
	EndIf
    Return $Ret[0]
EndFunc   ;==>_WinAPI_GetTickCount

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetTopWindow
; Description....: Retrieves a handle to the child window at the top of the Z order.
; Syntax.........: _WinAPI_GetTopWindow ( $hWnd )
; Parameters.....: $hWnd   - Handle to the parent window whose child windows are to be examined. If this parameter is 0, the function
;                            returns a handle to the window at the top of the Z order.
; Return values..: Success - Handle to the child window at the top of the Z order. If the specified window has no child windows,
;                            the return value is 0.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ GetTopWindow
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_GetTopWindow($hWnd)

	Local $Ret = DllCall('user32.dll', 'hwnd', 'GetTopWindow', 'hwnd', $hWnd)

	If @error Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_GetTopWindow

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetUserDefaultLCID
; Description....: Returns the locale identifier (LCID) for the user default locale.
; Syntax.........: _WinAPI_GetUserDefaultLCID ( )
; Parameters.....: None
; Return values..: Success - The default LCID for the user.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: WideBoyDixon
; Modified.......: Yashied
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ GetUserDefaultLCID
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_GetUserDefaultLCID()

    Local $Ret = DllCall('kernel32.dll', 'int', 'GetUserDefaultLCID')

    If @error Then
		Return SetError(1, 0, 0)
	EndIf
    Return $Ret[0]
EndFunc   ;==>_WinAPI_GetUserDefaultLCID

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetVersionEx
; Description....: Retrieves information about the current operating system.
; Syntax.........: _WinAPI_GetVersionEx ( )
; Parameters.....: None
; Return values..: Success - $tagOSVERSIONINFOEX structure that contains the information about the current operating system.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: When using the GetVersionEx function to determine whether your application is running on a particular version of
;                  the operating system, check for version numbers that are greater than or equal to the desired version numbers.
;                  This ensures that the test succeeds for later versions of the operating system.
; Related........:
; Link...........: @@MsdnLink@@ GetVersionEx
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_GetVersionEx()

	Local $tOSVERSIONINFOEX = DllStructCreate($tagOSVERSIONINFOEX)

	DllStructSetData($tOSVERSIONINFOEX, 'OSVersionInfoSize', DllStructGetSize($tOSVERSIONINFOEX))

	Local $Ret = DllCall('kernel32.dll', 'int', 'GetVersionExW', 'ptr', DllStructGetPtr($tOSVERSIONINFOEX))

	If (@error) Or ($Ret[0] = 0) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $tOSVERSIONINFOEX
EndFunc   ;==>_WinAPI_GetVersionEx

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetVolumeNameForVolumeMountPoint
; Description....: Retrieves a volume GUID path for the volume that is associated with the specified volume mount point.
; Syntax.........: _WinAPI_GetVolumeNameForVolumeMountPoint ( $sPath )
; Parameters.....: $sPath  - The path of a mounted folder (for example, Y:\MountX\) or a drive letter (for example, X:\).
; Return values..: Success - The volume GUID path. This path is of the form "\\?\Volume{GUID}\" where GUID is a GUID that
;                            identifies the volume. If there is more than one volume GUID path for the volume, only the first one
;                            in the mount manager's cache is returned.
;                  Failure - Empty string and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ GetVolumeNameForVolumeMountPoint
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_GetVolumeNameForVolumeMountPoint($sPath)

	Local $tData = DllStructCreate('wchar[80]')
	Local $Ret = DllCall('kernel32.dll', 'int', 'GetVolumeNameForVolumeMountPointW', 'wstr', $sPath, 'ptr', DllStructGetPtr($tData), 'dword', 80)

	If (@error) Or ($Ret[0] = 0) Then
		Return SetError(1, 0, '')
	EndIf
	Return DllStructGetData($tData, 1)
EndFunc   ;==>_WinAPI_GetVolumeNameForVolumeMountPoint

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetWindowInfo
; Description....: Retrieves information about the specified window.
; Syntax.........: _WinAPI_GetWindowInfo ( $hWnd )
; Parameters.....: $hWnd   - Handle to the window whose information is to be retrieved.
; Return values..: Success - $tagWINDOWINFO structure that contains the information about the specified window.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ GetWindowInfo
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_GetWindowInfo($hWnd)

	Local $tWINDOWINFO = DllStructCreate($tagWINDOWINFO)

	DllStructSetData($tWINDOWINFO, 'Size', DllStructGetSize($tWINDOWINFO))

	Local $Ret = DllCall('user32.dll', 'int', 'GetWindowInfo', 'hwnd', $hWnd, 'ptr', DllStructGetPtr($tWINDOWINFO))

	If (@error) Or ($Ret[0] = 0) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $tWINDOWINFO
EndFunc   ;==>_WinAPI_GetWindowInfo

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetWindowModuleFileName
; Description....: Retrieves the full path and file name of the module associated with the specified window handle.
; Syntax.........: _WinAPI_GetWindowModuleFileName ( $hWnd )
; Parameters.....: $hWnd   - Handle to the window whose module file name will be retrieved.
; Return values..: Success - The full path and file name.
;                  Failure - Empty string and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ GetWindowModuleFileName
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_GetWindowModuleFileName($hWnd)

	Local $Result = '', $PID = 0

	_WinAPI_GetWindowThreadProcessId($hWnd, $PID)
	If $PID Then
		$Result = _WinAPI_GetModuleFileNameEx($PID)
	EndIf
	Return SetError(@error, 0, $Result)
EndFunc   ;==>_WinAPI_GetWindowModuleFileName

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetWorkArea
; Description....: Retrieves the size of the work area on the primary display monitor.
; Syntax.........: _WinAPI_GetWorkArea ( )
; Parameters.....: None
; Return values..: Success - $tagRECT structure that contains the screen coordinates of the work area.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ SystemParametersInfo
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_GetWorkArea()

	Local $tRECT = DllStructCreate($tagRECT)
	Local $Ret = DllCall('user32.dll', 'int', 'SystemParametersInfo', 'uint', 48, 'uint', 0, 'ptr', DllStructGetPtr($tRECT), 'uint', 0)

	If (@error) Or ($Ret[0] = 0) Then
		Return SetError(1, 0, 0)
	EndIf
	Return SetError(0, 0, $tRECT)
EndFunc   ;==>_WinAPI_GetWorkArea

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GradientFill
; Description....: Fills rectangle or triangle gradient.
; Syntax.........: _WinAPI_GradientFill ($hDC, $aVertex [, $iStart [, $iEnd [, $fRotate]]] )
; Parameters.....: $hDC     - Handle to the destination device context.
;                  $aVertex - The 2D array ([x1, y1, $rgb1], [x2, y2, $rgb2], ... [xN, yN, $rgbN]) that contains the necessary
;                             gradient vertices. Each vertex in this array contains the following parameters.
;
;                             x   - The x-coordinate, in logical units.
;                             y   - The y-coordinate, in logical units
;                             rgb - The color information at the point of x, y.
;
;                  $iStart  - The index of array to start filling at.
;                  $iEnd    - The index of array to stop filling at.
;                  $fRotate - Specifies whether fills a rectangle from left to right edge (horizontal gradient). $fRotate used
;                             only for the rectangular gradients, for the triangular gradients this parameter will be ignored,
;                             valid values:
;                  |TRUE    - Fills from left to right edge.
;                  |FALSE   - Fills from top to bottom edge. (Default)
; Return values..: Success  - 1.
;                  Failure  - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: If the number of vertices defined by using $iStart and $iEnd parameters is 2, _WinAPI_GradientFill() function
;                  fills a rectangle. If the number of vertices is 3, fills a triangle. For the rectangle, the vertices must
;                  specify its upper left and lower right corners. Note that $aVertex array may contain any number of vertices
;                  of the gradient, but only 2 or 3 vertices may be used at the same time from this array.
;                  Otherwise, the function is fails.
;
;                  _WinAPI_GradientFill() function can only fill the rectangle or triangle at one call. Use multiple calls this
;                  function to fill a complex gradients.
; Related........:
; Link...........: @@MsdnLink@@ GdiGradientFill
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_GradientFill($hDC, $aVertex, $iStart = 0, $iEnd = -1, $fRotate = 0)

	If UBound($aVertex, 2) < 3  Then
		Return SetError(2, 0, 0)
	EndIf

	Local $Count, $Fill, $Mode, $Point, $tGradient, $tVertex, $Struct = ''

	If $iStart < 0 Then
		$iStart = 0
	EndIf
	If ($iEnd < 0) Or ($iEnd > UBound($aVertex) - 1) Then
		$iEnd = UBound($aVertex) - 1
	EndIf
	$Point = $iEnd - $iStart + 1
	If $Point > 3 Then
		$iEnd = $iStart + 2
		$Point = 3
	EndIf
	Switch $Point
		Case 2
			$Mode = Number($fRotate = 0)
		Case 3
			$Mode = 2
		Case Else
			Return SetError(1, 0, 0)
	EndSwitch
	For $i = $iStart To $iEnd
		$Struct &= 'short[8];'
	Next
	$tVertex = DllStructCreate(StringTrimRight($Struct, 1))
	If @error Then
		Return SetError(1, 0, 0)
	EndIf
	$Count = 1
	$tGradient = DllStructCreate('ulong[' & $Point & ']')
	For $i = $iStart To $iEnd
		DllStructSetData($tGradient, 1, $Count - 1, $Count)
		DllStructSetData($tVertex, $Count, _WinAPI_LoWord($aVertex[$i][0]), 1)
		DllStructSetData($tVertex, $Count, _WinAPI_HiWord($aVertex[$i][0]), 2)
		DllStructSetData($tVertex, $Count, _WinAPI_LoWord($aVertex[$i][1]), 3)
		DllStructSetData($tVertex, $Count, _WinAPI_HiWord($aVertex[$i][1]), 4)
		DllStructSetData($tVertex, $Count, BitShift(_WinAPI_GetBValue($aVertex[$i][2]), -8), 5)
		DllStructSetData($tVertex, $Count, BitShift(_WinAPI_GetGValue($aVertex[$i][2]), -8), 6)
		DllStructSetData($tVertex, $Count, BitShift(_WinAPI_GetRValue($aVertex[$i][2]), -8), 7)
		DllStructSetData($tVertex, $Count, 0, 8)
		$Count += 1
	Next

	Local $Ret = DllCall('gdi32.dll', 'int', 'GdiGradientFill', 'hwnd', $hDC, 'ptr', DllStructGetPtr($tVertex), 'ulong', $Point, 'ptr', DllStructGetPtr($tGradient), 'ulong', 1, 'ulong', $Mode)

	If (@error) Or ($Ret[0] = 0) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_GradientFill

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_InflateRect
; Description....: Increases or decreases the width and height of the specified rectangle.
; Syntax.........: _WinAPI_InflateRect( ByRef $tRECT, $DX, $DY )
; Parameters.....: $tRECT  - $tagRECT structure that increases or decreases in size.
;                  $DX     - The amount to increase or decrease (negative value) the rectangle width.
;                  $DY     - The amount to increase or decrease (negative value) the rectangle height.
; Return values..: Success - 1.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ InflateRect
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_InflateRect(ByRef $tRECT, $DX, $DY)

	Local $Ret = DllCall('user32.dll', 'int', 'InflateRect', 'ptr', DllStructGetPtr($tRECT), 'int', $DX, 'int', $DY)

	If (@error) Or ($Ret[0] = 0) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_InflateRect

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_IntersectRect
; Description....: Creates the intersection of two rectangles.
; Syntax.........: _WinAPI_IntersectRect ( $tRECT1, $tRECT2 )
; Parameters.....: $tRECT1 - $tagRECT structure that contains the first source rectangle.
;                  $tRECT2 - $tagRECT structure that contains the second source rectangle.
; Return values..: Success - $tagRECT structure that contains the intersection of the $tRECT1 and $tRECT2 rectangles.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: If the source rectangles do not intersect, an empty rectangle (in which all coordinates are set to zero) is
;                  placed into the destination rectangle.
; Related........:
; Link...........: @@MsdnLink@@ IntersectRect
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_IntersectRect($tRECT1, $tRECT2)

	Local $tRECT = DllStructCreate($tagRECT)
	Local $Ret = DllCall('user32.dll', 'int', 'IntersectRect', 'ptr', DllStructGetPtr($tRECT), 'ptr', DllStructGetPtr($tRECT1), 'ptr', DllStructGetPtr($tRECT2))

	If (@error) Or ($Ret[0] = 0) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $tRECT
EndFunc   ;==>_WinAPI_IntersectRect

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_InvalidateRect
; Description....: Adds a rectangle to the specified window's update region.
; Syntax.........: _WinAPI_InvalidateRect ( $hWnd [, $tRECT [, $fErase]] )
; Parameters.....: $hWnd   - Handle to the window whose update region has changed. If this parameter is 0, the system invalidates
;                            and redraws all windows, and sends the WM_ERASEBKGND and WM_NCPAINT messages to the window procedure
;                            before the function returns.
;                  $tRECT  - $tagRECT structure that contains the client coordinates of the rectangle to be added to the update
;                            region. If this parameter is 0, the entire client area is added to the update region.
;                  $fErase - Specifies whether the background within the update region is to be erased when the
;                            update region is processed.
;                  |TRUE   - The background is erased. (Default)
;                  |FALSE  - The background remains unchanged.
; Return values..: Success - 1.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ InvalidateRect
; Example........: Yes
; ===============================================================================================================================

#cs

Func _WinAPI_InvalidateRect($hWnd, $tRECT = 0, $fErase = 1)

	Local $Ret = DllCall('user32.dll', 'int', 'InvalidateRect', 'hwnd', $hWnd, 'ptr', DllStructGetPtr($tRECT), 'int', $fErase)

	If (@error) Or ($Ret[0] = 0) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_InvalidateRect

#ce

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_InvalidateRgn
; Description....: Adds a region to the specified window's update region.
; Syntax.........: _WinAPI_InvalidateRgn ( $hWnd [, $hRgn [, $fErase]] )
; Parameters.....: $hWnd   - Handle to the window with an update region that is to be modified.
;                  $hRgn   - Handle to the region to be added to the update region. The region is assumed to have client coordinates.
;                            If this parameter is 0, the entire client area is added to the update region.
;                  $fErase - Specifies whether the background within the update region is to be erased when the
;                            update region is processed.
;                  |TRUE   - The background is erased. (Default)
;                  |FALSE  - The background remains unchanged.
; Return values..: Success - 1.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ InvalidateRgn
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_InvalidateRgn($hWnd, $hRgn = 0, $fErase = 1)

	Local $Ret = DllCall('user32.dll', 'int', 'InvalidateRgn', 'hwnd', $hWnd, 'ptr', $hRgn, 'int', $fErase)

	If (@error) Or ($Ret[0] = 0) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_InvalidateRgn

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_InvertRect
; Description....: Inverts a rectangle in a window by performing a logical NOT operation on the color values for each pixel.
; Syntax.........: _WinAPI_InvertRect ( $hDC, $tRECT )
; Parameters.....: $hDC    - Handle to the device context.
;                  $tRECT  - $tagRECT structure that contains the logical coordinates of the rectangle to be inverted.
; Return values..: Success - 1.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: On monochrome screens, the _WinAPI_InvertRect() makes white pixels black and black pixels white. On color screens,
;                  the inversion depends on how colors are generated for the screen. Calling _WinAPI_InvertRect() twice for the same
;                  rectangle restores the display to its previous colors.
; Related........:
; Link...........: @@MsdnLink@@ InvertRect
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_InvertRect($hDC, $tRECT)

	Local $Ret = DllCall('user32.dll', 'int', 'InvertRect', 'hwnd', $hDC, 'ptr', DllStructGetPtr($tRECT))

	If (@error) Or ($Ret[0] = 0) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_InvertRect

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_InvertRgn
; Description....: Inverts the colors in the specified region.
; Syntax.........: _WinAPI_InvertRgn ( $hDC, $hRgn )
; Parameters.....: $hDC    - Handle to the device context.
;                  $hRgn   - Handle to the region for which colors are inverted. The region's coordinates are
;                            presumed to be logical coordinates.
; Return values..: Success - 1.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: On monochrome screens, the _WinAPI_InvertRgn() function makes white pixels black and black pixels white. On color
;                  screens, this inversion is dependent on the type of technology used to generate the colors for the screen.
; Related........:
; Link...........: @@MsdnLink@@ InvertRgn
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_InvertRgn($hDC, $hRgn)

	Local $Ret = DllCall('gdi32.dll', 'int', 'InvertRgn', 'hwnd', $hDC, 'ptr', $hRgn)

	If (@error) Or ($Ret[0] = 0) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_InvertRgn

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_IsChild
; Description....: Tests whether a window is a child window of a specified parent window.
; Syntax.........: _WinAPI_IsChild ( $hWnd, $hWndParent )
; Parameters.....: $hWnd       - Handle to the window to be tested.
;                  $hWndParent - Handle to the parent window.
; Return values..: Success     - 1 - The window is a child window of the specified parent window.
;                                0 - Otherwise.
;                  Failure     - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ IsChild
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_IsChild($hWnd, $hWndParent)

	Local $Ret = DllCall('user32.dll', 'int', 'IsChild', 'hwnd', $hWndParent, 'hwnd', $hWnd)

	If @error Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_IsChild

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_IsDoorOpen
; Description....: Checks if a CD (DVD) tray is open.
; Syntax.........: _WinAPI_IsDoorOpen ( $sDrive )
; Parameters.....: $sDrive - The drive letter of the CD tray to check, in the format D:, E:, etc.
; Return values..: Success - 1 - CD (DVD) tray is open.
;                            0 - Otherwise.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: G.Sandler (CreatoR)
; Modified.......: Yashied
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ IOCTL_SCSI_PASS_THROUGH
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_IsDoorOpen($sDrive)

	If Not (_WinAPI_GetDriveType($sDrive) = $DRIVE_CDROM) Then
		Return SetError(1, 0, 0)
	EndIf

	Local $hFile = _WinAPI_CreateFile('\\.\' & $sDrive, 2, 6, 6)

	If $hFile = 0 Then
		Return SetError(1, 0, 0)
	EndIf

	Local $tSCSI_PASS_THROUGH = DllStructCreate('ushort;ubyte;ubyte;ubyte;ubyte;ubyte;ubyte;ubyte;ubyte[3];uint;uint;uint;uint;ubyte[16];ubyte[240];ubyte[1024]')
	Local $pSCSI_PASS_THROUGH = DllStructGetPtr($tSCSI_PASS_THROUGH)

    DllStructSetData($tSCSI_PASS_THROUGH, 1, 44)
    DllStructSetData($tSCSI_PASS_THROUGH, 2, 0)
    DllStructSetData($tSCSI_PASS_THROUGH, 3, 0)
    DllStructSetData($tSCSI_PASS_THROUGH, 4, 0)
    DllStructSetData($tSCSI_PASS_THROUGH, 5, 0)
    DllStructSetData($tSCSI_PASS_THROUGH, 6, 12)
    DllStructSetData($tSCSI_PASS_THROUGH, 7, 16)
    DllStructSetData($tSCSI_PASS_THROUGH, 8, 1)
;   DllStructSetData($tSCSI_PASS_THROUGH, 9, 0)
    DllStructSetData($tSCSI_PASS_THROUGH, 10, 1024)
    DllStructSetData($tSCSI_PASS_THROUGH, 11, 5)
    DllStructSetData($tSCSI_PASS_THROUGH, 12, 44 + 240)
    DllStructSetData($tSCSI_PASS_THROUGH, 13, 44)
    DllStructSetData($tSCSI_PASS_THROUGH, 14, 0xBD, 1)
    DllStructSetData($tSCSI_PASS_THROUGH, 14, 0, 2)
    DllStructSetData($tSCSI_PASS_THROUGH, 14, 0, 3)
    DllStructSetData($tSCSI_PASS_THROUGH, 14, 0, 4)
    DllStructSetData($tSCSI_PASS_THROUGH, 14, 0, 5)
    DllStructSetData($tSCSI_PASS_THROUGH, 14, 0, 6)
    DllStructSetData($tSCSI_PASS_THROUGH, 14, 0, 7)
    DllStructSetData($tSCSI_PASS_THROUGH, 14, 0, 8)
    DllStructSetData($tSCSI_PASS_THROUGH, 14, 0, 9)
    DllStructSetData($tSCSI_PASS_THROUGH, 14, 8, 10)
    DllStructSetData($tSCSI_PASS_THROUGH, 14, 0, 11)
    DllStructSetData($tSCSI_PASS_THROUGH, 14, 0, 12)
    DllStructSetData($tSCSI_PASS_THROUGH, 14, 0, 13)
    DllStructSetData($tSCSI_PASS_THROUGH, 14, 0, 14)
    DllStructSetData($tSCSI_PASS_THROUGH, 14, 0, 15)
    DllStructSetData($tSCSI_PASS_THROUGH, 14, 0, 16)
    DllStructSetData($tSCSI_PASS_THROUGH, 15, 0, 1)
    DllStructSetData($tSCSI_PASS_THROUGH, 16, 0, 1)

	Local $Ret = DllCall('kernel32.dll', 'int', 'DeviceIoControl', 'ptr', $hFile, 'dword', 0x0004D004, 'ptr', $pSCSI_PASS_THROUGH, 'dword', 44, 'ptr', $pSCSI_PASS_THROUGH, 'dword', DllStructGetSize($tSCSI_PASS_THROUGH), 'dword*', 0, 'ptr', 0)

	If (@error) Or ($Ret[0] = 0) Then
		$Ret = 0
	EndIf
	_WinAPI_FreeHandle($hFile)
	If Not IsArray($Ret) Then
		Return SetError(2, 0, 0)
	EndIf
	Return SetError(0, 0, BitAND(DllStructGetData($tSCSI_PASS_THROUGH, 16, 2), 0x10) = 0x10)
EndFunc   ;==>_WinAPI_IsDoorOpen

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_IsHungAppWindow
; Description....: Determines whether the specified application is not responding.
; Syntax.........: _WinAPI_IsHungAppWindow ( $hWnd )
; Parameters.....: $hWnd   - Handle to the window.
; Return values..: Success - 1 - The window stops responding.
;                            0 - Otherwise.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: An application is considered to be not responding if it is not waiting for input, is not in startup processing,
;                  and has not called PeekMessage within the internal timeout period of 5 seconds.
; Related........:
; Link...........: @@MsdnLink@@ IsHungAppWindow
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_IsHungAppWindow($hWnd)

	Local $Ret = DllCall('user32.dll', 'int', 'IsHungAppWindow', 'hwnd', $hWnd)

	If @error Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_IsHungAppWindow

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_IsIconic
; Description....: Determines whether the specified window is minimized (iconic).
; Syntax.........: _WinAPI_IsIconic ( $hWnd )
; Parameters.....: $hWnd   - Handle to the window to test.
; Return values..: Success - 1 - The window is iconic.
;                            0 - Otherwise.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ IsIconic
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_IsIconic($hWnd)

	Local $Ret = DllCall('user32.dll', 'int', 'IsIconic', 'hwnd', $hWnd)

	If @error Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_IsIconic

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_IsNetworkAlive
; Description....: Determines whether or not a local system is connected to a network, and identifies the type of network connection.
; Syntax.........: _WinAPI_IsNetworkAlive ( )
; Parameters.....: None
; Return values..: Success - The type of network connection ($NETWORK_ALIVE_...) if a local system is connected to a network.
;                            0 - Is no connection.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: Always check @error flag before checking the return value of this function. If the @error is not 0,
;                  the function has failed and the following values do not apply.
; Related........:
; Link...........: @@MsdnLink@@ IsNetworkAlive
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_IsNetworkAlive()

	Local $Ret = DllCall('sensapi.dll', 'int', 'IsNetworkAlive', 'int*', 0)

	If (@error) Or ($Ret[0] = 0) Or (_WinAPI_GetLastError()) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[1]
EndFunc   ;==>_WinAPI_IsNetworkAlive

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_IsPressed
; Description....: Checks whether the key is pressed from the specified range.
; Syntax.........: _WinAPI_IsPressed ( [$iFrom [, $iTo]] )
; Parameters.....: $iFrom  - Specifies a virtual-key code to start checking. The code must be a value in the range 1 to 254.
;                  $iTo    - Specifies a virtual-key code to end checking. The code must be a value in the range 1 to 254 and be
;                            greater than value of the $iFrom parameter.
; Return values..: Success - 1 - The key is pressed.
;                            0 - Otherwise.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: The key status returned from this function changes as a process reads key messages from its message queue.
;                  The status does not reflect the interrupt-level state associated with the hardware. Use the _WinAPI_GetAsyncKeyState()
;                  function to retrieve that information.
; Related........:
; Link...........: None
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_IsPressed($iFrom = 0x01, $iTo = 0xFF)

	Local $tData = _WinAPI_GetKeyboardState()

	If @error Then
		Return SetError(1, 0, 0)
	EndIf

	For $i = $iFrom To $iTo
		Switch $i
			Case 0x0A, 0x0B, 0x0E To 0x0F, 0x16, 0x1A, 0x1C To 0x1F, 0x3A To 0x40, 0x5E, 0x88 To 0x8F, 0x97 To 0x9F, 0xB8 To 0xB9, 0xC1 To 0xDA, 0xE0, 0xE8
				ContinueLoop
			Case Else
				If BitAND(DllStructGetData($tData, 1, $i + 1), 0xF0) > 0 Then
					Return $i
				EndIf
		EndSwitch
	Next
	Return 0
EndFunc   ;==>_WinAPI_IsPressed

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_IsRectEmpty
; Description....: Determines whether the specified rectangle is empty.
; Syntax.........: _WinAPI_IsRectEmpty ( $tRECT )
; Parameters.....: $tRECT  - $tagRECT structure that contains the logical coordinates of the rectangle.
; Return values..: Success - 1 - The rectangle is empty.
;                            0 - Otherwise.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: An empty rectangle is one that has no area; that is, the coordinate of the right side is less than or equal
;                  to the coordinate of the left side, or the coordinate of the bottom side is less than or equal to the
;                  coordinate of the top side.
; Related........:
; Link...........: @@MsdnLink@@ IsRectEmpty
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_IsRectEmpty($tRECT)

	Local $Ret = DllCall('user32.dll', 'int', 'IsRectEmpty', 'ptr', DllStructGetPtr($tRECT))

	If @error Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_IsRectEmpty

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_IsThemeActive
; Description....: Tests if a visual style for the current application is active.
; Syntax.........: _WinAPI_IsThemeActive ( )
; Parameters.....: None
; Return values..: Success - 1 - The visual style is enabled.
;                            0 - Otherwise.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ IsThemeActive
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_IsThemeActive()

	Local $Ret = DllCall('uxtheme.dll', 'int', 'IsThemeActive')

	If @error Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_IsThemeActive

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_IsWindowEnabled
; Description....: Determines whether the specified window is enabled for mouse and keyboard input.
; Syntax.........: _WinAPI_IsWindowEnabled ( $hWnd )
; Parameters.....: $hWnd   - Handle to the window to test.
; Return values..: Success - 1 - The window is enabled.
;                            0 - Otherwise.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ IsWindowEnabled
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_IsWindowEnabled($hWnd)

	Local $Ret = DllCall('user32.dll', 'int', 'IsWindowEnabled', 'hwnd', $hWnd)

	If @error Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_IsWindowEnabled

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_IsWindowUnicode
; Description....: Determines whether the specified window is a native Unicode window.
; Syntax.........: _WinAPI_IsWindowUnicode ( $hWnd )
; Parameters.....: $hWnd   - Handle to the window to test.
; Return values..: Success - 1 - The window is a native Unicode window.
;                            0 - Otherwise.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ IsWindowUnicode
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_IsWindowUnicode($hWnd)

	Local $Ret = DllCall('user32.dll', 'int', 'IsWindowUnicode', 'hwnd', $hWnd)

	If @error Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_IsWindowUnicode

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_IsWritable
; Description....: Determines whether a disk is writable.
; Syntax.........: _WinAPI_IsWritable ( $sDrive )
; Parameters.....: $sDrive - The drive letter of the disk to check, in the format D:, E:, etc.
; Return values..: Success - 1 - The disk is writable.
;                            0 - Otherwise.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ IOCTL_DISK_IS_WRITABLE
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_IsWritable($sDrive)

	Local $hFile = _WinAPI_CreateFile('\\.\' & $sDrive, 2, 0, 0)

	If $hFile = 0 Then
		Return SetError(1, 0, 0)
	EndIf

	Local $Ret = DllCall('kernel32.dll', 'int', 'DeviceIoControl', 'ptr', $hFile, 'dword', 0x00070024, 'ptr', 0, 'dword', 0, 'ptr', 0, 'dword', 0, 'dword*', 0, 'ptr', 0)

	If @error Then
		$Ret = 0
	EndIf
	_WinAPI_FreeHandle($hFile)
	If Not IsArray($Ret) Then
		Return SetError(2, 0, 0)
	EndIf
	Return SetError(0, 0, $Ret[0])
EndFunc   ;==>_WinAPI_IsWritable

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_IsZoomed
; Description....: Determines whether a window is maximized.
; Syntax.........: _WinAPI_IsZoomed ( $hWnd )
; Parameters.....: $hWnd   - Handle to the window to test.
; Return values..: Success - 1 - The window is zoomed.
;                            0 - Otherwise.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ IsZoomed
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_IsZoomed($hWnd)

	Local $Ret = DllCall('user32.dll', 'int', 'IsZoomed', 'hwnd', $hWnd)

	If @error Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_IsZoomed

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_Keybd_Event
; Description....: Synthesizes a keystroke.
; Syntax.........: _WinAPI_Keybd_Event ( $vkCode, $iFlags [, $iScanCode [, $iExtraInfo]] )
; Parameters.....: $vkCode     - The virtual-key code ($VK_...). The code must be a value in the range 1 to 254.
;
;                                0x01 - Left mouse button
;                                0x02 - Right mouse button
;                                0x03 - Control-break processing
;                                0x04 - Middle mouse button (three-button mouse)
;                                0x05 - X1 mouse button
;                                0x06 - X2 mouse button
;
;                                0x08 - BACKSPACE key
;                                0x09 - TAB key
;
;                                0x0C - CLEAR key
;                                0x0D - ENTER key
;
;                                0x10 - SHIFT key
;                                0x11 - CTRL key
;                                0x12 - ALT key
;                                0x13 - PAUSE key
;                                0x14 - CAPS LOCK key
;
;                                0x1B - ESC key
;
;                                0x20 - SPACEBAR key
;                                0x21 - PAGE UP key
;                                0x22 - PAGE DOWN key
;                                0x23 - END key
;                                0x24 - HOME key
;                                0x25 - LEFT ARROW key
;                                0x26 - UP ARROW key
;                                0x27 - RIGHT ARROW key
;                                0x28 - DOWN ARROW key
;                                0x29 - SELECT key
;                                0x2A - PRINT key
;                                0x2B - EXECUTE key
;                                0x2C - PRINT SCREEN key
;                                0x2D - INS key
;                                0x2E - DEL key
;                                0x2F - HELP key
;                                0x30 - 0x39 - (0 - 9) key
;
;                                0x41 - 0x5A - (A - Z) key
;                                0x5B - Left Windows key
;                                0x5C - Right Windows key
;                                0x5D - Applications key
;
;                                0x5F - Computer Sleep key
;                                0x60 - 0x69 - Numeric keypad (0 - 9) key
;                                0x6A - Multiply key
;                                0x6B - Add key
;                                0x6C - Separator key
;                                0x6D - Subtract key
;                                0x6E - Decimal key
;                                0x6F - Divide key
;                                0x70 - 0x87 - (F1 - F24) key
;
;                                0x90 - NUM LOCK key
;                                0x91 - SCROLL LOCK key
;
;                                0xA0 - Left SHIFT key
;                                0xA1 - Right SHIFT key
;                                0xA2 - Left CONTROL key
;                                0xA3 - Right CONTROL key
;                                0xA4 - Left MENU key
;                                0xA5 - Right MENU key
;                                0xA6 - Browser Back key
;                                0xA7 - Browser Forward key
;                                0xA8 - Browser Refresh key
;                                0xA9 - Browser Stop key
;                                0xAA - Browser Search key
;                                0xAB - Browser Favorites key
;                                0xAC - Browser Start and Home key
;                                0xAD - Volume Mute key
;                                0xAE - Volume Down key
;                                0xAF - Volume Up key
;                                0xB0 - Next Track key
;                                0xB1 - Previous Track key
;                                0xB2 - Stop Media key
;                                0xB3 - Play/Pause Media key
;                                0xB4 - Start Mail key
;                                0xB5 - Select Media key
;                                0xB6 - Start Application 1 key
;                                0xB7 - Start Application 2 key
;
;                                0xBA - ';:' key
;                                0xBB - '+' key
;                                0xBC - ',' key
;                                0xBD - '-' key
;                                0xBE - '.' key
;                                0xBF - '/?' key
;                                0xC0 - '`~' key
;
;                                0xDB - '[{' key
;                                0xDC - '\|' key
;                                0xDD - ']}' key
;                                0xDE - 'single-quote/double-quote' key
;
;                                0xE2 - Either the angle bracket key or the backslash key on the RT 102-key keyboard
;
;                                0xE7 - Used to pass Unicode characters as if they were keystrokes
;
;                                0xF6 - Attn key
;                                0xF7 - CrSel key
;                                0xF8 - ExSel key
;                                0xF9 - Erase EOF key
;                                0xFA - Play key
;                                0xFB - Zoom key
;
;                                0xFD - PA1 key
;                                0xFE - Clear key
;
;                  $iFlags     - This parameter can be one or more of the following values.
;
;                                $KEYEVENTF_EXTENDEDKEY
;                                $KEYEVENTF_KEYUP
;
;                  $iScanCode  - The hardware scan code for the key.
;                  $iExtraInfo - The additional value associated with the key stroke.
; Return values..: Success     - 1.
;                  Failure     - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ keybd_event
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_Keybd_Event($vkCode, $iFlags, $iScanCode = 0, $iExtraInfo = 0)
	DllCall('user32.dll', 'int', 'keybd_event', 'int', $vkCode, 'int', $iScanCode, 'int', $iFlags, 'ptr', $iExtraInfo)
	If @error Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_Keybd_Event

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_KillTimer
; Description....: Destroys the specified timer.
; Syntax.........: _WinAPI_KillTimer ( $hWnd, $iTimerId )
; Parameters.....: $hWnd     - Handle to the window associated with the specified timer. This value must be the same as the
;                              $hWnd value passed to the _WinAPI_SetTimer() function that created the timer.
;                  $iTimerId - The timer identifier which specifies the timer to be destroyed.
; Return values..: Success   - 1.
;                  Failure   - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: This function does not remove WM_TIMER messages already posted to the message queue.
; Related........:
; Link...........: @@MsdnLink@@ KillTimer
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_KillTimer($hWnd, $iTimerId)

	Local $Ret = DllCall('user32.dll', 'int', 'KillTimer', 'hwnd', $hWnd, 'int', $iTimerId)

	If (@error) Or ($Ret[0] = 0) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_KillTimer

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_LoadCursor
; Description....: Loads the specified cursor resource from the executable (.EXE) file.
; Syntax.........: _WinAPI_LoadCursor ( $hInstance, $sName )
; Parameters.....: $hInstance - Handle to an instance of the module whose executable file contains the cursor to be loaded.
;                  $sName     - The name of the cursor resource or resource identifier to be loaded. To use one of the predefined
;                               cursors, the application must set the $hInstance parameter to 0 and the $sName parameter to one
;                               of the following values.
;
;                               $IDC_APPSTARTING
;                               $IDC_HAND
;                               $IDC_ARROW
;                               $IDC_CROSS
;                               $IDC_IBEAM
;                               $IDC_ICON
;                               $IDC_NO
;                               $IDC_SIZE
;                               $IDC_SIZEALL
;                               $IDC_SIZENESW
;                               $IDC_SIZENS
;                               $IDC_SIZENWSE
;                               $IDC_SIZEWE
;                               $IDC_UPARROW
;                               $IDC_WAIT
;
; Return values..: Success    - Handle to the newly loaded cursor.
;                  Failure    - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: This function loads the cursor resource only if it has not been loaded; otherwise, it retrieves the handle to
;                  the existing resource.
; Related........:
; Link...........: @@MsdnLink@@ LoadCursor
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_LoadCursor($hInstance, $sName)

	Local $TypeOfName = 'long'

	If IsString($sName) Then
		$TypeOfName = 'str'
	EndIf

	Local $Ret = DllCall('user32.dll', 'ptr', 'LoadCursor', 'ptr', $hInstance, $TypeOfName, $sName)

	If (@error) Or ($Ret[0] = 0) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_LoadCursor

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_LoadCursorFromFile
; Description....: Creates a cursor based on data contained in a file.
; Syntax.........: _WinAPI_LoadCursorFromFile ( $sFile )
; Parameters.....: $sFile  - The file data to be used to create the cursor. The data in the file must be in either .CUR or .ANI format.
; Return values..: Success - Handle to the new cursor.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ LoadCursorFromFile
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_LoadCursorFromFile($sFile)

	Local $Ret = DllCall('user32.dll', 'ptr', 'LoadCursorFromFileW', 'wstr', $sFile)

	If (@error) Or ($Ret[0] = 0) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_LoadCursorFromFile

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_LoadMedia
; Description....: Causes media to be loaded in a device.
; Syntax.........: _WinAPI_LoadMedia ( $sDrive )
; Parameters.....: $sDrive - The drive letter of the CD tray to load, in the format D:, E:, etc.
; Return values..: Success - 1.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ IOCTL_STORAGE_LOAD_MEDIA
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_LoadMedia($sDrive)

	If Not (_WinAPI_GetDriveType($sDrive) = $DRIVE_CDROM) Then
		Return SetError(1, 0, 0)
	EndIf

	Local $hFile = _WinAPI_CreateFile('\\.\' & $sDrive, 2, 2, 2)

	If $hFile = 0 Then
		Return SetError(1, 0, 0)
	EndIf

	Local $Ret = DllCall('kernel32.dll', 'int', 'DeviceIoControl', 'ptr', $hFile, 'dword', 0x002D480C, 'ptr', 0, 'dword', 0, 'ptr', 0, 'dword', 0, 'dword*', 0, 'ptr', 0)

	If @error Then
		$Ret = 0
	EndIf
	_WinAPI_FreeHandle($hFile)
	If Not IsArray($Ret) Then
		Return SetError(2, 0, 0)
	EndIf
	Return SetError(0, 0, $Ret[0])
EndFunc   ;==>_WinAPI_LoadMedia

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_LoadResource
; Description....: Loads the specified resource into global memory.
; Syntax.........: _WinAPI_LoadResource ( $hInstance, $hInfo )
; Parameters.....: $hInstance - Handle to the module whose executable file contains the resource. If this parameter is 0, the system
;                               loads the resource from the module that was used to create the current process.
;                  $hInfo     - Handle to the resource to be loaded. This handle is returned by the _WinAPI_FindResource()
;                               or _WinAPI_FindResourceEx() function.
; Return values..: Success    - Handle to the data associated with the resource.
;                  Failure    - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: To obtain a pointer to the resource data, call the _WinAPI_LockResource() function.
; Related........:
; Link...........: @@MsdnLink@@ LoadResource
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_LoadResource($hInstance, $hInfo)

	Local $Ret = DllCall('kernel32.dll', 'long', 'LoadResource', 'long', $hInstance, 'long', $hInfo)

	If (@error) Or ($Ret[0] = 0) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_LoadResource

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_LockDevice
; Description....: Enables or disables the mechanism that ejects media, for those devices possessing that locking capability.
; Syntax.........: _WinAPI_LockDevice ( $sDrive, $fLock )
; Parameters.....: $sDrive - The drive letter of the device to enable or disable, in the format D:, E:, etc.
;                  $fLock  - Specifies whether the device should be disabled, valid values:
;                  |TRUE   - The device is disabled.
;                  |FALSE  - The device is enabled.
; Return values..: Success - 1.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Psandu.ro
; Modified.......: Yashied
; Remarks........: This function is valid only for devices that support removable media.
; Related........:
; Link...........: @@MsdnLink@@ IOCTL_STORAGE_MEDIA_REMOVAL
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_LockDevice($sDrive, $fLock)

	Local $hFile = _WinAPI_CreateFile('\\.\' & $sDrive, 2, 6, 6)

	If $hFile = 0 Then
		Return SetError(1, 0, 0)
	EndIf

	Local $tPREVENT_MEDIA_REMOVAL = DllStructCreate('byte')

	DllStructSetData($tPREVENT_MEDIA_REMOVAL, 1, $fLock)

	Local $Ret = DllCall('kernel32.dll', 'int', 'DeviceIoControl', 'ptr', $hFile, 'dword', 0x002D4804, 'ptr', DllStructGetPtr($tPREVENT_MEDIA_REMOVAL), 'dword', DllStructGetSize($tPREVENT_MEDIA_REMOVAL), 'ptr', 0, 'dword', 0, 'dword*', 0, 'ptr', 0)

	If (@error) Or ($Ret[0] = 0) Then
		$Ret = 0
	EndIf
	_WinAPI_FreeHandle($hFile)
	If Not IsArray($Ret) Then
		Return SetError(2, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_LockDevice

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_LockResource
; Description....: Locks the specified resource in memory.
; Syntax.........: _WinAPI_LockResource ( $hData )
; Parameters.....: $hData  - Handle to the resource to be locked. The _WinAPI_LoadResource() function returns this handle. Do not
;                            pass any value as a parameter other than a successful return value from the LoadResource function.
; Return values..: Success - Pointer to the first byte of the resource.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: The pointer returned by this function is valid until the module containing the resource is unloaded. It is not
;                  necessary to unlock resources because the system automatically deletes them when the process that created
;                  them terminates.
;
;                  Do not try to lock a resource by using the handle returned by the _WinAPI_FindResource() or _WinAPI_FindResourceEx()
;                  function. Such a handle points to random data.
; Related........:
; Link...........: @@MsdnLink@@ LockResource
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_LockResource($hData)

	Local $Ret = DllCall('kernel32.dll', 'long', 'LockResource', 'long', $hData)

	If (@error) Or ($Ret[0] = 0) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_LockResource

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_LockWorkStation
; Description....: Locks the workstation's display.
; Syntax.........: _WinAPI_LockWorkStation ( )
; Parameters.....: None
; Return values..: Success - 1.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ LockWorkStation
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_LockWorkStation()
	DllCall('user32.dll', 'int', 'LockWorkStation')
	If @error Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_LockWorkStation

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_MoveFileEx
; Description....: Moves an existing file or directory, including its children, with various move options.
; Syntax.........: _WinAPI_MoveFileEx ( $sSource, $sDestination [, $iFlags] )
; Parameters.....: $sSource      - The current name of the file or directory on the local computer.
;                  $sDestination - The new name of the file or directory on the local computer.
;
;                                  When moving a file, the destination can be on a different file system or volume. If the destination
;                                  is on another drive, you must set the $MOVEFILE_COPY_ALLOWED.
;
;                                  When moving a directory, the destination must be on the same drive.
;
;                                  If $iFlags specifies $MOVEFILE_DELAY_UNTIL_REBOOT and $sDestination is empty string, _WinAPI_MoveFileEx()
;                                  registers the $sSource file to be deleted when the system restarts. If $sSource refers to a
;                                  directory, the system removes the directory at restart only if the directory is empty.
;
;                  $iFlags       - The flags that specify the move options. This parameter can be one or more of the following values.
;
;                                  $MOVEFILE_COPY_ALLOWED
;                                  $MOVEFILE_CREATE_HARDLINK
;                                  $MOVEFILE_DELAY_UNTIL_REBOOT
;                                  $MOVEFILE_FAIL_IF_NOT_TRACKABLE
;                                  $MOVEFILE_REPLACE_EXISTING
;                                  $MOVEFILE_WRITE_THROUGH
;
; Return values..: Success       - 1.
;                  Failure       - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: If the $iFlags parameter specifies $MOVEFILE_DELAY_UNTIL_REBOOT, _WinAPI_MoveFileEx() fails if it cannot
;                  access the registry. The function stores the locations of the files to be renamed at restart in the following
;                  registry value:
;
;                  HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\PendingFileRenameOperations
;
; Related........:
; Link...........: @@MsdnLink@@ MoveFileEx
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_MoveFileEx($sSource, $sDestination, $iFlags = 2)

	Local $TypeOfDestination = 'wstr'

	If StringStripWS($sDestination, 3) = '' Then
		$TypeOfDestination = 'ptr'
		$sDestination = 0
	EndIf

	Local $Ret = DllCall('kernel32.dll', 'int', 'MoveFileExW', 'wstr', $sSource, $TypeOfDestination, $sDestination, 'dword', $iFlags)

	If (@error) Or ($Ret[0] = 0) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_MoveFileEx

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_OemToChar
; Description....: Converts a string from the OEM-defined character set into either an ANSI string.
; Syntax.........: _WinAPI_OemToChar ( $sStr )
; Parameters.....: $sStr   - The string of characters from the OEM-defined character set.
; Return values..: Success - The converted string.
;                  Failure - Empty string and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ OemToChar
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_OemToChar($sStr)

	Local $tData = DllStructCreate('char[' & StringLen($sStr) + 1 & ']')
	Local $Ret = DllCall('user32.dll', 'int', 'OemToChar', 'str', $sStr, 'ptr', DllStructGetPtr($tData))

	If (@error) Or ($Ret[0] = 0) Then
		Return SetError(1, 0, '')
	EndIf
	Return DllStructGetData($tData, 1)
EndFunc   ;==>_WinAPI_OemToChar

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_OffsetClipRgn
; Description....: Moves the clipping region of a device context by the specified offsets.
; Syntax.........: _WinAPI_OffsetClipRgn ( $hDC, $iXOffset, $iYOffset )
; Parameters.....: $hDC      - Handle to the device context.
;                  $iXOffset - The number of logical units to move left or right.
;                  $iYOffset - The number of logical units to move up or down.
; Return values..: Success   - The value specifies the new clipping region's complexity; it can be one of the following values.
;
;                              $NULLREGION
;                              $SIMPLEREGION
;                              $COMPLEXREGION
;
;                  Failure   - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ OffsetClipRgn
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_OffsetClipRgn($hDC, $iXOffset, $iYOffset)

	Local $Ret = DllCall('gdi32.dll', 'int', 'OffsetClipRgn', 'hwnd', $hDC, 'int', $iXOffset, 'int', $iYOffset)

	If (@error) Or ($Ret[0] = 0) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_OffsetClipRgn

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_OffsetRect
; Description....: Moves the specified rectangle by the specified offsets.
; Syntax.........: _WinAPI_OffsetRect( ByRef $tRECT, $DX, $DY )
; Parameters.....: $tRECT  - $tagRECT structure that to be moved.
;                  $DX     - The amount to move the rectangle left (negative value) or right.
;                  $DY     - The amount to move the rectangle up (negative value) or down.
; Return values..: Success - 1.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ OffsetRect
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_OffsetRect(ByRef $tRECT, $DX, $DY)

	Local $Ret = DllCall('user32.dll', 'int', 'OffsetRect', 'ptr', DllStructGetPtr($tRECT), 'int', $DX, 'int', $DY)

	If (@error) Or ($Ret[0] = 0) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_OffsetRect

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_OffsetRgn
; Description....: Moves a region by the specified offsets.
; Syntax.........: _WinAPI_OffsetRgn ( $hRgn, $iXOffset, $iYOffset )
; Parameters.....: $hRgn     - Handle to the region to be moved.
;                  $iXOffset - The number of logical units to move left or right.
;                  $iYOffset - The number of logical units to move up or down.
; Return values..: Success   - The value specifies the new clipping region's complexity; it can be one of the following values.
;
;                              $NULLREGION
;                              $SIMPLEREGION
;                              $COMPLEXREGION
;
;                  Failure   - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ OffsetRgn
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_OffsetRgn($hRgn, $iXOffset, $iYOffset)

	Local $Ret = DllCall('gdi32.dll', 'int', 'OffsetRgn', 'ptr', $hRgn, 'int', $iXOffset, 'int', $iYOffset)

	If (@error) Or ($Ret[0] = 0) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_OffsetRgn

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_OpenIcon
; Description....: Restores a minimized (iconic) window to its previous size and position and activates the window.
; Syntax.........: _WinAPI_OpenIcon ( $hWnd )
; Parameters.....: $hWnd   - Handle to the window to be restored and activated.
; Return values..: Success - 1.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ OpenIcon
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_OpenIcon($hWnd)

	Local $Ret = DllCall('user32.dll', 'int', 'OpenIcon', 'hwnd', $hWnd)

	If (@error) Or ($Ret[0] = 0) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_OpenIcon

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_OpenSemaphore
; Description....: Opens an existing named semaphore object.
; Syntax.........: _WinAPI_OpenSemaphore ( $sSemaphore [, $iAccess] )
; Parameters.....: $sSemaphore - The name of the semaphore to be opened. Name comparisons are case sensitive.
;                  $iAccess    - The access to the semaphore object. The function fails if the security descriptor of the specified
;                                object does not permit the requested access for the calling process. This parameter can be one of
;                                the following values.
;
;                                $SEMAPHORE_ALL_ACCESS
;                                $SEMAPHORE_MODIFY_STATE
;
; Return values..: Success     - The handle to the semaphore object.
;                  Failure     - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: The function succeeds only if some process has already created the semaphore by using the _WinAPI_CreateSemaphore()
;                  function. The calling process can use the returned handle in any function that requires a handle to
;                  a semaphore object
; Related........:
; Link...........: @@MsdnLink@@ OpenSemaphore
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_OpenSemaphore($sSemaphore, $iAccess = 0x00100000)

	Local $Ret = DllCall('kernel32.dll', 'ptr', 'OpenSemaphore', 'dword', $iAccess, 'int', 0, 'str', $sSemaphore)

	If (@error) Or ($Ret[0] = 0) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_OpenSemaphore

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_PaintRgn
; Description....: Paints the specified region by using the brush currently selected into the device context.
; Syntax.........: _WinAPI_PaintRgn ( $hDC, $hRgn )
; Parameters.....: $hDC    - Handle to the device context.
;                  $hRgn   - Handle to the region to be filled. The region's coordinates are presumed to be logical coordinates.
; Return values..: Success - 1.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ PaintRgn
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_PaintRgn($hDC, $hRgn)

	Local $Ret = DllCall('gdi32.dll', 'int', 'PaintRgn', 'hwnd', $hDC, 'ptr', $hRgn)

	If (@error) Or ($Ret[0] = 0) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_PaintRgn

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_PathCompactPath
; Description....: Truncates a file path to fit within a given pixel width by replacing path components with ellipses.
; Syntax.........: _WinAPI_PathCompactPath ( $hWnd, $sPath [, $iWidth] )
; Parameters.....: $hWnd   - Handle to the window used for font metrics.
;                  $sPath  - The path to be modified.
;                  $iWidth - The width, in pixels, in which the string must fit. If this parameter is (-1), width will be equal to
;                            the width of the window.
; Return values..: Success - The modified path.
;                  Failure - The original $sPath parameter and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: This function will not compact the path beyond the base file name preceded by ellipses.
; Related........:
; Link...........: @@MsdnLink@@ PathCompactPath
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_PathCompactPath($hWnd, $sPath, $iWidth = -1)

	Local $hDC, $hBack, $tPath = DllStructCreate('wchar[' & (StringLen($sPath) + 1) & ']')
	Local $Ret

	If $iWidth < 0 Then
		$iWidth = _WinAPI_GetWindowWidth($hWnd)
	EndIf
	$Ret = DllCall('user32.dll', 'hwnd', 'GetDC', 'hwnd', $hWnd)
	If (@error) Or ($Ret[0] = 0) Then
		Return SetError(1, 0, $sPath)
	EndIf
	$hDC = $Ret[0]
	$Ret = DllCall('user32.dll', 'ptr', 'SendMessage', 'hwnd', $hWnd, 'int', 0x0031, 'int', 0, 'int', 0)
	$hBack = _WinAPI_SelectObject($hDC, $Ret[0])
	DllStructSetData($tPath, 1, $sPath)
	$Ret = DllCall('shlwapi.dll', 'int', 'PathCompactPathW', 'hwnd', $hDC, 'ptr', DllStructGetPtr($tPath), 'int', $iWidth)
	If (@error) Or ($Ret[0] = 0) Then
		$Ret = 0
	EndIf
	_WinAPI_SelectObject($hDC, $hBack)
	_WinAPI_ReleaseDC($hWnd, $hDC)
	If Not IsArray($Ret) Then
		Return SetError(1, 0, $sPath)
	EndIf
	Return DllStructGetData($tPath, 1)
EndFunc   ;==>_WinAPI_PathCompactPath

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_PathFindOnPath
; Description....: Searches for a file.
; Syntax.........: _WinAPI_PathFindOnPath ( $sFile [, $aDirs [, $iStart [, $iEnd]]] )
; Parameters.....: $sFile  - The file name for which to search.
;                  $aDirs  - The array of directories to be searched first. If this parameter is not an array, function attempts to
;                            find the file by searching standard directories such as System32 and the directories specified in the
;                            PATH environment variable.
;                  $iStart - The index of array to start searching at.
;                  $iEnd   - The index of array to stop searching at.
; Return values..: Success - The fully qualified path.
;                  Failure - The original $sFile parameter and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ PathFindOnPath
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_PathFindOnPath($sFile, $aDirs = 0, $iStart = 0, $iEnd = -1)

	Local $Count, $tPtrs = 0, $tDirs, $sDirs = ''

	If IsArray($aDirs) Then
		If $iStart < 0 Then
			$iStart = 0
		EndIf
		If ($iEnd < 0) Or ($iEnd > UBound($aDirs) - 1) Then
			$iEnd = UBound($aDirs) - 1
		EndIf
		For $i = $iStart To $iEnd
			$sDirs &= 'wchar[' & (StringLen($aDirs[$i]) + 1) & '];'
		Next
		$tDirs = DllStructCreate(StringTrimRight($sDirs, 1))
		If Not @error Then
			$tPtrs = DllStructCreate('ptr[' & ($iEnd - $iStart + 2) & ']')
			$Count = 1
			For $i = $iStart To $iEnd
				DLLStructSetData($tDirs, $Count, $aDirs[$i])
				DLLStructSetData($tPtrs, 1, DLLStructGetPtr($tDirs, $Count), $Count)
				$Count += 1
			Next
			DLLStructSetData($tPtrs, 1, Ptr(0), $Count)
		EndIf
	EndIf

	Local $tPath = DllStructCreate('wchar[1024]')

	DllStructSetData($tPath, 1, $sFile)

	Local $Ret = DllCall('shlwapi.dll', 'int', 'PathFindOnPathW', 'ptr', DllStructGetPtr($tPath), 'ptr', DllStructGetPtr($tPtrs))

	If (@error) Or ($Ret[0] = 0) Then
		Return SetError(1, 0, $sFile)
	EndIf
	Return DllStructGetData($tPath, 1)
EndFunc   ;==>_WinAPI_PathFindOnPath

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_PathIsDirectory
; Description....: Verifies that a path is a valid directory.
; Syntax.........: _WinAPI_PathIsDirectory ( $sPath )
; Parameters.....: $sPath  - The path to verify.
; Return values..: Success - 1 - The path is a valid directory.
;                            0 - Otherwise.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ PathIsDirectory
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_PathIsDirectory($sPath)

	Local $Ret = DllCall('shlwapi.dll', 'int', 'PathIsDirectoryW', 'wstr', $sPath)

	If @error Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_PathIsDirectory

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_PathIsDirectoryEmpty
; Description....: Determines whether a specified path is an empty directory.
; Syntax.........: _WinAPI_PathIsDirectoryEmpty ( $sPath )
; Parameters.....: $sPath  - The path to be tested.
; Return values..: Success - 1 - The path is an empty directory.
;                            0 - Otherwise.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ PathIsDirectoryEmpty
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_PathIsDirectoryEmpty($sPath)

	Local $Ret = DllCall('shlwapi.dll', 'int', 'PathIsDirectoryEmptyW', 'wstr', $sPath)

	If @error Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_PathIsDirectoryEmpty

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_PathMatchSpec
; Description....: Searches a string using a Microsoft MS-DOS wild card match type.
; Syntax.........: _WinAPI_PathMatchSpec ( $sPath, $sSpec )
; Parameters.....: $sPath  - The path to be searched.
;                  $sSpec  - The file type for which to search. For example, to test whether $sPath is a .doc file,
;                            $sSpec should be set to "*.doc".
; Return values..: Success - 1 - The string matches.
;                            0 - Otherwise.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ PathMatchSpec
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_PathMatchSpec($sPath, $sSpec)

	Local $Ret = DllCall('shlwapi.dll', 'int', 'PathMatchSpecW', 'wstr', $sPath, 'wstr', $sSpec)

	If @error Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_PathMatchSpec

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_PathSearchAndQualify
; Description....: Formats a path to the fully qualified path.
; Syntax.........: _WinAPI_PathSearchAndQualify ( $sPath )
; Parameters.....: $sPath  - The path to be formated.
; Return values..: Success - The formated path.
;                  Failure - The original $sPath parameter and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ PathSearchAndQualify
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_PathSearchAndQualify($sPath)

	Local $tPath = DllStructCreate('wchar[1024]')
	Local $Ret = DllCall('shlwapi.dll', 'int', 'PathSearchAndQualifyW', 'wstr', $sPath, 'ptr', DllStructGetPtr($tPath), 'int', 1024)

	If @error Then
		Return SetError(1, 0, $sPath)
	EndIf
	Return DllStructGetData($tPath, 1)
EndFunc   ;==>_WinAPI_PathSearchAndQualify

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_PathYetAnotherMakeUniqueName
; Description....: Creates a unique filename based on an existing filename.
; Syntax.........: _WinAPI_PathYetAnotherMakeUniqueName ( $sPath )
; Parameters.....: $sPath  - The file name that the unique name will be based on.
; Return values..: Success - 1.
;                  Failure - Empty string and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ PathYetAnotherMakeUniqueName
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_PathYetAnotherMakeUniqueName($sPath)

	Local $tData = DllStructCreate('wchar[1024]')
	Local $Ret = DllCall('shell32.dll', 'int', 'PathYetAnotherMakeUniqueName', 'ptr', DllStructGetPtr($tData), 'wstr', $sPath, 'ptr', 0, 'ptr', 0)

	If (@error) Or ($Ret[0] = 0) Then
		Return SetError(1, 0, '')
	EndIf
	Return DllStructGetData($tData, 1)
EndFunc   ;==>_WinAPI_PathYetAnotherMakeUniqueName

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_PickIconDlg
; Description....: Displays a dialog box that allows the user to choose an icon.
; Syntax.........: _WinAPI_PickIconDlg ( [$sIcon [, $iIndex [, $hParent]]] )
; Parameters.....: $sIcon   - The fully-qualified path of the file that contains the initial icon.
;                  $iIndex  - The index of the initial icon.
;                  $hParent - Handle of the parent window.
; Return values..: Success  - The array containing the following parameters:
;                             [0] - The path of the file that contains the selected icon.
;                             [1] - The index of the selected icon.
;                  Failure  - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: This function also sets the @error flag to 1 if the icon was not selected.
; Related........:
; Link...........: @@MsdnLink@@ PickIconDlg
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_PickIconDlg($sIcon = '', $iIndex = 0, $hParent = 0)

	Local $tIcon = DllStructCreate('wchar[1024]'), $tIndex = DllStructCreate('int')
	Local $Ret, $Error = 1, $Result[2] = [$sIcon, $iIndex]

	DllStructSetData($tIcon, 1, $sIcon)
	DllStructSetData($tIndex, 1, $iIndex)
	$Ret = DllCall('shell32.dll', 'int', 'PickIconDlg', 'hwnd', $hParent, 'ptr', DllStructGetPtr($tIcon), 'int', 1024, 'ptr', DllStructGetPtr($tIndex))
	If (Not @error) And ($Ret[0] > 0) Then
		$Ret = DllCall('kernel32.dll', 'int', 'ExpandEnvironmentStringsW', 'wstr', DllStructGetData($tIcon, 1), 'ptr', DllStructGetPtr($tIcon), 'int', 1024)
		If (Not @error) And ($Ret[0] > 0) Then
			$Result[0] = DllStructGetData($tIcon, 1)
			$Result[1] = DllStructGetData($tIndex, 1)
			$Error = 0
		EndIf
	EndIf
	Return SetError($Error, 0, $Result)
EndFunc   ;==>_WinAPI_PickIconDlg

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_Polygon
; Description....: Draws a polygon consisting of two or more vertices connected by straight lines.
; Syntax.........: _WinAPI_Polygon ( $hDC,  $aPoint [, $iStart [, $iEnd]] )
; Parameters.....: $dDC    - Handle to the device context.
;                  $aPoint - The 2D array ([x1, y1], [x2, y2], ... [xN, yN]) that contains the vertices of the polygon in logical
;                            units. The polygon is closed automatically by drawing a line from the last vertex to the first.
;                  $iStart - The index of array to start creating at.
;                  $iEnd   - The index of array to stop creating at.
; Return values..: Success - 1.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: The polygon is outlined by using the current pen and filled by using the current brush and polygon fill mode.
; Related........:
; Link...........: @@MsdnLink@@ Polygon
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_Polygon($hDC, $aPoint, $iStart = 0, $iEnd = -1)

	If UBound($aPoint, 2) < 2  Then
		Return SetError(2, 0, 0)
	EndIf

	Local $Count, $tData, $Struct = ''

	If $iStart < 0 Then
		$iStart = 0
	EndIf
	If ($iEnd < 0) Or ($iEnd > UBound($aPoint) - 1) Then
		$iEnd = UBound($aPoint) - 1
	EndIf
	For $i = $iStart To $iEnd
		$Struct &= 'int[2];'
	Next
	$tData = DllStructCreate(StringTrimRight($Struct, 1))
	If @error Then
		Return SetError(1, 0, 0)
	EndIf
	$Count = 1
	For $i = $iStart To $iEnd
		For $j = 0 To 1
			DllStructSetData($tData, $Count, $aPoint[$i][$j], $j + 1)
		Next
		$Count += 1
	Next

	Local $Ret = DllCall('gdi32.dll', 'ptr', 'Polygon', 'hwnd', $hDC, 'ptr', DllStructGetPtr($tData), 'int', $Count - 1)

	If (@error) Or ($Ret[0] = 0) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_Polygon

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_PrivateExtractIcon
; Description....: Extracts the icon with the specified dimension from the specified file.
; Syntax.........: _WinAPI_PrivateExtractIcon ( $sIcon, $iIndex, $iWidth, $iHeight )
; Parameters.....: $sIcon   - Path and name of the file from which the icon are to be extracted.
;                  $iIndex  - Index of the icon to extract.
;                  $iWidth  - Horizontal icon size wanted.
;                  $iHeight - Vertical icon size wanted.
; Return values..: Success  - Handle to the extracted icon.
;                  Failure  - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: If the icon with the specified dimension is not found in the file, it will choose the nearest appropriate icon and
;                  change to the specified dimension. When you are finished using the icon, destroy it using the _WinAPI_FreeIcon()
;                  function.
; Related........:
; Link...........: @@MsdnLink@@ PrivateExtractIcons
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_PrivateExtractIcon($sIcon, $iIndex, $iWidth, $iHeight)

	Local $Ret = DllCall('user32.dll', 'int', 'PrivateExtractIconsW', 'wstr', $sIcon, 'int', $iIndex, 'int', $iWidth, 'int', $iHeight, 'ptr*', 0, 'ptr*', 0, 'int', 1, 'int', 0)

	If (@error) Or ($Ret[0] = 0) Or ($Ret[5] = Ptr(0)) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[5]
EndFunc   ;==>_WinAPI_PrivateExtractIcon

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_PtInRectEx
; Description....: Determines whether the specified point lies within the specified rectangle.
; Syntax.........: _WinAPI_PtInRectEx ( $iX, $iY, $iLeft, $iTop, $iRight, $iBottom )
; Parameters.....: $iX      - The x-coordinate of the point.
;                  $iY      - The y-coordinate of the point.
;                  $iLeft   - The x-coordinate of the upper-left corner of the rectangle.
;                  $iTop    - The y-coordinate of the upper-left corner of the rectangle.
;                  $iRight  - The x-coordinate of the lower-right corner of the rectangle.
;                  $iBottom - The y-coordinate of the lower-right corner of the rectangle.
; Return values..: Success  - 1 - The specified point lies within the rectangle.
;                             0 - Otherwise.
;                  Failure  - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ PtInRect
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_PtInRectEx($iX, $iY, $iLeft, $iTop, $iRight, $iBottom)

	Local $tRECT = DllStructCreate($tagRECT)

	DllStructSetData($tRECT, 1, $iLeft)
	DllStructSetData($tRECT, 2, $iTop)
	DllStructSetData($tRECT, 3, $iRight)
	DllStructSetData($tRECT, 4, $iBottom)

	Local $Ret = DllCall('user32.dll', 'int', 'PtInRect', 'ptr', DllStructGetPtr($tRECT), 'int', $iX, 'int', $iY)

	If @error Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_PtInRectEx

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_PtInRegion
; Description....: Determines whether the specified point is inside the specified region.
; Syntax.........: _WinAPI_PtInRegion ( $hRgn, $iX, $iY )
; Parameters.....: $hRgn   - Handle to the region to be examined.
;                  $iX     - The x-coordinate of the point in logical units.
;                  $iY     - The y-coordinate of the point in logical units.
; Return values..: Success - 1 - The specified point is in the region.
;                            0 - Otherwise.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ PtInRegion
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_PtInRegion($hRgn, $iX, $iY)

	Local $Ret = DllCall('gdi32.dll', 'int', 'PtInRegion', 'ptr', $hRgn, 'int', $iX, 'int', $iY)

	If @error Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_PtInRegion

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_QueryDosDevice
; Description....: Retrieves the current mapping for a particular MS-DOS device name.
; Syntax.........: _WinAPI_QueryDosDevice ( $sDevice )
; Parameters.....: $sDevice - The name of the MS-DOS device.
; Return values..: Success  - The current mapping for the specified device. If the $sDevice parameter is empty string, return
;                             array of all existing MS-DOS device names (for example, \Device\HarddiskVolume1 or \Device\Floppy0).
;                             The zeroth array element contains the number of names.
;                  Failure  - Empty string and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ QueryDosDevice
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_QueryDosDevice($sDevice)

	Local $TypeOfDevice = 'wstr'

	If StringStripWS($sDevice, 3) = '' Then
		$TypeOfDevice = 'ptr'
		$sDevice = 0
	EndIf

	Local $tData = DllStructCreate('wchar[16384]')
	Local $Ret = DllCall('kernel32.dll', 'dword', 'QueryDosDeviceW', $TypeOfDevice, $sDevice, 'ptr', DllStructGetPtr($tData), 'dword', 16384)

	If (@error) Or ($Ret[0] = 0) Then
		Return SetError(1, 0, '')
	EndIf

	Local $Result = _WinAPI_StructToArray($tData, 1)

	If IsString($sDevice) Then
		$Result = $Result[1]
	EndIf
	Return $Result
EndFunc   ;==>_WinAPI_QueryDosDevice

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_Rectangle
; Description....: Draws a rectangle.
; Syntax.........: _WinAPI_Rectangle ( $hDC, $tRECT )
; Parameters.....: $hDC     - Handle to the device context.
;                  $tRECT   - $tagRECT structure that contains the logical coordinates of the rectangle.
; Return values..: Success  - 1.
;                  Failure  - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: The rectangle is outlined by using the current pen and filled by using the current brush.
; Related........:
; Link...........: @@MsdnLink@@ Rectangle
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_Rectangle($hDC, $tRECT)

	Local $Ret = DllCall('gdi32.dll', 'int', 'Rectangle', 'hwnd', $hDC, 'int', DllStructGetData($tRECT, 1), 'int', DllStructGetData($tRECT, 2), 'int', DllStructGetData($tRECT, 3), 'int', DllStructGetData($tRECT, 4))

	If (@error) Or ($Ret[0] = 0) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_Rectangle

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_RegisterShellHookWindow
; Description....: Registers a specified Shell window to receive certain messages for events or notifications.
; Syntax.........: _WinAPI_RegisterShellHookWindow ( $hWnd )
; Parameters.....: $hWnd   - Handle to the window to register for Shell hook messages.
; Return values..: Success - 1.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ RegisterShellHookWindow
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_RegisterShellHookWindow($hWnd)

	Local $Ret = DllCall('user32.dll', 'int', 'RegisterShellHookWindow', 'hwnd', $hWnd)

	If (@error) Or ($Ret[0] = 0) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_RegisterShellHookWindow

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_ReleaseSemaphore
; Description....: Increases the count of the specified semaphore object by a specified amount.
; Syntax.........: _WinAPI_ReleaseSemaphore ( $hSemaphore [, $iCount] )
; Parameters.....: $hSemaphore - Handle to the semaphore object. The _WinAPI_CreateSemaphore() or _WinAPI_OpenSemaphore() function
;                                returns this handle.
;                  $iIncrease  - The amount by which the semaphore object's current count is to be increased. The value must be greater
;                                than zero. If the specified amount would cause the semaphore's count to exceed the maximum count that
;                                was specified when the semaphore was created, the count is not changed and the function returns 0.
; Return values..: Success     - The previous count for the semaphore.
;                  Failure     - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: The state of a semaphore object is signaled when its count is greater than zero and nonsignaled when its count
;                  is equal to zero. The process that calls the _WinAPI_CreateSemaphore() function specifies the semaphore's initial
;                  count. Each time a waiting process is released because of the semaphore's signaled state, the count of the
;                  semaphore is decreased by one.
; Related........:
; Link...........: @@MsdnLink@@ ReleaseSemaphore
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_ReleaseSemaphore($hSemaphore, $iIncrease = 1)

	Local $Ret = DllCall('kernel32.dll', 'int', 'ReleaseSemaphore', 'ptr', $hSemaphore, 'int', $iIncrease, 'int*', 0)

	If (@error) Or ($Ret[0] = 0) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[3]
EndFunc   ;==>_WinAPI_ReleaseSemaphore

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_RemoveFontResource
; Description....: Removes the fonts in the specified file from the system font table.
; Syntax.........: _WinAPI_RemoveFontResource ( $sFont [, $fNotify] )
; Parameters.....: $sFont   - String that names a font resource file. To remove a font whose information comes from several resource
;                             files, they must be separated by a "|" . For example, abcxxxxx.pfm | abcxxxxx.pfb.
;                  $fNotify - Specifies whether sends a WM_FONTCHANGE message, valid values:
;                  |TRUE    - Send the WM_FONTCHANGE message to all top-level windows in the system after changing the pool of font resources.
;                  |FALSE   - Don`t send. (Default)
; Return values..: Success  - 1.
;                  Failure  - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ RemoveFontResource
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_RemoveFontResource($sFont, $fNotify = 0)

	Local $Ret = DllCall('gdi32.dll', 'int', 'RemoveFontResourceW', 'wstr', $sFont)

	If (@error) Or ($Ret[0] = 0) Then
		Return SetError(1, 0, 0)
	EndIf
	If $fNotify Then
		DllCall('user32.dll', 'int', 'SendMessage', 'hwnd', 0xFFFF, 'int', 0x001D, 'int', 0, 'int', 0)
	EndIf
	Return SetError(0, 0, 1)
EndFunc   ;==>_WinAPI_RemoveFontResource

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_RestartDlg
; Description....: Displays a dialog box that prompts the user to restart Microsoft Windows.
; Syntax.........: _WinAPI_RestartDlg( [$sText [, $iFlags [, $hParent]]] )
; Parameters.....: $sText   - The text that displays in the dialog box which prompts the user.
;                  $iFlags  - The flags that specify the type of shutdown.
;
;                             This parameter must include one of the following values.
;
;                             $EWX_LOGOFF
;                             $EWX_POWEROFF
;                             $EWX_REBOOT
;                             $EWX_SHUTDOWN
;
;                             This parameter can optionally include the following values.
;
;                             $EWX_FORCE
;                             $EWX_FORCEIFHUNG
;
;                  $hParent - Handle to the parent window.
; Return values..: Success  - The identifier of the button that was pressed to close the dialog box.
;                  Failure  - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ RestartDialog
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_RestartDlg($sText = '', $iFlags = 2, $hParent = 0)

	Local $Ret = DllCall('shell32.dll', 'int', 'RestartDialog', 'hwnd', $hParent, 'wstr', $sText, 'int', $iFlags)

	If @error Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_RestartDlg

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_RestoreDC
; Description....: Restores a device context (DC) to the specified state.
; Syntax.........: _WinAPI_RestoreDC ( $hDC, $ID )
; Parameters.....: $hDC    - Handle to the DC.
;                  $ID     - The saved state to be restored. If this parameter is positive, $DC represents a specific instance of the
;                            state to be restored. If this parameter is negative, $DC represents an instance relative to the current
;                            state. For example, (-1) restores the most recently saved state.
; Return values..: Success - 1.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ RestoreDC
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_RestoreDC($hDC, $ID)

	Local $Ret  = DllCall('gdi32.dll', 'int', 'RestoreDC', 'hwnd', $hDC, 'int', $ID)

	If (@error) Or ($Ret[0] = 0) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_RestoreDC

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_RGB
; Description....: Creates a RGB color value based on red, green, and blue components.
; Syntax.........: _WinAPI_RGB ( $iRed, $iGreen, $iBlue )
; Parameters.....: $iRed   - The intensity of the red color.
;                  $iGreen - The intensity of the green color.
;                  $iBlue  - The intensity of the blue color.
; Return values..: The resultant RGB color.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: None
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_RGB($iRed, $iGreen, $iBlue)
	Return __CheckColor(BitOR(BitShift($iBlue, -16), BitShift($iGreen, -8), $iRed))
EndFunc   ;==>_WinAPI_RGB

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_RoundRect
; Description....: Draws a rectangle with rounded corners. 
; Syntax.........: _WinAPI_RoundRect ( $hDC, $tRECT, $iWidth, $iHeight )
; Parameters.....: $hDC     - Handle to the device context.
;                  $tRECT   - $tagRECT structure that contains the logical coordinates of the rectangle.
;                  $iWidth  - The width, in logical coordinates, of the ellipse used to draw the rounded corners.
;                  $iHeight - The height, in logical coordinates, of the ellipse used to draw the rounded corners.
; Return values..: Success  - 1.
;                  Failure  - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: The rectangle is outlined by using the current pen and filled by using the current brush.
; Related........:
; Link...........: @@MsdnLink@@ RoundRect
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_RoundRect($hDC, $tRECT, $iWidth, $iHeight)

	Local $Ret = DllCall('gdi32.dll', 'int', 'RoundRect', 'hwnd', $hDC, 'int', DllStructGetData($tRECT, 1), 'int', DllStructGetData($tRECT, 2), 'int', DllStructGetData($tRECT, 3), 'int', DllStructGetData($tRECT, 4), 'int', $iWidth, 'int', $iHeight)

	If (@error) Or ($Ret[0] = 0) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_RoundRect

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_SaveDC
; Description....: Saves the current state of the specified device context (DC) by copying data describing selected objects and
;                  graphic modes to a context stack.
; Syntax.........: _WinAPI_SaveDC ( $hDC )
; Parameters.....: $hDC    - Handle to the DC whose state is to be saved.
; Return values..: Success - The value identifies the saved state.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ SaveDC
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_SaveDC($hDC)

	Local $Ret  = DllCall('gdi32.dll', 'ptr', 'SaveDC', 'hwnd', $hDC)

	If (@error) Or ($Ret[0] = 0) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_SaveDC

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_SetActiveWindow
; Description....: Activates the specified window.
; Syntax.........: _WinAPI_SetActiveWindow ( $hWnd )
; Parameters.....: $hWnd   - Handle to the top-level window to be activated.
; Return values..: Success - Handle to the window that was previously active.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ SetActiveWindow
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_SetActiveWindow($hWnd)

	Local $Ret = DllCall('user32.dll', 'int', 'SetActiveWindow', 'hwnd', $hWnd)

	If (@error) Or ($Ret[0] = 0) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_SetActiveWindow

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_SetClassLong
; Description....: Replaces the specified 32-bit (long) value into the specified window belongs.
; Syntax.........: _WinAPI_SetClassLong ( $hWnd, $iIndex, $dwNewLong )
; Parameters.....: $hWnd     - Handle to the window and, indirectly, the class to which the window belongs.
;                  $iIndex   - The 32-bit value to replace. This parameter can be one of the following values.
;
;                              $GCL_CBCLSEXTRA
;                              $GCL_CBWNDEXTRA
;                              $GCL_HBRBACKGROUND
;                              $GCL_HCURSOR
;                              $GCL_HICON
;                              $GCL_HICONSM
;                              $GCL_HMODULE
;                              $GCL_MENUNAME
;                              $GCL_STYLE
;                              $GCL_WNDPROC
;
;                  $iNewLong - The replacement value.
; Return values..: Success   - The previous value of the specified 32-bit integer. If the value was not previously set, the return value is zero.
;                  Failure   - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ SetClassLong
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_SetClassLong($hWnd, $iIndex, $iNewLong)

	Local $Ret = DllCall('user32.dll', 'int', 'SetClassLong', 'hwnd', $hWnd, 'int', $iIndex, 'long', $iNewLong)

	If (@error) Or ($Ret[0] = 0) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_SetClassLong

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_SetCompression
; Description....: Sets the compression state of a file or directory.
; Syntax.........: _WinAPI_SetCompression ( $sPath, $iCompression )
; Parameters.....: $sPath        - Path to file or directory to be compressed.
;                  $iCompression - One of the following compression constants.
;
;                                  $COMPRESSION_FORMAT_NONE
;                                  $COMPRESSION_FORMAT_DEFAULT
;                                  $COMPRESSION_FORMAT_LZNT1
;
; Return values..: Success       - 1.
;                  Failure       - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: If the file system of the volume containing the specified file or directory does not support per-file or
;                  per-directory compression, the function fails. File compression is supported for files of a maximum uncompressed
;                  size of 30 gigabytes.
; Related........:
; Link...........: @@MsdnLink@@ FSCTL_SET_COMPRESSION
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_SetCompression($sPath, $iCompression)

	Local $hFile = _WinAPI_CreateFileEx($sPath, 3, 0xC0000000, 0x03, 0x02000000)

	If Not $hFile Then
		Return SetError(1, 0, 0)
	EndIf

	Local $tData = DllStructCreate('ushort')

	DllStructSetData($tData, 1, $iCompression)

	Local $Ret = DllCall('kernel32.dll', 'int', 'DeviceIoControl', 'ptr', $hFile, 'dword', 0x0009C040, 'ptr', DllStructGetPtr($tData), 'dword', DllStructGetSize($tData), 'ptr', 0, 'dword', 0, 'dword*', 0, 'ptr', 0)

	If (@error) Or ($Ret[0] = 0) Then
		$Ret = 0
	EndIf
	_WinAPI_FreeHandle($hFile)
	If Not IsArray($Ret) Then
		Return SetError(2, 0, 0)
	EndIf
	Return SetError(0, 0, 1)
EndFunc   ;==>_WinAPI_SetCompression

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_SetCurrentDirectory
; Description....: Changes the current directory for the current process.
; Syntax.........: _WinAPI_SetCurrentDirectory ( $sDir )
; Parameters.....: $sDir   - The path to the new current directory.
; Return values..: Success - 1.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ SetCurrentDirectory
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_SetCurrentDirectory($sDir)

	Local $Ret = DllCall('kernel32.dll', 'int', 'SetCurrentDirectoryW', 'wstr', $sDir)

	If (@error) Or ($Ret[0] = 0) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_SetCurrentDirectory

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_SetDefaultPrinter
; Description....: Sets the printer name of the default printer for the current user on the local computer.
; Syntax.........: _WinAPI_SetDefaultPrinter ( $sPrinter )
; Parameters.....: $sPrinter - The default printer name. For a remote printer, the name format is \\server\printername. For a local
;                              printer, the name format is printername. If this parameter is empty string, this function will
;                              select a default printer from one of the installed printers.
; Return values..: Success   - 1.
;                  Failure   - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ SetDefaultPrinter
; Example........: Yes
; ===============================================================================================================================

#cs

Func _WinAPI_SetDefaultPrinter($sPrinter)

	Local $Ret = DllCall('winspool.drv', 'int', 'SetDefaultPrinterW', 'wstr', $sPrinter)

    If (@error) Or ($Ret[0] = 0) Then
		Return SetError(1, 0, 0)
	EndIf
    Return 1
EndFunc   ;==>_WinAPI_SetDefaultPrinter

#ce

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_SetDCBrushColor
; Description....: Sets the current device context (DC) brush color to the specified color value.
; Syntax.........: _WinAPI_SetDCBrushColor ( $hDC, $iRGB )
; Parameters.....: $hDC    - Handle to the device context.
;                  $iRGB   - The new brush color, in RGB.
; Return values..: Success - The value specifies the previous DC brush color, in RGB.
;                  Failure - (-1) and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: The function returns the previous $DC_BRUSH color, even if the stock brush $DC_BRUSH is not selected in the DC:
;                  however, this will not be used in drawing operations until the stock $DC_BRUSH is selected in the DC.
; Related........:
; Link...........: @@MsdnLink@@ SetDCBrushColor
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_SetDCBrushColor($hDC, $iRGB)

	Local $Ret = DllCall('gdi32.dll', 'dword', 'SetDCBrushColor', 'hwnd', $hDC, 'dword', __CheckColor($iRGB))

	If (@error) Or ($Ret[0] < 0) Then
		Return SetError(1, 0, -1)
	EndIf
	Return __CheckColor($Ret[0])
EndFunc   ;==>_WinAPI_SetDCBrushColor

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_SetDCPenColor
; Description....: Sets the current device context (DC) pen color to the specified color value.
; Syntax.........: _WinAPI_SetDCPenColor ( $hDC, $iRGB )
; Parameters.....: $hDC    - Handle to the device context.
;                  $iRGB   - The new pen color, in RGB.
; Return values..: Success - The value specifies the previous DC pen color, in RGB.
;                  Failure - (-1) and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: The function returns the previous $DC_PEN color, even if the stock pen $DC_PEN is not selected in the DC;
;                  however, this will not be used in drawing operations until the stock $DC_PEN is selected in the DC.
; Related........:
; Link...........: @@MsdnLink@@ SetDCPenColor
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_SetDCPenColor($hDC, $iRGB)

	Local $Ret = DllCall('gdi32.dll', 'dword', 'SetDCPenColor', 'hwnd', $hDC, 'dword', __CheckColor($iRGB))

	If (@error) Or ($Ret[0] < 0) Then
		Return SetError(1, 0, -1)
	EndIf
	Return __CheckColor($Ret[0])
EndFunc   ;==>_WinAPI_SetDCPenColor

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_SetFilePointerEx
; Description....: Moves the file pointer of the specified file.
; Syntax.........: _WinAPI_SetFilePointerEx ( $hFile, $iPos [, $iMethod] )
; Parameters.....: $hFile   - Handle to the file.
;                  $iPos    - The number of bytes to move the file pointer. A positive value moves the pointer forward in the
;                             file and a negative value moves the file pointer backward.
;                  $iMethod - The starting point for the file pointer move. This parameter can be one of the following values.
;
;                             $FILE_BEGIN
;                             $FILE_CURRENT
;                             $FILE_END
;
; Return values..: Success  - 1.
;                  Failure  - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ SetFilePointerEx
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_SetFilePointerEx($hFile, $iPos, $iMethod = 0)

	Local $Ret = DllCall('kernel32.dll', 'int', 'SetFilePointerEx', 'ptr', $hFile, 'int64', $iPos, 'int64*', 0, 'dword', $iMethod)

	If (@error) Or ($Ret[0] = 0) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_SetFilePointerEx

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_SetForegroundWindow
; Description....: Puts the specified window into the foreground and activates its.
; Syntax.........: _WinAPI_SetForegroundWindow ( $hWnd )
; Parameters.....: $hWnd   - Handle to the window that should be activated and brought to the foreground.
; Return values..: Success - 1.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ SetForegroundWindow
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_SetForegroundWindow($hWnd)

	Local $Ret = DllCall('user32.dll', 'int', 'SetForegroundWindow', 'hwnd', $hWnd)

	If (@error) Or ($Ret[0] = 0) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_SetForegroundWindow

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_SetHandleInformation
; Description....: Sets certain properties of an object handle.
; Syntax.........: _WinAPI_SetHandleInformation ( $hObject, $iMask, $iFlags )
; Parameters.....: $hObject - Handle to an object whose information is to be set.
;                  $iMask   - The mask that specifies the bit flags to be changed. Use the same constants as that of the $iFlags.
;                  $iFlags  - The flags that specifies properties of the object handle. This parameter can be 0 or one or
;                             more of the following values.
;
;                             $HANDLE_FLAG_INHERIT
;                             $HANDLE_FLAG_PROTECT_FROM_CLOSE
;
; Return values..: Success  - 1.
;                  Failure  - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ SetHandleInformation
; Example........: Yes
; ===============================================================================================================================

#cs

Func _WinAPI_SetHandleInformation($hObject, $iMask, $iFlags)

	Local $Ret = DllCall('kernel32.dll', 'int', 'SetHandleInformation', 'ptr', $hObject, 'dword', $iMask, 'dword', $iFlags)

	If (@error) Or ($Ret[0] = 0) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_SetHandleInformation

#ce

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_SetKeyboardLayout
; Description....: Loads a new input locale identifier to the specified window.
; Syntax.........: _WinAPI_SetKeyboardLayout ( $hWnd, $iLanguage )
; Parameters.....: $hWnd      - Handle to the window to load input locale identifier.
;                  $iLanguage - One of the following LCID constants.
;
;                               0x0436 - Afrikaans
;                               0x041C - Albanian
;                               0x0401 - Arabic
;                               0x1401 - Arabic Algeria
;                               0x3C01 - Arabic Bahrain
;                               0x0C01 - Arabic Egypt
;                               0x0801 - Arabic Iraq
;                               0x2C01 - Arabic Jordan
;                               0x3401 - Arabic Kuwait
;                               0x3001 - Arabic Lebanon
;                               0x1001 - Arabic Libya
;                               0x1801 - Arabic Morocco
;                               0x2001 - Arabic Oman
;                               0x4001 - Arabic Qatar
;                               0x0401 - Arabic Saudi Arabia
;                               0x2801 - Arabic Syria
;                               0x1C01 - Arabic Tunisia
;                               0x3801 - Arabic U.A.E
;                               0x2401 - Arabic Yemen
;                               0x042B - Armenian
;                               0x044D - Assamese
;                               0x082C - Azeri Cyrillic
;                               0x042C - Azeri Latin
;                               0x042D - Basque
;                               0x0813 - Belgian Dutch
;                               0x080C - Belgian French
;                               0x0445 - Bengali
;                               0x0416 - Portuguese (Brazil)
;                               0x0402 - Bulgarian
;                               0x0455 - Burmese
;                               0x0423 - Byelorussian (Belarusian)
;                               0x0403 - Catalan
;                               0x0C04 - Chinese Hong Kong SAR
;                               0x1404 - Chinese Macau SAR
;                               0x0804 - Chinese Simplified
;                               0x1004 - Chinese Singapore
;                               0x0404 - Chinese Traditional
;                               0x041A - Croatian
;                               0x0405 - Czech
;                               0x0406 - Danish
;                               0x0413 - Dutch
;                               0x0C09 - English Australia
;                               0x2809 - English Belize
;                               0x1009 - English Canadian
;                               0x2409 - English Caribbean
;                               0x1813 - English Ireland
;                               0x2009 - English Jamaica
;                               0x1409 - English New Zealand
;                               0x3409 - English Philippines
;                               0x1C09 - English South Africa
;                               0x2C09 - English Trinidad
;                               0x0809 - English U.K.
;                               0x0409 - English U.S.
;                               0x3009 - English Zimbabwe
;                               0x0425 - Estonian
;                               0x0438 - Faeroese
;                               0x0429 - Farsi
;                               0x040B - Finnish
;                               0x040C - French
;                               0x2C0C - French Cameroon
;                               0x0C0C - French Canadian
;                               0x300C - French Cote d'Ivoire
;                               0x140C - French Luxembourg
;                               0x340C - French Mali
;                               0x180C - French Monaco
;                               0x200C - French Reunion
;                               0x280C - French Senegal
;                               0x1C0C - French West Indies
;                               0x240C - French Congo (DRC)
;                               0x0462 - Frisian Netherlands
;                               0x083C - Gaelic Ireland
;                               0x043C - Gaelic Scotland
;                               0x0456 - Galician
;                               0x0437 - Georgian
;                               0x0407 - German
;                               0x0C07 - German Austria
;                               0x1407 - German Liechtenstein
;                               0x1007 - German Luxembourg
;                               0x0408 - Greek
;                               0x0447 - Gujarati
;                               0x040D - Hebrew
;                               0x0439 - Hindi
;                               0x040E - Hungarian
;                               0x040F - Icelandic
;                               0x0421 - Indonesian
;                               0x0410 - Italian
;                               0x0411 - Japanese
;                               0x044B - Kannada
;                               0x0460 - Kashmiri
;                               0x043F - Kazakh
;                               0x0453 - Khmer
;                               0x0440 - Kirghiz
;                               0x0457 - Konkani
;                               0x0412 - Korean
;                               0x0454 - Lao
;                               0x0426 - Latvian
;                               0x0427 - Lithuanian
;                               0x042F - FYRO Macedonian
;                               0x044C - Malayalam
;                               0x083E - Malay Brunei Darussalam
;                               0x043E - Malaysian
;                               0x043A - Maltese
;                               0x0458 - Manipuri
;                               0x044E - Marathi
;                               0x0450 - Mongolian
;                               0x0461 - Nepali
;                               0x0414 - Norwegian Bokmol
;                               0x0814 - Norwegian Nynorsk
;                               0x0448 - Oriya
;                               0x0415 - Polish
;                               0x0816 - Portuguese
;                               0x0446 - Punjabi
;                               0x0417 - Rhaeto-Romanic
;                               0x0418 - Romanian
;                               0x0818 - Romanian Moldova
;                               0x0419 - Russian
;                               0x0819 - Russian Moldova
;                               0x043B - Sami Lappish
;                               0x044F - Sanskrit
;                               0x0C1A - Serbian Cyrillic
;                               0x081A - Serbian Latin
;                               0x0430 - Sesotho
;                               0x0459 - Sindhi
;                               0x041B - Slovak
;                               0x0424 - Slovenian
;                               0x042E - Sorbian
;                               0x040A - Spanish (Traditional)
;                               0x2C0A - Spanish Argentina
;                               0x400A - Spanish Bolivia
;                               0x340A - Spanish Chile
;                               0x240A - Spanish Colombia
;                               0x140A - Spanish Costa Rica
;                               0x1C0A - Spanish Dominican Republic
;                               0x300A - Spanish Ecuador
;                               0x440A - Spanish El Salvador
;                               0x100A - Spanish Guatemala
;                               0x480A - Spanish Honduras
;                               0x4C0A - Spanish Nicaragua
;                               0x180A - Spanish Panama
;                               0x3C0A - Spanish Paraguay
;                               0x280A - Spanish Peru
;                               0x500A - Spanish Puerto Rico
;                               0x0C0A - Spanish Spain (Modern Sort)
;                               0x380A - Spanish Uruguay
;                               0x200A - Spanish Venezuela
;                               0x0430 - Sutu
;                               0x0441 - Swahili
;                               0x041D - Swedish
;                               0x081D - Swedish Finland
;                               0x100C - Swiss French
;                               0x0807 - Swiss German
;                               0x0810 - Swiss Italian
;                               0x0428 - Tajik
;                               0x0449 - Tamil
;                               0x0444 - Tatar
;                               0x044A - Telugu
;                               0x041E - Thai
;                               0x0451 - Tibetan
;                               0x0431 - Tsonga
;                               0x0432 - Tswana
;                               0x041F - Turkish
;                               0x0442 - Turkmen
;                               0x0422 - Ukrainian
;                               0x0420 - Urdu
;                               0x0843 - Uzbek Cyrillic
;                               0x0443 - Uzbek Latin
;                               0x0433 - Venda
;                               0x042A - Vietnamese
;                               0x0452 - Welsh
;                               0x0434 - Xhosa
;                               0x0435 - Zulu
;
; Return values..: Success    - 1.
;                  Failure    - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ LoadKeyboardLayout
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_SetKeyboardLayout($hWnd, $iLanguage)

	If Not _WinAPI_IsWindow($hWnd) Then
		Return SetError(1, 0, 0)
	EndIf

	Local $Ret = DllCall('user32.dll', 'long', 'LoadKeyboardLayout', 'str', '0000' & Hex($iLanguage, 4), 'int', 0)

	If (@error) Or ($Ret[0] = 0) Then
		Return SetError(1, 0, 0)
	EndIf
	DllCall('user32.dll', 'ptr', 'SendMessage', 'hwnd', $hWnd, 'int', 0x0050, 'int', 1, 'int', $Ret[0])
	Return SetError(0, 0, 1)
EndFunc   ;==>_WinAPI_SetKeyboardLayout

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_SetKeyboardState
; Description....: Copies a 256-byte array of keyboard key states into the calling process's keyboard input-state table.
; Syntax.........: _WinAPI_SetKeyboardState ( $tState )
; Parameters.....: $tData  - "byte[256]" structure that contains keyboard key states.
; Return values..: Success - 1.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: This function alters the input state of the calling process and not the global input state of the system.
;                  You cannot use this function to set the NUM LOCK, CAPS LOCK, or SCROLL LOCK indicator lights on the
;                  keyboard.
; Related........:
; Link...........: @@MsdnLink@@ SetKeyboardState
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_SetKeyboardState($tData)

	Local $Ret = DllCall('user32.dll', 'int', 'SetKeyboardState', 'ptr', DllStructGetPtr($tData))

	If (@error) Or ($Ret[0] = 0) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_SetKeyboardState

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_SetLayeredWindowAttributes
; Description....: Sets the opacity and transparency color key of a layered window.
; Syntax.........: _WinAPI_SetLayeredWindowAttributes ( $hWnd, $iRGB, $iAlpha, $iFlags )
; Parameters.....: $hWnd   - Handle to the layered window.
;                  $iRGB   - The transparency color key (in RGB) to be used when composing the layered window. All pixels painted
;                            by the window in this color will be transparent.
;                  $iAlpha - Alpha value used to describe the opacity of the layered window. When this parameter is 0, the window
;                            is completely transparent. When this parameter is 255, the window is opaque.
;                  $iFlags - This parameter specifies an action to take, and can be one or more of the following values.
;
;                            $LWA_COLORKEY
;                            $LWA_ALPHA
;
; Return values..: Success - 1
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: ProgAndy
; Modified.......: Yashied
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ SetLayeredWindowAttributes
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_SetLayeredWindowAttributes($hWnd, $iRGB, $iAlpha, $iFlags)

	Local $Ret = DllCall('user32.dll', 'int', 'SetLayeredWindowAttributes', 'hwnd', $hWnd, 'long', __CheckColor($iRGB), 'byte', $iAlpha, 'long', $iFlags)

	If (@error) Or ($Ret[0] = 0) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_SetLayeredWindowAttributes

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_SetLibraryColorMode
; Description....: Sets the color mode for the WinAPIEx library.
; Syntax.........: _WinAPI_SetLibraryColorMode ( $iMode )
; Parameters.....: $iMode - Specifies the color mode, valid values:
;                  |TRUE  - RGB
;                  |FALSE - BGR
; Return values..: None
; Author.........: Yashied
; Modified.......:
; Remarks........: The functions of this library, in which passes or which returns the color values, works with the values in
;                  accordance with the color mode that been set by this function. Initial color mode is RGB.
; Related........:
; Link...........: None
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_SetLibraryColorMode($iMode)
	$__RGB = Not ($iMode = 0)
EndFunc   ;==>_WinAPI_SetLibraryColorMode

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_SetParent
; Description....: Changes the parent window of the specified child window.
; Syntax.........: _WinAPI_SetParent ( $hWndChild, $hWndParent )
; Parameters.....: $hWndChild  - Handle to the child window.
;                  $hWndParent - Handle to the new parent window. If this parameter is 0, the desktop window becomes the new parent window.
; Return values..: Success     - Handle to the previous parent window.
;                  Failure     - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: An application can use the _WinAPI_SetParent() function to set the parent window of a pop-up, overlapped,
;                  or child window.
; Related........:
; Link...........: @@MsdnLink@@ SetParent
; Example........: Yes
; ===============================================================================================================================

#cs

Func _WinAPI_SetParent($hWndChild, $hWndParent)

	Local $Ret = DllCall('user32.dll', 'hwnd', 'SetParent', 'hwnd', $hWndChild, 'hwnd', $hWndParent)

	If (@error) Or ($Ret[0] = 0) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_SetParent

#ce

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_SetPixel
; Description....: Sets the pixel at the specified coordinates to the specified color.
; Syntax.........: _WinAPI_SetPixel ( $hDC, $iX, $iY, $iRGB )
; Parameters.....: $hDC    - Handle to the device context.
;                  $iX     - The x-coordinate, in logical units, of the point to be set.
;                  $iY     - The y-coordinate, in logical units, of the point to be set.
;                  $iRGB   - The color to be used to paint the point.
; Return values..: Success - 1.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ SetPixelV
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_SetPixel($hDC, $iX, $iY, $iRGB)

	Local $Ret = DllCall('gdi32.dll', 'int', 'SetPixelV', 'hwnd', $hDC, 'int', $iX, 'int', $iY, 'dword', __CheckColor($iRGB))

	If (@error) Or ($Ret[0] = 0) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_SetPixel

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_SetROP2
; Description....: Retrieves the foreground mix mode of the specified device context.
; Syntax.........: _WinAPI_SetROP2 ( $hDC, $iMode )
; Parameters.....: $hDC    - Handle to the device context.
;                  $iMode  - The mix mode. This parameter can be one of the following values.
;
;                            $R2_BLACK
;                            $R2_COPYPEN
;                            $R2_LAST
;                            $R2_MASKNOTPEN
;                            $R2_MASKPEN
;                            $R2_MASKPENNOT
;                            $R2_MERGENOTPEN
;                            $R2_MERGEPEN
;                            $R2_MERGEPENNOT
;                            $R2_NOP
;                            $R2_NOT
;                            $R2_NOTCOPYPEN
;                            $R2_NOTMASKPEN
;                            $R2_NOTMERGEPEN
;                            $R2_NOTXORPEN
;                            $R2_WHITE
;                            $R2_XORPEN
;
; Return values..: Success - The value specifies the previous mix mode.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: Mix modes define how GDI combines source and destination colors when drawing with the current pen. The mix modes
;                  are binary raster operation codes, representing all possible Boolean functions of two variables, using the binary
;                  operations AND, OR, and XOR (exclusive OR), and the unary operation NOT. The mix mode is for raster devices only;
;                  it is not available for vector devices.
; Related........:
; Link...........: @@MsdnLink@@ SetROP2
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_SetROP2($hDC, $iMode)

	Local $Ret = DllCall('gdi32.dll', 'int', 'SetROP2', 'hwnd', $hDC, 'int', $iMode)

	If (@error) Or ($Ret[0] = 0) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_SetROP2

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_SetStretchBltMode
; Description....: Sets the bitmap stretching mode in the specified device context.
; Syntax.........: _WinAPI_SetStretchBltMode ( $hDC, $iMode )
; Parameters.....: $hDC     - Handle to the device context.
;                  $iMode   - The stretching mode. This parameter can be one of the following values.
;
;                             $BLACKONWHITE
;                             $COLORONCOLOR
;                             $HALFTONE
;                             $WHITEONBLACK
;                             $STRETCH_ANDSCANS
;                             $STRETCH_DELETESCANS
;                             $STRETCH_HALFTONE
;                             $STRETCH_ORSCANS
;
; Return values..: Success  - 1.
;                  Failure  - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: The $BLACKONWHITE ($STRETCH_ANDSCANS) and $WHITEONBLACK ($STRETCH_ORSCANS) modes are typically used to
;                  preserve foreground pixels in monochrome bitmaps. The $COLORONCOLOR ($STRETCH_DELETESCANS) mode is typically
;                  used to preserve color in color bitmaps. The $HALFTONE ($STRETCH_HALFTONE) mode is slower and requires more
;                  processing of the source image than the other three modes; but produces higher quality images.
; Related........:
; Link...........: @@MsdnLink@@ SetStretchBltMode
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_SetStretchBltMode($hDC, $iMode)

	Local $Ret  = DllCall('gdi32.dll', 'int', 'SetStretchBltMode', 'hwnd', $hDC, 'int', $iMode)

	If (@error) Or ($Ret[0] = 0) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_SetStretchBltMode

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_SetSystemCursor
; Description....: Enables an application to customize the system cursors.
; Syntax.........: _WinAPI_SetSystemCursor ( $hCursor, $ID [, $fDuplicate] )
; Parameters.....: $hCursor    - Handle to a cursor.
;                  $ID         - This parameter specifies the system cursor to replace with the contents of $hCursor, and can be
;                                one of the following values.
;
;                                $OCR_APPSTARTING
;                                $OCR_NORMAL
;                                $OCR_CROSS
;                                $OCR_HAND
;                                $OCR_IBEAM
;                                $OCR_NO
;                                $OCR_SIZEALL
;                                $OCR_SIZENESW
;                                $OCR_SIZENS
;                                $OCR_SIZENWSE
;                                $OCR_SIZEWE
;                                $OCR_UP
;                                $OCR_WAIT
;                                $OCR_ICON
;                                $OCR_SIZE
;
;                  $fDuplicate - Specifies whether the cursor should be duplicated, valid values:
;                  |TRUE       - The cursor is duplicated.
;                  |FALSE      - The cursor is not duplicated. (Default)
; Return values..: Success     - 1.
;                  Failure     - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: The function replaces the contents of the system cursor specified by ID with the contents of the cursor handled
;                  by $hCursor. The system destroys hcur by calling the _WinAPI_FreeCursor() function. Therefore, $hCursor cannot be
;                  a cursor loaded using the _WinAPI_LoadCursor() function. To specify a cursor loaded from a resource, copy the
;                  cursor using the _WinAPI_DuplicateCursor() function, then pass the copy to _WinAPI_SetSystemCursor().
; Related........:
; Link...........: @@MsdnLink@@ SetSystemCursor
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_SetSystemCursor($hCursor, $ID, $fDuplicate = 0)

	If $fDuplicate Then
		$hCursor = _WinAPI_DuplicateCursor($hCursor)
	EndIf

	Local $Ret = DllCall('user32.dll', 'int', 'SetSystemCursor', 'ptr', $hCursor, 'dword', $ID)

	If (@error) Or ($Ret[0] = 0) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_SetSystemCursor

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_SetThemeAppProperties
; Description....: Sets the flags that determine how visual styles are implemented in the calling application.
; Syntax.........: _WinAPI_SetThemeAppProperties ( $iFlags )
; Parameters.....: $iFlags  - This parameter can be one or more of the following values.
;
;                            $STAP_ALLOW_NONCLIENT
;                            $STAP_ALLOW_CONTROLS
;                            $STAP_ALLOW_WEBCONTENT
;
; Return values..: Success  - 1.
;                  Failure  - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: After you set the flags, you must send a WM_THEMECHANGED message for the changes to take effect.
; Related........:
; Link...........: @@MsdnLink@@ SetThemeAppProperties
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_SetThemeAppProperties($iFlags)

	DllCall('uxtheme.dll', 'none', 'SetThemeAppProperties', 'dword', $iFlags)
	If @error Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_SetThemeAppProperties

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_SetTimer
; Description....: Creates a timer with the specified time-out value.
; Syntax.........: _WinAPI_SetTimer ( $hWnd, $iTimerId, $iElapse, $pTimerFunc )
; Parameters.....: $hWnd       - Handle to the window to be associated with the timer. This window must be owned by the calling
;                                process. If a 0 value for $hWnd is passed in along with an $iTimerId of an existing timer, that
;                                timer will be replaced in the same way that an existing non-zero $hWnd timer will be.
;                  $iTimerId   - The timer identifier. If the $hWnd parameter is 0, and the $iTimerId does not match an existing
;                                timer then it is ignored and a new timer ID is generated. If the $hWnd parameter is not 0 and
;                                the window specified by $hWnd already has a timer with the value $iTimerId, then the existing
;                                timer is replaced by the new timer. When _WinAPI_SetTimer() replaces a timer, the timer is reset.
;                                Therefore, a message will be sent after the current time-out value elapses, but the previously
;                                set time-out value is ignored. If the call is not intended to replace an existing timer,
;                                $iTimerId should be 0 if the $hWnd is 0.
;                  $iElapse    - The time-out value, in milliseconds.
;                  $pTimerFunc - The address of a callback function to be notified when the time-out value elapses. If this
;                                parameter is 0, the system posts a WM_TIMER message to the application queue.
; Return values..: Success     - The timer identifier. An application can pass this value to the _WinAPI_KillTimer() function to
;                                destroy the timer.
;                  Failure     - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: The timer identifier, $iTimerId, is specific to the associated window. Another window can have its own timer
;                  which has the same identifier as a timer owned by another window. The timers are distinct.
; Related........:
; Link...........: @@MsdnLink@@ SetTimer
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_SetTimer($hWnd, $iTimerId, $iElapse, $pTimerFunc)

	Local $Ret = DllCall('user32.dll', 'int', 'SetTimer', 'hwnd', $hWnd, 'int', $iTimerId, 'int', $iElapse, 'ptr', $pTimerFunc)

	If (@error) Or ($Ret[0] = 0) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_SetTimer

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_SetVolumeMountPoint
; Description....: Associates a volume with a drive letter or a directory on another volume.
; Syntax.........: _WinAPI_SetVolumeMountPoint ( $sPath, $GUID )
; Parameters.....: $sPath  - The user-mode path to be associated with the volume. This may be a drive letter (for example, X:\)
;                            or a directory on another volume (for example, Y:\MountX).
;                  $GUID   - The volume GUID path for the volume. This string must be of the form "\\?\Volume{GUID}\" where
;                            GUID is a GUID that identifies the volume. The \\?\ turns off path parsing and is ignored as part
;                            of the path.
; Return values..: Success - 1.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: It is an error to associate a volume with a directory that has any files or subdirectories in it. This error
;                  occurs for system and hidden directories as well as other directories, and it occurs for system and hidden
;                  files.
; Related........:
; Link...........: @@MsdnLink@@ SetVolumeMountPoint
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_SetVolumeMountPoint($sPath, $GUID)

	Local $Ret = DllCall('kernel32.dll', 'int', 'SetVolumeMountPointW', 'wstr', $sPath, 'wstr', $GUID)

	If (@error) Or ($Ret[0] = 0) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_SetVolumeMountPoint

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_ShareFolderDlg
; Description....: Displays the Folder Sharing tab on the properties sheet for the specified folder.
; Syntax.........: _WinAPI_ShareFolderDlg ( $sPath [, $hParent] )
; Parameters.....: $sPath   - The path to the folder that displays its Folder Sharing tab.
;                  $hParent - Handle to a parent window for the property sheet.
; Return values..: Success  - 1.
;                  Failure  - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ ShowShareFolderUI
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_ShareFolderDlg($sPath, $hParent = 0)

	Local $Ret = DllCall('ntshrui.dll', 'int', 'ShowShareFolderUIW', 'hwnd', $hParent, 'wstr', $sPath)

	If @error Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_ShareFolderDlg

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_ShellExtractIcons
; Description....: Extracts the icon with the specified dimension from the specified file.
; Syntax.........: _WinAPI_ShellExtractIcons ( $sIcon, $iIndex, $iWidth, $iHeight )
; Parameters.....: $sIcon   - Path and name of the file from which the icon are to be extracted.
;                  $iIndex  - Index of the icon to extract.
;                  $iWidth  - Horizontal icon size wanted.
;                  $iHeight - Vertical icon size wanted.
; Return values..: Success  - Handle to the extracted icon.
;                  Failure  - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: If the icon with the specified dimension is not found in the file, it will choose the nearest appropriate icon and
;                  change to the specified dimension. When you are finished using the icon, destroy it using the _WinAPI_FreeIcon()
;                  function.
; Related........:
; Link...........: @@MsdnLink@@ SHExtractIcons
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_ShellExtractIcons($sIcon, $iIndex, $iWidth, $iHeight)

	Local $Ret = DllCall('shell32.dll', 'int', 'SHExtractIconsW', 'wstr', $sIcon, 'int', $iIndex, 'int', $iWidth, 'int', $iHeight, 'ptr*', 0, 'ptr*', 0, 'int', 1, 'int', 0)

	If (@error) Or ($Ret[0] = 0) Or ($Ret[5] = Ptr(0)) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[5]
EndFunc   ;==>_WinAPI_ShellExtractIcons

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_ShellGetFileInfo
; Description....: Retrieves information about an object in the file system.
; Syntax.........: _WinAPI_ShellGetFileInfo ( $sPath, $iFlags [, $iAttributes] )
; Parameters.....: $sPath       - String that contains the absolute or relative path and file name. This string can use either
;                                 short (the 8.3 form) or long file names.
;
;                                 If the $iFlags parameter includes the $SHGFI_PIDL flag, this parameter must be the address of an
;                                 ITEMIDLIST (PIDL) structure that contains the list of item identifiers that uniquely identifies the
;                                 file within the Shell's namespace. The pointer to an item identifier list (PIDL) must be a fully
;                                 qualified PIDL. Relative PIDLs are not allowed.
;
;                                 If the $iFlags parameter includes the $SHGFI_USEFILEATTRIBUTES flag, this parameter does not have
;                                 to be a valid file name. The function will proceed as if the file exists with the specified name and
;                                 with the file attributes passed in the $iAttributes parameter. This allows you to obtain information
;                                 about a file type by passing just the extension for $sPath and passing $FILE_ATTRIBUTE_NORMAL
;                                 in $iAttributes.
;
;                  $iFlags      - The flags that specify the file information to retrieve. This parameter can be a combination of the
;                                 following values.
;
;                                 $SHGFI_ATTR_SPECIFIED
;                                 $SHGFI_ATTRIBUTES
;                                 $SHGFI_DISPLAYNAME
;                                 $SHGFI_EXETYPE
;                                 $SHGFI_ICON
;                                 $SHGFI_ICONLOCATION
;                                 $SHGFI_LARGEICON
;                                 $SHGFI_LINKOVERLAY
;                                 $SHGFI_OPENICON
;                                 $SHGFI_OVERLAYINDEX
;                                 $SHGFI_PIDL
;                                 $SHGFI_SELECTED
;                                 $SHGFI_SHELLICONSIZE
;                                 $SHGFI_SMALLICON
;                                 $SHGFI_SYSICONINDEX
;                                 $SHGFI_TYPENAME
;                                 $SHGFI_USEFILEATTRIBUTES
;
;                  $iAttributes - A combination of one or more file attribute flags ($FILE_ATTRIBUTE_...).
;
;                                 If $iFlags does not include the $SHGFI_USEFILEATTRIBUTES flag, this parameter is ignored. Default is 0x80
;                                 ($FILE_ATTRIBUTE_NORMAL).
;
; Return values..: Success      - $tagSHFILEINFO structure.
;
;                                 If $iFlags contains the $SHGFI_EXETYPE flag, the @extended flag specifies the type of the executable file.
;
;                                 If $iFlags contains the $SHGFI_SYSICONINDEX flag, the @extended flag specifies the handle to the
;                                 system image list.
;
;                  Failure      - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: If this function returns an icon handle in the hIcon member of the $tagSHFILEINFO structure, you are responsible for
;                  freeing it with _WinAPI_FreeIcon() when you no longer need it.
; Related........:
; Link...........: @@MsdnLink@@ SHGetFileInfo
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_ShellGetFileInfo($sPath, $iFlags, $iAttributes = 0x80)

	Local $tSHFILEINFO = DllStructCreate($tagSHFILEINFO)
	Local $Ret = DllCall('shell32.dll', 'ptr', 'SHGetFileInfoW', 'wstr', $sPath, 'dword', $iAttributes, 'ptr', DllStructGetPtr($tSHFILEINFO), 'int', DllStructGetSize($tSHFILEINFO), 'int', $iFlags)

	If @error Then
		Return SetError(1, 0, 0)
	EndIf
	Return SetError(0, $Ret[0], $tSHFILEINFO)
EndFunc   ;==>_WinAPI_ShellGetFileInfo

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_ShellGetSpecialFolderPath
; Description....: Retrieves the path of a special folder.
; Syntax.........: _WinAPI_ShellGetSpecialFolderPath ( $CSIDL [, $fCreate] )
; Parameters.....: $CSIDL   - The CSIDL that identifies the folder of interest.
;                  $fCreate - Specifies whether the folder should be created if it does not already exist, valid values:
;                  |TRUE    - The folder is created.
;                  |FALSE   - The folder is not created. (Default)
; Return values..: Success  - The full path of a special folder.
;                  Failure  - Empty string and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ SHGetSpecialFolderPath
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_ShellGetSpecialFolderPath($CSIDL, $fCreate = 0)

	Local $tPath = DllStructCreate('wchar[1024]')
	Local $Ret = DllCall('shell32.dll', 'int', 'SHGetSpecialFolderPathW', 'hwnd', 0, 'ptr', DllStructGetPtr($tPath), 'int', $CSIDL, 'int', $fCreate)

	If (@error) Or ($Ret[0] = 0) Then
		Return SetError(1, 0, '')
	EndIf
	Return DllStructGetData($tPath, 1)
EndFunc   ;==>_WinAPI_ShellGetSpecialFolderPath

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_ShellNotifyIcon
; Description....: Sends a message to the taskbar's status area.
; Syntax.........: _WinAPI_ShellNotifyIcon ( $iMessage, $tNOTIFYICONDATA )
; Parameters.....: $iMessage        - The variable that specifies the action to be taken. It can have one of the following values.
;
;                                     $NIM_ADD
;                                     $NIM_MODIFY
;                                     $NIM_DELETE
;                                     $NIM_SETFOCUS
;                                     $NIM_SETVERSION
;
;                  $tNOTIFYICONDATA - $tagNOTIFYICONDATA structure. The content and size of this structure depends on the value
;                                     of the $iMessage and version of the operating system.
; Return values..: Success          - 1.
;                  Failure          - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ Shell_NotifyIcon
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_ShellNotifyIcon($iMessage, $tNOTIFYICONDATA)

	Local $Ret = DllCall('shell32.dll', 'int', 'Shell_NotifyIconW', 'dword', $iMessage, 'ptr', DllStructGetPtr($tNOTIFYICONDATA))

	If (@error) Or ($Ret[0] = 0) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_ShellNotifyIcon

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_ShowLastError
; Description....: Shows the last error code and message.
; Syntax.........: _WinAPI_ShowLastError ( )
; Parameters.....: None
; Return values..: None
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: None
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_ShowLastError()

	Local $Error = _WinAPI_GetLastError()

	MsgBox(0, _WinAPI_GetLastError(), _WinAPI_GetLastErrorMessage())
	_WinAPI_SetLastError($Error)
EndFunc   ;==>_WinAPI_ShowLastError

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_ShowOwnedPopups
; Description....: Shows or hides all pop-up windows owned by the specified window.
; Syntax.........: _WinAPI_ShowOwnedPopups ( $hWnd , $fShow )
; Parameters.....: $hWnd   - Handle to the window that owns the pop-up windows to be shown or hidden.
;                  $fShow  - Specifies whether pop-up windows are to be shown or hidden.
;                  |TRUE   - All hidden pop-up windows are shown.
;                  |FALSE  - All visible pop-up windows are hidden.
; Return values..: Success - 1.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: This function shows only windows hidden by a previous call to _WinAPI_ShowOwnedPopups().
; Related........:
; Link...........: @@MsdnLink@@ ShowOwnedPopups
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_ShowOwnedPopups($hWnd, $fShow)

	Local $Ret = DllCall('user32.dll', 'int', 'ShowOwnedPopups', 'hwnd', $hWnd, 'int', $fShow)

	If (@error) Or ($Ret[0] = 0) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_ShowOwnedPopups

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_SizeofResource
; Description....: Returns the size, in bytes, of the specified resource.
; Syntax.........: _WinAPI_SizeofResource ( $hInstance, $hInfo )
; Parameters.....: $hInstance - Handle to the module whose executable file contains the resource.
;                  $hInfo     - Handle to the resource. This handle must be created by using the _WinAPI_FindResource() or _WinAPI_FindResourceEx()
;                               function.
; Return values..: Success    - The number of bytes in the resource.
;                  Failure    - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ SizeofResource
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_SizeofResource($hInstance, $hInfo)

	Local $Ret = DllCall('kernel32.dll', 'dword', 'SizeofResource', 'long', $hInstance, 'long', $hInfo)

	If (@error) Or ($Ret[0] = 0) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_SizeofResource

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_StretchBlt
; Description....: Copies a bitmap from a source rectangle into a destination rectangle, stretching or compressing the bitmap
;                  to fit the dimensions of the destination rectangle, if necessary.
; Syntax.........: _WinAPI_StretchBlt ( $hDestDC, $iXDest, $iYDest, $iWidthDest, $iHeightDest, $hSrcDC, $iXSrc, $iYSrc, $iWidthSrc, $iHeightSrc, $iRop )
; Parameters.....: $hDestDC     - Handle to the destination device context.
;                  $iXDest      - The x-coordinate, in logical units, of the upper-left corner of the destination rectangle.
;                  $iYDest      - The y-coordinate, in logical units, of the upper-left corner of the destination rectangle.
;                  $iWidthDest  - The width, in logical units, of the destination rectangle.
;                  $iHeightDest - The height, in logical units, of the destination rectangle.
;                  $hSrcDC      - Handle to the source device context.
;                  $iXSrc       - The x-coordinate, in logical units, of the upper-left corner of the source rectangle.
;                  $iYSrc       - The y-coordinate, in logical units, of the upper-left corner of the source rectangle.
;                  $iWidthSrc   - The width, in logical units, of the source rectangle.
;                  $iHeightSrc  - The height, in logical units, of the source rectangle.
;                  $iRop        - The raster-operation code. These codes define how the color data for the source rectangle is
;                                 to be combined with the color data for the destination rectangle to achieve the final color.
;                                 This parameter must be 0 or one of the following values.
;
;                                 $BLACKNESS
;                                 $CAPTUREBLT
;                                 $DSTINVERT
;                                 $MERGECOPY
;                                 $MERGEPAINT
;                                 $NOMIRRORBITMAP
;                                 $NOTSRCCOPY
;                                 $NOTSRCERASE
;                                 $PATCOPY
;                                 $PATINVERT
;                                 $PATPAINT
;                                 $SRCAND
;                                 $SRCCOPY
;                                 $SRCERASE
;                                 $SRCINVERT
;                                 $SRCPAINT
;                                 $WHITENESS
;
; Return values..: Success      - 1.
;                  Failure      - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: The system stretches or compresses the bitmap according to the stretching mode currently set in the
;                  destination device context.
; Related........:
; Link...........: @@MsdnLink@@ StretchBlt
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_StretchBlt($hDestDC, $iXDest, $iYDest, $iWidthDest, $iHeightDest, $hSrcDC, $iXSrc, $iYSrc, $iWidthSrc, $iHeightSrc, $iRop)

	Local $Ret  = DllCall('gdi32.dll', 'int', 'StretchBlt', 'hwnd', $hDestDC, 'int', $iXDest, 'int', $iYDest, 'int', $iWidthDest, 'int', $iHeightDest, 'hwnd', $hSrcDC, 'int', $iXSrc, 'int', $iYSrc, 'int', $iWidthSrc, 'int', $iHeightSrc, 'dword', $iRop)

	If (@error) Or ($Ret[0] = 0) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_StretchBlt

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_StructToArray
; Description....: Converts the structure to the array of strings.
; Syntax.........: _WinAPI_StructToArray ( $aData [, $fCount] )
; Parameters.....: $aData  - The structure to convert.
;                  $fCount - Specifies whether the first element contained the number of strings, valid values:
;                  |TRUE   - The count in the first element is returned.
;                  |FALSE  - The count is not returned. Use the UBound() to obtain this value. (Default)
; Return values..: Success - The array of strings.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: This function works for Unicode strings only.
; Related........:
; Link...........: None
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_StructToArray($tData, $fCount = 0)

	If Not IsDllStruct($tData) Then
		Return SetError(1, 0, 0)
	EndIf

	Local $Lenght = BitShift(DllStructGetSize($tData), 1)
	Local $tDup = DllStructCreate('wchar['& $Lenght &']', DllStructGetPtr($tData))
	Local $n = 0

	For $i = 1 To $Lenght
		If AscW(DllStructGetData($tDup, 1, $i)) = 0 Then
			DllStructSetData($tDup, 1, '|', $i)
			$n = $n + 1
			If $n > 1 Then
				ExitLoop
			EndIf
		Else
			$n = 0
		EndIf
	Next
	Return StringSplit(StringTrimRight(DllStructGetData($tDup, 1), $n), '|', 2 * ($fCount = 0))
EndFunc   ;==>_WinAPI_StructToArray

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_SubtractRect
; Description....: Determines the coordinates of a rectangle formed by subtracting one rectangle from another.
; Syntax.........: _WinAPI_SubtractRect ( $tRECT1, $tRECT2 )
; Parameters.....: $tRECT1 - $tagRECT structure from which the function subtracts the rectangle specified by $tRECT2.
;                  $tRECT2 - $tagRECT structure that the function subtracts from the rectangle specified by $tRECT1.
; Return values..: Success - $tagRECT structure that contains the rectangle determined by subtracting the rectangle specified
;                            by $tRECT2 from the rectangle specified by $tRECT1.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: The function only subtracts the rectangle specified by $tRECT2 from the rectangle specified by $tRECT1 when the
;                  rectangles intersect completely in either the x- or y-direction. For example, if $tRECT1 has the coordinates
;                  (10, 10, 100, 100) and $tRECT2 has the coordinates (50, 50, 150, 150), the function returns the rectangle with
;                  the coordinates (10, 10, 100, 100). If $tRECT1 has the coordinates (10, 10, 100, 100) and $tRECT2 has the
;                  coordinates (50, 10, 150, 150), however, the function returns the rectangle with the coordinates (10, 10, 50, 100).
;                  In other words, the resulting rectangle is the bounding box of the geometric difference.
; Related........:
; Link...........: @@MsdnLink@@ SubtractRect
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_SubtractRect($tRECT1, $tRECT2)

	Local $tRECT = DllStructCreate($tagRECT)
	Local $Ret = DllCall('user32.dll', 'int', 'SubtractRect', 'ptr', DllStructGetPtr($tRECT), 'ptr', DllStructGetPtr($tRECT1), 'ptr', DllStructGetPtr($tRECT2))

	If (@error) Or ($Ret[0] = 0) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $tRECT
EndFunc   ;==>_WinAPI_SubtractRect

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_SwitchColor
; Description....: Converts a color from BGR to RGB and back.
; Syntax.........: _WinAPI_SwitchColor ( $iColor )
; Parameters.....: $iColor - The color to conversion.
; Return values..: Converted color (RGB or BGR - depends on the $iColor value, BGR > RGB > BGR etc).
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: None
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_SwitchColor($iColor)
	Return BitOR(BitAND($iColor, 0x00FF00), BitShift(BitAND($iColor, 0x0000FF), -16), BitShift(BitAND($iColor, 0xFF0000), 16))
EndFunc   ;==>_WinAPI_SwitchColor

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_SwitchToThisWindow
; Description....: Switches the focus to a specified window and bring it to the foreground.
; Syntax.........: _WinAPI_SwitchToThisWindow ( $hWnd [, $fAltTab] )
; Parameters.....: $hWnd    - Handle to the window being switched to.
;                  $fAltTab - Specifies whether switches to using the Alt/Ctl+Tab key sequence, valid values:
;                  |TRUE    - The window is being switched to using the Alt/Ctl+Tab key sequence.
;                  |FALSE   - Otherwise. (Default)
; Return values..: Success  - 1.
;                  Failure  - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ SwitchToThisWindow
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_SwitchToThisWindow($hWnd, $fAltTab = 0)
	DllCall('user32.dll', 'none', 'SwitchToThisWindow', 'hwnd', $hWnd, 'int', $fAltTab)
	If @error Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_SwitchToThisWindow

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_TextOut
; Description....: 
; Syntax.........: _WinAPI_TextOut ( $hDC, $iX, $iY, $sText )
; Parameters.....: $hDC    - Handle to the device context.
;                  $iX     - The x-coordinate, in logical coordinates, of the reference point that the system uses to align the string.
;                  $iY     - The y-coordinate, in logical coordinates, of the reference point that the system uses to align the string.
;                  $sText  - The string to be drawn.
; Return values..: Success - 1.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: This function using the currently selected font, background color, and text color.
; Related........:
; Link...........: @@MsdnLink@@ TextOut
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_TextOut($hDC, $iX, $iY, $sText)

	Local $Ret = DllCall('gdi32.dll', 'int', 'TextOutW', 'hwnd', $hDC, 'int', $iX, 'int', $iY, 'wstr', $sText, 'int', StringLen($sText))

	If (@error) Or ($Ret[0] = 0) Then
		MsgBox(0, '', @error)
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_TextOut

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_TransparentBlt
; Description....: Performs a bit-block transfer of the color data corresponding to a rectangle of pixels.
; Syntax.........: _WinAPI_TransparentBlt ( $hDestDC, $iXDest, $iYDest, $iWidthDest, $iHeightDest, $hSrcDC, $iXSrc, $iYSrc, $iWidthSrc, $iHeightSrc, $iRGB )
; Parameters.....: $hDestDC     - Handle to the destination device context.
;                  $iXDest      - The x-coordinate, in logical units, of the upper-left corner of the destination rectangle.
;                  $iYDest      - The y-coordinate, in logical units, of the upper-left corner of the destination rectangle.
;                  $iWidthDest  - The width, in logical units, of the destination rectangle.
;                  $iHeightDest - The height, in logical units, of the destination rectangle.
;                  $hSrcDC      - Handle to the source device context.
;                  $iXSrc       - The x-coordinate, in logical units, of the upper-left corner of the source rectangle.
;                  $iYSrc       - The y-coordinate, in logical units, of the upper-left corner of the source rectangle.
;                  $iWidthSrc   - The width, in logical units, of the source rectangle.
;                  $iHeightSrc  - The height, in logical units, of the source rectangle.
;                  $iRGB        - The RGB color in the source bitmap to treat as transparent.
; Return values..: Success      - 1.
;                  Failure      - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: If the source and destination rectangles are not the same size, the source bitmap is stretched to match the
;                  destination rectangle. When the _WinAPI_SetStretchBltMode() function is used, the stretching modes of
;                  $BLACKONWHITE and $WHITEONBLACK are converted to $COLORONCOLOR for the _WinAPI_TransparentBlt() function.
;
;                  This function supports all formats of source bitmaps. However, for 32 bpp bitmaps, it just copies the alpha
;                  value over. Use _WinAPI_AlphaBlend() to specify 32 bits-per-pixel bitmaps with transparency.
; Related........:
; Link...........: @@MsdnLink@@ GdiTransparentBlt
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_TransparentBlt($hDestDC, $iXDest, $iYDest, $iWidthDest, $iHeightDest, $hSrcDC, $iXSrc, $iYSrc, $iWidthSrc, $iHeightSrc, $iRGB)

	Local $Ret  = DllCall('gdi32.dll', 'int', 'GdiTransparentBlt', 'hwnd', $hDestDC, 'int', $iXDest, 'int', $iYDest, 'int', $iWidthDest, 'uint', $iHeightDest, 'hwnd', $hSrcDC, 'int', $iXSrc, 'int', $iYSrc, 'int', $iWidthSrc, 'int', $iHeightSrc, 'dword', __CheckColor($iRGB))

	If (@error) Or ($Ret[0] = 0) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_TransparentBlt

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_UnionRect
; Description....: Creates the union of two rectangles.
; Syntax.........: _WinAPI_UnionRect ( $tRECT1, $tRECT2 )
; Parameters.....: $tRECT1 - $tagRECT structure that contains the first source rectangle.
;                  $tRECT2 - $tagRECT structure that contains the second source rectangle.
; Return values..: Success - $tagRECT structure that contains the union of the $tRECT1 and $tRECT2 rectangles.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: The union is the smallest rectangle that contains both source rectangles. The system ignores the
;                  dimensions of an empty rectangle that is, a rectangle in which all coordinates are set to zero, so that
;                  it has no height or no width.
; Related........:
; Link...........: @@MsdnLink@@ UnionRect
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_UnionRect($tRECT1, $tRECT2)

	Local $tRECT = DllStructCreate($tagRECT)
	Local $Ret = DllCall('user32.dll', 'int', 'UnionRect', 'ptr', DllStructGetPtr($tRECT), 'ptr', DllStructGetPtr($tRECT1), 'ptr', DllStructGetPtr($tRECT2))

	If (@error) Or ($Ret[0] = 0) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $tRECT
EndFunc   ;==>_WinAPI_UnionRect

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_ValidateRect
; Description....: Removes a rectangle from the current update region of the specified window.
; Syntax.........: _WinAPI_ValidateRect ( $hWnd [, $tRECT] )
; Parameters.....: $hWnd   - Handle to the window whose update region is to be modified. If this parameter is 0, the system
;                            invalidates and redraws all windows and sends the WM_ERASEBKGND and WM_NCPAINT messages to the window
;                            procedure before the function returns.
;                  $tRECT  - $tagRECT structure that contains the client coordinates of the rectangle to be removed from the
;                            update region. If this parameter is 0, the entire client area is removed.
; Return values..: Success - 1.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ ValidateRect
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_ValidateRect($hWnd, $tRECT = 0)

	Local $Ret = DllCall('user32.dll', 'int', 'ValidateRect', 'hwnd', $hWnd, 'ptr', DllStructGetPtr($tRECT))

	If (@error) Or ($Ret[0] = 0) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_ValidateRect

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_ValidateRgn
; Description....: Removes a region from the current update region of the specified window.
; Syntax.........: _WinAPI_ValidateRect ( $hWnd [, $hRgn] )
; Parameters.....: $hWnd   - Handle to the window whose update region is to be modified.
;                  $hRgn   - Handle to a region that defines the area to be removed from the update region. If this parameter is 0,
;                            the entire client area is removed.
; Return values..: Success - 1.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ ValidateRgn
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_ValidateRgn($hWnd, $hRgn = 0)

	Local $Ret = DllCall('user32.dll', 'int', 'ValidateRgn', 'hwnd', $hWnd, 'ptr', $hRgn)

	If (@error) Or ($Ret[0] = 0) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_ValidateRgn

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_WindowFromDC
; Description....: Retrieves a handle to the window associated with the specified display device context (DC).
; Syntax.........: _WinAPI_WindowFromDC ( $hDC )
; Parameters.....: $hDC    - Handle to the device context from which a handle to the associated window is to be retrieved.
; Return values..: Success - Handle to the window associated with the specified DC. If no window is associated with the specified
;                            DC, the return value is 0.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ WindowFromDC
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_WindowFromDC($hDC)

	Local $Ret = DllCall('user32.dll', 'hwnd', 'WindowFromDC', 'hwnd', $hDC)

	If @error Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_WindowFromDC

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_WinHelp
; Description....: Launches Microsoft Windows Help and passes additional data that indicates the nature of the help.
; Syntax.........: _WinAPI_WinHelp ( $hWnd, $iCommand [, $sPath [, $iData]] )
; Parameters.....: $hWnd     - Handle to the window requesting help. This function uses this handle to keep track of which
;                              applications have requested help. If the $iCommand parameter specifies $HELP_CONTEXTMENU or
;                              $HELP_WM_HELP, $hWnd identifies the control requesting help.
;                  $iCommand - The type of help requested. This parameter can be one of the following values.
;
;                              $HELP_COMMAND
;                              $HELP_CONTENTS
;                              $HELP_CONTEXT
;                              $HELP_CONTEXTMENU
;                              $HELP_CONTEXTPOPUP
;                              $HELP_FINDER
;                              $HELP_FORCEFILE
;                              $HELP_HELPONHELP
;                              $HELP_INDEX
;                              $HELP_KEY
;                              $HELP_MULTIKEY
;                              $HELP_PARTIALKEY
;                              $HELP_QUIT
;                              $HELP_SETCONTENTS
;                              $HELP_SETPOPUP_POS
;                              $HELP_SETWINPOS
;                              $HELP_TCARD (Can be combined with other values)
;                              $HELP_WM_HELP
;
;                  $sPath    - The path, if necessary, and the name of the Help file to display.
;                  $iData    - Additional data. The value used depends on the value of the $iCommand parameter.
;
;                              $HELP_COMMAND
;                              String that specifies the name of the Help macro(s) to run. If the string specifies multiple macro
;                              names, the names must be separated by semicolons. You must use the short form of the macro name
;                              for some macros because Windows Help does not support the long name.
;
;                              $HELP_CONTENTS
;                              Ignored; set to 0.
;
;                              $HELP_CONTEXT
;                              Contains the context identifier for the topic.
;
;                              $HELP_CONTEXTMENU
;                              Structure of a double word pairs ("dword[2], ..."). The first double word in each pair is the control
;                              identifier, and the second is the context identifier for the topic. The array must be terminated by
;                              a pair of zeros {0,0}. If you do not want to add Help to a particular control, set its context
;                              identifier to (-1).
;
;                              $HELP_CONTEXTPOPUP
;                              Contains the context identifier for a topic.
;
;                              $HELP_FINDER
;                              Ignored; set to 0.
;
;                              $HELP_FORCEFILE
;                              Ignored; set to 0.
;
;                              $HELP_HELPONHELP
;                              Ignored; set to 0.
;
;                              $HELP_INDEX
;                              Ignored; set to 0.
;
;                              $HELP_KEY
;                              Ther keyword string. Multiple keywords must be separated by semicolons.
;
;                              $HELP_MULTIKEY
;                              The MULTIKEYHELP structure that specifies a table footnote character and a keyword.
;
;                              $HELP_PARTIALKEY
;                              The keyword string. Multiple keywords must be separated by semicolons.
;
;                              $HELP_QUIT
;                              Ignored; set to 0.
;
;                              $HELP_SETCONTENTS
;                              Contains the context identifier for the Contents topic.
;
;                              $HELP_SETPOPUP_POS
;                              Contains the position data. The pop-up window is positioned as if the mouse cursor were at
;                              the specified point when the pop-up window was invoked.
;
;                              $HELP_SETWINPOS
;                              The HELPWININFO structure that specifies the size and position of either a primary or
;                              secondary Help window.
;
;                              $HELP_TCARD
;                              Depends on the command with which this command is combined.
;
;                              $HELP_WM_HELP
;                              Structure of a double word pairs ("dword[2], ..."). The first double word in each pair is the control
;                              identifier, and the second is the context identifier for the topic. The array must be terminated by
;                              a pair of zeros {0,0}. If you do not want to add Help to a particular control, set its context
;                              identifier to (-1).
;
; Return values..: Success   - 1.
;                  Failure   - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: Before closing the window that requested help, the application must call WinHelp with the $iCommand parameter set to
;                  $HELP_QUIT. Until all applications have done this, Windows Help will not terminate. Note that calling Windows Help
;                  with the $HELP_QUIT command is not necessary if you used the $HELP_CONTEXTPOPUP command to start Windows Help.
; Related........:
; Link...........: @@MsdnLink@@ WinHelp
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_WinHelp($hWnd, $iCommand, $sPath = '', $iData = 0)

	Local $lData, $tData

	Select
		Case BitAND($iCommand, 0x0107)
			; $HELP_COMMAND, $HELP_KEY, $HELP_PARTIALKEY
			$tData = DllStructCreate('wchar[1024]')
			DllStructSetData($tData, 1, $iData)
			$lData = DllStructGetPtr($tData)
		Case BitAND($iCommand, 0x020F)
			; $HELP_CONTEXTMENU, $HELP_MULTIKEY, $HELP_SETWINPOS, $HELP_WM_HELP
			$lData = DllStructGetPtr($iData)
		Case BitAND($iCommand, 0x000F)
			; $HELP_CONTENTS, $HELP_FINDER, $HELP_FORCEFILE, $HELP_HELPONHELP, $HELP_INDEX, $HELP_QUIT
			$lData = 0
		Case Else
			$lData = $iData
	EndSelect

	Local $Ret = DllCall('user32.dll', 'int', 'WinHelpW', 'hwnd', $hWnd, 'wstr', $sPath, 'uint', $iCommand, 'lparam', $lData)

	If (@error) Or ($Ret[0] = 0) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_WinHelp

#EndRegion Public Functions

#Region Internal Functions

Func __CheckColor($iColor)
	If $__RGB Then
		$iColor = _WinAPI_SwitchColor($iColor)
	EndIf
	Return $iColor
EndFunc   ;==>__CheckColor

Func __EnumWindowsProc($hWnd, $fVisible)
	If ($fVisible) And (Not _WinAPI_IsWindowVisible($hWnd)) Then
		Return 1
	EndIf
	$__Data[0][0] += 1
	If $__Data[0][0] > UBound($__Data) - 1 Then
		ReDim $__Data[$__Data[0][0] + 100][2]
	EndIf
	$__Data[$__Data[0][0]][0] = $hWnd
	$__Data[$__Data[0][0]][1] = _WinAPI_GetClassName($hWnd)
	Return 1
EndFunc   ;==>__EnumWindowsProc

Func __EnumResLanguagesProc($hModule, $iType, $iName, $iLanguage, $lParam)
	$__Data[0] += 1
	If $__Data[0] > UBound($__Data) - 1 Then
		ReDim $__Data[$__Data[0] + 100]
	EndIf
	$__Data[$__Data[0]] = $iLanguage
	Return 1
EndFunc   ;==>__EnumResLanguagesProc

Func __EnumResNamesProc($hModule, $iType, $iName, $lParam)

	Local $Ret, $sName, $tName

	$Ret = DllCall('kernel32.dll', 'int', 'GlobalSize', 'ptr', $iName)
	If (@error) Or ($Ret[0] = 0) Then
		$sName = $iName
	Else
		$tName = DllStructCreate('char[' & $Ret[0] & ']', $iName)
		$sName = DllStructGetData($tName, 1)
	EndIf
	$__Data[0] += 1
	If $__Data[0] > UBound($__Data) - 1 Then
		ReDim $__Data[$__Data[0] + 100]
	EndIf
	$__Data[$__Data[0]] = $sName
	Return 1
EndFunc   ;==>__EnumResNamesProc

Func __EnumResTypesProc($hModule, $iType, $lParam)

	Local $Ret, $sType, $tType

	$Ret = DllCall('kernel32.dll', 'int', 'GlobalSize', 'ptr', $iType)
	If (@error) Or ($Ret[0] = 0) Then
		$sType = $iType
	Else
		$tType = DllStructCreate('char[' & $Ret[0] & ']', $iType)
		$sType = DllStructGetData($tType, 1)
	EndIf
	$__Data[0] += 1
	If $__Data[0] > UBound($__Data) - 1 Then
		ReDim $__Data[$__Data[0] + 100]
	EndIf
	$__Data[$__Data[0]] = $sType
	Return 1
EndFunc   ;==>__EnumResTypesProc

#EndRegion Internal Functions
