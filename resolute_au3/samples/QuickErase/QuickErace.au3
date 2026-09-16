#NoTrayIcon
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=Resources\QuickErase\QuickErase.ico
#AutoIt3Wrapper_Res_Description=Securely delete files
#AutoIt3Wrapper_Res_Fileversion=0.4.2.421
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=y
#AutoIt3Wrapper_Res_LegalCopyright=© 2011 Rizonesoft
#AutoIt3Wrapper_Res_Icon_Add=Resources\Socialize\RSS.ico
#AutoIt3Wrapper_Res_Icon_Add=Resources\Socialize\Facebook.ico
#AutoIt3Wrapper_Res_Icon_Add=Resources\Socialize\Twitter.ico
#AutoIt3Wrapper_Res_Icon_Add=Resources\Socialize\PP.ico
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
;~ #AutoIt3Wrapper_Res_requestedExecutionLevel=requireAdministrator


#include <WindowsConstants.au3>
#include <StaticConstants.au3>
#include <ButtonConstants.au3>
#include <GUIConstantsEx.au3>
#include <EditConstants.au3>
#Include <Misc.au3>

#include "UDF\SecureFileDelete.au3"


Opt("GUICloseOnESC", 0) ; Default tray menu items (Script Paused/Exit) will not be shown.
;~ Opt("GUIOnEventMode", 1)
Opt("MustDeclareVars", 1)


;~ Program Constants and Variables
Global Const $PROGRAM_TITLE = "Quick Erase"
Global Const $PROGRAM_VERSION = FileGetVersion(@ScriptFullPath)
Global Const $PROGRAM_FORM_TITLE = $PROGRAM_TITLE & " : " &  $PROGRAM_VERSION
Global Const $INI_CURRENT = @ScriptDir & "\QuickErase.ini"
Global Const $REG_CURRENT = "HKEY_CURRENT_USER\Software\Rizonesoft\QuickErase"

Global $PROGRAM_GUI, $PROGRAM_ICON, $PROGRAM_PID, $PROGRAM_INSTALLED, $DOORS_OPENPAGE
;~ End Program Constants and Variables

;~ Settings
Global $setOnTop, $setNotify, $setPattern
Global $setRenFile, $setFileTime, $sPattern

Global $stPa = ""

Global $eStatus, $mnuFile, $filOptions, $filClose, $mnuHelp, $hlpAbout
Global $OptionsDlg, $chkOnTop, $chkWarnings
Global $radSimple, $radBIS5Base, $radRussian, $radBIS5En, $radAR380, $radDoDM
Global $radDoDME, $radDoDMECE, $radCanadian, $radGerman, $radSchneier, $chkRenFile, $chkSetFileTime
Global $radPayne, $ePattern, $lblPass
Global $btnOptOK, $btnOptCancel, $btnOptApply
Global $aboutDlg


_Singleton(@ScriptName, 0)


$setOnTop = IniRead($INI_CURRENT, "Main", "SetWindowOnTop", 1)
$setNotify = IniRead($INI_CURRENT, "Main", "ShowNotifications", 1)
$setPattern = IniRead($INI_CURRENT, "Pattern", "Pattern", "PAYNE-3163H")
$setRenFile = IniRead($INI_CURRENT, "Pattern", "RenameFile", "PAYNE-3163H")
$setFileTime = IniRead($INI_CURRENT, "Pattern", "SetFileTime", "PAYNE-3163H")

$sPattern = $setPattern

If Not FileExists(@ScriptDir & "\Themes") Then DirCreate(@ScriptDir & "\Themes")
FileInstall("Resources\QuickErase\150.ani", @ScriptDir & "\Themes\150.ani", 0)

$PROGRAM_GUI = GUICreate($PROGRAM_VERSION, 148, 230, -1, -1, BitOr($WS_CAPTION, $WS_POPUPWINDOW), $WS_EX_ACCEPTFILES)
GUISetFont(8.5, 400, 0, "Verdana")

$mnuFile = GUICtrlCreateMenu("&File")
$filOptions = GUICtrlCreateMenuItem("&Options...", $mnuFile)
GUICtrlCreateMenuItem("", $mnuFile)
$filClose = GUICtrlCreateMenuItem("&Close" & @TAB & "Alt+F4", $mnuFile)
$mnuHelp = GUICtrlCreateMenu("&Help")
$hlpAbout = GUICtrlCreateMenuItem("&About...", $mnuHelp)

$PROGRAM_ICON = GUICtrlCreateIcon(@ScriptFullPath, 99, 10, 0, 128, 128)
GuiCtrlSetState($PROGRAM_ICON, $GUI_DROPACCEPTED)
$eStatus = GUICtrlCreateEdit("Drag and drop the file you would like to erase on the eraser icon.", 5, 135, 138, 70, BitOR($ES_READONLY, $WS_VSCROLL))
GuiCtrlSetColor($eStatus, 0x2780D5)

GUISetState(@SW_SHOW)

_SetWindowOnTop($setNotify)

While 1

	Local $nMsg = GUIGetMsg()

	Switch $nMsg

		Case $GUI_EVENT_CLOSE, $filClose
			_CloseQuickErase()

		Case $GUI_EVENT_DROPPED

			Local $SecDelState

			Switch $setPattern
				Case "Quick", "British-HMG-IS5-Baseline"

					$stPa = "00000000"

					Dim $aPaQuick[1]

					$aPaQuick[0] = 0x00

					_EraseFile(@GUI_DragFile, $aPaQuick)

				Case "Russian-GOST-P50739-95"

					$stPa = "00000000"

					Dim $aPaRussion[2]

					$aPaRussion[0] = 0x00
					$aPaRussion[1] = Random(0, 255, 1)

					_EraseFile(@GUI_DragFile, $aPaRussion)

				Case "British-HMG-IS5-Enhanced"

					$stPa = "0000000011111111"

					Dim $aPaBHMG[3]

					$aPaBHMG[0] = 0x00
					$aPaBHMG[1] = 0xFF
					$aPaBHMG[2] = Random(0, 255, 1)

					_EraseFile(@GUI_DragFile, $aPaBHMG)

				Case "US-Army-AR380-95"

					$stPa = "0100101110110100"

					Dim $aPaAR380[3]

					$aPaAR380[0] = Random(0, 255, 1)
					$aPaAR380[1] = 0x4B
					$aPaAR380[2] = 0xB4

					_EraseFile(@GUI_DragFile, $aPaAR380)

				Case "DoD-5220-22-M"

					$stPa = "000000001111111110010111"

					Dim $aPaDoDM[3]

					$aPaDoDM[0] = 0x00
					$aPaDoDM[1] = 0xFF
					$aPaDoDM[2] = 0x97

					_EraseFile(@GUI_DragFile, $aPaDoDM)

				Case "DoD-5220-22-M-E"

					$stPa = ""

					Dim $aPaDoDME[3]

					$aPaDoDME[0] = Random(0, 255, 1)
					$aPaDoDME[1] = BitAND(BitNOT($aPaDoDME[0]), 0xFF)
					$aPaDoDME[2] = Random(0, 255, 1)

					_EraseFile(@GUI_DragFile, $aPaDoDME)

				Case "DoD-5220-22-M-ECE"

					$stPa = "11010011001011001001010101101010"

					Dim $aPaDoDMECE[7]

					$aPaDoDMECE[0] = 0xD3
					$aPaDoDMECE[1] = 0x2C
					$aPaDoDMECE[2] = Random(0, 255, 1)
					$aPaDoDMECE[3] = Random(0, 255, 1)
					$aPaDoDMECE[4] = 0x95
					$aPaDoDMECE[5] = 0x6A
					$aPaDoDMECE[6] = Random(0, 255, 1)

					_EraseFile(@GUI_DragFile, $aPaDoDMECE)

				Case "Canadian-RCMP-TSSIT-OPS-II"

					$stPa = "000000001111111100000000111111110000000011111111"

					Dim $aPaCanadian[7]

					$aPaCanadian[0] = 0x00
					$aPaCanadian[1] = 0xFF
					$aPaCanadian[2] = 0x00
					$aPaCanadian[3] = 0xFF
					$aPaCanadian[4] = 0x00
					$aPaCanadian[5] = 0xFF
					$aPaCanadian[6] = Random(0, 255, 1)

					_EraseFile(@GUI_DragFile, $aPaCanadian)

				Case "German-VSITR"

					$stPa = "00000000111111110000000011111111000000001111111110101010"

					Dim $aPaGerman[7]

					$aPaGerman[0] = 0x00
					$aPaGerman[1] = 0xFF
					$aPaGerman[2] = 0x00
					$aPaGerman[3] = 0xFF
					$aPaGerman[4] = 0x00
					$aPaGerman[5] = 0xFF
					$aPaGerman[6] = 0xAA

					_EraseFile(@GUI_DragFile, $aPaGerman)

				Case "Bruce-Schneier"

					$stPa = "1111111100000000"

					Dim $aPaSchneier[7]

					$aPaSchneier[0] = 0xFF
					$aPaSchneier[1] = 0x00
					$aPaSchneier[2] = Random(0, 255, 1)
					$aPaSchneier[3] = Random(0, 255, 1)
					$aPaSchneier[4] = Random(0, 255, 1)
					$aPaSchneier[5] = Random(0, 255, 1)
					$aPaSchneier[6] = Random(0, 255, 1)

					_EraseFile(@GUI_DragFile, $aPaSchneier)

				Case "PAYNE-3163H"

					Dim $aPaPayne[23]

					$aPaPayne[0] = Random(0, 255, 1)
					$aPaPayne[1] = BitAND(BitNOT($aPaPayne[0]), 0xFF)
					$aPaPayne[2] = Random(0, 255, 1)
					$aPaPayne[3] = 0x00
					$aPaPayne[4] = 0x11
					$aPaPayne[5] = 0x22
					$aPaPayne[6] = 0x33
					$aPaPayne[7] = 0x44
					$aPaPayne[8] = 0x55
					$aPaPayne[9] = 0x66
					$aPaPayne[10] = 0x77
					$aPaPayne[11] = 0x88
					$aPaPayne[12] = 0x99
					$aPaPayne[13] = 0xAA
					$aPaPayne[14] = 0xBB
					$aPaPayne[15] = 0xCC
					$aPaPayne[16] = 0xDD
					$aPaPayne[17] = 0xEE
					$aPaPayne[18] = 0xFF
					$aPaPayne[19] = Random(0, 255, 1)
					$aPaPayne[20] = BitAND(BitNOT($aPaPayne[19]), 0xFF)
					$aPaPayne[21] = Random(0, 255, 1)
					$aPaPayne[22] = 0x00

					$stPa = Binary($aPaPayne[0])
					For $aa = 1 To UBound($aPaPayne) - 1
						$stPa &=  " " & Binary($aPaPayne[$aa])
					Next

					_EraseFile(@GUI_DragFile, $aPaPayne)

			EndSwitch

		Case $filOptions
			_OptionsDlg()

		Case $hlpAbout
			_AboutDlg()

	EndSwitch

WEnd



Func _EraseFile($sFile, $aPattern = -1)

	Local $sFileName = StringSplit($sFile, "\", 1)
	Local $sFileDate = FileGetTime($sFile, 1)

	If $setNotify Then

		If Not IsDeclared("iMsgBoxAnswer") Then Local $iMsgBoxAnswer
		$iMsgBoxAnswer = MsgBox(262196, "Are you sure?", 	"Are you sure you want to erase this file?" & @CRLF & _
															"You will not be able to recover it at all!" & @CRLF & @CRLF & _
															$sFileName[$sFileName[0]] & @CRLF & _
															"Version: " & FileGetVersion($sFile) & @CRLF & _
															"Size: " & Round(FileGetSize($sFile) / 1024, 2) & " KB" & @CRLF & _
															"Date modified: " & $sFileDate[0] & "/" & $sFileDate[1] & "/" & $sFileDate[2])
		Select
			Case $iMsgBoxAnswer = 6 ;Yes
			Case $iMsgBoxAnswer = 7 ;No
				Return
		EndSelect

	EndIf

	GUISetCursor(15, 0, $PROGRAM_GUI)
	GUICtrlSetCursor($PROGRAM_ICON, 15)
	GuiCtrlSetImage($PROGRAM_ICON, @ScriptDir & "\Themes\150.ani")
	GuiCtrlSetFont($eStatus, 9, -1, -1, "Courier New")

	_SetStatus($stPa, 0x007F00)
	$SecDelState = _SecureFileDelete($sFile, True, True, True, $aPattern)
	If @error Then
		_SetStatus("Could not erase file!", 0xB60038)
	Else
		_SetStatus("[" & $sFileName[$sFileName[0]] & "] should be bye-bye now!", 0x16528E)
	EndIf

	GuiCtrlSetFont($eStatus, 8.5, -1, -1, "Verdana")
	GuiCtrlSetImage($PROGRAM_ICON, @ScriptFullPath, 99)
	GUICtrlSetCursor($PROGRAM_ICON, 2)
	GUISetCursor(2, 0, $PROGRAM_GUI)

EndFunc


Func _SetStatus($Message, $Color = 0x000000)
	GuiCtrlSetData($eStatus, $Message)
	GuiCtrlSetColor($eStatus, $Color)
EndFunc


Func _SetWindowOnTop($onTopFlag)

	If $onTopFlag Then
		WinSetOnTop($PROGRAM_GUI, "", 1)
		WinSetOnTop($OptionsDlg, "", 1)
	Else
		WinSetOnTop($PROGRAM_GUI, "", 0)
	EndIf

EndFunc


Func _CloseQuickErase()

	GUIDelete($PROGRAM_GUI)
	$PROGRAM_PID = ProcessExists(@ScriptName) ; Will return the PID or 0 if the process isn't found.
	If $PROGRAM_PID Then ProcessClose(@ScriptName)
	Exit

EndFunc


Func _OptionsDlg()

	Opt("GUIOnEventMode", 1)

	$OptionsDlg = GUICreate($PROGRAM_FORM_TITLE & " Options", 500, 500, -1, -1, BitOr($WS_CAPTION, $WS_POPUPWINDOW), $WS_EX_TOPMOST)
	GUISetFont(8.5, 400, 0, "Verdana", $OptionsDlg, 5)

	$chkOnTop = GUICtrlCreateCheckbox(" Show 'Quick Erase' always on top", 25, 30, 300, 15)
	If $setOnTop Then GuiCtrlSetState($chkOnTop, $GUI_CHECKED)
	$chkWarnings = GUICtrlCreateCheckbox(" Show warning message before erasing a file", 25, 50, 300, 15)
	If $setNotify Then GuiCtrlSetState($chkWarnings, $GUI_CHECKED)

	GUICtrlCreateGroup("Erase Patterns", 15, 100, 470, 220)
	$radSimple = GUICtrlCreateRadio(" Quick (0s)", 25, 125, 220, 15)
	$radBIS5Base = GUICtrlCreateRadio(" British HMG IS5 (Baseline)", 255, 125, 220, 15)
	$radRussian = GUICtrlCreateRadio(" Russian GOST P50739-95", 25, 145, 220, 15)
	$radBIS5En = GUICtrlCreateRadio(" British HMG IS5 (Enhanced)", 255, 145, 220, 15)
	$radAR380 = GUICtrlCreateRadio(" US Army AR380-95", 25, 165, 220, 15)
	$radDoDM = GUICtrlCreateRadio(" DoD 5220.22-M", 255, 165, 220, 15)
	$radDoDME = GUICtrlCreateRadio(" DoD 5220.22-M (E)", 25, 185, 220, 15)
	$radDoDMECE = GUICtrlCreateRadio(" DoD 5220.22-M (ECE)", 255, 185, 220, 15)
	$radCanadian = GUICtrlCreateRadio(" Canadian RCMP TSSIT OPS-II", 25, 205, 220, 15)
	$radGerman = GUICtrlCreateRadio(" German VSITR", 255, 205, 220, 15)
	$radSchneier = GUICtrlCreateRadio(" Bruce Schneier", 25, 225, 220, 15)
	$radPayne = GUICtrlCreateRadio(" PAYNE-3163H (Rizonesoft)", 255, 225, 220, 15)

	$chkRenFile = GUICtrlCreateCheckbox(" Rename file after overwriting", 25, 340, 300, 15)
	If $setRenFile Then GuiCtrlSetState($chkRenFile, $GUI_CHECKED)
	$chkSetFileTime = GUICtrlCreateCheckbox(" Set all file times to Jan. 1, 1980, 12:01am", 25, 360, 300, 15)
	If $setFileTime Then GuiCtrlSetState($chkSetFileTime, $GUI_CHECKED)

	$ePattern = GUICtrlCreateEdit("", 25, 260, 390, 50, BitOR($ES_READONLY, $WS_VSCROLL))
	GUICtrlCreateLabel("PASS", 430, 260, 40, 20, $SS_CENTER)
	$lblPass = GUICtrlCreateLabel("7", 430, 280, 40, 30, $SS_CENTER)
	GUICtrlSetFont(-1, 12)

	GUICtrlCreateGroup("", -99, -99, 1, 1)  ;~ Close group
	GUISetOnEvent($GUI_EVENT_CLOSE, "_CloseOptionsDlg", $OptionsDlg)

	Switch $setPattern
		Case "Quick"
			GUICtrlSetState($radSimple, $GUI_CHECKED)
		Case "British-HMG-IS5-Baseline"
			GUICtrlSetState($radBIS5Base, $GUI_CHECKED)
		Case "Russian-GOST-P50739-95"
			GUICtrlSetState($radRussian, $GUI_CHECKED)
		Case "British-HMG-IS5-Enhanced"
			GUICtrlSetState($radBIS5En, $GUI_CHECKED)
		Case "US-Army-AR380-95"
			GUICtrlSetState($radAR380, $GUI_CHECKED)
		Case "DoD-5220-22-M"
			GUICtrlSetState($radDoDM, $GUI_CHECKED)
		Case "DoD-5220-22-M-E"
			GUICtrlSetState($radDoDME, $GUI_CHECKED)
		Case "DoD-5220-22-M-ECE"
			GUICtrlSetState($radDoDMECE, $GUI_CHECKED)
		Case "Canadian-RCMP-TSSIT-OPS-II"
			GUICtrlSetState($radCanadian, $GUI_CHECKED)
		Case "German-VSITR"
			GUICtrlSetState($radGerman, $GUI_CHECKED)
		Case "Bruce-Schneier"
			GUICtrlSetState($radSchneier, $GUI_CHECKED)
		Case "PAYNE-3163H"
			GUICtrlSetState($radPayne, $GUI_CHECKED)
	EndSwitch

	_SetPatternRadioOptions()

	$btnOptOK = GUICtrlCreateButton("OK", 170, 450, 100, 30)
	$btnOptCancel = GUICtrlCreateButton("Cancel", 270, 450, 100, 30)
	$btnOptApply = GUICtrlCreateButton("Apply", 370, 450, 100, 30)

	GuiCtrlSetState($btnOptApply, $GUI_DISABLE)

	GUICtrlSetOnEvent($chkOnTop, "_EnableApplyButton")
	GUICtrlSetOnEvent($chkWarnings, "_EnableApplyButton")
	GUICtrlSetOnEvent($radSimple, "_SetPatternRadioOptions")
	GUICtrlSetOnEvent($radBIS5Base, "_SetPatternRadioOptions")
	GUICtrlSetOnEvent($radRussian, "_SetPatternRadioOptions")
	GUICtrlSetOnEvent($radBIS5En, "_SetPatternRadioOptions")
	GUICtrlSetOnEvent($radAR380, "_SetPatternRadioOptions")
	GUICtrlSetOnEvent($radDoDM, "_SetPatternRadioOptions")
	GUICtrlSetOnEvent($radDoDME, "_SetPatternRadioOptions")
	GUICtrlSetOnEvent($radDoDMECE, "_SetPatternRadioOptions")
	GUICtrlSetOnEvent($radCanadian, "_SetPatternRadioOptions")
	GUICtrlSetOnEvent($radGerman, "_SetPatternRadioOptions")
	GUICtrlSetOnEvent($radSchneier, "_SetPatternRadioOptions")
	GUICtrlSetOnEvent($radPayne, "_SetPatternRadioOptions")
	GUICtrlSetOnEvent($chkRenFile, "_EnableApplyButton")
	GUICtrlSetOnEvent($chkSetFileTime, "_EnableApplyButton")

	GUICtrlSetOnEvent($btnOptOK, "_OptionsOK")
	GUICtrlSetOnEvent($btnOptCancel, "_CloseOptionsDlg")
	GUICtrlSetOnEvent($btnOptApply, "_OptionsApply")

	GUISetState(@SW_SHOW, $OptionsDlg)

EndFunc


Func _OptionsOK()

	_OptionsApply()
	_CloseOptionsDlg()

EndFunc


Func _OptionsApply()

	GuiCtrlSetState($btnOptApply, $GUI_DISABLE)

	If BitAND(GUICtrlRead($chkOnTop), $GUI_CHECKED) Then
		$setOnTop = 1
	ElseIf BitAND(GUICtrlRead($chkOnTop), $GUI_UNCHECKED) Then
		$setOnTop = 0
	EndIf

	If BitAND(GUICtrlRead($chkWarnings), $GUI_CHECKED) Then
		$setNotify = 1
	ElseIf BitAND(GUICtrlRead($chkWarnings), $GUI_UNCHECKED) Then
		$setNotify = 0
	EndIf

	If BitAND(GUICtrlRead($radSimple), $GUI_CHECKED) Then
		$setPattern = "Quick"
	ElseIf BitAND(GUICtrlRead($radBIS5Base), $GUI_CHECKED) Then
		$setPattern = "British-HMG-IS5-Baseline"
	ElseIf BitAND(GUICtrlRead($radRussian), $GUI_CHECKED) Then
		$setPattern = "Russian-GOST-P50739-95"
	ElseIf BitAND(GUICtrlRead($radBIS5En), $GUI_CHECKED) Then
		$setPattern = "British-HMG-IS5-Enhanced"
	ElseIf BitAND(GUICtrlRead($radAR380), $GUI_CHECKED) Then
		$setPattern = "US-Army-AR380-95"
	ElseIf BitAND(GUICtrlRead($radDoDM), $GUI_CHECKED) Then
		$setPattern = "DoD-5220-22-M"
	ElseIf BitAND(GUICtrlRead($radDoDME), $GUI_CHECKED) Then
		$setPattern = "DoD-5220-22-M-E"
	ElseIf BitAND(GUICtrlRead($radDoDMECE), $GUI_CHECKED) Then
		$setPattern = "DoD-5220-22-M-ECE"
	ElseIf BitAND(GUICtrlRead($radCanadian), $GUI_CHECKED) Then
		$setPattern = "Canadian-RCMP-TSSIT-OPS-II"
	ElseIf BitAND(GUICtrlRead($radGerman), $GUI_CHECKED) Then
		$setPattern = "German-VSITR"
	ElseIf BitAND(GUICtrlRead($radSchneier), $GUI_CHECKED) Then
		$setPattern = "Bruce-Schneier"
	ElseIf BitAND(GUICtrlRead($radPayne), $GUI_CHECKED) Then
		$setPattern = "PAYNE-3163H"
	EndIf

	_SetWindowOnTop($setOnTop)

	If BitAND(GUICtrlRead($chkRenFile), $GUI_CHECKED) Then
		$setRenFile = 1
	ElseIf BitAND(GUICtrlRead($chkRenFile), $GUI_UNCHECKED) Then
		$setRenFile = 0
	EndIf

	If BitAND(GUICtrlRead($chkSetFileTime), $GUI_CHECKED) Then
		$setFileTime = 1
	ElseIf BitAND(GUICtrlRead($chkSetFileTime), $GUI_UNCHECKED) Then
		$setFileTime = 0
	EndIf

	IniWrite($INI_CURRENT, "Main", "SetWindowOnTop", $setOnTop)
	IniWrite($INI_CURRENT, "Main", "ShowNotifications", $setNotify)
	IniWrite($INI_CURRENT, "Pattern", "Pattern", $setPattern)
	IniWrite($INI_CURRENT, "Pattern", "RenameFile", $setRenFile)
	IniWrite($INI_CURRENT, "Pattern", "SetFileTime", $setFileTime)

EndFunc


Func _SetPatternRadioOptions()

	If BitAND(GUICtrlRead($radSimple), $GUI_CHECKED) Then
		$sPattern = "Quick"
	ElseIf BitAND(GUICtrlRead($radBIS5Base), $GUI_CHECKED) Then
		$sPattern = "British-HMG-IS5-Baseline"
	ElseIf BitAND(GUICtrlRead($radRussian), $GUI_CHECKED) Then
		$sPattern = "Russian-GOST-P50739-95"
	ElseIf BitAND(GUICtrlRead($radBIS5En), $GUI_CHECKED) Then
		$sPattern = "British-HMG-IS5-Enhanced"
	ElseIf BitAND(GUICtrlRead($radAR380), $GUI_CHECKED) Then
		$sPattern = "US-Army-AR380-95"
	ElseIf BitAND(GUICtrlRead($radDoDM), $GUI_CHECKED) Then
		$sPattern = "DoD-5220-22-M"
	ElseIf BitAND(GUICtrlRead($radDoDME), $GUI_CHECKED) Then
		$sPattern = "DoD-5220-22-M-E"
	ElseIf BitAND(GUICtrlRead($radDoDMECE), $GUI_CHECKED) Then
		$sPattern = "DoD-5220-22-M-ECE"
	ElseIf BitAND(GUICtrlRead($radCanadian), $GUI_CHECKED) Then
		$sPattern = "Canadian-RCMP-TSSIT-OPS-II"
	ElseIf BitAND(GUICtrlRead($radGerman), $GUI_CHECKED) Then
		$sPattern = "German-VSITR"
	ElseIf BitAND(GUICtrlRead($radSchneier), $GUI_CHECKED) Then
		$sPattern = "Bruce-Schneier"
	ElseIf BitAND(GUICtrlRead($radPayne), $GUI_CHECKED) Then
		$sPattern = "PAYNE-3163H"
	EndIf

	Switch $sPattern
		Case "Quick", "British-HMG-IS5-Baseline"
			GUICtrlSetData($ePattern, "00000000")
			GuiCtrlSetData($lblPass, "1")
		Case "Russian-GOST-P50739-95"
			GUICtrlSetData($ePattern, "00000000, Random")
			GuiCtrlSetData($lblPass, "2")
		Case "British-HMG-IS5-Enhanced"
			GUICtrlSetData($ePattern, "00000000, 11111111, Random")
			GuiCtrlSetData($lblPass, "3")
		Case "US-Army-AR380-95"
			GUICtrlSetData($ePattern, "Random, 01001011, 10110100")
			GuiCtrlSetData($lblPass, "3")
		Case "DoD-5220-22-M"
			GUICtrlSetData($ePattern, "00000000, 11111111, 10010111")
			GuiCtrlSetData($lblPass, "3")
		Case "DoD-5220-22-M-E"
			GUICtrlSetData($ePattern, "Random, Complement, Random")
			GuiCtrlSetData($lblPass, "3")
		Case "DoD-5220-22-M-ECE"
			GUICtrlSetData($ePattern, "11010011, 00101100, Random, Random, 10010101, 01101010, Random")
			GuiCtrlSetData($lblPass, "7")
		Case "Canadian-RCMP-TSSIT-OPS-II"
			GUICtrlSetData($ePattern, "00000000, 11111111, 00000000, 11111111, 00000000, 11111111, Random")
			GuiCtrlSetData($lblPass, "7")
		Case "German-VSITR"
			GUICtrlSetData($ePattern, "00000000, 11111111, 00000000, 11111111, 00000000, 11111111, 10101010")
			GuiCtrlSetData($lblPass, "7")
		Case "Bruce-Schneier"
			GUICtrlSetData($ePattern, "11111111, 00000000, Random, Random, Random, Random, Random")
			GuiCtrlSetData($lblPass, "7")
		Case "PAYNE-3163H"
			GUICtrlSetData($ePattern, 	"Random, Complement, Random, 00000000, 00010001, 00100010, 00110011, 01000100, 01010101, 01100110, " & _
										"01110111, 10001000, 10011001, 10101010, 10111011, 11001100, 11011101, 11101110, 11111111, Random, " & _
										"Complement, Random, 00000000")
			GuiCtrlSetData($lblPass, "23")
	EndSwitch

	_EnableApplyButton()

EndFunc


Func _EnableApplyButton()
	If BitAND(GuiCtrlGetState($btnOptApply), $GUI_DISABLE) Then GuiCtrlSetState($btnOptApply, $GUI_ENABLE)
EndFunc


Func _CloseOptionsDlg()
	Opt("GUIOnEventMode", 0)
	GUIDelete(@GUI_WinHandle)
EndFunc


Func _AboutDlg()

	Opt("GUIOnEventMode", 1)
	GuiCtrlSetState($hlpAbout, $GUI_DISABLE)

	Local $abHome, $abSupport
	Local $abLicense, $abPP
	Local $abSpaceLabel, $abSpaceProg, $abBtnOK
	Local $abRSS, $abFacebook, $abTwittter

	$aboutDlg = GUICreate("About " & $PROGRAM_TITLE, 400, 300, -1, -1, BitOr($WS_CAPTION, $WS_POPUPWINDOW), $WS_EX_TOPMOST)
	GUISetFont(8.5, 400, 0, "Verdana", $AboutDlg, 5)

	GUISetOnEvent($GUI_EVENT_CLOSE, "_CloseAboutDlg", $AboutDlg)

	GUICtrlCreateIcon(@ScriptFullPath, 99, 10, 10, 64, 64)
	GUICtrlCreateLabel($PROGRAM_TITLE, 88, 16, 300, 18)
	GUICtrlSetFont(-1, 9, 800, 0, "Verdana")
	GUICtrlCreateLabel("Version " & FileGetVersion(@ScriptFullPath), 88, 40, 300, 20)
	GUICtrlCreateLabel("Copyright © 2011 Rizonesoft", 88, 55, 300, 20)
	GuiCtrlSetFont(-1, 8.5) ;Underlined
	GuiCtrlSetColor(-1, 0x555555)

	GUICtrlCreateLabel("Rizonesoft Home: ", 10, 90, 130, 15, $SS_RIGHT)
	$abHome = GUICtrlCreateLabel("http://www.rizonesoft.com", 145, 90, 230, 15)
	GuiCtrlSetFont($abHome, 8.5, -1, 4) ;Underlined
	GuiCtrlSetColor($abHome, 0x0000FF)
	GuiCtrlSetCursor($abHome, 0)
	GUICtrlCreateLabel("Support: ", 10, 108, 130, 15, $SS_RIGHT)
	$abSupport = GUICtrlCreateLabel("http://www.rizonesoft.com/contact-us", 145, 108, 230, 15)
	GuiCtrlSetFont($abSupport, 8.5, -1, 4) ;Underlined
	GuiCtrlSetColor($abSupport, 0x0000FF)
	GuiCtrlSetCursor($abSupport, 0)
	GUICtrlCreateLabel("License: ", 10, 130, 130, 15, $SS_RIGHT)

	$abLicense = GUICtrlCreateLabel("No Nonsense version 1.3", 145, 130, 159, 15)
	GuiCtrlSetFont($abLicense, 8.5, -1, 4) ;Underlined
	GuiCtrlSetColor($abLicense, 0x0000FF)
	GuiCtrlSetCursor($abLicense, 0)

	Local $ScriptDirSplt = StringSplit(@ScriptDir, "\")
	Local $ScriptDrive  = $ScriptDirSplt[1]
	Local $drvSpaceUsed = DriveSpaceTotal($ScriptDrive) - DriveSpaceFree($ScriptDrive)

	$abSpaceLabel = GUICtrlCreateLabel("(" & $ScriptDrive & ") " & Round(DriveSpaceFree($ScriptDrive) / 1024, 1) & " GB free of " & _
					Round(DriveSpaceTotal($ScriptDrive) / 1024, 1) & " GB", 15, 180, 300, 15)
	$abSpaceProg = GUICtrlCreateProgress(15, 200, 350, 15)
	GUICtrlSetData($abSpaceProg, ($drvSpaceUsed / DriveSpaceTotal($ScriptDrive)) * 100)
	$abBtnOK = GUICtrlCreateButton("OK", 250, 250, 123, 33, $BS_DEFPUSHBUTTON)

	$abRSS = GUICtrlCreateIcon(@ScriptFullPath, 201, 20, 250, 32, 32)
	GUICtrlSetCursor($abRSS, 0)
	$abFacebook = GUICtrlCreateIcon(@ScriptFullPath, 202, 57, 250, 32, 32)
	GUICtrlSetCursor($abFacebook, 0)
	$abTwittter = GUICtrlCreateIcon(@ScriptFullPath, 203, 94, 250, 32, 32)
	GUICtrlSetCursor($abTwittter, 0)
	$abPP = GUICtrlCreateIcon(@ScriptFullPath, 204, 150, 250, 32, 32)
	GUICtrlSetCursor($abPP, 0)

	GUICtrlSetOnEvent($abHome, "_RizoneHome")
	GUICtrlSetOnEvent($abPP, "_DonateSomething")
	GUICtrlSetOnEvent($abSupport, "_Support")
	GUICtrlSetOnEvent($abLicense, "_NoNonsense")
	GUICtrlSetOnEvent($abRSS, "_SubscribeInReader")
	GUICtrlSetOnEvent($abFacebook, "_OpenFacebook")
	GUICtrlSetOnEvent($abTwittter, "_FollowOnTwitter")
	GUICtrlSetOnEvent($abBtnOK, "_CloseAboutDlg")

	GUISetState(@SW_SHOW, $AboutDlg)


EndFunc

Func _CloseAboutDlg()

	GuiCtrlSetState($hlpAbout, $GUI_ENABLE)
	Opt("GUIOnEventMode", 0)
	GUIDelete($aboutDlg)

EndFunc

Func _DonateSomething()
	ShellExecute("https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=CEZABT5KGTU74&lc=ZA&item_name=Rizonesoft&currency_code=USD&bn=PP%2dDonationsBF%3abtn_donateCC_LG%2egif%3aNonHosted")
EndFunc


Func _RizoneHome()
	ShellExecute("http://www.rizonesoft.com")
EndFunc


Func _Support()
	ShellExecute("http://www.rizonesoft.com/contact-us")
EndFunc


Func _NoNonsense()
	ShellExecute("http://www.rizonesoft.com/no-nonsense/")
EndFunc


Func _SubscribeInReader()
	ShellExecute("http://www.rizonesoft.com/feed/")
EndFunc


Func _OpenFacebook()
	ShellExecute("http://www.facebook.com/rizonesoft")
EndFunc


Func _FollowOnTwitter()
	ShellExecute("http://twitter.com/Rizonesoft")
EndFunc