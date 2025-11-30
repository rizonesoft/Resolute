#Include <APIConstants.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global Const $STM_SETIMAGE = 0x0172

Global $hInstance, $hResource, $hData, $pData, $hIcon, $iIcon, $iSize

; Load Resources.dll to memory
$hInstance = _WinAPI_LoadLibraryEx(@ScriptDir & '\Extras\Resources.dll', $LOAD_LIBRARY_AS_DATAFILE)
If Not $hInstance Then
	MsgBox(16, 'Error', @ScriptDir & '\Extras\Resources.dll not found.')
	Exit
EndIf

; Load RT_GROUP_ICON resource from Resources.dll library
$hResource = _WinAPI_FindResource($hInstance, $RT_GROUP_ICON, 1)
$hData = _WinAPI_LoadResource($hInstance, $hResource)
$pData = _WinAPI_LockResource($hData)

; Search an integer resource name for the icon that best fits the specified size (48x48)
$iIcon = _WinAPI_LookupIconIdFromDirectoryEx($pData, 1, 48, 48)

; Load RT_ICON resource from Resources.dll library
$hResource = _WinAPI_FindResource($hInstance, $RT_ICON, $iIcon)
$iSize = _WinAPI_SizeOfResource($hInstance, $hResource)
$hData = _WinAPI_LoadResource($hInstance, $hResource)
$pData = _WinAPI_LockResource($hData)

; Create icon from resource
$hIcon = _WinAPI_CreateIconFromResourceEx($pData, $iSize)

; Unload Resources.dll from memory
_WinAPI_FreeLibrary($hInstance)

; Create GUI
GUICreate('MyGUI', 128, 128)
GUICtrlCreateIcon('', 0, 40, 40, 48, 48)
GUICtrlSendMsg(-1, $STM_SETIMAGE, 1, $hIcon)
GUISetState()

Do
Until GUIGetMsg() = -3
