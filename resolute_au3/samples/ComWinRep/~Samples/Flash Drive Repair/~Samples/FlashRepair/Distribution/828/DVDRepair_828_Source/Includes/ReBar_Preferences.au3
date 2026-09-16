#include-once


#include "ReBar_Declarations.au3"


; #INDEX# =======================================================================================================================
; Title .........: ReBar Preferences
; AutoIt Version : 3.3.15.0
; Description ...:
; Author(s) .....: Derick Payne (Rizonesoft)
; ===============================================================================================================================

#Region Global Variables and Constants

; #VARIABLES# ===================================================================================================================
; ===============================================================================================================================

; #CONSTANTS# ===================================================================================================================
; ===============================================================================================================================
#EndRegion Global Variables and Constants


#Region Functions list
; #CURRENT# =====================================================================================================================
;
; ==============================================================================================================================
#EndRegion Functions list


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
	GUICtrlCreateGroup("", -99, -99, 1, 1) ;close group

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
		GUICtrlCreateGroup("", -99, -99, 1, 1) ;close group

		GUICtrlSetOnEvent($g_ReBarChkCacheOnExit, "_CheckPreferenceChange")
		GUICtrlSetOnEvent($g_ReBarChkLogEnabled, "_CheckPreferenceChange")
		GUICtrlSetOnEvent($g_ReBarBtnClearLog, "_RemoveLoggingFile")

		GUICtrlSetState($g_ReBarChkLogEnabled, $g_ReBarLogEnabled)

	EndIf

	GUICtrlCreateTabItem("") ; end tabitem definition

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

EndFunc   ;==>_ShowOptionsDlg


Func _CloseOptionsDlg()

	AdlibUnRegister("_CheckLogSizeChange")
	GUIDelete($g_ReBarPrefsGui)
	WinSetTrans($g_ReBarCoreGui, Default, 255)
	GUISetState(@SW_ENABLE, $g_ReBarCoreGui)
	WinActivate($g_ReBarCoreGui)

EndFunc   ;==>_CloseOptionsDlg


Func _CheckLogSizeChange()

	Local $iLogTemp = Int(GUICtrlRead($g_ReBarInLogSize))

	If $g_ReBarInLogSizeTemp <> $iLogTemp Then
		GUICtrlSetState($g_ReBarBtnSavePrefs, $GUI_ENABLE)
		$g_ReBarInLogSizeTemp = $iLogTemp
	EndIf

EndFunc


Func _CheckPreferenceChange()

	If _CheckBoxChanged("ClearCacheOnExit", $g_ReBarChkCacheOnExit) = True Or _
			_CheckBoxChanged("LoggingEnabled", $g_ReBarChkLogEnabled) = True Then
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
		If GUICtrlRead($hCheckBox) = $iTmp Or GUICtrlRead($hCheckBox) = ($iTmp + 4) Then
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