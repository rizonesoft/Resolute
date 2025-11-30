#NoTrayIcon
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=Resources\Ownership.ico
#AutoIt3Wrapper_Outfile=Ownership.exe
#AutoIt3Wrapper_Outfile_x64=Ownership64Bit.exe
#AutoIt3Wrapper_UseUpx=y
#AutoIt3Wrapper_Compile_Both=y
#AutoIt3Wrapper_UseX64=y
#AutoIt3Wrapper_Res_Fileversion=0.1.2.121
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=y
#AutoIt3Wrapper_Res_LegalCopyright=© 2014, Rizonesoft
#AutoIt3Wrapper_Res_requestedExecutionLevel=requireAdministrator
#AutoIt3Wrapper_Res_Icon_Add=Resources\Donate.ico
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.10.2
 Author:         Rizonesoft (www.rizonesoft.com)

 Script Function:
	Install Take Ownership Shell Extension.

#ce ----------------------------------------------------------------------------


Opt("MustDeclareVars", 1)
Opt("TrayMenuMode", 3) ;~ Default tray menu items (Script Paused/Exit) will not be shown.
Opt("GUIOnEventMode", 1)


#include <WindowsConstants.au3>
#include <StaticConstants.au3>
#include <ButtonConstants.au3>
#include <GUIConstantsEx.au3>
#include <Constants.au3>
#include <Misc.au3>

#include "UDF\Functions.au3"


;~ Rizonesoft Application Settings
Global Const $APPSET_TITLE = "Ownership"
Global Const $APPSET_VERSION = _GetExecVersioning(@ScriptFullPath, 5)

Global $OWNERSHIP_GUI, $LBL_DESCRIPTION, $BTN_INSTALL, $CHK_INSWPAUSE


_Singleton(@ScriptName, 0)

If Not @AutoItX64 And @OSArch = "X64" Then

	Local $Ownership64Bit = @ScriptDir & "\Ownership64Bit.exe"

	If FileExists($Ownership64Bit) Then
		ShellExecute($Ownership64Bit)
		_CloseOwnership()
	Else

		If Not IsDeclared("iMsgBox") Then Local $iMsgBox
		$iMsgBox = MsgBox(	$MB_YESNO + $MB_ICONEXCLAMATION + 262144, "Warning", _
							$APPSET_TITLE & " 32 Bit is not compatible with your Windows version. " & _
							"Please download " & $APPSET_TITLE & " 64 Bit. Would you like to visit the Download page " & _
							"now to download the 64 Bit version?", 60)
		Switch $iMsgBox
			Case  $IDYES
				ShellExecute("http://www.rizonesoft.com/freeware-downloads/")
				_CloseOwnership()
			Case -1, $IDNO
				_CloseOwnership()
		EndSwitch

	EndIf

Else

	If @OSVersion = "WIN_2000" Or @OSVersion = "WIN_XP" Or @OSVersion = "WIN_XPe" Or @OSVersion = "WIN_2003" Then
		MsgBox($MB_OK + $MB_ICONHAND + 262144, 	"Ownership", "This utility is not compatable with your version of windows. " & _
												"If you believe this to be an error, please feel free to email me at " & _
												"support@rizonesoft.com with all the details.", 30)
		Exit
	Else
		_StartCoreInterface()
	EndIf

EndIf


Func _StartCoreInterface()

	Local $BtnHelp, $LinkHome, $IcoDonate

	$OWNERSHIP_GUI = GUICreate($APPSET_TITLE & " " & $APPSET_VERSION, 350, 230, -1, -1)
	GUISetFont(9, 400, 0, "Verdana", $OWNERSHIP_GUI, 5)
	GUISetHelp("hh.exe " & @ScriptDir & "\Documents\Ownership.chm", $OWNERSHIP_GUI)

	GUICtrlCreateIcon(@ScriptFullPath, 99, 10, 10, 72, 72)
	$LBL_DESCRIPTION = GUICtrlCreateLabel("", 96, 15, 200, 40)
	$CHK_INSWPAUSE = GUICtrlCreateCheckbox("Install with Pause", 96, 68, 200, 20)
	$BTN_INSTALL = GUICtrlCreateButton("Install", 165, 100, 165, 33, $BS_DEFPUSHBUTTON)
	GUICtrlSetFont($BTN_INSTALL, 10)
	$BtnHelp = GUICtrlCreateButton("Help (F1)", 65, 100, 95, 33)

	GUICtrlCreateLabel("", 10, 150, 330, 2, $SS_ETCHEDHORZ)

	GUICtrlCreateLabel("© 2014 Rizonesoft", 10, 188, 195, 18)
	GUICtrlSetColor(-1, 0xC0C0C0)
	$LinkHome = GUICtrlCreateLabel("www.rizonesoft.com", 10, 205, 195, 18)
	GuiCtrlSetFont($LinkHome, 9, -1, 400, "", 5) ;Underlined
	GuiCtrlSetColor($LinkHome, 0x0000FF)
	GuiCtrlSetCursor($LinkHome, 0)

	$IcoDonate = GUICtrlCreateIcon(@ScriptFullPath, 201, 265, 155, 64, 64)
	GuiCtrlSetCursor($IcoDonate, 0)

	GUICtrlSetOnEvent($BtnHelp, "_OpenHelpDocumentation")
	GUICtrlSetOnEvent($BTN_INSTALL, "_InstallTakeOwnership")

	GUISetState(@SW_SHOW, $OWNERSHIP_GUI)

	GUISetOnEvent($GUI_EVENT_CLOSE, "_CloseOwnership")

	_GetOwnershipShellStatus()

	While 1
		Sleep(88)
	WEnd

EndFunc


Func _CloseOwnership()
	Exit
EndFunc


Func _OpenHelpDocumentation()
	ShellExecute("hh.exe", @ScriptDir & "\Documents\Ownership.chm")
EndFunc


Func _InstallTakeOwnership()

	Local $WithPause = ""

	If GUICtrlRead($BTN_INSTALL) = "Install" Then

		;~ Cleanup old ownership entries
		RegDelete("HKEY_CLASSES_ROOT\*\shell\takeownership")
		RegDelete("HKEY_CLASSES_ROOT\dllfile\shell\takeownership")
		RegDelete("HKEY_CLASSES_ROOT\exefile\shell\takeownership")
		RegDelete("HKEY_CLASSES_ROOT\Directory\shell\takeownership")
		;~ ==> Cleanup old ownership entries

		If GUICtrlRead($CHK_INSWPAUSE) = $GUI_CHECKED Then
			$WithPause = " && Pause"
		Else
			$WithPause = ""
		EndIf

		RegDelete("HKEY_CLASSES_ROOT\*\shell\runas")

		RegWrite("HKEY_CLASSES_ROOT\*\shell\runas", "", "REG_SZ", "Take Ownership")
		RegWrite("HKEY_CLASSES_ROOT\*\shell\runas", "HasLUAShield", "REG_SZ", "")
		RegWrite("HKEY_CLASSES_ROOT\*\shell\runas", "NoWorkingDirectory", "REG_SZ", "")

		RegWrite("HKEY_CLASSES_ROOT\*\shell\runas\command", "", "REG_SZ", _
			"cmd.exe /c takeown /f " & Chr(34) & "%1" & Chr(34) & " && icacls " & Chr(34) & "%1" & Chr(34) & " /grant administrators:F" & $WithPause)
		RegWrite("HKEY_CLASSES_ROOT\*\shell\runas\command", "IsolatedCommand", "REG_SZ", _
			"cmd.exe /c takeown /f " & Chr(34) & "%1" & Chr(34) & " && icacls " & Chr(34) & "%1" & Chr(34) & " /grant administrators:F" & $WithPause)

		RegDelete("HKEY_CLASSES_ROOT\dllfile\shell\runas")

		RegWrite("HKEY_CLASSES_ROOT\dllfile\shell\runas", "", "REG_SZ", "Take Ownership")
		RegWrite("HKEY_CLASSES_ROOT\dllfile\shell\runas", "HasLUAShield", "REG_SZ", "")
		RegWrite("HKEY_CLASSES_ROOT\dllfile\shell\runas", "NoWorkingDirectory", "REG_SZ", "")

		RegWrite("HKEY_CLASSES_ROOT\dllfile\shell\runas\command", "", "REG_SZ", _
			"cmd.exe /c takeown /f " & Chr(34) & "%1" & Chr(34) & " && icacls " & Chr(34) & "%1" & Chr(34) & " /grant administrators:F" & $WithPause)
		RegWrite("HKEY_CLASSES_ROOT\dllfile\shell\runas\command", "IsolatedCommand", "REG_SZ", _
			"cmd.exe /c takeown /f " & Chr(34) & "%1" & Chr(34) & " && icacls " & Chr(34) & "%1" & Chr(34) & " /grant administrators:F" & $WithPause)

		RegDelete("HKEY_CLASSES_ROOT\Directory\shell\runas")

		RegWrite("HKEY_CLASSES_ROOT\Directory\shell\runas", "", "REG_SZ", "Take Ownership")
		RegWrite("HKEY_CLASSES_ROOT\Directory\shell\runas", "HasLUAShield", "REG_SZ", "")
		RegWrite("HKEY_CLASSES_ROOT\Directory\shell\runas", "NoWorkingDirectory", "REG_SZ", "")

		RegWrite("HKEY_CLASSES_ROOT\Directory\shell\runas\command", "", "REG_SZ", _
			"cmd.exe /c takeown /f " & Chr(34) & "%1" & Chr(34) & " /r /d y && icacls " & Chr(34) & "%1" & Chr(34) & " /grant administrators:F /t" & $WithPause)
		RegWrite("HKEY_CLASSES_ROOT\Directory\shell\runas\command", "IsolatedCommand", "REG_SZ", _
			"cmd.exe /c takeown /f " & Chr(34) & "%1" & Chr(34) & " /r /d y && icacls " & Chr(34) & "%1" & Chr(34) & " /grant administrators:F /t" & $WithPause)

		RegDelete("HKEY_CLASSES_ROOT\Drive\shell\runas")

		RegWrite("HKEY_CLASSES_ROOT\Drive\shell\runas", "", "REG_SZ", "Take Ownership")
		RegWrite("HKEY_CLASSES_ROOT\Drive\shell\runas", "HasLUAShield", "REG_SZ", "")
		RegWrite("HKEY_CLASSES_ROOT\Drive\shell\runas", "NoWorkingDirectory", "REG_SZ", "")

		RegWrite("HKEY_CLASSES_ROOT\Drive\shell\runas\command", "", "REG_SZ", _
			"cmd.exe /c takeown /f " & Chr(34) & "%1" & Chr(34) & " /r /d y && icacls " & Chr(34) & "%1" & Chr(34) & " /grant administrators:F /t" & $WithPause)
		RegWrite("HKEY_CLASSES_ROOT\Drive\shell\runas\command", "IsolatedCommand", "REG_SZ", _
			"cmd.exe /c takeown /f " & Chr(34) & "%1" & Chr(34) & " /r /d y && icacls " & Chr(34) & "%1" & Chr(34) & " /grant administrators:F /t" & $WithPause)

	ElseIf GUICtrlRead($BTN_INSTALL) = "Uninstall" Then

		RegDelete("HKEY_CLASSES_ROOT\*\shell\runas")
		RegDelete("HKEY_CLASSES_ROOT\dllfile\shell\runas")
		RegDelete("HKEY_CLASSES_ROOT\Directory\shell\runas")
		RegDelete("HKEY_CLASSES_ROOT\Drive\shell\runas")

		RegWrite("HKEY_CLASSES_ROOT\exefile\shell\runas", "HasLUAShield", "REG_SZ", "")
		RegWrite("HKEY_CLASSES_ROOT\exefile\shell\runas\command", "", "REG_SZ", Chr(34) & "%1" & Chr(34) & " %*")
		RegWrite("HKEY_CLASSES_ROOT\exefile\shell\runas\command", "IsolatedCommand", "REG_SZ", Chr(34) & "%1" & Chr(34) & " %*")

	EndIf

	_GetOwnershipShellStatus()

EndFunc



Func _GetOwnershipShellStatus()

	If RegRead("HKEY_CLASSES_ROOT\*\shell\runas", "") Or _
		RegRead("HKEY_CLASSES_ROOT\dllfile\shell\runas", "") Or _
		RegRead("HKEY_CLASSES_ROOT\Directory\shell\runas", "") Or _
		RegRead("HKEY_CLASSES_ROOT\Drive\shell\runas", "") Then

		GUICtrlSetData($LBL_DESCRIPTION, "To uninstall the 'Take Ownership' right-click menu option, click the 'Uninstall' button.")
		GuiCtrlSetState($CHK_INSWPAUSE, $GUI_DISABLE)
		GUICtrlSetData($BTN_INSTALL, "Uninstall")

	Else

		GUICtrlSetData($LBL_DESCRIPTION, "To install the 'Take Ownership' right-click menu option, click the 'Install' button.")
		GuiCtrlSetState($CHK_INSWPAUSE, $GUI_ENABLE)
		GUICtrlSetData($BTN_INSTALL, "Install")

	EndIf

EndFunc
