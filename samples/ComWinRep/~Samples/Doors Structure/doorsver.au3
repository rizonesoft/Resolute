#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_icon=Resources\doorsver.ico
#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_Res_Description=Doors Version Reporter
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=y
#AutoIt3Wrapper_Res_LegalCopyright=© Rizone Technologies, All rights reserved
#AutoIt3Wrapper_Res_Language=1033
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****



#NoTrayIcon

Opt("MustDeclareVars", 1)       	;0=no, 1=require pre-declare
Opt("GUICloseOnESC", 1)         	;1=ESC  closes, 0=ESC won't close
Opt("GUIOnEventMode", 0)        	;0=disabled, 1=OnEvent mode enabled
Opt("MustDeclareVars", 1)       	;0=no, 1=require pre-declare
Opt("SendCapslockMode", 1)      	;1=store and restore, 0=don't
Opt("TCPTimeout", 250)           	;100 milliseconds
Opt("TrayAutoPause", 0)          	;0=no pause, 1=Pause
Opt("TrayIconDebug", 1)         	;0=no info, 1=debug line info
Opt("TrayIconHide", 1)          	;0=show, 1=hide tray icon
Opt("TrayMenuMode", 3)           	;0=append, 1=no default menu, 2=no automatic check, 4=menuitemID  not return
Opt("TrayOnEventMode", 0)        	;0=disable, 1=enable


#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>


Global Const $doorsVersion = IniRead(@ScriptDir & "\doorsver.sys", "Doors", "version", 0)
Global Const $doorsBuild = IniRead(@ScriptDir &  "\doorsver.sys", "Doors", "build", 0)

Global $dverGUI, $dvnMsg


$dverGUI = GUICreate("About Doors", 450, 370, 497, 272)
GUISetFont(8.5, 400, -1, "Tahoma", $dverGUI, 5)
GUISetBkColor(0xFFFFFF)

GUICtrlCreatePic(@ScriptDir & "\Doors.bmp", 20, 10, 400, 100)
GuiCtrlCreateLabel($doorsVersion, 350, 0, 100, 100)
GUICtrlSetFont(-1, 72, 400, -1, "Tahoma", 5)
GUICtrlSetColor(-1, 0x3166AC)

GUICtrlCreateLabel("", 5, 110, 440, 2, $SS_ETCHEDHORZ)
GuiCtrlCreateLabel(	"Rizone Doors" & @CRLF & _
					"Version " & $doorsVersion & " (Build " & $doorsBuild & ")" & @CRLF & _
					"Copyright © 2011 Rizone Technologies. All rights reserved." & @CRLF & _
					"The Doors system is governed by the NoNonsense license. Unfortunately included utilities from other " & _
					"companies does not follow our NoNonsense policies and has included licenses that you should read " & _
					"first before using Doors. ", 25, 120, 400, 150)
GuiCtrlCreateLabel(	"This product is licensed under the Rizone NoNonsense License to: " & @UserName, 25, 270, 400, 100)

GUISetState(@SW_SHOW)


While 1
	$dvnMsg = GUIGetMsg()
	Switch $dvnMsg
		Case $GUI_EVENT_CLOSE
			Exit

	EndSwitch
WEnd