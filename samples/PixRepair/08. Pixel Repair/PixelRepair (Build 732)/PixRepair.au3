#NoTrayIcon

#Region
#AutoIt3Wrapper_Icon=Resources\PixRepair.ico
#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_UseUpx=y
#AutoIt3Wrapper_Res_Description=Repair stuck LCD pixels and burnt in images.
#AutoIt3Wrapper_Res_Fileversion=0.0.0.733
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=y
#AutoIt3Wrapper_Res_LegalCopyright=Copyright © 2015, Rizonesoft
#AutoIt3Wrapper_Res_Icon_Add=Resources\YouTube.ico
#AutoIt3Wrapper_Res_Icon_Add=Resources\Facebook.ico
#AutoIt3Wrapper_Res_Icon_Add=Resources\Twitter.ico
#AutoIt3Wrapper_Res_Icon_Add=Resources\Google.ico
#AutoIt3Wrapper_Res_Icon_Add=Resources\Pinterest.ico
#AutoIt3Wrapper_Res_Icon_Add=Resources\RSS.ico
#AutoIt3Wrapper_Res_Icon_Add=Resources\Donate.ico
#AutoIt3Wrapper_Res_Icon_Add=Resources\sa.ico
#EndRegion


Opt("GUICloseOnESC", 1) ; Default tray menu items (Script Paused/Exit) will not be shown.
Opt("GUIOnEventMode", 1)
Opt("MustDeclareVars", 1)


;#include <WindowsConstants.au3>
#include <GuiConstantsEx.au3>
#include <Misc.au3>

#include "UDF\CoreConstants.au3"
#include "UDF\CoreFunctions.au3"


Global $GUI_PIXREPAIR, $MNU_FILE, $MNU_HELP


_CoreGUI()


Func _CoreGUI()

	Local $miFileVideo, $miFileYouTube, $miFileClose, $miHelpAbout
	Local $pixIcon

	$GUI_PIXREPAIR = GUICreate(_GUIGetTitle($PROG_NAME), 530, 510, -1, -1)
	GUISetFont(8.5, 400, 0, "Verdana", $GUI_PIXREPAIR, $CONF_FONTQUALITY)

	GUISetOnEvent($GUI_EVENT_CLOSE, "_CloseClicked", $GUI_PIXREPAIR)

	$MNU_FILE = GUICtrlCreateMenu("&File")
	$miFileVideo = GUICtrlCreateMenuItem("&Pixel Repair Videos", $MNU_FILE)
	$miFileVideo = GUICtrlCreateMenuItem("&Pixel Repair Videos on YouTube", $MNU_FILE)
	GUICtrlCreateMenuItem("", $MNU_FILE)
	$miFileClose = GUICtrlCreateMenuItem("&Close" & @TAB & "Esc", $MNU_FILE)
	$MNU_HELP = GUICtrlCreateMenu("&Help")
	$miHelpAbout = GUICtrlCreateMenuItem("&About...", $MNU_HELP)

	$pixIcon = GUICtrlCreateIcon(@ScriptFullPath, 99, 10, 5, 64, 64)
	GUICtrlCreateLabel(	"Repair stuck pixels or burnt in images on LCD screens.", 85, 5, 185, 30)
	GUICtrlSetColor(-1, 0x666666)
	GUICtrlSetFont($pixIcon, 9)


GUICtrlCreateIcon(@ScriptFullPath, 201, 85, 40, 24, 24)
GUICtrlSetCursor(-1, 0)
GUICtrlCreateLabel(	"Now also on YouTube for phones and tablets.", 115, 40, 150, 30)
GUICtrlSetColor(-1, 0xB3201D)

	GUICtrlCreateGroup("1)  Dead pixel locator", 10, 80, 260, 290)
	GUICtrlCreateLabel("", 20, 115, 10, 25)
	GUICtrlSetBkColor(-1, 0xFFFFFF)
	GUICtrlCreateGroup("", -99, -99, 1, 1) ; Close Group

	GUISetState(@SW_SHOW, $GUI_PIXREPAIR)

	;_CheckForUpdates()


	While 1
		Sleep(50)
	WEnd

EndFunc


Func _CloseClicked()

	GUIDelete($GUI_PIXREPAIR)
	Local $PID = ProcessExists(@ScriptName) ; Will return the PID or 0 if the process isn't found.
	If $PID Then ProcessClose(@ScriptName)
	Exit

EndFunc