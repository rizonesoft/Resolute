#include-once

#include <Misc.au3>

#include "ReBar_Declarations.au3"
#include "ReBar_Functions.au3"


OnAutoItExitRegister("_OnReBarExit")


If Not @Compiled Then

	$g_ReBarCompName = $g_ReBarRunCompName
	$g_ReBarProgName = $g_ReBarRunProgName
	$g_ReBarIcon = $g_ReBarRunIcon
	$g_ReBarIconHover = $g_ReBarRunIconHover
	$g_ReBarRunVersion = _AutoIt3Script_GetVersion(@ScriptFullPath, 0)

Else
	$g_ReBarRunVersion = FileGetVersion(@ScriptFullPath)
EndIf

$g_ReBarGuiTitle = _GUIGetTitle($g_ReBarProgName)

If _Singleton($g_ReBarGuiTitle, 1) = 0 And $g_ReBarSingleton = True Then
	MsgBox($MB_SYSTEMMODAL + $MB_ICONINFORMATION, "Warning", "Another occurence of " & $g_ReBarProgName & _
			" is already running. This message will self-destruct in " & _
			$g_ReBarMsgTimeout & " seconds.", $g_ReBarMsgTimeout)
	Exit
EndIf


Func _SetWorkingDirectories()

	If IniRead($g_ReBarPathIni, $g_ReBarShortName, "PortableEdition", 1) = 0 Then
		_SetAppDataDirectory()
	Else
		If Not _GenerateIniFile($g_ReBarPathIni) Then
			_SetAppDataDirectory()
		Else
			_ResetWorkingDirectories()
		EndIf
	EndIf

EndFunc   ;==>_SetWorkingDirectories


Func _SetAppDataDirectory()

	_CreateAppDataDirectories()

	$g_ReBarAppDataParent = @AppDataDir & "\" & $g_ReBarCompName
	$g_ReBarAppDataPath = $g_ReBarAppDataParent & "\" & $g_ReBarShortName
	$g_ReBarWorkingDir = $g_ReBarAppDataPath

	_ResetWorkingDirectories()
	_GenerateIniFile($g_ReBarPathIni, 0)

EndFunc   ;==>_SetAppDataDirectory


Func _ResetWorkingDirectories()

	$g_ReBarIniFileName = $g_ReBarShortName & ".ini"
	$g_ReBarPathIni = $g_ReBarWorkingDir & "\" & $g_ReBarIniFileName
	$g_ReBarCacheBase = $g_ReBarWorkingDir & "\Cache"
	$g_ReBarCachePath = $g_ReBarCacheBase & "\" & $g_ReBarShortName
	$g_ReBarLogFilename = $g_ReBarShortName & ".log"
	$g_ReBarLogBase = $g_ReBarWorkingDir & "\Logging\" & $g_ReBarShortName
	$g_ReBarLogPath = $g_ReBarLogBase & "\" & $g_ReBarLogFilename

	If $g_ReBarCacheEnabled == 1 Then DirCreate($g_ReBarCachePath)

EndFunc


Func _GenerateIniFile($iniPath, $bPortable = 1)

	Local $iResult

	$iResult = IniWrite($iniPath, $g_ReBarShortName, "PortableEdition", $bPortable)
	Return $iResult

EndFunc   ;==>_GenerateIniFile


Func _CreateAppDataDirectories()

	DirCreate($g_ReBarAppDataParent)
	DirCreate($g_ReBarAppDataPath)

EndFunc   ;==>_CreateAppDataDirectories
