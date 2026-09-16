#include-once

; Start the Control Panel
Func _StartControlPanel()
	_CheckControlPanelDisabled()
	ShellExecute(@SystemDir & "\control.exe")
	If @error Then
		_MemoLogWrite("The Windows Control Panel could not be started.", 2)
	EndIf
EndFunc

; Start Change or Remove Programs (Uninstall or Change a Program)
Func _StartChangeRemovePrograms()
	ShellExecute("control", "appwiz.cpl")
	_ControlPanelErrorHandler(@error)
EndFunc

; Start Add New Programs (Install a Program From the Network)
Func _StartAddNewPrograms()
	ShellExecute("control", "appwiz.cpl,,1")
	_ControlPanelErrorHandler(@error)
EndFunc

; Start Add / Remove Windows Components (Turn Windows Features On or Off)
Func _StartAddRemoveWindowsComponents()
	If @OSVersion = "WIN_VISTA" OR @OSVersion = "WIN_2008" Then
		ShellExecute("optionalfeatures")
		_ControlPanelErrorHandler(@error)
	Else
		ShellExecute("control", "appwiz.cpl,,2")
		_ControlPanelErrorHandler(@error)
	EndIf
EndFunc

; Start Program Access and Defaults
Func _StartProgramAccessDefaults()
	ShellExecute("control", "appwiz.cpl,,3")
	_ControlPanelErrorHandler(@error)
EndFunc

Func _StartAccessibilityOptions()
	ShellExecute("control", "access.cpl")
	_ControlPanelErrorHandler(@error)
EndFunc

; Start Automatic Updates (Windows Update)
Func _StartAutomaticUpdates()
	ShellExecute("control", "wuaucpl.cpl")
	_ControlPanelErrorHandler(@error)
EndFunc

Func _StartDateTimeProperties()
	ShellExecute("control", "timedate.cpl")
	_ControlPanelErrorHandler(@error)
EndFunc

Func _StartDirectXTroubleshooter()
	ShellExecute("dxdiag.exe")
	_ControlPanelErrorHandler(@error)
EndFunc

Func _StartDisplayProperties()
	ShellExecute("control", "desk.cpl")
	_ControlPanelErrorHandler(@error)
EndFunc

Func _StartColorAppearance()
	ShellExecute("control", "color")
	_ControlPanelErrorHandler(@error)
EndFunc

Func _StartFontManagement()
	ShellExecute("control", "fonts")
	_ControlPanelErrorHandler(@error)
EndFunc

Func _StartGameControllers()
	ShellExecute("control", "joy.cpl")
	_ControlPanelErrorHandler(@error)
EndFunc

Func _StartInternetProperties()
	ShellExecute("control", "inetcpl.cpl")
	_ControlPanelErrorHandler(@error)
EndFunc

Func _StartKeyboardProperties()
	ShellExecute("control", "keyboard")
	_ControlPanelErrorHandler(@error)
EndFunc

Func _StartMouseProperties()
	ShellExecute("control", "mouse")
	_ControlPanelErrorHandler(@error)
EndFunc



Func _StartFolderOptions()
	ShellExecute("control", "folders")
	_ControlPanelErrorHandler(@error)
EndFunc

Func _StartPhoneModemOptions()
	ShellExecute("control", "telephon.cpl")
	_ControlPanelErrorHandler(@error)
EndFunc

Func _StartPrintersFaxes()
	ShellExecute("control", "printers")
	_ControlPanelErrorHandler(@error)
EndFunc

Func _StartPowerOptions()
	ShellExecute("control", "powercfg.cpl")
	_ControlPanelErrorHandler(@error)
EndFunc

Func _StartSecurityCenter()
	ShellExecute("control", "wscui.cpl")
	_ControlPanelErrorHandler(@error)
EndFunc

Func _StartRegionalLanguageOptions()
	ShellExecute("control", "international")
	_ControlPanelErrorHandler(@error)
EndFunc

Func _StartScheduledTasks()
	ShellExecute("control", "schedtasks")
	_ControlPanelErrorHandler(@error)
EndFunc

Func _StartSoundAudioDeviceProperties()
	ShellExecute("control", "mmsys.cpl")
	_ControlPanelErrorHandler(@error)
EndFunc

Func _StartSystemProperties()
	ShellExecute("control", "sysdm.cpl")
	_ControlPanelErrorHandler(@error)
EndFunc

Func _StartUserAccounts()
	ShellExecute("control", "userpasswords")
	_ControlPanelErrorHandler(@error)
EndFunc

Func _ControlPanelErrorHandler($Error)
	If $Error Then
		_MemoLogWrite("The Control Panel applet could not be started.", 2)
	EndIf
EndFunc

Func _CheckControlPanelDisabled()
	Local $PolExpSysKey = "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer"
	Local $PolExpUserKey = "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer"

	If RegRead($PolExpSysKey, "NoControlPanel") = 1 Or _
	   RegRead($PolExpUserKey, "NoControlPanel") = 1 Then
		_MemoLogWrite("The Control Panel is disabled.", 2)
		$iMsgBoxAnswer = MsgBox(20, "Control Panel Disabled", "We have detected that the Control Panel is disabled on your computer. " & _
								"This could be due to your administrator disabling it or a virus attack. We can enable the Control " & _
								"Panel for you.  All you need to do is answer 'Yes' to enable it or 'No' to leave it disabled.",30)
		If $iMsgBoxAnswer = 6 Then
			RegWrite($PolExpSysKey, "NoControlPanel", "REG_DWORD", 0)
			RegWrite($PolExpUserKey, "NoControlPanel", "REG_DWORD", 0)
			_MemoLogWrite("The Control Panel should now be enabled.")
			_BootMessage()
		EndIf
	EndIf
EndFunc
