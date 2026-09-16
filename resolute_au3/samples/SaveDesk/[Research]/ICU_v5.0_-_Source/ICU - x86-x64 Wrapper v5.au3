#NoTrayIcon
#region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=Desktop.ico
#AutoIt3Wrapper_Outfile=ICU.exe
#AutoIt3Wrapper_Compression=0
#AutoIt3Wrapper_UseUpx=n
#AutoIt3Wrapper_Res_Comment=© ICU - Icon Configuration Utility 2009-2013 by Karsten Funk. All rights reserved. http://www.funk.eu
#AutoIt3Wrapper_Res_Description=Icon Configuration Utility
#AutoIt3Wrapper_Res_Fileversion=5.0.0.0
#AutoIt3Wrapper_Res_LegalCopyright=Creative Commons License "by-nc-sa 3.0", this program is freeware under Creative Commons License "by-nc-sa 3.0" (http://creativecommons.org/licenses/by-nc-sa/3.0/us/)
#AutoIt3Wrapper_Res_requestedExecutionLevel=asInvoker
#AutoIt3Wrapper_Res_Field=ProductName|ICU
#AutoIt3Wrapper_Res_Field=AutoIt Version|%AutoItVer%
#AutoIt3Wrapper_Res_Field=Compile Date|%date% %time%
#AutoIt3Wrapper_Res_Field=Made By|Karsten Funk
#AutoIt3Wrapper_Tidy_Stop_OnError=n
#AutoIt3Wrapper_Run_Obfuscator=y
#Obfuscator_Parameters=/sf /sv /om /cs=0 /cn=0
#endregion ;**** Directives created by AutoIt3Wrapper_GUI ****

#cs
	######################################

	Icon Configuration Utility
	Script Version: 5.0
	by Karsten Funk 2009 - 2013
	2013-May-24

	AutoIt Version: 3.3.8.1
	- Desktop Contextmenu Integration (DCI) only works on Win7 or newer (new registry keys)

	Further Infos:
	MSDN - Creating Context Menu Handlers
	http://msdn.microsoft.com/en-us/library/cc144171%28VS.85%29.aspx

	IContextMenu Interface
	http://msdn.microsoft.com/en-us/library/bb776095%28v=VS.85%29.aspx

	Creating Shell Extension Handlers
	http://msdn.microsoft.com/en-us/library/cc144067%28v=VS.85%29.aspx

	######################################
#ce

Global $s_ICU_Version = "ICU_v_5"
Global $sFilename, $iPID, $timer

If Not FileExists(@ScriptDir & "\ICU") Then DirCreate(@ScriptDir & "\ICU")
Global $sConfig_Path = @ScriptDir & "\ICU"

Global $iFileinstallSwitch = 0
If IniRead(@ScriptDir & "\ICU\ICU.ini", "Settings", "Version", "") <> $s_ICU_Version Then
	$iFileinstallSwitch = 1
	IniWrite(@ScriptDir & "\ICU\ICU.ini", "Settings", "Version", $s_ICU_Version)
EndIf

If @OSArch = "X86" Then
	$sFilename = $sConfig_Path & "\ICU_32bit.exe"
	If FileGetVersion(@ScriptName) <> FileGetVersion($sFilename) Then FileDelete($sFilename)
	FileInstall("ICU_32bit.exe", $sFilename, $iFileinstallSwitch)
Else
	$sFilename = $sConfig_Path & "\ICU_64bit.exe"
	If FileGetVersion(@ScriptName) <> FileGetVersion($sFilename) Then FileDelete($sFilename)
	FileInstall("ICU_64bit.exe", $sFilename, $iFileinstallSwitch)
EndIf

If Not FileExists($sFilename) Then _Exit("Could not extract OSArch file to" & @CRLF & @CRLF & $sFilename)

RunWait(FileGetShortName($sFilename) & " " & $CmdLineRaw, $sConfig_Path)

Func _Exit($sMsg = "")
	If $sMsg Then MsgBox(16 + 262144, "ICU Install Error", $sMsg)
	Exit
EndFunc   ;==>_Exit