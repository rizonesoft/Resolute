#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.2.0
 Author:         Rizone Technologies (Derick Payne)

 Script Function:
	Administration Functions.

#ce ----------------------------------------------------------------------------


Func _StartBiometricDevices()
	Run('cmd /cstart "AUTOIT-Tweak-Mode" shell:::{0142e4d0-fb7a-11dc-ba4a-000ffe7ab428}', @ScriptDir, @SW_HIDE)
EndFunc
