#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.2.0
 Author:         Rizone Technologies (Derick Payne)

 Script Function:
	Control Panel Functions.

#ce ----------------------------------------------------------------------------


Func _StartControlPanelgodMode()
	Run('cmd /cstart "AUTOIT-Tweak-Mode" shell:::{ED7BA470-8E54-465E-825C-99712043E01C}', @ScriptDir, @SW_HIDE)
EndFunc






