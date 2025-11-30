#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.2.0
 Author:         Rizone Technologies (Derick Payne)

 Script Function:
	Control Panel Functions.

#ce ----------------------------------------------------------------------------


Func _StartControlPanelgodMode()
	Run('cmd /cstart "AUTOIT-Tweak-Mode" shell:::{ED7BA470-8E54-465E-825C-99712043E01C}', @ScriptDir, @SW_HIDE)
EndFunc


Func _StartActionCenter()
	Run('cmd /cstart "AUTOIT-Tweak-Mode" shell:::{BB64F8A7-BEE7-4E1A-AB8D-7D8273F7FDB6}', @ScriptDir, @SW_HIDE)
EndFunc


Func _StartBackupAndRestore()
	Run('cmd /cstart "AUTOIT-Tweak-Mode" shell:::{B98A2BEA-7D42-4558-8BD1-832F41BAC6FD}', @ScriptDir, @SW_HIDE)
EndFunc
