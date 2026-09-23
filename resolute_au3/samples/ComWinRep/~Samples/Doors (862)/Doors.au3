#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Version=Beta
#AutoIt3Wrapper_Icon=Resources\Doors.ico
#AutoIt3Wrapper_UseUpx=n
#AutoIt3Wrapper_Res_Fileversion=0.0.0.87
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=y
#AutoIt3Wrapper_Res_requestedExecutionLevel=highestAvailable
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.8.0
 Author:         Rizonesoft (Derick Payne)

 Script Function:
	Rizonesoft Doors

#ce ----------------------------------------------------------------------------


Opt("TrayMenuMode", 1) ; Default tray menu items (Script Paused/Exit) will not be shown.
Opt("GUIOnEventMode", 1)
Opt("MustDeclareVars", 1)


#include <UDF\GuiSplash.au3>
#include <UDF\GuiMenuEx.au3>


_LoaderStart()
_LoaderUpdate(1)

Global Const $DoorsTitle = "Rizonesoft Doors 1"
Global Const $DoorsVersion =  FileGetVersion(@ScriptFullPath)

Global Const $CommonMnuRes = @ScriptDir & "\Structure\commnures.dll"

Global $doorsForm

Global $mainMenu, $structMenu


_LoaderUpdate(2)
_CheckIntegrity()
_LoaderUpdate(3)
_mainGUI()


Func _mainGUI()

	$doorsForm = GUICreate($DoorsTitle & " : " & $DoorsVersion, 750, 550, -1, -1)
	GUISetFont(8.5, 400, 0, "Verdana")
	GUISetBkColor(0xEBEBEB)

	_GUICtrlMenuEx_Startup()

	_LoaderUpdate(4)
	; ===============================================================================================================================
	; Structure Menu
	; ===============================================================================================================================

	GUISetOnEvent(-3, "_CLoseDoors") ;~ $GUI_EVENT_CLOSE = -3

	_LoaderUpdate(6)
	;_WinAPI_DestroyIcon($structIco01)


	GUISetState(@SW_SHOW, $doorsForm)

	_LoaderUpdate(100)

	While 1
		Sleep(50) ; Idle
	WEnd

EndFunc


Func _CheckIntegrity()

	If Not FileExists($CommonMnuRes) Then
		MsgBox(262192, 	"Resource not found!", "An important resource file could not be found @ [" & $CommonMnuRes & "]. " & _
						"Although Doors can still function without it, the menus will display without pretty little icons." & @CRLF, 60)

	EndIf

EndFunc


Func _CloseDoors()

	;;_GUICtrlMenuEx_DestroyMenu($structMenu)

	GUIDelete($doorsForm)
	Exit

EndFunc