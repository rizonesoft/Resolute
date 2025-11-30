#cs ----------------------------------------------------------------------------

	File:           Busy.au3
	AutoIt Version: 3.2.12.1
	Author:         zorphnog (Michael Mims)

	Script Function:
	Provides a status window with text, progress bar, and gif animation

#ce ----------------------------------------------------------------------------

#include-once
#include <WindowsConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <File.au3>
#include <Gif89.dll.au3>

Global Const _
	$BSY_SIZE          = 11, _
	$BSY_MAINWIN       = 0, _
	$BSY_GIFOBJ        = 1, _
	$BSY_STATUSTEXT    = 2, _
	$BSY_STATUSBAR     = 3, _
	$BSY_SCREENWIN     = 4, _
	$BSY_THEME_DIR     = 5, _
	$BSY_THEME_BGCOLOR = 6, _
	$BSY_THEME_TEXT    = 7, _
	$BSY_THEME_BAR     = 8, _
	$BSY_THEME_SCREEN  = 9, _
	$BSY_THEME_GIF     = 10
Global Const _
	$BUSY_SCREEN   = 0x1
	$BUSY_PROGRESS = 0x2
Global $g_hDll_Gif89 = 0, $g_aBsy_Info[$BSY_SIZE]

; #FUNCTION# ====================================================================================================================
; Name...........: _Busy_Close
; Description ...: Closes the busy status window.
; Syntax.........: _Busy_Close()
; Parameters ....: None
; Return values .: Success - Returns a 0
;                  Failure - Returns a -1
;                  @Error  - 0 = No error
;                  |1 = Invalid busy array
; Author ........: zorphnog
; Remarks .......: None
; ===============================================================================================================================
Func _Busy_Close()
	If Not IsArray($g_aBsy_Info) Or UBound($g_aBsy_Info) <> $BSY_SIZE Then Return SetError(1, 0, -1)
	GUIDelete($g_aBsy_Info[$BSY_MAINWIN])
	If $g_aBsy_Info[$BSY_SCREENWIN] <> 0 Then GUIDelete($g_aBsy_Info[$BSY_SCREENWIN])
	__Busy_Reset()
	Return 0
EndFunc   ;==>_Busy_Close

; #FUNCTION# ====================================================================================================================
; Name...........: _Busy_Create
; Description ...: Creates and displays a busy status window.
; Syntax.........: _Busy_Create($sStatus, $iOptions, $iTrans)
; Parameters ....: $sStatusText - Status text for the busy window
;                  $iOptions    - Busy window options
;                                 |$BUSY_PROGRESS = Creates a progress bar in the busy window
;                                 |$BUSY_SCREEN   = Create a transparent screen behind the busy window
;                  $iTrans      - The transparency number in the range 0 - 255
;                  $hGui        - Handle to a parent GUI
; Return values .: Success - Returns a 0
;                  Failure - Returns a -1
;                  @Error  - 0 = No error.
;                  |1 = Invalid busy array
; Author ........: zorphnog
; Remarks .......:
; ===============================================================================================================================
Func _Busy_Create($sStatusText = "", $iOptions = -1, $iTrans = -1, $hGui = -1)
	If Not IsArray($g_aBsy_Info) Or UBound($g_aBsy_Info) <> $BSY_SIZE Then Return SetError(1, 0, -1)
	Local $iGHeight = 85, $iGWidth = 150, $iHeight, $iWidth
	If $iOptions < 0 Or IsKeyword($iOptions) Then $iOptions = 0
	If $iTrans < 0 Or IsKeyword($iTrans) Then $iTrans = 225
	If $iTrans > 255 Then $iTrans = 255
	If $hGui <= 0 Or IsKeyword($hGui) Then $hGui = -1
	If BitAND($iOptions, $BUSY_PROGRESS) = $BUSY_PROGRESS Then $iGHeight += 10
	If BitAND($iOptions, $BUSY_SCREEN) = $BUSY_SCREEN Then
		$g_aBsy_Info[$BSY_SCREENWIN] = GUICreate("", @DesktopWidth, @DesktopHeight, 0, 0, BitOR($WS_POPUP, $WS_DISABLED), BitOR($WS_EX_TOPMOST, $WS_EX_TOOLWINDOW))
		GUISetBkColor($g_aBsy_Info[$BSY_THEME_SCREEN])
		WinSetTrans($g_aBsy_Info[$BSY_SCREENWIN], "", $iTrans)
		GUISetState(@SW_SHOW, $g_aBsy_Info[$BSY_SCREENWIN])
	EndIf
	If $hGui <> -1 Then
		$g_aBsy_Info[$BSY_MAINWIN] = GUICreate("", $iGWidth, $iGHeight, -1, -1, $WS_POPUP, BitOR($WS_EX_TOPMOST, $WS_EX_TOOLWINDOW, $WS_EX_LAYERED), $hGui)
	Else
		$g_aBsy_Info[$BSY_MAINWIN] = GUICreate("", $iGWidth, $iGHeight, -1, -1, $WS_POPUP, BitOR($WS_EX_TOPMOST, $WS_EX_TOOLWINDOW, $WS_EX_LAYERED))
	EndIf
	GUISetBkColor($g_aBsy_Info[$BSY_THEME_BGCOLOR])
	GUICtrlCreatePic($g_aBsy_Info[$BSY_THEME_DIR] & "\tr.bmp", $iGWidth - 5, 0, 5, 5)
	GUICtrlSetState(-1, $GUI_DISABLE)
	GUICtrlCreatePic($g_aBsy_Info[$BSY_THEME_DIR] & "\br.bmp", $iGWidth - 5, $iGHeight - 5, 5, 5)
	GUICtrlSetState(-1, $GUI_DISABLE)
	GUICtrlCreatePic($g_aBsy_Info[$BSY_THEME_DIR] & "\bl.bmp", 0, $iGHeight - 5, 5, 5)
	GUICtrlSetState(-1, $GUI_DISABLE)
	GUICtrlCreatePic($g_aBsy_Info[$BSY_THEME_DIR] & "\tl.bmp", 0, 0, 5, 5)
	GUICtrlSetState(-1, $GUI_DISABLE)
	__GetGifPixSize($g_aBsy_Info[$BSY_THEME_GIF], $iHeight, $iWidth)
	If IsObj($g_aBsy_Info[$BSY_GIFOBJ]) Then GUICtrlCreateObj($g_aBsy_Info[$BSY_GIFOBJ], Int(($iGWidth / 2) - ($iWidth / 2)), 10, $iWidth, $iHeight)
	If BitAND($iOptions, $BUSY_PROGRESS) = $BUSY_PROGRESS Then
		$g_aBsy_Info[$BSY_STATUSBAR] = GUICtrlCreateLabel("", 15, $iHeight + 18, 120, 2)
		GUICtrlSetBkColor(-1, $g_aBsy_Info[$BSY_THEME_BAR])
		GUICtrlSetState(-1, $GUI_HIDE)
		$g_aBsy_Info[$BSY_STATUSTEXT] = GUICtrlCreateLabel($sStatusText, 5, $iHeight + 25, $iGWidth - 10, 15, BitOR(0x50000000, $SS_CENTER))
		GUICtrlSetColor(-1, $g_aBsy_Info[$BSY_THEME_TEXT])
		GUICtrlSetFont(-1, -1, -1, -1, "Arial")
	Else
		$g_aBsy_Info[$BSY_STATUSTEXT] = GUICtrlCreateLabel($sStatusText, 5, $iHeight + 15, $iGWidth - 10, 15, BitOR(0x50000000, $SS_CENTER))
		GUICtrlSetColor(-1, $g_aBsy_Info[$BSY_THEME_TEXT])
		GUICtrlSetFont(-1, -1, -1, -1, "Arial")
	EndIf
	GUISetState(@SW_SHOW, $g_aBsy_Info[$BSY_MAINWIN])
	Return 0
EndFunc   ;==>_Busy_Create

; #FUNCTION# ====================================================================================================================
; Name...........: _Busy_Start
; Description ...: Registers the Gif89 dll and loads the default theme for the busy window
; Syntax.........: _Busy_Start()
; Parameters ....: None
; Return values .: Success - Returns the path to the dll file.
;                  Failure - Returns a blank string
;                  @Error  - 0 = No error.
;                  |1 = Temporary dll file could not be created
;                  |2 = The dll file failed to register
; Author ........: zorphnog
; Remarks .......:
; ===============================================================================================================================
Func _Busy_Start()
	Local $sDll_Filename, $hDll, $hFileDllOut

	$sDll_Filename = @SystemDir & "\Gif89.dll"
	If Not FileExists($sDll_Filename) Then
		$hFileDllOut = FileOpen($sDll_Filename, 2)
	EndIf
	If $hFileDllOut = -1 Then
		$sDll_Filename = _TempFile(@TempDir, "~", ".dll")
		$hFileDllOut = FileOpen($sDll_Filename, 2)
		If $hFileDllOut = -1 Then Return SetError(1, 0, "")
	EndIf
	FileWrite($hFileDllOut, Call('__' & 'Busy_Inline_Gif89Dll'))
	FileClose($hFileDllOut)
	FileSetTime($sDll_Filename, Call('__' & 'Busy_Inline_Modified'), 0)

	$iRet = RunWait(@ComSpec & " /c regsvr32 /s " & $sDll_Filename, @ScriptDir, @SW_HIDE)
	If @error Then
		$g_hDll_Gif89 = 0
		Return SetError(2, 0, "")
	Else
		$g_hDll_Gif89 = $sDll_Filename
		_Busy_UseTheme("Default")
		Return $sDll_Filename
	EndIf
EndFunc   ;==>_Busy_Start

; #FUNCTION# ====================================================================================================================
; Name...........: _Busy_Stop
; Description ...: Deletes the gif object and unregisters the Gif89 dll
; Syntax.........: _Busy_Stop()
; Parameters ....: None
; Return values .: Success - Returns a 0
;                  Failure - Returns path to dll file
;                  @Error  - 0 = No error.
;                  |1 = Dll file failed to unregister
; Author ........: zorphnog
; Remarks .......:
; ===============================================================================================================================
Func _Busy_Stop()
	$g_aBsy_Info[$BSY_GIFOBJ] = 0
	If $g_hDll_Gif89 <> "" Then
		RunWait(@ComSpec & " /c regsvr32 /s /u " & $g_hDll_Gif89, @ScriptDir, @SW_HIDE)
		If @error Then Return SetError(1, 0, $g_hDll_Gif89)
		FileDelete($g_hDll_Gif89)
	EndIf
	Return 0
EndFunc   ;==>_Busy_Stop

; #FUNCTION# ====================================================================================================================
; Name...........: _Busy_Update
; Description ...: Update the status text or progress of the busy window
; Syntax.........: _Busy_Update($sStatusText, $iStatusPercent)
; Parameters ....: $sStatusText    - The status text for the busy window
;                  $iStatusPercent - A percent number for the progress bar in the range 0 - 100
; Return values .: Success - Returns a 0
;                  Failure - Returns a -1
;                  @Error  - 0 = No error.
;                  |1 = Invalid busy array
; Author ........: zorphnog
; Remarks .......:
; ===============================================================================================================================
Func _Busy_Update($sStatusText = "", $iStatusPercent = -1)
	If Not IsArray($g_aBsy_Info) Or UBound($g_aBsy_Info) <> $BSY_SIZE Then Return SetError(1, 0, -1)
	If $sStatusText <> GUICtrlRead($g_aBsy_Info[$BSY_STATUSTEXT]) Then GUICtrlSetData($g_aBsy_Info[$BSY_STATUSTEXT], $sStatusText)
	If $iStatusPercent > -1 Then
		If $iStatusPercent > 100 Then $iStatusPercent = 100
		If $iStatusPercent = 0 Then
			GUICtrlSetState($g_aBsy_Info[$BSY_STATUSBAR], $GUI_HIDE)
		Else
			GUICtrlSetPos($g_aBsy_Info[$BSY_STATUSBAR], 15, 65, 120 * $iStatusPercent / 100)
			If BitAND(GUICtrlGetState($g_aBsy_Info[$BSY_STATUSBAR]), $GUI_HIDE) = $GUI_HIDE Then GUICtrlSetState($g_aBsy_Info[$BSY_STATUSBAR], $GUI_SHOW)
		EndIf
	EndIf
	Return 0
EndFunc   ;==>_Busy_Update

; #FUNCTION# ====================================================================================================================
; Name...........: _Busy_UseTheme
; Description ...: Use a custom theme for the busy window
; Syntax.........: _Busy_UseTheme($sThemeName)
; Parameters ....: $sThemeName - The name of the theme to use
; Return values .: Success - Returns a 0
;                  Failure - Returns a -1
;                  @Error  - 0 = No error.
;                  |1 = Invalid busy array
;                  |2 = Theme directory does not exist
;                  |3 = Settings file does not exist
; Author ........: zorphnog
; Remarks .......: Themes must be created in a folder named after theme located in the Busy folder of the script directory. Each
;                  theme must contain a settings.ini file with color hex values for the background, text, and progress bar. The
;                  animated gif must be named loader.gif. Each theme can also contain four images for the corners of the busy
;                  window. See default theme for an example.
; ===============================================================================================================================
Func _Busy_UseTheme($sThemeName)
	If Not IsArray($g_aBsy_Info) Or UBound($g_aBsy_Info) <> $BSY_SIZE Then Return SetError(1, 0, -1)
	Local $sDir, $sSettingsFile, $sTemp
	$sDir = @ScriptDir & "\Themes\" & $sThemeName
	If Not FileExists($sDir) Then Return SetError(2, 0, -1)
	$sSettingsFile = $sDir & "\settings.ini"
	If Not FileExists($sSettingsFile) Then Return SetError(3, 0, -1)
	$g_aBsy_Info[$BSY_THEME_DIR] = $sDir
	$g_aBsy_Info[$BSY_THEME_BGCOLOR] = __ValidateThemeEntry(IniRead($sSettingsFile, "colors", "bg", -1))
	If @error Then $g_aBsy_Info[$BSY_THEME_BGCOLOR] = 0x000000
	$g_aBsy_Info[$BSY_THEME_TEXT] = __ValidateThemeEntry(IniRead($sSettingsFile, "colors", "text", -1))
	If @error Then $g_aBsy_Info[$BSY_THEME_TEXT] = 0xFFFFFF
	$g_aBsy_Info[$BSY_THEME_BAR] = __ValidateThemeEntry(IniRead($sSettingsFile, "colors", "bar", -1))
	If @error Then $g_aBsy_Info[$BSY_THEME_BAR] = 0xFFFFFF
	$g_aBsy_Info[$BSY_THEME_SCREEN] = __ValidateThemeEntry(IniRead($sSettingsFile, "colors", "screen", -1))
	If @error Then $g_aBsy_Info[$BSY_THEME_SCREEN] = 0xFFFFFF
	$g_aBsy_Info[$BSY_THEME_GIF] = $sDir & "\loader.gif"
	__Busy_Reset()
EndFunc   ;==>_Busy_UseTheme

#Region internal functions

Func __ValidateThemeEntry($sEntry)
	If $sEntry = -1 Then Return SetError(1, 0, -1)
	Local $aResult = StringRegExp($sEntry, "(?i)([a-f0-9]{6})", 3)
	If Not @error Then Return "0x" & $aResult[0]
	Return SetError(2, 0, -1)
EndFunc  ;==__ValidateThemeEntry

Func __Busy_Reset()
	$g_aBsy_Info[$BSY_MAINWIN]    = 0
	$g_aBsy_Info[$BSY_STATUSTEXT] = 0
	$g_aBsy_Info[$BSY_STATUSBAR]  = 0
	$g_aBsy_Info[$BSY_SCREENWIN]  = 0
	$g_aBsy_Info[$BSY_GIFOBJ]     = 0
	$g_aBsy_Info[$BSY_GIFOBJ]     = ObjCreate("Gif89.Gif89")
	If Not @error Then $g_aBsy_Info[$BSY_GIFOBJ].filename = $g_aBsy_Info[$BSY_THEME_GIF]
EndFunc   ;==>__Busy_Reset

Func __GetGifPixSize($s_gif, ByRef $pwidth, ByRef $pheight)
	If FileGetSize($s_gif) > 9 Then
		Local $sizes = FileRead($s_gif, 10)
		$pwidth = Asc(StringMid($sizes, 8, 1)) * 256 + Asc(StringMid($sizes, 7, 1))
		$pheight = Asc(StringMid($sizes, 10, 1)) * 256 + Asc(StringMid($sizes, 9, 1))
	EndIf
EndFunc   ;==>__GetGifPixSize

#EndRegion internal functions
