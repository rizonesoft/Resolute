#Region Header

#cs

    Title:          WinAPI Extended UDF Library for AutoIt3
    Filename:       WinAPIEx.au3
    Description:    Additional variables, constants and functions for the WinAPI.au3
    Author:         Yashied
    Version:        3.1 / 3.3.6.1
    Requirements:   AutoIt v3.3 +, Developed/Tested on Windows XP Pro Service Pack 2 and Windows Vista/7
    Uses:           APIConstants.au3, WinAPI.au3
    Note:           The library uses the following system DLLs:

                    advapi32.dll
                    comctl32.dll
                    connect.dll
                    dwmapi.dll
                    gdi32.dll
                    kernel32.dll
                    ntdll.dll
                    ole32.dll
                    psapi.dll
                    sensapi.dll
                    shell32.dll
                    shlwapi.dll
                    user32.dll
                    uxtheme.dll
                    version.dll
                    winmm.dll
                    winspool.drv

    Available functions:

    _WinAPI_ActivateKeyboardLayout
    _WinAPI_AbortPath
    _WinAPI_AboutDlg
    _WinAPI_AddFontMemResourceEx
    _WinAPI_AddFontResourceEx
    _WinAPI_AddMRUString
    _WinAPI_AdjustTokenPrivileges
    _WinAPI_AdjustWindowRectEx
    _WinAPI_AlphaBlend
    _WinAPI_AngleArc
    _WinAPI_AnimateWindow
    _WinAPI_Arc
    _WinAPI_ArcTo
    _WinAPI_ArrayToStruct
    _WinAPI_AssignProcessToJobObject
    _WinAPI_AssocGetPerceivedType
    _WinAPI_AssocQueryString
    _WinAPI_BeginDeferWindowPos
    _WinAPI_BeginPaint
    _WinAPI_BeginPath
    _WinAPI_BeginUpdateResource
    _WinAPI_BringWindowToTop
    _WinAPI_BroadcastSystemMessage
    _WinAPI_BrowseForFolderDlg
    _WinAPI_CalculatePopupWindowPosition
    _WinAPI_CharToOem
    _WinAPI_ChildWindowFromPointEx
    _WinAPI_ClipCursor
    _WinAPI_CloseEnhMetaFile
    _WinAPI_CloseFigure
    _WinAPI_CloseThemeData
    _WinAPI_CloseWindow
    _WinAPI_CoInitialize
    _WinAPI_ColorHLSToRGB
    _WinAPI_ColorRGBToHLS
    _WinAPI_CommandLineToArgv
    _WinAPI_CopyBitmap
    _WinAPI_CopyCursor
    _WinAPI_CopyEnhMetaFile
    _WinAPI_CopyFileEx
    _WinAPI_CopyImage
    _WinAPI_CopyRect
    _WinAPI_CopyStruct
    _WinAPI_CoTaskMemAlloc
    _WinAPI_CoTaskMemFree
    _WinAPI_CoTaskMemRealloc
    _WinAPI_CoUninitialize
    _WinAPI_CreateBrushIndirect
    _WinAPI_CreateCaret
    _WinAPI_CreateCompatibleBitmapEx
    _WinAPI_CreateDIBSection
    _WinAPI_CreateEllipticRgn
    _WinAPI_CreateEnhMetaFile
    _WinAPI_CreateFileEx
    _WinAPI_CreateFileMapping
    _WinAPI_CreateGUID
    _WinAPI_CreateIcon
    _WinAPI_CreateIconFromResourceEx
    _WinAPI_CreateIconIndirect
    _WinAPI_CreateJobObject
    _WinAPI_CreateMRUList
    _WinAPI_CreateMutex
    _WinAPI_CreatePolygonRgn
    _WinAPI_CreateRect
    _WinAPI_CreateRectEx
    _WinAPI_CreateRectRgnIndirect
    _WinAPI_CreateSemaphore
    _WinAPI_CreateStreamOnHGlobal
    _WinAPI_DeferWindowPos
    _WinAPI_DefineDosDevice
    _WinAPI_DeleteEnhMetaFile
    _WinAPI_DeleteFile
    _WinAPI_DeleteVolumeMountPoint
    _WinAPI_DeregisterShellHookWindow
    _WinAPI_DestroyCaret
    _WinAPI_DestroyCursor
    _WinAPI_DeviceIoControl
    _WinAPI_DllGetVersion
    _WinAPI_DllInstall
    _WinAPI_DllUninstall
    _WinAPI_DragAcceptFiles
    _WinAPI_DragFinish
    _WinAPI_DragQueryFileEx
    _WinAPI_DragQueryPoint
    _WinAPI_DrawAnimatedRects
    _WinAPI_DrawBitmap
    _WinAPI_DrawShadowText
    _WinAPI_DrawThemeBackground
    _WinAPI_DrawThemeParentBackground
    _WinAPI_DrawThemeText
    _WinAPI_DrawThemeTextEx
    _WinAPI_DuplicateHandle
    _WinAPI_DwmEnableBlurBehindWindow
    _WinAPI_DwmEnableComposition
    _WinAPI_DwmGetColorizationColor
    _WinAPI_DwmGetWindowAttribute
    _WinAPI_DwmExtendFrameIntoClientArea
    _WinAPI_DwmIsCompositionEnabled
    _WinAPI_DwmQueryThumbnailSourceSize
    _WinAPI_DwmRegisterThumbnail
    _WinAPI_DwmSetWindowAttribute
    _WinAPI_DwmUnregisterThumbnail
    _WinAPI_DwmUpdateThumbnailProperties
    _WinAPI_DWordToInt
    _WinAPI_EjectMedia
    _WinAPI_Ellipse
    _WinAPI_EmptyWorkingSet
    _WinAPI_EndDeferWindowPos
    _WinAPI_EndPaint
    _WinAPI_EndPath
    _WinAPI_EndUpdateResource
    _WinAPI_EnumChildProcess
    _WinAPI_EnumChildWindows
    _WinAPI_EnumDeviceDrivers
    _WinAPI_EnumDisplaySettings
    _WinAPI_EnumMRUList
    _WinAPI_EnumProcessThreads
    _WinAPI_EnumProcessWindows
    _WinAPI_EnumResourceLanguages
    _WinAPI_EnumResourceNames
    _WinAPI_EnumResourceTypes
    _WinAPI_EnumSystemLocales
    _WinAPI_EqualRect
    _WinAPI_EqualRgn
    _WinAPI_EqualStruct
    _WinAPI_ExcludeClipRect
    _WinAPI_ExtCreateRegion
    _WinAPI_ExtFloodFill
    _WinAPI_ExtSelectClipRgn
    _WinAPI_FatalExit
    _WinAPI_FillPath
   *_WinAPI_FillRect
    _WinAPI_FillRgn
    _WinAPI_FillStruct
    _WinAPI_FindResource
    _WinAPI_FindResourceEx
    _WinAPI_FlattenPath
    _WinAPI_FlushViewOfFile
    _WinAPI_FormatDriveDlg
   *_WinAPI_FrameRect
    _WinAPI_FrameRgn
    _WinAPI_FreeMRUList
    _WinAPI_FreeResource
    _WinAPI_GetActiveWindow
    _WinAPI_GetArcDirection
   *_WinAPI_GetAsyncKeyState
    _WinAPI_GetBinaryType
    _WinAPI_GetBitmapDimension
    _WinAPI_GetBkColor
    _WinAPI_GetBValue
    _WinAPI_GetCaretBlinkTime
    _WinAPI_GetCaretPos
    _WinAPI_GetCDType
    _WinAPI_GetClassInfoEx
    _WinAPI_GetClassLongEx
    _WinAPI_GetClipBox
    _WinAPI_GetClipRgn
    _WinAPI_GetClipCursor
    _WinAPI_GetCompression
    _WinAPI_GetConnectedDlg
    _WinAPI_GetCurrentDirectory
    _WinAPI_GetCurrentHwProfile
    _WinAPI_GetCurrentThemeName
    _WinAPI_GetCursor
    _WinAPI_GetDateFormat
    _WinAPI_GetDCEx
    _WinAPI_GetDefaultPrinter
    _WinAPI_GetDeviceDriverBaseName
    _WinAPI_GetDeviceDriverFileName
    _WinAPI_GetDiskFreeSpaceEx
    _WinAPI_GetDriveBusType
    _WinAPI_GetDriveGeometryEx
    _WinAPI_GetDriveNumber
    _WinAPI_GetDriveType
    _WinAPI_GetErrorMessage
    _WinAPI_GetErrorMode
    _WinAPI_GetFileAttributes
    _WinAPI_GetFileVersionInfo
    _WinAPI_GetFontResourceInfo
   *_WinAPI_GetForegroundWindow
    _WinAPI_GetEnhMetaFile
    _WinAPI_GetEnhMetaFileBits
    _WinAPI_GetEnhMetaFileDescription
    _WinAPI_GetEnhMetaFileDimension
    _WinAPI_GetEnhMetaFileHeader
    _WinAPI_GetFileSizeOnDisk
    _WinAPI_GetFileTitle
    _WinAPI_GetGValue
    _WinAPI_GetHandleInformation
    _WinAPI_GetHGlobalFromStream
    _WinAPI_GetIconDimension
    _WinAPI_GetIdleTime
    _WinAPI_GetKeyboardLayout
    _WinAPI_GetKeyboardLayoutList
    _WinAPI_GetKeyboardState
    _WinAPI_GetKeyboardType
    _WinAPI_GetKeyNameText
    _WinAPI_GetKeyState
   *_WinAPI_GetLayeredWindowAttributes
    _WinAPI_GetLocaleInfo
    _WinAPI_GetLogicalDrives
    _WinAPI_GetModuleFileName
    _WinAPI_GetModuleHandleEx
    _WinAPI_GetObjectEx
    _WinAPI_GetObjectType
    _WinAPI_GetOutlineTextMetrics
    _WinAPI_GetParentProcess
    _WinAPI_GetPerformanceInfo
    _WinAPI_GetPixel
    _WinAPI_GetPolyFillMode
    _WinAPI_GetPosFromRect
    _WinAPI_GetProcAddress
    _WinAPI_GetProcessCommandLine
    _WinAPI_GetProcessFileName
    _WinAPI_GetProcessHandleCount
    _WinAPI_GetProcessIoCounters
    _WinAPI_GetProcessMemoryInfo
    _WinAPI_GetProcessName
    _WinAPI_GetProcessTimes
    _WinAPI_GetRegionData
    _WinAPI_GetRgnBox
    _WinAPI_GetROP2
    _WinAPI_GetRValue
    _WinAPI_GetSystemDefaultLCID
    _WinAPI_GetSystemInfo
    _WinAPI_GetSystemPowerStatus
    _WinAPI_GetSystemTimes
    _WinAPI_GetSystemWow64Directory
    _WinAPI_GetTempFileName
    _WinAPI_GetTextAlign
    _WinAPI_GetTextColor
    _WinAPI_GetTextFace
    _WinAPI_GetTextMetrics
    _WinAPI_GetThemeAppProperties
    _WinAPI_GetThemeColor
    _WinAPI_GetThemeDocumentationProperty
    _WinAPI_GetThemeFont
    _WinAPI_GetThemeInt
    _WinAPI_GetThemeMargins
    _WinAPI_GetThemePartSize
    _WinAPI_GetThemePosition
    _WinAPI_GetThemeRect
    _WinAPI_GetTickCount
    _WinAPI_GetTickCount64
    _WinAPI_GetTimeFormat
    _WinAPI_GetTopWindow
    _WinAPI_GetUDFColorMode
    _WinAPI_GetUDFVersion
    _WinAPI_GetUpdateRect
    _WinAPI_GetUpdateRgn
    _WinAPI_GetUserDefaultLCID
    _WinAPI_GetVersion
    _WinAPI_GetVersionEx
    _WinAPI_GetVolumeNameForVolumeMountPoint
    _WinAPI_GetWindowFileName
    _WinAPI_GetWindowInfo
    _WinAPI_GetWindowLongEx
    _WinAPI_GetWorkArea
    _WinAPI_GradientFill
    _WinAPI_HiByte
    _WinAPI_HideCaret
    _WinAPI_HiDWord
    _WinAPI_InflateRect
    _WinAPI_IntersectClipRect
    _WinAPI_IntersectRect
    _WinAPI_IntToDWord
   *_WinAPI_InvalidateRect
    _WinAPI_InvalidateRgn
    _WinAPI_InvertRect
    _WinAPI_InvertRgn
    _WinAPI_IOCTL
    _WinAPI_IsChild
    _WinAPI_IsDoorOpen
    _WinAPI_IsHungAppWindow
    _WinAPI_IsIconic
    _WinAPI_IsInternetConnected
    _WinAPI_IsLoadKBLayout
    _WinAPI_IsNetworkAlive
    _WinAPI_IsPressed
    _WinAPI_IsProcessInJob
    _WinAPI_IsProcessorFeaturePresent
    _WinAPI_IsRectEmpty
    _WinAPI_IsThemeActive
    _WinAPI_IsThemeBackgroundPartiallyTransparent
    _WinAPI_IsThemePartDefined
    _WinAPI_IsValidLocale
    _WinAPI_IsWindowEnabled
    _WinAPI_IsWindowUnicode
    _WinAPI_IsWow64Process
    _WinAPI_IsWritable
    _WinAPI_IsZoomed
    _WinAPI_Keybd_Event
    _WinAPI_KillTimer
    _WinAPI_LineDDA
    _WinAPI_LoadCursor
    _WinAPI_LoadCursorFromFile
    _WinAPI_LoadIconWithScaleDown
    _WinAPI_LoadKeyboardLayout
    _WinAPI_LoadMedia
    _WinAPI_LoadResource
    _WinAPI_LoByte
    _WinAPI_LockDevice
    _WinAPI_LockFile
    _WinAPI_LockResource
    _WinAPI_LockWorkStation
    _WinAPI_LoDWord
    _WinAPI_LongMid
    _WinAPI_LookupIconIdFromDirectoryEx
    _WinAPI_LookupPrivilegeName
    _WinAPI_LookupPrivilegeValue
    _WinAPI_MapViewOfFile
    _WinAPI_MessageBoxCheck
    _WinAPI_MessageBoxIndirect
    _WinAPI_MoveFileEx
    _WinAPI_MoveToEx
    _WinAPI_OemToChar
    _WinAPI_OffsetPoints
    _WinAPI_OffsetClipRgn
    _WinAPI_OffsetRect
    _WinAPI_OffsetRgn
    _WinAPI_OpenFileMapping
    _WinAPI_OpenIcon
    _WinAPI_OpenJobObject
    _WinAPI_OpenMutex
    _WinAPI_OpenProcessToken
    _WinAPI_OpenSemaphore
    _WinAPI_OpenThemeData
    _WinAPI_PaintRgn
    _WinAPI_PatBlt
    _WinAPI_PathCompactPath
    _WinAPI_PathFindExtension
    _WinAPI_PathFindFileName
    _WinAPI_PathFindNextComponent
   *_WinAPI_PathFindOnPath
    _WinAPI_PathGetArgs
    _WinAPI_PathGetCharType
    _WinAPI_PathGetDriveNumber
    _WinAPI_PathIsExe
    _WinAPI_PathIsDirectory
    _WinAPI_PathIsDirectoryEmpty
    _WinAPI_PathIsFileSpec
    _WinAPI_PathIsRelative
    _WinAPI_PathIsSameRoot
    _WinAPI_PathMatchSpec
    _WinAPI_PathParseIconLocation
    _WinAPI_PathRelativePathTo
    _WinAPI_PathRemoveArgs
    _WinAPI_PathRenameExtension
    _WinAPI_PathSearchAndQualify
    _WinAPI_PathToRegion
    _WinAPI_PathUnExpandEnvStrings
    _WinAPI_PathUnquoteSpaces
    _WinAPI_PathYetAnotherMakeUniqueName
    _WinAPI_PickIconDlg
    _WinAPI_PlayEnhMetaFile
    _WinAPI_PlaySound
    _WinAPI_PolyBezier
    _WinAPI_PolyBezierTo
    _WinAPI_PolyDraw
    _WinAPI_Polygon
    _WinAPI_PrintWindow
    _WinAPI_PtInRectEx
    _WinAPI_PtInRegion
    _WinAPI_PtVisible
    _WinAPI_QueryDosDevice
    _WinAPI_QueryInformationJobObject
    _WinAPI_QueryPerformanceCounter
    _WinAPI_QueryPerformanceFrequency
    _WinAPI_RadialGradientFill
    _WinAPI_Rectangle
    _WinAPI_RectInRegion
    _WinAPI_RectVisible
    _WinAPI_RegCloseKey
    _WinAPI_RegConnectRegistry
    _WinAPI_RegCopyTree
    _WinAPI_RegCopyTreeEx
    _WinAPI_RegCreateKey
    _WinAPI_RegDeleteEmptyKey
    _WinAPI_RegDeleteKey
    _WinAPI_RegDeleteKeyValue
    _WinAPI_RegDeleteTree
    _WinAPI_RegDeleteTreeEx
    _WinAPI_RegDeleteValue
    _WinAPI_RegDuplicateHKey
    _WinAPI_RegEnumKey
    _WinAPI_RegEnumValue
    _WinAPI_RegFlushKey
    _WinAPI_RegisterClassEx
    _WinAPI_RegisterHotKey
    _WinAPI_RegisterShellHookWindow
    _WinAPI_RegLoadMUIString
    _WinAPI_RegNotifyChangeKeyValue
    _WinAPI_RegOpenKey
    _WinAPI_RegQueryInfoKey
    _WinAPI_RegQueryLastWriteTime
    _WinAPI_RegQueryMultipleValues
    _WinAPI_RegQueryValue
    _WinAPI_RegRestoreKey
    _WinAPI_RegSaveKey
    _WinAPI_RegSetValue
    _WinAPI_ReleaseMutex
    _WinAPI_ReleaseSemaphore
    _WinAPI_RemoveFontMemResourceEx
    _WinAPI_RemoveFontResourceEx
    _WinAPI_ReOpenFile
    _WinAPI_ReplaceFile
    _WinAPI_ResetEvent
    _WinAPI_ResizeBitmap
    _WinAPI_RestartDlg
    _WinAPI_RestoreDC
    _WinAPI_RGB
    _WinAPI_RotatePoints
    _WinAPI_RoundRect
    _WinAPI_SaveDC
    _WinAPI_SelectClipPath
    _WinAPI_SelectClipRgn
    _WinAPI_SendMessageTimeout
    _WinAPI_SetActiveWindow
    _WinAPI_SetArcDirection
    _WinAPI_SetClassLongEx
    _WinAPI_SetCompression
    _WinAPI_SetCaretBlinkTime
    _WinAPI_SetCaretPos
    _WinAPI_SetCurrentDirectory
    _WinAPI_SetDCBrushColor
    _WinAPI_SetDCPenColor
   *_WinAPI_SetDefaultPrinter
    _WinAPI_SetDIBitsToDevice
    _WinAPI_SetEnhMetaFileBits
    _WinAPI_SetErrorMode
    _WinAPI_SetFileAttributes
    _WinAPI_SetFilePointerEx
    _WinAPI_SetForegroundWindow
   *_WinAPI_SetHandleInformation
    _WinAPI_SetInformationJobObject
    _WinAPI_SetKeyboardLayout
    _WinAPI_SetKeyboardState
   *_WinAPI_SetLayeredWindowAttributes
    _WinAPI_SetLocaleInfo
   *_WinAPI_SetParent
    _WinAPI_SetPixel
    _WinAPI_SetPolyFillMode
    _WinAPI_SetRectRgn
    _WinAPI_SetROP2
    _WinAPI_SetStretchBltMode
    _WinAPI_SetSystemCursor
    _WinAPI_SetTextAlign
    _WinAPI_SetThemeAppProperties
    _WinAPI_SetTimer
    _WinAPI_SetUDFColorMode
    _WinAPI_SetVolumeMountPoint
    _WinAPI_SetWindowLongEx
    _WinAPI_SetWindowTheme
    _WinAPI_ShellAddToRecentDocs
    _WinAPI_ShellChangeNotify
    _WinAPI_ShellChangeNotifyDeregister
    _WinAPI_ShellChangeNotifyRegister
    _WinAPI_ShellEmptyRecycleBin
    _WinAPI_ShellExtractAssociatedIcon
    _WinAPI_ShellExtractIcon
    _WinAPI_ShellFileOperation
    _WinAPI_ShellGetFileInfo
    _WinAPI_ShellGetKnownFolderPath
    _WinAPI_ShellGetPathFromIDList
    _WinAPI_ShellGetSetFolderCustomSettings
    _WinAPI_ShellGetSettings
    _WinAPI_ShellGetSpecialFolderLocation
    _WinAPI_ShellGetSpecialFolderPath
    _WinAPI_ShellGetStockIconInfo
    _WinAPI_ShellILCreateFromPath
    _WinAPI_ShellNotifyIcon
    _WinAPI_ShellObjectProperties
    _WinAPI_ShellOpenFolderAndSelectItems
    _WinAPI_ShellOpenWithDlg
    _WinAPI_ShellQueryRecycleBin
    _WinAPI_ShellQueryUserNotificationState
    _WinAPI_ShellSetSettings
    _WinAPI_ShowCaret
    _WinAPI_ShowLastError
    _WinAPI_ShowOwnedPopups
    _WinAPI_ShutdownDlg
    _WinAPI_SizeOfResource
    _WinAPI_StretchBlt
    _WinAPI_StrLen
    _WinAPI_StrokeAndFillPath
    _WinAPI_StrokePath
    _WinAPI_StructToArray
    _WinAPI_SubtractRect
    _WinAPI_SwapDWord
    _WinAPI_SwitchColor
    _WinAPI_SwitchToThisWindow
    _WinAPI_TransparentBlt
    _WinAPI_TextOut
    _WinAPI_UnionRect
    _WinAPI_UnionStruct
    _WinAPI_UniqueHardwareID
    _WinAPI_UnloadKeyboardLayout
    _WinAPI_UnlockFile
    _WinAPI_UnmapViewOfFile
    _WinAPI_UnregisterClass
    _WinAPI_UnregisterHotKey
    _WinAPI_UpdateLayeredWindowEx
    _WinAPI_UpdateResource
    _WinAPI_ValidateRect
    _WinAPI_ValidateRgn
    _WinAPI_VerQueryRoot
    _WinAPI_VerQueryValue
    _WinAPI_WidenPath
    _WinAPI_WindowFromDC
    _WinAPI_Wow64EnableWow64FsRedirection

#ce

#Include-once

#Include <APIConstants.au3>
#Include <WinAPI.au3>

#EndRegion Header

#Region Global Variables and Constants

Global Const $tagBITMAP = 'long bmType;long bmWidth;long bmHeight;long bmWidthBytes;ushort bmPlanes;ushort bmBitsPixel;ptr bmBits;'
Global Const $tagBITMAPINFOHEADER = 'dword biSize;long biWidth;long biHeight;ushort biPlanes;ushort biBitCount;dword biCompression;dword biSizeImage;long biXPelsPerMeter;long biYPelsPerMeter;dword biClrUsed;dword biClrImportant;'
Global Const $tagBITMAPV4HEADER = 'dword bV4Size;long bV4Width;long bV4Height;ushort bV4Planes;ushort bV4BitCount;dword bV4Compression;dword bV4SizeImage;long bV4XPelsPerMeter;long bV4YPelsPerMeter;dword bV4ClrUsed;dword bV4ClrImportant;dword bV4RedMask;dword bV4GreenMask;dword bV4BlueMask;dword bV4AlphaMask;dword bV4CSType;int bV4Endpoints[3];dword bV4GammaRed;dword bV4GammaGreen;dword bV4GammaBlue;'
Global Const $tagBITMAPV5HEADER = 'dword bV5Size;long bV5Width;long bV5Height;ushort bV5Planes;ushort bV5BitCount;dword bV5Compression;dword bV5SizeImage;long bV5XPelsPerMeter;long bV5YPelsPerMeter;dword bV5ClrUsed;dword bV5ClrImportant;dword bV5RedMask;dword bV5GreenMask;dword bV5BlueMask;dword bV5AlphaMask;dword bV5CSType;int bV5Endpoints[3];dword bV5GammaRed;dword bV5GammaGreen;dword bV5GammaBlue;dword bV5Intent;dword bV5ProfileData;dword bV5ProfileSize;dword bV5Reserved;'
;Global Const $tagBITMAPINFO = $tagBITMAPINFOHEADER & 'dword bmiColors[1];'
Global Const $tagDIBSECTION = $tagBITMAP & $tagBITMAPINFOHEADER & 'dword dsBitfields[3];ptr dshSection;dword dsOffset;'
Global Const $tagDISK_GEOMETRY = 'int64 Cylinders;dword MediaType;dword TracksPerCylinder;dword SectorsPerTrack;dword BytesPerSector;'
Global Const $tagDISK_GEOMETRY_EX = $tagDISK_GEOMETRY & 'int64 DiskSize;' ; & 'byte Data[n];'
Global Const $tagDTTOPTS = 'dword Size;dword Flags;dword clrText;dword clrBorder;dword clrShadow;int TextShadowType;' & $tagPOINT & ';int BorderSize;int FontPropId;int ColorPropId;int StateId;int ApplyOverlay;int GlowSize;ptr DrawTextCallback;lparam lParam;'
Global Const $tagENHMETAHEADER = 'dword Type;dword Size;long rcBounds[4];long rcFrame[4];dword Signature;dword Version;dword Bytes;dword Records;ushort Handles;ushort Reserved;dword Description;dword OffDescription;dword PalEntries;long Device[2];long Millimeters[2];dword PixelFormat;dword OffPixelFormat;dword OpenGL;long Micrometers[2];'
Global Const $tagEXTLOGPEN = 'dword PenStyle;dword Width;uint BrushStyle;dword Color;ulong_ptr Hatch;dword NumEntries' ; & 'dword StyleEntry[n];'
Global Const $tagHW_PROFILE_INFO = 'dword DockInfo;wchar ProfileGuid[39];wchar ProfileName[80];'
;Global Const $tagICONINFO = 'int Icon;dword xHotspot;dword yHotspot;ptr hMask;ptr hColor'
Global Const $tagIO_COUNTERS = 'uint64 ReadOperationCount;uint64 WriteOperationCount;uint64 OtherOperationCount;uint64 ReadTransferCount;uint64 WriteTransferCount;uint64 OtherTransferCount;'
Global Const $tagLOGBRUSH = 'uint Style;dword Color;ulong_ptr Hatch;'
Global Const $tagLOGPEN = 'uint Style;dword Width;dword Color;'
Global Const $tagLUID = 'dword LowPart;long HighPart;'
Global Const $tagMSGBOXPARAMS = 'uint Size;hwnd hOwner;ptr hInstance;int_ptr Text;int_ptr Caption;dword Style;int_ptr Icon;dword_ptr ContextHelpId;ptr MsgBoxCallback;dword LanguageId;'
Global Const $tagNOTIFYICONDATA = 'dword Size;hwnd hWnd;uint ID;uint Flags;uint CallbackMessage;ptr hIcon;wchar Tip[128];dword State;dword StateMask;wchar Info[256];uint Version;wchar InfoTitle[64];dword InfoFlags;'
Global Const $tagNOTIFYICONDATA_XP = $tagNOTIFYICONDATA & 'uint GUID;'
Global Const $tagNOTIFYICONDATA_VISTA = $tagNOTIFYICONDATA_XP & 'ptr hBalloonIcon;'
Global Const $tagJOBOBJECT_ASSOCIATE_COMPLETION_PORT = 'ulong_ptr CompletionKey;ptr CompletionPort;'
Global Const $tagJOBOBJECT_BASIC_ACCOUNTING_INFORMATION = 'int64 TotalUserTime;int64 TotalKernelTime;int64 ThisPeriodTotalUserTime;int64 ThisPeriodTotalKernelTime;dword TotalPageFaultCount;dword TotalProcesses;dword ActiveProcesses;dword TotalTerminatedProcesses;'
Global Const $tagJOBOBJECT_BASIC_AND_IO_ACCOUNTING_INFORMATION = $tagJOBOBJECT_BASIC_ACCOUNTING_INFORMATION & $tagIO_COUNTERS
Global Const $tagJOBOBJECT_BASIC_LIMIT_INFORMATION = 'int64 PerProcessUserTimeLimit;int64 PerJobUserTimeLimit;dword LimitFlags;ulong_ptr MinimumWorkingSetSize;ulong_ptr MaximumWorkingSetSize;dword ActiveProcessLimit;ulong_ptr Affinity;dword PriorityClass;dword SchedulingClass;'
Global Const $tagJOBOBJECT_BASIC_PROCESS_ID_LIST = 'dword NumberOfAssignedProcesses;dword NumberOfProcessIdsInList' ; & 'ulong_ptr ProcessIdList[n];'
Global Const $tagJOBOBJECT_BASIC_UI_RESTRICTIONS = 'dword UIRestrictionsClass;'
Global Const $tagJOBOBJECT_END_OF_JOB_TIME_INFORMATION = 'dword EndOfJobTimeAction;'
Global Const $tagJOBOBJECT_EXTENDED_LIMIT_INFORMATION = $tagJOBOBJECT_BASIC_LIMIT_INFORMATION & $tagIO_COUNTERS & 'ulong_ptr ProcessMemoryLimit;ulong_ptr JobMemoryLimit;ulong_ptr PeakProcessMemoryUsed;ulong_ptr PeakJobMemoryUsed;'
Global Const $tagJOBOBJECT_GROUP_INFORMATION = '' ; & 'ushort ProcessorGroup[n];'
Global Const $tagJOBOBJECT_SECURITY_LIMIT_INFORMATION = 'dword SecurityLimitFlags;ptr JobToken;ptr SidsToDisable;ptr PrivilegesToDelete;ptr RestrictedSids;'
Global Const $tagOSVERSIONINFO = 'dword OSVersionInfoSize;dword MajorVersion;dword MinorVersion;dword BuildNumber;dword PlatformId;wchar CSDVersion[128];'
Global Const $tagOSVERSIONINFOEX = $tagOSVERSIONINFO & 'ushort ServicePackMajor;ushort ServicePackMinor;ushort SuiteMask;byte ProductType;byte Reserved;'
Global Const $tagPAINTSTRUCT = 'hwnd hDC;int fErase;dword rPaint[4];int fRestore;int fIncUpdate;byte rgbReserved[32];'
Global Const $tagPANOSE = 'byte bFamilyType;byte bSerifStyle;byte bWeight;byte bProportion;byte bContrast;byte bStrokeVariation;byte bArmStyle;byte bLetterform;byte bMidline;byte bXHeight;'
Global Const $tagRGNDATAHEADER = 'dword Size;dword Type;dword Count;dword RgnSize;' & $tagRECT & ';'
;Global Const $tagRGNDATA = $tagRGNDATAHEADER ; & $tagRECT[n] & ';'
Global Const $tagSHFILEINFO = 'ptr hIcon;int iIcon;dword Attributes;wchar DisplayName[260];wchar TypeName[80];'
Global Const $tagSHFILEOPSTRUCT = 'hwnd hWnd;uint Func;ptr From;ptr To;dword Flags;int fAnyOperationsAborted;ptr hNameMappings;ptr ProgressTitle;'
Global Const $tagSHFOLDERCUSTOMSETTINGS = 'dword Size;dword Mask;ptr GUID;ptr WebViewTemplate;dword SizeWVT;ptr WebViewTemplateVersion;ptr InfoTip;dword SizeIT;ptr CLSID;dword Flags;ptr IconFile;dword SizeIF;int IconIndex;ptr Logo;dword SizeL;'
Global Const $tagSHSTOCKICONINFO = 'dword Size;ptr hIcon;int SysImageIndex;int iIcon;wchar Path[260];'
Global Const $tagSTORAGE_DEVICE_NUMBER = 'dword DeviceType;ulong DeviceNumber;ulong PartitionNumber;'
;Global Const $tagTEXTMETRIC = 'long tmHeight;long tmAscent;long tmDescent;long tmInternalLeading;long tmExternalLeading;long tmAveCharWidth;long tmMaxCharWidth;long tmWeight;long tmOverhang;long tmDigitizedAspectX;long tmDigitizedAspectY;wchar tmFirstChar;wchar tmLastChar;wchar tmDefaultChar;wchar tmBreakChar;byte tmItalic;byte tmUnderlined;byte tmStruckOut;byte tmPitchAndFamily;byte tmCharSet;'
;Global Const $tagOUTLINETEXTMETRIC = 'uint otmSize;' & $tagTEXTMETRIC & 'byte otmFiller[4];' & $tagPANOSE & 'uint otmSelection;uint otmType;int otmCharSlopeRise;int otmCharSlopeRun;int otmItalicAngle;uint otmEMSquare;int otmAscent;int otmDescent;uint otmLineGap;uint otmCapEmHeight;uint otmXHeight;long otmFontBox[4];int otmMacAscent;int otmMacDescent;uint otmMacLineGap;uint otmMinimumPPEM;long otmSubscriptSize[2];long otmSubscriptOffset[2];long otmSuperscriptSize[2];long otmSuperscriptOffset[2];uint otmStrikeoutSize;int otmStrikeoutPosition;int otmUnderscoreSize;int otmUnderscorePosition;uint otmFamilyName;uint otmFaceName;uint otmStyleName;uint otmFullName;' ; & 'byte Data[n];'
Global Const $tagVS_FIXEDFILEINFO = 'dword Signature;dword StrucVersion;dword FileVersionMS;dword FileVersionLS;dword ProductVersionMS;dword ProductVersionLS;dword FileFlagsMask;dword FileFlags;dword FileOS;dword FileType;dword FileSubtype;dword FileDateMS;dword FileDateLS;'
;Global Const $tagVS_VERSIONINFO = 'ushort Length;ushort ValueLength;ushort Type;wchar Key;ushort Padding1;' & $tagVS_FIXEDFILEINFO & 'ushort Padding2;ushort Children;'
Global Const $tagWINDOWINFO = 'dword Size;dword rWindow[4];dword rClient[4];dword Style;dword ExStyle;dword WindowStatus;uint cxWindowBorders;uint cyWindowBorders;ushort atomWindowType;ushort CreatorVersion;'
Global Const $tagWNDCLASSEX = 'uint Size;uint Style;ptr hWndProc;int ClsExtra;int WndExtra;ptr hInstance;ptr hIcon;ptr hCursor;ptr hBackground;ptr MenuName;ptr ClassName;ptr hIconSm;'
Global Const $tagXFORM = 'float eM11;float eM12;float eM21;float eM22;float eDX;float eDY;'

#EndRegion Global Variables and Constants

#Region Local Variables and Constants

Global $__Data, $__Ver = '3.1', $__RGB = True

#EndRegion Local Variables and Constants

#Region Public Functions

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_ActivateKeyboardLayout
; Description....: Sets the input locale identifier for the calling thread or the current process.
; Syntax.........: _WinAPI_ActivateKeyboardLayout ( $hLocale [, $iFlag] )
; Parameters.....: $hLocale - The input locale identifier to be activated. This parameter must be either the handle to a keyboard
;                             layout or one of the following values.
;
;                             $HKL_NEXT
;                             $HKL_PREV
;
;                  $iFlag   - The flag that specifies how the input locale identifier is to be activated. This parameter can be
;                             one of the following values.
;
;                             $KLF_REORDER
;                             $KLF_RESET
;                             $KLF_SETFORPROCESS
;                             $KLF_SHIFTLOCK
;
; Return values..: Success  - The previous input locale identifier.
;                  Failure  - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ ActivateKeyboardLayout
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_ActivateKeyboardLayout($hLocale, $iFlag = 0)

	Local $Ret = DllCall('user32.dll', 'long', 'ActivateKeyboardLayout', 'long', $hLocale, 'uint', $iFlag)

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_ActivateKeyboardLayout

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_AbortPath
; Description....: Closes and discards any paths in the specified device context.
; Syntax.........: _WinAPI_AbortPath ( $hDC )
; Parameters.....: $hDC    - Handle to the device context from which a path will be discarded.
; Return values..: Success - 1.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ AbortPath
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_AbortPath($hDC)

	Local $Ret = DllCall('gdi32.dll', 'int', 'AbortPath', 'hwnd', $hDC)

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_AbortPath

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_AboutDlg
; Description....: Displays a Windows About dialog box.
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

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_AboutDlg

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_AddFontMemResourceEx
; Description....: Adds the font resource from a memory image to the system.
; Syntax.........: _WinAPI_AddFontMemResourceEx ( $pData, $iSize )
; Parameters.....: $pData  - The pointer to a font resource.
;                  $iSize  - The number of bytes in the font resource.
; Return values..: Success - The handle uniquely identifies the fonts that were installed on the system, @extended flag will contain
;                            a number of fonts added to the system as a result of this call.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: This function allows an application to get a font that is embedded in a document or a Web page. A font that is
;                  added by this is always private to the process that made the call and is not enumerable.
;
;                  When the function succeeds, the caller of this function can free the memory pointed to by $pData because the system
;                  has made its own copy of the memory. To remove the fonts that were installed, call _WinAPI_RemoveFontMemResourceEx().
;                  However, when the process goes away, the system will unload the fonts.
; Related........:
; Link...........: @@MsdnLink@@ AddFontMemResourceEx
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_AddFontMemResourceEx($pData, $iSize)

	Local $Ret = DllCall('gdi32.dll', 'ptr', 'AddFontMemResourceEx', 'ptr', $pData, 'dword', $iSize, 'ptr', 0, 'dword*', 0)

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return SetError(0, $Ret[4], $Ret[0])
EndFunc   ;==>_WinAPI_AddFontMemResourceEx

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_AddFontResourceEx
; Description....: Adds the font resource from the specified file to the system font table.
; Syntax.........: _WinAPI_AddFontResourceEx ( $sFont [, $iFlag [, $fNotify]] )
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
;                             To add a font whose information comes from several resource files, they must be separated by a "|".
;                             For example, abcxxxxx.pfm|abcxxxxx.pfb.
;
;                  $iFlag   - The characteristics of the font to be added to the system. This parameter can be one of the following values.
;
;                             $FR_PRIVATE
;                             $FR_NOT_ENUM
;
;                  $fNotify - Specifies whether sends a WM_FONTCHANGE message, valid values:
;                  |TRUE    - Send the WM_FONTCHANGE message to all top-level windows after changing the pool of font resources.
;                  |FALSE   - Don`t send. (Default)
; Return values..: Success  - The value that specifies the number of fonts added.
;                  Failure  - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: This function installs the font only for the current session. When the system restarts, the font will not be present.
;                  To have the font installed even after restarting the system, the font must be listed in the registry.
; Related........:
; Link...........: @@MsdnLink@@ AddFontResourceEx
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_AddFontResourceEx($sFont, $iFlag = 0, $fNotify = 0)

	Local $Ret = DllCall('gdi32.dll', 'int', 'AddFontResourceExW', 'wstr', $sFont, 'dword', $iFlag, 'ptr', 0)

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	If $fNotify Then
		DllCall('user32.dll', 'int', 'SendMessage', 'hwnd', 0xFFFF, 'uint', 0x001D, 'int', 0, 'int', 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_AddFontResourceEx

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_AddMRUString
; Description....: Adds a string to the top of the most recently used (MRU) list.
; Syntax.........: _WinAPI_AddMRUString ( $hMRU, $sStr )
; Parameters.....: $hMRU   - Handle of the MRU list.
;                  $sStr   - The string be added.
; Return values..: Success - 1.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ AddMRUStringW
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_AddMRUString($hMRU, $sStr)

	Local $Ret = DllCall('comctl32.dll ', 'int', 'AddMRUStringW', 'ptr', $hMRU, 'wstr', $sStr)

	If (@error) Or ($Ret[0] = -1) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_AddMRUString

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_AdjustTokenPrivileges
; Description....: Enables or disables privileges in the specified access token.
; Syntax.........: _WinAPI_AdjustTokenPrivileges ( $hToken, $aPrivileges, $iState )
; Parameters.....: $hToken      - Handle to the access token that contains the privileges to be modified. The handle must have
;                                 $TOKEN_ADJUST_PRIVILEGES and $TOKEN_QUERY accesses to the token.
;                  $aPrivileges - The variable that specifies a privileges. If this parameter is (-1), the function disables of the token's
;                                 privileges and ignores the $iState parameter. $aPrivileges can be one of the following types.
;
;                                 Single privileges constants ($SE_*).
;                                 1D array of $SE_* constants.
;                                 2D array of $SE_* constants and their attributes (see $iState).
;
;                                 [0][0] - Privilege
;                                 [0][1] - Attribute
;                                 [n][0] - Privilege
;                                 [n][1] - Attribute
;
;                  $iState      - The privilege attribute. If $aPrivileges parameter is 1D array, $iState applied to the entire
;                                 array. If $aPrivileges parameter is (-1) or 2D array, the function ignores this parameter and will
;                                 use the attributes specified in the array. This parameter can be one of the following values.
;
;                                 0 - The privilege is disabled.
;                                 1 - The privilege is enabled.
;                                 2 - The privilege is enabled by default.
;
; Return values..: Success      - If $aPrivileges is a single $SE_* constant, returns a previous privilege attribute (0 or 1),
;                                 otherwise always returns 1. To determine whether the function adjusted all of the specified privileges,
;                                 check @extended flag, which returns one of the following values when the function succeeds:
;
;                                 0 - The function adjusted all specified privileges.
;                                 1 - The token does not have one or more of the privileges specified in the $aPrivileges parameter.
;
;                  Failure      - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: This function cannot add new privileges to the access token. It can only enable or disable the token's
;                  existing privileges.
; Related........:
; Link...........: @@MsdnLink@@ AdjustTokenPrivileges
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_AdjustTokenPrivileges($hToken, $aPrivileges, $iState)

	Switch $iState
		Case 0

		Case 1
			$iState = 2
		Case 2
			$iState = 1
		Case Else
			Return SetError(1, 0, 0)
	EndSwitch

	Local $tLUID, $tPrivileges = 0, $tPrev = 0, $iPrivileges = $aPrivileges, $Disable = 0, $Error, $Result = 1
	Local $Struct = 'dword;dword;long;dword'

	If $aPrivileges = -1 Then
		$Disable = 1
	Else
		If Not IsArray($aPrivileges) Then
			Dim $aPrivileges[1][2] = [[$iPrivileges, $iState]]
			$tPrev = DllStructCreate($Struct)
			If @error Then
				Return SetError(1, 0, 0)
			EndIf
		Else
			If Not UBound($aPrivileges, 2) Then
				Dim $aPrivileges[UBound($iPrivileges)][2]
				For $i = 0 To UBound($iPrivileges) - 1
					$aPrivileges[$i][0] = $iPrivileges[$i]
					$aPrivileges[$i][1] = $iState
				Next
			EndIf
		EndIf
		For $i = 1 To UBound($aPrivileges) - 1
			$Struct &= ';dword;long;dword'
		Next
		$tPrivileges = DllStructCreate($Struct)
		If @error Then
			Return SetError(1, 0, 0)
		EndIf
		DllStructSetData($tPrivileges, 1, UBound($aPrivileges))
		For $i = 0 To UBound($aPrivileges) - 1
			$tLUID = _WinAPI_LookupPrivilegeValue($aPrivileges[$i][0])
			If @error Then
				Return SetError(1, 0, 0)
			EndIf
			DllStructSetData($tPrivileges, 3 * $i + 2, DllStructGetData($tLUID, 1))
			DllStructSetData($tPrivileges, 3 * $i + 3, DllStructGetData($tLUID, 2))
			DllStructSetData($tPrivileges, 3 * $i + 4, $aPrivileges[$i][1])
		Next
	EndIf

	Local $Ret = DllCall('advapi32.dll', 'int', 'AdjustTokenPrivileges', 'ptr', $hToken, 'int', $Disable, 'ptr', DllStructGetPtr($tPrivileges), 'dword', DllStructGetSize($tPrev), 'ptr', DllStructGetPtr($tPrev), 'dword*', 0)

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	If IsDllStruct($tPrev) Then
		$Result = DllStructGetData($tPrev, 4)
	EndIf
	Switch _WinAPI_GetLastError()
		Case 1300 ; ERROR_NOT_ALL_ASSIGNED
			$Error = 1
		Case Else
			$Error = 0
	EndSwitch
	Return SetError(0, $Error, $Result)
EndFunc   ;==>_WinAPI_AdjustTokenPrivileges

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_AdjustWindowRectEx
; Description....: Calculates the required size of the window rectangle, based on the desired size of the client rectangle.
; Syntax.........: _WinAPI_AdjustWindowRectEx ( ByRef $tRECT, $iStyle [, $iExStyle [, $fMenu] )
; Parameters.....: $tRECT    - $tagRECT structure that contains the coordinates of the desired client area.
;                  $iStyle   - The window style of the window whose required size is to be calculated. Note that you cannot
;                              specify the $WS_OVERLAPPED style.
;                  $iExStyle - The extended window style of the window whose required size is to be calculated.
;                  $fMenu    - Specifies whether the window has a menu, valid values:
;                  |TRUE     - The window has a menu, valid values:
;                  |FALSE    - The window does not has a menu. (Default)
; Return values..: Success   - 1.
;                  Failure   - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ AdjustWindowRectEx
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_AdjustWindowRectEx(ByRef $tRECT, $iStyle, $iExStyle = 0, $fMenu = 0)

	Local $Ret = DllCall('user32.dll', 'int', 'AdjustWindowRectEx', 'ptr', DllStructGetPtr($tRECT), 'dword', $iStyle, 'int', $fMenu, 'dword', $iExStyle)

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_AdjustWindowRectEx

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

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_AlphaBlend

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_AngleArc
; Description....: Draws a line segment and an arc.
; Syntax.........: _WinAPI_AngleArc ( $hDC, $iX, $iY, $iRadius, $nStartAngle, $nSweepAngle )
; Parameters.....: $hDC         - Handle to a device context.
;                  $iX          - The x-coordinate, in logical units, of the center of the circle.
;                  $iY          - The y-coordinate, in logical units, of the center of the circle.
;                  $iRadius     - The radius, in logical units, of the circle.
;                  $nStartAngle - The start angle, in degrees, relative to the x-axis.
;                  $nSweepAngle - The sweep angle, in degrees, relative to the starting angle.
; Return values..: Success      - 1.
;                  Failure      - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: The _WinAPI_AngleArc() function draws lines by using the current pen. The figure is not filled. This function
;                  moves the current position to the ending point of the arc.
; Related........:
; Link...........: @@MsdnLink@@ AngleArc
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_AngleArc($hDC, $iX, $iY, $iRadius, $nStartAngle, $nSweepAngle)

	Local $Ret = DllCall('gdi32.dll', 'int', 'AngleArc', 'hwnd', $hDC, 'int', $iX, 'int', $iY, 'dword', $iRadius, 'float', $nStartAngle, 'float', $nSweepAngle)

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_AngleArc

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

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_AnimateWindow

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_Arc
; Description....: Draws an elliptical arc.
; Syntax.........: _WinAPI_Arc ( $hDC, $tRECT, $iXStartArc, $iYStartArc, $iXEndArc, $iYEndArc )
; Parameters.....: $hDC         - Handle to the device context.
;                  $tRECT       - $tagRECT structure that contains the the logical coordinates of the bounding rectangle.
;                  $iXStartArc  - The x-coordinate, in logical units, of the ending point of the radial line defining the starting point of the arc.
;                  $iYStartArc  - The y-coordinate, in logical units, of the ending point of the radial line defining the starting point of the arc.
;                  $iXEndArc    - The x-coordinate, in logical units, of the ending point of the radial line defining the ending point of the arc.
;                  $iYEndArc    - The y-coordinate, in logical units, of the ending point of the radial line defining the ending point of the arc.
; Return values..: Success      - 1.
;                  Failure      - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: The arc is drawn using the current pen; it is not filled. The current position is neither used nor updated by
;                  _WinAPI_Arc() function.
;
;                  Use the _WinAPI_GetArcDirection() and _WinAPI_SetArcDirection() functions to get and set the current drawing
;                  direction for a device context. The default drawing direction is counterclockwise.
; Related........:
; Link...........: @@MsdnLink@@ Arc
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_Arc($hDC, $tRECT, $iXStartArc, $iYStartArc, $iXEndArc, $iYEndArc)

	Local $Ret = DllCall('gdi32.dll', 'int', 'Arc', 'hwnd', $hDC, 'int', DllStructGetData($tRECT, 1), 'int', DllStructGetData($tRECT, 2), 'int', DllStructGetData($tRECT, 3), 'int', DllStructGetData($tRECT, 4), 'int', $iXStartArc, 'int', $iYStartArc, 'int', $iXEndArc, 'int', $iYEndArc)

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_Arc

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_ArcTo
; Description....: Draws an elliptical arc.
; Syntax.........: _WinAPI_ArcTo ( $hDC, $tRECT, $iXRadial1, $iYRadial1, $iXRadial2, $iYRadial2 )
; Parameters.....: $hDC       - Handle to the device context.
;                  $tRECT     - $tagRECT structure that contains the the logical coordinates of the bounding rectangle.
;                  $iXRadial1 - The x-coordinate, in logical units, of the endpoint of the radial defining the starting point of the arc.
;                  $iYRadial1 - The y-coordinate, in logical units, of the endpoint of the radial defining the starting point of the arc.
;                  $iXRadial2 - The x-coordinate, in logical units, of the endpoint of the radial defining the ending point of the arc.
;                  $iYRadial2 - The y-coordinate, in logical units, of the endpoint of the radial defining the ending point of the arc.
; Return values..: Success    - 1.
;                  Failure    - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: The arc is drawn using the current pen; it is not filled. _WinAPI_ArcTo() is similar to the _WinAPI_Arc() function,
;                  except that the current position is updated.
; Related........:
; Link...........: @@MsdnLink@@ ArcTo
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_ArcTo($hDC, $tRECT, $iXRadial1, $iYRadial1, $iXRadial2, $iYRadial2)

	Local $Ret = DllCall('gdi32.dll', 'int', 'ArcTo', 'hwnd', $hDC, 'int', DllStructGetData($tRECT, 1), 'int', DllStructGetData($tRECT, 2), 'int', DllStructGetData($tRECT, 3), 'int', DllStructGetData($tRECT, 4), 'int', $iXRadial1, 'int', $iYRadial1, 'int', $iXRadial2, 'int', $iYRadial2)

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_ArcTo

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
; Name...........: _WinAPI_AssignProcessToJobObject
; Description....: Assigns a process to an existing job object.
; Syntax.........: _WinAPI_AssignProcessToJobObject ( $hJob, $hProcess )
; Parameters.....: $hJob     - Handle to the job object to which the process will be associated. The handle must have the
;                              $JOB_OBJECT_ASSIGN_PROCESS access right.
;                  $hProcess - Handle to the process to associate with the job object. The process must not already be assigned to a job.
; Return values..: Success   - 1.
;                  Failure   - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: After you associate a process with a job object, the process is subject to the limits set for the job. To set
;                  limits for a job, use the _WinAPI_SetInformationJobObject() function.
;
;                  The process can be associated only with a single job. The process inherits limits from the job it is associated
;                  with and adds its accounting information to the job. If a process is associated with a job, all processes it
;                  creates are associated with that job by default.
; Related........:
; Link...........: @@MsdnLink@@ AssignProcessToJobObject
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_AssignProcessToJobObject($hJob, $hProcess)

	Local $Ret = DllCall('kernel32.dll', 'int', 'AssignProcessToJobObject', 'ptr', $hJob, 'ptr', $hProcess)

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_AssignProcessToJobObject

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_AssocGetPerceivedType
; Description....: Retrieves a file's perceived type based on its extension.
; Syntax.........: _WinAPI_AssocGetPerceivedType ( $sExt )
; Parameters.....: $sExt   - The file's extension. This should include the leading period, for example ".txt".
; Return values..: Success - The array containing the following parameters:
;
;                            [0] - The perceived type ($PERCEIVED_TYPE_*).
;                            [1] - The source of the perceived type information ($PERCEIVEDFLAG_*).
;                            [2] - The perceived type string, for instance "text" or "video".
;
;                  Failure - 0 and sets the @error flag to non-zero, @extended flag may contain the system error code.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ AssocGetPerceivedType
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_AssocGetPerceivedType($sExt)

	Local $Ret = DllCall('shlwapi.dll', 'uint', 'AssocGetPerceivedType', 'wstr', $sExt, 'int*', 0, 'dword*', 0, 'wstr*', '')

	If @error Then
		Return SetError(1, 0, 0)
	Else
		If $Ret[0] Then
			Return SetError(1, $Ret[0], 0)
		EndIf
	EndIf

	Local $Result[3]

	For $i = 0 To 2
		$Result[$i] = $Ret[$i + 2]
	Next
	Return $Result
EndFunc   ;==>_WinAPI_AssocGetPerceivedType

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_AssocQueryString
; Description....: Searches for and retrieves a file or protocol association-related string from the registry.
; Syntax.........: _WinAPI_AssocQueryString ( $sAssoc, $iType [, $iFlags [, $sExtra]] )
; Parameters.....: $sAssoc - The string that is used to determine the root key. The following four types of strings can be used.
;
;                            The file name extension, such as ".txt".
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
;                            values, except that only one $ASSOCF_INIT_* value can be included.
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
; Return values..: Success - The string that contains the requested ($ASSOCSTR_*) information.
;                  Failure - Empty string and sets the @error flag to non-zero, @extended flag may contain the system error code.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ AssocQueryString
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_AssocQueryString($sAssoc, $iType, $iFlags = 0, $sExtra = '')

	Local $TypeOfExtra = 'wstr'

	If Not StringStripWS($sExtra, 3) Then
		$TypeOfExtra = 'ptr'
		$sExtra = 0
	EndIf

	Local $tData = DllStructCreate('wchar[1024]')
	Local $Ret = DllCall('shlwapi.dll', 'uint', 'AssocQueryStringW', 'dword', $iFlags, 'dword', $iType, 'wstr', $sAssoc, $TypeOfExtra, $sExtra, 'ptr', DllStructGetPtr($tData), 'dword*', 1024)

	If @error Then
		Return SetError(1, 0, '')
	Else
		If $Ret[0] Then
			Return SetError(1, $Ret[0], '')
		EndIf
	EndIf
	Return DllStructGetData($tData, 1)
EndFunc   ;==>_WinAPI_AssocQueryString

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_BeginDeferWindowPos
; Description....: Allocates memory for a multiple-window-position structure.
; Syntax.........: _WinAPI_BeginDeferWindowPos ( [$iAmount] )
; Parameters.....: $iAmount - The initial number of windows for which to store position information.
; Return values..: Success  - The value identifies the multiple-window-position structure.
;                  Failure  - 0 and sets the @error flag to non-zero.
; Author.........: KaFu
; Modified.......: Yashied
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ BeginDeferWindowPos
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_BeginDeferWindowPos($iAmount = 1)

	Local $Ret = DllCall('user32.dll', 'ptr', 'BeginDeferWindowPos', 'int', $iAmount)

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_BeginDeferWindowPos

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

	If (@error) Or (Not $Ret[0]) Then
		$tPAINTSTRUCT = 0
	EndIf
	Return SetError(Number(IsDllStruct($tPAINTSTRUCT)), 0, $Ret[0])
EndFunc   ;==>_WinAPI_BeginPaint

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_BeginPath
; Description....: Opens a path bracket in the specified device context.
; Syntax.........: _WinAPI_BeginPath ( $hDC )
; Parameters.....: $hDC    - Handle to the device context.
; Return values..: Success - 1.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: After a path bracket is open, an application can begin calling GDI drawing functions to define the points that
;                  lie in the path. An application can close an open path bracket by calling the _WinAPI_EndPath() function.
;
;                  When an application calls _WinAPI_BeginPath() for a device context, any previous paths are discarded from that
;                  device context.
; Related........:
; Link...........: @@MsdnLink@@ BeginPath
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_BeginPath($hDC)

	Local $Ret = DllCall('gdi32.dll', 'int', 'BeginPath', 'hwnd', $hDC)

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_BeginPath

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_BeginUpdateResource
; Description....: Retrieves a handle that can be used to add, delete, or replace resources in a binary module.
; Syntax.........: _WinAPI_BeginUpdateResource ( $sFile [, $fDelete] )
; Parameters.....: $sFile   - The binary file in which to update resources. An application must be able to obtain write-access to
;                             this file; the file referenced by $sFile cannot be currently executing.
;                  $fDelete - Specifies whether to delete existing resources, valid values:
;                  |TRUE    - The resources are deleted and the updated file includes only resources added with the _WinAPI_UpdateResource().
;                  |FALSE   - The updated file includes existing resources. (Default)
; Return values..: Success  - Handle that can be used by the _WinAPI_UpdateResource() and _WinAPI_EndUpdateResource() functions.
;                  Failure  - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: It is recommended that the resource file is not loaded before this function is called. However, if that file
;                  is already loaded, it will not cause an error to be returned.
; Related........:
; Link...........: @@MsdnLink@@ BeginUpdateResource
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_BeginUpdateResource($sFile, $fDelete = 0)

	Local $Ret = DllCall('kernel32.dll', 'ptr', 'BeginUpdateResourceW', 'wstr', $sFile, 'int', $fDelete)

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_BeginUpdateResource

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

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_BringWindowToTop

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_BroadcastSystemMessage
; Description....: Sends a message to the specified recipients.
; Syntax.........: _WinAPI_BroadcastSystemMessage ( $iMessage [, $wParam [, $lParam [, $iFlags [, $iRecipients]]]] )
; Parameters.....: $iMessage    - The message to be sent.
;                  $wParam      - Additional message-specific information.
;                  $lParam      - Additional message-specific information.
;                  $iFlags      - The broadcast option. This parameter can be one or more of the following values.
;
;                                 $BSF_ALLOWSFW
;                                 $BSF_FLUSHDISK
;                                 $BSF_FORCEIFHUNG
;                                 $BSF_IGNORECURRENTTASK
;                                 $BSF_NOHANG
;                                 $BSF_NOTIMEOUTIFNOTHUNG
;                                 $BSF_POSTMESSAGE
;                                 $BSF_QUERY
;                                 $BSF_SENDNOTIFYMESSAGE
;
;                  $iRecipients - The recipients of the message. This parameter can be one or more of the following values.
;
;                                 $BSM_ALLCOMPONENTS
;                                 $BSM_ALLDESKTOPS
;                                 $BSM_APPLICATIONS
;                                 $BSM_INSTALLABLEDRIVERS
;                                 $BSM_NETDRIVER
;                                 $BSM_VXDS
;
; Return values..: Success      - 1 or 0 (see below), @extended flag receives a combination of $BSM_* values identifying which
;                                 recipients actually received the message.
;                  Failure      - (-1) and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: If the $iFlags parameter is $BSF_QUERY and at least one recipient returned BROADCAST_QUERY_DENY to the corresponding
;                  message, the return value is 0.
;
;                  The system only does marshalling for system messages (those in the range 0 to (WM_USER-1)). To send other messages
;                  (those >= WM_USER) to another process, you must do custom marshalling.
; Related........:
; Link...........: @@MsdnLink@@ BroadcastSystemMessage
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_BroadcastSystemMessage($iMessage, $wParam = 0, $lParam = 0, $iFlags = 0, $iRecipients = 0)

	Local $Ret = DllCall('user32.dll', 'long', 'BroadcastSystemMessageW', 'dword', $iFlags, 'dword*', $iRecipients, 'uint', $iMessage, 'wparam', $wParam, 'lparam', $lParam)

	If (@error) Or ($Ret[0] = -1) Then
		Return SetError(1, 0, -1)
	EndIf
	Return SetError(0, $Ret[2], $Ret[0])
EndFunc   ;==>_WinAPI_BroadcastSystemMessage

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_BrowseForFolderDlg
; Description....: Displays a dialog box that enables the user to select a Shell folder.
; Syntax.........: _WinAPI_BrowseForFolderDlg ( [$sRoot [, $sText [, $iFlags [, $pBrowseProc [, $lParam [, $hParent] )
; Parameters.....: $sRoot       - The root folder from which to start browsing. Only the specified folder and its subfolders in the
;                                 namespace hierarchy appear in the dialog box. If this parameter is 0, the namespace root
;                                 (the Desktop folder) is used.
;                  $sText       - The string that is displayed above the tree view control in the dialog box.
;                  $iFlags      - Flags that specify the options for the dialog box. This parameter can a combination of the
;                                 following values.
;
;                                 $BIF_RETURNONLYFSDIRS
;                                 $BIF_DONTGOBELOWDOMAIN
;                                 $BIF_STATUSTEXT
;                                 $BIF_RETURNFSANCESTORS
;                                 $BIF_EDITBOX
;                                 $BIF_VALIDATE
;                                 $BIF_NEWDIALOGSTYLE
;                                 $BIF_BROWSEINCLUDEURLS
;                                 $BIF_USENEWUI
;                                 $BIF_UAHINT
;                                 $BIF_NONEWFOLDERBUTTON
;                                 $BIF_NOTRANSLATETARGETS
;                                 $BIF_BROWSEFORCOMPUTER
;                                 $BIF_BROWSEFORPRINTER
;                                 $BIF_BROWSEINCLUDEFILES
;                                 $BIF_SHAREABLE
;
;                  $pBrowseProc - Pointer to a callback function that the dialog box calls when an event occurs. This function will
;                                 receive one of the following event messages.
;
;                                 $BFFM_INITIALIZED
;                                 $BFFM_IUNKNOWN
;                                 $BFFM_SELCHANGED
;                                 $BFFM_VALIDATEFAILED
;
;                                 (See MSDN for more information)
;
;                  $lParam      - The value that the dialog box passes to the callback function.
;                  $hParent     - Handle to the parent window for the dialog box.
; Return values..: Success      - The full path for chosen folder, or empty string if user cancels/closes the dialog.
;                  Failure      - Empty string and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ SHBrowseForFolder
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_BrowseForFolderDlg($sRoot = '', $sText = '', $iFlags= 0, $pBrowseProc = 0, $lParam = 0, $hParent = 0)

	Local $tBROWSEINFO = DllStructCreate('hwnd;ptr;ptr;ptr;int;ptr;uint_ptr;int')
	Local $tText = DllStructCreate('wchar[1024]')
	Local $tName = DllStructCreate('wchar[260]')
	Local $PIDL = 0, $Result = ''

	If _WinAPI_PathIsDirectory($sRoot) Then
		$PIDL = _WinAPI_ShellILCreateFromPath(_WinAPI_PathSearchAndQualify($sRoot))
	EndIf

	DllStructSetData($tBROWSEINFO, 1, $hParent)
	DllStructSetData($tBROWSEINFO, 2, $PIDL)
	DllStructSetData($tBROWSEINFO, 3, DllStructGetPtr($tName))
	DllStructSetData($tBROWSEINFO, 4, DllStructGetPtr($tText))
	DllStructSetData($tBROWSEINFO, 5, $iFlags)
	DllStructSetData($tBROWSEINFO, 6, $pBrowseProc)
	DllStructSetData($tBROWSEINFO, 7, $lParam)
	DllStructSetData($tBROWSEINFO, 8, 0)

	DllStructSetData($tText, 1, $sText)

	Local $Ret = DllCall('shell32.dll', 'ptr', 'SHBrowseForFolderW', 'ptr', DllStructGetPtr($tBROWSEINFO))

	If @error Then
		Return SetError(1, 0, '')
	Else
		If Not $Ret[0] Then
			Return ''
		EndIf
	EndIf
	$Result = _WinAPI_ShellGetPathFromIDList($Ret[0])
	_WinAPI_CoTaskMemFree($Ret[0])
	If $PIDL Then
		_WinAPI_CoTaskMemFree($PIDL)
	EndIf
	If Not $Result Then
		Return SetError(1, 0, '')
	EndIf
	Return $Result
EndFunc   ;==>_WinAPI_BrowseForFolderDlg

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_CalculatePopupWindowPosition
; Description....: Calculates an appropriate pop-up window position.
; Syntax.........: _WinAPI_CalculatePopupWindowPosition ( $iX, $iY, $iWidth, $iHeight [, $iFlags [, $tExclude]] )
; Parameters.....: $iX       - The x-coordinate, in logical units, of the specified anchor point.
;                  $iY       - The y-coordinate, in logical units, of the specified anchor point.
;                  $iWidth   - The width, in logical units, of the specified window.
;                  $iHeight  - The height, in logical units, of the specified window.
;                  $iFlags   - The flags that specify how the function positions the pop-up window horizontally and vertically.
;
;                              $TPM_CENTERALIGN
;                              $TPM_LEFTALIGN
;                              $TPM_RIGHTALIGN
;
;                              $TPM_BOTTOMALIGN
;                              $TPM_TOPALIGN
;                              $TPM_VCENTERALIGN
;
;                              $TPM_HORIZONTAL
;                              $TPM_VERTICAL
;
;                              $TPM_WORKAREA
;
;                  $tExclude - $tagRECT structure that specifies the exclude rectangle.
; Return values..: Success   - $tagRECT structure that specifies the pop-up window position.
;                  Failure   - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: This function requires Windows 7 or later.
; Related........:
; Link...........: @@MsdnLink@@ CalculatePopupWindowPosition
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_CalculatePopupWindowPosition($iX, $iY, $iWidth, $iHeight, $iFlags = 0, $tExclude = 0)

	Local $tAnchor = DllStructCreate($tagPOINT), $tSize = DllStructCreate($tagSIZE), $tPos =  DllStructCreate($tagRECT)

	DllStructSetData($tAnchor, 1, $iX)
	DllStructSetData($tAnchor, 2, $iY)

	DllStructSetData($tSize, 1, $iWidth)
	DllStructSetData($tSize, 2, $iHeight)

	Local $Ret = DllCall('user32.dll', 'int', 'CalculatePopupWindowPosition', 'ptr', DllStructGetPtr($tAnchor), 'ptr', DllStructGetPtr($tSize), 'uint', $iFlags, 'ptr', DllStructGetPtr($tExclude), 'ptr', DllStructGetPtr($tPos))

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $tPos
EndFunc   ;==>_WinAPI_CalculatePopupWindowPosition

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

	If (@error) Or (Not $Ret[0]) Then
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
; Name...........: _WinAPI_ClipCursor
; Description....: Confines the cursor to a rectangular area on the screen.
; Syntax.........: _WinAPI_ClipCursor ( $tRECT )
; Parameters.....: $tRECT  - $tagRECT structure that contains the screen coordinates of the confining rectangle. If this parameter is 0,
;                            the cursor is free to move anywhere on the screen.
; Return values..: Success - 1.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: The cursor is a shared resource. If an application confines the cursor, it must release the cursor by using
;                  _WinAPI_ClipCursor() before relinquishing control to another application.
; Related........:
; Link...........: @@MsdnLink@@ ClipCursor
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_ClipCursor($tRECT)

	Local $Ret = DllCall('user32.dll', 'int', 'ClipCursor', 'ptr', DllStructGetPtr($tRECT))

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_ClipCursor

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_CloseEnhMetaFile
; Description....: Closes an enhanced-metafile device context and returns a handle that identifies an enhanced-format metafile.
; Syntax.........: _WinAPI_CloseEnhMetaFile ( $hDC )
; Parameters.....: $hDC    - Handle to an enhanced-metafile device context.
; Return values..: Success - Handle to an enhanced metafile.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: When the application no longer needs an enhanced-metafile handle, it should delete the handle by calling the
;                  _WinAPI_DeleteEnhMetaFile() function.
; Related........:
; Link...........: @@MsdnLink@@ CloseEnhMetaFile
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_CloseEnhMetaFile($hDC)

	Local $Ret = DllCall('gdi32.dll', 'int', 'CloseEnhMetaFile', 'hwnd', $hDC)

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_CloseEnhMetaFile

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_CloseFigure
; Description....: Closes an open figure in a path.
; Syntax.........: _WinAPI_CloseFigure ( $hDC )
; Parameters.....: $hDC    - Handle to the device context in which the figure will be closed.
; Return values..: Success - 1.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: The _WinAPI_CloseFigure() function closes the figure by drawing a line from the current position to the first
;                  point of the figure (usually, the point specified by the most recent call to the _WinAPI_MoveToEx() function)
;                  and then connects the lines by using the line join style.
; Related........:
; Link...........: @@MsdnLink@@ CloseFigure
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_CloseFigure($hDC)

	Local $Ret = DllCall('gdi32.dll', 'int', 'CloseFigure', 'hwnd', $hDC)

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_CloseFigure

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_CloseThemeData
; Description....: Closes the theme data handle.
; Syntax.........: _WinAPI_CloseThemeData ( $hTheme )
; Parameters.....: $hTheme - Handle to a window's specified theme data.
; Return values..: Success - 1.
;                  Failure - 0 and sets the @error flag to non-zero, @extended flag may contain the system error code.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ CloseThemeData
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_CloseThemeData($hTheme)

	Local $Ret = DllCall('uxtheme.dll', 'uint', 'CloseThemeData', 'ptr', $hTheme)

	If @error Then
		Return SetError(1, 0, 0)
	Else
		If $Ret[0] Then
			Return SetError(1, $Ret[0], 0)
		EndIf
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_CloseThemeData

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

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_CloseWindow

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_CoInitialize
; Description....: Initializes the COM library for use by the calling process.
; Syntax.........: _WinAPI_CoInitialize ( [$iFlags] )
; Parameters.....: $iFlags - This parameter can be one or more of the following values.
;
;                            $COINIT_APARTMENTTHREADED
;                            $COINIT_DISABLE_OLE1DDE
;                            $COINIT_MULTITHREADED
;                            $COINIT_SPEED_OVER_MEMORY
;
; Return values..: Success - 1.
;                  Failure - 0 and sets the @error flag to non-zero, @extended flag may contain the system error code.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ CoInitializeEx
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_CoInitialize($iFlags = 0)

	Local $Ret = DllCall('ole32.dll', 'uint', 'CoInitializeEx', 'ptr', 0, 'dword', $iFlags)

	If @error Then
		Return SetError(1, 0, 0)
	Else
		If $Ret[0] Then
			Return SetError(1, $Ret[0], 0)
		EndIf
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_CoInitialize

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_ColorHLSToRGB
; Description....: Converts colors from hue-luminance-saturation (HLS) to RGB format.
; Syntax.........: _WinAPI_ColorHLSToRGB ( $iHue, $iLuminance, $iSaturation )
; Parameters.....: $iHue        - HLS hue value.
;                  $iLuminance  - HLS luminance value.
;                  $iSaturation - HLS saturation value.
; Return values..: Success      - Returns the RGB value.
;                  Failure      - (-1) and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ ColorHLSToRGB
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_ColorHLSToRGB($iHue, $iLuminance, $iSaturation)

	If Not $iSaturation Then
		$iHue = 160
	EndIf

	Local $Ret = DllCall('shlwapi.dll', 'dword', 'ColorHLSToRGB', 'dword', $iHue, 'dword', $iLuminance, 'dword', $iSaturation)

	If @error Then
		Return SetError(1, 0, -1)
	EndIf
	Return __RGB($Ret[0])
EndFunc   ;==>_WinAPI_ColorHLSToRGB

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_ColorRGBToHLS
; Description....: Converts colors from RGB to hue-luminance-saturation (HLS) format.
; Syntax.........: _WinAPI_ColorRGBToHLS ( $iRGB, ByRef $iHue, ByRef $iLuminance, ByRef $iSaturation )
; Parameters.....: $iRGB        - RGB color.
;                  $iHue        - HLS hue value.
;                  $iLuminance  - HLS luminance value.
;                  $iSaturation - HLS saturation value.
; Return values..: Success      - 1.
;                  Failure      - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ ColorRGBToHLS
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_ColorRGBToHLS($iRGB, ByRef $iHue, ByRef $iLuminance, ByRef $iSaturation)

	Local $Ret = DllCall('shlwapi.dll', 'none', 'ColorRGBToHLS', 'dword', __RGB($iRGB), 'dword*', 0, 'dword*', 0, 'dword*', 0)

	If @error Then
		Return SetError(1, 0, 0)
	EndIf
	$iHue = $Ret[2]
	$iLuminance = $Ret[3]
	$iSaturation = $Ret[4]
	Return 1
EndFunc   ;==>_WinAPI_ColorRGBToHLS

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_CommandLineToArgv
; Description....: Parses a command-line string and returns an array of the command-line arguments.
; Syntax.........: _WinAPI_CommandLineToArgv ( $sCmd )
; Parameters.....: $sCmd   - The string that contains the full command line. If this parameter is an empty string the function returns
;                            an empty array (zeroth element is 0).
; Return values..: Success - The array of the command-line arguments. The zeroth array element contains the number of arguments.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ CommandLineToArgvW
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_CommandLineToArgv($sCmd)

	Local $Result[1] = [0]

	$sCmd = StringStripWS($sCmd, 3)
	If Not $sCmd Then
		Return $Result
	EndIf

	Local $Ret, $Struct, $tArg, $tCmd, $tPtr

	$Struct = 'wchar[' & (StringLen($sCmd) + 1) & ']'
	$tCmd = DllStructCreate($Struct)
	DllStructSetData($tCmd, 1, $sCmd)
	$Ret = DllCall('shell32.dll', 'ptr', 'CommandLineToArgvW', 'ptr', DllStructGetPtr($tCmd), 'int*', 0)
	If (@error) Or (Not $Ret[0]) Or (Not $Ret[2]) Then
		Return SetError(1, 0, 0)
	EndIf
	$tPtr = DllStructCreate('ptr[' & $Ret[2] & ']', $Ret[0])
	Dim $Result[$Ret[2] + 1] = [$Ret[2]]
	For $i = 1 To $Ret[2]
		$tArg = DllStructCreate($Struct, DllStructGetData($tPtr, 1, $i))
		If Not @error Then
			$Result[$i] = DllStructGetData($tArg, 1)
		Else
			$Result = 0
			ExitLoop
		EndIf
	Next
	_WinAPI_LocalFree($Ret[0])
	If Not IsArray($Result) Then
		Return SetError(2, 0, 0)
	EndIf
	Return $Result
EndFunc   ;==>_WinAPI_CommandLineToArgv

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_CopyBitmap
; Description....: Creates a duplicate of a specified bitmap with a device-independent bitmap (DIB) section.
; Syntax.........: _WinAPI_CopyBitmap ( $hBitmap )
; Parameters.....: $hBitmap - Handle to the bitmap to be duplicated.
; Return values..: Success  - Handle to the new bitmap that was created.
;                  Failure  - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: When you are finished using the bitmap, destroy it using the _WinAPI_DeleteObject() function.
; Related........:
; Link...........: @@MsdnLink@@ CopyImage
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_CopyBitmap($hBitmap)
	Return _WinAPI_CopyImage($hBitmap, 0, 0, 0, 0x2000)
EndFunc   ;==>_WinAPI_CopyBitmap

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_CopyCursor
; Description....: Creates a duplicate of a specified cursor.
; Syntax.........: _WinAPI_CopyCursor ( $hCursor )
; Parameters.....: $hCursor - Handle to the cursor to be duplicated.
; Return values..: Success  - Handle to the new cursor that was created.
;                  Failure  - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: When you are finished using the cursor, destroy it using the _WinAPI_DestroyCursor() function.
; Related........:
; Link...........: @@MsdnLink@@ CopyIcon
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_CopyCursor($hCursor)
	Return _WinAPI_CopyIcon($hCursor)
EndFunc   ;==>_WinAPI_CopyCursor

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_CopyEnhMetaFile
; Description....: Copies the contents of an enhanced-format metafile to a specified file.
; Syntax.........: _WinAPI_CopyEnhMetaFile ( $hEmf [, $sFile] )
; Parameters.....: $hEmf   - Handle to the enhanced metafile to be copied.
;                  $sFile  - The name of the destination file (.emf). If this parameter is 0, the source metafile is copied to memory.
; Return values..: Success - Handle to the copy of the enhanced metafile.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: When the application no longer needs an enhanced-metafile handle, it should delete the handle by calling the
;                  _WinAPI_DeleteEnhMetaFile() function.
; Related........:
; Link...........: @@MsdnLink@@ CopyEnhMetaFile
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_CopyEnhMetaFile($hEmf, $sFile = '')

	Local $TypeOfFile = 'wstr'

	If Not StringStripWS($sFile, 3) Then
		$TypeOfFile = 'ptr'
		$sFile = 0
	EndIf

	Local $Ret = DllCall('gdi32.dll', 'ptr', 'CopyEnhMetaFileW', 'ptr', $hEmf, $TypeOfFile, $sFile)

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_CopyEnhMetaFile

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_CopyFileEx
; Description....: Copies an existing file to a new file, notifying the application of its progress through a callback function.
; Syntax.........: _WinAPI_CopyFileEx ( $sExistingFile, $sNewFile [, $iFlags [, $pProgressProc [, $pData] )
; Parameters.....: $sExistingFile - The name of an existing file.
;                  $sNewFile      - The name of the new file.
;                  $iFlags        - The flags that specify how the file is to be copied. This parameter can be a combination
;                                   of the following values.
;
;                                   $COPY_FILE_ALLOW_DECRYPTED_DESTINATION
;                                   $COPY_FILE_COPY_SYMLINK
;                                   $COPY_FILE_FAIL_IF_EXISTS
;                                   $COPY_FILE_NO_BUFFERING
;                                   $COPY_FILE_OPEN_SOURCE_FOR_WRITE
;                                   $COPY_FILE_RESTARTABLE
;
;                  $pProgressProc - The address of a callback function that is called each time another portion of the file
;                                   has been copied.
;
;                                   (See MSDN for more information)
;
;                  $pData         - The argument to be passed to the callback function.
; Return values..: Success        - 1.
;                  Failure        - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ CopyFileEx
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_CopyFileEx($sExistingFile, $sNewFile, $iFlags = 0, $pProgressProc = 0, $pData = 0)

	Local $Ret = DllCall('kernel32.dll', 'int', 'CopyFileExW', 'wstr', $sExistingFile, 'wstr', $sNewFile, 'ptr', $pProgressProc, 'long_ptr', $pData, 'ptr', 0, 'dword', $iFlags)

	If (@error) Or (Not $Ret[0]) Then
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
; Remarks........: When you are finished using the resource, you can release its associated memory by calling _WinAPI_DeleteObject()
;                  function respectively for bitmaps, cursors, or icons. The system automatically deletes the resource when its
;                  process terminates, however, calling the appropriate function saves memory and decreases the size of the
;                  process's working set.
; Related........:
; Link...........: @@MsdnLink@@ CopyImage
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_CopyImage($hImage, $iType = 0, $xDesired = 0, $yDesired = 0, $iFlags = 0)

	Local $Ret = DllCall('user32.dll', 'ptr', 'CopyImage', 'ptr', $hImage, 'int', $iType, 'int', $xDesired, 'int', $yDesired, 'int', $iFlags)

	If (@error) Or (Not $Ret[0]) Then
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

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $tData
EndFunc   ;==>_WinAPI_CopyRect

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_CopyStruct
; Description....: Creates a duplicate of a specified structure.
; Syntax.........: _WinAPI_CopyStruct (ByRef $tStruct [, $sStruct] )
; Parameters.....: $tStruct - The structure to be duplicated.
;                  $sStruct - The string representing the structure (same as for the DllStructCreate()).
; Return values..: Success  - "byte[n]" or $sStruct structure that was created.
;                  Failure  - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: None
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_CopyStruct(ByRef $tStruct, $sStruct = '')

	Local $Size = DllStructGetSize($tStruct)

	If Not $Size Then
		Return SetError(1, 0, 0)
	EndIf

	Local $tSrc, $tDst, $tResult

	If Not StringStripWS($sStruct, 7) Then
		$sStruct = 'byte[' & $Size & ']'
	EndIf
	$tResult = DllStructCreate($sStruct)
	$tDst = DllStructCreate('byte[' & $Size & ']', DllStructGetPtr($tResult))
	$tSrc = DllStructCreate('byte[' & $Size & ']', DllStructGetPtr($tStruct))
	If (Not IsDllStruct($tResult)) Or (Not IsDllStruct($tDst)) Or (Not IsDllStruct($tSrc)) Then
		Return SetError(1, 0, 0)
	EndIf
	For $i = 1 To $Size
		DllStructSetData($tDst, 1, DllStructGetData($tSrc, 1, $i), $i)
		If @error Then
			Return SetError(1, 0, 0)
		EndIf
	Next
	Return $tResult
EndFunc   ;==>_WinAPI_CopyStruct

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_CoTaskMemAlloc
; Description....: Allocates a block of task memory.
; Syntax.........: _WinAPI_CoTaskMemAlloc ( $iSize )
; Parameters.....: $iSize  - The size of the memory block to be allocated, in bytes.
; Return values..: Success - The allocated memory block.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: If $iSize is 0, _WinAPI_CoTaskMemAlloc() allocates a zero-length item and returns a valid pointer to that item.
;                  The allocated block may be larger than $iSize bytes because of the space required for alignment and for
;                  maintenance information.
; Related........:
; Link...........: @@MsdnLink@@ CoTaskMemAlloc
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_CoTaskMemAlloc($iSize)

	Local $Ret = DllCall('ole32.dll', 'ptr', 'CoTaskMemAlloc', 'uint_ptr', $iSize)

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_CoTaskMemAlloc

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_CoTaskMemFree
; Description....: Frees a block of task memory.
; Syntax.........: _WinAPI_CoTaskMemFree ( $hMemory )
; Parameters.....: $hMemory - The pointer to the memory block to be freed.
; Return values..: Success  - 1.
;                  Failure  - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ CoTaskMemFree
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_CoTaskMemFree($hMemory)
	DllCall('ole32.dll', 'int', 'CoTaskMemFree', 'ptr', $hMemory)
	If @error Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_CoTaskMemFree

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_CoTaskMemRealloc
; Description....: Changes the size of a previously allocated block of task memory.
; Syntax.........: _WinAPI_CoTaskMemRealloc ( $hMemory, $iSize )
; Parameters.....: $hMemory - The pointer to the memory block to be reallocated.
;                  $iSize   - The size of the memory block to be reallocated, in bytes.
; Return values..: Success  - The reallocated memory block.
;                  Failure  - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: If $hMemory is 0, function allocates a new memory block in the same way as the _WinAPI_CoTaskMemAlloc() function.
;                  If $hMemory is not 0, it should be a pointer returned by a prior call to _WinAPI_CoTaskMemAlloc().
;
;                  The contents of the block are unchanged up to the shorter of the new and old sizes, although the new block
;                  can be in a different location. If $hMemory is not 0 and $iSize is 0, then the memory pointed to by
;                  $hMemory is freed.
; Related........:
; Link...........: @@MsdnLink@@ CoTaskMemRealloc
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_CoTaskMemRealloc($hMemory, $iSize)

	Local $Ret = DllCall('ole32.dll', 'ptr', 'CoTaskMemRealloc', 'ptr', $hMemory, 'uint_ptr', $iSize)

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_CoTaskMemRealloc

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_CoUninitialize
; Description....: Closes the COM library on the current process.
; Syntax.........: _WinAPI_CoUninitialize ( )
; Parameters.....: None
; Return values..: Success - 1.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ CoUninitialize
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_CoUninitialize()
	DllCall('ole32.dll', 'none', 'CoUninitialize')
	If @error Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_CoUninitialize

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
;                            Specifies the orientation of the lines used to create the hatch. It can be one of the orientation constants ($HS_*).
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
	DllStructSetData($tLOGBRUSH, 2, __RGB($iRGB))
	DllStructSetData($tLOGBRUSH, 3, $iHatch)

	Local $Ret = DllCall('gdi32.dll', 'int', 'CreateBrushIndirect', 'ptr', DllStructGetPtr($tLOGBRUSH))

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_CreateBrushIndirect

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_CreateCaret
; Description....: Creates a new shape for the system caret and assigns ownership of the caret to the specified window.
; Syntax.........: _WinAPI_CreateCaret ( $hWnd, $hBitmap [, $iWidth [, $iHeight]] )
; Parameters.....: $hWnd    - Handle to the window that owns the caret.
;                  $hBitmap - Handle to the bitmap that defines the caret shape. If this parameter is 0, the caret is solid.
;                             If this parameter is 1, the caret is gray. If this parameter is a bitmap handle, the caret is
;                             the specified bitmap.
;                  $iWidth  - The width of the caret in logical units. If this parameter is 0, the width is set to the system-defined
;                             window border width. If $hBitmap is a bitmap handle, _WinAPI_CreateCaret() ignores this parameter.
;                  $iHeight - The height of the caret in logical units. If this parameter is 0, the height is set to the system-defined
;                             window border height. If $hBitmap  is a bitmap handle, _WinAPI_CreateCaret() ignores this parameter.
; Return values..: Success  - 1.
;                  Failure  - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: _WinAPI_CreateCaret() automatically destroys the previous caret shape, if any, regardless of the window that owns the caret.
;                  The caret is hidden until the application calls the _WinAPI_ShowCaret() function to make the caret visible.
;
;                  The system provides one caret per queue. A window should create a caret only when it has the keyboard focus or is active.
;                  The window should destroy the caret before losing the keyboard focus or becoming inactive.
;
;                  You can retrieve the width or height of the system's window border by using the _WinAPI_GetSystemMetrics() function,
;                  specifying the $SM_CXBORDER and $SM_CYBORDER values. Using the window border width or height guarantees that the
;                  caret will be visible on a high-resolution screen.
; Related........:
; Link...........: @@MsdnLink@@ CreateCaret
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_CreateCaret($hWnd, $hBitmap, $iWidth = 0, $iHeight = 0)

	Local $Ret = DllCall('user32.dll', 'int', 'CreateCaret', 'hwnd', $hWnd, 'ptr', $hBitmap, 'int', $iWidth, 'int', $iHeight)

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_CreateCaret

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
;                  When you no longer need the bitmap, call the _WinAPI_DeleteObject() function to delete it.
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
	If (@error) Or (Not $Ret[0]) Then
		_WinAPI_DeleteObject($hBmp)
		$Ret = 0
	EndIf
	_WinAPI_DeleteObject($hBrush)
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
;                  $iUsage      - The type of colors used. (either logical palette indexes or literal RGB values). The following
;                                 values are defined.
;
;                                 $DIB_PAL_COLORS
;                                 $DIB_RGB_COLORS
;
;                  $pBits       - A pointer to the location of the DIB bit values.
;                  $hSection    - Handle to a file-mapping object that the function will use to create the DIB.
;                  $iOffset     - The offset from the beginning of the file-mapping object referenced by $hSection where storage
;                                 for the bitmap bit values is to begin. This value is ignored if $hSection is 0.
; Return values..: Success      - Handle to the newly created DIB, and $pBits points to the bitmap bit values. You can create the
;                                 structure by using $pBits pointer to further its filling. For example,
;                                 DllStructCreate('dword[4]', $pBits).
;                  Failure      - 0 and sets the @error flag to non-zero, $pBits also is 0.
; Author.........: Yashied
; Modified.......:
; Remarks........: When you are finished using the icon, destroy it using the _WinAPI_DestroyIcon() function.
; Related........:
; Link...........: @@MsdnLink@@ CreateDIBSection
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_CreateDIBSection($hDC, $tBITMAPINFO, $iUsage, ByRef $pBits, $hSection = 0, $iOffset = 0)

	Local $Ret = DllCall('gdi32.dll', 'ptr', 'CreateDIBSection', 'hwnd', $hDC, 'ptr', DllStructGetPtr($tBITMAPINFO), 'uint', $iUsage, 'ptr*', 0, 'ptr', $hSection, 'dword', $iOffset)

	If (@error) Or (Not $Ret[0]) Then
		$pBits = 0
	Else
		$pBits = $Ret[4]
	EndIf
	Return SetError(Number(Not $Ret[0]), 0, $Ret[0])
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
;                  When you no longer need the HRGN object, call the _WinAPI_DeleteObject() function to delete it.
; Related........:
; Link...........: @@MsdnLink@@ CreateEllipticRgnIndirect
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_CreateEllipticRgn($tRECT)

	Local $Ret = DllCall('gdi32.dll', 'ptr', 'CreateEllipticRgnIndirect', 'ptr', DllStructGetPtr($tRECT))

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_CreateEllipticRgn

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_CreateEnhMetaFile
; Description....: Creates a device context for an enhanced-format metafile.
; Syntax.........: _WinAPI_CreateEnhMetaFile ( [$hDC [, $tRECT [, $fPixels [, $sFile [, $sDescription]]]]] )
; Parameters.....: $hDC          - Handle to a reference device for the enhanced metafile. The system uses this device context to
;                                  record the resolution and units of the device on which a picture originally appeared.
;                                  If this parameter is 0, it uses the current display device for reference.
;                  $tRECT        - $tagRECT structure that specifies the dimensions of the picture to be stored in the enhanced metafile.
;                                  If this parameter is 0, the graphics device interface computes
;                                  the dimensions of the smallest rectangle that surrounds the picture drawn by the application.
;                  $fPixels      - Specifies whether the $tRECT structure defined in pixels, valid values:
;                  |TRUE         - In logical units (pixels).
;                  |FALSE        - In .01-millimeter units. (Default)
;                  $sFile        - The file name for the enhanced metafile to be created. If this parameter is 0, the enhanced
;                                  metafile is memory based and its contents are lost when it is deleted by using the
;                                  _WinAPI_DeleteEnhMetaFile() function.
;                  $sDescription - The string that specifies the name of the application that created the picture, as well as the
;                                  picture's title. This string must be an empty string or represented as follows:
;
;                                  "application name|picture name"
;
; Return values..: Success       - Handle to the device context for the enhanced metafile.
;                  Failure       - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: Applications use the device context created by this function to store a graphics picture in an enhanced metafile.
;                  The handle identifying this device context can be passed to any GDI function.
;
;                  After an application stores a picture in an enhanced metafile, it can display the picture on any output device by
;                  calling the _WinAPI_PlayEnhMetaFile() function. When displaying the picture, the system uses the rectangle pointed
;                  to by the $tRECT parameter and the resolution data from the reference device to position and scale the picture.
;
;                  The file name for the enhanced metafile should use the .emf extension.
; Related........:
; Link...........: @@MsdnLink@@ CreateEnhMetaFile
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_CreateEnhMetaFile($hDC = 0, $tRECT = 0, $fPixels = 0, $sFile = '', $sDescription = '')

	Local $TypeOfFile = 'wstr'

	If Not StringStripWS($sFile, 3) Then
		$TypeOfFile = 'ptr'
		$sFile = 0
	EndIf

	Local $tData = 0, $aData = StringSplit($sDescription, '|', 2)

	If UBound($aData) < 2 Then
		ReDim $aData[2]
		$aData[1] = ''
	EndIf
	For $i = 0 To 1
		$aData[$i] = StringStripWS($aData[$i], 3)
	Next
	If ($aData[0]) Or ($aData[1]) Then
		$tData = _WinAPI_ArrayToStruct($aData)
	EndIf

	Local $Xp, $Yp, $Xm, $Ym, $hRef = 0

	If ($fPixels) And (IsDllStruct($tRECT)) Then
		If Not $hDC Then
			$hRef = _WinAPI_GetDC(0)
		EndIf
		$Xp = _WinAPI_GetDeviceCaps($hRef, 8 )
		$Yp = _WinAPI_GetDeviceCaps($hRef, 10)
		$Xm = _WinAPI_GetDeviceCaps($hRef, 4 )
		$Ym = _WinAPI_GetDeviceCaps($hRef, 6 )
		If $hRef Then
			_WinAPI_ReleaseDC(0, $hRef)
		EndIf
		For $i = 1 To 3 Step 2
			DllStructSetData($tRECT, $i, Round(DllStructGetData($tRECT, $i) * $Xm / $Xp * 100))
		Next
		For $i = 2 To 4 Step 2
			DllStructSetData($tRECT, $i, Round(DllStructGetData($tRECT, $i) * $Ym / $Yp * 100))
		Next
	EndIf

	Local $Ret = DllCall('gdi32.dll', 'hwnd', 'CreateEnhMetaFileW', 'hwnd', $hDC, $TypeOfFile, $sFile, 'ptr', DllStructGetPtr($tRECT), 'ptr', DllStructGetPtr($tData))

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_CreateEnhMetaFile

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_CreateFileEx
; Description....: Creates or opens a file or I/O device.
; Syntax.........: _WinAPI_CreateFileEx ( $sFile, $iCreation, $iAccess, $iShare [, $iFlagsAndAttributes [, $tSecurity [, $hTemplate]]] )
; Parameters.....: $sFile               - The name of the file or device to be created or opened.
;                  $iCreation           - The action to take on a file or device that exists or does not exist. This parameter must be
;                                         one of the following values, which cannot be combined.
;
;                                         $CREATE_NEW
;                                         $CREATE_ALWAYS
;                                         $OPEN_EXISTING
;                                         $OPEN_ALWAYS
;                                         $TRUNCATE_EXISTING
;
;                  $iAccess             - The requested access to the file or device, which can be summarized as read, write, both
;                                         or neither (zero).
;
;                                         $GENERIC_READ
;                                         $GENERIC_WRITE
;
;                                         (See MSDN for more information)
;
;                  $iShare              - The requested sharing mode of the file or device, which can be read, write, both,
;                                         delete, all of these, or none. If this parameter is 0 and _WinAPI_CreateFileEx() succeeds,
;                                         the file or device cannot be shared and cannot be opened again until the handle to
;                                         the file or device is closed.
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
;                                         $SECURITY_CONTEXT_TRACKING
;                                         $SECURITY_DELEGATION
;                                         $SECURITY_EFFECTIVE_ONLY
;                                         $SECURITY_IDENTIFICATION
;                                         $SECURITY_IMPERSONATION
;
;                  $tSecurity           - $tagSECURITY_ATTRIBUTES structure that contains two separate but related data members:
;                                         an optional security descriptor, and a Boolean value that determines whether the returned
;                                         handle can be inherited by child processes. If this parameter is 0, the handle cannot
;                                         be inherited by any child processes the application may create and the file or device
;                                         associated with the returned handle gets a default security descriptor.
;                  $hTemplate           - Handle to a template file with the $GENERIC_READ access right. The template file supplies
;                                         file attributes and extended attributes for the file that is being created.
; Return values..: Success              - Handle to the specified file, device, named pipe, or mail slot.
;                  Failure              - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: When an application is finished using the object handle returned by this function, use the _WinAPI_CloseHandle()
;                  function to close the handle. This not only frees up system resources, but can have wider influence on things
;                  like sharing the file or device and committing data to disk.
; Related........:
; Link...........: @@MsdnLink@@ CreateFile
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_CreateFileEx($sFile, $iCreation, $iAccess, $iShare, $iFlagsAndAttributes = 0, $tSecurity = 0, $hTemplate = 0)

	Local $Ret = DllCall('kernel32.dll', 'ptr', 'CreateFileW', 'wstr', $sFile, 'dword', $iAccess, 'dword', $iShare, 'ptr', DllStructGetPtr($tSecurity), 'dword', $iCreation, 'dword', $iFlagsAndAttributes, 'ptr', $hTemplate)

	If (@error) Or ($Ret[0] = Ptr(-1)) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_CreateFileEx

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_CreateFileMapping
; Description....: Creates or opens a named or unnamed file mapping object for a specified file.
; Syntax.........: _WinAPI_CreateFileMapping ( $hFile [, $iSize [, $sName [, $iProtect [, $tSecurity]]]] )
; Parameters.....: $hFile     - Handle to the file from which to create a file mapping object. If this parameter is (-1), the calling
;                               process must also specify a size for the file mapping object in the $iSize parameters. In this scenario,
;                               _WinAPI_CreateFileMapping() creates a file mapping object of a specified size that is backed by the
;                               system paging file instead of by a file in the file system.
;                  $iSize     - The maximum size of the file mapping object. If this parameter is 0, the maximum size of the file
;                               mapping object is equal to the current size of the file that $hFile identifies.
;                  $sName     - The name of the file mapping object.
;                  $iProtect  - Specifies the page protection of the file mapping object and can be one of the following values.
;
;                               $PAGE_EXECUTE_READ
;                               $PAGE_EXECUTE_READWRITE
;                               $PAGE_EXECUTE_WRITECOPY
;                               $PAGE_READONLY
;                               $PAGE_READWRITE
;                               $PAGE_WRITECOPY
;
;                               An application can specify one or more of the following attributes for the file mapping object
;                               by combining them with one of the preceding page protection values.
;
;                               $SEC_COMMIT
;                               $SEC_IMAGE
;                               $SEC_LARGE_PAGES
;                               $SEC_NOCACHE
;                               $SEC_RESERVE
;                               $SEC_WRITECOMBINE
;
;                  $tSecurity - $tagSECURITY_ATTRIBUTES structure that determines whether a returned handle can be inherited by
;                               child processes. If this parameter is 0, the handle cannot be inherited and the file mapping object
;                               gets a default security descriptor.
; Return values..: Success    - Handle to the newly created file mapping object. If the object exists before the function call,
;                               the function returns a handle to the existing object (with its current size, not the specified
;                               size), and sets the @extended flag to 1.
;                  Failure    - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: After a file mapping object is created, the size of the file must not exceed the size of the file mapping object;
;                  if it does, not all of the file contents are available for sharing.
;
;                  Multiple processes can share a view of the same file by either using a single shared file mapping object or creating
;                  separate file mapping objects backed by the same file. A single file mapping object can be shared by multiple processes
;                  through inheriting the handle at process creation, duplicating the handle, or opening the file mapping object by name.
;
;                  A file mapping object does not actually map the view into a process address space. The _WinAPI_MapViewOfFile()
;                  functions map a view of a file into a process address space.
;
;                  Mapped views of a file mapping object maintain internal references to the object, and a file mapping object does
;                  not close until all references to it are released. Therefore, to fully close a file mapping object, an application
;                  must unmap all mapped views of the file mapping object by calling _WinAPI_UnmapViewOfFile() and close the file
;                  mapping object handle by calling _WinAPI_CloseHandle(). These functions can be called in any order.
; Related........:
; Link...........: @@MsdnLink@@ CreateFileMapping
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_CreateFileMapping($hFile, $iSize = 0, $sName = '', $iProtect = 0x0004, $tSecurity = 0)

	Local $TypeOfName = 'wstr'

	If Not StringStripWS($sName, 3) Then
		$TypeOfName = 'ptr'
		$sName = 0
	EndIf

	Local $Ret = DllCall('kernel32.dll', 'ptr', 'CreateFileMappingW', 'ptr', $hFile, 'ptr', DllStructGetPtr($tSecurity), 'dword', $iProtect, 'dword', _WinAPI_HiDWord($iSize), 'dword', _WinAPI_LoDWord($iSize), $TypeOfName, $sName)

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return SetError(0, Number(_WinAPI_GetLastError() = 183), $Ret[0])
EndFunc   ;==>_WinAPI_CreateFileMapping

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_CreateGUID
; Description....: Creates a globally unique identifier (GUID).
; Syntax.........: _WinAPI_CreateGUID ( )
; Parameters.....: None
; Return values..: Success - The string representation of the GUID.
;                  Failure - Empty string and sets the @error flag to non-zero, @extended flag may contain the system error code.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: None
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_CreateGUID()

	Local $tData = DllStructCreate('wchar[39]')
	Local $tGUID = DllStructCreate($tagGUID)
	Local $Ret

	$Ret = DllCall('ole32.dll', 'uint', 'CoCreateGuid', 'ptr', DllStructGetPtr($tGUID))
	If @error Then
		Return SetError(1, 0, '')
	Else
		If $Ret[0] Then
			Return SetError(1, $Ret[0], 0)
		EndIf
	EndIf
	$Ret = DllCall('ole32.dll', 'int', 'StringFromGUID2', 'ptr', DllStructGetPtr($tGUID), 'ptr', DllStructGetPtr($tData), 'int', 39)
	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, '')
	EndIf
	Return DllStructGetData($tData, 1)
EndFunc   ;==>_WinAPI_CreateGUID

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_CreateIcon
; Description....: Creates an icon that has the specified size, colors, and bit patterns.
; Syntax.........: _WinAPI_CreateIcon ( $hInstance, $iWidth, $iHeight, $iPlanes, $iBitsPixel, $pANDBits, $pXORBits )
; Parameters.....: $hInstance  - Handle to the instance of the module creating the icon.
;                  $iWidth     - The width, in pixels, of the icon.
;                  $iHeight    - The height, in pixels, of the icon.
;                  $iPlanes    - The number of planes in the XOR bitmask of the icon.
;                  $iBitsPixel - The number of bits-per-pixel in the XOR bitmask of the icon.
;                  $pANDBits   - An array of bytes that contains the bit values for the AND bitmask of the icon. This bitmask describes
;                                a monochrome bitmap.
;                  $pXORBits   - An array of bytes that contains the bit values for the XOR bitmask of the icon. This bitmask describes
;                                a monochrome or device-dependent color bitmap.
; Return values..: Success     - Handle to the icon that is created.
;                  Failure     - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: When you are finished using the icon, destroy it using the _WinAPI_DestroyIcon() function.
; Related........:
; Link...........: @@MsdnLink@@ CreateIcon
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_CreateIcon($hInstance, $iWidth, $iHeight, $iPlanes, $iBitsPixel, $pANDBits, $pXORBits)

	Local $Ret = DllCall('user32.dll', 'ptr', 'CreateIcon', 'ptr', $hInstance, 'int', $iWidth, 'int', $iHeight, 'byte', $iPlanes, 'byte', $iBitsPixel, 'ptr', $pANDBits, 'ptr', $pXORBits)

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_CreateIcon

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_CreateIconFromResourceEx
; Description....: Creates an icon or cursor from resource bits describing the icon.
; Syntax.........: _WinAPI_CreateIconFromResourceEx ( $pData, $iSize [, $fIcon [, $xDesired [, $yDesired [, $iFlags]]]] )
; Parameters.....: $pData    - The icon or cursor resource bits. These bits are typically loaded by calls to the _WinAPI_LookupIconIdFromDirectoryEx()
;                              and _WinAPI_LoadResource() functions.
;                  $iSize    - The size, in bytes, of the set of bits pointed to by the $pData parameter.
;                  $fIcon    - Specifies whether an icon or a cursor is to be created, valid values:
;                  |TRUE     - An icon is to be created. (Default)
;                  |FALSE    - A cursor is to be created.
;                  $xDesired - The desired width, in pixels, of the icon or cursor. If this parameter is zero, the function uses the
;                              system metric value to set the width.
;                  $yDesired - The desired height, in pixels, of the icon or cursor. If this parameter is zero, the function uses the
;                              system metric value to set the height.
;                  $iFlags   - This parameter can be one or more of the following values.
;
;                              $LR_DEFAULTCOLOR
;                              $LR_DEFAULTSIZE
;                              $LR_MONOCHROME
;                              $LR_SHARED
;
; Return values..: Success   - Handle to the icon or cursor.
;                  Failure   - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: You should call _WinAPI_DestroyIcon() for icons created with _WinAPI_CreateIconFromResourceEx().
; Related........:
; Link...........: @@MsdnLink@@ CreateIconFromResourceEx
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_CreateIconFromResourceEx($pData, $iSize, $fIcon = 1, $xDesired = 0, $yDesired = 0, $iFlags = 0)

	Local $Ret = DllCall('user32.dll', 'ptr', 'CreateIconFromResourceEx', 'ptr', $pData, 'dword', $iSize, 'int', $fIcon, 'dword', 0x00030000, 'int', $xDesired, 'int', $yDesired, 'uint', $iFlags)

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_CreateIconFromResourceEx

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
;                  The application must continue to manage the original bitmaps and delete them by _WinAPI_DeleteObject() when they
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

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_CreateIconIndirect

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_CreateJobObject
; Description....: Creates or opens a job object.
; Syntax.........: _WinAPI_CreateJobObject ( [$sName [, $tSecurity] )
; Parameters.....: $sName     - The name of the job. Name comparison is case-sensitive. If this parameter is 0, the job is
;                               created without a name.
;                  $tSecurity - $tagSECURITY_ATTRIBUTES structure that specifies the security descriptor for the job object
;                               and determines whether child processes can inherit the returned handle. If this parameter is 0,
;                               the job object gets a default security descriptor and the handle cannot be inherited.
; Return values..: Success    - Handle to the job object. If the object existed before the function call, the function
;                               returns a handle to the existing job object.
;                  Failure    - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: When a job is created, its accounting information is initialized to zero, all limits are inactive, and there
;                  are no associated processes. To assign a process to a job object, use the _WinAPI_AssignProcessToJobObject()
;                  function. To set limits for a job, use the _WinAPI_SetInformationJobObject() function. To query accounting
;                  information, use the _WinAPI_QueryInformationJobObject() function.
;
;                  All processes associated with a job must run in the same session. A job is associated with the session of the
;                  first process to be assigned to the job.
;
;                  To close a job object handle, use the _WinAPI_CloseHandle() function. The job is destroyed when its last
;                  handle has been closed and all associated processes have exited.
; Related........:
; Link...........: @@MsdnLink@@ CreateJobObject
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_CreateJobObject($sName = '', $tSecurity = 0)

	Local $TypeOfName = 'wstr'

	If Not StringStripWS($sName, 3) Then
		$TypeOfName = 'ptr'
		$sName = 0
	EndIf

	Local $Ret = DllCall('kernel32.dll', 'int', 'CreateJobObjectW', 'ptr', $tSecurity, $TypeOfName, $sName)

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_CreateJobObject

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_CreateMRUList
; Description....: Creates a new most recently used (MRU) list.
; Syntax.........: _WinAPI_CreateMRUList ( $hKey, $sSubKey [, $iMax]] )
; Parameters.....: $hKey     - Handle to the currently open key, or one of the following predefined values under which to store the MRU data.
;
;                              $HKEY_CURRENT_USER
;                              $HKEY_LOCAL_MACHINE
;
;                  $sSubKey  - The subkey under which to store the MRU data.
;                  $iMax     - The maximum number of entries in the MRU list. Default is 26 (A..Z).
; Return values..: Success   - Handle to the new MRU list.
;                  Failure   - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ CreateMRUListW
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_CreateMRUList($hKey, $sSubKey, $iMax = 26)

	Local $tMRUINFO = DllStructCreate('dword;uint;uint;ulong_ptr;ptr;ptr')
	Local $tSubKey = DllStructCreate('wchar[' & (StringLen($sSubKey) + 1) & ']')

	DllStructSetData($tMRUINFO, 1, DllStructGetSize($tMRUINFO))
	DllStructSetData($tMRUINFO, 2, $iMax)
	DllStructSetData($tMRUINFO, 3, 0)
	DllStructSetData($tMRUINFO, 4, $hKey)
	DllStructSetData($tMRUINFO, 5, DllStructGetPtr($tSubKey))
	DllStructSetData($tMRUINFO, 6, 0)

	DllStructSetData($tSubKey, 1, $sSubKey)

	Local $Ret = DllCall('comctl32.dll ', 'int', 'CreateMRUListW', 'ptr', DllStructGetPtr($tMRUINFO))

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_CreateMRUList

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_CreateMutex
; Description....: Creates or opens a named or unnamed mutex object.
; Syntax.........: _WinAPI_CreateMutex ($sMutex [, $fInitial [, $tSecurity]] )
; Parameters.....: $sMutex    - The name of the mutex object. Name comparisons are case sensitive.
;                  $fInitial  - Specifies whether the calling process obtains the initial ownership of the mutex object, valid values:
;                  |TRUE      - The calling thread obtains initial ownership of the mutex object. (Default)
;                  |FALSE     - The calling thread does not obtain ownership of the mutex object.
;                  $tSecurity - $tagSECURITY_ATTRIBUTES structure that specifies a security descriptor for the new mutex. If this
;                               parameter is 0, the mutex gets a default security descriptor.
; Return values..: Success    - The handle to the newly created mutex object.
;                  Failure    - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: If the mutex is a named mutex and the object existed before this function call, the return value is a handle to
;                  the existing object, _WinAPI_GetLastError() returns ERROR_ALREADY_EXISTS, $fInitial is ignored, and the calling
;                  thread is not granted ownership. However, if the caller has limited access rights, the function will fail with
;                  ERROR_ACCESS_DENIED and the caller should use the _WinAPI_OpenMutex() function.
;
;                  Any process can specify the mutex-object handle in a call to one of the wait functions. The single-object wait
;                  functions return when the state of the specified object is signaled. The multiple-object wait functions can be
;                  instructed to return either when any one or when all of the specified objects are signaled. When a wait function
;                  returns, the waiting thread is released to continue its execution.
;
;                  Two or more processes can call _WinAPI_CreateMutex() to create the same named mutex. The first process actually
;                  creates the mutex, and subsequent processes with sufficient access rights simply open a handle to the existing
;                  mutex. This enables multiple processes to get handles of the same mutex, while relieving the user of the responsibility
;                  of ensuring that the creating process is started first. When using this technique, you should set the $fInitial
;                  parameter to FALSE; otherwise, it can be difficult to be certain which process has initial ownership.
;
;                  Use the _WinAPI_CloseHandle() function to close the handle. The system closes the handle automatically when the
;                  process terminates. The mutex object is destroyed when its last handle has been closed.
; Related........:
; Link...........: @@MsdnLink@@ CreateMutex
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_CreateMutex($sMutex, $fInitial = 1, $tSecurity = 0)

	Local $Ret = DllCall('kernel32.dll', 'ptr', 'CreateMutexW', 'ptr', DllStructGetPtr($tSecurity), 'int', $fInitial, 'wstr', $sMutex)

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_CreateMutex

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
; Remarks........: When you no longer need the HRGN object, call the _WinAPI_DeleteObject() function to delete it.
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
	$tData = DllStructCreate($Struct)
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

	If (@error) Or (Not $Ret[0]) Then
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
; Remarks........: When you no longer need the HRGN object, call the _WinAPI_DeleteObject() function to delete it.
; Related........:
; Link...........: @@MsdnLink@@ CreateRectRgnIndirect
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_CreateRectRgnIndirect($tRECT)

	Local $Ret = DllCall('gdi32.dll', 'ptr', 'CreateRectRgnIndirect', 'ptr', DllStructGetPtr($tRECT))

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_CreateRectRgnIndirect

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_CreateSemaphore
; Description....: Creates or opens a named or unnamed semaphore object.
; Syntax.........: _WinAPI_CreateSemaphore ( $sSemaphore, $iInitial, $iMaximum [, $tSecurity] )
; Parameters.....: $sSemaphore - The name of the semaphore to be opened. Name comparisons are case sensitive.
;                  $iInitial   - The initial count for the semaphore object. This value must be greater than or equal to zero and
;                                less than or equal to $iMaximum.
;                  $iMaximum   - The maximum count for the semaphore object. This value must be greater than zero.
;                  $tSecurity  - $tagSECURITY_ATTRIBUTES structure that specifies a security descriptor for the new semaphore.
;                                If this parameter is 0, the semaphore gets a default security descriptor.
; Return values..: Success     - The handle to the newly created semaphore object.
;                  Failure     - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: If the named semaphore object existed before the function call, the function returns a handle to the existing object.
;
;                  Any process can specify the semaphore-object handle in a call to _WinAPI_WaitFor... functions. The single-object
;                  wait functions return when the state of the specified object is signaled. The multiple-object wait functions can
;                  be instructed to return either when any one or when all of the specified objects are signaled. When a wait function
;                  returns, the waiting process is released to continue its execution.
;
;                  The state of a semaphore object is signaled when its count is greater than zero, and nonsignaled when its count
;                  is equal to zero. The $iInitial parameter specifies the initial count. Each time a waiting process is released
;                  because of the semaphore's signaled state, the count of the semaphore is decreased by one. Use the _WinAPI_ReleaseSemaphore()
;                  function to increment a semaphore's count by a specified amount. The count can never be less than zero or greater
;                  than the value specified in the $iMaximum parameter.
;
;                  Use the _WinAPI_CloseHandle() function to close the handle. The system closes the handle automatically when the
;                  process terminates. The semaphore object is destroyed when its last handle has been closed.
; Related........:
; Link...........: @@MsdnLink@@ CreateSemaphore
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_CreateSemaphore($sSemaphore, $iInitial, $iMaximum, $tSecurity = 0)

	Local $Ret = DllCall('kernel32.dll', 'ptr', 'CreateSemaphoreW', 'ptr', DllStructGetPtr($tSecurity), 'int', $iInitial, 'int', $iMaximum, 'wstr', $sSemaphore)

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_CreateSemaphore

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_CreateStreamOnHGlobal
; Description....: Creates a stream object that uses a memory handle to store the stream contents.
; Syntax.........: _WinAPI_CreateStreamOnHGlobal ( $hGlobal [, $fDeleteOnRelease] )
; Parameters.....: $hGlobal          - The memory handle, or if 0 a new handle is to be allocated instead. The handle must be
;                                      allocated as moveable and nondiscardable.
;                  $fDeleteOnRelease - Specifies whether the underlying handle for this stream object should be automatically
;                                      freed when the stream object is released, valid values:
;                  |TRUE             - The final release will automatically free the $hGlobal parameter. (Default)
;                  |FALSE            - The user must free the $hGlobal after the final release.
; Return values..: Success           - The pointer to the new stream object.
;                  Failure           - 0 and sets the @error flag to non-zero, @extended flag may contain the system error code.
; Author.........: Yashied
; Modified.......:
; Remarks........: If $hGlobal is 0, the function allocates a new memory handle and the stream is initially empty, otherwise, the
;                  initial contents of the stream are the current contents of the memory block. Thus, _WinAPI_CreateStreamOnHGlobal()
;                  can be used to open an existing stream in memory. The memory handle and its contents are undisturbed by the
;                  creation of the new stream object.
;
;                  After creating the stream object with _WinAPI_CreateStreamOnHGlobal(), call _WinAPI_GetHGlobalFromStream() to
;                  retrieve the memory handle associated with the stream object.
; Related........:
; Link...........: @@MsdnLink@@ CreateStreamOnHGlobal
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_CreateStreamOnHGlobal($hGlobal, $fDeleteOnRelease = 1)

	Local $Ret = DllCall('ole32.dll', 'uint', 'CreateStreamOnHGlobal', 'ptr', $hGlobal, 'int', $fDeleteOnRelease, 'ptr*', 0)

	If @error Then
		Return SetError(1, 0, 0)
	Else
		If $Ret[0] Then
			Return SetError(1, $Ret[0], 0)
		EndIf
	EndIf
	Return $Ret[3]
EndFunc   ;==>_WinAPI_CreateStreamOnHGlobal

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_DeferWindowPos
; Description....: Updates the specified multiple-window-position structure for the specified window.
; Syntax.........: _WinAPI_DeferWindowPos ( $hInfo, $hWnd, $hAfter, $iX, $iY, $iWidth, $iHeight, $iFlags )
; Parameters.....: $hInfo   - Handle to a multiple-window-position structure that contains size and position information for one
;                             or more windows. This structure is returned by _WinAPI_BeginDeferWindowPos() or by the most recent
;                             call to _WinAPI_DeferWindowPos().
;                  $hWnd    - Handle to the window for which update information is stored in the structure. All windows in a
;                             multiple-window-position structure must have the same parent.
;                  $hAfter  - Handle to the window that precedes the positioned window in the Z order. This parameter must be a
;                             window handle or one of the following values. This parameter is ignored if the $SWP_NOZORDER flag
;                             is set in the $iFlags parameter.
;
;                             $HWND_BOTTOM
;                             $HWND_NOTOPMOST
;                             $HWND_TOP
;                             $HWND_TOPMOST
;
;                  $iX      - The x-coordinate of the window's upper-left corner.
;                  $iY      - The y-coordinate of the window's upper-left corner.
;                  $iWidth  - The window's new width, in pixels.
;                  $iHeight - The window's new height, in pixels.
;                  $iFlags  - A combination of the following values that affect the size and position of the window.
;
;                             $SWP_DRAWFRAME
;                             $SWP_FRAMECHANGED
;                             $SWP_HIDEWINDOW
;                             $SWP_NOACTIVATE
;                             $SWP_NOCOPYBITS
;                             $SWP_NOMOVE
;                             $SWP_NOOWNERZORDER
;                             $SWP_NOREDRAW
;                             $SWP_NOREPOSITION
;                             $SWP_NOSENDCHANGING
;                             $SWP_NOSIZE
;                             $SWP_NOZORDER
;                             $SWP_SHOWWINDOW
;
; Return values..: Success  - The return value identifies the updated multiple-window-position structure.
;                  Failure  - 0 and sets the @error flag to non-zero.
; Author.........: KaFu
; Modified.......: Yashied
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ DeferWindowPos
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_DeferWindowPos($hInfo, $hWnd, $hAfter, $iX, $iY, $iWidth, $iHeight, $iFlags)

    Local $Ret = DllCall('user32.dll', 'ptr', 'DeferWindowPos', 'ptr', $hInfo, 'hwnd', $hWnd, 'hwnd', $hAfter, 'int', $iX, 'int', $iY, 'int', $iWidth, 'int', $iHeight, 'uint', $iFlags)

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_DeferWindowPos

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

	If Not StringStripWS($sPath, 3) Then
		$TypeOfPath = 'ptr'
		$sPath = 0
	EndIf

	Local $Ret = DllCall('kernel32.dll', 'int', 'DefineDosDeviceW', 'dword', $iFlags, 'wstr', $sDevice, $TypeOfPath, $sPath)

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_DefineDosDevice

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_DeleteEnhMetaFile
; Description....: Deletes an enhanced-format metafile or an enhanced-format metafile handle.
; Syntax.........: _WinAPI_DeleteEnhMetaFile ( $hEmf )
; Parameters.....: $hEmf   - Handle to an enhanced metafile.
; Return values..: Success - 1.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: If the $hEmf parameter identifies an enhanced metafile stored in memory, the _WinAPI_DeleteEnhMetaFile() function
;                  deletes the metafile. If $hEmf identifies a metafile stored on a disk, the function deletes the metafile handle but
;                  does not destroy the actual metafile. An application can retrieve the file by calling the _WinAPI_GetEnhMetaFile()
;                  function.
; Related........:
; Link...........: @@MsdnLink@@ DeleteEnhMetaFile
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_DeleteEnhMetaFile($hEmf)

	Local $Ret = DllCall('gdi32.dll', 'int', 'DeleteEnhMetaFile', 'ptr', $hEmf)

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_DeleteEnhMetaFile

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_DeleteFile
; Description....: Deletes an existing file.
; Syntax.........: _WinAPI_DeleteFile ( $sFile )
; Parameters.....: $sFile  - The name of the file to be deleted.
; Return values..: Success - 1.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ DeleteFile
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_DeleteFile($sFile)

	Local $Ret = DllCall('kernel32.dll', 'int', 'DeleteFileW', 'wstr', $sFile)

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_DeleteFile

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

	If (@error) Or (Not $Ret[0]) Then
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

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_DeregisterShellHookWindow

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_DestroyCaret
; Description....: Destroys the caret's current shape, frees the caret from the window, and removes the caret from the screen.
; Syntax.........: _WinAPI_DestroyCaret ( )
; Parameters.....: None
; Return values..: Success - 1.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: _WinAPI_DestroyCaret() destroys the caret only if a window in the current task owns the caret. If a window that
;                  is not in the current task owns the caret, _WinAPI_DestroyCaret() does nothing and returns 0.
;
;                  The window should destroy the caret before losing the keyboard focus or becoming inactive.
; Related........:
; Link...........: @@MsdnLink@@ DestroyCaret
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_DestroyCaret()

	Local $Ret = DllCall('user32.dll', 'int', 'DestroyCaret')

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_DestroyCaret

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_DestroyCursor
; Description....: Destroys a cursor and frees any memory the cursor occupied.
; Syntax.........: _WinAPI_DestroyCursor ( $hCursor )
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

Func _WinAPI_DestroyCursor($hCursor)

	Local $Ret = DllCall('user32.dll', 'int', 'DestroyCursor', 'ptr', $hCursor)

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_DestroyCursor

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_DeviceIoControl
; Description....: Sends a control code directly to a specified device driver.
; Syntax.........: _WinAPI_DeviceIoControl ( $hDevice, $iControlCode [, $pInBuffer [, $iInBufferSize [, $pOutBuffer [, $iOutBufferSize]]]] )
; Parameters.....: $hDevice        - Handle to the device on which the operation is to be performed. The device is typically a volume,
;                                    directory, file, or stream. To retrieve a device handle, use the _WinAPI_CreateFileEx function.
;                                    To specify a device name, use the following format:
;
;                                    _WinAPI_CreateFileEx("\\.\DeviceName", ...)
;
;                  $iControlCode   - The control code for the operation. This value identifies the specific operation to be performed
;                                    and the type of device on which to perform it.
;                  $pInBuffer      - A pointer to the input buffer that contains the data required to perform the operation.
;                  $iInBufferSize  - The size of the input buffer, in bytes.
;                  $pOutBuffer     - A pointer to the output buffer that is to receive the data returned by the operation.
;                  $iOutBufferSize - The size of the output buffer, in bytes.
; Return values..: Success - 1 and @extended flag contains the size of the data stored in the output buffer, in bytes.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ DeviceIoControl
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_DeviceIoControl($hDevice, $iControlCode, $pInBuffer = 0, $iInBufferSize = 0, $pOutBuffer = 0, $iOutBufferSize = 0)

	Local $Ret = DllCall('kernel32.dll', 'int', 'DeviceIoControl', 'ptr', $hDevice, 'dword', $iControlCode, 'ptr', $pInBuffer, 'dword', $iInBufferSize, 'ptr', $pOutBuffer, 'dword', $iOutBufferSize, 'dword*', 0, 'ptr', 0)

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return SetError(0, $Ret[7], 1)
EndFunc   ;==>_WinAPI_DeviceIoControl

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_DllGetVersion
; Description....: Retrieves a DLL-specific version information.
; Syntax.........: _WinAPI_DllGetVersion ( $sPath )
; Parameters.....: $sPath  - The path to the DLL file from which information is retrieved.
; Return values..: Success - The array containing the following information:
;
;                            [0] - The major version.
;                            [1] - The minor version.
;                            [2] - The build number.
;                            [3] - The platform for which the DLL was built ($DLLVER_PLATFORM_*).
;
;                  Failure - 0 and sets the @error flag to non-zero, @extended flag may contain the system error code.
; Author.........: Yashied
; Modified.......:
; Remarks........: This function is not an API. It is exported by name from each DLL that implements it. Currently, most of the Windows Shell
;                  and common controls DLLs implement DllGetVersion. These include, but are not limited to, shell32.dll, comctl32.dll,
;                  shdocvw.dll, and shlwapi.dll.
; Related........:
; Link...........: @@MsdnLink@@ DllGetVersion
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_DllGetVersion($sPath)

	Local $tVersion = DllStructCreate('dword[5]')

	DllStructSetData($tVersion, 1, DllStructGetSize($tVersion), 1)

	Local $Ret = DllCall($sPath, 'uint', 'DllGetVersion', 'ptr', DllStructGetPtr($tVersion))

	If @error Then
		Return SetError(@error, 0, 0)
	Else
		If $Ret[0] Then
			Return SetError(1, $Ret[0], 0)
		EndIf
	EndIf

	Local $Result[4]

	For $i = 0 To 3
		$Result[$i] = DllStructGetData($tVersion, 1, $i + 2)
	Next
	Return $Result
EndFunc   ;==>_WinAPI_DllGetVersion

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_DllInstall
; Description....: Registers OLE controls such as DLL or ActiveX Controls (OCX) files.
; Syntax.........: _WinAPI_DllInstall ( $sPath )
; Parameters.....: $sPath  - The path to the DLL file that will be registered.
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
; Parameters.....: $sPath  - The path to the DLL file that will be unregistered.
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
	DllCall('shell32.dll', 'none', 'DragAcceptFiles', 'hwnd', $hWnd, 'int', $fAccept)
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
	DllCall('shell32.dll', 'none', 'DragFinish', 'ptr', $hDrop)
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
; Return values..: Success - The array of the names of a dropped files. The zeroth array element contains the number of file names.
;                            If no files that satisfy the condition ($iFlag), the function fails.
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
	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	$Count = $Ret[0]
	ReDim $aData[$Count + 1]
	For $i = 0 To $Count - 1
		$tData = DllStructCreate('wchar[1024]')
		$Ret = DllCall('shell32.dll', 'int', 'DragQueryFileW', 'ptr', $hDrop, 'uint', $i, 'ptr', DllStructGetPtr($tData), 'uint', 1024)
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
	If Not $aData[0] Then
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

	If (@error) Or (Not $Ret[0]) Then
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

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_DrawAnimatedRects

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_DrawBitmap
; Description....: Draws a bitmap into the specified device context.
; Syntax.........: _WinAPI_DrawBitmap ( $hDC, $iX, $iY, $hBitmap [, $iRop] )
; Parameters.....: $hDC     - Handle to the device context into which the bitmap will be drawn.
;                  $iX      - Specifies the logical x-coordinate of the upper-left corner of the bitmap.
;                  $iY      - Specifies the logical y-coordinate of the upper-left corner of the bitmap.
;                  $hBitmap - Handle to the bitmap to be drawn.
;                  $iRop    - The raster-operation code (same as for _WinAPI_BitBlt()).
; Return values..: Success  - 1.
;                  Failure  - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: This function does not support bitmaps with Alpha channel, use _WinAPI_AlphaBlend() to work with them.
; Related........:
; Link...........: None
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_DrawBitmap($hDC, $iX, $iY, $hBitmap, $iRop = 0x00CC0020)

	Local $Ret, $tObj, $_hDC, $hSrcDC, $hSrcSv

    $tObj = DllStructCreate($tagBITMAP)
	$Ret = DllCall('gdi32.dll', 'int', 'GetObject', 'int', $hBitmap, 'int', DllStructGetSize($tObj), 'ptr', DllStructGetPtr($tObj))
	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	$Ret = DllCall('user32.dll', 'hwnd', 'GetDC', 'hwnd', 0)
	$_hDC = $Ret[0]
	$Ret = DllCall('gdi32.dll', 'hwnd', 'CreateCompatibleDC', 'hwnd', $_hDC)
	$hSrcDC = $Ret[0]
	$Ret = DllCall('gdi32.dll', 'hwnd', 'SelectObject', 'hwnd', $hSrcDC, 'ptr', $hBitmap)
	$hSrcSv = $Ret[0]
	$Ret = DllCall('gdi32.dll', 'int', 'BitBlt', 'hwnd', $hDC, 'int', $iX, 'int', $iY, 'int', DllStructGetData($tObj, 'bmWidth'), 'int', DllStructGetData($tObj, 'bmHeight'), 'hwnd', $hSrcDC, 'int', 0, 'int', 0, 'int', $iRop)
	If (@error) Or (Not $Ret[0]) Then
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
;                               the formatting text constants ($DT_*).
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
		If (@error) Or (Not $Ret[0]) Then
			Return SetError(1, 0, 0)
		EndIf
	EndIf
	$Ret = DllCall('comctl32.dll', 'int', 'DrawShadowText', 'hwnd', $hDC, 'wstr', $sText, 'uint', -1, 'ptr', DllStructGetPtr($tRECT), 'dword', $iFlags, 'int', __RGB($rgbText), 'int', __RGB($rgbShadow), 'int', $iXOffset, 'int', $iYOffset)
	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_DrawShadowText

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_DrawThemeBackground
; Description....: Draws the border and fill defined by the visual style for the specified control part.
; Syntax.........: _WinAPI_DrawThemeBackground ( $hTheme, $iPartId, $iStateId, $hDC, $tRECT [, $tCLIP] )
; Parameters.....: $hTheme   - Handle to a window's specified theme data.
;                  $iPartId  - The part to draw.
;                  $iStateId - The state of the part to draw.
;                  $hDC      - Handle to the device context for drawing the theme-defined background image.
;                  $tRECT    - $tagRECT structure that contains the rectangle in which the background image is drawn.
;                  $tCLIP    - $tagRECT structure that contains a clipping rectangle.
; Return values..: Success   - 1.
;                  Failure   - 0 and sets the @error flag to non-zero, @extended flag may contain the system error code.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ DrawThemeBackground
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_DrawThemeBackground($hTheme, $iPartId, $iStateId, $hDC, $tRECT, $tCLIP = 0)

	Local $Ret = DllCall('uxtheme.dll', 'uint', 'DrawThemeBackground', 'ptr', $hTheme, 'hwnd', $hDC, 'int', $iPartId, 'int', $iStateId, 'ptr', DllStructGetPtr($tRECT), 'ptr', DllStructGetPtr($tCLIP))

	If @error Then
		Return SetError(1, 0, 0)
	Else
		If $Ret[0] Then
			Return SetError(1, $Ret[0], 0)
		EndIf
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_DrawThemeBackground

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_DrawThemeParentBackground
; Description....: Draws the part of a parent control that is covered by a partially-transparent or alpha-blended child control.
; Syntax.........: _WinAPI_DrawThemeParentBackground ( $hWnd, $hDC [, $tRECT] )
; Parameters.....: $hWnd   - Handle of the child control.
;                  $hDC    - Handle to the child control's DC.
;                  $tRECT  - $tagRECT structure that defines the area, in the child window's coordinates, to be drawn.
; Return values..: Success - 1.
;                  Failure - 0 and sets the @error flag to non-zero, @extended flag may contain the system error code.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ DrawThemeParentBackground
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_DrawThemeParentBackground($hWnd, $hDC, $tRECT = 0)

	Local $Ret = DllCall('uxtheme.dll', 'uint', 'DrawThemeParentBackground', 'hwnd', $hWnd, 'hwnd', $hDC, 'ptr', DllStructGetPtr($tRECT))

	If @error Then
		Return SetError(1, 0, 0)
	Else
		If $Ret[0] Then
			Return SetError(1, $Ret[0], 0)
		EndIf
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_DrawThemeParentBackground

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_DrawThemeText
; Description....: Draws text using the color and font defined by the visual style.
; Syntax.........: _WinAPI_DrawThemeText ( $hTheme, $iPartId, $iStateId, $hDC, $sText, $tRECT, $iFlags )
; Parameters.....: $hTheme   - Handle to a window's specified theme data.
;                  $iPartId  - The part that has the desired text appearance. If this value is 0, the text is drawn in the
;                              default font, or a font selected into the device context.
;                  $iStateId - The state that has the desired text appearance.
;                  $hDC      - Handle to the device context to use for drawing.
;                  $sText    - The string that contains the text to draw.
;                  $tRECT    - $tagRECT structure that contains the rectangle in which the text is to be drawn.
;                  $iFlags   - The string's formatting flags. This parameter can be one or more of the $DT_* values.
; Return values..: Success   - 1.
;                  Failure   - 0 and sets the @error flag to non-zero, @extended flag may contain the system error code.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ DrawThemeText
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_DrawThemeText($hTheme, $iPartId, $iStateId, $hDC, $sText, $tRECT, $iFlags)

	Local $Ret = DllCall('uxtheme.dll', 'uint', 'DrawThemeText', 'ptr', $hTheme, 'hwnd', $hDC, 'int', $iPartId, 'int', $iStateId, 'wstr', $sText, 'int', -1, 'dword', $iFlags, 'dword', 0, 'ptr', DllStructGetPtr($tRECT))

	If @error Then
		Return SetError(1, 0, 0)
	Else
		If $Ret[0] Then
			Return SetError(1, $Ret[0], 0)
		EndIf
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_DrawThemeText

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_DrawThemeTextEx
; Description....: Draws text using the color and font defined by the visual style.
; Syntax.........: _WinAPI_DrawThemeTextEx ( $hTheme, $iPartId, $iStateId, $hDC, $sText, $tRECT, $iFlags, $tDTTOPTS )
; Parameters.....: $hTheme   - Handle to a window's specified theme data.
;                  $iPartId  - The part that has the desired text appearance. If this value is 0, the text is drawn in the
;                              default font, or a font selected into the device context.
;                  $iStateId - The state that has the desired text appearance.
;                  $hDC      - Handle to the device context to use for drawing.
;                  $sText    - The string that contains the text to draw.
;                  $tRECT    - $tagRECT structure that contains the rectangle in which the text is to be drawn.
;                  $iFlags   - The string's formatting flags. This parameter can be one or more of the $DT_* values.
;                  $tDTTOPTS - $tagDTTOPTS structure that defines additional formatting options.
; Return values..: Success   - 1.
;                  Failure   - 0 and sets the @error flag to non-zero, @extended flag may contain the system error code.
; Author.........: Yashied
; Modified.......:
; Remarks........: This function requires Windows Vista or later.
; Related........:
; Link...........: @@MsdnLink@@ DrawThemeTextEx
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_DrawThemeTextEx($hTheme, $iPartId, $iStateId, $hDC, $sText, $tRECT, $iFlags, $tDTTOPTS)

	Local $Ret = DllCall('uxtheme.dll', 'uint', 'DrawThemeTextEx', 'ptr', $hTheme, 'hwnd', $hDC, 'int', $iPartId, 'int', $iStateId, 'wstr', $sText, 'int', -1, 'dword', $iFlags, 'ptr', DllStructGetPtr($tRECT), 'ptr', DllStructGetPtr($tDTTOPTS))

	If @error Then
		Return SetError(1, 0, 0)
	Else
		If $Ret[0] Then
			Return SetError(1, $Ret[0], 0)
		EndIf
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_DrawThemeTextEx

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_DuplicateHandle
; Description....: Duplicates an object handle.
; Syntax.........: _WinAPI_DuplicateHandle ( $hProcess, $hSource, $hTarget [, $iAccess [, $iOptions [, $fInherit]]] )
; Parameters.....: $hProcess - Handle to the process with the handle to be duplicated. The handle must have the $PROCESS_DUP_HANDLE access right.
;                  $hSource  - Handle to be duplicated. This is an open object handle that is valid in the context of the source process.
;                  $hTarget  - Handle to the process that is to receive the duplicated handle. The handle must have the
;                              $PROCESS_DUP_HANDLE access right.
;                  $iAccess  - The access requested for the new handle.
;                  $iOptions - Optional actions. This parameter can be zero, or any combination of the following values.
;
;                              $DUPLICATE_CLOSE_SOURCE
;                              $DUPLICATE_SAME_ACCESS
;
;                  $fInherit - Specifies whether the handle is inheritable, valid values:
;                  |TRUE     - The duplicate handle can be inherited by new processes created by the target process.
;                  |FALSE    - The new handle cannot be inherited. (Default)
; Return values..: Success   - The duplicate handle. This handle is valid in the context of the target process.
;                  Failure   - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: The duplicate handle refers to the same object as the original handle. Therefore, any changes to the object are
;                  reflected through both handles. For example, if you duplicate a file handle, the current file position is always
;                  the same for both handles. For file handles to have different file positions, use the _WinAPI_CreateFile()
;                  function to create file handles that share access to the same file.
; Related........:
; Link...........: @@MsdnLink@@ DuplicateHandle
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_DuplicateHandle($hProcess, $hSource, $hTarget, $iAccess = 0, $iOptions = 2, $fInherit = 0)

	Local $Ret = DllCall('kernel32.dll', 'int', 'DuplicateHandle', 'ptr', $hProcess, 'ptr', $hSource, 'ptr', $hTarget, 'ptr*', 0, 'dword', $iAccess, 'int', $fInherit, 'dword', $iOptions)

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[4]
EndFunc   ;==>_WinAPI_DuplicateHandle

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_DwmEnableBlurBehindWindow
; Description....: Enables the blur effect on a specified window.
; Syntax.........: _WinAPI_DwmEnableBlurBehindWindow ( $hWnd [, $fEnable [, $fTransition [, $hRgn]]] )
; Parameters.....: $hWnd        - Handle to the window on which the blur behind data is applied.
;                  $fEnable     - Specifies whether register or unregister the window handle to DWM blur behind, valid values:
;                  |TRUE        - Register.
;                  |FALSE       - Unregister.
;                  $fTransition - Specifies whether colorize transition to match the maximized windows, valid values:
;                  |TRUE        - The window's should be colorized.
;                  |FALSE       - Otherwise.
;                  $hRgn        - The region within the client area to apply the blur behind. A zeroth value will apply the blur
;                                 behind the entire client area.
; Return values..: Success      - 1.
;                  Failure      - 0 and sets the @error flag to non-zero, @extended flag may contain the system error code.
; Author.........: Yashied
; Modified.......:
; Remarks........: The alpha values in the window are honored and the rendering atop the blur will use these alpha values.
;                  It is the application's responsibility for ensuring that the alpha values of all pixels in the window are correct.
;                  Some Windows Graphics Device Interface (GDI) operations do not preserve alpha values, so care must be taken when
;                  presenting child windows because the alpha values they contribute are unpredictable.
;
;                  This function must be called whenever Desktop Window Manager (DWM) composition is toggled. Handle the
;                  WM_DWMCOMPOSITIONCHANGED message for composition change notification.
;
;                  This function requires Windows Vista or later.
; Related........:
; Link...........: @@MsdnLink@@ DwmEnableBlurBehindWindow
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_DwmEnableBlurBehindWindow($hWnd, $fEnable = 1, $fTransition = 0, $hRgn = 0)

	Local $tBLURBEHIND = DllStructCreate('dword;int;ptr;int')
	Local $Flags = 0

	If $hRgn Then
		$Flags += 2
		DllStructSetData($tBLURBEHIND, 3, $hRgn)
	EndIf

	DllStructSetData($tBLURBEHIND, 1, BitOR($Flags, 0x05))
	DllStructSetData($tBLURBEHIND, 2, $fEnable)
	DllStructSetData($tBLURBEHIND, 4, $fTransition)

	Local $Ret = DllCall('dwmapi.dll', 'uint', 'DwmEnableBlurBehindWindow', 'hwnd', $hWnd, 'ptr', DllStructGetPtr($tBLURBEHIND))

	If @error Then
		Return SetError(1, 0, 0)
	Else
		If $Ret[0] Then
			Return SetError(1, $Ret[0], 0)
		EndIf
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_DwmEnableBlurBehindWindow

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_DwmEnableComposition
; Description....: Enables or disables Desktop Window Manager (DWM) composition.
; Syntax.........: _WinAPI_DwmEnableComposition ( $fEnable )
; Parameters.....: $fEnable  - Specifies whether enable or disable DWM composition, valid values:
;                  |TRUE     - Enable.
;                  |FALSE    - Disable.
; Return values..: Success   - 1.
;                  Failure   - 0 and sets the @error flag to non-zero, @extended flag may contain the system error code.
; Author.........: Yashied
; Modified.......:
; Remarks........: Disabling DWM composition disables it for the entire desktop. DWM composition will be automatically enabled
;                  when all processes that have disabled composition have called _WinAPI_DwmEnableComposition() to enable it or have
;                  been terminated. The WM_DWMCOMPOSITIONCHANGED notification is sent when DWM composition has enabled or disabled.
;
;                  This function requires Windows Vista or later.
; Related........:
; Link...........: @@MsdnLink@@ DwmEnableComposition
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_DwmEnableComposition($fEnable)

	If $fEnable Then
		$fEnable = 1
	EndIf

	Local $Ret = DllCall('dwmapi.dll', 'uint', 'DwmEnableComposition', 'uint', $fEnable)

	If @error Then
		Return SetError(1, 0, 0)
	Else
		If $Ret[0] Then
			Return SetError(1, $Ret[0], 0)
		EndIf
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_DwmEnableComposition

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_DwmGetColorizationColor
; Description....: Retrieves the current color used for Desktop Window Manager (DWM) glass composition.
; Syntax.........: _WinAPI_DwmGetColorizationColor ( )
; Parameters.....: None
; Return values..: Success - The current color (0xAARRGGBB) used for glass composition, @extended flag indicates whether the
;                            color is an opaque blend:
;                            1 - The color is an opaque blend.
;                            0 - Otherwise.
;                  Failure - 0 and sets the @error flag to non-zero, @extended flag may contain the system error code.
; Author.........: Yashied
; Modified.......:
; Remarks........: This function requires Windows Vista or later.
; Related........:
; Link...........: @@MsdnLink@@ DwmGetColorizationColor
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_DwmGetColorizationColor()

	Local $Ret = DllCall('dwmapi.dll', 'uint', 'DwmGetColorizationColor', 'dword*', 0, 'int*', 0)

	If @error Then
		Return SetError(1, 0, 0)
	Else
		If $Ret[0] Then
			Return SetError(1, $Ret[0], 0)
		EndIf
	EndIf
	Return SetError(0, $Ret[2], $Ret[1])
EndFunc   ;==>_WinAPI_DwmGetColorizationColor

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_DwmGetWindowAttribute
; Description....: Retrieves the current value of a specified attribute applied to the window.
; Syntax.........: _WinAPI_DwmGetWindowAttribute ( $hWnd, $iAttribute )
; Parameters.....: $hWnd       - Handle to the window for which the attribute data is retrieved.
;                  $iAttribute - The attribute to retrieve. This parameter can be one of the following values.
;
;                                $DWMWA_NCRENDERING_ENABLED
;                                $DWMWA_CAPTION_BUTTON_BOUNDS
;                                $DWMWA_EXTENDED_FRAME_BOUNDS
;
; Return values..: Success     - The value that contains the current value of the attribute. The type of the returned value depends
;                                on the value of the $iAttribute parameter.
;                  Failure     - 0 and sets the @error flag to non-zero, @extended flag may contain the system error code.
; Author.........: Yashied
; Modified.......:
; Remarks........: This function requires Windows Vista or later.
; Related........:
; Link...........: @@MsdnLink@@ DwmGetWindowAttribute
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_DwmGetWindowAttribute($hWnd, $iAttribute)

	Local $Struct

	Switch $iAttribute
		Case $DWMWA_CAPTION_BUTTON_BOUNDS, $DWMWA_EXTENDED_FRAME_BOUNDS
			$Struct = $tagRECT
		Case $DWMWA_NCRENDERING_ENABLED
			$Struct = 'uint'
		Case Else
			Return SetError(1, 0, 0)
	EndSwitch

	Local $tData = DllStructCreate($Struct)
	Local $Ret = DllCall('dwmapi.dll', 'uint', 'DwmGetWindowAttribute', 'hwnd', $hWnd, 'dword', $iAttribute, 'ptr', DllStructGetPtr($tData), 'dword', DllStructGetSize($tData))

	If @error Then
		Return SetError(1, 0, 0)
	Else
		If $Ret[0] Then
			Return SetError(1, $Ret[0], 0)
		EndIf
	EndIf
	Switch $iAttribute
		Case $DWMWA_NCRENDERING_ENABLED
			Return DllStructGetData($tData, 1)
		Case Else
			Return $tData
	EndSwitch
EndFunc   ;==>_WinAPI_DwmGetWindowAttribute

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_DwmExtendFrameIntoClientArea
; Description....: Extends the window frame behind the client area.
; Syntax.........: _WinAPI_DwmExtendFrameIntoClientArea ( $hWnd [, $tMARGINS] )
; Parameters.....: $hWnd     - Handle to the window for which the frame is extended into the client area.
;                  $tMARGINS - $tagMARGINS structure that describes the margins to use when extending the frame into the client area.
;                              Negative margins are used to create the "sheet of glass" effect where the client area is rendered as
;                              a solid surface with no window border.
; Return values..: Success   - 1.
;                  Failure   - 0 and sets the @error flag to non-zero, @extended flag may contain the system error code.
; Author.........: Yashied
; Modified.......:
; Remarks........: This function must be called whenever Desktop Window Manager (DWM) composition is toggled. Handle the
;                  WM_DWMCOMPOSITIONCHANGED message for composition change notification.
;
;                  This function requires Windows Vista or later.
; Related........:
; Link...........: @@MsdnLink@@ DwmExtendFrameIntoClientArea
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_DwmExtendFrameIntoClientArea($hWnd, $tMARGINS = 0)

	If Not IsDllStruct($tMARGINS) Then
		$tMARGINS = DllStructCreate('int;int;int;int')
		For $i = 1 To 4
			DllStructSetData($tMARGINS, $i, -1)
		Next
	EndIf

	Local $Ret = DllCall('dwmapi.dll', 'uint', 'DwmExtendFrameIntoClientArea', 'hwnd', $hWnd, 'ptr', DllStructGetPtr($tMARGINS))

	If @error Then
		Return SetError(1, 0, 0)
	Else
		If $Ret[0] Then
			Return SetError(1, $Ret[0], 0)
		EndIf
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_DwmExtendFrameIntoClientArea

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_DwmIsCompositionEnabled
; Description....: Determines whether Desktop Window Manager (DWM) composition is enabled.
; Syntax.........: _WinAPI_DwmIsCompositionEnabled ( )
; Parameters.....: None
; Return values..: Success - 1 - DWM composition is enabled.
;                            0 - Otherwise.
;                  Failure - 0 and sets the @error flag to non-zero, @extended flag may contain the system error code.
; Author.........: Yashied
; Modified.......:
; Remarks........: This function requires Windows Vista or later.
; Related........:
; Link...........: @@MsdnLink@@ DwmIsCompositionEnabled
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_DwmIsCompositionEnabled()

	Local $Ret = DllCall('dwmapi.dll', 'uint', 'DwmIsCompositionEnabled', 'int*', 0)

	If @error Then
		Return SetError(1, 0, 0)
	Else
		If $Ret[0] Then
			Return SetError(1, $Ret[0], 0)
		EndIf
	EndIf
	Return $Ret[1]
EndFunc   ;==>_WinAPI_DwmIsCompositionEnabled

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_DwmQueryThumbnailSourceSize
; Description....: Returns the source size of the Desktop Window Manager (DWM) thumbnail.
; Syntax.........: _WinAPI_DwmUnregisterThumbnail ( $hThumbnail )
; Parameters.....: $hThumbnail - Handle of the thumbnail to retrieve the source window size from.
; Return values..: Success     - $tagSIZE structure that contains the size of the source thumbnail.
;                  Failure     - 0 and sets the @error flag to non-zero, @extended flag may contain the system error code.
; Author.........: Yashied
; Modified.......:
; Remarks........: This function requires Windows Vista or later.
; Related........:
; Link...........: @@MsdnLink@@ DwmQueryThumbnailSourceSize
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_DwmQueryThumbnailSourceSize($hThumbnail)

	Local $tSIZE = DllStructCreate($tagSIZE)
	Local $Ret = DllCall('dwmapi.dll', 'uint', 'DwmQueryThumbnailSourceSize', 'ptr', $hThumbnail, 'ptr', DllStructGetPtr($tSIZE))

	If @error Then
		Return SetError(1, 0, 0)
	Else
		If $Ret[0] Then
			Return SetError(1, $Ret[0], 0)
		EndIf
	EndIf
	Return $tSIZE
EndFunc   ;==>_WinAPI_DwmQueryThumbnailSourceSize

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_DwmRegisterThumbnail
; Description....: Creates a Desktop Window Manager (DWM) thumbnail relationship between the destination and source windows.
; Syntax.........: _WinAPI_DwmRegisterThumbnail ( $hDestination, $hSource )
; Parameters.....: $hDestination - Handle to the window that will use the DWM thumbnail.
;                  $hSource      - Handle to the window to use as the thumbnail source.
; Return values..: Success       - Handle that represents the registration of the DWM thumbnail.
;                  Failure       - 0 and sets the @error flag to non-zero, @extended flag may contain the system error code.
; Author.........: Yashied
; Modified.......:
; Remarks........: The window designated by $hDestination must either be the desktop window itself or be owned by the process that
;                  is calling _WinAPI_DwmRegisterThumbnail().
;
;                  This function requires Windows Vista or later.
; Related........:
; Link...........: @@MsdnLink@@ DwmRegisterThumbnail
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_DwmRegisterThumbnail($hDestination, $hSource)

	Local $Ret = DllCall('dwmapi.dll', 'uint', 'DwmRegisterThumbnail', 'hwnd', $hDestination, 'hwnd', $hSource, 'ptr*', 0)

	If @error Then
		Return SetError(1, 0, 0)
	Else
		If $Ret[0] Then
			Return SetError(1, $Ret[0], 0)
		EndIf
	EndIf
	Return $Ret[3]
EndFunc   ;==>_WinAPI_DwmRegisterThumbnail

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_DwmSetWindowAttribute
; Description....: Sets the value of the specified attributes for non-client rendering to apply to the window.
; Syntax.........: _WinAPI_DwmSetWindowAttribute ( $hWnd, $iAttribute, $iData )
; Parameters.....: $hWnd       - The window handle to apply the given attribute.
;                  $iAttribute - The attribute to apply to the window. This parameter can be one of the following values.
;
;                                $DWMWA_NCRENDERING_POLICY
;                                $DWMWA_TRANSITIONS_FORCEDISABLED
;                                $DWMWA_ALLOW_NCPAINT
;                                $DWMWA_NONCLIENT_RTL_LAYOUT
;                                $DWMWA_FORCE_ICONIC_REPRESENTATION
;                                $DWMWA_FLIP3D_POLICY
;
;                                *Windows 7 or later
;
;                                $DWMWA_HAS_ICONIC_BITMAP
;                                $DWMWA_DISALLOW_PEEK
;                                $DWMWA_EXCLUDED_FROM_PEEK
;
;                  $iData      - The value of the attribute.
; Return values..: Success     - 1.
;                  Failure     - 0 and sets the @error flag to non-zero, @extended flag may contain the system error code.
; Author.........: Yashied
; Modified.......:
; Remarks........: This function requires Windows Vista or later.
; Related........:
; Link...........: @@MsdnLink@@ DwmSetWindowAttribute
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_DwmSetWindowAttribute($hWnd, $iAttribute, $iData)
	Switch $iAttribute
		Case $DWMWA_NCRENDERING_POLICY, $DWMWA_TRANSITIONS_FORCEDISABLED, $DWMWA_ALLOW_NCPAINT, $DWMWA_NONCLIENT_RTL_LAYOUT, $DWMWA_FORCE_ICONIC_REPRESENTATION, $DWMWA_FLIP3D_POLICY, $DWMWA_HAS_ICONIC_BITMAP, $DWMWA_DISALLOW_PEEK, $DWMWA_EXCLUDED_FROM_PEEK

		Case Else
			Return SetError(1, 0, 0)
	EndSwitch

	Local $tData = DllStructCreate('uint')

	DllStructSetData($tData, 1, $iData)
	If @error Then
		Return SetError(1, 0, 0)
	EndIf

	Local $Ret = DllCall('dwmapi.dll', 'uint', 'DwmSetWindowAttribute', 'hwnd', $hWnd, 'dword', $iAttribute, 'ptr', DllStructGetPtr($tData), 'dword', DllStructGetSize($tData))

	If @error Then
		Return SetError(1, 0, 0)
	Else
		If $Ret[0] Then
			Return SetError(1, $Ret[0], 0)
		EndIf
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_DwmSetWindowAttribute

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_DwmUnregisterThumbnail
; Description....: Removes a Desktop Window Manager (DWM) thumbnail relationship.
; Syntax.........: _WinAPI_DwmUnregisterThumbnail ( $hThumbnail )
; Parameters.....: $hThumbnail - Handle to the thumbnail relationship to be removed.
; Return values..: Success     - 1.
;                  Failure     - 0 and sets the @error flag to non-zero, @extended flag may contain the system error code.
; Author.........: Yashied
; Modified.......:
; Remarks........: This function requires Windows Vista or later.
; Related........:
; Link...........: @@MsdnLink@@ DwmUnregisterThumbnail
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_DwmUnregisterThumbnail($hThumbnail)

	Local $Ret = DllCall('dwmapi.dll', 'uint', 'DwmUnregisterThumbnail', 'ptr', $hThumbnail)

	If @error Then
		Return SetError(1, 0, 0)
	Else
		If $Ret[0] Then
			Return SetError(1, $Ret[0], 0)
		EndIf
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_DwmUnregisterThumbnail

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_DwmUpdateThumbnailProperties
; Description....: Specifies Desktop Window Manager (DWM) thumbnail properties.
; Syntax.........: _WinAPI_DwmUpdateThumbnailProperties ( $hThumbnail [, $fVisible [, $fClientAreaOnly [, $iOpacity [, $tRectDest [, $tRectSrc]]]]] )
; Parameters.....: $hThumbnail      - Handle of the thumbnail to retrieve the source window size from.
;                  $fVisible        - Specifies whether make the thumbnail visible or invisible, valid values:
;                  |TRUE            - Visible.
;                  |FALSE           - Invisible.
;                  $fClientAreaOnly - Specifies whether use only the thumbnail source's client area or entire window, valid values:
;                  |TRUE            - Use only source's client area.
;                  |FALSE           - Use entire window.
;                  $iOpacity        - The opacity with which to render the thumbnail. 0 is fully transparent while 255 is fully opaque.
;                  $tRectDest       - $tagRECT structure containing the rectangle in the destination window the thumbnail will be
;                                     rendered. By default, the size of this rectangle equal to the source size of the DWM thumbnail
;                                     which returns the _WinAPI_DwmQueryThumbnailSourceSize() function.
;                  $tRectSrc        - $tagRECT structure containing the rectangle that specifies the region of the source window
;                                     to use as the thumbnail. By default, the entire window is used as the thumbnail.
; Return values..: Success          - 1.
;                  Failure          - 0 and sets the @error flag to non-zero, @extended flag may contain the system error code.
; Author.........: Yashied
; Modified.......:
; Remarks........: Thumbnail relationships created by _WinAPI_DwmRegisterThumbnail() will not be rendered to the destination window
;                  until this function is called. Subsequent calls will update the thumbnail according to the properties.
;
;                  This function requires Windows Vista or later.
; Related........:
; Link...........: @@MsdnLink@@ DwmUpdateThumbnailProperties
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_DwmUpdateThumbnailProperties($hThumbnail, $fVisible = 1, $fClientAreaOnly = 0, $iOpacity = 255, $tRectDest = 0, $tRectSrc = 0)

	Local $tTHUMBNAIL = DllStructCreate('dword;int[4];int[4];byte;int;int')
	Local $tSIZE, $Flags = 0

	If Not IsDllStruct($tRectDest) Then
		$tSIZE = _WinAPI_DwmQueryThumbnailSourceSize($hThumbnail)
		If @error Then
			Return SetError(1, 0, 0)
		EndIf
		$tRectDest = _WinAPI_CreateRectEx(0, 0, DllStructGetData($tSIZE, 1), DllStructGetData($tSIZE, 2))
	EndIf
	For $i = 1 To 4
		DllStructSetData($tTHUMBNAIL, 2, DllStructGetData($tRectDest, $i), $i)
	Next
	If IsDllStruct($tRectSrc) Then
		$Flags += 2
		For $i = 1 To 4
			DllStructSetData($tTHUMBNAIL, 3, DllStructGetData($tRectSrc, $i), $i)
		Next
	EndIf

	DllStructSetData($tTHUMBNAIL, 1, BitOR($Flags, 0x1D))
	DllStructSetData($tTHUMBNAIL, 4, $iOpacity)
	DllStructSetData($tTHUMBNAIL, 5, $fVisible)
	DllStructSetData($tTHUMBNAIL, 6, $fClientAreaOnly)

	Local $Ret = DllCall('dwmapi.dll', 'uint', 'DwmUpdateThumbnailProperties', 'ptr', $hThumbnail, 'ptr', DllStructGetPtr($tTHUMBNAIL))

	If @error Then
		Return SetError(1, 0, 0)
	Else
		If $Ret[0] Then
			Return SetError(1, $Ret[0], 0)
		EndIf
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_DwmUpdateThumbnailProperties

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_DWordToInt
; Description....: Converts a value of type DWORD to a value of type INT.
; Syntax.........: _WinAPI_DWordToInt ( $iValue )
; Parameters.....: $iValue - The value to be converted.
; Return values..: The converted (INT) value.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: None
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_DWordToInt($iValue)

	Local $tData = DllStructCreate('int')

	DllStructSetData($tData, 1, $iValue)

	Return DllStructGetData($tData, 1)
EndFunc   ;==>_WinAPI_DWordToInt

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_EjectMedia
; Description....: Ejects media from a device.
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

	Local $hFile = _WinAPI_CreateFileEx('\\.\' & $sDrive, 3, 0x80000000, 0x01)

	If Not $hFile Then
		Return SetError(1, 0, 0)
	EndIf

	Local $Ret = DllCall('kernel32.dll', 'int', 'DeviceIoControl', 'ptr', $hFile, 'dword', $IOCTL_STORAGE_EJECT_MEDIA, 'ptr', 0, 'dword', 0, 'ptr', 0, 'dword', 0, 'dword*', 0, 'ptr', 0)

	If (@error) Or (Not $Ret[0]) Then
		$Ret = 0
	EndIf
	_WinAPI_CloseHandle($hFile)
	If Not IsArray($Ret) Then
		Return SetError(2, 0, 0)
	EndIf
	Return 1
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

	If (@error) Or (Not $Ret[0]) Then
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

	Local $hProcess = DllCall('kernel32.dll', 'ptr', 'OpenProcess', 'dword', 0x001F0FFF, 'int', 0, 'dword', $PID)

	If (@error) Or (Not $hProcess[0]) Then
		Return SetError(1, 0, 0)
	EndIf

	Local $Ret = DllCall(@SystemDir & '\psapi.dll', 'int', 'EmptyWorkingSet', 'ptr', $hProcess[0])

	If (@error) Or (Not $Ret[0]) Then
		$Ret = 0
	EndIf
	_WinAPI_CloseHandle($hProcess[0])
	If Not IsArray($Ret) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_EmptyWorkingSet

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_EndDeferWindowPos
; Description....: Simultaneously updates the position and size of one or more windows in a single screen-refreshing cycle.
; Syntax.........: _WinAPI_EndDeferWindowPos ( $hInfo )
; Parameters.....: $hInfo  - Handle to a multiple-window-position structure that contains size and position information for one or
;                            more windows. This internal structure is returned by the _WinAPI_BeginDeferWindowPos() function or by
;                            the most recent call to the _WinAPI_DeferWindowPos() function.
; Return values..: Success - 1.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: KaFu
; Modified.......: Yashied
; Remarks........: The _WinAPI_EndDeferWindowPos() function sends the WM_WINDOWPOSCHANGING and WM_WINDOWPOSCHANGED messages to
;                  each window identified in the internal structure.
; Related........:
; Link...........: @@MsdnLink@@ EndDeferWindowPos
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_EndDeferWindowPos($hInfo)

	Local $Ret = DllCall('user32.dll', 'int', 'EndDeferWindowPos', 'ptr', $hInfo)

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_EndDeferWindowPos

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

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_EndPaint

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_EndPath
; Description....: Closes a path bracket and selects the path defined by the bracket into the specified device context.
; Syntax.........: _WinAPI_EndPath ( $hDC )
; Parameters.....: $hDC    - Handle to the device context into which the new path is selected.
; Return values..: Success - 1.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ EndPath
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_EndPath($hDC)

	Local $Ret = DllCall('gdi32.dll', 'int', 'EndPath', 'hwnd', $hDC)

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_EndPath

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_EndUpdateResource
; Description....: Commits or discards changes of the resources within module.
; Syntax.........: _WinAPI_EndUpdateResource ( $hUpdate [, $fDiscard] )
; Parameters.....: $hUpdate  - A module handle returned by the _WinAPI_BeginUpdateResource(), and used by _WinAPI_UpdateResource(),
;                              referencing the file to be updated.
;                  $fDiscard - Specifies whether to write the resource updates to the file, valid values:
;                  |TRUE     - The changes are discarded.
;                  |FALSE    - The changes are made: the resource updates will take effect. (Default)
; Return values..: Success   - 1.
;                  Failure   - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ EndUpdateResource
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_EndUpdateResource($hUpdate, $fDiscard = 0)

	Local $Ret = DllCall('kernel32.dll', 'int', 'EndUpdateResourceW', 'ptr', $hUpdate, 'int', $fDiscard)

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_EndUpdateResource

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_EnumChildProcess
; Description....: Enumerates the child processes that belong to the specified process.
; Syntax.........: _WinAPI_EnumChildProcess ( [$PID] )
; Parameters.....: $PID    - The PID of the process. Default (0) is the current process.
; Return values..: Success - The 2D array of the PIDs and process names.
;
;                            [0][0] - Number of rows in array (n)
;                            [0][1] - Unused
;                            [1][0] - PID
;                            [1][1] - Process name
;                            [n][0] - PID
;                            [n][1] - Process name
;
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: None
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_EnumChildProcess($PID = 0)

	If Not $PID Then
		$PID = _WinAPI_GetCurrentProcessID()
		If Not $PID Then
			Return SetError(1, 0, 0)
		EndIf
	EndIf

	Local $hSnapshot = DllCall('kernel32.dll', 'ptr', 'CreateToolhelp32Snapshot', 'dword', 0x00000002, 'dword', 0)

	If (@error) Or (Not $hSnapshot[0]) Then
		Return SetError(1, 0, 0)
	EndIf

	Local $tPROCESSENTRY32 = DllStructCreate('dword Size;dword Usage;dword ProcessID;ulong_ptr DefaultHeapID;dword ModuleID;dword Threads;dword ParentProcessID;long PriClassBase;dword Flags;wchar ExeFile[260]')
	Local $pPROCESSENTRY32 = DllStructGetPtr($tPROCESSENTRY32)
	Local $Ret, $Result[101][2] = [[0]]

	$hSnapshot = $hSnapshot[0]
	DllStructSetData($tPROCESSENTRY32, 'Size', DllStructGetSize($tPROCESSENTRY32))
	$Ret = DllCall('kernel32.dll', 'int', 'Process32FirstW', 'ptr', $hSnapshot, 'ptr', $pPROCESSENTRY32)
	While (Not @error) And ($Ret[0])
		If DllStructGetData($tPROCESSENTRY32, 'ParentProcessID') = $PID Then
			$Result[0][0] += 1
			If $Result[0][0] > UBound($Result) - 1 Then
				ReDim $Result[$Result[0][0] + 100][2]
			EndIf
			$Result[$Result[0][0]][0] = DllStructGetData($tPROCESSENTRY32, 'ProcessID')
			$Result[$Result[0][0]][1] = DllStructGetData($tPROCESSENTRY32, 'ExeFile')
		EndIf
		$Ret = DllCall('kernel32.dll', 'int', 'Process32NextW', 'ptr', $hSnapshot, 'ptr', $pPROCESSENTRY32)
	WEnd
	_WinAPI_CloseHandle($hSnapshot)
	If $Result[0][0] Then
		ReDim $Result[$Result[0][0] + 1][2]
	Else
		Return SetError(1, 0, 0)
	EndIf
	Return $Result
EndFunc   ;==>_WinAPI_EnumChildProcess

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
;
;                              [0][0] - Number of rows in array (n)
;                              [0][1] - Unused
;                              [1][0] - Window handle
;                              [1][1] - Window class name
;                              [n][0] - Window handle
;                              [n][1] - Window class name
;
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

	Local $hEnumProc = DllCallbackRegister('__EnumWindowsProc','int','hwnd;lparam')
	Local $Error = 1

	Dim $__Data[101][2] = [[0]]
	DllCall('user32.dll', 'int', 'EnumChildWindows', 'hwnd', $hWnd, 'ptr', DllCallbackGetPtr($hEnumProc), 'lparam', $fVisible)
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
EndFunc   ;==>_WinAPI_EnumChildWindows

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_EnumDeviceDrivers
; Description....: Retrieves the load address for each device driver in the system.
; Syntax.........: _WinAPI_EnumDeviceDrivers ( )
; Parameters.....: None
; Return values..: Success - The array of device driver addresses. The zeroth array element contains the number of addresses.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ EnumDeviceDrivers
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_EnumDeviceDrivers()

	Local $tData, $Size, $Ret, $Result

	$Ret = DllCall(@SystemDir & '\psapi.dll', 'int', 'EnumDeviceDrivers', 'ptr', 0, 'dword', 0, 'dword*', 0)
	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	If @AutoItX64 Then
		$Size = $Ret[3] / 8
	Else
		$Size = $Ret[3] / 4
	EndIf
	$tData = DllStructCreate('ptr[' & $Size & ']')
	$Ret = DllCall(@SystemDir & '\psapi.dll', 'int', 'EnumDeviceDrivers', 'ptr', DllStructGetPtr($tData), 'dword', DllStructGetSize($tData), 'dword*', 0)
	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Dim $Result[$Size + 1] = [$Size]
	For $i = 1 To $Size
		$Result[$i] = DllStructGetData($tData, 1, $i)
	Next
	Return $Result
EndFunc   ;==>_WinAPI_EnumDeviceDrivers

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
;
;                             [0] - The width, in pixels, of the visible device surface.
;                             [1] - The height, in pixels, of the visible device surface.
;                             [2] - The color resolution, in bits per pixel, of the display device.
;                             [3] - The frequency, in hertz (cycles per second), of the display device in a particular mode.
;                             [4] - The device's display mode ($DM_*).
;
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

	If Not StringStripWS($sDevice, 3) Then
		$TypeOfDevice = 'ptr'
		$sDevice = 0
	EndIf

	Local $tDEVMODE = DllStructCreate('wchar[32];ushort;ushort;ushort;ushort;dword;dword[2];dword;dword;short;short;short;short;short;wchar[32];ushort;dword;dword;dword;dword;dword')

	DllStructSetData($tDEVMODE, 4, DllStructGetSize($tDEVMODE))
	DllStructSetData($tDEVMODE, 5, 0)

	Local $Ret = DllCall('user32.dll', 'int', 'EnumDisplaySettingsW', $TypeOfDevice, $sDevice, 'dword', $iMode, 'ptr', DllStructGetPtr($tDEVMODE))

	If (@error) Or (Not $Ret[0]) Then
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
; Name...........: _WinAPI_EnumMRUList
; Description....: Enumerates the contents of the most recently used (MRU) list.
; Syntax.........: _WinAPI_EnumMRUList ( $hMRU, $iItem )
; Parameters.....: $hMRU    - Handle of the MRU list, obtained when the list was created.
;                  $iItem   - The item to return. If this value is (-1), the function returns the number of items in the MRU list.
; Return values..: Success  - The item requested in $iItem. If $iItem is (-1) - the number of items in the MRU list.
;                  Failure  - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ EnumMRUListW
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_EnumMRUList($hMRU, $iItem)

	Local $tData = DllStructCreate('wchar[4096]')
	Local $Ret = DllCall('comctl32.dll ', 'int', 'EnumMRUListW', 'ptr', $hMRU, 'int', $iItem, 'ptr', DllStructGetPtr($tData), 'uint', 4096)

	If (@error) Or ($Ret[0] = -1) Then
		Return SetError(1, 0, 0)
	EndIf
	If $iItem < 0 Then
		Return $Ret[0]
	Else
		If Not $Ret[0] Then
			Return SetError(1, 0, 0)
		EndIf
	EndIf
	Return DllStructGetData($tData, 1)
EndFunc   ;==>_WinAPI_EnumMRUList

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

	If (@error) Or (Not $hSnapshot[0]) Then
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
	_WinAPI_CloseHandle($hSnapshot)
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
; Syntax.........: _WinAPI_EnumProcessWindows ( [$PID [, $fVisible]] )
; Parameters.....: $PID      - The PID of the process. Default (0) is the current process.
;                  $fVisible - Specifies whether enumerates the invisible window, valid values:
;                  |TRUE     - Enumerate only visible windows. (Default)
;                  |FALSE    - Enumerate all windows.
; Return values..: Success   - The 2D array of the handles to the windows and classes for the specified process.
;
;                              [0][0] - Number of rows in array (n)
;                              [0][1] - Unused
;                              [1][0] - Window handle
;                              [1][1] - Window class name
;                              [n][0] - Window handle
;                              [n][1] - Window class name
;
;                  Failure   - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: None
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_EnumProcessWindows($PID = 0, $fVisible = 1)

	Local $Threads = _WinAPI_EnumProcessThreads($PID)

	If @error Then
		Return SetError(1, 0, 0)
	EndIf

	Local $hEnumProc = DllCallbackRegister('__EnumWindowsProc','int','hwnd;lparam')
	Local $Error = 1

	Dim $__Data[101][2] = [[0]]
	For $i = 1 To $Threads[0]
		DllCall('user32.dll', 'int', 'EnumThreadWindows', 'dword', $Threads[$i], 'ptr',  DllCallbackGetPtr($hEnumProc), 'lparam', $fVisible)
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
; Return values..: Success  - The array of the LCIDs for specified resource type and name.
;                  Failure  - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ EnumResourceLanguages
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_EnumResourceLanguages($sModule, $sType, $sName)

	Local $Ret, $hModule, $hEnumProc, $TypeOfType = 'int', $TypeOfName = 'int'

	If IsString($sModule) Then
		If Not StringStripWS($sModule, 3) Then
			$hModule = DllCall('kernel32.dll', 'ptr', 'GetModuleHandle', 'ptr', 0)
		Else
			$hModule = DllCall('kernel32.dll', 'ptr', 'LoadLibraryW', 'wstr', $sModule)
		EndIf
		If (@error) Or (Not $hModule[0]) Then
			Return SetError(1, 0, 0)
		EndIf
		$hModule = $hModule[0]
	Else
		$hModule = $sModule
	EndIf
	If IsString($sType) Then
		$TypeOfType = 'wstr'
	EndIf
	If IsString($sName) Then
		$TypeOfName = 'wstr'
	EndIf
	Dim $__Data[101] = [0]
	$hEnumProc = DllCallbackRegister('__EnumResLanguagesProc','int','ptr;ptr;ptr;ushort;long_ptr')
	$Ret = DllCall('kernel32.dll', 'int', 'EnumResourceLanguagesW', 'ptr', $hModule, $TypeOfType, $sType, $TypeOfName, $sName, 'ptr', DllCallbackGetPtr($hEnumProc), 'long_ptr', 0)
	If (@error) Or (Not $Ret[0]) Then
		$__Data = 0
	Else
		ReDim $__Data[$__Data[0] + 1]
	EndIf
	DllCallbackFree($hEnumProc)
	If IsString($sModule) Then
		_WinAPI_FreeLibrary($hModule)
	EndIf
	Return SetError(Number(Not $__Data), 0, $__Data)
EndFunc   ;==>_WinAPI_EnumResourceLanguages

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_EnumResourceNames
; Description....: Enumerates resources of a specified type within a binary module.
; Syntax.........: _WinAPI_EnumResourceNames ( $sModule, $sType )
; Parameters.....: $sModule - Handle to a module to search.
;                  $sType   - The type of the resource. This parameter can be string or integer type.
; Return values..: Success  - The array of the names for the specified resource type.
;                  Failure  - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ EnumResourceNames
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_EnumResourceNames($sModule, $sType)

	Local $Ret, $hModule, $hEnumProc, $TypeOfType = 'int'

	If IsString($sModule) Then
		If Not StringStripWS($sModule, 3) Then
			$hModule = DllCall('kernel32.dll', 'ptr', 'GetModuleHandle', 'ptr', 0)
		Else
			$hModule = DllCall('kernel32.dll', 'ptr', 'LoadLibraryW', 'wstr', $sModule)
		EndIf
		If (@error) Or (Not $hModule[0]) Then
			Return SetError(1, 0, 0)
		EndIf
		$hModule = $hModule[0]
	Else
		$hModule = $sModule
	EndIf
	If IsString($sType) Then
		$TypeOfType = 'wstr'
	EndIf
	Dim $__Data[101] = [0]
	$hEnumProc = DllCallbackRegister('__EnumResNamesProc','int','ptr;ptr;ptr;long_ptr')
	$Ret = DllCall('kernel32.dll', 'int', 'EnumResourceNamesW', 'ptr', $hModule, $TypeOfType, $sType, 'ptr', DllCallbackGetPtr($hEnumProc), 'long_ptr', 0)
	If (@error) Or (Not $Ret[0]) Then
		$__Data = 0
	Else
		ReDim $__Data[$__Data[0] + 1]
	EndIf
	DllCallbackFree($hEnumProc)
	If IsString($sModule) Then
		_WinAPI_FreeLibrary($hModule)
	EndIf
	Return SetError(Number(Not $__Data), 0, $__Data)
EndFunc   ;==>_WinAPI_EnumResourceNames

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_EnumResourceTypes
; Description....: Enumerates resource types within a binary module.
; Syntax.........: _WinAPI_EnumResourceTypes ( $sModule )
; Parameters.....: $sModule - Handle to a module to search.
; Return values..: Success  - The array of the types of the resources for the specified module.
;                  Failure  - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ EnumResourceTypes
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_EnumResourceTypes($sModule)

	Local $Ret, $hModule, $hEnumProc

	If IsString($sModule) Then
		If Not StringStripWS($sModule, 3) Then
			$hModule = DllCall('kernel32.dll', 'ptr', 'GetModuleHandle', 'ptr', 0)
		Else
			$hModule = DllCall('kernel32.dll', 'ptr', 'LoadLibraryW', 'wstr', $sModule)
		EndIf
		If (@error) Or (Not $hModule[0]) Then
			Return SetError(1, 0, 0)
		EndIf
		$hModule = $hModule[0]
	Else
		$hModule = $sModule
	EndIf
	Dim $__Data[101] = [0]
	$hEnumProc = DllCallbackRegister('__EnumResTypesProc','int','ptr;ptr;long_ptr')
	$Ret = DllCall('kernel32.dll', 'int', 'EnumResourceTypesW', 'ptr', $hModule, 'ptr', DllCallbackGetPtr($hEnumProc), 'long_ptr', 0)
	If (@error) Or (Not $Ret[0]) Then
		$__Data = 0
	Else
		ReDim $__Data[$__Data[0] + 1]
	EndIf
	DllCallbackFree($hEnumProc)
	If IsString($sModule) Then
		_WinAPI_FreeLibrary($hModule)
	EndIf
	Return SetError(Number(Not $__Data), 0, $__Data)
EndFunc   ;==>_WinAPI_EnumResourceTypes

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_EnumSystemLocales
; Description....: Enumerates the locales that are either installed on or supported by an operating system.
; Syntax.........: _WinAPI_EnumSystemLocales ( $iFlag )
; Parameters.....: $iFlag  - Flags specifying the locale identifiers to enumerate. This parameter can have one of the
;                            following values.
;
;                            $LCID_INSTALLED
;                            $LCID_SUPPORTED
;
; Return values..: Success - The array of the locale identifiers.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ EnumSystemLocales
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_EnumSystemLocales($iFlag)

	Local $Ret, $hEnumProc

	Dim $__Data[101] = [0]
	$hEnumProc = DllCallbackRegister('__EnumLocalesProc','int','ptr')
	$Ret = DllCall('kernel32.dll', 'int', 'EnumSystemLocalesW', 'ptr', DllCallbackGetPtr($hEnumProc), 'dword', $iFlag)
	If (@error) Or (Not $Ret[0]) Or (Not IsArray($__Data)) Then
		$__Data = 0
	Else
		ReDim $__Data[$__Data[0] + 1]
	EndIf
	DllCallbackFree($hEnumProc)
	Return SetError(Number(Not $__Data), 0, $__Data)
EndFunc   ;==>_WinAPI_EnumSystemLocales

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
; Name...........: _WinAPI_EqualStruct
; Description....: Determines whether the two specified structures are equal.
; Syntax.........: _WinAPI_EqualStruct (ByRef $tStruct1, ByRef $tStruct2)
; Parameters.....: $tStruct1 - The structure that contains the first source data.
;                  $tStruct2 - The structure that contains the second source data.
; Return values..: Success   - 1 - The two structures are identical.
;                              0 - Otherwise.
;                  Failure   - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: None
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_EqualStruct(ByRef $tStruct1, ByRef $tStruct2)

	Local $Size1 = DllStructGetSize($tStruct1)
	Local $Size2 = DllStructGetSize($tStruct2)

	If (Not $Size1) Or (Not $Size2) Then
		Return SetError(1, 0, 0)
	Else
		If $Size1 <> $Size2 Then
			Return 0
		EndIf
	EndIf

	Local $tData1 = DllStructCreate('byte[' & $Size1 & ']', DllStructGetPtr($tStruct1))
	Local $tData2 = DllStructCreate('byte[' & $Size2 & ']', DllStructGetPtr($tStruct2))

	If (Not IsDllStruct($tData1)) Or (Not IsDllStruct($tData2)) Then
		Return SetError(1, 0, 0)
	EndIf
	For $i = 1 To $Size1
		If DllStructGetData($tData1, 1, $i) <> DllStructGetData($tData2, 1, $i) Then
			Return 0
		EndIf
	Next
	Return 1
EndFunc   ;==>_WinAPI_EqualStruct

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_ExcludeClipRect
; Description....: Creates a new clipping region that consists of the existing clipping region minus the specified rectangle.
; Syntax.........: _WinAPI_ExcludeClipRect ( $hDC, $tRECT )
; Parameters.....: $hDC    - Handle to the device context.
;                  $tRECT  - $tagRECT structure that contains the logical coordinates of the specified rectangle.
; Return values..: Success - The value that specifies the new clipping region's complexity; it can be one of the following values.
;
;                            $COMPLEXREGION
;                            $NULLREGION
;                            $SIMPLEREGION
;
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ ExcludeClipRect
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_ExcludeClipRect($hDC, $tRECT)

	Local $Ret = DllCall('gdi32.dll', 'int', 'ExcludeClipRect', 'hwnd', $hDC, 'int', DllStructGetData($tRECT, 1), 'int', DllStructGetData($tRECT, 2), 'int', DllStructGetData($tRECT, 3), 'int', DllStructGetData($tRECT, 4))

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_ExcludeClipRect

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_ExtCreateRegion
; Description....: Creates a region from the specified region and transformation data.
; Syntax.........: _WinAPI_ExtCreateRegion ( ByRef $tRGNDATA [, $tXFORM] )
; Parameters.....: $tRGNDATA - $tagRGNDATA structure that contains the region data in logical units.
;                  $tXFORM   - $tagXFORM structure that defines the transformation to be performed on the region.
; Return values..: Success   - The handle to the region.
;                  Failure   - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ ExtCreateRegion
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_ExtCreateRegion(ByRef $tRGNDATA, $tXFORM = 0)

	Local $Ret = DllCall('gdi32.dll', 'ptr', 'ExtCreateRegion', 'ptr', DllStructGetPtr($tXFORM), 'dword', DllStructGetSize($tRGNDATA), 'ptr', DllStructGetPtr($tRGNDATA))

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_ExtCreateRegion

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_ExtFloodFill
; Description....: Fills an area of the display surface with the current brush.
; Syntax.........: _WinAPI_ExtFloodFill ( $hDC, $iX, $iY, $iRGB [, $iType] )
; Parameters.....: $hDC    - Handle to the device context.
;                  $iX     - The x-coordinate, in logical units, of the point where filling is to start.
;                  $iY     - The y-coordinate, in logical units, of the point where filling is to start.
;                  $iRGB   - The color of the boundary or of the area to be filled, in RGB. The interpretation of color depends on
;                            the value of the $iType parameter.
;                  $iType  - The type of fill operation to be performed. This parameter must be one of the following values.
;
;                            $FLOODFILLBORDER
;                            $FLOODFILLSURFACE
;
; Return values..: Success - 1.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ ExtFloodFill
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_ExtFloodFill($hDC, $iX, $iY, $iRGB, $iType = 0)

	Local $Ret = DllCall('gdi32.dll', 'int', 'ExtFloodFill', 'hwnd', $hDC, 'int', $iX, 'int', $iY, 'dword', __RGB($iRGB), 'uint', $iType)

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_ExtFloodFill

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_ExtSelectClipRgn
; Description....: Combines the specified region with the current clipping region.
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
; Return values..: Success - The value that specifies the new clipping region's complexity; it can be one of the following values.
;
;                            $COMPLEXREGION
;                            $NULLREGION
;                            $SIMPLEREGION
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

	If (@error) Or (Not $Ret[0]) Then
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
; Name...........: _WinAPI_FillPath
; Description....: Closes any open figures in the current path and fills the path's interior by using the current brush.
; Syntax.........: _WinAPI_FillPath ( $hDC )
; Parameters.....: $hDC    - Handle to a device context that contains a valid path.
; Return values..: Success - 1.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: After its interior is filled, the path is discarded from the DC identified by the $hDC parameter.
; Related........:
; Link...........: @@MsdnLink@@ FillPath
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_FillPath($hDC)

	Local $Ret = DllCall('gdi32.dll', 'int', 'FillPath', 'hwnd', $hDC)

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_FillPath

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

	If (@error) Or (Not $Ret[0]) Then
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

	If (@error) Or (Not $Ret[0]) Then
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
; Syntax.........: _WinAPI_FindResource ( $hInstance, $sType, $sName )
; Parameters.....: $hInstance - Handle to the module whose executable file contains the resource. A value of 0 specifies the module
;                               handle associated with the image file that the operating system used to create the current process.
;                  $sType     - The type of the resource. This parameter can be string or integer type.
;                  $sName     - The name of the resource. This parameter can be string or integer type.
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

Func _WinAPI_FindResource($hInstance, $sType, $sName)

	Local $TypeOfType = 'int', $TypeOfName = 'int'

	If IsString($sType) Then
		$TypeOfType = 'wstr'
	EndIf
	If IsString($sName) Then
		$TypeOfName = 'wstr'
	EndIf

	Local $Ret = DllCall('kernel32.dll', 'ptr', 'FindResourceW', 'ptr', $hInstance, $TypeOfName, $sName, $TypeOfType, $sType)

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_FindResource

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_FindResourceEx
; Description....: Determines the location of the resource with the specified type, name, and language in the specified module.
; Syntax.........: _WinAPI_FindResourceEx ( $hInstance, $sType, $sName, $iLanguage )
; Parameters.....: $hInstance - Handle to the module whose executable file contains the resource. A value of 0 specifies the module
;                               handle associated with the image file that the operating system used to create the current process.
;                  $sType     - The type of the resource. This parameter can be string or integer type.
;                  $sName     - The name of the resource. This parameter can be string or integer type.
;                  $iLanguage - The language of the resource (LCID).
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

Func _WinAPI_FindResourceEx($hInstance, $sType, $sName, $iLanguage)

	Local $TypeOfType = 'int', $TypeOfName = 'int'

	If IsString($sType) Then
		$TypeOfType = 'wstr'
	EndIf
	If IsString($sName) Then
		$TypeOfName = 'wstr'
	EndIf

	Local $Ret = DllCall('kernel32.dll', 'ptr', 'FindResourceExW', 'ptr', $hInstance, $TypeOfType, $sType, $TypeOfName, $sName, 'ushort', $iLanguage)

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_FindResourceEx

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_FlattenPath
; Description....: Transforms any curves in the path that is selected into the current DC, turning each curve into a sequence of lines.
; Syntax.........: _WinAPI_FlattenPath ( $hDC )
; Parameters.....: $hDC    - Handle to a device context that contains a valid path.
; Return values..: Success - 1.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ FlattenPath
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_FlattenPath($hDC)

	Local $Ret = DllCall('gdi32.dll', 'int', 'FlattenPath', 'hwnd', $hDC)

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_FlattenPath

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_FlushViewOfFile
; Description....: Writes to the disk a byte range within a mapped view of a file.
; Syntax.........: _WinAPI_FlushViewOfFile ( $pAddress [, $iBytes] )
; Parameters.....: $pAddress - A pointer to the base address of the byte range to be flushed to the disk representation of the mapped file.
;                  $iBytes   - The number of bytes to be flushed. If $iBytes is 0, the file is flushed from the base address to the
;                              end of the mapping.
; Return values..: Success   - 1.
;                  Failure   - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ FlushViewOfFile
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_FlushViewOfFile($pAddress, $iBytes = 0)

	Local $Ret = DllCall('kernel32.dll', 'int', 'FlushViewOfFile', 'ptr', $pAddress, 'dword', $iBytes)

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_FlushViewOfFile

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
	If Not $sDrive Then
		Return SetError(-1, 0, 0)
	EndIf
	$sDrive = Asc($sDrive) - 65
	If ($sDrive < 0) Or ($sDrive > 25) Then
		Return SetError(-1, 0, 0)
	EndIf

	Local $Ret = DllCall('shell32.dll', 'int', 'SHFormatDrive', 'hwnd', $hParent, 'uint', $sDrive, 'uint', $SHFMT_ID_DEFAULT, 'uint', $iOption)

	If @error Then
		Return SetError(-1, 0, 0)
	Else
		If $Ret[0] < 0 Then
			Return SetError($Ret[0], 0, 0)
		EndIf
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

	If (@error) Or (Not $Ret[0]) Then
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

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_FrameRgn

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_FreeMRUList
; Description....: Frees the handle associated with the most recently used (MRU) list and writes cached data to the registry.
; Syntax.........: _WinAPI_FreeMRUList ( $hMRU )
; Parameters.....: $hMRU   - Handle of the MRU list to free.
; Return values..: Success - 1.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ FreeMRUList
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_FreeMRUList($hMRU)

	Local $Ret = DllCall('comctl32.dll ', 'int', 'FreeMRUList', 'ptr', $hMRU)

	If (@error) Or ($Ret[0] = -1) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_FreeMRUList

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

	Local $Ret = DllCall('kernel32.dll', 'int', 'FreeResource', 'ptr', $hData)

	If (@error) Or (Not $Ret[0]) Then
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
; Name...........: _WinAPI_GetArcDirection
; Description....: Retrieves the current arc direction for the specified device context.
; Syntax.........: _WinAPI_GetArcDirection ( $hDC )
; Parameters.....: $hDC    - Handle to the device context.
; Return values..: Success - The current arc direction ($AD_*).
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ GetArcDirection
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_GetArcDirection($hDC)

	Local $Ret = DllCall('gdi32.dll', 'int', 'GetArcDirection', 'hwnd', $hDC)

	If @error Then
		Return SetError(1, 0, 0)
	Else
		Switch $Ret[0]
			Case $AD_COUNTERCLOCKWISE, $AD_CLOCKWISE

			Case Else
				Return SetError(1, 0, 0)
		EndSwitch
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_GetArcDirection

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetAsyncKeyState
; Description....: Determines whether a key is up or down at the time the function is called.
; Syntax.........: _WinAPI_GetAsyncKeyState ( $vKey )
; Parameters.....: $vKey   - The virtual-key code ($VK_*).
; Return values..: Success - If the 16th (15) bit is set, the key is down, and if the 1st (0) bit is set, the key was pressed
;                            after the previous call to _WinAPI_GetAsyncKeyState().
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: Although the least significant bit of the return value indicates whether the key has been pressed since the last
;                  query, due to the pre-emptive multitasking nature of Windows, another application can call _WinAPI_GetAsyncKeyState()
;                  and receive the "recently pressed" bit instead of your application.
;
;                  You can use the virtual-key code constants $VK_SHIFT, $VK_CONTROL, and $VK_MENU as values for the $vKey parameter.
;                  This gives the state of the SHIFT, CTRL, or ALT keys without distinguishing between left and right.
; Related........:
; Link...........: @@MsdnLink@@ GetAsyncKeyState
; Example........: Yes
; ===============================================================================================================================

#cs

Func _WinAPI_GetAsyncKeyState($vKey)

	Local $Ret = DllCall('user32.dll', 'short', 'GetAsyncKeyState', 'int', $vKey)

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return BitAND($Ret[0], 0x8001)
EndFunc   ;==>_WinAPI_GetAsyncKeyState

#ce

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetBinaryType
; Description....: Determines whether a file is an executable (.exe) file, and if so, which subsystem runs the executable file.
; Syntax.........: _WinAPI_GetBinaryType ( $sPath )
; Parameters.....: $sPath  - The full path of the file whose executable type is to be determined.
; Return values..: Success - 1 - The file is executable, @extended flag will be contain one of the $SCS_* constant to
;                                indicate the file's executable type.
;                            0 - Otherwise.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ GetBinaryType
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_GetBinaryType($sPath)

	Local $Ret = DllCall('kernel32.dll', 'int', 'GetBinaryTypeW', 'wstr', $sPath, 'dword*', 0)

	If @error Then
		Return SetError(1, 0, 0)
	EndIf
	If Not $Ret[0] Then
		$Ret[2] = 0
	EndIf
	Return SetError(0, $Ret[2], $Ret[0])
EndFunc   ;==>_WinAPI_GetBinaryType

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

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf

	Local $tSIZE = DllStructCreate($tagSIZE)

	DllStructSetData($tSIZE, 1, DllStructGetData($tObj, 'bmWidth'))
	DllStructSetData($tSIZE, 2, DllStructGetData($tObj, 'bmHeight'))

	Return $tSIZE
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

	If (@error) Or ($Ret[0] = -1) Then
		Return SetError(1, 0, -1)
	EndIf
	Return __RGB($Ret[0])
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
	Return BitShift(BitAND(__RGB($iRGB), 0xFF0000), 16)
EndFunc   ;==>_WinAPI_GetBValue

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetCaretBlinkTime
; Description....: Returns the time required to invert the caret's pixels.
; Syntax.........: _WinAPI_GetCaretBlinkTime ( )
; Parameters.....: None
; Return values..: Success - The blink time, in milliseconds.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ GetCaretBlinkTime
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_GetCaretBlinkTime()

	Local $Ret = DllCall('user32.dll', 'uint', 'GetCaretBlinkTime')

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_GetCaretBlinkTime

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetCaretPos
; Description....: Retrieves the caret's position.
; Syntax.........: _WinAPI_GetCaretPos ( )
; Parameters.....: None
; Return values..: Success - The array that contains the client coordinates of the caret.
;
;                            [0] - x-coordinate of the caret.
;                            [1] - y-coordinate of the caret.
;
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ GetCaretPos
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_GetCaretPos()

	Local $tPOINT = DllStructCreate($tagPOINT)
	Local $Ret = DllCall('user32.dll', 'int', 'GetCaretPos', 'ptr', DllStructGetPtr($tagPOINT))

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf

	Local $Result[2]

	For $i = 0 To 1
		$Result[$i] = DllStructGetData($tPOINT, $i + 1)
	Next
	Return $Result
EndFunc   ;==>_WinAPI_GetCaretPos

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetCDType
; Description....: Retrieves a type of the media which is loaded into a specified CD-ROM device.
; Syntax.........: _WinAPI_GetCDType ( $sDrive )
; Parameters.....: $sDrive - The drive letter of the CD tray to retrieve information, in the format D:, E:, etc.
; Return values..: Success - The type of the media, it must be one of the following values.
;
;                            0x0000 - No media
;                            0x0008 - CD-ROM
;                            0x0009 - CD-R
;                            0x000A - CD-RW
;                            0x0010 - DVD-ROM
;                            0x0011 - DVD-R Sequential Recording
;                            0x0012 - DVD-RAM
;                            0x0013 - DVD-RW Restricted Overwrite
;                            0x0014 - DVD-RW Sequential Recording
;                            0x0015 - DVD-R Dual Layer
;                            0x0016 - DVD-R Dual Layer Jump Recording
;                            0x0017 - DVD-RW Dual Layer
;                            0x0018 - DVD-Download Disc Recording
;                            0x001A - DVD+RW
;                            0x001B - DVD+R
;                            0x0040 - BD-ROM
;                            0x0041 - BD-R Sequential Recording Mode (SRM)
;                            0x0042 - BD-R Random Recording Mode (RRM)
;                            0x0043 - BD-RE
;                            0x0050 - HD DVD-ROM
;                            0x0051 - HD DVD-R
;                            0x0052 - HD DVD-RAM
;                            0x0053 - HD DVD-RW
;                            0x0058 - HD DVD-R Dual Layer
;                            0x005A - HD DVD-RW Dual Layer
;                            0xFFFF - Unknown
;
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ IOCTL_SCSI_PASS_THROUGH
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_GetCDType($sDrive)

	Local $hFile = _WinAPI_CreateFileEx('\\.\' & $sDrive, 3, 0xC0000000, 0x03)

	If Not $hFile Then
		Return SetError(1, 0, 0)
	EndIf

	Local $tSPT = DllStructCreate('ushort Length;byte ScsiStatus;byte PathId;byte TargetId;byte Lun;byte CdbLength;byte SenseInfoLength;byte DataIn;byte Alignment[3];ulong DataTransferLength;ulong TimeOutValue;ulong_ptr DataBufferOffset;ulong SenseInfoOffset;byte Cdb[16];byte Hdr[8]')
	Local $tCDB = DllStructCreate('byte;byte;byte[2];byte[3];byte[2];byte;byte[2];byte[4]', DllStructGetPtr($tSPT, 'Cdb'))
	Local $tHDR = DllStructCreate('byte[4];byte;byte;byte[2]', DllStructGetPtr($tSPT, 'Hdr'))
	Local $Size = DllStructGetSize($tSPT) - 8

	DllStructSetData($tSPT, 'Length', $Size)
	DllStructSetData($tSPT, 'ScsiStatus', 0)
	DllStructSetData($tSPT, 'PathId', 0)
	DllStructSetData($tSPT, 'TargetId', 0)
	DllStructSetData($tSPT, 'Lun', 0)
	DllStructSetData($tSPT, 'CdbLength', 12)
	DllStructSetData($tSPT, 'SenseInfoLength', 0)
	DllStructSetData($tSPT, 'DataIn', 1)
	DllStructSetData($tSPT, 'DataTransferLength', 8)
	DllStructSetData($tSPT, 'TimeOutValue', 86400)
	DllStructSetData($tSPT, 'DataBufferOffset', $Size)
	DllStructSetData($tSPT, 'SenseInfoOffset', 0)

	DllStructSetData($tCDB, 1, 0x46)
	DllStructSetData($tCDB, 2, 0)
	DllStructSetData($tCDB, 3, 0, 1)
	DllStructSetData($tCDB, 3, 0, 2)
	DllStructSetData($tCDB, 5, 0, 1)
	DllStructSetData($tCDB, 5, 8, 2)
	DllStructSetData($tCDB, 6, 0)
	DllStructSetData($tCDB, 7, 0, 1)
	DllStructSetData($tCDB, 7, 0, 2)

	Local $Ret = DllCall('kernel32.dll', 'int', 'DeviceIoControl', 'ptr', $hFile, 'dword', $IOCTL_SCSI_PASS_THROUGH, 'ptr', DllStructGetPtr($tSPT), 'dword', $Size, 'ptr', DllStructGetPtr($tSPT), 'dword', DllStructGetSize($tSPT), 'dword*', 0, 'ptr', 0)

	If (@error) Or (Not $Ret[0]) Then
		$Ret = 0
	EndIf
	_WinAPI_CloseHandle($hFile)
	If Not IsArray($Ret) Then
		Return SetError(2, 0, 0)
	EndIf
	Return BitOR(BitShift(DllStructGetData($tHDR, 4, 1), -8), DllStructGetData($tHDR, 4, 2))
EndFunc   ;==>_WinAPI_GetCDType

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetClassInfoEx
; Description....: Retrieves information about a window class.
; Syntax.........: _WinAPI_GetClassInfoEx ( $sClass [, $hInstance] )
; Parameters.....: $sClass    - The class name. The name must be that of a preregistered class or a class registered by a previous
;                               call to the _WinAPI_RegisterClass() or _WinAPI_RegisterClassEx() function. Alternatively, this
;                               parameter can be a class atom. The atom must be in the low-order word of $sClass; the high-order
;                               word must be zero.
;                  $hInstance - Handle to the instance of the application that created the class. To retrieve information about
;                               classes defined by the system (such as buttons or list boxes), set this parameter to 0.
; Return values..: Success    - $tagWNDCLASSEX structure that contains the information about the class.
;                  Failure    - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ GetClassInfoEx
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_GetClassInfoEx($sClass, $hInstance = 0)

	Local $TypeOfClass = 'ptr'

	If IsString($sClass) Then
		$TypeOfClass = 'wstr'
	EndIf

	Local $tWNDCLASSEX = DllStructCreate($tagWNDCLASSEX)
	Local $Ret = DllCall('user32.dll', 'int', 'GetClassInfoExW', 'ptr', $hInstance, $TypeOfClass, $sClass, 'ptr', DllStructGetPtr($tWNDCLASSEX))

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $tWNDCLASSEX
EndFunc   ;==>_WinAPI_GetClassInfoEx

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetClassLongEx
; Description....: Retrieves the specified value associated with the specified window.
; Syntax.........: _WinAPI_GetClassLongEx ( $hWnd, $iIndex )
; Parameters.....: $hWnd   - Handle to the window.
;                  $iIndex - The value to retrieve. This parameter can be one of the following values.
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
; Return values..: Success - The requested value.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ GetClassLong
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_GetClassLongEx($hWnd, $iIndex)

	Local $Ret

	If StringInStr(@OSArch, '64') Then
		$Ret = DllCall('user32.dll', 'ulong_ptr', 'GetClassLongPtrW', 'hwnd', $hWnd, 'int', $iIndex)
	Else
		$Ret = DllCall('user32.dll', 'ulong', 'GetClassLongW', 'hwnd', $hWnd, 'int', $iIndex)
	EndIf
	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_GetClassLongEx

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetClipBox
; Description....: Retrieves the dimensions of the bounding rectangle of the visible area.
; Syntax.........: _WinAPI_GetClipBox ( $hDC, ByRef $tRECT )
; Parameters.....: $hDC    - Handle to the device context.
;                  $tRECT  - $tagRECT structure that receive the rectangle dimensions, in logical units.
; Return values..: Success - The value that specifies the new clipping region's complexity; it can be one of the following values.
;
;                            $COMPLEXREGION
;                            $NULLREGION
;                            $SIMPLEREGION
;
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ GetClipBox
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_GetClipBox($hDC, ByRef $tRECT)

	Local $Ret = DllCall('gdi32.dll', 'int', 'GetClipBox', 'hwnd', $hDC, 'ptr', DllStructGetPtr($tRECT))

	If (@error) Or (Not $Ret[0]) Then
		$tRECT = 0
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_GetClipBox

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetClipRgn
; Description....: Retrieves a handle identifying the current application-defined clipping region.
; Syntax.........: _WinAPI_GetClipRgn ( $hDC )
; Parameters.....: $hDC    - Handle to the device context.
; Return values..: Success - Handle to a copy of the current clipping region.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: An application-defined clipping region is a clipping region identified by the _WinAPI_SelectClipRgn() function.
;                  It is not a clipping region created when the application calls the _WinAPI_BeginPaint().
; Related........:
; Link...........: @@MsdnLink@@ GetClipRgn
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_GetClipRgn($hDC)

	Local $hRgn = _WinAPI_CreateRectRgn(0, 0, 0, 0)
	Local $Ret = DllCall('gdi32.dll', 'int', 'GetClipRgn', 'hwnd', $hDC, 'ptr', $hRgn)

	If (@error) Or ($Ret[0] = -1) Then
		$Ret = 0
	Else
		If Not $Ret[0] Then
			$Ret = 1
		EndIf
	EndIf
	If Not IsArray($Ret) Then
		_WinAPI_DeleteObject($hRgn)
		If Not $Ret Then
			Return SetError(1, 0, 0)
		Else
			Return 0
		EndIf
	EndIf
	Return $hRgn
EndFunc   ;==>_WinAPI_GetClipRgn

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetClipCursor
; Description....: Retrieves the screen coordinates of the rectangular area to which the cursor is confined.
; Syntax.........: _WinAPI_GetClipCursor ( )
; Parameters.....: None
; Return values..: Success - $tagRECT structure that receives the screen coordinates of the confining rectangle.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ GetClipCursor
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_GetClipCursor()

	Local $tRECT = DllStructCreate($tagRECT)
	Local $Ret = DllCall('user32.dll', 'int', 'GetClipCursor', 'ptr', DllStructGetPtr($tRECT))

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $tRECT
EndFunc   ;==>_WinAPI_GetClipCursor

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
	Local $Ret = DllCall('kernel32.dll', 'int', 'DeviceIoControl', 'ptr', $hFile, 'dword', $FSCTL_GET_COMPRESSION, 'ptr', 0, 'dword', 0, 'ptr', DllStructGetPtr($tData), 'dword', DllStructGetSize($tData), 'dword*', 0, 'ptr', 0)

	If (@error) Or (Not $Ret[0]) Then
		$Ret = 0
	EndIf
	_WinAPI_CloseHandle($hFile)
	If Not IsArray($Ret) Then
		Return SetError(2, 0, 0)
	EndIf
	Return DllStructGetData($tData, 1)
EndFunc   ;==>_WinAPI_GetCompression

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetConnectedDlg
; Description....: Launches the Get Connected wizard within the calling application to enable network connectivity.
; Syntax.........: _WinAPI_GetConnectedDlg ( $iDlg [, $iFlags [, $hParent]] )
; Parameters.....: $iDlg    - Specifies which the dialog should be launched, valid values:
;                  |0 - Local area network connectivity.
;                  |1 - Internet connectivity.
;                  |2 - Virtual private network (VPN) connectivity.
;                  $iFlags  - Specifies an additional options. This parameter can be one or more of the following values.
;                  |0 - Default.
;                  |1 - Do not display the Get Connected wizard page that shows whether or not the user has a working or active Internet connection.
;                  |2 - Do not display the Get Connected wizard page that shows a list of existing internet connections.
;                  |4 - Hide the finish page of the Get Connected wizard.
;                  $hParent - Handle to the parent window that called this API.
; Return values..: Success  - 1 - The Internet is connected.
;                             0 - Otherwise.
;                  Failure  - 0 and sets the @error flag to non-zero, @extended flag may contain the system error code.
; Author.........: Yashied
; Modified.......:
; Remarks........: This function requires Windows Vista or later.
; Related........:
; Link...........: None
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_GetConnectedDlg($iDlg, $iFlags = 0, $hParent = 0)

	If Not __DLL('connect.dll') Then
		Return SetError(1, 0, 0)
	EndIf

	Switch $iDlg
		Case 0
			$iDlg = 'GetNetworkConnected'
		Case 1
			$iDlg = 'GetInternetConnected'
		Case 2
			$iDlg = 'GetVPNConnected'
		Case Else
			Return SetError(1, 0, 0)
	EndSwitch

	Local $Str = ''

	If BitAND($iFlags, 1) Then
		$Str &= '-SkipInternetDetection '
	EndIf
	If BitAND($iFlags, 2) Then
		$Str &= '-SkipExistingConnections '
	EndIf
	If BitAND($iFlags, 4) Then
		$Str &= '-HideFinishPage '
	EndIf

	Local $Ret = DllCall('connect.dll', 'uint', $iDlg, 'hwnd', $hParent, 'dword', 0, 'dword', 0, 'dword', 0, 'ptr', 0, 'wstr', StringStripWS($Str, 2))

	If @error Then
		Return SetError(1, 0, 0)
	Else
		Switch $Ret[0]
			Case 0, 1 ; S_OK, S_FALSE

			Case Else
				Return SetError(1, $Ret[0], 0)
		EndSwitch
	EndIf
	Return Number(Not $Ret[0])
EndFunc   ;==>_WinAPI_GetConnectedDlg

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetCurrentDirectory
; Description....: Retrieves the current directory for the current process.
; Syntax.........: _WinAPI_GetCurrentDirectory ( )
; Parameters.....: None
; Return values..: Success - The absolute path to the current directory.
;                  Failure - Empty string and sets the @error flag to non-zero.
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

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, '')
	EndIf
	Return DllStructGetData($tData, 1)
EndFunc   ;==>_WinAPI_GetCurrentDirectory

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetCurrentHwProfile
; Description....: Retrieves information about the current hardware profile for the local computer.
; Syntax.........: _WinAPI_GetCurrentHwProfile ( )
; Parameters.....: None
; Return values..: Success - $tagHW_PROFILE_INFO structure that contains information about the current hardware profile.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ GetCurrentHwProfile
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_GetCurrentHwProfile()

	Local $tHW_PROFILE_INFO = DllStructCreate($tagHW_PROFILE_INFO)
	Local $Ret = DllCall('advapi32.dll', 'int', 'GetCurrentHwProfileW', 'ptr', DllStructGetPtr($tHW_PROFILE_INFO))

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $tHW_PROFILE_INFO
EndFunc   ;==>_WinAPI_GetCurrentHwProfile

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetCurrentThemeName
; Description....: Retrieves the name of the current visual styles, color scheme name, and size name.
; Syntax.........: _WinAPI_GetCurrentThemeName ( )
; Parameters.....: None
; Return values..: Success - The array that contains the following information.
;
;                  [0] - The theme path and file name.
;                  [1] - The color scheme name.
;                  [2] - The size name.
;
;                  Failure - 0 and sets the @error flag to non-zero, @extended flag may contain the system error code.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ GetCurrentThemeName
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_GetCurrentThemeName()

	Local $tData = DllStructCreate('wchar[1024];wchar[1024];wchar[1024]')
	Local $Ret = DllCall('uxtheme.dll', 'uint', 'GetCurrentThemeName', 'ptr', DllStructGetPtr($tData, 1), 'int', 1024, 'ptr', DllStructGetPtr($tData, 2), 'int', 1024, 'ptr', DllStructGetPtr($tData, 3), 'int', 1024)

	If @error Then
		Return SetError(1, 0, 0)
	Else
		If $Ret[0] Then
			Return SetError(1, $Ret[0], 0)
		EndIf
	EndIf

	Local $Result[3]

	For $i = 0 To 2
		$Result[$i] = DllStructGetData($tData, $i + 1)
	Next
	Return $Result
EndFunc   ;==>_WinAPI_GetCurrentThemeName

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
; Name...........: _WinAPI_GetDateFormat
; Description....: Formats a date as a date string for a locale specified by the locale identifier.
; Syntax.........: _WinAPI_GetDateFormat ( [$LCID [, $tSYSTEMTIME [, $iFlag [, $sFormat]]]] )
; Parameters.....: $LCID        - Locale identifier (LCID) that specifies the locale. If this parameter is 0, the function will
;                                 use default locale for the user.
;                  $tSYSTEMTIME - $tagSYSTEMTIME structure that contains the date information to format. If this parameter is 0,
;                                 the function will use the current local system date.
;                  $iFlag       - Flags specifying date format options. This parameter can be one or more of the following values.
;
;                                 $DATE_LONGDATE
;                                 $DATE_SHORTDATE (Default)
;                                 $DATE_USE_ALT_CALENDAR
;
;                                 *Windows Vista or later
;
;                                 $DATE_LTRREADING
;                                 $DATE_RTLREADING
;                                 $DATE_YEARMONTH
;
;                                 *Windows 7 or later
;
;                                 $DATE_AUTOLAYOUT
;
;                  $sFormat     - The string that is used to form the date. For example, "dddd dd, yyyy". If this parameter is 0,
;                                 the function returns the string according to the date format for the specified locale ($LCID).
; Return values..: Success      - The formatted date string.
;                  Failure      - Empty string and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ GetDateFormat
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_GetDateFormat($LCID = 0, $tSYSTEMTIME = 0, $iFlags = 0, $sFormat = '')

	Local $TypeOfFormat = 'wstr'

	If Not $LCID Then
		$LCID = 0x0400
	EndIf
	If Not StringStripWS($sFormat, 3) Then
		$TypeOfFormat = 'ptr'
		$sFormat = 0
	EndIf

	Local $tData = DllStructCreate('wchar[1024]')
	Local $Ret = DllCall('kernel32.dll', 'int', 'GetDateFormatW', 'long', $LCID, 'dword', $iFlags, 'ptr', DllStructGetPtr($tSYSTEMTIME), $TypeOfFormat, $sFormat, 'ptr', DllStructGetPtr($tData), 'int', 1024)

    If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, '')
	EndIf
    Return DllStructGetData($tData, 1)
EndFunc   ;==>_WinAPI_GetDateFormat

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetDCEx
; Description....: Retrieves a handle to a device context (DC) for the client area of a specified window.
; Syntax.........: _WinAPI_GetDCEx ( $hWnd, $hRgn, $iFlags )
; Parameters.....: $hWnd   - Handle to the window whose DC is to be retrieved. If this value is 0, _WinAPI_GetDCEx() retrieves the
;                            DC for the entire screen. If the value of $iFlags parameter is $DCX_INTERSECTRGN or DCX_EXCLUDERGN,
;                            then the operating system assumes ownership of the region and will automatically delete it when it is
;                            no longer needed. In this case, the application should not use or delete the region after a successful
;                            call to _WinAPI_GetDCEx().
;                  $hRgn   - A clipping region that may be combined with the visible region of the DC.
;                  $iFlags - Flags that specifies how the DC is created. This parameter can be one or more of the following values.
;
;                            $DCX_WINDOW
;                            $DCX_CACHE
;                            $DCX_PARENTCLIP
;                            $DCX_CLIPSIBLINGS
;                            $DCX_CLIPCHILDREN
;                            $DCX_NORESETATTRS
;                            $DCX_LOCKWINDOWUPDATE
;                            $DCX_EXCLUDERGN
;                            $DCX_INTERSECTRGN
;                            $DCX_INTERSECTUPDATE
;                            $DCX_VALIDATE
;
; Return values..: Success - Handle to the DC for the specified window.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: Unless the display DC belongs to a window class, the _WinAPI_ReleaseDC() function must be called to release the
;                  DC after painting.
; Related........:
; Link...........: @@MsdnLink@@ GetDCEx
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_GetDCEx($hWnd, $hRgn, $iFlags)

	Local $Ret = DllCall('user32.dll', 'hwnd', 'GetDCEx', 'hwnd', $hWnd, 'ptr', $hRgn, 'dword', $iFlags)

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_GetDCEx

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

	Local $tData = DllStructCreate('wchar[1024]')
	Local $Ret = DllCall('winspool.drv', 'int', 'GetDefaultPrinterW', 'ptr', DllStructGetPtr($tData), 'dword*', 1024)

    If (@error) Or (Not $Ret[0]) Then
		Return SetError(1 + (_WinAPI_GetLastError() = 0x02), 0, '')
	EndIf
    Return DllStructGetData($tData, 1)
EndFunc   ;==>_WinAPI_GetDefaultPrinter

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetDeviceDriverBaseName
; Description....: Retrieves the base name of the specified device driver.
; Syntax.........: _WinAPI_GetDeviceDriverBaseName ( $hDriver )
; Parameters.....: $hDriver - The load address of the device driver. This value can be retrieved using the _WinAPI_EnumDeviceDrivers() function.
; Return values..: Success  - The base name of the device driver.
;                  Failure  - Empty string and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ GetDeviceDriverBaseName
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_GetDeviceDriverBaseName($hDriver)

	Local $tData = DllStructCreate('wchar[1024]')
	Local $Ret = DllCall(@SystemDir & '\psapi.dll', 'int', 'GetDeviceDriverBaseNameW', 'ptr', $hDriver, 'ptr', DllStructGetPtr($tData), 'dword', 1024)

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, '')
	EndIf
	Return DllStructGetData($tData, 1)
EndFunc   ;==>_WinAPI_GetDeviceDriverBaseName

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetDeviceDriverFileName
; Description....: Retrieves the path available for the specified device driver.
; Syntax.........: _WinAPI_GetDeviceDriverFileName ( $hDriver )
; Parameters.....: $hDriver - The load address of the device driver. This value can be retrieved using the _WinAPI_EnumDeviceDrivers() function.
; Return values..: Success  - The path to the device driver.
;                  Failure  - Empty string and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ GetDeviceDriverFileName
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_GetDeviceDriverFileName($hDriver)

	Local $tData = DllStructCreate('wchar[1024]')
	Local $Ret = DllCall(@SystemDir & '\psapi.dll', 'int', 'GetDeviceDriverFileNameW', 'ptr', $hDriver, 'ptr', DllStructGetPtr($tData), 'dword', 1024)

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, '')
	EndIf
	Return DllStructGetData($tData, 1)
EndFunc   ;==>_WinAPI_GetDeviceDriverFileName

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetDiskFreeSpaceEx
; Description....: Retrieves information about the amount of space that is available on a disk volume.
; Syntax.........: _WinAPI_GetDiskFreeSpaceEx ( $sDrive )
; Parameters.....: $sDrive - The drive to retrieve information, in the format D:, E:, etc.
; Return values..: Success - The array containing the following parameters:
;
;                            [0] - The total number of available free bytes on a disk. If per-user quotas are being used, this value
;                                  may be less than the total number of free bytes on a disk.
;                            [1] - The total number of available bytes on a disk. If per-user quotas are being used, this value
;                                  may be less than the total number of bytes on a disk.
;                            [2] - The total number of free bytes on a disk.
;
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ GetDiskFreeSpaceEx
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_GetDiskFreeSpaceEx($sDrive)

	Local $tData = DllStructCreate('int64;int64;int64')
	Local $Mode = _WinAPI_SetErrorMode($SEM_FAILCRITICALERRORS)
	Local $Ret = DllCall('kernel32.dll', 'int', 'GetDiskFreeSpaceEx', 'str', $sDrive, 'ptr', DllStructGetPtr($tData, 1), 'ptr', DllStructGetPtr($tData, 2), 'ptr', DllStructGetPtr($tData, 3))

	If (@error) Or (Not $Ret[0]) Then
		$Ret = 0
	EndIf
	_WinAPI_SetErrorMode($Mode)
	If Not IsArray($Ret) Then
		Return SetError(1, 0, 0)
	EndIf

	Local $Result[3]

	For $i = 0 To 2
		$Result[$i] = DllStructGetData($tData, $i + 1)
	Next
	Return $Result
EndFunc   ;==>_WinAPI_GetDiskFreeSpaceEx

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetDriveBusType
; Description....: Retrieves a bus type for the specified drive.
; Syntax.........: _WinAPI_GetDriveBusType ( $sDrive )
; Parameters.....: $sDrive - The drive letter to retrieve information, in the format D:, E:, etc.
; Return values..: Success - The bus type constant ($DRIVE_BUS_TYPE_*).
;                  Failure - (-1) and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: This function works with the Plug and Play drivers only.
; Related........:
; Link...........: @@MsdnLink@@ IOCTL_STORAGE_QUERY_PROPERTY
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_GetDriveBusType($sDrive)

	Local $hFile = _WinAPI_CreateFileEx('\\.\' & $sDrive, 3, 0, 0)

	If Not $hFile Then
		Return SetError(1, 0, -1)
	EndIf

	Local $tSPQ = DllStructCreate('ulong PropertyId;ulong QueryType;byte AdditionalParameters[4]')
	Local $tSDD = DllStructCreate('ulong Version;ulong Size;byte DeviceType;byte DeviceTypeModifier;byte RemovableMedia;byte CommandQueueing;ulong VendorIdOffset;ulong ProductIdOffset;ulong ProductRevisionOffset;ulong SerialNumberOffset;ulong BusType;ulong RawPropertiesLength;byte RawDeviceProperties[1]')

	DllStructSetData($tSPQ, 'PropertyId', 0)
	DllStructSetData($tSPQ, 'QueryType', 0)

	Local $Ret = DllCall('kernel32.dll', 'int', 'DeviceIoControl', 'ptr', $hFile, 'dword', $IOCTL_STORAGE_QUERY_PROPERTY, 'ptr', DllStructGetPtr($tSPQ), 'dword', DllStructGetSize($tSPQ), 'ptr', DllStructGetPtr($tSDD), 'dword', DllStructGetSize($tSDD), 'dword*', 0, 'ptr', 0)

	If (@error) Or (Not $Ret[0]) Then
		$Ret = 0
	EndIf
	_WinAPI_CloseHandle($hFile)
	If Not IsArray($Ret) Then
		Return SetError(2, 0, -1)
	EndIf
	Return DllStructGetData($tSDD, 'BusType')
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

	Local $hFile = _WinAPI_CreateFileEx('\\.\PhysicalDrive' & $iDrive, 3, 0x80000000, 0x01)

	If Not $hFile Then
		Return SetError(1, 0, 0)
	EndIf

	Local $tDISK_GEOMETRY_EX = DllStructCreate($tagDISK_GEOMETRY_EX)
	Local $Ret = DllCall('kernel32.dll', 'int', 'DeviceIoControl', 'ptr', $hFile, 'dword', $IOCTL_DISK_GET_DRIVE_GEOMETRY_EX, 'ptr', 0, 'dword', 0, 'ptr', DllStructGetPtr($tDISK_GEOMETRY_EX), 'dword', DllStructGetSize($tDISK_GEOMETRY_EX), 'dword*', 0, 'ptr', 0)

	If (@error) Or (Not $Ret[0]) Then
		$Ret = 0
	EndIf
	_WinAPI_CloseHandle($hFile)
	If Not IsArray($Ret) Then
		Return SetError(2, 0, 0)
	EndIf
	Return $tDISK_GEOMETRY_EX
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

	Local $hFile = _WinAPI_CreateFileEx('\\.\' & $sDrive, 3, 0, 0)

	If Not $hFile Then
		Return SetError(1, 0, 0)
	EndIf

	Local $tSTORAGE_DEVICE_NUMBER = DllStructCreate($tagSTORAGE_DEVICE_NUMBER)
	Local $Ret = DllCall('kernel32.dll', 'int', 'DeviceIoControl', 'ptr', $hFile, 'dword', $IOCTL_STORAGE_GET_DEVICE_NUMBER, 'ptr', 0, 'dword', 0, 'ptr', DllStructGetPtr($tSTORAGE_DEVICE_NUMBER), 'dword', DllStructGetSize($tSTORAGE_DEVICE_NUMBER), 'dword*', 0, 'ptr', 0)

	If (@error) Or (Not $Ret[0]) Then
		$Ret = 0
	EndIf
	_WinAPI_CloseHandle($hFile)
	If Not IsArray($Ret) Then
		Return SetError(2, 0, 0)
	EndIf
	Return $tSTORAGE_DEVICE_NUMBER
EndFunc   ;==>_WinAPI_GetDriveNumber

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetDriveType
; Description....: Determines whether a disk drive is a removable, fixed, CD-ROM, RAM disk, or network drive.
; Syntax.........: _WinAPI_GetDriveType ( [$sDrive] )
; Parameters.....: $sDrive - The drive letter to retrieve information, in the format D:, E:, etc.
; Return values..: Success - The type of drive ($DRIVE_*).
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
	If $sDrive Then
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
; Name...........: _WinAPI_GetErrorMessage
; Description....: Retrieves a text error message for the specified system error code.
; Syntax.........: _WinAPI_GetErrorMessage ( $iCode [, $iLanguage] )
; Parameters.....: $iCode     - The system error code to retrieve a message.
;                  $iLanguage - The language identifier (LCID).
; Return values..: Success    - The requested message.
;                  Failure    - Empty string and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ FormatMessage
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_GetErrorMessage($iCode, $iLanguage = 0)

    Local $tData = DllStructCreate('wchar[1024]')
	Local $Ret = DllCall('kernel32.dll', 'dword', 'FormatMessageW', 'dword', 0x1000, 'ptr', 0, 'dword', $iCode, 'dword', $iLanguage, 'ptr', DllStructGetPtr($tData), 'dword', 1024, 'ptr', 0)

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, '')
	EndIf
	Return StringRegExpReplace(DllStructGetData($tData, 1), '[' & @LF & ',' & @CR & ']*\Z', '')
EndFunc   ;==>_WinAPI_GetErrorMessage

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetErrorMode
; Description....: Retrieves the error mode for the current process.
; Syntax.........: _WinAPI_GetErrorMode ( )
; Parameters.....: None
; Return values..: Success - The process error mode ($SEM_*).
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ GetErrorMode
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_GetErrorMode()

	Local $Ret = DllCall('kernel32.dll', 'uint', 'GetErrorMode')

	If @error Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_GetErrorMode

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetFileAttributes
; Description....: Retrieves file system attributes for a specified file or directory.
; Syntax.........: _WinAPI_GetFileAttributes ( $sFile )
; Parameters.....: $sFile  - The name of the file or directory.
; Return values..: Success - The value contains the attributes of the specified file or directory.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ GetFileAttributes
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_GetFileAttributes($sFile)

	Local $Ret = DllCall('kernel32.dll', 'dword', 'GetFileAttributesW', 'wstr', $sFile)

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_GetFileAttributes

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetFileVersionInfo
; Description....: Retrieves version information for the specified file.
; Syntax.........: _WinAPI_GetFileVersionInfo ( $sFile )
; Parameters.....: $sFile  - The name of the file.
; Return values..: Success - The "byte[n]" structure (buffer) that contains the file-version information.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ GetFileVersionInfo
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_GetFileVersionInfo($sFile)

	Local $Ret, $tData

	$Ret = DllCall('version.dll', 'dword', 'GetFileVersionInfoSizeW', 'wstr', $sFile, 'ptr', 0)
	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	$tData = DllStructCreate('byte[' & $Ret[0] & ']')
	$Ret = DllCall('version.dll', 'int', 'GetFileVersionInfoW', 'wstr', $sFile, 'dword', 0, 'dword', $Ret[0], 'ptr', DllStructGetPtr($tData))
	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $tData
EndFunc   ;==>_WinAPI_GetFileVersionInfo

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
		If Not _WinAPI_AddFontResourceEx($sFont, $FR_NOT_ENUM) Then
			Return SetError(1, 0, '')
		EndIf
	EndIf

	Local $tData = DllStructCreate('wchar[1024]')
	Local $Ret = DllCall('gdi32.dll', 'int', 'GetFontResourceInfoW','wstr', $sFont, 'dword*', 1024, 'ptr', DllStructGetPtr($tData), 'dword', 0x01)

	If (@error) Or (Not $Ret[0]) Then
		$Ret = 0
	EndIf
	If $fForce Then
		_WinAPI_RemoveFontResourceEx($sFont, $FR_NOT_ENUM)
	EndIf
	If Not IsArray($Ret) Then
		Return SetError(1, 0, '')
	EndIf
	Return DllStructGetData($tData, 1)
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
; Name...........: _WinAPI_GetEnhMetaFile
; Description....: Creates a handle that identifies the enhanced-format metafile stored in the specified file.
; Syntax.........: _WinAPI_GetEnhMetaFile ( $sFile )
; Parameters.....: $sFile  - The name of an enhanced metafile (.emf).
; Return values..: Success - Handle to the enhanced metafile.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: When the application no longer needs an enhanced-metafile handle, it should delete the handle by calling the
;                  _WinAPI_DeleteEnhMetaFile() function.
; Related........:
; Link...........: @@MsdnLink@@ GetEnhMetaFile
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_GetEnhMetaFile($sFile)

	Local $Ret = DllCall('gdi32.dll', 'ptr', 'GetEnhMetaFileW', 'wstr', $sFile)

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_GetEnhMetaFile

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetEnhMetaFileBits
; Description....: Retrieves the contents of the specified enhanced-format metafile and copies them into a buffer.
; Syntax.........: _WinAPI_GetEnhMetaFileBits ( $hEmf )
; Parameters.....: $hEmf   - Handle to the enhanced metafile.
; Return values..: Success - The "byte[n]" structure (buffer) that contains the metafile data.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: After the enhanced-metafile bits are retrieved, they can be used to create a memory-based metafile by calling the
;                  _WinAPI_SetEnhMetaFileBits() function.
; Related........:
; Link...........: @@MsdnLink@@ GetEnhMetaFileBits
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_GetEnhMetaFileBits($hEmf)

	Local $Ret, $tData

	$Ret = DllCall('gdi32.dll', 'uint', 'GetEnhMetaFileBits', 'ptr', $hEmf, 'uint', 0, 'ptr', 0)
	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	$tData = DllStructCreate('byte[' & $Ret[0] & ']')
	$Ret = DllCall('gdi32.dll', 'uint', 'GetEnhMetaFileBits', 'ptr', $hEmf, 'uint', $Ret[0], 'ptr', DllStructGetPtr($tData))
	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $tData
EndFunc   ;==>_WinAPI_GetEnhMetaFileBits

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetEnhMetaFileDescription
; Description....: Retrieves an optional text description from an enhanced-format metafile.
; Syntax.........: _WinAPI_GetEnhMetaFileDescription ( $hEmf )
; Parameters.....: $hEmf   - Handle to the enhanced metafile.
; Return values..: Success - If the optional text description does not exist, the return value is 0, otherwise an array that
;                            contains the following information.
;
;                            [0] - Application name
;                            [1] - Picture name
;
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ GetEnhMetaFileDescription
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_GetEnhMetaFileDescription($hEmf)

	Local $tData = DllStructCreate('wchar[1024]'), $pData = DllStructGetPtr($tData)
	Local $Ret = DllCall('gdi32.dll', 'uint', 'GetEnhMetaFileDescriptionW', 'ptr', $hEmf, 'uint', 1024, 'ptr', $pData)

	If (@error) Or ($Ret[0] = 0xFFFF) Then
		Return SetError(1, 0, 0)
	Else
		If Not $Ret[0] Then
			Return 0
		EndIf
	EndIf

	Local $aData = _WinAPI_StructToArray($pData)

	If Not IsArray($aData) Then
		Return SetError(1, 0, 0)
	EndIf

	Local $Result[2]

	For $i = 0 To 1
		If $aData[0] > $i Then
			$Result[$i] = $aData[$i + 1]
		Else
			$Result[$i] = ''
		EndIf
	Next
	Return $Result
EndFunc   ;==>_WinAPI_GetEnhMetaFileDescription

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetEnhMetaFileDimension
; Description....: Retrieves a dimension for the specified enhanced-format metafile.
; Syntax.........: _WinAPI_GetEnhMetaFileHeader ( $hEmf )
; Parameters.....: $hEmf   - Handle to the enhanced metafile for which a dimension is to be retrieved.
; Return values..: Success - $tagSIZE structure that contains the enhanced metafile dimension.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: None
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_GetEnhMetaFileDimension($hEmf)

	Local $tENHMETAHEADER = _WinAPI_GetEnhMetaFileHeader($hEmf)

	If @error Then
		Return SetError(1, 0, 0)
	EndIf

	Local $tSIZE = DllStructCreate($tagSIZE)

	DllStructSetData($tSIZE, 1, Round((DllStructGetData($tENHMETAHEADER, 'rcFrame', 3) - DllStructGetData($tENHMETAHEADER, 'rcFrame', 1)) * DllStructGetData($tENHMETAHEADER, 'Device', 1) / DllStructGetData($tENHMETAHEADER, 'Millimeters', 1) / 100))
	DllStructSetData($tSIZE, 2, Round((DllStructGetData($tENHMETAHEADER, 'rcFrame', 4) - DllStructGetData($tENHMETAHEADER, 'rcFrame', 2)) * DllStructGetData($tENHMETAHEADER, 'Device', 2) / DllStructGetData($tENHMETAHEADER, 'Millimeters', 2) / 100))

	Return $tSIZE
EndFunc   ;==>_WinAPI_GetEnhMetaFileDimension

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetEnhMetaFileHeader
; Description....: Retrieves the record containing the header for the specified enhanced-format metafile.
; Syntax.........: _WinAPI_GetEnhMetaFileHeader ( $hEmf )
; Parameters.....: $hEmf   - Handle to the enhanced metafile for which the header is to be retrieved.
; Return values..: Success - $tagENHMETAHEADER structure that contains the header record, @extended flag will be contain the
;                            the number of bytes copied to the structure, in bytes.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ GetEnhMetaFileHeader
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_GetEnhMetaFileHeader($hEmf)

	Local $tENHMETAHEADER = DllStructCreate($tagENHMETAHEADER)
	Local $Ret = DllCall('gdi32.dll', 'uint', 'GetEnhMetaFileHeader', 'ptr', $hEmf, 'uint', DllStructGetSize($tENHMETAHEADER), 'ptr', DllStructGetPtr($tENHMETAHEADER))

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return SetError(0, $Ret[0], $tENHMETAHEADER)
EndFunc   ;==>_WinAPI_GetEnhMetaFileHeader

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetFileSizeOnDisk
; Description....: Retrieves the file allocation size on disk.
; Syntax.........: _WinAPI_GetFileSizeOnDisk ( $sFile )
; Parameters.....: $sFile  - The name of the file to retrieve allocation size.
; Return values..: Success - The allocation size, in bytes. This value is a multiple of the sector or cluster size of the nderlying
;                            physical device.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: None
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_GetFileSizeOnDisk($sFile)

	$sFile = _WinAPI_PathSearchAndQualify($sFile, 1)
	If Not $sFile Then
		Return SetError(1, 0, 0)
	EndIf

    Local $aRet = DllCall('kernel32.dll', 'int', 'GetDiskFreeSpaceW', 'wstr', StringLeft($sFile, 2), 'dword*', 0, 'dword*', 0, 'dword*', 0, 'dword*', 0)

    If (@error) Or (Not $aRet[0]) Then
        Return SetError(1, 0, 0)
    EndIf
    Return Ceiling(FileGetSize($sFile) / ($aRet[2] * $aRet[3])) * ($aRet[2] * $aRet[3])
EndFunc   ;==>_WinAPI_GetFileSizeOnDisk

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetFileTitle
; Description....: Retrieves the name of the specified file.
; Syntax.........: _WinAPI_GetFileTitle ( $sFile )
; Parameters.....: $sFile  - The name and location of a file.
; Return values..: Success - The name of the file.
;                  Failure - Empty string and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: _WinAPI_GetFileTitle() should only be called with legal file names; using an illegal file name has an undefined result.
;
;                  _WinAPI_GetFileTitle() returns the string that the system would use to display the file name to the user.
;                  The display name includes an extension only if that is the user's preference for displaying file names. This means
;                  that the returned string may not accurately identify the file if it is used in calls to file system functions.
; Related........:
; Link...........: @@MsdnLink@@ GetFileTitle
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_GetFileTitle($sFile)

	Local $tData = DllStructCreate('wchar[1024]')
	Local $Ret = DllCall('comdlg32.dll', 'short', 'GetFileTitleW', 'wstr', $sFile, 'ptr', DllStructGetPtr($tData), 'word', 1024)

	If (@error) Or ($Ret[0]) Then
		Return SetError(1, 0, '')
	EndIf
	Return DllStructGetData($tData, 1)
EndFunc   ;==>_WinAPI_GetFileTitle

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
	Return BitShift(BitAND(__RGB($iRGB), 0x00FF00), 8)
EndFunc   ;==>_WinAPI_GetGValue

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetHandleInformation
; Description....: Retrieves certain properties of an object handle.
; Syntax.........: _WinAPI_GetHandleInformation ( $hObject )
; Parameters.....: $hObject - Handle to an object whose information is to be retrieved.
; Return values..: Success  - The value that specifies the properties of the object handle ($HANDLE_FLAG_*).
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

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[2]
EndFunc   ;==>_WinAPI_GetHandleInformation

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetHGlobalFromStream
; Description....: Retrieves the global memory handle to a stream.
; Syntax.........: _WinAPI_GetHGlobalFromStream ( $hStream )
; Parameters.....: $hStream - Pointer to the stream object previously created by a call to the _WinAPI_CreateStreamOnHGlobal() function.
; Return values..: Success  - Pointer to the current memory handle used by the specified stream object.
;                  Failure  - 0 and sets the @error flag to non-zero, @extended flag may contain the system error code.
; Author.........: Yashied
; Modified.......:
; Remarks........: This function can be called only from within the same process from which the byte array was created.
; Related........:
; Link...........: @@MsdnLink@@ GetHGlobalFromStream
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_GetHGlobalFromStream($hStream)

	Local $Ret = DllCall('ole32.dll', 'uint', 'GetHGlobalFromStream', 'ptr', $hStream, 'ptr*', 0)

	If @error Then
		Return SetError(1, 0, 0)
	Else
		If $Ret[0] Then
			Return SetError(1, $Ret[0], 0)
		EndIf
	EndIf
	Return $Ret[2]
EndFunc   ;==>_WinAPI_GetHGlobalFromStream

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

	Local $tICONINFO = DllStructCreate($tagICONINFO)
	Local $Ret = DllCall('user32.dll', 'int', 'GetIconInfo', 'ptr', $hIcon, 'ptr', DllStructGetPtr($tICONINFO))

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf

	Local $tSIZE = _WinAPI_GetBitmapDimension(DllStructGetData($tICONINFO, 5))

	For $i = 4 To 5
		_WinAPI_DeleteObject(DllStructGetData($tICONINFO, $i))
	Next
	If Not IsDllStruct($tSIZE) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $tSIZE
EndFunc   ;==>_WinAPI_GetIconDimension

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

	If (@error) Or (Not $Ret[0]) Then
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
	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	$Ret = DllCall('user32.dll', 'long', 'GetKeyboardLayout', 'long', $Ret[0])
	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_GetKeyboardLayout

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetKeyboardLayoutList
; Description....: Retrieves the all input locale identifiers corresponding to the current set of input locales in the system.
; Syntax.........: _WinAPI_GetKeyboardLayoutList ( )
; Parameters.....: None
; Return values..: Success - The array of input locale identifiers. The zeroth array element contains the number of identifiers.
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
	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf

	Local $tData = DllStructCreate('long[' & $Ret[0] & ']')

	$Ret = DllCall('user32.dll', 'int', 'GetKeyboardLayoutList', 'int', $Ret[0], 'ptr', DllStructGetPtr($tData))
	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf

	Local $List[$Ret[0] + 1] = [$Ret[0]]

	For $i = 1 To $List[0]
		$List[$i] = DllStructGetData($tData, 1, $i)
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

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $tData
EndFunc   ;==>_WinAPI_GetKeyboardState

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetKeyboardType
; Description....: Retrieves information about the current keyboard.
; Syntax.........: _WinAPI_GetKeyboardType ( $iType )
; Parameters.....: $iType   - The type of keyboard information to be retrieved, valid values:
;                  |0 - Keyboard type.
;                  |1 - Keyboard subtype (original equipment manufacturer (OEM)-dependent value).
;                  |2 - The number of function keys on the keyboard.
; Return values..: Success  - The value that specifies the requested information. If $iType is 0, return value may be one of the following values.
;                  |1 - IBM PC/XT or compatible (83-key) keyboard.
;                  |2 - Olivetti "ICO" (102-key) keyboard.
;                  |3 - IBM PC/AT (84-key) or similar keyboard.
;                  |4 - IBM enhanced (101- or 102-key) keyboard.
;                  |5 - Nokia 1050 and similar keyboards.
;                  |6 - Nokia 9140 and similar keyboards.
;                  |7 - Japanese keyboard.
;                  Failure  - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: When a single USB keyboard is connected to the computer, this function returns the code 81.
; Related........:
; Link...........: @@MsdnLink@@ GetKeyboardType
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_GetKeyboardType($iType)

	Local $Ret = DllCall('user32.dll', 'int', 'GetKeyboardType', 'int', $iType)

	If @error Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_GetKeyboardType

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

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, '')
	EndIf
	Return DllStructGetData($tData, 1)
EndFunc   ;==>_WinAPI_GetKeyNameText

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetKeyState
; Description....: Retrieves the status of the specified virtual key.
; Syntax.........: _WinAPI_GetKeyState ( $vKey )
; Parameters.....: $vKey   - Specifies a virtual key ($VK_*). If the desired virtual key is a letter or digit (A through Z,
;                            a through z, or 0 through 9).
; Return values..: Success - The value that specifies the status of the specified virtual key. If the high-order bit is 1, the key is
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

Func _WinAPI_GetKeyState($vKey)

	Local $Ret = DllCall('user32.dll', 'int', 'GetKeyState', 'int', $vKey)

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
;
;                            [0] - The transparency color key to be used when composing the layered window. All pixels painted
;                                  by the window in this color will be transparent. This can be 0 if the argument is not needed.
;                            [1] - The Alpha value used to describe the opacity of the layered window. When the variable is 0,
;                                  the window is completely transparent. When the variable is 255, the window is opaque.
;                                  This can be 0 if the argument is not needed.
;                            [2] - The layering flag ($LWA_*).
;
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: ProgAndy
; Modified.......: Yashied
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ GetLayeredWindowAttributes
; Example........: Yes
; ===============================================================================================================================

#cs

Func _WinAPI_GetLayeredWindowAttributes($hWnd)

	Local $Ret = DllCall('user32.dll', 'int', 'GetLayeredWindowAttributes', 'hwnd', $hWnd, 'long*', 0, 'byte*', 0, 'long*', 0)

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf

	Local $Result[3]

	$Result[0] = __RGB($Ret[2])
	$Result[1] = $Ret[3]
	$Result[2] = $Ret[4]

	Return $Result
EndFunc   ;==>_WinAPI_GetLayeredWindowAttributes

#ce

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetLocaleInfo
; Description....: Retrieves information about a locale specified by identifier.
; Syntax.........: _WinAPI_GetLocaleInfo ( $LCID, $iType )
; Parameters.....: $LCID   - Locale identifier for which to retrieve information or one of the following predefined values.
;
;                            $LOCALE_CUSTOM_DEFAULT
;                            $LOCALE_CUSTOM_UI_DEFAULT
;                            $LOCALE_CUSTOM_UNSPECIFIED
;
;                            $LOCALE_INVARIANT
;                            $LOCALE_SYSTEM_DEFAULT
;                            $LOCALE_USER_DEFAULT
;
;                  $iType  - The one of the locale information constants ($LOCALE_*) to retrieve.
; Return values..: Success - String containing the requested information.
;                  Failure - Empty string and sets the @error flag to non-zero.
; Author.........: WideBoyDixon
; Modified.......: Yashied
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ GetLocaleInfo
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_GetLocaleInfo($LCID, $iType)

	Local $tData = DllStructCreate('wchar[1024]')
	Local $Ret = DllCall('kernel32.dll', 'int', 'GetLocaleInfoW', 'long', $LCID, 'dword', $iType, 'ptr', DllStructGetPtr($tData), 'int', 1024)

    If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, '')
	EndIf
    Return DllStructGetData($tData, 1)
EndFunc   ;==>_WinAPI_GetLocaleInfo

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetLogicalDrives
; Description....: Retrieves a bitmask representing the currently available disk drives.
; Syntax.........: _WinAPI_GetLogicalDrives ( )
; Parameters.....: None
; Return values..: Success - The value is a bitmask representing the currently available disk drives. Bit position 0 (the least-significant bit)
;                            is drive A, bit position 1 is drive B, bit position 2 is drive C, and so on.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ GetLogicalDrives
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_GetLogicalDrives()

	Local $Ret = DllCall('kernel32.dll', 'dword', 'GetLogicalDrives')

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_GetLogicalDrives

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetModuleFileName
; Description....: Retrieves the fully-qualified path for the file that contains the specified module.
; Syntax.........: _WinAPI_GetModuleFileName( $hModule )
; Parameters.....: $hModule - Handle to the loaded module whose path is being requested. If this parameter is 0, function retrieves
;                             the path of the executable file of the current process.
; Return values..: Success  - The fully-qualified path of the module.
;                  Failure  - Empty string and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ GetModuleFileName
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_GetModuleFileName($hModule)

	Local $tData = DllStructCreate('wchar[1024]')
	Local $Ret = DllCall('kernel32.dll', 'dword', 'GetModuleFileNameW', 'ptr', $hModule, 'ptr', DllStructGetPtr($tData), 'dword', 1024)

	If (@error) Or (Not $Ret[0]) Then
		$Ret = 0
	EndIf
	Return DllStructGetData($tData, 1)
EndFunc   ;==>_WinAPI_GetModuleFileName

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetModuleHandleEx
; Description....: Retrieves a module handle for the specified module.
; Syntax.........: _WinAPI_GetModuleHandleEx ( $sModule [, $iFlags] )
; Parameters.....: $sModule - The name of the loaded module (either a .dll or .exe file), or a pointer to an address in the module
;                             (if $GET_MODULE_HANDLE_EX_FLAG_FROM_ADDRESS flag is specified). If this parameter is 0 or empty string,
;                             the function returns a handle to the file used to create the calling process (.exe file).
;                  $iFlags  - This parameter can be one or more of the following values.
;
;                             $GET_MODULE_HANDLE_EX_FLAG_FROM_ADDRESS
;                             $GET_MODULE_HANDLE_EX_FLAG_PIN
;                             $GET_MODULE_HANDLE_EX_FLAG_UNCHANGED_REFCOUNT
;                             $GET_MODULE_HANDLE_EX_FLAG_DEFAULT
;
; Return values..: Success  - Handle to the specified module.
;                  Failure  - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ GetModuleHandleEx
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_GetModuleHandleEx($sModule, $iFlags = 0)

	Local $TypeOfModule = 'ptr'

	If IsString($sModule) Then
		If StringStripWS($sModule, 3) Then
			$TypeOfModule = 'wstr'
		Else
			$sModule = 0
		EndIf
	EndIf

	Local $Ret = DllCall('kernel32.dll', 'int', 'GetModuleHandleExW', 'dword', $iFlags, $TypeOfModule, $sModule, 'ptr*', 0)

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[3]
EndFunc   ;==>_WinAPI_GetModuleHandleEx

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetObjectEx
; Description....: Retrieves information for the specified graphics object.
; Syntax.........: _WinAPI_GetObjectEx ( $hObject )
; Parameters.....: $hObject - Handle to the graphics object of interest. This can be a handle to one of the following: a logical
;                             bitmap, a brush, a font, a palette, or a pen.
; Return values..: Success  - The structure that depends on the graphics object ($hObject) and @extended flag will contain the value
;                             that identifies the object ($OBJ_*). You do not need to create the desired structure, _WinAPI_GetObjectEx()
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

	$Ret = DllCall('gdi32.dll', 'int', 'GetObjectW', 'int', $hObject, 'int', 0, 'ptr', 0)
	If (@error) Or (Not $Ret[0]) Then
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
			If $Size > 12 Then
				$tData = DllStructCreate($tagEXTLOGPEN)
				$Entry = BitShift($Size - DllStructGetSize($tData), 2)
				If $Entry Then
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
	$Ret = DllCall('gdi32.dll', 'int', 'GetObjectW', 'int', $hObject, 'int', DllStructGetSize($tData), 'ptr', DllStructGetPtr($tData))
	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return SetError(0, $Type, $tData)
EndFunc   ;==>_WinAPI_GetObjectEx

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetObjectType
; Description....: Retrieves the type of the specified object.
; Syntax.........: _WinAPI_GetObjectType ( $hObject )
; Parameters.....: $hObject - Handle to the graphics object.
; Return values..: Success  - The value identifies the object ($OBJ_*).
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

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_GetObjectType

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetOutlineTextMetrics
; Description....: Retrieves text metrics for TrueType fonts.
; Syntax.........: _WinAPI_GetOutlineTextMetrics ( $hDC )
; Parameters.....: $hDC    - Handle to the device context.
; Return values..: Success - $tagOUTLINETEXTMETRIC structure that contains the text metrics.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ GetOutlineTextMetrics
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_GetOutlineTextMetrics($hDC)

	Local $Ret, $tOLTM

	$Ret = DllCall('gdi32.dll', 'uint', 'GetOutlineTextMetricsW', 'hwnd', $hDC, 'uint', 0, 'ptr', 0)
	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
;	$tOLTM = DllStructCreate($tagOUTLINETEXTMETRIC)
	$tOLTM = DllStructCreate('uint otmSize;long tmHeight;long tmAscent;long tmDescent;long tmInternalLeading;long tmExternalLeading;long tmAveCharWidth;long tmMaxCharWidth;long tmWeight;long tmOverhang;long tmDigitizedAspectX;long tmDigitizedAspectY;wchar tmFirstChar;wchar tmLastChar;wchar tmDefaultChar;wchar tmBreakChar;byte tmItalic;byte tmUnderlined;byte tmStruckOut;byte tmPitchAndFamily;byte tmCharSet;byte otmFiller[4];' & $tagPANOSE & 'uint otmSelection;uint otmType;int otmCharSlopeRise;int otmCharSlopeRun;int otmItalicAngle;uint otmEMSquare;int otmAscent;int otmDescent;uint otmLineGap;uint otmCapEmHeight;uint otmXHeight;long otmFontBox[4];int otmMacAscent;int otmMacDescent;uint otmMacLineGap;uint otmMinimumPPEM;long otmSubscriptSize[2];long otmSubscriptOffset[2];long otmSuperscriptSize[2];long otmSuperscriptOffset[2];uint otmStrikeoutSize;int otmStrikeoutPosition;int otmUnderscoreSize;int otmUnderscorePosition;uint otmFamilyName;uint otmFaceName;uint otmStyleName;uint otmFullName')
;	$tOLTM = DllStructCreate($tagOUTLINETEXTMETRIC & 'byte[' & ($Ret[0] - DllStructGetSize($tOLTM)) & ']')
	$tOLTM = DllStructCreate('uint otmSize;long tmHeight;long tmAscent;long tmDescent;long tmInternalLeading;long tmExternalLeading;long tmAveCharWidth;long tmMaxCharWidth;long tmWeight;long tmOverhang;long tmDigitizedAspectX;long tmDigitizedAspectY;wchar tmFirstChar;wchar tmLastChar;wchar tmDefaultChar;wchar tmBreakChar;byte tmItalic;byte tmUnderlined;byte tmStruckOut;byte tmPitchAndFamily;byte tmCharSet;byte otmFiller[4];' & $tagPANOSE & 'uint otmSelection;uint otmType;int otmCharSlopeRise;int otmCharSlopeRun;int otmItalicAngle;uint otmEMSquare;int otmAscent;int otmDescent;uint otmLineGap;uint otmCapEmHeight;uint otmXHeight;long otmFontBox[4];int otmMacAscent;int otmMacDescent;uint otmMacLineGap;uint otmMinimumPPEM;long otmSubscriptSize[2];long otmSubscriptOffset[2];long otmSuperscriptSize[2];long otmSuperscriptOffset[2];uint otmStrikeoutSize;int otmStrikeoutPosition;int otmUnderscoreSize;int otmUnderscorePosition;uint otmFamilyName;uint otmFaceName;uint otmStyleName;uint otmFullName;byte[' & ($Ret[0] - DllStructGetSize($tOLTM)) & ']')
	$Ret = DllCall('gdi32.dll', 'uint', 'GetOutlineTextMetricsW', 'hwnd', $hDC, 'uint', $Ret[0], 'ptr', DllStructGetPtr($tOLTM))
	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $tOLTM
EndFunc   ;==>_WinAPI_GetOutlineTextMetrics

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetParentProcess
; Description....: Retrieves the PID of the parent process for the specified process.
; Syntax.........: _WinAPI_GetParentProcess ( [$PID] )
; Parameters.....: $PID    - The PID of the process. Default (0) is the current process.
; Return values..: Success - The PID of the parent process.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: None
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_GetParentProcess($PID = 0)

	If Not $PID Then
		$PID = _WinAPI_GetCurrentProcessID()
		If Not $PID Then
			Return SetError(1, 0, 0)
		EndIf
	EndIf

	Local $hSnapshot = DllCall('kernel32.dll', 'ptr', 'CreateToolhelp32Snapshot', 'dword', 0x00000002, 'dword', 0)

	If (@error) Or (Not $hSnapshot[0]) Then
		Return SetError(1, 0, 0)
	EndIf

	Local $tPROCESSENTRY32 = DllStructCreate('dword Size;dword Usage;dword ProcessID;ulong_ptr DefaultHeapID;dword ModuleID;dword Threads;dword ParentProcessID;long PriClassBase;dword Flags;wchar ExeFile[260]')
	Local $pPROCESSENTRY32 = DllStructGetPtr($tPROCESSENTRY32)
	Local $Ret, $Result = 0

	$hSnapshot = $hSnapshot[0]
	DllStructSetData($tPROCESSENTRY32, 'Size', DllStructGetSize($tPROCESSENTRY32))
	$Ret = DllCall('kernel32.dll', 'int', 'Process32FirstW', 'ptr', $hSnapshot, 'ptr', $pPROCESSENTRY32)
	While (Not @error) And ($Ret[0])
		If DllStructGetData($tPROCESSENTRY32, 'ProcessID') = $PID Then
			$Result = DllStructGetData($tPROCESSENTRY32, 'ParentProcessID')
			ExitLoop
		EndIf
		$Ret = DllCall('kernel32.dll', 'int', 'Process32NextW', 'ptr', $hSnapshot, 'ptr', $pPROCESSENTRY32)
	WEnd
	_WinAPI_CloseHandle($hSnapshot)
	If Not $Result Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Result
EndFunc   ;==>_WinAPI_GetParentProcess

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetPerformanceInfo
; Description....: Retrieves the performance information.
; Syntax.........: _WinAPI_GetPerformanceInfo ( )
; Parameters.....: None
; Return values..: Success - The array containing the following information:
;
;                            [0] - The memory that currently committed by the system, in bytes.
;                            [1] - The current maximum memory that can be committed by the system without extending the paging file(s), in bytes.
;                            [2] - The maximum memory that were simultaneously in the committed state since the last system reboot, in bytes.
;                            [3] - The amount of actual physical memory, in bytes.
;                            [4] - The amount of physical memory currently available, in bytes.
;                            [5] - The amount of system cache memory, in bytes.
;                            [6] - The sum of the memory currently in the paged and nonpaged kernel pools, in bytes.
;                            [7] - The memory currently in the paged kernel pool, in bytes.
;                            [8] - The memory currently in the nonpaged kernel pool, in bytes.
;                            [9] - The size of a page, in bytes.
;                           [10] - The current number of open handles.
;                           [11] - The current number of processes.
;                           [12] - The current number of threads.
;
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ GetPerformanceInfo
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_GetPerformanceInfo()

	Local $tPI = DllStructCreate('dword;ulong_ptr;ulong_ptr;ulong_ptr;ulong_ptr;ulong_ptr;ulong_ptr;ulong_ptr;ulong_ptr;ulong_ptr;ulong_ptr;dword;dword;dword')
	Local $Ret = DllCall(@SystemDir & '\psapi.dll', 'int', 'GetPerformanceInfo', 'ptr', DllStructGetPtr($tPI), 'dword', DllStructGetSize($tPI))

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf

	Local $Result[13]

	For $i = 0 To 12
		$Result[$i] = DllStructGetData($tPI, $i + 2)
	Next
	For $i = 0 To 8
		$Result[$i] *= $Result[9]
	Next
	Return $Result
EndFunc   ;==>_WinAPI_GetPerformanceInfo

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

	If (@error) Or ($Ret[0] = 0xFFFFFFFF) Then
		Return SetError(1, 0, -1)
	EndIf
	Return __RGB($Ret[0])
EndFunc   ;==>_WinAPI_GetPixel

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetPolyFillMode
; Description....: Retrieves the current polygon fill mode.
; Syntax.........: _WinAPI_GetPolyFillMode ( $hDC )
; Parameters.....: $hDC    - Handle to the device context.
; Return values..: Success - The polygon fill mode, which can be one of the following values.
;
;                            $ALTERNATE
;                            $WINDING
;
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ GetPolyFillMode
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_GetPolyFillMode($hDC)

	Local $Ret = DllCall('gdi32.dll', 'int', 'GetPolyFillMode', 'hwnd', $hDC)

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_GetPolyFillMode

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetPosFromRect
; Description....: Interprets the coordinates of the rectangle as offset and position coordinates.
; Syntax.........: _WinAPI_GetPosFromRect ( $tRECT )
; Parameters.....: $tRECT  - $tagRECT structure that contains the logical coordinates of the rectangle.
; Return values..: Success - The array containing the following parameters:
;
;                            [0] - The x-coordinate of the upper-left corner of the rectangle.
;                            [1] - The y-coordinate of the upper-left corner of the rectangle.
;                            [2] - The width of the rectangle.
;                            [3] - The height of the rectangle.
;
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: This function is inverse to the _WinAPI_CreateRectEx().
; Related........:
; Link...........: None
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_GetPosFromRect($tRECT)

	Local $Result[4]

	For $i = 0 To 3
		$Result[$i] = DllStructGetData($tRECT, $i + 1)
		If @error Then
			Return SetError(1, 0, 0)
		EndIf
	Next
	For $i = 2 To 3
		$Result[$i] -= $Result[$i - 2]
	Next
	Return $Result
EndFunc   ;==>_WinAPI_GetPosFromRect

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

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_GetProcAddress

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetProcessCommandLine
; Description....: Retrieves the command-line string for the specified process.
; Syntax.........: _WinAPI_GetProcessCommandLine ( [$PID] )
; Parameters.....: $PID    - The PID of the process. Default (0) is the current process.
; Return values..: Success - The command-line string.
;                  Failure - Empty string and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: This function uses undocumented API functions and may stop working properly in future versions of Windows.
;
;                  Using this function for some processes may require full access rights. Use _WinAPI_AdjustTokenPrivileges()
;                  function to enable SeDebugPrivilege privilege before calling _WinAPI_GetProcessCommandLine().
; Related........:
; Link...........: None
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_GetProcessCommandLine($PID = 0)

	If Not $PID Then
		$PID = _WinAPI_GetCurrentProcessID()
		If Not $PID Then
			Return SetError(1, 0, '')
		EndIf
	EndIf

	Local $Ret, $hProcess, $Error = True

	$Ret = DllCall('kernel32.dll', 'ptr', 'OpenProcess', 'dword', 0x00000410, 'int', 0, 'dword', $PID)
	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, '')
	EndIf

	$hProcess = $Ret[0]

	Local $tPBI = DllStructCreate('ulong_ptr Reserved1;ptr PebBaseAddress;ulong_ptr Reserved2[2];ulong_ptr UniqueProcessId;ulong_ptr Reserved3')
	Local $tUPP = DllStructCreate('byte Reserved1[16];ulong_ptr Reserved2[12];ptr ImagePathName;ptr CommandLine')
	Local $tCMD = DllStructCreate('wchar[1024]')
	Local $tPEB

	If @OSArch = 'X86' Then
		$tPEB = DllStructCreate('byte Reserved1[2];byte BeingDebugged;byte Reserved2;ulong_ptr Reserved3[2];ptr LoaderData;ptr ProcessParameters;byte Reserved4[104];ulong_ptr Reserved5[52];ptr PostProcessInitRoutine;byte Reserved6[128];ulong_ptr Reserved7;ulong SessionId')
	Else
		$tPEB = DllStructCreate('byte Reserved1[2];byte BeingDebugged;byte Reserved2[21];ptr LoaderData;ptr ProcessParameters;byte Reserved3[520];ptr PostProcessInitRoutine;byte Reserved4[136];ulong SessionId')
	EndIf

	Do
		$Ret = DllCall('ntdll.dll', 'int', 'NtQueryInformationProcess', 'ptr', $hProcess, 'ulong', 0, 'ptr', DllStructGetPtr($tPBI), 'ulong', DllStructGetSize($tPBI), 'ulong*', 0)
		If (@error) Or ($Ret[0]) Then
			ExitLoop
		EndIf
		$Ret = DllCall('kernel32.dll', 'int', 'ReadProcessMemory', 'ptr', $hProcess, 'ptr', DllStructGetData($tPBI, 'PebBaseAddress'), 'ptr', DllStructGetPtr($tPEB), 'ulong_ptr', DllStructGetSize($tPEB), 'ulong_ptr*', 0)
		If (@error) Or (Not $Ret[0]) Or (Not $Ret[5]) Then
			ExitLoop
		EndIf
		$Ret = DllCall('kernel32.dll', 'int', 'ReadProcessMemory', 'ptr', $hProcess, 'ptr', DllStructGetData($tPEB, 'ProcessParameters'), 'ptr', DllStructGetPtr($tUPP), 'ulong_ptr', DllStructGetSize($tUPP), 'ulong_ptr*', 0)
		If (@error) Or (Not $Ret[0]) Or (Not $Ret[5]) Then
			ExitLoop
		EndIf
		$Ret = DllCall('kernel32.dll', 'int', 'ReadProcessMemory', 'ptr', $hProcess, 'ptr', DllStructGetData($tUPP, 'CommandLine'), 'ptr', DllStructGetPtr($tCMD), 'ulong_ptr', DllStructGetSize($tCMD), 'ulong_ptr*', 0)
		If (@error) Or (Not $Ret[0]) Or (Not $Ret[5]) Then
			ExitLoop
		EndIf
		$Error = 0
	Until 1
	_WinAPI_CloseHandle($hProcess)
	If $Error Then
		Return SetError(1, 0, '')
	EndIf
	Return StringStripWS(_WinAPI_PathGetArgs(DllStructGetData($tCMD, 1)), 3)
EndFunc   ;==>_WinAPI_GetProcessCommandLine

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetProcessFileName
; Description....: Retrieves the fully-qualified path of the executable file for the specified process.
; Syntax.........: _WinAPI_GetProcessFileName ( [$PID] )
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

Func _WinAPI_GetProcessFileName($PID = 0)

	If Not $PID Then
		$PID = _WinAPI_GetCurrentProcessID()
		If Not $PID Then
			Return SetError(1, 0, '')
		EndIf
	EndIf

	Local $hProcess = DllCall('kernel32.dll', 'ptr', 'OpenProcess', 'dword', 0x00000410, 'int', 0, 'dword', $PID)

	If (@error) Or (Not $hProcess[0]) Then
		Return SetError(1, 0, '')
	EndIf

	Local $tPath = DllStructCreate('wchar[1024]')
	Local $Ret = DllCall(@SystemDir & '\psapi.dll', 'int', 'GetModuleFileNameExW', 'ptr', $hProcess[0], 'ptr', 0, 'ptr', DllStructGetPtr($tPath), 'int', 1024)

	If (@error) Or (Not $Ret[0]) Then
		$Ret = 0
	EndIf
	_WinAPI_CloseHandle($hProcess[0])
	If Not IsArray($Ret) Then
		Return SetError(1, 0, '')
	EndIf
	Return DllStructGetData($tPath, 1)
EndFunc   ;==>_WinAPI_GetProcessFileName

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetProcessHandleCount
; Description....: Retrieves the number of open handles that belong to the specified process.
; Syntax.........: _WinAPI_GetProcessHandleCount ( [$PID] )
; Parameters.....: $PID    - The PID of the process. Default (0) is the current process.
; Return values..: Success - The number of open handles.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ GetProcessHandleCount
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_GetProcessHandleCount($PID = 0)

	If Not $PID Then
		$PID = _WinAPI_GetCurrentProcessID()
		If Not $PID Then
			Return SetError(1, 0, 0)
		EndIf
	EndIf

	Local $hProcess = DllCall('kernel32.dll', 'ptr', 'OpenProcess', 'dword', 0x00000400, 'int', 0, 'dword', $PID)

	If (@error) Or (Not $hProcess[0]) Then
		Return SetError(1, 0, 0)
	EndIf

	Local $Ret = DllCall('kernel32.dll', 'int', 'GetProcessHandleCount', 'ptr', $hProcess[0], 'dword*', 0)

	If (@error) Or (Not $Ret[0]) Then
		$Ret = 0
	EndIf
	_WinAPI_CloseHandle($hProcess[0])
	If Not IsArray($Ret) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[2]
EndFunc   ;==>_WinAPI_GetProcessHandleCount

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetProcessIoCounters
; Description....: Retrieves accounting information for all I/O operations performed by the specified process.
; Syntax.........: _WinAPI_GetProcessIoCounters ( [$PID] )
; Parameters.....: $PID    - The PID of the process. Default (0) is the current process.
; Return values..: Success - The array that contains the following information.
;
;                            [0] - The number of read operations performed.
;                            [1] - The number of write operations performed.
;                            [2] - The number of I/O operations performed, other than read and write operations.
;                            [3] - The number of bytes read.
;                            [4] - The number of bytes written.
;                            [5] - The number of bytes transferred during operations other than read and write operations.
;
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ GetProcessIoCounters
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_GetProcessIoCounters($PID = 0)

	If Not $PID Then
		$PID = _WinAPI_GetCurrentProcessID()
		If Not $PID Then
			Return SetError(1, 0, 0)
		EndIf
	EndIf

	Local $hProcess = DllCall('kernel32.dll', 'ptr', 'OpenProcess', 'dword', 0x00000400, 'int', 0, 'dword', $PID)

	If (@error) Or (Not $hProcess[0]) Then
		Return SetError(1, 0, 0)
	EndIf

	Local $tIO_COUNTERS = DllStructCreate('uint64[6]')
	Local $Ret = DllCall('kernel32.dll', 'int', 'GetProcessIoCounters', 'ptr', $hProcess[0], 'ptr', DllStructGetPtr($tIO_COUNTERS))

	If (@error) Or (Not $Ret[0]) Then
		$Ret = 0
	EndIf
	_WinAPI_CloseHandle($hProcess[0])
	If Not IsArray($Ret) Then
		Return SetError(1, 0, 0)
	EndIf

	Local $Result[6]

	For $i = 0 To 5
		$Result[$i] = DllStructGetData($tIO_COUNTERS, 1, $i + 1)
	Next
	Return $Result
EndFunc   ;==>_WinAPI_GetProcessIoCounters

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetProcessMemoryInfo
; Description....: Retrieves information about the memory usage of the specified process.
; Syntax.........: _WinAPI_GetProcessMemoryInfo ( [$PID] )
; Parameters.....: $PID    - The PID of the process. Default (0) is the current process.
; Return values..: Success - The array that contains the following information.
;
;                            [0] - The number of page faults.
;                            [1] - The peak working set size, in bytes.
;                            [2] - The current working set size, in bytes.
;                            [3] - The peak paged pool usage, in bytes.
;                            [4] - The current paged pool usage, in bytes.
;                            [5] - The peak nonpaged pool usage, in bytes.
;                            [6] - The current nonpaged pool usage, in bytes.
;                            [7] - The current space allocated for the pagefile, in bytes.
;                            [8] - The peak space allocated for the pagefile, in bytes.
;                            [9] - The current amount of memory that cannot be shared with other processes, in bytes.
;
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

	Local $hProcess = DllCall('kernel32.dll', 'ptr', 'OpenProcess', 'dword', 0x00000410, 'int', 0, 'dword', $PID)

	If (@error) Or (Not $hProcess[0]) Then
		Return SetError(1, 0, 0)
	EndIf

	Local $tPMC_EX = DllStructCreate('dword;dword;ulong_ptr;ulong_ptr;ulong_ptr;ulong_ptr;ulong_ptr;ulong_ptr;ulong_ptr;ulong_ptr;ulong_ptr')
	Local $Ret = DllCall(@SystemDir & '\psapi.dll', 'int', 'GetProcessMemoryInfo', 'ptr', $hProcess[0], 'ptr', DllStructGetPtr($tPMC_EX), 'int', DllStructGetSize($tPMC_EX))

	If (@error) Or (Not $Ret[0]) Then
		$Ret = 0
	EndIf
	_WinAPI_CloseHandle($hProcess[0])
	If Not IsArray($Ret) Then
		Return SetError(1, 0, 0)
	EndIf

	Local $Result[10]

	For $i = 0 To 9
		$Result[$i] = DllStructGetData($tPMC_EX, $i + 2)
	Next
	Return $Result
EndFunc   ;==>_WinAPI_GetProcessMemoryInfo

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetProcessName
; Description....: Retrieves the name for the specified process.
; Syntax.........: _WinAPI_GetProcessName ( [$PID] )
; Parameters.....: $PID    - The PID of the process. Default (0) is the current process.
; Return values..: Success - The process name.
;                  Failure - Empty string and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: None
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_GetProcessName($PID = 0)

	If Not $PID Then
		$PID = _WinAPI_GetCurrentProcessID()
		If Not $PID Then
			Return SetError(1, 0, '')
		EndIf
	EndIf

	Local $hSnapshot = DllCall('kernel32.dll', 'ptr', 'CreateToolhelp32Snapshot', 'dword', 0x00000002, 'dword', 0)

	If (@error) Or (Not $hSnapshot[0]) Then
		Return SetError(1, 0, '')
	EndIf

	Local $tPROCESSENTRY32 = DllStructCreate('dword Size;dword Usage;dword ProcessID;ulong_ptr DefaultHeapID;dword ModuleID;dword Threads;dword ParentProcessID;long PriClassBase;dword Flags;wchar ExeFile[260]')
	Local $pPROCESSENTRY32 = DllStructGetPtr($tPROCESSENTRY32)
	Local $Ret, $Error = 1

	$hSnapshot = $hSnapshot[0]
	DllStructSetData($tPROCESSENTRY32, 'Size', DllStructGetSize($tPROCESSENTRY32))
	$Ret = DllCall('kernel32.dll', 'int', 'Process32FirstW', 'ptr', $hSnapshot, 'ptr', $pPROCESSENTRY32)
	While (Not @error) And ($Ret[0])
		If DllStructGetData($tPROCESSENTRY32, 'ProcessID') = $PID Then
			$Error = 0
			ExitLoop
		EndIf
		$Ret = DllCall('kernel32.dll', 'int', 'Process32NextW', 'ptr', $hSnapshot, 'ptr', $pPROCESSENTRY32)
	WEnd
	_WinAPI_CloseHandle($hSnapshot)
	If $Error Then
		Return SetError(1, 0, '')
	EndIf
	Return DllStructGetData($tPROCESSENTRY32, 'ExeFile')
EndFunc   ;==>_WinAPI_GetProcessName

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetProcessTimes
; Description....: Retrieves timing information for the specified process.
; Syntax.........: _WinAPI_GetProcessTimes ( [$PID] )
; Parameters.....: $PID    - The PID of the process. Default (0) is the current process.
; Return values..: Success - The array that contains the following information.
;
;                            [0] - $tagFILETIME structure that contains the creation time of the process.
;                            [1] - The time that the process has executed in kernel mode, in 100-nanosecond time units.
;                            [2] - The time that the process has executed in user mode, in 100-nanosecond time units.
;
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ GetProcessTimes
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_GetProcessTimes($PID = 0)

	If Not $PID Then
		$PID = _WinAPI_GetCurrentProcessID()
		If Not $PID Then
			Return SetError(1, 0, 0)
		EndIf
	EndIf

	Local $hProcess = DllCall('kernel32.dll', 'ptr', 'OpenProcess', 'dword', 0x00000400, 'int', 0, 'dword', $PID)

	If (@error) Or (Not $hProcess[0]) Then
		Return SetError(1, 0, 0)
	EndIf

	Local $tFILETIME = DllStructCreate($tagFILETIME)
	Local $Ret = DllCall('kernel32.dll', 'int', 'GetProcessTimes', 'ptr', $hProcess[0], 'ptr', DllStructGetPtr($tFILETIME), 'uint64*', 0, 'uint64*', 0, 'uint64*', 0)

	If (@error) Or (Not $Ret[0]) Then
		$Ret = 0
	EndIf
	_WinAPI_CloseHandle($hProcess[0])
	If Not IsArray($Ret) Then
		Return SetError(1, 0, 0)
	EndIf

	Local $Result[3]

	$Result[0] = $tFILETIME
	$Result[1] = $Ret[4]
	$Result[2] = $Ret[5]

	Return $Result
EndFunc   ;==>_WinAPI_GetProcessTimes

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetRegionData
; Description....: Fills the specified buffer with data describing a region.
; Syntax.........: _WinAPI_GetRegionData ( $hRgn, ByRef $tRGNDATA )
; Parameters.....: $hRgn     - Handle to the region.
;                  $tRGNDATA - $tagRGNDATA structure that receives the region data in logical units.
; Return values..: Success   - 1.
;                  Failure   - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ GetRegionData
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_GetRegionData($hRgn, ByRef $tRGNDATA)

	Local $Ret

	$Ret = DllCall('gdi32.dll', 'dword', 'GetRegionData', 'ptr', $hRgn, 'dword', 0, 'ptr', 0)
	If (@error) Or (Not $Ret[0]) Then
		$tRGNDATA = 0
		Return SetError(1, 0, 0)
	EndIf
	If $Ret[0] > 32 Then
		$tRGNDATA = DllStructCreate($tagRGNDATAHEADER & 'byte[' & ($Ret[0] - 32) & ']')
	Else
		$tRGNDATA = DllStructCreate($tagRGNDATAHEADER)
	EndIf
	$Ret = DllCall('gdi32.dll', 'dword', 'GetRegionData', 'ptr', $hRgn, 'dword', $Ret[0], 'ptr', DllStructGetPtr($tRGNDATA))
	If (@error) Or (Not $Ret[0]) Then
		$tRGNDATA = 0
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_GetRegionData

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetRgnBox
; Description....: Retrieves the bounding rectangle of the specified region.
; Syntax.........: _WinAPI_GetRgnBox ( $hRgn, ByRef $tRECT )
; Parameters.....: $hRgn   - Handle to the region.
;                  $tRECT  - $tagRECT structure that receives the bounding rectangle in logical units.
; Return values..: Success - The value that specifies the region's complexity. It can be one of the following values.
;
;                            $COMPLEXREGION
;                            $NULLREGION
;                            $SIMPLEREGION
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

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_GetRgnBox

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetROP2
; Description....: Retrieves the foreground mix mode of the specified device context.
; Syntax.........: _WinAPI_GetROP2 ( $hDC )
; Parameters.....: $hDC    - Handle to the device context.
; Return values..: Success - The value that specifies the foreground mix mode ($R2_*).
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

	If (@error) Or (Not $Ret[0]) Then
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
	Return BitAND(__RGB($iRGB), 0x0000FF)
EndFunc   ;==>_WinAPI_GetRValue

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetSystemDefaultLCID
; Description....: Returns the locale identifier (LCID) for the system locale.
; Syntax.........: _WinAPI_GetSystemDefaultLCID ( )
; Parameters.....: None
; Return values..: Success - The default LCID for the system.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: WideBoyDixon
; Modified.......: Yashied
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ GetSystemDefaultLCID
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_GetSystemDefaultLCID()

    Local $Ret = DllCall('kernel32.dll', 'long', 'GetSystemDefaultLCID')

    If @error Then
		Return SetError(1, 0, 0)
	EndIf
    Return $Ret[0]
EndFunc   ;==>_WinAPI_GetSystemDefaultLCID

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetSystemInfo
; Description....: Retrieves information about the current system.
; Syntax.........: _WinAPI_GetSystemInfo ( )
; Parameters.....: None
; Return values..: Success - The array containing the following information:
;
;                  [0] - The processor architecture of the installed operating system ($PROCESSOR_ARCHITECTURE_*).
;                  [1] - The page size and the granularity of page protection and commitment.
;                  [2] - A pointer to the lowest memory address accessible to applications and dynamic-link libraries (DLLs).
;                  [3] - A pointer to the highest memory address accessible to applications and DLLs.
;                  [4] - A mask representing the set of processors configured into the system. Bit 0 is processor 0; bit 31 is processor 31.
;                  [5] - The number of physical processors in the system.
;                  [6] - An obsolete member that is retained for compatibility ($PROCESSOR_*).
;                  [7] - The granularity for the starting address at which virtual memory can be allocated.
;                  [8] - The architecture-dependent processor level.
;                  [9] - The architecture-dependent processor revision (0x0000xxyy; xx - model; yy - stepping).
;
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ GetSystemInfo
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_GetSystemInfo()

	Local $Proc

	If _WinAPI_IsWow64Process() Then
		$Proc = 'GetNativeSystemInfo'
	Else
		$Proc = 'GetSystemInfo'
	EndIf

	Local $tagSYSTEMINFO = DllStructCreate('ushort;ushort;dword;ptr;ptr;dword_ptr;dword;dword;dword;ushort;ushort')

	DllCall('kernel32.dll', 'none', $Proc, 'ptr', DllStructGetPtr($tagSYSTEMINFO))
	If @error Then
		Return SetError(1, 0, 0)
	EndIf

	Local $Result[10]

	$Result[0] = DllStructGetData($tagSYSTEMINFO, 1)
	For $i = 1 To 9
		$Result[$i] = DllStructGetData($tagSYSTEMINFO, $i + 2)
	Next
	Return $Result
EndFunc   ;==>_WinAPI_GetSystemInfo

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetSystemPowerStatus
; Description....: Retrieves the power status of the system.
; Syntax.........: _WinAPI_GetSystemPowerStatus ( )
; Parameters.....: None
; Return values..: Success - The array containing the following parameters:
;
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
;
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

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf

	Local $Result[5]

	$Result[0] = DllStructGetData($tSYSTEM_POWER_STATUS, 1)
	$Result[1] = DllStructGetData($tSYSTEM_POWER_STATUS, 2)
	$Result[2] = DllStructGetData($tSYSTEM_POWER_STATUS, 3)
	$Result[3] = DllStructGetData($tSYSTEM_POWER_STATUS, 5)
	$Result[4] = DllStructGetData($tSYSTEM_POWER_STATUS, 6)

	For $i = 3 To 4
		If _WinAPI_DWordToInt($Result[$i]) = -1 Then
			$Result[$i] = -1
		EndIf
	Next

	Return $Result
EndFunc   ;==>_WinAPI_GetSystemPowerStatus

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetSystemTimes
; Description....: Retrieves system timing information.
; Syntax.........: _WinAPI_GetSystemTimes ( )
; Parameters.....: None
; Return values..: Success - The array that contains the following information.
;
;                            [0] - The time that the system has been idle.
;                            [1] - The time that the system has spent executing in kernel mode, in 100-nanosecond time units.
;                            [2] - The time that the system has spent executing in user mode, in 100-nanosecond time units.
;
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: On a multiprocessor system, the _WinAPI_GetSystemTimes() returns a values are the sum of the designated times
;                  across all processors.
; Related........:
; Link...........: @@MsdnLink@@ GetSystemTimes
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_GetSystemTimes()

	Local $Ret = DllCall('kernel32.dll', 'int', 'GetSystemTimes', 'uint64*', 0, 'uint64*', 0, 'uint64*', 0)

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf

	Local $Result[3]

	For $i = 0 To 2
		$Result[$i] = $Ret[$i + 1]
	Next
	Return $Result
EndFunc   ;==>_WinAPI_GetSystemTimes

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetSystemWow64Directory
; Description....: Retrieves the path of the system directory used by WOW64.
; Syntax.........: _WinAPI_GetSystemWow64Directory ( )
; Parameters.....: None
; Return values..: Success - The path of the system directory. This path does not end with a backslash.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: This directory is not present on 32-bit Windows.
; Related........:
; Link...........: @@MsdnLink@@ GetSystemWow64Directory
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_GetSystemWow64Directory()

	Local $tData = DllStructCreate('wchar[1024]')
	Local $Ret = DllCall('kernel32.dll', 'uint', 'GetSystemWow64DirectoryW', 'ptr', DllStructGetPtr($tData), 'uint', 1024)

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return DllStructGetData($tData, 1)
EndFunc   ;==>_WinAPI_GetSystemWow64Directory

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

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, '')
	EndIf
	Return DllStructGetData($tData, 1)
EndFunc   ;==>_WinAPI_GetTempFileName

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetTextAlign
; Description....: Retrieves the text-alignment setting for the specified device context.
; Syntax.........: _WinAPI_GetTextAlign ( $hDC )
; Parameters.....: $hDC    - Handle to the device context.
; Return values..: Success - The status of the text-alignment flags. The return value is a combination of the $TA_* and $VTA_* constants.
;                  Failure - (-1) and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ GetTextAlign
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_GetTextAlign($hDC)

	Local $Ret = DllCall('gdi32.dll', 'uint', 'GetTextAlign', 'hwnd', $hDC)

	If (@error) Or ($Ret[0] = 0xFFFFFFFF) Then
		Return SetError(1, 0, -1)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_GetTextAlign

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

	If (@error) Or ($Ret[0] = -1) Then
		Return SetError(1, 0, -1)
	EndIf
	Return __RGB($Ret[0])
EndFunc   ;==>_WinAPI_GetTextColor

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetTextFace
; Description....: Retrieves the typeface name of the font that is selected into the specified device context.
; Syntax.........: _WinAPI_GetTextFace ( $hDC )
; Parameters.....: $hDC    - Handle to the device context.
; Return values..: Success - The typeface name.
;                  Failure - Empty string and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ GetTextFace
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_GetTextFace($hDC)

	Local $tData = DllStructCreate('wchar[1024]')
	Local $Ret = DllCall('gdi32.dll', 'int', 'GetTextFaceW', 'hwnd', $hDC, 'int', 1024, 'ptr', DllStructGetPtr($tData))

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, '')
	EndIf
	Return DllStructGetData($tData, 1)
EndFunc   ;==>_WinAPI_GetTextFace

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

;	Local $tTEXTMETRIC = DllStructCreate($tagTEXTMETRIC)
	Local $tTEXTMETRIC = DllStructCreate('long tmHeight;long tmAscent;long tmDescent;long tmInternalLeading;long tmExternalLeading;long tmAveCharWidth;long tmMaxCharWidth;long tmWeight;long tmOverhang;long tmDigitizedAspectX;long tmDigitizedAspectY;wchar tmFirstChar;wchar tmLastChar;wchar tmDefaultChar;wchar tmBreakChar;byte tmItalic;byte tmUnderlined;byte tmStruckOut;byte tmPitchAndFamily;byte tmCharSet')
	Local $Ret = DllCall('gdi32.dll', 'int', 'GetTextMetricsW', 'hwnd', $hDC, 'ptr', DllStructGetPtr($tTEXTMETRIC))

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $tTEXTMETRIC
EndFunc   ;==>_WinAPI_GetTextMetrics

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetThemeAppProperties
; Description....: Retrieves the property flags that control how visual styles are applied in the current application.
; Syntax.........: _WinAPI_GetThemeAppProperties ( )
; Parameters.....: None
; Return values..: Success - The property bit flags ($STAP_ALLOW_*) combined with a logical OR operator.
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
; Syntax.........: _WinAPI_GetThemeColor ( $hTheme, $iPartId, $iStateId, $iPropId )
; Parameters.....: $hTheme   - Handle to a window's specified theme data.
;                  $iPartId  - The part that contains the color property.
;                  $iStateId - The state of the part.
;                  $iPropId  - The property to retrieve.
; Return values..: Success   - The received color, in RGB.
;                  Failure   - (-1) and sets the @error flag to non-zero, @extended flag may contain the system error code.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ GetThemeColor
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_GetThemeColor($hTheme, $iPartId, $iStateId, $iPropId)

	Local $Ret = DllCall('uxtheme.dll', 'uint', 'GetThemeColor', 'ptr', $hTheme, 'int', $iPartId, 'int', $iStateId, 'int', $iPropId, 'dword*', 0)

	If @error Then
		Return SetError(1, 0, -1)
	Else
		If $Ret[0] Then
			Return SetError(1, $Ret[0], -1)
		EndIf
	EndIf
	Return __RGB($Ret[5])
EndFunc   ;==>_WinAPI_GetThemeColor

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetThemeDocumentationProperty
; Description....: Retrieves the value for a theme property from the documentation section of the specified theme file.
; Syntax.........: _WinAPI_GetThemeDocumentationProperty ( $sFile, $sProperty )
; Parameters.....: $sFile     - The name of the theme file that will be opened to query for the property.
;                  $sProperty - The name of the theme property to query. This parameter can be one of the following values.
;
;                               $SZ_THDOCPROP_AUTHOR
;                               $SZ_THDOCPROP_CANONICALNAME
;                               $SZ_THDOCPROP_DISPLAYNAME
;                               $SZ_THDOCPROP_TOOLTIP
;
; Return values..: Success    - The property string value.
;                  Failure    - Empty string and sets the @error flag to non-zero, @extended flag may contain the system error code.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ GetThemeDocumentationProperty
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_GetThemeDocumentationProperty($sFile, $sProperty)

	Local $tData = DllStructCreate('wchar[1024]')
	Local $Ret = DllCall('uxtheme.dll', 'uint', 'GetThemeDocumentationProperty', 'wstr', $sFile, 'wstr', $sProperty, 'ptr', DllStructGetPtr($tData), 'int', 1024)

	If @error Then
		Return SetError(1, 0, '')
	Else
		If $Ret[0] Then
			Return SetError(1, $Ret[0], '')
		EndIf
	EndIf
	Return DllStructGetData($tData, 1)
EndFunc   ;==>_WinAPI_GetThemeDocumentationProperty

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetThemeFont
; Description....: Retrieves the value of a font property.
; Syntax.........: _WinAPI_GetThemeFont ( $hTheme, $iPartId, $iStateId, $iPropId )
; Parameters.....: $hTheme   - Handle to a window's specified theme data.
;                  $iPartId  - The part that contains the font property.
;                  $iStateId - The state of the part.
;                  $iPropId  - The property to retrieve.
; Return values..: Success   - $tagLOGFONT structure that contains a font property value.
;                  Failure   - 0 and sets the @error flag to non-zero, @extended flag may contain the system error code.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ GetThemeFont
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_GetThemeFont($hTheme, $iPartId, $iStateId, $iPropId)

	Local $tLOGFONT = DllStructCreate($tagLOGFONT)
	Local $Ret = DllCall('uxtheme.dll', 'uint', 'GetThemeFont', 'ptr', $hTheme, 'hwnd', 0, 'int', $iPartId, 'int', $iStateId, 'int', $iPropId, 'ptr', DllStructGetPtr($tLOGFONT))

	If @error Then
		Return SetError(1, 0, 0)
	Else
		If $Ret[0] Then
			Return SetError(1, $Ret[0], 0)
		EndIf
	EndIf
	Return $tLOGFONT
EndFunc   ;==>_WinAPI_GetThemeFont

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetThemeInt
; Description....: Retrieves the value of an int property.
; Syntax.........: _WinAPI_GetThemeInt ( $hTheme, $iPartId, $iStateId, $iPropId )
; Parameters.....: $hTheme   - Handle to a window's specified theme data.
;                  $iPartId  - The part that contains the int property.
;                  $iStateId - The state of the part.
;                  $iPropId  - The property to retrieve.
; Return values..: Success   - The retrieved value.
;                  Failure   - 0 and sets the @error flag to non-zero, @extended flag may contain the system error code.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ GetThemeInt
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_GetThemeInt($hTheme, $iPartId, $iStateId, $iPropId)

	Local $Ret = DllCall('uxtheme.dll', 'uint', 'GetThemeInt', 'ptr', $hTheme, 'int', $iPartId, 'int', $iStateId, 'int', $iPropId, 'int*', 0)

	If @error Then
		Return SetError(1, 0, 0)
	Else
		If $Ret[0] Then
			Return SetError(1, $Ret[0], 0)
		EndIf
	EndIf
	Return $Ret[5]
EndFunc   ;==>_WinAPI_GetThemeInt

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetThemeMargins
; Description....: Retrieves the value of a MARGINS property.
; Syntax.........: _WinAPI_GetThemeMargins ( $hTheme, $iPartId, $iStateId, $iPropId, $hDC, $tRECT)
; Parameters.....: $hTheme   - Handle to a window's specified theme data.
;                  $iPartId  - The part that contains the MARGINS property.
;                  $iStateId - The state of the part.
;                  $iPropId  - The property to retrieve.
;                  $hDC      - Handle to a device context to select fonts into.
;                  $tRECT    - $tagRECT structure that contains the rectangle that specifies the area to be drawn into.
; Return values..: Success   - $tagMARGINS structure that contains a margins value.
;                  Failure   - 0 and sets the @error flag to non-zero, @extended flag may contain the system error code.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ GetThemeMargins
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_GetThemeMargins($hTheme, $iPartId, $iStateId, $iPropId, $hDC, $tRECT)

	Local $tMARGINS = DllStructCreate($tagMARGINS)
	Local $Ret = DllCall('uxtheme.dll', 'uint', 'GetThemeMargins', 'ptr', $hTheme, 'hwnd', $hDC, 'int', $iPartId, 'int', $iStateId, 'int', $iPropId, 'ptr', DllStructGetPtr($tRECT), 'ptr', DllStructGetPtr($tMARGINS))

	If @error Then
		Return SetError(1, 0, 0)
	Else
		If $Ret[0] Then
			Return SetError(1, $Ret[0], 0)
		EndIf
	EndIf
	Return $tMARGINS
EndFunc   ;==>_WinAPI_GetThemeMargins

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetThemePartSize
; Description....: Calculates the original size of the part defined by a visual style.
; Syntax.........: _WinAPI_GetThemePartSize ( $hTheme, $iPartId, $iStateId, $hDC, $tRECT, $iType )
; Parameters.....: $hTheme   - Handle to a window's specified theme data.
;                  $iPartId  - The part part to calculate the size of.
;                  $iStateId - The state of the part.
;                  $hDC      - Handle to a device context to select fonts into.
;                  $tRECT    - $tagRECT structure that contains the rectangle used for the part drawing destination.
;                  $iType    - The type of size to retrieve. This parameter can be one of the following values.
;
;                              $TS_MIN
;                              $TS_TRUE
;                              $TS_DRAW
;
; Return values..: Success   - $tagSIZE structure that contains a dimensions of the specified part.
;                  Failure   - 0 and sets the @error flag to non-zero, @extended flag may contain the system error code.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ GetThemePartSize
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_GetThemePartSize($hTheme, $iPartId, $iStateId, $hDC, $tRECT, $iType)

	Local $tSIZE = DllStructCreate($tagSIZE)
	Local $Ret = DllCall('uxtheme.dll', 'uint', 'GetThemePartSize', 'ptr', $hTheme, 'hwnd', $hDC, 'int', $iPartId, 'int', $iStateId, 'ptr', DllStructGetPtr($tRECT), 'int', $iType, 'ptr', DllStructGetPtr($tSIZE))

	If @error Then
		Return SetError(1, 0, 0)
	Else
		If $Ret[0] Then
			Return SetError(1, $Ret[0], 0)
		EndIf
	EndIf
	Return $tSIZE
EndFunc   ;==>_WinAPI_GetThemePartSize

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetThemePosition
; Description....: Retrieves the value of a position property.
; Syntax.........: _WinAPI_GetThemePosition ( $hTheme, $iPartId, $iStateId, $iPropId )
; Parameters.....: $hTheme   - Handle to a window's specified theme data.
;                  $iPartId  - The part that contains the position property.
;                  $iStateId - The state of the part.
;                  $iPropId  - The property to retrieve.
; Return values..: Success   - $tagPOINT structure that contains a position value.
;                  Failure   - 0 and sets the @error flag to non-zero, @extended flag may contain the system error code.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ GetThemePosition
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_GetThemePosition($hTheme, $iPartId, $iStateId, $iPropId)

	Local $tPOINT = DllStructCreate($tagPOINT)
	Local $Ret = DllCall('uxtheme.dll', 'uint', 'GetThemePosition', 'ptr', $hTheme, 'int', $iPartId, 'int', $iStateId, 'int', $iPropId, 'ptr', DllStructGetPtr($tPOINT))

	If @error Then
		Return SetError(1, 0, 0)
	Else
		If $Ret[0] Then
			Return SetError(1, $Ret[0], 0)
		EndIf
	EndIf
	Return $tPOINT
EndFunc   ;==>_WinAPI_GetThemePosition

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetThemeRect
; Description....: Retrieves the value of a RECT property.
; Syntax.........: _WinAPI_GetThemeRect ( $hTheme, $iPartId, $iStateId, $iPropId )
; Parameters.....: $hTheme   - Handle to a window's specified theme data.
;                  $iPartId  - The part containing the RECT property.
;                  $iStateId - The state of the part.
;                  $iPropId  - The property to retrieve.
; Return values..: Success   - $tagRECT structure that contains a rectangle.
;                  Failure   - 0 and sets the @error flag to non-zero, @extended flag may contain the system error code.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ GetThemeRect
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_GetThemeRect($hTheme, $iPartId, $iStateId, $iPropId)

	Local $tRECT = DllStructCreate($tagRECT)
	Local $Ret = DllCall('uxtheme.dll', 'uint', 'GetThemeRect', 'ptr', $hTheme, 'int', $iPartId, 'int', $iStateId, 'int', $iPropId, 'ptr', DllStructGetPtr($tRECT))

	If @error Then
		Return SetError(1, 0, 0)
	Else
		If $Ret[0] Then
			Return SetError(1, $Ret[0], 0)
		EndIf
	EndIf
	Return $tRECT
EndFunc   ;==>_WinAPI_GetThemeRect

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
; Name...........: _WinAPI_GetTickCount64
; Description....: Retrieves the number of milliseconds that have elapsed since the system was started.
; Syntax.........: _WinAPI_GetTickCount64 ( )
; Parameters.....: None
; Return values..: Success - The number of milliseconds that have elapsed since the system was started.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: This function requires Windows Vista or later.
; Related........:
; Link...........: @@MsdnLink@@ GetTickCount64
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_GetTickCount64()

	Local $Ret = DllCall('kernel32.dll', 'uint64', 'GetTickCount64')

    If @error Then
		Return SetError(1, 0, 0)
	EndIf
    Return $Ret[0]
EndFunc   ;==>_WinAPI_GetTickCount64

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetTimeFormat
; Description....: Formats time as a time string for a locale specified by identifier.
; Syntax.........: _WinAPI_GetTimeFormat ( [$LCID [, $tSYSTEMTIME [, $iFlag [, $sFormat]]]] )
; Parameters.....: $LCID        - Locale identifier (LCID) that specifies the locale. If this parameter is 0, the function will
;                                 use default locale for the user.
;                  $tSYSTEMTIME - $tagSYSTEMTIME structure that contains the time information to format. If this parameter is 0,
;                                 the function will use the current local system time.
;                  $iFlag       - Flags specifying time format options. This parameter can be one or more of the following values.
;
;                                 $TIME_FORCE24HOURFORMAT
;                                 $TIME_NOMINUTESORSECONDS
;                                 $TIME_NOSECONDS
;                                 $TIME_NOTIMEMARKER
;
;                  $sFormat     - The string that is used to form the time. For example, "hh:mm:ss tt". If this parameter is 0,
;                                 the function returns the string according to the time format for the specified locale ($LCID).
; Return values..: Success      - The formatted time string.
;                  Failure      - Empty string and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ GetTimeFormat
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_GetTimeFormat($LCID = 0, $tSYSTEMTIME = 0, $iFlags = 0, $sFormat = '')

	Local $TypeOfFormat = 'wstr'

	If Not $LCID Then
		$LCID = 0x0400
	EndIf
	If Not StringStripWS($sFormat, 3) Then
		$TypeOfFormat = 'ptr'
		$sFormat = 0
	EndIf

	Local $tData = DllStructCreate('wchar[1024]')
	Local $Ret = DllCall('kernel32.dll', 'int', 'GetTimeFormatW', 'long', $LCID, 'dword', $iFlags, 'ptr', DllStructGetPtr($tSYSTEMTIME), $TypeOfFormat, $sFormat, 'ptr', DllStructGetPtr($tData), 'int', 1024)

    If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, '')
	EndIf
    Return DllStructGetData($tData, 1)
EndFunc   ;==>_WinAPI_GetTimeFormat

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
; Name...........: _WinAPI_GetUDFColorMode
; Description....: Retrieves the current color mode for WinAPIEx UDF library.
; Syntax.........: _WinAPI_GetUDFColorMode ( )
; Parameters.....: None
; Return values..: The one of the following values: 0 - BGR; 1 - RGB.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: None
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_GetUDFColorMode()
	Return Number($__RGB)
EndFunc   ;==>_WinAPI_GetUDFColorMode

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetUDFVersion
; Description....: Retrieves the current version of WinAPIEx UDF library.
; Syntax.........: _WinAPI_GetUDFVersion ( )
; Parameters.....: None
; Return values..: The version of this UDF library.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: None
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_GetUDFVersion()
	Return $__Ver
EndFunc   ;==>_WinAPI_GetUDFVersion

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetUpdateRect
; Description....: Retrieves the coordinates of the rectangle that completely encloses the update region of the specified window.
; Syntax.........: _WinAPI_GetUpdateRect ( $hWnd [, $fErase] )
; Parameters.....: $hWnd   - Handle to the window whose update region is to be retrieved.
;                  $fErase - Specifies whether the background in the update region is to be erased, valid values:
;                  |TRUE   - The background is erased. (Default)
;                  |FALSE  - The background remains unchanged.
; Return values..: Success - $tagRECT structure that contains the coordinates of the enclosing rectangle, in device units.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: The update rectangle retrieved by the _WinAPI_BeginPaint() function is identical to that retrieved by
;                  _WinAPI_GetUpdateRect()
;
;                  _WinAPI_BeginPaint() automatically validates the update region, so any call to _WinAPI_GetUpdateRect() made
;                   immediately after the call to _WinAPI_BeginPaint() retrieves an empty update region.
; Related........:
; Link...........: @@MsdnLink@@ GetUpdateRect
; Example........: YesNULLREGION
; ===============================================================================================================================

Func _WinAPI_GetUpdateRect($hWnd, $fErase = 1)

	Local $tRECT = DllStructCreate($tagRECT)
	Local $Ret = DllCall('user32.dll', 'int', 'GetUpdateRect', 'hwnd', $hWnd, 'ptr', DllStructGetPtr($tRECT), 'int', $fErase)

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $tRECT
EndFunc   ;==>_WinAPI_GetUpdateRect

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetUpdateRgn
; Description....: Retrieves the update region of a window by copying it into the specified region.
; Syntax.........: _WinAPI_GetUpdateRgn ( $hWnd, $hRgn [, $fErase] )
; Parameters.....: $hWnd   - Handle to the window with an update region that is to be retrieved.
;                  $hRgn   - Handle to the region to receive the update region.
;                  $fErase - Specifies whether the background in the update region is to be erased, valid values:
;                  |TRUE   - The background is erased. (Default)
;                  |FALSE  - The background remains unchanged.
; Return values..: Success - The value that indicates the complexity of the resulting region; it can be one of the following values.
;
;                            $COMPLEXREGION
;                            $NULLREGION
;                            $SIMPLEREGION
;
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: _WinAPI_BeginPaint() automatically validates the update region, so any call to _WinAPI_GetUpdateRgn() made
;                  immediately after the call to _WinAPI_BeginPaint() retrieves an empty update region.
; Related........:
; Link...........: @@MsdnLink@@ GetUpdateRgn
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_GetUpdateRgn($hWnd, $hRgn, $fErase = 1)

	Local $Ret = DllCall('user32.dll', 'int', 'GetUpdateRgn', 'hwnd', $hWnd, 'ptr', $hRgn, 'int', $fErase)

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_GetUpdateRgn

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

    Local $Ret = DllCall('kernel32.dll', 'long', 'GetUserDefaultLCID')

    If @error Then
		Return SetError(1, 0, 0)
	EndIf
    Return $Ret[0]
EndFunc   ;==>_WinAPI_GetUserDefaultLCID

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetVersion
; Description....: Retrieves version of the current operating system.
; Syntax.........: _WinAPI_GetVersion ( )
; Parameters.....: None
; Return values..: Success - The string containing the current OS version.
;
;                            "6.1" - Windows 7 / Windows Server 2008 R2
;                            "6.0" - Windows Server 2008 / Windows Vista
;                            "5.2" - Windows Server 2003 R2 / Windows Home Server / Windows Server 2003 / Windows XP Professional x64 Edition
;                            "5.1" - Windows XP
;                            "5.0" - Windows 2000
;
;                  Failure - Empty string and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: None
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_GetVersion()

	Local $tOSVERSIONINFOEX = _WinAPI_GetVersionEx()

	If @error Then
		Return SetError(1, 0, '')
	EndIf
	Return DllStructGetData($tOSVERSIONINFOEX, 'MajorVersion') & '.' & DllStructGetData($tOSVERSIONINFOEX, 'MinorVersion')
EndFunc   ;==>_WinAPI_GetVersion

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

	If (@error) Or (Not $Ret[0]) Then
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

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, '')
	EndIf
	Return DllStructGetData($tData, 1)
EndFunc   ;==>_WinAPI_GetVolumeNameForVolumeMountPoint

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetWindowFileName
; Description....: Retrieves the fully-qualified path of the module associated with the specified window handle.
; Syntax.........: _WinAPI_GetWindowFileName ( $hWnd )
; Parameters.....: $hWnd   - Handle to the window whose module file name will be retrieved.
; Return values..: Success - The full path and file name.
;                  Failure - Empty string and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: None
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_GetWindowFileName($hWnd)

	Local $PID = 0, $Result

	If _WinAPI_IsWindow($hWnd) Then
		_WinAPI_GetWindowThreadProcessId($hWnd, $PID)
	EndIf
	If Not $PID Then
		Return SetError(1, 0, '')
	EndIf
	$Result = _WinAPI_GetProcessFileName($PID)
	If @error Then
		Return SetError(1, 0, '')
	EndIf
	Return $Result
EndFunc   ;==>_WinAPI_GetWindowFileName

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

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $tWINDOWINFO
EndFunc   ;==>_WinAPI_GetWindowInfo

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetWindowLongEx
; Description....: Retrieves information about the specified window.
; Syntax.........: _WinAPI_GetWindowLongEx ( $hWnd, $iIndex )
; Parameters.....: $hWnd   - Handle to the window and, indirectly, the class to which the window belongs.
;                  $iIndex - The zero-based offset to the value to be retrieved. Valid values are in the range zero through the
;                            number of bytes of extra window memory, minus the size of an integer. To retrieve any other value,
;                            specify one of the following values.
;
;                            $GWL_EXSTYLE
;                            $GWL_HINSTANCE
;                            $GWL_HWNDPARENT
;                            $GWL_ID
;                            $GWL_STYLE
;                            $GWL_USERDATA
;                            $GWL_WNDPROC
;
; Return values..: Success - The requested value.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: If _WinAPI_SetWindowLong() has not been called previously, _WinAPI_GetWindowLong() returns 0.
; Related........:
; Link...........: @@MsdnLink@@ GetWindowLong
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_GetWindowLongEx($hWnd, $iIndex)

	Local $Ret

	If StringInStr(@OSArch, '64') Then
		$Ret = DllCall('user32.dll', 'long_ptr', 'GetWindowLongPtrW', 'hwnd', $hWnd, 'int', $iIndex)
	Else
		$Ret = DllCall('user32.dll', 'long', 'GetWindowLongW', 'hwnd', $hWnd, 'int', $iIndex)
	EndIf
	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_GetWindowLongEx

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

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $tRECT
EndFunc   ;==>_WinAPI_GetWorkArea

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GradientFill
; Description....: Fills rectangle or triangle gradient.
; Syntax.........: _WinAPI_GradientFill ($hDC, $aVertex [, $iStart [, $iEnd [, $fRotate]]] )
; Parameters.....: $hDC     - Handle to the device context.
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

	Local $Count, $Mode, $Point, $tGradient, $tVertex, $Struct = ''

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
			$Mode = Number(Not $fRotate)
		Case 3
			$Mode = 2
		Case Else
			Return SetError(1, 0, 0)
	EndSwitch
	For $i = $iStart To $iEnd
		$Struct &= 'ushort[8];'
	Next
	$tVertex = DllStructCreate($Struct)
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
		DllStructSetData($tVertex, $Count, BitShift(_WinAPI_GetRValue($aVertex[$i][2]), -8), 5)
		DllStructSetData($tVertex, $Count, BitShift(_WinAPI_GetGValue($aVertex[$i][2]), -8), 6)
		DllStructSetData($tVertex, $Count, BitShift(_WinAPI_GetBValue($aVertex[$i][2]), -8), 7)
		DllStructSetData($tVertex, $Count, 0, 8)
		$Count += 1
	Next

	Local $Ret = DllCall('gdi32.dll', 'int', 'GdiGradientFill', 'hwnd', $hDC, 'ptr', DllStructGetPtr($tVertex), 'ulong', $Point, 'ptr', DllStructGetPtr($tGradient), 'ulong', 1, 'ulong', $Mode)

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_GradientFill

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_HiByte
; Description....: Returns the high BYTE of a 16-bit (2 bytes) value.
; Syntax.........: _WinAPI_HiByte ( $iValue )
; Parameters.....: $iValue - 16-bit value.
; Return values..: High BYTE value.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: None
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_HiByte($iValue)
	Return BitAND(BitShift($iValue, 8), 0xFF)
EndFunc   ;==>_WinAPI_HiByte

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_HideCaret
; Description....: Removes the caret from the screen.
; Syntax.........: _WinAPI_HideCaret ( $hWnd )
; Parameters.....: $hWnd   - Handle to the window that owns the caret. If this parameter is 0, _WinAPI_HideCaret() searches the
;                            current task for the window that owns the caret.
; Return values..: Success - 1.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: _WinAPI_HideCaret() hides the caret only if the specified window owns the caret. If the specified window does
;                  not own the caret, _WinAPI_HideCaret() does nothing and returns 0.
;
;                  Hiding is cumulative. If your application calls _WinAPI_HideCaret() five times in a row, it must also call
;                  _WinAPI_ShowCaret() five times before the caret is displayed.
; Related........:
; Link...........: @@MsdnLink@@ HideCaret
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_HideCaret($hWnd)

	Local $Ret = DllCall('user32.dll', 'int', 'HideCaret', 'hwnd', $hWnd)

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_HideCaret

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_HiDWord
; Description....: Returns the high DWORD of a 64-bit (8 bytes) value.
; Syntax.........: _WinAPI_HiDWord ( $iValue )
; Parameters.....: $iValue - 64-bit value.
; Return values..: High DWORD value.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: None
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_HiDWord($iValue)

	Local $tInt64, $tQWord

	$tInt64 = DllStructCreate('int64')
	$tQWord = DllStructCreate('dword;dword', DllStructGetPtr($tInt64))
	DllStructSetData($tInt64, 1, $iValue)
	Return DllStructGetData($tQWord, 2)
EndFunc   ;==>_WinAPI_HiDWord

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_InflateRect
; Description....: Increases or decreases the width and height of the specified rectangle.
; Syntax.........: _WinAPI_InflateRect ( ByRef $tRECT, $DX, $DY )
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

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_InflateRect

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_IntersectClipRect
; Description....: Creates a new clipping region from the intersection of the current clipping region and the specified rectangle.
; Syntax.........: _WinAPI_IntersectClipRect ( $hDC, $tRECT )
; Parameters.....: $hDC    - Handle to the device context.
;                  $tRECT  - $tagRECT structure that contains the logical coordinates of the specified rectangle.
; Return values..: Success - The value that specifies the new clipping region's complexity; it can be one of the following values.
;
;                            $COMPLEXREGION
;                            $NULLREGION
;                            $SIMPLEREGION
;
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ IntersectClipRect
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_IntersectClipRect($hDC, $tRECT)

	Local $Ret = DllCall('gdi32.dll', 'int', 'IntersectClipRect', 'hwnd', $hDC, 'int', DllStructGetData($tRECT, 1), 'int', DllStructGetData($tRECT, 2), 'int', DllStructGetData($tRECT, 3), 'int', DllStructGetData($tRECT, 4))

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_IntersectClipRect

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

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $tRECT
EndFunc   ;==>_WinAPI_IntersectRect

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_IntToDWord
; Description....: Converts a value of type INT to a value of type DWORD.
; Syntax.........: _WinAPI_IntToDWord ( $iValue )
; Parameters.....: $iValue - The value to be converted.
; Return values..: The converted (DWORD) value.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: None
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_IntToDWord($iValue)

	Local $tData = DllStructCreate('dword')

	DllStructSetData($tData, 1, $iValue)

	Return DllStructGetData($tData, 1)
EndFunc   ;==>_WinAPI_IntToDWord

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

	If (@error) Or (Not $Ret[0]) Then
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

	If (@error) Or (Not $Ret[0]) Then
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

	If (@error) Or (Not $Ret[0]) Then
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

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_InvertRgn

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_IOCTL
; Description....: Create a unique system I/O control code (IOCTL).
; Syntax.........: _WinAPI_IOCTL ( $iDeviceType, $iFunction, $iMethod, $iAccess )
; Parameters.....: $iDeviceType - The type of device.
;                  $iFunction   - The action within the device category.
;                  $iMethod     - The method codes for how buffers are passed for I/O and file system controls.
;                  $iAccess     - The access check value for any access.
; Return values..: The IOCTL (DWORD) value.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ CTL_CODE
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_IOCTL($iDeviceType, $iFunction, $iMethod, $iAccess)
	Return BitOR(BitShift($iDeviceType, -16), BitShift($iAccess, -14), BitShift($iFunction, -2), $iMethod)
EndFunc   ;==>_WinAPI_IOCTL

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

	Local $hFile = _WinAPI_CreateFileEx('\\.\' & $sDrive, 3, 0xC0000000, 0x03)

	If Not $hFile Then
		Return SetError(1, 0, 0)
	EndIf

	Local $tSPT = DllStructCreate('ushort Length;byte ScsiStatus;byte PathId;byte TargetId;byte Lun;byte CdbLength;byte SenseInfoLength;byte DataIn;byte Alignment[3];ulong DataTransferLength;ulong TimeOutValue;ulong_ptr DataBufferOffset;ulong SenseInfoOffset;byte Cdb[16];byte Hdr[8]')
	Local $tCDB = DllStructCreate('byte;byte;byte[6];byte[2];byte;byte;byte[4]', DllStructGetPtr($tSPT, 'Cdb'))
	Local $tHDR = DllStructCreate('byte;byte;byte[3];byte;byte[2]', DllStructGetPtr($tSPT, 'Hdr'))
	Local $Size = DllStructGetSize($tSPT) - 8

	DllStructSetData($tSPT, 'Length', $Size)
	DllStructSetData($tSPT, 'ScsiStatus', 0)
	DllStructSetData($tSPT, 'PathId', 0)
	DllStructSetData($tSPT, 'TargetId', 0)
	DllStructSetData($tSPT, 'Lun', 0)
	DllStructSetData($tSPT, 'CdbLength', 12)
	DllStructSetData($tSPT, 'SenseInfoLength', 0)
	DllStructSetData($tSPT, 'DataIn', 1)
	DllStructSetData($tSPT, 'DataTransferLength', 8)
	DllStructSetData($tSPT, 'TimeOutValue', 86400)
	DllStructSetData($tSPT, 'DataBufferOffset', $Size)
	DllStructSetData($tSPT, 'SenseInfoOffset', 0)

	DllStructSetData($tCDB, 1, 0xBD)
	DllStructSetData($tCDB, 2, 0)
	DllStructSetData($tCDB, 4, 0, 1)
	DllStructSetData($tCDB, 4, 8, 2)
	DllStructSetData($tCDB, 5, 0)
	DllStructSetData($tCDB, 6, 0)

	Local $Ret = DllCall('kernel32.dll', 'int', 'DeviceIoControl', 'ptr', $hFile, 'dword', $IOCTL_SCSI_PASS_THROUGH, 'ptr', DllStructGetPtr($tSPT), 'dword', $Size, 'ptr', DllStructGetPtr($tSPT), 'dword', DllStructGetSize($tSPT), 'dword*', 0, 'ptr', 0)

	If (@error) Or (Not $Ret[0]) Then
		$Ret = 0
	EndIf
	_WinAPI_CloseHandle($hFile)
	If Not IsArray($Ret) Then
		Return SetError(2, 0, 0)
	EndIf
	Return Number(BitAND(DllStructGetData($tHDR, 2), 0x10) = 0x10)
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
; Name...........: _WinAPI_IsInternetConnected
; Description....: Determines whether the current user is connected to the Internet.
; Syntax.........: _WinAPI_IsInternetConnected ( )
; Parameters.....: None
; Return values..: Success - 1 - The user is connected to the Internet.
;                            0 - Otherwise.
;                  Failure - 0 and sets the @error flag to non-zero, @extended flag may contain the system error code.
; Author.........: Yashied
; Modified.......:
; Remarks........: This function requires Windows Vista or later.
; Related........:
; Link...........: @@MsdnLink@@ IsInternetConnected
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_IsInternetConnected()

	If Not __DLL('connect.dll') Then
		Return SetError(1, 0, 0)
	EndIf

	Local $Ret = DllCall('connect.dll', 'uint', 'IsInternetConnected')

	If @error Then
		Return SetError(1, 0, 0)
	Else
		Switch $Ret[0]
			Case 0, 1 ; S_OK, S_FALSE

			Case Else
				Return SetError(1, $Ret[0], 0)
		EndSwitch
	EndIf
	Return Number(Not $Ret[0])
EndFunc   ;==>_WinAPI_IsInternetConnected

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_IsLoadKBLayout
; Description....: Determines whether the specified input locale loaded into the system.
; Syntax.........: _WinAPI_IsLoadKBLayout ( $iLanguage )
; Parameters.....: $iLanguage - The name of the input locale identifier (LCID).
; Return values..: Success    - 1 - The input locale is loaded.
;                               0 - Otherwise.
;                  Failure    - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: None
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_IsLoadKBLayout($iLanguage)

	Local $Layout = _WinAPI_GetKeyboardLayoutList()

	If Not IsArray($Layout) Then
		Return SetError(1, 0, 0)
	EndIf
	For $i = 1 To $Layout[0]
		If $Layout[$i] = $iLanguage Then
			Return 1
		EndIf
	Next
	Return 0
EndFunc   ;==>_WinAPI_IsLoadKBLayout

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_IsNetworkAlive
; Description....: Determines whether or not a local system is connected to a network, and identifies the type of network connection.
; Syntax.........: _WinAPI_IsNetworkAlive ( )
; Parameters.....: None
; Return values..: Success - The type of network connection ($NETWORK_ALIVE_*) if a local system is connected to a network.
;                            0 - Is no connection.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: Always check @error flag before checking the return value of this function. If the @error is not 0,
;                  the function has failed and the following values do not apply.
;
;                  This function is only available for TCP/IP connections.
; Related........:
; Link...........: @@MsdnLink@@ IsNetworkAlive
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_IsNetworkAlive()

	If Not __DLL('sensapi.dll') Then
		Return SetError(1, 0, 0)
	EndIf

	Local $Ret = DllCall('sensapi.dll', 'int', 'IsNetworkAlive', 'int*', 0)

	If (@error) Or (Not $Ret[0]) Or (_WinAPI_GetLastError()) Then
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
				If BitAND(DllStructGetData($tData, 1, $i + 1), 0xF0) Then
					Return $i
				EndIf
		EndSwitch
	Next
	Return 0
EndFunc   ;==>_WinAPI_IsPressed

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_IsProcessInJob
; Description....: Determines whether the process is running in the specified job.
; Syntax.........: _WinAPI_IsProcessInJob( $hProcess [, $hJob] )
; Parameters.....: $hProcess - Handle to the process to be tested. The handle must have the $PROCESS_QUERY_INFORMATION or
;                              $PROCESS_QUERY_LIMITED_INFORMATION access right.
;                  $hJob     - Handle to the job. If this parameter is 0, the function tests if the process is running under any job.
; Return values..: Success   - 1 - The process is running in the job.
;                              0 - Otherwise.
;                  Failure   - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: An application cannot obtain a handle to the job object in which it is running unless it has the name of the job
;                  object. However, an application can call the _WinAPI_QueryInformationJobObject() function with 0 to obtain
;                  information about the job object.
; Related........:
; Link...........: @@MsdnLink@@ IsProcessInJob
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_IsProcessInJob($hProcess, $hJob = 0)

	Local $Ret = DllCall('kernel32.dll', 'int', 'IsProcessInJob', 'ptr', $hProcess, 'ptr', $hJob, 'int*', 0)

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[3]
EndFunc   ;==>_WinAPI_IsProcessInJob

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_IsProcessorFeaturePresent
; Description....: Determines whether the specified processor feature is supported by the current computer.
; Syntax.........: _WinAPI_IsProcessorFeaturePresent ( $iFeature )
; Parameters.....: $iFeature - The processor feature to be tested. This parameter can be one of the $PF_* constants.
; Return values..: Success   - 1 - The feature is supported.
;                              0 - Otherwise.
;                  Failure   - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ IsProcessorFeaturePresent
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_IsProcessorFeaturePresent($iFeature)

	Local $Ret = DllCall('kernel32.dll', 'int', 'IsProcessorFeaturePresent', 'dword', $iFeature)

	If @error Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_IsProcessorFeaturePresent

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
; Name...........: _WinAPI_IsThemeBackgroundPartiallyTransparent
; Description....: Retrieves whether the background specified by the visual style has transparent pieces or alpha-blended pieces.
; Syntax.........: _WinAPI_IsThemeBackgroundPartiallyTransparent ( $hTheme, $iPartId, $iStateId )
; Parameters.....: $hTheme   - Handle to a window's specified theme data.
;                  $iPartId  - The part.
;                  $iStateId - The state of the part.
; Return values..: Success   - 1 - The theme-specified background has transparent pieces or alpha-blended pieces.
;                              0 - Otherwise.
;                  Failure   - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ IsThemeBackgroundPartiallyTransparent
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_IsThemeBackgroundPartiallyTransparent($hTheme, $iPartId, $iStateId)

	Local $Ret = DllCall('uxtheme.dll', 'int', 'IsThemeBackgroundPartiallyTransparent', 'ptr', $hTheme, 'int', $iPartId, 'int', $iStateId)

	If @error Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_IsThemeBackgroundPartiallyTransparent

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_IsThemePartDefined
; Description....: Retrieves whether a visual style has defined parameters for the specified part.
; Syntax.........: _WinAPI_IsThemePartDefined ( $hTheme, $iPartId )
; Parameters.....: $hTheme  - Handle to a window's specified theme data.
;                  $iPartId - The part.
; Return values..: Success  - 1 - The theme has defined parameters for the specified $iPartId.
;                             0 - Otherwise.
;                  Failure  - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ IsThemePartDefined
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_IsThemePartDefined($hTheme, $iPartId)

	Local $Ret = DllCall('uxtheme.dll', 'int', 'IsThemePartDefined', 'ptr', $hTheme, 'int', $iPartId, 'int', 0)

	If @error Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_IsThemePartDefined

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_IsValidLocale
; Description....: Determines if the specified locale is installed or supported on the operating system.
; Syntax.........: _WinAPI_IsValidLocale ( $LCID [, $iFlag] )
; Parameters.....: $LCID   - Locale identifier of the locale to validate.
;                  $iFlag  - Flag specifying the validity test to apply to the locale identifier. This parameter can have one
;                            of the following values.
;
;                            $LCID_INSTALLED
;                            $LCID_SUPPORTED
;
; Return values..: Success - 1 - The locale identifier passes the specified validity test.
;                            0 - Otherwise.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ IsValidLocale
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_IsValidLocale($LCID, $iFlag)

	Local $Ret = DllCall('kernel32.dll', 'int', 'IsValidLocale', 'long', $LCID, 'dword', $iFlag)

	If @error Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_IsValidLocale

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
; Remarks........: A child window receives input only if it is both enabled and visible.
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
; Name...........: _WinAPI_IsWow64Process
; Description....: Determines whether the specified process is running under WOW64.
; Syntax.........: _WinAPI_IsWow64Process ( [$PID] )
; Parameters.....: $PID    - The PID of the process. Default (0) is the current process.
; Return values..: Success - 1 - The process is running under WOW64.
;                            0 - Otherwise.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ IsWow64Process
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_IsWow64Process($PID = 0)

	If Not $PID Then
		$PID = _WinAPI_GetCurrentProcessID()
		If Not $PID Then
			Return SetError(1, 0, 0)
		EndIf
	EndIf

	Local $hProcess = DllCall('kernel32.dll', 'ptr', 'OpenProcess', 'dword', 0x00000400, 'int', 0, 'dword', $PID)

	If (@error) Or (Not $hProcess[0]) Then
		Return SetError(1, 0, 0)
	EndIf

	Local $Ret = DllCall('kernel32.dll', 'int', 'IsWow64Process', 'ptr', $hProcess[0], 'int*', 0)

	If (@error) Or (Not $Ret[0]) Then
		$Ret = 0
	EndIf
	_WinAPI_CloseHandle($hProcess[0])
	If Not IsArray($Ret) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[2]
EndFunc   ;==>_WinAPI_IsWow64Process

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

	Local $hFile = _WinAPI_CreateFileEx('\\.\' & $sDrive, 3, 0, 0)

	If Not $hFile Then
		Return SetError(1, 0, 0)
	EndIf

	Local $Ret = DllCall('kernel32.dll', 'int', 'DeviceIoControl', 'ptr', $hFile, 'dword', $IOCTL_DISK_IS_WRITABLE, 'ptr', 0, 'dword', 0, 'ptr', 0, 'dword', 0, 'dword*', 0, 'ptr', 0)

	If @error Then
		$Ret = 0
	Else
		If Not $Ret[0] Then
			Switch _WinAPI_GetLastError()
				Case 19 ; ERROR_WRITE_PROTECT

				Case Else
					$Ret = 0
			EndSwitch
		EndIf
	EndIf
	_WinAPI_CloseHandle($hFile)
	If Not IsArray($Ret) Then
		Return SetError(2, 0, 0)
	EndIf
	Return $Ret[0]
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
; Syntax.........: _WinAPI_Keybd_Event ( $vKey, $iFlags [, $iScanCode [, $iExtraInfo]] )
; Parameters.....: $vKey       - The virtual-key code ($VK_*). The code must be a value in the range 1 to 254.
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

Func _WinAPI_Keybd_Event($vKey, $iFlags, $iScanCode = 0, $iExtraInfo = 0)
	DllCall('user32.dll', 'int', 'keybd_event', 'int', $vKey, 'int', $iScanCode, 'int', $iFlags, 'ptr', $iExtraInfo)
	If @error Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_Keybd_Event

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_KillTimer
; Description....: Destroys the specified timer.
; Syntax.........: _WinAPI_KillTimer ( $hWnd, $iTimerID )
; Parameters.....: $hWnd     - Handle to the window associated with the specified timer. This value must be the same as the
;                              $hWnd value passed to the _WinAPI_SetTimer() function that created the timer.
;                  $iTimerID - The timer identifier which specifies the timer to be destroyed.
; Return values..: Success   - 1.
;                  Failure   - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: This function does not remove WM_TIMER messages already posted to the message queue.
; Related........:
; Link...........: @@MsdnLink@@ KillTimer
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_KillTimer($hWnd, $iTimerID)

	Local $Ret = DllCall('user32.dll', 'int', 'KillTimer', 'hwnd', $hWnd, 'uint_ptr', $iTimerID)

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_KillTimer

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_LineDDA
; Description....: Determines which pixels should be highlighted for a line.
; Syntax.........: _WinAPI_LineDDA ( $X1, $Y1, $X2, $Y2, $pLineProc [, $pData] )
; Parameters.....: $X1        - Specifies the x-coordinate, in logical units, of the line's starting point.
;                  $Y1        - Specifies the y-coordinate, in logical units, of the line's starting point.
;                  $X2        - Specifies the x-coordinate, in logical units, of the line's ending point.
;                  $Y2        - Specifies the y-coordinate, in logical units, of the line's ending point.
;                  $pLineProc - Pointer to an application-defined callback function.
;                  $pData     - Pointer to the application-defined data.
; Return values..: Success    - 1.
;                  Failure    - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: The _WinAPI_LineDDA() function passes the coordinates for each point along the line, except for the line's ending
;                  point, to the application-defined callback function. In addition to passing the coordinates of a point, this
;                  function passes any existing application-defined data.
; Related........:
; Link...........: @@MsdnLink@@ LineDDA
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_LineDDA($X1, $Y1, $X2, $Y2, $pLineProc, $pData = 0)

	Local $Ret = DllCall('gdi32.dll', 'int', 'LineDDA', 'int', $X1, 'int', $Y1, 'int', $X2, 'int', $Y2, 'ptr', $pLineProc, 'lparam', $pData)

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_LineDDA

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

	Local $TypeOfName = 'int'

	If IsString($sName) Then
		$TypeOfName = 'wstr'
	EndIf

	Local $Ret = DllCall('user32.dll', 'ptr', 'LoadCursorW', 'ptr', $hInstance, $TypeOfName, $sName)

	If (@error) Or (Not $Ret[0]) Then
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

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_LoadCursorFromFile

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_LoadIconWithScaleDown
; Description....: Loads an icon and scales down a larger image instead of scaling up a smaller image.
; Syntax.........: _WinAPI_LoadIconWithScaleDown ( $hInstance, $sName, $iWidth, $iHeight )
; Parameters.....: $hInstance - Handle to the module of either a DLL or executable (.exe) file that contains the icon to be loaded.
;                  $sName     - The information about the icon to load. If $hInstance is not 0, $sName specifies the icon resource
;                               either by name or ordinal, otherwise, $sName specifies either the name of a standalone icon (.ico)
;                               file or the identifier of a predefined icon to load.
;
;                               $IDI_APPLICATION
;                               $IDI_ASTERISK
;                               $IDI_ERROR
;                               $IDI_EXCLAMATION
;                               $IDI_HAND
;                               $IDI_INFORMATION
;                               $IDI_QUESTION
;                               $IDI_SHIELD
;                               $IDI_WARNING
;                               $IDI_WINLOGO
;
;                  $iWidth    - The desired width, in pixels, of the icon.
;                  $iHeight   - The desired height, in pixels, of the icon.
; Return values..: Success    - The icon handle.
;                  Failure    - 0 and sets the @error flag to non-zero, @extended flag may contain the system error code.
; Author.........: Yashied
; Modified.......:
; Remarks........: This function requires Windows Vista or later.
; Related........:
; Link...........: @@MsdnLink@@ LoadIconWithScaleDown
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_LoadIconWithScaleDown($hInstance, $sName, $iWidth, $iHeight)

	Local $TypeOfName = 'int'

	If IsString($sName) Then
		$TypeOfName = 'wstr'
	EndIf

	Local $Ret = DllCall('comctl32.dll ', 'uint', 'LoadIconWithScaleDown', 'ptr', $hInstance, $TypeOfName, $sName, 'int', $iWidth, 'int', $iHeight, 'ptr*', 0)

	If @error Then
		Return SetError(1, 0, 0)
	Else
		If $Ret[0] Then
			Return SetError(1, $Ret[0], 0)
		EndIf
	EndIf
	Return $Ret[5]
EndFunc   ;==>_WinAPI_LoadIconWithScaleDown

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_LoadKeyboardLayout
; Description....: Loads a new input locale identifier into the system.
; Syntax.........: _WinAPI_LoadKeyboardLayout ( $iLanguage [, $iFlag] )
; Parameters.....: $iLanguage - The name of the input locale identifier to load (LCID).
;                  $iFlag     - The flag that specifies how the input locale identifier is to be loaded. This parameter can be
;                               one of the following values.
;
;                               $KLF_ACTIVATE
;                               $KLF_NOTELLSHELL
;                               $KLF_REORDER
;                               $KLF_REPLACELANG
;                               $KLF_SUBSTITUTE_OK
;                               $KLF_SETFORPROCESS
;
; Return values..: Success    - The input locale identifier to the locale matched with the requested name.
;                  Failure    - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ LoadKeyboardLayout
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_LoadKeyboardLayout($iLanguage, $iFlag = 0)

	Local $Ret = DllCall('user32.dll', 'long', 'LoadKeyboardLayoutW', 'wstr', Hex($iLanguage, 8), 'uint', $iFlag)

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_LoadKeyboardLayout

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_LoadMedia
; Description....: Loads media into a device.
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

	Local $hFile = _WinAPI_CreateFileEx('\\.\' & $sDrive, 3, 0x80000000, 0x01)

	If Not $hFile Then
		Return SetError(1, 0, 0)
	EndIf

	Local $Ret = DllCall('kernel32.dll', 'int', 'DeviceIoControl', 'ptr', $hFile, 'dword', $IOCTL_STORAGE_LOAD_MEDIA, 'ptr', 0, 'dword', 0, 'ptr', 0, 'dword', 0, 'dword*', 0, 'ptr', 0)

	If (@error) Or (Not $Ret[0]) Then
		$Ret = 0
	EndIf
	_WinAPI_CloseHandle($hFile)
	If Not IsArray($Ret) Then
		Return SetError(2, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_LoadMedia

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_LoadResource
; Description....: Loads the specified resource into global memory.
; Syntax.........: _WinAPI_LoadResource ( $hInstance, $hResource )
; Parameters.....: $hInstance - Handle to the module whose executable file contains the resource. If this parameter is 0, the system
;                               loads the resource from the module that was used to create the current process.
;                  $hResource - Handle to the resource to be loaded. This handle is returned by the _WinAPI_FindResource()
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

Func _WinAPI_LoadResource($hInstance, $hResource)

	Local $Ret = DllCall('kernel32.dll', 'ptr', 'LoadResource', 'ptr', $hInstance, 'ptr', $hResource)

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_LoadResource

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_LoByte
; Description....: Returns the low BYTE of a 16-bit (2 bytes) value.
; Syntax.........: _WinAPI_LoByte ( $iValue )
; Parameters.....: $iValue - 16-bit value.
; Return values..: Low BYTE value.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: None
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_LoByte($iValue)
	Return BitAND($iValue, 0xFF)
EndFunc   ;==>_WinAPI_LoByte

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

	Local $hFile = _WinAPI_CreateFileEx('\\.\' & $sDrive, 3, 0xC0000000, 0x03)

	If Not $hFile Then
		Return SetError(1, 0, 0)
	EndIf

	Local $tPREVENT_MEDIA_REMOVAL = DllStructCreate('byte')

	DllStructSetData($tPREVENT_MEDIA_REMOVAL, 1, $fLock)

	Local $Ret = DllCall('kernel32.dll', 'int', 'DeviceIoControl', 'ptr', $hFile, 'dword', $IOCTL_STORAGE_MEDIA_REMOVAL, 'ptr', DllStructGetPtr($tPREVENT_MEDIA_REMOVAL), 'dword', DllStructGetSize($tPREVENT_MEDIA_REMOVAL), 'ptr', 0, 'dword', 0, 'dword*', 0, 'ptr', 0)

	If (@error) Or (Not $Ret[0]) Then
		$Ret = 0
	EndIf
	_WinAPI_CloseHandle($hFile)
	If Not IsArray($Ret) Then
		Return SetError(2, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_LockDevice

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_LockFile
; Description....: Locks the specified file for exclusive access by the calling process.
; Syntax.........: _WinAPI_LockFile ( $hFile, $iOffset, $iLenght )
; Parameters.....: $hFile   - Handle to the file.
;                  $iOffset - The starting byte offset in the file where the lock should begin.
;                  $iLenght - The length of the byte range to be locked.
; Return values..: Success  - 1.
;                  Failure  - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: If a process terminates with a portion of a file locked or closes a file that has outstanding locks, the locks are
;                  unlocked by the operating system. However, the time it takes for the operating system to unlock these locks depends
;                  upon available system resources. Therefore, it is recommended that your process explicitly unlock all files it
;                  has locked when it terminates.
; Related........:
; Link...........: @@MsdnLink@@ LockFile
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_LockFile($hFile, $iOffset, $iLenght)

	Local $Ret = DllCall('kernel32.dll', 'int', 'LockFile', 'ptr', $hFile, 'dword', _WinAPI_LoDWord($iOffset), 'dword', _WinAPI_HiDWord($iOffset), 'dword', _WinAPI_LoDWord($iLenght), 'dword', _WinAPI_HiDWord($iLenght))

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_LockFile

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
;
;                  Note _WinAPI_LockResource() does not actually lock memory; it is just used to obtain a pointer to the memory
;                  containing the resource data. The name of the function comes from versions prior to Windows XP, when it was
;                  used to lock a global memory block allocated by _WinAPI_LoadResource().
; Related........:
; Link...........: @@MsdnLink@@ LockResource
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_LockResource($hData)

	Local $Ret = DllCall('kernel32.dll', 'ptr', 'LockResource', 'ptr', $hData)

	If (@error) Or (Not $Ret[0]) Then
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
; Name...........: _WinAPI_LoDWord
; Description....: Returns the low DWORD of a 64-bit (8 bytes) value.
; Syntax.........: _WinAPI_LoDWord ( $iValue )
; Parameters.....: $iValue - 64-bit value.
; Return values..: Low DWORD value.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: None
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_LoDWord($iValue)

	Local $tInt64, $tQWord

	$tInt64 = DllStructCreate('int64')
	$tQWord = DllStructCreate('dword;dword', DllStructGetPtr($tInt64))
	DllStructSetData($tInt64, 1, $iValue)
	Return DllStructGetData($tQWord, 1)
EndFunc   ;==>_WinAPI_LoDWord

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_LongMid
; Description....: Extracts a number of bits from a DWORD (32-bit) value.
; Syntax.........: _WinAPI_LongMid ( $iValue, $iStart, $iCount )
; Parameters.....: $iValue - 32-bit value.
;                  $iStart - The bit position to start. (0 - first bit)
;                  $iCount - The number of bits to extract.
; Return values..: The value that consists of a specified bits.
; Author.........: Yashied
; Modified.......:
; Remarks........: This function does not check the parameters for valid values. If values is incorrect, the function may return
;                  an unexpected results.
; Related........:
; Link...........: None
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_LongMid($iValue, $iStart, $iCount)
	Return BitAND(BitShift($iValue, $iStart), BitOR(BitShift(BitShift(0x7FFFFFFF, 32 - ($iCount + 1)), 1), BitShift(1, -($iCount - 1))))
EndFunc   ;==>_WinAPI_LongMid

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_LookupIconIdFromDirectoryEx
; Description....: Searches through icon or cursor data for the icon or cursor that best fits the current display device.
; Syntax.........: _WinAPI_LookupIconIdFromDirectoryEx ( $pData [, $fIcon [, $xDesired [, $yDesired [, $iFlags]]]] )
; Parameters.....: $pData    - The icon or cursor directory data. Because this function does not validate the resource data, it
;                              causes a general protection (GP) fault or returns an undefined value if presbits is not pointing
;                              to validresource data.
;                  $fIcon    - Specifies whether an icon or a cursor is sought, valid values:
;                  |TRUE     - The function is searching for an icon. (Default)
;                  |FALSE    - The function is searching for a cursor.
;                  $xDesired - The desired width, in pixels, of the icon or cursor. If this parameter is zero, the function uses the
;                              system metric value.
;                  $yDesired - The desired height, in pixels, of the icon or cursor. If this parameter is zero, the function uses the
;                              system metric value.
;                  $iFlags   - This parameter can be one or more of the following values.
;
;                              $LR_DEFAULTCOLOR
;                              $LR_MONOCHROME
;
; Return values..: Success   - An integer resource identifier for the icon or cursor that best fits the current display device.
;                  Failure   - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: The icon directory is loaded from a resource file with resource type $RT_GROUP_ICON (or $RT_GROUP_CURSOR),
;                  and an integer resource name for the specific icon to be loaded. _WinAPI_LookupIconIdFromDirectoryEx() returns
;                  an integer identifier that is the resource name of the icon that best fits the current display device.
; Related........:
; Link...........: @@MsdnLink@@ LookupIconIdFromDirectoryEx
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_LookupIconIdFromDirectoryEx($pData, $fIcon = 1, $xDesired = 0, $yDesired = 0, $iFlags = 0)

	Local $Ret = DllCall('user32.dll', 'int', 'LookupIconIdFromDirectoryEx', 'ptr', $pData, 'int', $fIcon, 'int', $xDesired, 'int', $yDesired, 'uint', $iFlags)

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_LookupIconIdFromDirectoryEx

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_LookupPrivilegeName
; Description....: Retrieves the name that corresponds to the privilege by a specified locally unique identifier (LUID).
; Syntax.........: _WinAPI_LookupPrivilegeName ( $tLUID )
; Parameters.....: $tLUID  - $tagLUID structure that specifies the LUID by which the privilege is known on the target system.
; Return values..: Success - The string that represents the privilege name. For example, "SeSecurityPrivilege".
;                  Failure - Empty string and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ LookupPrivilegeName
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_LookupPrivilegeName($tLUID)

	Local $tData = DllStructCreate('wchar[128]')
	Local $Ret = DllCall('advapi32.dll', 'int', 'LookupPrivilegeNameW', 'ptr', 0, 'ptr', DllStructGetPtr($tLUID), 'ptr', DllStructGetPtr($tData), 'dword*', 128)

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, '')
	EndIf
	Return DllStructGetData($tData, 1)
EndFunc   ;==>_WinAPI_LookupPrivilegeName

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_LookupPrivilegeValue
; Description....: Retrieves the locally unique identifier (LUID) to locally represent the specified privilege name.
; Syntax.........: _WinAPI_LookupPrivilegeValue ( $sPrivilege )
; Parameters.....: $sPrivilege - The string that specifies the name of the privilege ($SE_*).
; Return values..: Success     - $tagLUID structure that contains the LUID.
;                  Failure     - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ LookupPrivilegeValue
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_LookupPrivilegeValue($sPrivilege)

	Local $tLUID = DllStructCreate($tagLUID)
	Local $Ret = DllCall('advapi32.dll', 'int', 'LookupPrivilegeValueW', 'ptr', 0, 'wstr', $sPrivilege, 'ptr', DllStructGetPtr($tLUID))

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $tLUID
EndFunc   ;==>_WinAPI_LookupPrivilegeValue

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_MapViewOfFile
; Description....: Maps a view of a file mapping into the address space of a calling process.
; Syntax.........: _WinAPI_MapViewOfFile ( $hMapping [, $iOffset [, $iBytes [, $iAccess]]] )
; Parameters.....: $hMapping - Handle to a file mapping object. The _WinAPI_CreateFileMapping() and _WinAPI_OpenFileMapping()
;                              functions return this handle.
;                  $iOffset  - The file offset where the view is to begin.
;                  $iBytes   - The number of bytes of a file mapping to map to a view. All bytes must be within the maximum size
;                              specified by _WinAPI_CreateFileMapping(). If $iBytes is 0, the mapping extends from the specified
;                              offset to the end of the file mapping.
;                  $iAccess  - The access to the file mapping object. This parameter can be one of the following values.
;
;                              $FILE_MAP_ALL_ACCESS
;                              $FILE_MAP_COPY
;                              $FILE_MAP_READ
;                              $FILE_MAP_WRITE
;
;                              Each of the preceding values can be combined with the following value.
;
;                              $FILE_MAP_EXECUTE
;
; Return values..: Success   - The starting address of the mapped view.
;                  Failure   - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: For files that are larger than the address space, you can only map a small portion of the file data at one time.
;                  When the first view is complete, then you unmap it and map a new view.
; Related........:
; Link...........: @@MsdnLink@@ MapViewOfFile
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_MapViewOfFile($hMapping, $iOffset = 0, $iBytes = 0, $iAccess = 0x0006)

	Local $Ret = DllCall('kernel32.dll', 'ptr', 'MapViewOfFile', 'ptr', $hMapping, 'dword', $iAccess, 'dword', _WinAPI_HiDWord($iOffset), 'dword', _WinAPI_LoDWord($iOffset), 'dword', $iBytes)

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_MapViewOfFile

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_MessageBoxCheck
; Description....: Displays a message box that gives the user the option of suppressing further occurrences.
; Syntax.........: _WinAPI_MessageBoxCheck ( $iType, $sTitle, $sText, $sRegVal [, $iDefault [, $hParent]] )
; Parameters.....: $iType    - The flags that specify the contents and behavior of the message box.
;
;                              You must specify the buttons to be displayed by setting one and only one of the following flags.
;
;                              $MB_OK
;                              $MB_OKCANCEL
;                              $MB_YESNO
;
;                              You can display an optional icon by setting one and only one of the following flags.
;
;                              $MB_ICONEXCLAMATION
;                              $MB_ICONHAND
;                              $MB_ICONINFORMATION
;                              $MB_ICONQUESTION
;
;                  $sTitle   - The string that contains the title of the message box.
;                  $sText    - The string that contains the message to be displayed.
;                  $sRegVal  - The string that contains a unique string value to associate with this message.
;                  $iDefault - The value that the function returns when the user has opted not to have the message box displayed
;                              again. If the user has not opted to suppress the message box, the message box is displayed and
;                              the function ignores $iDefault.
;                  $hParent  - The window handle to the message box's owner.
; Return values..: Success   - If the user has already chosen to suppress the message box, the function immediately returns the
;                              value assigned to $iDefault, otherwise, returns one of the $ID_* constants.
;                  Failure   - (-1) and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: This function records the message boxes that the user has chosen to suppress under the following registry key.
;
;                  HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\LowRegistry\DontShowMeThisDialogAgain
;
; Related........:
; Link...........: @@MsdnLink@@ SHMessageBoxCheck
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_MessageBoxCheck($iType, $sTitle, $sText, $sRegVal, $iDefault = -1, $hParent = 0)

	Local $Ret = DllCall('shlwapi.dll', 'int', 'SHMessageBoxCheckW', 'hwnd', $hParent, 'wstr', $sText, 'wstr', $sTitle, 'uint', $iType, 'int', $iDefault, 'wstr', $sRegVal)

	If @error Then
		Return SetError(1, 0, -1)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_MessageBoxCheck

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_MessageBoxIndirect
; Description....: Creates, displays, and operates a message box.
; Syntax.........: _WinAPI_MessageBoxIndirect ( $tMSGBOXPARAMS )
; Parameters.....: $tMSGBOXPARAMS - $tagMSGBOXPARAMS structure that contains information used to display the message box.
; Return values..: Success        - One of the $ID* constants.
;                  Failure        - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: When you use a system-modal message box to indicate that the system is low on memory, the strings pointed to by the
;                  "Text" and "Caption" members of the $tagMSGBOXPARAMS structure should not be taken from a resource file, because
;                  an attempt to load the resource may fail.
;
;                  If you create a message box while a dialog box is present, use a handle to the dialog box as the hWnd parameter.
;                  The hWnd parameter should not identify a child window, such as a control in a dialog box.
; Related........:
; Link...........: @@MsdnLink@@ MessageBoxIndirect
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_MessageBoxIndirect($tMSGBOXPARAMS)

	Local $Ret = DllCall('user32.dll', 'int', 'MessageBoxIndirectW', 'ptr', DllStructGetPtr($tMSGBOXPARAMS))

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_MessageBoxIndirect

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_MoveFileEx
; Description....: Moves a file or directory, notifying the application of its progress through a callback function.
; Syntax.........: _WinAPI_MoveFileEx ( $sExistingFile, $sNewFile [, $iFlags [, $pProgressProc [, $pData] )
; Parameters.....: $sExistingFile - The name of the existing file or directory on the local computer.
;
;                                   If $iFlags specifies $MOVE_FILE_DELAY_UNTIL_REBOOT, the file cannot exist on a remote share
;                                   because delayed operations are performed before the network is available.
;
;                  $sNewFile      - The new name of the file or directory on the local computer.
;
;                                   When moving a file, $sNewFile can be on a different file system or volume. If $sNewFile is
;                                   on another drive, you must set the  $MOVE_FILE_COPY_ALLOWED flag in $iFlags parameter.
;
;                                   When moving a directory, $sExistingFile and $sNewFile  must be on the same drive.
;
;                                   If $iFlags specifies $MOVE_FILE_DELAY_UNTIL_REBOOT and $sNewFile is 0, _WinAPI_MoveFileEx()
;                                   registers $sExistingFile to be deleted when the system restarts. If $sExistingFile refers to
;                                   a directory, the system removes the directory at restart only if the directory is empty.
;
;                  $iFlags        - The move options. This parameter can be one or more of the following values.
;
;                                   $MOVE_FILE_COPY_ALLOWED
;                                   $MOVE_FILE_CREATE_HARDLINK
;                                   $MOVE_FILE_DELAY_UNTIL_REBOOT
;                                   $MOVE_FILE_FAIL_IF_NOT_TRACKABLE
;                                   $MOVE_FILE_REPLACE_EXISTING
;                                   $MOVE_FILE_WRITE_THROUGH
;
;                  $pProgressProc - The address of a callback function that is called each time another portion of the file
;                                   has been moved.
;
;                                   (See MSDN for more information)
;
;                  $pData         - The argument to be passed to the callback function.
; Return values..: Success        - 1.
;                  Failure        - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: If the $iFlags parameter specifies $MOVE_FILE_DELAY_UNTIL_REBOOT, _WinAPI_MoveFileEx() fails if it cannot
;                  access the registry. The function stores the locations of the files to be renamed at restart in the
;                  following registry value:
;
;                  HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\PendingFileRenameOperations
;
; Related........:
; Link...........: @@MsdnLink@@ MoveFileWithProgress
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_MoveFileEx($sExistingFile, $sNewFile, $iFlags = 0, $pProgressProc = 0, $pData = 0)

	Local $TypeOfNewFile = 'wstr'

	If Not StringStripWS($sNewFile, 3) Then
		$TypeOfNewFile = 'ptr'
		$sNewFile = 0
	EndIf

	Local $Ret = DllCall('kernel32.dll', 'int', 'MoveFileWithProgressW', 'wstr', $sExistingFile, $TypeOfNewFile, $sNewFile, 'ptr', $pProgressProc, 'long_ptr', $pData, 'dword', $iFlags)

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_MoveFileEx

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_MoveToEx
; Description....: Updates the current position to the specified point.
; Syntax.........: _WinAPI_MoveToEx ( $hDC, $iX, $iY )
; Parameters.....: $hDC    - Handle to the device context.
;                  $iX     - The x-coordinate, in logical units, of the new position, in logical units.
;                  $iY     - The y-coordinate, in logical units, of the new position, in logical units.
; Return values..: Success - $tagPOINT structure that receives the previous current position.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ MoveToEx
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_MoveToEx($hDC, $iX, $iY)

	Local $tPOINT = DllStructCreate($tagPOINT)
	Local $Ret = DllCall('gdi32.dll', 'int', 'MoveToEx', 'hwnd', $hDC, 'int', $iX, 'int', $iY, 'ptr', DllStructGetPtr($tPOINT))

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $tPOINT
EndFunc   ;==>_WinAPI_MoveToEx

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

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, '')
	EndIf
	Return DllStructGetData($tData, 1)
EndFunc   ;==>_WinAPI_OemToChar

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_OffsetPoints
; Description....: Moves a points from the array by the specified offsets.
; Syntax.........: _WinAPI_OffsetPoints ( ByRef $aPoint, $iXOffset, $iYOffset [, $iStart [, $iEnd]] )
; Parameters.....: $aPoint   - The 2D array ([x1, y1, ...], [x2, y2, ...], ... [xN, yN, ...]). Every first two elements from this
;                              array specifies a point to be move. Other array elements (if any) do not change.
;                  $iXOffset - The number of logical units to move left or right.
;                  $iYOffset - The number of logical units to move up or down.
;                  $iStart   - The index of array to start moving at.
;                  $iEnd     - The index of array to stop moving at.
; Return values..: Success   - 1.
;                  Failure   - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: None
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_OffsetPoints(ByRef $aPoint, $iXOffset, $iYOffset, $iStart = 0, $iEnd = -1)
	If UBound($aPoint, 2) < 2  Then
		Return SetError(2, 0, 0)
	EndIf
	If $iStart < 0 Then
		$iStart = 0
	EndIf
	If ($iEnd < 0) Or ($iEnd > UBound($aPoint) - 1) Then
		$iEnd = UBound($aPoint) - 1
	EndIf
	If $iStart > $iEnd Then
		Return SetError(1, 0, 0)
	EndIf
	For $i = $iStart To $iEnd
		$aPoint[$i][0] += $iXOffset
		$aPoint[$i][1] += $iYOffset
	Next
	Return 1
EndFunc   ;==>_WinAPI_OffsetPoints

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_OffsetClipRgn
; Description....: Moves the clipping region of a device context by the specified offsets.
; Syntax.........: _WinAPI_OffsetClipRgn ( $hDC, $iXOffset, $iYOffset )
; Parameters.....: $hDC      - Handle to the device context.
;                  $iXOffset - The number of logical units to move left or right.
;                  $iYOffset - The number of logical units to move up or down.
; Return values..: Success   - The value that specifies the new clipping region's complexity; it can be one of the following values.
;
;                              $COMPLEXREGION
;                              $NULLREGION
;                              $SIMPLEREGION
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

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_OffsetClipRgn

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_OffsetRect
; Description....: Moves the specified rectangle by the specified offsets.
; Syntax.........: _WinAPI_OffsetRect ( ByRef $tRECT, $DX, $DY )
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

	If (@error) Or (Not $Ret[0]) Then
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
; Return values..: Success   - The value that specifies the new clipping region's complexity; it can be one of the following values.
;
;                              $COMPLEXREGION
;                              $NULLREGION
;                              $SIMPLEREGION
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

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_OffsetRgn

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_OpenFileMapping
; Description....: Opens a named file mapping object.
; Syntax.........: _WinAPI_OpenFileMapping ( $sName [, $iAccess [, $fInherit]] )
; Parameters.....: $sName    - The name of the file mapping object to be opened.
;                  $iAccess  - The access to the file mapping object. This parameter can be one of the following values.
;
;                              $FILE_MAP_ALL_ACCESS
;                              $FILE_MAP_COPY
;                              $FILE_MAP_READ
;                              $FILE_MAP_WRITE
;
;                              Each of the preceding values can be combined with the following value.
;
;                              $FILE_MAP_EXECUTE
;
;                  $fInherit - Specifies whether inherites the handle by a processes, valid values:
;                  |TRUE     - The processes created by this process will inherit the handle.
;                  |FALSE    - The processes do not inherit this handle. (Default)
; Return values..: Success   - Handle to the specified file mapping object.
;                  Failure   - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ OpenFileMapping
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_OpenFileMapping($sName, $iAccess = 0x0006, $fInherit = 0)

	Local $Ret = DllCall('kernel32.dll', 'ptr', 'OpenFileMappingW', 'dword', $iAccess, 'int', $fInherit, 'wstr', $sName)

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_OpenFileMapping

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

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_OpenIcon

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_OpenJobObject
; Description....: Opens an existing job object.
; Syntax.........: _WinAPI_OpenJobObject ( $sName [, $iAccess [, $fInherit] )
; Parameters.....: $sName    - The name of the job to be opened. Name comparisons are case sensitive.
;                  $iAccess  - The access to the job object. This parameter can be one or more of the following values.
;
;                              $JOB_OBJECT_ALL_ACCESS
;                              $JOB_OBJECT_ASSIGN_PROCESS
;                              $JOB_OBJECT_QUERY
;                              $JOB_OBJECT_SET_ATTRIBUTES
;                              $JOB_OBJECT_SET_SECURITY_ATTRIBUTES
;                              $JOB_OBJECT_TERMINATE
;
;                  $fInherit - Specifies whether inherites the handle by a processes, valid values:
;                  |TRUE     - The processes created by this process will inherit the handle.
;                  |FALSE    - The processes do not inherit this handle. (Default)
; Return values..: Success   - Handle to the job object.
;                  Failure   - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ OpenJobObject
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_OpenJobObject($sName, $iAccess = 0x001F001F, $fInherit = 0)

	Local $Ret = DllCall('kernel32.dll', 'ptr', 'OpenJobObjectW', 'dword', $iAccess, 'int', $fInherit, 'wstr', $sName)

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_OpenJobObject

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_OpenMutex
; Description....: Opens an existing named mutex object.
; Syntax.........: _WinAPI_OpenMutex ( $sMutex [, $iAccess [, $fInherit]] )
; Parameters.....: $sMutex   - The name of the mutex to be opened. Name comparisons are case sensitive.
;                  $iAccess  - The access to the mutex object. The function fails if the security descriptor of the specified object
;                              does not permit the requested access for the calling process. This parameter can be one of the
;                              following values.
;
;                              $MUTEX_ALL_ACCESS
;                              $MUTEX_MODIFY_STATE
;
;                  $fInherit - Specifies whether inherites the handle by a processes, valid values:
;                  |TRUE     - The processes created by this process will inherit the handle.
;                  |FALSE    - The processes do not inherit this handle. (Default)
; Return values..: Success   - The handle to the mutex object.
;                  Failure   - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: The function succeeds only if some process has already created the mutex by using the _WinAPI_CreateMutex()
;                  function. The calling process can use the returned handle in any function that requires a handle to
;                  a mutex object.
; Related........:
; Link...........: @@MsdnLink@@ OpenMutex
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_OpenMutex($sMutex, $iAccess = 0x00100000, $fInherit = 0)

	Local $Ret = DllCall('kernel32.dll', 'ptr', 'OpenMutexW', 'dword', $iAccess, 'int', $fInherit, 'wstr', $sMutex)

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_OpenMutex

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_OpenProcessToken
; Description....: Opens the access token associated with a process.
; Syntax.........: _WinAPI_OpenProcessToken ( $iAccess [, $hProcess] )
; Parameters.....: $iAccess  - Access mask that specifies the requested types of access to the access token. This parameter can be
;                              one or more of the following values.
;
;                              $TOKEN_ADJUST_DEFAULT
;                              $TOKEN_ADJUST_GROUPS
;                              $TOKEN_ADJUST_PRIVILEGES
;                              $TOKEN_ADJUST_SESSIONID
;                              $TOKEN_ASSIGN_PRIMARY
;                              $TOKEN_DUPLICATE
;                              $TOKEN_EXECUTE
;                              $TOKEN_IMPERSONATE
;                              $TOKEN_QUERY
;                              $TOKEN_QUERY_SOURCE
;                              $TOKEN_READ
;                              $TOKEN_WRITE
;                              $TOKEN_ALL_ACCESS
;
;                  $hProcess - Handle to the process whose access token is opened. The process must have the
;                              $PROCESS_QUERY_INFORMATION access permission. If this parameter is 0, will use the current process.
; Return values..: Success   - Handle that identifies the newly opened access token.
;                  Failure   - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: Close the access token handle returned through this function by calling _WinAPI_CloseHandle().
; Related........:
; Link...........: @@MsdnLink@@ OpenProcessToken
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_OpenProcessToken($iAccess, $hProcess = 0)

	If Not $hProcess Then
		$hProcess = _WinAPI_GetCurrentProcess()
	EndIf

	Local $Ret = DllCall('advapi32.dll', 'int', 'OpenProcessToken', 'ptr', $hProcess, 'dword', $iAccess, 'ptr*', 0)

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[3]
EndFunc   ;==>_WinAPI_OpenProcessToken

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_OpenSemaphore
; Description....: Opens an existing named semaphore object.
; Syntax.........: _WinAPI_OpenSemaphore ( $sSemaphore [, $iAccess [, $fInherit]] )
; Parameters.....: $sSemaphore - The name of the semaphore to be opened. Name comparisons are case sensitive.
;                  $iAccess    - The access to the semaphore object. The function fails if the security descriptor of the specified
;                                object does not permit the requested access for the calling process. This parameter can be one
;                                of the following values.
;
;                                $SEMAPHORE_ALL_ACCESS
;                                $SEMAPHORE_MODIFY_STATE
;
;                  $fInherit   - Specifies whether inherites the handle by a processes, valid values:
;                  |TRUE       - The processes created by this process will inherit the handle.
;                  |FALSE      - The processes do not inherit this handle. (Default)
; Return values..: Success     - The handle to the semaphore object.
;                  Failure     - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: The function succeeds only if some process has already created the semaphore by using the _WinAPI_CreateSemaphore()
;                  function. The calling process can use the returned handle in any function that requires a handle to
;                  a semaphore object.
; Related........:
; Link...........: @@MsdnLink@@ OpenSemaphore
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_OpenSemaphore($sSemaphore, $iAccess = 0x00100000, $fInherit = 0)

	Local $Ret = DllCall('kernel32.dll', 'ptr', 'OpenSemaphoreW', 'dword', $iAccess, 'int', $fInherit, 'wstr', $sSemaphore)

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_OpenSemaphore

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_OpenThemeData
; Description....: Opens the theme data for a window and its associated class.
; Syntax.........: _WinAPI_OpenThemeData ( $hWnd, $sClass )
; Parameters.....: $hWnd   - Handle of the window for which theme data is required.
;                  $sClass - The string that contains a semicolon-separated list of classes. This parameter may contain a list,
;                            not just a single name, to provide the class an opportunity to get the best match between the
;                            class and the current visual style.
; Return values..: Success - The handle to the theme.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ OpenThemeData
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_OpenThemeData($hWnd, $sClass)

	Local $Ret = DllCall('uxtheme.dll', 'ptr', 'OpenThemeData', 'hwnd', $hWnd, 'wstr', $sClass)

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_OpenThemeData

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

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_PaintRgn

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_PatBlt
; Description....: Paints the specified rectangle using the brush that is currently selected into the specified device context.
; Syntax.........: _WinAPI_PatBlt ( $hDC, $iX, $iY, $iWidth, $iHeight, $iRop )
; Parameters.....: $hDC     - Handle to the device context.
;                  $iX      - The x-coordinate, in logical units, of the upper-left corner of the rectangle to be filled.
;                  $iY      - The y-coordinate, in logical units, of the upper-left corner of the rectangle to be filled.
;                  $iWidth  - The width, in logical units, of the rectangle.
;                  $iHeight - The height, in logical units, of the rectangle.
;                  $iRop    - The raster operation code. This code can be one of the following values.
;
;                             $BLACKNESS
;                             $DSTINVERT
;                             $PATCOPY
;                             $PATINVERT
;                             $WHITENESS
;
; Return values..: Success  - 1.
;                  Failure  - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ PatBlt
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_PatBlt($hDC, $iX, $iY, $iWidth, $iHeight, $iRop)

	Local $Ret  = DllCall('gdi32.dll', 'int', 'PatBlt', 'hwnd', $hDC, 'int', $iX, 'int', $iY, 'int', $iWidth, 'int', $iHeight, 'dword', $iRop)

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_PatBlt

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
	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, $sPath)
	EndIf
	$hDC = $Ret[0]
	$Ret = DllCall('user32.dll', 'ptr', 'SendMessage', 'hwnd', $hWnd, 'uint', 0x0031, 'int', 0, 'int', 0)
	$hBack = _WinAPI_SelectObject($hDC, $Ret[0])
	DllStructSetData($tPath, 1, $sPath)
	$Ret = DllCall('shlwapi.dll', 'int', 'PathCompactPathW', 'hwnd', $hDC, 'ptr', DllStructGetPtr($tPath), 'int', $iWidth)
	If (@error) Or (Not $Ret[0]) Then
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
; Name...........: _WinAPI_PathFindExtension
; Description....: Searches a path for an extension.
; Syntax.........: _WinAPI_PathFindExtension ( $sPath )
; Parameters.....: $sPath  - The path to search, including the extension being searched for.
; Return values..: Success - The string that contains the extension.
;                  Failure - Empty string and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ PathFindExtension
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_PathFindExtension($sPath)

	Local $tData = DllStructCreate('wchar[1024]')

	DllStructSetData($tData, 1, $sPath)

	Local $Ret = DllCall('shlwapi.dll', 'int', 'PathFindExtensionW', 'ptr', DllStructGetPtr($tData))

	If @error Then
		Return SetError(1, 0, '')
	EndIf
	Return DllStructGetData(DllStructCreate('wchar[1024]', $Ret[0]), 1)
EndFunc   ;==>_WinAPI_PathFindExtension

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_PathFindFileName
; Description....: Searches a path for a file name.
; Syntax.........: _WinAPI_PathFindFileName ( $sPath )
; Parameters.....: $sPath  - The path to search.
; Return values..: Success - The string that contains the filename.
;                  Failure - Empty string and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ PathFindFileName
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_PathFindFileName($sPath)

	Local $tData = DllStructCreate('wchar[1024]')

	DllStructSetData($tData, 1, $sPath)

	Local $Ret = DllCall('shlwapi.dll', 'int', 'PathFindFileNameW', 'ptr', DllStructGetPtr($tData))

	If @error Then
		Return SetError(1, 0, '')
	EndIf
	Return DllStructGetData(DllStructCreate('wchar[1024]', $Ret[0]), 1)
EndFunc   ;==>_WinAPI_PathFindFileName

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_PathFindNextComponent
; Description....: Parses a path and returns the portion of that path that follows the first backslash.
; Syntax.........: _WinAPI_PathFindNextComponent ( $sPath )
; Parameters.....: $sPath  - The path to parse. Path components are delimited by backslashes. For instance, the path
;                            "c:\path1\path2\file.txt" has four components: c:, path1, path2, and file.txt.
; Return values..: Success - The truncated path.
;                  Failure - Empty string and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: This function walks a path string until it encounters a backslash ("\"), ignores everything up to that point
;                  including the backslash, and returns the rest of the path. Therefore, if a path begins with a backslash (such as \path1\path2),
;                  the function simply removes the initial backslash and returns the rest (path1\path2).
; Related........:
; Link...........: @@MsdnLink@@ PathFindNextComponent
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_PathFindNextComponent($sPath)

	Local $tData = DllStructCreate('wchar[1024]')

	DllStructSetData($tData, 1, $sPath)

	Local $Ret = DllCall('shlwapi.dll', 'int', 'PathFindNextComponentW', 'ptr', DllStructGetPtr($tData))

	If @error Then
		Return SetError(1, 0, '')
	EndIf
	If Not $Ret[0] Then
		Return ''
	EndIf
	Return DllStructGetData(DllStructCreate('wchar[1024]', $Ret[0]), 1)
EndFunc   ;==>_WinAPI_PathFindNextComponent

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

#cs

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
		$tDirs = DllStructCreate($sDirs)
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

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, $sFile)
	EndIf
	Return DllStructGetData($tPath, 1)
EndFunc   ;==>_WinAPI_PathFindOnPath

#ce

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_PathGetArgs
; Description....: Finds the command-line arguments within a given path.
; Syntax.........: _WinAPI_PathGetArgs ( $sPath )
; Parameters.....: $sPath  - The path to be searched.
; Return values..: Success - The string that contains the arguments portion of the path if successful.
;                  Failure - Empty string and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: This function should not be used on generic command path templates (from users or the registry), but rather
;                  should be used only on templates that the application knows to be well formed.
; Related........:
; Link...........: @@MsdnLink@@ PathGetArgs
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_PathGetArgs($sPath)

	Local $tData = DllStructCreate('wchar[1024]')

	DllStructSetData($tData, 1, $sPath)

	Local $Ret = DllCall('shlwapi.dll', 'int', 'PathGetArgsW', 'ptr', DllStructGetPtr($tData))

	If @error Then
		Return SetError(1, 0, '')
	Else
		If Not $Ret[0] Then
			Return ''
		EndIf
	EndIf
	Return DllStructGetData(DllStructCreate('wchar[1024]', $Ret[0]), 1)
EndFunc   ;==>_WinAPI_PathGetArgs

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_PathGetCharType
; Description....: Determines the type of character in relation to a path.
; Syntax.........: _WinAPI_PathGetCharType ( $sChar )
; Parameters.....: $sChar  - The character for which to determine the type.
; Return values..: Success - Returns one or more of the following values that define the type of character.
;
;                            $GCT_INVALID
;                            $GCT_LFNCHAR
;                            $GCT_SEPARATOR
;                            $GCT_SHORTCHAR
;                            $GCT_WILD
;
;                  Failure - (-1) and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ PathGetCharType
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_PathGetCharType($sChar)

	Local $Ret = DllCall('shlwapi.dll', 'int', 'PathGetCharTypeW', 'dword', AscW($sChar))

	If @error Then
		Return SetError(1, 0, -1)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_PathGetCharType

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_PathGetDriveNumber
; Description....: Searches a path for a drive letter within the range of 'A' to 'Z' and returns the corresponding drive number.
; Syntax.........: _WinAPI_PathGetDriveNumber ( $sPath )
; Parameters.....: $sPath  - The path to be searched.
; Return values..: Success - The string that contains the drive letter (A:, B:, etc).
;                  Failure - Empty string and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ PathGetDriveNumber
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_PathGetDriveNumber($sPath)

	Local $Ret = DllCall('shlwapi.dll', 'int', 'PathGetDriveNumberW', 'wstr', $sPath)

	If (@error) Or ($Ret[0] = -1) Then
		Return SetError(1, 0, '')
	EndIf
	Return Chr($Ret[0] + 65) & ':'
EndFunc   ;==>_WinAPI_PathGetDriveNumber

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_PathIsExe
; Description....: Determines whether a file is an executable by examining the file extension.
; Syntax.........: _WinAPI_PathIsExe ( $sPath )
; Parameters.....: $sPath  - The path to be searched.
; Return values..: Success - 1 - The file extension is .cmd, .bat, .pif, .scf, .exe, .com, or .scr.
;                            0 - Otherwise.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ PathIsExe
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_PathIsExe($sPath)

	Local $Ret = DllCall('shell32.dll', 'int', 'PathIsExe', 'wstr', $sPath)

	If @error Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_PathIsExe

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
; Name...........: _WinAPI_PathIsFileSpec
; Description....: Searches a path for any path-delimiting characters.
; Syntax.........: _WinAPI_PathIsFileSpec ( $sPath )
; Parameters.....: $sPath  - The path to be searched.
; Return values..: Success - 1 - There are no path-delimiting characters (":" or "\") within the path.
;                            0 - Otherwise.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ PathIsFileSpec
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_PathIsFileSpec($sPath)

	Local $Ret = DllCall('shlwapi.dll', 'int', 'PathIsFileSpecW', 'wstr', $sPath)

	If @error Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_PathIsFileSpec

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_PathIsRelative
; Description....: Searches a path and determines if it is relative.
; Syntax.........: _WinAPI_PathIsRelative ( $sPath )
; Parameters.....: $sPath  - The path to be searched.
; Return values..: Success - 1 - The path is relative.
;                            0 - Otherwise.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ PathIsRelative
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_PathIsRelative($sPath)

	Local $Ret = DllCall('shlwapi.dll', 'int', 'PathIsRelativeW', 'wstr', $sPath)

	If @error Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_PathIsRelative

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_PathIsSameRoot
; Description....: Compares two paths to determine if they have a common root component.
; Syntax.........: _WinAPI_PathIsSameRoot ( $sPath1, $sPath2 )
; Parameters.....: $sPath1 - The first path to be compared.
;                  $sPath2 - The second path to be compared.
; Return values..: Success - 1 - Both strings have the same root component.
;                            0 - Otherwise.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ PathIsSameRoot
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_PathIsSameRoot($sPath1, $sPath2)

	Local $Ret = DllCall('shlwapi.dll', 'int', 'PathIsSameRootW', 'wstr', $sPath1, 'wstr', $sPath2)

	If @error Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_PathIsSameRoot

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
; Name...........: _WinAPI_PathParseIconLocation
; Description....: Parses a file location string that contains a file location and icon index.
; Syntax.........: _WinAPI_PathParseIconLocation ( $sPath )
; Parameters.....: $sPath  - The path that contains a file location string. It should be in the form "path,iconindex".
; Return values..: Success - The array containing the following parameters:
;
;                            [0] - The path of the file that contains the icon.
;                            [1] - The index of the icon.
;
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: This function is useful for taking a DefaultIcon value from the registry and separating the icon index from the path.
; Related........:
; Link...........: @@MsdnLink@@ PathParseIconLocation
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_PathParseIconLocation($sPath)

	Local $tData = DllStructCreate('wchar[' & (StringLen($sPath) + 1) & ']')

	DllStructSetData($tData, 1, $sPath)

	Local $Ret = DllCall('shlwapi.dll', 'int', 'PathParseIconLocationW', 'ptr', DllStructGetPtr($tData))

	If @error Then
		Return SetError(1, 0, 0)
	EndIf

	Local $Result[2]

	$Result[0] = DllStructGetData($tData, 1)
	$Result[1] = $Ret[0]

	Return $Result
EndFunc   ;==>_WinAPI_PathParseIconLocation

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_PathRelativePathTo
; Description....: Creates a relative path from one file or folder to another.
; Syntax.........: _WinAPI_PathRelativePathTo ( $sPathFrom, $fDirFrom, $sPathTo, $fDirTo )
; Parameters.....: $sPathFrom - The path to the file or directory that defines the start of the relative path.
;                  $fDirFrom  - Specifies whether is $sPathFrom path to the directory, valid values:
;                  |TRUE      - Directory.
;                  |FALSE     - File.
;                  $sPathTo   - The path to the file or directory that defines the endpoint of the relative path.
;                  $fDirTo    - Specifies whether is $fDirTo path to the directory, valid values:
;                  |TRUE      - Directory.
;                  |FALSE     - File.
; Return values..: Success    - The relative path.
;                  Failure    - Empty string and sets the @error flag to non-zero.
; Author.........: Mat
; Modified.......: Yashied
; Remarks........: This function takes a pair of paths and generates a relative path from one to the other. The paths do not have
;                  to be fully-qualified, but they must have a common prefix, otherwise, the function fails.
;
;                  For example, let the starting point, $sPathFrom, be "C:\A\B\C", and the ending point, $sPathTo, be "C:\A\D".
;                  _WinAPI_PathRelativePathTo() will return the relative path from $sPathFrom to $sPathTo as: "..\..\D\E". You will
;                  get the same result if you set $sPathFrom to "\A\B\C" and $sPathTo to "\A\D\E". On the other hand, "C:\A\B\C"
;                  and "D:\A\D" do not share a common prefix, and the function will fail. Note that "\" is not considered a prefix
;                  and is ignored. If you set $sPathFrom to "\\A\B\C", and $sPathTo to "\\C\D", the function will fail.
; Related........:
; Link...........: @@MsdnLink@@ PathRelativePathTo
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_PathRelativePathTo($sPathFrom, $fDirFrom, $sPathTo, $fDirTo)

	If $fDirFrom Then
		$fDirFrom = 0x10
	EndIf
	If $fDirTo Then
		$fDirTo = 0x10
	EndIf

	Local $tData = DllStructCreate('wchar[1024]')
	Local $Ret = DllCall('shlwapi.dll', 'int', 'PathRelativePathToW', 'ptr', DllStructGetPtr($tData), 'wstr', $sPathFrom, 'dword', $fDirFrom, 'wstr', $sPathTo, 'dword', $fDirTo)

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, '')
	EndIf
	Return DllStructGetData($tData, 1)
EndFunc   ;==>_WinAPI_PathRelativePathTo

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_PathRemoveArgs
; Description....: Removes any arguments from a given path.
; Syntax.........: _WinAPI_PathRemoveArgs ( $sPath )
; Parameters.....: $sPath  - The path that contains the path from which to remove arguments.
; Return values..: Success - The path of no arguments.
;                  Failure - Empty string and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: This function should not be used on generic command path templates (from users or the registry), but rather
;                  it should be used only on templates that the application knows to be well formed.
; Related........:
; Link...........: @@MsdnLink@@ PathRemoveArgs
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_PathRemoveArgs($sPath)

	Local $tData = DllStructCreate('wchar[' & (StringLen($sPath) + 1) & ']')

	DllStructSetData($tData, 1, $sPath)

	Local $Ret = DllCall('shlwapi.dll', 'none', 'PathRemoveArgsW', 'ptr', DllStructGetPtr($tData))

	If @error Then
		Return SetError(1, 0, '')
	EndIf
	Return DllStructGetData($tData, 1)
EndFunc   ;==>_WinAPI_PathRemoveArgs

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_PathRenameExtension
; Description....: Replaces the extension of a file name with a new extension.
; Syntax.........: _WinAPI_PathRenameExtension ( $sPath, $sExt )
; Parameters.....: $sPath  - The path in which to replace the extension.
;                  $sExt   - The string that contains a "." character followed by the new extension.
; Return values..: Success - The path with new extension.
;                  Failure - Empty string and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: If the file name does not contain an extension, the extension will be attached to the end of the string.
; Related........:
; Link...........: @@MsdnLink@@ PathRenameExtension
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_PathRenameExtension($sPath, $sExt)

	Local $tData = DllStructCreate('wchar[' & (StringLen($sPath) + 1) & ']')

	DllStructSetData($tData, 1, $sPath)

	Local $Ret = DllCall('shlwapi.dll', 'int', 'PathRenameExtensionW', 'ptr', DllStructGetPtr($tData), 'wstr', $sExt)

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, '')
	EndIf
	Return DllStructGetData($tData, 1)
EndFunc   ;==>_WinAPI_PathRenameExtension

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_PathSearchAndQualify
; Description....: Formats a path to the fully qualified path.
; Syntax.........: _WinAPI_PathSearchAndQualify ( $sPath [, $fExists] )
; Parameters.....: $sPath   - The path to be formated.
;                  $fExists - Specifies whether a path exists, valid values:
;                  |TRUE    - The path must be an existing path, otherwise, the function fails.
;                  |FALSE   - The path may not exist. (Default)
; Return values..: Success  - The formated path.
;                  Failure  - Empty string and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ PathSearchAndQualify
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_PathSearchAndQualify($sPath, $fExists = 0)

	Local $tPath = DllStructCreate('wchar[1024]')
	Local $Ret = DllCall('shlwapi.dll', 'int', 'PathSearchAndQualifyW', 'wstr', $sPath, 'ptr', DllStructGetPtr($tPath), 'int', 1024)

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, $sPath)
	EndIf
	$sPath = DllStructGetData($tPath, 1)
	If ($fExists) And (Not FileExists($sPath)) Then
		Return SetError(1, 0, '')
	EndIf
	Return $sPath
EndFunc   ;==>_WinAPI_PathSearchAndQualify

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_PathToRegion
; Description....: Creates a region from the path that is selected into the specified device context.
; Syntax.........: _WinAPI_PathToRegion ( $hDC )
; Parameters.....: $hDC    - Handle to a device context that contains a closed path.
; Return values..: Success - The handle to the region.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: The device context identified by the $hDC parameter must contain a closed path.
;
;                  After _WinAPI_PathToRegion() converts a path into a region, the system discards the closed path from the specified
;                  device context.
; Related........:
; Link...........: @@MsdnLink@@ PathToRegion
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_PathToRegion($hDC)

	Local $Ret = DllCall('gdi32.dll', 'ptr', 'PathToRegion', 'hwnd', $hDC)

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_PathToRegion

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_PathUnExpandEnvStrings
; Description....: Replaces folder names in a fully-qualified path with their associated environment string.
; Syntax.........: _WinAPI_PathUnExpandEnvStrings ( $sPath )
; Parameters.....: $sPath  - The path to be unexpanded.
; Return values..: Success - The unexpanded string.
;                  Failure - Empty string and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ PathUnExpandEnvStrings
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_PathUnExpandEnvStrings($sPath)

	Local $tData = DllStructCreate('wchar[1024]')
	Local $Ret = DllCall('shlwapi.dll', 'int', 'PathUnExpandEnvStringsW', 'wstr', $sPath, 'ptr', DllStructGetPtr($tData), 'uint', 1024)

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, '')
	EndIf
	Return DllStructGetData($tData, 1)
EndFunc   ;==>_WinAPI_PathUnExpandEnvStrings

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_PathUnquoteSpaces
; Description....: Removes quotes from the beginning and end of a path.
; Syntax.........: _WinAPI_PathUnquoteSpaces ( $sPath )
; Parameters.....: $sPath  - The path.
; Return values..: Success - The path with beginning and ending quotation marks removed.
;                  Failure - Empty string and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ PathUnquoteSpaces
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_PathUnquoteSpaces($sPath)

	Local $tData = DllStructCreate('wchar[' & (StringLen($sPath) + 1) & ']')

	DllStructSetData($tData, 1, $sPath)

	Local $Ret = DllCall('shlwapi.dll', 'none', 'PathUnquoteSpacesW', 'ptr', DllStructGetPtr($tData))

	If @error Then
		Return SetError(1, 0, 0)
	EndIf
	Return DllStructGetData($tData, 1)
EndFunc   ;==>_WinAPI_PathUnquoteSpaces

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

	If (@error) Or (Not $Ret[0]) Then
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
;
;                             [0] - The path of the file that contains the selected icon.
;                             [1] - The index of the selected icon.
;
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
	If (Not @error) And ($Ret[0]) Then
		$Ret = DllCall('kernel32.dll', 'int', 'ExpandEnvironmentStringsW', 'wstr', DllStructGetData($tIcon, 1), 'ptr', DllStructGetPtr($tIcon), 'int', 1024)
		If (Not @error) And ($Ret[0]) Then
			$Result[0] = DllStructGetData($tIcon, 1)
			$Result[1] = DllStructGetData($tIndex, 1)
			$Error = 0
		EndIf
	EndIf
	Return SetError($Error, 0, $Result)
EndFunc   ;==>_WinAPI_PickIconDlg

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_PlayEnhMetaFile
; Description....: Displays the picture stored in the specified enhanced-format metafile.
; Syntax.........: _WinAPI_PlayEnhMetaFile( $hDC, $hEmf, $tRECT )
; Parameters.....: $hDC    - Handle to the device context for the output device on which the picture will appear.
;                  $hEmf   - Handle to the enhanced metafile.
;                  $tRECT  - $tagRECT structure that contains the coordinates of the bounding rectangle used to display the picture,
;                            in logical units
; Return values..: Success - 1.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: An enhanced metafile can be embedded in a newly created enhanced metafile by calling _WinAPI_PlayEnhMetaFile()
;                  and playing the source enhanced metafile into the device context for the new enhanced metafile.
; Related........:
; Link...........: @@MsdnLink@@ PlayEnhMetaFile
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_PlayEnhMetaFile($hDC, $hEmf, $tRECT)

	Local $Ret = DllCall('gdi32.dll', 'int', 'PlayEnhMetaFile', 'hwnd', $hDC, 'ptr', $hEmf, 'ptr', DllStructGetPtr($tRECT))

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_PlayEnhMetaFile

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_PlaySound
; Description....: Plays a sound specified by the given file name, resource, or system event.
; Syntax.........: _WinAPI_PlaySound ( $sSound [, $iFlags [, $hInstance]] )
; Parameters.....: $sSound    - The string that specifies the sound to play. The maximum length is 255 characters. If $sSound is
;                               empty, any currently playing waveform sound is stopped.
;                  $iFlags    - The flags for sound playing. This parameter can be one or more of the following values.
;
;                               $SND_APPLICATION
;                               $SND_ALIAS
;                               $SND_ALIAS_ID
;                               $SND_ASYNC
;                               $SND_FILENAME
;                               $SND_LOOP
;                               $SND_MEMORY
;                               $SND_NODEFAULT
;                               $SND_NOSTOP
;                               $SND_NOWAIT
;                               $SND_PURGE
;                               $SND_RESOURCE
;                               $SND_SYNC
;
;                               Three flags ($SND_ALIAS, $SND_FILENAME, and $SND_RESOURCE) determine whether the name is interpreted
;                               as an alias for a system event, a file name, or a resource identifier. If none of these flags are
;                               specified, _WinAPI_PlaySound() searches the registry or the WIN.INI file for an association with
;                               the specified sound name. If an association is found, the sound event is played. If no association
;                               is found in the registry, the name is interpreted as a file name.
;
;                               If the $SND_ALIAS_ID flag is specified in $iFlags, the $sSound parameter must be one of the
;                               $SND_ALIAS_* values.
;
;                               (See MSDN for more information)
;
;                  $hInstance - Handle to the executable file that contains the resource to be loaded. If $iFlags does not
;                               contain the $SND_RESOURCE, this parameter will be ignored.
; Return values..: Success    - 1.
;                  Failure    - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ PlaySound
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_PlaySound($sSound, $iFlags = 0x00020010, $hInstance = 0)

	Local $TypeOfSound = 'ptr'

	If $sSound Then
		If IsString($sSound) Then
			$TypeOfSound = 'wstr'
		EndIf
	Else
		$sSound = 0
		$iFlags = 0
	EndIf

	Local $Ret = DllCall('winmm.dll', 'int', 'PlaySoundW', $TypeOfSound, $sSound, 'ptr', $hInstance, 'dword', $iFlags)

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_PlaySound

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_PolyBezier
; Description....: Draws one or more Bezier curves.
; Syntax.........: _WinAPI_PolyBezier ( $hDC, $aPoint [, $iStart [, $iEnd]] )
; Parameters.....: $hDC    - Handle to a device context.
;                  $aPoint - The 2D array ([x1, y1], [x2, y2], ... [xN, yN]) that contains the endpoints and control points of the
;                            curve(s), in logical units. The number of points must be one more than three times the number of curves
;                            to be drawn, because each Bezier curve requires two control points and an endpoint, and the initial
;                            curve requires an additional starting point.
;                  $iStart - The index of array to start drawing at.
;                  $iEnd   - The index of array to stop drawing at.
; Return values..: Success - 1.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: This function draws cubic Bezier curves by using the endpoints and control points specified by the $aPoint
;                  parameter. The first curve is drawn from the first point to the fourth point by using the second and third points
;                  as control points. Each subsequent curve in the sequence needs exactly three more points: the ending point of the
;                  previous curve is used as the starting point, the next two points in the sequence are control points, and the
;                  third is the ending point.
;
;                  The current position is neither used nor updated by the _WinAPI_PolyBezier() function. The figure is not filled.
;
;                  This function draws lines by using the current pen.
; Related........:
; Link...........: @@MsdnLink@@ PolyBezier
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_PolyBezier($hDC, $aPoint, $iStart = 0, $iEnd = -1)

	If UBound($aPoint, 2) < 2  Then
		Return SetError(2, 0, 0)
	EndIf

	Local $Point, $tPoint, $Count = 0, $Struct = ''

	If $iStart < 0 Then
		$iStart = 0
	EndIf
	If ($iEnd < 0) Or ($iEnd > UBound($aPoint) - 1) Then
		$iEnd = UBound($aPoint) - 1
	EndIf
	$Point = 1 + 3 * Floor(($iEnd - $iStart) / 3)
	If $Point < 1 Then
		Return SetError(1, 0, 0)
	EndIf
	$iEnd = $iStart + $Point - 1
	For $i = $iStart To $iEnd
		$Struct &= 'long[2];'
	Next
	$tPoint = DllStructCreate($Struct)
	If @error Then
		Return SetError(1, 0, 0)
	EndIf
	For $i = $iStart To $iEnd
		$Count += 1
		For $j = 0 To 1
			DllStructSetData($tPoint, $Count, $aPoint[$i][$j], $j + 1)
		Next
	Next

	Local $Ret = DllCall('gdi32.dll', 'int', 'PolyBezier', 'hwnd', $hDC, 'ptr', DllStructGetPtr($tPoint), 'dword', $Point)

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_PolyBezier

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_PolyBezierTo
; Description....: Draws one or more Bezier curves.
; Syntax.........: _WinAPI_PolyBezierTo ( $hDC, $aPoint [, $iStart [, $iEnd]] )
; Parameters.....: $hDC    - Handle to a device context.
;                  $aPoint - The 2D array ([x1, y1], [x2, y2], ... [xN, yN]) that contains the endpoints and control points of the
;                            curve(s), in logical units. The number of points must be three times the number of curves to be drawn,
;                            because each Bezier curve requires two control points and an ending point.
;                  $iStart - The index of array to start drawing at.
;                  $iEnd   - The index of array to stop drawing at.
; Return values..: Success - 1.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: This function draws cubic Bezier curves by using the control points specified by the $aPoint parameter.
;                  The first curve is drawn from the current position to the third point by using the first two points as control points.
;                  For each subsequent curve, the function needs exactly three more points, and uses the ending point of the previous
;                  curve as the starting point for the next.
;
;                  The current position moves to the ending point of the last Bezier curve. The figure is not filled.
;
;                  This function draws lines by using the current pen.
; Related........:
; Link...........: @@MsdnLink@@ PolyBezierTo
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_PolyBezierTo($hDC, $aPoint, $iStart = 0, $iEnd = -1)

	If UBound($aPoint, 2) < 2  Then
		Return SetError(2, 0, 0)
	EndIf

	Local $Point, $tPoint, $Count = 0, $Struct = ''

	If $iStart < 0 Then
		$iStart = 0
	EndIf
	If ($iEnd < 0) Or ($iEnd > UBound($aPoint) - 1) Then
		$iEnd = UBound($aPoint) - 1
	EndIf
	$Point = 3 * Floor(($iEnd - $iStart + 1) / 3)
	If $Point < 3 Then
		Return SetError(1, 0, 0)
	EndIf
	$iEnd = $iStart + $Point - 1
	For $i = $iStart To $iEnd
		$Struct &= 'long[2];'
	Next
	$tPoint = DllStructCreate($Struct)
	If @error Then
		Return SetError(1, 0, 0)
	EndIf
	For $i = $iStart To $iEnd
		$Count += 1
		For $j = 0 To 1
			DllStructSetData($tPoint, $Count, $aPoint[$i][$j], $j + 1)
		Next
	Next

	Local $Ret = DllCall('gdi32.dll', 'int', 'PolyBezierTo', 'hwnd', $hDC, 'ptr', DllStructGetPtr($tPoint), 'dword', $Point)

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_PolyBezierTo

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_PolyDraw
; Description....: Draws a set of line segments and Bezier curves.
; Syntax.........: _WinAPI_PolyDraw ( $hDC, $aPoint [, $iStart [, $iEnd]] )
; Parameters.....: $hDC    - Handle to a device context.
;                  $aPoint - The 2D array ([x1, y1, type1], [x2, y2, type2], ... [xN, yN, typeN]) that contains the endpoints for
;                            each line segment and the endpoints and control points for each Bezier curve, in logical units. In addition,
;                            the array contains a parameters that specifies how each point is used. The third parameter of the array
;                            can be one of the following values.
;
;                            $PT_BEZIERTO
;                            $PT_LINETO
;                            $PT_MOVETO
;
;                            $PT_BEZIERTO or $PT_LINETO type can be combined with the following value that the corresponding point
;                            is the last point in a figure and the figure is closed.
;
;                            $PT_CLOSEFIGURE
;
;                  $iStart - The index of array to start drawing at.
;                  $iEnd   - The index of array to stop drawing at.
; Return values..: Success - 1.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: This function can be used in place of consecutive calls to _WinAPI_MoveToEx(), _WinAPI_LineTo(), and _WinAPI_PolyBezierTo()
;                  functions to draw disjoint figures. The lines and curves are drawn using the current pen and figures are not filled.
;                  If there is an active path started by calling _WinAPI_BeginPath(), _WinAPI_PolyDraw() adds to the path.
;
;                  This function updates the current position.
; Related........:
; Link...........: @@MsdnLink@@ PolyDraw
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_PolyDraw($hDC, $aPoint, $iStart = 0, $iEnd = -1)

	If UBound($aPoint, 2) < 3  Then
		Return SetError(2, 0, 0)
	EndIf

	Local $Point, $tPoint, $tTypes, $Count = 0, $Struct = ''

	If $iStart < 0 Then
		$iStart = 0
	EndIf
	If ($iEnd < 0) Or ($iEnd > UBound($aPoint) - 1) Then
		$iEnd = UBound($aPoint) - 1
	EndIf
	$Point = $iEnd - $iStart + 1
	If Not $Point Then
		Return SetError(1, 0, 0)
	EndIf
	For $i = $iStart To $iEnd
		$Struct &= 'long[2];'
	Next
	$tPoint = DllStructCreate($Struct)
	If @error Then
		Return SetError(1, 0, 0)
	EndIf
	$tTypes = DllStructCreate('byte[' & $Point & ']')
	If @error Then
		Return SetError(1, 0, 0)
	EndIf
	For $i = $iStart To $iEnd
		$Count += 1
		For $j = 0 To 1
			DllStructSetData($tPoint, $Count, $aPoint[$i][$j], $j + 1)
		Next
		DllStructSetData($tTypes, 1, $aPoint[$i][2], $Count)
	Next

	Local $Ret = DllCall('gdi32.dll', 'int', 'PolyDraw', 'hwnd', $hDC, 'ptr', DllStructGetPtr($tPoint), 'ptr', DllStructGetPtr($tTypes), 'dword', $Point)

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_PolyDraw

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
	$tData = DllStructCreate($Struct)
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

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_Polygon

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_PrintWindow
; Description....: Copies a visual window into the specified device context.
; Syntax.........: _WinAPI_PrintWindow ( $hWnd, $hDC [, $fClient] )
; Parameters.....: $hWnd    - Handle to the window that will be copied.
;                  $hDC     - Handle to the device context.
;                  $fClient - Specifies whether copies only the client area of the window, valid values:
;                  |TRUE    - Only the client area of the window is copied to device context.
;                  |FALSE   - The entire window is copied. (Default)
; Return values..: Success  - 1.
;                  Failure  - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ PrintWindow
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_PrintWindow($hWnd, $hDC, $fClient = 0)

	Local $Ret = DllCall('user32.dll', 'int', 'PrintWindow', 'hwnd', $hWnd, 'hwnd', $hDC, 'uint', $fClient)

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_PrintWindow

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

	Local $tRECT = _WinAPI_CreateRect($iLeft, $iTop, $iRight, $iBottom)
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
; Name...........: _WinAPI_PtVisible
; Description....: Determines whether the specified point is within the clipping region.
; Syntax.........: _WinAPI_PtVisible ( $hDC, $iX, $iY )
; Parameters.....: $hDC    - Handle to the device context.
;                  $iX     - The x-coordinate, in logical units, of the point.
;                  $iY     - The y-coordinate, in logical units, of the point.
; Return values..: Success - 1 - The specified point is within the clipping region.
;                            0 - Otherwise.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ PtVisible
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_PtVisible($hDC, $iX, $iY)

	Local $Ret = DllCall('gdi32.dll', 'int', 'PtVisible', 'hwnd', $hDC, 'int', $iX, 'int', $iY)

	If @error Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_PtVisible

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_QueryDosDevice
; Description....: Retrieves the current mapping for a particular MS-DOS device name.
; Syntax.........: _WinAPI_QueryDosDevice ( $sDevice )
; Parameters.....: $sDevice - The name of the MS-DOS device.
; Return values..: Success  - The current mapping for the specified device. If the $sDevice parameter is empty string, return array
;                             of all existing MS-DOS device names (for example, "\Device\HarddiskVolume1" or "\Device\Floppy0").
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

	If Not StringStripWS($sDevice, 3) Then
		$TypeOfDevice = 'ptr'
		$sDevice = 0
	EndIf

	Local $tData = DllStructCreate('wchar[' & (32 * 1024 / 2) & ']'), $pData = DllStructGetPtr($tData)
	Local $Ret = DllCall('kernel32.dll', 'dword', 'QueryDosDeviceW', $TypeOfDevice, $sDevice, 'ptr', $pData, 'dword', 16384)

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, '')
	EndIf

	Local $Result = _WinAPI_StructToArray($pData)

	If IsString($sDevice) Then
		$Result = $Result[1]
	EndIf
	Return $Result
EndFunc   ;==>_WinAPI_QueryDosDevice

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_QueryInformationJobObject
; Description....: Retrieves limit and job state information from the job object.
; Syntax.........: _WinAPI_QueryInformationJobObject ( $hJob, $iJobObjectInfoClass, ByRef $tJobObjectInfo )
; Parameters.....: $hJob                - Handle to the job whose information is being queried. The handle must have the
;                                         $JOB_OBJECT_QUERY access right. If this value is 0 and the calling process is associated
;                                         with a job, the job associated with the calling process is used.
;                  $iJobObjectInfoClass - The information class for the limits to be queried. This parameter specifies the type
;                                         of $tJobObjectInfo structure, valid values:
;                  |1  - $tagJOBOBJECT_BASIC_ACCOUNTING_INFORMATION
;                  |2  - $tagJOBOBJECT_BASIC_LIMIT_INFORMATION
;                  |3  - $tagJOBOBJECT_BASIC_PROCESS_ID_LIST
;                  |4  - $tagJOBOBJECT_BASIC_UI_RESTRICTIONS
;                  |5  - $tagJOBOBJECT_SECURITY_LIMIT_INFORMATION
;                  |8  - $tagJOBOBJECT_BASIC_AND_IO_ACCOUNTING_INFORMATION
;                  |9  - $tagJOBOBJECT_EXTENDED_LIMIT_INFORMATION
;                  |11 - $tagJOBOBJECT_GROUP_INFORMATION
;                  $tJobObjectInfo      - $tagJOBOBJECT_* structure that retrieves the limit and job state information.
; Return values..: Success              - The length of data (in bytes) written to the structure pointed to by the
;                                         $tJobObjectInfo parameter.
;                  Failure              - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ QueryInformationJobObject
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_QueryInformationJobObject($hJob, $iJobObjectInfoClass, ByRef $tJobObjectInfo)

	Local $Ret = DllCall('kernel32.dll', 'int', 'QueryInformationJobObject', 'ptr', $hJob, 'int', $iJobObjectInfoClass, 'ptr', DllStructGetPtr($tJobObjectInfo), 'dword', DllStructGetSize($tJobObjectInfo), 'dword*', 0)

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[5]
EndFunc   ;==>_WinAPI_QueryInformationJobObject

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_QueryPerformanceCounter
; Description....: Retrieves the current value of the high-resolution performance counter.
; Syntax.........: _WinAPI_QueryPerformanceCounter ( )
; Parameters.....: None
; Return values..: Success - The current performance-counter value, in counts.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ QueryPerformanceCounter
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_QueryPerformanceCounter()

	Local $Ret = DllCall('kernel32.dll', 'int', 'QueryPerformanceCounter', 'int64*', 0)

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[1]
EndFunc   ;==>_WinAPI_QueryPerformanceCounter

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_QueryPerformanceFrequency
; Description....: Retrieves the frequency of the high-resolution performance counter.
; Syntax.........: _WinAPI_QueryPerformanceFrequency ( )
; Parameters.....: None
; Return values..: Success - The current performance-counter frequency, in counts per second.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ QueryPerformanceFrequency
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_QueryPerformanceFrequency()

	Local $Ret = DllCall('kernel32.dll', 'int', 'QueryPerformanceFrequency', 'int64*', 0)

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[1]
EndFunc   ;==>_WinAPI_QueryPerformanceFrequency

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_RadialGradientFill
; Description....: Fills radial gradient.
; Syntax.........: _WinAPI_RadialGradientFill($hDC, $iX, $iY, $iRadius, $iRGB1, $iRGB2 [, $iAngleStart [, $iAngleEnd [, $iStep]]] )
; Parameters.....: $hDC         - Handle to the device context.
;                  $iX          - The x-coordinate of the central point, in logical units.
;                  $iY          - The y-coordinate of the central point, in logical units.
;                  $iRadius     - The circle radius to filling the gradient.
;                  $iRGB1       - The color information at the central point.
;                  $iRGB2       - The color information at the edges of circle.
;                  $iAngleStart - The angle to start filling at, in degree.
;                  $iAngleEnd   - The angle to end filling at, in degree.
;                  $iStep       - The gradient filling step in degree. The larger value of this parameter, the gradient will be
;                                 better, but it's require more time, and vice versa.
; Return values..: Success  - 1.
;                  Failure  - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: This function does not fills gradient with transparency, and does not use antialiasing.
; Related........:
; Link...........: None
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_RadialGradientFill($hDC, $iX, $iY, $iRadius, $iRGB1, $iRGB2, $iAngleStart = 0, $iAngleEnd = 360, $iStep = 5)

	Local $Val

	If Abs($iAngleStart) > 360 Then
		$iAngleStart = Mod($iAngleStart, 360)
	EndIf
	If Abs($iAngleEnd) > 360 Then
		$iAngleEnd = Mod($iAngleEnd, 360)
	EndIf
	If ($iAngleStart < 0) Or ($iAngleEnd < 0) Then
		$iAngleStart += 360
		$iAngleEnd += 360
	EndIf
	If $iAngleStart > $iAngleEnd Then
		$Val = $iAngleStart
		$iAngleStart = $iAngleEnd
		$iAngleEnd = $Val
	EndIf
	If $iStep < 1 Then
		$iStep = 1
	EndIf

	Local $Ki = ATan(1) / 45
	Local $Xp = Round($iX + $iRadius * Cos($Ki * $iAngleStart))
	Local $Yp = Round($iY + $iRadius * Sin($Ki * $iAngleStart))
	Local $Xn, $Yn, $An = $iAngleStart
	Local $Vertex[3][3]

	While $An < $iAngleEnd
		$An += $iStep
		If $An > $iAngleEnd Then
			$An = $iAngleEnd
		EndIf
		$Xn = Round($iX + $iRadius * Cos($Ki * $An))
		$Yn = Round($iY + $iRadius * Sin($Ki * $An))
		$Vertex[0][0] = $iX
		$Vertex[0][1] = $iY
		$Vertex[0][2] = $iRGB1
		$Vertex[1][0] = $Xp
		$Vertex[1][1] = $Yp
		$Vertex[1][2] = $iRGB2
		$Vertex[2][0] = $Xn
		$Vertex[2][1] = $Yn
		$Vertex[2][2] = $iRGB2
		If Not _WinAPI_GradientFill($hDC, $Vertex, 0, 2) Then
			Return SetError(1, 0, 0)
		EndIf
		$Xp = $Xn
		$Yp = $Yn
	WEnd
	Return 1
EndFunc   ;==>_WinAPI_RadialGradientFill

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

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_Rectangle

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_RectInRegion
; Description....: Determines whether any part of the specified rectangle is within the boundaries of a region.
; Syntax.........: _WinAPI_RectInRegion ( $hRgn, $tRECT )
; Parameters.....: $hRgn   - Handle to the region.
;                  $tRECT  - $tagRECT structure that contains the coordinates of the rectangle in logical units.
; Return values..: Success - 1 - Any part of the specified rectangle lies within the boundaries of the region
;                            0 - Otherwise.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ RectInRegion
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_RectInRegion($hRgn, $tRECT)

	Local $Ret = DllCall('gdi32.dll', 'int', 'RectInRegion', 'ptr', $hRgn, 'ptr', DllStructGetPtr($tRECT))

	If @error Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_RectInRegion

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_RectVisible
; Description....: Determines whether any part of the specified rectangle lies within the clipping region.
; Syntax.........: _WinAPI_RectVisible ( $hDC, $tRECT )
; Parameters.....: $hDC    - Handle to the device context.
;                  $tRECT  - $tagRECT structure that contains the logical coordinates of the specified rectangle.
; Return values..: Success - 1, 2 - The rectangle lies within the clipping region.
;                            0    - Otherwise.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ RectVisible
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_RectVisible($hDC, $tRECT)

	Local $Ret = DllCall('gdi32.dll', 'int', 'RectVisible', 'hwnd', $hDC, 'ptr', DllStructGetPtr($tRECT))

	If @error Then
		Return SetError(1, 0, 0)
	Else
		Switch $Ret[0]
			Case 0, 1, 2

			Case Else
				Return SetError(1, $Ret[0], 0)
		EndSwitch
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_RectVisible

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_RegCloseKey
; Description....: Closes a handle to the specified registry key.
; Syntax.........: _WinAPI_RegCloseKey ( $hKey [, $fFlush] )
; Parameters.....: $hKey   - Handle to the open key to be closed. The handle must have been opened by the _WinAPI_RegCreateKey()
;                            or _WinAPI_RegOpenKey() function.
;                  $fFlush - Specifies whether writes all the attributes of the specified registry key into the registry,
;                            valid values:
;                  |TRUE   - Write changes to disk before close the handle.
;                  |FALSE  - Don`t write. (Default)
; Return values..: Success - 1.
;                  Failure - 0 and sets the @error flag to non-zero, @extended flag may contain the system error code.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ RegCloseKey
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_RegCloseKey($hKey, $fFlush = 0)

	If $fFlush Then
		If Not _WinAPI_RegFlushKey($hKey) Then
			Return SetError(1, @extended, 0)
		EndIf
	EndIf

	Local $Ret = DllCall('advapi32.dll', 'long', 'RegCloseKey', 'ulong_ptr', $hKey)

	If @error Then
		Return SetError(1, 0, 0)
	Else
		If $Ret[0] Then
			Return SetError(1, $Ret[0], 0)
		EndIf
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_RegCloseKey

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_RegConnectRegistry
; Description....: Establishes a connection to a predefined registry key on another computer.
; Syntax.........: _WinAPI_RegConnectRegistry ( $sComputer, $hKey )
; Parameters.....: $sComputer - The name of the remote computer. The string has the form as "\\computername". The caller must
;                               have access to the remote computer or the function fails. If this parameter is 0, the local
;                               computer name is used.
;                  $hKey      - The predefined registry handle. This parameter can be one of the following predefined keys
;                               on the remote computer.
;
;                               $HKEY_LOCAL_MACHINE
;                               $HKEY_PERFORMANCE_DATA
;                               $HKEY_USERS
;
; Return values..: Success    - Handle to the key on the remote computer.
;                  Failure    - 0 and sets the @error flag to non-zero, @extended flag may contain the system error code.
; Author.........: Yashied
; Modified.......:
; Remarks........: This function requires the Remote Registry service to be running on the remote computer.
;
;                  If the current user does not have proper access to the remote computer, the call to _WinAPI_RegConnectRegistry()
;                  fails. If the computer is joined to a workgroup and the "Force network logons using local accounts to authenticate
;                  as Guest" policy is enabled, the function fails. Note that this policy is enabled by default if the computer is
;                  joined to a workgroup.
;
;                  When a handle returned by _WinAPI_RegConnectRegistry() is no longer needed, it should be closed by
;                  calling _WinAPI_RegCloseKey().
; Related........:
; Link...........: @@MsdnLink@@ RegConnectRegistry
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_RegConnectRegistry($sComputer, $hKey)

	Local $Ret = DllCall('advapi32.dll', 'long', 'RegConnectRegistryW', 'wstr', $sComputer, 'ulong_ptr', $hKey, 'ulong_ptr*', 0)

	If @error Then
		Return SetError(1, 0, 0)
	Else
		If $Ret[0] Then
			Return SetError(1, $Ret[0], 0)
		EndIf
	EndIf
	Return $Ret[3]
EndFunc   ;==>_WinAPI_RegConnectRegistry

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_RegCopyTree
; Description....: Recursively copies the subkeys and values of the source subkey to the destination key.
; Syntax.........: _WinAPI_RegCopyTree ( $hSrcKey, $sSrcSubKey, $hDestKey )
; Parameters.....: $hSrcKey    - Handle to the source key or one of the predefined registry keys ($HKEY_*).
;                  $sSrcSubKey - The subkey whose subkeys and values are to be copied.
;                  $hDestKey   - Handle to the destination key.
; Return values..: Success     - 1.
;                  Failure     - 0 and sets the @error flag to non-zero, @extended flag may contain the system error code.
; Author.........: Yashied
; Modified.......:
; Remarks........: This function does not duplicate the security attributes of the keys and values that it copies. Rather,
;                  all security attributes in the destination key are the default attributes.
; Related........:
; Link...........: @@MsdnLink@@ SHCopyKey
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_RegCopyTree($hSrcKey, $sSrcSubKey, $hDestKey)

	Local $Ret = DllCall('shlwapi.dll', 'long', 'SHCopyKeyW', 'ulong_ptr', $hSrcKey, 'wstr', $sSrcSubKey, 'ulong_ptr', $hDestKey, 'dword', 0)

	If @error Then
		Return SetError(1, 0, 0)
	Else
		If $Ret[0] Then
			Return SetError(1, $Ret[0], 0)
		EndIf
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_RegCopyTree

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_RegCopyTreeEx
; Description....: Copies the specified registry key, along with its values and subkeys, to the specified destination key.
; Syntax.........: _WinAPI_RegCopyTreeEx ( $hSrcKey, $sSrcSubKey, $hDestKey )
; Parameters.....: $hSrcKey    - Handle to an open registry key. The key must have been opened with the $KEY_READ access right.
;                                This handle is returned by the _WinAPI_RegCreateKey() or _WinAPI_RegOpenKey() function, or it can be
;                                one of the predefined registry keys ($HKEY_*).
;                  $sSrcSubKey - The name of the key. This key must be a subkey of the key identified by the $hSrcKey parameter.
;                  $hDestKey   - Handle to the destination key. The calling process must have $KEY_CREATE_SUB_KEY access to the key.
;                                This handle is returned by the _WinAPI_RegCreateKey() or _WinAPI_RegOpenKey() function, or it can be
;                                one of the predefined registry keys ($HKEY_*).
; Return values..: Success     - 1.
;                  Failure     - 0 and sets the @error flag to non-zero, @extended flag may contain the system error code.
; Author.........: Yashied
; Modified.......:
; Remarks........: This function also copies the security descriptor for the key.
;
;                  This function requires Windows Vista or later.
; Related........:
; Link...........: @@MsdnLink@@ RegCopyTree
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_RegCopyTreeEx($hSrcKey, $sSrcSubKey, $hDestKey)

	Local $Ret = DllCall('advapi32.dll', 'long', 'RegCopyTreeW', 'ulong_ptr', $hSrcKey, 'wstr', $sSrcSubKey, 'ulong_ptr', $hDestKey)

	If @error Then
		Return SetError(1, 0, 0)
	Else
		If $Ret[0] Then
			Return SetError(1, $Ret[0], 0)
		EndIf
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_RegCopyTreeEx

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_RegCreateKey
; Description....: Creates the specified registry key.
; Syntax.........: _WinAPI_RegCreateKey ( $hKey [, $sSubKey [, $iAccess [, $iOptions [, $tSecurity]]]] )
; Parameters.....: $hKey      - Handle to an open registry key. If the key already exists, the function opens it. The calling process
;                               must have $KEY_CREATE_SUB_KEY access to the key. This handle is returned by the _WinAPI_RegCreateKey()
;                               or _WinAPI_RegOpenKey() function, or it can be one of the following predefined keys.
;
;                               $HKEY_CLASSES_ROOT
;                               $HKEY_CURRENT_CONFIG
;                               $HKEY_CURRENT_USER
;                               $HKEY_LOCAL_MACHINE
;                               $HKEY_USERS
;
;                  $sSubKey   - The name of a subkey that this function opens or creates. The subkey specified must be a subkey of
;                               the key identified by the $hKey parameter; it can be up to 32 levels deep in the registry tree.
;                  $iAccess   - The mask that specifies the access rights for the key. This parameter can be one or more of
;                               the following values.
;
;                               $KEY_ALL_ACCESS
;                               $KEY_CREATE_LINK
;                               $KEY_CREATE_SUB_KEY
;                               $KEY_ENUMERATE_SUB_KEYS
;                               $KEY_EXECUTE
;                               $KEY_NOTIFY
;                               $KEY_QUERY_VALUE
;                               $KEY_READ
;                               $KEY_SET_VALUE
;                               $KEY_WOW64_32KEY
;                               $KEY_WOW64_64KEY
;                               $KEY_WRITE
;
;                  $iOptions  - This parameter can be one of the following values.
;
;                               $REG_OPTION_BACKUP_RESTORE
;                               $REG_OPTION_CREATE_LINK
;                               $REG_OPTION_NON_VOLATILE
;                               $REG_OPTION_VOLATILE
;
;                  $tSecurity - $tagSECURITY_ATTRIBUTES structure that determines whether the returned handle can be inherited by
;                               child processes. If this parameter is 0, the handle cannot be inherited.
; Return values..: Success    - Handle to the opened or created key, @extended flag will contain one of the following
;                               disposition values.
;
;                               0 (FALSE) - The key existed and was simply opened without being changed.
;                               1 (TRUE)  - The key did not exist and was created.
;
;                  Failure    - 0 and sets the @error flag to non-zero, @extended flag may contain the system error code.
; Author.........: Yashied
; Modified.......:
; Remarks........: An application cannot create a key that is a direct child of HKEY_USERS or HKEY_LOCAL_MACHINE. An application
;                  can create subkeys in lower levels of the HKEY_USERS or HKEY_LOCAL_MACHINE trees.
;
;                  If the key is not one of the predefined registry keys ($HKEY_*) you must call the _WinAPI_RegCloseKey()
;                  function after finished using the handle.
; Related........:
; Link...........: @@MsdnLink@@ RegCreateKeyEx
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_RegCreateKey($hKey, $sSubKey = '', $iAccess = 0xF003F, $iOptions = 0, $tSecurity = 0)

	Local $Ret = DllCall('advapi32.dll', 'long', 'RegCreateKeyExW', 'ulong_ptr', $hKey, 'wstr', $sSubKey, 'dword', 0, 'ptr', 0, 'dword', $iOptions, 'dword', $iAccess, 'ptr', DllStructGetPtr($tSecurity), 'ulong_ptr*', 0, 'dword*', 0)

	If @error Then
		Return SetError(1, 0, 0)
	Else
		If $Ret[0] Then
			Return SetError(1, $Ret[0], 0)
		EndIf
	EndIf
	Return SetError(0, Number($Ret[9] = 1), $Ret[8])
EndFunc   ;==>_WinAPI_RegCreateKey

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_RegDeleteEmptyKey
; Description....: Deletes an empty key.
; Syntax.........: _WinAPI_RegDeleteEmptyKey ( $hKey [, $sSubKey] )
; Parameters.....: $hKey    - Handle to an open registry key, or any of the following predefined keys.
;
;                             $HKEY_CLASSES_ROOT
;                             $HKEY_CURRENT_CONFIG
;                             $HKEY_CURRENT_USER
;                             $HKEY_LOCAL_MACHINE
;                             $HKEY_USERS
;
;                  $sSubKey - The name of the key to delete.
; Return values..: Success  - 1.
;                  Failure  - 0 and sets the @error flag to non-zero, @extended flag may contain the system error code.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ SHDeleteEmptyKey
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_RegDeleteEmptyKey($hKey, $sSubKey = '')

	Local $Ret = DllCall('shlwapi.dll', 'long', 'SHDeleteEmptyKeyW', 'ulong_ptr', $hKey, 'wstr', $sSubKey)

	If @error Then
		Return SetError(1, 0, 0)
	Else
		If $Ret[0] Then
			Return SetError(1, $Ret[0], 0)
		EndIf
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_RegDeleteEmptyKey

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_RegDeleteKey
; Description....: Deletes a subkey and its values.
; Syntax.........: _WinAPI_RegDeleteKey ( $hKey [, $sSubKey] )
; Parameters.....: $hKey    - Handle to an open registry key. The access rights of this key do not affect the delete operation.
;                             This handle is returned by the _WinAPI_RegCreateKey() or _WinAPI_RegOpenKey() function, or it can be
;                             one of the following predefined keys.
;
;                             $HKEY_CLASSES_ROOT
;                             $HKEY_CURRENT_CONFIG
;                             $HKEY_CURRENT_USER
;                             $HKEY_LOCAL_MACHINE
;                             $HKEY_USERS
;
;                  $sSubKey - The name of the key to be deleted. It must be a subkey of the key that $hKey identifies, but it
;                             cannot have subkeys.
; Return values..: Success  - 1.
;                  Failure  - 0 and sets the @error flag to non-zero, @extended flag may contain the system error code.
; Author.........: Yashied
; Modified.......:
; Remarks........: A deleted key is not removed until the last handle to it is closed.
; Related........:
; Link...........: @@MsdnLink@@ RegDeleteKey
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_RegDeleteKey($hKey, $sSubKey = '')

	Local $Ret = DllCall('advapi32.dll', 'long', 'RegDeleteKeyW', 'ulong_ptr', $hKey, 'wstr', $sSubKey)

	If @error Then
		Return SetError(1, 0, 0)
	Else
		If $Ret[0] Then
			Return SetError(1, $Ret[0], 0)
		EndIf
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_RegDeleteKey

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_RegDeleteKeyValue
; Description....: Removes the specified value from the specified registry key and subkey.
; Syntax.........: _WinAPI_RegDeleteKeyValue ( $hKey, $sSubKey, $sValueName )
; Parameters.....: $hKey       - Handle to an open registry key. The key must have been opened with the $KEY_SET_VALUE access right.
;                                This handle is returned by the _WinAPI_RegCreateKey() or _WinAPI_RegOpenKey() function, or it can be
;                                one of the following predefined keys.
;
;                                $HKEY_CLASSES_ROOT
;                                $HKEY_CURRENT_CONFIG
;                                $HKEY_CURRENT_USER
;                                $HKEY_LOCAL_MACHINE
;                                $HKEY_USERS
;
;                  $sSubKey    - The name of the registry key. This key must be a subkey of the key identified by the $hKey parameter.
;                  $sValueName - The registry value to be removed from the key.
; Return values..: Success     - 1.
;                  Failure     - 0 and sets the @error flag to non-zero, @extended flag may contain the system error code.
; Author.........: Yashied
; Modified.......:
; Remarks........: This function requires Windows Vista or later.
; Related........:
; Link...........: @@MsdnLink@@ RegDeleteKeyValue
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_RegDeleteKeyValue($hKey, $sSubKey, $sValueName)

	Local $Ret = DllCall('advapi32.dll', 'long', 'RegDeleteKeyValueW', 'ulong_ptr', $hKey, 'wstr', $sSubKey, 'wstr', $sValueName)

	If @error Then
		Return SetError(1, 0, 0)
	Else
		If $Ret[0] Then
			Return SetError(1, $Ret[0], 0)
		EndIf
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_RegDeleteKeyValue

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_RegDeleteTree
; Description....: Deletes a subkey and all its descendants.
; Syntax.........: _WinAPI_RegDeleteTree ( $hKey [, $sSubKey] )
; Parameters.....: $hKey    - Handle to an open registry key, or any of the following predefined keys.
;
;                             $HKEY_CLASSES_ROOT
;                             $HKEY_CURRENT_CONFIG
;                             $HKEY_CURRENT_USER
;                             $HKEY_LOCAL_MACHINE
;                             $HKEY_PERFORMANCE_DATA
;                             $HKEY_USERS
;
;                  $sSubKey - The name of the key to delete.
; Return values..: Success  - 1.
;                  Failure  - 0 and sets the @error flag to non-zero, @extended flag may contain the system error code.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ SHDeleteKey
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_RegDeleteTree($hKey, $sSubKey = '')

	Local $Ret = DllCall('shlwapi.dll', 'long', 'SHDeleteKeyW', 'ulong_ptr', $hKey, 'wstr', $sSubKey)

	If @error Then
		Return SetError(1, 0, 0)
	Else
		If $Ret[0] Then
			Return SetError(1, $Ret[0], 0)
		EndIf
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_RegDeleteTree

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_RegDeleteTreeEx
; Description....: Deletes the subkeys and values of the specified key recursively.
; Syntax.........: _WinAPI_RegDeleteTreeEx ( $hKey [, $sSubKey] )
; Parameters.....: $hKey    - Handle to an open registry key. The key must have been opened with the following access rights:
;                             $DELETE, $KEY_ENUMERATE_SUB_KEYS, and $KEY_QUERY_VALUE. This handle is returned by the _WinAPI_RegCreateKey()
;                             or _WinAPI_RegOpenKey() function, or it can be one of the following predefined keys.
;
;                             $HKEY_CLASSES_ROOT
;                             $HKEY_CURRENT_CONFIG
;                             $HKEY_CURRENT_USER
;                             $HKEY_LOCAL_MACHINE
;                             $HKEY_USERS
;
;                  $sSubKey - The name of the key to delete. This key must be a subkey of the key identified by the $hKey parameter.
;                             If this parameter is not specified, the subkeys and values of $hKey are deleted.
; Return values..: Success  - 1.
;                  Failure  - 0 and sets the @error flag to non-zero, @extended flag may contain the system error code.
; Author.........: Yashied
; Modified.......:
; Remarks........: If the key has values, it must be opened with $KEY_SET_VALUE or this function will fail.
;
;                  This function requires Windows Vista or later.
; Related........:
; Link...........: @@MsdnLink@@ RegDeleteTree
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_RegDeleteTreeEx($hKey, $sSubKey = '')

	Local $Ret = DllCall('advapi32.dll', 'long', 'RegDeleteTreeW', 'ulong_ptr', $hKey, 'wstr', $sSubKey)

	If @error Then
		Return SetError(1, 0, 0)
	Else
		If $Ret[0] Then
			Return SetError(1, $Ret[0], 0)
		EndIf
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_RegDeleteTreeEx

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_RegDeleteValue
; Description....: Removes a named value from the specified registry key.
; Syntax.........: _WinAPI_RegDeleteValue ( $hKey, $sValueName )
; Parameters.....: $hKey       - Handle to an open registry key. The key must have been opened with the $KEY_SET_VALUE access right.
;                                This handle is returned by the _WinAPI_RegCreateKey() or _WinAPI_RegOpenKey() function, or it can be
;                                one of the following predefined keys.
;
;                                $HKEY_CLASSES_ROOT
;                                $HKEY_CURRENT_CONFIG
;                                $HKEY_CURRENT_USER
;                                $HKEY_LOCAL_MACHINE
;                                $HKEY_USERS
;
;                  $sValueName - The registry value to be removed. If this parameter is empty string, the key's unnamed or default
;                                value is removed.
; Return values..: Success     - 1.
;                  Failure     - 0 and sets the @error flag to non-zero, @extended flag may contain the system error code.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ RegDeleteValue
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_RegDeleteValue($hKey, $sValueName)

	Local $Ret = DllCall('advapi32.dll', 'long', 'RegDeleteValueW', 'ulong_ptr', $hKey, 'wstr', $sValueName)

	If @error Then
		Return SetError(1, 0, 0)
	Else
		If $Ret[0] Then
			Return SetError(1, $Ret[0], 0)
		EndIf
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_RegDeleteValue

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_RegDuplicateHKey
; Description....: Duplicates a registry key's handle.
; Syntax.........: _WinAPI_RegDuplicateHKey ( $hKey )
; Parameters.....: $hKey   - Handle to an open registry key to be duplicated.
; Return values..: Success - A duplicate of the handle.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ SHRegDuplicateHKey
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_RegDuplicateHKey($hKey)

	Local $Ret = DllCall('shlwapi.dll', 'ulong_ptr', 'SHRegDuplicateHKey', 'ulong_ptr', $hKey)

	If @error Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_RegDuplicateHKey

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_RegEnumKey
; Description....: Enumerates the subkeys of the specified open registry key.
; Syntax.........: _WinAPI_RegEnumKey ( $hKey, $iIndex )
; Parameters.....: $hKey   - Handle to an open registry key. The key must have been opened with the $KEY_ENUMERATE_SUB_KEYS access
;                            right. This handle is returned by the _WinAPI_RegCreateKey() or _WinAPI_RegOpenKey() function.
;                            It can also be one of the following predefined keys.
;
;                            $HKEY_CLASSES_ROOT
;                            $HKEY_CURRENT_CONFIG
;                            $HKEY_CURRENT_USER
;                            $HKEY_LOCAL_MACHINE
;                            $HKEY_PERFORMANCE_DATA
;                            $HKEY_USERS
;
;                  $iIndex - The index of the subkey to retrieve. This parameter should be zero for the first call to the _WinAPI_RegEnumKey()
;                            function and then incremented for subsequent calls.
; Return values..: Success - The string that contains the name of the subkey.
;                  Failure - Empty string and sets the @error flag to non-zero, @extended flag may contain the system error code.
; Author.........: Yashied
; Modified.......:
; Remarks........: To enumerate subkeys, an application should initially call the _WinAPI_RegEnumKey() function with the $iIndex
;                  parameter set to zero. The application should then increment the $iIndex parameter and call _WinAPI_RegEnumKey()
;                  until there are no more subkeys (meaning the @extended flag sets to ERROR_NO_MORE_ITEMS (259)).
;
;                  The application can also set $iIndex to the index of the last subkey on the first call to the function and
;                  decrement the index until the subkey with the index 0 is enumerated. To retrieve the index of the last subkey,
;                  use the _WinAPI_RegQueryInfoKey() function.
;
;                  While an application is using the _WinAPI_RegEnumKey() function, it should not make calls to any registration
;                  functions that might change the key being enumerated.
; Related........:
; Link...........: @@MsdnLink@@ RegEnumKeyEx
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_RegEnumKey($hKey, $iIndex)

	Local $tData = DllStructCreate('wchar[256]')
	Local $Ret = DllCall('advapi32.dll', 'long', 'RegEnumKeyExW', 'ulong_ptr', $hKey, 'dword', $iIndex, 'ptr', DllStructGetPtr($tData), 'dword*', 256, 'dword', 0, 'ptr', 0, 'ptr', 0, 'ptr', 0)

	If @error Then
		Return SetError(1, 0, '')
	Else
		If $Ret[0] Then
			Return SetError(1, $Ret[0], '')
		EndIf
	EndIf
	Return DllStructGetData($tData, 1)
EndFunc   ;==>_WinAPI_RegEnumKey

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_RegEnumValue
; Description....: Enumerates the values for the specified open registry key.
; Syntax.........: _WinAPI_RegEnumValue ( $hKey, $iIndex )
; Parameters.....: $hKey   - Handle to an open registry key. The key must have been opened with the $KEY_QUERY_VALUE access right.
;                            This handle is returned by the _WinAPI_RegCreateKey() or _WinAPI_RegOpenKey() function. It can also
;                            be one of the following predefined keys.
;
;                            $HKEY_CLASSES_ROOT
;                            $HKEY_CURRENT_CONFIG
;                            $HKEY_CURRENT_USER
;                            $HKEY_LOCAL_MACHINE
;                            $HKEY_PERFORMANCE_DATA
;                            $HKEY_USERS
;
;                  $iIndex - The index of the value to be retrieved. This parameter should be zero for the first call to the _WinAPI_RegEnumValue()
;                            function and then be incremented for subsequent calls.
; Return values..: Success - The string that contains the name of the value, @extended flag will contain the code indicating the
;                            type of data ($REG_*) stored in the specified value.
;                  Failure - Empty string and sets the @error flag to non-zero, @extended flag may contain the system error code.
; Author.........: Yashied
; Modified.......:
; Remarks........: To enumerate values, an application should initially call the _WinAPI_RegEnumValue() function with the $iIndex
;                  parameter set to zero. The application should then increment $iIndex and call the _WinAPI_RegEnumValue() function
;                  until there are no more values (until the @extended flag sets to ERROR_NO_MORE_ITEMS (259)).
;
;                  The application can also set $iIndex to the index of the last value on the first call to the function and
;                  decrement the index until the value with index 0 is enumerated. To retrieve the index of the last value,
;                  use the _WinAPI_RegQueryInfoKey() function.
;
;                  While using _WinAPI_RegEnumValue(), an application should not call any registry functions that might change the
;                  key being queried.
; Related........:
; Link...........: @@MsdnLink@@ RegEnumValue
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_RegEnumValue($hKey, $iIndex)

	Local $tData = DllStructCreate('wchar[1024]')
	Local $Ret = DllCall('advapi32.dll', 'long', 'RegEnumValueW', 'ulong_ptr', $hKey, 'dword', $iIndex, 'ptr', DllStructGetPtr($tData), 'dword*', 1024, 'dword', 0, 'dword*', 0, 'ptr', 0, 'ptr', 0)

	If @error Then
		Return SetError(1, 0, 0)
	Else
		If $Ret[0] Then
			Return SetError(1, $Ret[0], 0)
		EndIf
	EndIf
	Return SetError(0, $Ret[6], DllStructGetData($tData, 1))
EndFunc   ;==>_WinAPI_RegEnumValue

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_RegFlushKey
; Description....: Writes all the attributes of the specified open registry key into the registry.
; Syntax.........: _WinAPI_RegFlushKey ( $hKey )
; Parameters.....: $hKey   - Handle to an open registry key. The key must have been opened with the $KEY_QUERY_VALUE access right.
;                            This handle is returned by the _WinAPI_RegCreateKey() or _WinAPI_RegOpenKey() function. It can also
;                            be one of the following predefined keys.
;
;                            $HKEY_CLASSES_ROOT
;                            $HKEY_CURRENT_CONFIG
;                            $HKEY_CURRENT_USER
;                            $HKEY_LOCAL_MACHINE
;                            $HKEY_PERFORMANCE_DATA
;                            $HKEY_USERS
;
; Return values..: Success - 1.
;                  Failure - 0 and sets the @error flag to non-zero, @extended flag may contain the system error code.
; Author.........: Yashied
; Modified.......:
; Remarks........: The _WinAPI_RegFlushKey() function returns only when all the data for the hive that contains the specified key
;                  has been written to the registry store on disk. The _WinAPI_RegFlushKey() function writes out the data for other
;                  keys in the hive that have been modified since the last lazy flush or system start. After _WinAPI_RegFlushKey()
;                  returns, use _WinAPI_RegCloseKey() to close the handle to the registry key.
; Related........:
; Link...........: @@MsdnLink@@ RegFlushKey
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_RegFlushKey($hKey)

	Local $Ret = DllCall('advapi32.dll', 'long', 'RegFlushKey', 'ulong_ptr', $hKey)

	If @error Then
		Return SetError(1, 0, 0)
	Else
		If $Ret[0] Then
			Return SetError(1, $Ret[0], 0)
		EndIf
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_RegFlushKey

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_RegisterClassEx
; Description....: Registers a window class.
; Syntax.........: _WinAPI_RegisterClassEx ( $tWNDCLASSEX )
; Parameters.....: $tWNDCLASSEX - $tagWNDCLASSEX structure.
; Return values..: Success      - The value is a class atom that uniquely identifies the class being registered.
;                  Failure      - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ RegisterClassEx
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_RegisterClassEx($tWNDCLASSEX)

	Local $Ret = DllCall('user32.dll', 'dword', 'RegisterClassExW', 'ptr', DllStructGetPtr($tWNDCLASSEX))

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_RegisterClassEx

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_RegisterHotKey
; Description....: Defines a system-wide hot key.
; Syntax.........: _WinAPI_RegisterHotKey ( $hWnd, $ID, $iModifiers, $vKey )
; Parameters.....: $hWnd       - Handle to the window that will receive WM_HOTKEY messages generated by the hot key. If this parameter
;                                is 0, WM_HOTKEY messages are posted to the message queue of the calling thread and must be processed in
;                                the message loop.
;                  $ID         - Specifies the identifier of the hot key. An application must specify an id value in the range
;                                0x0000 through 0xBFFF.
;                  $iModifiers - Specifies keys that must be pressed in combination with the key specified by the $vKey parameter
;                                in order to generate the WM_HOTKEY message. The $iModifiers parameter can be a combination of the
;                                following values.
;
;                                $MOD_ALT
;                                $MOD_CONTROL
;                                $MOD_SHIFT
;                                $MOD_WIN
;
;                                *Windows 7 or later
;
;                                $MOD_NOREPEAT
;
;                  $vKey       - Specifies the virtual-key code of the hot key ($VK_*).
; Return values..: Success     - 1.
;                  Failure     - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: When a key is pressed, the system looks for a match against all hot keys. Upon finding a match, the system posts
;                  the WM_HOTKEY message to the message queue of the window with which the hot key is associated. If the hot key is
;                  not associated with a window, then the WM_HOTKEY message is posted to the thread associated with the hot key.
;
;                  _WinAPI_RegisterHotKey() fails if the keystrokes specified for the hot key have already been registered by
;                  another hot key.
;
;                  In Windows XP and previous versions of Windows, if a hot key already exists with the same $hWnd and $ID parameters,
;                  it is replaced by the new hot key.
;
;                  In Windows Vista and subsequent versions of Windows, if a hot key already exists with the same $hWnd and $ID
;                  parameters, it is maintained along with the new hot key. In these versions of Windows, the application must
;                  explicitly call _WinAPI_UnregisterHotKey() to unregister the old hot key.
; Related........:
; Link...........: @@MsdnLink@@ RegisterHotKey
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_RegisterHotKey($hWnd, $ID, $iModifiers, $vKey)

	Local $Ret = DllCall('user32.dll', 'int', 'RegisterHotKey', 'hwnd', $hWnd, 'int', $ID, 'uint', $iModifiers, 'uint', $vKey)

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_RegisterHotKey

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

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_RegisterShellHookWindow

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_RegLoadMUIString
; Description....: Loads the specified string from the specified key and subkey.
; Syntax.........: _WinAPI_RegLoadMUIString ( $hKey, $sValueName [, $sDirectory] )
; Parameters.....: $hKey       - Handle to an open registry key. The key must have been opened with the $KEY_QUERY_VALUE access right.
;                                This handle is returned by the _WinAPI_RegCreateKey() or _WinAPI_RegOpenKey() function. It can also
;                                be one of the following predefined keys.
;
;                                $HKEY_CLASSES_ROOT
;                                $HKEY_CURRENT_CONFIG
;                                $HKEY_CURRENT_USER
;                                $HKEY_LOCAL_MACHINE
;                                $HKEY_USERS
;
;                  $sValueName - The name of the registry value.
;                  $sDirectory - The directory path.
; Return values..: Success     - The loaded string.
;                  Failure     - Empty string and sets the @error flag to non-zero, @extended flag may contain the system error code.
; Author.........: Yashied
; Modified.......:
; Remarks........: The strings of the following form receive special handling:
;
;                  @[path]\dllname,-strID
;
;                  The string with identifier strID is loaded from dllname; the path is optional. If the $sDirectory parameter is
;                  empty string, the directory is prepended to the path specified in the registry data. Note that dllname can contain
;                  environment variables to be expanded.
;
;                  This function requires Windows Vista or later.
; Related........:
; Link...........: @@MsdnLink@@ RegLoadMUIString
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_RegLoadMUIString($hKey, $sValueName, $sDirectory = '')

	Local $TypeOfDirectory = 'wstr'

	If Not StringStripWS($sDirectory, 3) Then
		$TypeOfDirectory = 'ptr'
		$sDirectory = 0
	EndIf

	Local $tData = DllStructCreate('wchar[1024]')
	Local $Ret = DllCall('advapi32.dll', 'long', 'RegLoadMUIStringW', 'ulong_ptr', $hKey, 'wstr', $sValueName, 'ptr', DllStructGetPtr($tData), 'dword', DllStructGetSize($tData), 'dword*', 0, 'dword', 0, $TypeOfDirectory, $sDirectory)

	If @error Then
		Return SetError(1, 0, '')
	Else
		If $Ret[0] Then
			Return SetError(1, $Ret[0], '')
		EndIf
	EndIf
	Return DllStructGetData($tData, 1)
EndFunc   ;==>_WinAPI_RegLoadMUIString

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_RegNotifyChangeKeyValue
; Description....: Notifies the caller about changes to the attributes or contents of a specified registry key.
; Syntax.........: _WinAPI_RegNotifyChangeKeyValue ( $hKey, $iFilter [, $fSubtree [, $fAsync [, $hEvent]]] )
; Parameters.....: $hKey     - Handle to an open registry key. The key must have been opened with the KEY_NOTIFY access right.
;                              This handle is returned by the _WinAPI_RegCreateKey() or _WinAPI_RegOpenKey() function. It can also
;                              be one of the following predefined keys.
;
;                              $HKEY_CLASSES_ROOT
;                              $HKEY_CURRENT_CONFIG
;                              $HKEY_CURRENT_USER
;                              $HKEY_LOCAL_MACHINE
;                              $HKEY_USERS
;
;                  $iFilter  - Indicates the changes that should be reported. This parameter can be one or more of the following values.
;
;                              $REG_NOTIFY_CHANGE_NAME
;                              $REG_NOTIFY_CHANGE_ATTRIBUTES
;                              $REG_NOTIFY_CHANGE_LAST_SET
;                              $REG_NOTIFY_CHANGE_SECURITY
;
;                  $fSubtree - Specifies whether report changes in the subkeys of the specified key, valid values:
;                  |TRUE     - The function reports changes in the specified key and all its subkeys.
;                  |FALSE    - The function reports changes only in the specified key. (Default)
;                  $fAsync   - Specifies whether return immediately, valid values:
;                  |TRUE     - The function returns immediately and reports changes by signaling the specified event.
;                  |FALSE    - The function does not return until a change has occurred. (Default)
;                  $hEvent   - Handle to an event. If the $fAsync parameter is TRUE, the function returns immediately and changes are
;                              reported by signaling this event, otherwise this parameter is ignored.
; Return values..: Success   - 1.
;                  Failure   - 0 and sets the @error flag to non-zero, @extended flag may contain the system error code.
; Author.........: Yashied
; Modified.......:
; Remarks........: If the specified key is closed, the event is signaled. This means that an application should not depend on the
;                  key being open after returning from a wait operation on the event.
; Related........:
; Link...........: @@MsdnLink@@ RegNotifyChangeKeyValue
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_RegNotifyChangeKeyValue($hKey, $iFilter, $fSubtree = 0, $fAsync = 0, $hEvent = 0)

	Local $Ret = DllCall('advapi32.dll', 'long', 'RegNotifyChangeKeyValue', 'ulong_ptr', $hKey, 'int', $fSubtree, 'dword', $iFilter, 'ptr', $hEvent, 'int', $fAsync)

	If @error Then
		Return SetError(1, 0, 0)
	Else
		If $Ret[0] Then
			Return SetError(1, $Ret[0], 0)
		EndIf
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_RegNotifyChangeKeyValue

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_RegOpenKey
; Description....: Opens the specified registry key.
; Syntax.........: _WinAPI_RegOpenKey ( $hKey [, $sSubKey [, $iAccess]] )
; Parameters.....: $hKey    - Handle to an open registry key. This handle is returned by the _WinAPI_RegCreateKey() or _WinAPI_RegOpenKey()
;                             function, or it can be one of the following predefined keys.
;
;                             $HKEY_CLASSES_ROOT
;                             $HKEY_CURRENT_USER
;                             $HKEY_LOCAL_MACHINE
;                             $HKEY_USERS
;
;                  $sSubKey - The name of the registry subkey to be opened.
;                  $iAccess - A mask that specifies the desired access rights to the key. The function fails if the security
;                             descriptor of the key does not permit the requested access for the calling process. This parameter
;                             can be one or more of the $KEY_* constants.
; Return values..: Success  - Handle to the opened key.
;                  Failure  - 0 and sets the @error flag to non-zero, @extended flag may contain the system error code.
; Author.........: Yashied
; Modified.......:
; Remarks........: Unlike the _WinAPI_RegCreateKey() function, the _WinAPI_RegOpenKey() function does not create the specified key
;                  if the key does not exist in the registry.
;
;                  If the key is not one of the predefined registry keys ($HKEY_*) you must call the _WinAPI_RegCloseKey()
;                  function after finished using the handle.
; Related........:
; Link...........: @@MsdnLink@@ RegOpenKeyEx
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_RegOpenKey($hKey, $sSubKey = '', $iAccess = 0xF003F)

	Local $Ret = DllCall('advapi32.dll', 'long', 'RegOpenKeyExW', 'ulong_ptr', $hKey, 'wstr', $sSubKey, 'dword', 0, 'dword', $iAccess, 'ulong_ptr*', 0)

	If @error Then
		Return SetError(1, 0, 0)
	Else
		If $Ret[0] Then
			Return SetError(1, $Ret[0], 0)
		EndIf
	EndIf
	Return $Ret[5]
EndFunc   ;==>_WinAPI_RegOpenKey

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_RegQueryInfoKey
; Description....: Retrieves information about the specified registry key.
; Syntax.........: _WinAPI_RegQueryInfoKey ( $hKey )
; Parameters.....: $hKey   - Handle to an open registry key. The key must have been opened with the $KEY_QUERY_VALUE access right.
;                            This handle is returned by the _WinAPI_RegCreateKey() or _WinAPI_RegOpenKey() function. It can also
;                            be one of the following predefined keys.
;
;                            $HKEY_CLASSES_ROOT
;                            $HKEY_CURRENT_CONFIG
;                            $HKEY_CURRENT_USER
;                            $HKEY_LOCAL_MACHINE
;                            $HKEY_PERFORMANCE_DATA
;                            $HKEY_USERS
;
; Return values..: Success - The array containing the following parameters:
;
;                            [0] - The number of subkeys that are contained by the specified key.
;                            [1] - The size of the key's subkey with the longest name, in characters, not including the terminating null character.
;                            [2] - The number of values that are associated with the key.
;                            [3] - The size of the key's longest value name, in characters. The size does not include the terminating null character.
;                            [4] - The size of the longest data component among the key's values, in bytes.
;
;                  Failure - 0 and sets the @error flag to non-zero, @extended flag may contain the system error code.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ RegQueryInfoKey
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_RegQueryInfoKey($hKey)

	Local $Ret = DllCall('advapi32.dll', 'long', 'RegQueryInfoKeyW', 'ulong_ptr', $hKey, 'ptr', 0, 'ptr', 0, 'dword', 0, 'dword*', 0, 'dword*', 0, 'ptr', 0, 'dword*', 0, 'dword*', 0, 'dword*', 0, 'ptr', 0, 'ptr', 0)

	If @error Then
		Return SetError(1, 0, 0)
	Else
		If $Ret[0] Then
			Return SetError(1, $Ret[0], 0)
		EndIf
	EndIf

	Local $Result[5]

	$Result[0] = $Ret[5]
	$Result[1] = $Ret[6]
	$Result[2] = $Ret[8]
	$Result[3] = $Ret[9]
	$Result[4] = $Ret[10]

	Return $Result
EndFunc   ;==>_WinAPI_RegQueryInfoKey

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_RegQueryLastWriteTime
; Description....: Retrieves information about the last write time to the specified registry key.
; Syntax.........: _WinAPI_RegQueryLastWriteTime ( $hKey )
; Parameters.....: $hKey   - Handle to an open registry key. The key must have been opened with the $KEY_QUERY_VALUE access right.
;                            This handle is returned by the _WinAPI_RegCreateKey() or _WinAPI_RegOpenKey() function. It can also
;                            be one of the following predefined keys.
;
;                            $HKEY_CLASSES_ROOT
;                            $HKEY_CURRENT_CONFIG
;                            $HKEY_CURRENT_USER
;                            $HKEY_LOCAL_MACHINE
;                            $HKEY_PERFORMANCE_DATA
;                            $HKEY_USERS
;
; Return values..: Success - $tagFILETIME structure that contains the last write time.
;                  Failure - 0 and sets the @error flag to non-zero, @extended flag may contain the system error code.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ RegQueryInfoKey
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_RegQueryLastWriteTime($hKey)

	Local $tFILETIME = DllStructCreate($tagFILETIME)
	Local $Ret = DllCall('advapi32.dll', 'long', 'RegQueryInfoKeyW', 'ulong_ptr', $hKey, 'ptr', 0, 'ptr', 0, 'dword', 0, 'ptr', 0, 'ptr', 0, 'ptr', 0, 'ptr', 0, 'ptr', 0, 'ptr', 0, 'ptr', 0, 'ptr', DllStructGetPtr($tFILETIME))

	If @error Then
		Return SetError(1, 0, 0)
	Else
		If $Ret[0] Then
			Return SetError(1, $Ret[0], 0)
		EndIf
	EndIf
	Return $tFILETIME
EndFunc   ;==>_WinAPI_RegQueryLastWriteTime

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_RegQueryMultipleValues
; Description....: Retrieves the type and data for a list of value names associated with an open registry key.
; Syntax.........: _WinAPI_RegQueryMultipleValues ( $hKey, ByRef $aValent, ByRef $tData [, $iStart [, $iEnd]] )
; Parameters.....: $hKey    - Handle to an open registry key. The key must have been opened with the KEY_QUERY_VALUE access right.
;                             This handle is returned by the _WinAPI_RegCreateKey() or _WinAPI_RegOpenKey() function. It can also
;                             be one of the following predefined keys.
;
;                                $HKEY_CLASSES_ROOT
;                                $HKEY_CURRENT_CONFIG
;                                $HKEY_CURRENT_USER
;                                $HKEY_LOCAL_MACHINE
;                                $HKEY_PERFORMANCE_DATA
;                                $HKEY_USERS
;
;                  $aValent - The 2D array ([valuename1, 0, 0, 0], [valuename2, 0, 0, 0], ... [valuenameN, 0, 0, 0]) that contains the
;                             name of a values to retrieve. On input, 1, 2, and 3 array elements are not used, but the size of the array
;                             should be [n][4], otherwise, the function fails. Also, this function fails if any of the specified
;                             values do not exist in the specified key.
;                  $tData   - The buffer to receive data. If the function succeeds, the buffer is a "byte[n]" structure that receives
;                             the data for each value. You should not change this structure until you finish to use the data returned
;                             by this function. After that, you can release the memory allocated by this structure.
;                  $iStart  - The index of array to start querying at.
;                  $iEnd    - The index of array to stop querying at.
; Return values..: Success  - The number of bytes copied to the buffer. The $aValent array will contain the following data:
;
;                             [n][0] - The name of the value (unchanged).
;                             [n][1] - The size of the data, in bytes.
;                             [n][2] - The pointer to the data in buffer pointed to by the $tData parameter.
;                             [n][3] - The type of data ($REG_*).
;
;                  Failure  - 0 and sets the @error flag to non-zero, @extended flag may contain the system error code.
; Author.........: Yashied
; Modified.......:
; Remarks........: To prevent excessive serialization, the aggregate data returned by the function cannot exceed one megabyte.
; Related........:
; Link...........: @@MsdnLink@@ RegQueryMultipleValues
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_RegQueryMultipleValues($hKey, ByRef $aValent, ByRef $tData, $iStart = 0, $iEnd = -1)

	If UBound($aValent, 2) < 4  Then
		Return SetError(2, 0, 0)
	EndIf

	Local $Ret, $Count, $Values, $tValent, $pValent, $Struct = ''

	If $iStart < 0 Then
		$iStart = 0
	EndIf
	If ($iEnd < 0) Or ($iEnd > UBound($aValent) - 1) Then
		$iEnd = UBound($aValent) - 1
	EndIf
	$Values = $iEnd - $iStart + 1
	For $i = 1 To $Values
		$Struct &= 'ptr;dword;dword_ptr;dword;'
	Next
	$tValent = DllStructCreate($Struct)
	If @error Then
		Return SetError(1, 0, 0)
	EndIf
	$Count = 0
	For $i = $iStart To $iEnd
		$aValent[$i][2] = DllStructCreate('wchar[' & (StringLen($aValent[$i][0]) + 1) & ']')
		If @error Then
			Return SetError(1, 0, 0)
		EndIf
		DllStructSetData($tValent, 4 * $Count + 1, DllStructGetptr($aValent[$i][2]))
		DllStructSetData($aValent[$i][2], 1, $aValent[$i][0])
		$Count += 1
	Next
	$pValent = DllStructGetptr($tValent)
	$Ret = DllCall('advapi32.dll', 'long', 'RegQueryMultipleValuesW', 'ulong_ptr', $hKey, 'ptr', $pValent, 'dword', $Values, 'ptr', 0, 'dword*', 0)
	If @error Then
		Return SetError(1, 0, 0)
	Else
		Switch $Ret[0]
			Case 234 ; ERROR_MORE_DATA

			Case Else
				Return SetError(1, $Ret[0], 0)
		EndSwitch
	EndIf
	$tData = DllStructCreate('byte[' & $Ret[5] & ']')
	If @error Then
		Return SetError(1, 0, 0)
	EndIf
	$Ret = DllCall('advapi32.dll', 'long', 'RegQueryMultipleValuesW', 'ulong_ptr', $hKey, 'ptr', $pValent, 'dword', $Values, 'ptr', DllStructGetPtr($tData), 'dword*', $Ret[5])
	If @error Then
		Return SetError(1, 0, 0)
	Else
		If $Ret[0] Then
			Return SetError(1, $Ret[0], 0)
		EndIf
	EndIf
	$Count = 0
	For $i = $iStart To $iEnd
		For $j = 1 To 3
			$aValent[$i][$j] = DllStructGetData($tValent, 4 * $Count + $j + 1)
		Next
		$Count += 1
	Next
	Return $Ret[5]
EndFunc   ;==>_WinAPI_RegQueryMultipleValues

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_RegQueryValue
; Description....: Retrieves the type and data for the specified value name associated with an open registry key.
; Syntax.........: _WinAPI_RegQueryValue ( $hKey, $sValueName, ByRef $tValueData, $iBytes )
; Parameters.....: $hKey       - Handle to an open registry key. The key must have been opened with the KEY_QUERY_VALUE access right.
;                                This handle is returned by the _WinAPI_RegCreateKey() or _WinAPI_RegOpenKey() function. It can also
;                                be one of the following predefined keys.
;
;                                $HKEY_CLASSES_ROOT
;                                $HKEY_CURRENT_CONFIG
;                                $HKEY_CURRENT_USER
;                                $HKEY_LOCAL_MACHINE
;                                $HKEY_PERFORMANCE_DATA
;                                $HKEY_PERFORMANCE_NLSTEXT
;                                $HKEY_PERFORMANCE_TEXT
;                                $HKEY_USERS
;
;                  $sValueName - The name of the registry value. If $sValueName is empty string, the function retrieves the type and
;                                data for the key's unnamed or default value, if any.
;                  $tValueData - The structure (buffer) that receives the value's data.
; Return values..: Success     - The size of the data copied to $tValueData, in bytes, @extended flag will contain the code indicating
;                                the type of data ($REG_*).
;                  Failure     - 0 and sets the @error flag to non-zero, @extended flag may contain the system error code.
; Author.........: Yashied
; Modified.......:
; Remarks........: If the data has the REG_SZ, REG_MULTI_SZ or REG_EXPAND_SZ type, returned size includes any terminating null
;                  character or characters unless the data was stored without them.
;
;                  If the buffer specified by $tValueData parameter is not large enough to hold the data, the function returns
;                  ERROR_MORE_DATA (234) and returns the required buffer size. In this case, the contents of the buffer are
;                  undefined.
; Related........:
; Link...........: @@MsdnLink@@ RegQueryValueEx
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_RegQueryValue($hKey, $sValueName, ByRef $tValueData)

	Local $Ret = DllCall('advapi32.dll', 'long', 'RegQueryValueExW', 'ulong_ptr', $hKey, 'wstr', $sValueName, 'dword', 0, 'dword*', 0, 'ptr', DllStructGetPtr($tValueData), 'dword*', DllStructGetSize($tValueData))

	If @error Then
		Return SetError(1, 0, 0)
	Else
		If $Ret[0] Then
			Return SetError(1, $Ret[0], 0)
		EndIf
	EndIf
	Return SetError(0, $Ret[4], $Ret[6])
EndFunc   ;==>_WinAPI_RegQueryValue

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_RegRestoreKey
; Description....: Reads the registry information in a specified file and copies it over the specified key.
; Syntax.........: _WinAPI_RegRestoreKey ( $hKey, $sFile )
; Parameters.....: $hKey   - Handle to an open registry key. This handle is returned by the _WinAPI_RegCreateKey() or _WinAPI_RegOpenKey()
;                            function. It can also be one of the following predefined keys.
;
;                            $HKEY_CLASSES_ROOT
;                            $HKEY_CURRENT_CONFIG
;                            $HKEY_CURRENT_USER
;                            $HKEY_LOCAL_MACHINE
;                            $HKEY_USERS
;
;                  $sFile  - The name of the file with the registry information. This file is typically created by
;                            using the _WinAPI_RegSaveKey() function.
; Return values..: Success - 1.
;                  Failure - 0 and sets the @error flag to non-zero, @extended flag may contain the system error code.
; Author.........: Yashied
; Modified.......:
; Remarks........: There are two different registry hive file formats. Registry hives created on current operating systems typically
;                  cannot be loaded by earlier ones.
;
;                  The new information in the file specified by $sFile overwrites the contents of the key specified by the $hKey
;                  parameter, except for the key name.
;
;                  If any subkeys of the hKey parameter are open, _WinAPI_RegRestoreKey() fails.
; Related........:
; Link...........: @@MsdnLink@@ RegRestoreKey
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_RegRestoreKey($hKey, $sFile)

	Local $hToken, $Error = 1, $Ret = 0
	Local $Privileges[2] = [$SE_BACKUP_NAME, $SE_RESTORE_NAME]

	$hToken = _WinAPI_OpenProcessToken(BitOR($TOKEN_ADJUST_PRIVILEGES, $TOKEN_QUERY))
	If @error Then
		Return SetError(1, 0, 0)
	EndIf
	_WinAPI_AdjustTokenPrivileges($hToken, $Privileges, 1)
	If Not (@error Or @extended) Then
		$Ret = DllCall('advapi32.dll', 'long', 'RegRestoreKeyW', 'ulong_ptr', $hKey, 'wstr', $sFile, 'dword', 8)
		If @error Then
			$Ret = 0
		Else
			$Ret = $Ret[0]
			If Not $Ret Then
				$Error = 0
			EndIf
		EndIf
	EndIf
	_WinAPI_AdjustTokenPrivileges($hToken, $Privileges, 2)
	_WinAPI_CloseHandle($hToken)
	Return SetError($Error, $Ret, Number(Not $Error))
EndFunc   ;==>_WinAPI_RegRestoreKey

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_RegSaveKey
; Description....: Saves the specified key and all of its subkeys and values to a new file, in the standard format.
; Syntax.........: _WinAPI_RegSaveKey ( $hKey, $sFile [, $tSecurity] )
; Parameters.....: $hKey      - Handle to an open registry key.
;                  $sFile     - The name of the file in which the specified key and subkeys are to be saved. If the file already
;                               exists, the function replaces it. The new file has the archive attribute.
;                  $tSecurity - $tagSECURITY_ATTRIBUTES structure that specifies a security descriptor for the new file. If this
;                               parameter is 0, the file gets a default security descriptor.
; Return values..: Success    - 1.
;                  Failure    - 0 and sets the @error flag to non-zero, @extended flag may contain the system error code.
; Author.........: Yashied
; Modified.......:
; Remarks........: You can use the file created by this function in subsequent calls to the _WinAPI_RegRestoreKey() functions.
; Related........:
; Link...........: @@MsdnLink@@ RegSaveKey
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_RegSaveKey($hKey, $sFile, $tSecurity = 0)

	Local $hToken, $Error = 1, $Ret = 0

	$hToken = _WinAPI_OpenProcessToken(BitOR($TOKEN_ADJUST_PRIVILEGES, $TOKEN_QUERY))
	If @error Then
		Return SetError(1, 0, 0)
	EndIf
	_WinAPI_AdjustTokenPrivileges($hToken, $SE_BACKUP_NAME, 1)
	If Not (@error Or @extended) Then
		FileDelete($sFile)
		$Ret = DllCall('advapi32.dll', 'long', 'RegSaveKeyW', 'ulong_ptr', $hKey, 'wstr', $sFile, 'ptr', DllStructGetPtr($tSecurity))
		If @error Then
			$Ret = 0
		Else
			$Ret = $Ret[0]
			If Not $Ret Then
				$Error = 0
			EndIf
		EndIf
	EndIf
	_WinAPI_AdjustTokenPrivileges($hToken, $SE_BACKUP_NAME, 2)
	_WinAPI_CloseHandle($hToken)
	Return SetError($Error, $Ret, Number(Not $Error))
EndFunc   ;==>_WinAPI_RegSaveKey

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_RegSetValue
; Description....: Sets the data and type of a specified value under a registry key.
; Syntax.........: _WinAPI_RegSetValue ($hKey, $sValueName, $iType, ByRef $tValueData, $iBytes)
; Parameters.....: $hKey       - Handle to an open registry key. The key must have been opened with the $KEY_SET_VALUE access right.
;                                This handle is returned by the _WinAPI_RegCreateKey() or _WinAPI_RegOpenKey() function. It can also
;                                be one of the following predefined keys.
;
;                                $HKEY_CLASSES_ROOT
;                                $HKEY_CURRENT_CONFIG
;                                $HKEY_CURRENT_USER
;                                $HKEY_LOCAL_MACHINE
;                                $HKEY_PERFORMANCE_DATA
;                                $HKEY_USERS
;
;                  $sValueName - The name of the value to be set. If a value with this name is not already present in the key,
;                                the function adds it to the key. If $sValueName is empty string, the function sets the type and
;                                data for the key's unnamed or default value.
;                  $iType      - The type of data. This parameter can be one of the following values.
;
;                                $REG_BINARY
;                                $REG_DWORD
;                                $REG_DWORD_BIG_ENDIAN
;                                $REG_DWORD_LITTLE_ENDIAN
;                                $REG_EXPAND_SZ
;                                $REG_LINK
;                                $REG_MULTI_SZ
;                                $REG_NONE
;                                $REG_QWORD
;                                $REG_QWORD_LITTLE_ENDIAN
;                                $REG_SZ
;
;                  $tValueData - The structure (buffer) that contains the data to be stored. For string-based types, such as REG_SZ,
;                                the string must be null-terminated. With the REG_MULTI_SZ data type, the string must be terminated
;                                with two null characters. A backslash must be preceded by another backslash as an escape character.
;                                For example, specify "C:\\mydir\\myfile" to store the string "C:\mydir\myfile".
;                  $iBytes     - The size of the data, in bytes. If the data has the REG_SZ, REG_MULTI_SZ or REG_EXPAND_SZ type,
;                                this size includes any terminating null character or characters unless the data was stored
;                                without them.
; Return values..: Success     - 1.
;                  Failure     - 0 and sets the @error flag to non-zero, @extended flag may contain the system error code.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ RegSetValueEx
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_RegSetValue($hKey, $sValueName, $iType, ByRef $tValueData, $iBytes)

	Local $Ret = DllCall('advapi32.dll', 'long', 'RegSetValueExW', 'ulong_ptr', $hKey, 'wstr', $sValueName, 'dword', 0, 'dword', $iType, 'ptr', DllStructGetPtr($tValueData), 'dword', $iBytes)

	If @error Then
		Return SetError(1, 0, 0)
	Else
		If $Ret[0] Then
			Return SetError(1, $Ret[0], 0)
		EndIf
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_RegSetValue

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_ReleaseMutex
; Description....: Releases ownership of the specified mutex object.
; Syntax.........: _WinAPI_ReleaseMutex ( $hMutex )
; Parameters.....: $hMutex - Handle to the mutex object. The _WinAPI_CreateMutex() or _WinAPI_OpenMutex() function returns this handle.
; Return values..: Success - 1.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: The _WinAPI_ReleaseMutex() function fails if the calling thread does not own the mutex object.
; Related........:
; Link...........: @@MsdnLink@@ ReleaseMutex
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_ReleaseMutex($hMutex)

	Local $Ret = DllCall('kernel32.dll', 'int', 'ReleaseMutex', 'ptr', $hMutex)

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_ReleaseMutex

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_ReleaseSemaphore
; Description....: Increases the count of the specified semaphore object by a specified amount.
; Syntax.........: _WinAPI_ReleaseSemaphore ( $hSemaphore [, $iIncrease] )
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

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[3]
EndFunc   ;==>_WinAPI_ReleaseSemaphore

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_RemoveFontMemResourceEx
; Description....: Removes the fonts added from a memory image.
; Syntax.........: _WinAPI_RemoveFontMemResourceEx ( $hFont )
; Parameters.....: $hFont  - Handle to the font-resource. This handle is returned by the _WinAPI_AddFontMemResourceEx() function.
; Return values..: Success - 1.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ RemoveFontMemResourceEx
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_RemoveFontMemResourceEx($hFont)

	Local $Ret = DllCall('gdi32.dll', 'int', 'RemoveFontMemResourceEx', 'ptr', $hFont)

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_RemoveFontMemResourceEx

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_RemoveFontResourceEx
; Description....: Removes the fonts in the specified file from the system font table.
; Syntax.........: _WinAPI_RemoveFontResourceEx ( $sFont [, $iFlag [, $fNotify]] )
; Parameters.....: $sFont   - String that names a font resource file. To remove a font whose information comes from several resource
;                             files, they must be separated by a "|". For example, abcxxxxx.pfm|abcxxxxx.pfb.
;                  $iFlag   - The characteristics of the font to be removed from the system. In order for the font to be removed, the flags
;                             used must be the same as when the font was added with the _WinAPI_AddFontResourceEx() function.
;                  $fNotify - Specifies whether sends a WM_FONTCHANGE message, valid values:
;                  |TRUE    - Send the WM_FONTCHANGE message to all top-level windows after changing the pool of font resources.
;                  |FALSE   - Don`t send. (Default)
; Return values..: Success  - 1.
;                  Failure  - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ RemoveFontResourceEx
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_RemoveFontResourceEx($sFont, $iFlag = 0, $fNotify = 0)

	Local $Ret = DllCall('gdi32.dll', 'int', 'RemoveFontResourceExW', 'wstr', $sFont, 'dword', $iFlag, 'ptr', 0)

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	If $fNotify Then
		DllCall('user32.dll', 'int', 'SendMessage', 'hwnd', 0xFFFF, 'uint', 0x001D, 'int', 0, 'int', 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_RemoveFontResourceEx

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_ReOpenFile
; Description....: Reopens the specified file system object with different access rights, sharing mode, and flags.
; Syntax.........: _WinAPI_ReOpenFile ( $hFile, $iAccess, $iShare [, $iFlags] )
; Parameters.....: $sFile   - Handle to the object to be reopened. The object must have been created by the _WinAPI_CreateFile() function.
;                  $iAccess - The required access to the object. If this parameter is 0, the application can query device attributes
;                             without accessing the device.
;
;                             $GENERIC_READ
;                             $GENERIC_WRITE
;
;                             (See MSDN for more information)
;
;                  $iShare  - The sharing mode of the object. If this parameter is 0, the object cannot be shared and cannot be
;                             opened again until the handle is closed.
;
;                             $FILE_SHARE_READ
;                             $FILE_SHARE_WRITE
;                             $FILE_SHARE_DELETE
;
;                  $iFlags  - The file or device attributes and flags. This parameter can be one or more of the following values.
;
;                             $FILE_FLAG_BACKUP_SEMANTICS
;                             $FILE_FLAG_DELETE_ON_CLOSE
;                             $FILE_FLAG_NO_BUFFERING
;                             $FILE_FLAG_OPEN_NO_RECALL
;                             $FILE_FLAG_OPEN_REPARSE_POINT
;                             $FILE_FLAG_OVERLAPPED
;                             $FILE_FLAG_POSIX_SEMANTICS
;                             $FILE_FLAG_RANDOM_ACCESS
;                             $FILE_FLAG_SEQUENTIAL_SCAN
;                             $FILE_FLAG_WRITE_THROUGH
;
;                             $SECURITY_ANONYMOUS
;                             $SECURITY_CONTEXT_TRACKING
;                             $SECURITY_DELEGATION
;                             $SECURITY_EFFECTIVE_ONLY
;                             $SECURITY_IDENTIFICATION
;                             $SECURITY_IMPERSONATION
;
; Return values..: Success  - Handle to the specified file.
;                  Failure  - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: The $iFlags parameter cannot contain any of the file attribute flags ($FILE_ATTRIBUTE_*). These can only be
;                  specified when the file is created.
;
;                  This function requires Windows Vista or later.
; Related........:
; Link...........: @@MsdnLink@@ ReOpenFile
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_ReOpenFile($hFile, $iAccess, $iShare, $iFlags = 0)

	Local $Ret = DllCall('kernel32.dll', 'ptr', 'ReOpenFile', 'ptr', $hFile, 'dword', $iAccess, 'dword', $iShare, 'dword', $iFlags)

	If (@error) Or ($Ret[0] = Ptr(-1)) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_ReOpenFile

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_ReplaceFile
; Description....: Replaces one file with another file, and creates a backup copy of the original file.
; Syntax.........: _WinAPI_ReplaceFile ( $sReplacedFile, $sReplacementFile [, $sBackupFile [, $iFlags]] )
; Parameters.....: $sReplacedFile    - The name of the file to be replaced.
;                  $sReplacementFile - The name of the file that will replace the $sReplacedFile file.
;                  $sBackupFile      - The name of the file that will serve as a backup copy of the $sReplacedFile file. If this
;                                      parameter is empty string, no backup file is created.
;                  $iFlags           - The replacement options. This parameter can be one or more of the following values.
;
;                                      $REPLACEFILE_WRITE_THROUGH
;                                      $REPLACEFILE_IGNORE_MERGE_ERRORS
;                                      $REPLACEFILE_IGNORE_ACL_ERRORS
;
; Return values..: Success           - 1.
;                  Failure           - 0 and sets the @error flag to non-zero (see remarks).
; Author.........: Yashied
; Modified.......:
; Remarks........: If this function fails, call _WinAPI_GetLastError() function to get extended error information. The following
;                  are possible error codes for this function.
;
;                  ERROR_UNABLE_TO_MOVE_REPLACEMENT (1176)
;                  The replacement file could not be renamed. If $sBackupFile was specified, the replaced and replacement files
;                  retain their original file names. Otherwise, the replaced file no longer exists and the replacement file exists
;                  under its original name.
;
;                  ERROR_UNABLE_TO_MOVE_REPLACEMENT_2 (1177)
;                  The replacement file could not be moved. The replacement file still exists under its original name; however,
;                  it has inherited the file streams and attributes from the file it is replacing. The file to be replaced still
;                  exists with the name specified by $sReplacedFile.
;
;                  ERROR_UNABLE_TO_REMOVE_REPLACED (1175)
;                  The replaced file could not be deleted. The replaced and replacement files retain their original file names.
;
;                  If any other error is returned, such as ERROR_INVALID_PARAMETER, the replaced and replacement files will retain
;                  their original file names. In this scenario, a backup file does not exist and it is not guaranteed that the
;                  replacement file will have inherited all of the attributes and streams of the replaced file.
;
; Related........:
; Link...........: @@MsdnLink@@ ReplaceFile
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_ReplaceFile($sReplacedFile, $sReplacementFile, $sBackupFile = '', $iFlags = 0)

	Local $TypeOfBackupFile = 'wstr'

	If Not StringStripWS($sBackupFile, 3) Then
		$TypeOfBackupFile = 'ptr'
		$sBackupFile = 0
	EndIf

	Local $Ret = DllCall('kernel32.dll', 'int', 'ReplaceFileW', 'wstr', $sReplacedFile, 'wstr', $sReplacementFile, $TypeOfBackupFile, $sBackupFile, 'dword', $iFlags, 'ptr', 0, 'ptr', 0)

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_ReplaceFile

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_ResetEvent
; Description....: Sets the specified event object to the nonsignaled state.
; Syntax.........: _WinAPI_ResetEvent ( $hEvent )
; Parameters.....: $hEvent - Handle to the event object. The _WinAPI_CreateEvent() function returns this handle.
; Return values..: Success - 1.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: The state of an event object remains nonsignaled until it is explicitly set to signaled by the _WinAPI_SetEvent()
;                  function. This nonsignaled state blocks the execution of any threads that have specified the event object in a call to
;                  one of the _WinAPI_Wait... functions.
;
;                  The _WinAPI_ResetEvent() function is used primarily for manual-reset event objects, which must be set explicitly to the
;                  nonsignaled state. Auto-reset event objects automatically change from signaled to nonsignaled after a single waiting
;                  thread is released.
; Related........:
; Link...........: @@MsdnLink@@ ResetEvent
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_ResetEvent($hEvent)

	Local $Ret = DllCall('kernel32.dll', 'int', 'ResetEvent', 'ptr', $hEvent)

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_ResetEvent

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_ResizeBitmap
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
; Remarks........: This function does not support bitmaps with Alpha channel, use _WinAPI_AlphaBlend() to work with this bitmaps.
;
;                  When you are finished using the bitmap, destroy it using the _WinAPI_DeleteObject() function. This function
;                  does not destroy the original bitmap, you must to destroy it.
; Related........:
; Link...........: None
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_ResizeBitmap($hBitmap, $iWidth, $iHeight, $iMode = 3)

	Local $Ret, $tObj, $hBmp, $hDC, $hDestDC, $hDestSv, $hSrcDC, $hSrcSv

    $tObj = DllStructCreate($tagBITMAP)
	$Ret = DllCall('gdi32.dll', 'int', 'GetObject', 'int', $hBitmap, 'int', DllStructGetSize($tObj), 'ptr', DllStructGetPtr($tObj))
	If (@error) Or (Not $Ret[0]) Then
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
	$Ret = _WinAPI_StretchBlt($hDestDC, 0, 0, $iWidth, $iHeight, $hSrcDC, 0, 0, DllStructGetData($tObj, 'bmWidth'), DllStructGetData($tObj, 'bmHeight'), 0x00CC0020)
	DllCall('user32.dll', 'int', 'ReleaseDC', 'hwnd', 0, 'hwnd', $hDC)
	DllCall('gdi32.dll', 'ptr', 'SelectObject', 'hwnd', $hDestDC, 'ptr', $hDestSv)
	DllCall('gdi32.dll', 'ptr', 'SelectObject', 'hwnd', $hSrcDC, 'ptr', $hSrcSv)
	DllCall('gdi32.dll', 'int', 'DeleteDC', 'hwnd', $hDestDC)
	DllCall('gdi32.dll', 'int', 'DeleteDC', 'hwnd', $hSrcDC)
	If Not $Ret Then
		Return SetError(1, 0, 0)
	EndIf
	Return $hBmp
EndFunc   ;==>_WinAPI_ResizeBitmap

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_RestartDlg
; Description....: Displays a dialog box that prompts the user to restart Microsoft Windows.
; Syntax.........: _WinAPI_RestartDlg ( [$sText [, $iFlags [, $hParent]]] )
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

	If (@error) Or (Not $Ret[0]) Then
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
	Return __RGB(BitOR(BitShift($iBlue, -16), BitShift($iGreen, -8), $iRed))
EndFunc   ;==>_WinAPI_RGB

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_RotatePoints
; Description....: Rotates a points from the array by the specified angle.
; Syntax.........: _WinAPI_RotatePoints ( ByRef $aPoint, $iXC, $iYC, $iAngle [, $iStart [, $iEnd]] )
; Parameters.....: $aPoint - The 2D array ([x1, y1, ...], [x2, y2, ...], ... [xN, yN, ...]). Every first two elements from this
;                            array specifies a point to be rotate. Other array elements (if any) do not change.
;                  $iXC    - X-coordinates of the point on which there is a rotation, in logical units.
;                  $iYC    - Y-coordinates of the point on which there is a rotation, in logical units.
;                  $iAngle - The angle to rotate, in degree.
;                  $iStart - The index of array to start rotating at.
;                  $iEnd   - The index of array to stop rotating at.
; Return values..: Success - 1.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: None
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_RotatePoints(ByRef $aPoint, $iXC, $iYC, $iAngle, $iStart = 0, $iEnd = -1)
	If UBound($aPoint, 2) < 2  Then
		Return SetError(2, 0, 0)
	EndIf
	If $iStart < 0 Then
		$iStart = 0
	EndIf
	If ($iEnd < 0) Or ($iEnd > UBound($aPoint) - 1) Then
		$iEnd = UBound($aPoint) - 1
	EndIf
	If $iStart > $iEnd Then
		Return SetError(1, 0, 0)
	EndIf

	Local $Cos = Cos(ATan(1) / 45 * $iAngle)
	Local $Sin = Sin(ATan(1) / 45 * $iAngle)
	Local $Xn, $Yn

	For $i = $iStart To $iEnd
		$Xn = $aPoint[$i][0] - $iXC
		$Yn = $aPoint[$i][1] - $iYC
		$aPoint[$i][0] = $iXC + Round($Xn * $Cos - $Yn * $Sin)
		$aPoint[$i][1] = $iYC + Round($Xn * $Sin + $Yn * $Cos)
	Next
	Return 1
EndFunc   ;==>_WinAPI_RotatePoints

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

	If (@error) Or (Not $Ret[0]) Then
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

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_SaveDC

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_SelectClipPath
; Description....: Selects the current path as a clipping region, combining the new region with any existing clipping region.
; Syntax.........: _WinAPI_SelectClipPath ( $hDC [, $iMode] )
; Parameters.....: $hDC    - Handle to the device context of the path.
;                  $iMode  - The way to use the path. This parameter can be one of the following values.
;
;                            $RGN_AND
;                            $RGN_COPY
;                            $RGN_DIFF
;                            $RGN_OR
;                            $RGN_XOR
;
; Return values..: Success - 1.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ SelectClipPath
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_SelectClipPath($hDC, $iMode = 5)

	Local $Ret = DllCall('gdi32.dll', 'int', 'SelectClipPath', 'hwnd', $hDC, 'int', $iMode)

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_SelectClipPath

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_SelectClipRgn
; Description....: Selects a region as the current clipping region for the specified device context.
; Syntax.........: _WinAPI_SelectClipRgn ( $hDC, $hRgn )
; Parameters.....: $hDC    - Handle to the device context.
;                  $hRgn   - Handle to the region to be selected. To remove a device-context's clipping region, set this parameter to 0.
; Return values..: Success - The value that specifies the new clipping region's complexity; it can be one of the following values.
;
;
;                            $COMPLEXREGION
;                            $NULLREGION
;                            $SIMPLEREGION
;
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: Only a copy of the selected region is used. The region itself can be selected for any number of other device
;                  contexts or it can be deleted.
; Related........:
; Link...........: @@MsdnLink@@ SelectClipRgn
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_SelectClipRgn($hDC, $hRgn)

	Local $Ret = DllCall('gdi32.dll', 'int', 'SelectClipRgn', 'hwnd', $hDC, 'ptr', $hRgn)

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_SelectClipRgn

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_SendMessageTimeout
; Description....: Sends the specified message to one of more windows.
; Syntax.........: _WinAPI_SendMessageTimeout ( $hWnd, $iMessage [, $wParam [, $lParam [, $iTimeout [, $iFlags]]]] )
; Parameters.....: $hWnd     - Handle to the window whose window procedure will receive the message.
;                  $iMessage - The message to be sent.
;                  $wParam   - Additional message-specific information.
;                  $lParam   - Additional message-specific information.
;                  $iTimeout - The duration, in milliseconds, of the time-out period. If the message is a broadcast message, each
;                              window can use the full time-out period. Default is 1000.
;                  $iFlags   - The flags that specifies how to send the message. This parameter can be one or more of the
;                              following values.
;
;                              $SMTO_BLOCK
;                              $SMTO_NORMAL
;                              $SMTO_ABORTIFHUNG
;                              $SMTO_NOTIMEOUTIFNOTHUNG
;                              $SMTO_ERRORONEXIT
;
; Return values..: Success   - The result of the message processing, depends on the message sent.
;                  Failure   - (-1) and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: This function does not provide information about individual windows timing out if $HWND_BROADCAST is used.
;
;                  If times out, function fails. To get extended error information, call _WinAPI_GetLastError(). If _WinAPI_GetLastError()
;                  returns ERROR_TIMEOUT, then the function timed out. This function considers a thread is not responding if it has
;                  not responds within five seconds.
;
;                  The system only does marshalling for system messages (those in the range 0 to (WM_USER-1)). To send other messages
;                  (those >= WM_USER) to another process, you must do custom marshalling.
; Related........:
; Link...........: @@MsdnLink@@ SendMessageTimeout
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_SendMessageTimeout($hWnd, $iMessage, $wParam = 0, $lParam = 0, $iTimeout = 1000, $iFlags = 0)

	Local $Ret = DllCall('user32.dll', 'lresult', 'SendMessageTimeoutW', 'hwnd', $hWnd, 'uint', $iMessage, 'wparam', $wParam, 'lparam', $lParam, 'uint', $iFlags, 'uint', $iTimeout, 'dword_ptr*', 0)

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, -1)
	EndIf
	Return $Ret[7]
EndFunc   ;==>_WinAPI_SendMessageTimeout

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

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_SetActiveWindow

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_SetArcDirection
; Description....: Sets the drawing arc direction.
; Syntax.........: _WinAPI_SetArcDirection ( $hDC, $iDirection )
; Parameters.....: $hDC        - Handle to the device context.
;                  $iDirection - The new arc direction. This parameter can be one of the following values.
;
;                                $AD_COUNTERCLOCKWISE
;                                $AD_CLOCKWISE
;
; Return values..: Success     - The previous arc direction.
;                  Failure     - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: The default direction is counterclockwise.
; Related........:
; Link...........: @@MsdnLink@@ SetArcDirection
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_SetArcDirection($hDC, $iDirection)

	Local $Ret = DllCall('gdi32.dll', 'int', 'SetArcDirection', 'hwnd', $hDC, 'int', $iDirection)

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_SetArcDirection

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_SetClassLongEx
; Description....: Replaces the specified value into the specified window belongs.
; Syntax.........: _WinAPI_SetClassLongEx ( $hWnd, $iIndex, $iNewLong )
; Parameters.....: $hWnd     - Handle to the window.
;                  $iIndex   - The value to be replaced. This parameter can be one of the following values.
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
; Return values..: Success   - The previous value.
;                  Failure   - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ SetClassLong
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_SetClassLongEx($hWnd, $iIndex, $iNewLong)

	Local $Ret

	If StringInStr(@OSArch, '64') Then
		$Ret = DllCall('user32.dll', 'ulong_ptr', 'SetClassLongPtrW', 'hwnd', $hWnd, 'int', $iIndex, 'long_ptr', $iNewLong)
	Else
		$Ret = DllCall('user32.dll', 'ulong', 'SetClassLongW', 'hwnd', $hWnd, 'int', $iIndex, 'long', $iNewLong)
	EndIf
	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_SetClassLongEx

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

	Local $Ret = DllCall('kernel32.dll', 'int', 'DeviceIoControl', 'ptr', $hFile, 'dword', $FSCTL_SET_COMPRESSION, 'ptr', DllStructGetPtr($tData), 'dword', DllStructGetSize($tData), 'ptr', 0, 'dword', 0, 'dword*', 0, 'ptr', 0)

	If (@error) Or (Not $Ret[0]) Then
		$Ret = 0
	EndIf
	_WinAPI_CloseHandle($hFile)
	If Not IsArray($Ret) Then
		Return SetError(2, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_SetCompression

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_SetCaretBlinkTime
; Description....: Sets the caret blink time.
; Syntax.........: _WinAPI_SetCaretBlinkTime ( $iDuration )
; Parameters.....: $iDuration - The new blink time, in milliseconds. If this parameter is (-1), caret does not blink.
; Return values..: Success    - The previous blink time, in milliseconds.
;                  Failure    - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: The user can set the blink time using the Control Panel. Applications should respect the setting that the user
;                  has chosen. This function should only be used by application that allow the user to set the blink time, such
;                  as a Control Panel applet.
; Related........:
; Link...........: @@MsdnLink@@ SetCaretBlinkTime
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_SetCaretBlinkTime($iDuration)

	Local $Prev = _WinAPI_GetCaretBlinkTime()

	If @error Then
		Return SetError(1, 0, 0)
	EndIf

	Local $Ret = DllCall('user32.dll', 'int', 'SetCaretBlinkTime', 'uint', $iDuration)

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Prev
EndFunc   ;==>_WinAPI_SetCaretBlinkTime

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_SetCaretPos
; Description....: Moves the caret to the specified coordinates.
; Syntax.........: _WinAPI_SetCaretPos ( $iX, $iY )
; Parameters.....: $iX     - The new x-coordinate of the caret.
;                  $iY     - The new y-coordinate of the caret.
; Return values..: Success - 1.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ SetCaretPos
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_SetCaretPos($iX, $iY)

	Local $Ret = DllCall('user32.dll', 'int', 'SetCaretPos', 'int', $iX, 'int', $iY)

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_SetCaretPos

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

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_SetCurrentDirectory

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_SetDCBrushColor
; Description....: Sets the current device context (DC) brush color to the specified color value.
; Syntax.........: _WinAPI_SetDCBrushColor ( $hDC, $iRGB )
; Parameters.....: $hDC    - Handle to the device context.
;                  $iRGB   - The new brush color, in RGB.
; Return values..: Success - The value that specifies the previous DC brush color, in RGB.
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

	Local $Ret = DllCall('gdi32.dll', 'dword', 'SetDCBrushColor', 'hwnd', $hDC, 'dword', __RGB($iRGB))

	If (@error) Or ($Ret[0] = 0xFFFFFFFF) Then
		Return SetError(1, 0, -1)
	EndIf
	Return __RGB($Ret[0])
EndFunc   ;==>_WinAPI_SetDCBrushColor

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_SetDCPenColor
; Description....: Sets the current device context (DC) pen color to the specified color value.
; Syntax.........: _WinAPI_SetDCPenColor ( $hDC, $iRGB )
; Parameters.....: $hDC    - Handle to the device context.
;                  $iRGB   - The new pen color, in RGB.
; Return values..: Success - The value that specifies the previous DC pen color, in RGB.
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

	Local $Ret = DllCall('gdi32.dll', 'dword', 'SetDCPenColor', 'hwnd', $hDC, 'dword', __RGB($iRGB))

	If (@error) Or ($Ret[0] = 0xFFFFFFFF) Then
		Return SetError(1, 0, -1)
	EndIf
	Return __RGB($Ret[0])
EndFunc   ;==>_WinAPI_SetDCPenColor

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

    If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
    Return 1
EndFunc   ;==>_WinAPI_SetDefaultPrinter

#ce

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_SetDIBitsToDevice
; Description....: Sets the pixels in the specified rectangle on the device.
; Syntax.........: _WinAPI_SetDIBitsToDevice ( $hDC, $iXDest, $iYDest, $iWidth, $iHeight, $iXSrc, $iYSrc, $iStartScan, $iScanLines, $tBITMAPINFO, $iUsage, $pBits )
; Parameters.....: $hDC         - Handle to a device context.
;                  $iXDest      - The x-coordinate, in logical units, of the upper-left corner of the destination rectangle.
;                  $iYDest      - The y-coordinate, in logical units, of the upper-left corner of the destination rectangle.
;                  $iWidth      - The width, in logical units, of the image.
;                  $iHeight     - The height, in logical units, of the image.
;                  $iXSrc       - The x-coordinate, in logical units, of the lower-left corner of the image.
;                  $iYSrc       - The y-coordinate, in logical units, of the lower-left corner of the image.
;                  $iStartScan  - The starting scan line in the image.
;                  $iScanLines  - The number of DIB scan lines.
;                  $tBITMAPINFO - $tagBITMAPINFO structure that contains information about the DIB.
;                  $iUsage      - The type of colors used. (either logical palette indexes or literal RGB values). The following
;                                 values are defined.
;
;                                 $DIB_PAL_COLORS
;                                 $DIB_RGB_COLORS
;
;                  $pBits       - A pointer to the color data stored as an array of bytes.
; Return values..: Success      - The number of scan lines set.
;                  Failure      - 0 and sets the @error flag to non-zero.
; Author.........: Luke
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ SetDIBitsToDevice
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_SetDIBitsToDevice($hDC, $iXDest, $iYDest, $iWidth, $iHeight, $iXSrc, $iYSrc, $iStartScan, $iScanLines, $tBITMAPINFO, $iUsage, $pBits)

	Local $Ret = DllCall('gdi32.dll', 'int', 'SetDIBitsToDevice', 'hwnd', $hDC, 'int', $iYDest, 'int', $iYDest, 'dword', $iWidth, 'dword', $iHeight, 'int', $iXSrc, 'int', $iYSrc, 'uint', $iStartScan, 'uint', $iScanLines, 'ptr', $pBits, 'ptr', DllStructGetPtr($tBITMAPINFO), 'uint', $iUsage)

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_SetDIBitsToDevice

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_SetEnhMetaFileBits
; Description....: Creates a memory-based enhanced-format metafile from the specified data.
; Syntax.........: _WinAPI_SetEnhMetaFileBits ( ByRef $tBits )
; Parameters.....: $tBits  - The "byte[n]" structure (buffer) that contains enhanced-metafile data.
; Return values..: Success - Handle to a memory-based enhanced metafile.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: When the application no longer needs an enhanced-metafile handle, it should delete the handle by calling the
;                  _WinAPI_DeleteEnhMetaFile() function.
; Related........:
; Link...........: @@MsdnLink@@ SetEnhMetaFileBits
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_SetEnhMetaFileBits(ByRef $tBits)

	Local $Ret = DllCall('gdi32.dll', 'ptr', 'SetEnhMetaFileBits', 'uint', DllStructGetSize($tBits), 'ptr', DllStructGetPtr($tBits))

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_SetEnhMetaFileBits

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_SetErrorMode
; Description....: Controls whether the system will handle the specified types of serious errors or whether the process will handle them.
; Syntax.........: _WinAPI_SetErrorMode ( $iMode )
; Parameters.....: $iMode  - The process error mode. This parameter can be one or more of the following values.
;
;                            $SEM_FAILCRITICALERRORS
;                            $SEM_NOALIGNMENTFAULTEXCEPT
;                            $SEM_NOGPFAULTERRORBOX
;                            $SEM_NOOPENFILEERRORBOX
;
; Return values..: Success - The previous state of the error-mode bit flags ($SEM_*).
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ SetErrorMode
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_SetErrorMode($iMode)

	Local $Ret = DllCall('kernel32.dll', 'uint', 'SetErrorMode', 'uint', $iMode)

	If @error Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_SetErrorMode

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_SetFileAttributes
; Description....: Sets the attributes for a file or directory.
; Syntax.........: _WinAPI_SetFileAttributes ( $sFile, $iAttributes )
; Parameters.....: $sFile       - The name of the file whose attributes are to be set.
;                  $iAttributes - The file attributes to set for the file. This parameter can be one or more of the following values.
;
;                                 $FILE_ATTRIBUTE_READONLY
;                                 $FILE_ATTRIBUTE_HIDDEN
;                                 $FILE_ATTRIBUTE_SYSTEM
;                                 $FILE_ATTRIBUTE_ARCHIVE
;                                 $FILE_ATTRIBUTE_NORMAL
;                                 $FILE_ATTRIBUTE_TEMPORARY
;                                 $FILE_ATTRIBUTE_OFFLINE
;                                 $FILE_ATTRIBUTE_NOT_CONTENT_INDEXED
;
; Return values..: Success      - 1.
;                  Failure      - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: Not all attributes are supported by this function. For more information, see MSDN library.
; Related........:
; Link...........: @@MsdnLink@@ SetFileAttributes
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_SetFileAttributes($sFile, $iAttributes)

	Local $Ret = DllCall('kernel32.dll', 'int', 'SetFileAttributesW', 'wstr', $sFile, 'dword', $iAttributes)

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_SetFileAttributes

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

	If (@error) Or (Not $Ret[0]) Then
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

	If (@error) Or (Not $Ret[0]) Then
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

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_SetHandleInformation

#ce

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_SetInformationJobObject
; Description....: Sets limits for a job object.
; Syntax.........: _WinAPI_SetInformationJobObject ( $hJob, $iJobObjectInfoClass, $tJobObjectInfo )
; Parameters.....: $hJob                - Handle to the job whose limits are being set. The handle must have the
;                                         $JOB_OBJECT_SET_ATTRIBUTES access right.
;                  $iJobObjectInfoClass - The information class for the limits to be set. This parameter specifies the type
;                                         of $tJobObjectInfo structure, valid values:
;                  |2  - $tagJOBOBJECT_BASIC_LIMIT_INFORMATION
;                  |4  - $tagJOBOBJECT_BASIC_UI_RESTRICTIONS
;                  |5  - $tagJOBOBJECT_SECURITY_LIMIT_INFORMATION
;                  |6  - $tagJOBOBJECT_END_OF_JOB_TIME_INFORMATION
;                  |7  - $tagJOBOBJECT_ASSOCIATE_COMPLETION_PORT
;                  |9  - $tagJOBOBJECT_EXTENDED_LIMIT_INFORMATION
;                  |11 - $tagJOBOBJECT_GROUP_INFORMATION
;                  $tJobObjectInfo      - $tagJOBOBJECT_* structure that sets the limit and job state information.
; Return values..: Success              - 1.
;                  Failure              - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ SetInformationJobObject
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_SetInformationJobObject($hJob, $iJobObjectInfoClass, $tJobObjectInfo)

	Local $Ret = DllCall('kernel32.dll', 'int', 'SetInformationJobObject', 'ptr', $hJob, 'int', $iJobObjectInfoClass, 'ptr', DllStructGetPtr($tJobObjectInfo), 'dword', DllStructGetSize($tJobObjectInfo))

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_SetInformationJobObject

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_SetKeyboardLayout
; Description....: Sets an input locale identifier to the specified window.
; Syntax.........: _WinAPI_SetKeyboardLayout ( $hWnd, $iLanguage [, $iFlags] )
; Parameters.....: $hWnd      - Handle to the window to set input locale identifier.
;                  $iLanguage - The name of the input locale identifier (LCID).
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
;                  $iFlags    - The new input locale. This parameter can be one or more of the following values.
;
;                               $INPUTLANGCHANGE_BACKWARD
;                               $INPUTLANGCHANGE_FORWARD
;                               $INPUTLANGCHANGE_SYSCHARSET
;
; Return values..: Success    - 1.
;                  Failure    - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: None
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_SetKeyboardLayout($hWnd, $iLanguage, $iFlags = 0)

	If Not _WinAPI_IsWindow($hWnd) Then
		Return SetError(1, 0, 0)
	EndIf

	Local $hLocale = 0

	If $iLanguage Then
		$hLocale = _WinAPI_LoadKeyboardLayout($iLanguage)
		If @error Then
			Return SetError(1, 0, 0)
		EndIf
	EndIf
	DllCall('user32.dll', 'none', 'SendMessage', 'hwnd', $hWnd, 'uint', 0x0050, 'uint', $iFlags, 'ptr', $hLocale)
	Return 1
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

	If (@error) Or (Not $Ret[0]) Then
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

#cs

Func _WinAPI_SetLayeredWindowAttributes($hWnd, $iRGB, $iAlpha, $iFlags)

	Local $Ret = DllCall('user32.dll', 'int', 'SetLayeredWindowAttributes', 'hwnd', $hWnd, 'long', __RGB($iRGB), 'byte', $iAlpha, 'long', $iFlags)

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_SetLayeredWindowAttributes

#ce

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_SetLocaleInfo
; Description....: Sets an item of information in the user override portion of the current locale.
; Syntax.........: _WinAPI_SetLocaleInfo ( $LCID, $iType, $sData )
; Parameters.....: $LCID   - Locale identifier for which to set information or one of the following predefined values.
;
;                            $LOCALE_CUSTOM_DEFAULT
;                            $LOCALE_CUSTOM_UI_DEFAULT
;                            $LOCALE_CUSTOM_UNSPECIFIED
;
;                            $LOCALE_INVARIANT
;                            $LOCALE_SYSTEM_DEFAULT
;                            $LOCALE_USER_DEFAULT
;
;                  $iType  - Type of locale information to set. This parameter can be one of the $LOCALE_* constants.
;                  $sData  - The string containing the locale information to set. The information must be in the format specific to
;                            the specified constant.
; Return values..: Success - 1.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ SetLocaleInfo
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_SetLocaleInfo($LCID, $iType, $sData)

	Local $Ret = DllCall('kernel32.dll', 'int', 'SetLocaleInfoW', 'long', $LCID, 'dword', $iType, 'wstr', $sData)

    If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
    Return 1
EndFunc   ;==>_WinAPI_SetLocaleInfo

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

	If (@error) Or (Not $Ret[0]) Then
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

	Local $Ret = DllCall('gdi32.dll', 'int', 'SetPixelV', 'hwnd', $hDC, 'int', $iX, 'int', $iY, 'dword', __RGB($iRGB))

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_SetPixel

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_SetPolyFillMode
; Description....: Sets the polygon fill mode for functions that fill polygons.
; Syntax.........: _WinAPI_SetPolyFillMode ( $hDC [, $iMode] )
; Parameters.....: $hDC    - Handle to the device context.
;                  $iMode  - The new fill mode. This parameter can be one of the following values.
;
;                            $ALTERNATE
;                            $WINDING
;
; Return values..: Success - The previous filling mode.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ SetPolyFillMode
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_SetPolyFillMode($hDC, $iMode = 1)

	Local $Ret = DllCall('gdi32.dll', 'int', 'SetPolyFillMode', 'hwnd', $hDC, 'int', $iMode)

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_SetPolyFillMode

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_SetRectRgn
; Description....: Converts a region into a rectangular region with the specified coordinates.
; Syntax.........: _WinAPI_SetRectRgn ( $hRgn, $tRECT )
; Parameters.....: $hRgn   - Handle to the region.
;                  $tRECT  - $tagRECT structure that contains the coordinates of the rectangular region in logical units.
; Return values..: Success - 1.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ SetRectRgn
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_SetRectRgn($hRgn, $tRECT)

	Local $Ret = DllCall('gdi32.dll', 'int', 'SetRectRgn', 'ptr', $hRgn, 'int', DllStructGetData($tRECT, 1), 'int', DllStructGetData($tRECT, 2), 'int', DllStructGetData($tRECT, 3), 'int', DllStructGetData($tRECT, 4))

	If @error Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_SetRectRgn

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
; Return values..: Success - The value that specifies the previous mix mode.
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

	If (@error) Or (Not $Ret[0]) Then
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

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_SetStretchBltMode

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_SetSystemCursor
; Description....: Enables an application to customize the system cursors.
; Syntax.........: _WinAPI_SetSystemCursor ( $hCursor, $ID [, $fCopy] )
; Parameters.....: $hCursor - Handle to a cursor.
;                  $ID      - This parameter specifies the system cursor to replace with the contents of $hCursor, and can be
;                             one of the following values.
;
;                             $OCR_APPSTARTING
;                             $OCR_NORMAL
;                             $OCR_CROSS
;                             $OCR_HAND
;                             $OCR_IBEAM
;                             $OCR_NO
;                             $OCR_SIZEALL
;                             $OCR_SIZENESW
;                             $OCR_SIZENS
;                             $OCR_SIZENWSE
;                             $OCR_SIZEWE
;                             $OCR_UP
;                             $OCR_WAIT
;                             $OCR_ICON
;                             $OCR_SIZE
;
;                  $fCopy   - Specifies whether the cursor should be duplicated, valid values:
;                  |TRUE    - The cursor is duplicated.
;                  |FALSE   - The cursor is not duplicated. (Default)
; Return values..: Success  - 1.
;                  Failure  - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: The function replaces the contents of the system cursor specified by ID with the contents of the cursor handled
;                  by $hCursor. The system destroys hcur by calling the _WinAPI_DestroyCursor() function. Therefore, $hCursor cannot
;                  be a cursor loaded using the _WinAPI_LoadCursor() function. To specify a cursor loaded from a resource, copy the
;                  cursor using the _WinAPI_CopyCursor() function, then pass the copy to _WinAPI_SetSystemCursor().
; Related........:
; Link...........: @@MsdnLink@@ SetSystemCursor
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_SetSystemCursor($hCursor, $ID, $fCopy = 0)

	If $fCopy Then
		$hCursor = _WinAPI_CopyCursor($hCursor)
	EndIf

	Local $Ret = DllCall('user32.dll', 'int', 'SetSystemCursor', 'ptr', $hCursor, 'dword', $ID)

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_SetSystemCursor

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_SetTextAlign
; Description....: Sets the text-alignment flags for the specified device context.
; Syntax.........: _WinAPI_SetTextAlign ($hDC [, $iMode] )
; Parameters.....: $hDC    - Handle to the device context.
;                  $iMode  - The text alignment by using a mask of the values in the following list. Only one flag can be chosen
;                            from those that affect horizontal and vertical alignment. In addition, only one of the two flags that
;                            alter the current position can be chosen.
;
;                            $TA_BASELINE
;                            $TA_BOTTOM
;                            $TA_TOP
;                            $TA_CENTER
;                            $TA_LEFT
;                            $TA_RIGHT
;                            $TA_NOUPDATECP
;                            $TA_RTLREADING
;                            $TA_UPDATECP
;
;                            When the current font has a vertical default base line, as with Kanji, the following values must be
;                            used instead of $TA_BASELINE and $TA_CENTER.
;
;                            $VTA_BASELINE
;                            $VTA_CENTER
;
;                            The default values are $TA_LEFT, $TA_TOP, and $TA_NOUPDATECP.
;
; Return values..: Success - The previous text-alignment setting ($TA_* and $VTA_*).
;                  Failure - (-1) and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ SetTextAlign
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_SetTextAlign($hDC, $iMode = 0)

	Local $Ret = DllCall('gdi32.dll', 'uint', 'SetTextAlign', 'hwnd', $hDC, 'uint', $iMode)

	If (@error) Or ($Ret[0] = 0xFFFFFFFF) Then
		Return SetError(1, 0, -1)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_SetTextAlign

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
; Syntax.........: _WinAPI_SetTimer ( $hWnd, $iTimerID, $iElapse, $pTimerFunc )
; Parameters.....: $hWnd       - Handle to the window to be associated with the timer. This window must be owned by the calling
;                                process. If a 0 value for $hWnd is passed in along with an $iTimerID of an existing timer, that
;                                timer will be replaced in the same way that an existing non-zero $hWnd timer will be.
;                  $iTimerID   - The timer identifier. If the $hWnd parameter is 0, and the $iTimerID does not match an existing
;                                timer then it is ignored and a new timer ID is generated. If the $hWnd parameter is not 0 and
;                                the window specified by $hWnd already has a timer with the value $iTimerID, then the existing
;                                timer is replaced by the new timer. When _WinAPI_SetTimer() replaces a timer, the timer is reset.
;                                Therefore, a message will be sent after the current time-out value elapses, but the previously
;                                set time-out value is ignored. If the call is not intended to replace an existing timer,
;                                $iTimerID should be 0 if the $hWnd is 0.
;                  $iElapse    - The time-out value, in milliseconds.
;                  $pTimerFunc - The address of a callback function to be notified when the time-out value elapses. If this
;                                parameter is 0, the system posts a WM_TIMER message to the application queue.
;
;                                (See MSDN for more information)
;
; Return values..: Success     - The timer identifier. An application can pass this value to the _WinAPI_KillTimer() function to
;                                destroy the timer.
;                  Failure     - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: The timer identifier, $iTimerID, is specific to the associated window. Another window can have its own timer
;                  which has the same identifier as a timer owned by another window. The timers are distinct.
; Related........:
; Link...........: @@MsdnLink@@ SetTimer
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_SetTimer($hWnd, $iTimerID, $iElapse, $pTimerFunc)

	Local $Ret = DllCall('user32.dll', 'uint_ptr', 'SetTimer', 'hwnd', $hWnd, 'uint_ptr', $iTimerID, 'uint', $iElapse, 'ptr', $pTimerFunc)

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_SetTimer

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_SetUDFColorMode
; Description....: Sets the color mode for the WinAPIEx library.
; Syntax.........: _WinAPI_SetUDFColorMode ( $iMode )
; Parameters.....: $iMode - Specifies the color mode, valid values:
;                  |0 - BGR
;                  |1 - RGB
; Return values..: None
; Author.........: Yashied
; Modified.......:
; Remarks........: The functions of this library, in which passes or which returns the color values, works with the values in
;                  accordance with the color mode that been set by this function. Initial color mode is RGB.
; Related........:
; Link...........: None
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_SetUDFColorMode($iMode)
	$__RGB = Not ($iMode = 0)
EndFunc   ;==>_WinAPI_SetUDFColorMode

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

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_SetVolumeMountPoint

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_SetWindowLongEx
; Description....: Changes an attribute of the specified window.
; Syntax.........: _WinAPI_SetWindowLongEx ( $hWnd, $iIndex, $iNewLong )
; Parameters.....: $hWnd     - Handle to the window.
;                  $iIndex   - The zero-based offset to the value to be set. Valid values are in the range zero through the
;                              number of bytes of extra window memory, minus the size of an integer. To set any other value,
;                              specify one of the following values.
;
;                              $GWL_EXSTYLE
;                              $GWL_HINSTANCE
;                              $GWL_ID
;                              $GWL_STYLE
;                              $GWL_USERDATA
;                              $GWL_WNDPROC
;
;                  $iNewLong - The replacement value.
; Return values..: Success   - The previous value.
;                  Failure   - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ SetWindowLong
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_SetWindowLongEx($hWnd, $iIndex, $iNewLong)

	Local $Ret

	If StringInStr(@OSArch, '64') Then
		$Ret = DllCall('user32.dll', 'long_ptr', 'SetWindowLongPtrW', 'hwnd', $hWnd, 'int', $iIndex, 'long_ptr', $iNewLong)
	Else
		$Ret = DllCall('user32.dll', 'long', 'SetWindowLongW', 'hwnd', $hWnd, 'int', $iIndex, 'long', $iNewLong)
	EndIf
	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_SetWindowLongEx

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_SetWindowTheme
; Description....: Causes a window to use a different set of visual style information than its class normally uses.
; Syntax.........: _WinAPI_SetWindowTheme ( $hWnd [, $sName [, $sList]] )
; Parameters.....: $hWnd   - Handle to the window whose visual style information is to be changed.
;                  $sName  - A string that contains the application name. If this parameter is 0, the calling application's name is used.
;                  $sList  - A string that contains a semicolon-separated list of CLSID names to use in place of the actual list
;                            passed by the window's class. If this parameter is 0, the ID list from the calling class is used.
; Return values..: Success - 1.
;                  Failure - 0 and sets the @error flag to non-zero, @extended flag may contain the system error code.
; Author.........: Yashied
; Modified.......:
; Remarks........: The theme manager retains the $sName and the $sList associations through the lifetime of the window, even
;                  if visual styles subsequently change.
;
;                  When $sName and $sList are 0, the theme manager removes the previously applied associations. To prevent visual
;                  styles from being applied to a specified window, pass an empty string ("") which will not match any section
;                  entries.
; Related........:
; Link...........: @@MsdnLink@@ SetWindowTheme
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_SetWindowTheme($hWnd, $sName = 0, $sList = 0)

	Local $TypeOfName = 'wstr', $TypeOfList = 'wstr'

	If Not IsString($sName) Then
		$TypeOfName = 'ptr'
		$sName = 0
	EndIf
	If Not IsString($sList) Then
		$TypeOfList = 'ptr'
		$sList = 0
	EndIf

	Local $Ret = DllCall('uxtheme.dll', 'uint', 'SetWindowTheme', 'hwnd', $hWnd, $TypeOfName, $sName, $TypeOfList, $sList)

	If @error Then
		Return SetError(1, 0, 0)
	Else
		If $Ret[0] Then
			Return SetError(1, $Ret[0], 0)
		EndIf
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_SetWindowTheme

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_ShellAddToRecentDocs
; Description....: Adds a file to the most recently and frequently item list.
; Syntax.........: _WinAPI_ShellAddToRecentDocs ( $sFile )
; Parameters.....: $sFile  - The name of the file to be added. Set this parameter to empty string to clear all usage data on all items.
; Return values..: Success - 1.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ SHAddToRecentDocs
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_ShellAddToRecentDocs($sFile)

	Local $TypeOfFile = 'wstr'

	If StringStripWS($sFile, 3) Then
		$sFile = _WinAPI_PathSearchAndQualify($sFile, 1)
		If Not $sFile Then
			Return SetError(1, 0, 0)
		EndIf
	Else
		$TypeOfFile = 'ptr'
		$sFile = 0
	EndIf
	DllCall('shell32.dll', 'none', 'SHAddToRecentDocs', 'uint', 3, $TypeOfFile, $sFile)
	If @error Then
		Return SetError(2, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_ShellAddToRecentDocs

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_ShellChangeNotify
; Description....: Notifies the system of an event that an application has performed.
; Syntax.........: _WinAPI_ShellChangeNotify ( $iEvent, $iFlags [, $iItem1 [, $iItem2]] )
; Parameters.....: $iEvent - Describes the event that has occurred. Typically, only one event is specified at a time. If more than
;                            one event is specified, the values contained in the $iItem2 and $iItem2 parameters must be the same,
;                            respectively, for all specified events. This parameter can be one or more of the following values.
;
;                            $SHCNE_ALLEVENTS
;                            $SHCNE_ASSOCCHANGED
;                            $SHCNE_ATTRIBUTES
;                            $SHCNE_CREATE
;                            $SHCNE_DELETE
;                            $SHCNE_DRIVEADD
;                            $SHCNE_DRIVEADDGUI
;                            $SHCNE_DRIVEREMOVED
;                            $SHCNE_EXTENDED_EVENT
;                            $SHCNE_FREESPACE
;                            $SHCNE_MEDIAINSERTED
;                            $SHCNE_MEDIAREMOVED
;                            $SHCNE_MKDIR
;                            $SHCNE_NETSHARE
;                            $SHCNE_NETUNSHARE
;                            $SHCNE_RENAMEFOLDER
;                            $SHCNE_RENAMEITEM
;                            $SHCNE_RMDIR
;                            $SHCNE_SERVERDISCONNECT
;                            $SHCNE_UPDATEDIR
;                            $SHCNE_UPDATEIMAGE
;                            $SHCNE_UPDATEITEM
;                            $SHCNE_DISKEVENTS
;                            $SHCNE_GLOBALEVENTS
;                            $SHCNE_INTERRUPT
;
;                            (See MSDN for more information)
;
;                  $iFlags - Flags that indicate the meaning of the $iItem1 and $iItem2 parameters. This parameter must be one
;                            of the following values.
;
;                            $SHCNF_DWORD
;                            $SHCNF_IDLIST
;                            $SHCNF_PATH
;                            $SHCNF_PRINTER
;                            $SHCNF_FLUSH
;                            $SHCNF_FLUSHNOWAIT
;                            $SHCNF_NOTIFYRECURSIVE
;
;                            (See MSDN for more information)
;
;                  $iItem1 - First event-dependent value.
;                  $iItem2 - Second event-dependent value.
; Return values..: Success - 1.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ SHChangeNotify
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_ShellChangeNotify($iEvent, $iFlags, $iItem1 = 0, $iItem2 = 0)

	Local $TypeOfItem1 = 'dword_ptr', $TypeOfItem2 = 'dword_ptr'

	If IsString($iItem1) Then
		$TypeOfItem1 = 'wstr'
	EndIf
	If IsString($iItem2) Then
		$TypeOfItem2 = 'wstr'
	EndIf
	DllCall('shell32.dll', 'none', 'SHChangeNotify', 'long', $iEvent, 'uint', $iFlags, $TypeOfItem1, $iItem1, $TypeOfItem2, $iItem2)
	If @error Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_ShellChangeNotify

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_ShellChangeNotifyDeregister
; Description....: Unregisters the client's window.
; Syntax.........: _WinAPI_ShellChangeNotifyDeregister ( $ID )
; Parameters.....: $ID     - The value that specifies the registration ID returned by _WinAPI_ShellChangeNotifyRegister().
; Return values..: Success - 1.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ SHChangeNotifyDeregister
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_ShellChangeNotifyDeregister($ID)

	Local $Ret = DllCall('shell32.dll', 'int', 'SHChangeNotifyDeregister', 'ulong', $ID)

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_ShellChangeNotifyDeregister

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_ShellChangeNotifyRegister
; Description....: Registers a window to receive notifications from the file system or Shell.
; Syntax.........: _WinAPI_ShellChangeNotifyRegister ( $hWnd, $iMsg, $iEvents, $iSources, $aPaths [, $fRecursive] )
; Parameters.....: $hWnd       - Handle to the window that receives the change or notification messages.
;                  $iMsg       - Message to be posted to the window procedure.
;                  $iEvents    - Change notification events for which to receive notification. This parameter can be one or more
;                                of the $SHCNE_* values.
;                  $iSources   - One or more of the following values that indicate the type of events for which to receive
;                                notifications.
;
;                                $SHCNRF_INTERRUPTLEVEL
;                                $SHCNRF_SHELLLEVEL
;                                $SHCNRF_RECURSIVEINTERRUPT
;                                $SHCNRF_NEWDELIVERY
;
;                  $aPaths     - Single path or array of paths for which to receive notifications. These names should be
;                                fully-qualified paths to prevent unexpected results.
;                  $fRecursive - Specifies whether to post notifications for children paths in $aPaths parameter, valid values:
;                  |TRUE       - Notifications would come from the folder's children.
;                  |FALSE      - Notifications would come from the specified folder's only. (Default)
; Return values..: Success     - The registration ID.
;                  Failure     - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: When a change notification event is raised, the message indicated by $iMsg is delivered to the window specified
;                  by the $hWnd parameter. (See example)
;
;                  For performance reasons, multiple notifications can be combined into a single notification. For example,
;                  if a large number of $SHCNE_UPDATEITEM notifications are generated for files in the same folder, they can be
;                  joined into a single $SHCNE_UPDATEDIR notification.
; Related........:
; Link...........: @@MsdnLink@@ SHChangeNotifyRegister
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_ShellChangeNotifyRegister($hWnd, $iMsg, $iEvents, $iSources, $aPaths, $fRecursive = 0)

	Local $tEntry, $Path = $aPaths, $Struct = ''

	If IsArray($aPaths) Then
		If UBound($aPaths, 2) Then
			Return SetError(1, 0, 0)
		EndIf
	Else
		Dim $aPaths[1] = [$Path]
	EndIf
	For $i = 0 To UBound($aPaths) - 1
		If Not _WinAPI_PathIsDirectory($aPaths[$i]) Then
			Return SetError(1, 0, 0)
		EndIf
	Next
	For $i = 0 To UBound($aPaths) - 1
		$Struct &= 'ptr;int;'
	Next
	$tEntry = DllStructCreate($Struct)
	For $i = 0 To UBound($aPaths) - 1
		$aPaths[$i] = _WinAPI_ShellILCreateFromPath(_WinAPI_PathSearchAndQualify($aPaths[$i]))
		DllStructSetData($tEntry, 2 * $i + 1, $aPaths[$i])
		DllStructSetData($tEntry, 2 * $i + 2, $fRecursive)
	Next

	Local $Ret = DllCall('shell32.dll', 'ulong', 'SHChangeNotifyRegister', 'hwnd', $hWnd, 'int', $iSources, 'long', $iEvents, 'uint', $iMsg, 'int', UBound($aPaths), 'ptr', DllStructGetPtr($tEntry))

	If (Not @error) And ($Ret[0]) Then
		$Ret = $Ret[0]
	Else
		$Ret = 0
	EndIf
	For $i = 0 To UBound($aPaths) - 1
		_WinAPI_CoTaskMemFree($aPaths[$i])
	Next
	Return SetError(Number($Ret = 0), 0, $Ret)
EndFunc   ;==>_WinAPI_ShellChangeNotifyRegister

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_ShellEmptyRecycleBin
; Description....: Empties the Recycle Bin on the specified drive.
; Syntax.........: _WinAPI_ShellEmptyRecycleBin ( $sRoot [, $iFlags [, $hParent]] )
; Parameters.....: $sRoot   - The string that contains the path of the root drive on which the Recycle Bin is located. This string
;                             can be formatted with the drive, folder, and subfolder names, for example "c:\windows\system\".
;                             If this parameter is empty string, all Recycle Bins on all drives will be emptied.
;                  $iFlags  - This parameter can be one or more of the following values.
;
;                             $SHERB_NOCONFIRMATION
;                             $SHERB_NOPROGRESSUI
;                             $SHERB_NOSOUND
;                             $SHERB_NO_UI
;
;                  $hParent - Handle to the parent window of any dialog boxes that might be displayed during the operation.
; Return values..: Success  - 1.
;                  Failure  - 0 and sets the @error flag to non-zero, @extended flag may contain the system error code.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ SHEmptyRecycleBin
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_ShellEmptyRecycleBin($sRoot, $iFlags = 0, $hParent = 0)

	Local $Ret = DllCall('shell32.dll', 'uint', 'SHEmptyRecycleBinW', 'hwnd', $hParent, 'wstr', $sRoot, 'dword', $iFlags)

	If @error Then
		Return SetError(1, 0, 0)
	Else
		If $Ret[0] Then
			Return SetError(1, $Ret[0], 0)
		EndIf
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_ShellEmptyRecycleBin

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_ShellExtractAssociatedIcon
; Description....: Returns a handle to the icon that associated with the specified file's.
; Syntax.........: _WinAPI_ShellExtractAssociatedIcon ( $sFile [, $fSmall] )
; Parameters.....: $sFile  - The full path and file name of the file that contains the icon, or its extension, such as ".txt".
;                  $fSmall - Specifies whether extracts a small icon, valid values:
;                  |TRUE   - Extracts a small icon.
;                  |FALSE  - Extracts a large icon. (Default)
; Return values..: Success - The icon handle.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: None
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_ShellExtractAssociatedIcon($sFile, $fSmall = 0)

	Local $Flag = BitOR($SHGFI_ICON, $SHGFI_USEFILEATTRIBUTES)

	If $fSmall Then
		$Flag = BitOR($Flag, $SHGFI_SMALLICON)
	EndIf

	Local $tSHFILEINFO = DllStructCreate($tagSHFILEINFO)

	If Not _WinAPI_ShellGetFileInfo($sFile, $Flag, 0, $tSHFILEINFO) Then
		Return SetError(1, 0, 0)
	EndIf
	Return DllStructGetData($tSHFILEINFO, 'hIcon')
EndFunc   ;==>_WinAPI_ShellExtractAssociatedIcon

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_ShellExtractIcon
; Description....: Extracts the icon with the specified dimension from the specified file.
; Syntax.........: _WinAPI_ShellExtractIcon ( $sIcon, $iIndex, $iWidth, $iHeight )
; Parameters.....: $sIcon   - Path and name of the file from which the icon are to be extracted.
;                  $iIndex  - Index of the icon to extract.
;                  $iWidth  - Horizontal icon size wanted.
;                  $iHeight - Vertical icon size wanted.
; Return values..: Success  - Handle to the extracted icon.
;                  Failure  - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: If the icon with the specified dimension is not found in the file, it will choose the nearest appropriate icon and
;                  change to the specified dimension. When you are finished using the icon, destroy it using the _WinAPI_DestroyIcon()
;                  function.
; Related........:
; Link...........: @@MsdnLink@@ SHExtractIcons
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_ShellExtractIcon($sIcon, $iIndex, $iWidth, $iHeight)

	Local $Ret = DllCall('shell32.dll', 'int', 'SHExtractIconsW', 'wstr', $sIcon, 'int', $iIndex, 'int', $iWidth, 'int', $iHeight, 'ptr*', 0, 'ptr*', 0, 'int', 1, 'int', 0)

	If (@error) Or (Not $Ret[0]) Or (Not $Ret[5]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[5]
EndFunc   ;==>_WinAPI_ShellExtractIcon

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_ShellFileOperation
; Description....: Copies, moves, renames, or deletes a file system object.
; Syntax.........: _WinAPI_ShellFileOperation ( $sFrom, $sTo, $iFunc, $iFlags [, $sTitle [, $hParent]] )
; Parameters.....: $sFrom   - Single string or array of string that contains the source file name(s). These names should be
;                             fully-qualified paths to prevent unexpected results.
;                  $sTo     - Single string or array of string that contains the destination file or directory name(s) (if used).
;                             These names should be fully-qualified paths to prevent unexpected results.
;                  $iFunc   - A value that indicates which operation to perform. This parameter can be one of the following values.
;
;                             $FO_COPY
;                             $FO_DELETE
;                             $FO_MOVE
;                             $FO_RENAME
;
;                  $iFlags  - Flags that control the file operation. This parameter can be one of the following values.
;
;                             $FOF_ALLOWUNDO
;                             $FOF_CONFIRMMOUSE
;                             $FOF_FILESONLY
;                             $FOF_MULTIDESTFILES
;                             $FOF_NOCONFIRMATION
;                             $FOF_NOCONFIRMMKDIR
;                             $FOF_NO_CONNECTED_ELEMENTS
;                             $FOF_NOCOPYSECURITYATTRIBS
;                             $FOF_NOERRORUI
;                             $FOF_NORECURSEREPARSE
;                             $FOF_NORECURSION
;                             $FOF_RENAMEONCOLLISION
;                             $FOF_SILENT
;                             $FOF_SIMPLEPROGRESS
;                             $FOF_WANTMAPPINGHANDLE
;                             $FOF_WANTNUKEWARNING
;                             $FOF_NO_UI
;
;                  $sTitle  - The title of a progress dialog box. This parameter is used only if $iFlags includes the $FOF_SIMPLEPROGRESS flag.
;                  $hParent - Handle to the dialog box to display information about the status of the file operation.
; Return values..: Success  - $tagSHFILEOPSTRUCT structure that contains the additional information.
;                  Failure  - 0 and sets the @error flag to the one of the following values.
;
;                              -1 - AutoIt inherent error.
;                             113 - The source and destination files are the same file.
;                             114 - Multiple file paths were specified in the source buffer, but only one destination file path.
;                             115 - Rename operation was specified but the destination path is a different directory. Use the move operation instead.
;                             116 - The source is a root directory, which cannot be moved or renamed.
;                             117 - The operation was cancelled by the user, or silently cancelled if the appropriate flags were supplied to _WinAPI_ShellFileOperation().
;                             118 - The destination is a subtree of the source.
;                             120 - Security settings denied access to the source.
;                             121 - The source or destination path exceeded or would exceed MAX_PATH.
;                             122 - The operation involved multiple destination paths, which can fail in the case of a move operation.
;                             124 - The path in the source or destination or both was invalid.
;                             125 - The source and destination have the same parent folder.
;                             126 - The destination path is an existing file.
;                             128 - The destination path is an existing folder.
;                             129 - The name of the file exceeds MAX_PATH.
;                             130 - The destination is a read-only CD-ROM, possibly unformatted.
;                             131 - The destination is a read-only DVD, possibly unformatted.
;                             132 - The destination is a writable CD-ROM, possibly unformatted.
;                             133 - The file involved in the operation is too large for the destination media or file system.
;                             134 - The source is a read-only CD-ROM, possibly unformatted.
;                             135 - The source is a read-only DVD, possibly unformatted.
;                             136 - The source is a writable CD-ROM, possibly unformatted.
;                             183 - MAX_PATH was exceeded during the operation.
;                            1026 - An unknown error occurred. This is typically due to an invalid path in the source or destination.
;                           65536 - An unspecified error occurred on the destination.
;                           65652 - Destination is a root directory and cannot be renamed.
;
; Author.........: Yashied
; Modified.......:
; Remarks........: You should use fully-qualified path names with this function. Using it with relative path names is not thread safe.
; Related........:
; Link...........: @@MsdnLink@@ SHFileOperation
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_ShellFileOperation($sFrom, $sTo, $iFunc, $iFlags, $sTitle = '', $hParent = 0)

	Local $tFrom, $tTo, $Data

	If Not IsArray($sFrom) Then
		$Data = $sFrom
		Dim $sFrom[1] = [$Data]
	EndIf
	$tFrom = _WinAPI_ArrayToStruct($sFrom)
	If @error Then
		Return SetError(-1, 0, 0)
	EndIf
	If Not IsArray($sTo) Then
		$Data = $sTo
		Dim $sTo[1] = [$Data]
	EndIf
	$tTo = _WinAPI_ArrayToStruct($sTo)
	If @error Then
		Return SetError(-1, 0, 0)
	EndIf

	Local $tSHFILEOPSTRUCT = DllStructCreate($tagSHFILEOPSTRUCT)

	DllStructSetData($tSHFILEOPSTRUCT, 'hWnd', $hParent)
	DllStructSetData($tSHFILEOPSTRUCT, 'Func', $iFunc)
	DllStructSetData($tSHFILEOPSTRUCT, 'From', DllStructGetPtr($tFrom))
	DllStructSetData($tSHFILEOPSTRUCT, 'To', DllStructGetPtr($tTo))
	DllStructSetData($tSHFILEOPSTRUCT, 'Flags', $iFlags)
	DllStructSetData($tSHFILEOPSTRUCT, 'ProgressTitle', $sTitle)

	Local $Ret = DllCall('shell32.dll', 'int', 'SHFileOperationW', 'ptr', DllStructGetPtr($tSHFILEOPSTRUCT))

	If @error Then
		Return SetError(-1, 0, 0)
	Else
		If $Ret[0] Then
			Return SetError($Ret[0], 0, 0)
		EndIf
	EndIf
	Return $tSHFILEOPSTRUCT
EndFunc   ;==>_WinAPI_ShellFileOperation

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_ShellGetFileInfo
; Description....: Retrieves information about an object in the file system.
; Syntax.........: _WinAPI_ShellGetFileInfo ( $sPath, $iFlags, $iAttributes, ByRef $tSHFILEINFO )
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
;                  $iAttributes - A combination of one or more file attribute flags ($FILE_ATTRIBUTE_*).
;                  $tSHFILEINFO - $tagSHFILEINFO structure to receive the file information.
; Return values..: Success      - If $iFlags contains the $SHGFI_EXETYPE flag, return type of the executable file. If $iFlags contains the
;                                 $SHGFI_SYSICONINDEX flag, return handle to the system image list. Otherwise - 1.
;                  Failure      - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: If this function returns an icon handle in the hIcon member of the $tagSHFILEINFO structure, you are responsible
;                  for freeing it with _WinAPI_DestroyIcon() when you no longer need it.
; Related........:
; Link...........: @@MsdnLink@@ SHGetFileInfo
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_ShellGetFileInfo($sPath, $iFlags, $iAttributes, ByRef $tSHFILEINFO)

	Local $Ret = DllCall('shell32.dll', 'dword_ptr', 'SHGetFileInfoW', 'wstr', $sPath, 'dword', $iAttributes, 'ptr', DllStructGetPtr($tSHFILEINFO), 'uint', DllStructGetSize($tSHFILEINFO), 'uint', $iFlags)

	If @error Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_ShellGetFileInfo

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_ShellGetKnownFolderPath
; Description....: Retrieves the full path of a known folder identified.
; Syntax.........: _WinAPI_ShellGetKnownFolderPath ( $GUID [, $iFlags [, $hToken]] )
; Parameters.....: $GUID   - The GUID ($FOLDERID_*) that identifies the standard folders registered with the system.
;                  $iFlags - The flags that specify special retrieval options. This parameter can be one or more of the following values.
;
;                            $KF_FLAG_CREATE
;                            $KF_FLAG_DONT_VERIFY
;                            $KF_FLAG_DONT_UNEXPAND
;                            $KF_FLAG_NO_ALIAS
;                            $KF_FLAG_INIT
;                            $KF_FLAG_DEFAULT_PATH
;                            $KF_FLAG_NOT_PARENT_RELATIVE
;                            $KF_FLAG_SIMPLE_IDLIST
;
;                            *Windows 7 or later
;
;                            $KF_FLAG_ALIAS_ONLY
;
;                  $hToken - The access token that represents a particular user. If this parameter is 0, the function requests
;                            the known folder for the current user. Assigning the $hToken parameter a value of (-1) indicates the
;                            Default User. Note that access to the Default User folders requires administrator privileges.
; Return values..: Success - The path of the known folder.
;                  Failure - Empty string and sets the @error flag to non-zero, @extended flag may contain the system error code.
; Author.........: Yashied
; Modified.......:
; Remarks........: This function requires Windows Vista or later.
; Related........:
; Link...........: @@MsdnLink@@ SHGetKnownFolderPath
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_ShellGetKnownFolderPath($GUID, $iFlags = 0, $hToken = 0)

	Local $Ret, $Result, $tGUID, $tData

	$tGUID = DllStructCreate($tagGUID)
	$Ret = DllCall('ole32.dll', 'uint', 'CLSIDFromString', 'wstr', $GUID, 'ptr', DllStructGetPtr($tGUID))
	If (@error) Or ($Ret[0]) Then
		Return SetError(1, 0, '')
	EndIf
	$Ret  = DllCall('shell32.dll', 'uint', 'SHGetKnownFolderPath', 'ptr', DllStructGetPtr($tGUID), 'dword', $iFlags, 'ptr', $hToken, 'ptr*', 0)
	If @error Then
		Return SetError(1, 0, '')
	Else
		If $Ret[0] Then
			Return SetError(1, $Ret[0], '')
		EndIf
	EndIf
	$tData = DllStructCreate('wchar[' & (_WinAPI_StrLen($Ret[4]) + 1) & ']', $Ret[4])
	$Result = DllStructGetData($tData, 1)
	_WinAPI_CoTaskMemFree($Ret[4])
	Return $Result
EndFunc   ;==>_WinAPI_ShellGetKnownFolderPath

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_ShellGetPathFromIDList
; Description....: Converts an item identifier list to a file system path.
; Syntax.........: _WinAPI_ShellGetPathFromIDList ( $PIDL )
; Parameters.....: $PIDL   - The address of an item identifier list that specifies a file or directory location relative to the
;                            root of the namespace (the desktop).
; Return values..: Success - The file system path.
;                  Failure - Empty string and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ SHGetPathFromIDList
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_ShellGetPathFromIDList($PIDL)

	Local $tData = DllStructCreate('wchar[1024]')
	Local $Ret = DllCall('shell32.dll', 'int', 'SHGetPathFromIDListW', 'ptr', $PIDL, 'ptr', DllStructGetPtr($tData))

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, '')
	EndIf
	Return DllStructGetData($tData, 1)
EndFunc   ;==>_WinAPI_ShellGetPathFromIDList

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_ShellGetSetFolderCustomSettings
; Description....: Sets or retrieves custom folder settings.
; Syntax.........: _WinAPI_ShellGetSetFolderCustomSettings ( $sPath, $iFlag, ByRef $tSHFCS )
; Parameters.....: $sPath  - The path to the folder.
;                  $iFlag  - A flag controlling the action of the function. It may be one of the following values.
;
;                            $FCS_READ
;                            $FCS_FORCEWRITE
;                            $FCS_WRITE
;
;                  $tSHFCS - $tagSHFOLDERCUSTOMSETTINGS structure that provides or receives the custom folder settings.
; Return values..: Success - 1.
;                  Failure - 0 and sets the @error flag to non-zero, @extended flag may contain the system error code.
; Author.........: Yashied
; Modified.......:
; Remarks........: This function reads from and writes to Desktop.ini.
; Related........:
; Link...........: @@MsdnLink@@ SHGetSetFolderCustomSettings
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_ShellGetSetFolderCustomSettings($sPath, $iFlag, ByRef $tSHFCS)

	Local $Proc = 'SHGetSetFolderCustomSettings'

	If _WinAPI_GetVersion() < '6.0' Then
		$Proc &= 'W'
	EndIf

	Local $Ret = DllCall('shell32.dll', 'uint', $Proc, 'ptr', DllStructGetPtr($tSHFCS), 'wstr', $sPath, 'dword', $iFlag)

	If @error Then
		Return SetError(1, 0, 0)
	Else
		If $Ret[0] Then
			Return SetError(1, $Ret[0], 0)
		EndIf
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_ShellGetSetFolderCustomSettings

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_ShellGetSettings
; Description....: Retrieves Shell state settings.
; Syntax.........: _WinAPI_ShellGetSettings ( $iFlags )
; Parameters.....: $iFlags - The flags that indicate which settings should be retrieved. This parameter can be one or
;                            more of the following values (use ONLY this flags).
;
;                            $SSF_SHOWALLOBJECTS
;                            $SSF_SHOWEXTENSIONS
;                            $SSF_SHOWCOMPCOLOR
;                            $SSF_SHOWSYSFILES
;                            $SSF_DOUBLECLICKINWEBVIEW
;                            $SSF_DESKTOPHTML
;                            $SSF_WIN95CLASSIC
;                            $SSF_DONTPRETTYPATH
;                            $SSF_MAPNETDRVBUTTON
;                            $SSF_SHOWINFOTIP
;                            $SSF_HIDEICONS
;                            $SSF_NOCONFIRMRECYCLE
;                            $SSF_WEBVIEW
;                            $SSF_SHOWSUPERHIDDEN
;                            $SSF_SEPPROCESS
;                            $SSF_NONETCRAWLING
;                            $SSF_STARTPANELON
;
;                            *Windows Vista or later
;
;                            $SSF_AUTOCHECKSELECT
;                            $SSF_ICONSONLY
;                            $SSF_SHOWTYPEOVERLAY
;
; Return values..: Success - The value that contains a combination of flags specified in the $iFlags parameter. If flag is set,
;                            appropriate setting is enabled, otherwise disabled. The function checks only flags that were
;                            specified in the $iFlags parameter.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ SHGetSetSettings
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_ShellGetSettings($iFlags)

	Local $tSHELLSTATE = DllStructCreate('uint[8]')

	DllCall('shell32.dll', 'none', 'SHGetSetSettings', 'ptr', DllStructGetPtr($tSHELLSTATE), 'dword', $iFlags, 'int', 0)
	If @error Then
		Return SetError(1, 0, 0)
	EndIf

	Local $Val1 = DllStructGetData($tSHELLSTATE, 1, 1)
	Local $Val2 = DllStructGetData($tSHELLSTATE, 1, 8)
	Local $Result = 0

	If BitAND($Val1, 0x00000001) Then
		$Result += $SSF_SHOWALLOBJECTS
	EndIf
	If BitAND($Val1, 0x00000002) Then
		$Result += $SSF_SHOWEXTENSIONS
	EndIf
	If BitAND($Val1, 0x00000004) Then
		$Result += $SSF_NOCONFIRMRECYCLE
	EndIf
	If BitAND($Val1, 0x00000008) Then
		$Result += $SSF_SHOWSYSFILES
	EndIf
	If BitAND($Val1, 0x00000010) Then
		$Result += $SSF_SHOWCOMPCOLOR
	EndIf
	If BitAND($Val1, 0x00000020) Then
		$Result += $SSF_DOUBLECLICKINWEBVIEW
	EndIf
	If BitAND($Val1, 0x00000040) Then
		$Result += $SSF_DESKTOPHTML
	EndIf
	If BitAND($Val1, 0x00000080) Then
		$Result += $SSF_WIN95CLASSIC
	EndIf
	If BitAND($Val1, 0x00000100) Then
		$Result += $SSF_DONTPRETTYPATH
	EndIf
	If BitAND($Val1, 0x00000400) Then
		$Result += $SSF_MAPNETDRVBUTTON
	EndIf
	If BitAND($Val1, 0x00000800) Then
		$Result += $SSF_SHOWINFOTIP
	EndIf
	If BitAND($Val1, 0x00001000) Then
		$Result += $SSF_HIDEICONS
	EndIf
	If BitAND($Val1, 0x00002000) Then
		$Result += $SSF_WEBVIEW
	EndIf
	If BitAND($Val1, 0x00008000) Then
		$Result += $SSF_SHOWSUPERHIDDEN
	EndIf
	If BitAND($Val1, 0x00010000) Then
		$Result += $SSF_NONETCRAWLING
	EndIf
	If BitAND($Val2, 0x00000001) Then
		$Result += $SSF_SEPPROCESS
	EndIf
	If BitAND($Val2, 0x00000002) Then
		$Result += $SSF_STARTPANELON
	EndIf
	If BitAND($Val2, 0x00000008) Then
		$Result += $SSF_AUTOCHECKSELECT
	EndIf
	If BitAND($Val2, 0x00000010) Then
		$Result += $SSF_ICONSONLY
	EndIf
	If BitAND($Val2, 0x00000020) Then
		$Result += $SSF_SHOWTYPEOVERLAY
	EndIf
	Return $Result
EndFunc   ;==>_WinAPI_ShellGetSettings

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_ShellGetSpecialFolderLocation
; Description....: Retrieves a PIDL structure of a special folder.
; Syntax.........: _WinAPI_ShellGetSpecialFolderLocation ( $CSIDL )
; Parameters.....: $CSIDL  - The CSIDL ($CSIDL_*) that identifies the folder of interest.
; Return values..: Success - The PIDL specifying the folder's location relative to the root of the namespace (the desktop).
;                  Failure - 0 and sets the @error flag to non-zero, @extended flag may contain the system error code.
; Author.........: Yashied
; Modified.......:
; Remarks........: To free the returned PIDL, call the _WinAPI_CoTaskMemFree() function.
; Related........:
; Link...........: @@MsdnLink@@ SHGetSpecialFolderLocation
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_ShellGetSpecialFolderLocation($CSIDL)

	Local $Ret = DllCall('shell32.dll', 'uint', 'SHGetSpecialFolderLocation', 'hwnd', 0, 'int', $CSIDL, 'ptr*', 0)

	If @error Then
		Return SetError(1, 0, 0)
	Else
		If $Ret[0] Then
			Return SetError(1, $Ret[0], 0)
		EndIf
	EndIf
	Return $Ret[3]
EndFunc   ;==>_WinAPI_ShellGetSpecialFolderLocation

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_ShellGetSpecialFolderPath
; Description....: Retrieves the path of a special folder.
; Syntax.........: _WinAPI_ShellGetSpecialFolderPath ( $CSIDL [, $fCreate] )
; Parameters.....: $CSIDL   - The CSIDL ($CSIDL_*) that identifies the folder of interest.
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

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, '')
	EndIf
	Return DllStructGetData($tPath, 1)
EndFunc   ;==>_WinAPI_ShellGetSpecialFolderPath

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_ShellGetStockIconInfo
; Description....: Retrieves information about system-defined Shell icons.
; Syntax.........: _WinAPI_ShellGetStockIconInfo ( $SIID, $iFlags )
; Parameters.....: $SIID   - One of the $SIID_* constants that specifies which icon should be retrieved.
;                  $iFlags - The flags that specify which information is requested. This parameter can be a combination of the
;                            following values.
;
;                            $SHGSI_ICONLOCATION
;                            $SHGSI_ICON
;                            $SHGSI_SYSICONINDEX
;                            $SHGSI_LINKOVERLAY
;                            $SHGSI_SELECTED
;                            $SHGSI_LARGEICON
;                            $SHGSI_SMALLICON
;                            $SHGSI_SHELLICONSIZE
;
; Return values..: Success - $tagSHSTOCKICONINFO structure that contains the requested information.
;                  Failure - 0 and sets the @error flag to non-zero, @extended flag may contain the system error code.
; Author.........: Yashied
; Modified.......:
; Remarks........: If this function returns an icon handle in the "hIcon" member of the $tagSHSTOCKICONINFO structure, you are
;                  responsible for freeing the icon with _WinAPI_DestroyIcon() when you no longer need it.
;
;                  This function requires Windows Vista or later.
; Related........:
; Link...........: @@MsdnLink@@ SHGetStockIconInfo
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_ShellGetStockIconInfo($SIID, $iFlags)

	Local $tSHSTOCKICONINFO = DllStructCreate($tagSHSTOCKICONINFO)

	DllStructSetData($tSHSTOCKICONINFO, 'Size', DllStructGetSize($tSHSTOCKICONINFO))

	Local $Ret = DllCall('shell32.dll', 'uint', 'SHGetStockIconInfo', 'int', $SIID, 'uint', $iFlags, 'ptr', DllStructGetPtr($tSHSTOCKICONINFO))

	If @error Then
		Return SetError(1, 0, 0)
	Else
		If $Ret[0] Then
			Return SetError(1, $Ret[0], 0)
		EndIf
	EndIf
	Return $tSHSTOCKICONINFO
EndFunc   ;==>_WinAPI_ShellGetStockIconInfo

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_ShellILCreateFromPath
; Description....: Creates a pointer to an item identifier list (PIDL) from a path.
; Syntax.........: _WinAPI_ShellILCreateFromPath ( $sPath )
; Parameters.....: $sPath  - The path to be converted.
; Return values..: Success - The path in $sPath expressed as a PIDL.
;                  Failure - 0 and sets the @error flag to non-zero, @extended flag may contain the system error code.
; Author.........: Yashied
; Modified.......:
; Remarks........: To free the returned PIDL, call the _WinAPI_CoTaskMemFree() function.
; Related........:
; Link...........: @@MsdnLink@@ SHILCreateFromPath
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_ShellILCreateFromPath($sPath)

	Local $Ret = DllCall('shell32.dll', 'uint', 'SHILCreateFromPath', 'wstr', $sPath, 'ptr*', 0, 'dword*', 0)

	If @error Then
		Return SetError(1, 0, 0)
	Else
		If $Ret[0] Then
			Return SetError(1, $Ret[0], 0)
		EndIf
	EndIf
	Return $Ret[2]
EndFunc   ;==>_WinAPI_ShellILCreateFromPath

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

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_ShellNotifyIcon

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_ShellObjectProperties
; Description....: Invokes the Properties context menu command on a Shell object.
; Syntax.........: _WinAPI_ShellObjectProperties ( $sPath [, $iType [, $sProperty [, $hParent]]] )
; Parameters.....: $sPath     - The object name.
;                  $iType     - The value that specifies the type of object.
;
;                               $SHOP_PRINTERNAME
;                               $SHOP_FILEPATH
;                               $SHOP_VOLUMEGUID
;
;                  $sProperty - The name of the property sheet page to be opened initially.
;                  $hParent   - Handle of the parent window of the dialog box.
; Return values..: Success    - 1.
;                  Failure    - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ SHObjectProperties
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_ShellObjectProperties($sPath, $iType = 2, $sProperty = '', $hParent = 0)

	Local $TypeOfProperty = 'wstr'

	If Not StringStripWS($sProperty, 3) Then
		$TypeOfProperty = 'ptr'
		$sProperty = 0
	EndIf

	Local $Ret = DllCall('shell32.dll', 'int', 'SHObjectProperties', 'hwnd', $hParent, 'dword', $iType, 'wstr', $sPath, $TypeOfProperty, $sProperty)

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_ShellObjectProperties

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_ShellOpenFolderAndSelectItems
; Description....: Opens a Windows Explorer window with specified items in a particular folder selected.
; Syntax.........: _WinAPI_ShellOpenFolderAndSelectItems ( $sPath [, $aNames [, $iStart [, $iEnd [, $iFlags]]]] )
; Parameters.....: $sPath  - The fully qualified path that specifies the folder or file. If $aNames parameter is used, $sPath should
;                            specified only to a folder, otherwise, the function fails. This parameter can be an empty string.
;                  $aNames - The array of the folder or file names to be selected. It should be just names inside the folder.
;                  $iStart - The index of array to start selecting at.
;                  $iEnd   - The index of array to stop selecting at.
;                  $iFlags - The optional flags. This parameter can be one or more of the following values.
;
;                            *Windows Vista or later
;
;                            $OFASI_EDIT
;                            $OFASI_OPENDESKTOP
;
; Return values..: Success - 1.
;                  Failure - 0 and sets the @error flag to non-zero, @extended flag may contain the system error code.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ SHOpenFolderAndSelectItems
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_ShellOpenFolderAndSelectItems($sPath, $aNames = 0, $iStart = 0, $iEnd = -1, $iFlags = 0)

	$sPath = StringRegExpReplace(_WinAPI_PathSearchAndQualify($sPath), '\\*\Z', '')
	If $sPath Then
		If (IsArray($aNames)) And (Not _WinAPI_PathIsDirectory($sPath)) Then
			Return SetError(1, 0, 0)
		EndIf
	EndIf

	Local $PIDL = _WinAPI_ShellILCreateFromPath($sPath)

	If @error Then
		Return SetError(1, 0, 0)
	EndIf

	Local $sNames = '', $tNames = 0, $Ret, $Count = 0

	If IsArray($aNames) Then
		If $iStart < 0 Then
			$iStart = 0
		EndIf
		If ($iEnd < 0) Or ($iEnd > UBound($aNames) - 1) Then
			$iEnd = UBound($aNames) - 1
		EndIf
		For $i = $iStart To $iEnd
			$sNames &= 'ptr;'
		Next
		$tNames = DllStructCreate($sNames)
		If @error Then

		EndIf
		For $i = $iStart To $iEnd
			$Count += 1
			If $aNames[$i] Then
				DLLStructSetData($tNames, $Count, _WinAPI_ShellILCreateFromPath($sPath & '\' & $aNames[$i]))
			Else
				DLLStructSetData($tNames, $Count, 0)
			EndIf
		Next
	EndIf
	_WinAPI_CoInitialize()
	$Ret = DllCall('shell32.dll', 'uint', 'SHOpenFolderAndSelectItems', 'ptr', $PIDL, 'uint', $Count, 'ptr', DllStructGetPtr($tNames), 'dword', $iFlags)
	If @error Then
		$Ret = 0
	Else
		If $Ret[0] Then
			$Ret = $Ret[0]
		EndIf
	EndIf
	_WinAPI_CoUninitialize()
	_WinAPI_CoTaskMemFree($PIDL)
	For $i = 1 To $Count
		$PIDL = DllStructGetData($tNames, $i)
		If $PIDL Then
			_WinAPI_CoTaskMemFree($PIDL)
		EndIf
	Next
	If Not IsArray($Ret) Then
		Return SetError(1, $Ret, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_ShellOpenFolderAndSelectItems

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_ShellOpenWithDlg
; Description....: Displays the Open With dialog box.
; Syntax.........: _WinAPI_ShellOpenWithDlg ( $sFile [, $iFlags [, $hParent]] )
; Parameters.....: $sFile   - The file name.
;                  $iFlags  - The characteristics of the Open With dialog box. This parameter can be one or more of the following values.
;
;                             $OAIF_ALLOW_REGISTRATION
;                             $OAIF_REGISTER_EXT
;                             $OAIF_EXEC
;                             $OAIF_FORCE_REGISTRATION
;                             $OAIF_HIDE_REGISTRATION
;                             $OAIF_URL_PROTOCOL
;
;                  $hParent - Handle of the parent window.
; Return values..: Success  - 1.
;                  Failure  - 0 and sets the @error flag to non-zero, @extended flag may contain the system error code.
; Author.........: Yashied
; Modified.......:
; Remarks........: This function requires Windows Vista or later.
; Related........:
; Link...........: @@MsdnLink@@ SHOpenWithDialog
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_ShellOpenWithDlg($sFile, $iFlags = 0, $hParent = 0)

	Local $tData = DllStructCreate('wchar[1024]')
	Local $tOPENASINFO = DllStructCreate('ptr;ptr;dword')

	DllStructSetData($tData, 1, $sFile)
	DllStructSetData($tOPENASINFO, 1, DllStructGetPtr($tData))
	DllStructSetData($tOPENASINFO, 2, 0)
	DllStructSetData($tOPENASINFO, 3, $iFlags)

	Local $Ret = DllCall('shell32.dll', 'uint', 'SHOpenWithDialog', 'hwnd', $hParent, 'ptr', DllStructGetPtr($tOPENASINFO))

	If @error Then
		Return SetError(1, 0, 0)
	Else
		If $Ret[0] Then
			Return SetError(1, $Ret[0], 0)
		EndIf
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_ShellOpenWithDlg

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_ShellQueryRecycleBin
; Description....: Retrieves the size of the Recycle Bin and the number of items in it, for a specified drive.
; Syntax.........: _WinAPI_ShellQueryRecycleBin ( $sRoot )
; Parameters.....: $sRoot  - The string that contains the path of the root drive on which the Recycle Bin is located. This string
;                            can be formatted with the drive, folder, and subfolder names, for example "c:\windows\system\".
;                            If this parameter is empty string, information is retrieved for all Recycle Bins on all drives.
; Return values..: Success - The array that contains the following information.
;
;                            [0] - The total size of all the objects in the specified Recycle Bin, in bytes.
;                            [1] - The total number of items in the specified Recycle Bin.
;
;                  Failure - 0 and sets the @error flag to non-zero, @extended flag may contain the system error code.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ SHQueryRecycleBin
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_ShellQueryRecycleBin($sRoot)

	Local $tSHQUERYRBINFO = DllStructCreate('align 1;dword;int64;int64')

	DllStructSetData($tSHQUERYRBINFO, 1, DllStructGetSize($tSHQUERYRBINFO))

	Local $Ret = DllCall('shell32.dll', 'uint', 'SHQueryRecycleBinW', 'wstr', $sRoot, 'ptr', DllStructGetPtr($tSHQUERYRBINFO))

	If @error Then
		Return SetError(1, 0, 0)
	Else
		If $Ret[0] Then
			Return SetError(1, $Ret[0], 0)
		EndIf
	EndIf

	Local $Result[2]

	$Result[0] = DllStructGetData($tSHQUERYRBINFO, 2)
	$Result[1] = DllStructGetData($tSHQUERYRBINFO, 3)

	Return $Result
EndFunc   ;==>_WinAPI_ShellQueryRecycleBin

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_ShellQueryUserNotificationState
; Description....: Checks the state of the computer for the current user.
; Syntax.........: _WinAPI_ShellQueryUserNotificationState ( )
; Parameters.....: None
; Return values..: Success  - The current computer state ($QUNS_*).
;                  Failure  - 0 and sets the @error flag to non-zero, @extended flag may contain the system error code.
; Author.........: Yashied
; Modified.......:
; Remarks........: This function requires Windows Vista or later.
; Related........:
; Link...........: @@MsdnLink@@ SHQueryUserNotificationState
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_ShellQueryUserNotificationState()

	Local $Ret = DllCall('shell32.dll', 'uint', 'SHQueryUserNotificationState', 'uint*', 0)

	If @error Then
		Return SetError(1, 0, 0)
	Else
		If $Ret[0] Then
			Return SetError(1, $Ret[0], 0)
		EndIf
	EndIf
	Return $Ret[1]
EndFunc   ;==>_WinAPI_ShellQueryUserNotificationState

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_ShellSetSettings
; Description....: Sets Shell state settings.
; Syntax.........: _WinAPI_ShellSetSettings ( $iFlags, $fSet )
; Parameters.....: $iFlags - The flags that indicate which settings should be set. This parameter can be one or
;                            more of the following values (use ONLY this flags).
;
;                            $SSF_SHOWALLOBJECTS
;                            $SSF_SHOWEXTENSIONS
;                            $SSF_SHOWCOMPCOLOR
;                            $SSF_SHOWSYSFILES
;                            $SSF_DOUBLECLICKINWEBVIEW
;                            $SSF_DESKTOPHTML
;                            $SSF_WIN95CLASSIC
;                            $SSF_DONTPRETTYPATH
;                            $SSF_MAPNETDRVBUTTON
;                            $SSF_SHOWINFOTIP
;                            $SSF_HIDEICONS
;                            $SSF_NOCONFIRMRECYCLE
;                            $SSF_WEBVIEW
;                            $SSF_SHOWSUPERHIDDEN
;                            $SSF_SEPPROCESS
;                            $SSF_NONETCRAWLING
;                            $SSF_STARTPANELON
;
;                            *Windows Vista or later
;
;                            $SSF_AUTOCHECKSELECT
;                            $SSF_ICONSONLY
;                            $SSF_SHOWTYPEOVERLAY
;
;                  $fSet   - Specifies whether a settings ($SSF_*) is enable or disable, valid values:
;                  |TRUE   - Enable.
;                  |FALSE  - Disable.
; Return values..: Success - 1.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ SHGetSetSettings
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_ShellSetSettings($iFlags, $fSet)

	Local $Val1 = 0, $Val2 = 0

	If $fSet Then
		If BitAND($iFlags, $SSF_SHOWALLOBJECTS) Then
			$Val1 += 0x00000001
		EndIf
		If BitAND($iFlags, $SSF_SHOWEXTENSIONS) Then
			$Val1 += 0x00000002
		EndIf
		If BitAND($iFlags, $SSF_NOCONFIRMRECYCLE) Then
			$Val1 += 0x00000004
		EndIf
		If BitAND($iFlags, $SSF_SHOWSYSFILES) Then
			$Val1 += 0x00000008
		EndIf
		If BitAND($iFlags, $SSF_SHOWCOMPCOLOR) Then
			$Val1 += 0x00000010
		EndIf
		If BitAND($iFlags, $SSF_DOUBLECLICKINWEBVIEW) Then
			$Val1 += 0x00000020
		EndIf
		If BitAND($iFlags, $SSF_DESKTOPHTML) Then
			$Val1 += 0x00000040
		EndIf
		If BitAND($iFlags, $SSF_WIN95CLASSIC) Then
			$Val1 += 0x00000080
		EndIf
		If BitAND($iFlags, $SSF_DONTPRETTYPATH) Then
			$Val1 += 0x00000100
		EndIf
		If BitAND($iFlags, $SSF_MAPNETDRVBUTTON) Then
			$Val1 += 0x00000400
		EndIf
		If BitAND($iFlags, $SSF_SHOWINFOTIP) Then
			$Val1 += 0x00000800
		EndIf
		If BitAND($iFlags, $SSF_HIDEICONS) Then
			$Val1 += 0x00001000
		EndIf
		If BitAND($iFlags, $SSF_WEBVIEW) Then
			$Val1 += 0x00002000
		EndIf
		If BitAND($iFlags, $SSF_SHOWSUPERHIDDEN) Then
			$Val1 += 0x00008000
		EndIf
		If BitAND($iFlags, $SSF_NONETCRAWLING) Then
			$Val1 += 0x00010000
		EndIf
		If BitAND($iFlags, $SSF_SEPPROCESS) Then
			$Val2 += 0x00000001
		EndIf
		If BitAND($iFlags, $SSF_STARTPANELON) Then
			$Val2 += 0x00000002
		EndIf
		If BitAND($iFlags, $SSF_AUTOCHECKSELECT) Then
			$Val2 += 0x00000008
		EndIf
		If BitAND($iFlags, $SSF_ICONSONLY) Then
			$Val2 += 0x00000010
		EndIf
		If BitAND($iFlags, $SSF_SHOWTYPEOVERLAY) Then
			$Val2 += 0x00000020
		EndIf
	EndIf

	Local $tSHELLSTATE = DllStructCreate('uint[8]')

	DllStructSetData($tSHELLSTATE, 1, $Val1, 1)
	DllStructSetData($tSHELLSTATE, 1, $Val2, 8)
	DllCall('shell32.dll', 'none', 'SHGetSetSettings', 'ptr', DllStructGetPtr($tSHELLSTATE), 'dword', $iFlags, 'int', 1)
	If @error Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_ShellSetSettings

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_ShowCaret
; Description....: Makes the caret visible on the screen at the caret's current position.
; Syntax.........: _WinAPI_ShowCaret ( $hWnd )
; Parameters.....: $hWnd   - Handle to the window that owns the caret. If this parameter is 0, _WinAPI_ShowCaret() searches the
;                            current task for the window that owns the caret.
; Return values..: Success - 1.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: _WinAPI_ShowCaret() shows the caret only if the specified window owns the caret, the caret has a shape,
;                  and the caret has not been hidden two or more times in a row. If one or more of these conditions is not met,
;                  _WinAPI_ShowCaret() does nothing and returns 0.
;
;                  Hiding is cumulative. If your application calls _WinAPI_HideCaret() five times in a row, it must also call
;                  _WinAPI_ShowCaret() five times before the caret reappears.
; Related........:
; Link...........: @@MsdnLink@@ ShowCaret
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_ShowCaret($hWnd)

	Local $Ret = DllCall('user32.dll', 'int', 'ShowCaret', 'hwnd', $hWnd)

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_ShowCaret

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
	MsgBox(0, _WinAPI_GetLastError(), _WinAPI_GetLastErrorMessage())
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

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_ShowOwnedPopups

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_ShutdownDlg
; Description....: Displays a Windows Shutdown dialog box.
; Syntax.........: _WinAPI_ShutdownDlg ( )
; Parameters.....: None
; Return values..: None
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: None
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_ShutdownDlg()

	Local $oShell = ObjCreate('Shell.Application')

	If Not @error Then
		$oShell.ShutdownWindows()
	EndIf
EndFunc   ;==>_WinAPI_ShutdownDlg

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_SizeOfResource
; Description....: Returns the size, in bytes, of the specified resource.
; Syntax.........: _WinAPI_SizeOfResource ( $hInstance, $hResource )
; Parameters.....: $hInstance - Handle to the module whose executable file contains the resource.
;                  $hResource - Handle to the resource. This handle must be created by using the _WinAPI_FindResource() or _WinAPI_FindResourceEx()
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

Func _WinAPI_SizeOfResource($hInstance, $hResource)

	Local $Ret = DllCall('kernel32.dll', 'dword', 'SizeofResource', 'ptr', $hInstance, 'ptr', $hResource)

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_SizeOfResource

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

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_StretchBlt

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_StrLen
; Description....: Returns the length of the specified string.
; Syntax.........: _WinAPI_StrLen ( $pString [, $fUnicode] )
; Parameters.....: $pString  - Pointer to a null-terminated string.
;                  $fUnicode - Specifies whether a string is Unicode or ASCII code of a character, valid values:
;                  |TRUE     - Unicode. (Default)
;                  |FALSE    - ASCII.
; Return values..: Success   - The length of the string, in TCHAR values (not including the null-terminating character).
;                  Failure   - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ lstrlen
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_StrLen($pString, $fUnicode = 1)

	Local $W = ''

	If $fUnicode Then
		$W = 'W'
	EndIf

	Local $Ret = DllCall('kernel32.dll', 'int', 'lstrlen' & $W, 'ptr', $pString)

	If @error  Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_WinAPI_StrLen

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_StrokeAndFillPath
; Description....: Closes any open figures in a path, strokes the outline of the path, and fills its interior.
; Syntax.........: _WinAPI_StrokeAndFillPath ( $hDC )
; Parameters.....: $hDC    - Handle to the device context.
; Return values..: Success - 1.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: The device context identified by the $hDC parameter must contain a closed path.
; Related........:
; Link...........: @@MsdnLink@@ StrokeAndFillPath
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_StrokeAndFillPath($hDC)

	Local $Ret = DllCall('gdi32.dll', 'int', 'StrokeAndFillPath', 'hwnd', $hDC)

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_StrokeAndFillPath

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_StrokePath
; Description....: Renders the specified path by using the current pen.
; Syntax.........: _WinAPI_StrokePath ( $hDC )
; Parameters.....: $hDC    - Handle to a device context that contains the completed path.
; Return values..: Success - 1.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: The path, if it is to be drawn by this function, must have been completed through a call to _WinAPI_EndPath().
;                  Unlike other path drawing functions such as _WinAPI_StrokeAndFillPath(), _WinAPI_StrokePath() will not attempt
;                  to close the path by drawing a straight line from the first point on the path to the last point on the path.
; Related........:
; Link...........: @@MsdnLink@@ StrokePath
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_StrokePath($hDC)

	Local $Ret = DllCall('gdi32.dll', 'int', 'StrokePath', 'hwnd', $hDC)

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_StrokePath

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_StructToArray
; Description....: Converts the structure to the array of strings.
; Syntax.........: _WinAPI_StructToArray ( $pStruct [, $iItems] )
; Parameters.....: $pStruct - The pointer to the structure to convert. This structure should be same as for _WinAPI_ArrayToStruct().
;                  $iItems  - The number of strings that contains the structure. If this parameter is 0, the end of the structure
;                             determined by a double null-terminated character ("... ;{0};{0}").
; Return values..: Success  - The array of strings. The zeroth array element contains the number of strings.
;                  Failure  - 0 and sets the @error flag to one of the following values:
;                  |1 - $pStruct is not a correct pointer.
;                  |2 - Failed to allocate the memory.
;                  |3 - Size of the structure exceeds the allowable size (32 KB).
; Author.........: Yashied
; Modified.......:
; Remarks........: This function works for Unicode strings only.
; Related........:
; Link...........: None
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_StructToArray($pStruct, $iItems = 0)

	Local $tData, $Count = 0, $Index = 1, $Lenght = 32 * 1024 / 2, $Struct = ''
	Local $Result[101] = [1, 0]

	$tData = DllStructCreate('wchar[' & $Lenght & ']', $pStruct)
	If @error Then
		Return SetError(1, 0, 0)
	EndIf
	While 1
		If Not AscW(DllStructGetData($tData, 1, $Index)) Then
			$Count += 1
			If $Count > 1 Then
				ExitLoop
			EndIf
			$Result[0] += 1
			If ($iItems) And ($Result[0] > $iItems) Then
				ExitLoop
			EndIf
			If $Result[0] > UBound($Result) - 1 Then
				ReDim $Result[$Result[0] + 100]
			EndIf
			$Result[$Result[0]] = 0
		Else
			$Result[$Result[0]] += 1
			$Count = 0
		EndIf
		$Index += 1
		If $Index > $Lenght Then
			Return SetError(2, 0, 0)
		EndIf
	WEnd
	ReDim $Result[$Result[0]]
	$Result[0] -= 1
	For $i = 1 To $Result[0]
		$Struct &= 'wchar[' & ($Result[$i] + 1) & '];'
	Next
	$tData = DllStructCreate($Struct, $pStruct)
	If @error Then
		Return SetError(3, 0, 0)
	EndIf
	For $i = 1 To $Result[0]
		$Result[$i] = DllStructGetData($tData, $i)
	Next
	Return $Result
EndFunc   ;==>_WinAPI_StructToArray

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_SubtractRect
; Description....: Determines the coordinates of a rectangle formed by subtracting one rectangle from another.
; Syntax.........: _WinAPI_SubtractRect ( $tRECT1, $tRECT2 )
; Parameters.....: $tRECT1 - $tagRECT structure from which the function subtracts the rectangle specified by $tRECT2.
;                  $tRECT2 - $tagRECT structure that the function subtracts from the rectangle specified by $tRECT1.
; Return values..: Success - $tagRECT structure that contains the rectangle determined by subtracting the rectangle specified by
;                            $tRECT2 from the rectangle specified by $tRECT1.
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

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $tRECT
EndFunc   ;==>_WinAPI_SubtractRect

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_SwapDWord
; Description....: Swaps high-order and low-order bits of the 32-bit value.
; Syntax.........: _WinAPI_SwapDWord ( $iValue )
; Parameters.....: $iValue - 32-bit value.
; Return values..: Swapped value.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: None
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_SwapDWord($iValue)
	Return _WinAPI_MakeLong(_WinAPI_HiWord($iValue), _WinAPI_LoWord($iValue))
EndFunc   ;==>_WinAPI_SwapDWord

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_SwitchColor
; Description....: Converts a color from BGR to RGB and vice versa.
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
; Description....: Writes a string at the specified location, using the currently selected font, background color, and text color.
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

	If (@error) Or (Not $Ret[0]) Then
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

	Local $Ret  = DllCall('gdi32.dll', 'int', 'GdiTransparentBlt', 'hwnd', $hDestDC, 'int', $iXDest, 'int', $iYDest, 'int', $iWidthDest, 'int', $iHeightDest, 'hwnd', $hSrcDC, 'int', $iXSrc, 'int', $iYSrc, 'int', $iWidthSrc, 'int', $iHeightSrc, 'dword', __RGB($iRGB))

	If (@error) Or (Not $Ret[0]) Then
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

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $tRECT
EndFunc   ;==>_WinAPI_UnionRect

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_UnionStruct
; Description....: Creates the structure of two structures.
; Syntax.........: _WinAPI_UnionStruct (ByRef $tStruct1, ByRef $tStruct2)
; Parameters.....: $tStruct1 - The structure that contains the first source data.
;                  $tStruct2 - The structure that contains the second source data.
; Return values..: Success   - "byte[n]" structure that contains the union data of the $tStruct1 and $tStruct2.
;                  Failure   - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: None
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_UnionStruct(ByRef $tStruct1, ByRef $tStruct2)

	Local $Size1 = DllStructGetSize($tStruct1)
	Local $Size2 = DllStructGetSize($tStruct2)

	If (Not $Size1) Or (Not $Size2) Then
		Return SetError(1, 0, 0)
	EndIf

	Local $tData, $tResult, $Size, $Count = 1

	$tResult = DllStructCreate('byte[' & ($Size1 + $Size2) & ']')
	If @error Then
		Return SetError(1, 0, 0)
	EndIf
	For $i = 1 To 2
		$Size = Eval('Size' & $i)
		$tData = DllStructCreate('byte[' & $Size & ']', DllStructGetPtr(Eval('tStruct' & $i)))
		If @error Then
			Return SetError(1, 0, 0)
		EndIf
		For $j = 1 To $Size
			DllStructSetData($tResult, 1, DllStructGetData($tData, 1, $j), $Count)
			If @error Then
				Return SetError(1, 0, 0)
			EndIf
			$Count += 1
		Next
	Next
	Return $tResult
EndFunc   ;==>_WinAPI_UnionStruct

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_UniqueHardwareID
; Description....: Generates a unique hardware identifier (ID) for local computer.
; Syntax.........: _WinAPI_UniqueHardwareID ( [$iFlags] )
; Parameters.....: $iFlags - The flags that specifies what information would be used to generate ID. This parameter can be one
;                            or more of the following values.
;
;                            $UHID_MB
;                            Uses information about your motherboard. This flag is used by default regardless of whether specified or not.
;
;                            $UHID_BIOS
;                            Uses information from BIOS.
;
;                            $UHID_CPU
;                            Uses information about your processor(s). Note that $UHID_CPU flag reduces the function speed.
;
;                            $UHID_HDD
;                            Uses information about the installed hard drives. Any change in the configuration disks will change ID
;                            returned by this function. Taken into account only non-removable disks with an ATA or SATA interfaces.
;
;                            $UHID_All
;                            The sum of all the above flags.
;
; Return values..: Success - The string representation of the ID. @extended returns the value that contains a combination of flags
;                            specified in the $iFlags parameter. If flag is set, appropriate information is received successfully,
;                            otherwise fails. The function checks only flags that were specified in the $iFlags parameter.
;                  Failure - Empty string and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: This function uses the Windows Management Instrumentation (WMI).
; Related........:
; Link...........: None
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_UniqueHardwareID($iFlags = 0)

	Local $oService = ObjGet('winmgmts:\\.\root\cimv2')

	If Not IsObj($oService) Then
		Return SetError(1, 0, '')
	EndIf

	Local $oItems, $Hash, $Text, $Type, $Hw = '', $Result = 0

	$oItems = $oService.ExecQuery('SELECT * FROM Win32_ComputerSystemProduct')
	If Not IsObj($oItems) Then
		Return SetError(2, 0, '')
	EndIf
	For $Property In $oItems
		$Hw &= $Property.IdentifyingNumber
		$Hw &= $Property.Name
		$Hw &= $Property.SKUNumber
		$Hw &= $Property.UUID
		$Hw &= $Property.Vendor
		$Hw &= $Property.Version
	Next
	$Hw = StringStripWS($Hw, 8)
	If Not $Hw Then
		Return SetError(3, 0, '')
	EndIf
	If BitAND($iFlags, $UHID_BIOS) Then
		$oItems = $oService.ExecQuery('SELECT * FROM Win32_BIOS')
		If Not IsObj($oItems) Then
			Return SetError(2, 0, '')
		EndIf
		$Text = ''
		For $Property In $oItems
			$Text &= $Property.IdentificationCode
			$Text &= $Property.Manufacturer
			$Text &= $Property.Name
			$Text &= $Property.SerialNumber
			$Text &= $Property.SMBIOSMajorVersion
			$Text &= $Property.SMBIOSMinorVersion
;			$Text &= $Property.Version
		Next
		$Text = StringStripWS($Text, 8)
		If $Text Then
			$Result += $UHID_BIOS
			$Hw &= $Text
		EndIf
	EndIf
	If BitAND($iFlags, $UHID_CPU) Then
		$oItems = $oService.ExecQuery('SELECT * FROM Win32_Processor')
		If Not IsObj($oItems) Then
			Return SetError(2, 0, '')
		EndIf
		$Text = ''
		For $Property In $oItems
			$Text &= $Property.Architecture
			$Text &= $Property.Family
			$Text &= $Property.Level
			$Text &= $Property.Manufacturer
			$Text &= $Property.Name
			$Text &= $Property.ProcessorId
			$Text &= $Property.Revision
			$Text &= $Property.Version
		Next
		$Text = StringStripWS($Text, 8)
		If $Text Then
			$Result += $UHID_CPU
			$Hw &= $Text
		EndIf
	EndIf
	If BitAND($iFlags, $UHID_HDD) Then
		$oItems = $oService.ExecQuery('SELECT * FROM Win32_PhysicalMedia')
		If Not IsObj($oItems) Then
			Return SetError(2, 0, '')
		EndIf
		$Text = ''
		For $Property In $oItems
			Switch _WinAPI_GetDriveBusType($Property.Tag)
				Case $DRIVE_BUS_TYPE_ATA, $DRIVE_BUS_TYPE_SATA
					$Text &= $Property.SerialNumber
				Case Else

			EndSwitch
		Next
		$Text = StringStripWS($Text, 8)
		If $Text Then
			$Result += $UHID_HDD
			$Hw &= $Text
		EndIf
	EndIf
	$Hash = __MD5($Hw)
	If Not $Hash Then
		Return SetError(4, 0, '')
	EndIf
	Return SetError(0, $Result, '{' & StringMid($Hash, 1, 8) & '-' & StringMid($Hash, 9, 4) & '-' & StringMid($Hash, 13, 4) & '-' & StringMid($Hash, 17, 4) & '-' & StringMid($Hash, 21, 12) & '}')
EndFunc   ;==>_WinAPI_UniqueHardwareID

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_UnloadKeyboardLayout
; Description....: Unloads an input locale identifier.
; Syntax.........: _WinAPI_UnloadKeyboardLayout ( $hLocale )
; Parameters.....: $hLocale - The input locale identifier to be unloaded.
; Return values..: Success  - 1.
;                  Failure  - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: _WinAPI_UnloadKeyboardLayout() cannot unload the system default input locale identifier if it is the only
;                  keyboard layout loaded. You must first load another input locale identifier before unloading the default input
;                  locale identifier.
; Related........:
; Link...........: @@MsdnLink@@ UnloadKeyboardLayout
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_UnloadKeyboardLayout($hLocale)

	Local $Ret = DllCall('user32.dll', 'int', 'UnloadKeyboardLayout', 'long', $hLocale)

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_UnloadKeyboardLayout

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_UnlockFile
; Description....: Unlocks a region in an open file.
; Syntax.........: _WinAPI_UnlockFile ( $hFile, $iOffset, $iLenght )
; Parameters.....: $hFile   - Handle to the file that contains a region locked with _WinAPI_LockFile() function.
;                  $iOffset - The starting byte offset in the file where the locked region begins.
;                  $iLenght - The length of the byte range to be unlocked.
; Return values..: Success  - 1.
;                  Failure  - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: Unlocking a region of a file releases a previously acquired lock on the file. The region to unlock must correspond
;                  exactly to an existing locked region. Two adjacent regions of a file cannot be locked separately and then unlocked
;                  using a single region that spans both locked regions.
; Related........:
; Link...........: @@MsdnLink@@ UnlockFile
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_UnlockFile($hFile, $iOffset, $iLenght)

	Local $Ret = DllCall('kernel32.dll', 'int', 'UnlockFile', 'ptr', $hFile, 'dword', _WinAPI_LoDWord($iOffset), 'dword', _WinAPI_HiDWord($iOffset), 'dword', _WinAPI_LoDWord($iLenght), 'dword', _WinAPI_HiDWord($iLenght))

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_UnlockFile

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_UnmapViewOfFile
; Description....: Unmaps a mapped view of a file from the calling process's address space.
; Syntax.........: _WinAPI_UnmapViewOfFile ( $pAddress )
; Parameters.....: $pAddress - A pointer to the base address of the mapped view of a file that is to be unmapped. This value must be
;                              identical to the value returned by a previous call to the _WinAPI_MapViewOfFile() function.
; Return values..: Success   - 1.
;                  Failure   - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: Unmapping a mapped view of a file invalidates the range occupied by the view in the address space of the process
;                  and makes the range available for other allocations. It removes the working set entry for each unmapped virtual page
;                  that was part of the working set of the process and reduces the working set size of the process. It also
;                  decrements the share count of the corresponding physical page.
;
;                  Although an application may close the file handle used to create a file mapping object, the system holds the
;                  corresponding file open until the last view of the file is unmapped. Files for which the last view has not
;                  yet been unmapped are held open with no sharing restrictions.
;
;                  To minimize the risk of data loss in the event of a power failure or a system crash, you should explicitly flush
;                  modified pages using the _WinAPI_FlushViewOfFile() function.
; Related........:
; Link...........: @@MsdnLink@@ UnmapViewOfFile
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_UnmapViewOfFile($pAddress)

	Local $Ret = DllCall('kernel32.dll', 'int', 'UnmapViewOfFile', 'ptr', $pAddress)

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_UnmapViewOfFile

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_UnregisterClass
; Description....: Unregisters a window class, freeing the memory required for the class.
; Syntax.........: _WinAPI_UnregisterClass ( $sClass [, $hInstance] )
; Parameters.....: $sClass    - A null-terminated string or a class atom. If $sClass is a string, it specifies the window class
;                               name. This class name must have been registered by a previous call to the _WinAPI_RegisterClass()
;                               or _WinAPI_RegisterClassEx() function. If this parameter is an atom, it must be in the low-order
;                               word of $sClass; the high-order word must be zero.
;                  $hInstance - Handle to the instance of the module that created the class.
; Return values..: Success    - 1.
;                  Failure    - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: Before calling this function, an application must destroy all windows created with the specified class.
;                  All window classes that an application registers are unregistered when it terminates.
; Related........:
; Link...........: @@MsdnLink@@ UnregisterClass
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_UnregisterClass($sClass, $hInstance = 0)

	Local $TypeOfClass = 'ptr'

	If IsString($sClass) Then
		$TypeOfClass = 'wstr'
	EndIf

	Local $Ret = DllCall('user32.dll', 'int', 'UnregisterClassW', $TypeOfClass, $sClass, 'ptr', $hInstance)

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_UnregisterClass

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_UnregisterHotKey
; Description....: Frees a hot key previously registered by the calling thread.
; Syntax.........: _WinAPI_UnregisterHotKey ( $hWnd, $ID )
; Parameters.....: $hWnd   - Handle to the window associated with the hot key to be freed. This parameter should be 0 if the
;                            hot key is not associated with a window.
;                  $ID     - Specifies the identifier of the hot key to be freed.
; Return values..: Success - 1.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ UnregisterHotKey
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_UnregisterHotKey($hWnd, $ID)

	Local $Ret = DllCall('user32.dll', 'int', 'UnregisterHotKey', 'hwnd', $hWnd, 'int', $ID)

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_UnregisterHotKey

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_UpdateLayeredWindowEx
; Description....: Updates a bitmap translucency of a layered window.
; Syntax.........: _WinAPI_UpdateLayeredWindowEx ( $hWnd, $hBitmap [, $iOpacity [, $fDelete]] )
; Parameters.....: $hWnd     - Handle to a layered window. A layered window is created by specifying $WS_EX_LAYERED when its creating.
;                  $hBitmap  - Handle to the bitmap that will be set in the layered window.
;                  $iOpacity - The alpha transparency value to be used on the entire source bitmap.
;                  $fDelete  - Specifies whether deletes a bitmap after updated the window, valid values:
;                  |TRUE     - Bitmap will be deleted if function succeeds.
;                  |FALSE    - Don't deleted, you must release the bitmap when you are finished using it. (Default)
; Return values..: Success   - 1.
;                  Failure   - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: For best drawing performance by the layered window and any underlying windows, the layered window should be
;                  as small as possible.
; Related........:
; Link...........: None
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_UpdateLayeredWindowEx($hWnd, $hBitmap, $iOpacity = 255, $fDelete = 0)

	Local $Ret, $tSIZE, $tPOINT, $tBLENDFUNCTION, $hDC, $hDestDC, $hDestSv

	$Ret = DllCall('user32.dll', 'hwnd', 'GetDC', 'hwnd', $hWnd)
	$hDC = $Ret[0]
	$Ret = DllCall('gdi32.dll', 'hwnd', 'CreateCompatibleDC', 'hwnd', $hDC)
	$hDestDC = $Ret[0]
	$Ret = DllCall('gdi32.dll', 'hwnd', 'SelectObject', 'hwnd', $hDestDC, 'ptr', $hBitmap)
	$hDestSv = $Ret[0]
	$tSIZE = _WinAPI_GetBitmapDimension($hBitmap)
	$tPOINT = DllStructCreate($tagPOINT)
	$tBLENDFUNCTION = DllStructCreate($tagBLENDFUNCTION)
	DllStructSetData($tBLENDFUNCTION, 'Alpha', $iOpacity)
	DllStructSetData($tBLENDFUNCTION, 'Format', 1)
	$Ret = DllCall('user32.dll', 'int', 'UpdateLayeredWindow', 'hwnd', $hWnd, 'hwnd', $hDC, 'ptr', 0, 'ptr', DllStructGetPtr($tSIZE), 'hwnd', $hDestDC, 'ptr', DllStructGetPtr($tPOINT), 'dword', 0, 'ptr', DllStructGetPtr($tBLENDFUNCTION), 'dword', 0x02)
	DllCall('user32.dll', 'int', 'ReleaseDC', 'hwnd', $hWnd, 'hwnd', $hDC)
	DllCall('gdi32.dll', 'ptr', 'SelectObject', 'hwnd', $hDestDC, 'ptr', $hDestSv)
	DllCall('gdi32.dll', 'int', 'DeleteDC', 'hwnd', $hDestDC)
	If Not $Ret[0] Then
		Return SetError(1, 0, 0)
	EndIf
	If $fDelete Then
		_WinAPI_DeleteObject($hBitmap)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_UpdateLayeredWindowEx

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_UpdateResource
; Description....: Adds, deletes, or replaces a resource in a portable executable (PE) file.
; Syntax.........: _WinAPI_UpdateResource ( $hUpdate, $sType, $sName, $iLanguage, $pData, $iSize )
; Parameters.....: $hUpdate   - A module handle returned by the _WinAPI_BeginUpdateResource(), referencing the file to be updated.
;                  $sType     - The resource type to be updated. Alternatively, rather than a pointer, this parameter can be an
;                               integer value representing a predefined resource type. If the first character of the string is a
;                               pound sign (#), then the remaining characters represent a decimal number that specifies the integer
;                               identifier of the resource type. For example, the string "#258" represents the identifier 258.
;                               Also, you can use a predefined resource types ($RT_*).
;                  $sName     - The name of the resource to be updated. This parameter can be string or integer type (see above).
;                  $iLanguage - The language of the resource (LCID).
;                  $pData     - The resource data to be inserted into the file indicated by $hUpdate parameter. If the resource is
;                               one of the predefined types, the data must be valid and properly aligned. Note that this is the raw
;                               binary data, not the data provided by _WinAPI_LoadIcon(), _WinAPI_LoadString(), or other resource-
;                               specific load functions. All data containing strings or text must be in Unicode format. If $pData
;                               is 0 and $iSize is 0, the specified resource is deleted from the file indicated by $hUpdate.
;                  $iSize     - The size, in bytes, of the resource data at $pData.
; Return values..: Success    - 1.
;                  Failure    - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: It is recommended that the resource file is not loaded before this function is called. However, if that file
;                  is already loaded, it will not cause an error to be returned.
;
;                  An application can use _WinAPI_UpdateResource() repeatedly to make changes to the resource data. Each call
;                  to _WinAPI_UpdateResource() contributes to an internal list of additions, deletions, and replacements but does
;                  not actually write the data to the file. The application must use the _WinAPI_EndUpdateResource() function to
;                  write the accumulated changes.
;
;                  If $pData is 0 and $iSize is 0, the specified resource is deleted from the file indicated by $hUpdate.
; Related........:
; Link...........: @@MsdnLink@@ UpdateResource
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_UpdateResource($hUpdate, $sType, $sName, $iLanguage, $pData, $iSize)

	Local $TypeOfType = 'int', $TypeOfName = 'int'

	If IsString($sType) Then
		$TypeOfType = 'wstr'
	EndIf
	If IsString($sName) Then
		$TypeOfName = 'wstr'
	EndIf

	Local $Ret = DllCall('kernel32.dll', 'int', 'UpdateResourceW', 'ptr', $hUpdate, $TypeOfType, $sType, $TypeOfName, $sName, 'ushort', $iLanguage, 'ptr', $pData, 'dword', $iSize)

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_UpdateResource

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

	If (@error) Or (Not $Ret[0]) Then
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

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_ValidateRgn

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_VerQueryRoot
; Description....: Retrieves fixed (code page independent) version information from the specified file.
; Syntax.........: _WinAPI_VerQueryRoot ( $sFile )
; Parameters.....: $sFile  - The name of the file.
; Return values..: Success - $tagVS_FIXEDFILEINFO structure that contains the version information.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ VerQueryValue
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_VerQueryRoot($sFile)

	Local $tInfo = _WinAPI_GetFileVersionInfo($sFile)

	If Not IsDllStruct($tInfo) Then
		Return SetError(1, 0, 0)
	EndIf

	Local $Ret = DllCall('version.dll', 'int', 'VerQueryValueW', 'ptr', DllStructGetPtr($tInfo), 'wstr', '\', 'ptr*', 0, 'uint*', 0)

	If (@error) Or (Not $Ret[0]) Or (Not $Ret[4]) Then
		Return SetError(1, 0, 0)
	EndIf

	Local $tData = DllStructCreate('byte[' & $Ret[4] & ']', $Ret[3])

	If Not IsDllStruct($tData) Then
		Return SetError(1, 0, 0)
	EndIf
	Return _WinAPI_CopyStruct($tData, $tagVS_FIXEDFILEINFO)
EndFunc   ;==>_WinAPI_VerQueryRoot

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_VerQueryValue
; Description....: Retrieves specified version information from the specified file.
; Syntax.........: _WinAPI_VerQueryValue ( $sFile [, $sValues] )
; Parameters.....: $sFile   - The name of the file.
;                  $sValues - The string containing the field names for which you want to get values. The names must be separated
;                             by a "|". For example, "name1|name2|...|namei". If some fields do not exist, the corresponding array
;                             elements is an empty string. If this parameter is not specified (empty string), uses the reserved
;                             names (12) in the following sequence.
;
;                             "Comments"
;                             "CompanyName"
;                             "FileDescription"
;                             "FileVersion'
;                             "InternalName"
;                             "LegalCopyright"
;                             "LegalTrademarks"
;                             "OriginalFilename"
;                             "ProductName"
;                             "ProductVersion"
;                             "PrivateBuild"
;                             "SpecialBuild"
;
; Return values..: Success  - The 2D array of the string values that specified by $sValues parameter for each language. The zeroth
;                             array element [0][0] contains the number of languages of the resource. The array dimension (i) equal
;                             to the number specified parameters + 1. The zeroth array element [n][0] contains the language
;                             identifier (LCID).
;
;                             [0][0] - Number of languages (n)
;                             [0][i] - Unused
;                             [1][0] - LCID
;                             [1][i] - Value
;                             [n][0] - LCID
;                             [n][i] - Value
;
;                  Failure  - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ VerQueryValue
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_VerQueryValue($sFile, $sValues = '')

	Local $tInfo = _WinAPI_GetFileVersionInfo($sFile)

	If Not IsDllStruct($tInfo) Then
		Return SetError(1, 0, 0)
	EndIf

	$sValues = StringRegExpReplace($sValues, '\A[\s\|]*|[\s\|]*\Z', '')
	If Not $sValues Then
		$sValues = 'Comments|CompanyName|FileDescription|FileVersion|InternalName|LegalCopyright|LegalTrademarks|OriginalFilename|ProductName|ProductVersion|PrivateBuild|SpecialBuild'
	EndIf

	Local $Ret, $Lenght, $LP, $tLang, $aValues = StringSplit($sValues, '|', 2), $pInfo = DllStructGetPtr($tInfo)
	Local $Result[1][UBound($aValues) + 1] = [[0]]

	$Ret = DllCall('version.dll', 'int', 'VerQueryValueW', 'ptr', $pInfo, 'wstr', '\VarFileInfo\Translation', 'ptr*', 0, 'uint*', 0)
	If (@error) Or (Not $Ret[0]) Or (Not $Ret[4]) Then
		Return SetError(1, 0, 0)
	EndIf
	$Lenght = Floor($Ret[4] / 4)
	$tLang = DllStructCreate('dword[' & $Lenght & ']', $Ret[3])
	If Not IsDllStruct($tLang) Then
		Return SetError(1, 0, 0)
	EndIf
	For $i = 1 To $Lenght
		$Result[0][0] += 1
		ReDim $Result[$Result[0][0] + 1][UBound($aValues) + 1]
		$Result[$Result[0][0]][0] = _WinAPI_LoWord(DllStructGetData($tLang, 1, $i))
		$LP = Hex(_WinAPI_SwapDWord(DllStructGetData($tLang, 1, $i)), 8)
		For $j = 0 To UBound($aValues) - 1
			$Ret = DllCall('version.dll', 'int', 'VerQueryValueW', 'ptr', $pInfo, 'wstr', '\StringFileInfo\' & $LP & '\' & $aValues[$j], 'ptr*', 0, 'uint*', 0)
			If (Not @error) And ($Ret[0]) And ($Ret[4]) Then
				$Result[$Result[0][0]][$j + 1] = DllStructGetData(DllStructCreate('wchar[' & $Ret[4] & ']', $Ret[3]), 1)
			Else
				$Result[$Result[0][0]][$j + 1] = ''
			EndIf
		Next
	Next
	Return $Result
EndFunc   ;==>_WinAPI_VerQueryValue

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_WidenPath
; Description....: Redefines the current path as the area that would be painted if the path were stroked.
; Syntax.........: _WinAPI_WidenPath ( $hDC )
; Parameters.....: $hDC    - handle to a device context that contains a closed path.
; Return values..: Success - 1.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: The device context identified by the $hDC parameter must contain a closed path.
;
;                  The _WinAPI_WidenPath() function is successful only if the current pen has a width, in device units, of more than one.
;
;                  Any Bezier curves in the path are converted to sequences of straight lines approximating the widened curves.
;                  As such, no Bezier curves remain in the path after _WinAPI_WidenPath() is called.
; Related........:
; Link...........: @@MsdnLink@@ WidenPath
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_WidenPath($hDC)

	Local $Ret = DllCall('gdi32.dll', 'int', 'WidenPath', 'hwnd', $hDC)

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_WidenPath

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
; Name...........: _WinAPI_Wow64EnableWow64FsRedirection
; Description....: Enables or disables file system redirection for the calling thread.
; Syntax.........: _WinAPI_Wow64EnableWow64FsRedirection ( $fEnable )
; Parameters.....: $fEnable - Specifies whether enable or disable the WOW64 system folder redirection, valid values:
;                  |TRUE    - Enable.
;                  |FALSE   - Disable.
; Return values..: Success  - 1.
;                  Failure  - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: This function is useful for 32-bit applications that want to gain access to the native system32 directory.
;                  By default, WOW64 file system redirection is enabled.
; Related........:
; Link...........: @@MsdnLink@@ Wow64EnableWow64FsRedirection
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_Wow64EnableWow64FsRedirection($fEnable)

	Local $Ret = DllCall('kernel32.dll', 'int', 'Wow64EnableWow64FsRedirection', 'int', $fEnable)

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_Wow64EnableWow64FsRedirection

#EndRegion Public Functions

#Region Internal Functions

Func __DLL($sModule)
	If Not _WinAPI_GetModuleHandle($sModule) Then
		If Not _WinAPI_GetModuleHandleEx(_WinAPI_LoadLibrary($sModule), $GET_MODULE_HANDLE_EX_FLAG_FROM_ADDRESS) Then
			Return 0
		EndIf
	EndIf
	Return 1
EndFunc   ;==>__DLL

Func __EnumLocalesProc($pLocale)

	Local $tLocale, $Lenght = _WinAPI_StrLen($pLocale)

	If Not $Lenght Then
		$__Data = 0
		Return 0
	EndIf
	$__Data[0] += 1
	If $__Data[0] > UBound($__Data) - 1 Then
		ReDim $__Data[$__Data[0] + 100]
	EndIf
	$tLocale = DllStructCreate('wchar[' & ($Lenght + 1) & ']', $pLocale)
	$__Data[$__Data[0]] = Dec(DllStructGetData($tLocale, 1))
	Return 1
EndFunc   ;==>__EnumLocalesProc

Func __EnumResLanguagesProc($hModule, $iType, $iName, $iLanguage, $lParam)
	$__Data[0] += 1
	If $__Data[0] > UBound($__Data) - 1 Then
		ReDim $__Data[$__Data[0] + 100]
	EndIf
	$__Data[$__Data[0]] = $iLanguage
	Return 1
EndFunc   ;==>__EnumResLanguagesProc

Func __EnumResNamesProc($hModule, $iType, $iName, $lParam)

	Local $sName, $tName, $Lenght = _WinAPI_StrLen($iName)

	If $Lenght Then
		$tName = DllStructCreate('wchar[' & ($Lenght + 1) & ']', $iName)
		$sName = DllStructGetData($tName, 1)
	Else
		$sName = Number($iName)
	EndIf
	$__Data[0] += 1
	If $__Data[0] > UBound($__Data) - 1 Then
		ReDim $__Data[$__Data[0] + 100]
	EndIf
	$__Data[$__Data[0]] = $sName
	Return 1
EndFunc   ;==>__EnumResNamesProc

Func __EnumResTypesProc($hModule, $iType, $lParam)

	Local $sType, $tType, $Lenght = _WinAPI_StrLen($iType)

	If $Lenght Then
		$tType = DllStructCreate('wchar[' & ($Lenght + 1) & ']', $iType)
		$sType = DllStructGetData($tType, 1)
	Else
		$sType = Number($iType)
	EndIf
	$__Data[0] += 1
	If $__Data[0] > UBound($__Data) - 1 Then
		ReDim $__Data[$__Data[0] + 100]
	EndIf
	$__Data[$__Data[0]] = $sType
	Return 1
EndFunc   ;==>__EnumResTypesProc

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

Func __MD5($sData)

	Local $Ret, $hProv, $hHash, $tData, $Error = 1

	$hProv = DllCall('advapi32.dll', 'int', 'CryptAcquireContextW', 'ptr*', 0, 'ptr', 0, 'ptr', 0, 'dword', 3, 'dword', 0xF0000000)
	If (@error) Or (Not $hProv[0]) Then
		Return ''
	EndIf
	Do
		$hHash = DllCall('advapi32.dll', 'int', 'CryptCreateHash', 'ptr', $hProv[1], 'uint', 0x00008003, 'ptr', 0, 'dword', 0, 'ptr*', 0)
		If (@error) Or (Not $hProv[0]) Then
			$hHash = 0
			ExitLoop
		EndIf
		$hHash = $hHash[5]
		$tData = DllStructCreate('byte[' & BinaryLen($sData) & ']')
		DllStructSetData($tData, 1, $sData)
		$Ret = DllCall('advapi32.dll', 'int', 'CryptHashData', 'ptr', $hHash, 'ptr', DllStructGetPtr($tData), 'dword', DllStructGetSize($tData), 'dword', 1)
		If (@error) Or (Not $Ret[0]) Then
			ExitLoop
		EndIf
		$tData = DllStructCreate('byte[16]')
		$Ret = DllCall('advapi32.dll', 'int', 'CryptGetHashParam', 'ptr', $hHash, 'dword', 2, 'ptr', DllStructGetPtr($tData), 'dword*', 16, 'dword', 0)
		If (@error) Or (Not $Ret[0]) Then
			ExitLoop
		EndIf
		$Error = 0
	Until 1
	If $hHash Then
		DllCall('advapi32.dll', 'int', 'CryptDestroyHash', 'ptr', $hHash)
	EndIf
	If $Error Then
		Return ''
	EndIf
	Return StringTrimLeft(DllStructGetData($tData, 1), 2)
EndFunc   ;==>__MD5

Func __RGB($iColor)
	If $__RGB Then
		$iColor = _WinAPI_SwitchColor($iColor)
	EndIf
	Return $iColor
EndFunc   ;==>__RGB

#EndRegion Internal Functions
