#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.8.0
 Author:         Rizonesoft

 Script Function:
	Repair Explorer Function.

#ce ----------------------------------------------------------------------------


#include-once
#include <CoreWinRepair.au3>


Func _RestoreFolderOptions()

	_StartLogging("Restoring Folder Options, please wait...")
	_MemoLoggingWrite("Clearing Group Policies.")
	RegDelete("HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer", "NoFolderOption")

	_BroadcastChange()

	_MemoLoggingWrite("You should be able to change Folder Options now.", 1)
	_EndLogging()

EndFunc


Func _EnableShowHiddenFiles()

	_StartLogging("Enabling Show Hidden Files and Folders, please wait...")
	Switch @OSVersion

		Case "WIN_7"
			_MemoLoggingWrite("Restoring default configurations.")
			RegDelete("HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\Current Version\Explorer\Advanced\Folder\Hidden\SHOWALL", "CheckedValue")
			RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\Folder\Hidden\SHOWALL", "CheckedValue", "REG_DWORD", "0x00000001")


		Case Else
			_MemoLoggingWrite("Unsupported Operating System", 3)
			_EndLogging()
			Return
	EndSwitch

	_BroadcastChange()

	_MemoLoggingWrite("", 1)
	_EndLogging()

EndFunc


Func _RestoreAudioCD()

	_StartLogging("Restoring Audio CD protocol associations, please wait...")
	Switch @OSVersion
		Case "WIN_7"
			RegDelete("HKEY_CLASSES_ROOT\AudioCD")
			RegWrite("HKEY_CLASSES_ROOT\AudioCD", "BaseClass", "REG_SZ", "Drive")
			RegWrite("HKEY_CLASSES_ROOT\AudioCD", "FriendlyTypeName", "REG_SZ", "@shell32.dll,-10144")
			RegWrite("HKEY_CLASSES_ROOT\AudioCD", "", "REG_SZ", "AudioCD")
			RegWrite("HKEY_CLASSES_ROOT\AudioCD", "EditFlags", "REG_BINARY", "02001000")
			RegWrite("HKEY_CLASSES_ROOT\AudioCD\DefaultIcon", "", "REG_EXPAND_SZ", "%SystemRoot%\system32\shell32.dll,40")
			RegWrite("HKEY_CLASSES_ROOT\AudioCD\shell", "", "REG_SZ", "Play")
			RegWrite("HKEY_CLASSES_ROOT\AudioCD\shell\play", "", "REG_SZ", "&Play")
			RegWrite("HKEY_CLASSES_ROOT\AudioCD\shell\play", "MUIVerb", "REG_EXPAND_SZ", "@%SystemRoot%\system32\unregmp2.exe,-9991")
			RegWrite("HKEY_CLASSES_ROOT\AudioCD\shell\play\command", "", "REG_EXPAND_SZ", Chr(34) & "%ProgramFiles%\Windows Media Player\wmplayer.exe" & Chr(34) & " /prefetch:3 /device:AudioCD " & Chr(34) & "%L" & Chr(34))
			_BroadcastChange()

		Case Else
			_MemoLoggingWrite("Unsupported Operating System", 3)
			_EndLogging()
			Return
	EndSwitch
	_MemoLoggingWrite("Hope your computer still works.", 1)
	_EndLogging()

EndFunc