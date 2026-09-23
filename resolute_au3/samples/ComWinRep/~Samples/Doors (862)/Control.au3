#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.7.18 (beta)
 Author:         Rizonesoft (Derick Payne)

 Script Function:
	Rizonesoft Doors Control Panel.

#ce ----------------------------------------------------------------------------


#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=Resources\Control\Control.ico
#AutoIt3Wrapper_Res_Description=Doors Control Panel
#AutoIt3Wrapper_Res_Fileversion=0.0.6.74
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=y
#AutoIt3Wrapper_Res_LegalCopyright=© 2012 Rizonesoft
#AutoIt3Wrapper_Res_Icon_Add=Resources\Control\Home.ico
#AutoIt3Wrapper_Res_Icon_Add=Resources\Control\Display.ico
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****


Opt("GUICloseOnESC", 0)         	;1=ESC  closes, 0=ESC won't close
;Opt("GUIOnEventMode", 1)        	;0=disabled, 1=OnEvent mode enabled
Opt("MustDeclareVars", 1)       	;0=no, 1=require pre-declare
;Opt("SendCapslockMode", 1)      	;1=store and restore, 0=don't
Opt("TrayAutoPause", 0)          	;0=no pause, 1=Pause
Opt("TrayIconDebug", 1)         	;0=no info, 1=debug line info
;Opt("TrayOnEventMode", 0)        	;0=disable, 1=enable


;#Include <Date.au3>
#Include <GuiButton.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
;#include <WindowsConstants.au3>

#include <UDF\FunctionsDoors.au3>
#include <UDF\ConstantsDoors.au3>


Global $CONTROL_INTERFACE
Global $SETTING_FNTQLTY = IniRead($DOORS_SYSTEM_INI, "Appearance", "FontQuality", 5)
Global $CHK_HIGHQLTFNTS, $BTN_APPLY


_BuildControlInterface()


Func _BuildControlInterface()

	Local $GUIMsg, $mainTab, $icoGUI
	Local $btnHome, $homePage
	Local $btnAppearance, $appearancePage, $appearanceGroup
	Local $btnOK, $btnCancel

	$CONTROL_INTERFACE = GUICreate("Doors " & _GetDoorsVersion(1) & " Control Panel " & FileGetVersion(@ScriptFullPath), 650, 500)
	GUISetFont(8.5, 400, -1, "Verdana", $CONTROL_INTERFACE, $SETTING_FNTQLTY)

	$icoGUI = GUICtrlCreateIcon(@ScriptFullPath, 99, 46, 10, 48, 48, $SS_NOTIFY)

	$btnHome = GUICtrlCreateButton("Home", 10, 68, 130, 30)
	$btnAppearance = GUICtrlCreateButton("Appearance", 10, 100, 130, 30)

	$mainTab = GUICtrlCreateTab(150, -25, 525, 470)

	$homePage = GUICtrlCreateTabItem("Home")
	GUICtrlCreateTabitem ("")

	$appearancePage = GUICtrlCreateTabItem("Appearance")
	$CHK_HIGHQLTFNTS = GUICtrlCreateCheckbox(" Enable high quality fonts", 180, 45)
	GUICtrlSetTip($CHK_HIGHQLTFNTS, 	"anti-aliasing (font smoothing)", _
										"Enable high quality fonts", 1, 1)
	$appearanceGroup = GuiCtrlCreateGroup("Appearance", 165, 10, 470, 370)
	GUICtrlSetFont($appearanceGroup, 10)
	GUICtrlCreateGroup("", -99, -99, 1, 1)  ;~ Close group
	GUICtrlCreateTabitem ("")

	$btnOK = GUICtrlCreateButton("OK", 300, 450, 100, 30)
	$btnCancel = GUICtrlCreateButton("Cancel", 400, 450, 100, 30)
	$BTN_APPLY = GUICtrlCreateButton("Apply", 500, 450, 100, 30)
	GuiCtrlSetState($BTN_APPLY, $GUI_DISABLE)

	If $SETTING_FNTQLTY == 5 Then GUICtrlSetState($CHK_HIGHQLTFNTS, $GUI_CHECKED)

	GUICtrlSetImage($icoGUI, @ScriptFullPath, 201)

	GUISetState(@SW_SHOW)

	While 1

		$GUIMsg = GUIGetMsg()

		Switch $GUIMsg
			Case $btnHome
				GUICtrlSetImage($icoGUI, @ScriptFullPath, 201)
				GUICtrlSetState($homePage, $GUI_SHOW)
			Case $btnAppearance
				GUICtrlSetImage($icoGUI, @ScriptFullPath, 202)
				GUICtrlSetState($appearancePage, $GUI_SHOW)
			Case $CHK_HIGHQLTFNTS
				GuiCtrlSetState($BTN_APPLY, $GUI_ENABLE)
			Case $btnCancel
				_CloseMe()
			Case $btnOK
				_ApplySettings()
				_CloseMe()
			Case $BTN_APPLY
				_ApplySettings()
			Case $GUI_EVENT_CLOSE
				_CloseMe()
		EndSwitch

	WEnd


EndFunc


Func _ApplySettings()

	If GUICtrlRead($CHK_HIGHQLTFNTS) = $GUI_CHECKED Then
		$SETTING_FNTQLTY = 5
	ElseIf GUICtrlRead($CHK_HIGHQLTFNTS) = $GUI_UNCHECKED Then
		$SETTING_FNTQLTY = 3
	EndIf

	IniWrite($DOORS_SYSTEM_INI, "Appearance", "FontQuality", $SETTING_FNTQLTY)

	GuiCtrlSetState($BTN_APPLY, $GUI_DISABLE)

EndFunc


Func _CloseMe()

	GUIDelete($CONTROL_INTERFACE)
	Exit

EndFunc