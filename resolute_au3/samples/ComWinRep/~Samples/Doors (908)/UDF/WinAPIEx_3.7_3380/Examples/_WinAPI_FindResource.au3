#Include <APIConstants.au3>
#Include <GUIConstantsEx.au3>
#Include <Memory.au3>
#Include <StaticConstants.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global Const $sJpg = @TempDir & '\~Tech.jpg'

Global $Msg, $Button, $hFile, $hFont, $hInstance, $hResource, $hData, $pData, $tData, $hWave, $pWave, $sText, $iSize

; Load Resources.dll to memory
$hInstance = _WinAPI_LoadLibraryEx(@ScriptDir & '\Extras\Resources.dll', $LOAD_LIBRARY_AS_DATAFILE)
If Not $hInstance Then
	MsgBox(16, 'Error', @ScriptDir & '\Extras\Resources.dll not found.')
	Exit
EndIf

; Load JPEG resource from Resources.dll library
$hResource = _WinAPI_FindResource($hInstance, 'JPEG', 1)
$iSize = _WinAPI_SizeOfResource($hInstance, $hResource)
$hData = _WinAPI_LoadResource($hInstance, $hResource)
$pData = _WinAPI_LockResource($hData)

; Save resource to .jpg file
$hFile = FileOpen($sJpg, 2 + 16)
$tData = DllStructCreate('byte[' & $iSize & ']', $pData)
FileWrite($hFile, DllStructGetData($tData, 1))
FileClose($hFile)

; Load FONT resource from Resources.dll library
$hResource = _WinAPI_FindResource($hInstance, $RT_FONT, 'TECHNOVIA_CAPS')
$iSize = _WinAPI_SizeOfResource($hInstance, $hResource)
$hData = _WinAPI_LoadResource($hInstance, $hResource)
$pData = _WinAPI_LockResource($hData)

; Add font from a memory to the system
$hFont = _WinAPI_AddFontMemResourceEx($pData, $iSize)

; Load SOUND resource from Resources.dll library
$hResource = _WinAPI_FindResource($hInstance, 'SOUND', 1)
$iSize = _WinAPI_SizeOfResource($hInstance, $hResource)
$hData = _WinAPI_LoadResource($hInstance, $hResource)
$pData = _WinAPI_LockResource($hData)

; Copy WAV to memory for use later
$hWave = _MemGlobalAlloc($iSize, $GMEM_MOVEABLE)
$pWave = _MemGlobalLock($hWave)
_MemMoveMemory($pData, $pWave, $iSize)
;_MemGlobalUnlock($hWave)

; Load STRING resource from Resources.dll library
$sText = _WinAPI_LoadString($hInstance, 1)

; Unload Resources.dll from memory
_WinAPI_FreeLibrary($hInstance)

; Create GUI
GUICreate('MyGUI', 350, 350)
GUICtrlCreatePic($sJpg, 0, 0, 350, 350)
GUICtrlSetState(-1, $GUI_DISABLE)
GUICtrlCreateLabel($sText, 10, 18, 330, 36, $SS_CENTER)
GUICtrlSetFont(-1, 30, -1, -1, 'Technovia Caps')
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
GUICtrlSetColor(-1, 0xF06000)
$Button = GUICtrlCreateButton('Play Sound', 125, 316, 100, 23)
GUISetState()

While 1
	$Msg = GUIGetMsg()
	Switch $Msg
		Case $GUI_EVENT_CLOSE
			ExitLoop
		Case $Button
			_WinAPI_PlaySound($pWave, BitOR($SND_ASYNC, $SND_MEMORY, $SND_NOWAIT))
	EndSwitch
WEnd

; Free resources
_WinAPI_RemoveFontMemResourceEx($hFont)
FileDelete($sJpg)
