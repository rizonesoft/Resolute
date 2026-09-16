#Region Header

#cs

    Title:          API Constants UDF Library for AutoIt3
    Filename:       APIConstants.au3
    Description:    Constants to be used with WinAPIEx UDF library.
    Author:         Yashied
    Version:        3.1 / 3.3.6.1
    Requirements:   AutoIt v3.3 +, Developed/Tested on Windows XP Pro Service Pack 2 and Windows Vista/7
    Uses:           None
    Note:           -

#ce

#Include-once

#EndRegion Header

#Region Global Variables and Constants

; ===============================================================================================================================
; _WinAPI_ActivateKeyboardLayout(), _WinAPI_LoadKeyboardLayout()
; ===============================================================================================================================

Global Const $KLF_ACTIVATE = 0x00000001
Global Const $KLF_NOTELLSHELL = 0x00000080
Global Const $KLF_REORDER = 0x00000008
Global Const $KLF_REPLACELANG = 0x00000010
Global Const $KLF_RESET = 0x40000000
Global Const $KLF_SETFORPROCESS = 0x00000100
Global Const $KLF_SHIFTLOCK = 0x00010000
Global Const $KLF_SUBSTITUTE_OK = 0x00000002

Global Const $HKL_NEXT = 1
Global Const $HKL_PREV = 0

; ===============================================================================================================================
; _WinAPI_AddFontResourceEx(), _WinAPI_RemoveFontResourceEx()
; ===============================================================================================================================

Global Const $FR_PRIVATE = 0x10
Global Const $FR_NOT_ENUM = 0x20

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
; _WinAPI_AssocGetPerceivedType()
; ===============================================================================================================================

Global Const $PERCEIVED_TYPE_CUSTOM = -3
Global Const $PERCEIVED_TYPE_UNSPECIFIED = -2
Global Const $PERCEIVED_TYPE_FOLDER = -1
Global Const $PERCEIVED_TYPE_UNKNOWN = 0
Global Const $PERCEIVED_TYPE_TEXT = 1
Global Const $PERCEIVED_TYPE_IMAGE = 2
Global Const $PERCEIVED_TYPE_AUDIO = 3
Global Const $PERCEIVED_TYPE_VIDEO = 4
Global Const $PERCEIVED_TYPE_COMPRESSED = 5
Global Const $PERCEIVED_TYPE_DOCUMENT = 6
Global Const $PERCEIVED_TYPE_SYSTEM = 7
Global Const $PERCEIVED_TYPE_APPLICATION = 8
Global Const $PERCEIVED_TYPE_GAMEMEDIA = 9
Global Const $PERCEIVED_TYPE_CONTACTS = 10

Global Const $PERCEIVEDFLAG_UNDEFINED = 0x0000
Global Const $PERCEIVEDFLAG_SOFTCODED = 0x0001
Global Const $PERCEIVEDFLAG_HARDCODED = 0x0002
Global Const $PERCEIVEDFLAG_NATIVESUPPORT = 0x0004
Global Const $PERCEIVEDFLAG_GDIPLUS = 0x0010
Global Const $PERCEIVEDFLAG_WMSDK = 0x0020
Global Const $PERCEIVEDFLAG_ZIPFOLDER = 0x0040

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
; _WinAPI_BroadcastSystemMessage()
; ===============================================================================================================================

Global Const $BSF_ALLOWSFW = 0x0080
Global Const $BSF_FLUSHDISK = 0x0004
Global Const $BSF_FORCEIFHUNG = 0x0020
Global Const $BSF_IGNORECURRENTTASK = 0x0002
Global Const $BSF_NOHANG = 0x0008
Global Const $BSF_NOTIMEOUTIFNOTHUNG = 0x0040
Global Const $BSF_POSTMESSAGE = 0x0010
Global Const $BSF_QUERY = 0x0001
Global Const $BSF_SENDNOTIFYMESSAGE = 0x0100

Global Const $BSM_ALLCOMPONENTS = 0x00
Global Const $BSM_ALLDESKTOPS = 0x08
Global Const $BSM_APPLICATIONS = 0x10
Global Const $BSM_INSTALLABLEDRIVERS = 0x04
Global Const $BSM_NETDRIVER = 0x02
Global Const $BSM_VXDS = 0x01

; ===============================================================================================================================
; _WinAPI_BrowseForFolderDlg()
; ===============================================================================================================================

Global Const $BIF_RETURNONLYFSDIRS = 0x00000001
Global Const $BIF_DONTGOBELOWDOMAIN = 0x00000002
Global Const $BIF_STATUSTEXT = 0x00000004
Global Const $BIF_RETURNFSANCESTORS = 0x00000008
Global Const $BIF_EDITBOX = 0x00000010
Global Const $BIF_VALIDATE = 0x00000020
Global Const $BIF_NEWDIALOGSTYLE = 0x00000040
Global Const $BIF_BROWSEINCLUDEURLS = 0x00000080
Global Const $BIF_USENEWUI = BitOR($BIF_EDITBOX, $BIF_NEWDIALOGSTYLE)
Global Const $BIF_UAHINT = 0x00000100
Global Const $BIF_NONEWFOLDERBUTTON = 0x00000200
Global Const $BIF_NOTRANSLATETARGETS = 0x00000400
Global Const $BIF_BROWSEFORCOMPUTER = 0x00001000
Global Const $BIF_BROWSEFORPRINTER = 0x00002000
Global Const $BIF_BROWSEINCLUDEFILES = 0x00004000
Global Const $BIF_SHAREABLE = 0x00008000

; *Windows 7 or later
Global Const $BIF_BROWSEFILEJUNCTIONS = 0x00010000

Global Const $BFFM_INITIALIZED = 1
Global Const $BFFM_IUNKNOWN = 5
Global Const $BFFM_SELCHANGED = 2
Global Const $BFFM_VALIDATEFAILED = 4

Global Const $BFFM_ENABLEOK = 0x0465 ; WM_USER + 101
Global Const $BFFM_SETOKTEXT = 0x0469 ; WM_USER + 105
Global Const $BFFM_SETSELECTION = 0x0467 ; WM_USER + 103
Global Const $BFFM_SETEXPANDED = 0x046A ; WM_USER + 106
Global Const $BFFM_SETSTATUSTEXT = 0x0468 ; WM_USER + 104

; ===============================================================================================================================
; _WinAPI_CalculatePopupWindowPosition()
; ===============================================================================================================================

; *Included in MenuConstants.au3

#cs

Global Const $TPM_CENTERALIGN = 0x00000004
Global Const $TPM_LEFTALIGN = 0x00000000
Global Const $TPM_RIGHTALIGN = 0x00000008

Global Const $TPM_BOTTOMALIGN = 0x00000020
Global Const $TPM_TOPALIGN = 0x00000000
Global Const $TPM_VCENTERALIGN = 0x00000010

Global Const $TPM_HORIZONTAL = 0x00000000
Global Const $TPM_VERTICAL = 0x00000040

#ce

; *Windows 7 or later
Global Const $TPM_WORKAREA = 0x00010000

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
; _WinAPI_CoInitialize()
; ===============================================================================================================================

Global Const $COINIT_APARTMENTTHREADED = 0x02
Global Const $COINIT_DISABLE_OLE1DDE = 0x04
Global Const $COINIT_MULTITHREADED = 0x00
Global Const $COINIT_SPEED_OVER_MEMORY = 0x08

; ===============================================================================================================================
; _WinAPI_CopyFileEx(), _WinAPI_MoveFileEx()
; ===============================================================================================================================

Global Const $COPY_FILE_ALLOW_DECRYPTED_DESTINATION = 0x0008
Global Const $COPY_FILE_COPY_SYMLINK = 0x0800
Global Const $COPY_FILE_FAIL_IF_EXISTS = 0x0001
Global Const $COPY_FILE_NO_BUFFERING = 0x1000
Global Const $COPY_FILE_OPEN_SOURCE_FOR_WRITE = 0x0004
Global Const $COPY_FILE_RESTARTABLE = 0x0002

Global Const $MOVE_FILE_COPY_ALLOWED = 0x0002
Global Const $MOVE_FILE_CREATE_HARDLINK = 0x0010
Global Const $MOVE_FILE_DELAY_UNTIL_REBOOT = 0x0004
Global Const $MOVE_FILE_FAIL_IF_NOT_TRACKABLE = 0x0020
Global Const $MOVE_FILE_REPLACE_EXISTING = 0x0001
Global Const $MOVE_FILE_WRITE_THROUGH = 0x0008

Global Const $PROGRESS_CONTINUE = 0
Global Const $PROGRESS_CANCEL = 1
Global Const $PROGRESS_STOP = 2
Global Const $PROGRESS_QUIET = 3

; ===============================================================================================================================
; _WinAPI_CopyImage()
; ===============================================================================================================================

; *Included in Constants.au3

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

Global Const $HS_BDIAGONAL = 3
Global Const $HS_CROSS = 4
Global Const $HS_DIAGCROSS = 5
Global Const $HS_FDIAGONAL = 2
Global Const $HS_HORIZONTAL = 0
Global Const $HS_VERTICAL = 1

Global Const $DIB_PAL_COLORS = 1
Global Const $DIB_RGB_COLORS = 0

; ===============================================================================================================================
; _WinAPI_CreateFileEx()
; ===============================================================================================================================

; *Included in FileConstants.au3

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
Global Const $SECURITY_CONTEXT_TRACKING = 0x00040000
Global Const $SECURITY_DELEGATION = 0x00030000
Global Const $SECURITY_EFFECTIVE_ONLY = 0x00080000
Global Const $SECURITY_IDENTIFICATION = 0x00010000
Global Const $SECURITY_IMPERSONATION = 0x00020000

; ===============================================================================================================================
; _WinAPI_CreateFileMapping(), _WinAPI_OpenFileMapping()
; ===============================================================================================================================

; *Included in MemoryConstants.au3

#cs

Global Const $PAGE_EXECUTE = 0x0010
Global Const $PAGE_EXECUTE_READ = 0x0020
Global Const $PAGE_EXECUTE_READWRITE = 0x0040
Global Const $PAGE_EXECUTE_WRITECOPY = 0x0080
Global Const $PAGE_GUARD = 0x0100
Global Const $PAGE_NOACCESS = 0x0001
Global Const $PAGE_NOCACHE = 0x0200
Global Const $PAGE_READONLY = 0x0002
Global Const $PAGE_READWRITE = 0x0004
Global Const $PAGE_WRITECOMBINE = 0x0400
Global Const $PAGE_WRITECOPY = 0x0008

#ce

Global Const $SEC_COMMIT = 0x08000000
Global Const $SEC_IMAGE = 0x01000000
Global Const $SEC_LARGE_PAGES = 0x80000000
Global Const $SEC_NOCACHE = 0x10000000
Global Const $SEC_RESERVE = 0x04000000
Global Const $SEC_WRITECOMBINE = 0x40000000

Global Const $FILE_MAP_ALL_ACCESS = 0x001F
Global Const $FILE_MAP_COPY = 0x0001
Global Const $FILE_MAP_EXECUTE = 0x0020
Global Const $FILE_MAP_READ = 0x0004
Global Const $FILE_MAP_WRITE = 0x0002

; ===============================================================================================================================
; _WinAPI_CreatePolygonRgn()
; ===============================================================================================================================

Global Const $ALTERNATE = 1
Global Const $WINDING = 2

; ===============================================================================================================================
; _WinAPI_DeferWindowPos()
; ===============================================================================================================================

; *Included in Constants.au3

#cs

Global Const $HWND_BOTTOM = 1
Global Const $HWND_NOTOPMOST = -2
Global Const $HWND_TOP = 0
Global Const $HWND_TOPMOST = -1

Global Const $SWP_DRAWFRAME = 0x0020
Global Const $SWP_FRAMECHANGED = 0x0020
Global Const $SWP_HIDEWINDOW = 0x0080
Global Const $SWP_NOACTIVATE = 0x0010
Global Const $SWP_NOCOPYBITS = 0x0100
Global Const $SWP_NOMOVE = 0x0002
Global Const $SWP_NOOWNERZORDER = 0x0200
Global Const $SWP_NOREDRAW = 0x0008
Global Const $SWP_NOREPOSITION = 0x0200
Global Const $SWP_NOSENDCHANGING = 0x0400
Global Const $SWP_NOSIZE = 0x0001
Global Const $SWP_NOZORDER = 0x0004
Global Const $SWP_SHOWWINDOW = 0x0040

#ce

; ===============================================================================================================================
; _WinAPI_DefineDosDevice()
; ===============================================================================================================================

Global Const $DDD_EXACT_MATCH_ON_REMOVE = 0x04
Global Const $DDD_NO_BROADCAST_SYSTEM = 0x08
Global Const $DDD_RAW_TARGET_PATH = 0x01
Global Const $DDD_REMOVE_DEFINITION = 0x02

; ===============================================================================================================================
; _WinAPI_DeviceIoControl()
; ===============================================================================================================================

Global Const $FSCTL_ALLOW_EXTENDED_DASD_IO = 0x00090083
Global Const $FSCTL_CREATE_OR_GET_OBJECT_ID = 0x000900C0
Global Const $FSCTL_CREATE_USN_JOURNAL = 0x000900E7
Global Const $FSCTL_DELETE_OBJECT_ID = 0x000900A0
Global Const $FSCTL_DELETE_REPARSE_POINT = 0x000900AC
Global Const $FSCTL_DELETE_USN_JOURNAL = 0x000900F8
Global Const $FSCTL_DISMOUNT_VOLUME = 0x00090020
Global Const $FSCTL_DUMP_PROPERTY_DATA = 0x00090097
Global Const $FSCTL_ENABLE_UPGRADE = 0x000980D0
Global Const $FSCTL_ENCRYPTION_FSCTL_IO = 0x000900DB
Global Const $FSCTL_ENUM_USN_DATA = 0x000900B3
Global Const $FSCTL_EXTEND_VOLUME = 0x000900F0
Global Const $FSCTL_FILESYSTEM_GET_STATISTICS = 0x00090060
Global Const $FSCTL_FIND_FILES_BY_SID = 0x0009008F
Global Const $FSCTL_GET_COMPRESSION = 0x0009003C
Global Const $FSCTL_GET_NTFS_FILE_RECORD = 0x00090068
Global Const $FSCTL_GET_NTFS_VOLUME_DATA = 0x00090064
Global Const $FSCTL_GET_OBJECT_ID = 0x0009009C
Global Const $FSCTL_GET_REPARSE_POINT = 0x000900A8
Global Const $FSCTL_GET_RETRIEVAL_POINTERS = 0x00090073
Global Const $FSCTL_GET_VOLUME_BITMAP = 0x0009006F
Global Const $FSCTL_HSM_DATA = 0x0009C113
Global Const $FSCTL_HSM_MSG = 0x0009C108
Global Const $FSCTL_INVALIDATE_VOLUMES = 0x00090054
Global Const $FSCTL_IS_PATHNAME_VALID = 0x0009002C
Global Const $FSCTL_IS_VOLUME_DIRTY = 0x00090078
Global Const $FSCTL_IS_VOLUME_MOUNTED = 0x00090028
Global Const $FSCTL_LOCK_VOLUME = 0x00090018
Global Const $FSCTL_MARK_AS_SYSTEM_HIVE = 0x0009004F
Global Const $FSCTL_MARK_HANDLE = 0x000900FC
Global Const $FSCTL_MARK_VOLUME_DIRTY = 0x00090030
Global Const $FSCTL_MOVE_FILE = 0x00090074
Global Const $FSCTL_OPBATCH_ACK_CLOSE_PENDING = 0x00090010
Global Const $FSCTL_OPLOCK_BREAK_ACK_NO_2 = 0x00090050
Global Const $FSCTL_OPLOCK_BREAK_ACKNOWLEDGE = 0x0009000C
Global Const $FSCTL_OPLOCK_BREAK_NOTIFY = 0x00090014
Global Const $FSCTL_QUERY_ALLOCATED_RANGES = 0x000940CF
Global Const $FSCTL_QUERY_FAT_BPB = 0x00090058
Global Const $FSCTL_QUERY_RETRIEVAL_POINTERS = 0x0009003B
Global Const $FSCTL_QUERY_USN_JOURNAL = 0x000900F4
Global Const $FSCTL_READ_FILE_USN_DATA = 0x000900EB
Global Const $FSCTL_READ_PROPERTY_DATA = 0x00090087
Global Const $FSCTL_READ_RAW_ENCRYPTED = 0x000900E3
Global Const $FSCTL_READ_USN_JOURNAL = 0x000900BB
Global Const $FSCTL_RECALL_FILE = 0x00090117
Global Const $FSCTL_REQUEST_BATCH_OPLOCK = 0x00090008
Global Const $FSCTL_REQUEST_FILTER_OPLOCK = 0x0009005C
Global Const $FSCTL_REQUEST_OPLOCK_LEVEL_1 = 0x00090000
Global Const $FSCTL_REQUEST_OPLOCK_LEVEL_2 = 0x00090004
Global Const $FSCTL_SECURITY_ID_CHECK = 0x000940B7
Global Const $FSCTL_SET_COMPRESSION = 0x0009C040
Global Const $FSCTL_SET_ENCRYPTION = 0x000900D7
Global Const $FSCTL_SET_OBJECT_ID = 0x00090098
Global Const $FSCTL_SET_OBJECT_ID_EXTENDED = 0x000900BC
Global Const $FSCTL_SET_REPARSE_POINT = 0x000900A4
Global Const $FSCTL_SET_SPARSE = 0x000900C4
Global Const $FSCTL_SET_ZERO_DATA = 0x000980C8
Global Const $FSCTL_SIS_COPYFILE = 0x00090100
Global Const $FSCTL_SIS_LINK_FILES = 0x0009C104
Global Const $FSCTL_UNLOCK_VOLUME = 0x0009001C
Global Const $FSCTL_WRITE_PROPERTY_DATA = 0x0009008B
Global Const $FSCTL_WRITE_RAW_ENCRYPTED = 0x000900DF
Global Const $FSCTL_WRITE_USN_CLOSE_RECORD = 0x000900EF

Global Const $IOCTL_AACS_END_SESSION = 0x003350CC
Global Const $IOCTL_AACS_GENERATE_BINDING_NONCE = 0x0033D0F0
Global Const $IOCTL_AACS_GET_CERTIFICATE = 0x003350D4
Global Const $IOCTL_AACS_GET_CHALLENGE_KEY = 0x003350D8
Global Const $IOCTL_AACS_READ_BINDING_NONCE = 0x003350EC
Global Const $IOCTL_AACS_READ_MEDIA_ID = 0x003350E8
Global Const $IOCTL_AACS_READ_MEDIA_KEY_BLOCK = 0x003350C4
Global Const $IOCTL_AACS_READ_MEDIA_KEY_BLOCK_SIZE = 0x003350C0
Global Const $IOCTL_AACS_READ_SERIAL_NUMBER = 0x003350E4
Global Const $IOCTL_AACS_READ_VOLUME_ID = 0x003350E0
Global Const $IOCTL_AACS_SEND_CERTIFICATE = 0x003350D0
Global Const $IOCTL_AACS_SEND_CHALLENGE_KEY = 0x003350DC
Global Const $IOCTL_AACS_START_SESSION = 0x003350C8

Global Const $IOCTL_ATA_PASS_THROUGH = 0x0004D02C
Global Const $IOCTL_ATA_PASS_THROUGH_DIRECT = 0x0004D030

Global Const $IOCTL_CDROM_CHECK_VERIFY = 0x00024800
Global Const $IOCTL_CDROM_DISK_TYPE = 0x00020040
Global Const $IOCTL_CDROM_EJECT_MEDIA = 0x00024808
Global Const $IOCTL_CDROM_FIND_NEW_DEVICES = 0x00024818
Global Const $IOCTL_CDROM_GET_CONFIGURATION = 0x00024058
Global Const $IOCTL_CDROM_GET_CONTROL = 0x00024034
Global Const $IOCTL_CDROM_GET_DRIVE_GEOMETRY = 0x0002404C
Global Const $IOCTL_CDROM_GET_DRIVE_GEOMETRY_EX = 0x00024050
Global Const $IOCTL_CDROM_GET_LAST_SESSION = 0x00024038
Global Const $IOCTL_CDROM_GET_VOLUME = 0x00024014
Global Const $IOCTL_CDROM_LOAD_MEDIA = 0x0002480C
Global Const $IOCTL_CDROM_MEDIA_REMOVAL = 0x00024804
Global Const $IOCTL_CDROM_PAUSE_AUDIO = 0x0002400C
Global Const $IOCTL_CDROM_PLAY_AUDIO_MSF = 0x00024018
Global Const $IOCTL_CDROM_RAW_READ = 0x0002403E
Global Const $IOCTL_CDROM_READ_Q_CHANNEL = 0x0002402C
Global Const $IOCTL_CDROM_READ_TOC = 0x00024000
Global Const $IOCTL_CDROM_READ_TOC_EX = 0x00024054
Global Const $IOCTL_CDROM_RELEASE = 0x00024814
Global Const $IOCTL_CDROM_RESERVE = 0x00024810
Global Const $IOCTL_CDROM_RESUME_AUDIO = 0x00024010
Global Const $IOCTL_CDROM_SEEK_AUDIO_MSF = 0x00024004
Global Const $IOCTL_CDROM_SET_VOLUME = 0x00024028
Global Const $IOCTL_CDROM_STOP_AUDIO = 0x00024008
Global Const $IOCTL_CDROM_UNLOAD_DRIVER = 0x00025008

Global Const $IOCTL_DISK_CHECK_VERIFY = 0x00074800
Global Const $IOCTL_DISK_CONTROLLER_NUMBER = 0x00070044
Global Const $IOCTL_DISK_CREATE_DISK = 0x0007C058
Global Const $IOCTL_DISK_DELETE_DRIVE_LAYOUT = 0x0007C100
Global Const $IOCTL_DISK_EJECT_MEDIA = 0x00074808
Global Const $IOCTL_DISK_FIND_NEW_DEVICES = 0x00074818
Global Const $IOCTL_DISK_FORMAT_TRACKS = 0x0007C018
Global Const $IOCTL_DISK_FORMAT_TRACKS_EX = 0x0007C02C
Global Const $IOCTL_DISK_GET_CACHE_INFORMATION = 0x000740D4
Global Const $IOCTL_DISK_GET_DRIVE_GEOMETRY = 0x00070000
Global Const $IOCTL_DISK_GET_DRIVE_GEOMETRY_EX = 0x000700A0
Global Const $IOCTL_DISK_GET_DRIVE_LAYOUT = 0x0007400C
Global Const $IOCTL_DISK_GET_DRIVE_LAYOUT_EX = 0x00070050
Global Const $IOCTL_DISK_GET_LENGTH_INFO = 0x0007405C
Global Const $IOCTL_DISK_GET_MEDIA_TYPES = 0x00070C00
Global Const $IOCTL_DISK_GET_PARTITION_INFO = 0x00074004
Global Const $IOCTL_DISK_GET_PARTITION_INFO_EX = 0x00070048
Global Const $IOCTL_DISK_GET_WRITE_CACHE_STATE = 0x000740DC
Global Const $IOCTL_DISK_GROW_PARTITION = 0x0007C0D0
Global Const $IOCTL_DISK_HISTOGRAM_DATA = 0x00070034
Global Const $IOCTL_DISK_HISTOGRAM_RESET = 0x00070038
Global Const $IOCTL_DISK_HISTOGRAM_STRUCTURE = 0x00070030
Global Const $IOCTL_DISK_INTERNAL_CLEAR_VERIFY = 0x00070407
Global Const $IOCTL_DISK_INTERNAL_SET_NOTIFY = 0x00070408
Global Const $IOCTL_DISK_INTERNAL_SET_VERIFY = 0x00070403
Global Const $IOCTL_DISK_IS_WRITABLE = 0x00070024
Global Const $IOCTL_DISK_LOAD_MEDIA = 0x0007480C
Global Const $IOCTL_DISK_LOGGING = 0x00070028
Global Const $IOCTL_DISK_MEDIA_REMOVAL = 0x00074804
Global Const $IOCTL_DISK_PERFORMANCE = 0x00070020
Global Const $IOCTL_DISK_PERFORMANCE_OFF = 0x00070060
Global Const $IOCTL_DISK_REASSIGN_BLOCKS = 0x0007C01C
Global Const $IOCTL_DISK_RELEASE = 0x00074814
Global Const $IOCTL_DISK_REQUEST_DATA = 0x00070040
Global Const $IOCTL_DISK_REQUEST_STRUCTURE = 0x0007003C
Global Const $IOCTL_DISK_RESERVE = 0x00074810
Global Const $IOCTL_DISK_SET_CACHE_INFORMATION = 0x0007C0D8
Global Const $IOCTL_DISK_SET_DRIVE_LAYOUT = 0x0007C010
Global Const $IOCTL_DISK_SET_DRIVE_LAYOUT_EX = 0x0007C054
Global Const $IOCTL_DISK_SET_PARTITION_INFO = 0x0007C008
Global Const $IOCTL_DISK_SET_PARTITION_INFO_EX = 0x0007C04C
Global Const $IOCTL_DISK_UPDATE_DRIVE_SIZE = 0x0007C0C8
Global Const $IOCTL_DISK_UPDATE_PROPERTIES = 0x00070140
Global Const $IOCTL_DISK_VERIFY = 0x00070014

Global Const $IOCTL_DVD_END_SESSION = 0x0033500C
Global Const $IOCTL_DVD_GET_REGION = 0x00335014
Global Const $IOCTL_DVD_READ_KEY = 0x00335004
Global Const $IOCTL_DVD_READ_STRUCTURE = 0x00335140
Global Const $IOCTL_DVD_SEND_KEY = 0x00335008
Global Const $IOCTL_DVD_SEND_KEY2 = 0x0033D018
Global Const $IOCTL_DVD_SET_READ_AHEAD = 0x00335010
Global Const $IOCTL_DVD_START_SESSION = 0x00335000

Global Const $IOCTL_MOUNTDEV_LINK_CREATED = 0x004D0010
Global Const $IOCTL_MOUNTDEV_LINK_DELETED = 0x004D0014
Global Const $IOCTL_MOUNTDEV_QUERY_STABLE_GUID = 0x004D0018
Global Const $IOCTL_MOUNTDEV_QUERY_SUGGESTED_LINK_NAME = 0x004D000C
Global Const $IOCTL_MOUNTDEV_QUERY_UNIQUE_ID = 0x004D0000
Global Const $IOCTL_MOUNTDEV_UNIQUE_ID_CHANGE_NOTIFY = 0x004D0004

Global Const $IOCTL_MOUNTMGR_AUTO_DL_ASSIGNMENTS = 0x006DC014
Global Const $IOCTL_MOUNTMGR_CHANGE_NOTIFY = 0x006D4020
Global Const $IOCTL_MOUNTMGR_CHECK_UNPROCESSED_VOLUMES = 0x006D4028
Global Const $IOCTL_MOUNTMGR_CREATE_POINT = 0x006DC000
Global Const $IOCTL_MOUNTMGR_DELETE_POINTS = 0x006DC004
Global Const $IOCTL_MOUNTMGR_DELETE_POINTS_DBONLY = 0x006DC00C
Global Const $IOCTL_MOUNTMGR_KEEP_LINKS_WHEN_OFFLINE = 0x006DC024
Global Const $IOCTL_MOUNTMGR_NEXT_DRIVE_LETTER = 0x006DC010
Global Const $IOCTL_MOUNTMGR_QUERY_DOS_VOLUME_PATH = 0x006D0030
Global Const $IOCTL_MOUNTMGR_QUERY_DOS_VOLUME_PATHS = 0x006D0034
Global Const $IOCTL_MOUNTMGR_QUERY_POINTS = 0x006D0008
Global Const $IOCTL_MOUNTMGR_VOLUME_ARRIVAL_NOTIFICATION = 0x006D402C
Global Const $IOCTL_MOUNTMGR_VOLUME_MOUNT_POINT_CREATED = 0x006DC018
Global Const $IOCTL_MOUNTMGR_VOLUME_MOUNT_POINT_DELETED = 0x006DC01C

Global Const $IOCTL_SCSI_GET_INQUIRY_DATA = 0x0004100C
Global Const $IOCTL_SCSI_GET_CAPABILITIES = 0x00041010
Global Const $IOCTL_SCSI_GET_ADDRESS = 0x00041018
Global Const $IOCTL_SCSI_MINIPORT = 0x0004D008
Global Const $IOCTL_SCSI_PASS_THROUGH = 0x0004D004
Global Const $IOCTL_SCSI_PASS_THROUGH_DIRECT = 0x0004D014
Global Const $IOCTL_SCSI_RESCAN_BUS = 0x0004101C

Global Const $IOCTL_STORAGE_BREAK_RESERVATION = 0x002D5014
Global Const $IOCTL_STORAGE_CHECK_VERIFY = 0x002D4800
Global Const $IOCTL_STORAGE_CHECK_VERIFY2 = 0x002D0800
Global Const $IOCTL_STORAGE_EJECT_MEDIA = 0x002D4808
Global Const $IOCTL_STORAGE_EJECTION_CONTROL = 0x002D0940
Global Const $IOCTL_STORAGE_FIND_NEW_DEVICES = 0x002D4818
Global Const $IOCTL_STORAGE_GET_DEVICE_NUMBER = 0x002D1080
Global Const $IOCTL_STORAGE_GET_HOTPLUG_INFO = 0x002D0C14
Global Const $IOCTL_STORAGE_GET_MEDIA_SERIAL_NUMBER = 0x002D0C10
Global Const $IOCTL_STORAGE_GET_MEDIA_TYPES = 0x002D0C00
Global Const $IOCTL_STORAGE_GET_MEDIA_TYPES_EX = 0x002D0C04
Global Const $IOCTL_STORAGE_LOAD_MEDIA = 0x002D480C
Global Const $IOCTL_STORAGE_LOAD_MEDIA2 = 0x002D080C
Global Const $IOCTL_STORAGE_MANAGE_DATA_SET_ATTRIBUTES = 0x002D9404
Global Const $IOCTL_STORAGE_MCN_CONTROL = 0x002D0944
Global Const $IOCTL_STORAGE_MEDIA_REMOVAL = 0x002D4804
Global Const $IOCTL_STORAGE_PERSISTENT_RESERVE_IN = 0x002D5018
Global Const $IOCTL_STORAGE_PERSISTENT_RESERVE_OUT = 0x002D501C
Global Const $IOCTL_STORAGE_PREDICT_FAILURE = 0x002D1100
Global Const $IOCTL_STORAGE_QUERY_PROPERTY = 0x002D1400
Global Const $IOCTL_STORAGE_RELEASE = 0x002D4814
Global Const $IOCTL_STORAGE_RESERVE = 0x002D4810
Global Const $IOCTL_STORAGE_RESET_BUS = 0x002D5000
Global Const $IOCTL_STORAGE_RESET_DEVICE = 0x002D5004
Global Const $IOCTL_STORAGE_SET_HOTPLUG_INFO = 0x002DCC18
Global Const $IOCTL_STORAGE_SET_READ_AHEAD = 0x002D4400

Global Const $IOCTL_VOLUME_GET_GPT_ATTRIBUTES = 0x00560038
Global Const $IOCTL_VOLUME_GET_VOLUME_DISK_EXTENTS = 0x00560000
Global Const $IOCTL_VOLUME_IS_CLUSTERED = 0x00560030
Global Const $IOCTL_VOLUME_IS_IO_CAPABLE = 0x00560014
Global Const $IOCTL_VOLUME_IS_OFFLINE = 0x00560010
Global Const $IOCTL_VOLUME_IS_PARTITION = 0x00560028
Global Const $IOCTL_VOLUME_LOGICAL_TO_PHYSICAL = 0x00560020
Global Const $IOCTL_VOLUME_OFFLINE = 0x0056C00C
Global Const $IOCTL_VOLUME_ONLINE = 0x0056C008
Global Const $IOCTL_VOLUME_PHYSICAL_TO_LOGICAL = 0x00560024
Global Const $IOCTL_VOLUME_QUERY_FAILOVER_SET = 0x00560018
Global Const $IOCTL_VOLUME_QUERY_VOLUME_NUMBER = 0x0056001C
Global Const $IOCTL_VOLUME_READ_PLEX = 0x0056402E
Global Const $IOCTL_VOLUME_SET_GPT_ATTRIBUTES = 0x00560034
Global Const $IOCTL_VOLUME_SUPPORTS_ONLINE_OFFLINE = 0x00560004

Global Const $SMART_GET_VERSION = 0x00074080
Global Const $SMART_RCV_DRIVE_DATA = 0x0007C088
Global Const $SMART_SEND_DRIVE_COMMAND = 0x0007C084

; ===============================================================================================================================
; _WinAPI_DllGetVersion()
; ===============================================================================================================================

Global Const $DLLVER_PLATFORM_WINDOWS = 0x01
Global Const $DLLVER_PLATFORM_NT = 0x02

; ===============================================================================================================================
; _WinAPI_DrawShadowText()
; ===============================================================================================================================

; *Included in WindowsConstants.au3

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
; _WinAPI_DrawThemeTextEx()
; ===============================================================================================================================

Global Const $DTT_TEXTCOLOR = 0x00000001
Global Const $DTT_BORDERCOLOR = 0x00000002
Global Const $DTT_SHADOWCOLOR = 0x00000004
Global Const $DTT_SHADOWTYPE = 0x00000008
Global Const $DTT_SHADOWOFFSET = 0x00000010
Global Const $DTT_BORDERSIZE = 0x00000020
Global Const $DTT_FONTPROP = 0x00000040
Global Const $DTT_COLORPROP = 0x00000080
Global Const $DTT_STATEID = 0x00000100
Global Const $DTT_CALCRECT = 0x00000200
Global Const $DTT_APPLYOVERLAY = 0x00000400
Global Const $DTT_GLOWSIZE = 0x00000800
Global Const $DTT_CALLBACK = 0x00001000
Global Const $DTT_COMPOSITED = 0x00002000
Global Const $DTT_VALIDBITS = BitOR($DTT_TEXTCOLOR, $DTT_BORDERCOLOR, $DTT_SHADOWCOLOR, $DTT_SHADOWTYPE, $DTT_SHADOWOFFSET, $DTT_BORDERSIZE, $DTT_FONTPROP, $DTT_COLORPROP, $DTT_STATEID, $DTT_CALCRECT, $DTT_APPLYOVERLAY, $DTT_GLOWSIZE, $DTT_COMPOSITED)

Global Const $TST_NONE = 0
Global Const $TST_SINGLE = 1
Global Const $TST_CONTINUOUS = 2

; ===============================================================================================================================
; _WinAPI_DuplicateHandle()
; ===============================================================================================================================

Global Const $DUPLICATE_CLOSE_SOURCE = 0x01
Global Const $DUPLICATE_SAME_ACCESS = 0x02

; *Included in ProcessConstants.au3

#cs

Global Const $PROCESS_ALL_ACCESS = 0x001F0FFF
Global Const $PROCESS_CREATE_PROCESS = 0x00000080
Global Const $PROCESS_CREATE_THREAD = 0x00000002
Global Const $PROCESS_DUP_HANDLE = 0x00000040
Global Const $PROCESS_QUERY_INFORMATION = 0x00000400
Global Const $PROCESS_QUERY_LIMITED_INFORMATION = 0x00001000
Global Const $PROCESS_SET_INFORMATION = 0x00000200
Global Const $PROCESS_SET_QUOTA = 0x00000100
Global Const $PROCESS_SUSPEND_RESUME = 0x00000800
Global Const $PROCESS_TERMINATE = 0x00000001
Global Const $PROCESS_VM_OPERATION = 0x00000008
Global Const $PROCESS_VM_READ = 0x00000010
Global Const $PROCESS_VM_WRITE = 0x00000020

#ce

; ===============================================================================================================================
; _WinAPI_DwmGetWindowAttribute(), _WinAPI_DwmSetWindowAttribute()
; ===============================================================================================================================

Global Const $DWMWA_NCRENDERING_ENABLED = 1
Global Const $DWMWA_NCRENDERING_POLICY = 2
Global Const $DWMWA_TRANSITIONS_FORCEDISABLED = 3
Global Const $DWMWA_ALLOW_NCPAINT = 4
Global Const $DWMWA_CAPTION_BUTTON_BOUNDS = 5
Global Const $DWMWA_NONCLIENT_RTL_LAYOUT = 6
Global Const $DWMWA_FORCE_ICONIC_REPRESENTATION = 7
Global Const $DWMWA_FLIP3D_POLICY = 8
Global Const $DWMWA_EXTENDED_FRAME_BOUNDS = 9

; *Windows 7 or later
Global Const $DWMWA_HAS_ICONIC_BITMAP = 10
Global Const $DWMWA_DISALLOW_PEEK = 11
Global Const $DWMWA_EXCLUDED_FROM_PEEK = 12

Global Const $DWMNCRP_USEWINDOWSTYLE = 0
Global Const $DWMNCRP_DISABLED = 1
Global Const $DWMNCRP_ENABLED = 2

Global Const $DWMFLIP3D_DEFAULT = 0
Global Const $DWMFLIP3D_EXCLUDEBELOW = 1
Global Const $DWMFLIP3D_EXCLUDEABOVE = 2

; ===============================================================================================================================
; _WinAPI_EnumDisplaySettings()
; ===============================================================================================================================

Global Const $ENUM_CURRENT_SETTINGS = -1
Global Const $ENUM_REGISTRY_SETTINGS = -2

Global Const $DM_GRAYSCALE = 0x01
Global Const $DM_INTERLACED = 0x02

; ===============================================================================================================================
; _WinAPI_ExtFloodFill()
; ===============================================================================================================================

Global Const $FLOODFILLBORDER = 0
Global Const $FLOODFILLSURFACE = 1

; ===============================================================================================================================
; _WinAPI_ExtSelectClipRgn(), _WinAPI_SelectClipPath()
; ===============================================================================================================================

; *Included in WindowsConstants.au3

#cs

Global Const $RGN_AND = 1
Global Const $RGN_OR = 2
Global Const $RGN_XOR = 3
Global Const $RGN_DIFF = 4
Global Const $RGN_COPY = 5

#ce

; ===============================================================================================================================
; _WinAPI_FindResource(), _WinAPI_FindResourceEx(), _WinAPI_UpdateResource()
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
; _WinAPI_GetArcDirection(), _WinAPI_SetArcDirection()
; ===============================================================================================================================

Global Const $AD_COUNTERCLOCKWISE = 1
Global Const $AD_CLOCKWISE = 2

; ===============================================================================================================================
; _WinAPI_GetBinaryType()
; ===============================================================================================================================

Global Const $SCS_32BIT_BINARY = 0
Global Const $SCS_64BIT_BINARY = 6
Global Const $SCS_DOS_BINARY = 1
Global Const $SCS_OS216_BINARY = 5
Global Const $SCS_PIF_BINARY = 3
Global Const $SCS_POSIX_BINARY = 4
Global Const $SCS_WOW_BINARY = 2

; ===============================================================================================================================
; _WinAPI_GetClassLongEx(), _WinAPI_SetClassLongEx()
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
; _WinAPI_GetCurrentHwProfile()
; ===============================================================================================================================

Global Const $DOCKINFO_DOCKED = 0x02
Global Const $DOCKINFO_UNDOCKED = 0x01
Global Const $DOCKINFO_USER_SUPPLIED = 0x04
Global Const $DOCKINFO_USER_DOCKED = 0x05
Global Const $DOCKINFO_USER_UNDOCKED = 0x06

; ===============================================================================================================================
; _WinAPI_GetDateFormat()
; ===============================================================================================================================

Global Const $DATE_LONGDATE = 0x02
Global Const $DATE_SHORTDATE = 0x01
Global Const $DATE_USE_ALT_CALENDAR = 0x04

; *Windows Vista or later
Global Const $DATE_LTRREADING = 0x10
Global Const $DATE_RTLREADING = 0x20
Global Const $DATE_YEARMONTH = 0x08

; *Windows 7 or later
Global Const $DATE_AUTOLAYOUT = 0x40

; ===============================================================================================================================
; _WinAPI_GetDCEx()
; ===============================================================================================================================

Global Const $DCX_WINDOW = 0x00000001
Global Const $DCX_CACHE = 0x00000002
Global Const $DCX_PARENTCLIP = 0x00000020
Global Const $DCX_CLIPSIBLINGS = 0x00000010
Global Const $DCX_CLIPCHILDREN = 0x00000008
Global Const $DCX_NORESETATTRS = 0x00000004
Global Const $DCX_LOCKWINDOWUPDATE = 0x00000400
Global Const $DCX_EXCLUDERGN = 0x00000040
Global Const $DCX_INTERSECTRGN = 0x00000080
Global Const $DCX_INTERSECTUPDATE = 0x00000200
Global Const $DCX_VALIDATE = 0x00200000

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
; _WinAPI_GetErrorMode(), _WinAPI_SetErrorMode()
; ===============================================================================================================================

Global Const $SEM_FAILCRITICALERRORS = 0x0001
Global Const $SEM_NOALIGNMENTFAULTEXCEPT = 0x0004
Global Const $SEM_NOGPFAULTERRORBOX = 0x0002
Global Const $SEM_NOOPENFILEERRORBOX = 0x8000

; ===============================================================================================================================
; _WinAPI_GetHandleInformation(), _WinAPI_SetHandleInformation()
; ===============================================================================================================================

Global Const $HANDLE_FLAG_INHERIT = 0x00000001
Global Const $HANDLE_FLAG_PROTECT_FROM_CLOSE = 0x00000002

; ===============================================================================================================================
; _WinAPI_GetLayeredWindowAttributes(), _WinAPI_SetLayeredWindowAttributes()
; ===============================================================================================================================

; *Included in WindowsConstants.au3

#cs

Global Const $LWA_COLORKEY = 0x01
Global Const $LWA_ALPHA = 0x02

#ce

; ===============================================================================================================================
; _WinAPI_GetLocaleInfo(), _WinAPI_SetLocaleInfo()
; ===============================================================================================================================

Global Const $LOCALE_ILANGUAGE = 0x0001
Global Const $LOCALE_SLANGUAGE = 0x0002
Global Const $LOCALE_SENGLANGUAGE = 0x1001
Global Const $LOCALE_SABBREVLANGNAME = 0x0003
Global Const $LOCALE_SNATIVELANGNAME = 0x0004

Global Const $LOCALE_ICOUNTRY = 0x0005
Global Const $LOCALE_SCOUNTRY = 0x0006
Global Const $LOCALE_SENGCOUNTRY = 0x1002
Global Const $LOCALE_SABBREVCTRYNAME = 0x0007
Global Const $LOCALE_SNATIVECTRYNAME = 0x0008

Global Const $LOCALE_IDEFAULTLANGUAGE = 0x0009
Global Const $LOCALE_IDEFAULTCOUNTRY = 0x000A
Global Const $LOCALE_IDEFAULTCODEPAGE = 0x000B
Global Const $LOCALE_IDEFAULTANSICODEPAGE = 0x1004
Global Const $LOCALE_IDEFAULTMACCODEPAGE = 0x1011

Global Const $LOCALE_SLIST = 0x000C
Global Const $LOCALE_IMEASURE = 0x000D

Global Const $LOCALE_SDECIMAL = 0x000E
Global Const $LOCALE_STHOUSAND = 0x000F
Global Const $LOCALE_SGROUPING = 0x0010
Global Const $LOCALE_IDIGITS = 0x0011
Global Const $LOCALE_ILZERO = 0x0012
Global Const $LOCALE_INEGNUMBER = 0x1010
Global Const $LOCALE_SNATIVEDIGITS = 0x0013

Global Const $LOCALE_SCURRENCY = 0x0014
Global Const $LOCALE_SINTLSYMBOL = 0x0015
Global Const $LOCALE_SMONDECIMALSEP = 0x0016
Global Const $LOCALE_SMONTHOUSANDSEP = 0x0017
Global Const $LOCALE_SMONGROUPING = 0x0018
Global Const $LOCALE_ICURRDIGITS = 0x0019
Global Const $LOCALE_IINTLCURRDIGITS = 0x001A
Global Const $LOCALE_ICURRENCY = 0x001B
Global Const $LOCALE_INEGCURR = 0x001C

Global Const $LOCALE_SDATE = 0x001D
Global Const $LOCALE_STIME = 0x001E
Global Const $LOCALE_SSHORTDATE = 0x001F
Global Const $LOCALE_SLONGDATE = 0x0020
Global Const $LOCALE_STIMEFORMAT = 0x1003
Global Const $LOCALE_IDATE = 0x0021
Global Const $LOCALE_ILDATE = 0x0022
Global Const $LOCALE_ITIME = 0x0023
Global Const $LOCALE_ITIMEMARKPOSN = 0x1005
Global Const $LOCALE_ICENTURY = 0x0024
Global Const $LOCALE_ITLZERO = 0x0025
Global Const $LOCALE_IDAYLZERO = 0x0026
Global Const $LOCALE_IMONLZERO = 0x0027
Global Const $LOCALE_S1159 = 0x0028
Global Const $LOCALE_S2359 = 0x0029

Global Const $LOCALE_ICALENDARTYPE = 0x1009
Global Const $LOCALE_IOPTIONALCALENDAR = 0x100B
Global Const $LOCALE_IFIRSTDAYOFWEEK = 0x100C
Global Const $LOCALE_IFIRSTWEEKOFYEAR = 0x100D

Global Const $LOCALE_SDAYNAME1 = 0x002A
Global Const $LOCALE_SDAYNAME2 = 0x002B
Global Const $LOCALE_SDAYNAME3 = 0x002C
Global Const $LOCALE_SDAYNAME4 = 0x002D
Global Const $LOCALE_SDAYNAME5 = 0x002E
Global Const $LOCALE_SDAYNAME6 = 0x002F
Global Const $LOCALE_SDAYNAME7 = 0x0030
Global Const $LOCALE_SABBREVDAYNAME1 = 0x0031
Global Const $LOCALE_SABBREVDAYNAME2 = 0x0032
Global Const $LOCALE_SABBREVDAYNAME3 = 0x0033
Global Const $LOCALE_SABBREVDAYNAME4 = 0x0034
Global Const $LOCALE_SABBREVDAYNAME5 = 0x0035
Global Const $LOCALE_SABBREVDAYNAME6 = 0x0036
Global Const $LOCALE_SABBREVDAYNAME7 = 0x0037
Global Const $LOCALE_SMONTHNAME1 = 0x0038
Global Const $LOCALE_SMONTHNAME2 = 0x0039
Global Const $LOCALE_SMONTHNAME3 = 0x003A
Global Const $LOCALE_SMONTHNAME4 = 0x003B
Global Const $LOCALE_SMONTHNAME5 = 0x003C
Global Const $LOCALE_SMONTHNAME6 = 0x003D
Global Const $LOCALE_SMONTHNAME7 = 0x003E
Global Const $LOCALE_SMONTHNAME8 = 0x003F
Global Const $LOCALE_SMONTHNAME9 = 0x0040
Global Const $LOCALE_SMONTHNAME10 = 0x0041
Global Const $LOCALE_SMONTHNAME11 = 0x0042
Global Const $LOCALE_SMONTHNAME12 = 0x0043
Global Const $LOCALE_SMONTHNAME13 = 0x100E
Global Const $LOCALE_SABBREVMONTHNAME1 = 0x0044
Global Const $LOCALE_SABBREVMONTHNAME2 = 0x0045
Global Const $LOCALE_SABBREVMONTHNAME3 = 0x0046
Global Const $LOCALE_SABBREVMONTHNAME4 = 0x0047
Global Const $LOCALE_SABBREVMONTHNAME5 = 0x0048
Global Const $LOCALE_SABBREVMONTHNAME6 = 0x0049
Global Const $LOCALE_SABBREVMONTHNAME7 = 0x004A
Global Const $LOCALE_SABBREVMONTHNAME8 = 0x004B
Global Const $LOCALE_SABBREVMONTHNAME9 = 0x004C
Global Const $LOCALE_SABBREVMONTHNAME10 = 0x004D
Global Const $LOCALE_SABBREVMONTHNAME11 = 0x004E
Global Const $LOCALE_SABBREVMONTHNAME12 = 0x004F
Global Const $LOCALE_SABBREVMONTHNAME13 = 0x100F

Global Const $LOCALE_SPOSITIVESIGN = 0x0050
Global Const $LOCALE_SNEGATIVESIGN = 0x0051
Global Const $LOCALE_IPOSSIGNPOSN = 0x0052
Global Const $LOCALE_INEGSIGNPOSN = 0x0053
Global Const $LOCALE_IPOSSYMPRECEDES = 0x0054
Global Const $LOCALE_IPOSSEPBYSPACE = 0x0055
Global Const $LOCALE_INEGSYMPRECEDES = 0x0056
Global Const $LOCALE_INEGSEPBYSPACE = 0x0057

Global Const $LOCALE_FONTSIGNATURE = 0x0058
Global Const $LOCALE_SISO639LANGNAME = 0x0059
Global Const $LOCALE_SISO3166CTRYNAME = 0x005A

Global Const $LOCALE_IDEFAULTEBCDICCODEPAGE = 0x1012
Global Const $LOCALE_IPAPERSIZE = 0x100A
Global Const $LOCALE_SENGCURRNAME = 0x1007
Global Const $LOCALE_SNATIVECURRNAME = 0x1008
Global Const $LOCALE_SYEARMONTH = 0x1006
Global Const $LOCALE_SSORTNAME = 0x1013
Global Const $LOCALE_IDIGITSUBSTITUTION = 0x1014

Global Const $LOCALE_CUSTOM_DEFAULT = 0x0C00
Global Const $LOCALE_CUSTOM_UI_DEFAULT = 0x1400
Global Const $LOCALE_CUSTOM_UNSPECIFIED = 0x1000

Global Const $LOCALE_INVARIANT = 0x007F
Global Const $LOCALE_SYSTEM_DEFAULT = 0x0800
Global Const $LOCALE_USER_DEFAULT = 0x0400

; ===============================================================================================================================
; _WinAPI_GetModuleHandleEx()
; ===============================================================================================================================

Global Const $GET_MODULE_HANDLE_EX_FLAG_FROM_ADDRESS = 0x00000004
Global Const $GET_MODULE_HANDLE_EX_FLAG_PIN = 0x00000001
Global Const $GET_MODULE_HANDLE_EX_FLAG_UNCHANGED_REFCOUNT = 0x00000002
Global Const $GET_MODULE_HANDLE_EX_FLAG_DEFAULT = 0x00000000

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
; _WinAPI_GetSystemInfo()
; ===============================================================================================================================

Global Const $PROCESSOR_ARCHITECTURE_AMD64 = 9
Global Const $PROCESSOR_ARCHITECTURE_IA64 = 6
Global Const $PROCESSOR_ARCHITECTURE_INTEL = 0
Global Const $PROCESSOR_ARCHITECTURE_UNKNOWN = 0xFFFF

Global Const $PROCESSOR_INTEL_386 = 386
Global Const $PROCESSOR_INTEL_486 = 486
Global Const $PROCESSOR_INTEL_PENTIUM = 586
Global Const $PROCESSOR_INTEL_IA64 = 2200
Global Const $PROCESSOR_AMD_X8664 = 8664

; ===============================================================================================================================
; _WinAPI_GetTextAlign(), _WinAPI_SetTextAlign()
; ===============================================================================================================================

Global Const $TA_BASELINE = 0x0018
Global Const $TA_BOTTOM = 0x0008
Global Const $TA_TOP = 0x0000
Global Const $TA_CENTER = 0x0006
Global Const $TA_LEFT = 0x0000
Global Const $TA_RIGHT = 0x0002
Global Const $TA_NOUPDATECP = 0x0000
Global Const $TA_RTLREADING = 0x0100
Global Const $TA_UPDATECP = 0x0001

Global Const $VTA_BASELINE = $TA_BASELINE
Global Const $VTA_BOTTOM = $TA_RIGHT
Global Const $VTA_TOP = $TA_LEFT
Global Const $VTA_CENTER = $TA_CENTER
Global Const $VTA_LEFT = $TA_BOTTOM
Global Const $VTA_RIGHT = $TA_TOP

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
; _WinAPI_GetThemeDocumentationProperty()
; ===============================================================================================================================

Global Const $SZ_THDOCPROP_AUTHOR = 'Author'
Global Const $SZ_THDOCPROP_CANONICALNAME = 'ThemeName'
Global Const $SZ_THDOCPROP_DISPLAYNAME = 'DisplayName'
Global Const $SZ_THDOCPROP_TOOLTIP = 'ToolTip'

; ===============================================================================================================================
; _WinAPI_GetThemePartSize()
; ===============================================================================================================================

Global Const $TS_MIN = 0
Global Const $TS_TRUE = 1
Global Const $TS_DRAW = 2

; ===============================================================================================================================
; _WinAPI_GetTimeFormat()
; ===============================================================================================================================

Global Const $TIME_FORCE24HOURFORMAT = 0x08
Global Const $TIME_NOMINUTESORSECONDS = 0x01
Global Const $TIME_NOSECONDS = 0x02
Global Const $TIME_NOTIMEMARKER = 0x04

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
; _WinAPI_GetWindowLongEx(), _WinAPI_SetWindowLongEx()
; ===============================================================================================================================

; *Included in Constants.au3

#cs

Global Const $GWL_EXSTYLE = -20
Global Const $GWL_HINSTANCE = -6
Global Const $GWL_HWNDPARENT = -8
Global Const $GWL_ID = -12
Global Const $GWL_STYLE = -16
Global Const $GWL_USERDATA = -21
Global Const $GWL_WNDPROC = -4

#ce

; ===============================================================================================================================
; _WinAPI_IsNetworkAlive()
; ===============================================================================================================================

Global Const $NETWORK_ALIVE_LAN = 0x01
Global Const $NETWORK_ALIVE_WAN = 0x02
Global Const $NETWORK_ALIVE_AOL = 0x04

; ===============================================================================================================================
; _WinAPI_IsProcessorFeaturePresent()
; ===============================================================================================================================

Global Const $PF_3DNOW_INSTRUCTIONS_AVAILABLE = 7
Global Const $PF_CHANNELS_ENABLED = 16
Global Const $PF_COMPARE_EXCHANGE_DOUBLE = 2
Global Const $PF_COMPARE_EXCHANGE128 = 14
Global Const $PF_COMPARE64_EXCHANGE128 = 15
Global Const $PF_FLOATING_POINT_EMULATED = 1
Global Const $PF_FLOATING_POINT_PRECISION_ERRATA = 0
Global Const $PF_MMX_INSTRUCTIONS_AVAILABLE = 3
Global Const $PF_NX_ENABLED = 12
Global Const $PF_PAE_ENABLED = 9
Global Const $PF_RDTSC_INSTRUCTION_AVAILABLE = 8
Global Const $PF_SSE3_INSTRUCTIONS_AVAILABLE = 13
Global Const $PF_XMMI_INSTRUCTIONS_AVAILABLE = 6
Global Const $PF_XMMI64_INSTRUCTIONS_AVAILABLE = 10
Global Const $PF_XSAVE_ENABLED = 17

; ===============================================================================================================================
; _WinAPI_IsValidLocale()
; ===============================================================================================================================

Global Const $LCID_INSTALLED = 1
Global Const $LCID_SUPPORTED = 2

; ===============================================================================================================================
; _WinAPI_Keybd_Event()
; ===============================================================================================================================

Global Const $KEYEVENTF_EXTENDEDKEY = 0x01
Global Const $KEYEVENTF_KEYUP = 0x02

; ===============================================================================================================================
; _WinAPI_Keybd_Event() and similar
; ===============================================================================================================================

; *Included (some) in Constants.au3

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

; *Included in Constants.au3

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
; _WinAPI_LoadIconWithScaleDown()
; ===============================================================================================================================

; *Included in Constants.au3

#cs

Global Const $IDI_APPLICATION = 32512
Global Const $IDI_ASTERISK = 32516
Global Const $IDI_EXCLAMATION = 32515
Global Const $IDI_HAND = 32513
Global Const $IDI_QUESTION = 32514
Global Const $IDI_SHIELD = 32518
Global Const $IDI_WINLOGO = 32517
Global Const $IDI_ERROR = $IDI_HAND
Global Const $IDI_INFORMATION = $IDI_ASTERISK
Global Const $IDI_WARNING = $IDI_EXCLAMATION

#ce

; ===============================================================================================================================
; _WinAPI_LookupPrivilegeValue()
; ===============================================================================================================================

; *Included in SecurityConstants.au3

#cs

Global Const $SE_ASSIGNPRIMARYTOKEN_NAME = 'SeAssignPrimaryTokenPrivilege'
Global Const $SE_AUDIT_NAME = 'SeAuditPrivilege'
Global Const $SE_BACKUP_NAME = 'SeBackupPrivilege'
Global Const $SE_CHANGE_NOTIFY_NAME = 'SeChangeNotifyPrivilege'
Global Const $SE_CREATE_GLOBAL_NAME = 'SeCreateGlobalPrivilege'
Global Const $SE_CREATE_PAGEFILE_NAME = 'SeCreatePagefilePrivilege'
Global Const $SE_CREATE_PERMANENT_NAME = 'SeCreatePermanentPrivilege'
Global Const $SE_CREATE_SYMBOLIC_LINK_NAME = 'SeCreateSymbolicLinkPrivilege'
Global Const $SE_CREATE_TOKEN_NAME = 'SeCreateTokenPrivilege'
Global Const $SE_DEBUG_NAME = 'SeDebugPrivilege'
Global Const $SE_ENABLE_DELEGATION_NAME = 'SeEnableDelegationPrivilege'
Global Const $SE_IMPERSONATE_NAME = 'SeImpersonatePrivilege'
Global Const $SE_INC_BASE_PRIORITY_NAME = 'SeIncreaseBasePriorityPrivilege'
Global Const $SE_INCREASE_QUOTA_NAME = 'SeIncreaseQuotaPrivilege'
Global Const $SE_INC_WORKING_SET_NAME = 'SeIncreaseWorkingSetPrivilege'
Global Const $SE_LOAD_DRIVER_NAME = 'SeLoadDriverPrivilege'
Global Const $SE_LOCK_MEMORY_NAME = 'SeLockMemoryPrivilege'
Global Const $SE_MACHINE_ACCOUNT_NAME = 'SeMachineAccountPrivilege'
Global Const $SE_MANAGE_VOLUME_NAME = 'SeManageVolumePrivilege'
Global Const $SE_PROF_SINGLE_PROCESS_NAME = 'SeProfileSingleProcessPrivilege'
Global Const $SE_RELABEL_NAME = 'SeRelabelPrivilege'
Global Const $SE_REMOTE_SHUTDOWN_NAME = 'SeRemoteShutdownPrivilege'
Global Const $SE_RESTORE_NAME = 'SeRestorePrivilege'
Global Const $SE_SECURITY_NAME = 'SeSecurityPrivilege'
Global Const $SE_SHUTDOWN_NAME = 'SeShutdownPrivilege'
Global Const $SE_SYNC_AGENT_NAME = 'SeSyncAgentPrivilege'
Global Const $SE_SYSTEM_ENVIRONMENT_NAME = 'SeSystemEnvironmentPrivilege'
Global Const $SE_SYSTEM_PROFILE_NAME = 'SeSystemProfilePrivilege'
Global Const $SE_SYSTEMTIME_NAME = 'SeSystemtimePrivilege'
Global Const $SE_TAKE_OWNERSHIP_NAME = 'SeTakeOwnershipPrivilege'
Global Const $SE_TCB_NAME = 'SeTcbPrivilege'
Global Const $SE_TIME_ZONE_NAME = 'SeTimeZonePrivilege'
Global Const $SE_TRUSTED_CREDMAN_ACCESS_NAME = 'SeTrustedCredManAccessPrivilege'
Global Const $SE_UNDOCK_NAME = 'SeUndockPrivilege'
Global Const $SE_UNSOLICITED_INPUT_NAME = 'SeUnsolicitedInputPrivilege'

#ce

; ===============================================================================================================================
; _WinAPI_MessageBoxCheck(), _WinAPI_MessageBoxIndirect()
; ===============================================================================================================================

; *Included (some) in Constants.au3

#cs

Global Const $MB_ABORTRETRYIGNORE = 0x00000002
Global Const $MB_CANCELTRYCONTINUE = 0x00000006
Global Const $MB_HELP = 0x00004000
Global Const $MB_OK = 0x00000000
Global Const $MB_OKCANCEL = 0x00000001
Global Const $MB_RETRYCANCEL = 0x00000005
Global Const $MB_YESNO = 0x00000004
Global Const $MB_YESNOCANCEL = 0x00000003

Global Const $MB_ICONEXCLAMATION = 0x00000030
Global Const $MB_ICONWARNING = 0x00000030
Global Const $MB_ICONINFORMATION = 0x00000040
Global Const $MB_ICONASTERISK = 0x00000040
Global Const $MB_ICONQUESTION = 0x00000020
Global Const $MB_ICONSTOP = 0x00000010
Global Const $MB_ICONERROR = 0x00000010
Global Const $MB_ICONHAND = 0x00000010
Global Const $MB_USERICON = 0x00000080

Global Const $MB_DEFBUTTON1 = 0x00000000
Global Const $MB_DEFBUTTON2 = 0x00000100
Global Const $MB_DEFBUTTON3 = 0x00000200
Global Const $MB_DEFBUTTON4 = 0x00000300

Global Const $MB_APPLMODAL = 0x00000000
Global Const $MB_SYSTEMMODAL = 0x00001000
Global Const $MB_TASKMODAL = 0x00002000

Global Const $MB_DEFAULT_DESKTOP_ONLY = 0x00020000
Global Const $MB_RIGHT = 0x00080000
Global Const $MB_RTLREADING = 0x00100000
Global Const $MB_SETFOREGROUND = 0x00010000L
Global Const $MB_TOPMOST = 0x00040000
Global Const $MB_SERVICE_NOTIFICATION = 0x00200000

Global Const $IDABORT = 3
Global Const $IDCANCEL = 2
Global Const $IDCONTINUE = 11
Global Const $IDIGNORE = 5
Global Const $IDNO = 7
Global Const $IDOK = 1
Global Const $IDRETRY = 4
Global Const $IDTRYAGAIN = 10
Global Const $IDYES = 6

#ce

; ===============================================================================================================================
; _WinAPI_OpenMutex()
; ===============================================================================================================================

Global Const $MUTEX_ALL_ACCESS = 0x001F0001
Global Const $MUTEX_MODIFY_STATE = 0x00000001

; ===============================================================================================================================
; _WinAPI_OpenJobObject(), _WinAPI_QueryInformationJobObject(), _WinAPI_SetInformationJobObject()
; ===============================================================================================================================

Global Const $JOB_OBJECT_ALL_ACCESS = 0x001F001F
Global Const $JOB_OBJECT_ASSIGN_PROCESS = 0x00000001
Global Const $JOB_OBJECT_QUERY = 0x00000004
Global Const $JOB_OBJECT_SET_ATTRIBUTES = 0x00000002
Global Const $JOB_OBJECT_SET_SECURITY_ATTRIBUTES = 0x00000010
Global Const $JOB_OBJECT_TERMINATE = 0x00000008

Global Const $JOB_OBJECT_LIMIT_ACTIVE_PROCESS = 0x00000008
Global Const $JOB_OBJECT_LIMIT_AFFINITY = 0x00000010
Global Const $JOB_OBJECT_LIMIT_BREAKAWAY_OK = 0x00000800
Global Const $JOB_OBJECT_LIMIT_DIE_ON_UNHANDLED_EXCEPTION = 0x00000400
Global Const $JOB_OBJECT_LIMIT_JOB_MEMORY = 0x00000200
Global Const $JOB_OBJECT_LIMIT_JOB_TIME = 0x00000004
Global Const $JOB_OBJECT_LIMIT_KILL_ON_JOB_CLOSE = 0x00002000
Global Const $JOB_OBJECT_LIMIT_PRESERVE_JOB_TIME = 0x00000040
Global Const $JOB_OBJECT_LIMIT_PRIORITY_CLASS = 0x00000020
Global Const $JOB_OBJECT_LIMIT_PROCESS_MEMORY = 0x00000100
Global Const $JOB_OBJECT_LIMIT_PROCESS_TIME = 0x00000002
Global Const $JOB_OBJECT_LIMIT_SCHEDULING_CLASS = 0x00000080
Global Const $JOB_OBJECT_LIMIT_SILENT_BREAKAWAY_OK = 0x00001000
Global Const $JOB_OBJECT_LIMIT_WORKINGSET = 0x00000001

Global Const $JOB_OBJECT_UILIMIT_DESKTOP = 0x00000040
Global Const $JOB_OBJECT_UILIMIT_DISPLAYSETTINGS = 0x00000010
Global Const $JOB_OBJECT_UILIMIT_EXITWINDOWS = 0x00000080
Global Const $JOB_OBJECT_UILIMIT_GLOBALATOMS = 0x00000020
Global Const $JOB_OBJECT_UILIMIT_HANDLES = 0x00000001
Global Const $JOB_OBJECT_UILIMIT_READCLIPBOARD = 0x00000002
Global Const $JOB_OBJECT_UILIMIT_SYSTEMPARAMETERS = 0x00000008
Global Const $JOB_OBJECT_UILIMIT_WRITECLIPBOARD = 0x00000004

Global Const $JOB_OBJECT_SECURITY_FILTER_TOKENS = 0x00000008
Global Const $JOB_OBJECT_SECURITY_NO_ADMIN = 0x00000001
Global Const $JOB_OBJECT_SECURITY_ONLY_TOKEN = 0x00000004
Global Const $JOB_OBJECT_SECURITY_RESTRICTED_TOKEN = 0x00000002

Global Const $JOB_OBJECT_TERMINATE_AT_END_OF_JOB = 0
Global Const $JOB_OBJECT_POST_AT_END_OF_JOB = 1

; ===============================================================================================================================
; _WinAPI_OpenProcessToken()
; ===============================================================================================================================

; *Included in SecurityConstants.au3

#cs

Global Const $TOKEN_ADJUST_DEFAULT = 0x00000080
Global Const $TOKEN_ADJUST_GROUPS = 0x00000040
Global Const $TOKEN_ADJUST_PRIVILEGES = 0x00000020
Global Const $TOKEN_ADJUST_SESSIONID = 0x00000100
Global Const $TOKEN_ASSIGN_PRIMARY = 0x00000001
Global Const $TOKEN_DUPLICATE = 0x00000002
Global Const $TOKEN_EXECUTE = 0x00020000
Global Const $TOKEN_IMPERSONATE = 0x00000004
Global Const $TOKEN_QUERY = 0x00000008
Global Const $TOKEN_QUERY_SOURCE = 0x00000010
Global Const $TOKEN_READ = 0x00020008
Global Const $TOKEN_WRITE = 0x000200E0
Global Const $TOKEN_ALL_ACCESS = 0x000F01FF

#ce

; ===============================================================================================================================
; _WinAPI_OpenSemaphore()
; ===============================================================================================================================

Global Const $SEMAPHORE_ALL_ACCESS = 0x001F0003
Global Const $SEMAPHORE_MODIFY_STATE = 0x00000002

; ===============================================================================================================================
; _WinAPI_PatBlt(), _WinAPI_StretchBlt()
; ===============================================================================================================================

; *Included in WindowsConstants.au3

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
; _WinAPI_PathGetCharType()
; ===============================================================================================================================

Global Const $GCT_INVALID = 0x00
Global Const $GCT_LFNCHAR = 0x01
Global Const $GCT_SEPARATOR = 0x08
Global Const $GCT_SHORTCHAR = 0x02
Global Const $GCT_WILD = 0x04

; ===============================================================================================================================
; _WinAPI_PlaySound()
; ===============================================================================================================================

Global Const $SND_APPLICATION = 0x00000080
Global Const $SND_ALIAS = 0x00010000
Global Const $SND_ALIAS_ID = 0x00110000
Global Const $SND_ASYNC = 0x00000001
Global Const $SND_FILENAME = 0x00020000
Global Const $SND_LOOP = 0x00000008
Global Const $SND_MEMORY = 0x00000004
Global Const $SND_NODEFAULT = 0x00000002
Global Const $SND_NOSTOP = 0x00000010
Global Const $SND_NOWAIT = 0x00002000
Global Const $SND_PURGE = 0x00000040
Global Const $SND_RESOURCE = 0x00040004
Global Const $SND_SYNC = 0x00000000

; *Windows Vista or later
Global Const $SND_SENTRY = 0x00080000
Global Const $SND_SYSTEM = 0x00200000

Global Const $SND_ALIAS_SYSTEMASTERISK = 'SystemAsterisk'
Global Const $SND_ALIAS_SYSTEMDEFAULT = 'SystemDefault'
Global Const $SND_ALIAS_SYSTEMEXCLAMATION = 'SystemExclamation'
Global Const $SND_ALIAS_SYSTEMEXIT = 'SystemExit'
Global Const $SND_ALIAS_SYSTEMHAND = 'SystemHand'
Global Const $SND_ALIAS_SYSTEMQUESTION = 'SystemQuestion'
Global Const $SND_ALIAS_SYSTEMSTART = 'SystemStart'
Global Const $SND_ALIAS_SYSTEMWELCOME = 'SystemWelcome'

; ===============================================================================================================================
; _WinAPI_PolyDraw()
; ===============================================================================================================================

Global Const $PT_BEZIERTO = 4
Global Const $PT_LINETO = 2
Global Const $PT_MOVETO = 6
Global Const $PT_CLOSEFIGURE = 1

; ===============================================================================================================================
; _WinAPI_RegisterHotKey()
; ===============================================================================================================================

Global Const $MOD_ALT = 0x0001
Global Const $MOD_CONTROL = 0x0002
Global Const $MOD_SHIFT = 0x0004
Global Const $MOD_WIN = 0x0008

; *Windows 7 or later
Global Const $MOD_NOREPEAT = 0x4000

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
; _WinAPI_Reg...
; ===============================================================================================================================

Global Const $HKEY_CLASSES_ROOT = 0x80000000
Global Const $HKEY_CURRENT_CONFIG = 0x80000005
Global Const $HKEY_CURRENT_USER = 0x80000001
Global Const $HKEY_LOCAL_MACHINE = 0x80000002
Global Const $HKEY_PERFORMANCE_DATA = 0x80000004
Global Const $HKEY_PERFORMANCE_NLSTEXT = 0x80000060
Global Const $HKEY_PERFORMANCE_TEXT = 0x80000050
Global Const $HKEY_USERS = 0x80000003

Global Const $KEY_ALL_ACCESS = 0xF003F
Global Const $KEY_CREATE_LINK = 0x0020
Global Const $KEY_CREATE_SUB_KEY = 0x0004
Global Const $KEY_ENUMERATE_SUB_KEYS = 0x0008
Global Const $KEY_EXECUTE = 0x20019
Global Const $KEY_NOTIFY = 0x0010
Global Const $KEY_QUERY_VALUE = 0x0001
Global Const $KEY_READ = 0x20019
Global Const $KEY_SET_VALUE = 0x0002
Global Const $KEY_WOW64_32KEY = 0x0200
Global Const $KEY_WOW64_64KEY = 0x0100
Global Const $KEY_WRITE = 0x20006

Global Const $REG_NOTIFY_CHANGE_NAME = 0x01
Global Const $REG_NOTIFY_CHANGE_ATTRIBUTES = 0x02
Global Const $REG_NOTIFY_CHANGE_LAST_SET = 0x04
Global Const $REG_NOTIFY_CHANGE_SECURITY = 0x08

Global Const $REG_OPTION_BACKUP_RESTORE = 0x04
Global Const $REG_OPTION_CREATE_LINK = 0x02
Global Const $REG_OPTION_NON_VOLATILE = 0x00
Global Const $REG_OPTION_VOLATILE = 0x01

; *Included in Constants.au3

#cs

Global Const $REG_BINARY = 3
Global Const $REG_DWORD = 4
Global Const $REG_DWORD_BIG_ENDIAN = 5
Global Const $REG_DWORD_LITTLE_ENDIAN = 4
Global Const $REG_EXPAND_SZ = 2
Global Const $REG_LINK = 6
Global Const $REG_MULTI_SZ = 7
Global Const $REG_NONE = 0
Global Const $REG_QWORD = 11
Global Const $REG_QWORD_LITTLE_ENDIAN = 11
Global Const $REG_SZ = 1

#ce

; ===============================================================================================================================
; _WinAPI_ReplaceFile()
; ===============================================================================================================================

Global Const $REPLACEFILE_WRITE_THROUGH = 0x01
Global Const $REPLACEFILE_IGNORE_MERGE_ERRORS = 0x02
Global Const $REPLACEFILE_IGNORE_ACL_ERRORS = 0x04

; ===============================================================================================================================
; _WinAPI_ResizeBitmap(), _WinAPI_SetStretchBltMode()
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
; _WinAPI_RestartDlg()
; ===============================================================================================================================

Global Const $EWX_LOGOFF = 0
Global Const $EWX_POWEROFF = 8
Global Const $EWX_REBOOT = 2
Global Const $EWX_SHUTDOWN = 1
Global Const $EWX_FORCE = 4
Global Const $EWX_FORCEIFHUNG = 16

; ===============================================================================================================================
; _WinAPI_SendMessageTimeout()
; ===============================================================================================================================

Global Const $SMTO_BLOCK = 0x0001
Global Const $SMTO_NORMAL = 0x0000
Global Const $SMTO_ABORTIFHUNG = 0x0002
Global Const $SMTO_NOTIMEOUTIFNOTHUNG = 0x0008
Global Const $SMTO_ERRORONEXIT = 0x0020

; ===============================================================================================================================
; _WinAPI_SetKeyboardLayout()
; ===============================================================================================================================

Global Const $INPUTLANGCHANGE_BACKWARD = 0x0004
Global Const $INPUTLANGCHANGE_FORWARD = 0x0002
Global Const $INPUTLANGCHANGE_SYSCHARSET = 0x0001

; ===============================================================================================================================
; _WinAPI_SetSystemCursor()
; ===============================================================================================================================

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

; ===============================================================================================================================
; _WinAPI_ShellChangeNotify()
; ===============================================================================================================================

Global Const $SHCNE_ALLEVENTS = 0x7FFFFFFF
Global Const $SHCNE_ASSOCCHANGED = 0x8000000
Global Const $SHCNE_ATTRIBUTES = 0x00000800
Global Const $SHCNE_CREATE = 0x00000002
Global Const $SHCNE_DELETE = 0x00000004
Global Const $SHCNE_DRIVEADD = 0x00000100
Global Const $SHCNE_DRIVEADDGUI = 0x00010000
Global Const $SHCNE_DRIVEREMOVED = 0x00000080
Global Const $SHCNE_EXTENDED_EVENT = 0x04000000
Global Const $SHCNE_FREESPACE = 0x00040000
Global Const $SHCNE_MEDIAINSERTED = 0x00000020
Global Const $SHCNE_MEDIAREMOVED = 0x00000040
Global Const $SHCNE_MKDIR = 0x00000008
Global Const $SHCNE_NETSHARE = 0x00000200
Global Const $SHCNE_NETUNSHARE = 0x00000400
Global Const $SHCNE_RENAMEFOLDER = 0x00020000
Global Const $SHCNE_RENAMEITEM = 0x00000001
Global Const $SHCNE_RMDIR = 0x00000010
Global Const $SHCNE_SERVERDISCONNECT = 0x00004000
Global Const $SHCNE_UPDATEDIR = 0x00001000
Global Const $SHCNE_UPDATEIMAGE = 0x00008000
Global Const $SHCNE_UPDATEITEM = 0x00002000
Global Const $SHCNE_DISKEVENTS = 0x0002381F
Global Const $SHCNE_GLOBALEVENTS = 0x0C0581E0
Global Const $SHCNE_INTERRUPT = 0x80000000

Global Const $SHCNF_DWORD = 0x00000003
Global Const $SHCNF_IDLIST = 0x00000000
Global Const $SHCNF_PATH = 0x00000001
Global Const $SHCNF_PRINTER = 0x00000002
Global Const $SHCNF_FLUSH = 0x00001000
Global Const $SHCNF_FLUSHNOWAIT = 0x00002000
Global Const $SHCNF_NOTIFYRECURSIVE = 0x00010000

; ===============================================================================================================================
; _WinAPI_ShellChangeNotifyRegister()
; ===============================================================================================================================

Global Const $SHCNRF_INTERRUPTLEVEL = 0x0001
Global Const $SHCNRF_SHELLLEVEL = 0x0002
Global Const $SHCNRF_RECURSIVEINTERRUPT = 0x1000
Global Const $SHCNRF_NEWDELIVERY = 0x8000

; ===============================================================================================================================
; _WinAPI_ShellEmptyRecycleBin()
; ===============================================================================================================================

Global Const $SHERB_NOCONFIRMATION = 0x01
Global Const $SHERB_NOPROGRESSUI = 0x02
Global Const $SHERB_NOSOUND = 0x04
Global Const $SHERB_NO_UI = BitOR($SHERB_NOCONFIRMATION, $SHERB_NOPROGRESSUI, $SHERB_NOSOUND)

; ===============================================================================================================================
; _WinAPI_ShellFileOperation()
; ===============================================================================================================================

Global Const $FO_COPY = 2
Global Const $FO_DELETE = 3
Global Const $FO_MOVE = 1
Global Const $FO_RENAME = 4

Global Const $FOF_ALLOWUNDO = 0x0040
Global Const $FOF_CONFIRMMOUSE = 0x0002
Global Const $FOF_FILESONLY = 0x0080
Global Const $FOF_MULTIDESTFILES = 0x0001
Global Const $FOF_NOCONFIRMATION = 0x0010
Global Const $FOF_NOCONFIRMMKDIR = 0x0200
Global Const $FOF_NO_CONNECTED_ELEMENTS = 0x2000
Global Const $FOF_NOCOPYSECURITYATTRIBS = 0x0800
Global Const $FOF_NOERRORUI = 0x0400
Global Const $FOF_NORECURSEREPARSE = 0x8000
Global Const $FOF_NORECURSION = 0x1000
Global Const $FOF_RENAMEONCOLLISION = 0x0008
Global Const $FOF_SILENT = 0x0004
Global Const $FOF_SIMPLEPROGRESS = 0x0100
Global Const $FOF_WANTMAPPINGHANDLE = 0x0020
Global Const $FOF_WANTNUKEWARNING = 0x4000
Global Const $FOF_NO_UI = BitOR($FOF_NOCONFIRMATION, $FOF_NOCONFIRMMKDIR, $FOF_NOERRORUI, $FOF_SILENT)

; ===============================================================================================================================
; _WinAPI_ShellGetFileInfo()
; ===============================================================================================================================

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
; _WinAPI_ShellGetKnownFolderPath()
; ===============================================================================================================================

Global Const $FOLDERID_AddNewPrograms = '{DE61D971-5EBC-4F02-A3A9-6C82895E5C04}'
Global Const $FOLDERID_AdminTools = '{724EF170-A42D-4FEF-9F26-B60E846FBA4F}'
Global Const $FOLDERID_AppUpdates = '{A305CE99-F527-492B-8B1A-7E76FA98D6E4}'
Global Const $FOLDERID_CDBurning = '{9E52AB10-F80D-49DF-ACB8-4330F5687855}'
Global Const $FOLDERID_ChangeRemovePrograms = '{DF7266AC-9274-4867-8D55-3BD661DE872D}'
Global Const $FOLDERID_CommonAdminTools = '{D0384E7D-BAC3-4797-8F14-CBA229B392B5}'
Global Const $FOLDERID_CommonOEMLinks = '{C1BAE2D0-10DF-4334-BEDD-7AA20B227A9D}'
Global Const $FOLDERID_CommonPrograms = '{0139D44E-6AFE-49F2-8690-3DAFCAE6FFB8}'
Global Const $FOLDERID_CommonStartMenu = '{A4115719-D62E-491D-AA7C-E74B8BE3B067}'
Global Const $FOLDERID_CommonStartup = '{82A5EA35-D9CD-47C5-9629-E15D2F714E6E}'
Global Const $FOLDERID_CommonTemplates = '{B94237E7-57AC-4347-9151-B08C6C32D1F7}'
Global Const $FOLDERID_ComputerFolder = '{0AC0837C-BBF8-452A-850D-79D08E667CA7}'
Global Const $FOLDERID_ConflictFolder = '{4BFEFB45-347D-4006-A5BE-AC0CB0567192}'
Global Const $FOLDERID_ConnectionsFolder = '{6F0CD92B-2E97-45D1-88FF-B0D186B8DEDD}'
Global Const $FOLDERID_Contacts = '{56784854-C6CB-462B-8169-88E350ACB882}'
Global Const $FOLDERID_ControlPanelFolder = '{82A74AEB-AEB4-465C-A014-D097EE346D63}'
Global Const $FOLDERID_Cookies = '{2B0F765D-C0E9-4171-908E-08A611B84FF6}'
Global Const $FOLDERID_Desktop = '{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}'
Global Const $FOLDERID_DeviceMetadataStore = '{5CE4A5E9-E4EB-479D-B89F-130C02886155}'
Global Const $FOLDERID_DocumentsLibrary = '{7B0DB17D-9CD2-4A93-9733-46CC89022E7C}'
Global Const $FOLDERID_Downloads = '{374DE290-123F-4565-9164-39C4925E467B}'
Global Const $FOLDERID_Favorites = '{1777F761-68AD-4D8A-87BD-30B759FA33DD}'
Global Const $FOLDERID_Fonts = '{FD228CB7-AE11-4AE3-864C-16F3910AB8FE}'
Global Const $FOLDERID_Games = '{CAC52C1A-B53D-4EDC-92D7-6B2E8AC19434}'
Global Const $FOLDERID_GameTasks = '{054FAE61-4DD8-4787-80B6-090220C4B700}'
Global Const $FOLDERID_History = '{D9DC8A3B-B784-432E-A781-5A1130A75963}'
Global Const $FOLDERID_HomeGroup = '{52528A6B-B9E3-4ADD-B60D-588C2DBA842D}'
Global Const $FOLDERID_ImplicitAppShortcuts = '{BCB5256F-79F6-4CEE-B725-DC34E402FD46}'
Global Const $FOLDERID_InternetCache = '{352481E8-33BE-4251-BA85-6007CAEDCF9D}'
Global Const $FOLDERID_InternetFolder = '{4D9F7874-4E0C-4904-967B-40B0D20C3E4B}'
Global Const $FOLDERID_Libraries = '{1B3EA5DC-B587-4786-B4EF-BD1DC332AEAE}'
Global Const $FOLDERID_Links = '{BFB9D5E0-C6A9-404C-B2B2-AE6DB6AF4968}'
Global Const $FOLDERID_LocalAppData = '{F1B32785-6FBA-4FCF-9D55-7B8E7F157091}'
Global Const $FOLDERID_LocalAppDataLow = '{A520A1A4-1780-4FF6-BD18-167343C5AF16}'
Global Const $FOLDERID_LocalizedResourcesDir = '{2A00375E-224C-49DE-B8D1-440DF7EF3DDC}'
Global Const $FOLDERID_Music = '{4BD8D571-6D19-48D3-BE97-422220080E43}'
Global Const $FOLDERID_MusicLibrary = '{2112AB0A-C86A-4FFE-A368-0DE96E47012E}'
Global Const $FOLDERID_NetHood = '{C5ABBF53-E17F-4121-8900-86626FC2C973}'
Global Const $FOLDERID_NetworkFolder = '{D20BEEC4-5CA8-4905-AE3B-BF251EA09B53}'
Global Const $FOLDERID_OriginalImages = '{2C36C0AA-5812-4B87-BFD0-4CD0DFB19B39}'
Global Const $FOLDERID_PhotoAlbums = '{69D2CF90-FC33-4FB7-9A0C-EBB0F0FCB43C}'
Global Const $FOLDERID_PicturesLibrary = '{A990AE9F-A03B-4E80-94BC-9912D7504104}'
Global Const $FOLDERID_Pictures = '{33E28130-4E1E-4676-835A-98395C3BC3BB}'
Global Const $FOLDERID_Playlists = '{DE92C1C7-837F-4F69-A3BB-86E631204A23}'
Global Const $FOLDERID_PrintersFolder = '{76FC4E2D-D6AD-4519-A663-37BD56068185}'
Global Const $FOLDERID_PrintHood = '{9274BD8D-CFD1-41C3-B35E-B13F55A758F4}'
Global Const $FOLDERID_Profile = '{5E6C858F-0E22-4760-9AFE-EA3317B67173}'
Global Const $FOLDERID_ProgramData = '{62AB5D82-FDC1-4DC3-A9DD-070D1D495D97}'
Global Const $FOLDERID_ProgramFiles = '{905E63B6-C1BF-494E-B29C-65B732D3D21A}'
Global Const $FOLDERID_ProgramFilesX64 = '{6D809377-6AF0-444B-8957-A3773F02200E}'
Global Const $FOLDERID_ProgramFilesX86 = '{7C5A40EF-A0FB-4BFC-874A-C0F2E0B9FA8E}'
Global Const $FOLDERID_ProgramFilesCommon = '{F7F1ED05-9F6D-47A2-AAAE-29D317C6F066}'
Global Const $FOLDERID_ProgramFilesCommonX64 = '{6365D5A7-0F0D-45E5-87F6-0DA56B6A4F7D}'
Global Const $FOLDERID_ProgramFilesCommonX86 = '{DE974D24-D9C6-4D3E-BF91-F4455120B917}'
Global Const $FOLDERID_Programs = '{A77F5D77-2E2B-44C3-A6A2-ABA601054A51}'
Global Const $FOLDERID_Public = '{DFDF76A2-C82A-4D63-906A-5644AC457385}'
Global Const $FOLDERID_PublicDesktop = '{C4AA340D-F20F-4863-AFEF-F87EF2E6BA25}'
Global Const $FOLDERID_PublicDocuments = '{ED4824AF-DCE4-45A8-81E2-FC7965083634}'
Global Const $FOLDERID_PublicDownloads = '{3D644C9B-1FB8-4F30-9B45-F670235F79C0}'
Global Const $FOLDERID_PublicGameTasks = '{DEBF2536-E1A8-4C59-B6A2-414586476AEA}'
Global Const $FOLDERID_PublicLibraries = '{48DAF80B-E6CF-4F4E-B800-0E69D84EE384}'
Global Const $FOLDERID_PublicMusic = '{3214FAB5-9757-4298-BB61-92A9DEAA44FF}'
Global Const $FOLDERID_PublicPictures = '{B6EBFB86-6907-413C-9AF7-4FC2ABF07CC5}'
Global Const $FOLDERID_PublicRingtones = '{E555AB60-153B-4D17-9F04-A5FE99FC15EC}'
Global Const $FOLDERID_PublicVideos = '{2400183A-6185-49FB-A2D8-4A392A602BA3}'
Global Const $FOLDERID_QuickLaunch = '{52A4F021-7B75-48A9-9F6B-4B87A210BC8F}'
Global Const $FOLDERID_Recent = '{AE50C081-EBD2-438A-8655-8A092E34987A}'
Global Const $FOLDERID_RecordedTVLibrary = '{1A6FDBA2-F42D-4358-A798-B74D745926C5}'
Global Const $FOLDERID_RecycleBinFolder = '{B7534046-3ECB-4C18-BE4E-64CD4CB7D6AC}'
Global Const $FOLDERID_ResourceDir = '{8AD10C31-2ADB-4296-A8F7-E4701232C972}'
Global Const $FOLDERID_Ringtones = '{C870044B-F49E-4126-A9C3-B52A1FF411E8}'
Global Const $FOLDERID_RoamingAppData = '{3EB685DB-65F9-4CF6-A03A-E3EF65729F3D}'
Global Const $FOLDERID_SampleMusic = '{B250C668-F57D-4EE1-A63C-290EE7D1AA1F}'
Global Const $FOLDERID_SamplePictures = '{C4900540-2379-4C75-844B-64E6FAF8716B}'
Global Const $FOLDERID_SamplePlaylists = '{15CA69B3-30EE-49C1-ACE1-6B5EC372AFB5}'
Global Const $FOLDERID_SampleVideos = '{859EAD94-2E85-48AD-A71A-0969CB56A6CD}'
Global Const $FOLDERID_SavedGames = '{4C5C32FF-BB9D-43B0-B5B4-2D72E54EAAA4}'
Global Const $FOLDERID_SavedSearches = '{7D1D3A04-DEBB-4115-95CF-2F29DA2920DA}'
Global Const $FOLDERID_SEARCH_CSC = '{EE32E446-31CA-4ABA-814F-A5EBD2FD6D5E}'
Global Const $FOLDERID_SEARCH_MAPI = '{98EC0E18-2098-4D44-8644-66979315A281}'
Global Const $FOLDERID_SearchHome = '{190337D1-B8CA-4121-A639-6D472D16972A}'
Global Const $FOLDERID_SendTo = '{8983036C-27C0-404B-8F08-102D10DCFD74}'
Global Const $FOLDERID_SidebarDefaultParts = '{7B396E54-9EC5-4300-BE0A-2482EBAE1A26}'
Global Const $FOLDERID_SidebarParts = '{A75D362E-50FC-4FB7-AC2C-A8BEAA314493}'
Global Const $FOLDERID_StartMenu = '{625B53C3-AB48-4EC1-BA1F-A1EF4146FC19}'
Global Const $FOLDERID_Startup = '{B97D20BB-F46A-4C97-BA10-5E3608430854}'
Global Const $FOLDERID_SyncManagerFolder = '{43668BF8-C14E-49B2-97C9-747784D784B7}'
Global Const $FOLDERID_SyncResultsFolder = '{289A9A43-BE44-4057-A41B-587A76D7E7F9}'
Global Const $FOLDERID_SyncSetupFolder = '{0F214138-B1D3-4A90-BBA9-27CBC0C5389A}'
Global Const $FOLDERID_System = '{1AC14E77-02E7-4E5D-B744-2EB1AE5198B7}'
Global Const $FOLDERID_SystemX86 = '{D65231B0-B2F1-4857-A4CE-A8E7C6EA7D27}'
Global Const $FOLDERID_Templates = '{A63293E8-664E-48DB-A079-DF759E0509F7}'
Global Const $FOLDERID_UserPinned = '{9E3995AB-1F9C-4F13-B827-48B24B6C7174}'
Global Const $FOLDERID_UserProfiles = '{0762D272-C50A-4BB0-A382-697DCD729B80}'
Global Const $FOLDERID_UserProgramFiles = '{5CD7AEE2-2219-4A67-B85D-6C9CE15660CB}'
Global Const $FOLDERID_UserProgramFilesCommon = '{BCBD3057-CA5C-4622-B42D-BC56DB0AE516}'
Global Const $FOLDERID_UsersFiles = '{F3CE0F7C-4901-4ACC-8648-D5D44B04EF8F}'
Global Const $FOLDERID_UsersLibraries = '{A302545D-DEFF-464B-ABE8-61C8648D939B}'
Global Const $FOLDERID_Videos = '{18989B1D-99B5-455B-841C-AB7C74E4DDFC}'
Global Const $FOLDERID_VideosLibrary = '{491E922F-5643-4AF4-A7EB-4E7A138D8174}'
Global Const $FOLDERID_Windows = '{F38BF404-1D43-42F2-9305-67DE0B28FC23}'

Global Const $KF_FLAG_CREATE = 0x00008000
Global Const $KF_FLAG_DONT_VERIFY = 0x00004000
Global Const $KF_FLAG_DONT_UNEXPAND = 0x00002000
Global Const $KF_FLAG_NO_ALIAS = 0x00001000
Global Const $KF_FLAG_INIT = 0x00000800
Global Const $KF_FLAG_DEFAULT_PATH = 0x00000400
Global Const $KF_FLAG_NOT_PARENT_RELATIVE = 0x00000200
Global Const $KF_FLAG_SIMPLE_IDLIST = 0x00000100

; *Windows 7 or later
Global Const $KF_FLAG_ALIAS_ONLY = 0x80000000

; ===============================================================================================================================
; _WinAPI_ShellGetSetFolderCustomSettings()
; ===============================================================================================================================

Global Const $FCSM_VIEWID = 0x0001
Global Const $FCSM_WEBVIEWTEMPLATE = 0x0002
Global Const $FCSM_INFOTIP = 0x0004
Global Const $FCSM_CLSID = 0x0008
Global Const $FCSM_ICONFILE = 0x0010
Global Const $FCSM_LOGO = 0x0020
Global Const $FCSM_FLAGS = 0x0040

Global Const $FCS_READ = 0x0001
Global Const $FCS_FORCEWRITE = 0x0002
Global Const $FCS_WRITE = BitOR($FCS_READ, $FCS_FORCEWRITE)

; ===============================================================================================================================
; _WinAPI_ShellGetSettings(), _WinAPI_ShellSetSettings()
; ===============================================================================================================================

Global Const $SSF_SHOWALLOBJECTS = 0x00000001
Global Const $SSF_SHOWEXTENSIONS = 0x00000002
Global Const $SSF_SHOWCOMPCOLOR = 0x00000008
Global Const $SSF_SHOWSYSFILES = 0x00000020
Global Const $SSF_DOUBLECLICKINWEBVIEW = 0x00000080
Global Const $SSF_DESKTOPHTML = 0x00000200
Global Const $SSF_WIN95CLASSIC = 0x00000400
Global Const $SSF_DONTPRETTYPATH = 0x00000800
Global Const $SSF_MAPNETDRVBUTTON = 0x00001000
Global Const $SSF_SHOWINFOTIP = 0x00002000
Global Const $SSF_HIDEICONS = 0x00004000
Global Const $SSF_NOCONFIRMRECYCLE = 0x00008000
Global Const $SSF_WEBVIEW = 0x00020000
Global Const $SSF_SHOWSUPERHIDDEN = 0x00040000
Global Const $SSF_SEPPROCESS = 0x00080000
Global Const $SSF_NONETCRAWLING = 0x00100000
Global Const $SSF_STARTPANELON = 0x00200000

; *Windows Vista or later
Global Const $SSF_AUTOCHECKSELECT = 0x00800000
Global Const $SSF_ICONSONLY = 0x01000000
Global Const $SSF_SHOWTYPEOVERLAY = 0x02000000

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
; _WinAPI_ShellGetStockIconInfo()
; ===============================================================================================================================

Global Const $SIID_DOCNOASSOC = 0
Global Const $SIID_DOCASSOC = 1
Global Const $SIID_APPLICATION = 2
Global Const $SIID_FOLDER = 3
Global Const $SIID_FOLDEROPEN = 4
Global Const $SIID_DRIVE525 = 5
Global Const $SIID_DRIVE35 = 6
Global Const $SIID_DRIVEREMOVE = 7
Global Const $SIID_DRIVEFIXED = 8
Global Const $SIID_DRIVENET = 9
Global Const $SIID_DRIVENETDISABLED = 10
Global Const $SIID_DRIVECD = 11
Global Const $SIID_DRIVERAM = 12
Global Const $SIID_WORLD = 13
Global Const $SIID_SERVER = 15
Global Const $SIID_PRINTER = 16
Global Const $SIID_MYNETWORK = 17
Global Const $SIID_FIND = 22
Global Const $SIID_HELP = 23
Global Const $SIID_SHARE = 28
Global Const $SIID_LINK = 29
Global Const $SIID_SLOWFILE = 30
Global Const $SIID_RECYCLER = 31
Global Const $SIID_RECYCLERFULL = 32
Global Const $SIID_MEDIACDAUDIO = 40
Global Const $SIID_LOCK = 47
Global Const $SIID_AUTOLIST = 49
Global Const $SIID_PRINTERNET = 50
Global Const $SIID_SERVERSHARE = 51
Global Const $SIID_PRINTERFAX = 52
Global Const $SIID_PRINTERFAXNET = 53
Global Const $SIID_PRINTERFILE = 54
Global Const $SIID_STACK = 55
Global Const $SIID_MEDIASVCD = 56
Global Const $SIID_STUFFEDFOLDER = 57
Global Const $SIID_DRIVEUNKNOWN = 58
Global Const $SIID_DRIVEDVD = 59
Global Const $SIID_MEDIADVD = 60
Global Const $SIID_MEDIADVDRAM = 61
Global Const $SIID_MEDIADVDRW = 62
Global Const $SIID_MEDIADVDR = 63
Global Const $SIID_MEDIADVDROM = 64
Global Const $SIID_MEDIACDAUDIOPLUS = 65
Global Const $SIID_MEDIACDRW = 66
Global Const $SIID_MEDIACDR = 67
Global Const $SIID_MEDIACDBURN = 68
Global Const $SIID_MEDIABLANKCD = 69
Global Const $SIID_MEDIACDROM = 70
Global Const $SIID_AUDIOFILES = 71
Global Const $SIID_IMAGEFILES = 72
Global Const $SIID_VIDEOFILES = 73
Global Const $SIID_MIXEDFILES = 74
Global Const $SIID_FOLDERBACK = 75
Global Const $SIID_FOLDERFRONT = 76
Global Const $SIID_SHIELD = 77
Global Const $SIID_WARNING = 78
Global Const $SIID_INFO = 79
Global Const $SIID_ERROR = 80
Global Const $SIID_KEY = 81
Global Const $SIID_SOFTWARE = 82
Global Const $SIID_RENAME = 83
Global Const $SIID_DELETE = 84
Global Const $SIID_MEDIAAUDIODVD = 85
Global Const $SIID_MEDIAMOVIEDVD = 86
Global Const $SIID_MEDIAENHANCEDCD = 87
Global Const $SIID_MEDIAENHANCEDDVD = 88
Global Const $SIID_MEDIAHDDVD = 89
Global Const $SIID_MEDIABLURAY = 90
Global Const $SIID_MEDIAVCD = 91
Global Const $SIID_MEDIADVDPLUSR = 92
Global Const $SIID_MEDIADVDPLUSRW = 93
Global Const $SIID_DESKTOPPC = 94
Global Const $SIID_MOBILEPC = 95
Global Const $SIID_USERS = 96
Global Const $SIID_MEDIASMARTMEDIA = 97
Global Const $SIID_MEDIACOMPACTFLASH = 98
Global Const $SIID_DEVICECELLPHONE = 99
Global Const $SIID_DEVICECAMERA = 100
Global Const $SIID_DEVICEVIDEOCAMERA = 101
Global Const $SIID_DEVICEAUDIOPLAYER = 102
Global Const $SIID_NETWORKCONNECT = 103
Global Const $SIID_INTERNET = 104
Global Const $SIID_ZIPFILE = 105
Global Const $SIID_SETTINGS = 106
Global Const $SIID_DRIVEHDDVD = 132
Global Const $SIID_DRIVEBD = 133
Global Const $SIID_MEDIAHDDVDROM = 134
Global Const $SIID_MEDIAHDDVDR = 135
Global Const $SIID_MEDIAHDDVDRAM = 136
Global Const $SIID_MEDIABDROM = 137
Global Const $SIID_MEDIABDR = 138
Global Const $SIID_MEDIABDRE = 139
Global Const $SIID_CLUSTEREDDRIVE = 140
Global Const $SIID_MAX_ICONS = 174

Global Const $SHGSI_ICONLOCATION = 0
Global Const $SHGSI_ICON = $SHGFI_ICON
Global Const $SHGSI_SYSICONINDEX = $SHGFI_SYSICONINDEX
Global Const $SHGSI_LINKOVERLAY = $SHGFI_LINKOVERLAY
Global Const $SHGSI_SELECTED = $SHGFI_SELECTED
Global Const $SHGSI_LARGEICON = $SHGFI_LARGEICON
Global Const $SHGSI_SMALLICON = $SHGFI_SMALLICON
Global Const $SHGSI_SHELLICONSIZE = $SHGFI_SHELLICONSIZE

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
; _WinAPI_ShellObjectProperties()
; ===============================================================================================================================

Global Const $SHOP_PRINTERNAME = 1
Global Const $SHOP_FILEPATH = 2
Global Const $SHOP_VOLUMEGUID = 4

; ===============================================================================================================================
; _WinAPI_ShellOpenFolderAndSelectItems()
; ===============================================================================================================================

; *Windows Vista or later
Global Const $OFASI_EDIT = 0x01
Global Const $OFASI_OPENDESKTOP = 0x02

; ===============================================================================================================================
; _WinAPI_ShellOpenWithDlg()
; ===============================================================================================================================

Global Const $OAIF_ALLOW_REGISTRATION = 0x00000001
Global Const $OAIF_REGISTER_EXT = 0x00000002
Global Const $OAIF_EXEC = 0x00000004
Global Const $OAIF_FORCE_REGISTRATION = 0x00000008
Global Const $OAIF_HIDE_REGISTRATION = 0x00000020
Global Const $OAIF_URL_PROTOCOL = 0x00000040

; ===============================================================================================================================
; _WinAPI_ShellQueryUserNotificationState()
; ===============================================================================================================================

; *Windows Vista or later
Global Const $QUNS_NOT_PRESENT = 1
Global Const $QUNS_BUSY = 2
Global Const $QUNS_RUNNING_D3D_FULL_SCREEN = 3
Global Const $QUNS_PRESENTATION_MODE = 4
Global Const $QUNS_ACCEPTS_NOTIFICATIONS = 5
Global Const $QUNS_QUIET_TIME = 6

; ===============================================================================================================================
; _WinAPI_UniqueHardwareID()
; ===============================================================================================================================

Global Const $UHID_MB = 0x00
Global Const $UHID_BIOS = 0x01
Global Const $UHID_CPU = 0x02
Global Const $UHID_HDD = 0x04
Global Const $UHID_All = BitOR($UHID_MB, $UHID_BIOS, $UHID_CPU, $UHID_HDD)

; ===============================================================================================================================
; _WinAPI_VerQueryRoot()
; ===============================================================================================================================

Global Const $VS_FF_DEBUG = 0x00000001
Global Const $VS_FF_INFOINFERRED = 0x00000010
Global Const $VS_FF_PATCHED = 0x00000004
Global Const $VS_FF_PRERELEASE = 0x00000002
Global Const $VS_FF_PRIVATEBUILD = 0x00000008
Global Const $VS_FF_SPECIALBUILD = 0x00000020

Global Const $VOS_DOS = 0x00010000
Global Const $VOS_NT = 0x00040000
Global Const $VOS__WINDOWS16 = 0x00000001
Global Const $VOS__WINDOWS32 = 0x00000004
Global Const $VOS_OS216 = 0x00020000
Global Const $VOS_OS232 = 0x00030000
Global Const $VOS__PM16 = 0x00000002
Global Const $VOS__PM32 = 0x00000003
Global Const $VOS_UNKNOWN = 0x00000000

Global Const $VOS_DOS_WINDOWS16 = 0x00010001
Global Const $VOS_DOS_WINDOWS32 = 0x00010004
Global Const $VOS_NT_WINDOWS32 = 0x00040004
Global Const $VOS_OS216_PM16 = 0x00020002
Global Const $VOS_OS232_PM32 = 0x00030003

Global Const $VFT_APP = 0x00000001
Global Const $VFT_DLL = 0x00000002
Global Const $VFT_DRV = 0x00000003
Global Const $VFT_FONT = 0x00000004
Global Const $VFT_STATIC_LIB = 0x00000007
Global Const $VFT_UNKNOWN = 0x00000000
Global Const $VFT_VXD = 0x00000005

Global Const $VFT2_DRV_COMM = 0x0000000A
Global Const $VFT2_DRV_DISPLAY = 0x00000004
Global Const $VFT2_DRV_INSTALLABLE = 0x00000008
Global Const $VFT2_DRV_KEYBOARD = 0x00000002
Global Const $VFT2_DRV_LANGUAGE = 0x00000003
Global Const $VFT2_DRV_MOUSE = 0x00000005
Global Const $VFT2_DRV_NETWORK = 0x00000006
Global Const $VFT2_DRV_PRINTER = 0x00000001
Global Const $VFT2_DRV_SOUND = 0x00000009
Global Const $VFT2_DRV_SYSTEM = 0x00000007
Global Const $VFT2_DRV_VERSIONED_PRINTER = 0x0000000C
Global Const $VFT2_UNKNOWN = 0x00000000

Global Const $VFT2_FONT_RASTER = 0x00000001
Global Const $VFT2_FONT_TRUETYPE = 0x00000003
Global Const $VFT2_FONT_VECTOR = 0x00000002
;Global Const $VFT2_UNKNOWN = 0x00000000

#EndRegion Global Variables and Constants
