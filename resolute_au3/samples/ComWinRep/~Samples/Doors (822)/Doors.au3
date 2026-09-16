#AutoIt3Wrapper_Version = Beta
#AutoIt3Wrapper_Icon=Resources\WinPower.ico
#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_Res_Description=Doors Hive System
#AutoIt3Wrapper_Res_Fileversion=0.8.0.823
#AutoIt3Wrapper_Res_FileVersion_AutoIncrement=y
#AutoIt3Wrapper_Res_LegalCopyright=Rizonesoft
#AutoIt3Wrapper_res_requestedExecutionLevel=highestAvailable
#AutoIt3Wrapper_Res_Icon_Add=Resources\emotes\Big-Smile.ico
#AutoIt3Wrapper_Res_Icon_Add=Resources\emotes\Crying.ico
#AutoIt3Wrapper_Res_Icon_Add=Resources\emotes\Devilish.ico
#AutoIt3Wrapper_Res_Icon_Add=Resources\emotes\Glasses.ico
#AutoIt3Wrapper_Res_Icon_Add=Resources\emotes\Grin.ico
#AutoIt3Wrapper_Res_Icon_Add=Resources\emotes\Plain.ico
#AutoIt3Wrapper_Res_Icon_Add=Resources\emotes\Sad.ico
#AutoIt3Wrapper_Res_Icon_Add=Resources\emotes\Smile.ico
#AutoIt3Wrapper_Res_Icon_Add=Resources\emotes\Surprise.ico
#AutoIt3Wrapper_Res_Icon_Add=Resources\emotes\Wink.ico
#AutoIt3Wrapper_Res_Icon_Add=Resources\emotes\Wink.ico
#AutoIt3Wrapper_Res_Icon_Add=Resources\RBEmp.ico
#AutoIt3Wrapper_Res_Icon_Add=Resources\RBFull.ico
Opt("TrayMenuMode", 1)
Opt("GUIOnEventMode", 1)
Opt("GUIResizeMode", 1)
Opt("MustDeclareVars", 1)
Global Const $SS_LEFT = 0
Global Const $SS_CENTER = 1
Global Const $SS_RIGHT = 2
Global Const $SS_ICON = 3
Global Const $SS_BLACKRECT = 4
Global Const $SS_GRAYRECT = 5
Global Const $SS_WHITERECT = 6
Global Const $SS_BLACKFRAME = 7
Global Const $SS_GRAYFRAME = 8
Global Const $SS_WHITEFRAME = 9
Global Const $SS_SIMPLE = 11
Global Const $SS_LEFTNOWORDWRAP = 12
Global Const $SS_BITMAP = 14
Global Const $SS_ETCHEDHORZ = 16
Global Const $SS_ETCHEDVERT = 17
Global Const $SS_ETCHEDFRAME = 18
Global Const $SS_NOPREFIX = 128
Global Const $SS_NOTIFY = 256
Global Const $SS_CENTERIMAGE = 512
Global Const $SS_RIGHTJUST = 1024
Global Const $SS_SUNKEN = 4096
Global Const $GUI_SS_DEFAULT_LABEL = 0
Global Const $GUI_SS_DEFAULT_GRAPHIC = 0
Global Const $GUI_SS_DEFAULT_ICON = $SS_NOTIFY
Global Const $GUI_SS_DEFAULT_PIC = $SS_NOTIFY
Global Const $GUI_EVENT_CLOSE = -3
Global Const $GUI_EVENT_MINIMIZE = -4
Global Const $GUI_EVENT_RESTORE = -5
Global Const $GUI_EVENT_MAXIMIZE = -6
Global Const $GUI_EVENT_PRIMARYDOWN = -7
Global Const $GUI_EVENT_PRIMARYUP = -8
Global Const $GUI_EVENT_SECONDARYDOWN = -9
Global Const $GUI_EVENT_SECONDARYUP = -10
Global Const $GUI_EVENT_MOUSEMOVE = -11
Global Const $GUI_EVENT_RESIZED = -12
Global Const $GUI_EVENT_DROPPED = -13
Global Const $GUI_RUNDEFMSG = "GUI_RUNDEFMSG"
Global Const $GUI_AVISTOP = 0
Global Const $GUI_AVISTART = 1
Global Const $GUI_AVICLOSE = 2
Global Const $GUI_CHECKED = 1
Global Const $GUI_INDETERMINATE = 2
Global Const $GUI_UNCHECKED = 4
Global Const $GUI_DROPACCEPTED = 8
Global Const $GUI_NODROPACCEPTED = 4096
Global Const $GUI_ACCEPTFILES = $GUI_DROPACCEPTED
Global Const $GUI_SHOW = 16
Global Const $GUI_HIDE = 32
Global Const $GUI_ENABLE = 64
Global Const $GUI_DISABLE = 128
Global Const $GUI_FOCUS = 256
Global Const $GUI_NOFOCUS = 8192
Global Const $GUI_DEFBUTTON = 512
Global Const $GUI_EXPAND = 1024
Global Const $GUI_ONTOP = 2048
Global Const $GUI_FONTITALIC = 2
Global Const $GUI_FONTUNDER = 4
Global Const $GUI_FONTSTRIKE = 8
Global Const $GUI_DOCKAUTO = 1
Global Const $GUI_DOCKLEFT = 2
Global Const $GUI_DOCKRIGHT = 4
Global Const $GUI_DOCKHCENTER = 8
Global Const $GUI_DOCKTOP = 32
Global Const $GUI_DOCKBOTTOM = 64
Global Const $GUI_DOCKVCENTER = 128
Global Const $GUI_DOCKWIDTH = 256
Global Const $GUI_DOCKHEIGHT = 512
Global Const $GUI_DOCKSIZE = 768
Global Const $GUI_DOCKMENUBAR = 544
Global Const $GUI_DOCKSTATEBAR = 576
Global Const $GUI_DOCKALL = 802
Global Const $GUI_DOCKBORDERS = 102
Global Const $GUI_GR_CLOSE = 1
Global Const $GUI_GR_LINE = 2
Global Const $GUI_GR_BEZIER = 4
Global Const $GUI_GR_MOVE = 6
Global Const $GUI_GR_COLOR = 8
Global Const $GUI_GR_RECT = 10
Global Const $GUI_GR_ELLIPSE = 12
Global Const $GUI_GR_PIE = 14
Global Const $GUI_GR_DOT = 16
Global Const $GUI_GR_PIXEL = 18
Global Const $GUI_GR_HINT = 20
Global Const $GUI_GR_REFRESH = 22
Global Const $GUI_GR_PENSIZE = 24
Global Const $GUI_GR_NOBKCOLOR = -2
Global Const $GUI_BKCOLOR_DEFAULT = -1
Global Const $GUI_BKCOLOR_TRANSPARENT = -2
Global Const $GUI_BKCOLOR_LV_ALTERNATE = -33554432
Global Const $GUI_WS_EX_PARENTDRAG = 1048576
Global Const $GMEM_FIXED = 0
Global Const $GMEM_MOVEABLE = 2
Global Const $GMEM_NOCOMPACT = 16
Global Const $GMEM_NODISCARD = 32
Global Const $GMEM_ZEROINIT = 64
Global Const $GMEM_MODIFY = 128
Global Const $GMEM_DISCARDABLE = 256
Global Const $GMEM_NOT_BANKED = 4096
Global Const $GMEM_SHARE = 8192
Global Const $GMEM_DDESHARE = 8192
Global Const $GMEM_NOTIFY = 16384
Global Const $GMEM_LOWER = 4096
Global Const $GMEM_VALID_FLAGS = 32626
Global Const $GMEM_INVALID_HANDLE = 32768
Global Const $GPTR = $GMEM_FIXED + $GMEM_ZEROINIT
Global Const $GHND = $GMEM_MOVEABLE + $GMEM_ZEROINIT
Global Const $MEM_COMMIT = 4096
Global Const $MEM_RESERVE = 8192
Global Const $MEM_TOP_DOWN = 1048576
Global Const $MEM_SHARED = 134217728
Global Const $PAGE_NOACCESS = 1
Global Const $PAGE_READONLY = 2
Global Const $PAGE_READWRITE = 4
Global Const $PAGE_EXECUTE = 16
Global Const $PAGE_EXECUTE_READ = 32
Global Const $PAGE_EXECUTE_READWRITE = 64
Global Const $PAGE_GUARD = 256
Global Const $PAGE_NOCACHE = 512
Global Const $MEM_DECOMMIT = 16384
Global Const $MEM_RELEASE = 32768
Global Const $TAGPOINT = "struct;long X;long Y;endstruct"
Global Const $TAGRECT = "struct;long Left;long Top;long Right;long Bottom;endstruct"
Global Const $TAGSIZE = "struct;long X;long Y;endstruct"
Global Const $TAGMARGINS = "int cxLeftWidth;int cxRightWidth;int cyTopHeight;int cyBottomHeight"
Global Const $TAGFILETIME = "struct;dword Lo;dword Hi;endstruct"
Global Const $TAGSYSTEMTIME = "struct;word Year;word Month;word Dow;word Day;word Hour;word Minute;word Second;word MSeconds;endstruct"
Global Const $TAGTIME_ZONE_INFORMATION = "struct;long Bias;wchar StdName[32];word StdDate[8];long StdBias;wchar DayName[32];word DayDate[8];long DayBias;endstruct"
Global Const $TAGNMHDR = "struct;hwnd hWndFrom;uint_ptr IDFrom;INT Code;endstruct"
Global Const $TAGCOMBOBOXEXITEM = "uint Mask;int_ptr Item;ptr Text;int TextMax;int Image;int SelectedImage;int OverlayImage;" & "int Indent;lparam Param"
Global Const $TAGNMCBEDRAGBEGIN = $TAGNMHDR & ";int ItemID;wchar szText[260]"
Global Const $TAGNMCBEENDEDIT = $TAGNMHDR & ";bool fChanged;int NewSelection;wchar szText[260];int Why"
Global Const $TAGNMCOMBOBOXEX = $TAGNMHDR & ";uint Mask;int_ptr Item;ptr Text;int TextMax;int Image;" & "int SelectedImage;int OverlayImage;int Indent;lparam Param"
Global Const $TAGDTPRANGE = "word MinYear;word MinMonth;word MinDOW;word MinDay;word MinHour;word MinMinute;" & "word MinSecond;word MinMSecond;word MaxYear;word MaxMonth;word MaxDOW;word MaxDay;word MaxHour;" & "word MaxMinute;word MaxSecond;word MaxMSecond;bool MinValid;bool MaxValid"
Global Const $TAGNMDATETIMECHANGE = $TAGNMHDR & ";dword Flag;" & $TAGSYSTEMTIME
Global Const $TAGNMDATETIMEFORMAT = $TAGNMHDR & ";ptr Format;" & $TAGSYSTEMTIME & ";ptr pDisplay;wchar Display[64]"
Global Const $TAGNMDATETIMEFORMATQUERY = $TAGNMHDR & ";ptr Format;struct;long SizeX;long SizeY;endstruct"
Global Const $TAGNMDATETIMEKEYDOWN = $TAGNMHDR & ";int VirtKey;ptr Format;" & $TAGSYSTEMTIME
Global Const $TAGNMDATETIMESTRING = $TAGNMHDR & ";ptr UserString;" & $TAGSYSTEMTIME & ";dword Flags"
Global Const $TAGEVENTLOGRECORD = "dword Length;dword Reserved;dword RecordNumber;dword TimeGenerated;dword TimeWritten;dword EventID;" & "word EventType;word NumStrings;word EventCategory;word ReservedFlags;dword ClosingRecordNumber;dword StringOffset;" & "dword UserSidLength;dword UserSidOffset;dword DataLength;dword DataOffset"
Global Const $TAGGDIPBITMAPDATA = "uint Width;uint Height;int Stride;int Format;ptr Scan0;uint_ptr Reserved"
Global Const $TAGGDIPENCODERPARAM = "byte GUID[16];ulong Count;ulong Type;ptr Values"
Global Const $TAGGDIPENCODERPARAMS = "uint Count;byte Params[1]"
Global Const $TAGGDIPRECTF = "float X;float Y;float Width;float Height"
Global Const $TAGGDIPSTARTUPINPUT = "uint Version;ptr Callback;bool NoThread;bool NoCodecs"
Global Const $TAGGDIPSTARTUPOUTPUT = "ptr HookProc;ptr UnhookProc"
Global Const $TAGGDIPIMAGECODECINFO = "byte CLSID[16];byte FormatID[16];ptr CodecName;ptr DllName;ptr FormatDesc;ptr FileExt;" & "ptr MimeType;dword Flags;dword Version;dword SigCount;dword SigSize;ptr SigPattern;ptr SigMask"
Global Const $TAGGDIPPENCODERPARAMS = "uint Count;byte Params[1]"
Global Const $TAGHDITEM = "uint Mask;int XY;ptr Text;handle hBMP;int TextMax;int Fmt;lparam Param;int Image;int Order;uint Type;ptr pFilter;uint State"
Global Const $TAGNMHDDISPINFO = $TAGNMHDR & ";int Item;uint Mask;ptr Text;int TextMax;int Image;lparam lParam"
Global Const $TAGNMHDFILTERBTNCLICK = $TAGNMHDR & ";int Item;" & $TAGRECT
Global Const $TAGNMHEADER = $TAGNMHDR & ";int Item;int Button;ptr pItem"
Global Const $TAGGETIPADDRESS = "byte Field4;byte Field3;byte Field2;byte Field1"
Global Const $TAGNMIPADDRESS = $TAGNMHDR & ";int Field;int Value"
Global Const $TAGLVFINDINFO = "struct;uint Flags;ptr Text;lparam Param;" & $TAGPOINT & ";uint Direction;endstruct"
Global Const $TAGLVHITTESTINFO = $TAGPOINT & ";uint Flags;int Item;int SubItem;int iGroup"
Global Const $TAGLVITEM = "struct;uint Mask;int Item;int SubItem;uint State;uint StateMask;ptr Text;int TextMax;int Image;lparam Param;" & "int Indent;int GroupID;uint Columns;ptr pColumns;ptr piColFmt;int iGroup;endstruct"
Global Const $TAGNMLISTVIEW = $TAGNMHDR & ";int Item;int SubItem;uint NewState;uint OldState;uint Changed;" & "struct;long ActionX;long ActionY;endstruct;lparam Param"
Global Const $TAGNMLVCUSTOMDRAW = "struct;" & $TAGNMHDR & ";dword dwDrawStage;handle hdc;" & $TAGRECT & ";dword_ptr dwItemSpec;uint uItemState;lparam lItemlParam;endstruct" & ";dword clrText;dword clrTextBk;int iSubItem;dword dwItemType;dword clrFace;int iIconEffect;" & "int iIconPhase;int iPartId;int iStateId;struct;long TextLeft;long TextTop;long TextRight;long TextBottom;endstruct;uint uAlign"
Global Const $TAGNMLVDISPINFO = $TAGNMHDR & ";" & $TAGLVITEM
Global Const $TAGNMLVFINDITEM = $TAGNMHDR & ";int Start;" & $TAGLVFINDINFO
Global Const $TAGNMLVGETINFOTIP = $TAGNMHDR & ";dword Flags;ptr Text;int TextMax;int Item;int SubItem;lparam lParam"
Global Const $TAGNMITEMACTIVATE = $TAGNMHDR & ";int Index;int SubItem;uint NewState;uint OldState;uint Changed;" & $TAGPOINT & ";lparam lParam;uint KeyFlags"
Global Const $TAGNMLVKEYDOWN = "align 1;" & $TAGNMHDR & ";word VKey;uint Flags"
Global Const $TAGNMLVSCROLL = $TAGNMHDR & ";int DX;int DY"
Global Const $TAGMCHITTESTINFO = "uint Size;" & $TAGPOINT & ";uint Hit;" & $TAGSYSTEMTIME & ";" & $TAGRECT & ";int iOffset;int iRow;int iCol"
Global Const $TAGMCMONTHRANGE = "word MinYear;word MinMonth;word MinDOW;word MinDay;word MinHour;word MinMinute;word MinSecond;" & "word MinMSeconds;word MaxYear;word MaxMonth;word MaxDOW;word MaxDay;word MaxHour;word MaxMinute;word MaxSecond;" & "word MaxMSeconds;short Span"
Global Const $TAGMCRANGE = "word MinYear;word MinMonth;word MinDOW;word MinDay;word MinHour;word MinMinute;word MinSecond;" & "word MinMSeconds;word MaxYear;word MaxMonth;word MaxDOW;word MaxDay;word MaxHour;word MaxMinute;word MaxSecond;" & "word MaxMSeconds;short MinSet;short MaxSet"
Global Const $TAGMCSELRANGE = "word MinYear;word MinMonth;word MinDOW;word MinDay;word MinHour;word MinMinute;word MinSecond;" & "word MinMSeconds;word MaxYear;word MaxMonth;word MaxDOW;word MaxDay;word MaxHour;word MaxMinute;word MaxSecond;" & "word MaxMSeconds"
Global Const $TAGNMDAYSTATE = $TAGNMHDR & ";" & $TAGSYSTEMTIME & ";int DayState;ptr pDayState"
Global Const $TAGNMSELCHANGE = $TAGNMHDR & ";struct;word BegYear;word BegMonth;word BegDOW;word BegDay;word BegHour;word BegMinute;word BegSecond;word BegMSeconds;endstruct;" & "struct;word EndYear;word EndMonth;word EndDOW;word EndDay;word EndHour;word EndMinute;word EndSecond;word EndMSeconds;endstruct"
Global Const $TAGNMOBJECTNOTIFY = $TAGNMHDR & ";int Item;ptr piid;ptr pObject;long Result;dword dwFlags"
Global Const $TAGNMTCKEYDOWN = "align 1;" & $TAGNMHDR & ";word VKey;uint Flags"
Global Const $TAGTVITEM = "struct;uint Mask;handle hItem;uint State;uint StateMask;ptr Text;int TextMax;int Image;int SelectedImage;" & "int Children;lparam Param;endstruct"
Global Const $TAGTVITEMEX = "struct;" & $TAGTVITEM & ";int Integral;uint uStateEx;hwnd hwnd;int iExpandedImage;int iReserved;endstruct"
Global Const $TAGNMTREEVIEW = $TAGNMHDR & ";uint Action;" & "struct;uint OldMask;handle OldhItem;uint OldState;uint OldStateMask;" & "ptr OldText;int OldTextMax;int OldImage;int OldSelectedImage;int OldChildren;lparam OldParam;endstruct;" & "struct;uint NewMask;handle NewhItem;uint NewState;uint NewStateMask;" & "ptr NewText;int NewTextMax;int NewImage;int NewSelectedImage;int NewChildren;lparam NewParam;endstruct;" & "struct;long PointX;long PointY;endstruct"
Global Const $TAGNMTVCUSTOMDRAW = "struct;" & $TAGNMHDR & ";dword DrawStage;handle HDC;" & $TAGRECT & ";dword_ptr ItemSpec;uint ItemState;lparam ItemParam;endstruct" & ";dword ClrText;dword ClrTextBk;int Level"
Global Const $TAGNMTVDISPINFO = $TAGNMHDR & ";" & $TAGTVITEM
Global Const $TAGNMTVGETINFOTIP = $TAGNMHDR & ";ptr Text;int TextMax;handle hItem;lparam lParam"
Global Const $TAGTVHITTESTINFO = $TAGPOINT & ";uint Flags;handle Item"
Global Const $TAGNMTVKEYDOWN = "align 1;" & $TAGNMHDR & ";word VKey;uint Flags"
Global Const $TAGNMMOUSE = $TAGNMHDR & ";dword_ptr ItemSpec;dword_ptr ItemData;" & $TAGPOINT & ";lparam HitInfo"
Global Const $TAGTOKEN_PRIVILEGES = "dword Count;align 4;int64 LUID;dword Attributes"
Global Const $TAGIMAGEINFO = "handle hBitmap;handle hMask;int Unused1;int Unused2;" & $TAGRECT
Global Const $TAGMENUINFO = "dword Size;INT Mask;dword Style;uint YMax;handle hBack;dword ContextHelpID;ulong_ptr MenuData"
Global Const $TAGMENUITEMINFO = "uint Size;uint Mask;uint Type;uint State;uint ID;handle SubMenu;handle BmpChecked;handle BmpUnchecked;" & "ulong_ptr ItemData;ptr TypeData;uint CCH;handle BmpItem"
Global Const $TAGREBARBANDINFO = "uint cbSize;uint fMask;uint fStyle;dword clrFore;dword clrBack;ptr lpText;uint cch;" & "int iImage;hwnd hwndChild;uint cxMinChild;uint cyMinChild;uint cx;handle hbmBack;uint wID;uint cyChild;uint cyMaxChild;" & "uint cyIntegral;uint cxIdeal;lparam lParam;uint cxHeader;" & $TAGRECT & ";uint uChevronState"
Global Const $TAGNMREBARAUTOBREAK = $TAGNMHDR & ";uint uBand;uint wID;lparam lParam;uint uMsg;uint fStyleCurrent;bool fAutoBreak"
Global Const $TAGNMRBAUTOSIZE = $TAGNMHDR & ";bool fChanged;" & "struct;long TargetLeft;long TargetTop;long TargetRight;long TargetBottom;endstruct;" & "struct;long ActualLeft;long ActualTop;long ActualRight;long ActualBottom;endstruct"
Global Const $TAGNMREBAR = $TAGNMHDR & ";dword dwMask;uint uBand;uint fStyle;uint wID;lparam lParam"
Global Const $TAGNMREBARCHEVRON = $TAGNMHDR & ";uint uBand;uint wID;lparam lParam;" & $TAGRECT & ";lparam lParamNM"
Global Const $TAGNMREBARCHILDSIZE = $TAGNMHDR & ";uint uBand;uint wID;" & "struct;long CLeft;long CTop;long CRight;long CBottom;endstruct;" & "struct;long BLeft;long BTop;long BRight;long BBottom;endstruct"
Global Const $TAGCOLORSCHEME = "dword Size;dword BtnHighlight;dword BtnShadow"
Global Const $TAGNMTOOLBAR = $TAGNMHDR & ";int iItem;" & "struct;int iBitmap;int idCommand;byte fsState;byte fsStyle;dword_ptr dwData;int_ptr iString;endstruct" & ";int cchText;ptr pszText;" & $TAGRECT
Global Const $TAGNMTBHOTITEM = $TAGNMHDR & ";int idOld;int idNew;dword dwFlags"
Global Const $TAGTBBUTTON = "int Bitmap;int Command;byte State;byte Style;align;dword_ptr Param;int_ptr String"
Global Const $TAGTBBUTTONINFO = "uint Size;dword Mask;int Command;int Image;byte State;byte Style;word CX;dword_ptr Param;ptr Text;int TextMax"
Global Const $TAGNETRESOURCE = "dword Scope;dword Type;dword DisplayType;dword Usage;ptr LocalName;ptr RemoteName;ptr Comment;ptr Provider"
Global Const $TAGOVERLAPPED = "ulong_ptr Internal;ulong_ptr InternalHigh;struct;dword Offset;dword OffsetHigh;endstruct;handle hEvent"
Global Const $TAGOPENFILENAME = "dword StructSize;hwnd hwndOwner;handle hInstance;ptr lpstrFilter;ptr lpstrCustomFilter;" & "dword nMaxCustFilter;dword nFilterIndex;ptr lpstrFile;dword nMaxFile;ptr lpstrFileTitle;dword nMaxFileTitle;" & "ptr lpstrInitialDir;ptr lpstrTitle;dword Flags;word nFileOffset;word nFileExtension;ptr lpstrDefExt;lparam lCustData;" & "ptr lpfnHook;ptr lpTemplateName;ptr pvReserved;dword dwReserved;dword FlagsEx"
Global Const $TAGBITMAPINFO = "struct;dword Size;long Width;long Height;word Planes;word BitCount;dword Compression;dword SizeImage;" & "long XPelsPerMeter;long YPelsPerMeter;dword ClrUsed;dword ClrImportant;endstruct;dword RGBQuad"
Global Const $TAGBLENDFUNCTION = "byte Op;byte Flags;byte Alpha;byte Format"
Global Const $TAGGUID = "ulong Data1;ushort Data2;ushort Data3;byte Data4[8]"
Global Const $TAGWINDOWPLACEMENT = "uint length;uint flags;uint showCmd;long ptMinPosition[2];long ptMaxPosition[2];long rcNormalPosition[4]"
Global Const $TAGWINDOWPOS = "hwnd hWnd;hwnd InsertAfter;int X;int Y;int CX;int CY;uint Flags"
Global Const $TAGSCROLLINFO = "uint cbSize;uint fMask;int nMin;int nMax;uint nPage;int nPos;int nTrackPos"
Global Const $TAGSCROLLBARINFO = "dword cbSize;" & $TAGRECT & ";int dxyLineButton;int xyThumbTop;" & "int xyThumbBottom;int reserved;dword rgstate[6]"
Global Const $TAGLOGFONT = "long Height;long Width;long Escapement;long Orientation;long Weight;byte Italic;byte Underline;" & "byte Strikeout;byte CharSet;byte OutPrecision;byte ClipPrecision;byte Quality;byte PitchAndFamily;wchar FaceName[32]"
Global Const $TAGKBDLLHOOKSTRUCT = "dword vkCode;dword scanCode;dword flags;dword time;ulong_ptr dwExtraInfo"
Global Const $TAGPROCESS_INFORMATION = "handle hProcess;handle hThread;dword ProcessID;dword ThreadID"
Global Const $TAGSTARTUPINFO = "dword Size;ptr Reserved1;ptr Desktop;ptr Title;dword X;dword Y;dword XSize;dword YSize;dword XCountChars;" & "dword YCountChars;dword FillAttribute;dword Flags;word ShowWindow;word Reserved2;ptr Reserved3;handle StdInput;" & "handle StdOutput;handle StdError"
Global Const $TAGSECURITY_ATTRIBUTES = "dword Length;ptr Descriptor;bool InheritHandle"
Global Const $TAGWIN32_FIND_DATA = "dword dwFileAttributes;dword ftCreationTime[2];dword ftLastAccessTime[2];dword ftLastWriteTime[2];dword nFileSizeHigh;dword nFileSizeLow;dword dwReserved0;dword dwReserved1;wchar cFileName[260];wchar cAlternateFileName[14]"
Global Const $TAGTEXTMETRIC = "long tmHeight;long tmAscent;long tmDescent;long tmInternalLeading;long tmExternalLeading;" & "long tmAveCharWidth;long tmMaxCharWidth;long tmWeight;long tmOverhang;long tmDigitizedAspectX;long tmDigitizedAspectY;" & "wchar tmFirstChar;wchar tmLastChar;wchar tmDefaultChar;wchar tmBreakChar;byte tmItalic;byte tmUnderlined;byte tmStruckOut;" & "byte tmPitchAndFamily;byte tmCharSet"
Global Const $PROCESS_TERMINATE = 1
Global Const $PROCESS_CREATE_THREAD = 2
Global Const $PROCESS_SET_SESSIONID = 4
Global Const $PROCESS_VM_OPERATION = 8
Global Const $PROCESS_VM_READ = 16
Global Const $PROCESS_VM_WRITE = 32
Global Const $PROCESS_DUP_HANDLE = 64
Global Const $PROCESS_CREATE_PROCESS = 128
Global Const $PROCESS_SET_QUOTA = 256
Global Const $PROCESS_SET_INFORMATION = 512
Global Const $PROCESS_QUERY_INFORMATION = 1024
Global Const $PROCESS_SUSPEND_RESUME = 2048
Global Const $PROCESS_ALL_ACCESS = 2035711
Global Const $ERROR_NO_TOKEN = 1008
Global Const $SE_ASSIGNPRIMARYTOKEN_NAME = "SeAssignPrimaryTokenPrivilege"
Global Const $SE_AUDIT_NAME = "SeAuditPrivilege"
Global Const $SE_BACKUP_NAME = "SeBackupPrivilege"
Global Const $SE_CHANGE_NOTIFY_NAME = "SeChangeNotifyPrivilege"
Global Const $SE_CREATE_GLOBAL_NAME = "SeCreateGlobalPrivilege"
Global Const $SE_CREATE_PAGEFILE_NAME = "SeCreatePagefilePrivilege"
Global Const $SE_CREATE_PERMANENT_NAME = "SeCreatePermanentPrivilege"
Global Const $SE_CREATE_TOKEN_NAME = "SeCreateTokenPrivilege"
Global Const $SE_DEBUG_NAME = "SeDebugPrivilege"
Global Const $SE_ENABLE_DELEGATION_NAME = "SeEnableDelegationPrivilege"
Global Const $SE_IMPERSONATE_NAME = "SeImpersonatePrivilege"
Global Const $SE_INC_BASE_PRIORITY_NAME = "SeIncreaseBasePriorityPrivilege"
Global Const $SE_INCREASE_QUOTA_NAME = "SeIncreaseQuotaPrivilege"
Global Const $SE_LOAD_DRIVER_NAME = "SeLoadDriverPrivilege"
Global Const $SE_LOCK_MEMORY_NAME = "SeLockMemoryPrivilege"
Global Const $SE_MACHINE_ACCOUNT_NAME = "SeMachineAccountPrivilege"
Global Const $SE_MANAGE_VOLUME_NAME = "SeManageVolumePrivilege"
Global Const $SE_PROF_SINGLE_PROCESS_NAME = "SeProfileSingleProcessPrivilege"
Global Const $SE_REMOTE_SHUTDOWN_NAME = "SeRemoteShutdownPrivilege"
Global Const $SE_RESTORE_NAME = "SeRestorePrivilege"
Global Const $SE_SECURITY_NAME = "SeSecurityPrivilege"
Global Const $SE_SHUTDOWN_NAME = "SeShutdownPrivilege"
Global Const $SE_SYNC_AGENT_NAME = "SeSyncAgentPrivilege"
Global Const $SE_SYSTEM_ENVIRONMENT_NAME = "SeSystemEnvironmentPrivilege"
Global Const $SE_SYSTEM_PROFILE_NAME = "SeSystemProfilePrivilege"
Global Const $SE_SYSTEMTIME_NAME = "SeSystemtimePrivilege"
Global Const $SE_TAKE_OWNERSHIP_NAME = "SeTakeOwnershipPrivilege"
Global Const $SE_TCB_NAME = "SeTcbPrivilege"
Global Const $SE_UNSOLICITED_INPUT_NAME = "SeUnsolicitedInputPrivilege"
Global Const $SE_UNDOCK_NAME = "SeUndockPrivilege"
Global Const $SE_PRIVILEGE_ENABLED_BY_DEFAULT = 1
Global Const $SE_PRIVILEGE_ENABLED = 2
Global Const $SE_PRIVILEGE_REMOVED = 4
Global Const $SE_PRIVILEGE_USED_FOR_ACCESS = -2147483648
Global Const $SE_GROUP_MANDATORY = 1
Global Const $SE_GROUP_ENABLED_BY_DEFAULT = 2
Global Const $SE_GROUP_ENABLED = 4
Global Const $SE_GROUP_OWNER = 8
Global Const $SE_GROUP_USE_FOR_DENY_ONLY = 16
Global Const $SE_GROUP_INTEGRITY = 32
Global Const $SE_GROUP_INTEGRITY_ENABLED = 64
Global Const $SE_GROUP_RESOURCE = 536870912
Global Const $SE_GROUP_LOGON_ID = -1073741824
Global Enum $TOKENPRIMARY = 1, $TOKENIMPERSONATION
Global Enum $SECURITYANONYMOUS = 0, $SECURITYIDENTIFICATION, $SECURITYIMPERSONATION, $SECURITYDELEGATION
Global Enum $TOKENUSER = 1, $TOKENGROUPS, $TOKENPRIVILEGES, $TOKENOWNER, $TOKENPRIMARYGROUP, $TOKENDEFAULTDACL, $TOKENSOURCE, $TOKENTYPE, $TOKENIMPERSONATIONLEVEL, $TOKENSTATISTICS, $TOKENRESTRICTEDSIDS, $TOKENSESSIONID, $TOKENGROUPSANDPRIVILEGES, $TOKENSESSIONREFERENCE, $TOKENSANDBOXINERT, $TOKENAUDITPOLICY, $TOKENORIGIN, $TOKENELEVATIONTYPE, $TOKENLINKEDTOKEN, $TOKENELEVATION, $TOKENHASRESTRICTIONS, $TOKENACCESSINFORMATION, $TOKENVIRTUALIZATIONALLOWED, $TOKENVIRTUALIZATIONENABLED, $TOKENINTEGRITYLEVEL, $TOKENUIACCESS, $TOKENMANDATORYPOLICY, $TOKENLOGONSID
Global Const $TOKEN_ASSIGN_PRIMARY = 1
Global Const $TOKEN_DUPLICATE = 2
Global Const $TOKEN_IMPERSONATE = 4
Global Const $TOKEN_QUERY = 8
Global Const $TOKEN_QUERY_SOURCE = 16
Global Const $TOKEN_ADJUST_PRIVILEGES = 32
Global Const $TOKEN_ADJUST_GROUPS = 64
Global Const $TOKEN_ADJUST_DEFAULT = 128
Global Const $TOKEN_ADJUST_SESSIONID = 256
Global Const $TOKEN_ALL_ACCESS = 983551
Global Const $TOKEN_READ = 131080
Global Const $TOKEN_WRITE = 131296
Global Const $TOKEN_EXECUTE = 131072
Global Const $TOKEN_HAS_TRAVERSE_PRIVILEGE = 1
Global Const $TOKEN_HAS_BACKUP_PRIVILEGE = 2
Global Const $TOKEN_HAS_RESTORE_PRIVILEGE = 4
Global Const $TOKEN_HAS_ADMIN_GROUP = 8
Global Const $TOKEN_IS_RESTRICTED = 16
Global Const $TOKEN_SESSION_NOT_REFERENCED = 32
Global Const $TOKEN_SANDBOX_INERT = 64
Global Const $TOKEN_HAS_IMPERSONATE_PRIVILEGE = 128
Global Const $RIGHTS_DELETE = 65536
Global Const $READ_CONTROL = 131072
Global Const $WRITE_DAC = 262144
Global Const $WRITE_OWNER = 524288
Global Const $SYNCHRONIZE = 1048576
Global Const $STANDARD_RIGHTS_REQUIRED = 983040
Global Const $STANDARD_RIGHTS_READ = $READ_CONTROL
Global Const $STANDARD_RIGHTS_WRITE = $READ_CONTROL
Global Const $STANDARD_RIGHTS_EXECUTE = $READ_CONTROL
Global Const $STANDARD_RIGHTS_ALL = 2031616
Global Const $SPECIFIC_RIGHTS_ALL = 65535
Global Enum $NOT_USED_ACCESS = 0, $GRANT_ACCESS, $SET_ACCESS, $DENY_ACCESS, $REVOKE_ACCESS, $SET_AUDIT_SUCCESS, $SET_AUDIT_FAILURE
Global Enum $TRUSTEE_IS_UNKNOWN = 0, $TRUSTEE_IS_USER, $TRUSTEE_IS_GROUP, $TRUSTEE_IS_DOMAIN, $TRUSTEE_IS_ALIAS, $TRUSTEE_IS_WELL_KNOWN_GROUP, $TRUSTEE_IS_DELETED, $TRUSTEE_IS_INVALID, $TRUSTEE_IS_COMPUTER
Global Const $LOGON_WITH_PROFILE = 1
Global Const $LOGON_NETCREDENTIALS_ONLY = 2
Global Enum $SIDTYPEUSER = 1, $SIDTYPEGROUP, $SIDTYPEDOMAIN, $SIDTYPEALIAS, $SIDTYPEWELLKNOWNGROUP, $SIDTYPEDELETEDACCOUNT, $SIDTYPEINVALID, $SIDTYPEUNKNOWN, $SIDTYPECOMPUTER, $SIDTYPELABEL
Global Const $SID_ADMINISTRATORS = "S-1-5-32-544"
Global Const $SID_USERS = "S-1-5-32-545"
Global Const $SID_GUESTS = "S-1-5-32-546"
Global Const $SID_ACCOUNT_OPERATORS = "S-1-5-32-548"
Global Const $SID_SERVER_OPERATORS = "S-1-5-32-549"
Global Const $SID_PRINT_OPERATORS = "S-1-5-32-550"
Global Const $SID_BACKUP_OPERATORS = "S-1-5-32-551"
Global Const $SID_REPLICATOR = "S-1-5-32-552"
Global Const $SID_OWNER = "S-1-3-0"
Global Const $SID_EVERYONE = "S-1-1-0"
Global Const $SID_NETWORK = "S-1-5-2"
Global Const $SID_INTERACTIVE = "S-1-5-4"
Global Const $SID_SYSTEM = "S-1-5-18"
Global Const $SID_AUTHENTICATED_USERS = "S-1-5-11"
Global Const $SID_SCHANNEL_AUTHENTICATION = "S-1-5-64-14"
Global Const $SID_DIGEST_AUTHENTICATION = "S-1-5-64-21"
Global Const $SID_NT_SERVICE = "S-1-5-80"
Global Const $SID_UNTRUSTED_MANDATORY_LEVEL = "S-1-16-0"
Global Const $SID_LOW_MANDATORY_LEVEL = "S-1-16-4096"
Global Const $SID_MEDIUM_MANDATORY_LEVEL = "S-1-16-8192"
Global Const $SID_MEDIUM_PLUS_MANDATORY_LEVEL = "S-1-16-8448"
Global Const $SID_HIGH_MANDATORY_LEVEL = "S-1-16-12288"
Global Const $SID_SYSTEM_MANDATORY_LEVEL = "S-1-16-16384"
Global Const $SID_PROTECTED_PROCESS_MANDATORY_LEVEL = "S-1-16-20480"
Global Const $SID_SECURE_PROCESS_MANDATORY_LEVEL = "S-1-16-28672"
Global Const $SID_ALL_SERVICES = "S-1-5-80-0"
Func _WINAPI_GETLASTERROR($CURERR = @error, $CUREXT = @extended)
	Local $ARESULT = DllCall("kernel32.dll", "dword", "GetLastError")
	Return SetError($CURERR, $CUREXT, $ARESULT[0])
EndFunc
Func _WINAPI_SETLASTERROR($IERRCODE, $CURERR = @error, $CUREXT = @extended)
	DllCall("kernel32.dll", "none", "SetLastError", "dword", $IERRCODE)
	Return SetError($CURERR, $CUREXT)
EndFunc
Global Const $FC_NOOVERWRITE = 0
Global Const $FC_OVERWRITE = 1
Global Const $FT_MODIFIED = 0
Global Const $FT_CREATED = 1
Global Const $FT_ACCESSED = 2
Global Const $FO_READ = 0
Global Const $FO_APPEND = 1
Global Const $FO_OVERWRITE = 2
Global Const $FO_BINARY = 16
Global Const $FO_UNICODE = 32
Global Const $FO_UTF16_LE = 32
Global Const $FO_UTF16_BE = 64
Global Const $FO_UTF8 = 128
Global Const $FO_UTF8_NOBOM = 256
Global Const $EOF = -1
Global Const $FD_FILEMUSTEXIST = 1
Global Const $FD_PATHMUSTEXIST = 2
Global Const $FD_MULTISELECT = 4
Global Const $FD_PROMPTCREATENEW = 8
Global Const $FD_PROMPTOVERWRITE = 16
Global Const $CREATE_NEW = 1
Global Const $CREATE_ALWAYS = 2
Global Const $OPEN_EXISTING = 3
Global Const $OPEN_ALWAYS = 4
Global Const $TRUNCATE_EXISTING = 5
Global Const $INVALID_SET_FILE_POINTER = -1
Global Const $FILE_BEGIN = 0
Global Const $FILE_CURRENT = 1
Global Const $FILE_END = 2
Global Const $FILE_ATTRIBUTE_READONLY = 1
Global Const $FILE_ATTRIBUTE_HIDDEN = 2
Global Const $FILE_ATTRIBUTE_SYSTEM = 4
Global Const $FILE_ATTRIBUTE_DIRECTORY = 16
Global Const $FILE_ATTRIBUTE_ARCHIVE = 32
Global Const $FILE_ATTRIBUTE_DEVICE = 64
Global Const $FILE_ATTRIBUTE_NORMAL = 128
Global Const $FILE_ATTRIBUTE_TEMPORARY = 256
Global Const $FILE_ATTRIBUTE_SPARSE_FILE = 512
Global Const $FILE_ATTRIBUTE_REPARSE_POINT = 1024
Global Const $FILE_ATTRIBUTE_COMPRESSED = 2048
Global Const $FILE_ATTRIBUTE_OFFLINE = 4096
Global Const $FILE_ATTRIBUTE_NOT_CONTENT_INDEXED = 8192
Global Const $FILE_ATTRIBUTE_ENCRYPTED = 16384
Global Const $FILE_SHARE_READ = 1
Global Const $FILE_SHARE_WRITE = 2
Global Const $FILE_SHARE_DELETE = 4
Global Const $GENERIC_ALL = 268435456
Global Const $GENERIC_EXECUTE = 536870912
Global Const $GENERIC_WRITE = 1073741824
Global Const $GENERIC_READ = -2147483648
Func _SENDMESSAGE($HWND, $IMSG, $WPARAM = 0, $LPARAM = 0, $IRETURN = 0, $WPARAMTYPE = "wparam", $LPARAMTYPE = "lparam", $SRETURNTYPE = "lresult")
	Local $ARESULT = DllCall("user32.dll", $SRETURNTYPE, "SendMessageW", "hwnd", $HWND, "uint", $IMSG, $WPARAMTYPE, $WPARAM, $LPARAMTYPE, $LPARAM)
	If @error Then Return SetError(@error, @extended, "")
	If $IRETURN >= 0 And $IRETURN <= 4 Then Return $ARESULT[$IRETURN]
	Return $ARESULT
EndFunc
Func _SENDMESSAGEA($HWND, $IMSG, $WPARAM = 0, $LPARAM = 0, $IRETURN = 0, $WPARAMTYPE = "wparam", $LPARAMTYPE = "lparam", $SRETURNTYPE = "lresult")
	Local $ARESULT = DllCall("user32.dll", $SRETURNTYPE, "SendMessageA", "hwnd", $HWND, "uint", $IMSG, $WPARAMTYPE, $WPARAM, $LPARAMTYPE, $LPARAM)
	If @error Then Return SetError(@error, @extended, "")
	If $IRETURN >= 0 And $IRETURN <= 4 Then Return $ARESULT[$IRETURN]
	Return $ARESULT
EndFunc
Global $__GAINPROCESS_WINAPI[64][2] = [[0, 0]]
Global $__GAWINLIST_WINAPI[64][2] = [[0, 0]]
Global Const $__WINAPICONSTANT_WM_SETFONT = 48
Global Const $__WINAPICONSTANT_FW_NORMAL = 400
Global Const $__WINAPICONSTANT_DEFAULT_CHARSET = 1
Global Const $__WINAPICONSTANT_OUT_DEFAULT_PRECIS = 0
Global Const $__WINAPICONSTANT_CLIP_DEFAULT_PRECIS = 0
Global Const $__WINAPICONSTANT_DEFAULT_QUALITY = 0
Global Const $__WINAPICONSTANT_FORMAT_MESSAGE_ALLOCATE_BUFFER = 256
Global Const $__WINAPICONSTANT_FORMAT_MESSAGE_FROM_SYSTEM = 4096
Global Const $__WINAPICONSTANT_LOGPIXELSX = 88
Global Const $__WINAPICONSTANT_LOGPIXELSY = 90
Global Const $HGDI_ERROR = Ptr(-1)
Global Const $INVALID_HANDLE_VALUE = Ptr(-1)
Global Const $CLR_INVALID = -1
Global Const $__WINAPICONSTANT_FLASHW_CAPTION = 1
Global Const $__WINAPICONSTANT_FLASHW_TRAY = 2
Global Const $__WINAPICONSTANT_FLASHW_TIMER = 4
Global Const $__WINAPICONSTANT_FLASHW_TIMERNOFG = 12
Global Const $__WINAPICONSTANT_GW_HWNDNEXT = 2
Global Const $__WINAPICONSTANT_GW_CHILD = 5
Global Const $__WINAPICONSTANT_DI_MASK = 1
Global Const $__WINAPICONSTANT_DI_IMAGE = 2
Global Const $__WINAPICONSTANT_DI_NORMAL = 3
Global Const $__WINAPICONSTANT_DI_COMPAT = 4
Global Const $__WINAPICONSTANT_DI_DEFAULTSIZE = 8
Global Const $__WINAPICONSTANT_DI_NOMIRROR = 16
Global Const $__WINAPICONSTANT_DISPLAY_DEVICE_ATTACHED_TO_DESKTOP = 1
Global Const $__WINAPICONSTANT_DISPLAY_DEVICE_PRIMARY_DEVICE = 4
Global Const $__WINAPICONSTANT_DISPLAY_DEVICE_MIRRORING_DRIVER = 8
Global Const $__WINAPICONSTANT_DISPLAY_DEVICE_VGA_COMPATIBLE = 16
Global Const $__WINAPICONSTANT_DISPLAY_DEVICE_REMOVABLE = 32
Global Const $__WINAPICONSTANT_DISPLAY_DEVICE_MODESPRUNED = 134217728
Global Const $NULL_BRUSH = 5
Global Const $NULL_PEN = 8
Global Const $BLACK_BRUSH = 4
Global Const $DKGRAY_BRUSH = 3
Global Const $DC_BRUSH = 18
Global Const $GRAY_BRUSH = 2
Global Const $HOLLOW_BRUSH = $NULL_BRUSH
Global Const $LTGRAY_BRUSH = 1
Global Const $WHITE_BRUSH = 0
Global Const $BLACK_PEN = 7
Global Const $DC_PEN = 19
Global Const $WHITE_PEN = 6
Global Const $ANSI_FIXED_FONT = 11
Global Const $ANSI_VAR_FONT = 12
Global Const $DEVICE_DEFAULT_FONT = 14
Global Const $DEFAULT_GUI_FONT = 17
Global Const $OEM_FIXED_FONT = 10
Global Const $SYSTEM_FONT = 13
Global Const $SYSTEM_FIXED_FONT = 16
Global Const $DEFAULT_PALETTE = 15
Global Const $MB_PRECOMPOSED = 1
Global Const $MB_COMPOSITE = 2
Global Const $MB_USEGLYPHCHARS = 4
Global Const $ULW_ALPHA = 2
Global Const $ULW_COLORKEY = 1
Global Const $ULW_OPAQUE = 4
Global Const $WH_CALLWNDPROC = 4
Global Const $WH_CALLWNDPROCRET = 12
Global Const $WH_CBT = 5
Global Const $WH_DEBUG = 9
Global Const $WH_FOREGROUNDIDLE = 11
Global Const $WH_GETMESSAGE = 3
Global Const $WH_JOURNALPLAYBACK = 1
Global Const $WH_JOURNALRECORD = 0
Global Const $WH_KEYBOARD = 2
Global Const $WH_KEYBOARD_LL = 13
Global Const $WH_MOUSE = 7
Global Const $WH_MOUSE_LL = 14
Global Const $WH_MSGFILTER = -1
Global Const $WH_SHELL = 10
Global Const $WH_SYSMSGFILTER = 6
Global Const $WPF_ASYNCWINDOWPLACEMENT = 4
Global Const $WPF_RESTORETOMAXIMIZED = 2
Global Const $WPF_SETMINPOSITION = 1
Global Const $KF_EXTENDED = 256
Global Const $KF_ALTDOWN = 8192
Global Const $KF_UP = 32768
Global Const $LLKHF_EXTENDED = BitShift($KF_EXTENDED, 8)
Global Const $LLKHF_INJECTED = 16
Global Const $LLKHF_ALTDOWN = BitShift($KF_ALTDOWN, 8)
Global Const $LLKHF_UP = BitShift($KF_UP, 8)
Global Const $OFN_ALLOWMULTISELECT = 512
Global Const $OFN_CREATEPROMPT = 8192
Global Const $OFN_DONTADDTORECENT = 33554432
Global Const $OFN_ENABLEHOOK = 32
Global Const $OFN_ENABLEINCLUDENOTIFY = 4194304
Global Const $OFN_ENABLESIZING = 8388608
Global Const $OFN_ENABLETEMPLATE = 64
Global Const $OFN_ENABLETEMPLATEHANDLE = 128
Global Const $OFN_EXPLORER = 524288
Global Const $OFN_EXTENSIONDIFFERENT = 1024
Global Const $OFN_FILEMUSTEXIST = 4096
Global Const $OFN_FORCESHOWHIDDEN = 268435456
Global Const $OFN_HIDEREADONLY = 4
Global Const $OFN_LONGNAMES = 2097152
Global Const $OFN_NOCHANGEDIR = 8
Global Const $OFN_NODEREFERENCELINKS = 1048576
Global Const $OFN_NOLONGNAMES = 262144
Global Const $OFN_NONETWORKBUTTON = 131072
Global Const $OFN_NOREADONLYRETURN = 32768
Global Const $OFN_NOTESTFILECREATE = 65536
Global Const $OFN_NOVALIDATE = 256
Global Const $OFN_OVERWRITEPROMPT = 2
Global Const $OFN_PATHMUSTEXIST = 2048
Global Const $OFN_READONLY = 1
Global Const $OFN_SHAREAWARE = 16384
Global Const $OFN_SHOWHELP = 16
Global Const $OFN_EX_NOPLACESBAR = 1
Global Const $TMPF_FIXED_PITCH = 1
Global Const $TMPF_VECTOR = 2
Global Const $TMPF_TRUETYPE = 4
Global Const $TMPF_DEVICE = 8
Global Const $DUPLICATE_CLOSE_SOURCE = 1
Global Const $DUPLICATE_SAME_ACCESS = 2
Global Const $TAGCURSORINFO = "dword Size;dword Flags;handle hCursor;" & $TAGPOINT
Global Const $TAGDISPLAY_DEVICE = "dword Size;wchar Name[32];wchar String[128];dword Flags;wchar ID[128];wchar Key[128]"
Global Const $TAGFLASHWINFO = "uint Size;hwnd hWnd;dword Flags;uint Count;dword TimeOut"
Global Const $TAGICONINFO = "bool Icon;dword XHotSpot;dword YHotSpot;handle hMask;handle hColor"
Global Const $TAGMEMORYSTATUSEX = "dword Length;dword MemoryLoad;" & "uint64 TotalPhys;uint64 AvailPhys;uint64 TotalPageFile;uint64 AvailPageFile;" & "uint64 TotalVirtual;uint64 AvailVirtual;uint64 AvailExtendedVirtual"
Func _WINAPI_ATTACHCONSOLE($IPROCESSID = -1)
	Local $ARESULT = DllCall("kernel32.dll", "bool", "AttachConsole", "dword", $IPROCESSID)
	If @error Then Return SetError(@error, @extended, False)
	Return $ARESULT[0]
EndFunc
Func _WINAPI_ATTACHTHREADINPUT($IATTACH, $IATTACHTO, $FATTACH)
	Local $ARESULT = DllCall("user32.dll", "bool", "AttachThreadInput", "dword", $IATTACH, "dword", $IATTACHTO, "bool", $FATTACH)
	If @error Then Return SetError(@error, @extended, False)
	Return $ARESULT[0]
EndFunc
Func _WINAPI_BEEP($IFREQ = 500, $IDURATION = 1000)
	Local $ARESULT = DllCall("kernel32.dll", "bool", "Beep", "dword", $IFREQ, "dword", $IDURATION)
	If @error Then Return SetError(@error, @extended, False)
	Return $ARESULT[0]
EndFunc
Func _WINAPI_BITBLT($HDESTDC, $IXDEST, $IYDEST, $IWIDTH, $IHEIGHT, $HSRCDC, $IXSRC, $IYSRC, $IROP)
	Local $ARESULT = DllCall("gdi32.dll", "bool", "BitBlt", "handle", $HDESTDC, "int", $IXDEST, "int", $IYDEST, "int", $IWIDTH, "int", $IHEIGHT, "handle", $HSRCDC, "int", $IXSRC, "int", $IYSRC, "dword", $IROP)
	If @error Then Return SetError(@error, @extended, False)
	Return $ARESULT[0]
EndFunc
Func _WINAPI_CALLNEXTHOOKEX($HHK, $ICODE, $WPARAM, $LPARAM)
	Local $ARESULT = DllCall("user32.dll", "lresult", "CallNextHookEx", "handle", $HHK, "int", $ICODE, "wparam", $WPARAM, "lparam", $LPARAM)
	If @error Then Return SetError(@error, @extended, -1)
	Return $ARESULT[0]
EndFunc
Func _WINAPI_CALLWINDOWPROC($LPPREVWNDFUNC, $HWND, $MSG, $WPARAM, $LPARAM)
	Local $ARESULT = DllCall("user32.dll", "lresult", "CallWindowProc", "ptr", $LPPREVWNDFUNC, "hwnd", $HWND, "uint", $MSG, "wparam", $WPARAM, "lparam", $LPARAM)
	If @error Then Return SetError(@error, @extended, -1)
	Return $ARESULT[0]
EndFunc
Func _WINAPI_CLIENTTOSCREEN($HWND, ByRef $TPOINT)
	DllCall("user32.dll", "bool", "ClientToScreen", "hwnd", $HWND, "struct*", $TPOINT)
	Return SetError(@error, @extended, $TPOINT)
EndFunc
Func _WINAPI_CLOSEHANDLE($HOBJECT)
	Local $ARESULT = DllCall("kernel32.dll", "bool", "CloseHandle", "handle", $HOBJECT)
	If @error Then Return SetError(@error, @extended, False)
	Return $ARESULT[0]
EndFunc
Func _WINAPI_COMBINERGN($HRGNDEST, $HRGNSRC1, $HRGNSRC2, $ICOMBINEMODE)
	Local $ARESULT = DllCall("gdi32.dll", "int", "CombineRgn", "handle", $HRGNDEST, "handle", $HRGNSRC1, "handle", $HRGNSRC2, "int", $ICOMBINEMODE)
	If @error Then Return SetError(@error, @extended, 0)
	Return $ARESULT[0]
EndFunc
Func _WINAPI_COMMDLGEXTENDEDERROR()
	Local Const $CDERR_DIALOGFAILURE = 65535
	Local Const $CDERR_FINDRESFAILURE = 6
	Local Const $CDERR_INITIALIZATION = 2
	Local Const $CDERR_LOADRESFAILURE = 7
	Local Const $CDERR_LOADSTRFAILURE = 5
	Local Const $CDERR_LOCKRESFAILURE = 8
	Local Const $CDERR_MEMALLOCFAILURE = 9
	Local Const $CDERR_MEMLOCKFAILURE = 10
	Local Const $CDERR_NOHINSTANCE = 4
	Local Const $CDERR_NOHOOK = 11
	Local Const $CDERR_NOTEMPLATE = 3
	Local Const $CDERR_REGISTERMSGFAIL = 12
	Local Const $CDERR_STRUCTSIZE = 1
	Local Const $FNERR_BUFFERTOOSMALL = 12291
	Local Const $FNERR_INVALIDFILENAME = 12290
	Local Const $FNERR_SUBCLASSFAILURE = 12289
	Local $ARESULT = DllCall("comdlg32.dll", "dword", "CommDlgExtendedError")
	If @error Then Return SetError(@error, @extended, 0)
	Switch $ARESULT[0]
		Case $CDERR_DIALOGFAILURE
			Return SetError($ARESULT[0], 0, "The dialog box could not be created." & @LF & "The common dialog box function's call to the DialogBox function failed." & @LF & "For example, this error occurs if the common dialog box call specifies an invalid window handle.")
		Case $CDERR_FINDRESFAILURE
			Return SetError($ARESULT[0], 0, "The common dialog box function failed to find a specified resource.")
		Case $CDERR_INITIALIZATION
			Return SetError($ARESULT[0], 0, "The common dialog box function failed during initialization." & @LF & "This error often occurs when sufficient memory is not available.")
		Case $CDERR_LOADRESFAILURE
			Return SetError($ARESULT[0], 0, "The common dialog box function failed to load a specified resource.")
		Case $CDERR_LOADSTRFAILURE
			Return SetError($ARESULT[0], 0, "The common dialog box function failed to load a specified string.")
		Case $CDERR_LOCKRESFAILURE
			Return SetError($ARESULT[0], 0, "The common dialog box function failed to lock a specified resource.")
		Case $CDERR_MEMALLOCFAILURE
			Return SetError($ARESULT[0], 0, "The common dialog box function was unable to allocate memory for internal structures.")
		Case $CDERR_MEMLOCKFAILURE
			Return SetError($ARESULT[0], 0, "The common dialog box function was unable to lock the memory associated with a handle.")
		Case $CDERR_NOHINSTANCE
			Return SetError($ARESULT[0], 0, "The ENABLETEMPLATE flag was set in the Flags member of the initialization structure for the corresponding common dialog box," & @LF & "but you failed to provide a corresponding instance handle.")
		Case $CDERR_NOHOOK
			Return SetError($ARESULT[0], 0, "The ENABLEHOOK flag was set in the Flags member of the initialization structure for the corresponding common dialog box," & @LF & "but you failed to provide a pointer to a corresponding hook procedure.")
		Case $CDERR_NOTEMPLATE
			Return SetError($ARESULT[0], 0, "The ENABLETEMPLATE flag was set in the Flags member of the initialization structure for the corresponding common dialog box," & @LF & "but you failed to provide a corresponding template.")
		Case $CDERR_REGISTERMSGFAIL
			Return SetError($ARESULT[0], 0, "The RegisterWindowMessage function returned an error code when it was called by the common dialog box function.")
		Case $CDERR_STRUCTSIZE
			Return SetError($ARESULT[0], 0, "The lStructSize member of the initialization structure for the corresponding common dialog box is invalid")
		Case $FNERR_BUFFERTOOSMALL
			Return SetError($ARESULT[0], 0, "The buffer pointed to by the lpstrFile member of the OPENFILENAME structure is too small for the file name specified by the user." & @LF & "The first two bytes of the lpstrFile buffer contain an integer value specifying the size, in TCHARs, required to receive the full name.")
		Case $FNERR_INVALIDFILENAME
			Return SetError($ARESULT[0], 0, "A file name is invalid.")
		Case $FNERR_SUBCLASSFAILURE
			Return SetError($ARESULT[0], 0, "An attempt to subclass a list box failed because sufficient memory was not available.")
	EndSwitch
	Return Hex($ARESULT[0])
EndFunc
Func _WINAPI_COPYICON($HICON)
	Local $ARESULT = DllCall("user32.dll", "handle", "CopyIcon", "handle", $HICON)
	If @error Then Return SetError(@error, @extended, 0)
	Return $ARESULT[0]
EndFunc
Func _WINAPI_CREATEBITMAP($IWIDTH, $IHEIGHT, $IPLANES = 1, $IBITSPERPEL = 1, $PBITS = 0)
	Local $ARESULT = DllCall("gdi32.dll", "handle", "CreateBitmap", "int", $IWIDTH, "int", $IHEIGHT, "uint", $IPLANES, "uint", $IBITSPERPEL, "ptr", $PBITS)
	If @error Then Return SetError(@error, @extended, 0)
	Return $ARESULT[0]
EndFunc
Func _WINAPI_CREATECOMPATIBLEBITMAP($HDC, $IWIDTH, $IHEIGHT)
	Local $ARESULT = DllCall("gdi32.dll", "handle", "CreateCompatibleBitmap", "handle", $HDC, "int", $IWIDTH, "int", $IHEIGHT)
	If @error Then Return SetError(@error, @extended, 0)
	Return $ARESULT[0]
EndFunc
Func _WINAPI_CREATECOMPATIBLEDC($HDC)
	Local $ARESULT = DllCall("gdi32.dll", "handle", "CreateCompatibleDC", "handle", $HDC)
	If @error Then Return SetError(@error, @extended, 0)
	Return $ARESULT[0]
EndFunc
Func _WINAPI_CREATEEVENT($PATTRIBUTES = 0, $FMANUALRESET = True, $FINITIALSTATE = True, $SNAME = "")
	Local $SNAMETYPE = "wstr"
	If $SNAME = "" Then
		$SNAME = 0
		$SNAMETYPE = "ptr"
	EndIf
	Local $ARESULT = DllCall("kernel32.dll", "handle", "CreateEventW", "ptr", $PATTRIBUTES, "bool", $FMANUALRESET, "bool", $FINITIALSTATE, $SNAMETYPE, $SNAME)
	If @error Then Return SetError(@error, @extended, 0)
	Return $ARESULT[0]
EndFunc
Func _WINAPI_CREATEFILE($SFILENAME, $ICREATION, $IACCESS = 4, $ISHARE = 0, $IATTRIBUTES = 0, $PSECURITY = 0)
	Local $IDA = 0, $ISM = 0, $ICD = 0, $IFA = 0
	If BitAND($IACCESS, 1) <> 0 Then $IDA = BitOR($IDA, $GENERIC_EXECUTE)
	If BitAND($IACCESS, 2) <> 0 Then $IDA = BitOR($IDA, $GENERIC_READ)
	If BitAND($IACCESS, 4) <> 0 Then $IDA = BitOR($IDA, $GENERIC_WRITE)
	If BitAND($ISHARE, 1) <> 0 Then $ISM = BitOR($ISM, $FILE_SHARE_DELETE)
	If BitAND($ISHARE, 2) <> 0 Then $ISM = BitOR($ISM, $FILE_SHARE_READ)
	If BitAND($ISHARE, 4) <> 0 Then $ISM = BitOR($ISM, $FILE_SHARE_WRITE)
	Switch $ICREATION
		Case 0
			$ICD = $CREATE_NEW
		Case 1
			$ICD = $CREATE_ALWAYS
		Case 2
			$ICD = $OPEN_EXISTING
		Case 3
			$ICD = $OPEN_ALWAYS
		Case 4
			$ICD = $TRUNCATE_EXISTING
	EndSwitch
	If BitAND($IATTRIBUTES, 1) <> 0 Then $IFA = BitOR($IFA, $FILE_ATTRIBUTE_ARCHIVE)
	If BitAND($IATTRIBUTES, 2) <> 0 Then $IFA = BitOR($IFA, $FILE_ATTRIBUTE_HIDDEN)
	If BitAND($IATTRIBUTES, 4) <> 0 Then $IFA = BitOR($IFA, $FILE_ATTRIBUTE_READONLY)
	If BitAND($IATTRIBUTES, 8) <> 0 Then $IFA = BitOR($IFA, $FILE_ATTRIBUTE_SYSTEM)
	Local $ARESULT = DllCall("kernel32.dll", "handle", "CreateFileW", "wstr", $SFILENAME, "dword", $IDA, "dword", $ISM, "ptr", $PSECURITY, "dword", $ICD, "dword", $IFA, "ptr", 0)
	If @error Or $ARESULT[0] = Ptr(-1) Then Return SetError(@error, @extended, 0)
	Return $ARESULT[0]
EndFunc
Func _WINAPI_CREATEFONT($NHEIGHT, $NWIDTH, $NESCAPE = 0, $NORIENTN = 0, $FNWEIGHT = $__WINAPICONSTANT_FW_NORMAL, $BITALIC = False, $BUNDERLINE = False, $BSTRIKEOUT = False, $NCHARSET = $__WINAPICONSTANT_DEFAULT_CHARSET, $NOUTPUTPREC = $__WINAPICONSTANT_OUT_DEFAULT_PRECIS, $NCLIPPREC = $__WINAPICONSTANT_CLIP_DEFAULT_PRECIS, $NQUALITY = $__WINAPICONSTANT_DEFAULT_QUALITY, $NPITCH = 0, $SZFACE = "Arial")
	Local $ARESULT = DllCall("gdi32.dll", "handle", "CreateFontW", "int", $NHEIGHT, "int", $NWIDTH, "int", $NESCAPE, "int", $NORIENTN, "int", $FNWEIGHT, "dword", $BITALIC, "dword", $BUNDERLINE, "dword", $BSTRIKEOUT, "dword", $NCHARSET, "dword", $NOUTPUTPREC, "dword", $NCLIPPREC, "dword", $NQUALITY, "dword", $NPITCH, "wstr", $SZFACE)
	If @error Then Return SetError(@error, @extended, 0)
	Return $ARESULT[0]
EndFunc
Func _WINAPI_CREATEFONTINDIRECT($TLOGFONT)
	Local $ARESULT = DllCall("gdi32.dll", "handle", "CreateFontIndirectW", "struct*", $TLOGFONT)
	If @error Then Return SetError(@error, @extended, 0)
	Return $ARESULT[0]
EndFunc
Func _WINAPI_CREATEPEN($IPENSTYLE, $IWIDTH, $NCOLOR)
	Local $ARESULT = DllCall("gdi32.dll", "handle", "CreatePen", "int", $IPENSTYLE, "int", $IWIDTH, "dword", $NCOLOR)
	If @error Then Return SetError(@error, @extended, 0)
	Return $ARESULT[0]
EndFunc
Func _WINAPI_CREATEPROCESS($SAPPNAME, $SCOMMAND, $PSECURITY, $PTHREAD, $FINHERIT, $IFLAGS, $PENVIRON, $SDIR, $PSTARTUPINFO, $PPROCESS)
	Local $TCOMMAND = 0
	Local $SAPPNAMETYPE = "wstr", $SDIRTYPE = "wstr"
	If $SAPPNAME = "" Then
		$SAPPNAMETYPE = "ptr"
		$SAPPNAME = 0
	EndIf
	If $SCOMMAND <> "" Then
		$TCOMMAND = DllStructCreate("wchar Text[" & 260 + 1 & "]")
		DllStructSetData($TCOMMAND, "Text", $SCOMMAND)
	EndIf
	If $SDIR = "" Then
		$SDIRTYPE = "ptr"
		$SDIR = 0
	EndIf
	Local $ARESULT = DllCall("kernel32.dll", "bool", "CreateProcessW", $SAPPNAMETYPE, $SAPPNAME, "struct*", $TCOMMAND, "ptr", $PSECURITY, "ptr", $PTHREAD, "bool", $FINHERIT, "dword", $IFLAGS, "ptr", $PENVIRON, $SDIRTYPE, $SDIR, "ptr", $PSTARTUPINFO, "ptr", $PPROCESS)
	If @error Then Return SetError(@error, @extended, False)
	Return $ARESULT[0]
EndFunc
Func _WINAPI_CREATERECTRGN($ILEFTRECT, $ITOPRECT, $IRIGHTRECT, $IBOTTOMRECT)
	Local $ARESULT = DllCall("gdi32.dll", "handle", "CreateRectRgn", "int", $ILEFTRECT, "int", $ITOPRECT, "int", $IRIGHTRECT, "int", $IBOTTOMRECT)
	If @error Then Return SetError(@error, @extended, 0)
	Return $ARESULT[0]
EndFunc
Func _WINAPI_CREATEROUNDRECTRGN($ILEFTRECT, $ITOPRECT, $IRIGHTRECT, $IBOTTOMRECT, $IWIDTHELLIPSE, $IHEIGHTELLIPSE)
	Local $ARESULT = DllCall("gdi32.dll", "handle", "CreateRoundRectRgn", "int", $ILEFTRECT, "int", $ITOPRECT, "int", $IRIGHTRECT, "int", $IBOTTOMRECT, "int", $IWIDTHELLIPSE, "int", $IHEIGHTELLIPSE)
	If @error Then Return SetError(@error, @extended, 0)
	Return $ARESULT[0]
EndFunc
Func _WINAPI_CREATESOLIDBITMAP($HWND, $ICOLOR, $IWIDTH, $IHEIGHT, $BRGB = 1)
	Local $HDC = _WINAPI_GETDC($HWND)
	Local $HDESTDC = _WINAPI_CREATECOMPATIBLEDC($HDC)
	Local $HBITMAP = _WINAPI_CREATECOMPATIBLEBITMAP($HDC, $IWIDTH, $IHEIGHT)
	Local $HOLD = _WINAPI_SELECTOBJECT($HDESTDC, $HBITMAP)
	Local $TRECT = DllStructCreate($TAGRECT)
	DllStructSetData($TRECT, 1, 0)
	DllStructSetData($TRECT, 2, 0)
	DllStructSetData($TRECT, 3, $IWIDTH)
	DllStructSetData($TRECT, 4, $IHEIGHT)
	If $BRGB Then
		$ICOLOR = BitOR(BitAND($ICOLOR, 65280), BitShift(BitAND($ICOLOR, 255), -16), BitShift(BitAND($ICOLOR, 16711680), 16))
	EndIf
	Local $HBRUSH = _WINAPI_CREATESOLIDBRUSH($ICOLOR)
	_WINAPI_FILLRECT($HDESTDC, $TRECT, $HBRUSH)
	If @error Then
		_WINAPI_DELETEOBJECT($HBITMAP)
		$HBITMAP = 0
	EndIf
	_WINAPI_DELETEOBJECT($HBRUSH)
	_WINAPI_RELEASEDC($HWND, $HDC)
	_WINAPI_SELECTOBJECT($HDESTDC, $HOLD)
	_WINAPI_DELETEDC($HDESTDC)
	If Not $HBITMAP Then Return SetError(1, 0, 0)
	Return $HBITMAP
EndFunc
Func _WINAPI_CREATESOLIDBRUSH($NCOLOR)
	Local $ARESULT = DllCall("gdi32.dll", "handle", "CreateSolidBrush", "dword", $NCOLOR)
	If @error Then Return SetError(@error, @extended, 0)
	Return $ARESULT[0]
EndFunc
Func _WINAPI_CREATEWINDOWEX($IEXSTYLE, $SCLASS, $SNAME, $ISTYLE, $IX, $IY, $IWIDTH, $IHEIGHT, $HPARENT, $HMENU = 0, $HINSTANCE = 0, $PPARAM = 0)
	If $HINSTANCE = 0 Then $HINSTANCE = _WINAPI_GETMODULEHANDLE("")
	Local $ARESULT = DllCall("user32.dll", "hwnd", "CreateWindowExW", "dword", $IEXSTYLE, "wstr", $SCLASS, "wstr", $SNAME, "dword", $ISTYLE, "int", $IX, "int", $IY, "int", $IWIDTH, "int", $IHEIGHT, "hwnd", $HPARENT, "handle", $HMENU, "handle", $HINSTANCE, "ptr", $PPARAM)
	If @error Then Return SetError(@error, @extended, 0)
	Return $ARESULT[0]
EndFunc
Func _WINAPI_DEFWINDOWPROC($HWND, $IMSG, $IWPARAM, $ILPARAM)
	Local $ARESULT = DllCall("user32.dll", "lresult", "DefWindowProc", "hwnd", $HWND, "uint", $IMSG, "wparam", $IWPARAM, "lparam", $ILPARAM)
	If @error Then Return SetError(@error, @extended, 0)
	Return $ARESULT[0]
EndFunc
Func _WINAPI_DELETEDC($HDC)
	Local $ARESULT = DllCall("gdi32.dll", "bool", "DeleteDC", "handle", $HDC)
	If @error Then Return SetError(@error, @extended, False)
	Return $ARESULT[0]
EndFunc
Func _WINAPI_DELETEOBJECT($HOBJECT)
	Local $ARESULT = DllCall("gdi32.dll", "bool", "DeleteObject", "handle", $HOBJECT)
	If @error Then Return SetError(@error, @extended, False)
	Return $ARESULT[0]
EndFunc
Func _WINAPI_DESTROYICON($HICON)
	Local $ARESULT = DllCall("user32.dll", "bool", "DestroyIcon", "handle", $HICON)
	If @error Then Return SetError(@error, @extended, False)
	Return $ARESULT[0]
EndFunc
Func _WINAPI_DESTROYWINDOW($HWND)
	Local $ARESULT = DllCall("user32.dll", "bool", "DestroyWindow", "hwnd", $HWND)
	If @error Then Return SetError(@error, @extended, False)
	Return $ARESULT[0]
EndFunc
Func _WINAPI_DRAWEDGE($HDC, $PTRRECT, $NEDGETYPE, $GRFFLAGS)
	Local $ARESULT = DllCall("user32.dll", "bool", "DrawEdge", "handle", $HDC, "ptr", $PTRRECT, "uint", $NEDGETYPE, "uint", $GRFFLAGS)
	If @error Then Return SetError(@error, @extended, False)
	Return $ARESULT[0]
EndFunc
Func _WINAPI_DRAWFRAMECONTROL($HDC, $PTRRECT, $NTYPE, $NSTATE)
	Local $ARESULT = DllCall("user32.dll", "bool", "DrawFrameControl", "handle", $HDC, "ptr", $PTRRECT, "uint", $NTYPE, "uint", $NSTATE)
	If @error Then Return SetError(@error, @extended, False)
	Return $ARESULT[0]
EndFunc
Func _WINAPI_DRAWICON($HDC, $IX, $IY, $HICON)
	Local $ARESULT = DllCall("user32.dll", "bool", "DrawIcon", "handle", $HDC, "int", $IX, "int", $IY, "handle", $HICON)
	If @error Then Return SetError(@error, @extended, False)
	Return $ARESULT[0]
EndFunc
Func _WINAPI_DRAWICONEX($HDC, $IX, $IY, $HICON, $IWIDTH = 0, $IHEIGHT = 0, $ISTEP = 0, $HBRUSH = 0, $IFLAGS = 3)
	Local $IOPTIONS
	Switch $IFLAGS
		Case 1
			$IOPTIONS = $__WINAPICONSTANT_DI_MASK
		Case 2
			$IOPTIONS = $__WINAPICONSTANT_DI_IMAGE
		Case 3
			$IOPTIONS = $__WINAPICONSTANT_DI_NORMAL
		Case 4
			$IOPTIONS = $__WINAPICONSTANT_DI_COMPAT
		Case 5
			$IOPTIONS = $__WINAPICONSTANT_DI_DEFAULTSIZE
		Case Else
			$IOPTIONS = $__WINAPICONSTANT_DI_NOMIRROR
	EndSwitch
	Local $ARESULT = DllCall("user32.dll", "bool", "DrawIconEx", "handle", $HDC, "int", $IX, "int", $IY, "handle", $HICON, "int", $IWIDTH, "int", $IHEIGHT, "uint", $ISTEP, "handle", $HBRUSH, "uint", $IOPTIONS)
	If @error Then Return SetError(@error, @extended, False)
	Return $ARESULT[0]
EndFunc
Func _WINAPI_DRAWLINE($HDC, $IX1, $IY1, $IX2, $IY2)
	_WINAPI_MOVETO($HDC, $IX1, $IY1)
	If @error Then Return SetError(@error, @extended, False)
	_WINAPI_LINETO($HDC, $IX2, $IY2)
	If @error Then Return SetError(@error, @extended, False)
	Return True
EndFunc
Func _WINAPI_DRAWTEXT($HDC, $STEXT, ByRef $TRECT, $IFLAGS)
	Local $ARESULT = DllCall("user32.dll", "int", "DrawTextW", "handle", $HDC, "wstr", $STEXT, "int", -1, "struct*", $TRECT, "uint", $IFLAGS)
	If @error Then Return SetError(@error, @extended, 0)
	Return $ARESULT[0]
EndFunc
Func _WINAPI_DUPLICATEHANDLE($HSOURCEPROCESSHANDLE, $HSOURCEHANDLE, $HTARGETPROCESSHANDLE, $IDESIREDACCESS, $FINHERITHANDLE, $IOPTIONS)
	Local $ACALL = DllCall("kernel32.dll", "bool", "DuplicateHandle", "handle", $HSOURCEPROCESSHANDLE, "handle", $HSOURCEHANDLE, "handle", $HTARGETPROCESSHANDLE, "handle*", 0, "dword", $IDESIREDACCESS, "bool", $FINHERITHANDLE, "dword", $IOPTIONS)
	If @error Or Not $ACALL[0] Then Return SetError(1, @extended, 0)
	Return $ACALL[4]
EndFunc
Func _WINAPI_ENABLEWINDOW($HWND, $FENABLE = True)
	Local $ARESULT = DllCall("user32.dll", "bool", "EnableWindow", "hwnd", $HWND, "bool", $FENABLE)
	If @error Then Return SetError(@error, @extended, False)
	Return $ARESULT[0]
EndFunc
Func _WINAPI_ENUMDISPLAYDEVICES($SDEVICE, $IDEVNUM)
	Local $TNAME = 0, $IFLAGS = 0, $ADEVICE[5]
	If $SDEVICE <> "" Then
		$TNAME = DllStructCreate("wchar Text[" & StringLen($SDEVICE) + 1 & "]")
		DllStructSetData($TNAME, "Text", $SDEVICE)
	EndIf
	Local $TDEVICE = DllStructCreate($TAGDISPLAY_DEVICE)
	Local $IDEVICE = DllStructGetSize($TDEVICE)
	DllStructSetData($TDEVICE, "Size", $IDEVICE)
	DllCall("user32.dll", "bool", "EnumDisplayDevicesW", "struct*", $TNAME, "dword", $IDEVNUM, "struct*", $TDEVICE, "dword", 1)
	If @error Then Return SetError(@error, @extended, 0)
	Local $IN = DllStructGetData($TDEVICE, "Flags")
	If BitAND($IN, $__WINAPICONSTANT_DISPLAY_DEVICE_ATTACHED_TO_DESKTOP) <> 0 Then $IFLAGS = BitOR($IFLAGS, 1)
	If BitAND($IN, $__WINAPICONSTANT_DISPLAY_DEVICE_PRIMARY_DEVICE) <> 0 Then $IFLAGS = BitOR($IFLAGS, 2)
	If BitAND($IN, $__WINAPICONSTANT_DISPLAY_DEVICE_MIRRORING_DRIVER) <> 0 Then $IFLAGS = BitOR($IFLAGS, 4)
	If BitAND($IN, $__WINAPICONSTANT_DISPLAY_DEVICE_VGA_COMPATIBLE) <> 0 Then $IFLAGS = BitOR($IFLAGS, 8)
	If BitAND($IN, $__WINAPICONSTANT_DISPLAY_DEVICE_REMOVABLE) <> 0 Then $IFLAGS = BitOR($IFLAGS, 16)
	If BitAND($IN, $__WINAPICONSTANT_DISPLAY_DEVICE_MODESPRUNED) <> 0 Then $IFLAGS = BitOR($IFLAGS, 32)
	$ADEVICE[0] = True
	$ADEVICE[1] = DllStructGetData($TDEVICE, "Name")
	$ADEVICE[2] = DllStructGetData($TDEVICE, "String")
	$ADEVICE[3] = $IFLAGS
	$ADEVICE[4] = DllStructGetData($TDEVICE, "ID")
	Return $ADEVICE
EndFunc
Func _WINAPI_ENUMWINDOWS($FVISIBLE = True, $HWND = Default)
	__WINAPI_ENUMWINDOWSINIT()
	If $HWND = Default Then $HWND = _WINAPI_GETDESKTOPWINDOW()
	__WINAPI_ENUMWINDOWSCHILD($HWND, $FVISIBLE)
	Return $__GAWINLIST_WINAPI
EndFunc
Func __WINAPI_ENUMWINDOWSADD($HWND, $SCLASS = "")
	If $SCLASS = "" Then $SCLASS = _WINAPI_GETCLASSNAME($HWND)
	$__GAWINLIST_WINAPI[0][0] += 1
	Local $ICOUNT = $__GAWINLIST_WINAPI[0][0]
	If $ICOUNT >= $__GAWINLIST_WINAPI[0][1] Then
		ReDim $__GAWINLIST_WINAPI[$ICOUNT + 64][2]
		$__GAWINLIST_WINAPI[0][1] += 64
	EndIf
	$__GAWINLIST_WINAPI[$ICOUNT][0] = $HWND
	$__GAWINLIST_WINAPI[$ICOUNT][1] = $SCLASS
EndFunc
Func __WINAPI_ENUMWINDOWSCHILD($HWND, $FVISIBLE = True)
	$HWND = _WINAPI_GETWINDOW($HWND, $__WINAPICONSTANT_GW_CHILD)
	While $HWND <> 0
		IF (Not $FVISIBLE) Or _WINAPI_ISWINDOWVISIBLE($HWND) Then
			__WINAPI_ENUMWINDOWSCHILD($HWND, $FVISIBLE)
			__WINAPI_ENUMWINDOWSADD($HWND)
		EndIf
		$HWND = _WINAPI_GETWINDOW($HWND, $__WINAPICONSTANT_GW_HWNDNEXT)
	WEnd
EndFunc
Func __WINAPI_ENUMWINDOWSINIT()
	ReDim $__GAWINLIST_WINAPI[64][2]
	$__GAWINLIST_WINAPI[0][0] = 0
	$__GAWINLIST_WINAPI[0][1] = 64
EndFunc
Func _WINAPI_ENUMWINDOWSPOPUP()
	__WINAPI_ENUMWINDOWSINIT()
	Local $HWND = _WINAPI_GETWINDOW(_WINAPI_GETDESKTOPWINDOW(), $__WINAPICONSTANT_GW_CHILD)
	Local $SCLASS
	While $HWND <> 0
		If _WINAPI_ISWINDOWVISIBLE($HWND) Then
			$SCLASS = _WINAPI_GETCLASSNAME($HWND)
			If $SCLASS = "#32768" Then
				__WINAPI_ENUMWINDOWSADD($HWND)
			ElseIf $SCLASS = "ToolbarWindow32" Then
				__WINAPI_ENUMWINDOWSADD($HWND)
			ElseIf $SCLASS = "ToolTips_Class32" Then
				__WINAPI_ENUMWINDOWSADD($HWND)
			ElseIf $SCLASS = "BaseBar" Then
				__WINAPI_ENUMWINDOWSCHILD($HWND)
			EndIf
		EndIf
		$HWND = _WINAPI_GETWINDOW($HWND, $__WINAPICONSTANT_GW_HWNDNEXT)
	WEnd
	Return $__GAWINLIST_WINAPI
EndFunc
Func _WINAPI_ENUMWINDOWSTOP()
	__WINAPI_ENUMWINDOWSINIT()
	Local $HWND = _WINAPI_GETWINDOW(_WINAPI_GETDESKTOPWINDOW(), $__WINAPICONSTANT_GW_CHILD)
	While $HWND <> 0
		If _WINAPI_ISWINDOWVISIBLE($HWND) Then __WINAPI_ENUMWINDOWSADD($HWND)
		$HWND = _WINAPI_GETWINDOW($HWND, $__WINAPICONSTANT_GW_HWNDNEXT)
	WEnd
	Return $__GAWINLIST_WINAPI
EndFunc
Func _WINAPI_EXPANDENVIRONMENTSTRINGS($SSTRING)
	Local $ARESULT = DllCall("kernel32.dll", "dword", "ExpandEnvironmentStringsW", "wstr", $SSTRING, "wstr", "", "dword", 4096)
	If @error Then Return SetError(@error, @extended, "")
	Return $ARESULT[2]
EndFunc
Func _WINAPI_EXTRACTICONEX($SFILE, $IINDEX, $PLARGE, $PSMALL, $IICONS)
	Local $ARESULT = DllCall("shell32.dll", "uint", "ExtractIconExW", "wstr", $SFILE, "int", $IINDEX, "struct*", $PLARGE, "struct*", $PSMALL, "uint", $IICONS)
	If @error Then Return SetError(@error, @extended, 0)
	Return $ARESULT[0]
EndFunc
Func _WINAPI_FATALAPPEXIT($SMESSAGE)
	DllCall("kernel32.dll", "none", "FatalAppExitW", "uint", 0, "wstr", $SMESSAGE)
	If @error Then Return SetError(@error, @extended)
EndFunc
Func _WINAPI_FILLRECT($HDC, $PTRRECT, $HBRUSH)
	Local $ARESULT
	If IsPtr($HBRUSH) Then
		$ARESULT = DllCall("user32.dll", "int", "FillRect", "handle", $HDC, "struct*", $PTRRECT, "handle", $HBRUSH)
	Else
		$ARESULT = DllCall("user32.dll", "int", "FillRect", "handle", $HDC, "struct*", $PTRRECT, "dword_ptr", $HBRUSH)
	EndIf
	If @error Then Return SetError(@error, @extended, False)
	Return $ARESULT[0]
EndFunc
Func _WINAPI_FINDEXECUTABLE($SFILENAME, $SDIRECTORY = "")
	Local $ARESULT = DllCall("shell32.dll", "INT", "FindExecutableW", "wstr", $SFILENAME, "wstr", $SDIRECTORY, "wstr", "")
	If @error Then Return SetError(@error, @extended, 0)
	Return SetExtended($ARESULT[0], $ARESULT[3])
EndFunc
Func _WINAPI_FINDWINDOW($SCLASSNAME, $SWINDOWNAME)
	Local $ARESULT = DllCall("user32.dll", "hwnd", "FindWindowW", "wstr", $SCLASSNAME, "wstr", $SWINDOWNAME)
	If @error Then Return SetError(@error, @extended, 0)
	Return $ARESULT[0]
EndFunc
Func _WINAPI_FLASHWINDOW($HWND, $FINVERT = True)
	Local $ARESULT = DllCall("user32.dll", "bool", "FlashWindow", "hwnd", $HWND, "bool", $FINVERT)
	If @error Then Return SetError(@error, @extended, False)
	Return $ARESULT[0]
EndFunc
Func _WINAPI_FLASHWINDOWEX($HWND, $IFLAGS = 3, $ICOUNT = 3, $ITIMEOUT = 0)
	Local $TFLASH = DllStructCreate($TAGFLASHWINFO)
	Local $IFLASH = DllStructGetSize($TFLASH)
	Local $IMODE = 0
	If BitAND($IFLAGS, 1) <> 0 Then $IMODE = BitOR($IMODE, $__WINAPICONSTANT_FLASHW_CAPTION)
	If BitAND($IFLAGS, 2) <> 0 Then $IMODE = BitOR($IMODE, $__WINAPICONSTANT_FLASHW_TRAY)
	If BitAND($IFLAGS, 4) <> 0 Then $IMODE = BitOR($IMODE, $__WINAPICONSTANT_FLASHW_TIMER)
	If BitAND($IFLAGS, 8) <> 0 Then $IMODE = BitOR($IMODE, $__WINAPICONSTANT_FLASHW_TIMERNOFG)
	DllStructSetData($TFLASH, "Size", $IFLASH)
	DllStructSetData($TFLASH, "hWnd", $HWND)
	DllStructSetData($TFLASH, "Flags", $IMODE)
	DllStructSetData($TFLASH, "Count", $ICOUNT)
	DllStructSetData($TFLASH, "Timeout", $ITIMEOUT)
	Local $ARESULT = DllCall("user32.dll", "bool", "FlashWindowEx", "struct*", $TFLASH)
	If @error Then Return SetError(@error, @extended, False)
	Return $ARESULT[0]
EndFunc
Func _WINAPI_FLOATTOINT($NFLOAT)
	Local $TFLOAT = DllStructCreate("float")
	Local $TINT = DllStructCreate("int", DllStructGetPtr($TFLOAT))
	DllStructSetData($TFLOAT, 1, $NFLOAT)
	Return DllStructGetData($TINT, 1)
EndFunc
Func _WINAPI_FLUSHFILEBUFFERS($HFILE)
	Local $ARESULT = DllCall("kernel32.dll", "bool", "FlushFileBuffers", "handle", $HFILE)
	If @error Then Return SetError(@error, @extended, False)
	Return $ARESULT[0]
EndFunc
Func _WINAPI_FORMATMESSAGE($IFLAGS, $PSOURCE, $IMESSAGEID, $ILANGUAGEID, ByRef $PBUFFER, $ISIZE, $VARGUMENTS)
	Local $SBUFFERTYPE = "struct*"
	If IsString($PBUFFER) Then $SBUFFERTYPE = "wstr"
	Local $ARESULT = DllCall("Kernel32.dll", "dword", "FormatMessageW", "dword", $IFLAGS, "ptr", $PSOURCE, "dword", $IMESSAGEID, "dword", $ILANGUAGEID, $SBUFFERTYPE, $PBUFFER, "dword", $ISIZE, "ptr", $VARGUMENTS)
	If @error Then Return SetError(@error, @extended, 0)
	If $SBUFFERTYPE = "wstr" Then $PBUFFER = $ARESULT[5]
	Return $ARESULT[0]
EndFunc
Func _WINAPI_FRAMERECT($HDC, $PTRRECT, $HBRUSH)
	Local $ARESULT = DllCall("user32.dll", "int", "FrameRect", "handle", $HDC, "ptr", $PTRRECT, "handle", $HBRUSH)
	If @error Then Return SetError(@error, @extended, False)
	Return $ARESULT[0]
EndFunc
Func _WINAPI_FREELIBRARY($HMODULE)
	Local $ARESULT = DllCall("kernel32.dll", "bool", "FreeLibrary", "handle", $HMODULE)
	If @error Then Return SetError(@error, @extended, False)
	Return $ARESULT[0]
EndFunc
Func _WINAPI_GETANCESTOR($HWND, $IFLAGS = 1)
	Local $ARESULT = DllCall("user32.dll", "hwnd", "GetAncestor", "hwnd", $HWND, "uint", $IFLAGS)
	If @error Then Return SetError(@error, @extended, 0)
	Return $ARESULT[0]
EndFunc
Func _WINAPI_GETASYNCKEYSTATE($IKEY)
	Local $ARESULT = DllCall("user32.dll", "short", "GetAsyncKeyState", "int", $IKEY)
	If @error Then Return SetError(@error, @extended, 0)
	Return $ARESULT[0]
EndFunc
Func _WINAPI_GETBKMODE($HDC)
	Local $ARESULT = DllCall("gdi32.dll", "int", "GetBkMode", "handle", $HDC)
	If @error Then Return SetError(@error, @extended, 0)
	Return $ARESULT[0]
EndFunc
Func _WINAPI_GETCLASSNAME($HWND)
	If Not IsHWnd($HWND) Then $HWND = GUICtrlGetHandle($HWND)
	Local $ARESULT = DllCall("user32.dll", "int", "GetClassNameW", "hwnd", $HWND, "wstr", "", "int", 4096)
	If @error Then Return SetError(@error, @extended, False)
	Return SetExtended($ARESULT[0], $ARESULT[2])
EndFunc
Func _WINAPI_GETCLIENTHEIGHT($HWND)
	Local $TRECT = _WINAPI_GETCLIENTRECT($HWND)
	If @error Then Return SetError(@error, @extended, 0)
	Return DllStructGetData($TRECT, "Bottom") - DllStructGetData($TRECT, "Top")
EndFunc
Func _WINAPI_GETCLIENTWIDTH($HWND)
	Local $TRECT = _WINAPI_GETCLIENTRECT($HWND)
	If @error Then Return SetError(@error, @extended, 0)
	Return DllStructGetData($TRECT, "Right") - DllStructGetData($TRECT, "Left")
EndFunc
Func _WINAPI_GETCLIENTRECT($HWND)
	Local $TRECT = DllStructCreate($TAGRECT)
	DllCall("user32.dll", "bool", "GetClientRect", "hwnd", $HWND, "struct*", $TRECT)
	If @error Then Return SetError(@error, @extended, 0)
	Return $TRECT
EndFunc
Func _WINAPI_GETCURRENTPROCESS()
	Local $ARESULT = DllCall("kernel32.dll", "handle", "GetCurrentProcess")
	If @error Then Return SetError(@error, @extended, 0)
	Return $ARESULT[0]
EndFunc
Func _WINAPI_GETCURRENTPROCESSID()
	Local $ARESULT = DllCall("kernel32.dll", "dword", "GetCurrentProcessId")
	If @error Then Return SetError(@error, @extended, 0)
	Return $ARESULT[0]
EndFunc
Func _WINAPI_GETCURRENTTHREAD()
	Local $ARESULT = DllCall("kernel32.dll", "handle", "GetCurrentThread")
	If @error Then Return SetError(@error, @extended, 0)
	Return $ARESULT[0]
EndFunc
Func _WINAPI_GETCURRENTTHREADID()
	Local $ARESULT = DllCall("kernel32.dll", "dword", "GetCurrentThreadId")
	If @error Then Return SetError(@error, @extended, 0)
	Return $ARESULT[0]
EndFunc
Func _WINAPI_GETCURSORINFO()
	Local $TCURSOR = DllStructCreate($TAGCURSORINFO)
	Local $ICURSOR = DllStructGetSize($TCURSOR)
	DllStructSetData($TCURSOR, "Size", $ICURSOR)
	DllCall("user32.dll", "bool", "GetCursorInfo", "struct*", $TCURSOR)
	If @error Then Return SetError(@error, @extended, 0)
	Local $ACURSOR[5]
	$ACURSOR[0] = True
	$ACURSOR[1] = DllStructGetData($TCURSOR, "Flags") <> 0
	$ACURSOR[2] = DllStructGetData($TCURSOR, "hCursor")
	$ACURSOR[3] = DllStructGetData($TCURSOR, "X")
	$ACURSOR[4] = DllStructGetData($TCURSOR, "Y")
	Return $ACURSOR
EndFunc
Func _WINAPI_GETDC($HWND)
	Local $ARESULT = DllCall("user32.dll", "handle", "GetDC", "hwnd", $HWND)
	If @error Then Return SetError(@error, @extended, 0)
	Return $ARESULT[0]
EndFunc
Func _WINAPI_GETDESKTOPWINDOW()
	Local $ARESULT = DllCall("user32.dll", "hwnd", "GetDesktopWindow")
	If @error Then Return SetError(@error, @extended, 0)
	Return $ARESULT[0]
EndFunc
Func _WINAPI_GETDEVICECAPS($HDC, $IINDEX)
	Local $ARESULT = DllCall("gdi32.dll", "int", "GetDeviceCaps", "handle", $HDC, "int", $IINDEX)
	If @error Then Return SetError(@error, @extended, 0)
	Return $ARESULT[0]
EndFunc
Func _WINAPI_GETDIBITS($HDC, $HBMP, $ISTARTSCAN, $ISCANLINES, $PBITS, $PBI, $IUSAGE)
	Local $ARESULT = DllCall("gdi32.dll", "int", "GetDIBits", "handle", $HDC, "handle", $HBMP, "uint", $ISTARTSCAN, "uint", $ISCANLINES, "ptr", $PBITS, "ptr", $PBI, "uint", $IUSAGE)
	If @error Then Return SetError(@error, @extended, False)
	Return $ARESULT[0]
EndFunc
Func _WINAPI_GETDLGCTRLID($HWND)
	Local $ARESULT = DllCall("user32.dll", "int", "GetDlgCtrlID", "hwnd", $HWND)
	If @error Then Return SetError(@error, @extended, 0)
	Return $ARESULT[0]
EndFunc
Func _WINAPI_GETDLGITEM($HWND, $IITEMID)
	Local $ARESULT = DllCall("user32.dll", "hwnd", "GetDlgItem", "hwnd", $HWND, "int", $IITEMID)
	If @error Then Return SetError(@error, @extended, 0)
	Return $ARESULT[0]
EndFunc
Func _WINAPI_GETFOCUS()
	Local $ARESULT = DllCall("user32.dll", "hwnd", "GetFocus")
	If @error Then Return SetError(@error, @extended, 0)
	Return $ARESULT[0]
EndFunc
Func _WINAPI_GETFOREGROUNDWINDOW()
	Local $ARESULT = DllCall("user32.dll", "hwnd", "GetForegroundWindow")
	If @error Then Return SetError(@error, @extended, 0)
	Return $ARESULT[0]
EndFunc
Func _WINAPI_GETGUIRESOURCES($IFLAG = 0, $HPROCESS = -1)
	If $HPROCESS = -1 Then $HPROCESS = _WINAPI_GETCURRENTPROCESS()
	Local $ARESULT = DllCall("user32.dll", "dword", "GetGuiResources", "handle", $HPROCESS, "dword", $IFLAG)
	If @error Then Return SetError(@error, @extended, 0)
	Return $ARESULT[0]
EndFunc
Func _WINAPI_GETICONINFO($HICON)
	Local $TINFO = DllStructCreate($TAGICONINFO)
	DllCall("user32.dll", "bool", "GetIconInfo", "handle", $HICON, "struct*", $TINFO)
	If @error Then Return SetError(@error, @extended, 0)
	Local $AICON[6]
	$AICON[0] = True
	$AICON[1] = DllStructGetData($TINFO, "Icon") <> 0
	$AICON[2] = DllStructGetData($TINFO, "XHotSpot")
	$AICON[3] = DllStructGetData($TINFO, "YHotSpot")
	$AICON[4] = DllStructGetData($TINFO, "hMask")
	$AICON[5] = DllStructGetData($TINFO, "hColor")
	Return $AICON
EndFunc
Func _WINAPI_GETFILESIZEEX($HFILE)
	Local $ARESULT = DllCall("kernel32.dll", "bool", "GetFileSizeEx", "handle", $HFILE, "int64*", 0)
	If @error Then Return SetError(@error, @extended, 0)
	Return $ARESULT[2]
EndFunc
Func _WINAPI_GETLASTERRORMESSAGE()
	Local $TBUFFERPTR = DllStructCreate("ptr")
	Local $NCOUNT = _WINAPI_FORMATMESSAGE(BitOR($__WINAPICONSTANT_FORMAT_MESSAGE_ALLOCATE_BUFFER, $__WINAPICONSTANT_FORMAT_MESSAGE_FROM_SYSTEM), 0, _WINAPI_GETLASTERROR(), 0, $TBUFFERPTR, 0, 0)
	If @error Then Return SetError(@error, 0, "")
	Local $STEXT = ""
	Local $PBUFFER = DllStructGetData($TBUFFERPTR, 1)
	If $PBUFFER Then
		If $NCOUNT > 0 Then
			Local $TBUFFER = DllStructCreate("wchar[" & ($NCOUNT + 1) & "]", $PBUFFER)
			$STEXT = DllStructGetData($TBUFFER, 1)
		EndIf
		_WINAPI_LOCALFREE($PBUFFER)
	EndIf
	Return $STEXT
EndFunc
Func _WINAPI_GETLAYEREDWINDOWATTRIBUTES($HWND, ByRef $I_TRANSCOLOR, ByRef $TRANSPARENCY, $ASCOLORREF = False)
	$I_TRANSCOLOR = -1
	$TRANSPARENCY = -1
	Local $ARESULT = DllCall("user32.dll", "bool", "GetLayeredWindowAttributes", "hwnd", $HWND, "dword*", $I_TRANSCOLOR, "byte*", $TRANSPARENCY, "dword*", 0)
	If @error Then Return SetError(@error, @extended, 0)
	If Not $ASCOLORREF Then
		$ARESULT[2] = Int(BinaryMid($ARESULT[2], 3, 1) & BinaryMid($ARESULT[2], 2, 1) & BinaryMid($ARESULT[2], 1, 1))
	EndIf
	$I_TRANSCOLOR = $ARESULT[2]
	$TRANSPARENCY = $ARESULT[3]
	Return $ARESULT[4]
EndFunc
Func _WINAPI_GETMODULEHANDLE($SMODULENAME)
	Local $SMODULENAMETYPE = "wstr"
	If $SMODULENAME = "" Then
		$SMODULENAME = 0
		$SMODULENAMETYPE = "ptr"
	EndIf
	Local $ARESULT = DllCall("kernel32.dll", "handle", "GetModuleHandleW", $SMODULENAMETYPE, $SMODULENAME)
	If @error Then Return SetError(@error, @extended, 0)
	Return $ARESULT[0]
EndFunc
Func _WINAPI_GETMOUSEPOS($FTOCLIENT = False, $HWND = 0)
	Local $IMODE = Opt("MouseCoordMode", 1)
	Local $APOS = MouseGetPos()
	Opt("MouseCoordMode", $IMODE)
	Local $TPOINT = DllStructCreate($TAGPOINT)
	DllStructSetData($TPOINT, "X", $APOS[0])
	DllStructSetData($TPOINT, "Y", $APOS[1])
	If $FTOCLIENT Then
		_WINAPI_SCREENTOCLIENT($HWND, $TPOINT)
		If @error Then Return SetError(@error, @extended, 0)
	EndIf
	Return $TPOINT
EndFunc
Func _WINAPI_GETMOUSEPOSX($FTOCLIENT = False, $HWND = 0)
	Local $TPOINT = _WINAPI_GETMOUSEPOS($FTOCLIENT, $HWND)
	If @error Then Return SetError(@error, @extended, 0)
	Return DllStructGetData($TPOINT, "X")
EndFunc
Func _WINAPI_GETMOUSEPOSY($FTOCLIENT = False, $HWND = 0)
	Local $TPOINT = _WINAPI_GETMOUSEPOS($FTOCLIENT, $HWND)
	If @error Then Return SetError(@error, @extended, 0)
	Return DllStructGetData($TPOINT, "Y")
EndFunc
Func _WINAPI_GETOBJECT($HOBJECT, $ISIZE, $POBJECT)
	Local $ARESULT = DllCall("gdi32.dll", "int", "GetObjectW", "handle", $HOBJECT, "int", $ISIZE, "ptr", $POBJECT)
	If @error Then Return SetError(@error, @extended, 0)
	Return $ARESULT[0]
EndFunc
Func _WINAPI_GETOPENFILENAME($STITLE = "", $SFILTER = "All files (*.*)", $SINITALDIR = ".", $SDEFAULTFILE = "", $SDEFAULTEXT = "", $IFILTERINDEX = 1, $IFLAGS = 0, $IFLAGSEX = 0, $HWNDOWNER = 0)
	Local $IPATHLEN = 4096
	Local $INULLS = 0
	Local $TOFN = DllStructCreate($TAGOPENFILENAME)
	Local $AFILES[1] = [0]
	Local $IFLAG = $IFLAGS
	Local $ASFLINES = StringSplit($SFILTER, "|")
	Local $ASFILTER[$ASFLINES[0] * 2 + 1]
	Local $ISTART, $IFINAL, $STFILTER
	$ASFILTER[0] = $ASFLINES[0] * 2
	For $I = 1 To $ASFLINES[0]
		$ISTART = StringInStr($ASFLINES[$I], "(", 0, 1)
		$IFINAL = StringInStr($ASFLINES[$I], ")", 0, -1)
		$ASFILTER[$I * 2 - 1] = StringStripWS(StringLeft($ASFLINES[$I], $ISTART - 1), 3)
		$ASFILTER[$I * 2] = StringStripWS(StringTrimRight(StringTrimLeft($ASFLINES[$I], $ISTART), StringLen($ASFLINES[$I]) - $IFINAL + 1), 3)
		$STFILTER &= "wchar[" & StringLen($ASFILTER[$I * 2 - 1]) + 1 & "];wchar[" & StringLen($ASFILTER[$I * 2]) + 1 & "];"
	Next
	Local $TTITLE = DllStructCreate("wchar Title[" & StringLen($STITLE) + 1 & "]")
	Local $TINITIALDIR = DllStructCreate("wchar InitDir[" & StringLen($SINITALDIR) + 1 & "]")
	Local $TFILTER = DllStructCreate($STFILTER & "wchar")
	Local $TPATH = DllStructCreate("wchar Path[" & $IPATHLEN & "]")
	Local $TEXTN = DllStructCreate("wchar Extension[" & StringLen($SDEFAULTEXT) + 1 & "]")
	For $I = 1 To $ASFILTER[0]
		DllStructSetData($TFILTER, $I, $ASFILTER[$I])
	Next
	DllStructSetData($TTITLE, "Title", $STITLE)
	DllStructSetData($TINITIALDIR, "InitDir", $SINITALDIR)
	DllStructSetData($TPATH, "Path", $SDEFAULTFILE)
	DllStructSetData($TEXTN, "Extension", $SDEFAULTEXT)
	DllStructSetData($TOFN, "StructSize", DllStructGetSize($TOFN))
	DllStructSetData($TOFN, "hwndOwner", $HWNDOWNER)
	DllStructSetData($TOFN, "lpstrFilter", DllStructGetPtr($TFILTER))
	DllStructSetData($TOFN, "nFilterIndex", $IFILTERINDEX)
	DllStructSetData($TOFN, "lpstrFile", DllStructGetPtr($TPATH))
	DllStructSetData($TOFN, "nMaxFile", $IPATHLEN)
	DllStructSetData($TOFN, "lpstrInitialDir", DllStructGetPtr($TINITIALDIR))
	DllStructSetData($TOFN, "lpstrTitle", DllStructGetPtr($TTITLE))
	DllStructSetData($TOFN, "Flags", $IFLAG)
	DllStructSetData($TOFN, "lpstrDefExt", DllStructGetPtr($TEXTN))
	DllStructSetData($TOFN, "FlagsEx", $IFLAGSEX)
	DllCall("comdlg32.dll", "bool", "GetOpenFileNameW", "struct*", $TOFN)
	If @error Then Return SetError(@error, @extended, $AFILES)
	If BitAND($IFLAGS, $OFN_ALLOWMULTISELECT) = $OFN_ALLOWMULTISELECT And BitAND($IFLAGS, $OFN_EXPLORER) = $OFN_EXPLORER Then
		For $X = 1 To $IPATHLEN
			If DllStructGetData($TPATH, "Path", $X) = Chr(0) Then
				DllStructSetData($TPATH, "Path", "|", $X)
				$INULLS += 1
			Else
				$INULLS = 0
			EndIf
			If $INULLS = 2 Then ExitLoop
		Next
		DllStructSetData($TPATH, "Path", Chr(0), $X - 1)
		$AFILES = StringSplit(DllStructGetData($TPATH, "Path"), "|")
		If $AFILES[0] = 1 Then Return __WINAPI_PARSEFILEDIALOGPATH(DllStructGetData($TPATH, "Path"))
		Return StringSplit(DllStructGetData($TPATH, "Path"), "|")
	ElseIf BitAND($IFLAGS, $OFN_ALLOWMULTISELECT) = $OFN_ALLOWMULTISELECT Then
		$AFILES = StringSplit(DllStructGetData($TPATH, "Path"), " ")
		If $AFILES[0] = 1 Then Return __WINAPI_PARSEFILEDIALOGPATH(DllStructGetData($TPATH, "Path"))
		Return StringSplit(StringReplace(DllStructGetData($TPATH, "Path"), " ", "|"), "|")
	Else
		Return __WINAPI_PARSEFILEDIALOGPATH(DllStructGetData($TPATH, "Path"))
	EndIf
EndFunc
Func _WINAPI_GETOVERLAPPEDRESULT($HFILE, $POVERLAPPED, ByRef $IBYTES, $FWAIT = False)
	Local $ARESULT = DllCall("kernel32.dll", "bool", "GetOverlappedResult", "handle", $HFILE, "ptr", $POVERLAPPED, "dword*", 0, "bool", $FWAIT)
	If @error Then Return SetError(@error, @extended, False)
	$IBYTES = $ARESULT[3]
	Return $ARESULT[0]
EndFunc
Func _WINAPI_GETPARENT($HWND)
	Local $ARESULT = DllCall("user32.dll", "hwnd", "GetParent", "hwnd", $HWND)
	If @error Then Return SetError(@error, @extended, 0)
	Return $ARESULT[0]
EndFunc
Func _WINAPI_GETPROCESSAFFINITYMASK($HPROCESS)
	Local $ARESULT = DllCall("kernel32.dll", "bool", "GetProcessAffinityMask", "handle", $HPROCESS, "dword_ptr*", 0, "dword_ptr*", 0)
	If @error Then Return SetError(@error, @extended, 0)
	Local $AMASK[3]
	$AMASK[0] = True
	$AMASK[1] = $ARESULT[2]
	$AMASK[2] = $ARESULT[3]
	Return $AMASK
EndFunc
Func _WINAPI_GETSAVEFILENAME($STITLE = "", $SFILTER = "All files (*.*)", $SINITALDIR = ".", $SDEFAULTFILE = "", $SDEFAULTEXT = "", $IFILTERINDEX = 1, $IFLAGS = 0, $IFLAGSEX = 0, $HWNDOWNER = 0)
	Local $IPATHLEN = 4096
	Local $TOFN = DllStructCreate($TAGOPENFILENAME)
	Local $AFILES[1] = [0]
	Local $IFLAG = $IFLAGS
	Local $ASFLINES = StringSplit($SFILTER, "|")
	Local $ASFILTER[$ASFLINES[0] * 2 + 1]
	Local $ISTART, $IFINAL, $STFILTER
	$ASFILTER[0] = $ASFLINES[0] * 2
	For $I = 1 To $ASFLINES[0]
		$ISTART = StringInStr($ASFLINES[$I], "(", 0, 1)
		$IFINAL = StringInStr($ASFLINES[$I], ")", 0, -1)
		$ASFILTER[$I * 2 - 1] = StringStripWS(StringLeft($ASFLINES[$I], $ISTART - 1), 3)
		$ASFILTER[$I * 2] = StringStripWS(StringTrimRight(StringTrimLeft($ASFLINES[$I], $ISTART), StringLen($ASFLINES[$I]) - $IFINAL + 1), 3)
		$STFILTER &= "wchar[" & StringLen($ASFILTER[$I * 2 - 1]) + 1 & "];wchar[" & StringLen($ASFILTER[$I * 2]) + 1 & "];"
	Next
	Local $TTITLE = DllStructCreate("wchar Title[" & StringLen($STITLE) + 1 & "]")
	Local $TINITIALDIR = DllStructCreate("wchar InitDir[" & StringLen($SINITALDIR) + 1 & "]")
	Local $TFILTER = DllStructCreate($STFILTER & "wchar")
	Local $TPATH = DllStructCreate("wchar Path[" & $IPATHLEN & "]")
	Local $TEXTN = DllStructCreate("wchar Extension[" & StringLen($SDEFAULTEXT) + 1 & "]")
	For $I = 1 To $ASFILTER[0]
		DllStructSetData($TFILTER, $I, $ASFILTER[$I])
	Next
	DllStructSetData($TTITLE, "Title", $STITLE)
	DllStructSetData($TINITIALDIR, "InitDir", $SINITALDIR)
	DllStructSetData($TPATH, "Path", $SDEFAULTFILE)
	DllStructSetData($TEXTN, "Extension", $SDEFAULTEXT)
	DllStructSetData($TOFN, "StructSize", DllStructGetSize($TOFN))
	DllStructSetData($TOFN, "hwndOwner", $HWNDOWNER)
	DllStructSetData($TOFN, "lpstrFilter", DllStructGetPtr($TFILTER))
	DllStructSetData($TOFN, "nFilterIndex", $IFILTERINDEX)
	DllStructSetData($TOFN, "lpstrFile", DllStructGetPtr($TPATH))
	DllStructSetData($TOFN, "nMaxFile", $IPATHLEN)
	DllStructSetData($TOFN, "lpstrInitialDir", DllStructGetPtr($TINITIALDIR))
	DllStructSetData($TOFN, "lpstrTitle", DllStructGetPtr($TTITLE))
	DllStructSetData($TOFN, "Flags", $IFLAG)
	DllStructSetData($TOFN, "lpstrDefExt", DllStructGetPtr($TEXTN))
	DllStructSetData($TOFN, "FlagsEx", $IFLAGSEX)
	DllCall("comdlg32.dll", "bool", "GetSaveFileNameW", "struct*", $TOFN)
	If @error Then Return SetError(@error, @extended, $AFILES)
	Return __WINAPI_PARSEFILEDIALOGPATH(DllStructGetData($TPATH, "Path"))
EndFunc
Func _WINAPI_GETSTOCKOBJECT($IOBJECT)
	Local $ARESULT = DllCall("gdi32.dll", "handle", "GetStockObject", "int", $IOBJECT)
	If @error Then Return SetError(@error, @extended, 0)
	Return $ARESULT[0]
EndFunc
Func _WINAPI_GETSTDHANDLE($ISTDHANDLE)
	If $ISTDHANDLE < 0 Or $ISTDHANDLE > 2 Then Return SetError(2, 0, -1)
	Local Const $AHANDLE[3] = [-10, -11, -12]
	Local $ARESULT = DllCall("kernel32.dll", "handle", "GetStdHandle", "dword", $AHANDLE[$ISTDHANDLE])
	If @error Then Return SetError(@error, @extended, -1)
	Return $ARESULT[0]
EndFunc
Func _WINAPI_GETSYSCOLOR($IINDEX)
	Local $ARESULT = DllCall("user32.dll", "dword", "GetSysColor", "int", $IINDEX)
	If @error Then Return SetError(@error, @extended, 0)
	Return $ARESULT[0]
EndFunc
Func _WINAPI_GETSYSCOLORBRUSH($IINDEX)
	Local $ARESULT = DllCall("user32.dll", "handle", "GetSysColorBrush", "int", $IINDEX)
	If @error Then Return SetError(@error, @extended, 0)
	Return $ARESULT[0]
EndFunc
Func _WINAPI_GETSYSTEMMETRICS($IINDEX)
	Local $ARESULT = DllCall("user32.dll", "int", "GetSystemMetrics", "int", $IINDEX)
	If @error Then Return SetError(@error, @extended, 0)
	Return $ARESULT[0]
EndFunc
Func _WINAPI_GETTEXTEXTENTPOINT32($HDC, $STEXT)
	Local $TSIZE = DllStructCreate($TAGSIZE)
	Local $ISIZE = StringLen($STEXT)
	DllCall("gdi32.dll", "bool", "GetTextExtentPoint32W", "handle", $HDC, "wstr", $STEXT, "int", $ISIZE, "struct*", $TSIZE)
	If @error Then Return SetError(@error, @extended, 0)
	Return $TSIZE
EndFunc
Func _WINAPI_GETTEXTMETRICS($HDC)
	Local $TTEXTMETRIC = DllStructCreate($TAGTEXTMETRIC)
	Local $RET = DllCall("gdi32.dll", "bool", "GetTextMetricsW", "handle", $HDC, "struct*", $TTEXTMETRIC)
	If @error Then Return SetError(@error, @extended, 0)
	If Not $RET[0] Then Return SetError(-1, 0, 0)
	Return $TTEXTMETRIC
EndFunc
Func _WINAPI_GETWINDOW($HWND, $ICMD)
	Local $ARESULT = DllCall("user32.dll", "hwnd", "GetWindow", "hwnd", $HWND, "uint", $ICMD)
	If @error Then Return SetError(@error, @extended, 0)
	Return $ARESULT[0]
EndFunc
Func _WINAPI_GETWINDOWDC($HWND)
	Local $ARESULT = DllCall("user32.dll", "handle", "GetWindowDC", "hwnd", $HWND)
	If @error Then Return SetError(@error, @extended, 0)
	Return $ARESULT[0]
EndFunc
Func _WINAPI_GETWINDOWHEIGHT($HWND)
	Local $TRECT = _WINAPI_GETWINDOWRECT($HWND)
	If @error Then Return SetError(@error, @extended, 0)
	Return DllStructGetData($TRECT, "Bottom") - DllStructGetData($TRECT, "Top")
EndFunc
Func _WINAPI_GETWINDOWLONG($HWND, $IINDEX)
	Local $SFUNCNAME = "GetWindowLongW"
	If @AutoItX64 Then $SFUNCNAME = "GetWindowLongPtrW"
	Local $ARESULT = DllCall("user32.dll", "long_ptr", $SFUNCNAME, "hwnd", $HWND, "int", $IINDEX)
	If @error Then Return SetError(@error, @extended, 0)
	Return $ARESULT[0]
EndFunc
Func _WINAPI_GETWINDOWPLACEMENT($HWND)
	Local $TWINDOWPLACEMENT = DllStructCreate($TAGWINDOWPLACEMENT)
	DllStructSetData($TWINDOWPLACEMENT, "length", DllStructGetSize($TWINDOWPLACEMENT))
	DllCall("user32.dll", "bool", "GetWindowPlacement", "hwnd", $HWND, "struct*", $TWINDOWPLACEMENT)
	If @error Then Return SetError(@error, @extended, 0)
	Return $TWINDOWPLACEMENT
EndFunc
Func _WINAPI_GETWINDOWRECT($HWND)
	Local $TRECT = DllStructCreate($TAGRECT)
	DllCall("user32.dll", "bool", "GetWindowRect", "hwnd", $HWND, "struct*", $TRECT)
	If @error Then Return SetError(@error, @extended, 0)
	Return $TRECT
EndFunc
Func _WINAPI_GETWINDOWRGN($HWND, $HRGN)
	Local $ARESULT = DllCall("user32.dll", "int", "GetWindowRgn", "hwnd", $HWND, "handle", $HRGN)
	If @error Then Return SetError(@error, @extended, 0)
	Return $ARESULT[0]
EndFunc
Func _WINAPI_GETWINDOWTEXT($HWND)
	Local $ARESULT = DllCall("user32.dll", "int", "GetWindowTextW", "hwnd", $HWND, "wstr", "", "int", 4096)
	If @error Then Return SetError(@error, @extended, "")
	Return SetExtended($ARESULT[0], $ARESULT[2])
EndFunc
Func _WINAPI_GETWINDOWTHREADPROCESSID($HWND, ByRef $IPID)
	Local $ARESULT = DllCall("user32.dll", "dword", "GetWindowThreadProcessId", "hwnd", $HWND, "dword*", 0)
	If @error Then Return SetError(@error, @extended, 0)
	$IPID = $ARESULT[2]
	Return $ARESULT[0]
EndFunc
Func _WINAPI_GETWINDOWWIDTH($HWND)
	Local $TRECT = _WINAPI_GETWINDOWRECT($HWND)
	If @error Then Return SetError(@error, @extended, 0)
	Return DllStructGetData($TRECT, "Right") - DllStructGetData($TRECT, "Left")
EndFunc
Func _WINAPI_GETXYFROMPOINT(ByRef $TPOINT, ByRef $IX, ByRef $IY)
	$IX = DllStructGetData($TPOINT, "X")
	$IY = DllStructGetData($TPOINT, "Y")
EndFunc
Func _WINAPI_GLOBALMEMORYSTATUS()
	Local $TMEM = DllStructCreate($TAGMEMORYSTATUSEX)
	Local $IMEM = DllStructGetSize($TMEM)
	DllStructSetData($TMEM, 1, $IMEM)
	DllCall("kernel32.dll", "none", "GlobalMemoryStatusEx", "ptr", $TMEM)
	If @error Then Return SetError(@error, @extended, 0)
	Local $AMEM[7]
	$AMEM[0] = DllStructGetData($TMEM, 2)
	$AMEM[1] = DllStructGetData($TMEM, 3)
	$AMEM[2] = DllStructGetData($TMEM, 4)
	$AMEM[3] = DllStructGetData($TMEM, 5)
	$AMEM[4] = DllStructGetData($TMEM, 6)
	$AMEM[5] = DllStructGetData($TMEM, 7)
	$AMEM[6] = DllStructGetData($TMEM, 8)
	Return $AMEM
EndFunc
Func _WINAPI_GUIDFROMSTRING($SGUID)
	Local $TGUID = DllStructCreate($TAGGUID)
	_WINAPI_GUIDFROMSTRINGEX($SGUID, $TGUID)
	If @error Then Return SetError(@error, @extended, 0)
	Return $TGUID
EndFunc
Func _WINAPI_GUIDFROMSTRINGEX($SGUID, $PGUID)
	Local $ARESULT = DllCall("ole32.dll", "long", "CLSIDFromString", "wstr", $SGUID, "struct*", $PGUID)
	If @error Then Return SetError(@error, @extended, False)
	Return $ARESULT[0]
EndFunc
Func _WINAPI_HIWORD($ILONG)
	Return BitShift($ILONG, 16)
EndFunc
Func _WINAPI_INPROCESS($HWND, ByRef $HLASTWND)
	If $HWND = $HLASTWND Then Return True
	For $II = $__GAINPROCESS_WINAPI[0][0] To 1 Step -1
		If $HWND = $__GAINPROCESS_WINAPI[$II][0] Then
			If $__GAINPROCESS_WINAPI[$II][1] Then
				$HLASTWND = $HWND
				Return True
			Else
				Return False
			EndIf
		EndIf
	Next
	Local $IPROCESSID
	_WINAPI_GETWINDOWTHREADPROCESSID($HWND, $IPROCESSID)
	Local $ICOUNT = $__GAINPROCESS_WINAPI[0][0] + 1
	If $ICOUNT >= 64 Then $ICOUNT = 1
	$__GAINPROCESS_WINAPI[0][0] = $ICOUNT
	$__GAINPROCESS_WINAPI[$ICOUNT][0] = $HWND
	$__GAINPROCESS_WINAPI[$ICOUNT][1] = ($IPROCESSID = @AutoItPID)
	Return $__GAINPROCESS_WINAPI[$ICOUNT][1]
EndFunc
Func _WINAPI_INTTOFLOAT($IINT)
	Local $TINT = DllStructCreate("int")
	Local $TFLOAT = DllStructCreate("float", DllStructGetPtr($TINT))
	DllStructSetData($TINT, 1, $IINT)
	Return DllStructGetData($TFLOAT, 1)
EndFunc
Func _WINAPI_ISCLASSNAME($HWND, $SCLASSNAME)
	Local $SSEPARATOR = Opt("GUIDataSeparatorChar")
	Local $ACLASSNAME = StringSplit($SCLASSNAME, $SSEPARATOR)
	If Not IsHWnd($HWND) Then $HWND = GUICtrlGetHandle($HWND)
	Local $SCLASSCHECK = _WINAPI_GETCLASSNAME($HWND)
	For $X = 1 To UBound($ACLASSNAME) - 1
		If StringUpper(StringMid($SCLASSCHECK, 1, StringLen($ACLASSNAME[$X]))) = StringUpper($ACLASSNAME[$X]) Then Return True
	Next
	Return False
EndFunc
Func _WINAPI_ISWINDOW($HWND)
	Local $ARESULT = DllCall("user32.dll", "bool", "IsWindow", "hwnd", $HWND)
	If @error Then Return SetError(@error, @extended, 0)
	Return $ARESULT[0]
EndFunc
Func _WINAPI_ISWINDOWVISIBLE($HWND)
	Local $ARESULT = DllCall("user32.dll", "bool", "IsWindowVisible", "hwnd", $HWND)
	If @error Then Return SetError(@error, @extended, 0)
	Return $ARESULT[0]
EndFunc
Func _WINAPI_INVALIDATERECT($HWND, $TRECT = 0, $FERASE = True)
	Local $ARESULT = DllCall("user32.dll", "bool", "InvalidateRect", "hwnd", $HWND, "struct*", $TRECT, "bool", $FERASE)
	If @error Then Return SetError(@error, @extended, False)
	Return $ARESULT[0]
EndFunc
Func _WINAPI_LINETO($HDC, $IX, $IY)
	Local $ARESULT = DllCall("gdi32.dll", "bool", "LineTo", "handle", $HDC, "int", $IX, "int", $IY)
	If @error Then Return SetError(@error, @extended, False)
	Return $ARESULT[0]
EndFunc
Func _WINAPI_LOADBITMAP($HINSTANCE, $SBITMAP)
	Local $SBITMAPTYPE = "int"
	If IsString($SBITMAP) Then $SBITMAPTYPE = "wstr"
	Local $ARESULT = DllCall("user32.dll", "handle", "LoadBitmapW", "handle", $HINSTANCE, $SBITMAPTYPE, $SBITMAP)
	If @error Then Return SetError(@error, @extended, 0)
	Return $ARESULT[0]
EndFunc
Func _WINAPI_LOADIMAGE($HINSTANCE, $SIMAGE, $ITYPE, $IXDESIRED, $IYDESIRED, $ILOAD)
	Local $ARESULT, $SIMAGETYPE = "int"
	If IsString($SIMAGE) Then $SIMAGETYPE = "wstr"
	$ARESULT = DllCall("user32.dll", "handle", "LoadImageW", "handle", $HINSTANCE, $SIMAGETYPE, $SIMAGE, "uint", $ITYPE, "int", $IXDESIRED, "int", $IYDESIRED, "uint", $ILOAD)
	If @error Then Return SetError(@error, @extended, 0)
	Return $ARESULT[0]
EndFunc
Func _WINAPI_LOADLIBRARY($SFILENAME)
	Local $ARESULT = DllCall("kernel32.dll", "handle", "LoadLibraryW", "wstr", $SFILENAME)
	If @error Then Return SetError(@error, @extended, 0)
	Return $ARESULT[0]
EndFunc
Func _WINAPI_LOADLIBRARYEX($SFILENAME, $IFLAGS = 0)
	Local $ARESULT = DllCall("kernel32.dll", "handle", "LoadLibraryExW", "wstr", $SFILENAME, "ptr", 0, "dword", $IFLAGS)
	If @error Then Return SetError(@error, @extended, 0)
	Return $ARESULT[0]
EndFunc
Func _WINAPI_LOADSHELL32ICON($IICONID)
	Local $TICONS = DllStructCreate("ptr Data")
	Local $IICONS = _WINAPI_EXTRACTICONEX("shell32.dll", $IICONID, 0, $TICONS, 1)
	If @error Then Return SetError(@error, @extended, 0)
	If $IICONS <= 0 Then Return SetError(1, 0, 0)
	Return DllStructGetData($TICONS, "Data")
EndFunc
Func _WINAPI_LOADSTRING($HINSTANCE, $ISTRINGID)
	Local $ARESULT = DllCall("user32.dll", "int", "LoadStringW", "handle", $HINSTANCE, "uint", $ISTRINGID, "wstr", "", "int", 4096)
	If @error Then Return SetError(@error, @extended, "")
	Return SetExtended($ARESULT[0], $ARESULT[3])
EndFunc
Func _WINAPI_LOCALFREE($HMEM)
	Local $ARESULT = DllCall("kernel32.dll", "handle", "LocalFree", "handle", $HMEM)
	If @error Then Return SetError(@error, @extended, False)
	Return $ARESULT[0]
EndFunc
Func _WINAPI_LOWORD($ILONG)
	Return BitAND($ILONG, 65535)
EndFunc
Func _WINAPI_MAKELANGID($LGIDPRIMARY, $LGIDSUB)
	Return BitOR(BitShift($LGIDSUB, -10), $LGIDPRIMARY)
EndFunc
Func _WINAPI_MAKELCID($LGID, $SRTID)
	Return BitOR(BitShift($SRTID, -16), $LGID)
EndFunc
Func _WINAPI_MAKELONG($ILO, $IHI)
	Return BitOR(BitShift($IHI, -16), BitAND($ILO, 65535))
EndFunc
Func _WINAPI_MAKEQWORD($LODWORD, $HIDWORD)
	Local $TINT64 = DllStructCreate("uint64")
	Local $TDWORDS = DllStructCreate("dword;dword", DllStructGetPtr($TINT64))
	DllStructSetData($TDWORDS, 1, $LODWORD)
	DllStructSetData($TDWORDS, 2, $HIDWORD)
	Return DllStructGetData($TINT64, 1)
EndFunc
Func _WINAPI_MESSAGEBEEP($ITYPE = 1)
	Local $ISOUND
	Switch $ITYPE
		Case 1
			$ISOUND = 0
		Case 2
			$ISOUND = 16
		Case 3
			$ISOUND = 32
		Case 4
			$ISOUND = 48
		Case 5
			$ISOUND = 64
		Case Else
			$ISOUND = -1
	EndSwitch
	Local $ARESULT = DllCall("user32.dll", "bool", "MessageBeep", "uint", $ISOUND)
	If @error Then Return SetError(@error, @extended, False)
	Return $ARESULT[0]
EndFunc
Func _WINAPI_MSGBOX($IFLAGS, $STITLE, $STEXT)
	BlockInput(0)
	MsgBox($IFLAGS, $STITLE, $STEXT & "      ")
EndFunc
Func _WINAPI_MOUSE_EVENT($IFLAGS, $IX = 0, $IY = 0, $IDATA = 0, $IEXTRAINFO = 0)
	DllCall("user32.dll", "none", "mouse_event", "dword", $IFLAGS, "dword", $IX, "dword", $IY, "dword", $IDATA, "ulong_ptr", $IEXTRAINFO)
	If @error Then Return SetError(@error, @extended)
EndFunc
Func _WINAPI_MOVETO($HDC, $IX, $IY)
	Local $ARESULT = DllCall("gdi32.dll", "bool", "MoveToEx", "handle", $HDC, "int", $IX, "int", $IY, "ptr", 0)
	If @error Then Return SetError(@error, @extended, False)
	Return $ARESULT[0]
EndFunc
Func _WINAPI_MOVEWINDOW($HWND, $IX, $IY, $IWIDTH, $IHEIGHT, $FREPAINT = True)
	Local $ARESULT = DllCall("user32.dll", "bool", "MoveWindow", "hwnd", $HWND, "int", $IX, "int", $IY, "int", $IWIDTH, "int", $IHEIGHT, "bool", $FREPAINT)
	If @error Then Return SetError(@error, @extended, False)
	Return $ARESULT[0]
EndFunc
Func _WINAPI_MULDIV($INUMBER, $INUMERATOR, $IDENOMINATOR)
	Local $ARESULT = DllCall("kernel32.dll", "int", "MulDiv", "int", $INUMBER, "int", $INUMERATOR, "int", $IDENOMINATOR)
	If @error Then Return SetError(@error, @extended, -1)
	Return $ARESULT[0]
EndFunc
Func _WINAPI_MULTIBYTETOWIDECHAR($STEXT, $ICODEPAGE = 0, $IFLAGS = 0, $BRETSTRING = False)
	Local $STEXTTYPE = "str"
	If Not IsString($STEXT) Then $STEXTTYPE = "struct*"
	Local $ARESULT = DllCall("kernel32.dll", "int", "MultiByteToWideChar", "uint", $ICODEPAGE, "dword", $IFLAGS, $STEXTTYPE, $STEXT, "int", -1, "ptr", 0, "int", 0)
	If @error Then Return SetError(@error, @extended, 0)
	Local $IOUT = $ARESULT[0]
	Local $TOUT = DllStructCreate("wchar[" & $IOUT & "]")
	$ARESULT = DllCall("kernel32.dll", "int", "MultiByteToWideChar", "uint", $ICODEPAGE, "dword", $IFLAGS, $STEXTTYPE, $STEXT, "int", -1, "struct*", $TOUT, "int", $IOUT)
	If @error Then Return SetError(@error, @extended, 0)
	If $BRETSTRING Then Return DllStructGetData($TOUT, 1)
	Return $TOUT
EndFunc
Func _WINAPI_MULTIBYTETOWIDECHAREX($STEXT, $PTEXT, $ICODEPAGE = 0, $IFLAGS = 0)
	Local $ARESULT = DllCall("kernel32.dll", "int", "MultiByteToWideChar", "uint", $ICODEPAGE, "dword", $IFLAGS, "STR", $STEXT, "int", -1, "struct*", $PTEXT, "int", (StringLen($STEXT) + 1) * 2)
	If @error Then Return SetError(@error, @extended, False)
	Return $ARESULT[0]
EndFunc
Func _WINAPI_OPENPROCESS($IACCESS, $FINHERIT, $IPROCESSID, $FDEBUGPRIV = False)
	Local $ARESULT = DllCall("kernel32.dll", "handle", "OpenProcess", "dword", $IACCESS, "bool", $FINHERIT, "dword", $IPROCESSID)
	If @error Then Return SetError(@error, @extended, 0)
	If $ARESULT[0] Then Return $ARESULT[0]
	If Not $FDEBUGPRIV Then Return 0
	Local $HTOKEN = _SECURITY__OPENTHREADTOKENEX(BitOR($TOKEN_ADJUST_PRIVILEGES, $TOKEN_QUERY))
	If @error Then Return SetError(@error, @extended, 0)
	_SECURITY__SETPRIVILEGE($HTOKEN, "SeDebugPrivilege", True)
	Local $IERROR = @error
	Local $ILASTERROR = @extended
	Local $IRET = 0
	If Not @error Then
		$ARESULT = DllCall("kernel32.dll", "handle", "OpenProcess", "dword", $IACCESS, "bool", $FINHERIT, "dword", $IPROCESSID)
		$IERROR = @error
		$ILASTERROR = @extended
		If $ARESULT[0] Then $IRET = $ARESULT[0]
		_SECURITY__SETPRIVILEGE($HTOKEN, "SeDebugPrivilege", False)
		If @error Then
			$IERROR = @error
			$ILASTERROR = @extended
		EndIf
	EndIf
	_WINAPI_CLOSEHANDLE($HTOKEN)
	Return SetError($IERROR, $ILASTERROR, $IRET)
EndFunc
Func __WINAPI_PARSEFILEDIALOGPATH($SPATH)
	Local $AFILES[3]
	$AFILES[0] = 2
	Local $STEMP = StringMid($SPATH, 1, StringInStr($SPATH, "\", 0, -1) - 1)
	$AFILES[1] = $STEMP
	$AFILES[2] = StringMid($SPATH, StringInStr($SPATH, "\", 0, -1) + 1)
	Return $AFILES
EndFunc
Func _WINAPI_PATHFINDONPATH(Const $SZFILE, $AEXTRAPATHS = "", Const $SZPATHDELIMITER = @LF)
	Local $IEXTRACOUNT = 0
	If IsString($AEXTRAPATHS) Then
		If StringLen($AEXTRAPATHS) Then
			$AEXTRAPATHS = StringSplit($AEXTRAPATHS, $SZPATHDELIMITER, 1 + 2)
			$IEXTRACOUNT = UBound($AEXTRAPATHS, 1)
		EndIf
	ElseIf IsArray($AEXTRAPATHS) Then
		$IEXTRACOUNT = UBound($AEXTRAPATHS)
	EndIf
	Local $TPATHS, $TPATHPTRS
	If $IEXTRACOUNT Then
		Local $SZSTRUCT = ""
		For $PATH In $AEXTRAPATHS
			$SZSTRUCT &= "wchar[" & StringLen($PATH) + 1 & "];"
		Next
		$TPATHS = DllStructCreate($SZSTRUCT)
		$TPATHPTRS = DllStructCreate("ptr[" & $IEXTRACOUNT + 1 & "]")
		For $I = 1 To $IEXTRACOUNT
			DllStructSetData($TPATHS, $I, $AEXTRAPATHS[$I - 1])
			DllStructSetData($TPATHPTRS, 1, DllStructGetPtr($TPATHS, $I), $I)
		Next
		DllStructSetData($TPATHPTRS, 1, Ptr(0), $IEXTRACOUNT + 1)
	EndIf
	Local $ARESULT = DllCall("shlwapi.dll", "bool", "PathFindOnPathW", "wstr", $SZFILE, "struct*", $TPATHPTRS)
	If @error Then Return SetError(@error, @extended, False)
	If $ARESULT[0] = 0 Then Return SetError(1, 0, $SZFILE)
	Return $ARESULT[1]
EndFunc
Func _WINAPI_POINTFROMRECT(ByRef $TRECT, $FCENTER = True)
	Local $IX1 = DllStructGetData($TRECT, "Left")
	Local $IY1 = DllStructGetData($TRECT, "Top")
	Local $IX2 = DllStructGetData($TRECT, "Right")
	Local $IY2 = DllStructGetData($TRECT, "Bottom")
	If $FCENTER Then
		$IX1 = $IX1 + (($IX2 - $IX1) / 2)
		$IY1 = $IY1 + (($IY2 - $IY1) / 2)
	EndIf
	Local $TPOINT = DllStructCreate($TAGPOINT)
	DllStructSetData($TPOINT, "X", $IX1)
	DllStructSetData($TPOINT, "Y", $IY1)
	Return $TPOINT
EndFunc
Func _WINAPI_POSTMESSAGE($HWND, $IMSG, $IWPARAM, $ILPARAM)
	Local $ARESULT = DllCall("user32.dll", "bool", "PostMessage", "hwnd", $HWND, "uint", $IMSG, "wparam", $IWPARAM, "lparam", $ILPARAM)
	If @error Then Return SetError(@error, @extended, False)
	Return $ARESULT[0]
EndFunc
Func _WINAPI_PRIMARYLANGID($LGID)
	Return BitAND($LGID, 1023)
EndFunc
Func _WINAPI_PTINRECT(ByRef $TRECT, ByRef $TPOINT)
	Local $ARESULT = DllCall("user32.dll", "bool", "PtInRect", "struct*", $TRECT, "struct", $TPOINT)
	If @error Then Return SetError(1, @extended, False)
	Return NOT ($ARESULT[0] = 0)
EndFunc
Func _WINAPI_READFILE($HFILE, $PBUFFER, $ITOREAD, ByRef $IREAD, $POVERLAPPED = 0)
	Local $ARESULT = DllCall("kernel32.dll", "bool", "ReadFile", "handle", $HFILE, "ptr", $PBUFFER, "dword", $ITOREAD, "dword*", 0, "ptr", $POVERLAPPED)
	If @error Then Return SetError(@error, @extended, False)
	$IREAD = $ARESULT[4]
	Return $ARESULT[0]
EndFunc
Func _WINAPI_READPROCESSMEMORY($HPROCESS, $PBASEADDRESS, $PBUFFER, $ISIZE, ByRef $IREAD)
	Local $ARESULT = DllCall("kernel32.dll", "bool", "ReadProcessMemory", "handle", $HPROCESS, "ptr", $PBASEADDRESS, "ptr", $PBUFFER, "ulong_ptr", $ISIZE, "ulong_ptr*", 0)
	If @error Then Return SetError(@error, @extended, False)
	$IREAD = $ARESULT[5]
	Return $ARESULT[0]
EndFunc
Func _WINAPI_RECTISEMPTY(ByRef $TRECT)
	RETURN (DllStructGetData($TRECT, "Left") = 0) AND (DllStructGetData($TRECT, "Top") = 0) AND (DllStructGetData($TRECT, "Right") = 0) AND (DllStructGetData($TRECT, "Bottom") = 0)
EndFunc
Func _WINAPI_REDRAWWINDOW($HWND, $TRECT = 0, $HREGION = 0, $IFLAGS = 5)
	Local $ARESULT = DllCall("user32.dll", "bool", "RedrawWindow", "hwnd", $HWND, "struct*", $TRECT, "handle", $HREGION, "uint", $IFLAGS)
	If @error Then Return SetError(@error, @extended, False)
	Return $ARESULT[0]
EndFunc
Func _WINAPI_REGISTERWINDOWMESSAGE($SMESSAGE)
	Local $ARESULT = DllCall("user32.dll", "uint", "RegisterWindowMessageW", "wstr", $SMESSAGE)
	If @error Then Return SetError(@error, @extended, 0)
	Return $ARESULT[0]
EndFunc
Func _WINAPI_RELEASECAPTURE()
	Local $ARESULT = DllCall("user32.dll", "bool", "ReleaseCapture")
	If @error Then Return SetError(@error, @extended, False)
	Return $ARESULT[0]
EndFunc
Func _WINAPI_RELEASEDC($HWND, $HDC)
	Local $ARESULT = DllCall("user32.dll", "int", "ReleaseDC", "hwnd", $HWND, "handle", $HDC)
	If @error Then Return SetError(@error, @extended, False)
	Return $ARESULT[0]
EndFunc
Func _WINAPI_SCREENTOCLIENT($HWND, ByRef $TPOINT)
	Local $ARESULT = DllCall("user32.dll", "bool", "ScreenToClient", "hwnd", $HWND, "struct*", $TPOINT)
	If @error Then Return SetError(@error, @extended, False)
	Return $ARESULT[0]
EndFunc
Func _WINAPI_SELECTOBJECT($HDC, $HGDIOBJ)
	Local $ARESULT = DllCall("gdi32.dll", "handle", "SelectObject", "handle", $HDC, "handle", $HGDIOBJ)
	If @error Then Return SetError(@error, @extended, False)
	Return $ARESULT[0]
EndFunc
Func _WINAPI_SETBKCOLOR($HDC, $ICOLOR)
	Local $ARESULT = DllCall("gdi32.dll", "INT", "SetBkColor", "handle", $HDC, "dword", $ICOLOR)
	If @error Then Return SetError(@error, @extended, -1)
	Return $ARESULT[0]
EndFunc
Func _WINAPI_SETBKMODE($HDC, $IBKMODE)
	Local $ARESULT = DllCall("gdi32.dll", "int", "SetBkMode", "handle", $HDC, "int", $IBKMODE)
	If @error Then Return SetError(@error, @extended, 0)
	Return $ARESULT[0]
EndFunc
Func _WINAPI_SETCAPTURE($HWND)
	Local $ARESULT = DllCall("user32.dll", "hwnd", "SetCapture", "hwnd", $HWND)
	If @error Then Return SetError(@error, @extended, 0)
	Return $ARESULT[0]
EndFunc
Func _WINAPI_SETCURSOR($HCURSOR)
	Local $ARESULT = DllCall("user32.dll", "handle", "SetCursor", "handle", $HCURSOR)
	If @error Then Return SetError(@error, @extended, 0)
	Return $ARESULT[0]
EndFunc
Func _WINAPI_SETDEFAULTPRINTER($SPRINTER)
	Local $ARESULT = DllCall("winspool.drv", "bool", "SetDefaultPrinterW", "wstr", $SPRINTER)
	If @error Then Return SetError(@error, @extended, False)
	Return $ARESULT[0]
EndFunc
Func _WINAPI_SETDIBITS($HDC, $HBMP, $ISTARTSCAN, $ISCANLINES, $PBITS, $PBMI, $ICOLORUSE = 0)
	Local $ARESULT = DllCall("gdi32.dll", "int", "SetDIBits", "handle", $HDC, "handle", $HBMP, "uint", $ISTARTSCAN, "uint", $ISCANLINES, "ptr", $PBITS, "ptr", $PBMI, "uint", $ICOLORUSE)
	If @error Then Return SetError(@error, @extended, False)
	Return $ARESULT[0]
EndFunc
Func _WINAPI_SETENDOFFILE($HFILE)
	Local $ARESULT = DllCall("kernel32.dll", "bool", "SetEndOfFile", "handle", $HFILE)
	If @error Then Return SetError(@error, @extended, False)
	Return $ARESULT[0]
EndFunc
Func _WINAPI_SETEVENT($HEVENT)
	Local $ARESULT = DllCall("kernel32.dll", "bool", "SetEvent", "handle", $HEVENT)
	If @error Then Return SetError(@error, @extended, False)
	Return $ARESULT[0]
EndFunc
Func _WINAPI_SETFILEPOINTER($HFILE, $IPOS, $IMETHOD = 0)
	Local $ARESULT = DllCall("kernel32.dll", "INT", "SetFilePointer", "handle", $HFILE, "long", $IPOS, "ptr", 0, "long", $IMETHOD)
	If @error Then Return SetError(@error, @extended, -1)
	Return $ARESULT[0]
EndFunc
Func _WINAPI_SETFOCUS($HWND)
	Local $ARESULT = DllCall("user32.dll", "hwnd", "SetFocus", "hwnd", $HWND)
	If @error Then Return SetError(@error, @extended, 0)
	Return $ARESULT[0]
EndFunc
Func _WINAPI_SETFONT($HWND, $HFONT, $FREDRAW = True)
	_SENDMESSAGE($HWND, $__WINAPICONSTANT_WM_SETFONT, $HFONT, $FREDRAW, 0, "hwnd")
EndFunc
Func _WINAPI_SETHANDLEINFORMATION($HOBJECT, $IMASK, $IFLAGS)
	Local $ARESULT = DllCall("kernel32.dll", "bool", "SetHandleInformation", "handle", $HOBJECT, "dword", $IMASK, "dword", $IFLAGS)
	If @error Then Return SetError(@error, @extended, False)
	Return $ARESULT[0]
EndFunc
Func _WINAPI_SETLAYEREDWINDOWATTRIBUTES($HWND, $I_TRANSCOLOR, $TRANSPARENCY = 255, $DWFLAGS = 3, $ISCOLORREF = False)
	If $DWFLAGS = Default Or $DWFLAGS = "" Or $DWFLAGS < 0 Then $DWFLAGS = 3
	If Not $ISCOLORREF Then
		$I_TRANSCOLOR = Int(BinaryMid($I_TRANSCOLOR, 3, 1) & BinaryMid($I_TRANSCOLOR, 2, 1) & BinaryMid($I_TRANSCOLOR, 1, 1))
	EndIf
	Local $ARESULT = DllCall("user32.dll", "bool", "SetLayeredWindowAttributes", "hwnd", $HWND, "dword", $I_TRANSCOLOR, "byte", $TRANSPARENCY, "dword", $DWFLAGS)
	If @error Then Return SetError(@error, @extended, False)
	Return $ARESULT[0]
EndFunc
Func _WINAPI_SETPARENT($HWNDCHILD, $HWNDPARENT)
	Local $ARESULT = DllCall("user32.dll", "hwnd", "SetParent", "hwnd", $HWNDCHILD, "hwnd", $HWNDPARENT)
	If @error Then Return SetError(@error, @extended, 0)
	Return $ARESULT[0]
EndFunc
Func _WINAPI_SETPROCESSAFFINITYMASK($HPROCESS, $IMASK)
	Local $ARESULT = DllCall("kernel32.dll", "bool", "SetProcessAffinityMask", "handle", $HPROCESS, "ulong_ptr", $IMASK)
	If @error Then Return SetError(@error, @extended, False)
	Return $ARESULT[0]
EndFunc
Func _WINAPI_SETSYSCOLORS($VELEMENTS, $VCOLORS)
	Local $ISEARRAY = IsArray($VELEMENTS), $ISCARRAY = IsArray($VCOLORS)
	Local $IELEMENTNUM
	If Not $ISCARRAY And Not $ISEARRAY Then
		$IELEMENTNUM = 1
	ElseIf $ISCARRAY Or $ISEARRAY Then
		If Not $ISCARRAY Or Not $ISEARRAY Then Return SetError(-1, -1, False)
		If UBound($VELEMENTS) <> UBound($VCOLORS) Then Return SetError(-1, -1, False)
		$IELEMENTNUM = UBound($VELEMENTS)
	EndIf
	Local $TELEMENTS = DllStructCreate("int Element[" & $IELEMENTNUM & "]")
	Local $TCOLORS = DllStructCreate("dword NewColor[" & $IELEMENTNUM & "]")
	If Not $ISEARRAY Then
		DllStructSetData($TELEMENTS, "Element", $VELEMENTS, 1)
	Else
		For $X = 0 To $IELEMENTNUM - 1
			DllStructSetData($TELEMENTS, "Element", $VELEMENTS[$X], $X + 1)
		Next
	EndIf
	If Not $ISCARRAY Then
		DllStructSetData($TCOLORS, "NewColor", $VCOLORS, 1)
	Else
		For $X = 0 To $IELEMENTNUM - 1
			DllStructSetData($TCOLORS, "NewColor", $VCOLORS[$X], $X + 1)
		Next
	EndIf
	Local $ARESULT = DllCall("user32.dll", "bool", "SetSysColors", "int", $IELEMENTNUM, "struct*", $TELEMENTS, "struct*", $TCOLORS)
	If @error Then Return SetError(@error, @extended, False)
	Return $ARESULT[0]
EndFunc
Func _WINAPI_SETTEXTCOLOR($HDC, $ICOLOR)
	Local $ARESULT = DllCall("gdi32.dll", "INT", "SetTextColor", "handle", $HDC, "dword", $ICOLOR)
	If @error Then Return SetError(@error, @extended, -1)
	Return $ARESULT[0]
EndFunc
Func _WINAPI_SETWINDOWLONG($HWND, $IINDEX, $IVALUE)
	_WINAPI_SETLASTERROR(0)
	Local $SFUNCNAME = "SetWindowLongW"
	If @AutoItX64 Then $SFUNCNAME = "SetWindowLongPtrW"
	Local $ARESULT = DllCall("user32.dll", "long_ptr", $SFUNCNAME, "hwnd", $HWND, "int", $IINDEX, "long_ptr", $IVALUE)
	If @error Then Return SetError(@error, @extended, 0)
	Return $ARESULT[0]
EndFunc
Func _WINAPI_SETWINDOWPLACEMENT($HWND, $PWINDOWPLACEMENT)
	Local $ARESULT = DllCall("user32.dll", "bool", "SetWindowPlacement", "hwnd", $HWND, "ptr", $PWINDOWPLACEMENT)
	If @error Then Return SetError(@error, @extended, False)
	Return $ARESULT[0]
EndFunc
Func _WINAPI_SETWINDOWPOS($HWND, $HAFTER, $IX, $IY, $ICX, $ICY, $IFLAGS)
	Local $ARESULT = DllCall("user32.dll", "bool", "SetWindowPos", "hwnd", $HWND, "hwnd", $HAFTER, "int", $IX, "int", $IY, "int", $ICX, "int", $ICY, "uint", $IFLAGS)
	If @error Then Return SetError(@error, @extended, False)
	Return $ARESULT[0]
EndFunc
Func _WINAPI_SETWINDOWRGN($HWND, $HRGN, $BREDRAW = True)
	Local $ARESULT = DllCall("user32.dll", "int", "SetWindowRgn", "hwnd", $HWND, "handle", $HRGN, "bool", $BREDRAW)
	If @error Then Return SetError(@error, @extended, False)
	Return $ARESULT[0]
EndFunc
Func _WINAPI_SETWINDOWSHOOKEX($IDHOOK, $LPFN, $HMOD, $DWTHREADID = 0)
	Local $ARESULT = DllCall("user32.dll", "handle", "SetWindowsHookEx", "int", $IDHOOK, "ptr", $LPFN, "handle", $HMOD, "dword", $DWTHREADID)
	If @error Then Return SetError(@error, @extended, 0)
	Return $ARESULT[0]
EndFunc
Func _WINAPI_SETWINDOWTEXT($HWND, $STEXT)
	Local $ARESULT = DllCall("user32.dll", "bool", "SetWindowTextW", "hwnd", $HWND, "wstr", $STEXT)
	If @error Then Return SetError(@error, @extended, False)
	Return $ARESULT[0]
EndFunc
Func _WINAPI_SHOWCURSOR($FSHOW)
	Local $ARESULT = DllCall("user32.dll", "int", "ShowCursor", "bool", $FSHOW)
	If @error Then Return SetError(@error, @extended, 0)
	Return $ARESULT[0]
EndFunc
Func _WINAPI_SHOWERROR($STEXT, $FEXIT = True)
	_WINAPI_MSGBOX(266256, "Error", $STEXT)
	If $FEXIT Then Exit
EndFunc
Func _WINAPI_SHOWMSG($STEXT)
	_WINAPI_MSGBOX(64 + 4096, "Information", $STEXT)
EndFunc
Func _WINAPI_SHOWWINDOW($HWND, $ICMDSHOW = 5)
	Local $ARESULT = DllCall("user32.dll", "bool", "ShowWindow", "hwnd", $HWND, "int", $ICMDSHOW)
	If @error Then Return SetError(@error, @extended, False)
	Return $ARESULT[0]
EndFunc
Func _WINAPI_STRINGFROMGUID($PGUID)
	Local $ARESULT = DllCall("ole32.dll", "int", "StringFromGUID2", "struct*", $PGUID, "wstr", "", "int", 40)
	If @error Then Return SetError(@error, @extended, "")
	Return SetExtended($ARESULT[0], $ARESULT[2])
EndFunc
Func _WINAPI_STRINGLENA($VSTRING)
	Local $ACALL = DllCall("kernel32.dll", "int", "lstrlenA", "struct*", $VSTRING)
	If @error Then Return SetError(1, @extended, 0)
	Return $ACALL[0]
EndFunc
Func _WINAPI_STRINGLENW($VSTRING)
	Local $ACALL = DllCall("kernel32.dll", "int", "lstrlenW", "struct*", $VSTRING)
	If @error Then Return SetError(1, @extended, 0)
	Return $ACALL[0]
EndFunc
Func _WINAPI_SUBLANGID($LGID)
	Return BitShift($LGID, 10)
EndFunc
Func _WINAPI_SYSTEMPARAMETERSINFO($IACTION, $IPARAM = 0, $VPARAM = 0, $IWININI = 0)
	Local $ARESULT = DllCall("user32.dll", "bool", "SystemParametersInfoW", "uint", $IACTION, "uint", $IPARAM, "ptr", $VPARAM, "uint", $IWININI)
	If @error Then Return SetError(@error, @extended, False)
	Return $ARESULT[0]
EndFunc
Func _WINAPI_TWIPSPERPIXELX()
	Local $LNGDC, $TWIPSPERPIXELX
	$LNGDC = _WINAPI_GETDC(0)
	$TWIPSPERPIXELX = 1440 / _WINAPI_GETDEVICECAPS($LNGDC, $__WINAPICONSTANT_LOGPIXELSX)
	_WINAPI_RELEASEDC(0, $LNGDC)
	Return $TWIPSPERPIXELX
EndFunc
Func _WINAPI_TWIPSPERPIXELY()
	Local $LNGDC, $TWIPSPERPIXELY
	$LNGDC = _WINAPI_GETDC(0)
	$TWIPSPERPIXELY = 1440 / _WINAPI_GETDEVICECAPS($LNGDC, $__WINAPICONSTANT_LOGPIXELSY)
	_WINAPI_RELEASEDC(0, $LNGDC)
	Return $TWIPSPERPIXELY
EndFunc
Func _WINAPI_UNHOOKWINDOWSHOOKEX($HHK)
	Local $ARESULT = DllCall("user32.dll", "bool", "UnhookWindowsHookEx", "handle", $HHK)
	If @error Then Return SetError(@error, @extended, False)
	Return $ARESULT[0]
EndFunc
Func _WINAPI_UPDATELAYEREDWINDOW($HWND, $HDCDEST, $PPTDEST, $PSIZE, $HDCSRCE, $PPTSRCE, $IRGB, $PBLEND, $IFLAGS)
	Local $ARESULT = DllCall("user32.dll", "bool", "UpdateLayeredWindow", "hwnd", $HWND, "handle", $HDCDEST, "ptr", $PPTDEST, "ptr", $PSIZE, "handle", $HDCSRCE, "ptr", $PPTSRCE, "dword", $IRGB, "ptr", $PBLEND, "dword", $IFLAGS)
	If @error Then Return SetError(@error, @extended, False)
	Return $ARESULT[0]
EndFunc
Func _WINAPI_UPDATEWINDOW($HWND)
	Local $ARESULT = DllCall("user32.dll", "bool", "UpdateWindow", "hwnd", $HWND)
	If @error Then Return SetError(@error, @extended, False)
	Return $ARESULT[0]
EndFunc
Func _WINAPI_WAITFORINPUTIDLE($HPROCESS, $ITIMEOUT = -1)
	Local $ARESULT = DllCall("user32.dll", "dword", "WaitForInputIdle", "handle", $HPROCESS, "dword", $ITIMEOUT)
	If @error Then Return SetError(@error, @extended, False)
	Return $ARESULT[0]
EndFunc
Func _WINAPI_WAITFORMULTIPLEOBJECTS($ICOUNT, $PHANDLES, $FWAITALL = False, $ITIMEOUT = -1)
	Local $ARESULT = DllCall("kernel32.dll", "INT", "WaitForMultipleObjects", "dword", $ICOUNT, "ptr", $PHANDLES, "bool", $FWAITALL, "dword", $ITIMEOUT)
	If @error Then Return SetError(@error, @extended, -1)
	Return $ARESULT[0]
EndFunc
Func _WINAPI_WAITFORSINGLEOBJECT($HHANDLE, $ITIMEOUT = -1)
	Local $ARESULT = DllCall("kernel32.dll", "INT", "WaitForSingleObject", "handle", $HHANDLE, "dword", $ITIMEOUT)
	If @error Then Return SetError(@error, @extended, -1)
	Return $ARESULT[0]
EndFunc
Func _WINAPI_WIDECHARTOMULTIBYTE($PUNICODE, $ICODEPAGE = 0, $BRETSTRING = True)
	Local $SUNICODETYPE = "wstr"
	If Not IsString($PUNICODE) Then $SUNICODETYPE = "struct*"
	Local $ARESULT = DllCall("kernel32.dll", "int", "WideCharToMultiByte", "uint", $ICODEPAGE, "dword", 0, $SUNICODETYPE, $PUNICODE, "int", -1, "ptr", 0, "int", 0, "ptr", 0, "ptr", 0)
	If @error Then Return SetError(@error, @extended, "")
	Local $TMULTIBYTE = DllStructCreate("char[" & $ARESULT[0] & "]")
	$ARESULT = DllCall("kernel32.dll", "int", "WideCharToMultiByte", "uint", $ICODEPAGE, "dword", 0, $SUNICODETYPE, $PUNICODE, "int", -1, "struct*", $TMULTIBYTE, "int", $ARESULT[0], "ptr", 0, "ptr", 0)
	If @error Then Return SetError(@error, @extended, "")
	If $BRETSTRING Then Return DllStructGetData($TMULTIBYTE, 1)
	Return $TMULTIBYTE
EndFunc
Func _WINAPI_WINDOWFROMPOINT(ByRef $TPOINT)
	Local $ARESULT = DllCall("user32.dll", "hwnd", "WindowFromPoint", "struct", $TPOINT)
	If @error Then Return SetError(1, @extended, 0)
	Return $ARESULT[0]
EndFunc
Func _WINAPI_WRITECONSOLE($HCONSOLE, $STEXT)
	Local $ARESULT = DllCall("kernel32.dll", "bool", "WriteConsoleW", "handle", $HCONSOLE, "wstr", $STEXT, "dword", StringLen($STEXT), "dword*", 0, "ptr", 0)
	If @error Then Return SetError(@error, @extended, False)
	Return $ARESULT[0]
EndFunc
Func _WINAPI_WRITEFILE($HFILE, $PBUFFER, $ITOWRITE, ByRef $IWRITTEN, $POVERLAPPED = 0)
	Local $ARESULT = DllCall("kernel32.dll", "bool", "WriteFile", "handle", $HFILE, "ptr", $PBUFFER, "dword", $ITOWRITE, "dword*", 0, "ptr", $POVERLAPPED)
	If @error Then Return SetError(@error, @extended, False)
	$IWRITTEN = $ARESULT[4]
	Return $ARESULT[0]
EndFunc
Func _WINAPI_WRITEPROCESSMEMORY($HPROCESS, $PBASEADDRESS, $PBUFFER, $ISIZE, ByRef $IWRITTEN, $SBUFFER = "ptr")
	Local $ARESULT = DllCall("kernel32.dll", "bool", "WriteProcessMemory", "handle", $HPROCESS, "ptr", $PBASEADDRESS, $SBUFFER, $PBUFFER, "ulong_ptr", $ISIZE, "ulong_ptr*", 0)
	If @error Then Return SetError(@error, @extended, False)
	$IWRITTEN = $ARESULT[5]
	Return $ARESULT[0]
EndFunc
Func _SECURITY__ADJUSTTOKENPRIVILEGES($HTOKEN, $FDISABLEALL, $PNEWSTATE, $IBUFFERLEN, $PPREVSTATE = 0, $PREQUIRED = 0)
	Local $ACALL = DllCall("advapi32.dll", "bool", "AdjustTokenPrivileges", "handle", $HTOKEN, "bool", $FDISABLEALL, "struct*", $PNEWSTATE, "dword", $IBUFFERLEN, "struct*", $PPREVSTATE, "struct*", $PREQUIRED)
	If @error Then Return SetError(1, @extended, False)
	Return NOT ($ACALL[0] = 0)
EndFunc
Func _SECURITY__CREATEPROCESSWITHTOKEN($HTOKEN, $ILOGONFLAGS, $SCOMMANDLINE, $ICREATIONFLAGS, $SCURDIR, $TSTARTUPINFO, $TPROCESS_INFORMATION)
	Local $ACALL = DllCall("advapi32.dll", "bool", "CreateProcessWithTokenW", "handle", $HTOKEN, "dword", $ILOGONFLAGS, "ptr", 0, "wstr", $SCOMMANDLINE, "dword", $ICREATIONFLAGS, "struct*", 0, "wstr", $SCURDIR, "struct*", $TSTARTUPINFO, "struct*", $TPROCESS_INFORMATION)
	If @error Or Not $ACALL[0] Then Return SetError(1, @extended, False)
	Return True
EndFunc
Func _SECURITY__DUPLICATETOKENEX($HEXISTINGTOKEN, $IDESIREDACCESS, $IIMPERSONATIONLEVEL, $ITOKENTYPE)
	Local $ACALL = DllCall("advapi32.dll", "bool", "DuplicateTokenEx", "handle", $HEXISTINGTOKEN, "dword", $IDESIREDACCESS, "struct*", 0, "int", $IIMPERSONATIONLEVEL, "int", $ITOKENTYPE, "handle*", 0)
	If @error Or Not $ACALL[0] Then Return SetError(1, @extended, 0)
	Return $ACALL[6]
EndFunc
Func _SECURITY__GETACCOUNTSID($SACCOUNT, $SSYSTEM = "")
	Local $AACCT = _SECURITY__LOOKUPACCOUNTNAME($SACCOUNT, $SSYSTEM)
	If @error Then Return SetError(@error, @extended, 0)
	If IsArray($AACCT) Then Return _SECURITY__STRINGSIDTOSID($AACCT[0])
	Return ""
EndFunc
Func _SECURITY__GETLENGTHSID($PSID)
	If Not _SECURITY__ISVALIDSID($PSID) Then Return SetError(1, @extended, 0)
	Local $ACALL = DllCall("advapi32.dll", "dword", "GetLengthSid", "struct*", $PSID)
	If @error Then Return SetError(2, @extended, 0)
	Return $ACALL[0]
EndFunc
Func _SECURITY__GETTOKENINFORMATION($HTOKEN, $ICLASS)
	Local $ACALL = DllCall("advapi32.dll", "bool", "GetTokenInformation", "handle", $HTOKEN, "int", $ICLASS, "struct*", 0, "dword", 0, "dword*", 0)
	If @error Or Not $ACALL[5] Then Return SetError(1, @extended, 0)
	Local $ILEN = $ACALL[5]
	Local $TBUFFER = DllStructCreate("byte[" & $ILEN & "]")
	$ACALL = DllCall("advapi32.dll", "bool", "GetTokenInformation", "handle", $HTOKEN, "int", $ICLASS, "struct*", $TBUFFER, "dword", DllStructGetSize($TBUFFER), "dword*", 0)
	If @error Or Not $ACALL[0] Then Return SetError(2, @extended, 0)
	Return $TBUFFER
EndFunc
Func _SECURITY__IMPERSONATESELF($ILEVEL = $SECURITYIMPERSONATION)
	Local $ACALL = DllCall("advapi32.dll", "bool", "ImpersonateSelf", "int", $ILEVEL)
	If @error Then Return SetError(1, @extended, False)
	Return NOT ($ACALL[0] = 0)
EndFunc
Func _SECURITY__ISVALIDSID($PSID)
	Local $ACALL = DllCall("advapi32.dll", "bool", "IsValidSid", "struct*", $PSID)
	If @error Then Return SetError(1, @extended, False)
	Return NOT ($ACALL[0] = 0)
EndFunc
Func _SECURITY__LOOKUPACCOUNTNAME($SACCOUNT, $SSYSTEM = "")
	Local $TDATA = DllStructCreate("byte SID[256]")
	Local $ACALL = DllCall("advapi32.dll", "bool", "LookupAccountNameW", "wstr", $SSYSTEM, "wstr", $SACCOUNT, "struct*", $TDATA, "dword*", DllStructGetSize($TDATA), "wstr", "", "dword*", DllStructGetSize($TDATA), "int*", 0)
	If @error Or Not $ACALL[0] Then Return SetError(1, @extended, 0)
	Local $AACCT[3]
	$AACCT[0] = _SECURITY__SIDTOSTRINGSID(DllStructGetPtr($TDATA, "SID"))
	$AACCT[1] = $ACALL[5]
	$AACCT[2] = $ACALL[7]
	Return $AACCT
EndFunc
Func _SECURITY__LOOKUPACCOUNTSID($VSID, $SSYSTEM = "")
	Local $PSID, $AACCT[3]
	If IsString($VSID) Then
		$PSID = _SECURITY__STRINGSIDTOSID($VSID)
	Else
		$PSID = $VSID
	EndIf
	If Not _SECURITY__ISVALIDSID($PSID) Then Return SetError(1, @extended, 0)
	Local $TYPESYSTEM = "ptr"
	If $SSYSTEM Then $TYPESYSTEM = "wstr"
	Local $ACALL = DllCall("advapi32.dll", "bool", "LookupAccountSidW", $TYPESYSTEM, $SSYSTEM, "struct*", $PSID, "wstr", "", "dword*", 65536, "wstr", "", "dword*", 65536, "int*", 0)
	If @error Or Not $ACALL[0] Then Return SetError(2, @extended, 0)
	Local $AACCT[3]
	$AACCT[0] = $ACALL[3]
	$AACCT[1] = $ACALL[5]
	$AACCT[2] = $ACALL[7]
	Return $AACCT
EndFunc
Func _SECURITY__LOOKUPPRIVILEGEVALUE($SSYSTEM, $SNAME)
	Local $ACALL = DllCall("advapi32.dll", "bool", "LookupPrivilegeValueW", "wstr", $SSYSTEM, "wstr", $SNAME, "int64*", 0)
	If @error Or Not $ACALL[0] Then Return SetError(1, @extended, 0)
	Return $ACALL[3]
EndFunc
Func _SECURITY__OPENPROCESSTOKEN($HPROCESS, $IACCESS)
	Local $ACALL = DllCall("advapi32.dll", "bool", "OpenProcessToken", "handle", $HPROCESS, "dword", $IACCESS, "handle*", 0)
	If @error Or Not $ACALL[0] Then Return SetError(1, @extended, 0)
	Return $ACALL[3]
EndFunc
Func _SECURITY__OPENTHREADTOKEN($IACCESS, $HTHREAD = 0, $FOPENASSELF = False)
	If $HTHREAD = 0 Then $HTHREAD = _WINAPI_GETCURRENTTHREAD()
	If @error Then Return SetError(1, @extended, 0)
	Local $ACALL = DllCall("advapi32.dll", "bool", "OpenThreadToken", "handle", $HTHREAD, "dword", $IACCESS, "bool", $FOPENASSELF, "handle*", 0)
	If @error Or Not $ACALL[0] Then Return SetError(2, @extended, 0)
	Return $ACALL[4]
EndFunc
Func _SECURITY__OPENTHREADTOKENEX($IACCESS, $HTHREAD = 0, $FOPENASSELF = False)
	Local $HTOKEN = _SECURITY__OPENTHREADTOKEN($IACCESS, $HTHREAD, $FOPENASSELF)
	If $HTOKEN = 0 Then
		If _WINAPI_GETLASTERROR() <> $ERROR_NO_TOKEN Then Return SetError(3, _WINAPI_GETLASTERROR(), 0)
		If Not _SECURITY__IMPERSONATESELF() Then Return SetError(1, _WINAPI_GETLASTERROR(), 0)
		$HTOKEN = _SECURITY__OPENTHREADTOKEN($IACCESS, $HTHREAD, $FOPENASSELF)
		If $HTOKEN = 0 Then Return SetError(2, _WINAPI_GETLASTERROR(), 0)
	EndIf
	Return $HTOKEN
EndFunc
Func _SECURITY__SETPRIVILEGE($HTOKEN, $SPRIVILEGE, $FENABLE)
	Local $ILUID = _SECURITY__LOOKUPPRIVILEGEVALUE("", $SPRIVILEGE)
	If $ILUID = 0 Then Return SetError(1, @extended, False)
	Local $TCURRSTATE = DllStructCreate($TAGTOKEN_PRIVILEGES)
	Local $ICURRSTATE = DllStructGetSize($TCURRSTATE)
	Local $TPREVSTATE = DllStructCreate($TAGTOKEN_PRIVILEGES)
	Local $IPREVSTATE = DllStructGetSize($TPREVSTATE)
	Local $TREQUIRED = DllStructCreate("int Data")
	DllStructSetData($TCURRSTATE, "Count", 1)
	DllStructSetData($TCURRSTATE, "LUID", $ILUID)
	If Not _SECURITY__ADJUSTTOKENPRIVILEGES($HTOKEN, False, $TCURRSTATE, $ICURRSTATE, $TPREVSTATE, $TREQUIRED) Then Return SetError(2, @error, False)
	DllStructSetData($TPREVSTATE, "Count", 1)
	DllStructSetData($TPREVSTATE, "LUID", $ILUID)
	Local $IATTRIBUTES = DllStructGetData($TPREVSTATE, "Attributes")
	If $FENABLE Then
		$IATTRIBUTES = BitOR($IATTRIBUTES, $SE_PRIVILEGE_ENABLED)
	Else
		$IATTRIBUTES = BitAND($IATTRIBUTES, BitNOT($SE_PRIVILEGE_ENABLED))
	EndIf
	DllStructSetData($TPREVSTATE, "Attributes", $IATTRIBUTES)
	If Not _SECURITY__ADJUSTTOKENPRIVILEGES($HTOKEN, False, $TPREVSTATE, $IPREVSTATE, $TCURRSTATE, $TREQUIRED) Then Return SetError(3, @error, False)
	Return True
EndFunc
Func _SECURITY__SETTOKENINFORMATION($HTOKEN, $ITOKENINFORMATION, $VTOKENINFORMATION, $ITOKENINFORMATIONLENGTH)
	Local $ACALL = DllCall("advapi32.dll", "bool", "SetTokenInformation", "handle", $HTOKEN, "int", $ITOKENINFORMATION, "struct*", $VTOKENINFORMATION, "dword", $ITOKENINFORMATIONLENGTH)
	If @error Or Not $ACALL[0] Then Return SetError(1, @extended, False)
	Return True
EndFunc
Func _SECURITY__SIDTOSTRINGSID($PSID)
	If Not _SECURITY__ISVALIDSID($PSID) Then Return SetError(1, 0, "")
	Local $ACALL = DllCall("advapi32.dll", "bool", "ConvertSidToStringSidW", "struct*", $PSID, "ptr*", 0)
	If @error Or Not $ACALL[0] Then Return SetError(2, @extended, "")
	Local $PSTRINGSID = $ACALL[2]
	Local $SSID = DllStructGetData(DllStructCreate("wchar Text[" & _WINAPI_STRINGLENW($PSTRINGSID) + 1 & "]", $PSTRINGSID), "Text")
	_WINAPI_LOCALFREE($PSTRINGSID)
	Return $SSID
EndFunc
Func _SECURITY__SIDTYPESTR($ITYPE)
	Switch $ITYPE
		Case $SIDTYPEUSER
			Return "User"
		Case $SIDTYPEGROUP
			Return "Group"
		Case $SIDTYPEDOMAIN
			Return "Domain"
		Case $SIDTYPEALIAS
			Return "Alias"
		Case $SIDTYPEWELLKNOWNGROUP
			Return "Well Known Group"
		Case $SIDTYPEDELETEDACCOUNT
			Return "Deleted Account"
		Case $SIDTYPEINVALID
			Return "Invalid"
		Case $SIDTYPEUNKNOWN
			Return "Unknown Type"
		Case $SIDTYPECOMPUTER
			Return "Computer"
		Case $SIDTYPELABEL
			Return "A mandatory integrity label SID"
		Case Else
			Return "Unknown SID Type"
	EndSwitch
EndFunc
Func _SECURITY__STRINGSIDTOSID($SSID)
	Local $ACALL = DllCall("advapi32.dll", "bool", "ConvertStringSidToSidW", "wstr", $SSID, "ptr*", 0)
	If @error Or Not $ACALL[0] Then Return SetError(1, @extended, 0)
	Local $PSID = $ACALL[2]
	Local $TBUFFER = DllStructCreate("byte Data[" & _SECURITY__GETLENGTHSID($PSID) & "]", $PSID)
	Local $TSID = DllStructCreate("byte Data[" & DllStructGetSize($TBUFFER) & "]")
	DllStructSetData($TSID, "Data", DllStructGetData($TBUFFER, "Data"))
	_WINAPI_LOCALFREE($PSID)
	Return $TSID
EndFunc
Global Const $TAGMEMMAP = "handle hProc;ulong_ptr Size;ptr Mem"
Func _MEMFREE(ByRef $TMEMMAP)
	Local $PMEMORY = DllStructGetData($TMEMMAP, "Mem")
	Local $HPROCESS = DllStructGetData($TMEMMAP, "hProc")
	Local $BRESULT = _MEMVIRTUALFREEEX($HPROCESS, $PMEMORY, 0, $MEM_RELEASE)
	DllCall("kernel32.dll", "bool", "CloseHandle", "handle", $HPROCESS)
	If @error Then Return SetError(@error, @extended, False)
	Return $BRESULT
EndFunc
Func _MEMGLOBALALLOC($IBYTES, $IFLAGS = 0)
	Local $ARESULT = DllCall("kernel32.dll", "handle", "GlobalAlloc", "uint", $IFLAGS, "ulong_ptr", $IBYTES)
	If @error Then Return SetError(@error, @extended, 0)
	Return $ARESULT[0]
EndFunc
Func _MEMGLOBALFREE($HMEM)
	Local $ARESULT = DllCall("kernel32.dll", "ptr", "GlobalFree", "handle", $HMEM)
	If @error Then Return SetError(@error, @extended, False)
	Return $ARESULT[0]
EndFunc
Func _MEMGLOBALLOCK($HMEM)
	Local $ARESULT = DllCall("kernel32.dll", "ptr", "GlobalLock", "handle", $HMEM)
	If @error Then Return SetError(@error, @extended, 0)
	Return $ARESULT[0]
EndFunc
Func _MEMGLOBALSIZE($HMEM)
	Local $ARESULT = DllCall("kernel32.dll", "ulong_ptr", "GlobalSize", "handle", $HMEM)
	If @error Then Return SetError(@error, @extended, 0)
	Return $ARESULT[0]
EndFunc
Func _MEMGLOBALUNLOCK($HMEM)
	Local $ARESULT = DllCall("kernel32.dll", "bool", "GlobalUnlock", "handle", $HMEM)
	If @error Then Return SetError(@error, @extended, 0)
	Return $ARESULT[0]
EndFunc
Func _MEMINIT($HWND, $ISIZE, ByRef $TMEMMAP)
	Local $ARESULT = DllCall("User32.dll", "dword", "GetWindowThreadProcessId", "hwnd", $HWND, "dword*", 0)
	If @error Then Return SetError(@error, @extended, 0)
	Local $IPROCESSID = $ARESULT[2]
	If $IPROCESSID = 0 Then Return SetError(1, 0, 0)
	Local $IACCESS = BitOR($PROCESS_VM_OPERATION, $PROCESS_VM_READ, $PROCESS_VM_WRITE)
	Local $HPROCESS = __MEM_OPENPROCESS($IACCESS, False, $IPROCESSID, True)
	Local $IALLOC = BitOR($MEM_RESERVE, $MEM_COMMIT)
	Local $PMEMORY = _MEMVIRTUALALLOCEX($HPROCESS, 0, $ISIZE, $IALLOC, $PAGE_READWRITE)
	If $PMEMORY = 0 Then Return SetError(2, 0, 0)
	$TMEMMAP = DllStructCreate($TAGMEMMAP)
	DllStructSetData($TMEMMAP, "hProc", $HPROCESS)
	DllStructSetData($TMEMMAP, "Size", $ISIZE)
	DllStructSetData($TMEMMAP, "Mem", $PMEMORY)
	Return $PMEMORY
EndFunc
Func _MEMMOVEMEMORY($PSOURCE, $PDEST, $ILENGTH)
	DllCall("kernel32.dll", "none", "RtlMoveMemory", "struct*", $PDEST, "struct*", $PSOURCE, "ulong_ptr", $ILENGTH)
	If @error Then Return SetError(@error, @extended)
EndFunc
Func _MEMREAD(ByRef $TMEMMAP, $PSRCE, $PDEST, $ISIZE)
	Local $ARESULT = DllCall("kernel32.dll", "bool", "ReadProcessMemory", "handle", DllStructGetData($TMEMMAP, "hProc"), "ptr", $PSRCE, "struct*", $PDEST, "ulong_ptr", $ISIZE, "ulong_ptr*", 0)
	If @error Then Return SetError(@error, @extended, False)
	Return $ARESULT[0]
EndFunc
Func _MEMWRITE(ByRef $TMEMMAP, $PSRCE, $PDEST = 0, $ISIZE = 0, $SSRCE = "struct*")
	If $PDEST = 0 Then $PDEST = DllStructGetData($TMEMMAP, "Mem")
	If $ISIZE = 0 Then $ISIZE = DllStructGetData($TMEMMAP, "Size")
	Local $ARESULT = DllCall("kernel32.dll", "bool", "WriteProcessMemory", "handle", DllStructGetData($TMEMMAP, "hProc"), "ptr", $PDEST, $SSRCE, $PSRCE, "ulong_ptr", $ISIZE, "ulong_ptr*", 0)
	If @error Then Return SetError(@error, @extended, False)
	Return $ARESULT[0]
EndFunc
Func _MEMVIRTUALALLOC($PADDRESS, $ISIZE, $IALLOCATION, $IPROTECT)
	Local $ARESULT = DllCall("kernel32.dll", "ptr", "VirtualAlloc", "ptr", $PADDRESS, "ulong_ptr", $ISIZE, "dword", $IALLOCATION, "dword", $IPROTECT)
	If @error Then Return SetError(@error, @extended, 0)
	Return $ARESULT[0]
EndFunc
Func _MEMVIRTUALALLOCEX($HPROCESS, $PADDRESS, $ISIZE, $IALLOCATION, $IPROTECT)
	Local $ARESULT = DllCall("kernel32.dll", "ptr", "VirtualAllocEx", "handle", $HPROCESS, "ptr", $PADDRESS, "ulong_ptr", $ISIZE, "dword", $IALLOCATION, "dword", $IPROTECT)
	If @error Then Return SetError(@error, @extended, 0)
	Return $ARESULT[0]
EndFunc
Func _MEMVIRTUALFREE($PADDRESS, $ISIZE, $IFREETYPE)
	Local $ARESULT = DllCall("kernel32.dll", "bool", "VirtualFree", "ptr", $PADDRESS, "ulong_ptr", $ISIZE, "dword", $IFREETYPE)
	If @error Then Return SetError(@error, @extended, False)
	Return $ARESULT[0]
EndFunc
Func _MEMVIRTUALFREEEX($HPROCESS, $PADDRESS, $ISIZE, $IFREETYPE)
	Local $ARESULT = DllCall("kernel32.dll", "bool", "VirtualFreeEx", "handle", $HPROCESS, "ptr", $PADDRESS, "ulong_ptr", $ISIZE, "dword", $IFREETYPE)
	If @error Then Return SetError(@error, @extended, False)
	Return $ARESULT[0]
EndFunc
Func __MEM_OPENPROCESS($IACCESS, $FINHERIT, $IPROCESSID, $FDEBUGPRIV = False)
	Local $ARESULT = DllCall("kernel32.dll", "handle", "OpenProcess", "dword", $IACCESS, "bool", $FINHERIT, "dword", $IPROCESSID)
	If @error Then Return SetError(@error, @extended, 0)
	If $ARESULT[0] Then Return $ARESULT[0]
	If Not $FDEBUGPRIV Then Return 0
	Local $HTOKEN = _SECURITY__OPENTHREADTOKENEX(BitOR($TOKEN_ADJUST_PRIVILEGES, $TOKEN_QUERY))
	If @error Then Return SetError(@error, @extended, 0)
	_SECURITY__SETPRIVILEGE($HTOKEN, "SeDebugPrivilege", True)
	Local $IERROR = @error
	Local $ILASTERROR = @extended
	Local $IRET = 0
	If Not @error Then
		$ARESULT = DllCall("kernel32.dll", "handle", "OpenProcess", "dword", $IACCESS, "bool", $FINHERIT, "dword", $IPROCESSID)
		$IERROR = @error
		$ILASTERROR = @extended
		If $ARESULT[0] Then $IRET = $ARESULT[0]
		_SECURITY__SETPRIVILEGE($HTOKEN, "SeDebugPrivilege", False)
		If @error Then
			$IERROR = @error
			$ILASTERROR = @extended
		EndIf
	EndIf
	DllCall("kernel32.dll", "bool", "CloseHandle", "handle", $HTOKEN)
	Return SetError($IERROR, $ILASTERROR, $IRET)
EndFunc
Func _DATEADD($STYPE, $IVALTOADD, $SDATE)
	Local $ASTIMEPART[4]
	Local $ASDATEPART[4]
	Local $IJULIANDATE
	$STYPE = StringLeft($STYPE, 1)
	If StringInStr("D,M,Y,w,h,n,s", $STYPE) = 0 Or $STYPE = "" Then
		Return SetError(1, 0, 0)
	EndIf
	If Not StringIsInt($IVALTOADD) Then
		Return SetError(2, 0, 0)
	EndIf
	If Not _DATEISVALID($SDATE) Then
		Return SetError(3, 0, 0)
	EndIf
	_DATETIMESPLIT($SDATE, $ASDATEPART, $ASTIMEPART)
	If $STYPE = "d" Or $STYPE = "w" Then
		If $STYPE = "w" Then $IVALTOADD = $IVALTOADD * 7
		$IJULIANDATE = _DATETODAYVALUE($ASDATEPART[1], $ASDATEPART[2], $ASDATEPART[3]) + $IVALTOADD
		_DAYVALUETODATE($IJULIANDATE, $ASDATEPART[1], $ASDATEPART[2], $ASDATEPART[3])
	EndIf
	If $STYPE = "m" Then
		$ASDATEPART[2] = $ASDATEPART[2] + $IVALTOADD
		While $ASDATEPART[2] > 12
			$ASDATEPART[2] = $ASDATEPART[2] - 12
			$ASDATEPART[1] = $ASDATEPART[1] + 1
		WEnd
		While $ASDATEPART[2] < 1
			$ASDATEPART[2] = $ASDATEPART[2] + 12
			$ASDATEPART[1] = $ASDATEPART[1] - 1
		WEnd
	EndIf
	If $STYPE = "y" Then
		$ASDATEPART[1] = $ASDATEPART[1] + $IVALTOADD
	EndIf
	If $STYPE = "h" Or $STYPE = "n" Or $STYPE = "s" Then
		Local $ITIMEVAL = _TIMETOTICKS($ASTIMEPART[1], $ASTIMEPART[2], $ASTIMEPART[3]) / 1000
		If $STYPE = "h" Then $ITIMEVAL = $ITIMEVAL + $IVALTOADD * 3600
		If $STYPE = "n" Then $ITIMEVAL = $ITIMEVAL + $IVALTOADD * 60
		If $STYPE = "s" Then $ITIMEVAL = $ITIMEVAL + $IVALTOADD
		Local $DAY2ADD = Int($ITIMEVAL / (24 * 60 * 60))
		$ITIMEVAL = $ITIMEVAL - $DAY2ADD * 24 * 60 * 60
		If $ITIMEVAL < 0 Then
			$DAY2ADD = $DAY2ADD - 1
			$ITIMEVAL = $ITIMEVAL + 24 * 60 * 60
		EndIf
		$IJULIANDATE = _DATETODAYVALUE($ASDATEPART[1], $ASDATEPART[2], $ASDATEPART[3]) + $DAY2ADD
		_DAYVALUETODATE($IJULIANDATE, $ASDATEPART[1], $ASDATEPART[2], $ASDATEPART[3])
		_TICKSTOTIME($ITIMEVAL * 1000, $ASTIMEPART[1], $ASTIMEPART[2], $ASTIMEPART[3])
	EndIf
	Local $INUMDAYS = _DAYSINMONTH($ASDATEPART[1])
	If $INUMDAYS[$ASDATEPART[2]] < $ASDATEPART[3] Then $ASDATEPART[3] = $INUMDAYS[$ASDATEPART[2]]
	$SDATE = $ASDATEPART[1] & "/" & StringRight("0" & $ASDATEPART[2], 2) & "/" & StringRight("0" & $ASDATEPART[3], 2)
	If $ASTIMEPART[0] > 0 Then
		If $ASTIMEPART[0] > 2 Then
			$SDATE = $SDATE & " " & StringRight("0" & $ASTIMEPART[1], 2) & ":" & StringRight("0" & $ASTIMEPART[2], 2) & ":" & StringRight("0" & $ASTIMEPART[3], 2)
		Else
			$SDATE = $SDATE & " " & StringRight("0" & $ASTIMEPART[1], 2) & ":" & StringRight("0" & $ASTIMEPART[2], 2)
		EndIf
	EndIf
	RETURN ($SDATE)
EndFunc
Func _DATEDAYOFWEEK($IDAYNUM, $ISHORT = 0)
	Local Const $ADAYOFWEEK[8] = ["", "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
	Select
		Case Not StringIsInt($IDAYNUM) Or Not StringIsInt($ISHORT)
			Return SetError(1, 0, "")
		Case $IDAYNUM < 1 Or $IDAYNUM > 7
			Return SetError(1, 0, "")
		Case Else
			Select
				Case $ISHORT = 0
					Return $ADAYOFWEEK[$IDAYNUM]
				Case $ISHORT = 1
					Return StringLeft($ADAYOFWEEK[$IDAYNUM], 3)
				Case Else
					Return SetError(1, 0, "")
			EndSelect
	EndSelect
EndFunc
Func _DATEDAYSINMONTH($IYEAR, $IMONTHNUM)
	If __DATEISMONTH($IMONTHNUM) And __DATEISYEAR($IYEAR) Then
		Local $AINUMDAYS = _DAYSINMONTH($IYEAR)
		Return $AINUMDAYS[$IMONTHNUM]
	EndIf
	Return SetError(1, 0, 0)
EndFunc
Func _DATEDIFF($STYPE, $SSTARTDATE, $SENDDATE)
	$STYPE = StringLeft($STYPE, 1)
	If StringInStr("d,m,y,w,h,n,s", $STYPE) = 0 Or $STYPE = "" Then
		Return SetError(1, 0, 0)
	EndIf
	If Not _DATEISVALID($SSTARTDATE) Then
		Return SetError(2, 0, 0)
	EndIf
	If Not _DATEISVALID($SENDDATE) Then
		Return SetError(3, 0, 0)
	EndIf
	Local $ASSTARTDATEPART[4], $ASSTARTTIMEPART[4], $ASENDDATEPART[4], $ASENDTIMEPART[4]
	_DATETIMESPLIT($SSTARTDATE, $ASSTARTDATEPART, $ASSTARTTIMEPART)
	_DATETIMESPLIT($SENDDATE, $ASENDDATEPART, $ASENDTIMEPART)
	Local $ADAYSDIFF = _DATETODAYVALUE($ASENDDATEPART[1], $ASENDDATEPART[2], $ASENDDATEPART[3]) - _DATETODAYVALUE($ASSTARTDATEPART[1], $ASSTARTDATEPART[2], $ASSTARTDATEPART[3])
	Local $ITIMEDIFF, $IYEARDIFF, $ISTARTTIMEINSECS, $IENDTIMEINSECS
	If $ASSTARTTIMEPART[0] > 1 And $ASENDTIMEPART[0] > 1 Then
		$ISTARTTIMEINSECS = $ASSTARTTIMEPART[1] * 3600 + $ASSTARTTIMEPART[2] * 60 + $ASSTARTTIMEPART[3]
		$IENDTIMEINSECS = $ASENDTIMEPART[1] * 3600 + $ASENDTIMEPART[2] * 60 + $ASENDTIMEPART[3]
		$ITIMEDIFF = $IENDTIMEINSECS - $ISTARTTIMEINSECS
		If $ITIMEDIFF < 0 Then
			$ADAYSDIFF = $ADAYSDIFF - 1
			$ITIMEDIFF = $ITIMEDIFF + 24 * 60 * 60
		EndIf
	Else
		$ITIMEDIFF = 0
	EndIf
	Select
		Case $STYPE = "d"
			RETURN ($ADAYSDIFF)
		Case $STYPE = "m"
			$IYEARDIFF = $ASENDDATEPART[1] - $ASSTARTDATEPART[1]
			Local $IMONTHDIFF = $ASENDDATEPART[2] - $ASSTARTDATEPART[2] + $IYEARDIFF * 12
			If $ASENDDATEPART[3] < $ASSTARTDATEPART[3] Then $IMONTHDIFF = $IMONTHDIFF - 1
			$ISTARTTIMEINSECS = $ASSTARTTIMEPART[1] * 3600 + $ASSTARTTIMEPART[2] * 60 + $ASSTARTTIMEPART[3]
			$IENDTIMEINSECS = $ASENDTIMEPART[1] * 3600 + $ASENDTIMEPART[2] * 60 + $ASENDTIMEPART[3]
			$ITIMEDIFF = $IENDTIMEINSECS - $ISTARTTIMEINSECS
			If $ASENDDATEPART[3] = $ASSTARTDATEPART[3] And $ITIMEDIFF < 0 Then $IMONTHDIFF = $IMONTHDIFF - 1
			RETURN ($IMONTHDIFF)
		Case $STYPE = "y"
			$IYEARDIFF = $ASENDDATEPART[1] - $ASSTARTDATEPART[1]
			If $ASENDDATEPART[2] < $ASSTARTDATEPART[2] Then $IYEARDIFF = $IYEARDIFF - 1
			If $ASENDDATEPART[2] = $ASSTARTDATEPART[2] And $ASENDDATEPART[3] < $ASSTARTDATEPART[3] Then $IYEARDIFF = $IYEARDIFF - 1
			$ISTARTTIMEINSECS = $ASSTARTTIMEPART[1] * 3600 + $ASSTARTTIMEPART[2] * 60 + $ASSTARTTIMEPART[3]
			$IENDTIMEINSECS = $ASENDTIMEPART[1] * 3600 + $ASENDTIMEPART[2] * 60 + $ASENDTIMEPART[3]
			$ITIMEDIFF = $IENDTIMEINSECS - $ISTARTTIMEINSECS
			If $ASENDDATEPART[2] = $ASSTARTDATEPART[2] And $ASENDDATEPART[3] = $ASSTARTDATEPART[3] And $ITIMEDIFF < 0 Then $IYEARDIFF = $IYEARDIFF - 1
			RETURN ($IYEARDIFF)
		Case $STYPE = "w"
			RETURN (Int($ADAYSDIFF / 7))
		Case $STYPE = "h"
			RETURN ($ADAYSDIFF * 24 + Int($ITIMEDIFF / 3600))
		Case $STYPE = "n"
			RETURN ($ADAYSDIFF * 24 * 60 + Int($ITIMEDIFF / 60))
		Case $STYPE = "s"
			RETURN ($ADAYSDIFF * 24 * 60 * 60 + $ITIMEDIFF)
	EndSelect
EndFunc
Func _DATEISLEAPYEAR($IYEAR)
	If StringIsInt($IYEAR) Then
		Select
			Case Mod($IYEAR, 4) = 0 And Mod($IYEAR, 100) <> 0
				Return 1
			Case Mod($IYEAR, 400) = 0
				Return 1
			Case Else
				Return 0
		EndSelect
	EndIf
	Return SetError(1, 0, 0)
EndFunc
Func __DATEISMONTH($INUMBER)
	If StringIsInt($INUMBER) Then
		If $INUMBER >= 1 And $INUMBER <= 12 Then
			Return 1
		Else
			Return 0
		EndIf
	EndIf
	Return 0
EndFunc
Func _DATEISVALID($SDATE)
	Local $ASDATEPART[4], $ASTIMEPART[4]
	Local $SDATETIME = StringSplit($SDATE, " T")
	If $SDATETIME[0] > 0 Then $ASDATEPART = StringSplit($SDATETIME[1], "/-.")
	If UBound($ASDATEPART) <> 4 Then RETURN (0)
	If $ASDATEPART[0] <> 3 Then RETURN (0)
	If Not StringIsInt($ASDATEPART[1]) Then RETURN (0)
	If Not StringIsInt($ASDATEPART[2]) Then RETURN (0)
	If Not StringIsInt($ASDATEPART[3]) Then RETURN (0)
	$ASDATEPART[1] = Number($ASDATEPART[1])
	$ASDATEPART[2] = Number($ASDATEPART[2])
	$ASDATEPART[3] = Number($ASDATEPART[3])
	Local $INUMDAYS = _DAYSINMONTH($ASDATEPART[1])
	If $ASDATEPART[1] < 1000 Or $ASDATEPART[1] > 2999 Then RETURN (0)
	If $ASDATEPART[2] < 1 Or $ASDATEPART[2] > 12 Then RETURN (0)
	If $ASDATEPART[3] < 1 Or $ASDATEPART[3] > $INUMDAYS[$ASDATEPART[2]] Then RETURN (0)
	If $SDATETIME[0] > 1 Then
		$ASTIMEPART = StringSplit($SDATETIME[2], ":")
		If UBound($ASTIMEPART) < 4 Then ReDim $ASTIMEPART[4]
	Else
		Dim $ASTIMEPART[4]
	EndIf
	If $ASTIMEPART[0] < 1 Then RETURN (1)
	If $ASTIMEPART[0] < 2 Then RETURN (0)
	If $ASTIMEPART[0] = 2 Then $ASTIMEPART[3] = "00"
	If Not StringIsInt($ASTIMEPART[1]) Then RETURN (0)
	If Not StringIsInt($ASTIMEPART[2]) Then RETURN (0)
	If Not StringIsInt($ASTIMEPART[3]) Then RETURN (0)
	$ASTIMEPART[1] = Number($ASTIMEPART[1])
	$ASTIMEPART[2] = Number($ASTIMEPART[2])
	$ASTIMEPART[3] = Number($ASTIMEPART[3])
	If $ASTIMEPART[1] < 0 Or $ASTIMEPART[1] > 23 Then RETURN (0)
	If $ASTIMEPART[2] < 0 Or $ASTIMEPART[2] > 59 Then RETURN (0)
	If $ASTIMEPART[3] < 0 Or $ASTIMEPART[3] > 59 Then RETURN (0)
	Return 1
EndFunc
Func __DATEISYEAR($INUMBER)
	If StringIsInt($INUMBER) Then
		If StringLen($INUMBER) = 4 Then
			Return 1
		Else
			Return 0
		EndIf
	EndIf
	Return 0
EndFunc
Func _DATELASTWEEKDAYNUM($IWEEKDAYNUM)
	Select
		Case Not StringIsInt($IWEEKDAYNUM)
			Return SetError(1, 0, 0)
		Case $IWEEKDAYNUM < 1 Or $IWEEKDAYNUM > 7
			Return SetError(1, 0, 0)
		Case Else
			Local $ILASTWEEKDAYNUM
			If $IWEEKDAYNUM = 1 Then
				$ILASTWEEKDAYNUM = 7
			Else
				$ILASTWEEKDAYNUM = $IWEEKDAYNUM - 1
			EndIf
			Return $ILASTWEEKDAYNUM
	EndSelect
EndFunc
Func _DATELASTMONTHNUM($IMONTHNUM)
	Select
		Case Not StringIsInt($IMONTHNUM)
			Return SetError(1, 0, 0)
		Case $IMONTHNUM < 1 Or $IMONTHNUM > 12
			Return SetError(1, 0, 0)
		Case Else
			Local $ILASTMONTHNUM
			If $IMONTHNUM = 1 Then
				$ILASTMONTHNUM = 12
			Else
				$ILASTMONTHNUM = $IMONTHNUM - 1
			EndIf
			$ILASTMONTHNUM = StringFormat("%02d", $ILASTMONTHNUM)
			Return $ILASTMONTHNUM
	EndSelect
EndFunc
Func _DATELASTMONTHYEAR($IMONTHNUM, $IYEAR)
	Select
		Case Not StringIsInt($IMONTHNUM) Or Not StringIsInt($IYEAR)
			Return SetError(1, 0, 0)
		Case $IMONTHNUM < 1 Or $IMONTHNUM > 12
			Return SetError(1, 0, 0)
		Case Else
			Local $ILASTYEAR
			If $IMONTHNUM = 1 Then
				$ILASTYEAR = $IYEAR - 1
			Else
				$ILASTYEAR = $IYEAR
			EndIf
			$ILASTYEAR = StringFormat("%04d", $ILASTYEAR)
			Return $ILASTYEAR
	EndSelect
EndFunc
Func _DATENEXTWEEKDAYNUM($IWEEKDAYNUM)
	Select
		Case Not StringIsInt($IWEEKDAYNUM)
			Return SetError(1, 0, 0)
		Case $IWEEKDAYNUM < 1 Or $IWEEKDAYNUM > 7
			Return SetError(1, 0, 0)
		Case Else
			Local $INEXTWEEKDAYNUM
			If $IWEEKDAYNUM = 7 Then
				$INEXTWEEKDAYNUM = 1
			Else
				$INEXTWEEKDAYNUM = $IWEEKDAYNUM + 1
			EndIf
			Return $INEXTWEEKDAYNUM
	EndSelect
EndFunc
Func _DATENEXTMONTHNUM($IMONTHNUM)
	Select
		Case Not StringIsInt($IMONTHNUM)
			Return SetError(1, 0, 0)
		Case $IMONTHNUM < 1 Or $IMONTHNUM > 12
			Return SetError(1, 0, 0)
		Case Else
			Local $INEXTMONTHNUM
			If $IMONTHNUM = 12 Then
				$INEXTMONTHNUM = 1
			Else
				$INEXTMONTHNUM = $IMONTHNUM + 1
			EndIf
			$INEXTMONTHNUM = StringFormat("%02d", $INEXTMONTHNUM)
			Return $INEXTMONTHNUM
	EndSelect
EndFunc
Func _DATENEXTMONTHYEAR($IMONTHNUM, $IYEAR)
	Select
		Case Not StringIsInt($IMONTHNUM) Or Not StringIsInt($IYEAR)
			Return SetError(1, 0, 0)
		Case $IMONTHNUM < 1 Or $IMONTHNUM > 12
			Return SetError(1, 0, 0)
		Case Else
			Local $INEXTYEAR
			If $IMONTHNUM = 12 Then
				$INEXTYEAR = $IYEAR + 1
			Else
				$INEXTYEAR = $IYEAR
			EndIf
			$INEXTYEAR = StringFormat("%04d", $INEXTYEAR)
			Return $INEXTYEAR
	EndSelect
EndFunc
Func _DATETIMEFORMAT($SDATE, $STYPE)
	Local $ASDATEPART[4], $ASTIMEPART[4]
	Local $STEMPDATE = "", $STEMPTIME = ""
	Local $SAM, $SPM, $LNGX
	If Not _DATEISVALID($SDATE) Then
		Return SetError(1, 0, "")
	EndIf
	If $STYPE < 0 Or $STYPE > 5 Or Not IsInt($STYPE) Then
		Return SetError(2, 0, "")
	EndIf
	_DATETIMESPLIT($SDATE, $ASDATEPART, $ASTIMEPART)
	Switch $STYPE
		Case 0
			$LNGX = DllCall("kernel32.dll", "int", "GetLocaleInfoW", "dword", 1024, "dword", 31, "wstr", "", "int", 255)
			If Not @error And $LNGX[0] <> 0 Then
				$STEMPDATE = $LNGX[3]
			Else
				$STEMPDATE = "M/d/yyyy"
			EndIf
			If $ASTIMEPART[0] > 1 Then
				$LNGX = DllCall("kernel32.dll", "int", "GetLocaleInfoW", "dword", 1024, "dword", 4099, "wstr", "", "int", 255)
				If Not @error And $LNGX[0] <> 0 Then
					$STEMPTIME = $LNGX[3]
				Else
					$STEMPTIME = "h:mm:ss tt"
				EndIf
			EndIf
		Case 1
			$LNGX = DllCall("kernel32.dll", "int", "GetLocaleInfoW", "dword", 1024, "dword", 32, "wstr", "", "int", 255)
			If Not @error And $LNGX[0] <> 0 Then
				$STEMPDATE = $LNGX[3]
			Else
				$STEMPDATE = "dddd, MMMM dd, yyyy"
			EndIf
		Case 2
			$LNGX = DllCall("kernel32.dll", "int", "GetLocaleInfoW", "dword", 1024, "dword", 31, "wstr", "", "int", 255)
			If Not @error And $LNGX[0] <> 0 Then
				$STEMPDATE = $LNGX[3]
			Else
				$STEMPDATE = "M/d/yyyy"
			EndIf
		Case 3
			If $ASTIMEPART[0] > 1 Then
				$LNGX = DllCall("kernel32.dll", "int", "GetLocaleInfoW", "dword", 1024, "dword", 4099, "wstr", "", "int", 255)
				If Not @error And $LNGX[0] <> 0 Then
					$STEMPTIME = $LNGX[3]
				Else
					$STEMPTIME = "h:mm:ss tt"
				EndIf
			EndIf
		Case 4
			If $ASTIMEPART[0] > 1 Then
				$STEMPTIME = "hh:mm"
			EndIf
		Case 5
			If $ASTIMEPART[0] > 1 Then
				$STEMPTIME = "hh:mm:ss"
			EndIf
	EndSwitch
	If $STEMPDATE <> "" Then
		$LNGX = DllCall("kernel32.dll", "int", "GetLocaleInfoW", "dword", 1024, "dword", 29, "wstr", "", "int", 255)
		If Not @error And $LNGX[0] <> 0 Then
			$STEMPDATE = StringReplace($STEMPDATE, "/", $LNGX[3])
		EndIf
		Local $IWDAY = _DATETODAYOFWEEK($ASDATEPART[1], $ASDATEPART[2], $ASDATEPART[3])
		$ASDATEPART[3] = StringRight("0" & $ASDATEPART[3], 2)
		$ASDATEPART[2] = StringRight("0" & $ASDATEPART[2], 2)
		$STEMPDATE = StringReplace($STEMPDATE, "d", "@")
		$STEMPDATE = StringReplace($STEMPDATE, "m", "#")
		$STEMPDATE = StringReplace($STEMPDATE, "y", "&")
		$STEMPDATE = StringReplace($STEMPDATE, "@@@@", _DATEDAYOFWEEK($IWDAY, 0))
		$STEMPDATE = StringReplace($STEMPDATE, "@@@", _DATEDAYOFWEEK($IWDAY, 1))
		$STEMPDATE = StringReplace($STEMPDATE, "@@", $ASDATEPART[3])
		$STEMPDATE = StringReplace($STEMPDATE, "@", StringReplace(StringLeft($ASDATEPART[3], 1), "0", "") & StringRight($ASDATEPART[3], 1))
		$STEMPDATE = StringReplace($STEMPDATE, "####", _DATETOMONTH($ASDATEPART[2], 0))
		$STEMPDATE = StringReplace($STEMPDATE, "###", _DATETOMONTH($ASDATEPART[2], 1))
		$STEMPDATE = StringReplace($STEMPDATE, "##", $ASDATEPART[2])
		$STEMPDATE = StringReplace($STEMPDATE, "#", StringReplace(StringLeft($ASDATEPART[2], 1), "0", "") & StringRight($ASDATEPART[2], 1))
		$STEMPDATE = StringReplace($STEMPDATE, "&&&&", $ASDATEPART[1])
		$STEMPDATE = StringReplace($STEMPDATE, "&&", StringRight($ASDATEPART[1], 2))
	EndIf
	If $STEMPTIME <> "" Then
		$LNGX = DllCall("kernel32.dll", "int", "GetLocaleInfoW", "dword", 1024, "dword", 40, "wstr", "", "int", 255)
		If Not @error And $LNGX[0] <> 0 Then
			$SAM = $LNGX[3]
		Else
			$SAM = "AM"
		EndIf
		$LNGX = DllCall("kernel32.dll", "int", "GetLocaleInfoW", "dword", 1024, "dword", 41, "wstr", "", "int", 255)
		If Not @error And $LNGX[0] <> 0 Then
			$SPM = $LNGX[3]
		Else
			$SPM = "PM"
		EndIf
		$LNGX = DllCall("kernel32.dll", "int", "GetLocaleInfoW", "dword", 1024, "dword", 30, "wstr", "", "int", 255)
		If Not @error And $LNGX[0] <> 0 Then
			$STEMPTIME = StringReplace($STEMPTIME, ":", $LNGX[3])
		EndIf
		If StringInStr($STEMPTIME, "tt") Then
			If $ASTIMEPART[1] < 12 Then
				$STEMPTIME = StringReplace($STEMPTIME, "tt", $SAM)
				If $ASTIMEPART[1] = 0 Then $ASTIMEPART[1] = 12
			Else
				$STEMPTIME = StringReplace($STEMPTIME, "tt", $SPM)
				If $ASTIMEPART[1] > 12 Then $ASTIMEPART[1] = $ASTIMEPART[1] - 12
			EndIf
		EndIf
		$ASTIMEPART[1] = StringRight("0" & $ASTIMEPART[1], 2)
		$ASTIMEPART[2] = StringRight("0" & $ASTIMEPART[2], 2)
		$ASTIMEPART[3] = StringRight("0" & $ASTIMEPART[3], 2)
		$STEMPTIME = StringReplace($STEMPTIME, "hh", StringFormat("%02d", $ASTIMEPART[1]))
		$STEMPTIME = StringReplace($STEMPTIME, "h", StringReplace(StringLeft($ASTIMEPART[1], 1), "0", "") & StringRight($ASTIMEPART[1], 1))
		$STEMPTIME = StringReplace($STEMPTIME, "mm", StringFormat("%02d", $ASTIMEPART[2]))
		$STEMPTIME = StringReplace($STEMPTIME, "ss", StringFormat("%02d", $ASTIMEPART[3]))
		$STEMPDATE = StringStripWS($STEMPDATE & " " & $STEMPTIME, 3)
	EndIf
	Return $STEMPDATE
EndFunc
Func _DATETIMESPLIT($SDATE, ByRef $ASDATEPART, ByRef $ITIMEPART)
	Local $SDATETIME = StringSplit($SDATE, " T")
	If $SDATETIME[0] > 0 Then $ASDATEPART = StringSplit($SDATETIME[1], "/-.")
	If $SDATETIME[0] > 1 Then
		$ITIMEPART = StringSplit($SDATETIME[2], ":")
		If UBound($ITIMEPART) < 4 Then ReDim $ITIMEPART[4]
	Else
		Dim $ITIMEPART[4]
	EndIf
	If UBound($ASDATEPART) < 4 Then ReDim $ASDATEPART[4]
	For $X = 1 To 3
		If StringIsInt($ASDATEPART[$X]) Then
			$ASDATEPART[$X] = Number($ASDATEPART[$X])
		Else
			$ASDATEPART[$X] = -1
		EndIf
		If StringIsInt($ITIMEPART[$X]) Then
			$ITIMEPART[$X] = Number($ITIMEPART[$X])
		Else
			$ITIMEPART[$X] = 0
		EndIf
	Next
	Return 1
EndFunc
Func _DATETODAYOFWEEK($IYEAR, $IMONTH, $IDAY)
	If Not _DATEISVALID($IYEAR & "/" & $IMONTH & "/" & $IDAY) Then
		Return SetError(1, 0, "")
	EndIf
	Local $I_AFACTOR = Int((14 - $IMONTH) / 12)
	Local $I_YFACTOR = $IYEAR - $I_AFACTOR
	Local $I_MFACTOR = $IMONTH + (12 * $I_AFACTOR) - 2
	Local $I_DFACTOR = Mod($IDAY + $I_YFACTOR + Int($I_YFACTOR / 4) - Int($I_YFACTOR / 100) + Int($I_YFACTOR / 400) + Int((31 * $I_MFACTOR) / 12), 7)
	RETURN ($I_DFACTOR + 1)
EndFunc
Func _DATETODAYOFWEEKISO($IYEAR, $IMONTH, $IDAY)
	Local $IDOW = _DATETODAYOFWEEK($IYEAR, $IMONTH, $IDAY)
	If @error Then
		Return SetError(1, 0, "")
	EndIf
	If $IDOW >= 2 Then Return $IDOW - 1
	Return 7
EndFunc
Func _DATETODAYVALUE($IYEAR, $IMONTH, $IDAY)
	If Not _DATEISVALID(StringFormat("%04d/%02d/%02d", $IYEAR, $IMONTH, $IDAY)) Then
		Return SetError(1, 0, "")
	EndIf
	If $IMONTH < 3 Then
		$IMONTH = $IMONTH + 12
		$IYEAR = $IYEAR - 1
	EndIf
	Local $I_AFACTOR = Int($IYEAR / 100)
	Local $I_BFACTOR = Int($I_AFACTOR / 4)
	Local $I_CFACTOR = 2 - $I_AFACTOR + $I_BFACTOR
	Local $I_EFACTOR = Int(1461 * ($IYEAR + 4716) / 4)
	Local $I_FFACTOR = Int(153 * ($IMONTH + 1) / 5)
	Local $IJULIANDATE = $I_CFACTOR + $IDAY + $I_EFACTOR + $I_FFACTOR - 1524.5
	RETURN ($IJULIANDATE)
EndFunc
Func _DATETOMONTH($IMONTH, $ISHORT = 0)
	Local $AMONTHNUMBER[13] = ["", "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
	Local $AMONTHNUMBERABBREV[13] = ["", "Jan", "Feb", "Mar", "Apr", "May", "June", "July", "Aug", "Sept", "Oct", "Nov", "Dec"]
	Select
		Case Not StringIsInt($IMONTH)
			Return SetError(1, 0, "")
		Case $IMONTH < 1 Or $IMONTH > 12
			Return SetError(1, 0, "")
		Case Else
			Select
				Case $ISHORT = 0
					Return $AMONTHNUMBER[$IMONTH]
				Case $ISHORT = 1
					Return $AMONTHNUMBERABBREV[$IMONTH]
				Case Else
					Return SetError(1, 0, "")
			EndSelect
	EndSelect
EndFunc
Func _DAYVALUETODATE($IJULIANDATE, ByRef $IYEAR, ByRef $IMONTH, ByRef $IDAY)
	If $IJULIANDATE < 0 Or Not IsNumber($IJULIANDATE) Then
		Return SetError(1, 0, 0)
	EndIf
	Local $I_ZFACTOR = Int($IJULIANDATE + 0.5)
	Local $I_WFACTOR = Int(($I_ZFACTOR - 1867216.25) / 36524.25)
	Local $I_XFACTOR = Int($I_WFACTOR / 4)
	Local $I_AFACTOR = $I_ZFACTOR + 1 + $I_WFACTOR - $I_XFACTOR
	Local $I_BFACTOR = $I_AFACTOR + 1524
	Local $I_CFACTOR = Int(($I_BFACTOR - 122.1) / 365.25)
	Local $I_DFACTOR = Int(365.25 * $I_CFACTOR)
	Local $I_EFACTOR = Int(($I_BFACTOR - $I_DFACTOR) / 30.6001)
	Local $I_FFACTOR = Int(30.6001 * $I_EFACTOR)
	$IDAY = $I_BFACTOR - $I_DFACTOR - $I_FFACTOR
	If $I_EFACTOR - 1 < 13 Then
		$IMONTH = $I_EFACTOR - 1
	Else
		$IMONTH = $I_EFACTOR - 13
	EndIf
	If $IMONTH < 3 Then
		$IYEAR = $I_CFACTOR - 4715
	Else
		$IYEAR = $I_CFACTOR - 4716
	EndIf
	$IYEAR = StringFormat("%04d", $IYEAR)
	$IMONTH = StringFormat("%02d", $IMONTH)
	$IDAY = StringFormat("%02d", $IDAY)
	Return $IYEAR & "/" & $IMONTH & "/" & $IDAY
EndFunc
Func _DATE_JULIANDAYNO($IYEAR, $IMONTH, $IDAY)
	Local $SFULLDATE = StringFormat("%04d/%02d/%02d", $IYEAR, $IMONTH, $IDAY)
	If Not _DATEISVALID($SFULLDATE) Then
		Return SetError(1, 0, "")
	EndIf
	Local $IJDAY = 0
	Local $AIDAYSINMONTH = _DAYSINMONTH($IYEAR)
	For $ICNTR = 1 To $IMONTH - 1
		$IJDAY = $IJDAY + $AIDAYSINMONTH[$ICNTR]
	Next
	$IJDAY = ($IYEAR * 1000) + ($IJDAY + $IDAY)
	Return $IJDAY
EndFunc
Func _JULIANTODATE($IJDAY, $SSEP = "/")
	Local $IYEAR = Int($IJDAY / 1000)
	Local $IDAYS = Mod($IJDAY, 1000)
	Local $IMAXDAYS = 365
	If _DATEISLEAPYEAR($IYEAR) Then $IMAXDAYS = 366
	If $IDAYS > $IMAXDAYS Then
		Return SetError(1, 0, "")
	EndIf
	Local $AIDAYSINMONTH = _DAYSINMONTH($IYEAR)
	Local $IMONTH = 1
	While $IDAYS > $AIDAYSINMONTH[$IMONTH]
		$IDAYS = $IDAYS - $AIDAYSINMONTH[$IMONTH]
		$IMONTH = $IMONTH + 1
	WEnd
	Return StringFormat("%04d%s%02d%s%02d", $IYEAR, $SSEP, $IMONTH, $SSEP, $IDAYS)
EndFunc
Func _NOW()
	RETURN (_DATETIMEFORMAT(@YEAR & "/" & @MON & "/" & @MDAY & " " & @HOUR & ":" & @MIN & ":" & @SEC, 0))
EndFunc
Func _NOWCALC()
	RETURN (@YEAR & "/" & @MON & "/" & @MDAY & " " & @HOUR & ":" & @MIN & ":" & @SEC)
EndFunc
Func _NOWCALCDATE()
	RETURN (@YEAR & "/" & @MON & "/" & @MDAY)
EndFunc
Func _NOWDATE()
	RETURN (_DATETIMEFORMAT(@YEAR & "/" & @MON & "/" & @MDAY, 0))
EndFunc
Func _NOWTIME($STYPE = 3)
	If $STYPE < 3 Or $STYPE > 5 Then $STYPE = 3
	RETURN (_DATETIMEFORMAT(@YEAR & "/" & @MON & "/" & @MDAY & " " & @HOUR & ":" & @MIN & ":" & @SEC, $STYPE))
EndFunc
Func _SETDATE($IDAY, $IMONTH = 0, $IYEAR = 0)
	If $IYEAR = 0 Then $IYEAR = @YEAR
	If $IMONTH = 0 Then $IMONTH = @MON
	If Not _DATEISVALID($IYEAR & "/" & $IMONTH & "/" & $IDAY) Then Return 1
	Local $TSYSTEMTIME = DllStructCreate($TAGSYSTEMTIME)
	DllCall("kernel32.dll", "none", "GetLocalTime", "struct*", $TSYSTEMTIME)
	If @error Then Return SetError(@error, @extended, 0)
	DllStructSetData($TSYSTEMTIME, 4, $IDAY)
	If $IMONTH > 0 Then DllStructSetData($TSYSTEMTIME, 2, $IMONTH)
	If $IYEAR > 0 Then DllStructSetData($TSYSTEMTIME, 1, $IYEAR)
	Local $IRETVAL = _DATE_TIME_SETLOCALTIME($TSYSTEMTIME)
	If @error Then Return SetError(@error, @extended, 0)
	Return Int($IRETVAL)
EndFunc
Func _SETTIME($IHOUR, $IMINUTE, $ISECOND = 0)
	If $IHOUR < 0 Or $IHOUR > 23 Then Return 1
	If $IMINUTE < 0 Or $IMINUTE > 59 Then Return 1
	If $ISECOND < 0 Or $ISECOND > 59 Then Return 1
	Local $TSYSTEMTIME = DllStructCreate($TAGSYSTEMTIME)
	DllCall("kernel32.dll", "none", "GetLocalTime", "struct*", $TSYSTEMTIME)
	If @error Then Return SetError(@error, @extended, 0)
	DllStructSetData($TSYSTEMTIME, 5, $IHOUR)
	DllStructSetData($TSYSTEMTIME, 6, $IMINUTE)
	If $ISECOND > 0 Then DllStructSetData($TSYSTEMTIME, 7, $ISECOND)
	Local $IRETVAL = _DATE_TIME_SETLOCALTIME($TSYSTEMTIME)
	If @error Then Return SetError(@error, @extended, 0)
	Return Int($IRETVAL)
EndFunc
Func _TICKSTOTIME($ITICKS, ByRef $IHOURS, ByRef $IMINS, ByRef $ISECS)
	If Number($ITICKS) > 0 Then
		$ITICKS = Int($ITICKS / 1000)
		$IHOURS = Int($ITICKS / 3600)
		$ITICKS = Mod($ITICKS, 3600)
		$IMINS = Int($ITICKS / 60)
		$ISECS = Mod($ITICKS, 60)
		Return 1
	ElseIf Number($ITICKS) = 0 Then
		$IHOURS = 0
		$ITICKS = 0
		$IMINS = 0
		$ISECS = 0
		Return 1
	Else
		Return SetError(1, 0, 0)
	EndIf
EndFunc
Func _TIMETOTICKS($IHOURS = @HOUR, $IMINS = @MIN, $ISECS = @SEC)
	If StringIsInt($IHOURS) And StringIsInt($IMINS) And StringIsInt($ISECS) Then
		Local $ITICKS = 1000 * ((3600 * $IHOURS) + (60 * $IMINS) + $ISECS)
		Return $ITICKS
	Else
		Return SetError(1, 0, 0)
	EndIf
EndFunc
Func _WEEKNUMBERISO($IYEAR = @YEAR, $IMONTH = @MON, $IDAY = @MDAY)
	If $IDAY > 31 Or $IDAY < 1 Then
		Return SetError(1, 0, -1)
	ElseIf $IMONTH > 12 Or $IMONTH < 1 Then
		Return SetError(1, 0, -1)
	ElseIf $IYEAR < 1 Or $IYEAR > 2999 Then
		Return SetError(1, 0, -1)
	EndIf
	Local $IDOW = _DATETODAYOFWEEKISO($IYEAR, $IMONTH, $IDAY) - 1
	Local $IDOW0101 = _DATETODAYOFWEEKISO($IYEAR, 1, 1) - 1
	IF ($IMONTH = 1 And 3 < $IDOW0101 And $IDOW0101 < 7 - ($IDAY - 1)) Then
		$IDOW = $IDOW0101 - 1
		$IDOW0101 = _DATETODAYOFWEEKISO($IYEAR - 1, 1, 1) - 1
		$IMONTH = 12
		$IDAY = 31
		$IYEAR = $IYEAR - 1
	ELSEIF ($IMONTH = 12 And 30 - ($IDAY - 1) < _DATETODAYOFWEEKISO($IYEAR + 1, 1, 1) - 1 And _DATETODAYOFWEEKISO($IYEAR + 1, 1, 1) - 1 < 4) Then
		Return 1
	EndIf
	Return Int((_DATETODAYOFWEEKISO($IYEAR, 1, 1) - 1 < 4) + 4 * ($IMONTH - 1) + (2 * ($IMONTH - 1) + ($IDAY - 1) + $IDOW0101 - $IDOW + 6) * 36 / 256)
EndFunc
Func _WEEKNUMBER($IYEAR = @YEAR, $IMONTH = @MON, $IDAY = @MDAY, $IWEEKSTART = 1)
	If $IDAY > 31 Or $IDAY < 1 Then
		Return SetError(1, 0, -1)
	ElseIf $IMONTH > 12 Or $IMONTH < 1 Then
		Return SetError(1, 0, -1)
	ElseIf $IYEAR < 1 Or $IYEAR > 2999 Then
		Return SetError(1, 0, -1)
	ElseIf $IWEEKSTART < 1 Or $IWEEKSTART > 2 Then
		Return SetError(2, 0, -1)
	EndIf
	Local $ISTARTWEEK1, $IENDWEEK1
	Local $IDOW0101 = _DATETODAYOFWEEKISO($IYEAR, 1, 1)
	Local $IDATE = $IYEAR & "/" & $IMONTH & "/" & $IDAY
	If $IWEEKSTART = 1 Then
		If $IDOW0101 = 6 Then
			$ISTARTWEEK1 = 0
		Else
			$ISTARTWEEK1 = -1 * $IDOW0101 - 1
		EndIf
		$IENDWEEK1 = $ISTARTWEEK1 + 6
	Else
		$ISTARTWEEK1 = $IDOW0101 * - 1
		$IENDWEEK1 = $ISTARTWEEK1 + 6
	EndIf
	Local $ISTARTWEEK1NY
	Local $IENDWEEK1DATE = _DATEADD("d", $IENDWEEK1, $IYEAR & "/01/01")
	Local $IDOW0101NY = _DATETODAYOFWEEKISO($IYEAR + 1, 1, 1)
	If $IWEEKSTART = 1 Then
		If $IDOW0101NY = 6 Then
			$ISTARTWEEK1NY = 0
		Else
			$ISTARTWEEK1NY = -1 * $IDOW0101NY - 1
		EndIf
	Else
		$ISTARTWEEK1NY = $IDOW0101NY * - 1
	EndIf
	Local $ISTARTWEEK1DATENY = _DATEADD("d", $ISTARTWEEK1NY, $IYEAR + 1 & "/01/01")
	Local $ICURRDATEDIFF = _DATEDIFF("d", $IENDWEEK1DATE, $IDATE) - 1
	Local $ICURRDATEDIFFNY = _DATEDIFF("d", $ISTARTWEEK1DATENY, $IDATE)
	If $ICURRDATEDIFF >= 0 And $ICURRDATEDIFFNY < 0 Then Return 2 + Int($ICURRDATEDIFF / 7)
	If $ICURRDATEDIFF < 0 Or $ICURRDATEDIFFNY >= 0 Then Return 1
EndFunc
Func _DAYSINMONTH($IYEAR)
	Local $AIDAYS[13] = [0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
	If _DATEISLEAPYEAR($IYEAR) Then $AIDAYS[2] = 29
	Return $AIDAYS
EndFunc
Func __DATE_TIME_CLONESYSTEMTIME($PSYSTEMTIME)
	Local $TSYSTEMTIME1 = DllStructCreate($TAGSYSTEMTIME, $PSYSTEMTIME)
	Local $TSYSTEMTIME2 = DllStructCreate($TAGSYSTEMTIME)
	DllStructSetData($TSYSTEMTIME2, "Month", DllStructGetData($TSYSTEMTIME1, "Month"))
	DllStructSetData($TSYSTEMTIME2, "Day", DllStructGetData($TSYSTEMTIME1, "Day"))
	DllStructSetData($TSYSTEMTIME2, "Year", DllStructGetData($TSYSTEMTIME1, "Year"))
	DllStructSetData($TSYSTEMTIME2, "Hour", DllStructGetData($TSYSTEMTIME1, "Hour"))
	DllStructSetData($TSYSTEMTIME2, "Minute", DllStructGetData($TSYSTEMTIME1, "Minute"))
	DllStructSetData($TSYSTEMTIME2, "Second", DllStructGetData($TSYSTEMTIME1, "Second"))
	DllStructSetData($TSYSTEMTIME2, "MSeconds", DllStructGetData($TSYSTEMTIME1, "MSeconds"))
	DllStructSetData($TSYSTEMTIME2, "DOW", DllStructGetData($TSYSTEMTIME1, "DOW"))
	Return $TSYSTEMTIME2
EndFunc
Func _DATE_TIME_COMPAREFILETIME($PFILETIME1, $PFILETIME2)
	Local $ARESULT = DllCall("kernel32.dll", "long", "CompareFileTime", "ptr", $PFILETIME1, "ptr", $PFILETIME2)
	If @error Then Return SetError(@error, @extended, 0)
	Return $ARESULT[0]
EndFunc
Func _DATE_TIME_DOSDATETIMETOFILETIME($IFATDATE, $IFATTIME)
	Local $TTIME = DllStructCreate($TAGFILETIME)
	Local $ARESULT = DllCall("kernel32.dll", "bool", "DosDateTimeToFileTime", "word", $IFATDATE, "word", $IFATTIME, "struct*", $TTIME)
	If @error Then Return SetError(@error, @extended, 0)
	Return SetExtended($ARESULT[0], $TTIME)
EndFunc
Func _DATE_TIME_DOSDATETOARRAY($IDOSDATE)
	Local $ADATE[3]
	$ADATE[0] = BitAND($IDOSDATE, 31)
	$ADATE[1] = BitAND(BitShift($IDOSDATE, 5), 15)
	$ADATE[2] = BitAND(BitShift($IDOSDATE, 9), 63) + 1980
	Return $ADATE
EndFunc
Func _DATE_TIME_DOSDATETIMETOARRAY($IDOSDATE, $IDOSTIME)
	Local $ADATE[6]
	$ADATE[0] = BitAND($IDOSDATE, 31)
	$ADATE[1] = BitAND(BitShift($IDOSDATE, 5), 15)
	$ADATE[2] = BitAND(BitShift($IDOSDATE, 9), 63) + 1980
	$ADATE[5] = BitAND($IDOSTIME, 31) * 2
	$ADATE[4] = BitAND(BitShift($IDOSTIME, 5), 63)
	$ADATE[3] = BitAND(BitShift($IDOSTIME, 11), 31)
	Return $ADATE
EndFunc
Func _DATE_TIME_DOSDATETIMETOSTR($IDOSDATE, $IDOSTIME)
	Local $ADATE = _DATE_TIME_DOSDATETIMETOARRAY($IDOSDATE, $IDOSTIME)
	Return StringFormat("%02d/%02d/%04d %02d:%02d:%02d", $ADATE[0], $ADATE[1], $ADATE[2], $ADATE[3], $ADATE[4], $ADATE[5])
EndFunc
Func _DATE_TIME_DOSDATETOSTR($IDOSDATE)
	Local $ADATE = _DATE_TIME_DOSDATETOARRAY($IDOSDATE)
	Return StringFormat("%02d/%02d/%04d", $ADATE[0], $ADATE[1], $ADATE[2])
EndFunc
Func _DATE_TIME_DOSTIMETOARRAY($IDOSTIME)
	Local $ATIME[3]
	$ATIME[2] = BitAND($IDOSTIME, 31) * 2
	$ATIME[1] = BitAND(BitShift($IDOSTIME, 5), 63)
	$ATIME[0] = BitAND(BitShift($IDOSTIME, 11), 31)
	Return $ATIME
EndFunc
Func _DATE_TIME_DOSTIMETOSTR($IDOSTIME)
	Local $ATIME = _DATE_TIME_DOSTIMETOARRAY($IDOSTIME)
	Return StringFormat("%02d:%02d:%02d", $ATIME[0], $ATIME[1], $ATIME[2])
EndFunc
Func _DATE_TIME_ENCODEFILETIME($IMONTH, $IDAY, $IYEAR, $IHOUR = 0, $IMINUTE = 0, $ISECOND = 0, $IMSECONDS = 0)
	Local $TSYSTEMTIME = _DATE_TIME_ENCODESYSTEMTIME($IMONTH, $IDAY, $IYEAR, $IHOUR, $IMINUTE, $ISECOND, $IMSECONDS)
	Return _DATE_TIME_SYSTEMTIMETOFILETIME($TSYSTEMTIME)
EndFunc
Func _DATE_TIME_ENCODESYSTEMTIME($IMONTH, $IDAY, $IYEAR, $IHOUR = 0, $IMINUTE = 0, $ISECOND = 0, $IMSECONDS = 0)
	Local $TSYSTEMTIME = DllStructCreate($TAGSYSTEMTIME)
	DllStructSetData($TSYSTEMTIME, "Month", $IMONTH)
	DllStructSetData($TSYSTEMTIME, "Day", $IDAY)
	DllStructSetData($TSYSTEMTIME, "Year", $IYEAR)
	DllStructSetData($TSYSTEMTIME, "Hour", $IHOUR)
	DllStructSetData($TSYSTEMTIME, "Minute", $IMINUTE)
	DllStructSetData($TSYSTEMTIME, "Second", $ISECOND)
	DllStructSetData($TSYSTEMTIME, "MSeconds", $IMSECONDS)
	Return $TSYSTEMTIME
EndFunc
Func _DATE_TIME_FILETIMETOARRAY(ByRef $TFILETIME)
	IF ((DllStructGetData($TFILETIME, 1) + DllStructGetData($TFILETIME, 2)) = 0) Then Return SetError(1, 0, 0)
	Local $TSYSTEMTIME = _DATE_TIME_FILETIMETOSYSTEMTIME($TFILETIME)
	If @error Then Return SetError(@error, @extended, 0)
	Return _DATE_TIME_SYSTEMTIMETOARRAY($TSYSTEMTIME)
EndFunc
Func _DATE_TIME_FILETIMETOSTR(ByRef $TFILETIME, $BFMT = 0)
	Local $ADATE = _DATE_TIME_FILETIMETOARRAY($TFILETIME)
	If @error Then Return SetError(@error, @extended, "")
	If $BFMT Then
		Return StringFormat("%04d/%02d/%02d %02d:%02d:%02d", $ADATE[2], $ADATE[0], $ADATE[1], $ADATE[3], $ADATE[4], $ADATE[5])
	Else
		Return StringFormat("%02d/%02d/%04d %02d:%02d:%02d", $ADATE[0], $ADATE[1], $ADATE[2], $ADATE[3], $ADATE[4], $ADATE[5])
	EndIf
EndFunc
Func _DATE_TIME_FILETIMETODOSDATETIME($PFILETIME)
	Local $ADATE[2]
	Local $ARESULT = DllCall("kernel32.dll", "bool", "FileTimeToDosDateTime", "ptr", $PFILETIME, "word*", 0, "word*", 0)
	If @error Then Return SetError(@error, @extended, $ADATE)
	$ADATE[0] = $ARESULT[2]
	$ADATE[1] = $ARESULT[3]
	Return SetExtended($ARESULT[0], $ADATE)
EndFunc
Func _DATE_TIME_FILETIMETOLOCALFILETIME($PFILETIME)
	Local $TLOCAL = DllStructCreate($TAGFILETIME)
	Local $ARESULT = DllCall("kernel32.dll", "bool", "FileTimeToLocalFileTime", "struct*", $PFILETIME, "struct*", $TLOCAL)
	If @error Then Return SetError(@error, @extended, 0)
	Return SetExtended($ARESULT[0], $TLOCAL)
EndFunc
Func _DATE_TIME_FILETIMETOSYSTEMTIME($PFILETIME)
	Local $TSYSTTIME = DllStructCreate($TAGSYSTEMTIME)
	Local $ARESULT = DllCall("kernel32.dll", "bool", "FileTimeToSystemTime", "struct*", $PFILETIME, "struct*", $TSYSTTIME)
	If @error Then Return SetError(@error, @extended, 0)
	Return SetExtended($ARESULT[0], $TSYSTTIME)
EndFunc
Func _DATE_TIME_GETFILETIME($HFILE)
	Local $ADATE[3]
	$ADATE[0] = DllStructCreate($TAGFILETIME)
	$ADATE[1] = DllStructCreate($TAGFILETIME)
	$ADATE[2] = DllStructCreate($TAGFILETIME)
	Local $ARESULT = DllCall("Kernel32.dll", "bool", "GetFileTime", "handle", $HFILE, "struct*", $ADATE[0], "struct*", $ADATE[1], "struct*", $ADATE[2])
	If @error Then Return SetError(@error, @extended, 0)
	Return SetExtended($ARESULT[0], $ADATE)
EndFunc
Func _DATE_TIME_GETLOCALTIME()
	Local $TSYSTTIME = DllStructCreate($TAGSYSTEMTIME)
	DllCall("kernel32.dll", "none", "GetLocalTime", "struct*", $TSYSTTIME)
	If @error Then Return SetError(@error, @extended, 0)
	Return $TSYSTTIME
EndFunc
Func _DATE_TIME_GETSYSTEMTIME()
	Local $TSYSTTIME = DllStructCreate($TAGSYSTEMTIME)
	DllCall("kernel32.dll", "none", "GetSystemTime", "struct*", $TSYSTTIME)
	If @error Then Return SetError(@error, @extended, 0)
	Return $TSYSTTIME
EndFunc
Func _DATE_TIME_GETSYSTEMTIMEADJUSTMENT()
	Local $AINFO[3]
	Local $ARESULT = DllCall("kernel32.dll", "bool", "GetSystemTimeAdjustment", "dword*", 0, "dword*", 0, "bool*", 0)
	If @error Then Return SetError(@error, @extended, 0)
	$AINFO[0] = $ARESULT[1]
	$AINFO[1] = $ARESULT[2]
	$AINFO[2] = $ARESULT[3] <> 0
	Return SetExtended($ARESULT[0], $AINFO)
EndFunc
Func _DATE_TIME_GETSYSTEMTIMEASFILETIME()
	Local $TFILETIME = DllStructCreate($TAGFILETIME)
	DllCall("kernel32.dll", "none", "GetSystemTimeAsFileTime", "struct*", $TFILETIME)
	If @error Then Return SetError(@error, @extended, 0)
	Return $TFILETIME
EndFunc
Func _DATE_TIME_GETSYSTEMTIMES()
	Local $AINFO[3]
	$AINFO[0] = DllStructCreate($TAGFILETIME)
	$AINFO[1] = DllStructCreate($TAGFILETIME)
	$AINFO[2] = DllStructCreate($TAGFILETIME)
	Local $ARESULT = DllCall("kernel32.dll", "bool", "GetSystemTimes", "struct*", $AINFO[0], "struct*", $AINFO[1], "struct*", $AINFO[2])
	If @error Then Return SetError(@error, @extended, 0)
	Return SetExtended($ARESULT[0], $AINFO)
EndFunc
Func _DATE_TIME_GETTICKCOUNT()
	Local $ARESULT = DllCall("kernel32.dll", "dword", "GetTickCount")
	If @error Then Return SetError(@error, @extended, 0)
	Return $ARESULT[0]
EndFunc
Func _DATE_TIME_GETTIMEZONEINFORMATION()
	Local $TTIMEZONE = DllStructCreate($TAGTIME_ZONE_INFORMATION)
	Local $ARESULT = DllCall("kernel32.dll", "dword", "GetTimeZoneInformation", "struct*", $TTIMEZONE)
	If @error Or $ARESULT[0] = -1 Then Return SetError(@error, @extended, 0)
	Local $AINFO[8]
	$AINFO[0] = $ARESULT[0]
	$AINFO[1] = DllStructGetData($TTIMEZONE, "Bias")
	$AINFO[2] = _WINAPI_WIDECHARTOMULTIBYTE(DllStructGetPtr($TTIMEZONE, "StdName"))
	$AINFO[3] = __DATE_TIME_CLONESYSTEMTIME(DllStructGetPtr($TTIMEZONE, "StdDate"))
	$AINFO[4] = DllStructGetData($TTIMEZONE, "StdBias")
	$AINFO[5] = _WINAPI_WIDECHARTOMULTIBYTE(DllStructGetPtr($TTIMEZONE, "DayName"))
	$AINFO[6] = __DATE_TIME_CLONESYSTEMTIME(DllStructGetPtr($TTIMEZONE, "DayDate"))
	$AINFO[7] = DllStructGetData($TTIMEZONE, "DayBias")
	Return $AINFO
EndFunc
Func _DATE_TIME_LOCALFILETIMETOFILETIME($PLOCALTIME)
	Local $TFILETIME = DllStructCreate($TAGFILETIME)
	Local $ARESULT = DllCall("kernel32.dll", "bool", "LocalFileTimeToFileTime", "ptr", $PLOCALTIME, "struct*", $TFILETIME)
	If @error Then Return SetError(@error, @extended, 0)
	Return SetExtended($ARESULT[0], $TFILETIME)
EndFunc
Func _DATE_TIME_SETFILETIME($HFILE, $PCREATETIME, $PLASTACCESS, $PLASTWRITE)
	Local $ARESULT = DllCall("kernel32.dll", "bool", "SetFileTime", "handle", $HFILE, "ptr", $PCREATETIME, "ptr", $PLASTACCESS, "ptr", $PLASTWRITE)
	If @error Then Return SetError(@error, @extended, False)
	Return $ARESULT[0]
EndFunc
Func _DATE_TIME_SETLOCALTIME($PSYSTEMTIME)
	Local $ARESULT = DllCall("kernel32.dll", "bool", "SetLocalTime", "struct*", $PSYSTEMTIME)
	If @error Or Not $ARESULT[0] Then Return SetError(@error, @extended, False)
	$ARESULT = DllCall("kernel32.dll", "bool", "SetLocalTime", "struct*", $PSYSTEMTIME)
	If @error Then Return SetError(@error, @extended, False)
	Return $ARESULT[0]
EndFunc
Func _DATE_TIME_SETSYSTEMTIME($PSYSTEMTIME)
	Local $ARESULT = DllCall("kernel32.dll", "bool", "SetSystemTime", "ptr", $PSYSTEMTIME)
	If @error Then Return SetError(@error, @extended, False)
	Return $ARESULT[0]
EndFunc
Func _DATE_TIME_SETSYSTEMTIMEADJUSTMENT($IADJUSTMENT, $FDISABLED)
	Local $HTOKEN = _SECURITY__OPENTHREADTOKENEX(BitOR($TOKEN_ADJUST_PRIVILEGES, $TOKEN_QUERY))
	If @error Then Return SetError(@error, @extended, False)
	_SECURITY__SETPRIVILEGE($HTOKEN, "SeSystemtimePrivilege", True)
	Local $IERROR = @error
	Local $ILASTERROR = @extended
	Local $IRET = False
	If Not @error Then
		Local $ARESULT = DllCall("kernel32.dll", "bool", "SetSystemTimeAdjustment", "dword", $IADJUSTMENT, "bool", $FDISABLED)
		If @error Then
			$IERROR = @error
			$ILASTERROR = @extended
		ElseIf $ARESULT[0] Then
			$IRET = True
		Else
			$IERROR = 1
			$ILASTERROR = _WINAPI_GETLASTERROR()
		EndIf
		_SECURITY__SETPRIVILEGE($HTOKEN, "SeSystemtimePrivilege", False)
		If @error Then $IERROR = 2
	EndIf
	_WINAPI_CLOSEHANDLE($HTOKEN)
	Return SetError($IERROR, $ILASTERROR, $IRET)
EndFunc
Func _DATE_TIME_SETTIMEZONEINFORMATION($IBIAS, $SSTDNAME, $TSTDDATE, $ISTDBIAS, $SDAYNAME, $TDAYDATE, $IDAYBIAS)
	Local $TSTDNAME = _WINAPI_MULTIBYTETOWIDECHAR($SSTDNAME)
	Local $TDAYNAME = _WINAPI_MULTIBYTETOWIDECHAR($SDAYNAME)
	Local $TZONEINFO = DllStructCreate($TAGTIME_ZONE_INFORMATION)
	DllStructSetData($TZONEINFO, "Bias", $IBIAS)
	DllStructSetData($TZONEINFO, "StdName", DllStructGetData($TSTDNAME, 1))
	_MEMMOVEMEMORY($TSTDDATE, DllStructGetPtr($TZONEINFO, "StdDate"), DllStructGetSize($TSTDDATE))
	DllStructSetData($TZONEINFO, "StdBias", $ISTDBIAS)
	DllStructSetData($TZONEINFO, "DayName", DllStructGetData($TDAYNAME, 1))
	_MEMMOVEMEMORY($TDAYDATE, DllStructGetPtr($TZONEINFO, "DayDate"), DllStructGetSize($TDAYDATE))
	DllStructSetData($TZONEINFO, "DayBias", $IDAYBIAS)
	Local $HTOKEN = _SECURITY__OPENTHREADTOKENEX(BitOR($TOKEN_ADJUST_PRIVILEGES, $TOKEN_QUERY))
	If @error Then Return SetError(@error, @extended, False)
	_SECURITY__SETPRIVILEGE($HTOKEN, "SeSystemtimePrivilege", True)
	Local $IERROR = @error
	Local $ILASTERROR = @extended
	Local $IRET = False
	If Not @error Then
		Local $ARESULT = DllCall("kernel32.dll", "bool", "SetTimeZoneInformation", "struct*", $TZONEINFO)
		If @error Then
			$IERROR = @error
			$ILASTERROR = @extended
		ElseIf $ARESULT[0] Then
			$ILASTERROR = 0
			$IRET = True
		Else
			$IERROR = 1
			$ILASTERROR = _WINAPI_GETLASTERROR()
		EndIf
		_SECURITY__SETPRIVILEGE($HTOKEN, "SeSystemtimePrivilege", False)
		If @error Then $IERROR = 2
	EndIf
	_WINAPI_CLOSEHANDLE($HTOKEN)
	Return SetError($IERROR, $ILASTERROR, $IRET)
EndFunc
Func _DATE_TIME_SYSTEMTIMETOARRAY(ByRef $TSYSTEMTIME)
	Local $AINFO[8]
	$AINFO[0] = DllStructGetData($TSYSTEMTIME, "Month")
	$AINFO[1] = DllStructGetData($TSYSTEMTIME, "Day")
	$AINFO[2] = DllStructGetData($TSYSTEMTIME, "Year")
	$AINFO[3] = DllStructGetData($TSYSTEMTIME, "Hour")
	$AINFO[4] = DllStructGetData($TSYSTEMTIME, "Minute")
	$AINFO[5] = DllStructGetData($TSYSTEMTIME, "Second")
	$AINFO[6] = DllStructGetData($TSYSTEMTIME, "MSeconds")
	$AINFO[7] = DllStructGetData($TSYSTEMTIME, "DOW")
	Return $AINFO
EndFunc
Func _DATE_TIME_SYSTEMTIMETODATESTR(ByRef $TSYSTEMTIME, $BFMT = 0)
	Local $AINFO = _DATE_TIME_SYSTEMTIMETOARRAY($TSYSTEMTIME)
	If @error Then Return SetError(@error, @extended, "")
	If $BFMT Then
		Return StringFormat("%04d/%02d/%02d", $AINFO[2], $AINFO[0], $AINFO[1])
	Else
		Return StringFormat("%02d/%02d/%04d", $AINFO[0], $AINFO[1], $AINFO[2])
	EndIf
EndFunc
Func _DATE_TIME_SYSTEMTIMETODATETIMESTR(ByRef $TSYSTEMTIME, $BFMT = 0)
	Local $AINFO = _DATE_TIME_SYSTEMTIMETOARRAY($TSYSTEMTIME)
	If @error Then Return SetError(@error, @extended, "")
	If $BFMT Then
		Return StringFormat("%04d/%02d/%02d %02d:%02d:%02d", $AINFO[2], $AINFO[0], $AINFO[1], $AINFO[3], $AINFO[4], $AINFO[5])
	Else
		Return StringFormat("%02d/%02d/%04d %02d:%02d:%02d", $AINFO[0], $AINFO[1], $AINFO[2], $AINFO[3], $AINFO[4], $AINFO[5])
	EndIf
EndFunc
Func _DATE_TIME_SYSTEMTIMETOFILETIME($PSYSTEMTIME)
	Local $TFILETIME = DllStructCreate($TAGFILETIME)
	Local $ARESULT = DllCall("kernel32.dll", "bool", "SystemTimeToFileTime", "struct*", $PSYSTEMTIME, "struct*", $TFILETIME)
	If @error Then Return SetError(@error, @extended, 0)
	Return SetExtended($ARESULT[0], $TFILETIME)
EndFunc
Func _DATE_TIME_SYSTEMTIMETOTIMESTR(ByRef $TSYSTEMTIME)
	Local $AINFO = _DATE_TIME_SYSTEMTIMETOARRAY($TSYSTEMTIME)
	Return StringFormat("%02d:%02d:%02d", $AINFO[3], $AINFO[4], $AINFO[5])
EndFunc
Func _DATE_TIME_SYSTEMTIMETOTZSPECIFICLOCALTIME($PUTC, $PTIMEZONE = 0)
	Local $TLOCALTIME = DllStructCreate($TAGSYSTEMTIME)
	Local $ARESULT = DllCall("kernel32.dll", "bool", "SystemTimeToTzSpecificLocalTime", "ptr", $PTIMEZONE, "ptr", $PUTC, "struct*", $TLOCALTIME)
	If @error Then Return SetError(@error, @extended, 0)
	Return SetExtended($ARESULT[0], $TLOCALTIME)
EndFunc
Func _DATE_TIME_TZSPECIFICLOCALTIMETOSYSTEMTIME($PLOCALTIME, $PTIMEZONE = 0)
	Local $TUTC = DllStructCreate($TAGSYSTEMTIME)
	Local $ARESULT = DllCall("kernel32.dll", "ptr", "TzSpecificLocalTimeToSystemTime", "ptr", $PTIMEZONE, "ptr", $PLOCALTIME, "struct*", $TUTC)
	If @error Then Return SetError(@error, @extended, 0)
	Return SetExtended($ARESULT[0], $TUTC)
EndFunc
Global Const $FW_DONTCARE = 0
Global Const $FW_THIN = 100
Global Const $FW_EXTRALIGHT = 200
Global Const $FW_ULTRALIGHT = 200
Global Const $FW_LIGHT = 300
Global Const $FW_NORMAL = 400
Global Const $FW_REGULAR = 400
Global Const $FW_MEDIUM = 500
Global Const $FW_SEMIBOLD = 600
Global Const $FW_DEMIBOLD = 600
Global Const $FW_BOLD = 700
Global Const $FW_EXTRABOLD = 800
Global Const $FW_ULTRABOLD = 800
Global Const $FW_HEAVY = 900
Global Const $FW_BLACK = 900
Global Const $CF_EFFECTS = 256
Global Const $CF_PRINTERFONTS = 2
Global Const $CF_SCREENFONTS = 1
Global Const $CF_NOSCRIPTSEL = 8388608
Global Const $CF_INITTOLOGFONTSTRUCT = 64
Global Const $LOGPIXELSX = 88
Global Const $LOGPIXELSY = 90
Global Const $ANSI_CHARSET = 0
Global Const $BALTIC_CHARSET = 186
Global Const $CHINESEBIG5_CHARSET = 136
Global Const $DEFAULT_CHARSET = 1
Global Const $EASTEUROPE_CHARSET = 238
Global Const $GB2312_CHARSET = 134
Global Const $GREEK_CHARSET = 161
Global Const $HANGEUL_CHARSET = 129
Global Const $MAC_CHARSET = 77
Global Const $OEM_CHARSET = 255
Global Const $RUSSIAN_CHARSET = 204
Global Const $SHIFTJIS_CHARSET = 128
Global Const $SYMBOL_CHARSET = 2
Global Const $TURKISH_CHARSET = 162
Global Const $VIETNAMESE_CHARSET = 163
Global Const $OUT_CHARACTER_PRECIS = 2
Global Const $OUT_DEFAULT_PRECIS = 0
Global Const $OUT_DEVICE_PRECIS = 5
Global Const $OUT_OUTLINE_PRECIS = 8
Global Const $OUT_PS_ONLY_PRECIS = 10
Global Const $OUT_RASTER_PRECIS = 6
Global Const $OUT_STRING_PRECIS = 1
Global Const $OUT_STROKE_PRECIS = 3
Global Const $OUT_TT_ONLY_PRECIS = 7
Global Const $OUT_TT_PRECIS = 4
Global Const $CLIP_CHARACTER_PRECIS = 1
Global Const $CLIP_DEFAULT_PRECIS = 0
Global Const $CLIP_EMBEDDED = 128
Global Const $CLIP_LH_ANGLES = 16
Global Const $CLIP_MASK = 15
Global Const $CLIP_STROKE_PRECIS = 2
Global Const $CLIP_TT_ALWAYS = 32
Global Const $ANTIALIASED_QUALITY = 4
Global Const $DEFAULT_QUALITY = 0
Global Const $DRAFT_QUALITY = 1
Global Const $NONANTIALIASED_QUALITY = 3
Global Const $PROOF_QUALITY = 2
Global Const $DEFAULT_PITCH = 0
Global Const $FIXED_PITCH = 1
Global Const $VARIABLE_PITCH = 2
Global Const $FF_DECORATIVE = 80
Global Const $FF_DONTCARE = 0
Global Const $FF_MODERN = 48
Global Const $FF_ROMAN = 16
Global Const $FF_SCRIPT = 64
Global Const $FF_SWISS = 32
Global Const $__MISCCONSTANT_CC_ANYCOLOR = 256
Global Const $__MISCCONSTANT_CC_FULLOPEN = 2
Global Const $__MISCCONSTANT_CC_RGBINIT = 1
Global Const $TAGCHOOSECOLOR = "dword Size;hwnd hWndOwnder;handle hInstance;dword rgbResult;ptr CustColors;dword Flags;lparam lCustData;" & "ptr lpfnHook;ptr lpTemplateName"
Global Const $TAGCHOOSEFONT = "dword Size;hwnd hWndOwner;handle hDC;ptr LogFont;int PointSize;dword Flags;dword rgbColors;lparam CustData;" & "ptr fnHook;ptr TemplateName;handle hInstance;ptr szStyle;word FontType;int SizeMin;int SizeMax"
Func _CHOOSECOLOR($IRETURNTYPE = 0, $ICOLORREF = 0, $IREFTYPE = 0, $HWNDOWNDER = 0)
	Local $CUSTCOLORS = "dword[16]"
	Local $TCHOOSE = DllStructCreate($TAGCHOOSECOLOR)
	Local $TCC = DllStructCreate($CUSTCOLORS)
	If $IREFTYPE = 1 Then
		$ICOLORREF = Int($ICOLORREF)
	ElseIf $IREFTYPE = 2 Then
		$ICOLORREF = Hex(String($ICOLORREF), 6)
		$ICOLORREF = "0x" & StringMid($ICOLORREF, 5, 2) & StringMid($ICOLORREF, 3, 2) & StringMid($ICOLORREF, 1, 2)
	EndIf
	DllStructSetData($TCHOOSE, "Size", DllStructGetSize($TCHOOSE))
	DllStructSetData($TCHOOSE, "hWndOwnder", $HWNDOWNDER)
	DllStructSetData($TCHOOSE, "rgbResult", $ICOLORREF)
	DllStructSetData($TCHOOSE, "CustColors", DllStructGetPtr($TCC))
	DllStructSetData($TCHOOSE, "Flags", BitOR($__MISCCONSTANT_CC_ANYCOLOR, $__MISCCONSTANT_CC_FULLOPEN, $__MISCCONSTANT_CC_RGBINIT))
	Local $ARESULT = DllCall("comdlg32.dll", "bool", "ChooseColor", "struct*", $TCHOOSE)
	If @error Then Return SetError(@error, @extended, -1)
	If $ARESULT[0] = 0 Then Return SetError(-3, -3, -1)
	Local $COLOR_PICKED = DllStructGetData($TCHOOSE, "rgbResult")
	If $IRETURNTYPE = 1 Then
		Return "0x" & Hex(String($COLOR_PICKED), 6)
	ElseIf $IRETURNTYPE = 2 Then
		$COLOR_PICKED = Hex(String($COLOR_PICKED), 6)
		Return "0x" & StringMid($COLOR_PICKED, 5, 2) & StringMid($COLOR_PICKED, 3, 2) & StringMid($COLOR_PICKED, 1, 2)
	ElseIf $IRETURNTYPE = 0 Then
		Return $COLOR_PICKED
	Else
		Return SetError(-4, -4, -1)
	EndIf
EndFunc
Func _CHOOSEFONT($SFONTNAME = "Courier New", $IPOINTSIZE = 10, $ICOLORREF = 0, $IFONTWEIGHT = 0, $IITALIC = False, $IUNDERLINE = False, $ISTRIKETHRU = False, $HWNDOWNER = 0)
	Local $ITALIC = 0, $UNDERLINE = 0, $STRIKEOUT = 0
	Local $LNGDC = __MISC_GETDC(0)
	Local $LFHEIGHT = Round(($IPOINTSIZE * __MISC_GETDEVICECAPS($LNGDC, $LOGPIXELSX)) / 72, 0)
	__MISC_RELEASEDC(0, $LNGDC)
	Local $TCHOOSEFONT = DllStructCreate($TAGCHOOSEFONT)
	Local $TLOGFONT = DllStructCreate($TAGLOGFONT)
	DllStructSetData($TCHOOSEFONT, "Size", DllStructGetSize($TCHOOSEFONT))
	DllStructSetData($TCHOOSEFONT, "hWndOwner", $HWNDOWNER)
	DllStructSetData($TCHOOSEFONT, "LogFont", DllStructGetPtr($TLOGFONT))
	DllStructSetData($TCHOOSEFONT, "PointSize", $IPOINTSIZE)
	DllStructSetData($TCHOOSEFONT, "Flags", BitOR($CF_SCREENFONTS, $CF_PRINTERFONTS, $CF_EFFECTS, $CF_INITTOLOGFONTSTRUCT, $CF_NOSCRIPTSEL))
	DllStructSetData($TCHOOSEFONT, "rgbColors", $ICOLORREF)
	DllStructSetData($TCHOOSEFONT, "FontType", 0)
	DllStructSetData($TLOGFONT, "Height", $LFHEIGHT)
	DllStructSetData($TLOGFONT, "Weight", $IFONTWEIGHT)
	DllStructSetData($TLOGFONT, "Italic", $IITALIC)
	DllStructSetData($TLOGFONT, "Underline", $IUNDERLINE)
	DllStructSetData($TLOGFONT, "Strikeout", $ISTRIKETHRU)
	DllStructSetData($TLOGFONT, "FaceName", $SFONTNAME)
	Local $ARESULT = DllCall("comdlg32.dll", "bool", "ChooseFontW", "struct*", $TCHOOSEFONT)
	If @error Then Return SetError(@error, @extended, -1)
	If $ARESULT[0] = 0 Then Return SetError(-3, -3, -1)
	Local $FONTNAME = DllStructGetData($TLOGFONT, "FaceName")
	If StringLen($FONTNAME) = 0 And StringLen($SFONTNAME) > 0 Then $FONTNAME = $SFONTNAME
	If DllStructGetData($TLOGFONT, "Italic") Then $ITALIC = 2
	If DllStructGetData($TLOGFONT, "Underline") Then $UNDERLINE = 4
	If DllStructGetData($TLOGFONT, "Strikeout") Then $STRIKEOUT = 8
	Local $ATTRIBUTES = BitOR($ITALIC, $UNDERLINE, $STRIKEOUT)
	Local $SIZE = DllStructGetData($TCHOOSEFONT, "PointSize") / 10
	Local $COLORREF = DllStructGetData($TCHOOSEFONT, "rgbColors")
	Local $WEIGHT = DllStructGetData($TLOGFONT, "Weight")
	Local $COLOR_PICKED = Hex(String($COLORREF), 6)
	Return StringSplit($ATTRIBUTES & "," & $FONTNAME & "," & $SIZE & "," & $WEIGHT & "," & $COLORREF & "," & "0x" & $COLOR_PICKED & "," & "0x" & StringMid($COLOR_PICKED, 5, 2) & StringMid($COLOR_PICKED, 3, 2) & StringMid($COLOR_PICKED, 1, 2), ",")
EndFunc
Func _CLIPPUTFILE($SFILE, $SSEPARATOR = "|")
	Local Const $GMEM_MOVEABLE = 2, $CF_HDROP = 15
	$SFILE &= $SSEPARATOR & $SSEPARATOR
	Local $NGLOBMEMSIZE = 2 * (StringLen($SFILE) + 20)
	Local $ARESULT = DllCall("user32.dll", "bool", "OpenClipboard", "hwnd", 0)
	If @error Or $ARESULT[0] = 0 Then Return SetError(1, _WINAPI_GETLASTERROR(), False)
	Local $IERROR = 0, $ILASTERROR = 0
	$ARESULT = DllCall("user32.dll", "bool", "EmptyClipboard")
	If @error Or Not $ARESULT[0] Then
		$IERROR = 2
		$ILASTERROR = _WINAPI_GETLASTERROR()
	Else
		$ARESULT = DllCall("kernel32.dll", "handle", "GlobalAlloc", "uint", $GMEM_MOVEABLE, "ulong_ptr", $NGLOBMEMSIZE)
		If @error Or Not $ARESULT[0] Then
			$IERROR = 3
			$ILASTERROR = _WINAPI_GETLASTERROR()
		Else
			Local $HGLOBAL = $ARESULT[0]
			$ARESULT = DllCall("kernel32.dll", "ptr", "GlobalLock", "handle", $HGLOBAL)
			If @error Or Not $ARESULT[0] Then
				$IERROR = 4
				$ILASTERROR = _WINAPI_GETLASTERROR()
			Else
				Local $HLOCK = $ARESULT[0]
				Local $DROPFILES = DllStructCreate("dword pFiles;" & $TAGPOINT & ";bool fNC;bool fWide;wchar[" & StringLen($SFILE) + 1 & "]", $HLOCK)
				If @error Then Return SetError(5, 6, False)
				Local $TEMPSTRUCT = DllStructCreate("dword;long;long;bool;bool")
				DllStructSetData($DROPFILES, "pFiles", DllStructGetSize($TEMPSTRUCT))
				DllStructSetData($DROPFILES, "X", 0)
				DllStructSetData($DROPFILES, "Y", 0)
				DllStructSetData($DROPFILES, "fNC", 0)
				DllStructSetData($DROPFILES, "fWide", 1)
				DllStructSetData($DROPFILES, 6, $SFILE)
				For $I = 1 To StringLen($SFILE)
					If DllStructGetData($DROPFILES, 6, $I) = $SSEPARATOR Then DllStructSetData($DROPFILES, 6, Chr(0), $I)
				Next
				$ARESULT = DllCall("user32.dll", "handle", "SetClipboardData", "uint", $CF_HDROP, "handle", $HGLOBAL)
				If @error Or Not $ARESULT[0] Then
					$IERROR = 6
					$ILASTERROR = _WINAPI_GETLASTERROR()
				EndIf
				$ARESULT = DllCall("kernel32.dll", "bool", "GlobalUnlock", "handle", $HGLOBAL)
				IF (@error Or Not $ARESULT[0]) And Not $IERROR And _WINAPI_GETLASTERROR() Then
					$IERROR = 8
					$ILASTERROR = _WINAPI_GETLASTERROR()
				EndIf
			EndIf
			$ARESULT = DllCall("kernel32.dll", "ptr", "GlobalFree", "handle", $HGLOBAL)
			IF (@error Or $ARESULT[0]) And Not $IERROR Then
				$IERROR = 9
				$ILASTERROR = _WINAPI_GETLASTERROR()
			EndIf
		EndIf
	EndIf
	$ARESULT = DllCall("user32.dll", "bool", "CloseClipboard")
	IF (@error Or Not $ARESULT[0]) And Not $IERROR Then Return SetError(7, _WINAPI_GETLASTERROR(), False)
	If $IERROR Then Return SetError($IERROR, $ILASTERROR, False)
	Return True
EndFunc
Func _IIF($FTEST, $VTRUEVAL, $VFALSEVAL)
	If $FTEST Then
		Return $VTRUEVAL
	Else
		Return $VFALSEVAL
	EndIf
EndFunc
Func _MOUSETRAP($ILEFT = 0, $ITOP = 0, $IRIGHT = 0, $IBOTTOM = 0)
	Local $ARESULT
	If @NumParams == 0 Then
		$ARESULT = DllCall("user32.dll", "bool", "ClipCursor", "ptr", 0)
		If @error Or Not $ARESULT[0] Then Return SetError(1, _WINAPI_GETLASTERROR(), False)
	Else
		If @NumParams == 2 Then
			$IRIGHT = $ILEFT + 1
			$IBOTTOM = $ITOP + 1
		EndIf
		Local $TRECT = DllStructCreate($TAGRECT)
		DllStructSetData($TRECT, "Left", $ILEFT)
		DllStructSetData($TRECT, "Top", $ITOP)
		DllStructSetData($TRECT, "Right", $IRIGHT)
		DllStructSetData($TRECT, "Bottom", $IBOTTOM)
		$ARESULT = DllCall("user32.dll", "bool", "ClipCursor", "struct*", $TRECT)
		If @error Or Not $ARESULT[0] Then Return SetError(2, _WINAPI_GETLASTERROR(), False)
	EndIf
	Return True
EndFunc
Func _SINGLETON($SOCCURENCENAME, $IFLAG = 0)
	Local Const $ERROR_ALREADY_EXISTS = 183
	Local Const $SECURITY_DESCRIPTOR_REVISION = 1
	Local $TSECURITYATTRIBUTES = 0
	If BitAND($IFLAG, 2) Then
		Local $TSECURITYDESCRIPTOR = DllStructCreate("byte;byte;word;ptr[4]")
		Local $ARET = DllCall("advapi32.dll", "bool", "InitializeSecurityDescriptor", "struct*", $TSECURITYDESCRIPTOR, "dword", $SECURITY_DESCRIPTOR_REVISION)
		If @error Then Return SetError(@error, @extended, 0)
		If $ARET[0] Then
			$ARET = DllCall("advapi32.dll", "bool", "SetSecurityDescriptorDacl", "struct*", $TSECURITYDESCRIPTOR, "bool", 1, "ptr", 0, "bool", 0)
			If @error Then Return SetError(@error, @extended, 0)
			If $ARET[0] Then
				$TSECURITYATTRIBUTES = DllStructCreate($TAGSECURITY_ATTRIBUTES)
				DllStructSetData($TSECURITYATTRIBUTES, 1, DllStructGetSize($TSECURITYATTRIBUTES))
				DllStructSetData($TSECURITYATTRIBUTES, 2, DllStructGetPtr($TSECURITYDESCRIPTOR))
				DllStructSetData($TSECURITYATTRIBUTES, 3, 0)
			EndIf
		EndIf
	EndIf
	Local $HANDLE = DllCall("kernel32.dll", "handle", "CreateMutexW", "struct*", $TSECURITYATTRIBUTES, "bool", 1, "wstr", $SOCCURENCENAME)
	If @error Then Return SetError(@error, @extended, 0)
	Local $LASTERROR = DllCall("kernel32.dll", "dword", "GetLastError")
	If @error Then Return SetError(@error, @extended, 0)
	If $LASTERROR[0] = $ERROR_ALREADY_EXISTS Then
		If BitAND($IFLAG, 1) Then
			Return SetError($LASTERROR[0], $LASTERROR[0], 0)
		Else
			Exit -1
		EndIf
	EndIf
	Return $HANDLE[0]
EndFunc
Func _ISPRESSED($SHEXKEY, $VDLL = "user32.dll")
	Local $A_R = DllCall($VDLL, "short", "GetAsyncKeyState", "int", "0x" & $SHEXKEY)
	If @error Then Return SetError(@error, @extended, False)
	Return BitAND($A_R[0], 32768) <> 0
EndFunc
Func _VERSIONCOMPARE($SVERSION1, $SVERSION2)
	If $SVERSION1 = $SVERSION2 Then Return 0
	Local $SEP = "."
	If StringInStr($SVERSION1, $SEP) = 0 Then $SEP = ","
	Local $AVERSION1 = StringSplit($SVERSION1, $SEP)
	Local $AVERSION2 = StringSplit($SVERSION2, $SEP)
	If UBound($AVERSION1) <> UBound($AVERSION2) Or UBound($AVERSION1) = 0 Then
		SetExtended(1)
		If $SVERSION1 > $SVERSION2 Then
			Return 1
		ElseIf $SVERSION1 < $SVERSION2 Then
			Return -1
		EndIf
	Else
		For $I = 1 To UBound($AVERSION1) - 1
			If StringIsDigit($AVERSION1[$I]) And StringIsDigit($AVERSION2[$I]) Then
				If Number($AVERSION1[$I]) > Number($AVERSION2[$I]) Then
					Return 1
				ElseIf Number($AVERSION1[$I]) < Number($AVERSION2[$I]) Then
					Return -1
				EndIf
			Else
				SetExtended(1)
				If $AVERSION1[$I] > $AVERSION2[$I] Then
					Return 1
				ElseIf $AVERSION1[$I] < $AVERSION2[$I] Then
					Return -1
				EndIf
			EndIf
		Next
	EndIf
	Return SetError(2, 0, 0)
EndFunc
Func __MISC_GETDC($HWND)
	Local $ARESULT = DllCall("User32.dll", "handle", "GetDC", "hwnd", $HWND)
	If @error Or Not $ARESULT[0] Then Return SetError(1, _WINAPI_GETLASTERROR(), 0)
	Return $ARESULT[0]
EndFunc
Func __MISC_GETDEVICECAPS($HDC, $IINDEX)
	Local $ARESULT = DllCall("GDI32.dll", "int", "GetDeviceCaps", "handle", $HDC, "int", $IINDEX)
	If @error Then Return SetError(@error, @extended, 0)
	Return $ARESULT[0]
EndFunc
Func __MISC_RELEASEDC($HWND, $HDC)
	Local $ARESULT = DllCall("User32.dll", "int", "ReleaseDC", "hwnd", $HWND, "handle", $HDC)
	If @error Then Return SetError(@error, @extended, False)
	Return $ARESULT[0] <> 0
EndFunc
#Region Header
Global Const $DDL_ARCHIVE = 32
Global Const $DDL_DIRECTORY = 16
Global Const $DDL_DRIVES = 16384
Global Const $DDL_EXCLUSIVE = 32768
Global Const $DDL_HIDDEN = 2
Global Const $DDL_READONLY = 1
Global Const $DDL_READWRITE = 0
Global Const $DDL_SYSTEM = 4
Global Const $COLOR_AQUA = 65535
Global Const $COLOR_BLACK = 0
Global Const $COLOR_BLUE = 255
Global Const $COLOR_CREAM = 16776176
Global Const $COLOR_FUCHSIA = 16711935
Global Const $COLOR_GRAY = 8421504
Global Const $COLOR_GREEN = 32768
Global Const $COLOR_LIME = 65280
Global Const $COLOR_MAROON = 9116770
Global Const $COLOR_MEDBLUE = 708
Global Const $COLOR_MEDGRAY = 10526884
Global Const $COLOR_MONEYGREEN = 12639424
Global Const $COLOR_NAVY = 128
Global Const $COLOR_OLIVE = 8421376
Global Const $COLOR_PURPLE = 8388736
Global Const $COLOR_RED = 16711680
Global Const $COLOR_SILVER = 12632256
Global Const $COLOR_SKYBLUE = 10930928
Global Const $COLOR_TEAL = 32896
Global Const $COLOR_WHITE = 16777215
Global Const $COLOR_YELLOW = 16776960
Global Const $CLR_NONE = -1
Global Const $CLR_DEFAULT = -16777216
Global Const $CLR_AQUA = 16776960
Global Const $CLR_BLACK = 0
Global Const $CLR_BLUE = 16711680
Global Const $CLR_CREAM = 15793151
Global Const $CLR_FUCHSIA = 16711935
Global Const $CLR_GRAY = 8421504
Global Const $CLR_GREEN = 32768
Global Const $CLR_LIME = 65280
Global Const $CLR_MAROON = 6429835
Global Const $CLR_MEDBLUE = 12845568
Global Const $CLR_MEDGRAY = 10789024
Global Const $CLR_MONEYGREEN = 12639424
Global Const $CLR_NAVY = 8388608
Global Const $CLR_OLIVE = 32896
Global Const $CLR_PURPLE = 8388736
Global Const $CLR_RED = 255
Global Const $CLR_SILVER = 12632256
Global Const $CLR_SKYBLUE = 15780518
Global Const $CLR_TEAL = 8421376
Global Const $CLR_WHITE = 16777215
Global Const $CLR_YELLOW = 65535
Global Const $CC_ANYCOLOR = 256
Global Const $CC_FULLOPEN = 2
Global Const $CC_RGBINIT = 1
Global Const $OPT_COORDSRELATIVE = 0
Global Const $OPT_COORDSABSOLUTE = 1
Global Const $OPT_COORDSCLIENT = 2
Global Const $OPT_ERRORSILENT = 0
Global Const $OPT_ERRORFATAL = 1
Global Const $OPT_CAPSNOSTORE = 0
Global Const $OPT_CAPSSTORE = 1
Global Const $OPT_MATCHSTART = 1
Global Const $OPT_MATCHANY = 2
Global Const $OPT_MATCHEXACT = 3
Global Const $OPT_MATCHADVANCED = 4
Global Const $CCS_TOP = 1
Global Const $CCS_NOMOVEY = 2
Global Const $CCS_BOTTOM = 3
Global Const $CCS_NORESIZE = 4
Global Const $CCS_NOPARENTALIGN = 8
Global Const $CCS_NOHILITE = 16
Global Const $CCS_ADJUSTABLE = 32
Global Const $CCS_NODIVIDER = 64
Global Const $CCS_VERT = 128
Global Const $CCS_LEFT = 129
Global Const $CCS_NOMOVEX = 130
Global Const $CCS_RIGHT = 131
Global Const $DI_MASK = 1
Global Const $DI_IMAGE = 2
Global Const $DI_NORMAL = 3
Global Const $DI_COMPAT = 4
Global Const $DI_DEFAULTSIZE = 8
Global Const $DI_NOMIRROR = 16
Global Const $DISPLAY_DEVICE_ATTACHED_TO_DESKTOP = 1
Global Const $DISPLAY_DEVICE_MULTI_DRIVER = 2
Global Const $DISPLAY_DEVICE_PRIMARY_DEVICE = 4
Global Const $DISPLAY_DEVICE_MIRRORING_DRIVER = 8
Global Const $DISPLAY_DEVICE_VGA_COMPATIBLE = 16
Global Const $DISPLAY_DEVICE_REMOVABLE = 32
Global Const $DISPLAY_DEVICE_DISCONNECT = 33554432
Global Const $DISPLAY_DEVICE_REMOTE = 67108864
Global Const $DISPLAY_DEVICE_MODESPRUNED = 134217728
Global Const $FLASHW_CAPTION = 1
Global Const $FLASHW_TRAY = 2
Global Const $FLASHW_TIMER = 4
Global Const $FLASHW_TIMERNOFG = 12
Global Const $FORMAT_MESSAGE_ALLOCATE_BUFFER = 256
Global Const $FORMAT_MESSAGE_IGNORE_INSERTS = 512
Global Const $FORMAT_MESSAGE_FROM_STRING = 1024
Global Const $FORMAT_MESSAGE_FROM_HMODULE = 2048
Global Const $FORMAT_MESSAGE_FROM_SYSTEM = 4096
Global Const $FORMAT_MESSAGE_ARGUMENT_ARRAY = 8192
Global Const $GW_HWNDFIRST = 0
Global Const $GW_HWNDLAST = 1
Global Const $GW_HWNDNEXT = 2
Global Const $GW_HWNDPREV = 3
Global Const $GW_OWNER = 4
Global Const $GW_CHILD = 5
Global Const $GWL_WNDPROC = -4
Global Const $GWL_HINSTANCE = -6
Global Const $GWL_HWNDPARENT = -8
Global Const $GWL_ID = -12
Global Const $GWL_STYLE = -16
Global Const $GWL_EXSTYLE = -20
Global Const $GWL_USERDATA = -21
Global Const $STD_CUT = 0
Global Const $STD_COPY = 1
Global Const $STD_PASTE = 2
Global Const $STD_UNDO = 3
Global Const $STD_REDOW = 4
Global Const $STD_DELETE = 5
Global Const $STD_FILENEW = 6
Global Const $STD_FILEOPEN = 7
Global Const $STD_FILESAVE = 8
Global Const $STD_PRINTPRE = 9
Global Const $STD_PROPERTIES = 10
Global Const $STD_HELP = 11
Global Const $STD_FIND = 12
Global Const $STD_REPLACE = 13
Global Const $STD_PRINT = 14
Global Const $LR_DEFAULTCOLOR = 0
Global Const $LR_MONOCHROME = 1
Global Const $LR_COLOR = 2
Global Const $LR_COPYRETURNORG = 4
Global Const $LR_COPYDELETEORG = 8
Global Const $LR_LOADFROMFILE = 16
Global Const $LR_LOADTRANSPARENT = 32
Global Const $LR_DEFAULTSIZE = 64
Global Const $LR_VGACOLOR = 128
Global Const $LR_LOADMAP3DCOLORS = 4096
Global Const $LR_CREATEDIBSECTION = 8192
Global Const $LR_COPYFROMRESOURCE = 16384
Global Const $LR_SHARED = 32768
Global Const $IMAGE_BITMAP = 0
Global Const $IMAGE_ICON = 1
Global Const $IMAGE_CURSOR = 2
Global Const $KB_SENDSPECIAL = 0
Global Const $KB_SENDRAW = 1
Global Const $KB_CAPSOFF = 0
Global Const $KB_CAPSON = 1
Global Const $DONT_RESOLVE_DLL_REFERENCES = 1
Global Const $LOAD_LIBRARY_AS_DATAFILE = 2
Global Const $LOAD_WITH_ALTERED_SEARCH_PATH = 8
Global Const $OBJID_WINDOW = 0
Global Const $OBJID_TITLEBAR = -2
Global Const $OBJID_SIZEGRIP = -7
Global Const $OBJID_CARET = -8
Global Const $OBJID_CURSOR = -9
Global Const $OBJID_ALERT = -10
Global Const $OBJID_SOUND = -11
Global Const $VK_DOWN = 40
Global Const $VK_END = 35
Global Const $VK_HOME = 36
Global Const $VK_LEFT = 37
Global Const $VK_NEXT = 34
Global Const $VK_PRIOR = 33
Global Const $VK_RIGHT = 39
Global Const $VK_UP = 38
Global Const $VK_LBUTTON = 1
Global Const $VK_RBUTTON = 2
Global Const $VK_MBUTTON = 4
Global Const $MB_OK = 0
Global Const $MB_OKCANCEL = 1
Global Const $MB_ABORTRETRYIGNORE = 2
Global Const $MB_YESNOCANCEL = 3
Global Const $MB_YESNO = 4
Global Const $MB_RETRYCANCEL = 5
Global Const $MB_ICONHAND = 16
Global Const $MB_ICONQUESTION = 32
Global Const $MB_ICONEXCLAMATION = 48
Global Const $MB_ICONASTERISK = 64
Global Const $MB_DEFBUTTON1 = 0
Global Const $MB_DEFBUTTON2 = 256
Global Const $MB_DEFBUTTON3 = 512
Global Const $MB_APPLMODAL = 0
Global Const $MB_SYSTEMMODAL = 4096
Global Const $MB_TASKMODAL = 8192
Global Const $MB_TOPMOST = 262144
Global Const $MB_RIGHTJUSTIFIED = 524288
Global Const $IDTIMEOUT = -1
Global Const $IDOK = 1
Global Const $IDCANCEL = 2
Global Const $IDABORT = 3
Global Const $IDRETRY = 4
Global Const $IDIGNORE = 5
Global Const $IDYES = 6
Global Const $IDNO = 7
Global Const $IDTRYAGAIN = 10
Global Const $IDCONTINUE = 11
Global Const $DLG_NOTITLE = 1
Global Const $DLG_NOTONTOP = 2
Global Const $DLG_TEXTLEFT = 4
Global Const $DLG_TEXTRIGHT = 8
Global Const $DLG_MOVEABLE = 16
Global Const $DLG_TEXTVCENTER = 32
Global Const $TIP_ICONNONE = 0
Global Const $TIP_ICONASTERISK = 1
Global Const $TIP_ICONEXCLAMATION = 2
Global Const $TIP_ICONHAND = 3
Global Const $TIP_NOSOUND = 16
Global Const $IDC_UNKNOWN = 0
Global Const $IDC_APPSTARTING = 1
Global Const $IDC_ARROW = 2
Global Const $IDC_CROSS = 3
Global Const $IDC_HAND = 32649
Global Const $IDC_HELP = 4
Global Const $IDC_IBEAM = 5
Global Const $IDC_ICON = 6
Global Const $IDC_NO = 7
Global Const $IDC_SIZE = 8
Global Const $IDC_SIZEALL = 9
Global Const $IDC_SIZENESW = 10
Global Const $IDC_SIZENS = 11
Global Const $IDC_SIZENWSE = 12
Global Const $IDC_SIZEWE = 13
Global Const $IDC_UPARROW = 14
Global Const $IDC_WAIT = 15
Global Const $IDI_APPLICATION = 32512
Global Const $IDI_ASTERISK = 32516
Global Const $IDI_EXCLAMATION = 32515
Global Const $IDI_HAND = 32513
Global Const $IDI_QUESTION = 32514
Global Const $IDI_WINLOGO = 32517
Global Const $SD_LOGOFF = 0
Global Const $SD_SHUTDOWN = 1
Global Const $SD_REBOOT = 2
Global Const $SD_FORCE = 4
Global Const $SD_POWERDOWN = 8
Global Const $STR_NOCASESENSE = 0
Global Const $STR_CASESENSE = 1
Global Const $STR_STRIPLEADING = 1
Global Const $STR_STRIPTRAILING = 2
Global Const $STR_STRIPSPACES = 4
Global Const $STR_STRIPALL = 8
Global Const $TRAY_ITEM_EXIT = 3
Global Const $TRAY_ITEM_PAUSE = 4
Global Const $TRAY_ITEM_FIRST = 7
Global Const $TRAY_CHECKED = 1
Global Const $TRAY_UNCHECKED = 4
Global Const $TRAY_ENABLE = 64
Global Const $TRAY_DISABLE = 128
Global Const $TRAY_FOCUS = 256
Global Const $TRAY_DEFAULT = 512
Global Const $TRAY_EVENT_SHOWICON = -3
Global Const $TRAY_EVENT_HIDEICON = -4
Global Const $TRAY_EVENT_FLASHICON = -5
Global Const $TRAY_EVENT_NOFLASHICON = -6
Global Const $TRAY_EVENT_PRIMARYDOWN = -7
Global Const $TRAY_EVENT_PRIMARYUP = -8
Global Const $TRAY_EVENT_SECONDARYDOWN = -9
Global Const $TRAY_EVENT_SECONDARYUP = -10
Global Const $TRAY_EVENT_MOUSEOVER = -11
Global Const $TRAY_EVENT_MOUSEOUT = -12
Global Const $TRAY_EVENT_PRIMARYDOUBLE = -13
Global Const $TRAY_EVENT_SECONDARYDOUBLE = -14
Global Const $STDIN_CHILD = 1
Global Const $STDOUT_CHILD = 2
Global Const $STDERR_CHILD = 4
Global Const $STDERR_MERGED = 8
Global Const $STDIO_INHERIT_PARENT = 16
Global Const $RUN_CREATE_NEW_CONSOLE = 65536
Global Const $MOUSEEVENTF_ABSOLUTE = 32768
Global Const $MOUSEEVENTF_MOVE = 1
Global Const $MOUSEEVENTF_LEFTDOWN = 2
Global Const $MOUSEEVENTF_LEFTUP = 4
Global Const $MOUSEEVENTF_RIGHTDOWN = 8
Global Const $MOUSEEVENTF_RIGHTUP = 16
Global Const $MOUSEEVENTF_MIDDLEDOWN = 32
Global Const $MOUSEEVENTF_MIDDLEUP = 64
Global Const $MOUSEEVENTF_WHEEL = 2048
Global Const $MOUSEEVENTF_XDOWN = 128
Global Const $MOUSEEVENTF_XUP = 256
Global Const $REG_NONE = 0
Global Const $REG_SZ = 1
Global Const $REG_EXPAND_SZ = 2
Global Const $REG_BINARY = 3
Global Const $REG_DWORD = 4
Global Const $REG_DWORD_BIG_ENDIAN = 5
Global Const $REG_LINK = 6
Global Const $REG_MULTI_SZ = 7
Global Const $REG_RESOURCE_LIST = 8
Global Const $REG_FULL_RESOURCE_DESCRIPTOR = 9
Global Const $REG_RESOURCE_REQUIREMENTS_LIST = 10
Global Const $HWND_BOTTOM = 1
Global Const $HWND_NOTOPMOST = -2
Global Const $HWND_TOP = 0
Global Const $HWND_TOPMOST = -1
Global Const $SWP_NOSIZE = 1
Global Const $SWP_NOMOVE = 2
Global Const $SWP_NOZORDER = 4
Global Const $SWP_NOREDRAW = 8
Global Const $SWP_NOACTIVATE = 16
Global Const $SWP_FRAMECHANGED = 32
Global Const $SWP_DRAWFRAME = 32
Global Const $SWP_SHOWWINDOW = 64
Global Const $SWP_HIDEWINDOW = 128
Global Const $SWP_NOCOPYBITS = 256
Global Const $SWP_NOOWNERZORDER = 512
Global Const $SWP_NOREPOSITION = 512
Global Const $SWP_NOSENDCHANGING = 1024
Global Const $SWP_DEFERERASE = 8192
Global Const $SWP_ASYNCWINDOWPOS = 16384
Global Const $LANG_AFRIKAANS = 54
Global Const $LANG_ALBANIAN = 28
Global Const $LANG_ARABIC = 1
Global Const $LANG_ARMENIAN = 43
Global Const $LANG_ASSAMESE = 77
Global Const $LANG_AZERI = 44
Global Const $LANG_BASQUE = 45
Global Const $LANG_BELARUSIAN = 35
Global Const $LANG_BENGALI = 69
Global Const $LANG_BULGARIAN = 2
Global Const $LANG_CATALAN = 3
Global Const $LANG_CHINESE = 4
Global Const $LANG_CROATIAN = 26
Global Const $LANG_CZECH = 5
Global Const $LANG_DANISH = 6
Global Const $LANG_DUTCH = 19
Global Const $LANG_ENGLISH = 9
Global Const $LANG_ESTONIAN = 37
Global Const $LANG_FAEROESE = 56
Global Const $LANG_FARSI = 41
Global Const $LANG_FINNISH = 11
Global Const $LANG_FRENCH = 156
Global Const $LANG_GEORGIAN = 55
Global Const $LANG_GERMAN = 7
Global Const $LANG_GREEK = 8
Global Const $LANG_GUJARATI = 71
Global Const $LANG_HEBREW = 13
Global Const $LANG_HINDI = 57
Global Const $LANG_HUNGARIAN = 14
Global Const $LANG_ICELANDIC = 15
Global Const $LANG_INDONESIAN = 33
Global Const $LANG_ITALIAN = 16
Global Const $LANG_JAPANESE = 17
Global Const $LANG_KANNADA = 75
Global Const $LANG_KASHMIRI = 96
Global Const $LANG_KAZAK = 63
Global Const $LANG_KONKANI = 87
Global Const $LANG_KOREAN = 18
Global Const $LANG_LATVIAN = 38
Global Const $LANG_LITHUANIAN = 39
Global Const $LANG_MACEDONIAN = 47
Global Const $LANG_MALAY = 62
Global Const $LANG_MALAYALAM = 76
Global Const $LANG_MANIPURI = 88
Global Const $LANG_MARATHI = 78
Global Const $LANG_NEPALI = 97
Global Const $LANG_NEUTRAL = 0
Global Const $LANG_NORWEGIAN = 20
Global Const $LANG_ORIYA = 72
Global Const $LANG_POLISH = 21
Global Const $LANG_PORTUGUESE = 22
Global Const $LANG_PUNJABI = 70
Global Const $LANG_ROMANIAN = 24
Global Const $LANG_RUSSIAN = 25
Global Const $LANG_SANSKRIT = 79
Global Const $LANG_SERBIAN = 26
Global Const $LANG_SINDHI = 89
Global Const $LANG_SLOVAK = 27
Global Const $LANG_SLOVENIAN = 36
Global Const $LANG_SPANISH = 10
Global Const $LANG_SWAHILI = 65
Global Const $LANG_SWEDISH = 29
Global Const $LANG_TAMIL = 73
Global Const $LANG_TATAR = 68
Global Const $LANG_TELUGU = 74
Global Const $LANG_THAI = 30
Global Const $LANG_TURKISH = 31
Global Const $LANG_UKRAINIAN = 34
Global Const $LANG_URDU = 32
Global Const $LANG_UZBEK = 67
Global Const $LANG_VIETNAMESE = 42
Global Const $SUBLANG_ARABIC_ALGERIA = 5
Global Const $SUBLANG_ARABIC_BAHRAIN = 15
Global Const $SUBLANG_ARABIC_EGYPT = 3
Global Const $SUBLANG_ARABIC_IRAQ = 2
Global Const $SUBLANG_ARABIC_JORDAN = 11
Global Const $SUBLANG_ARABIC_KUWAIT = 13
Global Const $SUBLANG_ARABIC_LEBANON = 12
Global Const $SUBLANG_ARABIC_LIBYA = 4
Global Const $SUBLANG_ARABIC_MOROCCO = 6
Global Const $SUBLANG_ARABIC_OMAN = 8
Global Const $SUBLANG_ARABIC_QATAR = 16
Global Const $SUBLANG_ARABIC_SAUDI_ARABIA = 1
Global Const $SUBLANG_ARABIC_SYRIA = 10
Global Const $SUBLANG_ARABIC_TUNISIA = 7
Global Const $SUBLANG_ARABIC_UAE = 14
Global Const $SUBLANG_ARABIC_YEMEN = 9
Global Const $SUBLANG_AZERI_CYRILLIC = 2
Global Const $SUBLANG_AZERI_LATIN = 1
Global Const $SUBLANG_CHINESE_HONGKONG = 3
Global Const $SUBLANG_CHINESE_MACAU = 5
Global Const $SUBLANG_CHINESE_SIMPLIFIED = 2
Global Const $SUBLANG_CHINESE_SINGAPORE = 4
Global Const $SUBLANG_CHINESE_TRADITIONAL = 1
Global Const $SUBLANG_DEFAULT = 1
Global Const $SUBLANG_DUTCH = 1
Global Const $SUBLANG_DUTCH_BELGIAN = 2
Global Const $SUBLANG_ENGLISH_AUS = 3
Global Const $SUBLANG_ENGLISH_BELIZE = 10
Global Const $SUBLANG_ENGLISH_CAN = 4
Global Const $SUBLANG_ENGLISH_CARIBBEAN = 9
Global Const $SUBLANG_ENGLISH_EIRE = 6
Global Const $SUBLANG_ENGLISH_JAMAICA = 8
Global Const $SUBLANG_ENGLISH_NZ = 5
Global Const $SUBLANG_ENGLISH_PHILIPPINES = 13
Global Const $SUBLANG_ENGLISH_SOUTH_AFRICA = 7
Global Const $SUBLANG_ENGLISH_TRINIDAD = 11
Global Const $SUBLANG_ENGLISH_UK = 2
Global Const $SUBLANG_ENGLISH_US = 1
Global Const $SUBLANG_ENGLISH_ZIMBABWE = 12
Global Const $SUBLANG_FRENCH = 1
Global Const $SUBLANG_FRENCH_BELGIAN = 2
Global Const $SUBLANG_FRENCH_CANADIAN = 3
Global Const $SUBLANG_FRENCH_LUXEMBOURG = 5
Global Const $SUBLANG_FRENCH_MONACO = 6
Global Const $SUBLANG_FRENCH_SWISS = 4
Global Const $SUBLANG_GERMAN = 1
Global Const $SUBLANG_GERMAN_AUSTRIAN = 3
Global Const $SUBLANG_GERMAN_LIECHTENSTEIN = 5
Global Const $SUBLANG_GERMAN_LUXEMBOURG = 4
Global Const $SUBLANG_GERMAN_SWISS = 2
Global Const $SUBLANG_ITALIAN = 1
Global Const $SUBLANG_ITALIAN_SWISS = 2
Global Const $SUBLANG_KASHMIRI_INDIA = 2
Global Const $SUBLANG_KOREAN = 1
Global Const $SUBLANG_LITHUANIAN = 1
Global Const $SUBLANG_MALAY_BRUNEI_DARUSSALAM = 2
Global Const $SUBLANG_MALAY_MALAYSIA = 1
Global Const $SUBLANG_NEPALI_INDIA = 2
Global Const $SUBLANG_NEUTRAL = 0
Global Const $SUBLANG_NORWEGIAN_BOKMAL = 1
Global Const $SUBLANG_NORWEGIAN_NYNORSK = 2
Global Const $SUBLANG_PORTUGUESE = 2
Global Const $SUBLANG_PORTUGUESE_BRAZILIAN = 1
Global Const $SUBLANG_SERBIAN_CYRILLIC = 3
Global Const $SUBLANG_SERBIAN_LATIN = 2
Global Const $SUBLANG_SPANISH = 1
Global Const $SUBLANG_SPANISH_ARGENTINA = 11
Global Const $SUBLANG_SPANISH_BOLIVIA = 16
Global Const $SUBLANG_SPANISH_CHILE = 13
Global Const $SUBLANG_SPANISH_COLOMBIA = 9
Global Const $SUBLANG_SPANISH_COSTA_RICA = 5
Global Const $SUBLANG_SPANISH_DOMINICAN_REPUBLIC = 7
Global Const $SUBLANG_SPANISH_ECUADOR = 12
Global Const $SUBLANG_SPANISH_EL_SALVADOR = 17
Global Const $SUBLANG_SPANISH_GUATEMALA = 4
Global Const $SUBLANG_SPANISH_HONDURAS = 18
Global Const $SUBLANG_SPANISH_MEXICAN = 2
Global Const $SUBLANG_SPANISH_MODERN = 3
Global Const $SUBLANG_SPANISH_NICARAGUA = 19
Global Const $SUBLANG_SPANISH_PANAMA = 6
Global Const $SUBLANG_SPANISH_PARAGUAY = 15
Global Const $SUBLANG_SPANISH_PERU = 10
Global Const $SUBLANG_SPANISH_PUERTO_RICO = 20
Global Const $SUBLANG_SPANISH_URUGUAY = 14
Global Const $SUBLANG_SPANISH_VENEZUELA = 8
Global Const $SUBLANG_SWEDISH = 1
Global Const $SUBLANG_SWEDISH_FINLAND = 2
Global Const $SUBLANG_SYS_DEFAULT = 2
Global Const $SUBLANG_URDU_INDIA = 2
Global Const $SUBLANG_URDU_PAKISTAN = 1
Global Const $SUBLANG_UZBEK_CYRILLIC = 2
Global Const $SORT_DEFAULT = 0
Global Const $SORT_JAPANESE_XJIS = 0
Global Const $SORT_JAPANESE_UNICODE = 1
Global Const $SORT_CHINESE_BIG5 = 0
Global Const $SORT_CHINESE_PRCP = 0
Global Const $SORT_CHINESE_UNICODE = 1
Global Const $SORT_CHINESE_PRC = 2
Global Const $SORT_KOREAN_KSC = 0
Global Const $SORT_KOREAN_UNICODE = 1
Global Const $SORT_GERMAN_PHONE_BOOK = 1
Global Const $SORT_HUNGARIAN_DEFAULT = 0
Global Const $SORT_HUNGARIAN_TECHNICAL = 1
Global Const $SORT_GEORGIAN_TRADITIONAL = 0
Global Const $SORT_GEORGIAN_MODERN = 1
Global Const $GDIP_DASHCAPFLAT = 0
Global Const $GDIP_DASHCAPROUND = 2
Global Const $GDIP_DASHCAPTRIANGLE = 3
Global Const $GDIP_DASHSTYLESOLID = 0
Global Const $GDIP_DASHSTYLEDASH = 1
Global Const $GDIP_DASHSTYLEDOT = 2
Global Const $GDIP_DASHSTYLEDASHDOT = 3
Global Const $GDIP_DASHSTYLEDASHDOTDOT = 4
Global Const $GDIP_DASHSTYLECUSTOM = 5
Global Const $GDIP_EPGCHROMINANCETABLE = "{F2E455DC-09B3-4316-8260-676ADA32481C}"
Global Const $GDIP_EPGCOLORDEPTH = "{66087055-AD66-4C7C-9A18-38A2310B8337}"
Global Const $GDIP_EPGCOMPRESSION = "{E09D739D-CCD4-44EE-8EBA-3FBF8BE4FC58}"
Global Const $GDIP_EPGLUMINANCETABLE = "{EDB33BCE-0266-4A77-B904-27216099E717}"
Global Const $GDIP_EPGQUALITY = "{1D5BE4B5-FA4A-452D-9CDD-5DB35105E7EB}"
Global Const $GDIP_EPGRENDERMETHOD = "{6D42C53A-229A-4825-8BB7-5C99E2B9A8B8}"
Global Const $GDIP_EPGSAVEFLAG = "{292266FC-AC40-47BF-8CFC-A85B89A655DE}"
Global Const $GDIP_EPGSCANMETHOD = "{3A4E2661-3109-4E56-8536-42C156E7DCFA}"
Global Const $GDIP_EPGTRANSFORMATION = "{8D0EB2D1-A58E-4EA8-AA14-108074B7B6F9}"
Global Const $GDIP_EPGVERSION = "{24D18C76-814A-41A4-BF53-1C219CCCF797}"
Global Const $GDIP_EPTBYTE = 1
Global Const $GDIP_EPTASCII = 2
Global Const $GDIP_EPTSHORT = 3
Global Const $GDIP_EPTLONG = 4
Global Const $GDIP_EPTRATIONAL = 5
Global Const $GDIP_EPTLONGRANGE = 6
Global Const $GDIP_EPTUNDEFINED = 7
Global Const $GDIP_EPTRATIONALRANGE = 8
Global Const $GDIP_ERROK = 0
Global Const $GDIP_ERRGENERICERROR = 1
Global Const $GDIP_ERRINVALIDPARAMETER = 2
Global Const $GDIP_ERROUTOFMEMORY = 3
Global Const $GDIP_ERROBJECTBUSY = 4
Global Const $GDIP_ERRINSUFFICIENTBUFFER = 5
Global Const $GDIP_ERRNOTIMPLEMENTED = 6
Global Const $GDIP_ERRWIN32ERROR = 7
Global Const $GDIP_ERRWRONGSTATE = 8
Global Const $GDIP_ERRABORTED = 9
Global Const $GDIP_ERRFILENOTFOUND = 10
Global Const $GDIP_ERRVALUEOVERFLOW = 11
Global Const $GDIP_ERRACCESSDENIED = 12
Global Const $GDIP_ERRUNKNOWNIMAGEFORMAT = 13
Global Const $GDIP_ERRFONTFAMILYNOTFOUND = 14
Global Const $GDIP_ERRFONTSTYLENOTFOUND = 15
Global Const $GDIP_ERRNOTTRUETYPEFONT = 16
Global Const $GDIP_ERRUNSUPPORTEDGDIVERSION = 17
Global Const $GDIP_ERRGDIPLUSNOTINITIALIZED = 18
Global Const $GDIP_ERRPROPERTYNOTFOUND = 19
Global Const $GDIP_ERRPROPERTYNOTSUPPORTED = 20
Global Const $GDIP_EVTCOMPRESSIONLZW = 2
Global Const $GDIP_EVTCOMPRESSIONCCITT3 = 3
Global Const $GDIP_EVTCOMPRESSIONCCITT4 = 4
Global Const $GDIP_EVTCOMPRESSIONRLE = 5
Global Const $GDIP_EVTCOMPRESSIONNONE = 6
Global Const $GDIP_EVTTRANSFORMROTATE90 = 13
Global Const $GDIP_EVTTRANSFORMROTATE180 = 14
Global Const $GDIP_EVTTRANSFORMROTATE270 = 15
Global Const $GDIP_EVTTRANSFORMFLIPHORIZONTAL = 16
Global Const $GDIP_EVTTRANSFORMFLIPVERTICAL = 17
Global Const $GDIP_EVTMULTIFRAME = 18
Global Const $GDIP_EVTLASTFRAME = 19
Global Const $GDIP_EVTFLUSH = 20
Global Const $GDIP_EVTFRAMEDIMENSIONPAGE = 23
Global Const $GDIP_ICFENCODER = 1
Global Const $GDIP_ICFDECODER = 2
Global Const $GDIP_ICFSUPPORTBITMAP = 4
Global Const $GDIP_ICFSUPPORTVECTOR = 8
Global Const $GDIP_ICFSEEKABLEENCODE = 16
Global Const $GDIP_ICFBLOCKINGDECODE = 32
Global Const $GDIP_ICFBUILTIN = 65536
Global Const $GDIP_ICFSYSTEM = 131072
Global Const $GDIP_ICFUSER = 262144
Global Const $GDIP_ILMREAD = 1
Global Const $GDIP_ILMWRITE = 2
Global Const $GDIP_ILMUSERINPUTBUF = 4
Global Const $GDIP_LINECAPFLAT = 0
Global Const $GDIP_LINECAPSQUARE = 1
Global Const $GDIP_LINECAPROUND = 2
Global Const $GDIP_LINECAPTRIANGLE = 3
Global Const $GDIP_LINECAPNOANCHOR = 16
Global Const $GDIP_LINECAPSQUAREANCHOR = 17
Global Const $GDIP_LINECAPROUNDANCHOR = 18
Global Const $GDIP_LINECAPDIAMONDANCHOR = 19
Global Const $GDIP_LINECAPARROWANCHOR = 20
Global Const $GDIP_LINECAPCUSTOM = 255
Global Const $GDIP_PXF01INDEXED = 196865
Global Const $GDIP_PXF04INDEXED = 197634
Global Const $GDIP_PXF08INDEXED = 198659
Global Const $GDIP_PXF16GRAYSCALE = 1052676
Global Const $GDIP_PXF16RGB555 = 135173
Global Const $GDIP_PXF16RGB565 = 135174
Global Const $GDIP_PXF16ARGB1555 = 397319
Global Const $GDIP_PXF24RGB = 137224
Global Const $GDIP_PXF32RGB = 139273
Global Const $GDIP_PXF32ARGB = 2498570
Global Const $GDIP_PXF32PARGB = 860171
Global Const $GDIP_PXF48RGB = 1060876
Global Const $GDIP_PXF64ARGB = 3424269
Global Const $GDIP_PXF64PARGB = 1851406
Global Const $GDIP_IMAGEFORMAT_UNDEFINED = "{B96B3CA9-0728-11D3-9D7B-0000F81EF32E}"
Global Const $GDIP_IMAGEFORMAT_MEMORYBMP = "{B96B3CAA-0728-11D3-9D7B-0000F81EF32E}"
Global Const $GDIP_IMAGEFORMAT_BMP = "{B96B3CAB-0728-11D3-9D7B-0000F81EF32E}"
Global Const $GDIP_IMAGEFORMAT_EMF = "{B96B3CAC-0728-11D3-9D7B-0000F81EF32E}"
Global Const $GDIP_IMAGEFORMAT_WMF = "{B96B3CAD-0728-11D3-9D7B-0000F81EF32E}"
Global Const $GDIP_IMAGEFORMAT_JPEG = "{B96B3CAE-0728-11D3-9D7B-0000F81EF32E}"
Global Const $GDIP_IMAGEFORMAT_PNG = "{B96B3CAF-0728-11D3-9D7B-0000F81EF32E}"
Global Const $GDIP_IMAGEFORMAT_GIF = "{B96B3CB0-0728-11D3-9D7B-0000F81EF32E}"
Global Const $GDIP_IMAGEFORMAT_TIFF = "{B96B3CB1-0728-11D3-9D7B-0000F81EF32E}"
Global Const $GDIP_IMAGEFORMAT_EXIF = "{B96B3CB2-0728-11D3-9D7B-0000F81EF32E}"
Global Const $GDIP_IMAGEFORMAT_ICON = "{B96B3CB5-0728-11D3-9D7B-0000F81EF32E}"
Global Const $GDIP_IMAGETYPE_UNKNOWN = 0
Global Const $GDIP_IMAGETYPE_BITMAP = 1
Global Const $GDIP_IMAGETYPE_METAFILE = 2
Global Const $GDIP_IMAGEFLAGS_NONE = 0
Global Const $GDIP_IMAGEFLAGS_SCALABLE = 1
Global Const $GDIP_IMAGEFLAGS_HASALPHA = 2
Global Const $GDIP_IMAGEFLAGS_HASTRANSLUCENT = 4
Global Const $GDIP_IMAGEFLAGS_PARTIALLYSCALABLE = 8
Global Const $GDIP_IMAGEFLAGS_COLORSPACE_RGB = 16
Global Const $GDIP_IMAGEFLAGS_COLORSPACE_CMYK = 32
Global Const $GDIP_IMAGEFLAGS_COLORSPACE_GRAY = 64
Global Const $GDIP_IMAGEFLAGS_COLORSPACE_YCBCR = 128
Global Const $GDIP_IMAGEFLAGS_COLORSPACE_YCCK = 256
Global Const $GDIP_IMAGEFLAGS_HASREALDPI = 4096
Global Const $GDIP_IMAGEFLAGS_HASREALPIXELSIZE = 8192
Global Const $GDIP_IMAGEFLAGS_READONLY = 65536
Global Const $GDIP_IMAGEFLAGS_CACHING = 131072
Global $GHGDIPBRUSH = 0
Global $GHGDIPDLL = 0
Global $GHGDIPPEN = 0
Global $GIGDIPREF = 0
Global $GIGDIPTOKEN = 0
Func _GDIPLUS_ARROWCAPCREATE($FHEIGHT, $FWIDTH, $BFILLED = True)
	Local $ARESULT = DllCall($GHGDIPDLL, "int", "GdipCreateAdjustableArrowCap", "float", $FHEIGHT, "float", $FWIDTH, "bool", $BFILLED, "ptr*", 0)
	If @error Then Return SetError(@error, @extended, 0)
	Return SetExtended($ARESULT[0], $ARESULT[4])
EndFunc
Func _GDIPLUS_ARROWCAPDISPOSE($HCAP)
	Local $ARESULT = DllCall($GHGDIPDLL, "int", "GdipDeleteCustomLineCap", "handle", $HCAP)
	If @error Then Return SetError(@error, @extended, False)
	Return $ARESULT[0] = 0
EndFunc
Func _GDIPLUS_ARROWCAPGETFILLSTATE($HARROWCAP)
	Local $ARESULT = DllCall($GHGDIPDLL, "int", "GdipGetAdjustableArrowCapFillState", "handle", $HARROWCAP, "bool*", 0)
	If @error Then Return SetError(@error, @extended, False)
	Return $ARESULT[0] = 0
EndFunc
Func _GDIPLUS_ARROWCAPGETHEIGHT($HARROWCAP)
	Local $ARESULT = DllCall($GHGDIPDLL, "int", "GdipGetAdjustableArrowCapHeight", "handle", $HARROWCAP, "float*", 0)
	If @error Then Return SetError(@error, @extended, 0)
	Return SetExtended($ARESULT[0], $ARESULT[2])
EndFunc
Func _GDIPLUS_ARROWCAPGETMIDDLEINSET($HARROWCAP)
	Local $ARESULT = DllCall($GHGDIPDLL, "int", "GdipGetAdjustableArrowCapMiddleInset", "handle", $HARROWCAP, "float*", 0)
	If @error Then Return SetError(@error, @extended, 0)
	Return SetExtended($ARESULT[0], $ARESULT[2])
EndFunc
Func _GDIPLUS_ARROWCAPGETWIDTH($HARROWCAP)
	Local $ARESULT = DllCall($GHGDIPDLL, "int", "GdipGetAdjustableArrowCapWidth", "handle", $HARROWCAP, "float*", 0)
	If @error Then Return SetError(@error, @extended, 0)
	Return SetExtended($ARESULT[0], $ARESULT[2])
EndFunc
Func _GDIPLUS_ARROWCAPSETFILLSTATE($HARROWCAP, $BFILLED = True)
	Local $ARESULT = DllCall($GHGDIPDLL, "int", "GdipSetAdjustableArrowCapFillState", "handle", $HARROWCAP, "bool", $BFILLED)
	If @error Then Return SetError(@error, @extended, False)
	Return $ARESULT[0] = 0
EndFunc
Func _GDIPLUS_ARROWCAPSETHEIGHT($HARROWCAP, $FHEIGHT)
	Local $ARESULT = DllCall($GHGDIPDLL, "int", "GdipSetAdjustableArrowCapHeight", "handle", $HARROWCAP, "float", $FHEIGHT)
	If @error Then Return SetError(@error, @extended, False)
	Return $ARESULT[0] = 0
EndFunc
Func _GDIPLUS_ARROWCAPSETMIDDLEINSET($HARROWCAP, $FINSET)
	Local $ARESULT = DllCall($GHGDIPDLL, "int", "GdipSetAdjustableArrowCapMiddleInset", "handle", $HARROWCAP, "float", $FINSET)
	If @error Then Return SetError(@error, @extended, False)
	Return $ARESULT[0] = 0
EndFunc
Func _GDIPLUS_ARROWCAPSETWIDTH($HARROWCAP, $FWIDTH)
	Local $ARESULT = DllCall($GHGDIPDLL, "int", "GdipSetAdjustableArrowCapWidth", "handle", $HARROWCAP, "float", $FWIDTH)
	If @error Then Return SetError(@error, @extended, False)
	Return $ARESULT[0] = 0
EndFunc
Func _GDIPLUS_BITMAPCLONEAREA($HBMP, $ILEFT, $ITOP, $IWIDTH, $IHEIGHT, $IFORMAT = 137224)
	Local $ARESULT = DllCall($GHGDIPDLL, "int", "GdipCloneBitmapAreaI", "int", $ILEFT, "int", $ITOP, "int", $IWIDTH, "int", $IHEIGHT, "int", $IFORMAT, "handle", $HBMP, "ptr*", 0)
	If @error Then Return SetError(@error, @extended, 0)
	Return SetExtended($ARESULT[0], $ARESULT[7])
EndFunc
Func _GDIPLUS_BITMAPCREATEFROMFILE($SFILENAME)
	Local $ARESULT = DllCall($GHGDIPDLL, "int", "GdipCreateBitmapFromFile", "wstr", $SFILENAME, "ptr*", 0)
	If @error Then Return SetError(@error, @extended, 0)
	Return SetExtended($ARESULT[0], $ARESULT[2])
EndFunc
Func _GDIPLUS_BITMAPCREATEFROMGRAPHICS($IWIDTH, $IHEIGHT, $HGRAPHICS)
	Local $ARESULT = DllCall($GHGDIPDLL, "int", "GdipCreateBitmapFromGraphics", "int", $IWIDTH, "int", $IHEIGHT, "handle", $HGRAPHICS, "ptr*", 0)
	If @error Then Return SetError(@error, @extended, 0)
	Return SetExtended($ARESULT[0], $ARESULT[4])
EndFunc
Func _GDIPLUS_BITMAPCREATEFROMHBITMAP($HBMP, $HPAL = 0)
	Local $ARESULT = DllCall($GHGDIPDLL, "int", "GdipCreateBitmapFromHBITMAP", "handle", $HBMP, "handle", $HPAL, "ptr*", 0)
	If @error Then Return SetError(@error, @extended, 0)
	Return SetExtended($ARESULT[0], $ARESULT[3])
EndFunc
Func _GDIPLUS_BITMAPCREATEHBITMAPFROMBITMAP($HBITMAP, $IARGB = -16777216)
	Local $ARESULT = DllCall($GHGDIPDLL, "int", "GdipCreateHBITMAPFromBitmap", "handle", $HBITMAP, "ptr*", 0, "dword", $IARGB)
	If @error Then Return SetError(@error, @extended, 0)
	Return SetExtended($ARESULT[0], $ARESULT[2])
EndFunc
Func _GDIPLUS_BITMAPDISPOSE($HBITMAP)
	Local $ARESULT = DllCall($GHGDIPDLL, "int", "GdipDisposeImage", "handle", $HBITMAP)
	If @error Then Return SetError(@error, @extended, False)
	Return $ARESULT[0] = 0
EndFunc
Func _GDIPLUS_BITMAPLOCKBITS($HBITMAP, $ILEFT, $ITOP, $IWIDTH, $IHEIGHT, $IFLAGS = $GDIP_ILMREAD, $IFORMAT = $GDIP_PXF32RGB)
	Local $TDATA = DllStructCreate($TAGGDIPBITMAPDATA)
	Local $TRECT = DllStructCreate($TAGRECT)
	DllStructSetData($TRECT, "Left", $ILEFT)
	DllStructSetData($TRECT, "Top", $ITOP)
	DllStructSetData($TRECT, "Right", $IWIDTH)
	DllStructSetData($TRECT, "Bottom", $IHEIGHT)
	Local $ARESULT = DllCall($GHGDIPDLL, "int", "GdipBitmapLockBits", "handle", $HBITMAP, "struct*", $TRECT, "uint", $IFLAGS, "int", $IFORMAT, "struct*", $TDATA)
	If @error Then Return SetError(@error, @extended, 0)
	Return SetExtended($ARESULT[0], $TDATA)
EndFunc
Func _GDIPLUS_BITMAPUNLOCKBITS($HBITMAP, $TBITMAPDATA)
	Local $ARESULT = DllCall($GHGDIPDLL, "int", "GdipBitmapUnlockBits", "handle", $HBITMAP, "struct*", $TBITMAPDATA)
	If @error Then Return SetError(@error, @extended, False)
	Return $ARESULT[0] = 0
EndFunc
Func _GDIPLUS_BRUSHCLONE($HBRUSH)
	Local $ARESULT = DllCall($GHGDIPDLL, "int", "GdipCloneBrush", "handle", $HBRUSH, "ptr*", 0)
	If @error Then Return SetError(@error, @extended, 0)
	Return SetExtended($ARESULT[0], $ARESULT[2])
EndFunc
Func _GDIPLUS_BRUSHCREATESOLID($IARGB = -16777216)
	Local $ARESULT = DllCall($GHGDIPDLL, "int", "GdipCreateSolidFill", "int", $IARGB, "ptr*", 0)
	If @error Then Return SetError(@error, @extended, 0)
	Return SetExtended($ARESULT[0], $ARESULT[2])
EndFunc
Func _GDIPLUS_BRUSHDISPOSE($HBRUSH)
	Local $ARESULT = DllCall($GHGDIPDLL, "int", "GdipDeleteBrush", "handle", $HBRUSH)
	If @error Then Return SetError(@error, @extended, False)
	Return $ARESULT[0] = 0
EndFunc
Func _GDIPLUS_BRUSHGETSOLIDCOLOR($HBRUSH)
	Local $ARESULT = DllCall($GHGDIPDLL, "int", "GdipGetSolidFillColor", "handle", $HBRUSH, "dword*", 0)
	If @error Then Return SetError(@error, @extended, -1)
	Return SetExtended($ARESULT[0], $ARESULT[2])
EndFunc
Func _GDIPLUS_BRUSHGETTYPE($HBRUSH)
	Local $ARESULT = DllCall($GHGDIPDLL, "int", "GdipGetBrushType", "handle", $HBRUSH, "int*", 0)
	If @error Then Return SetError(@error, @extended, -1)
	Return SetExtended($ARESULT[0], $ARESULT[2])
EndFunc
Func _GDIPLUS_BRUSHSETSOLIDCOLOR($HBRUSH, $IARGB = -16777216)
	Local $ARESULT = DllCall($GHGDIPDLL, "int", "GdipSetSolidFillColor", "handle", $HBRUSH, "dword", $IARGB)
	If @error Then Return SetError(@error, @extended, 0)
	Return $ARESULT[0] = 0
EndFunc
Func _GDIPLUS_CUSTOMLINECAPDISPOSE($HCAP)
	Local $ARESULT = DllCall($GHGDIPDLL, "int", "GdipDeleteCustomLineCap", "handle", $HCAP)
	If @error Then Return SetError(@error, @extended, False)
	Return $ARESULT[0] = 0
EndFunc
Func _GDIPLUS_DECODERS()
	Local $ICOUNT = _GDIPLUS_DECODERSGETCOUNT()
	Local $ISIZE = _GDIPLUS_DECODERSGETSIZE()
	Local $TBUFFER = DllStructCreate("byte[" & $ISIZE & "]")
	Local $ARESULT = DllCall($GHGDIPDLL, "int", "GdipGetImageDecoders", "uint", $ICOUNT, "uint", $ISIZE, "struct*", $TBUFFER)
	If @error Then Return SetError(@error, @extended, 0)
	If $ARESULT[0] <> 0 Then Return SetError($ARESULT[0], 0, 0)
	Local $PBUFFER = DllStructGetPtr($TBUFFER)
	Local $TCODEC, $AINFO[$ICOUNT + 1][14]
	$AINFO[0][0] = $ICOUNT
	For $II = 1 To $ICOUNT
		$TCODEC = DllStructCreate($TAGGDIPIMAGECODECINFO, $PBUFFER)
		$AINFO[$II][1] = _WINAPI_STRINGFROMGUID(DllStructGetPtr($TCODEC, "CLSID"))
		$AINFO[$II][2] = _WINAPI_STRINGFROMGUID(DllStructGetPtr($TCODEC, "FormatID"))
		$AINFO[$II][3] = _WINAPI_WIDECHARTOMULTIBYTE(DllStructGetData($TCODEC, "CodecName"))
		$AINFO[$II][4] = _WINAPI_WIDECHARTOMULTIBYTE(DllStructGetData($TCODEC, "DllName"))
		$AINFO[$II][5] = _WINAPI_WIDECHARTOMULTIBYTE(DllStructGetData($TCODEC, "FormatDesc"))
		$AINFO[$II][6] = _WINAPI_WIDECHARTOMULTIBYTE(DllStructGetData($TCODEC, "FileExt"))
		$AINFO[$II][7] = _WINAPI_WIDECHARTOMULTIBYTE(DllStructGetData($TCODEC, "MimeType"))
		$AINFO[$II][8] = DllStructGetData($TCODEC, "Flags")
		$AINFO[$II][9] = DllStructGetData($TCODEC, "Version")
		$AINFO[$II][10] = DllStructGetData($TCODEC, "SigCount")
		$AINFO[$II][11] = DllStructGetData($TCODEC, "SigSize")
		$AINFO[$II][12] = DllStructGetData($TCODEC, "SigPattern")
		$AINFO[$II][13] = DllStructGetData($TCODEC, "SigMask")
		$PBUFFER += DllStructGetSize($TCODEC)
	Next
	Return $AINFO
EndFunc
Func _GDIPLUS_DECODERSGETCOUNT()
	Local $ARESULT = DllCall($GHGDIPDLL, "int", "GdipGetImageDecodersSize", "uint*", 0, "uint*", 0)
	If @error Then Return SetError(@error, @extended, -1)
	Return SetExtended($ARESULT[0], $ARESULT[1])
EndFunc
Func _GDIPLUS_DECODERSGETSIZE()
	Local $ARESULT = DllCall($GHGDIPDLL, "int", "GdipGetImageDecodersSize", "uint*", 0, "uint*", 0)
	If @error Then Return SetError(@error, @extended, -1)
	Return SetExtended($ARESULT[0], $ARESULT[2])
EndFunc
Func _GDIPLUS_DRAWIMAGEPOINTS($HGRAPHIC, $HIMAGE, $NULX, $NULY, $NURX, $NURY, $NLLX, $NLLY, $COUNT = 3)
	Local $TPOINT = DllStructCreate("float X;float Y;float X2;float Y2;float X3;float Y3")
	DllStructSetData($TPOINT, "X", $NULX)
	DllStructSetData($TPOINT, "Y", $NULY)
	DllStructSetData($TPOINT, "X2", $NURX)
	DllStructSetData($TPOINT, "Y2", $NURY)
	DllStructSetData($TPOINT, "X3", $NLLX)
	DllStructSetData($TPOINT, "Y3", $NLLY)
	Local $ARESULT = DllCall($GHGDIPDLL, "int", "GdipDrawImagePoints", "handle", $HGRAPHIC, "handle", $HIMAGE, "struct*", $TPOINT, "int", $COUNT)
	If @error Then Return SetError(@error, @extended, False)
	Return $ARESULT[0] = 0
EndFunc
Func _GDIPLUS_ENCODERS()
	Local $ICOUNT = _GDIPLUS_ENCODERSGETCOUNT()
	Local $ISIZE = _GDIPLUS_ENCODERSGETSIZE()
	Local $TBUFFER = DllStructCreate("byte[" & $ISIZE & "]")
	Local $ARESULT = DllCall($GHGDIPDLL, "int", "GdipGetImageEncoders", "uint", $ICOUNT, "uint", $ISIZE, "struct*", $TBUFFER)
	If @error Then Return SetError(@error, @extended, 0)
	If $ARESULT[0] <> 0 Then Return SetError($ARESULT[0], 0, 0)
	Local $PBUFFER = DllStructGetPtr($TBUFFER)
	Local $TCODEC, $AINFO[$ICOUNT + 1][14]
	$AINFO[0][0] = $ICOUNT
	For $II = 1 To $ICOUNT
		$TCODEC = DllStructCreate($TAGGDIPIMAGECODECINFO, $PBUFFER)
		$AINFO[$II][1] = _WINAPI_STRINGFROMGUID(DllStructGetPtr($TCODEC, "CLSID"))
		$AINFO[$II][2] = _WINAPI_STRINGFROMGUID(DllStructGetPtr($TCODEC, "FormatID"))
		$AINFO[$II][3] = _WINAPI_WIDECHARTOMULTIBYTE(DllStructGetData($TCODEC, "CodecName"))
		$AINFO[$II][4] = _WINAPI_WIDECHARTOMULTIBYTE(DllStructGetData($TCODEC, "DllName"))
		$AINFO[$II][5] = _WINAPI_WIDECHARTOMULTIBYTE(DllStructGetData($TCODEC, "FormatDesc"))
		$AINFO[$II][6] = _WINAPI_WIDECHARTOMULTIBYTE(DllStructGetData($TCODEC, "FileExt"))
		$AINFO[$II][7] = _WINAPI_WIDECHARTOMULTIBYTE(DllStructGetData($TCODEC, "MimeType"))
		$AINFO[$II][8] = DllStructGetData($TCODEC, "Flags")
		$AINFO[$II][9] = DllStructGetData($TCODEC, "Version")
		$AINFO[$II][10] = DllStructGetData($TCODEC, "SigCount")
		$AINFO[$II][11] = DllStructGetData($TCODEC, "SigSize")
		$AINFO[$II][12] = DllStructGetData($TCODEC, "SigPattern")
		$AINFO[$II][13] = DllStructGetData($TCODEC, "SigMask")
		$PBUFFER += DllStructGetSize($TCODEC)
	Next
	Return $AINFO
EndFunc
Func _GDIPLUS_ENCODERSGETCLSID($SFILEEXT)
	Local $AENCODERS = _GDIPLUS_ENCODERS()
	For $II = 1 To $AENCODERS[0][0]
		If StringInStr($AENCODERS[$II][6], "*." & $SFILEEXT) > 0 Then Return $AENCODERS[$II][1]
	Next
	Return SetError(-1, -1, "")
EndFunc
Func _GDIPLUS_ENCODERSGETCOUNT()
	Local $ARESULT = DllCall($GHGDIPDLL, "int", "GdipGetImageEncodersSize", "uint*", 0, "uint*", 0)
	If @error Then Return SetError(@error, @extended, -1)
	Return SetExtended($ARESULT[0], $ARESULT[1])
EndFunc
Func _GDIPLUS_ENCODERSGETPARAMLIST($HIMAGE, $SENCODER)
	Local $ISIZE = _GDIPLUS_ENCODERSGETPARAMLISTSIZE($HIMAGE, $SENCODER)
	If @error Then Return SetError(@error, -1, 0)
	Local $TGUID = _WINAPI_GUIDFROMSTRING($SENCODER)
	Local $TBUFFER = DllStructCreate("dword Count;byte Params[" & $ISIZE - 4 & "]")
	Local $ARESULT = DllCall($GHGDIPDLL, "int", "GdipGetEncoderParameterList", "handle", $HIMAGE, "struct*", $TGUID, "uint", $ISIZE, "struct*", $TBUFFER)
	If @error Then Return SetError(@error, @extended, 0)
	Return SetExtended($ARESULT[0], $TBUFFER)
EndFunc
Func _GDIPLUS_ENCODERSGETPARAMLISTSIZE($HIMAGE, $SENCODER)
	Local $TGUID = _WINAPI_GUIDFROMSTRING($SENCODER)
	Local $ARESULT = DllCall($GHGDIPDLL, "int", "GdipGetEncoderParameterListSize", "handle", $HIMAGE, "struct*", $TGUID, "uint*", 0)
	If @error Then Return SetError(@error, @extended, 0)
	Return SetExtended($ARESULT[0], $ARESULT[3])
EndFunc
Func _GDIPLUS_ENCODERSGETSIZE()
	Local $ARESULT = DllCall($GHGDIPDLL, "int", "GdipGetImageEncodersSize", "uint*", 0, "uint*", 0)
	If @error Then Return SetError(@error, @extended, -1)
	Return SetExtended($ARESULT[0], $ARESULT[2])
EndFunc
Func _GDIPLUS_FONTCREATE($HFAMILY, $FSIZE, $ISTYLE = 0, $IUNIT = 3)
	Local $ARESULT = DllCall($GHGDIPDLL, "int", "GdipCreateFont", "handle", $HFAMILY, "float", $FSIZE, "int", $ISTYLE, "int", $IUNIT, "ptr*", 0)
	If @error Then Return SetError(@error, @extended, 0)
	Return SetExtended($ARESULT[0], $ARESULT[5])
EndFunc
Func _GDIPLUS_FONTDISPOSE($HFONT)
	Local $ARESULT = DllCall($GHGDIPDLL, "int", "GdipDeleteFont", "handle", $HFONT)
	If @error Then Return SetError(@error, @extended, False)
	Return $ARESULT[0] = 0
EndFunc
Func _GDIPLUS_FONTFAMILYCREATE($SFAMILY)
	Local $ARESULT = DllCall($GHGDIPDLL, "int", "GdipCreateFontFamilyFromName", "wstr", $SFAMILY, "ptr", 0, "handle*", 0)
	If @error Then Return SetError(@error, @extended, 0)
	Return SetExtended($ARESULT[0], $ARESULT[3])
EndFunc
Func _GDIPLUS_FONTFAMILYDISPOSE($HFAMILY)
	Local $ARESULT = DllCall($GHGDIPDLL, "int", "GdipDeleteFontFamily", "handle", $HFAMILY)
	If @error Then Return SetError(@error, @extended, False)
	Return $ARESULT[0] = 0
EndFunc
Func _GDIPLUS_GRAPHICSCLEAR($HGRAPHICS, $IARGB = -16777216)
	Local $ARESULT = DllCall($GHGDIPDLL, "int", "GdipGraphicsClear", "handle", $HGRAPHICS, "dword", $IARGB)
	If @error Then Return SetError(@error, @extended, False)
	Return $ARESULT[0] = 0
EndFunc
Func _GDIPLUS_GRAPHICSCREATEFROMHDC($HDC)
	Local $ARESULT = DllCall($GHGDIPDLL, "int", "GdipCreateFromHDC", "handle", $HDC, "ptr*", 0)
	If @error Then Return SetError(@error, @extended, 0)
	Return SetExtended($ARESULT[0], $ARESULT[2])
EndFunc
Func _GDIPLUS_GRAPHICSCREATEFROMHWND($HWND)
	Local $ARESULT = DllCall($GHGDIPDLL, "int", "GdipCreateFromHWND", "hwnd", $HWND, "ptr*", 0)
	If @error Then Return SetError(@error, @extended, 0)
	Return SetExtended($ARESULT[0], $ARESULT[2])
EndFunc
Func _GDIPLUS_GRAPHICSDISPOSE($HGRAPHICS)
	Local $ARESULT = DllCall($GHGDIPDLL, "int", "GdipDeleteGraphics", "handle", $HGRAPHICS)
	If @error Then Return SetError(@error, @extended, False)
	Return $ARESULT[0] = 0
EndFunc
Func _GDIPLUS_GRAPHICSDRAWARC($HGRAPHICS, $IX, $IY, $IWIDTH, $IHEIGHT, $FSTARTANGLE, $FSWEEPANGLE, $HPEN = 0)
	__GDIPLUS_PENDEFCREATE($HPEN)
	Local $ARESULT = DllCall($GHGDIPDLL, "int", "GdipDrawArcI", "handle", $HGRAPHICS, "handle", $HPEN, "int", $IX, "int", $IY, "int", $IWIDTH, "int", $IHEIGHT, "float", $FSTARTANGLE, "float", $FSWEEPANGLE)
	Local $TMPERROR = @error, $TMPEXTENDED = @extended
	__GDIPLUS_PENDEFDISPOSE()
	If $TMPERROR Then Return SetError($TMPERROR, $TMPEXTENDED, False)
	Return $ARESULT[0] = 0
EndFunc
Func _GDIPLUS_GRAPHICSDRAWBEZIER($HGRAPHICS, $IX1, $IY1, $IX2, $IY2, $IX3, $IY3, $IX4, $IY4, $HPEN = 0)
	__GDIPLUS_PENDEFCREATE($HPEN)
	Local $ARESULT = DllCall($GHGDIPDLL, "int", "GdipDrawBezierI", "handle", $HGRAPHICS, "handle", $HPEN, "int", $IX1, "int", $IY1, "int", $IX2, "int", $IY2, "int", $IX3, "int", $IY3, "int", $IX4, "int", $IY4)
	Local $TMPERROR = @error, $TMPEXTENDED = @extended
	__GDIPLUS_PENDEFDISPOSE()
	If $TMPERROR Then Return SetError($TMPERROR, $TMPEXTENDED, False)
	Return $ARESULT[0] = 0
EndFunc
Func _GDIPLUS_GRAPHICSDRAWCLOSEDCURVE($HGRAPHICS, $APOINTS, $HPEN = 0)
	Local $ICOUNT = $APOINTS[0][0]
	Local $TPOINTS = DllStructCreate("long[" & $ICOUNT * 2 & "]")
	For $II = 1 To $ICOUNT
		DllStructSetData($TPOINTS, 1, $APOINTS[$II][0], (($II - 1) * 2) + 1)
		DllStructSetData($TPOINTS, 1, $APOINTS[$II][1], (($II - 1) * 2) + 2)
	Next
	__GDIPLUS_PENDEFCREATE($HPEN)
	Local $ARESULT = DllCall($GHGDIPDLL, "int", "GdipDrawClosedCurveI", "handle", $HGRAPHICS, "handle", $HPEN, "struct*", $TPOINTS, "int", $ICOUNT)
	Local $TMPERROR = @error, $TMPEXTENDED = @extended
	__GDIPLUS_PENDEFDISPOSE()
	If $TMPERROR Then Return SetError($TMPERROR, $TMPEXTENDED, False)
	Return $ARESULT[0] = 0
EndFunc
Func _GDIPLUS_GRAPHICSDRAWCURVE($HGRAPHICS, $APOINTS, $HPEN = 0)
	Local $ICOUNT = $APOINTS[0][0]
	Local $TPOINTS = DllStructCreate("long[" & $ICOUNT * 2 & "]")
	For $II = 1 To $ICOUNT
		DllStructSetData($TPOINTS, 1, $APOINTS[$II][0], (($II - 1) * 2) + 1)
		DllStructSetData($TPOINTS, 1, $APOINTS[$II][1], (($II - 1) * 2) + 2)
	Next
	__GDIPLUS_PENDEFCREATE($HPEN)
	Local $ARESULT = DllCall($GHGDIPDLL, "int", "GdipDrawCurveI", "handle", $HGRAPHICS, "handle", $HPEN, "struct*", $TPOINTS, "int", $ICOUNT)
	Local $TMPERROR = @error, $TMPEXTENDED = @extended
	__GDIPLUS_PENDEFDISPOSE()
	If $TMPERROR Then Return SetError($TMPERROR, $TMPEXTENDED, False)
	Return $ARESULT[0] = 0
EndFunc
Func _GDIPLUS_GRAPHICSDRAWELLIPSE($HGRAPHICS, $IX, $IY, $IWIDTH, $IHEIGHT, $HPEN = 0)
	__GDIPLUS_PENDEFCREATE($HPEN)
	Local $ARESULT = DllCall($GHGDIPDLL, "int", "GdipDrawEllipseI", "handle", $HGRAPHICS, "handle", $HPEN, "int", $IX, "int", $IY, "int", $IWIDTH, "int", $IHEIGHT)
	Local $TMPERROR = @error, $TMPEXTENDED = @extended
	__GDIPLUS_PENDEFDISPOSE()
	If $TMPERROR Then Return SetError($TMPERROR, $TMPEXTENDED, False)
	Return $ARESULT[0] = 0
EndFunc
Func _GDIPLUS_GRAPHICSDRAWIMAGE($HGRAPHICS, $HIMAGE, $IX, $IY)
	Local $ARESULT = DllCall($GHGDIPDLL, "int", "GdipDrawImageI", "handle", $HGRAPHICS, "handle", $HIMAGE, "int", $IX, "int", $IY)
	If @error Then Return SetError(@error, @extended, False)
	Return $ARESULT[0] = 0
EndFunc
Func _GDIPLUS_GRAPHICSDRAWIMAGERECT($HGRAPHICS, $HIMAGE, $IX, $IY, $IW, $IH)
	Local $ARESULT = DllCall($GHGDIPDLL, "int", "GdipDrawImageRectI", "handle", $HGRAPHICS, "handle", $HIMAGE, "int", $IX, "int", $IY, "int", $IW, "int", $IH)
	If @error Then Return SetError(@error, @extended, False)
	Return $ARESULT[0] = 0
EndFunc
Func _GDIPLUS_GRAPHICSDRAWIMAGERECTRECT($HGRAPHICS, $HIMAGE, $ISRCX, $ISRCY, $ISRCWIDTH, $ISRCHEIGHT, $IDSTX, $IDSTY, $IDSTWIDTH, $IDSTHEIGHT, $IUNIT = 2)
	Local $ARESULT = DllCall($GHGDIPDLL, "int", "GdipDrawImageRectRectI", "handle", $HGRAPHICS, "handle", $HIMAGE, "int", $IDSTX, "int", $IDSTY, "int", $IDSTWIDTH, "int", $IDSTHEIGHT, "int", $ISRCX, "int", $ISRCY, "int", $ISRCWIDTH, "int", $ISRCHEIGHT, "int", $IUNIT, "int", 0, "int", 0, "int", 0)
	If @error Then Return SetError(@error, @extended, False)
	Return $ARESULT[0] = 0
EndFunc
Func _GDIPLUS_GRAPHICSDRAWLINE($HGRAPHICS, $IX1, $IY1, $IX2, $IY2, $HPEN = 0)
	__GDIPLUS_PENDEFCREATE($HPEN)
	Local $ARESULT = DllCall($GHGDIPDLL, "int", "GdipDrawLineI", "handle", $HGRAPHICS, "handle", $HPEN, "int", $IX1, "int", $IY1, "int", $IX2, "int", $IY2)
	Local $TMPERROR = @error, $TMPEXTENDED = @extended
	__GDIPLUS_PENDEFDISPOSE()
	If $TMPERROR Then Return SetError($TMPERROR, $TMPEXTENDED, False)
	Return $ARESULT[0] = 0
EndFunc
Func _GDIPLUS_GRAPHICSDRAWPIE($HGRAPHICS, $IX, $IY, $IWIDTH, $IHEIGHT, $FSTARTANGLE, $FSWEEPANGLE, $HPEN = 0)
	__GDIPLUS_PENDEFCREATE($HPEN)
	Local $ARESULT = DllCall($GHGDIPDLL, "int", "GdipDrawPieI", "handle", $HGRAPHICS, "handle", $HPEN, "int", $IX, "int", $IY, "int", $IWIDTH, "int", $IHEIGHT, "float", $FSTARTANGLE, "float", $FSWEEPANGLE)
	Local $TMPERROR = @error, $TMPEXTENDED = @extended
	__GDIPLUS_PENDEFDISPOSE()
	If $TMPERROR Then Return SetError($TMPERROR, $TMPEXTENDED, False)
	Return $ARESULT[0] = 0
EndFunc
Func _GDIPLUS_GRAPHICSDRAWPOLYGON($HGRAPHICS, $APOINTS, $HPEN = 0)
	Local $ICOUNT = $APOINTS[0][0]
	Local $TPOINTS = DllStructCreate("long[" & $ICOUNT * 2 & "]")
	For $II = 1 To $ICOUNT
		DllStructSetData($TPOINTS, 1, $APOINTS[$II][0], (($II - 1) * 2) + 1)
		DllStructSetData($TPOINTS, 1, $APOINTS[$II][1], (($II - 1) * 2) + 2)
	Next
	__GDIPLUS_PENDEFCREATE($HPEN)
	Local $ARESULT = DllCall($GHGDIPDLL, "int", "GdipDrawPolygonI", "handle", $HGRAPHICS, "handle", $HPEN, "struct*", $TPOINTS, "int", $ICOUNT)
	Local $TMPERROR = @error, $TMPEXTENDED = @extended
	__GDIPLUS_PENDEFDISPOSE()
	If $TMPERROR Then Return SetError($TMPERROR, $TMPEXTENDED, False)
	Return $ARESULT[0] = 0
EndFunc
Func _GDIPLUS_GRAPHICSDRAWRECT($HGRAPHICS, $IX, $IY, $IWIDTH, $IHEIGHT, $HPEN = 0)
	__GDIPLUS_PENDEFCREATE($HPEN)
	Local $ARESULT = DllCall($GHGDIPDLL, "int", "GdipDrawRectangleI", "handle", $HGRAPHICS, "handle", $HPEN, "int", $IX, "int", $IY, "int", $IWIDTH, "int", $IHEIGHT)
	Local $TMPERROR = @error, $TMPEXTENDED = @extended
	__GDIPLUS_PENDEFDISPOSE()
	If $TMPERROR Then Return SetError($TMPERROR, $TMPEXTENDED, False)
	Return $ARESULT[0] = 0
EndFunc
Func _GDIPLUS_GRAPHICSDRAWSTRING($HGRAPHICS, $SSTRING, $NX, $NY, $SFONT = "Arial", $NSIZE = 10, $IFORMAT = 0)
	Local $HBRUSH = _GDIPLUS_BRUSHCREATESOLID()
	Local $HFORMAT = _GDIPLUS_STRINGFORMATCREATE($IFORMAT)
	Local $HFAMILY = _GDIPLUS_FONTFAMILYCREATE($SFONT)
	Local $HFONT = _GDIPLUS_FONTCREATE($HFAMILY, $NSIZE)
	Local $TLAYOUT = _GDIPLUS_RECTFCREATE($NX, $NY, 0, 0)
	Local $AINFO = _GDIPLUS_GRAPHICSMEASURESTRING($HGRAPHICS, $SSTRING, $HFONT, $TLAYOUT, $HFORMAT)
	Local $ARESULT = _GDIPLUS_GRAPHICSDRAWSTRINGEX($HGRAPHICS, $SSTRING, $HFONT, $AINFO[0], $HFORMAT, $HBRUSH)
	Local $IERROR = @error
	_GDIPLUS_FONTDISPOSE($HFONT)
	_GDIPLUS_FONTFAMILYDISPOSE($HFAMILY)
	_GDIPLUS_STRINGFORMATDISPOSE($HFORMAT)
	_GDIPLUS_BRUSHDISPOSE($HBRUSH)
	Return SetError($IERROR, 0, $ARESULT)
EndFunc
Func _GDIPLUS_GRAPHICSDRAWSTRINGEX($HGRAPHICS, $SSTRING, $HFONT, $TLAYOUT, $HFORMAT, $HBRUSH)
	Local $ARESULT = DllCall($GHGDIPDLL, "int", "GdipDrawString", "handle", $HGRAPHICS, "wstr", $SSTRING, "int", -1, "handle", $HFONT, "struct*", $TLAYOUT, "handle", $HFORMAT, "handle", $HBRUSH)
	If @error Then Return SetError(@error, @extended, False)
	Return $ARESULT[0] = 0
EndFunc
Func _GDIPLUS_GRAPHICSFILLCLOSEDCURVE($HGRAPHICS, $APOINTS, $HBRUSH = 0)
	Local $ICOUNT = $APOINTS[0][0]
	Local $TPOINTS = DllStructCreate("long[" & $ICOUNT * 2 & "]")
	For $II = 1 To $ICOUNT
		DllStructSetData($TPOINTS, 1, $APOINTS[$II][0], (($II - 1) * 2) + 1)
		DllStructSetData($TPOINTS, 1, $APOINTS[$II][1], (($II - 1) * 2) + 2)
	Next
	__GDIPLUS_BRUSHDEFCREATE($HBRUSH)
	Local $ARESULT = DllCall($GHGDIPDLL, "int", "GdipFillClosedCurveI", "handle", $HGRAPHICS, "handle", $HBRUSH, "struct*", $TPOINTS, "int", $ICOUNT)
	Local $TMPERROR = @error, $TMPEXTENDED = @extended
	__GDIPLUS_BRUSHDEFDISPOSE()
	If $TMPERROR Then Return SetError($TMPERROR, $TMPEXTENDED, False)
	Return $ARESULT[0] = 0
EndFunc
Func _GDIPLUS_GRAPHICSFILLELLIPSE($HGRAPHICS, $IX, $IY, $IWIDTH, $IHEIGHT, $HBRUSH = 0)
	__GDIPLUS_BRUSHDEFCREATE($HBRUSH)
	Local $ARESULT = DllCall($GHGDIPDLL, "int", "GdipFillEllipseI", "handle", $HGRAPHICS, "handle", $HBRUSH, "int", $IX, "int", $IY, "int", $IWIDTH, "int", $IHEIGHT)
	Local $TMPERROR = @error, $TMPEXTENDED = @extended
	__GDIPLUS_BRUSHDEFDISPOSE()
	If $TMPERROR Then Return SetError($TMPERROR, $TMPEXTENDED, False)
	Return $ARESULT[0] = 0
EndFunc
Func _GDIPLUS_GRAPHICSFILLPIE($HGRAPHICS, $IX, $IY, $IWIDTH, $IHEIGHT, $FSTARTANGLE, $FSWEEPANGLE, $HBRUSH = 0)
	__GDIPLUS_BRUSHDEFCREATE($HBRUSH)
	Local $ARESULT = DllCall($GHGDIPDLL, "int", "GdipFillPieI", "handle", $HGRAPHICS, "handle", $HBRUSH, "int", $IX, "int", $IY, "int", $IWIDTH, "int", $IHEIGHT, "float", $FSTARTANGLE, "float", $FSWEEPANGLE)
	Local $TMPERROR = @error, $TMPEXTENDED = @extended
	__GDIPLUS_BRUSHDEFDISPOSE()
	If $TMPERROR Then Return SetError($TMPERROR, $TMPEXTENDED, False)
	Return $ARESULT[0] = 0
EndFunc
Func _GDIPLUS_GRAPHICSFILLPOLYGON($HGRAPHICS, $APOINTS, $HBRUSH = 0)
	Local $ICOUNT = $APOINTS[0][0]
	Local $TPOINTS = DllStructCreate("long[" & $ICOUNT * 2 & "]")
	For $II = 1 To $ICOUNT
		DllStructSetData($TPOINTS, 1, $APOINTS[$II][0], (($II - 1) * 2) + 1)
		DllStructSetData($TPOINTS, 1, $APOINTS[$II][1], (($II - 1) * 2) + 2)
	Next
	__GDIPLUS_BRUSHDEFCREATE($HBRUSH)
	Local $ARESULT = DllCall($GHGDIPDLL, "int", "GdipFillPolygonI", "handle", $HGRAPHICS, "handle", $HBRUSH, "struct*", $TPOINTS, "int", $ICOUNT, "int", "FillModeAlternate")
	Local $TMPERROR = @error, $TMPEXTENDED = @extended
	__GDIPLUS_BRUSHDEFDISPOSE()
	If $TMPERROR Then Return SetError($TMPERROR, $TMPEXTENDED, False)
	Return $ARESULT[0] = 0
EndFunc
Func _GDIPLUS_GRAPHICSFILLRECT($HGRAPHICS, $IX, $IY, $IWIDTH, $IHEIGHT, $HBRUSH = 0)
	__GDIPLUS_BRUSHDEFCREATE($HBRUSH)
	Local $ARESULT = DllCall($GHGDIPDLL, "int", "GdipFillRectangleI", "handle", $HGRAPHICS, "handle", $HBRUSH, "int", $IX, "int", $IY, "int", $IWIDTH, "int", $IHEIGHT)
	Local $TMPERROR = @error, $TMPEXTENDED = @extended
	__GDIPLUS_BRUSHDEFDISPOSE()
	If $TMPERROR Then Return SetError($TMPERROR, $TMPEXTENDED, False)
	Return $ARESULT[0] = 0
EndFunc
Func _GDIPLUS_GRAPHICSGETDC($HGRAPHICS)
	Local $ARESULT = DllCall($GHGDIPDLL, "int", "GdipGetDC", "handle", $HGRAPHICS, "ptr*", 0)
	If @error Then Return SetError(@error, @extended, False)
	Return SetExtended($ARESULT[0], $ARESULT[2])
EndFunc
Func _GDIPLUS_GRAPHICSGETSMOOTHINGMODE($HGRAPHICS)
	Local $ARESULT = DllCall($GHGDIPDLL, "int", "GdipGetSmoothingMode", "handle", $HGRAPHICS, "int*", 0)
	If @error Then Return SetError(@error, @extended, -1)
	Switch $ARESULT[2]
		Case 3
			Return SetExtended($ARESULT[0], 1)
		Case 7
			Return SetExtended($ARESULT[0], 2)
		Case Else
			Return SetExtended($ARESULT[0], 0)
	EndSwitch
EndFunc
Func _GDIPLUS_GRAPHICSMEASURESTRING($HGRAPHICS, $SSTRING, $HFONT, $TLAYOUT, $HFORMAT)
	Local $TRECTF = DllStructCreate($TAGGDIPRECTF)
	Local $ARESULT = DllCall($GHGDIPDLL, "int", "GdipMeasureString", "handle", $HGRAPHICS, "wstr", $SSTRING, "int", -1, "handle", $HFONT, "struct*", $TLAYOUT, "handle", $HFORMAT, "struct*", $TRECTF, "int*", 0, "int*", 0)
	If @error Then Return SetError(@error, @extended, 0)
	Local $AINFO[3]
	$AINFO[0] = $TRECTF
	$AINFO[1] = $ARESULT[8]
	$AINFO[2] = $ARESULT[9]
	Return SetExtended($ARESULT[0], $AINFO)
EndFunc
Func _GDIPLUS_GRAPHICSRELEASEDC($HGRAPHICS, $HDC)
	Local $ARESULT = DllCall($GHGDIPDLL, "int", "GdipReleaseDC", "handle", $HGRAPHICS, "handle", $HDC)
	If @error Then Return SetError(@error, @extended, False)
	Return SetExtended($ARESULT[0], $ARESULT[2])
EndFunc
Func _GDIPLUS_GRAPHICSSETTRANSFORM($HGRAPHICS, $HMATRIX)
	Local $ARESULT = DllCall($GHGDIPDLL, "int", "GdipSetWorldTransform", "handle", $HGRAPHICS, "handle", $HMATRIX)
	If @error Then Return SetError(@error, @extended, False)
	Return $ARESULT[0] = 0
EndFunc
Func _GDIPLUS_GRAPHICSSETSMOOTHINGMODE($HGRAPHICS, $ISMOOTH)
	If $ISMOOTH < 0 Or $ISMOOTH > 4 Then $ISMOOTH = 0
	Local $ARESULT = DllCall($GHGDIPDLL, "int", "GdipSetSmoothingMode", "handle", $HGRAPHICS, "int", $ISMOOTH)
	If @error Then Return SetError(@error, @extended, False)
	Return $ARESULT[0] = 0
EndFunc
Func _GDIPLUS_IMAGEDISPOSE($HIMAGE)
	Local $ARESULT = DllCall($GHGDIPDLL, "int", "GdipDisposeImage", "handle", $HIMAGE)
	If @error Then Return SetError(@error, @extended, False)
	Return $ARESULT[0] = 0
EndFunc
Func _GDIPLUS_IMAGEGETFLAGS($HIMAGE)
	Local $AFLAG[2] = [0, ""]
	IF ($HIMAGE = -1) OR (Not $HIMAGE) Then Return SetError(10, 1, $AFLAG)
	Local $AIMAGEFLAGS[13][2] = [["Pixel data Cacheable", $GDIP_IMAGEFLAGS_CACHING],["Pixel data read-only", $GDIP_IMAGEFLAGS_READONLY],["Pixel size in image", $GDIP_IMAGEFLAGS_HASREALPIXELSIZE],["DPI info in image", $GDIP_IMAGEFLAGS_HASREALDPI],["YCCK color space", $GDIP_IMAGEFLAGS_COLORSPACE_YCCK],["YCBCR color space", $GDIP_IMAGEFLAGS_COLORSPACE_YCBCR],["Grayscale image", $GDIP_IMAGEFLAGS_COLORSPACE_GRAY],["CMYK color space", $GDIP_IMAGEFLAGS_COLORSPACE_CMYK],["RGB color space", $GDIP_IMAGEFLAGS_COLORSPACE_RGB],["Partially scalable", $GDIP_IMAGEFLAGS_PARTIALLYSCALABLE],["Alpha values other than 0 (transparent) and 255 (opaque)", $GDIP_IMAGEFLAGS_HASTRANSLUCENT],["Alpha values", $GDIP_IMAGEFLAGS_HASALPHA],["Scalable", $GDIP_IMAGEFLAGS_SCALABLE]]
	Local $ARESULT = DllCall($GHGDIPDLL, "int", "GdipGetImageFlags", "handle", $HIMAGE, "long*", 0)
	If @error Then Return SetError(@error, 2, $AFLAG)
	If $ARESULT[2] = $GDIP_IMAGEFLAGS_NONE Then
		$AFLAG[1] = "No pixel data"
		Return SetError($ARESULT[0], 3, $AFLAG)
	EndIf
	$AFLAG[0] = $ARESULT[2]
	For $I = 0 To 12
		If BitAND($ARESULT[2], $AIMAGEFLAGS[$I][1]) = $AIMAGEFLAGS[$I][1] Then
			If StringLen($AFLAG[1]) Then $AFLAG[1] &= "|"
			$ARESULT[2] -= $AIMAGEFLAGS[$I][1]
			$AFLAG[1] &= $AIMAGEFLAGS[$I][0]
		EndIf
	Next
	Return SetExtended($ARESULT[0], $AFLAG)
EndFunc
Func _GDIPLUS_IMAGEGETGRAPHICSCONTEXT($HIMAGE)
	Local $ARESULT = DllCall($GHGDIPDLL, "int", "GdipGetImageGraphicsContext", "handle", $HIMAGE, "ptr*", 0)
	If @error Then Return SetError(@error, @extended, -1)
	Return SetExtended($ARESULT[0], $ARESULT[2])
EndFunc
Func _GDIPLUS_IMAGEGETHEIGHT($HIMAGE)
	Local $ARESULT = DllCall($GHGDIPDLL, "int", "GdipGetImageHeight", "handle", $HIMAGE, "uint*", 0)
	If @error Then Return SetError(@error, @extended, -1)
	Return SetExtended($ARESULT[0], $ARESULT[2])
EndFunc
Func _GDIPLUS_IMAGEGETHORIZONTALRESOLUTION($HIMAGE)
	IF ($HIMAGE = -1) OR (Not $HIMAGE) Then Return SetError(10, 1, 0)
	Local $ARESULT = DllCall($GHGDIPDLL, "int", "GdipGetImageHorizontalResolution", "handle", $HIMAGE, "float*", 0)
	If @error Then Return SetError(@error, @extended, 0)
	Return SetExtended($ARESULT[0], Round($ARESULT[2]))
EndFunc
Func _GDIPLUS_IMAGEGETPIXELFORMAT($HIMAGE)
	Local $AFORMAT[2] = [0, ""]
	IF ($HIMAGE = -1) OR (Not $HIMAGE) Then Return SetError(10, 1, $AFORMAT)
	Local $APIXELFORMAT[14][2] = [["1 Bpp Indexed", $GDIP_PXF01INDEXED],["4 Bpp Indexed", $GDIP_PXF04INDEXED],["8 Bpp Indexed", $GDIP_PXF08INDEXED],["16 Bpp Grayscale", $GDIP_PXF16GRAYSCALE],["16 Bpp RGB 555", $GDIP_PXF16RGB555],["16 Bpp RGB 565", $GDIP_PXF16RGB565],["16 Bpp ARGB 1555", $GDIP_PXF16ARGB1555],["24 Bpp RGB", $GDIP_PXF24RGB],["32 Bpp RGB", $GDIP_PXF32RGB],["32 Bpp ARGB", $GDIP_PXF32ARGB],["32 Bpp PARGB", $GDIP_PXF32PARGB],["48 Bpp RGB", $GDIP_PXF48RGB],["64 Bpp ARGB", $GDIP_PXF64ARGB],["64 Bpp PARGB", $GDIP_PXF64PARGB]]
	Local $ARESULT = DllCall($GHGDIPDLL, "int", "GdipGetImagePixelFormat", "handle", $HIMAGE, "int*", 0)
	If @error Then Return SetError(@error, @extended, $AFORMAT)
	For $I = 0 To 13
		If $APIXELFORMAT[$I][1] = $ARESULT[2] Then
			$AFORMAT[0] = $APIXELFORMAT[$I][1]
			$AFORMAT[1] = $APIXELFORMAT[$I][0]
			Return SetExtended($ARESULT[0], $AFORMAT)
		EndIf
	Next
	Return SetExtended($ARESULT[0], $AFORMAT)
EndFunc
Func _GDIPLUS_IMAGEGETRAWFORMAT($HIMAGE)
	Local $AGUID[2]
	IF ($HIMAGE = -1) OR (Not $HIMAGE) Then Return SetError(10, 1, $AGUID)
	Local $AIMAGETYPE[11][2] = [["UNDEFINED", $GDIP_IMAGEFORMAT_UNDEFINED],["MEMORYBMP", $GDIP_IMAGEFORMAT_MEMORYBMP],["BMP", $GDIP_IMAGEFORMAT_BMP],["EMF", $GDIP_IMAGEFORMAT_EMF],["WMF", $GDIP_IMAGEFORMAT_WMF],["JPEG", $GDIP_IMAGEFORMAT_JPEG],["PNG", $GDIP_IMAGEFORMAT_PNG],["GIF", $GDIP_IMAGEFORMAT_GIF],["TIFF", $GDIP_IMAGEFORMAT_TIFF],["EXIF", $GDIP_IMAGEFORMAT_EXIF],["ICON", $GDIP_IMAGEFORMAT_ICON]]
	Local $TSTRUCT = DllStructCreate("byte[16]")
	Local $ARESULT1 = DllCall($GHGDIPDLL, "int", "GdipGetImageRawFormat", "handle", $HIMAGE, "struct*", $TSTRUCT)
	If @error Then Return SetError(@error, @extended, $AGUID)
	IF (Not IsArray($ARESULT1)) Then Return SetError(1, 3, $AGUID)
	Local $SRESULT2 = _WINAPI_STRINGFROMGUID($ARESULT1[2])
	If @error Then Return SetError(@error, 4, $AGUID)
	For $I = 0 To 10
		If $AIMAGETYPE[$I][1] == $SRESULT2 Then
			$AGUID[0] = $AIMAGETYPE[$I][1]
			$AGUID[1] = $AIMAGETYPE[$I][0]
			Return SetExtended($ARESULT1[0], $AGUID)
		EndIf
	Next
	Return SetError(-1, 5, $AGUID)
EndFunc
Func _GDIPLUS_IMAGEGETTYPE($HIMAGE)
	IF ($HIMAGE = -1) OR (Not $HIMAGE) Then Return SetError(10, 0, -1)
	Local $ARESULT = DllCall($GHGDIPDLL, "int", "GdipGetImageType", "handle", $HIMAGE, "int*", 0)
	If @error Then Return SetError(@error, @extended, -1)
	Return SetExtended($ARESULT[0], $ARESULT[2])
EndFunc
Func _GDIPLUS_IMAGEGETVERTICALRESOLUTION($HIMAGE)
	IF ($HIMAGE = -1) OR (Not $HIMAGE) Then Return SetError(10, 0, 0)
	Local $ARESULT = DllCall($GHGDIPDLL, "int", "GdipGetImageVerticalResolution", "handle", $HIMAGE, "float*", 0)
	If @error Then Return SetError(@error, @extended, 0)
	Return SetExtended($ARESULT[0], Round($ARESULT[2]))
EndFunc
Func _GDIPLUS_IMAGEGETWIDTH($HIMAGE)
	Local $ARESULT = DllCall($GHGDIPDLL, "int", "GdipGetImageWidth", "handle", $HIMAGE, "uint*", -1)
	If @error Then Return SetError(@error, @extended, -1)
	Return SetExtended($ARESULT[0], $ARESULT[2])
EndFunc
Func _GDIPLUS_IMAGELOADFROMFILE($SFILENAME)
	Local $ARESULT = DllCall($GHGDIPDLL, "int", "GdipLoadImageFromFile", "wstr", $SFILENAME, "ptr*", 0)
	If @error Then Return SetError(@error, @extended, -1)
	Return SetExtended($ARESULT[0], $ARESULT[2])
EndFunc
Func _GDIPLUS_IMAGESAVETOFILE($HIMAGE, $SFILENAME)
	Local $SEXT = __GDIPLUS_EXTRACTFILEEXT($SFILENAME)
	Local $SCLSID = _GDIPLUS_ENCODERSGETCLSID($SEXT)
	If $SCLSID = "" Then Return SetError(-1, 0, False)
	Return _GDIPLUS_IMAGESAVETOFILEEX($HIMAGE, $SFILENAME, $SCLSID, 0)
EndFunc
Func _GDIPLUS_IMAGESAVETOFILEEX($HIMAGE, $SFILENAME, $SENCODER, $PPARAMS = 0)
	Local $TGUID = _WINAPI_GUIDFROMSTRING($SENCODER)
	Local $ARESULT = DllCall($GHGDIPDLL, "int", "GdipSaveImageToFile", "handle", $HIMAGE, "wstr", $SFILENAME, "struct*", $TGUID, "struct*", $PPARAMS)
	If @error Then Return SetError(@error, @extended, False)
	Return $ARESULT[0] = 0
EndFunc
Func _GDIPLUS_MATRIXCREATE()
	Local $ARESULT = DllCall($GHGDIPDLL, "int", "GdipCreateMatrix", "ptr*", 0)
	If @error Then Return SetError(@error, @extended, 0)
	Return SetExtended($ARESULT[0], $ARESULT[1])
EndFunc
Func _GDIPLUS_MATRIXDISPOSE($HMATRIX)
	Local $ARESULT = DllCall($GHGDIPDLL, "int", "GdipDeleteMatrix", "handle", $HMATRIX)
	If @error Then Return SetError(@error, @extended, False)
	Return $ARESULT[0] = 0
EndFunc
Func _GDIPLUS_MATRIXROTATE($HMATRIX, $FANGLE, $BAPPEND = False)
	Local $ARESULT = DllCall($GHGDIPDLL, "int", "GdipRotateMatrix", "handle", $HMATRIX, "float", $FANGLE, "int", $BAPPEND)
	If @error Then Return SetError(@error, @extended, False)
	Return $ARESULT[0] = 0
EndFunc
Func _GDIPLUS_MATRIXSCALE($HMATRIX, $FSCALEX, $FSCALEY, $BORDER = False)
	Local $ARESULT = DllCall($GHGDIPDLL, "int", "GdipScaleMatrix", "handle", $HMATRIX, "float", $FSCALEX, "float", $FSCALEY, "int", $BORDER)
	If @error Then Return SetError(@error, @extended, False)
	Return $ARESULT[0] = 0
EndFunc
Func _GDIPLUS_MATRIXTRANSLATE($HMATRIX, $FOFFSETX, $FOFFSETY, $BAPPEND = False)
	Local $ARESULT = DllCall($GHGDIPDLL, "int", "GdipTranslateMatrix", "handle", $HMATRIX, "float", $FOFFSETX, "float", $FOFFSETY, "int", $BAPPEND)
	If @error Then Return SetError(@error, @extended, False)
	Return $ARESULT[0] = 0
EndFunc
Func _GDIPLUS_PARAMADD(ByRef $TPARAMS, $SGUID, $ICOUNT, $ITYPE, $PVALUES)
	Local $TPARAM = DllStructCreate($TAGGDIPENCODERPARAM, DllStructGetPtr($TPARAMS, "Params") + (DllStructGetData($TPARAMS, "Count") * 28))
	_WINAPI_GUIDFROMSTRINGEX($SGUID, DllStructGetPtr($TPARAM, "GUID"))
	DllStructSetData($TPARAM, "Type", $ITYPE)
	DllStructSetData($TPARAM, "Count", $ICOUNT)
	DllStructSetData($TPARAM, "Values", $PVALUES)
	DllStructSetData($TPARAMS, "Count", DllStructGetData($TPARAMS, "Count") + 1)
EndFunc
Func _GDIPLUS_PARAMINIT($ICOUNT)
	If $ICOUNT <= 0 Then Return SetError(-1, -1, 0)
	Return DllStructCreate("dword Count;byte Params[" & $ICOUNT * 28 & "]")
EndFunc
Func _GDIPLUS_PENCREATE($IARGB = -16777216, $FWIDTH = 1, $IUNIT = 2)
	Local $ARESULT = DllCall($GHGDIPDLL, "int", "GdipCreatePen1", "dword", $IARGB, "float", $FWIDTH, "int", $IUNIT, "ptr*", 0)
	If @error Then Return SetError(@error, @extended, 0)
	Return SetExtended($ARESULT[0], $ARESULT[4])
EndFunc
Func _GDIPLUS_PENDISPOSE($HPEN)
	Local $ARESULT = DllCall($GHGDIPDLL, "int", "GdipDeletePen", "handle", $HPEN)
	If @error Then Return SetError(@error, @extended, False)
	Return $ARESULT[0] = 0
EndFunc
Func _GDIPLUS_PENGETALIGNMENT($HPEN)
	Local $ARESULT = DllCall($GHGDIPDLL, "int", "GdipGetPenMode", "handle", $HPEN, "int*", 0)
	If @error Then Return SetError(@error, @extended, -1)
	Return SetExtended($ARESULT[0], $ARESULT[2])
EndFunc
Func _GDIPLUS_PENGETCOLOR($HPEN)
	Local $ARESULT = DllCall($GHGDIPDLL, "int", "GdipGetPenColor", "handle", $HPEN, "dword*", 0)
	If @error Then Return SetError(@error, @extended, -1)
	Return SetExtended($ARESULT[0], $ARESULT[2])
EndFunc
Func _GDIPLUS_PENGETCUSTOMENDCAP($HPEN)
	Local $ARESULT = DllCall($GHGDIPDLL, "int", "GdipGetPenCustomEndCap", "handle", $HPEN, "ptr*", 0)
	If @error Then Return SetError(@error, @extended, 0)
	Return SetExtended($ARESULT[0], $ARESULT[2])
EndFunc
Func _GDIPLUS_PENGETDASHCAP($HPEN)
	Local $ARESULT = DllCall($GHGDIPDLL, "int", "GdipGetPenDashCap197819", "handle", $HPEN, "int*", 0)
	If @error Then Return SetError(@error, @extended, -1)
	Return SetExtended($ARESULT[0], $ARESULT[2])
EndFunc
Func _GDIPLUS_PENGETDASHSTYLE($HPEN)
	Local $ARESULT = DllCall($GHGDIPDLL, "int", "GdipGetPenDashStyle", "handle", $HPEN, "int*", 0)
	If @error Then Return SetError(@error, @extended, -1)
	Return SetExtended($ARESULT[0], $ARESULT[2])
EndFunc
Func _GDIPLUS_PENGETENDCAP($HPEN)
	Local $ARESULT = DllCall($GHGDIPDLL, "int", "GdipGetPenEndCap", "handle", $HPEN, "int*", 0)
	If @error Then Return SetError(@error, @extended, -1)
	Return SetExtended($ARESULT[0], $ARESULT[2])
EndFunc
Func _GDIPLUS_PENGETWIDTH($HPEN)
	Local $ARESULT = DllCall($GHGDIPDLL, "int", "GdipGetPenWidth", "handle", $HPEN, "float*", 0)
	If @error Then Return SetError(@error, @extended, -1)
	Return SetExtended($ARESULT[0], $ARESULT[2])
EndFunc
Func _GDIPLUS_PENSETALIGNMENT($HPEN, $IALIGNMENT = 0)
	Local $ARESULT = DllCall($GHGDIPDLL, "int", "GdipSetPenMode", "handle", $HPEN, "int", $IALIGNMENT)
	If @error Then Return SetError(@error, @extended, False)
	Return $ARESULT[0] = 0
EndFunc
Func _GDIPLUS_PENSETCOLOR($HPEN, $IARGB)
	Local $ARESULT = DllCall($GHGDIPDLL, "int", "GdipSetPenColor", "handle", $HPEN, "dword", $IARGB)
	If @error Then Return SetError(@error, @extended, False)
	Return $ARESULT[0] = 0
EndFunc
Func _GDIPLUS_PENSETDASHCAP($HPEN, $IDASH = 0)
	Local $ARESULT = DllCall($GHGDIPDLL, "int", "GdipSetPenDashCap197819", "handle", $HPEN, "int", $IDASH)
	If @error Then Return SetError(@error, @extended, False)
	Return $ARESULT[0] = 0
EndFunc
Func _GDIPLUS_PENSETCUSTOMENDCAP($HPEN, $HENDCAP)
	Local $ARESULT = DllCall($GHGDIPDLL, "int", "GdipSetPenCustomEndCap", "handle", $HPEN, "handle", $HENDCAP)
	If @error Then Return SetError(@error, @extended, False)
	Return $ARESULT[0] = 0
EndFunc
Func _GDIPLUS_PENSETDASHSTYLE($HPEN, $ISTYLE = 0)
	Local $ARESULT = DllCall($GHGDIPDLL, "int", "GdipSetPenDashStyle", "handle", $HPEN, "int", $ISTYLE)
	If @error Then Return SetError(@error, @extended, False)
	Return $ARESULT[0] = 0
EndFunc
Func _GDIPLUS_PENSETENDCAP($HPEN, $IENDCAP)
	Local $ARESULT = DllCall($GHGDIPDLL, "int", "GdipSetPenEndCap", "handle", $HPEN, "int", $IENDCAP)
	If @error Then Return SetError(@error, @extended, False)
	Return $ARESULT[0] = 0
EndFunc
Func _GDIPLUS_PENSETWIDTH($HPEN, $FWIDTH)
	Local $ARESULT = DllCall($GHGDIPDLL, "int", "GdipSetPenWidth", "handle", $HPEN, "float", $FWIDTH)
	If @error Then Return SetError(@error, @extended, False)
	Return $ARESULT[0] = 0
EndFunc
Func _GDIPLUS_RECTFCREATE($NX = 0, $NY = 0, $NWIDTH = 0, $NHEIGHT = 0)
	Local $TRECTF = DllStructCreate($TAGGDIPRECTF)
	DllStructSetData($TRECTF, "X", $NX)
	DllStructSetData($TRECTF, "Y", $NY)
	DllStructSetData($TRECTF, "Width", $NWIDTH)
	DllStructSetData($TRECTF, "Height", $NHEIGHT)
	Return $TRECTF
EndFunc
Func _GDIPLUS_SHUTDOWN()
	If $GHGDIPDLL = 0 Then Return SetError(-1, -1, False)
	$GIGDIPREF -= 1
	If $GIGDIPREF = 0 Then
		DllCall($GHGDIPDLL, "none", "GdiplusShutdown", "ptr", $GIGDIPTOKEN)
		DllClose($GHGDIPDLL)
		$GHGDIPDLL = 0
	EndIf
	Return True
EndFunc
Func _GDIPLUS_STARTUP()
	$GIGDIPREF += 1
	If $GIGDIPREF > 1 Then Return True
	$GHGDIPDLL = DllOpen("GDIPlus.dll")
	If $GHGDIPDLL = -1 Then
		$GIGDIPREF = 0
		Return SetError(1, 2, False)
	EndIf
	Local $TINPUT = DllStructCreate($TAGGDIPSTARTUPINPUT)
	Local $TTOKEN = DllStructCreate("ulong_ptr Data")
	DllStructSetData($TINPUT, "Version", 1)
	Local $ARESULT = DllCall($GHGDIPDLL, "int", "GdiplusStartup", "struct*", $TTOKEN, "struct*", $TINPUT, "ptr", 0)
	If @error Then Return SetError(@error, @extended, False)
	$GIGDIPTOKEN = DllStructGetData($TTOKEN, "Data")
	Return $ARESULT[0] = 0
EndFunc
Func _GDIPLUS_STRINGFORMATCREATE($IFORMAT = 0, $ILANGID = 0)
	Local $ARESULT = DllCall($GHGDIPDLL, "int", "GdipCreateStringFormat", "int", $IFORMAT, "word", $ILANGID, "ptr*", 0)
	If @error Then Return SetError(@error, @extended, 0)
	Return SetExtended($ARESULT[0], $ARESULT[3])
EndFunc
Func _GDIPLUS_STRINGFORMATDISPOSE($HFORMAT)
	Local $ARESULT = DllCall($GHGDIPDLL, "int", "GdipDeleteStringFormat", "handle", $HFORMAT)
	If @error Then Return SetError(@error, @extended, False)
	Return $ARESULT[0] = 0
EndFunc
Func _GDIPLUS_STRINGFORMATSETALIGN($HSTRINGFORMAT, $IFLAG)
	Local $ARESULT = DllCall($GHGDIPDLL, "int", "GdipSetStringFormatAlign", "handle", $HSTRINGFORMAT, "int", $IFLAG)
	If @error Then Return SetError(@error, @extended, 0)
	Return $ARESULT[0] = 0
EndFunc
Func __GDIPLUS_BRUSHDEFCREATE(ByRef $HBRUSH)
	If $HBRUSH = 0 Then
		$GHGDIPBRUSH = _GDIPLUS_BRUSHCREATESOLID()
		$HBRUSH = $GHGDIPBRUSH
	EndIf
EndFunc
Func __GDIPLUS_BRUSHDEFDISPOSE()
	If $GHGDIPBRUSH <> 0 Then
		_GDIPLUS_BRUSHDISPOSE($GHGDIPBRUSH)
		$GHGDIPBRUSH = 0
	EndIf
EndFunc
Func __GDIPLUS_EXTRACTFILEEXT($SFILENAME, $FNODOT = True)
	Local $IINDEX = __GDIPLUS_LASTDELIMITER(".\:", $SFILENAME)
	IF ($IINDEX > 0) AND (StringMid($SFILENAME, $IINDEX, 1) = ".") Then
		If $FNODOT Then
			Return StringMid($SFILENAME, $IINDEX + 1)
		Else
			Return StringMid($SFILENAME, $IINDEX)
		EndIf
	Else
		Return ""
	EndIf
EndFunc
Func __GDIPLUS_LASTDELIMITER($SDELIMITERS, $SSTRING)
	Local $SDELIMITER, $IN
	For $II = 1 To StringLen($SDELIMITERS)
		$SDELIMITER = StringMid($SDELIMITERS, $II, 1)
		$IN = StringInStr($SSTRING, $SDELIMITER, 0, -1)
		If $IN > 0 Then Return $IN
	Next
EndFunc
Func __GDIPLUS_PENDEFCREATE(ByRef $HPEN)
	If $HPEN = 0 Then
		$GHGDIPPEN = _GDIPLUS_PENCREATE()
		$HPEN = $GHGDIPPEN
	EndIf
EndFunc
Func __GDIPLUS_PENDEFDISPOSE()
	If $GHGDIPPEN <> 0 Then
		_GDIPLUS_PENDISPOSE($GHGDIPPEN)
		$GHGDIPPEN = 0
	EndIf
EndFunc
Global Const $WS_TILED = 0
Global Const $WS_OVERLAPPED = 0
Global Const $WS_MAXIMIZEBOX = 65536
Global Const $WS_MINIMIZEBOX = 131072
Global Const $WS_TABSTOP = 65536
Global Const $WS_GROUP = 131072
Global Const $WS_SIZEBOX = 262144
Global Const $WS_THICKFRAME = 262144
Global Const $WS_SYSMENU = 524288
Global Const $WS_HSCROLL = 1048576
Global Const $WS_VSCROLL = 2097152
Global Const $WS_DLGFRAME = 4194304
Global Const $WS_BORDER = 8388608
Global Const $WS_CAPTION = 12582912
Global Const $WS_OVERLAPPEDWINDOW = 13565952
Global Const $WS_TILEDWINDOW = 13565952
Global Const $WS_MAXIMIZE = 16777216
Global Const $WS_CLIPCHILDREN = 33554432
Global Const $WS_CLIPSIBLINGS = 67108864
Global Const $WS_DISABLED = 134217728
Global Const $WS_VISIBLE = 268435456
Global Const $WS_MINIMIZE = 536870912
Global Const $WS_CHILD = 1073741824
Global Const $WS_POPUP = -2147483648
Global Const $WS_POPUPWINDOW = -2138570752
Global Const $DS_MODALFRAME = 128
Global Const $DS_SETFOREGROUND = 512
Global Const $DS_CONTEXTHELP = 8192
Global Const $WS_EX_ACCEPTFILES = 16
Global Const $WS_EX_MDICHILD = 64
Global Const $WS_EX_APPWINDOW = 262144
Global Const $WS_EX_COMPOSITED = 33554432
Global Const $WS_EX_CLIENTEDGE = 512
Global Const $WS_EX_CONTEXTHELP = 1024
Global Const $WS_EX_DLGMODALFRAME = 1
Global Const $WS_EX_LEFTSCROLLBAR = 16384
Global Const $WS_EX_OVERLAPPEDWINDOW = 768
Global Const $WS_EX_RIGHT = 4096
Global Const $WS_EX_STATICEDGE = 131072
Global Const $WS_EX_TOOLWINDOW = 128
Global Const $WS_EX_TOPMOST = 8
Global Const $WS_EX_TRANSPARENT = 32
Global Const $WS_EX_WINDOWEDGE = 256
Global Const $WS_EX_LAYERED = 524288
Global Const $WS_EX_CONTROLPARENT = 65536
Global Const $WS_EX_LAYOUTRTL = 4194304
Global Const $WS_EX_RTLREADING = 8192
Global Const $WM_GETTEXTLENGTH = 14
Global Const $WM_GETTEXT = 13
Global Const $WM_SIZE = 5
Global Const $WM_SIZING = 532
Global Const $WM_USER = 1024
Global Const $WM_CREATE = 1
Global Const $WM_DESTROY = 2
Global Const $WM_MOVE = 3
Global Const $WM_ACTIVATE = 6
Global Const $WM_SETFOCUS = 7
Global Const $WM_KILLFOCUS = 8
Global Const $WM_ENABLE = 10
Global Const $WM_SETREDRAW = 11
Global Const $WM_SETTEXT = 12
Global Const $WM_PAINT = 15
Global Const $WM_CLOSE = 16
Global Const $WM_QUERYENDSESSION = 17
Global Const $WM_QUIT = 18
Global Const $WM_ERASEBKGND = 20
Global Const $WM_QUERYOPEN = 19
Global Const $WM_SYSCOLORCHANGE = 21
Global Const $WM_ENDSESSION = 22
Global Const $WM_SHOWWINDOW = 24
Global Const $WM_SETTINGCHANGE = 26
Global Const $WM_WININICHANGE = 26
Global Const $WM_DEVMODECHANGE = 27
Global Const $WM_ACTIVATEAPP = 28
Global Const $WM_FONTCHANGE = 29
Global Const $WM_TIMECHANGE = 30
Global Const $WM_CANCELMODE = 31
Global Const $WM_IME_STARTCOMPOSITION = 269
Global Const $WM_IME_ENDCOMPOSITION = 270
Global Const $WM_IME_COMPOSITION = 271
Global Const $WM_IME_KEYLAST = 271
Global Const $WM_SETCURSOR = 32
Global Const $WM_MOUSEACTIVATE = 33
Global Const $WM_CHILDACTIVATE = 34
Global Const $WM_QUEUESYNC = 35
Global Const $WM_GETMINMAXINFO = 36
Global Const $WM_PAINTICON = 38
Global Const $WM_ICONERASEBKGND = 39
Global Const $WM_NEXTDLGCTL = 40
Global Const $WM_SPOOLERSTATUS = 42
Global Const $WM_DRAWITEM = 43
Global Const $WM_MEASUREITEM = 44
Global Const $WM_DELETEITEM = 45
Global Const $WM_VKEYTOITEM = 46
Global Const $WM_CHARTOITEM = 47
Global Const $WM_SETFONT = 48
Global Const $WM_GETFONT = 49
Global Const $WM_SETHOTKEY = 50
Global Const $WM_GETHOTKEY = 51
Global Const $WM_QUERYDRAGICON = 55
Global Const $WM_COMPAREITEM = 57
Global Const $WM_GETOBJECT = 61
Global Const $WM_COMPACTING = 65
Global Const $WM_COMMNOTIFY = 68
Global Const $WM_WINDOWPOSCHANGING = 70
Global Const $WM_WINDOWPOSCHANGED = 71
Global Const $WM_POWER = 72
Global Const $WM_NOTIFY = 78
Global Const $WM_COPYDATA = 74
Global Const $WM_CANCELJOURNAL = 75
Global Const $WM_INPUTLANGCHANGEREQUEST = 80
Global Const $WM_INPUTLANGCHANGE = 81
Global Const $WM_TCARD = 82
Global Const $WM_HELP = 83
Global Const $WM_USERCHANGED = 84
Global Const $WM_NOTIFYFORMAT = 85
Global Const $WM_PARENTNOTIFY = 528
Global Const $WM_ENTERMENULOOP = 529
Global Const $WM_EXITMENULOOP = 530
Global Const $WM_NEXTMENU = 531
Global Const $WM_CAPTURECHANGED = 533
Global Const $WM_MOVING = 534
Global Const $WM_POWERBROADCAST = 536
Global Const $WM_DEVICECHANGE = 537
Global Const $WM_MDICREATE = 544
Global Const $WM_MDIDESTROY = 545
Global Const $WM_MDIACTIVATE = 546
Global Const $WM_MDIRESTORE = 547
Global Const $WM_MDINEXT = 548
Global Const $WM_MDIMAXIMIZE = 549
Global Const $WM_MDITILE = 550
Global Const $WM_MDICASCADE = 551
Global Const $WM_MDIICONARRANGE = 552
Global Const $WM_MDIGETACTIVE = 553
Global Const $WM_MDISETMENU = 560
Global Const $WM_ENTERSIZEMOVE = 561
Global Const $WM_EXITSIZEMOVE = 562
Global Const $WM_DROPFILES = 563
Global Const $WM_MDIREFRESHMENU = 564
Global Const $WM_IME_SETCONTEXT = 641
Global Const $WM_IME_NOTIFY = 642
Global Const $WM_IME_CONTROL = 643
Global Const $WM_IME_COMPOSITIONFULL = 644
Global Const $WM_IME_SELECT = 645
Global Const $WM_IME_CHAR = 646
Global Const $WM_IME_REQUEST = 648
Global Const $WM_IME_KEYDOWN = 656
Global Const $WM_IME_KEYUP = 657
Global Const $WM_NCMOUSEHOVER = 672
Global Const $WM_MOUSEHOVER = 673
Global Const $WM_NCMOUSELEAVE = 674
Global Const $WM_MOUSELEAVE = 675
Global Const $WM_WTSSESSION_CHANGE = 689
Global Const $WM_TABLET_FIRST = 704
Global Const $WM_TABLET_LAST = 735
Global Const $WM_CUT = 768
Global Const $WM_COPY = 769
Global Const $WM_PASTE = 770
Global Const $WM_CLEAR = 771
Global Const $WM_UNDO = 772
Global Const $WM_PALETTEISCHANGING = 784
Global Const $WM_HOTKEY = 786
Global Const $WM_PALETTECHANGED = 785
Global Const $WM_PRINT = 791
Global Const $WM_PRINTCLIENT = 792
Global Const $WM_APPCOMMAND = 793
Global Const $WM_QUERYNEWPALETTE = 783
Global Const $WM_THEMECHANGED = 794
Global Const $WM_HANDHELDFIRST = 856
Global Const $WM_HANDHELDLAST = 863
Global Const $WM_AFXFIRST = 864
Global Const $WM_AFXLAST = 895
Global Const $WM_PENWINFIRST = 896
Global Const $WM_PENWINLAST = 911
Global Const $WM_CONTEXTMENU = 123
Global Const $WM_STYLECHANGING = 124
Global Const $WM_STYLECHANGED = 125
Global Const $WM_DISPLAYCHANGE = 126
Global Const $WM_GETICON = 127
Global Const $WM_SETICON = 128
Global Const $WM_NCCREATE = 129
Global Const $WM_NCDESTROY = 130
Global Const $WM_NCCALCSIZE = 131
Global Const $WM_NCHITTEST = 132
Global Const $WM_NCPAINT = 133
Global Const $WM_NCACTIVATE = 134
Global Const $WM_GETDLGCODE = 135
Global Const $WM_SYNCPAINT = 136
Global Const $WM_NCMOUSEMOVE = 160
Global Const $WM_NCLBUTTONDOWN = 161
Global Const $WM_NCLBUTTONUP = 162
Global Const $WM_NCLBUTTONDBLCLK = 163
Global Const $WM_NCRBUTTONDOWN = 164
Global Const $WM_NCRBUTTONUP = 165
Global Const $WM_NCRBUTTONDBLCLK = 166
Global Const $WM_NCMBUTTONDOWN = 167
Global Const $WM_NCMBUTTONUP = 168
Global Const $WM_NCMBUTTONDBLCLK = 169
Global Const $WM_NCXBUTTONDOWN = 171
Global Const $WM_NCXBUTTONUP = 172
Global Const $WM_NCXBUTTONDBLCLK = 173
Global Const $WM_KEYDOWN = 256
Global Const $WM_KEYFIRST = 256
Global Const $WM_KEYUP = 257
Global Const $WM_CHAR = 258
Global Const $WM_DEADCHAR = 259
Global Const $WM_SYSKEYDOWN = 260
Global Const $WM_SYSKEYUP = 261
Global Const $WM_SYSCHAR = 262
Global Const $WM_SYSDEADCHAR = 263
Global Const $WM_KEYLAST = 265
Global Const $WM_UNICHAR = 265
Global Const $WM_INITDIALOG = 272
Global Const $WM_COMMAND = 273
Global Const $WM_SYSCOMMAND = 274
Global Const $WM_TIMER = 275
Global Const $WM_HSCROLL = 276
Global Const $WM_VSCROLL = 277
Global Const $WM_INITMENU = 278
Global Const $WM_INITMENUPOPUP = 279
Global Const $WM_MENUSELECT = 287
Global Const $WM_MENUCHAR = 288
Global Const $WM_ENTERIDLE = 289
Global Const $WM_MENURBUTTONUP = 290
Global Const $WM_MENUDRAG = 291
Global Const $WM_MENUGETOBJECT = 292
Global Const $WM_UNINITMENUPOPUP = 293
Global Const $WM_MENUCOMMAND = 294
Global Const $WM_CHANGEUISTATE = 295
Global Const $WM_UPDATEUISTATE = 296
Global Const $WM_QUERYUISTATE = 297
Global Const $WM_CTLCOLORMSGBOX = 306
Global Const $WM_CTLCOLOREDIT = 307
Global Const $WM_CTLCOLORLISTBOX = 308
Global Const $WM_CTLCOLORBTN = 309
Global Const $WM_CTLCOLORDLG = 310
Global Const $WM_CTLCOLORSCROLLBAR = 311
Global Const $WM_CTLCOLORSTATIC = 312
Global Const $WM_CTLCOLOR = 25
Global Const $MN_GETHMENU = 481
Global Const $WM_APP = 32768
Global Const $NM_FIRST = 0
Global Const $NM_OUTOFMEMORY = $NM_FIRST - 1
Global Const $NM_CLICK = $NM_FIRST - 2
Global Const $NM_DBLCLK = $NM_FIRST - 3
Global Const $NM_RETURN = $NM_FIRST - 4
Global Const $NM_RCLICK = $NM_FIRST - 5
Global Const $NM_RDBLCLK = $NM_FIRST - 6
Global Const $NM_SETFOCUS = $NM_FIRST - 7
Global Const $NM_KILLFOCUS = $NM_FIRST - 8
Global Const $NM_CUSTOMDRAW = $NM_FIRST - 12
Global Const $NM_HOVER = $NM_FIRST - 13
Global Const $NM_NCHITTEST = $NM_FIRST - 14
Global Const $NM_KEYDOWN = $NM_FIRST - 15
Global Const $NM_RELEASEDCAPTURE = $NM_FIRST - 16
Global Const $NM_SETCURSOR = $NM_FIRST - 17
Global Const $NM_CHAR = $NM_FIRST - 18
Global Const $NM_TOOLTIPSCREATED = $NM_FIRST - 19
Global Const $NM_LDOWN = $NM_FIRST - 20
Global Const $NM_RDOWN = $NM_FIRST - 21
Global Const $NM_THEMECHANGED = $NM_FIRST - 22
Global Const $WM_MOUSEFIRST = 512
Global Const $WM_MOUSEMOVE = 512
Global Const $WM_LBUTTONDOWN = 513
Global Const $WM_LBUTTONUP = 514
Global Const $WM_LBUTTONDBLCLK = 515
Global Const $WM_RBUTTONDOWN = 516
Global Const $WM_RBUTTONUP = 517
Global Const $WM_RBUTTONDBLCLK = 518
Global Const $WM_MBUTTONDOWN = 519
Global Const $WM_MBUTTONUP = 520
Global Const $WM_MBUTTONDBLCLK = 521
Global Const $WM_MOUSEWHEEL = 522
Global Const $WM_XBUTTONDOWN = 523
Global Const $WM_XBUTTONUP = 524
Global Const $WM_XBUTTONDBLCLK = 525
Global Const $WM_MOUSEHWHEEL = 526
Global Const $PS_SOLID = 0
Global Const $PS_DASH = 1
Global Const $PS_DOT = 2
Global Const $PS_DASHDOT = 3
Global Const $PS_DASHDOTDOT = 4
Global Const $PS_NULL = 5
Global Const $PS_INSIDEFRAME = 6
Global Const $LWA_ALPHA = 2
Global Const $LWA_COLORKEY = 1
Global Const $RGN_AND = 1
Global Const $RGN_OR = 2
Global Const $RGN_XOR = 3
Global Const $RGN_DIFF = 4
Global Const $RGN_COPY = 5
Global Const $ERRORREGION = 0
Global Const $NULLREGION = 1
Global Const $SIMPLEREGION = 2
Global Const $COMPLEXREGION = 3
Global Const $TRANSPARENT = 1
Global Const $OPAQUE = 2
Global Const $CCM_FIRST = 8192
Global Const $CCM_GETUNICODEFORMAT = ($CCM_FIRST + 6)
Global Const $CCM_SETUNICODEFORMAT = ($CCM_FIRST + 5)
Global Const $CCM_SETBKCOLOR = $CCM_FIRST + 1
Global Const $CCM_SETCOLORSCHEME = $CCM_FIRST + 2
Global Const $CCM_GETCOLORSCHEME = $CCM_FIRST + 3
Global Const $CCM_GETDROPTARGET = $CCM_FIRST + 4
Global Const $CCM_SETWINDOWTHEME = $CCM_FIRST + 11
Global Const $GA_PARENT = 1
Global Const $GA_ROOT = 2
Global Const $GA_ROOTOWNER = 3
Global Const $SM_CXSCREEN = 0
Global Const $SM_CYSCREEN = 1
Global Const $SM_CXVSCROLL = 2
Global Const $SM_CYHSCROLL = 3
Global Const $SM_CYCAPTION = 4
Global Const $SM_CXBORDER = 5
Global Const $SM_CYBORDER = 6
Global Const $SM_CXDLGFRAME = 7
Global Const $SM_CYDLGFRAME = 8
Global Const $SM_CYVTHUMB = 9
Global Const $SM_CXHTHUMB = 10
Global Const $SM_CXICON = 11
Global Const $SM_CYICON = 12
Global Const $SM_CXCURSOR = 13
Global Const $SM_CYCURSOR = 14
Global Const $SM_CYMENU = 15
Global Const $SM_CXFULLSCREEN = 16
Global Const $SM_CYFULLSCREEN = 17
Global Const $SM_CYKANJIWINDOW = 18
Global Const $SM_MOUSEPRESENT = 19
Global Const $SM_CYVSCROLL = 20
Global Const $SM_CXHSCROLL = 21
Global Const $SM_DEBUG = 22
Global Const $SM_SWAPBUTTON = 23
Global Const $SM_RESERVED1 = 24
Global Const $SM_RESERVED2 = 25
Global Const $SM_RESERVED3 = 26
Global Const $SM_RESERVED4 = 27
Global Const $SM_CXMIN = 28
Global Const $SM_CYMIN = 29
Global Const $SM_CXSIZE = 30
Global Const $SM_CYSIZE = 31
Global Const $SM_CXFRAME = 32
Global Const $SM_CYFRAME = 33
Global Const $SM_CXMINTRACK = 34
Global Const $SM_CYMINTRACK = 35
Global Const $SM_CXDOUBLECLK = 36
Global Const $SM_CYDOUBLECLK = 37
Global Const $SM_CXICONSPACING = 38
Global Const $SM_CYICONSPACING = 39
Global Const $SM_MENUDROPALIGNMENT = 40
Global Const $SM_PENWINDOWS = 41
Global Const $SM_DBCSENABLED = 42
Global Const $SM_CMOUSEBUTTONS = 43
Global Const $SM_SECURE = 44
Global Const $SM_CXEDGE = 45
Global Const $SM_CYEDGE = 46
Global Const $SM_CXMINSPACING = 47
Global Const $SM_CYMINSPACING = 48
Global Const $SM_CXSMICON = 49
Global Const $SM_CYSMICON = 50
Global Const $SM_CYSMCAPTION = 51
Global Const $SM_CXSMSIZE = 52
Global Const $SM_CYSMSIZE = 53
Global Const $SM_CXMENUSIZE = 54
Global Const $SM_CYMENUSIZE = 55
Global Const $SM_ARRANGE = 56
Global Const $SM_CXMINIMIZED = 57
Global Const $SM_CYMINIMIZED = 58
Global Const $SM_CXMAXTRACK = 59
Global Const $SM_CYMAXTRACK = 60
Global Const $SM_CXMAXIMIZED = 61
Global Const $SM_CYMAXIMIZED = 62
Global Const $SM_NETWORK = 63
Global Const $SM_CLEANBOOT = 67
Global Const $SM_CXDRAG = 68
Global Const $SM_CYDRAG = 69
Global Const $SM_SHOWSOUNDS = 70
Global Const $SM_CXMENUCHECK = 71
Global Const $SM_CYMENUCHECK = 72
Global Const $SM_SLOWMACHINE = 73
Global Const $SM_MIDEASTENABLED = 74
Global Const $SM_MOUSEWHEELPRESENT = 75
Global Const $SM_XVIRTUALSCREEN = 76
Global Const $SM_YVIRTUALSCREEN = 77
Global Const $SM_CXVIRTUALSCREEN = 78
Global Const $SM_CYVIRTUALSCREEN = 79
Global Const $SM_CMONITORS = 80
Global Const $SM_SAMEDISPLAYFORMAT = 81
Global Const $SM_IMMENABLED = 82
Global Const $SM_CXFOCUSBORDER = 83
Global Const $SM_CYFOCUSBORDER = 84
Global Const $SM_TABLETPC = 86
Global Const $SM_MEDIACENTER = 87
Global Const $SM_STARTER = 88
Global Const $SM_SERVERR2 = 89
Global Const $SM_CMETRICS = 90
Global Const $SM_REMOTESESSION = 4096
Global Const $SM_SHUTTINGDOWN = 8192
Global Const $SM_REMOTECONTROL = 8193
Global Const $SM_CARETBLINKINGENABLED = 8194
Global Const $BLACKNESS = 66
Global Const $CAPTUREBLT = 1073741824
Global Const $DSTINVERT = 5570569
Global Const $MERGECOPY = 12583114
Global Const $MERGEPAINT = 12255782
Global Const $NOMIRRORBITMAP = -2147483648
Global Const $NOTSRCCOPY = 3342344
Global Const $NOTSRCERASE = 1114278
Global Const $PATCOPY = 15728673
Global Const $PATINVERT = 5898313
Global Const $PATPAINT = 16452105
Global Const $SRCAND = 8913094
Global Const $SRCCOPY = 13369376
Global Const $SRCERASE = 4457256
Global Const $SRCINVERT = 6684742
Global Const $SRCPAINT = 15597702
Global Const $WHITENESS = 16711778
Global Const $DT_BOTTOM = 8
Global Const $DT_CALCRECT = 1024
Global Const $DT_CENTER = 1
Global Const $DT_EDITCONTROL = 8192
Global Const $DT_END_ELLIPSIS = 32768
Global Const $DT_EXPANDTABS = 64
Global Const $DT_EXTERNALLEADING = 512
Global Const $DT_HIDEPREFIX = 1048576
Global Const $DT_INTERNAL = 4096
Global Const $DT_LEFT = 0
Global Const $DT_MODIFYSTRING = 65536
Global Const $DT_NOCLIP = 256
Global Const $DT_NOFULLWIDTHCHARBREAK = 524288
Global Const $DT_NOPREFIX = 2048
Global Const $DT_PATH_ELLIPSIS = 16384
Global Const $DT_PREFIXONLY = 2097152
Global Const $DT_RIGHT = 2
Global Const $DT_RTLREADING = 131072
Global Const $DT_SINGLELINE = 32
Global Const $DT_TABSTOP = 128
Global Const $DT_TOP = 0
Global Const $DT_VCENTER = 4
Global Const $DT_WORDBREAK = 16
Global Const $DT_WORD_ELLIPSIS = 262144
Global Const $RDW_ERASE = 4
Global Const $RDW_FRAME = 1024
Global Const $RDW_INTERNALPAINT = 2
Global Const $RDW_INVALIDATE = 1
Global Const $RDW_NOERASE = 32
Global Const $RDW_NOFRAME = 2048
Global Const $RDW_NOINTERNALPAINT = 16
Global Const $RDW_VALIDATE = 8
Global Const $RDW_ERASENOW = 512
Global Const $RDW_UPDATENOW = 256
Global Const $RDW_ALLCHILDREN = 128
Global Const $RDW_NOCHILDREN = 64
Global Const $WM_RENDERFORMAT = 773
Global Const $WM_RENDERALLFORMATS = 774
Global Const $WM_DESTROYCLIPBOARD = 775
Global Const $WM_DRAWCLIPBOARD = 776
Global Const $WM_PAINTCLIPBOARD = 777
Global Const $WM_VSCROLLCLIPBOARD = 778
Global Const $WM_SIZECLIPBOARD = 779
Global Const $WM_ASKCBFORMATNAME = 780
Global Const $WM_CHANGECBCHAIN = 781
Global Const $WM_HSCROLLCLIPBOARD = 782
Global Const $HTERROR = -2
Global Const $HTTRANSPARENT = -1
Global Const $HTNOWHERE = 0
Global Const $HTCLIENT = 1
Global Const $HTCAPTION = 2
Global Const $HTSYSMENU = 3
Global Const $HTGROWBOX = 4
Global Const $HTSIZE = $HTGROWBOX
Global Const $HTMENU = 5
Global Const $HTHSCROLL = 6
Global Const $HTVSCROLL = 7
Global Const $HTMINBUTTON = 8
Global Const $HTMAXBUTTON = 9
Global Const $HTLEFT = 10
Global Const $HTRIGHT = 11
Global Const $HTTOP = 12
Global Const $HTTOPLEFT = 13
Global Const $HTTOPRIGHT = 14
Global Const $HTBOTTOM = 15
Global Const $HTBOTTOMLEFT = 16
Global Const $HTBOTTOMRIGHT = 17
Global Const $HTBORDER = 18
Global Const $HTREDUCE = $HTMINBUTTON
Global Const $HTZOOM = $HTMAXBUTTON
Global Const $HTSIZEFIRST = $HTLEFT
Global Const $HTSIZELAST = $HTBOTTOMRIGHT
Global Const $HTOBJECT = 19
Global Const $HTCLOSE = 20
Global Const $HTHELP = 21
Global Const $COLOR_SCROLLBAR = 0
Global Const $COLOR_BACKGROUND = 1
Global Const $COLOR_ACTIVECAPTION = 2
Global Const $COLOR_INACTIVECAPTION = 3
Global Const $COLOR_MENU = 4
Global Const $COLOR_WINDOW = 5
Global Const $COLOR_WINDOWFRAME = 6
Global Const $COLOR_MENUTEXT = 7
Global Const $COLOR_WINDOWTEXT = 8
Global Const $COLOR_CAPTIONTEXT = 9
Global Const $COLOR_ACTIVEBORDER = 10
Global Const $COLOR_INACTIVEBORDER = 11
Global Const $COLOR_APPWORKSPACE = 12
Global Const $COLOR_HIGHLIGHT = 13
Global Const $COLOR_HIGHLIGHTTEXT = 14
Global Const $COLOR_BTNFACE = 15
Global Const $COLOR_BTNSHADOW = 16
Global Const $COLOR_GRAYTEXT = 17
Global Const $COLOR_BTNTEXT = 18
Global Const $COLOR_INACTIVECAPTIONTEXT = 19
Global Const $COLOR_BTNHIGHLIGHT = 20
Global Const $COLOR_3DDKSHADOW = 21
Global Const $COLOR_3DLIGHT = 22
Global Const $COLOR_INFOTEXT = 23
Global Const $COLOR_INFOBK = 24
Global Const $COLOR_HOTLIGHT = 26
Global Const $COLOR_GRADIENTACTIVECAPTION = 27
Global Const $COLOR_GRADIENTINACTIVECAPTION = 28
Global Const $COLOR_MENUHILIGHT = 29
Global Const $COLOR_MENUBAR = 30
Global Const $COLOR_DESKTOP = 1
Global Const $COLOR_3DFACE = 15
Global Const $COLOR_3DSHADOW = 16
Global Const $COLOR_3DHIGHLIGHT = 20
Global Const $COLOR_3DHILIGHT = 20
Global Const $COLOR_BTNHILIGHT = 20
Global Const $HINST_COMMCTRL = -1
Global Const $IDB_STD_SMALL_COLOR = 0
Global Const $IDB_STD_LARGE_COLOR = 1
Global Const $IDB_VIEW_SMALL_COLOR = 4
Global Const $IDB_VIEW_LARGE_COLOR = 5
Global Const $IDB_HIST_SMALL_COLOR = 8
Global Const $IDB_HIST_LARGE_COLOR = 9
Global Const $STARTF_FORCEOFFFEEDBACK = 128
Global Const $STARTF_FORCEONFEEDBACK = 64
Global Const $STARTF_RUNFULLSCREEN = 32
Global Const $STARTF_USECOUNTCHARS = 8
Global Const $STARTF_USEFILLATTRIBUTE = 16
Global Const $STARTF_USEHOTKEY = 512
Global Const $STARTF_USEPOSITION = 4
Global Const $STARTF_USESHOWWINDOW = 1
Global Const $STARTF_USESIZE = 2
Global Const $STARTF_USESTDHANDLES = 256
Global Const $CDDS_PREPAINT = 1
Global Const $CDDS_POSTPAINT = 2
Global Const $CDDS_PREERASE = 3
Global Const $CDDS_POSTERASE = 4
Global Const $CDDS_ITEM = 65536
Global Const $CDDS_ITEMPREPAINT = 65537
Global Const $CDDS_ITEMPOSTPAINT = 65538
Global Const $CDDS_ITEMPREERASE = 65539
Global Const $CDDS_ITEMPOSTERASE = 65540
Global Const $CDDS_SUBITEM = 131072
Global Const $CDIS_SELECTED = 1
Global Const $CDIS_GRAYED = 2
Global Const $CDIS_DISABLED = 4
Global Const $CDIS_CHECKED = 8
Global Const $CDIS_FOCUS = 16
Global Const $CDIS_DEFAULT = 32
Global Const $CDIS_HOT = 64
Global Const $CDIS_MARKED = 128
Global Const $CDIS_INDETERMINATE = 256
Global Const $CDIS_SHOWKEYBOARDCUES = 512
Global Const $CDIS_NEARHOT = 1024
Global Const $CDIS_OTHERSIDEHOT = 2048
Global Const $CDIS_DROPHILITED = 4096
Global Const $CDRF_DODEFAULT = 0
Global Const $CDRF_NEWFONT = 2
Global Const $CDRF_SKIPDEFAULT = 4
Global Const $CDRF_NOTIFYPOSTPAINT = 16
Global Const $CDRF_NOTIFYITEMDRAW = 32
Global Const $CDRF_NOTIFYSUBITEMDRAW = 32
Global Const $CDRF_NOTIFYPOSTERASE = 64
Global Const $CDRF_DOERASE = 8
Global Const $CDRF_SKIPPOSTPAINT = 256
Global Const $GUI_SS_DEFAULT_GUI = BitOR($WS_MINIMIZEBOX, $WS_CAPTION, $WS_POPUP, $WS_SYSMENU)
#EndRegion Header
#Region Local Variables and Constants
Global Const $__SS_BITMAP = 14
Global Const $__SS_ICON = 3
Global Const $__STM_SETIMAGE = 370
Global Const $__STM_GETIMAGE = 371
#EndRegion Local Variables and Constants
#Region Public Functions
Func _SETCOMBINEBKICON($HWND, $IBACKGROUND, $SICON1, $IINDEX1 = 0, $IWIDTH1 = -1, $IHEIGHT1 = -1, $SICON2 = "", $IINDEX2 = 0, $IWIDTH2 = -1, $IHEIGHT2 = -1, $IX = 0, $IY = 0, $HOVERLAP = 0)
	$HWND = _ICONS_CONTROL_CHECKHANDLE($HWND)
	If $HWND = 0 Then
		Return SetError(1, 0, 0)
	EndIf
	Local $HPARENT
	If $IBACKGROUND < 0 Then
		$HPARENT = _WINAPI_GETPARENT($HWND)
		IF (BitAND(WinGetState($HPARENT), 2)) AND (Not BitAND(WinGetState($HPARENT), 16)) Then
			$IBACKGROUND = _ICONS_SYSTEM_GETCOLOR($HPARENT)
		EndIf
		If $IBACKGROUND < 0 Then
			$IBACKGROUND = _ICONS_SYSTEM_SWITCHCOLOR(_WINAPI_GETSYSCOLOR($COLOR_3DFACE))
		EndIf
	EndIf
	_ICONS_CONTROL_CHECKSIZE($HWND, $IWIDTH1, $IHEIGHT1)
	_ICONS_CONTROL_CHECKSIZE($HWND, $IWIDTH2, $IHEIGHT2)
	Local $HBACK = _ICONS_ICON_EXTRACT($SICON1, $IINDEX1, $IWIDTH1, $IHEIGHT1)
	Local $HFRONT = _ICONS_ICON_EXTRACT($SICON2, $IINDEX2, $IWIDTH2, $IHEIGHT2)
	Local $HICON = _ICONS_ICON_MERGE($IBACKGROUND, $HBACK, $HFRONT, $IX, $IY, $IWIDTH1, $IHEIGHT1)
	If $HBACK Then
		_WINAPI_DESTROYICON($HBACK)
	EndIf
	If $HFRONT Then
		_WINAPI_DESTROYICON($HFRONT)
	EndIf
	If NOT ($HOVERLAP < 0) Then
		$HOVERLAP = _ICONS_CONTROL_CHECKHANDLE($HOVERLAP)
	EndIf
	If Not _ICONS_CONTROL_SETIMAGE($HWND, $HICON, $IMAGE_ICON, $HOVERLAP) Then
		If $HICON Then
			_WINAPI_DESTROYICON($HICON)
		EndIf
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc
Func _SETICON($HWND, $SICON, $IINDEX = 0, $IWIDTH = -1, $IHEIGHT = -1, $HOVERLAP = 0)
	$HWND = _ICONS_CONTROL_CHECKHANDLE($HWND)
	If $HWND = 0 Then
		Return SetError(1, 0, 0)
	EndIf
	_ICONS_CONTROL_CHECKSIZE($HWND, $IWIDTH, $IHEIGHT)
	Local $HICON = _ICONS_ICON_EXTRACT($SICON, $IINDEX, $IWIDTH, $IHEIGHT)
	If NOT ($HOVERLAP < 0) Then
		$HOVERLAP = _ICONS_CONTROL_CHECKHANDLE($HOVERLAP)
	EndIf
	If Not _ICONS_CONTROL_SETIMAGE($HWND, $HICON, $IMAGE_ICON, $HOVERLAP) Then
		If $HICON Then
			_WINAPI_DESTROYICON($HICON)
		EndIf
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc
Func _SETIMAGE($HWND, $SIMAGE, $HOVERLAP = 0)
	$HWND = _ICONS_CONTROL_CHECKHANDLE($HWND)
	If $HWND = 0 Then
		Return SetError(1, 0, 0)
	EndIf
	Local $RESULT, $HIMAGE, $HBITMAP, $HFIT
	_GDIPLUS_STARTUP()
	$HIMAGE = _GDIPLUS_BITMAPCREATEFROMFILE($SIMAGE)
	$HFIT = _ICONS_CONTROL_FITTO($HWND, $HIMAGE)
	$HBITMAP = _GDIPLUS_BITMAPCREATEHBITMAPFROMBITMAP($HFIT)
	_GDIPLUS_IMAGEDISPOSE($HFIT)
	_GDIPLUS_SHUTDOWN()
	If NOT ($HOVERLAP < 0) Then
		$HOVERLAP = _ICONS_CONTROL_CHECKHANDLE($HOVERLAP)
	EndIf
	$RESULT = _ICONS_CONTROL_SETIMAGE($HWND, $HBITMAP, $IMAGE_BITMAP, $HOVERLAP)
	If $RESULT Then
		$HIMAGE = _SENDMESSAGE($HWND, $__STM_GETIMAGE, $IMAGE_BITMAP, 0)
		IF (@error) OR ($HBITMAP = $HIMAGE) Then
			$HBITMAP = 0
		EndIf
	EndIf
	If $HBITMAP Then
		_WINAPI_DELETEOBJECT($HBITMAP)
	EndIf
	Return SetError(1 - $RESULT, 0, $RESULT)
EndFunc
Func _SETHICON($HWND, $HICON, $HOVERLAP = 0)
	$HWND = _ICONS_CONTROL_CHECKHANDLE($HWND)
	If $HWND = 0 Then
		Return SetError(1, 0, 0)
	EndIf
	If NOT ($HOVERLAP < 0) Then
		$HOVERLAP = _ICONS_CONTROL_CHECKHANDLE($HOVERLAP)
	EndIf
	$HICON = _ICONS_ICON_DUPLICATE($HICON)
	If Not _ICONS_CONTROL_SETIMAGE($HWND, $HICON, $IMAGE_ICON, $HOVERLAP) Then
		If $HICON Then
			_WINAPI_DESTROYICON($HICON)
		EndIf
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc
Func _SETHIMAGE($HWND, $HBITMAP, $HOVERLAP = 0)
	$HWND = _ICONS_CONTROL_CHECKHANDLE($HWND)
	If $HWND = 0 Then
		Return SetError(1, 0, 0)
	EndIf
	Local $RESULT, $HIMAGE
	If NOT ($HOVERLAP < 0) Then
		$HOVERLAP = _ICONS_CONTROL_CHECKHANDLE($HOVERLAP)
	EndIf
	$HBITMAP = _ICONS_BITMAP_DUPLICATE($HBITMAP)
	$RESULT = _ICONS_CONTROL_SETIMAGE($HWND, $HBITMAP, $IMAGE_BITMAP, $HOVERLAP)
	If $RESULT Then
		$HIMAGE = _SENDMESSAGE($HWND, $__STM_GETIMAGE, $IMAGE_BITMAP, 0)
		IF (@error) OR ($HBITMAP = $HIMAGE) Then
			$HBITMAP = 0
		EndIf
	EndIf
	If $HBITMAP Then
		_WINAPI_DELETEOBJECT($HBITMAP)
	EndIf
	Return SetError(1 - $RESULT, 0, $RESULT)
EndFunc
#EndRegion Public Functions
#Region Internal Functions
Func _ICONS_BITMAP_CROP($HBITMAP, $IX, $IY, $IWIDTH, $IHEIGHT)
	If Not _ICONS_BITMAP_ISHBITMAP($HBITMAP) Then
		Return 0
	EndIf
	Local $HDC, $HDESTDC, $HSRCDC, $HBMP
	$HDC = _WINAPI_GETDC(0)
	$HDESTDC = _WINAPI_CREATECOMPATIBLEDC($HDC)
	$HBMP = _WINAPI_CREATECOMPATIBLEBITMAP($HDC, $IWIDTH, $IHEIGHT)
	_WINAPI_SELECTOBJECT($HDESTDC, $HBMP)
	$HSRCDC = _WINAPI_CREATECOMPATIBLEDC($HDC)
	_WINAPI_SELECTOBJECT($HSRCDC, $HBITMAP)
	_WINAPI_RELEASEDC(0, $HDC)
	If Not _WINAPI_BITBLT($HDESTDC, 0, 0, $IWIDTH, $IHEIGHT, $HSRCDC, $IX, $IY, $SRCCOPY) Then
		_WINAPI_DELETEOBJECT($HBMP)
		$HBMP = 0
	EndIf
	_WINAPI_DELETEDC($HDESTDC)
	_WINAPI_DELETEDC($HSRCDC)
	Return $HBMP
EndFunc
Func _ICONS_BITMAP_CREATEFROMICON($HICON)
	Local $TICONINFO = DllStructCreate($TAGICONINFO)
	Local $RET, $HBITMAP
	$RET = DllCall("user32.dll", "int", "GetIconInfo", "ptr", $HICON, "ptr", DllStructGetPtr($TICONINFO))
	IF (@error) OR ($RET[0] = 0) Then
		Return 0
	EndIf
	$HBITMAP = _ICONS_BITMAP_DUPLICATE(DllStructGetData($TICONINFO, 5), 1)
	If Not _ICONS_BITMAP_ISALPHA($HBITMAP) Then
		_GDIPLUS_STARTUP()
		_WINAPI_DELETEOBJECT($HBITMAP)
		$RET = DllCall($GHGDIPDLL, "int", "GdipCreateBitmapFromHICON", "ptr", $HICON, "ptr*", 0)
		IF (Not @error) AND ($RET[0] = 0) Then
			$HBITMAP = _GDIPLUS_BITMAPCREATEHBITMAPFROMBITMAP($RET[2])
			_GDIPLUS_IMAGEDISPOSE($RET[2])
		Else
			$HBITMAP = 0
		EndIf
		_GDIPLUS_SHUTDOWN()
	EndIf
	Return $HBITMAP
EndFunc
Func _ICONS_BITMAP_CREATESOLIDBITMAP($ICOLOR, $IWIDTH, $IHEIGHT)
	Local $HDC, $HMEMDC, $TRECT, $HBITMAP, $HBRUSH, $TRECT = DllStructCreate($TAGRECT)
	DllStructSetData($TRECT, 1, 0)
	DllStructSetData($TRECT, 2, 0)
	DllStructSetData($TRECT, 3, $IWIDTH)
	DllStructSetData($TRECT, 4, $IHEIGHT)
	$HDC = _WINAPI_GETDC(0)
	$HMEMDC = _WINAPI_CREATECOMPATIBLEDC($HDC)
	$HBITMAP = _WINAPI_CREATECOMPATIBLEBITMAP($HDC, $IWIDTH, $IHEIGHT)
	_WINAPI_SELECTOBJECT($HMEMDC, $HBITMAP)
	_WINAPI_RELEASEDC(0, $HDC)
	$HBRUSH = _WINAPI_CREATESOLIDBRUSH(_ICONS_SYSTEM_SWITCHCOLOR($ICOLOR))
	If Not _WINAPI_FILLRECT($HMEMDC, DllStructGetPtr($TRECT), $HBRUSH) Then
		_WINAPI_DELETEOBJECT($HBITMAP)
		$HBITMAP = 0
	EndIf
	_WINAPI_DELETEOBJECT($HBRUSH)
	_WINAPI_DELETEDC($HMEMDC)
	Return $HBITMAP
EndFunc
Func _ICONS_BITMAP_DUPLICATE($HBITMAP, $FDELETE = 0)
	If $FDELETE Then
		$FDELETE = $LR_COPYDELETEORG
	EndIf
	Local $RET = DllCall("user32.dll", "hwnd", "CopyImage", "ptr", $HBITMAP, "int", 0, "int", 0, "int", 0, "int", BitOR($LR_CREATEDIBSECTION, $FDELETE))
	IF (@error) OR ($RET[0] = 0) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $RET[0]
EndFunc
Func _ICONS_BITMAP_GETSIZE($HBITMAP)
	If Not _ICONS_BITMAP_ISHBITMAP($HBITMAP) Then
		Return 0
	EndIf
	Local $TOBJ = DllStructCreate("long Type;long Width;long Height;long WidthBytes;ushort Planes;ushort BitsPixel;ptr Bits")
	Local $RET = DllCall("gdi32.dll", "int", "GetObject", "int", $HBITMAP, "int", DllStructGetSize($TOBJ), "ptr", DllStructGetPtr($TOBJ))
	IF (@error) OR ($RET[0] = 0) Then
		Return 0
	EndIf
	Local $SIZE[2] = [DllStructGetData($TOBJ, "Width"), DllStructGetData($TOBJ, "Height")]
	IF ($SIZE[0] = 0) OR ($SIZE[1] = 0) Then
		Return 0
	EndIf
	Return $SIZE
EndFunc
Func _ICONS_BITMAP_ISALPHA($HBITMAP)
	Local $RET, $LENGHT, $TBITS
	$RET = DllCall("gdi32.dll", "int", "GetBitmapBits", "ptr", $HBITMAP, "long", 0, "ptr", 0)
	IF (@error) OR ($RET[0] = 0) Then
		Return SetError(1, 0, 0)
	EndIf
	$LENGHT = $RET[0] / 4
	$TBITS = DllStructCreate("dword[" & $LENGHT & "]")
	$RET = DllCall("gdi32.dll", "int", "GetBitmapBits", "ptr", $HBITMAP, "long", $RET[0], "ptr", DllStructGetPtr($TBITS))
	IF (@error) OR ($RET[0] = 0) Then
		Return SetError(1, 0, 0)
	EndIf
	For $I = 1 To $LENGHT
		If BitAND(DllStructGetData($TBITS, 1, $I), -16777216) Then
			Return 1
		EndIf
	Next
	Return 0
EndFunc
Func _ICONS_BITMAP_ISHBITMAP($HBITMAP)
	Local $RET = DllCall("gdi32.dll", "dword", "GetObjectType", "ptr", $HBITMAP)
	IF (Not @error) AND ($RET[0] = 7) Then
		Return 1
	EndIf
	Return 0
EndFunc
Func _ICONS_BITMAP_LOAD($SIMAGE)
	_GDIPLUS_STARTUP()
	Local $HIMAGE = _GDIPLUS_IMAGELOADFROMFILE($SIMAGE)
	Local $HBITMAP = _GDIPLUS_BITMAPCREATEHBITMAPFROMBITMAP($HIMAGE)
	_GDIPLUS_IMAGEDISPOSE($HIMAGE)
	_GDIPLUS_SHUTDOWN()
	Return $HBITMAP
EndFunc
Func _ICONS_BITMAP_RESIZE($HBITMAP, $IWIDTH, $IHEIGHT, $FHALFTONE = 0)
	Local $SIZE = _ICONS_BITMAP_GETSIZE($HBITMAP)
	If $SIZE = 0 Then
		Return 0
	EndIf
	Local $RET, $HDC, $HDESTDC, $HSRCDC, $HBMP
	$HDC = _WINAPI_GETDC(0)
	$HDESTDC = _WINAPI_CREATECOMPATIBLEDC($HDC)
	$HBMP = _WINAPI_CREATECOMPATIBLEBITMAP($HDC, $IWIDTH, $IHEIGHT)
	_WINAPI_SELECTOBJECT($HDESTDC, $HBMP)
	$HSRCDC = _WINAPI_CREATECOMPATIBLEDC($HDC)
	_WINAPI_SELECTOBJECT($HSRCDC, $HBITMAP)
	_WINAPI_RELEASEDC(0, $HDC)
	If $FHALFTONE Then
		$FHALFTONE = 4
	Else
		$FHALFTONE = 3
	EndIf
	DllCall("gdi32.dll", "int", "SetStretchBltMode", "hwnd", $HDESTDC, "int", $FHALFTONE)
	$RET = DllCall("gdi32.dll", "int", "StretchBlt", "hwnd", $HDESTDC, "int", 0, "int", 0, "int", $IWIDTH, "int", $IHEIGHT, "hwnd", $HSRCDC, "int", 0, "int", 0, "int", $SIZE[0], "int", $SIZE[1], "dword", $SRCCOPY)
	IF (@error) OR ($RET[0] = 0) Then
		_WINAPI_DELETEOBJECT($HBMP)
		$HBMP = 0
	EndIf
	_WINAPI_DELETEDC($HDESTDC)
	_WINAPI_DELETEDC($HSRCDC)
	Return $HBMP
EndFunc
Func _ICONS_CONTROL_CHECKHANDLE($HWND)
	If Not IsHWnd($HWND) Then
		$HWND = GUICtrlGetHandle($HWND)
		If $HWND = 0 Then
			Return 0
		EndIf
	EndIf
	Return $HWND
EndFunc
Func _ICONS_CONTROL_CHECKSIZE($HWND, ByRef $IX, ByRef $IY)
	Local $SIZE = _ICONS_CONTROL_GETSIZE($HWND)
	If $IX < 1 Then
		If $SIZE = 0 Then
			$IX = _WINAPI_GETSYSTEMMETRICS($SM_CXICON)
		Else
			$IX = $SIZE[0]
		EndIf
	EndIf
	If $IY < 1 Then
		If $SIZE = 0 Then
			$IY = _WINAPI_GETSYSTEMMETRICS($SM_CYICON)
		Else
			$IY = $SIZE[1]
		EndIf
	EndIf
EndFunc
Func _ICONS_CONTROL_ENUM($HWND, $IDIRECTION)
	Local $IWND, $COUNT = 0, $AWND[50] = [$HWND]
	If $IDIRECTION Then
		$IDIRECTION = $GW_HWNDNEXT
	Else
		$IDIRECTION = $GW_HWNDPREV
	EndIf
	While 1
		$IWND = _WINAPI_GETWINDOW($AWND[$COUNT], $IDIRECTION)
		If Not $IWND Then
			ExitLoop
		EndIf
		$COUNT += 1
		If $COUNT = UBound($AWND) Then
			ReDim $AWND[$COUNT + 50]
		EndIf
		$AWND[$COUNT] = $IWND
	WEnd
	ReDim $AWND[$COUNT + 1]
	Return $AWND
EndFunc
Func _ICONS_CONTROL_FITTO($HWND, $HIMAGE)
	Local $SIZE = _ICONS_CONTROL_GETSIZE($HWND)
	If $SIZE = 0 Then
		Return SetError(1, 0, $HIMAGE)
	EndIf
	_GDIPLUS_STARTUP()
	Local $WIDTH = _GDIPLUS_IMAGEGETWIDTH($HIMAGE), $HEIGHT = _GDIPLUS_IMAGEGETHEIGHT($HIMAGE)
	Local $RET, $ERROR = 0
	IF ($WIDTH = -1) OR ($HEIGHT = -1) Then
		$ERROR = 1
	Else
		IF ($WIDTH <> $SIZE[0]) OR ($HEIGHT <> $SIZE[1]) Then
			$RET = DllCall($GHGDIPDLL, "int", "GdipGetImageThumbnail", "ptr", $HIMAGE, "int", $SIZE[0], "int", $SIZE[1], "ptr*", 0, "ptr", 0, "ptr", 0)
			IF (Not @error) AND ($RET[0] = 0) Then
				_GDIPLUS_IMAGEDISPOSE($HIMAGE)
				$HIMAGE = $RET[4]
			Else
				$ERROR = 1
			EndIf
		EndIf
	EndIf
	_GDIPLUS_SHUTDOWN()
	Return SetError($ERROR, 0, $HIMAGE)
EndFunc
Func _ICONS_CONTROL_GETRECT($HWND)
	Local $POS = ControlGetPos($HWND, "", "")
	IF (@error) OR ($POS[2] = 0) OR ($POS[3] = 0) Then
		Return 0
	EndIf
	Local $TRECT = DllStructCreate($TAGRECT)
	DllStructSetData($TRECT, 1, $POS[0])
	DllStructSetData($TRECT, 2, $POS[1])
	DllStructSetData($TRECT, 3, $POS[0] + $POS[2])
	DllStructSetData($TRECT, 4, $POS[1] + $POS[3])
	Return $TRECT
EndFunc
Func _ICONS_CONTROL_GETSIZE($HWND)
	Local $TRECT = DllStructCreate($TAGRECT)
	Local $RET = DllCall("user32.dll", "int", "GetClientRect", "hwnd", $HWND, "ptr", DllStructGetPtr($TRECT))
	IF (@error) OR ($RET[0] = 0) Then
		Return 0
	EndIf
	Local $SIZE[2] = [DllStructGetData($TRECT, 3) - DllStructGetData($TRECT, 1), DllStructGetData($TRECT, 4) - DllStructGetData($TRECT, 2)]
	IF ($SIZE[0] = 0) OR ($SIZE[1] = 0) Then
		Return 0
	EndIf
	Return $SIZE
EndFunc
Func _ICONS_CONTROL_INVALIDATE($HWND)
	Local $TRECT = _ICONS_CONTROL_GETRECT($HWND)
	If IsDllStruct($TRECT) Then
		_WINAPI_INVALIDATERECT(_WINAPI_GETPARENT($HWND), $TRECT)
	EndIf
EndFunc
Func _ICONS_CONTROL_SETIMAGE($HWND, $HIMAGE, $ITYPE, $HOVERLAP)
	Local $STATIC, $STYLE, $UPDATE, $TRECT, $HPREV
	Switch $ITYPE
		Case $IMAGE_BITMAP
			$STATIC = $__SS_BITMAP
		Case $IMAGE_ICON
			$STATIC = $__SS_ICON
		Case Else
			Return 0
	EndSwitch
	$STYLE = _WINAPI_GETWINDOWLONG($HWND, $GWL_STYLE)
	If @error Then
		Return 0
	EndIf
	_WINAPI_SETWINDOWLONG($HWND, $GWL_STYLE, BitOR($STYLE, $STATIC))
	If @error Then
		Return 0
	EndIf
	$TRECT = _ICONS_CONTROL_GETRECT($HWND)
	$HPREV = _SENDMESSAGE($HWND, $__STM_SETIMAGE, $ITYPE, $HIMAGE)
	If @error Then
		Return 0
	EndIf
	If $HPREV Then
		If $ITYPE = $IMAGE_BITMAP Then
			_WINAPI_DELETEOBJECT($HPREV)
		Else
			_WINAPI_DESTROYICON($HPREV)
		EndIf
	EndIf
	IF (Not $HIMAGE) AND (IsDllStruct($TRECT)) Then
		_WINAPI_MOVEWINDOW($HWND, DllStructGetData($TRECT, 1), DllStructGetData($TRECT, 2), DllStructGetData($TRECT, 3) - DllStructGetData($TRECT, 1), DllStructGetData($TRECT, 4) - DllStructGetData($TRECT, 2), 0)
	EndIf
	If $HOVERLAP Then
		If Not IsHWnd($HOVERLAP) Then
			$HOVERLAP = 0
		EndIf
		_ICONS_CONTROL_UPDATE($HWND, $HOVERLAP)
	Else
		_ICONS_CONTROL_INVALIDATE($HWND)
	EndIf
	Return 1
EndFunc
Func _ICONS_CONTROL_UPDATE($HWND, $HOVERLAP)
	Local $TBACK, $TFRONT = _ICONS_CONTROL_GETRECT($HWND)
	If $TFRONT = 0 Then
		Return
	EndIf
	Local $ANEXT = _ICONS_CONTROL_ENUM($HWND, 1)
	Local $APREV = _ICONS_CONTROL_ENUM($HWND, 0)
	If UBound($APREV) = 1 Then
		_WINAPI_INVALIDATERECT(_WINAPI_GETPARENT($HWND), $TFRONT)
		Return
	EndIf
	Local $AWND[UBound($ANEXT) + UBound($APREV - 1)]
	Local $TINTERSECT = DllStructCreate($TAGRECT), $PINTERSECT = DllStructGetPtr($TINTERSECT)
	Local $IWND, $RET, $XOFFSET, $YOFFSET, $COUNT = 0, $UPDATE = 0
	For $I = UBound($APREV) - 1 To 1 Step -1
		$AWND[$COUNT] = $APREV[$I]
		$COUNT += 1
	Next
	For $I = 0 To UBound($ANEXT) - 1
		$AWND[$COUNT] = $ANEXT[$I]
		$COUNT += 1
	Next
	For $I = 0 To $COUNT - 1
		If $AWND[$I] = $HWND Then
			_WINAPI_INVALIDATERECT($HWND)
		Else
			IF (Not $HOVERLAP) OR ($AWND[$I] = $HOVERLAP) Then
				$TBACK = _ICONS_CONTROL_GETRECT($AWND[$I])
				$RET = DllCall("user32.dll", "int", "IntersectRect", "ptr", $PINTERSECT, "ptr", DllStructGetPtr($TFRONT), "ptr", DllStructGetPtr($TBACK))
				IF (Not @error) AND ($RET[0]) Then
					$RET = DllCall("user32.dll", "int", "IsRectEmpty", "ptr", $PINTERSECT)
					IF (Not @error) AND (Not $RET[0]) Then
						$XOFFSET = DllStructGetData($TBACK, 1)
						$YOFFSET = DllStructGetData($TBACK, 2)
						$RET = DllCall("user32.dll", "int", "OffsetRect", "ptr", $PINTERSECT, "int", -$XOFFSET, "int", -$YOFFSET)
						IF (Not @error) AND ($RET[0]) Then
							_WINAPI_INVALIDATERECT($AWND[$I], $TINTERSECT)
							$UPDATE += 1
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
	Next
	If Not $UPDATE Then
		_WINAPI_INVALIDATERECT(_WINAPI_GETPARENT($HWND), $TFRONT)
	EndIf
EndFunc
Func _ICONS_ICON_DUPLICATE($HICON)
	If $HICON Then
		Return _WINAPI_COPYICON($HICON)
	EndIf
	Return 0
EndFunc
Func _ICONS_ICON_EXTRACT($SICON, $IINDEX, $IWIDTH, $IHEIGHT)
	Local $RET = DllCall("shell32.dll", "int", "SHExtractIconsW", "wstr", $SICON, "int", $IINDEX, "int", $IWIDTH, "int", $IHEIGHT, "ptr*", 0, "ptr*", 0, "int", 1, "int", 0)
	IF (@error) OR ($RET[0] = 0) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $RET[5]
EndFunc
Func _ICONS_ICON_CREATEFROMBITMAP($HBITMAP)
	Local $SIZE = _ICONS_BITMAP_GETSIZE($HBITMAP)
	If $SIZE = 0 Then
		Return 0
	EndIf
	Local $TICONINFO = DllStructCreate($TAGICONINFO)
	Local $HMASK = _ICONS_BITMAP_CREATESOLIDBITMAP(0, $SIZE[0], $SIZE[1])
	Local $HICON = 0
	DllStructSetData($TICONINFO, 1, 1)
	DllStructSetData($TICONINFO, 2, 0)
	DllStructSetData($TICONINFO, 3, 0)
	DllStructSetData($TICONINFO, 4, $HMASK)
	DllStructSetData($TICONINFO, 5, $HBITMAP)
	Local $RET = DllCall("user32.dll", "ptr", "CreateIconIndirect", "ptr", DllStructGetPtr($TICONINFO))
	IF (Not @error) AND ($RET[0]) Then
		$HICON = $RET[0]
	EndIf
	_WINAPI_DELETEOBJECT($HMASK)
	Return $HICON
EndFunc
Func _ICONS_ICON_GETSIZE($HICON)
	Local $TICONINFO = DllStructCreate($TAGICONINFO)
	Local $RET = DllCall("user32.dll", "int", "GetIconInfo", "ptr", $HICON, "ptr", DllStructGetPtr($TICONINFO))
	IF (@error) OR ($RET[0] = 0) Then
		Return 0
	EndIf
	Local $SIZE = _ICONS_BITMAP_GETSIZE(DllStructGetData($TICONINFO, 5))
	_WINAPI_DELETEOBJECT(DllStructGetData($TICONINFO, 4))
	_WINAPI_DELETEOBJECT(DllStructGetData($TICONINFO, 5))
	IF ($SIZE[0] = 0) OR ($SIZE[1] = 0) Then
		Return 0
	EndIf
	Return $SIZE
EndFunc
Func _ICONS_ICON_MERGE($IBACKGROUND, $HBACK, $HFRONT, $IX, $IY, $IWIDTH = -1, $IHEIGHT = -1)
	Local $SIZE
	IF ($IWIDTH < 1) OR ($IHEIGHT < 1) Then
		$SIZE = _ICONS_ICON_GETSIZE($HBACK)
		If $SIZE = 0 Then
			Return 0
		EndIf
		If $IWIDTH < 1 Then
			$IWIDTH = $SIZE[0]
		EndIf
		If $IHEIGHT < 1 Then
			$IHEIGHT = $SIZE[0]
		EndIf
	EndIf
	Local $HDC, $HMEMDC, $HIMAGE, $HBITMAP, $HICON
	$HDC = _WINAPI_GETDC(0)
	$HMEMDC = _WINAPI_CREATECOMPATIBLEDC($HDC)
	$HBITMAP = _ICONS_BITMAP_CREATESOLIDBITMAP($IBACKGROUND, $IWIDTH, $IHEIGHT)
	_WINAPI_SELECTOBJECT($HMEMDC, $HBITMAP)
	_WINAPI_RELEASEDC(0, $HDC)
	If $HBACK Then
		_WINAPI_DRAWICONEX($HMEMDC, 0, 0, $HBACK, 0, 0, 0, 0, $DI_NORMAL)
	EndIf
	If $HFRONT Then
		_WINAPI_DRAWICONEX($HMEMDC, $IX, $IY, $HFRONT, 0, 0, 0, 0, $DI_NORMAL)
	EndIf
	_GDIPLUS_STARTUP()
	$HIMAGE = _GDIPLUS_BITMAPCREATEFROMHBITMAP($HBITMAP)
	$HICON = DllCall($GHGDIPDLL, "int", "GdipCreateHICONFromBitmap", "ptr", $HIMAGE, "ptr*", 0)
	IF (Not @error) AND ($HICON[0] = 0) Then
		$HICON = $HICON[2]
	Else
		$HICON = 0
	EndIf
	_GDIPLUS_IMAGEDISPOSE($HIMAGE)
	_GDIPLUS_SHUTDOWN()
	_WINAPI_DELETEOBJECT($HBITMAP)
	_WINAPI_DELETEDC($HMEMDC)
	Return $HICON
EndFunc
Func _ICONS_SYSTEM_GETCOLOR($HWND)
	Local $RET, $HDC = _WINAPI_GETDC($HWND)
	If $HDC = 0 Then
		Return -1
	EndIf
	$RET = DllCall("gdi32.dll", "int", "GetBkColor", "hwnd", $HDC)
	IF (@error) OR ($RET[0] < 0) Then
		$RET = -1
	EndIf
	_WINAPI_RELEASEDC($HWND, $HDC)
	If $RET < 0 Then
		Return -1
	EndIf
	Return _ICONS_SYSTEM_SWITCHCOLOR($RET[0])
EndFunc
Func _ICONS_SYSTEM_SWITCHCOLOR($ICOLOR)
	Return BitOR(BitAND($ICOLOR, 65280), BitShift(BitAND($ICOLOR, 255), -16), BitShift(BitAND($ICOLOR, 16711680), 16))
EndFunc
#EndRegion Internal Functions
Global $LOADER_FORM, $LOADER_STATUSBAR
Func _LOADERSTART()
	$LOADER_FORM = GUICreate("", 250, 150, -1, -1, BitOR(-2147483648, 8388608), 8)
	GUICtrlCreateIcon(@ScriptDir & "\Doors\Themes\Stroke.ani", -1, (250 - 32) / 2, 15, 32, 32)
	GUICtrlCreateLabel("Loading Doors...", 1, 65, 248, -1, 1)
	GUICtrlSetFont(-1, 10, -1, -1, "Tahoma", 5)
	GUICtrlCreateLabel("", 9, 99, 232, 12)
	GUICtrlSetBkColor(-1, 0)
	GUICtrlCreateLabel("", 10, 100, 230, 10)
	GUICtrlSetBkColor(-1, 12632256)
	$LOADER_STATUSBAR = GUICtrlCreateLabel("", 11, 101, 0, 8)
	GUICtrlSetBkColor($LOADER_STATUSBAR, 0)
	GUICtrlSetState($LOADER_STATUSBAR, 32)
	GUISetState(@SW_SHOW, $LOADER_FORM)
	Return 0
EndFunc
Func _LOADERUPDATE($ISTATUSPERCENT)
	If $ISTATUSPERCENT > -1 Then
		If $ISTATUSPERCENT > 100 Then $ISTATUSPERCENT = 100
		If $ISTATUSPERCENT = 0 Then
			GUICtrlSetState($LOADER_STATUSBAR, 32)
		Else
			GUICtrlSetState($LOADER_STATUSBAR, 16)
			GUICtrlSetPos($LOADER_STATUSBAR, 11, 101, 228 * $ISTATUSPERCENT / 100)
		EndIf
		If $ISTATUSPERCENT = 100 Then
			GUIDelete($LOADER_FORM)
		EndIf
	EndIf
	Return 0
EndFunc
Func _WINAPI_ABOUTDLG($STITLE, $SNAME, $STEXT, $HICON = 0, $HPARENT = 0)
	Local $RET = DllCall("shell32.dll", "int", "ShellAboutW", "hwnd", $HPARENT, "wstr", $STITLE & "#" & $SNAME, "wstr", $STEXT, "ptr", $HICON)
	IF (@error) OR (Not $RET[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc
Func _WINAPI_EMPTYWORKINGSET($PID = 0)
	If Not $PID Then
		$PID = _WINAPI_GETCURRENTPROCESSID()
		If Not $PID Then
			Return SetError(1, 0, 0)
		EndIf
	EndIf
	Local $HPROCESS = DllCall("kernel32.dll", "ptr", "OpenProcess", "dword", 2035711, "int", 0, "dword", $PID)
	IF (@error) OR (Not $HPROCESS[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Local $RET = DllCall(@SystemDir & "\psapi.dll", "int", "EmptyWorkingSet", "ptr", $HPROCESS[0])
	IF (@error) OR (Not $RET[0]) Then
		$RET = 0
	EndIf
	_WINAPI_CLOSEHANDLE($HPROCESS[0])
	If Not IsArray($RET) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc
Func _WINAPI_GETKEYSTATE($VKEY)
	Local $RET = DllCall("user32.dll", "int", "GetKeyState", "int", $VKEY)
	If @error Then
		Return SetError(1, 0, 0)
	EndIf
	Return $RET[0]
EndFunc
Func _WINAPI_SHELLEXTRACTICON($SICON, $IINDEX, $IWIDTH, $IHEIGHT)
	Local $RET = DllCall("shell32.dll", "int", "SHExtractIconsW", "wstr", $SICON, "int", $IINDEX, "int", $IWIDTH, "int", $IHEIGHT, "ptr*", 0, "ptr*", 0, "int", 1, "int", 0)
	IF (@error) OR (Not $RET[0]) OR (Not $RET[5]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $RET[5]
EndFunc
Global Const $SETTINGS_DOORS = @ScriptDir & "\Structure\Doors.ini"
Global $SET_DEFMODE = IniRead($SETTINGS_DOORS, "Development", "DoorsDevMode", 0)
Global Const $ES_LEFT = 0
Global Const $ES_CENTER = 1
Global Const $ES_RIGHT = 2
Global Const $ES_MULTILINE = 4
Global Const $ES_UPPERCASE = 8
Global Const $ES_LOWERCASE = 16
Global Const $ES_PASSWORD = 32
Global Const $ES_AUTOVSCROLL = 64
Global Const $ES_AUTOHSCROLL = 128
Global Const $ES_NOHIDESEL = 256
Global Const $ES_OEMCONVERT = 1024
Global Const $ES_READONLY = 2048
Global Const $ES_WANTRETURN = 4096
Global Const $ES_NUMBER = 8192
Global Const $EC_ERR = -1
Global Const $ECM_FIRST = 5376
Global Const $EM_CANUNDO = 198
Global Const $EM_CHARFROMPOS = 215
Global Const $EM_EMPTYUNDOBUFFER = 205
Global Const $EM_FMTLINES = 200
Global Const $EM_GETCUEBANNER = ($ECM_FIRST + 2)
Global Const $EM_GETFIRSTVISIBLELINE = 206
Global Const $EM_GETHANDLE = 189
Global Const $EM_GETIMESTATUS = 217
Global Const $EM_GETLIMITTEXT = 213
Global Const $EM_GETLINE = 196
Global Const $EM_GETLINECOUNT = 186
Global Const $EM_GETMARGINS = 212
Global Const $EM_GETMODIFY = 184
Global Const $EM_GETPASSWORDCHAR = 210
Global Const $EM_GETRECT = 178
Global Const $EM_GETSEL = 176
Global Const $EM_GETTHUMB = 190
Global Const $EM_GETWORDBREAKPROC = 209
Global Const $EM_HIDEBALLOONTIP = ($ECM_FIRST + 4)
Global Const $EM_LIMITTEXT = 197
Global Const $EM_LINEFROMCHAR = 201
Global Const $EM_LINEINDEX = 187
Global Const $EM_LINELENGTH = 193
Global Const $EM_LINESCROLL = 182
Global Const $EM_POSFROMCHAR = 214
Global Const $EM_REPLACESEL = 194
Global Const $EM_SCROLL = 181
Global Const $EM_SCROLLCARET = 183
Global Const $EM_SETCUEBANNER = ($ECM_FIRST + 1)
Global Const $EM_SETHANDLE = 188
Global Const $EM_SETIMESTATUS = 216
Global Const $EM_SETLIMITTEXT = $EM_LIMITTEXT
Global Const $EM_SETMARGINS = 211
Global Const $EM_SETMODIFY = 185
Global Const $EM_SETPASSWORDCHAR = 204
Global Const $EM_SETREADONLY = 207
Global Const $EM_SETRECT = 179
Global Const $EM_SETRECTNP = 180
Global Const $EM_SETSEL = 177
Global Const $EM_SETTABSTOPS = 203
Global Const $EM_SETWORDBREAKPROC = 208
Global Const $EM_SHOWBALLOONTIP = ($ECM_FIRST + 3)
Global Const $EM_UNDO = 199
Global Const $EC_LEFTMARGIN = 1
Global Const $EC_RIGHTMARGIN = 2
Global Const $EC_USEFONTINFO = 65535
Global Const $EMSIS_COMPOSITIONSTRING = 1
Global Const $EIMES_GETCOMPSTRATONCE = 1
Global Const $EIMES_CANCELCOMPSTRINFOCUS = 2
Global Const $EIMES_COMPLETECOMPSTRKILLFOCUS = 4
Global Const $EN_ALIGN_LTR_EC = 1792
Global Const $EN_ALIGN_RTL_EC = 1793
Global Const $EN_CHANGE = 768
Global Const $EN_ERRSPACE = 1280
Global Const $EN_HSCROLL = 1537
Global Const $EN_KILLFOCUS = 512
Global Const $EN_MAXTEXT = 1281
Global Const $EN_SETFOCUS = 256
Global Const $EN_UPDATE = 1024
Global Const $EN_VSCROLL = 1538
Global Const $TTI_NONE = 0
Global Const $TTI_INFO = 1
Global Const $TTI_WARNING = 2
Global Const $TTI_ERROR = 3
Global Const $TTI_INFO_LARGE = 4
Global Const $TTI_WARNING_LARGE = 5
Global Const $TTI_ERROR_LARGE = 6
Global Const $__EDITCONSTANT_WS_VSCROLL = 2097152
Global Const $__EDITCONSTANT_WS_HSCROLL = 1048576
Global Const $GUI_SS_DEFAULT_EDIT = BitOR($ES_WANTRETURN, $__EDITCONSTANT_WS_VSCROLL, $__EDITCONSTANT_WS_HSCROLL, $ES_AUTOVSCROLL, $ES_AUTOHSCROLL)
Global Const $GUI_SS_DEFAULT_INPUT = BitOR($ES_LEFT, $ES_AUTOHSCROLL)
Global Const $SBARS_SIZEGRIP = 256
Global Const $SBT_TOOLTIPS = 2048
Global Const $SBARS_TOOLTIPS = 2048
Global Const $SBT_SUNKEN = 0
Global Const $SBT_NOBORDERS = 256
Global Const $SBT_POPOUT = 512
Global Const $SBT_RTLREADING = 1024
Global Const $SBT_NOTABPARSING = 2048
Global Const $SBT_OWNERDRAW = 4096
Global Const $__STATUSBARCONSTANT_WM_USER = 1024
Global Const $SB_GETBORDERS = ($__STATUSBARCONSTANT_WM_USER + 7)
Global Const $SB_GETICON = ($__STATUSBARCONSTANT_WM_USER + 20)
Global Const $SB_GETPARTS = ($__STATUSBARCONSTANT_WM_USER + 6)
Global Const $SB_GETRECT = ($__STATUSBARCONSTANT_WM_USER + 10)
Global Const $SB_GETTEXTA = ($__STATUSBARCONSTANT_WM_USER + 2)
Global Const $SB_GETTEXTW = ($__STATUSBARCONSTANT_WM_USER + 13)
Global Const $SB_GETTEXT = $SB_GETTEXTA
Global Const $SB_GETTEXTLENGTHA = ($__STATUSBARCONSTANT_WM_USER + 3)
Global Const $SB_GETTEXTLENGTHW = ($__STATUSBARCONSTANT_WM_USER + 12)
Global Const $SB_GETTEXTLENGTH = $SB_GETTEXTLENGTHA
Global Const $SB_GETTIPTEXTA = ($__STATUSBARCONSTANT_WM_USER + 18)
Global Const $SB_GETTIPTEXTW = ($__STATUSBARCONSTANT_WM_USER + 19)
Global Const $SB_GETUNICODEFORMAT = 8192 + 6
Global Const $SB_ISSIMPLE = ($__STATUSBARCONSTANT_WM_USER + 14)
Global Const $SB_SETBKCOLOR = 8192 + 1
Global Const $SB_SETICON = ($__STATUSBARCONSTANT_WM_USER + 15)
Global Const $SB_SETMINHEIGHT = ($__STATUSBARCONSTANT_WM_USER + 8)
Global Const $SB_SETPARTS = ($__STATUSBARCONSTANT_WM_USER + 4)
Global Const $SB_SETTEXTA = ($__STATUSBARCONSTANT_WM_USER + 1)
Global Const $SB_SETTEXTW = ($__STATUSBARCONSTANT_WM_USER + 11)
Global Const $SB_SETTEXT = $SB_SETTEXTA
Global Const $SB_SETTIPTEXTA = ($__STATUSBARCONSTANT_WM_USER + 16)
Global Const $SB_SETTIPTEXTW = ($__STATUSBARCONSTANT_WM_USER + 17)
Global Const $SB_SETUNICODEFORMAT = 8192 + 5
Global Const $SB_SIMPLE = ($__STATUSBARCONSTANT_WM_USER + 9)
Global Const $SB_SIMPLEID = 255
Global Const $SBN_FIRST = -880
Global Const $SBN_SIMPLEMODECHANGE = $SBN_FIRST - 0
Global Const $_UDF_GLOBALIDS_OFFSET = 2
Global Const $_UDF_GLOBALID_MAX_WIN = 16
Global Const $_UDF_STARTID = 10000
Global Const $_UDF_GLOBALID_MAX_IDS = 55535
Global Const $__UDFGUICONSTANT_WS_VISIBLE = 268435456
Global Const $__UDFGUICONSTANT_WS_CHILD = 1073741824
Global $_UDF_GLOBALIDS_USED[$_UDF_GLOBALID_MAX_WIN][$_UDF_GLOBALID_MAX_IDS + $_UDF_GLOBALIDS_OFFSET + 1]
Func __UDF_GETNEXTGLOBALID($HWND)
	Local $NCTRLID, $IUSEDINDEX = -1, $FALLUSED = True
	If Not WinExists($HWND) Then Return SetError(-1, -1, 0)
	For $IINDEX = 0 To $_UDF_GLOBALID_MAX_WIN - 1
		If $_UDF_GLOBALIDS_USED[$IINDEX][0] <> 0 Then
			If Not WinExists($_UDF_GLOBALIDS_USED[$IINDEX][0]) Then
				For $X = 0 To UBound($_UDF_GLOBALIDS_USED, 2) - 1
					$_UDF_GLOBALIDS_USED[$IINDEX][$X] = 0
				Next
				$_UDF_GLOBALIDS_USED[$IINDEX][1] = $_UDF_STARTID
				$FALLUSED = False
			EndIf
		EndIf
	Next
	For $IINDEX = 0 To $_UDF_GLOBALID_MAX_WIN - 1
		If $_UDF_GLOBALIDS_USED[$IINDEX][0] = $HWND Then
			$IUSEDINDEX = $IINDEX
			ExitLoop
		EndIf
	Next
	If $IUSEDINDEX = -1 Then
		For $IINDEX = 0 To $_UDF_GLOBALID_MAX_WIN - 1
			If $_UDF_GLOBALIDS_USED[$IINDEX][0] = 0 Then
				$_UDF_GLOBALIDS_USED[$IINDEX][0] = $HWND
				$_UDF_GLOBALIDS_USED[$IINDEX][1] = $_UDF_STARTID
				$FALLUSED = False
				$IUSEDINDEX = $IINDEX
				ExitLoop
			EndIf
		Next
	EndIf
	If $IUSEDINDEX = -1 And $FALLUSED Then Return SetError(16, 0, 0)
	If $_UDF_GLOBALIDS_USED[$IUSEDINDEX][1] = $_UDF_STARTID + $_UDF_GLOBALID_MAX_IDS Then
		For $IIDINDEX = $_UDF_GLOBALIDS_OFFSET To UBound($_UDF_GLOBALIDS_USED, 2) - 1
			If $_UDF_GLOBALIDS_USED[$IUSEDINDEX][$IIDINDEX] = 0 Then
				$NCTRLID = ($IIDINDEX - $_UDF_GLOBALIDS_OFFSET) + 10000
				$_UDF_GLOBALIDS_USED[$IUSEDINDEX][$IIDINDEX] = $NCTRLID
				Return $NCTRLID
			EndIf
		Next
		Return SetError(-1, $_UDF_GLOBALID_MAX_IDS, 0)
	EndIf
	$NCTRLID = $_UDF_GLOBALIDS_USED[$IUSEDINDEX][1]
	$_UDF_GLOBALIDS_USED[$IUSEDINDEX][1] += 1
	$_UDF_GLOBALIDS_USED[$IUSEDINDEX][($NCTRLID - 10000) + $_UDF_GLOBALIDS_OFFSET] = $NCTRLID
	Return $NCTRLID
EndFunc
Func __UDF_FREEGLOBALID($HWND, $IGLOBALID)
	If $IGLOBALID - $_UDF_STARTID < 0 Or $IGLOBALID - $_UDF_STARTID > $_UDF_GLOBALID_MAX_IDS Then Return SetError(-1, 0, False)
	For $IINDEX = 0 To $_UDF_GLOBALID_MAX_WIN - 1
		If $_UDF_GLOBALIDS_USED[$IINDEX][0] = $HWND Then
			For $X = $_UDF_GLOBALIDS_OFFSET To UBound($_UDF_GLOBALIDS_USED, 2) - 1
				If $_UDF_GLOBALIDS_USED[$IINDEX][$X] = $IGLOBALID Then
					$_UDF_GLOBALIDS_USED[$IINDEX][$X] = 0
					Return True
				EndIf
			Next
			Return SetError(-3, 0, False)
		EndIf
	Next
	Return SetError(-2, 0, False)
EndFunc
Func __UDF_DEBUGPRINT($STEXT, $ILINE = @ScriptLineNumber, $ERR = @error, $EXT = @extended)
	ConsoleWrite("!===========================================================" & @CRLF & "+======================================================" & @CRLF & "-->Line(" & StringFormat("%04d", $ILINE) & "):" & @TAB & $STEXT & @CRLF & "+======================================================" & @CRLF)
	Return SetError($ERR, $EXT, 1)
EndFunc
Func __UDF_VALIDATECLASSNAME($HWND, $SCLASSNAMES)
	__UDF_DEBUGPRINT("This is for debugging only, set the debug variable to false before submitting")
	If _WINAPI_ISCLASSNAME($HWND, $SCLASSNAMES) Then Return True
	Local $SSEPARATOR = Opt("GUIDataSeparatorChar")
	$SCLASSNAMES = StringReplace($SCLASSNAMES, $SSEPARATOR, ",")
	__UDF_DEBUGPRINT("Invalid Class Type(s):" & @LF & @TAB & "Expecting Type(s): " & $SCLASSNAMES & @LF & @TAB & "Received Type : " & _WINAPI_GETCLASSNAME($HWND))
	Exit
EndFunc
Global $__GHSBLASTWND
Global $DEBUG_SB = False
Global Const $__STATUSBARCONSTANT_CLASSNAME = "msctls_statusbar32"
Global Const $__STATUSBARCONSTANT_WM_SIZE = 5
Global Const $__STATUSBARCONSTANT_CLR_DEFAULT = -16777216
Global Const $TAGBORDERS = "int BX;int BY;int RX"
Func _GUICTRLSTATUSBAR_CREATE($HWND, $VPARTEDGE = -1, $VPARTTEXT = "", $ISTYLES = -1, $IEXSTYLES = -1)
	If Not IsHWnd($HWND) Then Return SetError(1, 0, 0)
	Local $ISTYLE = BitOR($__UDFGUICONSTANT_WS_CHILD, $__UDFGUICONSTANT_WS_VISIBLE)
	If $ISTYLES = -1 Then $ISTYLES = 0
	If $IEXSTYLES = -1 Then $IEXSTYLES = 0
	Local $APARTWIDTH[1], $APARTTEXT[1]
	If @NumParams > 1 Then
		If IsArray($VPARTEDGE) Then
			$APARTWIDTH = $VPARTEDGE
		Else
			$APARTWIDTH[0] = $VPARTEDGE
		EndIf
		If @NumParams = 2 Then
			ReDim $APARTTEXT[UBound($APARTWIDTH)]
		Else
			If IsArray($VPARTTEXT) Then
				$APARTTEXT = $VPARTTEXT
			Else
				$APARTTEXT[0] = $VPARTTEXT
			EndIf
			If UBound($APARTWIDTH) <> UBound($APARTTEXT) Then
				Local $ILAST
				If UBound($APARTWIDTH) > UBound($APARTTEXT) Then
					$ILAST = UBound($APARTTEXT)
					ReDim $APARTTEXT[UBound($APARTWIDTH)]
					For $X = $ILAST To UBound($APARTTEXT) - 1
						$APARTWIDTH[$X] = ""
					Next
				Else
					$ILAST = UBound($APARTWIDTH)
					ReDim $APARTWIDTH[UBound($APARTTEXT)]
					For $X = $ILAST To UBound($APARTWIDTH) - 1
						$APARTWIDTH[$X] = $APARTWIDTH[$X - 1] + 75
					Next
					$APARTWIDTH[UBound($APARTTEXT) - 1] = -1
				EndIf
			EndIf
		EndIf
		If Not IsHWnd($HWND) Then $HWND = HWnd($HWND)
		If @NumParams > 3 Then $ISTYLE = BitOR($ISTYLE, $ISTYLES)
	EndIf
	Local $NCTRLID = __UDF_GETNEXTGLOBALID($HWND)
	If @error Then Return SetError(@error, @extended, 0)
	Local $HWNDSBAR = _WINAPI_CREATEWINDOWEX($IEXSTYLES, $__STATUSBARCONSTANT_CLASSNAME, "", $ISTYLE, 0, 0, 0, 0, $HWND, $NCTRLID)
	If @error Then Return SetError(@error, @extended, 0)
	If @NumParams > 1 Then
		_GUICTRLSTATUSBAR_SETPARTS($HWNDSBAR, UBound($APARTWIDTH), $APARTWIDTH)
		For $X = 0 To UBound($APARTTEXT) - 1
			_GUICTRLSTATUSBAR_SETTEXT($HWNDSBAR, $APARTTEXT[$X], $X)
		Next
	EndIf
	Return $HWNDSBAR
EndFunc
Func _GUICTRLSTATUSBAR_DESTROY(ByRef $HWND)
	If $DEBUG_SB Then __UDF_VALIDATECLASSNAME($HWND, $__STATUSBARCONSTANT_CLASSNAME)
	If Not _WINAPI_ISCLASSNAME($HWND, $__STATUSBARCONSTANT_CLASSNAME) Then Return SetError(2, 2, False)
	Local $DESTROYED = 0
	If IsHWnd($HWND) Then
		If _WINAPI_INPROCESS($HWND, $__GHSBLASTWND) Then
			Local $NCTRLID = _WINAPI_GETDLGCTRLID($HWND)
			Local $HPARENT = _WINAPI_GETPARENT($HWND)
			$DESTROYED = _WINAPI_DESTROYWINDOW($HWND)
			Local $IRET = __UDF_FREEGLOBALID($HPARENT, $NCTRLID)
			If Not $IRET Then
			EndIf
		Else
			Return SetError(1, 1, False)
		EndIf
	EndIf
	If $DESTROYED Then $HWND = 0
	Return $DESTROYED <> 0
EndFunc
Func _GUICTRLSTATUSBAR_EMBEDCONTROL($HWND, $IPART, $HCONTROL, $IFIT = 4)
	Local $ARECT = _GUICTRLSTATUSBAR_GETRECT($HWND, $IPART)
	Local $IBARX = $ARECT[0]
	Local $IBARY = $ARECT[1]
	Local $IBARW = $ARECT[2] - $IBARX
	Local $IBARH = $ARECT[3] - $IBARY
	Local $ICONX = $IBARX
	Local $ICONY = $IBARY
	Local $ICONW = _WINAPI_GETWINDOWWIDTH($HCONTROL)
	Local $ICONH = _WINAPI_GETWINDOWHEIGHT($HCONTROL)
	If $ICONW > $IBARW Then $ICONW = $IBARW
	If $ICONH > $IBARH Then $ICONH = $IBARH
	Local $IPADX = ($IBARW - $ICONW) / 2
	Local $IPADY = ($IBARH - $ICONH) / 2
	If $IPADX < 0 Then $IPADX = 0
	If $IPADY < 0 Then $IPADY = 0
	If BitAND($IFIT, 1) = 1 Then $ICONX = $IBARX + $IPADX
	If BitAND($IFIT, 2) = 2 Then $ICONY = $IBARY + $IPADY
	If BitAND($IFIT, 4) = 4 Then
		$IPADX = _GUICTRLSTATUSBAR_GETBORDERSRECT($HWND)
		$IPADY = _GUICTRLSTATUSBAR_GETBORDERSVERT($HWND)
		$ICONX = $IBARX
		If _GUICTRLSTATUSBAR_ISSIMPLE($HWND) Then $ICONX += $IPADX
		$ICONY = $IBARY + $IPADY
		$ICONW = $IBARW - ($IPADX * 2)
		$ICONH = $IBARH - ($IPADY * 2)
	EndIf
	_WINAPI_SETPARENT($HCONTROL, $HWND)
	_WINAPI_MOVEWINDOW($HCONTROL, $ICONX, $ICONY, $ICONW, $ICONH)
EndFunc
Func _GUICTRLSTATUSBAR_GETBORDERS($HWND)
	If $DEBUG_SB Then __UDF_VALIDATECLASSNAME($HWND, $__STATUSBARCONSTANT_CLASSNAME)
	Local $TBORDERS = DllStructCreate($TAGBORDERS)
	Local $IRET
	If _WINAPI_INPROCESS($HWND, $__GHSBLASTWND) Then
		$IRET = _SENDMESSAGE($HWND, $SB_GETBORDERS, 0, $TBORDERS, 0, "wparam", "struct*")
	Else
		Local $ISIZE = DllStructGetSize($TBORDERS)
		Local $TMEMMAP
		Local $PMEMORY = _MEMINIT($HWND, $ISIZE, $TMEMMAP)
		$IRET = _SENDMESSAGE($HWND, $SB_GETBORDERS, 0, $PMEMORY, 0, "wparam", "ptr")
		_MEMREAD($TMEMMAP, $PMEMORY, $TBORDERS, $ISIZE)
		_MEMFREE($TMEMMAP)
	EndIf
	Local $ABORDERS[3]
	If $IRET = 0 Then Return SetError(-1, -1, $ABORDERS)
	$ABORDERS[0] = DllStructGetData($TBORDERS, "BX")
	$ABORDERS[1] = DllStructGetData($TBORDERS, "BY")
	$ABORDERS[2] = DllStructGetData($TBORDERS, "RX")
	Return $ABORDERS
EndFunc
Func _GUICTRLSTATUSBAR_GETBORDERSHORZ($HWND)
	Local $ABORDERS = _GUICTRLSTATUSBAR_GETBORDERS($HWND)
	Return SetError(@error, @extended, $ABORDERS[0])
EndFunc
Func _GUICTRLSTATUSBAR_GETBORDERSRECT($HWND)
	Local $ABORDERS = _GUICTRLSTATUSBAR_GETBORDERS($HWND)
	Return SetError(@error, @extended, $ABORDERS[2])
EndFunc
Func _GUICTRLSTATUSBAR_GETBORDERSVERT($HWND)
	Local $ABORDERS = _GUICTRLSTATUSBAR_GETBORDERS($HWND)
	Return SetError(@error, @extended, $ABORDERS[1])
EndFunc
Func _GUICTRLSTATUSBAR_GETCOUNT($HWND)
	If $DEBUG_SB Then __UDF_VALIDATECLASSNAME($HWND, $__STATUSBARCONSTANT_CLASSNAME)
	Return _SENDMESSAGE($HWND, $SB_GETPARTS)
EndFunc
Func _GUICTRLSTATUSBAR_GETHEIGHT($HWND)
	Local $TRECT = _GUICTRLSTATUSBAR_GETRECTEX($HWND, 0)
	Return DllStructGetData($TRECT, "Bottom") - DllStructGetData($TRECT, "Top") - (_GUICTRLSTATUSBAR_GETBORDERSVERT($HWND) * 2)
EndFunc
Func _GUICTRLSTATUSBAR_GETICON($HWND, $IINDEX = 0)
	If $DEBUG_SB Then __UDF_VALIDATECLASSNAME($HWND, $__STATUSBARCONSTANT_CLASSNAME)
	Return _SENDMESSAGE($HWND, $SB_GETICON, $IINDEX, 0, 0, "wparam", "lparam", "handle")
EndFunc
Func _GUICTRLSTATUSBAR_GETPARTS($HWND)
	If $DEBUG_SB Then __UDF_VALIDATECLASSNAME($HWND, $__STATUSBARCONSTANT_CLASSNAME)
	Local $ICOUNT = _GUICTRLSTATUSBAR_GETCOUNT($HWND)
	Local $TPARTS = DllStructCreate("int[" & $ICOUNT & "]")
	Local $APARTS[$ICOUNT + 1]
	If _WINAPI_INPROCESS($HWND, $__GHSBLASTWND) Then
		$APARTS[0] = _SENDMESSAGE($HWND, $SB_GETPARTS, $ICOUNT, $TPARTS, 0, "wparam", "struct*")
	Else
		Local $IPARTS = DllStructGetSize($TPARTS)
		Local $TMEMMAP
		Local $PMEMORY = _MEMINIT($HWND, $IPARTS, $TMEMMAP)
		$APARTS[0] = _SENDMESSAGE($HWND, $SB_GETPARTS, $ICOUNT, $PMEMORY, 0, "wparam", "ptr")
		_MEMREAD($TMEMMAP, $PMEMORY, $TPARTS, $IPARTS)
		_MEMFREE($TMEMMAP)
	EndIf
	For $II = 1 To $ICOUNT
		$APARTS[$II] = DllStructGetData($TPARTS, 1, $II)
	Next
	Return $APARTS
EndFunc
Func _GUICTRLSTATUSBAR_GETRECT($HWND, $IPART)
	Local $TRECT = _GUICTRLSTATUSBAR_GETRECTEX($HWND, $IPART)
	If @error Then Return SetError(@error, 0, 0)
	Local $ARECT[4]
	$ARECT[0] = DllStructGetData($TRECT, "Left")
	$ARECT[1] = DllStructGetData($TRECT, "Top")
	$ARECT[2] = DllStructGetData($TRECT, "Right")
	$ARECT[3] = DllStructGetData($TRECT, "Bottom")
	Return $ARECT
EndFunc
Func _GUICTRLSTATUSBAR_GETRECTEX($HWND, $IPART)
	If $DEBUG_SB Then __UDF_VALIDATECLASSNAME($HWND, $__STATUSBARCONSTANT_CLASSNAME)
	Local $TRECT = DllStructCreate($TAGRECT)
	Local $IRET
	If _WINAPI_INPROCESS($HWND, $__GHSBLASTWND) Then
		$IRET = _SENDMESSAGE($HWND, $SB_GETRECT, $IPART, $TRECT, 0, "wparam", "struct*")
	Else
		Local $IRECT = DllStructGetSize($TRECT)
		Local $TMEMMAP
		Local $PMEMORY = _MEMINIT($HWND, $IRECT, $TMEMMAP)
		$IRET = _SENDMESSAGE($HWND, $SB_GETRECT, $IPART, $PMEMORY, 0, "wparam", "ptr")
		_MEMREAD($TMEMMAP, $PMEMORY, $TRECT, $IRECT)
		_MEMFREE($TMEMMAP)
	EndIf
	Return SetError($IRET = 0, 0, $TRECT)
EndFunc
Func _GUICTRLSTATUSBAR_GETTEXT($HWND, $IPART)
	If $DEBUG_SB Then __UDF_VALIDATECLASSNAME($HWND, $__STATUSBARCONSTANT_CLASSNAME)
	Local $FUNICODE = _GUICTRLSTATUSBAR_GETUNICODEFORMAT($HWND)
	Local $IBUFFER = _GUICTRLSTATUSBAR_GETTEXTLENGTH($HWND, $IPART)
	If $IBUFFER = 0 Then Return SetError(1, 0, "")
	Local $TBUFFER
	If $FUNICODE Then
		$TBUFFER = DllStructCreate("wchar Text[" & $IBUFFER & "]")
		$IBUFFER *= 2
	Else
		$TBUFFER = DllStructCreate("char Text[" & $IBUFFER & "]")
	EndIf
	If _WINAPI_INPROCESS($HWND, $__GHSBLASTWND) Then
		_SENDMESSAGE($HWND, $SB_GETTEXTW, $IPART, $TBUFFER, 0, "wparam", "struct*")
	Else
		Local $TMEMMAP
		Local $PMEMORY = _MEMINIT($HWND, $IBUFFER, $TMEMMAP)
		If $FUNICODE Then
			_SENDMESSAGE($HWND, $SB_GETTEXTW, $IPART, $PMEMORY, 0, "wparam", "ptr")
		Else
			_SENDMESSAGE($HWND, $SB_GETTEXT, $IPART, $PMEMORY, 0, "wparam", "ptr")
		EndIf
		_MEMREAD($TMEMMAP, $PMEMORY, $TBUFFER, $IBUFFER)
		_MEMFREE($TMEMMAP)
	EndIf
	Return DllStructGetData($TBUFFER, "Text")
EndFunc
Func _GUICTRLSTATUSBAR_GETTEXTFLAGS($HWND, $IPART)
	If $DEBUG_SB Then __UDF_VALIDATECLASSNAME($HWND, $__STATUSBARCONSTANT_CLASSNAME)
	If _GUICTRLSTATUSBAR_GETUNICODEFORMAT($HWND) Then
		Return _SENDMESSAGE($HWND, $SB_GETTEXTLENGTHW, $IPART)
	Else
		Return _SENDMESSAGE($HWND, $SB_GETTEXTLENGTH, $IPART)
	EndIf
EndFunc
Func _GUICTRLSTATUSBAR_GETTEXTLENGTH($HWND, $IPART)
	Return _WINAPI_LOWORD(_GUICTRLSTATUSBAR_GETTEXTFLAGS($HWND, $IPART))
EndFunc
Func _GUICTRLSTATUSBAR_GETTEXTLENGTHEX($HWND, $IPART)
	Return _WINAPI_HIWORD(_GUICTRLSTATUSBAR_GETTEXTFLAGS($HWND, $IPART))
EndFunc
Func _GUICTRLSTATUSBAR_GETTIPTEXT($HWND, $IPART)
	If $DEBUG_SB Then __UDF_VALIDATECLASSNAME($HWND, $__STATUSBARCONSTANT_CLASSNAME)
	Local $FUNICODE = _GUICTRLSTATUSBAR_GETUNICODEFORMAT($HWND)
	Local $TBUFFER
	If $FUNICODE Then
		$TBUFFER = DllStructCreate("wchar Text[4096]")
	Else
		$TBUFFER = DllStructCreate("char Text[4096]")
	EndIf
	If _WINAPI_INPROCESS($HWND, $__GHSBLASTWND) Then
		_SENDMESSAGE($HWND, $SB_GETTIPTEXTW, _WINAPI_MAKELONG($IPART, 4096), $TBUFFER, 0, "wparam", "struct*")
	Else
		Local $TMEMMAP
		Local $PMEMORY = _MEMINIT($HWND, 4096, $TMEMMAP)
		If $FUNICODE Then
			_SENDMESSAGE($HWND, $SB_GETTIPTEXTW, _WINAPI_MAKELONG($IPART, 4096), $PMEMORY, 0, "wparam", "ptr")
		Else
			_SENDMESSAGE($HWND, $SB_GETTIPTEXTA, _WINAPI_MAKELONG($IPART, 4096), $PMEMORY, 0, "wparam", "ptr")
		EndIf
		_MEMREAD($TMEMMAP, $PMEMORY, $TBUFFER, 4096)
		_MEMFREE($TMEMMAP)
	EndIf
	Return DllStructGetData($TBUFFER, "Text")
EndFunc
Func _GUICTRLSTATUSBAR_GETUNICODEFORMAT($HWND)
	If $DEBUG_SB Then __UDF_VALIDATECLASSNAME($HWND, $__STATUSBARCONSTANT_CLASSNAME)
	Return _SENDMESSAGE($HWND, $SB_GETUNICODEFORMAT) <> 0
EndFunc
Func _GUICTRLSTATUSBAR_GETWIDTH($HWND, $IPART)
	Local $TRECT = _GUICTRLSTATUSBAR_GETRECTEX($HWND, $IPART)
	Return DllStructGetData($TRECT, "Right") - DllStructGetData($TRECT, "Left") - (_GUICTRLSTATUSBAR_GETBORDERSHORZ($HWND) * 2)
EndFunc
Func _GUICTRLSTATUSBAR_ISSIMPLE($HWND)
	If $DEBUG_SB Then __UDF_VALIDATECLASSNAME($HWND, $__STATUSBARCONSTANT_CLASSNAME)
	Return _SENDMESSAGE($HWND, $SB_ISSIMPLE) <> 0
EndFunc
Func _GUICTRLSTATUSBAR_RESIZE($HWND)
	If $DEBUG_SB Then __UDF_VALIDATECLASSNAME($HWND, $__STATUSBARCONSTANT_CLASSNAME)
	_SENDMESSAGE($HWND, $__STATUSBARCONSTANT_WM_SIZE)
EndFunc
Func _GUICTRLSTATUSBAR_SETBKCOLOR($HWND, $ICOLOR)
	If $DEBUG_SB Then __UDF_VALIDATECLASSNAME($HWND, $__STATUSBARCONSTANT_CLASSNAME)
	$ICOLOR = _SENDMESSAGE($HWND, $SB_SETBKCOLOR, 0, $ICOLOR)
	If $ICOLOR = $__STATUSBARCONSTANT_CLR_DEFAULT Then Return "0x" & Hex($__STATUSBARCONSTANT_CLR_DEFAULT)
	Return $ICOLOR
EndFunc
Func _GUICTRLSTATUSBAR_SETICON($HWND, $IPART, $HICON = -1, $SICONFILE = "")
	If $DEBUG_SB Then __UDF_VALIDATECLASSNAME($HWND, $__STATUSBARCONSTANT_CLASSNAME)
	If $HICON = -1 Then Return _SENDMESSAGE($HWND, $SB_SETICON, $IPART, $HICON, 0, "wparam", "handle") <> 0
	If StringLen($SICONFILE) <= 0 Then Return _SENDMESSAGE($HWND, $SB_SETICON, $IPART, $HICON) <> 0
	Local $TICON = DllStructCreate("handle")
	Local $VRESULT = DllCall("shell32.dll", "uint", "ExtractIconExW", "wstr", $SICONFILE, "int", $HICON, "ptr", 0, "struct*", $TICON, "uint", 1)
	If @error Then Return SetError(@error, @extended, False)
	$VRESULT = $VRESULT[0]
	If $VRESULT > 0 Then $VRESULT = _SENDMESSAGE($HWND, $SB_SETICON, $IPART, DllStructGetData($TICON, 1), 0, "wparam", "handle")
	DllCall("user32.dll", "bool", "DestroyIcon", "handle", DllStructGetData($TICON, 1))
	Return $VRESULT
EndFunc
Func _GUICTRLSTATUSBAR_SETMINHEIGHT($HWND, $IMINHEIGHT)
	If $DEBUG_SB Then __UDF_VALIDATECLASSNAME($HWND, $__STATUSBARCONSTANT_CLASSNAME)
	_SENDMESSAGE($HWND, $SB_SETMINHEIGHT, $IMINHEIGHT)
	_GUICTRLSTATUSBAR_RESIZE($HWND)
EndFunc
Func _GUICTRLSTATUSBAR_SETPARTS($HWND, $IAPARTS = -1, $IAPARTWIDTH = 25)
	If $DEBUG_SB Then __UDF_VALIDATECLASSNAME($HWND, $__STATUSBARCONSTANT_CLASSNAME)
	Local $TPARTS, $IPARTS = 1
	If IsArray($IAPARTS) <> 0 Then
		$IAPARTS[UBound($IAPARTS) - 1] = -1
		$IPARTS = UBound($IAPARTS)
		$TPARTS = DllStructCreate("int[" & $IPARTS & "]")
		For $X = 0 To $IPARTS - 2
			DllStructSetData($TPARTS, 1, $IAPARTS[$X], $X + 1)
		Next
		DllStructSetData($TPARTS, 1, -1, $IPARTS)
	ElseIf IsArray($IAPARTWIDTH) <> 0 Then
		$IPARTS = UBound($IAPARTWIDTH)
		$TPARTS = DllStructCreate("int[" & $IPARTS & "]")
		For $X = 0 To $IPARTS - 2
			DllStructSetData($TPARTS, 1, $IAPARTWIDTH[$X], $X + 1)
		Next
		DllStructSetData($TPARTS, 1, -1, $IPARTS)
	ElseIf $IAPARTS > 1 Then
		$IPARTS = $IAPARTS
		$TPARTS = DllStructCreate("int[" & $IPARTS & "]")
		For $X = 1 To $IPARTS - 1
			DllStructSetData($TPARTS, 1, $IAPARTWIDTH * $X, $X)
		Next
		DllStructSetData($TPARTS, 1, -1, $IPARTS)
	Else
		$TPARTS = DllStructCreate("int")
		DllStructSetData($TPARTS, $IPARTS, -1)
	EndIf
	If _WINAPI_INPROCESS($HWND, $__GHSBLASTWND) Then
		_SENDMESSAGE($HWND, $SB_SETPARTS, $IPARTS, $TPARTS, 0, "wparam", "struct*")
	Else
		Local $ISIZE = DllStructGetSize($TPARTS)
		Local $TMEMMAP
		Local $PMEMORY = _MEMINIT($HWND, $ISIZE, $TMEMMAP)
		_MEMWRITE($TMEMMAP, $TPARTS)
		_SENDMESSAGE($HWND, $SB_SETPARTS, $IPARTS, $PMEMORY, 0, "wparam", "ptr")
		_MEMFREE($TMEMMAP)
	EndIf
	_GUICTRLSTATUSBAR_RESIZE($HWND)
	Return True
EndFunc
Func _GUICTRLSTATUSBAR_SETSIMPLE($HWND, $FSIMPLE = True)
	If $DEBUG_SB Then __UDF_VALIDATECLASSNAME($HWND, $__STATUSBARCONSTANT_CLASSNAME)
	_SENDMESSAGE($HWND, $SB_SIMPLE, $FSIMPLE)
EndFunc
Func _GUICTRLSTATUSBAR_SETTEXT($HWND, $STEXT = "", $IPART = 0, $IUFLAG = 0)
	If $DEBUG_SB Then __UDF_VALIDATECLASSNAME($HWND, $__STATUSBARCONSTANT_CLASSNAME)
	Local $FUNICODE = _GUICTRLSTATUSBAR_GETUNICODEFORMAT($HWND)
	Local $IBUFFER = StringLen($STEXT) + 1
	Local $TTEXT
	If $FUNICODE Then
		$TTEXT = DllStructCreate("wchar Text[" & $IBUFFER & "]")
		$IBUFFER *= 2
	Else
		$TTEXT = DllStructCreate("char Text[" & $IBUFFER & "]")
	EndIf
	DllStructSetData($TTEXT, "Text", $STEXT)
	If _GUICTRLSTATUSBAR_ISSIMPLE($HWND) Then $IPART = $SB_SIMPLEID
	Local $IRET
	If _WINAPI_INPROCESS($HWND, $__GHSBLASTWND) Then
		$IRET = _SENDMESSAGE($HWND, $SB_SETTEXTW, BitOR($IPART, $IUFLAG), $TTEXT, 0, "wparam", "struct*")
	Else
		Local $TMEMMAP
		Local $PMEMORY = _MEMINIT($HWND, $IBUFFER, $TMEMMAP)
		_MEMWRITE($TMEMMAP, $TTEXT)
		If $FUNICODE Then
			$IRET = _SENDMESSAGE($HWND, $SB_SETTEXTW, BitOR($IPART, $IUFLAG), $PMEMORY, 0, "wparam", "ptr")
		Else
			$IRET = _SENDMESSAGE($HWND, $SB_SETTEXT, BitOR($IPART, $IUFLAG), $PMEMORY, 0, "wparam", "ptr")
		EndIf
		_MEMFREE($TMEMMAP)
	EndIf
	Return $IRET <> 0
EndFunc
Func _GUICTRLSTATUSBAR_SETTIPTEXT($HWND, $IPART, $STEXT)
	If $DEBUG_SB Then __UDF_VALIDATECLASSNAME($HWND, $__STATUSBARCONSTANT_CLASSNAME)
	Local $FUNICODE = _GUICTRLSTATUSBAR_GETUNICODEFORMAT($HWND)
	Local $IBUFFER = StringLen($STEXT) + 1
	Local $TTEXT
	If $FUNICODE Then
		$TTEXT = DllStructCreate("wchar TipText[" & $IBUFFER & "]")
		$IBUFFER *= 2
	Else
		$TTEXT = DllStructCreate("char TipText[" & $IBUFFER & "]")
	EndIf
	DllStructSetData($TTEXT, "TipText", $STEXT)
	If _WINAPI_INPROCESS($HWND, $__GHSBLASTWND) Then
		_SENDMESSAGE($HWND, $SB_SETTIPTEXTW, $IPART, $TTEXT, 0, "wparam", "struct*")
	Else
		Local $TMEMMAP
		Local $PMEMORY = _MEMINIT($HWND, $IBUFFER, $TMEMMAP)
		_MEMWRITE($TMEMMAP, $TTEXT, $PMEMORY, $IBUFFER)
		If $FUNICODE Then
			_SENDMESSAGE($HWND, $SB_SETTIPTEXTW, $IPART, $PMEMORY, 0, "wparam", "ptr")
		Else
			_SENDMESSAGE($HWND, $SB_SETTIPTEXTA, $IPART, $PMEMORY, 0, "wparam", "ptr")
		EndIf
		_MEMFREE($TMEMMAP)
	EndIf
EndFunc
Func _GUICTRLSTATUSBAR_SETUNICODEFORMAT($HWND, $FUNICODE = True)
	If $DEBUG_SB Then __UDF_VALIDATECLASSNAME($HWND, $__STATUSBARCONSTANT_CLASSNAME)
	Return _SENDMESSAGE($HWND, $SB_SETUNICODEFORMAT, $FUNICODE)
EndFunc
Func _GUICTRLSTATUSBAR_SHOWHIDE($HWND, $ISTATE)
	If $DEBUG_SB Then __UDF_VALIDATECLASSNAME($HWND, $__STATUSBARCONSTANT_CLASSNAME)
	If $ISTATE <> @SW_HIDE And $ISTATE <> @SW_SHOW Then Return SetError(1, 1, False)
	Return _WINAPI_SHOWWINDOW($HWND, $ISTATE)
EndFunc
Global $_GHEDITLASTWND
Global $DEBUG_ED = False
Global Const $__EDITCONSTANT_CLASSNAME = "Edit"
Global Const $__EDITCONSTANT_GUI_CHECKED = 1
Global Const $__EDITCONSTANT_GUI_HIDE = 32
Global Const $__EDITCONSTANT_GUI_EVENT_CLOSE = -3
Global Const $__EDITCONSTANT_GUI_ENABLE = 64
Global Const $__EDITCONSTANT_GUI_DISABLE = 128
Global Const $__EDITCONSTANT_SS_CENTER = 1
Global Const $__EDITCONSTANT_WM_SETREDRAW = 11
Global Const $__EDITCONSTANT_WS_CAPTION = 12582912
Global Const $__EDITCONSTANT_WS_POPUP = -2147483648
Global Const $__EDITCONSTANT_WS_TABSTOP = 65536
Global Const $__EDITCONSTANT_WS_SYSMENU = 524288
Global Const $__EDITCONSTANT_WS_MINIMIZEBOX = 131072
Global Const $__EDITCONSTANT_DEFAULT_GUI_FONT = 17
Global Const $__EDITCONSTANT_WM_SETFONT = 48
Global Const $__EDITCONSTANT_WM_GETTEXTLENGTH = 14
Global Const $__EDITCONSTANT_WM_GETTEXT = 13
Global Const $__EDITCONSTANT_WM_SETTEXT = 12
Global Const $__EDITCONSTANT_SB_LINEUP = 0
Global Const $__EDITCONSTANT_SB_LINEDOWN = 1
Global Const $__EDITCONSTANT_SB_PAGEDOWN = 3
Global Const $__EDITCONSTANT_SB_PAGEUP = 2
Global Const $__EDITCONSTANT_SB_SCROLLCARET = 4
Global Const $TAGEDITBALLOONTIP = "dword Size;ptr Title;ptr Text;int Icon"
Func _GUICTRLEDIT_APPENDTEXT($HWND, $STEXT)
	If $DEBUG_ED Then __UDF_VALIDATECLASSNAME($HWND, $__EDITCONSTANT_CLASSNAME)
	If Not IsHWnd($HWND) Then $HWND = GUICtrlGetHandle($HWND)
	Local $ILENGTH = _GUICTRLEDIT_GETTEXTLEN($HWND)
	_GUICTRLEDIT_SETSEL($HWND, $ILENGTH, $ILENGTH)
	_SENDMESSAGE($HWND, $EM_REPLACESEL, True, $STEXT, 0, "wparam", "wstr")
EndFunc
Func _GUICTRLEDIT_BEGINUPDATE($HWND)
	If $DEBUG_ED Then __UDF_VALIDATECLASSNAME($HWND, $__EDITCONSTANT_CLASSNAME)
	If Not IsHWnd($HWND) Then $HWND = GUICtrlGetHandle($HWND)
	Return _SENDMESSAGE($HWND, $__EDITCONSTANT_WM_SETREDRAW) = 0
EndFunc
Func _GUICTRLEDIT_CANUNDO($HWND)
	If $DEBUG_ED Then __UDF_VALIDATECLASSNAME($HWND, $__EDITCONSTANT_CLASSNAME)
	If Not IsHWnd($HWND) Then $HWND = GUICtrlGetHandle($HWND)
	Return _SENDMESSAGE($HWND, $EM_CANUNDO) <> 0
EndFunc
Func _GUICTRLEDIT_CHARFROMPOS($HWND, $IX, $IY)
	If $DEBUG_ED Then __UDF_VALIDATECLASSNAME($HWND, $__EDITCONSTANT_CLASSNAME)
	If Not IsHWnd($HWND) Then $HWND = GUICtrlGetHandle($HWND)
	Local $ARETURN[2]
	Local $IRET = _SENDMESSAGE($HWND, $EM_CHARFROMPOS, 0, _WINAPI_MAKELONG($IX, $IY))
	$ARETURN[0] = _WINAPI_LOWORD($IRET)
	$ARETURN[1] = _WINAPI_HIWORD($IRET)
	Return $ARETURN
EndFunc
Func _GUICTRLEDIT_CREATE($HWND, $STEXT, $IX, $IY, $IWIDTH = 150, $IHEIGHT = 150, $ISTYLE = 3150020, $IEXSTYLE = 512)
	If Not IsHWnd($HWND) Then Return SetError(1, 0, 0)
	If Not IsString($STEXT) Then Return SetError(2, 0, 0)
	If $IWIDTH = -1 Then $IWIDTH = 150
	If $IHEIGHT = -1 Then $IHEIGHT = 150
	If $ISTYLE = -1 Then $ISTYLE = 3150020
	If $IEXSTYLE = -1 Then $IEXSTYLE = 512
	If BitAND($ISTYLE, $ES_READONLY) = $ES_READONLY Then
		$ISTYLE = BitOR($__UDFGUICONSTANT_WS_CHILD, $__UDFGUICONSTANT_WS_VISIBLE, $ISTYLE)
	Else
		$ISTYLE = BitOR($__UDFGUICONSTANT_WS_CHILD, $__UDFGUICONSTANT_WS_VISIBLE, $__EDITCONSTANT_WS_TABSTOP, $ISTYLE)
	EndIf
	Local $NCTRLID = __UDF_GETNEXTGLOBALID($HWND)
	If @error Then Return SetError(@error, @extended, 0)
	Local $HEDIT = _WINAPI_CREATEWINDOWEX($IEXSTYLE, $__EDITCONSTANT_CLASSNAME, "", $ISTYLE, $IX, $IY, $IWIDTH, $IHEIGHT, $HWND, $NCTRLID)
	_SENDMESSAGE($HEDIT, $__EDITCONSTANT_WM_SETFONT, _WINAPI_GETSTOCKOBJECT($__EDITCONSTANT_DEFAULT_GUI_FONT), True)
	_GUICTRLEDIT_SETTEXT($HEDIT, $STEXT)
	_GUICTRLEDIT_SETLIMITTEXT($HEDIT, 0)
	Return $HEDIT
EndFunc
Func _GUICTRLEDIT_DESTROY(ByRef $HWND)
	If $DEBUG_ED Then __UDF_VALIDATECLASSNAME($HWND, $__EDITCONSTANT_CLASSNAME)
	If Not _WINAPI_ISCLASSNAME($HWND, $__EDITCONSTANT_CLASSNAME) Then Return SetError(2, 2, False)
	Local $DESTROYED = 0
	If IsHWnd($HWND) Then
		If _WINAPI_INPROCESS($HWND, $_GHEDITLASTWND) Then
			Local $NCTRLID = _WINAPI_GETDLGCTRLID($HWND)
			Local $HPARENT = _WINAPI_GETPARENT($HWND)
			$DESTROYED = _WINAPI_DESTROYWINDOW($HWND)
			Local $IRET = __UDF_FREEGLOBALID($HPARENT, $NCTRLID)
			If Not $IRET Then
			EndIf
		Else
			Return SetError(1, 1, False)
		EndIf
	Else
		$DESTROYED = GUICtrlDelete($HWND)
	EndIf
	If $DESTROYED Then $HWND = 0
	Return $DESTROYED <> 0
EndFunc
Func _GUICTRLEDIT_EMPTYUNDOBUFFER($HWND)
	If $DEBUG_ED Then __UDF_VALIDATECLASSNAME($HWND, $__EDITCONSTANT_CLASSNAME)
	If Not IsHWnd($HWND) Then $HWND = GUICtrlGetHandle($HWND)
	_SENDMESSAGE($HWND, $EM_EMPTYUNDOBUFFER)
EndFunc
Func _GUICTRLEDIT_ENDUPDATE($HWND)
	If $DEBUG_ED Then __UDF_VALIDATECLASSNAME($HWND, $__EDITCONSTANT_CLASSNAME)
	If Not IsHWnd($HWND) Then $HWND = GUICtrlGetHandle($HWND)
	Return _SENDMESSAGE($HWND, $__EDITCONSTANT_WM_SETREDRAW, 1) = 0
EndFunc
Func _GUICTRLEDIT_FMTLINES($HWND, $FSOFTBREAK = False)
	If $DEBUG_ED Then __UDF_VALIDATECLASSNAME($HWND, $__EDITCONSTANT_CLASSNAME)
	If Not IsHWnd($HWND) Then $HWND = GUICtrlGetHandle($HWND)
	Return _SENDMESSAGE($HWND, $EM_FMTLINES, $FSOFTBREAK)
EndFunc
Func _GUICTRLEDIT_FIND($HWND, $FREPLACE = False)
	If $DEBUG_ED Then __UDF_VALIDATECLASSNAME($HWND, $__EDITCONSTANT_CLASSNAME)
	If Not IsHWnd($HWND) Then $HWND = GUICtrlGetHandle($HWND)
	Local $IPOS = 0, $ICASE, $IOCCURANCE = 0, $IREPLACEMENTS = 0
	Local $APARTSRIGHTEDGE[3] = [125, 225, -1]
	Local $OLDMODE = Opt("GUIOnEventMode", 0)
	Local $ASEL = _GUICTRLEDIT_GETSEL($HWND)
	Local $STEXT = _GUICTRLEDIT_GETTEXT($HWND)
	Local $GUISEARCH = GUICreate("Find", 349, 177, -1, -1, BitOR($__UDFGUICONSTANT_WS_CHILD, $__EDITCONSTANT_WS_MINIMIZEBOX, $__EDITCONSTANT_WS_CAPTION, $__EDITCONSTANT_WS_POPUP, $__EDITCONSTANT_WS_SYSMENU))
	Local $STATUSBAR1 = _GUICTRLSTATUSBAR_CREATE($GUISEARCH, $APARTSRIGHTEDGE)
	_GUICTRLSTATUSBAR_SETTEXT($STATUSBAR1, "Find: ")
	GUISetIcon(@SystemDir & "\shell32.dll", 22, $GUISEARCH)
	GUICtrlCreateLabel("Find what:", 9, 10, 53, 16, $__EDITCONSTANT_SS_CENTER)
	Local $INPUTSEARCH = GUICtrlCreateInput("", 80, 8, 257, 21)
	Local $LBLREPLACE = GUICtrlCreateLabel("Replace with:", 9, 42, 69, 17, $__EDITCONSTANT_SS_CENTER)
	Local $INPUTREPLACE = GUICtrlCreateInput("", 80, 40, 257, 21)
	Local $CHKWHOLEONLY = GUICtrlCreateCheckbox("Match whole word only", 9, 72, 145, 17)
	Local $CHKMATCHCASE = GUICtrlCreateCheckbox("Match case", 9, 96, 145, 17)
	Local $BTNFINDNEXT = GUICtrlCreateButton("Find Next", 168, 72, 161, 21, 0)
	Local $BTNREPLACE = GUICtrlCreateButton("Replace", 168, 96, 161, 21, 0)
	Local $BTNCLOSE = GUICtrlCreateButton("Close", 104, 130, 161, 21, 0)
	IF (IsArray($ASEL) And $ASEL <> $EC_ERR) Then
		GUICtrlSetData($INPUTSEARCH, StringMid($STEXT, $ASEL[0] + 1, $ASEL[1] - $ASEL[0]))
		If $ASEL[0] <> $ASEL[1] Then
			$IPOS = $ASEL[0]
			If BitAND(GUICtrlRead($CHKMATCHCASE), $__EDITCONSTANT_GUI_CHECKED) = $__EDITCONSTANT_GUI_CHECKED Then $ICASE = 1
			$IOCCURANCE = 1
			Local $ITPOSE
			While 1
				$ITPOSE = StringInStr($STEXT, GUICtrlRead($INPUTSEARCH), $ICASE, $IOCCURANCE)
				If Not $ITPOSE Then
					$IOCCURANCE = 0
					ExitLoop
				ElseIf $ITPOSE = $IPOS + 1 Then
					ExitLoop
				EndIf
				$IOCCURANCE += 1
			WEnd
		EndIf
		_GUICTRLSTATUSBAR_SETTEXT($STATUSBAR1, "Find: " & GUICtrlRead($INPUTSEARCH))
	EndIf
	If $FREPLACE = False Then
		GUICtrlSetState($LBLREPLACE, $__EDITCONSTANT_GUI_HIDE)
		GUICtrlSetState($INPUTREPLACE, $__EDITCONSTANT_GUI_HIDE)
		GUICtrlSetState($BTNREPLACE, $__EDITCONSTANT_GUI_HIDE)
	Else
		_GUICTRLSTATUSBAR_SETTEXT($STATUSBAR1, "Replacements: " & $IREPLACEMENTS, 1)
		_GUICTRLSTATUSBAR_SETTEXT($STATUSBAR1, "With: ", 2)
	EndIf
	GUISetState(@SW_SHOW)
	Local $MSGFIND
	While 1
		$MSGFIND = GUIGetMsg()
		Select
			Case $MSGFIND = $__EDITCONSTANT_GUI_EVENT_CLOSE Or $MSGFIND = $BTNCLOSE
				ExitLoop
			Case $MSGFIND = $BTNFINDNEXT
				GUICtrlSetState($BTNFINDNEXT, $__EDITCONSTANT_GUI_DISABLE)
				GUICtrlSetCursor($BTNFINDNEXT, 15)
				Sleep(100)
				_GUICTRLSTATUSBAR_SETTEXT($STATUSBAR1, "Find: " & GUICtrlRead($INPUTSEARCH))
				If $FREPLACE = True Then
					_GUICTRLSTATUSBAR_SETTEXT($STATUSBAR1, "Find: " & GUICtrlRead($INPUTSEARCH))
					_GUICTRLSTATUSBAR_SETTEXT($STATUSBAR1, "With: " & GUICtrlRead($INPUTREPLACE), 2)
				EndIf
				__GUICTRLEDIT_FINDTEXT($HWND, $INPUTSEARCH, $CHKMATCHCASE, $CHKWHOLEONLY, $IPOS, $IOCCURANCE, $IREPLACEMENTS)
				Sleep(100)
				GUICtrlSetState($BTNFINDNEXT, $__EDITCONSTANT_GUI_ENABLE)
				GUICtrlSetCursor($BTNFINDNEXT, 2)
			Case $MSGFIND = $BTNREPLACE
				GUICtrlSetState($BTNREPLACE, $__EDITCONSTANT_GUI_DISABLE)
				GUICtrlSetCursor($BTNREPLACE, 15)
				Sleep(100)
				_GUICTRLSTATUSBAR_SETTEXT($STATUSBAR1, "Find: " & GUICtrlRead($INPUTSEARCH))
				_GUICTRLSTATUSBAR_SETTEXT($STATUSBAR1, "With: " & GUICtrlRead($INPUTREPLACE), 2)
				If $IPOS Then
					_GUICTRLEDIT_REPLACESEL($HWND, GUICtrlRead($INPUTREPLACE))
					$IREPLACEMENTS += 1
					$IOCCURANCE -= 1
					_GUICTRLSTATUSBAR_SETTEXT($STATUSBAR1, "Replacements: " & $IREPLACEMENTS, 1)
				EndIf
				__GUICTRLEDIT_FINDTEXT($HWND, $INPUTSEARCH, $CHKMATCHCASE, $CHKWHOLEONLY, $IPOS, $IOCCURANCE, $IREPLACEMENTS)
				Sleep(100)
				GUICtrlSetState($BTNREPLACE, $__EDITCONSTANT_GUI_ENABLE)
				GUICtrlSetCursor($BTNREPLACE, 2)
		EndSelect
	WEnd
	GUIDelete($GUISEARCH)
	Opt("GUIOnEventMode", $OLDMODE)
EndFunc
Func __GUICTRLEDIT_FINDTEXT($HWND, $INPUTSEARCH, $CHKMATCHCASE, $CHKWHOLEONLY, ByRef $IPOS, ByRef $IOCCURANCE, ByRef $IREPLACEMENTS)
	If $DEBUG_ED Then __UDF_VALIDATECLASSNAME($HWND, $__EDITCONSTANT_CLASSNAME)
	If Not IsHWnd($HWND) Then $HWND = GUICtrlGetHandle($HWND)
	Local $ICASE = 0, $IWHOLE = 0
	Local $FEXACT = False
	Local $SFIND = GUICtrlRead($INPUTSEARCH)
	Local $STEXT = _GUICTRLEDIT_GETTEXT($HWND)
	If BitAND(GUICtrlRead($CHKMATCHCASE), $__EDITCONSTANT_GUI_CHECKED) = $__EDITCONSTANT_GUI_CHECKED Then $ICASE = 1
	If BitAND(GUICtrlRead($CHKWHOLEONLY), $__EDITCONSTANT_GUI_CHECKED) = $__EDITCONSTANT_GUI_CHECKED Then $IWHOLE = 1
	If $SFIND <> "" Then
		$IOCCURANCE += 1
		$IPOS = StringInStr($STEXT, $SFIND, $ICASE, $IOCCURANCE)
		If $IWHOLE And $IPOS Then
			Local $C_COMPARE2 = StringMid($STEXT, $IPOS + StringLen($SFIND), 1)
			If $IPOS = 1 Then
				IF ($IPOS + StringLen($SFIND)) - 1 = StringLen($STEXT) OR ($C_COMPARE2 = " " Or $C_COMPARE2 = @LF Or $C_COMPARE2 = @CR Or $C_COMPARE2 = @CRLF Or $C_COMPARE2 = @TAB) Then $FEXACT = True
			Else
				Local $C_COMPARE1 = StringMid($STEXT, $IPOS - 1, 1)
				IF ($IPOS + StringLen($SFIND)) - 1 = StringLen($STEXT) Then
					IF ($C_COMPARE1 = " " Or $C_COMPARE1 = @LF Or $C_COMPARE1 = @CR Or $C_COMPARE1 = @CRLF Or $C_COMPARE1 = @TAB) Then $FEXACT = True
				Else
					IF ($C_COMPARE1 = " " Or $C_COMPARE1 = @LF Or $C_COMPARE1 = @CR Or $C_COMPARE1 = @CRLF Or $C_COMPARE1 = @TAB) AND ($C_COMPARE2 = " " Or $C_COMPARE2 = @LF Or $C_COMPARE2 = @CR Or $C_COMPARE2 = @CRLF Or $C_COMPARE2 = @TAB) Then $FEXACT = True
				EndIf
			EndIf
			If $FEXACT = False Then
				__GUICTRLEDIT_FINDTEXT($HWND, $INPUTSEARCH, $CHKMATCHCASE, $CHKWHOLEONLY, $IPOS, $IOCCURANCE, $IREPLACEMENTS)
			Else
				_GUICTRLEDIT_SETSEL($HWND, $IPOS - 1, ($IPOS + StringLen($SFIND)) - 1)
				_GUICTRLEDIT_SCROLL($HWND, $__EDITCONSTANT_SB_SCROLLCARET)
			EndIf
		ElseIf $IWHOLE And Not $IPOS Then
			$IOCCURANCE = 0
			MsgBox(48, "Find", "Reached End of document, Can not find the string '" & $SFIND & "'")
		ElseIf Not $IWHOLE Then
			If Not $IPOS Then
				$IOCCURANCE = 1
				_GUICTRLEDIT_SETSEL($HWND, -1, 0)
				_GUICTRLEDIT_SCROLL($HWND, $__EDITCONSTANT_SB_SCROLLCARET)
				$IPOS = StringInStr($STEXT, $SFIND, $ICASE, $IOCCURANCE)
				If Not $IPOS Then
					$IOCCURANCE = 0
					MsgBox(48, "Find", "Reached End of document, Can not find the string  '" & $SFIND & "'")
				Else
					_GUICTRLEDIT_SETSEL($HWND, $IPOS - 1, ($IPOS + StringLen($SFIND)) - 1)
					_GUICTRLEDIT_SCROLL($HWND, $__EDITCONSTANT_SB_SCROLLCARET)
				EndIf
			Else
				_GUICTRLEDIT_SETSEL($HWND, $IPOS - 1, ($IPOS + StringLen($SFIND)) - 1)
				_GUICTRLEDIT_SCROLL($HWND, $__EDITCONSTANT_SB_SCROLLCARET)
			EndIf
		EndIf
	EndIf
EndFunc
Func _GUICTRLEDIT_GETFIRSTVISIBLELINE($HWND)
	If $DEBUG_ED Then __UDF_VALIDATECLASSNAME($HWND, $__EDITCONSTANT_CLASSNAME)
	If Not IsHWnd($HWND) Then $HWND = GUICtrlGetHandle($HWND)
	Return _SENDMESSAGE($HWND, $EM_GETFIRSTVISIBLELINE)
EndFunc
Func _GUICTRLEDIT_GETHANDLE($HWND)
	If $DEBUG_ED Then __UDF_VALIDATECLASSNAME($HWND, $__EDITCONSTANT_CLASSNAME)
	If Not IsHWnd($HWND) Then $HWND = GUICtrlGetHandle($HWND)
	Return Ptr(_SENDMESSAGE($HWND, $EM_GETHANDLE))
EndFunc
Func _GUICTRLEDIT_GETIMESTATUS($HWND)
	If $DEBUG_ED Then __UDF_VALIDATECLASSNAME($HWND, $__EDITCONSTANT_CLASSNAME)
	If Not IsHWnd($HWND) Then $HWND = GUICtrlGetHandle($HWND)
	Return _SENDMESSAGE($HWND, $EM_GETIMESTATUS, $EMSIS_COMPOSITIONSTRING)
EndFunc
Func _GUICTRLEDIT_GETLIMITTEXT($HWND)
	If $DEBUG_ED Then __UDF_VALIDATECLASSNAME($HWND, $__EDITCONSTANT_CLASSNAME)
	If Not IsHWnd($HWND) Then $HWND = GUICtrlGetHandle($HWND)
	Return _SENDMESSAGE($HWND, $EM_GETLIMITTEXT)
EndFunc
Func _GUICTRLEDIT_GETLINE($HWND, $ILINE)
	If $DEBUG_ED Then __UDF_VALIDATECLASSNAME($HWND, $__EDITCONSTANT_CLASSNAME)
	If Not IsHWnd($HWND) Then $HWND = GUICtrlGetHandle($HWND)
	Local $ILENGTH = _GUICTRLEDIT_LINELENGTH($HWND, $ILINE)
	If $ILENGTH = 0 Then Return ""
	Local $TBUFFER = DllStructCreate("short Len;wchar Text[" & $ILENGTH & "]")
	DllStructSetData($TBUFFER, "Len", $ILENGTH + 1)
	Local $IRET = _SENDMESSAGE($HWND, $EM_GETLINE, $ILINE, $TBUFFER, 0, "wparam", "struct*")
	If $IRET = 0 Then Return SetError($EC_ERR, $EC_ERR, "")
	Local $TTEXT = DllStructCreate("wchar Text[" & $ILENGTH & "]", DllStructGetPtr($TBUFFER))
	Return DllStructGetData($TTEXT, "Text")
EndFunc
Func _GUICTRLEDIT_GETLINECOUNT($HWND)
	If $DEBUG_ED Then __UDF_VALIDATECLASSNAME($HWND, $__EDITCONSTANT_CLASSNAME)
	If Not IsHWnd($HWND) Then $HWND = GUICtrlGetHandle($HWND)
	Return _SENDMESSAGE($HWND, $EM_GETLINECOUNT)
EndFunc
Func _GUICTRLEDIT_GETMARGINS($HWND)
	If $DEBUG_ED Then __UDF_VALIDATECLASSNAME($HWND, $__EDITCONSTANT_CLASSNAME)
	If Not IsHWnd($HWND) Then $HWND = GUICtrlGetHandle($HWND)
	Local $AMARGINS[2]
	Local $IMARGINS = _SENDMESSAGE($HWND, $EM_GETMARGINS)
	$AMARGINS[0] = _WINAPI_LOWORD($IMARGINS)
	$AMARGINS[1] = _WINAPI_HIWORD($IMARGINS)
	Return $AMARGINS
EndFunc
Func _GUICTRLEDIT_GETMODIFY($HWND)
	If $DEBUG_ED Then __UDF_VALIDATECLASSNAME($HWND, $__EDITCONSTANT_CLASSNAME)
	If Not IsHWnd($HWND) Then $HWND = GUICtrlGetHandle($HWND)
	Return _SENDMESSAGE($HWND, $EM_GETMODIFY) <> 0
EndFunc
Func _GUICTRLEDIT_GETPASSWORDCHAR($HWND)
	If $DEBUG_ED Then __UDF_VALIDATECLASSNAME($HWND, $__EDITCONSTANT_CLASSNAME)
	If Not IsHWnd($HWND) Then $HWND = GUICtrlGetHandle($HWND)
	Return _SENDMESSAGE($HWND, $EM_GETPASSWORDCHAR)
EndFunc
Func _GUICTRLEDIT_GETRECT($HWND)
	If $DEBUG_ED Then __UDF_VALIDATECLASSNAME($HWND, $__EDITCONSTANT_CLASSNAME)
	If Not IsHWnd($HWND) Then $HWND = GUICtrlGetHandle($HWND)
	Local $ARECT[4]
	Local $TRECT = _GUICTRLEDIT_GETRECTEX($HWND)
	$ARECT[0] = DllStructGetData($TRECT, "Left")
	$ARECT[1] = DllStructGetData($TRECT, "Top")
	$ARECT[2] = DllStructGetData($TRECT, "Right")
	$ARECT[3] = DllStructGetData($TRECT, "Bottom")
	Return $ARECT
EndFunc
Func _GUICTRLEDIT_GETRECTEX($HWND)
	If $DEBUG_ED Then __UDF_VALIDATECLASSNAME($HWND, $__EDITCONSTANT_CLASSNAME)
	If Not IsHWnd($HWND) Then $HWND = GUICtrlGetHandle($HWND)
	Local $TRECT = DllStructCreate($TAGRECT)
	_SENDMESSAGE($HWND, $EM_GETRECT, 0, $TRECT, 0, "wparam", "struct*")
	Return $TRECT
EndFunc
Func _GUICTRLEDIT_GETSEL($HWND)
	If $DEBUG_ED Then __UDF_VALIDATECLASSNAME($HWND, $__EDITCONSTANT_CLASSNAME)
	If Not IsHWnd($HWND) Then $HWND = GUICtrlGetHandle($HWND)
	Local $ASEL[2]
	Local $WPARAM = DllStructCreate("uint Start")
	Local $LPARAM = DllStructCreate("uint End")
	_SENDMESSAGE($HWND, $EM_GETSEL, $WPARAM, $LPARAM, 0, "struct*", "struct*")
	$ASEL[0] = DllStructGetData($WPARAM, "Start")
	$ASEL[1] = DllStructGetData($LPARAM, "End")
	Return $ASEL
EndFunc
Func _GUICTRLEDIT_GETTEXT($HWND)
	If $DEBUG_ED Then __UDF_VALIDATECLASSNAME($HWND, $__EDITCONSTANT_CLASSNAME)
	If Not IsHWnd($HWND) Then $HWND = GUICtrlGetHandle($HWND)
	Local $ITEXTLEN = _GUICTRLEDIT_GETTEXTLEN($HWND) + 1
	Local $TTEXT = DllStructCreate("wchar Text[" & $ITEXTLEN & "]")
	_SENDMESSAGE($HWND, $__EDITCONSTANT_WM_GETTEXT, $ITEXTLEN, $TTEXT, 0, "wparam", "struct*")
	Return DllStructGetData($TTEXT, "Text")
EndFunc
Func _GUICTRLEDIT_GETTEXTLEN($HWND)
	If $DEBUG_ED Then __UDF_VALIDATECLASSNAME($HWND, $__EDITCONSTANT_CLASSNAME)
	If Not IsHWnd($HWND) Then $HWND = GUICtrlGetHandle($HWND)
	Return _SENDMESSAGE($HWND, $__EDITCONSTANT_WM_GETTEXTLENGTH)
EndFunc
Func _GUICTRLEDIT_GETTHUMB($HWND)
	If $DEBUG_ED Then __UDF_VALIDATECLASSNAME($HWND, $__EDITCONSTANT_CLASSNAME)
	If Not IsHWnd($HWND) Then $HWND = GUICtrlGetHandle($HWND)
	Return _SENDMESSAGE($HWND, $EM_GETTHUMB)
EndFunc
Func _GUICTRLEDIT_GETWORDBREAKPROC($HWND)
	If $DEBUG_ED Then __UDF_VALIDATECLASSNAME($HWND, $__EDITCONSTANT_CLASSNAME)
	If Not IsHWnd($HWND) Then $HWND = GUICtrlGetHandle($HWND)
	Return _SENDMESSAGE($HWND, $EM_GETWORDBREAKPROC)
EndFunc
Func _GUICTRLEDIT_HIDEBALLOONTIP($HWND)
	If $DEBUG_ED Then __UDF_VALIDATECLASSNAME($HWND, $__EDITCONSTANT_CLASSNAME)
	If Not IsHWnd($HWND) Then $HWND = GUICtrlGetHandle($HWND)
	Return _SENDMESSAGE($HWND, $EM_HIDEBALLOONTIP) <> 0
EndFunc
Func _GUICTRLEDIT_INSERTTEXT($HWND, $STEXT, $IINDEX = -1)
	If $DEBUG_ED Then __UDF_VALIDATECLASSNAME($HWND, $__EDITCONSTANT_CLASSNAME)
	If Not IsHWnd($HWND) Then $HWND = GUICtrlGetHandle($HWND)
	If $IINDEX = -1 Then
		_GUICTRLEDIT_APPENDTEXT($HWND, $STEXT)
	Else
		_GUICTRLEDIT_SETSEL($HWND, $IINDEX, $IINDEX)
		_SENDMESSAGE($HWND, $EM_REPLACESEL, True, $STEXT, 0, "wparam", "wstr")
	EndIf
EndFunc
Func _GUICTRLEDIT_LINEFROMCHAR($HWND, $IINDEX = -1)
	If $DEBUG_ED Then __UDF_VALIDATECLASSNAME($HWND, $__EDITCONSTANT_CLASSNAME)
	If Not IsHWnd($HWND) Then $HWND = GUICtrlGetHandle($HWND)
	Return _SENDMESSAGE($HWND, $EM_LINEFROMCHAR, $IINDEX)
EndFunc
Func _GUICTRLEDIT_LINEINDEX($HWND, $IINDEX = -1)
	If $DEBUG_ED Then __UDF_VALIDATECLASSNAME($HWND, $__EDITCONSTANT_CLASSNAME)
	If Not IsHWnd($HWND) Then $HWND = GUICtrlGetHandle($HWND)
	Return _SENDMESSAGE($HWND, $EM_LINEINDEX, $IINDEX)
EndFunc
Func _GUICTRLEDIT_LINELENGTH($HWND, $IINDEX = -1)
	If $DEBUG_ED Then __UDF_VALIDATECLASSNAME($HWND, $__EDITCONSTANT_CLASSNAME)
	If Not IsHWnd($HWND) Then $HWND = GUICtrlGetHandle($HWND)
	Local $CHARINDEX = _GUICTRLEDIT_LINEINDEX($HWND, $IINDEX)
	Return _SENDMESSAGE($HWND, $EM_LINELENGTH, $CHARINDEX)
EndFunc
Func _GUICTRLEDIT_LINESCROLL($HWND, $IHORIZ, $IVERT)
	If $DEBUG_ED Then __UDF_VALIDATECLASSNAME($HWND, $__EDITCONSTANT_CLASSNAME)
	If Not IsHWnd($HWND) Then $HWND = GUICtrlGetHandle($HWND)
	Return _SENDMESSAGE($HWND, $EM_LINESCROLL, $IHORIZ, $IVERT) <> 0
EndFunc
Func _GUICTRLEDIT_POSFROMCHAR($HWND, $IINDEX)
	If $DEBUG_ED Then __UDF_VALIDATECLASSNAME($HWND, $__EDITCONSTANT_CLASSNAME)
	If Not IsHWnd($HWND) Then $HWND = GUICtrlGetHandle($HWND)
	Local $ACOORD[2]
	Local $IRET = _SENDMESSAGE($HWND, $EM_POSFROMCHAR, $IINDEX)
	$ACOORD[0] = _WINAPI_LOWORD($IRET)
	$ACOORD[1] = _WINAPI_HIWORD($IRET)
	Return $ACOORD
EndFunc
Func _GUICTRLEDIT_REPLACESEL($HWND, $STEXT, $FUNDO = True)
	If $DEBUG_ED Then __UDF_VALIDATECLASSNAME($HWND, $__EDITCONSTANT_CLASSNAME)
	If Not IsHWnd($HWND) Then $HWND = GUICtrlGetHandle($HWND)
	_SENDMESSAGE($HWND, $EM_REPLACESEL, $FUNDO, $STEXT, 0, "wparam", "wstr")
EndFunc
Func _GUICTRLEDIT_SCROLL($HWND, $IDIRECTION)
	If $DEBUG_ED Then __UDF_VALIDATECLASSNAME($HWND, $__EDITCONSTANT_CLASSNAME)
	If Not IsHWnd($HWND) Then $HWND = GUICtrlGetHandle($HWND)
	If BitAND($IDIRECTION, $__EDITCONSTANT_SB_LINEDOWN) <> $__EDITCONSTANT_SB_LINEDOWN And BitAND($IDIRECTION, $__EDITCONSTANT_SB_LINEUP) <> $__EDITCONSTANT_SB_LINEUP And BitAND($IDIRECTION, $__EDITCONSTANT_SB_PAGEDOWN) <> $__EDITCONSTANT_SB_PAGEDOWN And BitAND($IDIRECTION, $__EDITCONSTANT_SB_PAGEUP) <> $__EDITCONSTANT_SB_PAGEUP And BitAND($IDIRECTION, $__EDITCONSTANT_SB_SCROLLCARET) <> $__EDITCONSTANT_SB_SCROLLCARET Then Return 0
	If $IDIRECTION == $__EDITCONSTANT_SB_SCROLLCARET Then
		Return _SENDMESSAGE($HWND, $EM_SCROLLCARET)
	Else
		Return _SENDMESSAGE($HWND, $EM_SCROLL, $IDIRECTION)
	EndIf
EndFunc
Func _GUICTRLEDIT_SETHANDLE($HWND, $HMEMORY)
	If $DEBUG_ED Then __UDF_VALIDATECLASSNAME($HWND, $__EDITCONSTANT_CLASSNAME)
	If Not IsHWnd($HWND) Then $HWND = GUICtrlGetHandle($HWND)
	_SENDMESSAGE($HWND, $EM_SETHANDLE, $HMEMORY, 0, 0, "handle")
EndFunc
Func _GUICTRLEDIT_SETIMESTATUS($HWND, $ICOMPOSITION)
	If $DEBUG_ED Then __UDF_VALIDATECLASSNAME($HWND, $__EDITCONSTANT_CLASSNAME)
	If Not IsHWnd($HWND) Then $HWND = GUICtrlGetHandle($HWND)
	Return _SENDMESSAGE($HWND, $EM_SETIMESTATUS, $EMSIS_COMPOSITIONSTRING, $ICOMPOSITION)
EndFunc
Func _GUICTRLEDIT_SETLIMITTEXT($HWND, $ILIMIT)
	If $DEBUG_ED Then __UDF_VALIDATECLASSNAME($HWND, $__EDITCONSTANT_CLASSNAME)
	If Not IsHWnd($HWND) Then $HWND = GUICtrlGetHandle($HWND)
	_SENDMESSAGE($HWND, $EM_SETLIMITTEXT, $ILIMIT)
EndFunc
Func _GUICTRLEDIT_SETMARGINS($HWND, $IMARGIN = 1, $ILEFT = 65535, $IRIGHT = 65535)
	If $DEBUG_ED Then __UDF_VALIDATECLASSNAME($HWND, $__EDITCONSTANT_CLASSNAME)
	If Not IsHWnd($HWND) Then $HWND = GUICtrlGetHandle($HWND)
	_SENDMESSAGE($HWND, $EM_SETMARGINS, $IMARGIN, _WINAPI_MAKELONG($ILEFT, $IRIGHT))
EndFunc
Func _GUICTRLEDIT_SETMODIFY($HWND, $FMODIFIED)
	If $DEBUG_ED Then __UDF_VALIDATECLASSNAME($HWND, $__EDITCONSTANT_CLASSNAME)
	If Not IsHWnd($HWND) Then $HWND = GUICtrlGetHandle($HWND)
	_SENDMESSAGE($HWND, $EM_SETMODIFY, $FMODIFIED)
EndFunc
Func _GUICTRLEDIT_SETPASSWORDCHAR($HWND, $CDISPLAYCHAR = "0")
	If $DEBUG_ED Then __UDF_VALIDATECLASSNAME($HWND, $__EDITCONSTANT_CLASSNAME)
	If Not IsHWnd($HWND) Then $HWND = GUICtrlGetHandle($HWND)
	$CDISPLAYCHAR = StringLeft($CDISPLAYCHAR, 1)
	If Asc($CDISPLAYCHAR) = 48 Then
		_SENDMESSAGE($HWND, $EM_SETPASSWORDCHAR)
	Else
		_SENDMESSAGE($HWND, $EM_SETPASSWORDCHAR, Asc($CDISPLAYCHAR))
	EndIf
EndFunc
Func _GUICTRLEDIT_SETREADONLY($HWND, $FREADONLY)
	If $DEBUG_ED Then __UDF_VALIDATECLASSNAME($HWND, $__EDITCONSTANT_CLASSNAME)
	If Not IsHWnd($HWND) Then $HWND = GUICtrlGetHandle($HWND)
	Return _SENDMESSAGE($HWND, $EM_SETREADONLY, $FREADONLY) <> 0
EndFunc
Func _GUICTRLEDIT_SETRECT($HWND, $ARECT)
	Local $TRECT = DllStructCreate($TAGRECT)
	DllStructSetData($TRECT, "Left", $ARECT[0])
	DllStructSetData($TRECT, "Top", $ARECT[1])
	DllStructSetData($TRECT, "Right", $ARECT[2])
	DllStructSetData($TRECT, "Bottom", $ARECT[3])
	_GUICTRLEDIT_SETRECTEX($HWND, $TRECT)
EndFunc
Func _GUICTRLEDIT_SETRECTEX($HWND, $TRECT)
	If $DEBUG_ED Then __UDF_VALIDATECLASSNAME($HWND, $__EDITCONSTANT_CLASSNAME)
	If Not IsHWnd($HWND) Then $HWND = GUICtrlGetHandle($HWND)
	_SENDMESSAGE($HWND, $EM_SETRECT, 0, $TRECT, 0, "wparam", "struct*")
EndFunc
Func _GUICTRLEDIT_SETRECTNP($HWND, $ARECT)
	Local $TRECT = DllStructCreate($TAGRECT)
	DllStructSetData($TRECT, "Left", $ARECT[0])
	DllStructSetData($TRECT, "Top", $ARECT[1])
	DllStructSetData($TRECT, "Right", $ARECT[2])
	DllStructSetData($TRECT, "Bottom", $ARECT[3])
	_GUICTRLEDIT_SETRECTNPEX($HWND, $TRECT)
EndFunc
Func _GUICTRLEDIT_SETRECTNPEX($HWND, $TRECT)
	If $DEBUG_ED Then __UDF_VALIDATECLASSNAME($HWND, $__EDITCONSTANT_CLASSNAME)
	If Not IsHWnd($HWND) Then $HWND = GUICtrlGetHandle($HWND)
	_SENDMESSAGE($HWND, $EM_SETRECTNP, 0, $TRECT, 0, "wparam", "struct*")
EndFunc
Func _GUICTRLEDIT_SETSEL($HWND, $ISTART, $IEND)
	If $DEBUG_ED Then __UDF_VALIDATECLASSNAME($HWND, $__EDITCONSTANT_CLASSNAME)
	If Not IsHWnd($HWND) Then $HWND = GUICtrlGetHandle($HWND)
	_SENDMESSAGE($HWND, $EM_SETSEL, $ISTART, $IEND)
EndFunc
Func _GUICTRLEDIT_SETTABSTOPS($HWND, $ATABSTOPS)
	If $DEBUG_ED Then __UDF_VALIDATECLASSNAME($HWND, $__EDITCONSTANT_CLASSNAME)
	If Not IsHWnd($HWND) Then $HWND = GUICtrlGetHandle($HWND)
	If Not IsArray($ATABSTOPS) Then Return SetError(-1, -1, False)
	Local $STABSTOPS = ""
	Local $INUMTABSTOPS = UBound($ATABSTOPS)
	For $X = 0 To $INUMTABSTOPS - 1
		$STABSTOPS &= "int;"
	Next
	$STABSTOPS = StringTrimRight($STABSTOPS, 1)
	Local $TTABSTOPS = DllStructCreate($STABSTOPS)
	For $X = 0 To $INUMTABSTOPS - 1
		DllStructSetData($TTABSTOPS, $X + 1, $ATABSTOPS[$X])
	Next
	Local $IRET = _SENDMESSAGE($HWND, $EM_SETTABSTOPS, $INUMTABSTOPS, $TTABSTOPS, 0, "wparam", "struct*") <> 0
	_WINAPI_INVALIDATERECT($HWND)
	Return $IRET
EndFunc
Func _GUICTRLEDIT_SETTEXT($HWND, $STEXT)
	If $DEBUG_ED Then __UDF_VALIDATECLASSNAME($HWND, $__EDITCONSTANT_CLASSNAME)
	If Not IsHWnd($HWND) Then $HWND = GUICtrlGetHandle($HWND)
	_SENDMESSAGE($HWND, $__EDITCONSTANT_WM_SETTEXT, 0, $STEXT, 0, "wparam", "wstr")
EndFunc
Func _GUICTRLEDIT_SETWORDBREAKPROC($HWND, $IADDRESSFUNC)
	If $DEBUG_ED Then __UDF_VALIDATECLASSNAME($HWND, $__EDITCONSTANT_CLASSNAME)
	If Not IsHWnd($HWND) Then $HWND = GUICtrlGetHandle($HWND)
	_SENDMESSAGE($HWND, $EM_SETWORDBREAKPROC, 0, $IADDRESSFUNC)
EndFunc
Func _GUICTRLEDIT_SHOWBALLOONTIP($HWND, $STITLE, $STEXT, $IICON)
	If $DEBUG_ED Then __UDF_VALIDATECLASSNAME($HWND, $__EDITCONSTANT_CLASSNAME)
	If Not IsHWnd($HWND) Then $HWND = GUICtrlGetHandle($HWND)
	Local $TTITLE = _WINAPI_MULTIBYTETOWIDECHAR($STITLE)
	Local $TTEXT = _WINAPI_MULTIBYTETOWIDECHAR($STEXT)
	Local $TTT = DllStructCreate($TAGEDITBALLOONTIP)
	DllStructSetData($TTT, "Size", DllStructGetSize($TTT))
	DllStructSetData($TTT, "Title", DllStructGetPtr($TTITLE))
	DllStructSetData($TTT, "Text", DllStructGetPtr($TTEXT))
	DllStructSetData($TTT, "Icon", $IICON)
	Return _SENDMESSAGE($HWND, $EM_SHOWBALLOONTIP, 0, $TTT, 0, "wparam", "struct*") <> 0
EndFunc
Func _GUICTRLEDIT_UNDO($HWND)
	If $DEBUG_ED Then __UDF_VALIDATECLASSNAME($HWND, $__EDITCONSTANT_CLASSNAME)
	If Not IsHWnd($HWND) Then $HWND = GUICtrlGetHandle($HWND)
	Return _SENDMESSAGE($HWND, $EM_UNDO) <> 0
EndFunc
Func _FILECOUNTLINES($SFILEPATH)
	Local $HFILE = FileOpen($SFILEPATH, $FO_READ)
	If $HFILE = -1 Then Return SetError(1, 0, 0)
	Local $SFILECONTENT = StringStripWS(FileRead($HFILE), 2)
	FileClose($HFILE)
	Local $ATMP
	If StringInStr($SFILECONTENT, @LF) Then
		$ATMP = StringSplit(StringStripCR($SFILECONTENT), @LF)
	ElseIf StringInStr($SFILECONTENT, @CR) Then
		$ATMP = StringSplit($SFILECONTENT, @CR)
	Else
		If StringLen($SFILECONTENT) Then
			Return 1
		Else
			Return SetError(2, 0, 0)
		EndIf
	EndIf
	Return $ATMP[0]
EndFunc
Func _FILECREATE($SFILEPATH)
	Local $HOPENFILE = FileOpen($SFILEPATH, $FO_OVERWRITE)
	If $HOPENFILE = -1 Then Return SetError(1, 0, 0)
	Local $HWRITEFILE = FileWrite($HOPENFILE, "")
	FileClose($HOPENFILE)
	If $HWRITEFILE = -1 Then Return SetError(2, 0, 0)
	Return 1
EndFunc
Func _FILELISTTOARRAY($SPATH, $SFILTER = "*", $IFLAG = 0)
	Local $HSEARCH, $SFILE, $SFILELIST, $SDELIM = "|"
	$SPATH = StringRegExpReplace($SPATH, "[\\/]+\z", "") & "\"
	If Not FileExists($SPATH) Then Return SetError(1, 1, "")
	If StringRegExp($SFILTER, "[\\/:><\|]|(?s)\A\s*\z") Then Return SetError(2, 2, "")
	If NOT ($IFLAG = 0 Or $IFLAG = 1 Or $IFLAG = 2) Then Return SetError(3, 3, "")
	$HSEARCH = FileFindFirstFile($SPATH & $SFILTER)
	If @error Then Return SetError(4, 4, "")
	While 1
		$SFILE = FileFindNextFile($HSEARCH)
		If @error Then ExitLoop
		IF ($IFLAG + @extended = 2) Then ContinueLoop
		$SFILELIST &= $SDELIM & $SFILE
	WEnd
	FileClose($HSEARCH)
	If Not $SFILELIST Then Return SetError(4, 4, "")
	Return StringSplit(StringTrimLeft($SFILELIST, 1), "|")
EndFunc
Func _FILEPRINT($S_FILE, $I_SHOW = @SW_HIDE)
	Local $A_RET = DllCall("shell32.dll", "int", "ShellExecuteW", "hwnd", 0, "wstr", "print", "wstr", $S_FILE, "wstr", "", "wstr", "", "int", $I_SHOW)
	If @error Then Return SetError(@error, @extended, 0)
	If $A_RET[0] <= 32 Then Return SetError(10, $A_RET[0], 0)
	Return 1
EndFunc
Func _FILEREADTOARRAY($SFILEPATH, ByRef $AARRAY)
	Local $HFILE = FileOpen($SFILEPATH, $FO_READ)
	If $HFILE = -1 Then Return SetError(1, 0, 0)
	Local $AFILE = FileRead($HFILE, FileGetSize($SFILEPATH))
	If StringRight($AFILE, 1) = @LF Then $AFILE = StringTrimRight($AFILE, 1)
	If StringRight($AFILE, 1) = @CR Then $AFILE = StringTrimRight($AFILE, 1)
	FileClose($HFILE)
	If StringInStr($AFILE, @LF) Then
		$AARRAY = StringSplit(StringStripCR($AFILE), @LF)
	ElseIf StringInStr($AFILE, @CR) Then
		$AARRAY = StringSplit($AFILE, @CR)
	Else
		If StringLen($AFILE) Then
			Dim $AARRAY[2] = [1, $AFILE]
		Else
			Return SetError(2, 0, 0)
		EndIf
	EndIf
	Return 1
EndFunc
Func _FILEWRITEFROMARRAY($FILE, $A_ARRAY, $I_BASE = 0, $I_UBOUND = 0, $S_DELIM = "|")
	If Not IsArray($A_ARRAY) Then Return SetError(2, 0, 0)
	Local $IDIMS = UBound($A_ARRAY, 0)
	If $IDIMS > 2 Then Return SetError(4, 0, 0)
	Local $LAST = UBound($A_ARRAY) - 1
	If $I_UBOUND < 1 Or $I_UBOUND > $LAST Then $I_UBOUND = $LAST
	If $I_BASE < 0 Or $I_BASE > $LAST Then $I_BASE = 0
	Local $HFILE
	If IsString($FILE) Then
		$HFILE = FileOpen($FILE, $FO_OVERWRITE)
	Else
		$HFILE = $FILE
	EndIf
	If $HFILE = -1 Then Return SetError(1, 0, 0)
	Local $ERRORSAV = 0
	Switch $IDIMS
		Case 1
			For $X = $I_BASE To $I_UBOUND
				If FileWrite($HFILE, $A_ARRAY[$X] & @CRLF) = 0 Then
					$ERRORSAV = 3
					ExitLoop
				EndIf
			Next
		Case 2
			Local $S_TEMP
			For $X = $I_BASE To $I_UBOUND
				$S_TEMP = $A_ARRAY[$X][0]
				For $Y = 1 To $IDIMS
					$S_TEMP &= $S_DELIM & $A_ARRAY[$X][$Y]
				Next
				If FileWrite($HFILE, $S_TEMP & @CRLF) = 0 Then
					$ERRORSAV = 3
					ExitLoop
				EndIf
			Next
	EndSwitch
	If IsString($FILE) Then FileClose($HFILE)
	If $ERRORSAV Then Return SetError($ERRORSAV, 0, 0)
	Return 1
EndFunc
Func _FILEWRITELOG($SLOGPATH, $SLOGMSG, $IFLAG = -1)
	Local $HOPENFILE = $SLOGPATH, $IOPENMODE = $FO_APPEND
	Local $SDATENOW = @YEAR & "-" & @MON & "-" & @MDAY
	Local $STIMENOW = @HOUR & ":" & @MIN & ":" & @SEC
	Local $SMSG = $SDATENOW & " " & $STIMENOW & " : " & $SLOGMSG
	If $IFLAG <> -1 Then
		$SMSG &= @CRLF & FileRead($SLOGPATH)
		$IOPENMODE = $FO_OVERWRITE
	EndIf
	If IsString($SLOGPATH) Then
		$HOPENFILE = FileOpen($SLOGPATH, $IOPENMODE)
		If $HOPENFILE = -1 Then
			Return SetError(1, 0, 0)
		EndIf
	EndIf
	Local $IRETURN = FileWriteLine($HOPENFILE, $SMSG)
	If IsString($SLOGPATH) Then
		$IRETURN = FileClose($HOPENFILE)
	EndIf
	If $IRETURN <= 0 Then
		Return SetError(2, $IRETURN, 0)
	EndIf
	Return $IRETURN
EndFunc
Func _FILEWRITETOLINE($SFILE, $ILINE, $STEXT, $FOVERWRITE = 0)
	If $ILINE <= 0 Then Return SetError(4, 0, 0)
	If Not IsString($STEXT) Then
		$STEXT = String($STEXT)
		If $STEXT = "" Then Return SetError(6, 0, 0)
	EndIf
	If $FOVERWRITE <> 0 And $FOVERWRITE <> 1 Then Return SetError(5, 0, 0)
	If Not FileExists($SFILE) Then Return SetError(2, 0, 0)
	Local $SREAD_FILE = FileRead($SFILE)
	Local $ASPLIT_FILE = StringSplit(StringStripCR($SREAD_FILE), @LF)
	If UBound($ASPLIT_FILE) < $ILINE Then Return SetError(1, 0, 0)
	Local $IENCODING = FILEGETENCODING($SFILE)
	Local $HFILE = FileOpen($SFILE, $IENCODING + $FO_OVERWRITE)
	If $HFILE = -1 Then Return SetError(3, 0, 0)
	$SREAD_FILE = ""
	For $I = 1 To $ASPLIT_FILE[0]
		If $I = $ILINE Then
			If $FOVERWRITE = 1 Then
				If $STEXT <> "" Then $SREAD_FILE &= $STEXT & @CRLF
			Else
				$SREAD_FILE &= $STEXT & @CRLF & $ASPLIT_FILE[$I] & @CRLF
			EndIf
		ElseIf $I < $ASPLIT_FILE[0] Then
			$SREAD_FILE &= $ASPLIT_FILE[$I] & @CRLF
		ElseIf $I = $ASPLIT_FILE[0] Then
			$SREAD_FILE &= $ASPLIT_FILE[$I]
		EndIf
	Next
	FileWrite($HFILE, $SREAD_FILE)
	FileClose($HFILE)
	Return 1
EndFunc
Func _PATHFULL($SRELATIVEPATH, $SBASEPATH = @WorkingDir)
	If Not $SRELATIVEPATH Or $SRELATIVEPATH = "." Then Return $SBASEPATH
	Local $SFULLPATH = StringReplace($SRELATIVEPATH, "/", "\")
	Local Const $SFULLPATHCONST = $SFULLPATH
	Local $SPATH
	Local $BROOTONLY = StringLeft($SFULLPATH, 1) = "\" And StringMid($SFULLPATH, 2, 1) <> "\"
	For $I = 1 To 2
		$SPATH = StringLeft($SFULLPATH, 2)
		If $SPATH = "\\" Then
			$SFULLPATH = StringTrimLeft($SFULLPATH, 2)
			Local $NSERVERLEN = StringInStr($SFULLPATH, "\") - 1
			$SPATH = "\\" & StringLeft($SFULLPATH, $NSERVERLEN)
			$SFULLPATH = StringTrimLeft($SFULLPATH, $NSERVERLEN)
			ExitLoop
		ElseIf StringRight($SPATH, 1) = ":" Then
			$SFULLPATH = StringTrimLeft($SFULLPATH, 2)
			ExitLoop
		Else
			$SFULLPATH = $SBASEPATH & "\" & $SFULLPATH
		EndIf
	Next
	If $I = 3 Then Return ""
	If StringLeft($SFULLPATH, 1) <> "\" Then
		If StringLeft($SFULLPATHCONST, 2) = StringLeft($SBASEPATH, 2) Then
			$SFULLPATH = $SBASEPATH & "\" & $SFULLPATH
		Else
			$SFULLPATH = "\" & $SFULLPATH
		EndIf
	EndIf
	Local $ATEMP = StringSplit($SFULLPATH, "\")
	Local $APATHPARTS[$ATEMP[0]], $J = 0
	For $I = 2 To $ATEMP[0]
		If $ATEMP[$I] = ".." Then
			If $J Then $J -= 1
		ElseIf NOT ($ATEMP[$I] = "" And $I <> $ATEMP[0]) And $ATEMP[$I] <> "." Then
			$APATHPARTS[$J] = $ATEMP[$I]
			$J += 1
		EndIf
	Next
	$SFULLPATH = $SPATH
	If Not $BROOTONLY Then
		For $I = 0 To $J - 1
			$SFULLPATH &= "\" & $APATHPARTS[$I]
		Next
	Else
		$SFULLPATH &= $SFULLPATHCONST
		If StringInStr($SFULLPATH, "..") Then $SFULLPATH = _PATHFULL($SFULLPATH)
	EndIf
	While StringInStr($SFULLPATH, ".\")
		$SFULLPATH = StringReplace($SFULLPATH, ".\", "\")
	WEnd
	Return $SFULLPATH
EndFunc
Func _PATHGETRELATIVE($SFROM, $STO)
	If StringRight($SFROM, 1) <> "\" Then $SFROM &= "\"
	If StringRight($STO, 1) <> "\" Then $STO &= "\"
	If $SFROM = $STO Then Return SetError(1, 0, StringTrimRight($STO, 1))
	Local $ASFROM = StringSplit($SFROM, "\")
	Local $ASTO = StringSplit($STO, "\")
	If $ASFROM[1] <> $ASTO[1] Then Return SetError(2, 0, StringTrimRight($STO, 1))
	Local $I = 2
	Local $IDIFF = 1
	While 1
		If $ASFROM[$I] <> $ASTO[$I] Then
			$IDIFF = $I
			ExitLoop
		EndIf
		$I += 1
	WEnd
	$I = 1
	Local $SRELPATH = ""
	For $J = 1 To $ASTO[0]
		If $I >= $IDIFF Then
			$SRELPATH &= "\" & $ASTO[$I]
		EndIf
		$I += 1
	Next
	$SRELPATH = StringTrimLeft($SRELPATH, 1)
	$I = 1
	For $J = 1 To $ASFROM[0]
		If $I > $IDIFF Then
			$SRELPATH = "..\" & $SRELPATH
		EndIf
		$I += 1
	Next
	If StringRight($SRELPATH, 1) == "\" Then $SRELPATH = StringTrimRight($SRELPATH, 1)
	Return $SRELPATH
EndFunc
Func _PATHMAKE($SZDRIVE, $SZDIR, $SZFNAME, $SZEXT)
	If StringLen($SZDRIVE) Then
		If NOT (StringLeft($SZDRIVE, 2) = "\\") Then $SZDRIVE = StringLeft($SZDRIVE, 1) & ":"
	EndIf
	If StringLen($SZDIR) Then
		If NOT (StringRight($SZDIR, 1) = "\") And NOT (StringRight($SZDIR, 1) = "/") Then $SZDIR = $SZDIR & "\"
	EndIf
	If StringLen($SZEXT) Then
		If NOT (StringLeft($SZEXT, 1) = ".") Then $SZEXT = "." & $SZEXT
	EndIf
	Return $SZDRIVE & $SZDIR & $SZFNAME & $SZEXT
EndFunc
Func _PATHSPLIT($SZPATH, ByRef $SZDRIVE, ByRef $SZDIR, ByRef $SZFNAME, ByRef $SZEXT)
	Local $DRIVE = ""
	Local $DIR = ""
	Local $FNAME = ""
	Local $EXT = ""
	Local $POS
	Local $ARRAY[5]
	$ARRAY[0] = $SZPATH
	If StringMid($SZPATH, 2, 1) = ":" Then
		$DRIVE = StringLeft($SZPATH, 2)
		$SZPATH = StringTrimLeft($SZPATH, 2)
	ElseIf StringLeft($SZPATH, 2) = "\\" Then
		$SZPATH = StringTrimLeft($SZPATH, 2)
		$POS = StringInStr($SZPATH, "\")
		If $POS = 0 Then $POS = StringInStr($SZPATH, "/")
		If $POS = 0 Then
			$DRIVE = "\\" & $SZPATH
			$SZPATH = ""
		Else
			$DRIVE = "\\" & StringLeft($SZPATH, $POS - 1)
			$SZPATH = StringTrimLeft($SZPATH, $POS - 1)
		EndIf
	EndIf
	Local $NPOSFORWARD = StringInStr($SZPATH, "/", 0, -1)
	Local $NPOSBACKWARD = StringInStr($SZPATH, "\", 0, -1)
	If $NPOSFORWARD >= $NPOSBACKWARD Then
		$POS = $NPOSFORWARD
	Else
		$POS = $NPOSBACKWARD
	EndIf
	$DIR = StringLeft($SZPATH, $POS)
	$FNAME = StringRight($SZPATH, StringLen($SZPATH) - $POS)
	If StringLen($DIR) = 0 Then $FNAME = $SZPATH
	$POS = StringInStr($FNAME, ".", 0, -1)
	If $POS Then
		$EXT = StringRight($FNAME, StringLen($FNAME) - ($POS - 1))
		$FNAME = StringLeft($FNAME, $POS - 1)
	EndIf
	$SZDRIVE = $DRIVE
	$SZDIR = $DIR
	$SZFNAME = $FNAME
	$SZEXT = $EXT
	$ARRAY[1] = $DRIVE
	$ARRAY[2] = $DIR
	$ARRAY[3] = $FNAME
	$ARRAY[4] = $EXT
	Return $ARRAY
EndFunc
Func _REPLACESTRINGINFILE($SZFILENAME, $SZSEARCHSTRING, $SZREPLACESTRING, $FCASENESS = 0, $FOCCURANCE = 1)
	Local $IRETVAL = 0
	Local $NCOUNT, $SENDSWITH
	If StringInStr(FileGetAttrib($SZFILENAME), "R") Then Return SetError(6, 0, -1)
	Local $HFILE = FileOpen($SZFILENAME, $FO_READ)
	If $HFILE = -1 Then Return SetError(1, 0, -1)
	Local $S_TOTFILE = FileRead($HFILE, FileGetSize($SZFILENAME))
	If StringRight($S_TOTFILE, 2) = @CRLF Then
		$SENDSWITH = @CRLF
	ElseIf StringRight($S_TOTFILE, 1) = @CR Then
		$SENDSWITH = @CR
	ElseIf StringRight($S_TOTFILE, 1) = @LF Then
		$SENDSWITH = @LF
	Else
		$SENDSWITH = ""
	EndIf
	Local $AFILELINES = StringSplit(StringStripCR($S_TOTFILE), @LF)
	FileClose($HFILE)
	Local $IENCODING = FILEGETENCODING($SZFILENAME)
	Local $HWRITEHANDLE = FileOpen($SZFILENAME, $IENCODING + $FO_OVERWRITE)
	If $HWRITEHANDLE = -1 Then Return SetError(2, 0, -1)
	For $NCOUNT = 1 To $AFILELINES[0]
		If StringInStr($AFILELINES[$NCOUNT], $SZSEARCHSTRING, $FCASENESS) Then
			$AFILELINES[$NCOUNT] = StringReplace($AFILELINES[$NCOUNT], $SZSEARCHSTRING, $SZREPLACESTRING, 1 - $FOCCURANCE, $FCASENESS)
			$IRETVAL = $IRETVAL + 1
			If $FOCCURANCE = 0 Then
				$IRETVAL = 1
				ExitLoop
			EndIf
		EndIf
	Next
	For $NCOUNT = 1 To $AFILELINES[0] - 1
		If FileWriteLine($HWRITEHANDLE, $AFILELINES[$NCOUNT]) = 0 Then
			FileClose($HWRITEHANDLE)
			Return SetError(3, 0, -1)
		EndIf
	Next
	If $AFILELINES[$NCOUNT] <> "" Then FileWrite($HWRITEHANDLE, $AFILELINES[$NCOUNT] & $SENDSWITH)
	FileClose($HWRITEHANDLE)
	Return $IRETVAL
EndFunc
Func _TEMPFILE($S_DIRECTORYNAME = @TempDir, $S_FILEPREFIX = "~", $S_FILEEXTENSION = ".tmp", $I_RANDOMLENGTH = 7)
	If IsKeyword($S_FILEPREFIX) Then $S_FILEPREFIX = "~"
	If IsKeyword($S_FILEEXTENSION) Then $S_FILEEXTENSION = ".tmp"
	If IsKeyword($I_RANDOMLENGTH) Then $I_RANDOMLENGTH = 7
	If Not FileExists($S_DIRECTORYNAME) Then $S_DIRECTORYNAME = @TempDir
	If Not FileExists($S_DIRECTORYNAME) Then $S_DIRECTORYNAME = @ScriptDir
	If StringRight($S_DIRECTORYNAME, 1) <> "\" Then $S_DIRECTORYNAME = $S_DIRECTORYNAME & "\"
	Local $S_TEMPNAME
	Do
		$S_TEMPNAME = ""
		While StringLen($S_TEMPNAME) < $I_RANDOMLENGTH
			$S_TEMPNAME = $S_TEMPNAME & Chr(Random(97, 122, 1))
		WEnd
		$S_TEMPNAME = $S_DIRECTORYNAME & $S_FILEPREFIX & $S_TEMPNAME & $S_FILEEXTENSION
	Until Not FileExists($S_TEMPNAME)
	Return $S_TEMPNAME
EndFunc
Global Const $DIR_DOORS = @ScriptDir & "\Doors"
Global Const $DIR_CONSOLE = @ScriptDir & "\Console"
Global Const $DIR_LOGGING = @ScriptDir & "\Doors\Logging"
Global Const $DIR_MODULES = @ScriptDir & "\Programs"
Global Const $LOGGFILE_DOORS = $DIR_LOGGING & "\Doors.log"
Func _INITIALIZELOGFILE($MAXSIZE)
	$MAXSIZE = $MAXSIZE / 1048576
	If Not FileExists($DIR_LOGGING) Then DirCreate($DIR_LOGGING)
	If FileExists($LOGGFILE_DOORS) Then
		FileSetAttrib($LOGGFILE_DOORS, "-A-S-R-H")
		If Round(FileGetSize($LOGGFILE_DOORS) / 1048576) > $MAXSIZE Then
			If FileExists($LOGGFILE_DOORS) Then
				FileDelete($LOGGFILE_DOORS)
			EndIf
		EndIf
	Else
	EndIf
EndFunc
Func _INITIALIZELOGGING()
	If Not IsDeclared("eStatus") Then Local $ESTATUS
	GUICtrlSetData($ESTATUS, "")
EndFunc
Func _MEMOLOGGINGWRITE($MESSAGE = "", $ISUCCESS = 0, $TIMESTAMP = True)
	If Not IsDeclared("eStatus") Then Local $ESTATUS
	Local $STRPREFIX = ""
	Select
		Case $ISUCCESS = 1
			GUICtrlSetColor($ESTATUS, 418182)
		Case $ISUCCESS = 2
			GUICtrlSetColor($ESTATUS, 11665408)
		Case $ISUCCESS = 3
			GUICtrlSetColor($ESTATUS, 15104282)
	EndSelect
	Sleep(10)
	_GUICTRLEDIT_APPENDTEXT($ESTATUS, $STRPREFIX & $MESSAGE & @CRLF)
	_LOGGINGWRITE($STRPREFIX & StringReplace($MESSAGE, ", please wait...", ":", 0, 2), $TIMESTAMP)
EndFunc
Func _LOGGINGWRITE($MESSAGE = "", $TIMESTAMP = True)
	Local $OPENLOG, $STIMESTAMP = ""
	$OPENLOG = FileOpen($LOGGFILE_DOORS, 1)
	If $OPENLOG = -1 Then
	EndIf
	If $TIMESTAMP Then $STIMESTAMP = "[" & @MDAY & "/" & @MON & "/" & @YEAR & " " & @HOUR & ":" & @MIN & ":" & @SEC & "] "
	FileWrite($OPENLOG, $STIMESTAMP & $MESSAGE & @CRLF)
	FileClose($OPENLOG)
EndFunc
Func _LANCHDOORSHIVEMODULE($SEXECFILE, $SHIVENAME, $SHFULLNAME, $DMODE = False)
	Local $SEXECPATH = $DIR_MODULES & "\" & $SEXECFILE
	Local $SHAPATH = $DIR_MODULES & "\" & $SHIVENAME & ".7z"
	Local $SHCPATH = $DIR_MODULES & "\" & $SHIVENAME & ".cmd"
	_INITIALIZELOGGING()
	If FileExists($SEXECPATH) And Not FileExists($SHAPATH) Then
		_LAUNCHFIXEDLOCATION($SEXECPATH, $SHFULLNAME)
	Else
		_MEMOLOGGINGWRITE("Configuring " & $SHFULLNAME & " for first-time-use (FTU), please wait...", 1)
		If FileExists($SHAPATH) Then
			_MEMOLOGGINGWRITE("Found [" & $SHIVENAME & ".7z] hive module, continuing with configuration.", 1)
			If Not FileExists($SHCPATH) Then
				_MEMOLOGGINGWRITE("Could not find the [" & $SHIVENAME & ".cmd] file, will attempting to create it, please wait...", 3)
				Local $OCFILE = FileOpen($SHCPATH, 1)
				If $OCFILE = -1 Then
					_MEMOLOGGINGWRITE("Could not create the [" & $SHCPATH & "] file.", 2)
					Return SetError(1, 0, 0)
				EndIf
				FileWrite($OCFILE, "@ECHO OFF" & @CRLF)
				FileWrite($OCFILE, "SET ArchiveName=" & $SHIVENAME & ".7z" & @CRLF)
				FileWrite($OCFILE, "SET DoorsApp=" & $SEXECFILE & @CRLF)
				FileWrite($OCFILE, "SET DoorsAppName=" & $SHFULLNAME & @CRLF)
				FileWrite($OCFILE, "ECHO." & @CRLF)
				FileWrite($OCFILE, "ECHO Testing archive" & @CRLF)
				FileWrite($OCFILE, "ECHO." & @CRLF)
				FileWrite($OCFILE, "..\Console\7za.exe t %ArchiveName%" & @CRLF)
				FileWrite($OCFILE, "IF %ERRORLEVEL% == 0 ( GOTO EXTRACT ) ELSE ( GOTO ERROR )" & @CRLF)
				FileWrite($OCFILE, ":EXTRACT" & @CRLF)
				FileWrite($OCFILE, "ECHO." & @CRLF)
				FileWrite($OCFILE, "ECHO Extracting %DoorsAppName% and preparing for first time usage." & @CRLF)
				FileWrite($OCFILE, "ECHO." & @CRLF)
				FileWrite($OCFILE, "..\Console\7za.exe x %ArchiveName% -aoa" & @CRLF)
				FileWrite($OCFILE, "ECHO." & @CRLF)
				FileWrite($OCFILE, "ECHO Removing %DoorsAppName% archive" & @CRLF)
				FileWrite($OCFILE, "ECHO." & @CRLF)
				If $DMODE = 0 Then FileWrite($OCFILE, "DEL %ArchiveName%" & @CRLF)
				FileWrite($OCFILE, "ECHO." & @CRLF)
				FileWrite($OCFILE, "START %DoorsApp%" & @CRLF)
				FileWrite($OCFILE, "GOTO END" & @CRLF)
				FileWrite($OCFILE, ":ERROR" & @CRLF)
				FileWrite($OCFILE, "ECHO." & @CRLF)
				FileWrite($OCFILE, "ECHO Error: %ERRORLEVEL%" & @CRLF)
				FileWrite($OCFILE, "ECHO." & @CRLF)
				FileWrite($OCFILE, ":END" & @CRLF)
				FileClose($OCFILE)
				Sleep(250)
				_MEMOLOGGINGWRITE($SHFULLNAME & " configuration file created @ " & "[" & $SHCPATH & "]", 1)
				_RUNONCECONFIGURATION($SHCPATH)
			Else
				_RUNONCECONFIGURATION($SHCPATH)
			EndIf
		EndIf
	EndIf
EndFunc
Func _RUNONCECONFIGURATION($SHHIVECONF)
	If FileExists($SHHIVECONF) Then
		_MEMOLOGGINGWRITE("Completing the RunOnce hive configuration, please wait...")
		ShellExecute($SHHIVECONF, "", $DIR_MODULES, "", @SW_SHOW)
	EndIf
EndFunc
Func _LAUNCHFIXEDLOCATION($SPATH, $SNAME, $SPARAM = "", $SWORKING = "", $SVERB = "", $SHOWFLAG = @SW_SHOW)
	If FileExists($SPATH) Then
		_MEMOLOGGINGWRITE("Launching " & $SNAME)
		ShellExecute($SPATH, $SPARAM, $SWORKING, $SVERB, $SHOWFLAG)
	Else
		_MEMOLOGGINGWRITE("Doors cannot find [" & $SPATH & "]", 2)
		MsgBox(262160, $SPATH, "Doors cannot find '" & $SPATH & "'. Although the Doors hive can function without it, " & "the specific function will not be available.", 60)
	EndIf
EndFunc
Func _OPENFOLDER($SPATH)
	_INITIALIZELOGGING()
	_MEMOLOGGINGWRITE("Opening [" & $SPATH & "]")
	ShellExecute($SPATH)
	If @error Then _MEMOLOGGINGWRITE("Could not open [" & $SPATH & "]", 2)
EndFunc
Func _OPENTEXTFILE($STEXTFILE)
	_INITIALIZELOGGING()
	_MEMOLOGGINGWRITE("Opening [" & $STEXTFILE & "]")
	If FileExists(@ScriptDir & "\Doors\Bin\Notepad2\Notepad2.exe") Then
		ShellExecute(@ScriptDir & "\Doors\Bin\Notepad2\Notepad2.exe", $STEXTFILE)
	Else
		ShellExecute($STEXTFILE)
	EndIf
EndFunc
Func _GETDOORSVERSION($IFLAG)
	Local $VERRETURN = FileGetVersion(@ScriptFullPath)
	Local $SPLRETURN = StringSplit($VERRETURN, ".")
	If $SPLRETURN[0] >= 4 Then
		If $IFLAG = 1 Then
			Return $SPLRETURN[1]
		ElseIf $IFLAG = 2 Then
			Return $SPLRETURN[2]
		ElseIf $IFLAG = 3 Then
			Return $SPLRETURN[3]
		ElseIf $IFLAG = 4 Then
			Return $SPLRETURN[4]
		ElseIf $IFLAG = 5 Then
			Return $SPLRETURN[1] & "." & $SPLRETURN[2]
		ElseIf $IFLAG = 6 Then
			Return $VERRETURN
		EndIf
	EndIf
EndFunc
Func _DRAWSTATUSSIZEFROMPERCENTAGE($FRBAR, $PERC, $BCLEFT, $BCTOP, $BCWIDTH, $BCHEIGHT)
	If $PERC > -1 Then
		If $PERC > 100 Then $PERC = 100
		If $PERC = 0 Then
			GUICtrlSetState($FRBAR, $GUI_HIDE)
		Else
			If BitAND(GUICtrlGetState($FRBAR), $GUI_HIDE) = $GUI_HIDE Then
				GUICtrlSetState($FRBAR, $GUI_SHOW)
			EndIf
			GUICtrlSetPos($FRBAR, $BCLEFT + 1, $BCTOP + 1, (($BCWIDTH - 2) * $PERC) / 100, $BCHEIGHT - 2)
		EndIf
	EndIf
EndFunc
Global $AGUIEXT_SECTION_DATA[1][9] = [[0, 0, 1, 0, "", 9999]]
Global $AGUIEXT_OBJ_DATA[1][2] = [[0]]
Global $FGUIEXT_SECTIONACTION = False
Func _GUIEXTENDER_INIT($HWND, $IORIENT = 0, $IFIXED = 0)
	If Not IsHWnd($HWND) Then Return SetError(1, 0, 0)
	If $AGUIEXT_SECTION_DATA[0][3] Then Return SetError(2, 0, 0)
	Switch $IORIENT
		Case 0, 1
		Case Else
			Return SetError(3, 1, 0)
	EndSwitch
	Switch $IFIXED
		Case 0, 1, 2
		Case Else
			Return SetError(3, 2, 0)
	EndSwitch
	$AGUIEXT_SECTION_DATA[0][3] = $HWND
	$AGUIEXT_SECTION_DATA[0][1] = $IORIENT
	$AGUIEXT_SECTION_DATA[0][4] = $IFIXED
	Opt("GUIResizeMode", $GUI_DOCKALL)
	GUISetOnEvent(-5, "_GUIExtender_Restore")
	Return 1
EndFunc
Func _GUIEXTENDER_SECTION_START($ISECTION_COORD, $ISECTION_SIZE)
	If $AGUIEXT_SECTION_DATA[0][0] > 1 Then
		If $AGUIEXT_SECTION_DATA[$AGUIEXT_SECTION_DATA[0][0] - 1][0] + $AGUIEXT_SECTION_DATA[$AGUIEXT_SECTION_DATA[0][0] - 1][1] > $ISECTION_COORD Then Return SetError(1, 0, 0)
	EndIf
	$AGUIEXT_SECTION_DATA[0][0] += 1
	If UBound($AGUIEXT_SECTION_DATA) < $AGUIEXT_SECTION_DATA[0][0] + 1 Then
		ReDim $AGUIEXT_SECTION_DATA[$AGUIEXT_SECTION_DATA[0][0] + 1][9]
	EndIf
	$AGUIEXT_SECTION_DATA[$AGUIEXT_SECTION_DATA[0][0]][0] = $ISECTION_COORD
	$AGUIEXT_SECTION_DATA[$AGUIEXT_SECTION_DATA[0][0]][1] = $ISECTION_SIZE
	If $AGUIEXT_SECTION_DATA[$AGUIEXT_SECTION_DATA[0][0]][2] = "" Then $AGUIEXT_SECTION_DATA[$AGUIEXT_SECTION_DATA[0][0]][2] = 2
	If $AGUIEXT_SECTION_DATA[0][1] Then
		$AGUIEXT_SECTION_DATA[$AGUIEXT_SECTION_DATA[0][0]][3] = GUICtrlCreateLabel("", $ISECTION_COORD, 0, 1, 1)
	Else
		$AGUIEXT_SECTION_DATA[$AGUIEXT_SECTION_DATA[0][0]][3] = GUICtrlCreateLabel("", 0, $ISECTION_COORD, 1, 1)
	EndIf
	GUICtrlSetBkColor(-1, -2)
	GUICtrlSetState(-1, 128)
	If $AGUIEXT_SECTION_DATA[$AGUIEXT_SECTION_DATA[0][0]][5] = "" Then $AGUIEXT_SECTION_DATA[$AGUIEXT_SECTION_DATA[0][0]][5] = 9999
	Return $AGUIEXT_SECTION_DATA[0][0]
EndFunc
Func _GUIEXTENDER_SECTION_END()
	$AGUIEXT_SECTION_DATA[$AGUIEXT_SECTION_DATA[0][0]][4] = GUICtrlCreateDummy() - 1
EndFunc
Func _GUIEXTENDER_SECTION_ACTION($ISECTION, $STEXT_EXTENDED = "", $STEXT_RETRACTED = "", $IX = 0, $IY = 0, $IW = 1, $IH = 1, $ITYPE = 0, $IEVENTMODE = 0)
	If $ISECTION > 1 And UBound($AGUIEXT_SECTION_DATA) < $ISECTION + 1 Then
		ReDim $AGUIEXT_SECTION_DATA[$ISECTION + 1][9]
	EndIf
	$AGUIEXT_SECTION_DATA[$ISECTION][2] = 1
	Local $IDEF_ARROWS = 0
	If $STEXT_EXTENDED = "" And $STEXT_RETRACTED = "" Then
		$IDEF_ARROWS = 1
		If $AGUIEXT_SECTION_DATA[0][1] Then
			$STEXT_EXTENDED = 3
			$STEXT_RETRACTED = 4
		Else
			$STEXT_EXTENDED = 5
			$STEXT_RETRACTED = 6
		EndIf
	EndIf
	Switch $ITYPE
		Case 0
			$AGUIEXT_SECTION_DATA[$ISECTION][5] = GUICtrlCreateButton($STEXT_EXTENDED, $IX, $IY, $IW, $IH)
		Case Else
			$AGUIEXT_SECTION_DATA[$ISECTION][5] = GUICtrlCreateCheckbox($STEXT_EXTENDED, $IX, $IY, $IW, $IH, 4096)
			GUICtrlSetState(-1, 1)
	EndSwitch
	If $AGUIEXT_SECTION_DATA[$ISECTION][5] = 0 Then Return SetError(2, 0, 0)
	If $IDEF_ARROWS Then GUICtrlSetFont($AGUIEXT_SECTION_DATA[$ISECTION][5], 10, 400, 0, "Webdings")
	If $IEVENTMODE Then GUICtrlSetOnEvent($AGUIEXT_SECTION_DATA[$ISECTION][5], "_GUIExtender_Section_Action_Event")
	$AGUIEXT_SECTION_DATA[$ISECTION][6] = $STEXT_EXTENDED
	$AGUIEXT_SECTION_DATA[$ISECTION][7] = $STEXT_RETRACTED
	$AGUIEXT_SECTION_DATA[$ISECTION][8] = $ITYPE
	Return 1
EndFunc
Func _GUIEXTENDER_ACTION($IMSG)
	If $IMSG = -5 Then _GUIEXTENDER_RESTORE()
	For $I = 0 To $AGUIEXT_SECTION_DATA[0][0]
		If $IMSG = $AGUIEXT_SECTION_DATA[$I][5] Then
			Switch $AGUIEXT_SECTION_DATA[$I][2]
				Case 0
					_GUIEXTENDER_SECTION_EXTEND($I, True)
				Case Else
					_GUIEXTENDER_SECTION_EXTEND($I, False)
			EndSwitch
			$FGUIEXT_SECTIONACTION = True
		EndIf
	Next
EndFunc
Func _GUIEXTENDER_RESTORE()
	GUISetState(@SW_HIDE, $AGUIEXT_SECTION_DATA[0][3])
	For $I = UBound($AGUIEXT_SECTION_DATA) - 1 To 1 Step -1
		If $AGUIEXT_SECTION_DATA[$I][2] <> 2 Then
			Switch $AGUIEXT_SECTION_DATA[$I][2]
				Case 0
					_GUIEXTENDER_SECTION_EXTEND($I)
					_GUIEXTENDER_SECTION_EXTEND($I, False)
				Case 1
					_GUIEXTENDER_SECTION_EXTEND($I, False)
					_GUIEXTENDER_SECTION_EXTEND($I)
			EndSwitch
			ExitLoop
		EndIf
	Next
	GUISetState(@SW_SHOW, $AGUIEXT_SECTION_DATA[0][3])
EndFunc
Func _GUIEXTENDER_SECTION_EXTEND($ISECTION, $FEXTEND = True, $IFIXED = 9)
	Local $APOS, $ICID, $IDELTA_GUI
	If BitAND(WinGetState($AGUIEXT_SECTION_DATA[0][3]), 16) Then Return SetError(3, 0, 0)
	If $ISECTION = 0 Then
		_GUIEXTENDER_SECTION_ALL_EXTEND($FEXTEND)
		Return 1
	EndIf
	If $ISECTION > UBound($AGUIEXT_SECTION_DATA) - 1 Then Return SetError(1, 1, 0)
	If $AGUIEXT_SECTION_DATA[$ISECTION][1] = "" Then Return SetError(1, 2, 0)
	IF ($AGUIEXT_SECTION_DATA[$ISECTION][2] = 1 And $FEXTEND = True) OR ($AGUIEXT_SECTION_DATA[$ISECTION][2] = 0 And $FEXTEND = False) Then Return SetError(2, 0, 0)
	Switch $IFIXED
		Case 0, 1, 2
		Case Else
			$IFIXED = $AGUIEXT_SECTION_DATA[0][4]
	EndSwitch
	Local $AGUIPOS = WinGetPos($AGUIEXT_SECTION_DATA[0][3])
	Local $IGUI_FIXED = $AGUIPOS[2]
	Local $IGUI_ADJUST = $AGUIPOS[3]
	If $AGUIEXT_SECTION_DATA[0][1] Then
		$IGUI_FIXED = $AGUIPOS[3]
		$IGUI_ADJUST = $AGUIPOS[2]
	EndIf
	If $FEXTEND Then
		GUICtrlSetData($AGUIEXT_SECTION_DATA[$ISECTION][5], $AGUIEXT_SECTION_DATA[$ISECTION][6])
		If $AGUIEXT_SECTION_DATA[$ISECTION][8] = 1 Then GUICtrlSetState($AGUIEXT_SECTION_DATA[$ISECTION][5], 1)
		$AGUIEXT_SECTION_DATA[$ISECTION][2] = 1
		$IGUI_ADJUST += $AGUIEXT_SECTION_DATA[$ISECTION][1]
	Else
		GUICtrlSetData($AGUIEXT_SECTION_DATA[$ISECTION][5], $AGUIEXT_SECTION_DATA[$ISECTION][7])
		If $AGUIEXT_SECTION_DATA[$ISECTION][8] = 1 Then GUICtrlSetState($AGUIEXT_SECTION_DATA[$ISECTION][5], 4)
		$AGUIEXT_SECTION_DATA[$ISECTION][2] = 0
		$IGUI_ADJUST -= $AGUIEXT_SECTION_DATA[$ISECTION][1]
	EndIf
	For $I = $AGUIEXT_SECTION_DATA[1][3] To $AGUIEXT_SECTION_DATA[$AGUIEXT_SECTION_DATA[0][0]][4]
	Next
	If $AGUIEXT_SECTION_DATA[0][1] Then
		$IDELTA_GUI = $AGUIPOS[2] - $IGUI_ADJUST
		Switch $IFIXED
			Case 0
				WinMove($AGUIEXT_SECTION_DATA[0][3], "", Default, Default, $IGUI_ADJUST, $IGUI_FIXED)
			Case 1
				WinMove($AGUIEXT_SECTION_DATA[0][3], "", $AGUIPOS[0] + Int($IDELTA_GUI / 2), Default, $IGUI_ADJUST, $IGUI_FIXED)
			Case 2
				WinMove($AGUIEXT_SECTION_DATA[0][3], "", $AGUIPOS[0] + $IDELTA_GUI, Default, $IGUI_ADJUST, $IGUI_FIXED)
		EndSwitch
	Else
		$IDELTA_GUI = $AGUIPOS[3] - $IGUI_ADJUST
		Switch $IFIXED
			Case 0
				WinMove($AGUIEXT_SECTION_DATA[0][3], "", Default, Default, $IGUI_FIXED, $IGUI_ADJUST)
			Case 1
				WinMove($AGUIEXT_SECTION_DATA[0][3], "", Default, $AGUIPOS[1] + Int($IDELTA_GUI / 2), $IGUI_FIXED, $IGUI_ADJUST)
			Case 2
				WinMove($AGUIEXT_SECTION_DATA[0][3], "", Default, $AGUIPOS[1] + $IDELTA_GUI, $IGUI_FIXED, $IGUI_ADJUST)
		EndSwitch
	EndIf
	Local $INEXT_COORD = $AGUIEXT_SECTION_DATA[1][0]
	Local $IADJUST_X = 0, $IADJUST_Y = 0
	For $I = 1 To $AGUIEXT_SECTION_DATA[0][0]
		If $AGUIEXT_SECTION_DATA[$I][2] > 0 Then
			$APOS = ControlGetPos($AGUIEXT_SECTION_DATA[0][3], "", $AGUIEXT_SECTION_DATA[$I][3])
			If $AGUIEXT_SECTION_DATA[0][1] Then
				$IADJUST_X = $APOS[0] - $INEXT_COORD
				If $APOS[1] > $IGUI_FIXED Then $IADJUST_Y = $IGUI_FIXED
			Else
				$IADJUST_Y = $APOS[1] - $INEXT_COORD
				If $APOS[0] > $IGUI_FIXED Then $IADJUST_X = $IGUI_FIXED
			EndIf
			For $J = $AGUIEXT_SECTION_DATA[$I][3] To $AGUIEXT_SECTION_DATA[$I][4]
				$ICID = $J
				$APOS = ControlGetPos($AGUIEXT_SECTION_DATA[0][3], "", $ICID)
				If @error Then
					For $K = 1 To $AGUIEXT_OBJ_DATA[0][0]
						If $AGUIEXT_OBJ_DATA[$K][0] = $J Then
							$APOS = ControlGetPos($AGUIEXT_SECTION_DATA[0][3], "", $AGUIEXT_OBJ_DATA[$K][1])
							$ICID = $AGUIEXT_OBJ_DATA[$K][1]
							ExitLoop
						EndIf
					Next
					If $ICID = $J And GUICtrlGetHandle($J) = 0 Then $ICID = "Ignore"
				EndIf
				If $ICID = "Ignore" Then ContinueLoop
				ControlMove($AGUIEXT_SECTION_DATA[0][3], "", $ICID, $APOS[0] - $IADJUST_X, $APOS[1] - $IADJUST_Y)
				GUICtrlSetState($J, 16)
			Next
			$INEXT_COORD += $AGUIEXT_SECTION_DATA[$I][1]
		Else
			$APOS = ControlGetPos($AGUIEXT_SECTION_DATA[0][3], "", $AGUIEXT_SECTION_DATA[$I][3])
			If $AGUIEXT_SECTION_DATA[0][1] Then
				If $APOS[1] < $IGUI_FIXED Then
					For $J = $AGUIEXT_SECTION_DATA[$I][3] To $AGUIEXT_SECTION_DATA[$I][4]
						$ICID = $J
						$APOS = ControlGetPos($AGUIEXT_SECTION_DATA[0][3], "", $J)
						If @error Then
							For $K = 1 To $AGUIEXT_OBJ_DATA[0][0]
								If $AGUIEXT_OBJ_DATA[$K][0] = $J Then
									$APOS = ControlGetPos($AGUIEXT_SECTION_DATA[0][3], "", $AGUIEXT_OBJ_DATA[$K][1])
									$ICID = $AGUIEXT_OBJ_DATA[$K][1]
									ExitLoop
								EndIf
							Next
							If $ICID = $J And GUICtrlGetHandle($J) = 0 Then $ICID = "Ignore"
						EndIf
						If $ICID = "Ignore" Then ContinueLoop
						ControlMove($AGUIEXT_SECTION_DATA[0][3], "", $ICID, $APOS[0], $APOS[1] + $IGUI_FIXED)
					Next
				EndIf
			Else
				If $APOS[0] < $IGUI_FIXED Then
					For $J = $AGUIEXT_SECTION_DATA[$I][3] To $AGUIEXT_SECTION_DATA[$I][4]
						$ICID = $J
						$APOS = ControlGetPos($AGUIEXT_SECTION_DATA[0][3], "", $J)
						If @error Then
							For $K = 1 To $AGUIEXT_OBJ_DATA[0][0]
								If $AGUIEXT_OBJ_DATA[$K][0] = $J Then
									$APOS = ControlGetPos($AGUIEXT_SECTION_DATA[0][3], "", $AGUIEXT_OBJ_DATA[$K][1])
									$ICID = $AGUIEXT_OBJ_DATA[$K][1]
									ExitLoop
								EndIf
							Next
							If $ICID = $J And GUICtrlGetHandle($J) = 0 Then $ICID = "Ignore"
						EndIf
						If $ICID = "Ignore" Then ContinueLoop
						ControlMove($AGUIEXT_SECTION_DATA[0][3], "", $ICID, $APOS[0] + $IGUI_FIXED, $APOS[1])
					Next
				EndIf
			EndIf
		EndIf
	Next
	If $AGUIEXT_SECTION_DATA[0][5] <> 9999 Then
		Local $IALL_STATE = 0
		For $I = 1 To $AGUIEXT_SECTION_DATA[0][0]
			If $AGUIEXT_SECTION_DATA[$I][2] = 1 Then
				$IALL_STATE = 1
				ExitLoop
			EndIf
		Next
		Switch $IALL_STATE
			Case 0
				$AGUIEXT_SECTION_DATA[0][2] = 0
				GUICtrlSetData($AGUIEXT_SECTION_DATA[0][5], $AGUIEXT_SECTION_DATA[0][7])
				If $AGUIEXT_SECTION_DATA[0][8] = 1 Then GUICtrlSetState($AGUIEXT_SECTION_DATA[0][5], 4)
			Case Else
				$AGUIEXT_SECTION_DATA[0][2] = 1
				GUICtrlSetData($AGUIEXT_SECTION_DATA[0][5], $AGUIEXT_SECTION_DATA[0][6])
				If $AGUIEXT_SECTION_DATA[0][8] = 1 Then GUICtrlSetState($AGUIEXT_SECTION_DATA[0][5], 1)
		EndSwitch
	EndIf
	Return 1
EndFunc
Func _GUIEXTENDER_SECTION_STATE($ISECTION)
	If $ISECTION > UBound($AGUIEXT_SECTION_DATA) - 1 Then Return SetError(1, 0, -1)
	Return $AGUIEXT_SECTION_DATA[$ISECTION][2]
EndFunc
Func _GUIEXTENDER_UDFCTRLCHECK($HCTRL_HANDLE, $ISECTION, $IX, $IY)
	Local $ICTRL_COORD
	If Not IsHWnd($HCTRL_HANDLE) Or Not WinExists($HCTRL_HANDLE) Then Return SetError(1, 0, 0)
	If $ISECTION > UBound($AGUIEXT_SECTION_DATA) - 1 Then Return SetError(2, 0, 0)
	If Not IsInt($IX) Or Not IsInt($IY) Then Return SetError(3, 0, 0)
	Switch _GUIEXTENDER_SECTION_STATE($ISECTION)
		Case 1
			ControlShow($AGUIEXT_SECTION_DATA[0][3], "", $HCTRL_HANDLE)
			If $AGUIEXT_SECTION_DATA[0][1] = 0 Then
				$ICTRL_COORD = $IY + $AGUIEXT_SECTION_DATA[1][0]
			Else
				$ICTRL_COORD = $IX + $AGUIEXT_SECTION_DATA[1][0]
			EndIf
			For $I = 1 To $ISECTION - 1
				If _GUIEXTENDER_SECTION_STATE($I) Then
					$ICTRL_COORD += $AGUIEXT_SECTION_DATA[$I][1]
				EndIf
			Next
			If $AGUIEXT_SECTION_DATA[0][1] = 0 Then
				WinMove($HCTRL_HANDLE, "", $IX, $ICTRL_COORD)
			Else
				WinMove($HCTRL_HANDLE, "", $ICTRL_COORD, $IY)
			EndIf
		Case 0
			ControlHide($AGUIEXT_SECTION_DATA[0][3], "", $HCTRL_HANDLE)
	EndSwitch
	$FGUIEXT_SECTIONACTION = False
	Return 1
EndFunc
Func _GUIEXTENDER_ACTIONCHECK()
	Return $FGUIEXT_SECTIONACTION
EndFunc
Func _GUIEXTENDER_OBJ_DATA($ICID, $IOBJ)
	$AGUIEXT_OBJ_DATA[0][0] += 1
	ReDim $AGUIEXT_OBJ_DATA[$AGUIEXT_OBJ_DATA[0][0] + 1][2]
	$AGUIEXT_OBJ_DATA[$AGUIEXT_OBJ_DATA[0][0]][0] = $ICID
	Local $ARET = DllCall("oleacc.dll", "int", "WindowFromAccessibleObject", "idispatch", $IOBJ, "hwnd*", 0)
	If @error Or $ARET[0] Then Return SetError(1, 0, 0)
	$AGUIEXT_OBJ_DATA[$AGUIEXT_OBJ_DATA[0][0]][1] = $ARET[2]
	Return 1
EndFunc
Func _GUIEXTENDER_CLEAR()
	Global $AGUIEXT_SECTION_DATA[1][9] = [[0, 0, 1, 0, "", 9999]]
EndFunc
Func _GUIEXTENDER_SECTION_ALL_EXTEND($FEXTEND = True)
	Local $ISTATE = 0
	If $FEXTEND Then $ISTATE = 1
	For $I = 1 To $AGUIEXT_SECTION_DATA[0][0]
		If $AGUIEXT_SECTION_DATA[$I][2] <> 2 And $AGUIEXT_SECTION_DATA[$I][2] = NOT ($ISTATE) Then
			_GUIEXTENDER_SECTION_EXTEND($I, $FEXTEND)
			$AGUIEXT_SECTION_DATA[$I][2] = $ISTATE
			Switch $FEXTEND
				Case True
					GUICtrlSetData($AGUIEXT_SECTION_DATA[$I][5], $AGUIEXT_SECTION_DATA[$I][6])
					If $AGUIEXT_SECTION_DATA[$I][8] = 1 Then GUICtrlSetState($AGUIEXT_SECTION_DATA[$I][5], 1)
				Case False
					GUICtrlSetData($AGUIEXT_SECTION_DATA[$I][5], $AGUIEXT_SECTION_DATA[$I][7])
					If $AGUIEXT_SECTION_DATA[$I][8] = 1 Then GUICtrlSetState($AGUIEXT_SECTION_DATA[$I][5], 4)
			EndSwitch
		EndIf
	Next
EndFunc
Func _GUIEXTENDER_SECTION_ACTION_EVENT()
	_GUIEXTENDER_ACTION(@GUI_CtrlId)
	If Not IsDeclared("GuiUpdate") Then Local $GUIUPDATE
	$GUIUPDATE = True
EndFunc
Global Const $MF_UNCHECKED = 0
Global Const $MF_STRING = 0
Global Const $MF_GRAYED = 1
Global Const $MF_DISABLED = 2
Global Const $MF_BITMAP = 4
Global Const $MF_CHECKED = 8
Global Const $MF_POPUP = 16
Global Const $MF_MENUBARBREAK = 32
Global Const $MF_MENUBREAK = 64
Global Const $MF_HILITE = 128
Global Const $MF_OWNERDRAW = 256
Global Const $MF_USECHECKBITMAPS = 512
Global Const $MF_BYPOSITION = 1024
Global Const $MF_SEPARATOR = 2048
Global Const $MF_DEFAULT = 4096
Global Const $MF_SYSMENU = 8192
Global Const $MF_HELP = 16384
Global Const $MF_RIGHTJUSTIFY = 16384
Global Const $MF_MOUSESELECT = 32768
Global Const $MFS_GRAYED = 3
Global Const $MFS_DISABLED = $MFS_GRAYED
Global Const $MFS_CHECKED = $MF_CHECKED
Global Const $MFS_HILITE = $MF_HILITE
Global Const $MFS_DEFAULT = $MF_DEFAULT
Global Const $MFT_BITMAP = $MF_BITMAP
Global Const $MFT_MENUBARBREAK = $MF_MENUBARBREAK
Global Const $MFT_MENUBREAK = $MF_MENUBREAK
Global Const $MFT_OWNERDRAW = $MF_OWNERDRAW
Global Const $MFT_RADIOCHECK = 512
Global Const $MFT_SEPARATOR = $MF_SEPARATOR
Global Const $MFT_RIGHTORDER = 8192
Global Const $MFT_RIGHTJUSTIFY = $MF_RIGHTJUSTIFY
Global Const $MIIM_STATE = 1
Global Const $MIIM_ID = 2
Global Const $MIIM_SUBMENU = 4
Global Const $MIIM_CHECKMARKS = 8
Global Const $MIIM_TYPE = 16
Global Const $MIIM_DATA = 32
Global Const $MIIM_DATAMASK = 63
Global Const $MIIM_STRING = 64
Global Const $MIIM_BITMAP = 128
Global Const $MIIM_FTYPE = 256
Global Const $MIM_MAXHEIGHT = 1
Global Const $MIM_BACKGROUND = 2
Global Const $MIM_HELPID = 4
Global Const $MIM_MENUDATA = 8
Global Const $MIM_STYLE = 16
Global Const $MIM_APPLYTOSUBMENUS = -2147483648
Global Const $MNS_CHECKORBMP = 67108864
Global Const $MNS_NOTIFYBYPOS = 134217728
Global Const $MNS_AUTODISMISS = 268435456
Global Const $MNS_DRAGDROP = 536870912
Global Const $MNS_MODELESS = 1073741824
Global Const $MNS_NOCHECK = -2147483648
Global Const $TPM_LEFTBUTTON = 0
Global Const $TPM_LEFTALIGN = 0
Global Const $TPM_TOPALIGN = 0
Global Const $TPM_HORIZONTAL = 0
Global Const $TPM_RECURSE = 1
Global Const $TPM_RIGHTBUTTON = 2
Global Const $TPM_CENTERALIGN = 4
Global Const $TPM_RIGHTALIGN = 8
Global Const $TPM_VCENTERALIGN = 16
Global Const $TPM_BOTTOMALIGN = 32
Global Const $TPM_VERTICAL = 64
Global Const $TPM_NONOTIFY = 128
Global Const $TPM_RETURNCMD = 256
Global Const $TPM_HORPOSANIMATION = 1024
Global Const $TPM_HORNEGANIMATION = 2048
Global Const $TPM_VERPOSANIMATION = 4096
Global Const $TPM_VERNEGANIMATION = 8192
Global Const $TPM_NOANIMATION = 16384
Global Const $TPM_LAYOUTRTL = 32768
Global Const $SC_SIZE = 61440
Global Const $SC_MOVE = 61456
Global Const $SC_MINIMIZE = 61472
Global Const $SC_MAXIMIZE = 61488
Global Const $SC_NEXTWINDOW = 61504
Global Const $SC_PREVWINDOW = 61520
Global Const $SC_CLOSE = 61536
Global Const $SC_VSCROLL = 61552
Global Const $SC_HSCROLL = 61568
Global Const $SC_MOUSEMENU = 61584
Global Const $SC_KEYMENU = 61696
Global Const $SC_ARRANGE = 61712
Global Const $SC_RESTORE = 61728
Global Const $SC_TASKLIST = 61744
Global Const $SC_SCREENSAVE = 61760
Global Const $SC_HOTKEY = 61776
Global Const $SC_DEFAULT = 61792
Global Const $SC_MONITORPOWER = 61808
Global Const $SC_CONTEXTHELP = 61824
Global Const $SC_SEPARATOR = 61455
Global Const $OBJID_SYSMENU = -1
Global Const $OBJID_MENU = -3
Global Const $__MENUCONSTANT_OBJID_CLIENT = -4
Global Const $TAGMENUBARINFO = "dword Size;" & $TAGRECT & ";handle hMenu;handle hWndMenu;bool Focused"
Global Const $TAGMDINEXTMENU = "handle hMenuIn;handle hMenuNext;hwnd hWndNext"
Global Const $TAGMENUGETOBJECTINFO = "dword Flags;uint Pos;handle hMenu;ptr RIID;ptr Obj"
Global Const $TAGTPMPARAMS = "uint Size;" & $TAGRECT
Func _GUICTRLMENU_ADDMENUITEM($HMENU, $STEXT, $ICMDID = 0, $HSUBMENU = 0)
	Local $IINDEX = _GUICTRLMENU_GETITEMCOUNT($HMENU)
	Local $TMENU = DllStructCreate($TAGMENUITEMINFO)
	DllStructSetData($TMENU, "Size", DllStructGetSize($TMENU))
	DllStructSetData($TMENU, "Mask", BitOR($MIIM_ID, $MIIM_STRING, $MIIM_SUBMENU))
	DllStructSetData($TMENU, "ID", $ICMDID)
	DllStructSetData($TMENU, "SubMenu", $HSUBMENU)
	If $STEXT = "" Then
		DllStructSetData($TMENU, "Mask", $MIIM_FTYPE)
		DllStructSetData($TMENU, "Type", $MFT_SEPARATOR)
	Else
		DllStructSetData($TMENU, "Mask", BitOR($MIIM_ID, $MIIM_STRING, $MIIM_SUBMENU))
		Local $TTEXT = DllStructCreate("wchar Text[" & StringLen($STEXT) + 1 & "]")
		DllStructSetData($TTEXT, "Text", $STEXT)
		DllStructSetData($TMENU, "TypeData", DllStructGetPtr($TTEXT))
	EndIf
	Local $ARESULT = DllCall("User32.dll", "bool", "InsertMenuItemW", "handle", $HMENU, "uint", $IINDEX, "bool", True, "struct*", $TMENU)
	If @error Then Return SetError(@error, @extended, -1)
	Return SetExtended($ARESULT[0], $IINDEX)
EndFunc
Func _GUICTRLMENU_APPENDMENU($HMENU, $IFLAGS, $INEWITEM, $PNEWITEM)
	Local $STYPE = "wstr"
	If BitAND($IFLAGS, $MF_BITMAP) Then $STYPE = "handle"
	If BitAND($IFLAGS, $MF_OWNERDRAW) Then $STYPE = "ulong_ptr"
	Local $ARESULT = DllCall("User32.dll", "bool", "AppendMenuW", "handle", $HMENU, "uint", $IFLAGS, "uint_ptr", $INEWITEM, $STYPE, $PNEWITEM)
	If @error Then Return SetError(@error, @extended, False)
	If $ARESULT[0] = 0 Then Return SetError(10, 0, False)
	_GUICTRLMENU_DRAWMENUBAR(_GUICTRLMENU_FINDPARENT($HMENU))
	Return True
EndFunc
Func _GUICTRLMENU_CHECKMENUITEM($HMENU, $IITEM, $FCHECK = True, $FBYPOS = True)
	Local $IBYPOS = 0
	If $FCHECK Then $IBYPOS = BitOR($IBYPOS, $MF_CHECKED)
	If $FBYPOS Then $IBYPOS = BitOR($IBYPOS, $MF_BYPOSITION)
	Local $ARESULT = DllCall("User32.dll", "dword", "CheckMenuItem", "handle", $HMENU, "uint", $IITEM, "uint", $IBYPOS)
	If @error Then Return SetError(@error, @extended, -1)
	Return $ARESULT[0]
EndFunc
Func _GUICTRLMENU_CHECKRADIOITEM($HMENU, $IFIRST, $ILAST, $ICHECK, $FBYPOS = True)
	Local $IBYPOS = 0
	If $FBYPOS Then $IBYPOS = $MF_BYPOSITION
	Local $ARESULT = DllCall("User32.dll", "bool", "CheckMenuRadioItem", "handle", $HMENU, "uint", $IFIRST, "uint", $ILAST, "uint", $ICHECK, "uint", $IBYPOS)
	If @error Then Return SetError(@error, @extended, False)
	Return $ARESULT[0]
EndFunc
Func _GUICTRLMENU_CREATEMENU($ISTYLE = 8)
	Local $ARESULT = DllCall("User32.dll", "handle", "CreateMenu")
	If @error Then Return SetError(@error, @extended, 0)
	If $ARESULT[0] = 0 Then Return SetError(10, 0, 0)
	_GUICTRLMENU_SETMENUSTYLE($ARESULT[0], $ISTYLE)
	Return $ARESULT[0]
EndFunc
Func _GUICTRLMENU_CREATEPOPUP($ISTYLE = 8)
	Local $ARESULT = DllCall("User32.dll", "handle", "CreatePopupMenu")
	If @error Then Return SetError(@error, @extended, 0)
	If $ARESULT[0] = 0 Then Return SetError(10, 0, 0)
	_GUICTRLMENU_SETMENUSTYLE($ARESULT[0], $ISTYLE)
	Return $ARESULT[0]
EndFunc
Func _GUICTRLMENU_DELETEMENU($HMENU, $IITEM, $FBYPOS = True)
	Local $IBYPOS = 0
	If $FBYPOS Then $IBYPOS = $MF_BYPOSITION
	Local $ARESULT = DllCall("User32.dll", "bool", "DeleteMenu", "handle", $HMENU, "uint", $IITEM, "uint", $IBYPOS)
	If @error Then Return SetError(@error, @extended, False)
	If $ARESULT[0] = 0 Then Return SetError(10, 0, False)
	_GUICTRLMENU_DRAWMENUBAR(_GUICTRLMENU_FINDPARENT($HMENU))
	Return True
EndFunc
Func _GUICTRLMENU_DESTROYMENU($HMENU)
	Local $ARESULT = DllCall("User32.dll", "bool", "DestroyMenu", "handle", $HMENU)
	If @error Then Return SetError(@error, @extended, False)
	Return $ARESULT[0]
EndFunc
Func _GUICTRLMENU_DRAWMENUBAR($HWND)
	Local $ARESULT = DllCall("User32.dll", "bool", "DrawMenuBar", "hwnd", $HWND)
	If @error Then Return SetError(@error, @extended, False)
	Return $ARESULT[0]
EndFunc
Func _GUICTRLMENU_ENABLEMENUITEM($HMENU, $IITEM, $ISTATE = 0, $FBYPOS = True)
	Local $IBYPOS = $ISTATE
	If $FBYPOS Then $IBYPOS = BitOR($IBYPOS, $MF_BYPOSITION)
	Local $ARESULT = DllCall("User32.dll", "bool", "EnableMenuItem", "handle", $HMENU, "uint", $IITEM, "uint", $IBYPOS)
	If @error Then Return SetError(@error, @extended, False)
	If $ARESULT[0] = 0 Then Return SetError(10, 0, False)
	_GUICTRLMENU_DRAWMENUBAR(_GUICTRLMENU_FINDPARENT($HMENU))
	Return True
EndFunc
Func _GUICTRLMENU_ENDMENU()
	Local $ARESULT = DllCall("User32.dll", "bool", "EndMenu")
	If @error Then Return SetError(@error, @extended, False)
	Return $ARESULT[0]
EndFunc
Func _GUICTRLMENU_FINDITEM($HMENU, $STEXT, $FINSTR = False, $ISTART = 0)
	Local $SMENU
	For $II = $ISTART To _GUICTRLMENU_GETITEMCOUNT($HMENU)
		$SMENU = StringReplace(_GUICTRLMENU_GETITEMTEXT($HMENU, $II), "&", "")
		Switch $FINSTR
			Case False
				If $SMENU = $STEXT Then Return $II
			Case True
				If StringInStr($SMENU, $STEXT) Then Return $II
		EndSwitch
	Next
	Return -1
EndFunc
Func _GUICTRLMENU_FINDPARENT($HMENU)
	Local $HLIST = _WINAPI_ENUMWINDOWSTOP()
	For $II = 1 To $HLIST[0][0]
		If _GUICTRLMENU_GETMENU($HLIST[$II][0]) = $HMENU Then Return $HLIST[$II][0]
	Next
EndFunc
Func _GUICTRLMENU_GETITEMBMP($HMENU, $IITEM, $FBYPOS = True)
	Local $TINFO = _GUICTRLMENU_GETITEMINFO($HMENU, $IITEM, $FBYPOS)
	Return DllStructGetData($TINFO, "BmpItem")
EndFunc
Func _GUICTRLMENU_GETITEMBMPCHECKED($HMENU, $IITEM, $FBYPOS = True)
	Local $TINFO = _GUICTRLMENU_GETITEMINFO($HMENU, $IITEM, $FBYPOS)
	Return DllStructGetData($TINFO, "BmpChecked")
EndFunc
Func _GUICTRLMENU_GETITEMBMPUNCHECKED($HMENU, $IITEM, $FBYPOS = True)
	Local $TINFO = _GUICTRLMENU_GETITEMINFO($HMENU, $IITEM, $FBYPOS)
	Return DllStructGetData($TINFO, "BmpUnchecked")
EndFunc
Func _GUICTRLMENU_GETITEMCHECKED($HMENU, $IITEM, $FBYPOS = True)
	Return BitAND(_GUICTRLMENU_GETITEMSTATEEX($HMENU, $IITEM, $FBYPOS), $MF_CHECKED) <> 0
EndFunc
Func _GUICTRLMENU_GETITEMCOUNT($HMENU)
	Local $ARESULT = DllCall("User32.dll", "int", "GetMenuItemCount", "handle", $HMENU)
	If @error Then Return SetError(@error, @extended, -1)
	Return $ARESULT[0]
EndFunc
Func _GUICTRLMENU_GETITEMDATA($HMENU, $IITEM, $FBYPOS = True)
	Local $TINFO = _GUICTRLMENU_GETITEMINFO($HMENU, $IITEM, $FBYPOS)
	Return DllStructGetData($TINFO, "ItemData")
EndFunc
Func _GUICTRLMENU_GETITEMDEFAULT($HMENU, $IITEM, $FBYPOS = True)
	Return BitAND(_GUICTRLMENU_GETITEMSTATEEX($HMENU, $IITEM, $FBYPOS), $MF_DEFAULT) <> 0
EndFunc
Func _GUICTRLMENU_GETITEMDISABLED($HMENU, $IITEM, $FBYPOS = True)
	Return BitAND(_GUICTRLMENU_GETITEMSTATEEX($HMENU, $IITEM, $FBYPOS), $MF_DISABLED) <> 0
EndFunc
Func _GUICTRLMENU_GETITEMENABLED($HMENU, $IITEM, $FBYPOS = True)
	Return BitAND(_GUICTRLMENU_GETITEMSTATEEX($HMENU, $IITEM, $FBYPOS), $MF_DISABLED) = 0
EndFunc
Func _GUICTRLMENU_GETITEMGRAYED($HMENU, $IITEM, $FBYPOS = True)
	Return BitAND(_GUICTRLMENU_GETITEMSTATEEX($HMENU, $IITEM, $FBYPOS), $MF_GRAYED) <> 0
EndFunc
Func _GUICTRLMENU_GETITEMHIGHLIGHTED($HMENU, $IITEM, $FBYPOS = True)
	Return BitAND(_GUICTRLMENU_GETITEMSTATEEX($HMENU, $IITEM, $FBYPOS), $MF_HILITE) <> 0
EndFunc
Func _GUICTRLMENU_GETITEMID($HMENU, $IITEM, $FBYPOS = True)
	Local $TINFO = _GUICTRLMENU_GETITEMINFO($HMENU, $IITEM, $FBYPOS)
	Return DllStructGetData($TINFO, "ID")
EndFunc
Func _GUICTRLMENU_GETITEMINFO($HMENU, $IITEM, $FBYPOS = True)
	Local $TINFO = DllStructCreate($TAGMENUITEMINFO)
	DllStructSetData($TINFO, "Size", DllStructGetSize($TINFO))
	DllStructSetData($TINFO, "Mask", $MIIM_DATAMASK)
	Local $ARESULT = DllCall("User32.dll", "bool", "GetMenuItemInfo", "handle", $HMENU, "uint", $IITEM, "bool", $FBYPOS, "struct*", $TINFO)
	If @error Then Return SetError(@error, @extended, 0)
	Return SetExtended($ARESULT[0], $TINFO)
EndFunc
Func _GUICTRLMENU_GETITEMRECT($HWND, $HMENU, $IITEM)
	Local $TRECT = _GUICTRLMENU_GETITEMRECTEX($HWND, $HMENU, $IITEM)
	Local $ARECT[4]
	$ARECT[0] = DllStructGetData($TRECT, "Left")
	$ARECT[1] = DllStructGetData($TRECT, "Top")
	$ARECT[2] = DllStructGetData($TRECT, "Right")
	$ARECT[3] = DllStructGetData($TRECT, "Bottom")
	Return $ARECT
EndFunc
Func _GUICTRLMENU_GETITEMRECTEX($HWND, $HMENU, $IITEM)
	Local $TRECT = DllStructCreate($TAGRECT)
	Local $ARESULT = DllCall("User32.dll", "bool", "GetMenuItemRect", "hwnd", $HWND, "handle", $HMENU, "uint", $IITEM, "struct*", $TRECT)
	If @error Then Return SetError(@error, @extended, 0)
	Return SetExtended($ARESULT[0], $TRECT)
EndFunc
Func _GUICTRLMENU_GETITEMSTATE($HMENU, $IITEM, $FBYPOS = True)
	Local $IRET = 0
	Local $ISTATE = _GUICTRLMENU_GETITEMSTATEEX($HMENU, $IITEM, $FBYPOS)
	If BitAND($ISTATE, $MFS_CHECKED) <> 0 Then $IRET = BitOR($IRET, 1)
	If BitAND($ISTATE, $MFS_DEFAULT) <> 0 Then $IRET = BitOR($IRET, 2)
	If BitAND($ISTATE, $MFS_DISABLED) <> 0 Then $IRET = BitOR($IRET, 4)
	If BitAND($ISTATE, $MFS_GRAYED) <> 0 Then $IRET = BitOR($IRET, 8)
	If BitAND($ISTATE, $MFS_HILITE) <> 0 Then $IRET = BitOR($IRET, 16)
	Return $IRET
EndFunc
Func _GUICTRLMENU_GETITEMSTATEEX($HMENU, $IITEM, $FBYPOS = True)
	Local $TINFO = _GUICTRLMENU_GETITEMINFO($HMENU, $IITEM, $FBYPOS)
	Return DllStructGetData($TINFO, "State")
EndFunc
Func _GUICTRLMENU_GETITEMSUBMENU($HMENU, $IITEM)
	Local $ARESULT = DllCall("User32.dll", "handle", "GetSubMenu", "handle", $HMENU, "int", $IITEM)
	If @error Then Return SetError(@error, @extended, 0)
	Return $ARESULT[0]
EndFunc
Func _GUICTRLMENU_GETITEMTEXT($HMENU, $IITEM, $FBYPOS = True)
	Local $IBYPOS = 0
	If $FBYPOS Then $IBYPOS = $MF_BYPOSITION
	Local $ARESULT = DllCall("User32.dll", "int", "GetMenuStringW", "handle", $HMENU, "uint", $IITEM, "wstr", 0, "int", 4096, "uint", $IBYPOS)
	If @error Then Return SetError(@error, @extended, 0)
	Return SetExtended($ARESULT[0], $ARESULT[3])
EndFunc
Func _GUICTRLMENU_GETITEMTYPE($HMENU, $IITEM, $FBYPOS = True)
	Local $TINFO = _GUICTRLMENU_GETITEMINFO($HMENU, $IITEM, $FBYPOS)
	Return DllStructGetData($TINFO, "Type")
EndFunc
Func _GUICTRLMENU_GETMENU($HWND)
	Local $ARESULT = DllCall("User32.dll", "handle", "GetMenu", "hwnd", $HWND)
	If @error Then Return SetError(@error, @extended, 0)
	Return $ARESULT[0]
EndFunc
Func _GUICTRLMENU_GETMENUBACKGROUND($HMENU)
	Local $TINFO = _GUICTRLMENU_GETMENUINFO($HMENU)
	Return DllStructGetData($TINFO, "hBack")
EndFunc
Func _GUICTRLMENU_GETMENUBARINFO($HWND, $IITEM = 0, $IOBJECT = 1)
	Local $AOBJECT[3] = [$__MENUCONSTANT_OBJID_CLIENT, $OBJID_MENU, $OBJID_SYSMENU]
	Local $TINFO = DllStructCreate($TAGMENUBARINFO)
	DllStructSetData($TINFO, "Size", DllStructGetSize($TINFO))
	Local $ARESULT = DllCall("User32.dll", "bool", "GetMenuBarInfo", "hwnd", $HWND, "long", $AOBJECT[$IOBJECT], "long", $IITEM, "struct*", $TINFO)
	If @error Then Return SetError(@error, @extended, 0)
	Local $AINFO[8]
	$AINFO[0] = DllStructGetData($TINFO, "Left")
	$AINFO[1] = DllStructGetData($TINFO, "Top")
	$AINFO[2] = DllStructGetData($TINFO, "Right")
	$AINFO[3] = DllStructGetData($TINFO, "Bottom")
	$AINFO[4] = DllStructGetData($TINFO, "hMenu")
	$AINFO[5] = DllStructGetData($TINFO, "hWndMenu")
	$AINFO[6] = BitAND(DllStructGetData($TINFO, "Focused"), 1) <> 0
	$AINFO[7] = BitAND(DllStructGetData($TINFO, "Focused"), 2) <> 0
	Return SetExtended($ARESULT[0], $AINFO)
EndFunc
Func _GUICTRLMENU_GETMENUCONTEXTHELPID($HMENU)
	Local $TINFO = _GUICTRLMENU_GETMENUINFO($HMENU)
	Return DllStructGetData($TINFO, "ContextHelpID")
EndFunc
Func _GUICTRLMENU_GETMENUDATA($HMENU)
	Local $TINFO = _GUICTRLMENU_GETMENUINFO($HMENU)
	Return DllStructGetData($TINFO, "MenuData")
EndFunc
Func _GUICTRLMENU_GETMENUDEFAULTITEM($HMENU, $FBYPOS = True, $IFLAGS = 0)
	Local $ARESULT = DllCall("User32.dll", "INT", "GetMenuDefaultItem", "handle", $HMENU, "uint", $FBYPOS, "uint", $IFLAGS)
	If @error Then Return SetError(@error, @extended, -1)
	Return $ARESULT[0]
EndFunc
Func _GUICTRLMENU_GETMENUHEIGHT($HMENU)
	Local $TINFO = _GUICTRLMENU_GETMENUINFO($HMENU)
	Return DllStructGetData($TINFO, "YMax")
EndFunc
Func _GUICTRLMENU_GETMENUINFO($HMENU)
	Local $TINFO = DllStructCreate($TAGMENUINFO)
	DllStructSetData($TINFO, "Size", DllStructGetSize($TINFO))
	DllStructSetData($TINFO, "Mask", BitOR($MIM_BACKGROUND, $MIM_HELPID, $MIM_MAXHEIGHT, $MIM_MENUDATA, $MIM_STYLE))
	Local $ARESULT = DllCall("User32.dll", "bool", "GetMenuInfo", "handle", $HMENU, "struct*", $TINFO)
	If @error Then Return SetError(@error, @extended, 0)
	Return SetExtended($ARESULT[0], $TINFO)
EndFunc
Func _GUICTRLMENU_GETMENUSTYLE($HMENU)
	Local $TINFO = _GUICTRLMENU_GETMENUINFO($HMENU)
	Return DllStructGetData($TINFO, "Style")
EndFunc
Func _GUICTRLMENU_GETSYSTEMMENU($HWND, $FREVERT = False)
	Local $ARESULT = DllCall("User32.dll", "hwnd", "GetSystemMenu", "hwnd", $HWND, "int", $FREVERT)
	If @error Then Return SetError(@error, @extended, 0)
	Return $ARESULT[0]
EndFunc
Func _GUICTRLMENU_INSERTMENUITEM($HMENU, $IINDEX, $STEXT, $ICMDID = 0, $HSUBMENU = 0)
	Local $TMENU = DllStructCreate($TAGMENUITEMINFO)
	DllStructSetData($TMENU, "Size", DllStructGetSize($TMENU))
	DllStructSetData($TMENU, "Mask", BitOR($MIIM_ID, $MIIM_STRING, $MIIM_SUBMENU))
	DllStructSetData($TMENU, "ID", $ICMDID)
	DllStructSetData($TMENU, "SubMenu", $HSUBMENU)
	If $STEXT = "" Then
		DllStructSetData($TMENU, "Mask", $MIIM_FTYPE)
		DllStructSetData($TMENU, "Type", $MFT_SEPARATOR)
	Else
		DllStructSetData($TMENU, "Mask", BitOR($MIIM_ID, $MIIM_STRING, $MIIM_SUBMENU))
		Local $TTEXT = DllStructCreate("wchar Text[" & StringLen($STEXT) + 1 & "]")
		DllStructSetData($TTEXT, "Text", $STEXT)
		DllStructSetData($TMENU, "TypeData", DllStructGetPtr($TTEXT))
	EndIf
	Local $ARESULT = DllCall("User32.dll", "bool", "InsertMenuItemW", "handle", $HMENU, "uint", $IINDEX, "bool", True, "struct*", $TMENU)
	If @error Then Return SetError(@error, @extended, False)
	Return $ARESULT[0]
EndFunc
Func _GUICTRLMENU_INSERTMENUITEMEX($HMENU, $IINDEX, ByRef $TMENU, $FBYPOS = True)
	Local $ARESULT = DllCall("User32.dll", "bool", "InsertMenuItemW", "handle", $HMENU, "uint", $IINDEX, "bool", $FBYPOS, "struct*", $TMENU)
	If @error Then Return SetError(@error, @extended, False)
	Return $ARESULT[0]
EndFunc
Func _GUICTRLMENU_ISMENU($HMENU)
	Local $ARESULT = DllCall("User32.dll", "bool", "IsMenu", "handle", $HMENU)
	If @error Then Return SetError(@error, @extended, False)
	Return $ARESULT[0]
EndFunc
Func _GUICTRLMENU_LOADMENU($HINST, $SMENUNAME)
	Local $ARESULT = DllCall("User32.dll", "handle", "LoadMenuW", "handle", $HINST, "wstr", $SMENUNAME)
	If @error Then Return SetError(@error, @extended, 0)
	Return $ARESULT[0]
EndFunc
Func _GUICTRLMENU_MAPACCELERATOR($HMENU, $CACCEL)
	Local $STEXT
	Local $ICOUNT = _GUICTRLMENU_GETITEMCOUNT($HMENU)
	For $II = 0 To $ICOUNT - 1
		$STEXT = _GUICTRLMENU_GETITEMTEXT($HMENU, $II)
		If StringInStr($STEXT, "&" & $CACCEL) > 0 Then Return $II
	Next
	Return -1
EndFunc
Func _GUICTRLMENU_MENUITEMFROMPOINT($HWND, $HMENU, $IX = -1, $IY = -1)
	If $IX = -1 Then $IX = _WINAPI_GETMOUSEPOSX()
	If $IY = -1 Then $IY = _WINAPI_GETMOUSEPOSY()
	Local $ARESULT = DllCall("User32.dll", "int", "MenuItemFromPoint", "hwnd", $HWND, "handle", $HMENU, "int", $IX, "int", $IY)
	If @error Then Return SetError(@error, @extended, -1)
	Return $ARESULT[0]
EndFunc
Func _GUICTRLMENU_REMOVEMENU($HMENU, $IITEM, $FBYPOS = True)
	Local $IBYPOS = 0
	If $FBYPOS Then $IBYPOS = $MF_BYPOSITION
	Local $ARESULT = DllCall("User32.dll", "bool", "RemoveMenu", "handle", $HMENU, "uint", $IITEM, "uint", $IBYPOS)
	If @error Then Return SetError(@error, @extended, False)
	If $ARESULT[0] = 0 Then Return SetError(10, 0, False)
	_GUICTRLMENU_DRAWMENUBAR(_GUICTRLMENU_FINDPARENT($HMENU))
	Return True
EndFunc
Func _GUICTRLMENU_SETITEMBITMAPS($HMENU, $IITEM, $HCHECKED, $HUNCHECKED, $FBYPOS = True)
	Local $IBYPOS = 0
	If $FBYPOS Then $IBYPOS = $MF_BYPOSITION
	Local $ARESULT = DllCall("User32.dll", "bool", "SetMenuItemBitmaps", "handle", $HMENU, "uint", $IITEM, "uint", $IBYPOS, "handle", $HUNCHECKED, "handle", $HCHECKED)
	If @error Then Return SetError(@error, @extended, False)
	Return $ARESULT[0]
EndFunc
Func _GUICTRLMENU_SETITEMBMP($HMENU, $IITEM, $HBMP, $FBYPOS = True)
	Local $TINFO = DllStructCreate($TAGMENUITEMINFO)
	DllStructSetData($TINFO, "Size", DllStructGetSize($TINFO))
	DllStructSetData($TINFO, "Mask", $MIIM_BITMAP)
	DllStructSetData($TINFO, "BmpItem", $HBMP)
	Return _GUICTRLMENU_SETITEMINFO($HMENU, $IITEM, $TINFO, $FBYPOS)
EndFunc
Func _GUICTRLMENU_SETITEMBMPCHECKED($HMENU, $IITEM, $HBMP, $FBYPOS = True)
	Local $TINFO = _GUICTRLMENU_GETITEMINFO($HMENU, $IITEM, $FBYPOS)
	DllStructSetData($TINFO, "Mask", $MIIM_CHECKMARKS)
	DllStructSetData($TINFO, "BmpChecked", $HBMP)
	Return _GUICTRLMENU_SETITEMINFO($HMENU, $IITEM, $TINFO, $FBYPOS)
EndFunc
Func _GUICTRLMENU_SETITEMBMPUNCHECKED($HMENU, $IITEM, $HBMP, $FBYPOS = True)
	Local $TINFO = _GUICTRLMENU_GETITEMINFO($HMENU, $IITEM, $FBYPOS)
	DllStructSetData($TINFO, "Mask", $MIIM_CHECKMARKS)
	DllStructSetData($TINFO, "BmpUnchecked", $HBMP)
	Return _GUICTRLMENU_SETITEMINFO($HMENU, $IITEM, $TINFO, $FBYPOS)
EndFunc
Func _GUICTRLMENU_SETITEMCHECKED($HMENU, $IITEM, $FSTATE = True, $FBYPOS = True)
	Return _GUICTRLMENU_SETITEMSTATE($HMENU, $IITEM, $MFS_CHECKED, $FSTATE, $FBYPOS)
EndFunc
Func _GUICTRLMENU_SETITEMDATA($HMENU, $IITEM, $IDATA, $FBYPOS = True)
	Local $TINFO = DllStructCreate($TAGMENUITEMINFO)
	DllStructSetData($TINFO, "Size", DllStructGetSize($TINFO))
	DllStructSetData($TINFO, "Mask", $MIIM_DATA)
	DllStructSetData($TINFO, "ItemData", $IDATA)
	Return _GUICTRLMENU_SETITEMINFO($HMENU, $IITEM, $TINFO, $FBYPOS)
EndFunc
Func _GUICTRLMENU_SETITEMDEFAULT($HMENU, $IITEM, $FSTATE = True, $FBYPOS = True)
	Return _GUICTRLMENU_SETITEMSTATE($HMENU, $IITEM, $MFS_DEFAULT, $FSTATE, $FBYPOS)
EndFunc
Func _GUICTRLMENU_SETITEMDISABLED($HMENU, $IITEM, $FSTATE = True, $FBYPOS = True)
	Return _GUICTRLMENU_SETITEMSTATE($HMENU, $IITEM, BitOR($MFS_DISABLED, $MFS_GRAYED), $FSTATE, $FBYPOS)
EndFunc
Func _GUICTRLMENU_SETITEMENABLED($HMENU, $IITEM, $FSTATE = True, $FBYPOS = True)
	Return _GUICTRLMENU_SETITEMSTATE($HMENU, $IITEM, BitOR($MFS_DISABLED, $MFS_GRAYED), Not $FSTATE, $FBYPOS)
EndFunc
Func _GUICTRLMENU_SETITEMGRAYED($HMENU, $IITEM, $FSTATE = True, $FBYPOS = True)
	Return _GUICTRLMENU_SETITEMSTATE($HMENU, $IITEM, $MFS_GRAYED, $FSTATE, $FBYPOS)
EndFunc
Func _GUICTRLMENU_SETITEMHIGHLIGHTED($HMENU, $IITEM, $FSTATE = True, $FBYPOS = True)
	Return _GUICTRLMENU_SETITEMSTATE($HMENU, $IITEM, $MFS_HILITE, $FSTATE, $FBYPOS)
EndFunc
Func _GUICTRLMENU_SETITEMID($HMENU, $IITEM, $IID, $FBYPOS = True)
	Local $TINFO = DllStructCreate($TAGMENUITEMINFO)
	DllStructSetData($TINFO, "Size", DllStructGetSize($TINFO))
	DllStructSetData($TINFO, "Mask", $MIIM_ID)
	DllStructSetData($TINFO, "ID", $IID)
	Return _GUICTRLMENU_SETITEMINFO($HMENU, $IITEM, $TINFO, $FBYPOS)
EndFunc
Func _GUICTRLMENU_SETITEMINFO($HMENU, $IITEM, ByRef $TINFO, $FBYPOS = True)
	DllStructSetData($TINFO, "Size", DllStructGetSize($TINFO))
	Local $ARESULT = DllCall("User32.dll", "bool", "SetMenuItemInfoW", "handle", $HMENU, "uint", $IITEM, "bool", $FBYPOS, "struct*", $TINFO)
	If @error Then Return SetError(@error, @extended, False)
	Return $ARESULT[0]
EndFunc
Func _GUICTRLMENU_SETITEMSTATE($HMENU, $IITEM, $ISTATE, $FSTATE = True, $FBYPOS = True)
	Local $IFLAG = _GUICTRLMENU_GETITEMSTATEEX($HMENU, $IITEM, $FBYPOS)
	If $FSTATE Then
		$ISTATE = BitOR($IFLAG, $ISTATE)
	Else
		$ISTATE = BitAND($IFLAG, BitNOT($ISTATE))
	EndIf
	Local $TINFO = DllStructCreate($TAGMENUITEMINFO)
	DllStructSetData($TINFO, "Size", DllStructGetSize($TINFO))
	DllStructSetData($TINFO, "Mask", $MIIM_STATE)
	DllStructSetData($TINFO, "State", $ISTATE)
	Return _GUICTRLMENU_SETITEMINFO($HMENU, $IITEM, $TINFO, $FBYPOS)
EndFunc
Func _GUICTRLMENU_SETITEMSUBMENU($HMENU, $IITEM, $HSUBMENU, $FBYPOS = True)
	Local $TINFO = DllStructCreate($TAGMENUITEMINFO)
	DllStructSetData($TINFO, "Size", DllStructGetSize($TINFO))
	DllStructSetData($TINFO, "Mask", $MIIM_SUBMENU)
	DllStructSetData($TINFO, "SubMenu", $HSUBMENU)
	Return _GUICTRLMENU_SETITEMINFO($HMENU, $IITEM, $TINFO, $FBYPOS)
EndFunc
Func _GUICTRLMENU_SETITEMTEXT($HMENU, $IITEM, $STEXT, $FBYPOS = True)
	Local $TBUFFER = DllStructCreate("wchar Text[" & StringLen($STEXT) + 1 & "]")
	DllStructSetData($TBUFFER, "Text", $STEXT)
	Local $TINFO = DllStructCreate($TAGMENUITEMINFO)
	DllStructSetData($TINFO, "Size", DllStructGetSize($TINFO))
	DllStructSetData($TINFO, "Mask", $MIIM_STRING)
	DllStructSetData($TINFO, "TypeData", DllStructGetPtr($TBUFFER))
	Return _GUICTRLMENU_SETITEMINFO($HMENU, $IITEM, $TINFO, $FBYPOS)
EndFunc
Func _GUICTRLMENU_SETITEMTYPE($HMENU, $IITEM, $ITYPE, $FBYPOS = True)
	Local $TINFO = DllStructCreate($TAGMENUITEMINFO)
	DllStructSetData($TINFO, "Size", DllStructGetSize($TINFO))
	DllStructSetData($TINFO, "Mask", $MIIM_FTYPE)
	DllStructSetData($TINFO, "Type", $ITYPE)
	Return _GUICTRLMENU_SETITEMINFO($HMENU, $IITEM, $TINFO, $FBYPOS)
EndFunc
Func _GUICTRLMENU_SETMENU($HWND, $HMENU)
	Local $ARESULT = DllCall("User32.dll", "bool", "SetMenu", "hwnd", $HWND, "handle", $HMENU)
	If @error Then Return SetError(@error, @extended, False)
	Return $ARESULT[0]
EndFunc
Func _GUICTRLMENU_SETMENUBACKGROUND($HMENU, $HBRUSH)
	Local $TINFO = DllStructCreate($TAGMENUINFO)
	DllStructSetData($TINFO, "Mask", $MIM_BACKGROUND)
	DllStructSetData($TINFO, "hBack", $HBRUSH)
	Return _GUICTRLMENU_SETMENUINFO($HMENU, $TINFO)
EndFunc
Func _GUICTRLMENU_SETMENUCONTEXTHELPID($HMENU, $IHELPID)
	Local $TINFO = DllStructCreate($TAGMENUINFO)
	DllStructSetData($TINFO, "Mask", $MIM_HELPID)
	DllStructSetData($TINFO, "ContextHelpID", $IHELPID)
	Return _GUICTRLMENU_SETMENUINFO($HMENU, $TINFO)
EndFunc
Func _GUICTRLMENU_SETMENUDATA($HMENU, $IDATA)
	Local $TINFO = DllStructCreate($TAGMENUINFO)
	DllStructSetData($TINFO, "Mask", $MIM_MENUDATA)
	DllStructSetData($TINFO, "MenuData", $IDATA)
	Return _GUICTRLMENU_SETMENUINFO($HMENU, $TINFO)
EndFunc
Func _GUICTRLMENU_SETMENUDEFAULTITEM($HMENU, $IITEM, $FBYPOS = True)
	Local $ARESULT = DllCall("User32.dll", "bool", "SetMenuDefaultItem", "handle", $HMENU, "uint", $IITEM, "uint", $FBYPOS)
	If @error Then Return SetError(@error, @extended, False)
	Return $ARESULT[0]
EndFunc
Func _GUICTRLMENU_SETMENUHEIGHT($HMENU, $IHEIGHT)
	Local $TINFO = DllStructCreate($TAGMENUINFO)
	DllStructSetData($TINFO, "Mask", $MIM_MAXHEIGHT)
	DllStructSetData($TINFO, "YMax", $IHEIGHT)
	Return _GUICTRLMENU_SETMENUINFO($HMENU, $TINFO)
EndFunc
Func _GUICTRLMENU_SETMENUINFO($HMENU, ByRef $TINFO)
	DllStructSetData($TINFO, "Size", DllStructGetSize($TINFO))
	Local $ARESULT = DllCall("User32.dll", "bool", "SetMenuInfo", "handle", $HMENU, "struct*", $TINFO)
	If @error Then Return SetError(@error, @extended, False)
	Return $ARESULT[0]
EndFunc
Func _GUICTRLMENU_SETMENUSTYLE($HMENU, $ISTYLE)
	Local $TINFO = DllStructCreate($TAGMENUINFO)
	DllStructSetData($TINFO, "Mask", $MIM_STYLE)
	DllStructSetData($TINFO, "Style", $ISTYLE)
	Return _GUICTRLMENU_SETMENUINFO($HMENU, $TINFO)
EndFunc
Func _GUICTRLMENU_TRACKPOPUPMENU($HMENU, $HWND, $IX = -1, $IY = -1, $IALIGNX = 1, $IALIGNY = 1, $INOTIFY = 0, $IBUTTONS = 0)
	If $IX = -1 Then $IX = _WINAPI_GETMOUSEPOSX()
	If $IY = -1 Then $IY = _WINAPI_GETMOUSEPOSY()
	Local $IFLAGS = 0
	Switch $IALIGNX
		Case 1
			$IFLAGS = BitOR($IFLAGS, $TPM_LEFTALIGN)
		Case 2
			$IFLAGS = BitOR($IFLAGS, $TPM_RIGHTALIGN)
		Case Else
			$IFLAGS = BitOR($IFLAGS, $TPM_CENTERALIGN)
	EndSwitch
	Switch $IALIGNY
		Case 1
			$IFLAGS = BitOR($IFLAGS, $TPM_TOPALIGN)
		Case 2
			$IFLAGS = BitOR($IFLAGS, $TPM_VCENTERALIGN)
		Case Else
			$IFLAGS = BitOR($IFLAGS, $TPM_BOTTOMALIGN)
	EndSwitch
	If BitAND($INOTIFY, 1) <> 0 Then $IFLAGS = BitOR($IFLAGS, $TPM_NONOTIFY)
	If BitAND($INOTIFY, 2) <> 0 Then $IFLAGS = BitOR($IFLAGS, $TPM_RETURNCMD)
	Switch $IBUTTONS
		Case 1
			$IFLAGS = BitOR($IFLAGS, $TPM_RIGHTBUTTON)
		Case Else
			$IFLAGS = BitOR($IFLAGS, $TPM_LEFTBUTTON)
	EndSwitch
	Local $ARESULT = DllCall("User32.dll", "bool", "TrackPopupMenu", "handle", $HMENU, "uint", $IFLAGS, "int", $IX, "int", $IY, "int", 0, "hwnd", $HWND, "ptr", 0)
	If @error Then Return SetError(@error, @extended, 0)
	Return $ARESULT[0]
EndFunc
Global $__G_GUICTRLMENUEX_USECALLBACK
Func _GUICTRLMENUEX_STARTUP($USECALLBACK = Default)
	If IsKeyword($USECALLBACK) Then
		If __GUICTRLMENUEX_VISTAANDLATER() Then
			$USECALLBACK = False
		Else
			$USECALLBACK = True
		EndIf
	EndIf
	If $USECALLBACK Then
		GUIRegisterMsg($WM_DRAWITEM, "__GUICtrlMenuEx_WM_DRAWITEM")
		GUIRegisterMsg($WM_MEASUREITEM, "__GUICtrlMenuEx_WM_MEASUREITEM")
	Else
		GUIRegisterMsg($WM_DRAWITEM, "")
		GUIRegisterMsg($WM_MEASUREITEM, "")
	EndIf
	$__G_GUICTRLMENUEX_USECALLBACK = $USECALLBACK
EndFunc
Func _GUICTRLMENUEX_SETITEMICON($MENU, $ITEM, $ICON, $BYPOS = True)
	If $ICON Then
		If $__G_GUICTRLMENUEX_USECALLBACK Then
			$ICON = _WINAPI_COPYICON($ICON)
			Local $MENUITEMINFO = _GUICTRLMENU_GETITEMINFO($MENU, $ITEM, $BYPOS)
			DllStructSetData($MENUITEMINFO, "Mask", $MIIM_BITMAP)
			DllStructSetData($MENUITEMINFO, "BmpItem", -1)
			_GUICTRLMENU_SETITEMINFO($MENU, $ITEM, $MENUITEMINFO, $BYPOS)
			_GUICTRLMENU_SETITEMDATA($MENU, $ITEM, $ICON)
		Else
			Local $BITMAP = __GUICTRLMENUEX_CREATEBITMAPFROMICON($ICON)
			_GUICTRLMENU_SETITEMBMP($MENU, $ITEM, $BITMAP, $BYPOS)
		EndIf
		Return True
	EndIf
	Return False
EndFunc
Func _GUICTRLMENUEX_ADDMENUITEM($MENU, $TEXT, $CMDID = 0, $ICON = 0, $SUBMENU = 0)
	Local $INDEX = _GUICTRLMENU_ADDMENUITEM($MENU, $TEXT, $CMDID, $SUBMENU)
	_GUICTRLMENUEX_SETITEMICON($MENU, $INDEX, $ICON)
	Return $INDEX
EndFunc
Func _GUICTRLMENUEX_INSERTMENUITEM($MENU, $INDEX, $TEXT, $CMDID = 0, $ICON = 0, $SUBMENU = 0)
	If _GUICTRLMENU_INSERTMENUITEM($MENU, $INDEX, $TEXT, $CMDID, $SUBMENU) Then
		If _GUICTRLMENUEX_SETITEMICON($MENU, $INDEX, $ICON) Then Return True
	EndIf
	Return False
EndFunc
Func _GUICTRLMENUEX_ADDMENUBAR($MENU)
	Local $ITEM = _GUICTRLMENU_ADDMENUITEM($MENU, "")
	_GUICTRLMENU_SETITEMTYPE($MENU, $ITEM, $MFT_SEPARATOR)
EndFunc
Func _GUICTRLMENUEX_INSERTMENUBAR($MENU, $INDEX)
	If _GUICTRLMENU_INSERTMENUITEM($MENU, $INDEX, "") Then
		_GUICTRLMENU_SETITEMTYPE($MENU, $INDEX, $MFT_SEPARATOR)
		Return True
	EndIf
	Return False
EndFunc
Func _GUICTRLMENUEX_DELETEMENU($MENU, $ITEM, $BYPOS = True)
	If $__G_GUICTRLMENUEX_USECALLBACK Then
		Local $ICON = _GUICTRLMENU_GETITEMDATA($MENU, $ITEM, $BYPOS)
		_WINAPI_DESTROYICON($ICON)
	Else
		Local $BITMAP = _GUICTRLMENU_GETITEMBMP($MENU, $ITEM, $BYPOS)
		_WINAPI_DELETEOBJECT($BITMAP)
	EndIf
	Return _GUICTRLMENU_DELETEMENU($MENU, $ITEM, $BYPOS)
EndFunc
Func _GUICTRLMENUEX_DESTROYMENU($MENU)
	Local $COUNT = _GUICTRLMENU_GETITEMCOUNT($MENU)
	For $I = 1 To $COUNT
		_GUICTRLMENUEX_DELETEMENU($MENU, 0)
	Next
	Return _GUICTRLMENU_DESTROYMENU($MENU)
EndFunc
Func __GUICTRLMENUEX_WM_MEASUREITEM($HWND, $MSG, $WPARAM, $LPARAM)
	If $__G_GUICTRLMENUEX_USECALLBACK Then
		Local $MEASUREITEM = DllStructCreate("UINT CtlType;UINT CtlID;UINT itemID;UINT itemWidth;UINT itemHeight;ULONG_PTR itemData", $LPARAM)
		If DllStructGetData($MEASUREITEM, "CtlType") = 1 Then
			Local $ICON = DllStructGetData($MEASUREITEM, "itemData")
			If $ICON Then
				Local $SIZE = __GUICTRLMENUEX_GETICONSIZE($ICON)
				DllStructSetData($MEASUREITEM, "itemWidth", $SIZE[0])
				DllStructSetData($MEASUREITEM, "itemHeight", $SIZE[1])
				Return True
			EndIf
		EndIf
	EndIf
	Return 0
EndFunc
Func __GUICTRLMENUEX_WM_DRAWITEM($HWND, $MSG, $WPARAM, $LPARAM)
	If $__G_GUICTRLMENUEX_USECALLBACK Then
		Local $DRAWITEM = DllStructCreate("UINT CtlType;UINT CtlID;UINT itemID;UINT itemAction;UINT itemState;HWND hwndItem;HWND hDC;INT rcItem[4];ULONG_PTR itemData", $LPARAM)
		If DllStructGetData($DRAWITEM, "CtlType") = 1 Then
			Local $ICON = DllStructGetData($DRAWITEM, "itemData")
			If $ICON Then
				Local $HDC = DllStructGetData($DRAWITEM, "hDC")
				Local $LEFT = DllStructGetData($DRAWITEM, "rcItem", 1)
				Local $TOP = DllStructGetData($DRAWITEM, "rcItem", 2)
				_WINAPI_DRAWICONEX($HDC, $LEFT / 2, $TOP, $ICON, 0, 0, 0, 0, 3)
			EndIf
			Return True
		EndIf
	EndIf
	Return 0
EndFunc
Func __GUICTRLMENUEX_GETICONSIZE($ICON)
	Local Const $TAGBITMAP = "LONG bmType;LONG bmWidth;LONG bmHeight;LONG bmWidthBytes;WORD bmPlanes;WORD bmBitsPixel;ptr bmBits"
	Local $ICONINFO = _WINAPI_GETICONINFO($ICON)
	Local $BITMAP = DllStructCreate($TAGBITMAP)
	_WINAPI_GETOBJECT($ICONINFO[5], DllStructGetSize($BITMAP), DllStructGetPtr($BITMAP))
	Local $WIDTH = DllStructGetData($BITMAP, "bmWidth")
	Local $HEIGHT = DllStructGetData($BITMAP, "bmHeight")
	_WINAPI_DELETEOBJECT($ICONINFO[4])
	_WINAPI_DELETEOBJECT($ICONINFO[5])
	Local $RET[2] = [$WIDTH, $HEIGHT]
	Return $RET
EndFunc
Func __GUICTRLMENUEX_CREATEBITMAPFROMICON($ICON)
	If __GUICTRLMENUEX_VISTAANDLATER() Then
		Return __GUICTRLMENUEX_CREATEBITMAPFROMICON_VISTA($ICON)
	Else
		Return __GUICTRLMENUEX_CREATEBITMAPFROMICON_XP($ICON)
	EndIf
EndFunc
Func __GUICTRLMENUEX_CREATEBITMAPFROMICON_XP($ICON)
	Local $SIZE = __GUICTRLMENUEX_GETICONSIZE($ICON)
	Local $DC = _WINAPI_GETDC(0)
	Local $DESTDC = _WINAPI_CREATECOMPATIBLEDC($DC)
	Local $BITMAP = _WINAPI_CREATESOLIDBITMAP(0, _WINAPI_GETSYSCOLOR($COLOR_MENU), $SIZE[0], $SIZE[1])
	Local $OLDBITMAP = _WINAPI_SELECTOBJECT($DESTDC, $BITMAP)
	If $OLDBITMAP > 0 Then
		_WINAPI_DRAWICONEX($DESTDC, 0, 0, $ICON, 0, 0, 0, 0, 3)
		_WINAPI_SELECTOBJECT($DESTDC, $OLDBITMAP)
	EndIf
	_WINAPI_RELEASEDC(0, $DC)
	_WINAPI_DELETEDC($DESTDC)
	Return $BITMAP
EndFunc
Func __GUICTRLMENUEX_CREATEBITMAPFROMICON_VISTA($ICON)
	Local $SIZE = __GUICTRLMENUEX_GETICONSIZE($ICON)
	Local $DESTDC = _WINAPI_CREATECOMPATIBLEDC(0)
	Local $BITMAP = __GUICTRLMENUEX_CREATE32BITHBITMAP($DESTDC, $SIZE)
	Local $OLDBITMAP = _WINAPI_SELECTOBJECT($DESTDC, $BITMAP)
	If $OLDBITMAP > 0 Then
		Local $BLENDFUNCTION = DllStructCreate("BYTE BlendOp; BYTE BlendFlags; BYTE SourceConstantAlpha; BYTE AlphaFormat")
		DllStructSetData($BLENDFUNCTION, 1, 0)
		DllStructSetData($BLENDFUNCTION, 2, 0)
		DllStructSetData($BLENDFUNCTION, 3, 255)
		DllStructSetData($BLENDFUNCTION, 4, 1)
		Local $PAINTPARAMS = DllStructCreate("DWORD Size; DWORD Flags; ptr Exclude; ptr BlendFunction")
		DllStructSetData($PAINTPARAMS, "Size", DllStructGetSize($PAINTPARAMS))
		DllStructSetData($PAINTPARAMS, "Flags", 1)
		DllStructSetData($PAINTPARAMS, "BlendFunction", DllStructGetPtr($BLENDFUNCTION))
		Local $RECT = DllStructCreate($TAGRECT)
		DllStructSetData($RECT, "Right", $SIZE[0])
		DllStructSetData($RECT, "Bottom", $SIZE[1])
		Local $PAINTBUFFER = __GUICTRLMENUEX_BEGINBUFFEREDPAINT($DESTDC, DllStructGetPtr($RECT), 1, DllStructGetPtr($PAINTPARAMS))
		If Not @error And $PAINTBUFFER[0] Then
			If _WINAPI_DRAWICONEX($PAINTBUFFER[1], 0, 0, $ICON, 0, 0, 0, 0, 3) Then
				__GUICTRLMENUEX_CONVERTBUFFERTOPARGB32($PAINTBUFFER[0], $DESTDC, $ICON, $SIZE)
			EndIf
			__GUICTRLMENUEX_ENDBUFFEREDPAINT($PAINTBUFFER[0], True)
		EndIf
		_WINAPI_SELECTOBJECT($DESTDC, $OLDBITMAP)
	EndIf
	_WINAPI_DELETEDC($DESTDC)
	Return $BITMAP
EndFunc
Func __GUICTRLMENUEX_CONVERTBUFFERTOPARGB32($BUFFEREDPAINT, $HDC, $ICON, $SIZE)
	Local $ROW
	Local $ARGBPTR = __GUICTRLMENUEX_GETBUFFEREDPAINTBITS($BUFFEREDPAINT, $ROW)
	If $ARGBPTR Then
		Local $ARGB = DllStructCreate("dword[" & ($SIZE[0] * $SIZE[1]) & "]", $ARGBPTR)
		If Not __GUICTRLMENUEX_HASALPHA($ARGB, $SIZE, $ROW) Then
			Local $ICONINFO = _WINAPI_GETICONINFO($ICON)
			If $ICONINFO[4] Then
				__GUICTRLMENUEX_CONVERTTOPARGB32($HDC, $ARGB, $ICONINFO[4], $SIZE, $ROW)
			EndIf
			_WINAPI_DELETEOBJECT($ICONINFO[4])
			_WINAPI_DELETEOBJECT($ICONINFO[5])
		EndIf
	EndIf
EndFunc
Func __GUICTRLMENUEX_HASALPHA($ARGB, $SIZE, $ROW)
	Local $DELTA = $ROW - $SIZE[0]
	Local $POS = 1
	For $Y = $SIZE[1] To 1 Step -1
		For $X = $SIZE[0] To 1 Step -1
			If BitAND(DllStructGetData($ARGB, 1, $POS), -16777216) Then
				Return True
			EndIf
			$POS += 1
		Next
		$POS += $DELTA
	Next
	Return False
EndFunc
Func __GUICTRLMENUEX_CONVERTTOPARGB32($HDC, ByRef $ARGB, $HBMP, $SIZE, $ROW)
	Local $BITMAPINFO = DllStructCreate($TAGBITMAPINFO)
	DllStructSetData($BITMAPINFO, "Size", DllStructGetSize($BITMAPINFO))
	DllStructSetData($BITMAPINFO, "Planes", 1)
	DllStructSetData($BITMAPINFO, "Compression", 0)
	DllStructSetData($BITMAPINFO, "Width", $SIZE[0])
	DllStructSetData($BITMAPINFO, "Height", $SIZE[1])
	DllStructSetData($BITMAPINFO, "BitCount", 32)
	Local $ARGBMASK = DllStructCreate("dword[" & ($SIZE[0] * $SIZE[1]) & "]")
	If _WINAPI_GETDIBITS($HDC, $HBMP, 0, $SIZE[1], DllStructGetPtr($ARGBMASK), DllStructGetPtr($BITMAPINFO), 0) = $SIZE[1] Then
		Local $DELTA = $ROW - $SIZE[0]
		Local $POS = 1
		For $Y = $SIZE[1] To 1 Step -1
			For $X = $SIZE[0] To 1 Step -1
				If DllStructGetData($ARGBMASK, 1, $POS) Then
					DllStructSetData($ARGB, 1, 0, $POS)
				Else
					DllStructSetData($ARGB, 1, BitOR(DllStructGetData($ARGB, 1, $POS), -16777216), $POS)
				EndIf
				$POS += 1
			Next
		Next
	EndIf
EndFunc
Func __GUICTRLMENUEX_CREATE32BITHBITMAP($HDC, $SIZE, $BITS = 0)
	Local $BITMAPINFO = DllStructCreate($TAGBITMAPINFO)
	DllStructSetData($BITMAPINFO, "Size", DllStructGetSize($BITMAPINFO))
	DllStructSetData($BITMAPINFO, "Planes", 1)
	DllStructSetData($BITMAPINFO, "Compression", 0)
	DllStructSetData($BITMAPINFO, "Width", $SIZE[0])
	DllStructSetData($BITMAPINFO, "Height", $SIZE[1])
	DllStructSetData($BITMAPINFO, "BitCount", 32)
	Return __GUICTRLMENUEX_CREATEDIBSECTION($HDC, DllStructGetPtr($BITMAPINFO), 0, $BITS, 0, 0)
EndFunc
Func __GUICTRLMENUEX_CREATEDIBSECTION($HDC, $BMI, $USAGE, $BITS, $SECTION, $OFFSET)
	Local $RET = DllCall("gdi32.dll", "hwnd", "CreateDIBSection", "hwnd", $HDC, "ptr", $BMI, "uint", $USAGE, "ptr*", $BITS, "hwnd", $SECTION, "dword", $OFFSET)
	If Not @error Then
		Return $RET[0]
	EndIf
	Return SetError(1, 0, 0)
EndFunc
Func __GUICTRLMENUEX_BEGINBUFFEREDPAINT($DCTARGET, $RECTTARGET, $FORMAT, $PAINTPARAMS)
	Local $RET = DllCall("UxTheme.dll", "hwnd", "BeginBufferedPaint", "hwnd", $DCTARGET, "ptr", $RECTTARGET, "dword", $FORMAT, "ptr", $PAINTPARAMS, "hwnd*", 0)
	If Not @error Then
		Local $ARRAY[2] = [$RET[0], $RET[5]]
		Return $ARRAY
	EndIf
	Return SetError(1, 0, 0)
EndFunc
Func __GUICTRLMENUEX_ENDBUFFEREDPAINT($BUFFEREDPAINT, $UPDATETARGET = True)
	Local $RET = DllCall("UxTheme.dll", "hwnd", "EndBufferedPaint", "hwnd", $BUFFEREDPAINT, "int", $UPDATETARGET)
	If Not @error Then
		Return $RET[0]
	EndIf
	Return SetError(1, 0, 0)
EndFunc
Func __GUICTRLMENUEX_GETBUFFEREDPAINTBITS($BUFFEREDPAINT, ByRef $ROW)
	Local $RET = DllCall("UxTheme.dll", "int", "GetBufferedPaintBits", "hwnd", $BUFFEREDPAINT, "ptr*", 0, "int*", 0)
	If Not @error Then
		$ROW = $RET[3]
		Return $RET[2]
	EndIf
	Return SetError(1, 0, 0)
EndFunc
Func __GUICTRLMENUEX_VISTAANDLATER()
	Local $OSVI = DllStructCreate("DWORD OSVersionInfoSize; DWORD MajorVersion; DWORD MinorVersion; DWORD BuildNumber; DWORD PlatformId; wchar CSDVersion[128]")
	DllStructSetData($OSVI, "OSVersionInfoSize", DllStructGetSize($OSVI))
	DllCall("kernel32.dll", "bool", "GetVersionExW", "ptr", DllStructGetPtr($OSVI))
	Return DllStructGetData($OSVI, "MajorVersion") >= 6
EndFunc
Global Const $PE_CONSOLE = @ScriptDir & "\Console\Console.exe"
Global Const $PE_COMMAND = @ScriptDir & "\Console\Command.exe"
Global Const $INI_COMMAND = @ScriptDir & "\Console\Command.ini"
Func _LAUNCHREVOUNINSTALLER()
	_LANCHDOORSHIVEMODULE("revouninstaller\Revouninstaller.exe", "revouninstaller", "Revo Uninstaller", $SET_DEFMODE)
EndFunc
Func _LAUNCHDEFRAGMENTATION()
	Local $AUSDEFREXE = $DIR_MODULES & "\ausdiskdefrag\DiskDefrag.exe"
	If FileExists($AUSDEFREXE) Or FileExists($DIR_MODULES & "\ausdiskdefrag.7z") Then
		_LANCHDOORSHIVEMODULE("ausdiskdefrag\DiskDefrag.exe", "ausdiskdefrag", "Auslogics Disk Defrag", $SET_DEFMODE)
	Else
		Switch @OSVersion
			Case "WIN_XP", "WIN_XPe", "WIN_2003"
				_LAUNCHFIXEDLOCATION(@SystemDir & "\dfrg.msc", "Windows 2000 Defrag")
			Case "WIN_VISTA", "WIN_7", "WIN_2008", "WIN_2008R2", "WIN_8"
				_LAUNCHFIXEDLOCATION(@SystemDir & "\dfrgui.exe", "Windows Defrag")
		EndSwitch
	EndIf
EndFunc
Func _LAUNCHOWNERSHIP()
	_LAUNCHFIXEDLOCATION($DIR_DOORS & "\Ownership.exe", "Rizonesoft Ownership")
EndFunc
Func _LAUNCHINDICATORS()
	_LAUNCHFIXEDLOCATION($DIR_DOORS & "\Indicators.exe", "Rizonesoft Notebook Indicators")
EndFunc
Func _LAUNCHCOMMANDPROMPT()
	_INITIALIZELOGGING()
	_MEMOLOGGINGWRITE("Launching the Doors Command Prompt, please wait...")
	If IniRead($INI_COMMAND, "Command", "RepairCommandOnStart", 1) = 1 Then
		_MEMOLOGGINGWRITE("Automatic Command Prompt repair enabled (Command.ini)")
	EndIf
	If IniRead($INI_COMMAND, "Command", "SetCommandEnhancements", 1) = 1 Then
		_MEMOLOGGINGWRITE("Command Prompt Enhancements enabled (Command.ini)")
		If IniRead($INI_COMMAND, "Command", "RemoveEnancementsOnClose", 0) = 1 Then
			_MEMOLOGGINGWRITE("Command Prompt Enhancements will be removed when you close the Command Prompt (Command.ini)")
		EndIf
	EndIf
	ShellExecute($PE_COMMAND)
EndFunc
Func _STARTCOMMANDPROMPTREPAIR()
	If _REPAIRCOMMANDPROMPT() > 0 Then
		_MEMOLOGGINGWRITE("The Command Prompt should work now", 1)
	Else
		_MEMOLOGGINGWRITE("Nothing seems to be broken here.", 1)
	EndIf
EndFunc
Func _REPAIRCOMMANDPROMPT()
	Local $ERRORCOUNT = 0
	_INITIALIZELOGGING()
	_MEMOLOGGINGWRITE("Searching for Command Prompt errors, please wait...")
	If RegRead("HKEY_CURRENT_USER\Software\Policies\Microsoft\Windows\System", "DisableCMD") <> 0 Or RegRead("HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows\System", "DisableCMD") <> 0 Then
		$ERRORCOUNT = +1
		_MEMOLOGGINGWRITE("The command prompt has been disabled by your administrator.", 2)
		_MEMOLOGGINGWRITE("Restoring access to the Command Prompt, please wait...")
		RegDelete("HKEY_CURRENT_USER\Software\Policies\Microsoft\Windows\System", "DisableCMD")
		RegDelete("HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows\System", "DisableCMD")
	EndIf
	If EnvGet("ComSpec") = "" Then
		_MEMOLOGGINGWRITE("The ComSpec environment variable is missing.", 2)
		_MEMOLOGGINGWRITE("Restoring the ComSpec environment variable to [%SystemRoot%\system32\cmd.exe], please wait...")
		EnvSet("ComSpec", "%SystemRoot%\system32\cmd.exe")
		$ERRORCOUNT = +1
	EndIf
	Return $ERRORCOUNT
EndFunc
Func _LAUNCHCONSOLE()
	_LAUNCHFIXEDLOCATION($PE_CONSOLE, "Console")
EndFunc
Func _LAUNCHDOORSUPDATE()
	_LAUNCHFIXEDLOCATION(@ScriptDir & "\wyUpdate.exe", "Doors Update")
EndFunc
Func _LAUNCHPOWERENC()
	_LANCHDOORSHIVEMODULE("powerenc\powerenc.exe", "powerenc", "Benware PowerEnc", $SET_DEFMODE)
EndFunc
Func _REPAIRFONTREGISTRATIONS()
	_INITIALIZELOGGING()
	_MEMOLOGGINGWRITE("Removing stale font registrations and repairing missing font registration, please wait...")
	If @OSARCH = "X64" Then
		ShellExecute($DIR_CONSOLE & "\64Bit\FontReg.exe")
	Else
		ShellExecute($DIR_CONSOLE & "\FontReg.exe")
	EndIf
	_MEMOLOGGINGWRITE("Font registrations repaired, I hope.", 1)
EndFunc
Func _LAUNCHCLAMWINANTIVIRUS()
	_LANCHDOORSHIVEMODULE("clamwin\bin\ClamWin.exe", "clamwin", "ClamWin Antivirus", $SET_DEFMODE)
EndFunc
If _SINGLETON(@ScriptName, 1) = 0 Then
	MsgBox(262192, "Warning", "An occurence of Doors is already running.", 30)
	Exit
EndIf
Global Const $EXITPROCESS = False
Global Const $DOORSVERSION = FileGetVersion(@ScriptFullPath)
Global Const $DOORSRES = @ScriptDir & "\Structure\Shell20.exe"
Global $DOORSFORM, $MAINMENU, $GOMENU, $GOCOMPSUB, $GOPROGSUB, $PROGMULITSUB, $GOCSFSUB, $DOORSMENU, $DLOGSUB
Global $ACCMENU, $ACCMAINTSUB, $ACCOPTISUB, $OPTIMEMSUB, $ACCENHSUB, $ENHSHELLSUB, $ACCCOMPSUB
Global $ADMINMENU, $REPAIRMENU, $REPWINSUB, $SECURMENU, $SECVCLSUB, $SYSMENU
Global $IAHGAP = 350, $IAVGAP = 55, $IACOUNT = 13, $IASIZE = 48, $IAGAP = 5, $ALPICON[$IACOUNT + 1]
Global $IBHGAP = 350, $IBVGAP = 180, $IBCOUNT = 13, $IBSIZE = 48, $IBGAP = 5, $BLPICON[$IBCOUNT + 1]
Global $ESTATUS, $IMENU_SECTION, $IMORE_SECTION
Global $HMEMICO, $HCPUICO, $ICOKSTATE, $KSDIFF = 0, $DOORSTIME, $TM1FREE, $TM2FREE, $MEMUSAGEBAR, $PAGEUSBAR, $LBLMEMUSAGE, $LBLPAGEUS
Global $GUIUPDATE = True, $DOORSICON
Global $CCOM1, $CCOM2, $CCOM3, $CCOM4, $CCOM5, $CCOM6, $CCOM7, $CCOM8, $CCOM9
_LOADERSTART()
_INITIALIZELOGFILE(5)
_LOGGINGWRITE("", False)
_LOGGINGWRITE("", False)
_LOGGINGWRITE("                                            ./", False)
_LOGGINGWRITE("                                          (o o)", False)
_LOGGINGWRITE("--------------------------------------oOOo-(_)-oOOo--------------------------------------", False)
_LOADERUPDATE(1)
_LOADERUPDATE(2)
_CHECKINTEGRITY()
_LOADERUPDATE(3)
Func _LOADAPPSETTINGS()
	$CCOM1 = IniRead($SETTINGS_DOORS, "QuickLaunch", "1", "")
EndFunc
_LOADERUPDATE(4)
_LOADERUPDATE(5)
_LOADERUPDATE(6)
_LOADERUPDATE(7)
_LOADERUPDATE(8)
_LOADERUPDATE(9)
_MAINGUI()
Func _MAINGUI()
	GUIRegisterMsg($WM_COMMAND, "WM_COMMAND")
	$DOORSFORM = GUICreate("Rizonesoft Doors " & _GETDOORSVERSION(1) & " : Build " & _GETDOORSVERSION(4), 750, 550, -1, -1, -1, -1)
	GUISetFont(8.5, 400, 0, "Verdana")
	GUISetBkColor(15461355)
	_GUICTRLMENUEX_STARTUP(Default)
	$MAINMENU = _GUICTRLMENU_CREATEMENU()
	Local $WINORBICO = _WINAPI_SHELLEXTRACTICON(@ScriptFullPath, -201 - Random(0, 9, 1), 32, 32)
	Local $GOICON[3], $SHELL20[50]
	For $EX = 0 To UBound($SHELL20) - 1
		$SHELL20[$EX] = _WINAPI_SHELLEXTRACTICON($DOORSRES, -211 - $EX, 16, 16)
	Next
	_LOADERUPDATE(10)
	$GOICON[0] = _WINAPI_SHELLEXTRACTICON($DOORSRES, -211, 24, 24)
	$GOICON[1] = _WINAPI_SHELLEXTRACTICON($DOORSRES, -212, 24, 24)
	$GOICON[2] = _WINAPI_SHELLEXTRACTICON($DOORSRES, -213, 24, 24)
	$GOMENU = _GUICTRLMENU_CREATEMENU()
	_GUICTRLMENU_SETMENUSTYLE($GOMENU, 67108864)
	_GUICTRLMENU_ADDMENUITEM($MAINMENU, "&Go", 1, $GOMENU)
	_LOADERUPDATE(11)
	$GOCOMPSUB = _GUICTRLMENU_CREATEPOPUP()
	_GUICTRLMENU_SETMENUSTYLE($GOCOMPSUB, 67108864)
	_GUICTRLMENU_ADDMENUITEM($GOMENU, "&Computer", 1, $GOCOMPSUB)
	_GUICTRLMENUEX_ADDMENUITEM($GOCOMPSUB, "&Computer", 1101, $SHELL20[0])
	_GUICTRLMENUEX_ADDMENUBAR($GOCOMPSUB)
	_GUICTRLMENUEX_ADDMENUITEM($GOCOMPSUB, "&Home Drive (" & @HomeDrive & ")", 1102, $SHELL20[3])
	_GUICTRLMENUEX_SETITEMICON($GOMENU, 0, $GOICON[0])
	_GUICTRLMENUEX_ADDMENUITEM($GOMENU, "&Documents", 1108, $GOICON[1])
	_LOADERUPDATE(12)
	$GOPROGSUB = _GUICTRLMENU_CREATEPOPUP()
	_GUICTRLMENU_SETMENUSTYLE($GOPROGSUB, 67108864)
	_GUICTRLMENU_ADDMENUITEM($GOMENU, "&Programs", 2, $GOPROGSUB)
	_GUICTRLMENUEX_SETITEMICON($GOMENU, 2, $GOICON[2])
	$PROGMULITSUB = _GUICTRLMENU_CREATEPOPUP()
	_GUICTRLMENU_SETMENUSTYLE($PROGMULITSUB, 67108864)
	_GUICTRLMENU_ADDMENUITEM($GOPROGSUB, "&Multimedia", 0, $PROGMULITSUB)
	_GUICTRLMENUEX_SETITEMICON($GOPROGSUB, 0, $SHELL20[4])
	_GUICTRLMENUEX_ADDMENUITEM($PROGMULITSUB, "&Rip and convert audio", 1103, $SHELL20[5])
	_LOADERUPDATE(13)
	$DOORSMENU = _GUICTRLMENU_CREATEPOPUP()
	_GUICTRLMENU_SETMENUSTYLE($DOORSMENU, 67108864)
	_GUICTRLMENU_ADDMENUITEM($MAINMENU, "&Doors", 2, $DOORSMENU)
	$DLOGSUB = _GUICTRLMENU_CREATEPOPUP()
	_GUICTRLMENU_SETMENUSTYLE($DLOGSUB, 67108864)
	_GUICTRLMENU_ADDMENUITEM($DOORSMENU, "&Doors Logging", 0, $DLOGSUB)
	_GUICTRLMENUEX_ADDMENUITEM($DLOGSUB, "Open logging &folder", 1204, $SHELL20[1])
	_GUICTRLMENUEX_ADDMENUITEM($DLOGSUB, "Open &logging file", 1205, $SHELL20[25])
	_GUICTRLMENUEX_ADDMENUITEM($DOORSMENU, "&Doors Update", 1201, $SHELL20[6])
	_GUICTRLMENUEX_ADDMENUBAR($DOORSMENU)
	_GUICTRLMENUEX_ADDMENUITEM($DOORSMENU, "&Minimize", 1202, $SHELL20[7])
	_GUICTRLMENUEX_ADDMENUITEM($DOORSMENU, "&Shutdown Doors", 1203, $SHELL20[8])
	_LOADERUPDATE(14)
	HotKeySet("^!c", "_LAUNCHCONSOLE")
	$ACCMENU = _GUICTRLMENU_CREATEMENU()
	_GUICTRLMENU_SETMENUSTYLE($ACCMENU, 67108864)
	_GUICTRLMENU_ADDMENUITEM($MAINMENU, "Acc&essories", 3, $ACCMENU)
	_LOADERUPDATE(15)
	$ACCMAINTSUB = _GUICTRLMENU_CREATEPOPUP()
	_GUICTRLMENU_SETMENUSTYLE($ACCMAINTSUB, 67108864)
	_GUICTRLMENU_ADDMENUITEM($ACCMENU, "&Maintenance", 1, $ACCMAINTSUB)
	_GUICTRLMENUEX_ADDMENUITEM($ACCMAINTSUB, "&Uninstall programs", 1306, $SHELL20[14])
	_GUICTRLMENUEX_SETITEMICON($ACCMENU, 0, $SHELL20[9])
	_LOADERUPDATE(16)
	$ACCOPTISUB = _GUICTRLMENU_CREATEPOPUP()
	_GUICTRLMENU_SETMENUSTYLE($ACCOPTISUB, 67108864)
	_GUICTRLMENU_ADDMENUITEM($ACCMENU, "&Optimization", 2, $ACCOPTISUB)
	$OPTIMEMSUB = _GUICTRLMENU_CREATEPOPUP()
	_GUICTRLMENU_SETMENUSTYLE($OPTIMEMSUB, 67108864)
	_GUICTRLMENU_ADDMENUITEM($ACCOPTISUB, "&Memory Management", 1, $OPTIMEMSUB)
	_GUICTRLMENUEX_ADDMENUITEM($ACCOPTISUB, "&Disk Defragmenter", 1304, $SHELL20[15])
	_GUICTRLMENUEX_SETITEMICON($ACCOPTISUB, 0, $SHELL20[24])
	_GUICTRLMENUEX_ADDMENUITEM($OPTIMEMSUB, "&Force mem into PageFile (Experimental)", 1308, $SHELL20[24])
	_GUICTRLMENUEX_SETITEMICON($ACCMENU, 1, $SHELL20[10])
	_LOADERUPDATE(17)
	$ACCENHSUB = _GUICTRLMENU_CREATEPOPUP()
	_GUICTRLMENU_SETMENUSTYLE($ACCENHSUB, 67108864)
	_GUICTRLMENU_ADDMENUITEM($ACCMENU, "&Enhancements", 3, $ACCENHSUB)
	$ENHSHELLSUB = _GUICTRLMENU_CREATEPOPUP()
	_GUICTRLMENU_SETMENUSTYLE($ENHSHELLSUB, 67108864)
	_GUICTRLMENU_ADDMENUITEM($ACCENHSUB, "&Shell Extensions", 1, $ENHSHELLSUB)
	_GUICTRLMENUEX_ADDMENUITEM($ENHSHELLSUB, "&Ownership", 1305, $SHELL20[18])
	_GUICTRLMENUEX_SETITEMICON($ACCENHSUB, 0, $SHELL20[17])
	_GUICTRLMENUEX_SETITEMICON($ACCMENU, 2, $SHELL20[11])
	_GUICTRLMENUEX_ADDMENUBAR($ACCMENU)
	_GUICTRLMENUEX_ADDMENUITEM($ACCMENU, "Notebook &Indicators", 1307, $SHELL20[19])
	_GUICTRLMENUEX_ADDMENUBAR($ACCMENU)
	_LOADERUPDATE(18)
	$ACCCOMPSUB = _GUICTRLMENU_CREATEPOPUP()
	_GUICTRLMENU_SETMENUSTYLE($ACCCOMPSUB, 67108864)
	_GUICTRLMENU_ADDMENUITEM($ACCMENU, "Command &Prompt", 4, $ACCCOMPSUB)
	_GUICTRLMENUEX_ADDMENUITEM($ACCCOMPSUB, "Command &Prompt", 1301, $SHELL20[12])
	_GUICTRLMENUEX_ADDMENUITEM($ACCCOMPSUB, "Command &Prompt repair", 1302, $SHELL20[13])
	_GUICTRLMENUEX_SETITEMICON($ACCMENU, 6, $SHELL20[12])
	_GUICTRLMENUEX_ADDMENUITEM($ACCMENU, "&Console " & @TAB & "Ctrl+Alt+S", 1303, $SHELL20[16])
	_LOADERUPDATE(19)
	$ADMINMENU = _GUICTRLMENU_CREATEPOPUP()
	_GUICTRLMENU_SETMENUSTYLE($ADMINMENU, 67108864)
	_GUICTRLMENU_ADDMENUITEM($MAINMENU, "&Administration", 4, $ADMINMENU)
	_LOADERUPDATE(20)
	$REPAIRMENU = _GUICTRLMENU_CREATEPOPUP()
	_GUICTRLMENU_SETMENUSTYLE($REPAIRMENU, 67108864)
	_GUICTRLMENU_ADDMENUITEM($MAINMENU, "&Repair", 4, $REPAIRMENU)
	$REPWINSUB = _GUICTRLMENU_CREATEPOPUP()
	_GUICTRLMENU_SETMENUSTYLE($REPWINSUB, 67108864)
	_GUICTRLMENU_ADDMENUITEM($REPAIRMENU, "&Windows", 1, $REPWINSUB)
	_GUICTRLMENUEX_ADDMENUITEM($REPWINSUB, "Repair &font registrations", 1501, $SHELL20[21])
	_GUICTRLMENUEX_SETITEMICON($REPAIRMENU, 0, $SHELL20[20])
	_LOADERUPDATE(21)
	$SECURMENU = _GUICTRLMENU_CREATEPOPUP()
	_GUICTRLMENU_SETMENUSTYLE($SECURMENU, 67108864)
	_GUICTRLMENU_ADDMENUITEM($MAINMENU, "&Confidence", 5, $SECURMENU)
	$SECVCLSUB = _GUICTRLMENU_CREATEPOPUP()
	_GUICTRLMENU_SETMENUSTYLE($SECVCLSUB, 67108864)
	_GUICTRLMENU_ADDMENUITEM($SECURMENU, "&Virus Cleaners", 1, $SECVCLSUB)
	_GUICTRLMENUEX_ADDMENUITEM($SECVCLSUB, "ClamWin Antivirus Scanner", 1601, $SHELL20[23])
	_GUICTRLMENUEX_SETITEMICON($SECURMENU, 0, $SHELL20[22])
	_LOADERUPDATE(22)
	$SYSMENU = _GUICTRLMENU_CREATEPOPUP()
	_GUICTRLMENU_SETMENUSTYLE($SYSMENU, 67108864)
	_GUICTRLMENU_ADDMENUITEM($MAINMENU, "&System", 6, $SYSMENU)
	_GUICTRLMENUEX_ADDMENUITEM($SYSMENU, "Windows &version", 1701, $SHELL20[20])
	_LOADERUPDATE(23)
	_GUICTRLMENUEX_SETITEMICON($MAINMENU, 0, $WINORBICO)
	_LOADERUPDATE(24)
	_GUICTRLMENU_SETMENU($DOORSFORM, $MAINMENU)
	_GUIEXTENDER_INIT($DOORSFORM, 0, 0)
	_GUIEXTENDER_SECTION_START(0, 0)
	If @OSVersion = "WIN_2003" Then
		$HMEMICO = GUICtrlCreateIcon("", 0, 10, 5, 16, 16)
		$HCPUICO = GUICtrlCreateIcon("", 0, 195, 5, 16, 16)
	Else
		$HMEMICO = GUICtrlCreateIcon($DOORSRES, 209, 10, 5, 16, 16)
		$HCPUICO = GUICtrlCreateIcon($DOORSRES, 210, 195, 5, 16, 16)
	EndIf
	GUICtrlCreateLabel("", 35, 5, 100, 8)
	GUICtrlSetBkColor(-1, 463648)
	$MEMUSAGEBAR = GUICtrlCreateLabel("", 36, 6, 10, 6)
	GUICtrlSetBkColor($MEMUSAGEBAR, 6868730)
	$LBLMEMUSAGE = GUICtrlCreateLabel("100%", 140, 3, 50, 11)
	GUICtrlSetFont($LBLMEMUSAGE, 7, 400, -1, "Tahoma", 5)
	GUICtrlCreateLabel("", 35, 15, 100, 8)
	GUICtrlSetBkColor(-1, 463648)
	$PAGEUSBAR = GUICtrlCreateLabel("", 36, 16, 50, 6)
	GUICtrlSetBkColor($PAGEUSBAR, 16431616)
	$LBLPAGEUS = GUICtrlCreateLabel("100%", 140, 14, 50, 11)
	GUICtrlSetFont($LBLPAGEUS, 7, 400, -1, "Tahoma", 5)
	GUICtrlCreateLabel("", 215, 6, 100, 12)
	GUICtrlSetBkColor(-1, 463648)
	GUICtrlCreateLabel("", 216, 7, 50, 10)
	GUICtrlSetBkColor(-1, 8178812)
	_LOADERUPDATE(25)
	GUICtrlCreateLabel("", -50, 29, 800, 1)
	GUICtrlSetBkColor(-1, 14277081)
	GUICtrlCreateLabel("", -50, 30, 800, 20)
	GUICtrlSetBkColor(-1, 15066597)
	GUICtrlCreateLabel("", -50, 50, 800, 1)
	GUICtrlSetBkColor(-1, 15790320)
	GUICtrlCreateLabel("", -50, 52, 800, 1)
	GUICtrlSetBkColor(-1, 14277081)
	$ICOKSTATE = GUICtrlCreateIcon($DOORSRES, 201, 5, 32, 16, 16)
	$DOORSTIME = GUICtrlCreateLabel("00:00:00", 680, 33, 300, 20)
	GUICtrlSetColor($DOORSTIME, 463648)
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
	GUICtrlSetFont(-1, 7.5, 400, -1, "Verdana")
	_LOADERUPDATE(26)
	_GUIEXTENDER_SECTION_ACTION(2, "", "", 710, 3, 23, 23, 0, 1)
	_GUIEXTENDER_SECTION_END()
	$DOORSICON = GUICtrlCreateIcon(@ScriptFullPath, 99, 20, 60, 64, 64, $SS_NOTIFY)
	GUICtrlSetCursor($DOORSICON, 0)
	_LOADERUPDATE(27)
	Local $QUIB1, $QUIB2, $QUIB3, $QUIB4, $QUIB5, $QUIB6, $QUIB7, $QUIB8, $QUIB9, $QUIE
	$QUIB1 = GUICtrlCreateButton("1", 15, 130, 25, 23)
	If $CCOM1 = "" Then GUICtrlSetState($QUIB1, $GUI_DISABLE)
	$QUIB2 = GUICtrlCreateButton("2", 40, 130, 25, 23)
	$QUIB3 = GUICtrlCreateButton("3", 65, 130, 25, 23)
	$QUIB4 = GUICtrlCreateButton("4", 15, 153, 25, 23)
	$QUIB5 = GUICtrlCreateButton("5", 40, 153, 25, 23)
	$QUIB6 = GUICtrlCreateButton("6", 65, 153, 25, 23)
	$QUIB7 = GUICtrlCreateButton("7", 15, 176, 25, 23)
	$QUIB8 = GUICtrlCreateButton("8", 40, 176, 25, 23)
	$QUIB9 = GUICtrlCreateButton("9", 65, 176, 25, 23)
	$QUIE = GUICtrlCreateButton("...", 15, 199, 75, 23)
	_LOADERUPDATE(28)
	_WINAPI_DESTROYICON($WINORBICO)
	For $X = 0 To UBound($GOICON) - 1
		_WINAPI_DESTROYICON($GOICON[$X])
	Next
	For $C = 0 To UBound($SHELL20) - 1
		_WINAPI_DESTROYICON($SHELL20[$C])
	Next
	_LOADERUPDATE(29)
	$IMORE_SECTION = _GUIEXTENDER_SECTION_START(0, 465)
	_LOADERUPDATE(96)
	GUICtrlCreateGroup("", $IAHGAP, $IAVGAP, Round($IACOUNT / 2) * $IASIZE + (2 + (Round($IACOUNT / 2) + 1) * $IAGAP), 2 * $IASIZE + 3 * $IAGAP + 10)
	For $A = 0 To $IACOUNT
		If $A < $IACOUNT / 2 Then
			$ALPICON[$A] = GUICtrlCreateIcon("", 0, $IAHGAP + $IAGAP + ($A * $IASIZE) + ($A * $IAGAP) + 1, $IAVGAP + 2 * $IAGAP + 2, $IASIZE, $IASIZE, $SS_NOTIFY)
		Else
			Local $B = $A - Round($IACOUNT / 2)
			$ALPICON[$A] = GUICtrlCreateIcon("", 0, $IAHGAP + $IAGAP + ($B * $IASIZE) + ($B * $IAGAP) + 1, $IAVGAP + 3 * $IAGAP + $IASIZE + 2, $IASIZE, $IASIZE, $SS_NOTIFY)
		EndIf
		GUICtrlSetCursor($ALPICON[$A], 0)
		GUICtrlSetResizing($ALPICON[$A], $GUI_DOCKALL)
	Next
	_LOADERUPDATE(97)
	GUICtrlSetOnEvent($ALPICON[7], "_LaunchRevoUninstaller")
	GUICtrlSetOnEvent($ALPICON[8], "_LaunchDefragmentation")
	GUICtrlSetOnEvent($ALPICON[13], "_LaunchConsole")
	GUICtrlCreateGroup("", $IBHGAP, $IBVGAP, Ceiling($IBCOUNT / 2) * $IBSIZE + (2 + (Ceiling($IBCOUNT / 2) + 1) * $IBGAP), 2 * $IBSIZE + 3 * $IBGAP + 10)
	For $I = 0 To $IBCOUNT
		If $I < $IBCOUNT / 2 Then
			$BLPICON[$I] = GUICtrlCreateIcon("", 0, $IBHGAP + $IBGAP + ($I * $IBSIZE) + ($I * $IBGAP) + 1, $IBVGAP + 2 * $IBGAP + 2, $IBSIZE, $IBSIZE, $SS_NOTIFY)
		Else
			Local $J = $I - Ceiling($IBCOUNT / 2)
			$BLPICON[$I] = GUICtrlCreateIcon("", 0, $IBHGAP + $IBGAP + ($J * $IBSIZE) + ($J * $IBGAP) + 1, $IBVGAP + 3 * $IBGAP + $IBSIZE + 2, $IBSIZE, $IBSIZE, $SS_NOTIFY)
		EndIf
		GUICtrlSetCursor($BLPICON[$I], 0)
	Next
	$ESTATUS = GUICtrlCreateEdit("", 10, 344, 525, 105, BitOR($WS_VSCROLL, $ES_READONLY, $ES_AUTOVSCROLL, $WS_HSCROLL))
	GUICtrlSetBkColor($ESTATUS, 16777215)
	Local $RECICON, $LBINSIZE, $LBINITEMS, $BTNBINEM, $BTNDCLEAN
	Local $RECBINCON, $RBCONOPEN, $RBCONEXPLORE, $RBCONEMP, $RBCONPROP
	GUICtrlCreateGroup("", 578, 305, 150, 150)
	$RECICON = GUICtrlCreateIcon(@ScriptFullPath, 212, 668, 285, 48, 48, BitOR($SS_NOTIFY, $WS_GROUP))
	GUICtrlSetTip($RECICON, "Open the Recycle Bin. Right-Click" & @CRLF & "for more options.", "Recycle Bin", 1, 1)
	GUICtrlSetCursor($RECICON, 0)
	$LBINSIZE = GUICtrlCreateLabel("0 MB", 590, 290, 80, 17)
	GUICtrlSetFont(-1, 8.5, 800, 0, "Verdana")
	$LBINITEMS = GUICtrlCreateLabel("0 Objects", 590, 310, 80, 17)
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	$RECBINCON = GUICtrlCreateContextMenu($RECICON)
	$RBCONOPEN = GUICtrlCreateMenuItem("Open", $RECBINCON)
	$RBCONEXPLORE = GUICtrlCreateMenuItem("Explore", $RECBINCON)
	GUICtrlSetState($RBCONOPEN, $GUI_DEFBUTTON)
	$RBCONEMP = GUICtrlCreateMenuItem("Empty Recycle Bin", $RECBINCON)
	GUICtrlCreateMenuItem("", $RECBINCON)
	$RBCONPROP = GUICtrlCreateMenuItem("Properties...", $RECBINCON)
	_GUIEXTENDER_SECTION_END()
	GUISetOnEvent($GUI_EVENT_CLOSE, "_CLoseDoors")
	GUISetOnEvent($GUI_EVENT_RESTORE, "_GuiUpdate")
	GUISetState(@SW_SHOW, $DOORSFORM)
	_LOADERUPDATE(98)
	_REDUCEMEM()
	_LOADERUPDATE(99)
	ADLIBREGISTER("_ReduceMem", 5000)
	ADLIBREGISTER("_GatherDisplayStats", 1000)
	ADLIBREGISTER("_toggleKeysState", 200)
	_GATHERDISPLAYSTATS()
	_LOADERUPDATE(100)
	While 1
		_CHECKDOCK()
		If $GUIUPDATE = True Then
			_GUIUPDATE()
		EndIf
		Sleep(50)
		_WINAPI_EMPTYWORKINGSET()
	WEnd
EndFunc
Func WM_COMMAND($HWND, $MSG, $WPARAM, $LPARAM)
	Local $CODE = _WINAPI_HIWORD($WPARAM)
	If $CODE = 0 Then _RUNMENUCOMMAND(_WINAPI_LOWORD($WPARAM))
EndFunc
Func _CHECKDOCK()
EndFunc
Func _REDUCEMEM()
	Local $APROCSLIST, $APINILIST
	$APINILIST = StringSplit("cmd.exe|Command.exe|Console.exe|DiskDefrag.exe|firefox.exe|plugin-container.exe|Revouninstaller.exe", "|")
	$APROCSLIST = ProcessList()
	For $I = 1 To $APROCSLIST[0][0]
		For $X = 1 To $APINILIST[0]
			If $APROCSLIST[$I][0] = $APINILIST[$X] Then
				_WINAPI_EMPTYWORKINGSET($APROCSLIST[$I][1])
			EndIf
		Next
	Next
EndFunc
Func _CLOSEDOORS()
	GUISetState(@SW_HIDE, $DOORSFORM)
	_GUICTRLMENUEX_DESTROYMENU($MAINMENU)
	_GUICTRLMENUEX_DESTROYMENU($GOMENU)
	_GUICTRLMENUEX_DESTROYMENU($GOCOMPSUB)
	_GUICTRLMENUEX_DESTROYMENU($GOPROGSUB)
	_GUICTRLMENUEX_DESTROYMENU($PROGMULITSUB)
	_GUICTRLMENUEX_DESTROYMENU($GOCSFSUB)
	_GUICTRLMENUEX_DESTROYMENU($DOORSMENU)
	_GUICTRLMENUEX_DESTROYMENU($DLOGSUB)
	_GUICTRLMENUEX_DESTROYMENU($ACCMENU)
	_GUICTRLMENUEX_DESTROYMENU($ACCMAINTSUB)
	_GUICTRLMENUEX_DESTROYMENU($ACCOPTISUB)
	_GUICTRLMENUEX_DESTROYMENU($OPTIMEMSUB)
	_GUICTRLMENUEX_DESTROYMENU($ACCENHSUB)
	_GUICTRLMENUEX_DESTROYMENU($ENHSHELLSUB)
	_GUICTRLMENUEX_DESTROYMENU($ACCCOMPSUB)
	_GUICTRLMENUEX_DESTROYMENU($ADMINMENU)
	_GUICTRLMENUEX_DESTROYMENU($REPAIRMENU)
	_GUICTRLMENUEX_DESTROYMENU($REPWINSUB)
	_GUICTRLMENUEX_DESTROYMENU($SECURMENU)
	_GUICTRLMENUEX_DESTROYMENU($SECVCLSUB)
	_GUICTRLMENUEX_DESTROYMENU($SYSMENU)
	GUIDelete($DOORSFORM)
	If $EXITPROCESS = True Then
		Local $PROCESSID = ProcessExists(@ScriptName)
		If $PROCESSID Then ProcessClose($PROCESSID)
	EndIf
	Exit
EndFunc
Func _GUIUPDATE()
	Local $HPICON[3]
	Local $MEMICO, $CPUICO
	$HPICON[0] = _WINAPI_SHELLEXTRACTICON($DOORSRES, -225, 48, 48)
	$HPICON[1] = _WINAPI_SHELLEXTRACTICON($DOORSRES, -226, 48, 48)
	$HPICON[2] = _WINAPI_SHELLEXTRACTICON($DOORSRES, -227, 48, 48)
	$MEMICO = _WINAPI_SHELLEXTRACTICON($DOORSRES, -209, 16, 16)
	$CPUICO = _WINAPI_SHELLEXTRACTICON($DOORSRES, -210, 16, 16)
	_SETHICON($ALPICON[7], $HPICON[0], -1)
	GUICtrlSetTip($ALPICON[7], "Uninstall software and remove unwanted programs installed on your computer", "Revo Uninstaller", 1, 2)
	_SETHICON($ALPICON[8], $HPICON[1], -1)
	GUICtrlSetTip($ALPICON[8], "Defragments your disks so that your computer runs faster and more efficiently.", "Disk Defragmenter", 1, 2)
	_SETHICON($ALPICON[13], $HPICON[2], -1)
	GUICtrlSetTip($ALPICON[13], "Performs text-based (command-line) functions.", "Console " & FileGetVersion($PE_CONSOLE), 1, 2)
	For $J = 0 To UBound($HPICON) - 1
		_WINAPI_DESTROYICON($HPICON[$J])
	Next
	If @OSVersion = "WIN_2003" Then
		_SETHICON($HMEMICO, $MEMICO, -1)
		_SETHICON($HCPUICO, $CPUICO, -1)
		_WINAPI_DESTROYICON($MEMICO)
		_WINAPI_DESTROYICON($CPUICO)
	EndIf
	$GUIUPDATE = False
EndFunc
Func _RUNMENUCOMMAND($MNUID)
	_STARTPROCESSING()
	Switch $MNUID
		Case 1101
			ShellExecute("explorer", "/e,::{20D04FE0-3AEA-1069-A2D8-08002B30309D}")
		Case 1102
			ShellExecute("explorer", "/e," & @HomeDrive)
		Case 1103
			_LAUNCHPOWERENC()
		Case 1108
			ShellExecute(@AppDataDir & "\Microsoft\Windows\Libraries\Documents.library-ms")
		Case 1201
			_LAUNCHDOORSUPDATE()
		Case 1202
			WinSetState($DOORSFORM, "", @SW_MINIMIZE)
		Case 1203
			_CLOSEDOORS()
		Case 1204
			_OPENFOLDER($DIR_LOGGING)
		Case 1205
			_OPENTEXTFILE($LOGGFILE_DOORS)
		Case 1301
			_LAUNCHCOMMANDPROMPT()
		Case 1302
			_STARTCOMMANDPROMPTREPAIR()
		Case 1303
			_LAUNCHCONSOLE()
		Case 1304
			_LAUNCHDEFRAGMENTATION()
		Case 1305
			_LAUNCHOWNERSHIP()
		Case 1306
			_LAUNCHREVOUNINSTALLER()
		Case 1307
			_LAUNCHINDICATORS()
		Case 1308
			ShellExecute($DIR_CONSOLE & "\Command.exe", "/DEFRAG", $DIR_CONSOLE, "", @SW_HIDE)
		Case 1501
			_REPAIRFONTREGISTRATIONS()
		Case 1601
			_LAUNCHCLAMWINANTIVIRUS()
		Case 1701
			_WINAPI_ABOUTDLG("", "", "", 0)
	EndSwitch
	_ENDPROCESSING()
EndFunc
Func _GATHERDISPLAYSTATS()
	Local $MEMSTATS = MemGetStats()
	Local $PAGEUSPERC = Round((($MEMSTATS[3] - $MEMSTATS[4]) / $MEMSTATS[3]) * 100)
	Local $CURTIME = _DATE_TIME_GETLOCALTIME()
	GUICtrlSetData($DOORSTIME, _DATE_TIME_SYSTEMTIMETOTIMESTR($CURTIME))
	If $MEMSTATS[0] <> $TM1FREE Then
		_DRAWSTATUSSIZEFROMPERCENTAGE($MEMUSAGEBAR, $MEMSTATS[0], 35, 5, 100, 8)
		GUICtrlSetData($LBLMEMUSAGE, $MEMSTATS[0] & "%")
		$TM1FREE = $MEMSTATS[0]
	EndIf
	If $PAGEUSPERC <> $TM2FREE Then
		_DRAWSTATUSSIZEFROMPERCENTAGE($PAGEUSBAR, $PAGEUSPERC, 35, 15, 100, 8)
		GUICtrlSetData($LBLPAGEUS, $PAGEUSPERC & "%")
		$TM2FREE = $PAGEUSPERC
	EndIf
EndFunc
Func _TOGGLEKEYSSTATE()
	Local $KEYSTATE = 0
	If _WINAPI_GETKEYSTATE(144) <> 0 Then
		$KEYSTATE = $KEYSTATE + 1
	EndIf
	If _WINAPI_GETKEYSTATE(145) <> 0 Then
		$KEYSTATE = $KEYSTATE + 2
	EndIf
	If _WINAPI_GETKEYSTATE(20) <> 0 Then
		$KEYSTATE = $KEYSTATE + 4
	EndIf
	If $KSDIFF <> $KEYSTATE Then
		Select
			Case $KEYSTATE = 1
				GUICtrlSetImage($ICOKSTATE, $DOORSRES, 202)
			Case $KEYSTATE = 2
				GUICtrlSetImage($ICOKSTATE, $DOORSRES, 203)
			Case $KEYSTATE = 3
				GUICtrlSetImage($ICOKSTATE, $DOORSRES, 204)
			Case $KEYSTATE = 4
				GUICtrlSetImage($ICOKSTATE, $DOORSRES, 205)
			Case $KEYSTATE = 5
				GUICtrlSetImage($ICOKSTATE, $DOORSRES, 206)
			Case $KEYSTATE = 6
				GUICtrlSetImage($ICOKSTATE, $DOORSRES, 207)
			Case $KEYSTATE = 7
				GUICtrlSetImage($ICOKSTATE, $DOORSRES, 208)
			Case Else
				GUICtrlSetImage($ICOKSTATE, $DOORSRES, 201)
		EndSelect
		$KSDIFF = $KEYSTATE
	EndIf
EndFunc
Func _STARTPROCESSING()
	GUISetCursor(15)
EndFunc
Func _ENDPROCESSING()
	GUISetCursor(2)
EndFunc
Func _CHECKINTEGRITY()
	If Not FileExists($DOORSRES) Then
		MsgBox(262192, "Resource not found!", "An important resource file could not be found @ [" & $DOORSRES & "]. " & "Although Doors can still function without it, the menus will display without pretty little icons." & @CRLF, 60)
	EndIf
	If Not FileExists($DIR_LOGGING) Then DirCreate($DIR_LOGGING)
EndFunc
; DeTokenise by myAut2Exe >The Open Source AutoIT/AutoHotKey script decompiler< 2.10 build(157)