#NoTrayIcon
#region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=Desktop.ico
#AutoIt3Wrapper_Outfile=ICU_32bit.exe
#AutoIt3Wrapper_Outfile_x64=ICU_64bit.exe
#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_UseUpx=n
#AutoIt3Wrapper_Compile_Both=y
#AutoIt3Wrapper_UseX64=y
#AutoIt3Wrapper_Res_Comment=© ICU - Icon Configuration Utility 2009-2013 by Karsten Funk. All rights reserved. http://www.funk.eu
#AutoIt3Wrapper_Res_Description=Icon Configuration Utility
#AutoIt3Wrapper_Res_Fileversion=5.0.0.0
#AutoIt3Wrapper_Res_LegalCopyright=Creative Commons License "by-nc-sa 3.0", this program is freeware under Creative Commons License "by-nc-sa 3.0" (http://creativecommons.org/licenses/by-nc-sa/3.0/us/)
#AutoIt3Wrapper_Res_requestedExecutionLevel=asInvoker
#AutoIt3Wrapper_Res_Field=ProductName|ICU
#AutoIt3Wrapper_Res_Field=AutoIt Version|%AutoItVer%
#AutoIt3Wrapper_Res_Field=Compile Date|%date% %time%
#AutoIt3Wrapper_Res_Field=Made By|Karsten Funk
#AutoIt3Wrapper_Run_AU3Check=n
#AutoIt3Wrapper_Tidy_Stop_OnError=n
#AutoIt3Wrapper_Run_Obfuscator=y
#Obfuscator_Parameters=/sf /sv /om /cs=0 /cn=0
#endregion ;**** Directives created by AutoIt3Wrapper_GUI ****

#region DllOpen_PostProcessor START
Global $h_DLL_Kernel32 = DllOpen("kernel32.dll")
Global $h_DLL_User32 = DllOpen("user32.dll")
Global $h_DLL_Advapi32 = DllOpen("advapi32.dll")
Global $h_DLL_GDI32 = DllOpen("gdi32.dll")
Global $h_DLL_OLE32 = DllOpen("ole32.dll")
Global $h_DLL_OLEAut32 = DllOpen("oleaut32.dll")
Global $h_DLL_Crypt32 = DllOpen("Crypt32.dll")
#region DllOpen_PostProcessor END

Global $__CmdLineRaw = $CmdLineRaw
Global $__CmdLine[$CmdLine[0] + 1]
$__CmdLine[0] = $CmdLine[0]
For $i = 1 To $__CmdLine[0]
	$__CmdLine[$i] = $CmdLine[$i]
Next

#cs
	######################################

	Icon Configuration Utility
	Script Version: 5.0
	by Karsten Funk 2009 - 2013
	2013-May-24

	AutoIt Version: 3.3.8.1
	- Desktop Contextmenu Integration (DCI) only works on Win7 or newer (new registry keys)

	######################################
#ce

; 2013-May-24 - v4 > v5
; Improved Win8 compatibility (esp. Desktop Contextmenu Integration / DCI)
; Added "minimized" command line switch (to start GUI minimized to tray / autostart with windows), see program "About" for details on command line switches
; Added Tray Menu (esp. useful for Win XP) > see "minimized" switch. Also pressing ESC or minimizing the program will send ICU to the system tray now
; Added "toggle" command line switch
; Added "restore %resolution%" and "savereplace %resolution%" command line switches

Global $h_GUI_Main
Global $sGUITitle = "ICU - Icon Configuration Utility v5"
Global $s_ICU_Version = "ICU_v_5"
Global $hGUI_Help, $c_Help_Hyperlink_CC, $c_Help_Hyperlink_Funk
Global $b_GUI_Help_Exit = False, $b_GUI_Help_Tray_Save = False

Opt("GUICloseOnESC", 0)
Opt("TrayOnEventMode", 1)
Opt("TrayMenuMode", 1 + 2 + 4 + 8)
Opt("TrayAutoPause", 0)

If @OSArch = "X64" And Not @AutoItX64 Then
	_Tray_Show_Error_and_Exit("Fatal Error" & @CRLF & "This version of ICU is 32bit compiled and will not run correctly with a 64bit OS.")
ElseIf @OSArch <> "X64" And @AutoItX64 Then
	_Tray_Show_Error_and_Exit("Fatal Error" & @CRLF & "This version of ICU is 64bit compiled and will not run correctly with a 32bit OS.")
EndIf
If Not @AutoItX64 Then
	$sGUITitle &= " - 32bit"
Else
	$sGUITitle &= " - 64bit"
EndIf

If Not @Compiled Then $__CmdLineRaw = "" ; Remove none-compiled command line strings

If Not StringLen($__CmdLineRaw) Or StringInStr($__CmdLineRaw, "minimized") Then ; Open GUI Version of ICU
	If StringInStr($__CmdLineRaw, "minimized") Then
		$__CmdLine[0] = 0
		$__CmdLineRaw = "minimized" ; if minimized, all other options are dropped
	EndIf
	_EnforceSingleInstance('398cba7a-eca3-4470-a937-f0960a4595cb')
Else ; open command line Version of ICU
	_EnforceSingleInstance('498cba7a-eca3-4470-a937-f0960a4595cb')
EndIf

If StringInStr($__CmdLineRaw, "%resolution%") Then
	$__CmdLineRaw = StringReplace($__CmdLineRaw, "%resolution%", @DesktopWidth & "x" & @DesktopHeight & "x" & @DesktopDepth)
	For $i = 1 To $__CmdLine[0]
		$__CmdLine[$i] = StringReplace($__CmdLine[$i], "%resolution%", @DesktopWidth & "x" & @DesktopHeight & "x" & @DesktopDepth)
	Next
EndIf

Global $i_Color_OrangeRed = 0xFF4500
Global $i_Color_LimeGreen = 0x32CD32

#include <ButtonConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <ComboConstants.au3>
#include <WindowsConstants.au3>
#include <GuiListView.au3>
#include <Date.au3>
#include <File.au3>
#include <Winapi.au3>
#include <Constants.au3>
#include <GuiMenu.au3>
#include <WinAPIEx_3.8_3380\WinAPIEx.au3>
#include <GDIPlus.au3>

Global Const $STM_SETIMAGE = 0x0172

Global $hMouseHook = -1, $hMouseProc = -1
Global $i_GetDesktop_MousePos_Exit

Global $sConfig_FullPath, $sConfig_Path = @ScriptDir, $aScreen_Res
Global $hDeskWin, $h_Desktop_SysListView32


$timer_desktop_handle = TimerInit()
While TimerDiff($timer_desktop_handle) < 30000
	$hDeskWin = _WinGetDesktopHandle()
	$h_Desktop_SysListView32 = HWnd(@extended)
	If _GUICtrlListView_GetItemCount($h_Desktop_SysListView32) Then ExitLoop
	$h_Desktop_SysListView32 = ""
	Sleep(10)
WEnd
If Not IsHWnd($h_Desktop_SysListView32) Then
	_Tray_Show_Error_and_Exit("Desktop Window not found. ICU will exit now.")
EndIf

If BitAND(_WinAPI_GetWindowLong($h_Desktop_SysListView32, $GWL_STYLE), $LVS_AUTOARRANGE) Then
	If IniRead($sConfig_Path & "\ICU.ini", "Settings", "Checkbox_Warning_AutoArrange", $GUI_CHECKED) = $GUI_CHECKED Then
		TraySetState()
		TrayTip($sGUITitle & " - Warning", "Icon ""Auto Arrange"" is activated for the Desktop. This might prevent ICU from restoring the Icon positions properly. Deactivate ""Auto Arrange"" when restore does not work as intended.", 5, 1)
		Sleep(1000)
	EndIf
EndIf

If BitAND(_GUICtrlListView_GetExtendedListViewStyle($h_Desktop_SysListView32), $LVS_EX_SNAPTOGRID) Then
	If IniRead($sConfig_Path & "\ICU.ini", "Settings", "Checkbox_Warning_AlignToGrid", $GUI_CHECKED) = $GUI_CHECKED Then
		TraySetState()
		TrayTip($sGUITitle & " - Warning", "Icon ""Align to Grid"" is activated for the Desktop. This will might ICU from restoring the Icon positions properly. Deactivate ""Align to Grid"" when restore does not work as intended.", 5, 1)
		Sleep(1000)
	EndIf
EndIf

; Get list of existing config files
Global $aConfig_List = _FileListToArray($sConfig_Path, "*.icf", 1)

If $__WINVER > 0x0600 Then ; Windows 7 or later
	If Not IniRead($sConfig_Path & "\ICU.ini", "Settings", "Version", "") Then
		IniWrite($sConfig_Path & "\ICU.ini", "Settings", "Version", $s_ICU_Version)
		If MsgBox(4 + 32 + 262144, $sGUITitle & " - Install", "" & _
				"Do you want to enable ICU Desktop Contextmenu" & @CRLF & _
				"Integration (will write settings to registy / settings" & @CRLF & _
				"can be removed on main screen)?") = 6 Then
			IniWrite($sConfig_Path & "\ICU.ini", "Settings", "Desktop_Contextmenu_Integration", 1)
			If _DCI_Enable(True) Then MsgBox(64 + 262144, $sGUITitle & " - Install", "Desktop Contextmenu Integration IS enabled.")
		Else
			IniWrite($sConfig_Path & "\ICU.ini", "Settings", "Desktop_Contextmenu_Integration", 0)
			If _DCI_Enable(False) Then MsgBox(64 + 262144, $sGUITitle & " - Install", "Desktop Contextmenu Integration NOT enabled.")
		EndIf
	EndIf
Else
	If Not IniRead($sConfig_Path & "\ICU.ini", "Settings", "Version", "") Then IniWrite($sConfig_Path & "\ICU.ini", "Settings", "Version", $s_ICU_Version)
EndIf

Global $i_DCI_Is_Enabled = _DCI_Is_Enabled()

_GDIPlus_Startup()
OnAutoItExitRegister("_Exit_OnAutoItExitRegister")

Global $c_Button_Save, $c_Button_Restore, $c_Button_Delete, $c_Button_Duplicate, $c_Button_Show_Help, $c_Label_State, $c_Listview_Configs, $h_Listview_Configs
Global $c_Label_DCI_Status, $c_Button_DCI_Enable = 1, $c_Button_DCI_Disable = 1
Global $c_Hyperlink_CC, $c_Hyperlink_URL_homepage, $c_Hyperlink_Donate_Picture

$c_TrayItem_Save = TrayCreateItem("Save")
$c_TrayItem_Restore = TrayCreateMenu("Restore Config")
$c_TrayItem_Settings = TrayCreateItem("Settings")
$c_TrayItem_Exit = TrayCreateItem("Exit")
Global $a_TrayItem_Restore[1] = [0]

If $__WINVER > 0x0600 Then ; Windows 7 or later

	$h_GUI_Main = GUICreate($sGUITitle, 470, 337)
	_SetFont_hWnd(8.25, 400, 0, "Arial", $h_GUI_Main)

	$c_Button_Save = GUICtrlCreateButton("Save", 10, 175, 82, 25)
	$c_Button_Restore = GUICtrlCreateButton("Restore", 102, 175, 82, 25)
	$c_Button_Delete = GUICtrlCreateButton("Delete", 194, 175, 82, 25)
	$c_Button_Duplicate = GUICtrlCreateButton("Duplicate", 286, 175, 82, 25)
	$c_Button_Show_Help = GUICtrlCreateButton("About", 378, 175, 82, 25)

	GUICtrlCreateLabel("List of saved layouts (*.icf files), right click to edit", 10, 8, 400, 20)

	$c_Label_State = GUICtrlCreateLabel("Ready", 380, 7, 80, 16, $SS_CENTER + $SS_CENTERIMAGE)
	GUICtrlSetBkColor(-1, $i_Color_LimeGreen)

	$c_Listview_Configs = GUICtrlCreateListView("#|Name|Date|Resolution|Move unknown Icons", 10, 30, 450, 135, $LVS_SINGLESEL, $LVS_EX_FULLROWSELECT)
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_LV_ALTERNATE)
	$h_Listview_Configs = GUICtrlGetHandle($c_Listview_Configs)

	_GUICtrlListView_SetColumnWidth($h_Listview_Configs, 0, 20)
	_GUICtrlListView_SetColumnWidth($h_Listview_Configs, 1, 80 + 48 + 46)
	_GUICtrlListView_SetColumnWidth($h_Listview_Configs, 2, $LVSCW_AUTOSIZE_USEHEADER)
	_GUICtrlListView_SetColumnWidth($h_Listview_Configs, 3, $LVSCW_AUTOSIZE_USEHEADER)
	_GUICtrlListView_SetColumnWidth($h_Listview_Configs, 4, 80)

	If IsArray($aConfig_List) Then
		_Fill_ListView()
	Else
		GUICtrlCreateListViewItem("|No Layouts saved", $c_Listview_Configs)
		GUICtrlSetState($c_Button_Restore, $GUI_DISABLE)
		GUICtrlSetState($c_Button_Delete, $GUI_DISABLE)
	EndIf

	$c_Checkbox_Autosave = GUICtrlCreateCheckbox(" Create Shortcut on Save", 323, 206 + 15, 250, 17)
	GUICtrlSetState(-1, IniRead($sConfig_Path & "\ICU.ini", "Settings", "Checkbox_Autosave", $GUI_CHECKED))
	GUICtrlSetTip(-1, "ICU will automatically create a shortcut in" & @CRLF & "the program directory on saving a layout")

	GUICtrlCreateLabel("Command line usage ", 10, 208, 150, 13)
	_SetFont_Ctrl(-1, 7, 600, 0, "Arial")
	GUICtrlCreateLabel("See ""About"" for details", 127, 208, 100, 13)
	_SetFont_Ctrl(-1, 7, 400, 0, "Arial")

	GUICtrlCreateLabel("Warning on ", 10, 208 + 15, 70, 13)
	_SetFont_Ctrl(-1, 7, 600, 0, "Arial")

	$c_Checkbox_Warning_AutoArrange = GUICtrlCreateCheckbox(" Auto Arrange", 80, 206 + 15, 85, 17)
	GUICtrlSetState(-1, IniRead($sConfig_Path & "\ICU.ini", "Settings", "Checkbox_Warning_AutoArrange", $GUI_CHECKED))
	GUICtrlSetTip(-1, "If the Desktop ""Auto Arrange"" feature is activated, ICU will post a warning Message Box on start")
	$c_Checkbox_Warning_AlignToGrid = GUICtrlCreateCheckbox(" Align to Grid", 170, 206 + 15, 100, 17)
	GUICtrlSetState(-1, IniRead($sConfig_Path & "\ICU.ini", "Settings", "Checkbox_Warning_AlignToGrid", $GUI_CHECKED))
	GUICtrlSetTip(-1, "If the Desktop ""Align to Grid"" feature is activated, ICU will post a warning Message Box on start")

	GUICtrlCreateGroup(" ICU Desktop Contextmenu Integration (DCI) ", 10, 230 + 15, 450, 59)
	$c_Label_DCI_Status = GUICtrlCreateLabel("", 24, 258, 100, 15)
	_SetFont_Ctrl($c_Label_DCI_Status, 9.5, 600, 0, "Arial")

	$c_Button_DCI_Enable = GUICtrlCreateButton("Install DCI", 125 + 20, 252 + 15, 120, 25)
	GUICtrlSetTip(-1, "Adds ICU to the right click menu on the desktop." & @CRLF & "DCI settings are added to / deleted from the registry." & @CRLF & @CRLF & "Uninstall DCI before removing ICU from your computer.", "Desktop Contextmenu Integration", 1, 1)
	$c_Button_DCI_Disable = GUICtrlCreateButton("Uninstall DCI", 245 + 40, 252 + 15, 120, 25)

	Switch IniRead($sConfig_Path & "\ICU.ini", "Settings", "Desktop_Contextmenu_Integration", 0)
		Case 0
			GUICtrlSetState($c_Button_DCI_Enable, $GUI_ENABLE)
			GUICtrlSetState($c_Button_DCI_Disable, $GUI_DISABLE)

			GUICtrlSetData($c_Label_DCI_Status, "Not Installed")
			GUICtrlSetColor($c_Label_DCI_Status, $i_Color_OrangeRed)

		Case 1
			GUICtrlSetState($c_Button_DCI_Enable, $GUI_DISABLE)
			GUICtrlSetState($c_Button_DCI_Disable, $GUI_ENABLE)

			GUICtrlSetData($c_Label_DCI_Status, "Is Installed")
			GUICtrlSetColor($c_Label_DCI_Status, $i_Color_LimeGreen)
	EndSwitch

	GUICtrlCreateGroup("", -99, -99, 1, 1)

	$c_Hyperlink_CC = GUICtrlCreatePic("", 10, 231 + 70 + 15, 80, 15, $SS_NOTIFY)
	GUICtrlSetCursor($c_Hyperlink_CC, 0)
	GUICtrlSetBkColor(-1, 0x00ff00)

	GUICtrlCreateLabel("For support visit ", 163, 234 + 70 + 15, 74, 17)
	_SetFont_Ctrl(-1, 7, 400, 0, "Arial")
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)

	$c_Hyperlink_URL_homepage = GUICtrlCreateLabel('http://www.funk.eu', 236, 234 + 70 + 15, 78, 17)
	_SetFont_Ctrl(-1, 7, 400, 0, "Arial")
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
	GUICtrlSetColor(-1, 0x1111CC)
	GUICtrlSetCursor(-1, 0)

	$c_Hyperlink_Donate_Picture = GUICtrlCreatePic("", 360, 228 + 70 + 15, 100, 20, $SS_NOTIFY)
	GUICtrlSetCursor($c_Hyperlink_Donate_Picture, 0)
	GUICtrlSetBkColor(-1, 0x00ff00)

	Local $hBitmap_License = _Load_BMP_From_Mem(_BinaryString_Picture_License(), True)
	_WinAPI_DeleteObject(GUICtrlSendMsg($c_Hyperlink_CC, $STM_SETIMAGE, $IMAGE_BITMAP, $hBitmap_License))
	_WinAPI_DeleteObject($hBitmap_License)
	Local $hBitmap_Donate = _Load_BMP_From_Mem(_BinaryString_Picture_Donate(), True)
	_WinAPI_DeleteObject(GUICtrlSendMsg($c_Hyperlink_Donate_Picture, $STM_SETIMAGE, $IMAGE_BITMAP, $hBitmap_Donate))
	_WinAPI_DeleteObject($hBitmap_Donate)

Else

	$h_GUI_Main = GUICreate($sGUITitle, 470, 267)
	_SetFont_hWnd(8.25, 400, 0, "Arial", $h_GUI_Main)

	$c_Button_Save = GUICtrlCreateButton("Save", 10, 175, 82, 25)
	$c_Button_Restore = GUICtrlCreateButton("Restore", 102, 175, 82, 25)
	$c_Button_Delete = GUICtrlCreateButton("Delete", 194, 175, 82, 25)
	$c_Button_Duplicate = GUICtrlCreateButton("Duplicate", 286, 175, 82, 25)
	$c_Button_Show_Help = GUICtrlCreateButton("About", 378, 175, 82, 25)

	GUICtrlCreateLabel("List of saved layouts (*.icf files), right click to edit", 10, 8, 400, 20)

	$c_Label_State = GUICtrlCreateLabel("Ready", 380, 7, 80, 16, $SS_CENTER + $SS_CENTERIMAGE)
	GUICtrlSetBkColor(-1, $i_Color_LimeGreen)

	$c_Listview_Configs = GUICtrlCreateListView("#|Name|Date|Resolution|Move unknown Icons", 10, 30, 450, 135, $LVS_SINGLESEL, $LVS_EX_FULLROWSELECT)
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_LV_ALTERNATE)
	$h_Listview_Configs = GUICtrlGetHandle($c_Listview_Configs)

	_GUICtrlListView_SetColumnWidth($h_Listview_Configs, 0, 20)
	_GUICtrlListView_SetColumnWidth($h_Listview_Configs, 1, 80 + 48 + 46)
	_GUICtrlListView_SetColumnWidth($h_Listview_Configs, 2, $LVSCW_AUTOSIZE_USEHEADER)
	_GUICtrlListView_SetColumnWidth($h_Listview_Configs, 3, $LVSCW_AUTOSIZE_USEHEADER)
	_GUICtrlListView_SetColumnWidth($h_Listview_Configs, 4, 80)

	If IsArray($aConfig_List) Then
		_Fill_ListView()
	Else
		GUICtrlCreateListViewItem("|No Layouts saved", $c_Listview_Configs)
		GUICtrlSetState($c_Button_Restore, $GUI_DISABLE)
		GUICtrlSetState($c_Button_Delete, $GUI_DISABLE)
	EndIf

	$c_Checkbox_Autosave = GUICtrlCreateCheckbox(" Create Shortcut on Save", 323, 206 + 15, 250, 17)
	GUICtrlSetState(-1, IniRead($sConfig_Path & "\ICU.ini", "Settings", "Checkbox_Autosave", $GUI_CHECKED))
	GUICtrlSetTip(-1, "ICU will automatically create a shortcut in" & @CRLF & "the program directory on saving a layout")

	GUICtrlCreateLabel("Command line usage ", 10, 208, 150, 13)
	_SetFont_Ctrl(-1, 7, 600, 0, "Arial")
	GUICtrlCreateLabel("See ""About"" for details", 127, 208, 100, 13)
	_SetFont_Ctrl(-1, 7, 400, 0, "Arial")

	GUICtrlCreateLabel("Warning on ", 10, 208 + 15, 70, 13)
	_SetFont_Ctrl(-1, 7, 600, 0, "Arial")

	$c_Checkbox_Warning_AutoArrange = GUICtrlCreateCheckbox(" Auto Arrange", 80, 206 + 15, 85, 17)
	GUICtrlSetState(-1, IniRead($sConfig_Path & "\ICU.ini", "Settings", "Checkbox_Warning_AutoArrange", $GUI_CHECKED))
	GUICtrlSetTip(-1, "If the Desktop ""Auto Arrange"" feature is activated, ICU will post a warning Message Box on start")
	$c_Checkbox_Warning_AlignToGrid = GUICtrlCreateCheckbox(" Align to Grid", 170, 206 + 15, 100, 17)
	GUICtrlSetState(-1, IniRead($sConfig_Path & "\ICU.ini", "Settings", "Checkbox_Warning_AlignToGrid", $GUI_CHECKED))
	GUICtrlSetTip(-1, "If the Desktop ""Align to Grid"" feature is activated, ICU will post a warning Message Box on start")

	$c_Hyperlink_CC = GUICtrlCreatePic("", 10, 231 + 15, 80, 15, $SS_NOTIFY)
	GUICtrlSetCursor($c_Hyperlink_CC, 0)
	GUICtrlSetBkColor(-1, 0x00ff00)

	GUICtrlCreateLabel("For support visit ", 163, 234 + 15, 74, 17)
	_SetFont_Ctrl(-1, 7, 400, 0, "Arial")
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)

	$c_Hyperlink_URL_homepage = GUICtrlCreateLabel('http://www.funk.eu', 236, 234 + 15, 78, 17)
	_SetFont_Ctrl(-1, 7, 400, 0, "Arial")
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
	GUICtrlSetColor(-1, 0x1111CC)
	GUICtrlSetCursor(-1, 0)

	$c_Hyperlink_Donate_Picture = GUICtrlCreatePic("", 360, 228 + 15, 100, 20, $SS_NOTIFY)
	GUICtrlSetCursor($c_Hyperlink_Donate_Picture, 0)
	GUICtrlSetBkColor(-1, 0x00ff00)

	Local $hBitmap_License = _Load_BMP_From_Mem(_BinaryString_Picture_License(), True)
	_WinAPI_DeleteObject(GUICtrlSendMsg($c_Hyperlink_CC, $STM_SETIMAGE, $IMAGE_BITMAP, $hBitmap_License))
	_WinAPI_DeleteObject($hBitmap_License)
	Local $hBitmap_Donate = _Load_BMP_From_Mem(_BinaryString_Picture_Donate(), True)
	_WinAPI_DeleteObject(GUICtrlSendMsg($c_Hyperlink_Donate_Picture, $STM_SETIMAGE, $IMAGE_BITMAP, $hBitmap_Donate))
	_WinAPI_DeleteObject($hBitmap_Donate)

EndIf

If $__CmdLine[0] = 3 And StringLower($__CmdLine[1]) = "toggle" Then

	If Not IsArray($aConfig_List) Then _Exit()

	Global $s_Toggle_Config_File_Save, $s_Toggle_Config_File_Save_Raw
	Global $s_Toggle_Config_File_Save_Buffer, $s_Toggle_Config_File_Save_Buffer_Raw
	Global $s_Toggle_Config_File_Restore, $s_Toggle_Config_File_Restore_Raw
	Global $b_Config_Found

	For $y = 2 To 3

		$b_Config_Found = False

		If IsInt($__CmdLine[$y]) Then
			For $i = 1 To $aConfig_List[0]
				If Number(StringLeft($aConfig_List[$i], 3)) = Number($__CmdLine[$y]) Then
					$sConfig_FullPath = $sConfig_Path & "\" & $aConfig_List[$i]
					If FileExists($sConfig_FullPath) Then
						$b_Config_Found = True
						ExitLoop
					EndIf
				EndIf
			Next
		Else
			For $i = 1 To $aConfig_List[0]
				If StringInStr($aConfig_List[$i], $__CmdLine[$y]) Then
					$sConfig_FullPath = $sConfig_Path & "\" & $aConfig_List[$i]
					If FileExists($sConfig_FullPath) Then
						$b_Config_Found = True
						ExitLoop
					EndIf
				EndIf
			Next
		EndIf

		If $b_Config_Found = False Then _Tray_Show_Error_and_Exit("Fatal Error" & @CRLF & "ICU could not find called config """ & $__CmdLine[$y] & """")

		If $y = 2 Then
			$s_Toggle_Config_File_Save = $sConfig_FullPath
			$s_Toggle_Config_File_Save_Raw = $__CmdLine[$y]
		Else
			$s_Toggle_Config_File_Restore = $sConfig_FullPath
			$s_Toggle_Config_File_Restore_Raw = $__CmdLine[$y]
		EndIf

	Next

	If IniRead($s_Toggle_Config_File_Save, "Data", "Timestamp", 0) > IniRead($s_Toggle_Config_File_Restore, "Data", "Timestamp", 0) Then

		$s_Toggle_Config_File_Save_Buffer = $s_Toggle_Config_File_Save
		$s_Toggle_Config_File_Save = $s_Toggle_Config_File_Restore
		$s_Toggle_Config_File_Restore = $s_Toggle_Config_File_Save_Buffer

		$s_Toggle_Config_File_Save_Buffer_Raw = $s_Toggle_Config_File_Save_Raw
		$s_Toggle_Config_File_Save_Raw = $s_Toggle_Config_File_Restore_Raw
		$s_Toggle_Config_File_Restore_Raw = $s_Toggle_Config_File_Save_Buffer_Raw

	EndIf

	; MsgBox(0, "", $s_Toggle_Config_File_Save & @CRLF & IniRead($s_Toggle_Config_File_Save, "Data", "Timestamp", 0) & @CRLF & @CRLF & $s_Toggle_Config_File_Restore & @CRLF & IniRead($s_Toggle_Config_File_Restore, "Data", "Timestamp", 0))

	_Save_Config(True, $s_Toggle_Config_File_Save_Raw)
	If $i_DCI_Is_Enabled Then _DCI_Registry_Update()

	$sConfig_FullPath = $s_Toggle_Config_File_Restore
	_Set_Locations_Desktop()
	_Exit()

EndIf

If $__CmdLine[0] = 2 And StringLower($__CmdLine[1]) = "restore" Then

	If Not IsArray($aConfig_List) Then _Exit()

	If IsInt($__CmdLine[2]) Then
		For $i = 1 To $aConfig_List[0]
			If Number(StringLeft($aConfig_List[$i], 3)) = Number($__CmdLine[2]) Then
				$sConfig_FullPath = $sConfig_Path & "\" & $aConfig_List[$i]
				If FileExists($sConfig_FullPath) Then _Set_Locations_Desktop()
				_Exit()
			EndIf
		Next
	Else
		For $i = 1 To $aConfig_List[0]
			If StringInStr($aConfig_List[$i], $__CmdLine[2]) Then
				$sConfig_FullPath = $sConfig_Path & "\" & $aConfig_List[$i]
				If FileExists($sConfig_FullPath) Then _Set_Locations_Desktop()
				_Exit()
			EndIf
		Next
	EndIf

	_Tray_Show_Error_and_Exit("Fatal Error" & @CRLF & "ICU could not find called config """ & $__CmdLine[2] & """")

ElseIf $__CmdLine[0] = 1 And StringLower($__CmdLine[1]) = "autosave" Then
	_Save_Config(True)
	If $i_DCI_Is_Enabled Then _DCI_Registry_Update()
	_Exit()
ElseIf $__CmdLine[0] = 1 And StringLower($__CmdLine[1]) = "save" Then
	_Save_Config()
	If $i_DCI_Is_Enabled Then _DCI_Registry_Update()
	_Exit()
ElseIf $__CmdLine[0] = 2 And StringLower($__CmdLine[1]) = "savereplace" Then
	_Save_Config(True, $__CmdLine[2])
	If $i_DCI_Is_Enabled Then _DCI_Registry_Update()
	_Exit()
EndIf

Global Enum $c_Button_Change_Context_Menu_Unkown_Icons = 1000, $c_Button_Change_Context_Menu_Unkown_Icons_TopLeft, $c_Button_Change_Context_Menu_Unkown_Icons_BottomRight, $c_Button_Change_Context_Menu_Unkown_Icons_CustomPosition, $c_Button_Change_Context_Menu_Unkown_Icons_AskPerIcon, $c_Button_Change_Context_Menu_Unkown_Icons_OffScreen
Global Enum $c_Button_Change_Context_Menu_Restore = 2000, $c_Button_Change_Context_Menu_Delete, $c_Button_Change_Context_Menu_Duplicate, $c_Button_Change_Context_Menu_ShowConfigFile, $c_Button_Change_Context_Menu_MoveConfigFile

Global $b_Restore_Config_Notify = False

GUIRegisterMsg($WM_NOTIFY, "WM_NOTIFY")
GUIRegisterMsg($WM_COMMAND, "WM_COMMAND")
GUIRegisterMsg($WM_CONTEXTMENU, "WM_CONTEXTMENU")

_GUI_Help_Create()
If Not StringInStr($__CmdLineRaw, "minimized") Then GUISetState(@SW_SHOW, $h_GUI_Main)

TraySetClick(8)
TraySetState()
TraySetToolTip("ICU - Icon Configuration Utility")
TrayItemSetOnEvent($c_TrayItem_Save, "_tray_save")
TraySetOnEvent($TRAY_EVENT_PRIMARYDOWN, "_tray_recover")
TrayItemSetOnEvent($c_TrayItem_Settings, "_tray_recover")
TrayItemSetOnEvent($c_TrayItem_Exit, "_Exit")

$c_Dummy_AccelKeys_ESC = GUICtrlCreateDummy()
Global $a_AccelKeys[1][2] = [["{ESC}", $c_Dummy_AccelKeys_ESC]]
GUISetAccelerators($a_AccelKeys, $h_GUI_Main)

; ----- Main loop -----

While 1

	$Msg = GUIGetMsg(1)

	Switch $Msg[1]
		Case $h_GUI_Main
			Switch $Msg[0]
				Case $c_Checkbox_Autosave
					IniWrite($sConfig_Path & "\ICU.ini", "Settings", "Checkbox_Autosave", GUICtrlRead($c_Checkbox_Autosave))

				Case $GUI_EVENT_MINIMIZE, $c_Dummy_AccelKeys_ESC
					_tray_minimize()

				Case $GUI_EVENT_CLOSE
					_Exit()

				Case $c_Button_Save
					_Save_Config()
					If $i_DCI_Is_Enabled Then _DCI_Registry_Update()

				Case $c_Button_Restore
					_Restore_Config()

				Case $c_Button_Duplicate
					_Duplicate_Config()

				Case $c_Button_Delete
					_Delete_Config()

				Case $c_Button_Show_Help
					_GUI_Help_Show()

				Case $c_Button_DCI_Enable
					If $__WINVER > 0x0600 Then ; Windows 7 or later
						If _DCI_Enable(True) Then
							GUICtrlSetState($c_Button_DCI_Enable, $GUI_DISABLE)
							GUICtrlSetState($c_Button_DCI_Disable, $GUI_ENABLE)
							GUICtrlSetData($c_Label_DCI_Status, "installed")
							GUICtrlSetColor($c_Label_DCI_Status, $i_Color_LimeGreen)
						EndIf
					EndIf

				Case $c_Button_DCI_Disable
					If $__WINVER > 0x0600 Then ; Windows 7 or later
						If _DCI_Enable(False) Then
							GUICtrlSetState($c_Button_DCI_Enable, $GUI_ENABLE)
							GUICtrlSetState($c_Button_DCI_Disable, $GUI_DISABLE)
							GUICtrlSetData($c_Label_DCI_Status, "not installed")
							GUICtrlSetColor($c_Label_DCI_Status, $i_Color_OrangeRed)
						EndIf
					EndIf
			EndSwitch
	EndSwitch

	If $b_Restore_Config_Notify Then
		$b_Restore_Config_Notify = False
		_Restore_Config()
	EndIf

WEnd

_Exit()

Func _tray_save()
	If BitAND(WinGetState($hGUI_Help), 2) Then
		$b_GUI_Help_Exit = True
		$b_GUI_Help_Tray_Save = True
	Else
		_Save_Config()
		If $i_DCI_Is_Enabled Then _DCI_Registry_Update()
	EndIf
EndFunc   ;==>_tray_save

Func _tray_recover()
	$b_GUI_Help_Exit = True
	GUISetState(@SW_SHOW, $h_GUI_Main)
	GUISetState(@SW_RESTORE, $h_GUI_Main)
EndFunc   ;==>_tray_recover

Func _tray_minimize()
	GUISetState(@SW_HIDE, $h_GUI_Main)
EndFunc   ;==>_tray_minimize

Func _tray_restore_config()
	For $i = 1 To $a_TrayItem_Restore[0]
		If @TRAY_ID = $a_TrayItem_Restore[$i] Then
			_GUICtrlListView_SetItemSelected($h_Listview_Configs, $i - 1)
			_Restore_Config()
		EndIf
	Next
EndFunc   ;==>_tray_restore_config

Func _Save_Config($b_AutoSave_with_Timestamp = False, $sSaveReplace_Config = "")

	Local $b_Save_Config_Canceled, $sConfig_Name, $s_Combo_Unknown_Icon_Handling, $iNew_Index
	Local $h_GUI_Save, $c_Input_Save_Config_Type, $c_Button_Save_Ok, $c_Button_Save_Cancel

	GUISetState(@SW_HIDE, $h_GUI_Main)

	If Not $b_AutoSave_with_Timestamp Then
		While 1

			$b_Save_Config_Canceled = False
			$h_GUI_Save = GUICreate($sGUITitle, 260, 117)
			_SetFont_hWnd(8.25, 400, 0, "Arial", $h_GUI_Save)

			GUICtrlCreateLabel("Enter a name for the new Icon Configuration File", 15, 7, 250)
			$c_Input_Save_Config_Type = GUICtrlCreateInput("", 15, 23, 230)

			GUICtrlCreateLabel("Move unknown Icons to", 23, 56, 110, 13)
			$c_Combo_Unknown_Icon_Handling = GUICtrlCreateCombo("Top-Left", 145, 52, 100, 20, BitOR($CBS_DROPDOWNLIST, $CBS_AUTOHSCROLL))
			GUICtrlSetData(-1, "Bottom-Right|Custom Position|Ask per Icon|Off-Screen", IniRead($sConfig_Path & "\ICU.ini", "Settings", "Default_Unknown_Icon_Handling", "Top-Left"))

			$c_Button_Save_Ok = GUICtrlCreateButton("Save", 33, 80, 80, 30)
			$c_Button_Save_Cancel = GUICtrlCreateButton("Cancel", 146, 80, 80, 30)

			GUICtrlSetState($c_Button_Save_Ok, $GUI_DEFBUTTON)
			GUISetState(@SW_SHOW, $h_GUI_Save)

			While 1
				Switch GUIGetMsg()
					Case $GUI_EVENT_CLOSE
						$b_Save_Config_Canceled = True
						ExitLoop

					Case $c_Button_Save_Cancel
						$b_Save_Config_Canceled = True
						ExitLoop

					Case $c_Button_Save_Ok
						If GUICtrlRead($c_Input_Save_Config_Type) Then
							If GUICtrlRead($c_Combo_Unknown_Icon_Handling) = "Custom Position" Then
								Local $aPos = _GetDesktop_MousePos()
								If $aPos[0] <> -1 Then
									$s_Combo_Unknown_Icon_Handling = "Custom-Position," & $aPos[0] & "," & $aPos[1]
									IniWrite($sConfig_Path & "\ICU.ini", "Settings", "Default_Unknown_Icon_Handling", "Custom Position")
									ExitLoop
								Else
									GUISetState(@SW_RESTORE, $h_GUI_Save)
								EndIf
							Else
								IniWrite($sConfig_Path & "\ICU.ini", "Settings", "Default_Unknown_Icon_Handling", $s_Combo_Unknown_Icon_Handling)
								ExitLoop
							EndIf
						Else
							MsgBox(64 + 262144, $sGUITitle, "Enter a name or cancel save.", 0, $h_GUI_Save)
						EndIf

				EndSwitch
			WEnd

			$sConfig_Name = StringRegExpReplace(GUICtrlRead($c_Input_Save_Config_Type), '[\Q\/:?*"<>|\E]', '') ; force valid filename

			If Not $s_Combo_Unknown_Icon_Handling Then $s_Combo_Unknown_Icon_Handling = GUICtrlRead($c_Combo_Unknown_Icon_Handling)
			If Not StringInStr($__CmdLineRaw, "save") Then GUISetState(@SW_SHOW, $h_GUI_Main)
			GUIDelete($h_GUI_Save)
			If $b_Save_Config_Canceled Then
				GUICtrlSetData($c_Label_State, "Ready")
				GUICtrlSetBkColor($c_Label_State, $i_Color_LimeGreen)
				GUICtrlSetState($c_Button_Restore, $GUI_ENABLE)
				GUICtrlSetState($c_Button_Delete, $GUI_ENABLE)
				Return
			EndIf

			GUICtrlSetData($c_Label_State, "Working")
			GUICtrlSetBkColor($c_Label_State, 0xFF4500)
			$sConfig_FullPath = ""

			; Get new config filename
			If IsArray($aConfig_List) Then
				$iNew_Index = 0
				For $i = 0 To UBound($aConfig_List) - 1
					If StringLen($aConfig_List[$i]) > 4 Then
						If Number(StringLeft($aConfig_List[$i], 3)) >= $iNew_Index Then $iNew_Index = Number(StringLeft($aConfig_List[$i], 3)) + 1
						If $sConfig_Name = StringMid($aConfig_List[$i], 5, StringLen($aConfig_List[$i]) - 8) Then
							Switch MsgBox(3 + 32 + 262144, $sGUITitle, "A config file named '" & $sConfig_Name & "' already exists." & @CRLF & @CRLF & "Do you want to replace this config (yes) or create a new one (no)?", 0, $h_GUI_Main)
								Case 6 ; yes
									$sConfig_FullPath = $sConfig_Path & "\" & $aConfig_List[$i]
									$iNew_Index = Int(StringLeft($aConfig_List[$i], 3))
									ExitLoop
								Case 7 ; no
									$sConfig_FullPath = ""
									ExitLoop
								Case 2 ; cancel
									GUICtrlSetData($c_Label_State, "Ready")
									GUICtrlSetBkColor($c_Label_State, $i_Color_LimeGreen)
									GUICtrlSetState($c_Button_Restore, $GUI_ENABLE)
									GUICtrlSetState($c_Button_Delete, $GUI_ENABLE)
									Return
							EndSwitch
						EndIf
					EndIf
				Next
				If Not StringLen($sConfig_FullPath) Then $sConfig_FullPath = $sConfig_Path & "\" & StringFormat("%03i", $iNew_Index) & "_" & $sConfig_Name & ".icf"

			Else
				$iNew_Index = 1
				$sConfig_FullPath = $sConfig_Path & "\001_" & $sConfig_Name & ".icf"
			EndIf
			If $sConfig_FullPath Then ExitLoop
		WEnd

	Else ; $b_AutoSave_with_Timestamp = True

		If $sSaveReplace_Config Then

			$sConfig_FullPath = ""
			$sConfig_Name = ""

			If IsInt($sSaveReplace_Config) Then
				For $i = 1 To $aConfig_List[0]
					If Number(StringLeft($aConfig_List[$i], 3)) = Number($sSaveReplace_Config) Then
						$sConfig_FullPath = $sConfig_Path & "\" & $aConfig_List[$i]
					EndIf
				Next
				If Not $sConfig_FullPath Then $sConfig_FullPath = $sConfig_Path & "\" & StringFormat("%03i", Number($sSaveReplace_Config)) & "_" & @YEAR & "_" & @MON & "_" & @MDAY & "_" & @HOUR & @MIN & @SEC & ".icf"
			Else
				For $i = 1 To $aConfig_List[0]
					If StringInStr($aConfig_List[$i], $sSaveReplace_Config) Then
						$sConfig_FullPath = $sConfig_Path & "\" & $aConfig_List[$i]
					EndIf
				Next
				If Not $sConfig_FullPath Then $sConfig_FullPath = $sConfig_Path & "\" & StringFormat("%03i", 99) & "_" & $sSaveReplace_Config & ".icf"
			EndIf

			$s_Combo_Unknown_Icon_Handling = IniRead($sConfig_FullPath, "Data", "Unknown_Icon_Handling", "Top-Left")
			$sConfig_Name = IniRead($sConfig_FullPath, "Data", "Type", $sConfig_Name)

			If Not $sConfig_Name Then
				If IsInt($sSaveReplace_Config) Then
					$sConfig_Name = @YEAR & "_" & @MON & "_" & @MDAY & "_" & @HOUR & @MIN & @SEC
				Else
					$sConfig_Name = $sSaveReplace_Config
				EndIf
			EndIf

		Else

			$s_Combo_Unknown_Icon_Handling = "Top-Left"
			$sConfig_Name = @YEAR & "_" & @MON & "_" & @MDAY & "_" & @HOUR & @MIN & @SEC

			If IsArray($aConfig_List) Then
				$iNew_Index = 0
				For $i = 0 To UBound($aConfig_List) - 1
					If StringLen($aConfig_List[$i]) > 4 Then
						If Number(StringLeft($aConfig_List[$i], 3)) >= $iNew_Index Then $iNew_Index = Number(StringLeft($aConfig_List[$i], 3)) + 1
						If $sConfig_Name = StringMid($aConfig_List[$i], 5, StringLen($aConfig_List[$i]) - 8) Then
							Switch MsgBox(3 + 32 + 262144, $sGUITitle, "A config file named '" & $sConfig_Name & "' already exists." & @CRLF & @CRLF & "Do you want to replace this config (yes) or create a new one (no)?", 0, $h_GUI_Main)
								Case 6 ; yes
									$sConfig_FullPath = $sConfig_Path & "\" & $aConfig_List[$i]
									$iNew_Index = Int(StringLeft($aConfig_List[$i], 3))
									ExitLoop
								Case 7 ; no
									$sConfig_FullPath = ""
									ExitLoop
								Case 2 ; cancel
									GUICtrlSetData($c_Label_State, "Ready")
									GUICtrlSetBkColor($c_Label_State, $i_Color_LimeGreen)
									GUICtrlSetState($c_Button_Restore, $GUI_ENABLE)
									GUICtrlSetState($c_Button_Delete, $GUI_ENABLE)
									Return
							EndSwitch
						EndIf
					EndIf
				Next
				If Not StringLen($sConfig_FullPath) Then $sConfig_FullPath = $sConfig_Path & "\" & StringFormat("%03i", $iNew_Index) & "_" & $sConfig_Name & ".icf"

			Else
				$iNew_Index = 1
				$sConfig_FullPath = $sConfig_Path & "\001_" & $sConfig_Name & ".icf"
			EndIf
		EndIf

	EndIf

	; Write config file data
	FileDelete($sConfig_FullPath)
	IniWrite($sConfig_FullPath, "Data", "Type", $sConfig_Name)
	IniWrite($sConfig_FullPath, "Data", "Date", _NowCalc())
	IniWrite($sConfig_FullPath, "Data", "Timestamp", _Epoch_encrypt(@YEAR & "/" & @MON & "/" & @MDAY & " " & @HOUR & ":" & @MIN & ":" & @SEC))

	Local $VirtX = DllCall($h_DLL_User32, "int", "GetSystemMetrics", "int", 78) ;SM_CXVIRTUALSCREEN 78
	;The width of the virtual screen, in pixels. The virtual screen is the bounding rectangle of all display monitors.
	;The SM_XVIRTUALSCREEN metric is the coordinates for the left side of the virtual screen.
	Local $VirtY = DllCall($h_DLL_User32, "int", "GetSystemMetrics", "int", 79) ;SM_CYVIRTUALSCREEN 79
	;The height of the virtual screen, in pixels. The virtual screen is the bounding rectangle of all display monitors.
	;The SM_YVIRTUALSCREEN metric is the coordinates for the top of the virtual screen
	IniWrite($sConfig_FullPath, "Data", "Resolution", $VirtX[0] & "x" & $VirtY[0])
	IniWrite($sConfig_FullPath, "Data", "Unknown_Icon_Handling", $s_Combo_Unknown_Icon_Handling)

	If BitAND(IniRead($sConfig_Path & "\ICU.ini", "Settings", "Checkbox_Autosave", $GUI_CHECKED), $GUI_CHECKED) Then
		Local $sLnkTargetFile = StringTrimRight(@ScriptDir, StringLen(@ScriptDir) - StringInStr(@ScriptDir, "\", 0, -1)) & "\ICU - Restore Layout - " & $sConfig_Name & ".lnk"
		Do
			$sLnkTargetFile = StringReplace($sLnkTargetFile, "\\", "\")
		Until Not @extended
		FileDelete($sLnkTargetFile)
		FileCreateShortcut(@ScriptDir & "\" & @ScriptName, $sLnkTargetFile, @ScriptDir, "restore " & $iNew_Index, "ICU - Restore Layout " & $sConfig_Name, @ScriptDir & "\" & @ScriptName, "", 0, @SW_MINIMIZE)
	EndIf

	; Save Desktop locations
	_Save_Locations_Desktop()

	; Refill list
	_Fill_ListView()

	; Reset GUI
	GUICtrlSetData($c_Label_State, "Ready")
	GUICtrlSetBkColor($c_Label_State, $i_Color_LimeGreen)
	GUICtrlSetState($c_Button_Restore, $GUI_ENABLE)
	GUICtrlSetState($c_Button_Delete, $GUI_ENABLE)

EndFunc   ;==>_Save_Config

Func _Save_Locations_Desktop()

	If Not IsHWnd($h_Desktop_SysListView32) Then
		_Tray_Show_Error_and_Exit("Error _Save_Locations_Desktop()" & @CRLF & "Desktop Window Handle not found.")
		; MsgBox(16 + 262144, $sGUITitle & " - Error _Save_Locations_Desktop()", "Desktop Window Handle not found.", 0, $h_GUI_Main)
		; _Exit()
	EndIf

	Local $aDesktop = _Desktop_to_Array()
	If Not IsArray($aDesktop) Or UBound($aDesktop, 2) <> 4 Then
		_Tray_Show_Error_and_Exit("Error _Save_Locations_Desktop()" & @CRLF & "_Desktop_to_Array() returned wrong dimension." & @CRLF & @CRLF & "Dim-1: " & UBound($aDesktop) & @CRLF & "Dim-2: " & UBound($aDesktop, 2), False)
		; MsgBox(16 + 262144, $sGUITitle & " - Error _Save_Locations_Desktop()", "_Desktop_to_Array() returned wrong dimension." & @CRLF & @CRLF & "Dim-1: " & UBound($aDesktop) & @CRLF & "Dim-2: " & UBound($aDesktop, 2), 0, $h_GUI_Main)
		; Return SetError(1)
	EndIf

	For $i = 0 To UBound($aDesktop) - 1
		IniWrite($sConfig_FullPath, "Desktop", _URIEncode($aDesktop[$i][0] & $aDesktop[$i][1] & $aDesktop[$i][2]), $aDesktop[$i][3])
	Next

EndFunc   ;==>_Save_Locations_Desktop

Func _Restore_Config()

	GUICtrlSetData($c_Label_State, "Working")
	GUICtrlSetBkColor($c_Label_State, 0xFF4500)

	; Get config file name
	Local $iIndex = _GUICtrlListView_GetSelectedIndices($h_Listview_Configs, True)
	If $iIndex[0] <> 1 Then
		ReDim $iIndex[2]
		$iIndex[0] = 1
		$iIndex[1] = 0
	EndIf

	If $iIndex[0] = 1 Then
		$sConfig_FullPath = $sConfig_Path & "\" & $aConfig_List[$iIndex[1] + 1]
		; Restore Desktop
		_Set_Locations_Desktop()
		ControlListView($h_GUI_Main, "", $h_Listview_Configs, "SelectClear")
	EndIf

	; Reset GUI
	GUICtrlSetData($c_Label_State, "Ready")
	GUICtrlSetBkColor($c_Label_State, $i_Color_LimeGreen)

EndFunc   ;==>_Restore_Config

Func _Duplicate_Config()

	GUICtrlSetData($c_Label_State, "Working")
	GUICtrlSetBkColor($c_Label_State, 0xFF4500)

	; Get config file name
	Local $iIndex = _GUICtrlListView_GetSelectedIndices($h_Listview_Configs, True)
	If $iIndex[0] <> 1 Then
		ReDim $iIndex[2]
		$iIndex[0] = 1
		$iIndex[1] = 0
	EndIf

	If $iIndex[0] = 1 Then
		$sConfig_FullPath = $sConfig_Path & "\" & $aConfig_List[$iIndex[1] + 1]

		For $i = 1 To 999
			If Not FileExists($sConfig_Path & "\" & StringFormat("%03i", $i) & "*.icf") Then
				;ConsoleWrite($i & @CRLF & $sConfig_FullPath & @CRLF & $sConfig_Path & "\" & StringFormat("%03i", $i) & "_" & StringTrimLeft($aConfig_List[$iIndex[1] + 1], 4) & @CRLF)
				FileCopy($sConfig_FullPath, $sConfig_Path & "\" & StringFormat("%03i", $i) & "_" & StringTrimLeft($aConfig_List[$iIndex[1] + 1], 4))
				ExitLoop
			EndIf
		Next

		ControlListView($h_GUI_Main, "", $h_Listview_Configs, "SelectClear")
	EndIf

	_Fill_ListView()

	; Reset GUI
	GUICtrlSetData($c_Label_State, "Ready")
	GUICtrlSetBkColor($c_Label_State, $i_Color_LimeGreen)

EndFunc   ;==>_Duplicate_Config

Func _Change_Config($iCtrlId)

	GUICtrlSetData($c_Label_State, "Working")
	GUICtrlSetBkColor($c_Label_State, 0xFF4500)

	; Get config file name
	Local $iIndex = _GUICtrlListView_GetSelectedIndices($h_Listview_Configs, True)
	If $iIndex[0] <> 1 Then
		ReDim $iIndex[2]
		$iIndex[0] = 1
		$iIndex[1] = 0
	EndIf

	If $iIndex[0] = 1 Then

		$sConfig_FullPath = $sConfig_Path & "\" & $aConfig_List[$iIndex[1] + 1]

		Switch $iCtrlId
			Case $c_Button_Change_Context_Menu_Unkown_Icons_TopLeft
				IniWrite($sConfig_FullPath, "Data", "Unknown_Icon_Handling", "Top-Left")
			Case $c_Button_Change_Context_Menu_Unkown_Icons_BottomRight
				IniWrite($sConfig_FullPath, "Data", "Unknown_Icon_Handling", "Bottom-Right")
			Case $c_Button_Change_Context_Menu_Unkown_Icons_CustomPosition
				Local $aPos = _GetDesktop_MousePos()
				If $aPos[0] <> -1 Then IniWrite($sConfig_FullPath, "Data", "Unknown_Icon_Handling", "Custom-Position," & $aPos[0] & "," & $aPos[1])
				WinMinimizeAllUndo()
			Case $c_Button_Change_Context_Menu_Unkown_Icons_AskPerIcon
				IniWrite($sConfig_FullPath, "Data", "Unknown_Icon_Handling", "Ask per Icon")
			Case $c_Button_Change_Context_Menu_Unkown_Icons_OffScreen
				IniWrite($sConfig_FullPath, "Data", "Unknown_Icon_Handling", "Off-Screen")
		EndSwitch

		ControlListView($h_GUI_Main, "", $h_Listview_Configs, "SelectClear")

	EndIf

	_Fill_ListView()

	; Reset GUI
	GUICtrlSetData($c_Label_State, "Ready")
	GUICtrlSetBkColor($c_Label_State, $i_Color_LimeGreen)

EndFunc   ;==>_Change_Config

Func _Set_Locations_Desktop()

	If Not IsHWnd($h_Desktop_SysListView32) Then
		_Tray_Show_Error_and_Exit("Fatal Error in _Set_Locations_Desktop()" & @CRLF & "Desktop Window Handle not found.")
		; MsgBox(16 + 262144, $sGUITitle & " - Fatal Error in _Set_Locations_Desktop()", "Desktop Window Handle not found.", 0, $h_GUI_Main)
		; _Exit()
	EndIf

	; Now replace icons back in stored positions
	Local $j = 0, $sAskAnswer, $sPos_Saved, $aPos, $aPos_Ask

	Local $aDesktop = _Desktop_to_Array()
	If Not IsArray($aDesktop) Or UBound($aDesktop, 2) <> 4 Then
		_Tray_Show_Error_and_Exit("Error _Set_Locations_Desktop()" & @CRLF & "_Desktop_to_Array() returned wrong dimension." & @CRLF & @CRLF & "Dim-1: " & UBound($aDesktop) & @CRLF & "Dim-2: " & UBound($aDesktop, 2), False)
		; MsgBox(16 + 262144, $sGUITitle & " - Error _Set_Locations_Desktop()", "_Desktop_to_Array() returned wrong dimension." & @CRLF & @CRLF & "Dim-1: " & UBound($aDesktop) & @CRLF & "Dim-2: " & UBound($aDesktop, 2), 0, $h_GUI_Main)
		; Return SetError(1)
	EndIf

	_GUICtrlListView_BeginUpdate($h_Desktop_SysListView32)

	Local $VirtX = DllCall($h_DLL_User32, "int", "GetSystemMetrics", "int", 78) ;SM_CXVIRTUALSCREEN 78
	;The width of the virtual screen, in pixels. The virtual screen is the bounding rectangle of all display monitors.
	;The SM_XVIRTUALSCREEN metric is the coordinates for the left side of the virtual screen.
	Local $VirtY = DllCall($h_DLL_User32, "int", "GetSystemMetrics", "int", 79) ;SM_CYVIRTUALSCREEN 79
	;The height of the virtual screen, in pixels. The virtual screen is the bounding rectangle of all display monitors.
	;The SM_YVIRTUALSCREEN metric is the coordinates for the top of the virtual screen

	Local $s_Unknown_Icon_Handling = IniRead($sConfig_FullPath, "Data", "Unknown_Icon_Handling", "Top-Left")
	If $s_Unknown_Icon_Handling = "Ask per Icon" Then _GUICtrlListView_EndUpdate($h_Desktop_SysListView32)
	Local $a_Unknown_Icon_Handling_Custom_Position
	If StringInStr($s_Unknown_Icon_Handling, "Custom-Position") Then
		$a_Unknown_Icon_Handling_Custom_Position = StringSplit($s_Unknown_Icon_Handling, ",")
		$s_Unknown_Icon_Handling = "Custom-Position"
		;_ArrayDisplay($a_Unknown_Icon_Handling_Custom_Position)
		$a_Unknown_Icon_Handling_Custom_Position[2] = Int($a_Unknown_Icon_Handling_Custom_Position[2])
		$a_Unknown_Icon_Handling_Custom_Position[3] = Int($a_Unknown_Icon_Handling_Custom_Position[3])
		If Not IsInt($a_Unknown_Icon_Handling_Custom_Position[2]) Or Not IsInt($a_Unknown_Icon_Handling_Custom_Position[3]) Then
			;ConsoleWrite("! Custom-Position Error" & @crlf)
			IniWrite($sConfig_FullPath, "Data", "Unknown_Icon_Handling", "Top-Left")
			$s_Unknown_Icon_Handling = "Top-Left"
		EndIf
	EndIf

	For $i = 0 To UBound($aDesktop) - 1
		$sPos_Saved = IniRead($sConfig_FullPath, "Desktop", _URIEncode($aDesktop[$i][0] & $aDesktop[$i][1] & $aDesktop[$i][2]), "")
		If $sPos_Saved Then
			$aPos = StringSplit($sPos_Saved, ":")
			If UBound($aPos) = 3 Then
				_GUICtrlListView_SetItemPosition($h_Desktop_SysListView32, $i, $aPos[1], $aPos[2])
			Else
				_Tray_Show_Error_and_Exit("Error _Set_Locations_Desktop()" & @CRLF & "Saved Postion is not in the right format." & @CRLF & @CRLF & $aDesktop[$i][0] & @CRLF & $sPos_Saved, False)
				; MsgBox(16 + 262144, $sGUITitle & " - Error _Set_Locations_Desktop()", "Saved Postion is not in the right format." & @CRLF & @CRLF & $aDesktop[$i][0] & @CRLF & $sPos_Saved, 0, $h_GUI_Main)
			EndIf
		Else
			Switch $s_Unknown_Icon_Handling

				Case "Custom-Position"
					_GUICtrlListView_SetItemPosition($h_Desktop_SysListView32, $i, $a_Unknown_Icon_Handling_Custom_Position[2], $a_Unknown_Icon_Handling_Custom_Position[3])

				Case "Off-Screen"
					_GUICtrlListView_SetItemPosition($h_Desktop_SysListView32, $i, 9999, 9999)

				Case "Ask per Icon"
					$aPos_Ask = _GetDesktop_MousePos($aDesktop[$i][0])
					If $aPos_Ask[0] = -1 Then ExitLoop
					_GUICtrlListView_SetItemPosition($h_Desktop_SysListView32, $i, $aPos_Ask[0], $aPos_Ask[1])

				Case "Bottom-Right"
					_GUICtrlListView_SetItemPosition($h_Desktop_SysListView32, $i, $VirtX[0] - 48, $VirtY[0] - 48)

				Case Else ; Top-Left
					_GUICtrlListView_SetItemPosition($h_Desktop_SysListView32, $i, 0, 0)

			EndSwitch

		EndIf
	Next

	_GUICtrlListView_EndUpdate($h_Desktop_SysListView32)

	; GUISetState(@SW_RESTORE, $h_GUI_Main)
	; WinActivate($h_GUI_Main)

	#cs
		If IniRead($sConfig_FullPath, "Data", "LV_AutoArrange", "No") = "Yes" Then
		DllCall('user32.dll', 'int', 'SendMessage', 'hwnd', _WinAPI_GetParent($h_Desktop_SysListView32), 'uint', $WM_COMMAND, 'wparam', 28785, 'lparam', 0) ; Toogle Auto Arrange
		EndIf
		If IniRead($sConfig_FullPath, "Data", "LV_Snap_to_Grid", "No") = "Yes" Then
		DllCall('user32.dll', 'int', 'SendMessage', 'hwnd', _WinAPI_GetParent($h_Desktop_SysListView32), 'uint', $WM_COMMAND, 'wparam', 28788, 'lparam', 0) ; Toogle Snap to Grid
		EndIf
	#ce

EndFunc   ;==>_Set_Locations_Desktop


Func _Delete_Config()
	Local $iIndex = _GUICtrlListView_GetSelectedIndices($h_Listview_Configs, True)
	If $iIndex[0] = 1 Then
		If MsgBox(4 + 16 + 256 + 262144, $sGUITitle, "Are you sure you want to delete the config file """ & _GUICtrlListView_GetItemText($h_Listview_Configs, $iIndex[1], 1) & """?", 0, $h_GUI_Main) = 6 Then _Delete_Config_Do()
		ControlListView($h_GUI_Main, "", $h_Listview_Configs, "SelectClear")
	EndIf
	If $i_DCI_Is_Enabled Then _DCI_Registry_Update()
EndFunc   ;==>_Delete_Config

Func _Delete_Config_Do()

	GUICtrlSetData($c_Label_State, "Deleting")
	GUICtrlSetBkColor($c_Label_State, 0xFF4500)

	; Get config file name
	Local $sLayoutName, $sLnkTargetFile
	Local $iIndex = _GUICtrlListView_GetSelectedIndices($h_Listview_Configs, True)

	If $iIndex[0] = 1 Then
		$sConfig_FullPath = $sConfig_Path & "\" & $aConfig_List[$iIndex[1] + 1]
		; Delete config file
		$sLayoutName = _GUICtrlListView_GetItemText($h_Listview_Configs, $iIndex[1], 1)
		Local $sLnkTargetFile = StringTrimRight(@ScriptDir, StringLen(@ScriptDir) - StringInStr(@ScriptDir, "\", 0, -1)) & "\ICU - Restore Layout - " & $sLayoutName & ".lnk"
		Do
			$sLnkTargetFile = StringReplace($sLnkTargetFile, "\\", "\")
		Until Not @extended
		FileRecycle($sLnkTargetFile)
		FileRecycle($sConfig_FullPath)
		ControlListView($h_GUI_Main, "", $h_Listview_Configs, "SelectClear")
	EndIf

	; Refill list
	_Fill_ListView()

	; Reset GUI
	GUICtrlSetData($c_Label_State, "Ready")
	GUICtrlSetBkColor($c_Label_State, $i_Color_LimeGreen)

EndFunc   ;==>_Delete_Config_Do

Func _Fill_ListView()

	For $i = 1 To $a_TrayItem_Restore[0]
		TrayItemDelete($a_TrayItem_Restore[$i])
	Next

	_GUICtrlListView_DeleteAllItems($h_Listview_Configs)
	; Get list of files
	$aConfig_List = _FileListToArray($sConfig_Path, "*.icf", 1)
	; Fill Listview
	Local $sType, $sDate, $sRes, $sUnkownIconHandling
	;$s_LV_AutoArrange, $s_LV_SnapToGrid
	If Not IsArray($aConfig_List) Then
		GUICtrlCreateListViewItem("|No Layouts saved", $c_Listview_Configs)
		GUICtrlSetState($c_Button_Restore, $GUI_DISABLE)
		GUICtrlSetState($c_Button_Delete, $GUI_DISABLE)

		ReDim $a_TrayItem_Restore[2]
		$a_TrayItem_Restore[0] = 1
		$a_TrayItem_Restore[1] = TrayCreateItem("No Layouts saved", $c_TrayItem_Restore)
		TrayItemSetState($a_TrayItem_Restore[1], $TRAY_DISABLE)

	Else

		ReDim $a_TrayItem_Restore[$aConfig_List[0] + 1]
		$a_TrayItem_Restore[0] = $aConfig_List[0]

		For $i = 1 To $aConfig_List[0]
			$sType = IniRead($sConfig_Path & "\" & $aConfig_List[$i], "Data", "Type", "Unknown")
			$sDate = IniRead($sConfig_Path & "\" & $aConfig_List[$i], "Data", "Date", "Unknown")
			$sRes = IniRead($sConfig_Path & "\" & $aConfig_List[$i], "Data", "Resolution", "Unknown")
			$sUnkownIconHandling = IniRead($sConfig_Path & "\" & $aConfig_List[$i], "Data", "Unknown_Icon_Handling", "Unknown")
			;$s_LV_AutoArrange = IniRead($sConfig_Path & "\" & $aConfig_List[$i], "Data", "LV_AutoArrange", "No")
			;$s_LV_SnapToGrid = IniRead($sConfig_Path & "\" & $aConfig_List[$i], "Data", "LV_Snap_to_Grid", "No")
			;GUICtrlCreateListViewItem(Number(StringLeft($aConfig_List[$i], 3)) & "|" & $sType & "|" & $sDate & "|" & $sRes & "|" & $sUnkownIconHandling & "|" & $s_LV_AutoArrange & "|" & $s_LV_SnapToGrid, $c_Listview_Configs)
			GUICtrlCreateListViewItem(Number(StringLeft($aConfig_List[$i], 3)) & "|" & $sType & "|" & $sDate & "|" & $sRes & "|" & $sUnkownIconHandling, $c_Listview_Configs)
			GUICtrlSetBkColor(-1, 0xefefef)

			$a_TrayItem_Restore[$i] = TrayCreateItem("#" & Number(StringLeft($aConfig_List[$i], 3)) & " - " & $sType, $c_TrayItem_Restore)
			TrayItemSetOnEvent(-1, "_tray_restore_config")

		Next
	EndIf
	_GUICtrlListView_SetColumnWidth($h_Listview_Configs, 0, 20)
	_GUICtrlListView_SetColumnWidth($h_Listview_Configs, 1, 80 + 48 + 46)
	_GUICtrlListView_SetColumnWidth($h_Listview_Configs, 2, $LVSCW_AUTOSIZE_USEHEADER)
	_GUICtrlListView_SetColumnWidth($h_Listview_Configs, 3, $LVSCW_AUTOSIZE_USEHEADER)
	_GUICtrlListView_SetColumnWidth($h_Listview_Configs, 4, 80)
	;_GUICtrlListView_SetColumnWidth($h_Listview_Configs, 5, 48)
	;_GUICtrlListView_SetColumnWidth($h_Listview_Configs, 6, 48)

EndFunc   ;==>_Fill_ListView

; #FUNCTION# ====================================================================================================================
; Name...........: _URIEncode
; Description ...: Encodes a string to be used in an URI
; Syntax.........: _URIEncode($sData)
; Parameters ....: $sData    - String to encode
; Return values .: Encoded String
; Author ........: Prog@ndy
; Modified.......:
; Remarks .......: This function uses UTF-8 encoding for special chars
; Related .......: _URIDecode
; Link ..........;
; Example .......;
; ===============================================================================================================================
Func _URIEncode($sData)
	; Prog@ndy
	Local $aData = StringSplit(BinaryToString(StringToBinary($sData, 4), 1), "")
	Local $nChar
	$sData = ""
	For $i = 1 To $aData[0]
;~         ConsoleWrite($aData[$i] & @CRLF)
		$nChar = Asc($aData[$i])
		Switch $nChar
			Case 45, 46, 48 - 57, 65 To 90, 95, 97 To 122, 126
				$sData &= $aData[$i]
			Case 32
				$sData &= "+"
			Case Else
				$sData &= "%" & Hex($nChar, 2)
		EndSwitch
	Next
	Return $sData
EndFunc   ;==>_URIEncode

Func _URIDecode($sData)
	; Prog@ndy
	Local $aData = StringSplit(StringReplace($sData, "+", " ", 0, 1), "%")
	$sData = ""
	For $i = 2 To $aData[0]
		$aData[1] &= Chr(Dec(StringLeft($aData[$i], 2))) & StringTrimLeft($aData[$i], 2)
	Next
	Return BinaryToString(StringToBinary($aData[1], 1), 4)
EndFunc   ;==>_URIDecode

Func _EnforceSingleInstance($GUID_Program)
	If $GUID_Program = "" Then Return SetError(1, '', 1)
	Local $hWnd_ICU = WinGetHandle($GUID_Program)
	If IsHWnd($hWnd_ICU) Then
		; ProcessClose(WinGetProcess(WinGetHandle($GUID_Program), ""))
		WinClose($hWnd_ICU)
		WinWaitClose($hWnd_ICU, "", 2)
	EndIf
	AutoItWinSetTitle($GUID_Program)
	Return WinGetHandle($GUID_Program)
EndFunc   ;==>_EnforceSingleInstance

Func _DCI_Enable($bSwitch = True)
	;If Not @Compiled Then Return MsgBox(64 + 262144, $sGUITitle, "ICU must be compiled to use the DCI feature.")
	Switch $bSwitch
		Case True
			IniWrite($sConfig_Path & "\ICU.ini", "Settings", "Desktop_Contextmenu_Integration", 1)
			_DCI_Registry_Update()
			If @error Then
				; MsgBox(16 + 262144, $sGUITitle & " - Error _DCI_Enable()", "ICU could not install DCI settings." & @CRLF & "Error code: " & @error, 0, $h_GUI_Main)
				_Tray_Show_Error_and_Exit("Error _DCI_Enable()" & @CRLF & "ICU could not install DCI settings." & @CRLF & "Error code: " & @error & @CRLF & "Extended error code: " & @extended, False)
				Return SetError(1)
			EndIf
		Case False
			IniWrite($sConfig_Path & "\ICU.ini", "Settings", "Desktop_Contextmenu_Integration", 0)
			_DCI_Registry_Update()
			If @error Then
				_Tray_Show_Error_and_Exit("Error _DCI_Enable()" & @CRLF & "ICU could not uninstall DCI settings." & @CRLF & "Error code: " & @error & @CRLF & "Extended error code: " & @extended, False)
				; MsgBox(16 + 262144, $sGUITitle & " - Error _DCI_Enable()", "ICU could not uninstall DCI settings." & @CRLF & "Error code: " & @error, 0, $h_GUI_Main)
				Return SetError(1)
			EndIf
	EndSwitch
	$i_DCI_Is_Enabled = _DCI_Is_Enabled()
	Return 1
EndFunc   ;==>_DCI_Enable

Func _DCI_Is_Enabled()
	Return IniRead($sConfig_Path & "\ICU.ini", "Settings", "Desktop_Contextmenu_Integration", 0)
EndFunc   ;==>_DCI_Is_Enabled

Func _DCI_Registry_Update()
	#cs
		Further Infos:
		MSDN - Creating Context Menu Handlers
		http://msdn.microsoft.com/en-us/library/cc144171%28VS.85%29.aspx
		IContextMenu Interface
		http://msdn.microsoft.com/en-us/library/bb776095%28v=VS.85%29.aspx
		Creating Shell Extension Handlers
		http://msdn.microsoft.com/en-us/library/cc144067%28v=VS.85%29.aspx
		http://pc.de/software/kaskadierte-menues-windows-345
	#ce

	;If Not @Compiled Then Return MsgBox(64 + 262144, $sGUITitle, "ICU must be compiled to use the DCI feature.")
	Switch IniRead($sConfig_Path & "\ICU.ini", "Settings", "Desktop_Contextmenu_Integration", 0)
		Case 1
			_DCI_Registry_Delete_Entries()
			If @error Then Return SetError(@error, @extended)

			RegWrite("HKEY_CURRENT_USER\Software\Classes\DesktopBackground\shell\ICU_ContextMenu_Anchor", "MUIVerb", "REG_SZ", "ICU")
			RegWrite("HKEY_CURRENT_USER\Software\Classes\DesktopBackground\shell\ICU_ContextMenu_Anchor", "Position", "REG_SZ", "Bottom")
			RegWrite("HKEY_CURRENT_USER\Software\Classes\DesktopBackground\shell\ICU_ContextMenu_Anchor", "Icon", "REG_EXPAND_SZ", @ScriptFullPath & ",0")
			RegWrite("HKEY_CURRENT_USER\Software\Classes\DesktopBackground\shell\ICU_ContextMenu_Anchor", "ExtendedSubCommandsKey", "REG_SZ", "DesktopBackground\ContextMenus\ICU")

			RegWrite("HKEY_CURRENT_USER\Software\Classes\DesktopBackground\ContextMenus\ICU\Shell\001_ICU", "Icon", "REG_EXPAND_SZ", "shell32.dll,-22")
			RegWrite("HKEY_CURRENT_USER\Software\Classes\DesktopBackground\ContextMenus\ICU\Shell\001_ICU", "MUIVerb", "REG_SZ", "Settings")
			RegWrite("HKEY_CURRENT_USER\Software\Classes\DesktopBackground\ContextMenus\ICU\Shell\001_ICU\command", "", "REG_EXPAND_SZ", @ScriptFullPath)

			RegWrite("HKEY_CURRENT_USER\Software\Classes\DesktopBackground\ContextMenus\ICU\Shell\002_ICU", "Icon", "REG_EXPAND_SZ", "shell32.dll,-7")
			RegWrite("HKEY_CURRENT_USER\Software\Classes\DesktopBackground\ContextMenus\ICU\Shell\002_ICU", "MUIVerb", "REG_SZ", "Save Desktop Layout")
			RegWrite("HKEY_CURRENT_USER\Software\Classes\DesktopBackground\ContextMenus\ICU\Shell\002_ICU", "CommandFlags", "REG_DWORD", 0x40)
			RegWrite("HKEY_CURRENT_USER\Software\Classes\DesktopBackground\ContextMenus\ICU\Shell\002_ICU\command", "", "REG_EXPAND_SZ", @ScriptFullPath & " save")

			; Get list of files
			Local $aConfig_List = _FileListToArray($sConfig_Path, "*.icf", 1), $sEnum, $sType, $sRes
			If IsArray($aConfig_List) Then
				For $i = 1 To $aConfig_List[0]
					$sEnum = StringFormat("%03i", $i + 2)
					$sType = IniRead($sConfig_Path & "\" & $aConfig_List[$i], "Data", "Type", "Unknown")
					$sRes = IniRead($sConfig_Path & "\" & $aConfig_List[$i], "Data", "Resolution", "Unknown")
					RegWrite("HKEY_CURRENT_USER\Software\Classes\DesktopBackground\ContextMenus\ICU\Shell\" & $sEnum & "_ICU", "Icon", "REG_EXPAND_SZ", "shell32.dll,-167")
					RegWrite("HKEY_CURRENT_USER\Software\Classes\DesktopBackground\ContextMenus\ICU\Shell\" & $sEnum & "_ICU", "MUIVerb", "REG_EXPAND_SZ", "Restore Layout #" & Number(StringLeft($aConfig_List[$i], 3)) & " - " & $sType & " @ " & $sRes)
					RegWrite("HKEY_CURRENT_USER\Software\Classes\DesktopBackground\ContextMenus\ICU\Shell\" & $sEnum & "_ICU\command", "", "REG_EXPAND_SZ", @ScriptFullPath & " restore " & Number(StringLeft($aConfig_List[$i], 3)))
				Next
			EndIf

		Case 0
			_DCI_Registry_Delete_Entries()
			If @error Then Return SetError(@error, @extended)
	EndSwitch
EndFunc   ;==>_DCI_Registry_Update

Func _DCI_Registry_Delete_Entries()
	; Local $iError = 0
	If RegDelete("HKEY_CURRENT_USER\Software\Classes\DesktopBackground\ContextMenus\ICU") = 2 Then Return SetError(@error, @extended) ; $iError += 1
	If RegDelete("HKEY_CURRENT_USER\Software\Classes\DesktopBackground\shell\ICU_ContextMenu_Anchor") = 2 Then Return SetError(@error, @extended) ; $iError += 1
	Return 1 ; SetError($iError)
EndFunc   ;==>_DCI_Registry_Delete_Entries

Func _Exit()
	AutoItWinSetTitle("")
	Exit
EndFunc   ;==>_Exit

Func _Exit_OnAutoItExitRegister()
	If $__WINVER > 0x0600 Then ; Windows 7 or later
		If IniRead($sConfig_Path & "\ICU.ini", "Settings", "Desktop_Contextmenu_Integration", 0) = 1 Then
			_DCI_Enable(False)
			_DCI_Enable(True)
		EndIf
	EndIf
	_GDIPlus_Shutdown()
	DllClose($h_DLL_Kernel32)
	DllClose($h_DLL_User32)
	DllClose($h_DLL_Advapi32)
	DllClose($h_DLL_GDI32)
	DllClose($h_DLL_OLE32)
	DllClose($h_DLL_OLEAut32)
	DllClose($h_DLL_Crypt32)
EndFunc   ;==>_Exit_OnAutoItExitRegister

Func _Desktop_to_Array()

	Local $a_LV_Item, $a_Icon_Pos
	Local $iItemCount = _GUICtrlListView_GetItemCount($h_Desktop_SysListView32)
	If Not $iItemCount Then
		; MsgBox(16 + 262144, $sGUITitle & " - Error _Desktop_to_Array()", "Desktop SysListView32 does not seem to contain any icons.", 0, $h_GUI_Main)
		_Tray_Show_Error_and_Exit("Error _Desktop_to_Array()" & @CRLF & "Desktop SysListView32 does not seem to contain any icons.", False)
		Return
	EndIf
	Local $aDesktop[$iItemCount][4]
	Local $s_DesktopDir_Buffer
	Local $s_DesktopCommonDir_Buffer

	For $i = 0 To $iItemCount - 1

		$a_LV_Item = _GUICtrlListView_GetItem($h_Desktop_SysListView32, $i, 0)
		$aDesktop[$i][0] = $a_LV_Item[3]

		If FileExists(@DesktopDir & "\" & $aDesktop[$i][0]) And Not StringInStr($s_DesktopDir_Buffer, ";" & $aDesktop[$i][0] & ";") Then
			$aDesktop[$i][1] = @DesktopDir & "\" & $aDesktop[$i][0]
			$s_DesktopDir_Buffer &= ";" & $aDesktop[$i][0] & ";"
			If StringInStr(FileGetAttrib($aDesktop[$i][1]), "D") Then
				$aDesktop[$i][2] = "|_Dir"
			Else
				$aDesktop[$i][2] = "|_File"
			EndIf
		ElseIf FileExists(@DesktopCommonDir & "\" & $aDesktop[$i][0]) Then
			$aDesktop[$i][1] = @DesktopCommonDir & "\" & $aDesktop[$i][0]
			$s_DesktopCommonDir_Buffer &= ";" & $aDesktop[$i][0] & ";"
			If StringInStr(FileGetAttrib($aDesktop[$i][1]), "D") Then
				$aDesktop[$i][2] = "|_Dir"
			Else
				$aDesktop[$i][2] = "|_File"
			EndIf
		ElseIf FileExists(@DesktopDir & "\" & $aDesktop[$i][0] & ".lnk") And Not StringInStr($s_DesktopDir_Buffer, ";" & $aDesktop[$i][0] & ".lnk" & ";") Then
			$aDesktop[$i][1] = @DesktopDir & "\" & $aDesktop[$i][0] & ".lnk"
			$s_DesktopDir_Buffer &= ";" & $aDesktop[$i][0] & ".lnk" & ";"
			$aDesktop[$i][2] = "|_lnk"
		ElseIf FileExists(@DesktopDir & "\" & $aDesktop[$i][0] & ".url") And Not StringInStr($s_DesktopDir_Buffer, ";" & $aDesktop[$i][0] & ".url" & ";") Then
			$aDesktop[$i][1] = @DesktopDir & "\" & $aDesktop[$i][0] & ".url"
			$s_DesktopDir_Buffer &= ";" & $aDesktop[$i][0] & ".url" & ";"
			$aDesktop[$i][2] = "|_url"
		ElseIf FileExists(@DesktopCommonDir & "\" & $aDesktop[$i][0] & ".lnk") Then
			$aDesktop[$i][1] = @DesktopCommonDir & "\" & $aDesktop[$i][0] & ".lnk"
			$s_DesktopCommonDir_Buffer &= ";" & $aDesktop[$i][0] & ".lnk" & ";"
			$aDesktop[$i][2] = "|_lnk"
		ElseIf FileExists(@DesktopCommonDir & "\" & $aDesktop[$i][0] & ".url") Then
			$aDesktop[$i][1] = @DesktopCommonDir & "\" & $aDesktop[$i][0] & ".url"
			$s_DesktopCommonDir_Buffer &= ";" & $aDesktop[$i][0] & ".url" & ";"
			$aDesktop[$i][2] = "|_url"
		EndIf

		$a_Icon_Pos = _GUICtrlListView_GetItemPosition($h_Desktop_SysListView32, $i)
		$aDesktop[$i][3] = $a_Icon_Pos[0] & ":" & $a_Icon_Pos[1]

	Next

	Return $aDesktop
EndFunc   ;==>_Desktop_to_Array


; http://www.autoitscript.com/forum/topic/119783-desktop-class-workerw/page__view__findpost__p__903081
; ===============================================================================================================================
; <_WinGetDesktopHandle.au3>
;
; Function to get the Windows' Desktop Handle.
;   Since this is no longer a simple '[CLASS:Progman]' on Aero-enabled desktops, this method uses a slightly
;   more involved method to find the correct Desktop Handle.
;
; Author: Ascend4nt, credits to Valik for pointing out the Parent->Child relationship: Desktop->'SHELLDLL_DefView'
; ===============================================================================================================================
; Example use:
#cs
	#include <GuiListView.au3>
	$iTimer = TimerInit()
	$hDeskWin = _WinGetDesktopHandle()
	$h_Listview_Configs = HWnd(@extended)
	ConsoleWrite("Time elapsed:" & TimerDiff($iTimer) & " ms" & @CRLF)
	$iDeskItems = _GUICtrlListView_GetItemCount($h_Listview_Configs)
	ConsoleWrite("Handle to desktop: " & $hDeskWin & ", Title: '" & WinGetTitle($hDeskWin) & "', Handle to Listview: " & $h_Listview_Configs & ", # Items:" & $iDeskItems & ", Title: " & WinGetTitle($h_Listview_Configs) & @CRLF)
	MsgBox(0, "Desktop handle (with ListView) found", "Handle to desktop: " & $hDeskWin & ", Title: '" & WinGetTitle($hDeskWin) & "'," & @CRLF & "Handle to Listview: " & $h_Listview_Configs & @CRLF & "# Desktop Items:" & $iDeskItems)
#ce

Func _WinGetDesktopHandle()
	Local $i, $hDeskWin, $hSHELLDLL_DefView, $h_Listview_Configs
	; The traditional Windows Classname for the Desktop, not always so on newer O/S's
	$hDeskWin = WinGetHandle("[CLASS:Progman]")
	; Parent->Child relationship: Desktop->SHELLDLL_DefView
	$hSHELLDLL_DefView = ControlGetHandle($hDeskWin, '', '[CLASS:SHELLDLL_DefView; INSTANCE:1]')
	; No luck with finding the Desktop and/or child?
	If $hDeskWin = '' Or $hSHELLDLL_DefView = '' Then
		; Look through a list of WorkerW windows - one will be the Desktop on Windows 7+ O/S's
		$aWinlist = WinList("[CLASS:WorkerW]")
		For $i = 1 To $aWinlist[0][0]
			$hSHELLDLL_DefView = ControlGetHandle($aWinlist[$i][1], '', '[CLASS:SHELLDLL_DefView; INSTANCE:1]')
			If $hSHELLDLL_DefView <> '' Then
				$hDeskWin = $aWinlist[$i][1]
				ExitLoop
			EndIf
		Next
	EndIf
	; Parent->Child relationship: Desktop->SHELDLL_DefView->SysListView32
	$h_Listview_Configs = ControlGetHandle($hSHELLDLL_DefView, '', '[CLASS:SysListView32; INSTANCE:1]')
	If $h_Listview_Configs = '' Then Return SetError(-1, 0, '')
	Return SetExtended($h_Listview_Configs, $hDeskWin)
EndFunc   ;==>_WinGetDesktopHandle

Func _SetFont_Ctrl($icontrolID = -1, $iSize = 8.5, $iweight = 400, $iattribute = 0, $sfontname = Default, $iquality = 2)
	If IsKeyword($sfontname) Then
		Local $a_SetFont_GetDefault = _SetFont_GetDefault()
		$sfontname = $a_SetFont_GetDefault[3]
	EndIf
	If Not IsDeclared("__i_SetFont_DPI_Ratio") Then
		Global $__i_SetFont_DPI_Ratio = _SetFont_GetDPI()
		$__i_SetFont_DPI_Ratio = $__i_SetFont_DPI_Ratio[2]
	EndIf
	GUICtrlSetFont($icontrolID, $iSize / $__i_SetFont_DPI_Ratio, $iweight, $iattribute, $sfontname, $iquality)
EndFunc   ;==>_SetFont_Ctrl

Func _SetFont_hWnd($iSize = 8.5, $iweight = 400, $iattribute = 0, $sfontname = Default, $hWnd = Default, $iquality = 2)
	If Not IsHWnd($hWnd) Then $hWnd = GUISwitch(0)
	If IsKeyword($sfontname) Then
		Local $a_SetFont_GetDefault = _SetFont_GetDefault()
		$sfontname = $a_SetFont_GetDefault[3]
	EndIf
	If Not IsDeclared("__i_SetFont_DPI_Ratio") Then
		Global $__i_SetFont_DPI_Ratio = _SetFont_GetDPI()
		$__i_SetFont_DPI_Ratio = $__i_SetFont_DPI_Ratio[2]
	EndIf
	GUISetFont($iSize / $__i_SetFont_DPI_Ratio, $iweight, $iattribute, $sfontname, $hWnd, $iquality)
EndFunc   ;==>_SetFont_hWnd

; #INTERNAL_USE_ONLY#============================================================================================================
; Name...........: _SetFont_GetDefault
; Description ...: Determines Windows default MsgBox font size and name
; Syntax.........: _SetFont_GetDefault()
; Return values .: Success - Array holding determined font data
;                : Failure - Array holding default values
;                  Array elements - [0] = Size, [1] = Weight, [2] = Style, [3] = Name, [4] = Quality
; Author ........: KaFu
; ===============================================================================================================================
Func _SetFont_GetDefault()

	; Fill array with standard default data
	Local $aDefFontData[5] = [8.5, 400, 0, "Tahoma", 2]

	; Get AutoIt GUI handle
	Local $hWnd = WinGetHandle(AutoItWinGetTitle())
	; Open Theme DLL
	Local $hThemeDLL = DllOpen("uxtheme.dll")
	; Get default theme handle
	Local $hTheme = DllCall($hThemeDLL, 'ptr', 'OpenThemeData', 'hwnd', $hWnd, 'wstr', "Static")
	If @error Then Return $aDefFontData
	$hTheme = $hTheme[0]
	; Create LOGFONT structure => http://msdn.microsoft.com/en-us/library/dd145037(VS.85).aspx
	Local $tFont = DllStructCreate("long;long;long;long;long;byte;byte;byte;byte;byte;byte;byte;byte;wchar[32]")
	Local $pFont = DllStructGetPtr($tFont)
	; Get MsgBox font from theme
	DllCall($hThemeDLL, 'long', 'GetThemeSysFont', 'HANDLE', $hTheme, 'int', 805, 'ptr', $pFont) ; TMT_MSGBOXFONT
	If @error Then Return $aDefFontData
	; Get default DC
	Local $hDC = DllCall("user32.dll", "handle", "GetDC", "hwnd", $hWnd)
	If @error Then Return $aDefFontData
	$hDC = $hDC[0]
	; Get font vertical size
	Local $iPixel_Y = DllCall("gdi32.dll", "int", "GetDeviceCaps", "handle", $hDC, "int", 90) ; LOGPIXELSY
	If Not @error Then
		$iPixel_Y = $iPixel_Y[0]
		$aDefFontData[0] = Int(2 * (.25 - DllStructGetData($tFont, 1) * 72 / $iPixel_Y)) / 2
	EndIf
	; Close DC
	DllCall("user32.dll", "int", "ReleaseDC", "hwnd", $hWnd, "handle", $hDC)
	; Extract font data from LOGFONT structure
	$aDefFontData[3] = DllStructGetData($tFont, 14)
	$aDefFontData[1] = DllStructGetData($tFont, 5)
	$aDefFontData[4] = DllStructGetData($tFont, 12)

	If DllStructGetData($tFont, 6) Then $aDefFontData[2] += 2
	If DllStructGetData($tFont, 7) Then $aDefFontData[2] += 4
	If DllStructGetData($tFont, 8) Then $aDefFontData[2] += 8

	Return $aDefFontData

EndFunc   ;==>_SetFont_GetDefault

;; GetDPI.au3
;;
;; Get the current DPI (dots per inch) setting, and the ratio
;; between it and approximately 96 DPI.
;;
;; Author: Phillip123Adams
;; Posted: August, 17, 2005, originally developed 10/17/2004,
;; AutoIT 3.1.1.67 (but earlier v3.1.1 versions with DLLCall should work).
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;~   ;; Example
;~  #include<guiconstants.au3>
;~   ;;
;~   ;; Get the current DPI.
;~  $a1 = _SetFont_GetDPI()
;~  $iDPI = $a1[1]
;~  $iDPIRat = $a1[2]
;~   ;;
;~   ;; Design the GUI to show how to apply the DPI adjustment.
;~  GUICreate("Applying DPI to GUI's", 250 * $iDPIRat, 120 * $iDPIRat)
;~  $lbl = GUICtrlCreateLabel("The current DPI value is " & $iDPI &@lf& "Ratio to 96 is " & $iDPIRat &@lf&@lf& "Call function _SetFont_GetDPI.  Then multiply all GUI dimensions by the returned value divided by approximately 96.0.", 10 * $iDPIRat, 5 * $iDPIRat, 220 * $iDPIRat, 80 * $iDPIRat)
;~  $btnClose = GUICtrlCreateButton("Close", 105 * $iDPIRat, 90 * $iDPIRat, 40 * $iDPIRat, 20 * $iDPIRat)
;~  GUISetState()
;~   ;;
;~  while 1
;~   $iMsg = GUIGetMsg()
;~   If $iMsg = $GUI_EVENT_CLOSE or $iMsg = $btnClose then ExitLoop
;~  WEnd
;~  Exit
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Func _SetFont_GetDPI()
	;; Get the current DPI (dots per inch) setting, and the ratio between it and
	;; approximately 96 DPI.
	;;
	;; Retrun a 1D array of dimension 3.  Indices zero is the dimension of the array
	;; minus one.  Indices 1 = the current DPI (an integer).  Indices 2 is the ratio
	;; should be applied to all GUI dimensions to make the GUI automatically adjust
	;; to suit the various DPI settings.
	;;
	;; Author: Phillip123Adams
	;; Posted: August, 17, 2005, originally developed 6/04/2004,
	;; AutoIT 3.1.1.67 (but earlier v3.1.1 versions with DLLCall should work).
	;;
	;; Note: The dll calls are based upon code from the AutoIt3 forum from a post
	;; by this-is-me on Nov 23 2004, 10:29 AM under topic "@Larry, Help!"  Thanks
	;; to this-is-me and Larry.  Prior to that, I was obtaining the current DPI
	;; from the Registry:
	;;    $iDPI = RegRead("HKCU\Control Panel\Desktop\WindowMetrics", "AppliedDPI")
	;;

	Local $a1[3]
	Local $iDPI, $iDPIRat, $Logpixelsy = 90, $hWnd = 0
	Local $hDC = DllCall($h_DLL_User32, "long", "GetDC", "long", $hWnd)
	Local $aRet = DllCall($h_DLL_GDI32, "long", "GetDeviceCaps", "long", $hDC[0], "long", $Logpixelsy)
	Local $hDC = DllCall($h_DLL_User32, "long", "ReleaseDC", "long", $hWnd, "long", $hDC)
	$iDPI = $aRet[0]
	;; Set a ratio for the GUI dimensions based upon the current DPI value.
	Select
		Case $iDPI = 0
			$iDPI = 96
			$iDPIRat = 94
		Case $iDPI < 84
			$iDPIRat = $iDPI / 105
		Case $iDPI < 121
			$iDPIRat = $iDPI / 96
		Case $iDPI < 145
			$iDPIRat = $iDPI / 95
		Case Else
			$iDPIRat = $iDPI / 94
	EndSelect
	$a1[0] = 2
	$a1[1] = $iDPI
	$a1[2] = $iDPIRat
	;; Return the array
	Return $a1
EndFunc   ;==>_SetFont_GetDPI

Func WM_NOTIFY($hWnd, $iMsg, $iwParam, $ilParam)
	Local $tNMHDR = DllStructCreate($tagNMHDR, $ilParam)
	Local $hWndFrom = HWnd(DllStructGetData($tNMHDR, "hWndFrom"))
	Local $iIDFrom = DllStructGetData($tNMHDR, "IDFrom")
	Local $iCode = DllStructGetData($tNMHDR, "Code")

	Switch $hWndFrom
		Case $h_Listview_Configs
			Switch $iCode
				Case $LVN_ITEMACTIVATE
					$b_Restore_Config_Notify = True
					Return $GUI_RUNDEFMSG
			EndSwitch
	EndSwitch
	Return $GUI_RUNDEFMSG
EndFunc   ;==>WM_NOTIFY

Func WM_CONTEXTMENU($hWnd, $iMsg, $iwParam, $ilParam)

	$iItem = _GUICtrlListView_HitTest($h_Listview_Configs)
	If $iItem[0] < 0 Then Return

	Local $iConfig_Number = $iItem[0] + 1
	Local $sConfig_File = $aConfig_List[$iItem[0] + 1]
	Local $sConfig_FullPath = $sConfig_Path & "\" & $aConfig_List[$iItem[0] + 1]

	Local $hMenu_Unkown_Icons = _GUICtrlMenu_CreateMenu(32)
	_GUICtrlMenu_InsertMenuItem($hMenu_Unkown_Icons, 0, "Top-Left", $c_Button_Change_Context_Menu_Unkown_Icons_TopLeft)
	_GUICtrlMenu_InsertMenuItem($hMenu_Unkown_Icons, 1, "Bottom-Right", $c_Button_Change_Context_Menu_Unkown_Icons_BottomRight)
	_GUICtrlMenu_InsertMenuItem($hMenu_Unkown_Icons, 2, "Custom Position", $c_Button_Change_Context_Menu_Unkown_Icons_CustomPosition)
	_GUICtrlMenu_InsertMenuItem($hMenu_Unkown_Icons, 3, "Ask per Icon", $c_Button_Change_Context_Menu_Unkown_Icons_AskPerIcon)
	_GUICtrlMenu_InsertMenuItem($hMenu_Unkown_Icons, 4, "Off-Screen", $c_Button_Change_Context_Menu_Unkown_Icons_OffScreen)

	Local $hMenu = _GUICtrlMenu_CreatePopup(32)
	_GUICtrlMenu_InsertMenuItem($hMenu, 0, "Move unkown Icons", $c_Button_Change_Context_Menu_Unkown_Icons, $hMenu_Unkown_Icons)
	_GUICtrlMenu_InsertMenuItem($hMenu, 1, "")
	_GUICtrlMenu_InsertMenuItem($hMenu, 2, "Restore", $c_Button_Change_Context_Menu_Restore)
	_GUICtrlMenu_InsertMenuItem($hMenu, 3, "Delete", $c_Button_Change_Context_Menu_Delete)
	_GUICtrlMenu_InsertMenuItem($hMenu, 4, "Duplicate", $c_Button_Change_Context_Menu_Duplicate)
	_GUICtrlMenu_InsertMenuItem($hMenu, 5, "")
	_GUICtrlMenu_InsertMenuItem($hMenu, 6, "Move Config File to #", $c_Button_Change_Context_Menu_MoveConfigFile)
	_GUICtrlMenu_InsertMenuItem($hMenu, 7, "Show Config File", $c_Button_Change_Context_Menu_ShowConfigFile)

	Switch IniRead($sConfig_FullPath, "Data", "Unknown_Icon_Handling", "Top-Left")
		Case "Off-Screen"
			_GUICtrlMenu_SetItemState($hMenu_Unkown_Icons, 4, $MFS_CHECKED)
		Case "Ask per Icon"
			_GUICtrlMenu_SetItemState($hMenu_Unkown_Icons, 3, $MFS_CHECKED)
		Case "Bottom-Right"
			_GUICtrlMenu_SetItemState($hMenu_Unkown_Icons, 1, $MFS_CHECKED)
		Case "Top-Left"
			_GUICtrlMenu_SetItemState($hMenu_Unkown_Icons, 0, $MFS_CHECKED)
		Case Else
			_GUICtrlMenu_SetItemState($hMenu_Unkown_Icons, 2, $MFS_CHECKED)
	EndSwitch

	Local $iSelection = _GUICtrlMenu_TrackPopupMenu($hMenu, $iwParam, -1, -1, 1, 1, 2)

	Switch $iSelection
		Case $c_Button_Change_Context_Menu_Unkown_Icons_TopLeft To $c_Button_Change_Context_Menu_Unkown_Icons_OffScreen

			_Change_Config($iSelection)

		Case $c_Button_Change_Context_Menu_Restore
			_Restore_Config()

		Case $c_Button_Change_Context_Menu_Delete
			_Delete_Config()

		Case $c_Button_Change_Context_Menu_Duplicate
			_Duplicate_Config()

		Case $c_Button_Change_Context_Menu_ShowConfigFile
			Run("notepad.exe " & $sConfig_FullPath)

		Case $c_Button_Change_Context_Menu_MoveConfigFile
			Local $iPosNew = InputBox($sGUITitle, "Enter a new # position number for the config file", Default, Default, 300, 130, Default, Default, 0, $h_GUI_Main)
			If Not @error Then
				$iPosNew = Int($iPosNew)
				If $iPosNew And $iConfig_Number <> $iPosNew Then
					FileMove($sConfig_Path & "\" & $sConfig_File, $sConfig_Path & "\" & "x_" & StringTrimLeft($sConfig_File, 4))
					If $iPosNew > $aConfig_List[0] Then $iPosNew = $aConfig_List[0]
					If $iPosNew > $iConfig_Number Then
						For $i = $iConfig_Number + 1 To $iPosNew
							FileMove($sConfig_Path & "\" & $aConfig_List[$i], $sConfig_Path & "\" & StringFormat("%03i", $i - 1) & "_" & StringTrimLeft($aConfig_List[$i], 4))
						Next
					Else
						For $i = $iPosNew To $iConfig_Number - 1
							FileMove($sConfig_Path & "\" & $aConfig_List[$i], $sConfig_Path & "\" & StringFormat("%03i", $i + 1) & "_" & StringTrimLeft($aConfig_List[$i], 4))
						Next
					EndIf
					FileMove($sConfig_Path & "\" & "x_" & StringTrimLeft($sConfig_File, 4), $sConfig_Path & "\" & StringFormat("%03i", $iPosNew) & "_" & StringTrimLeft($sConfig_File, 4))
					_Fill_ListView()
				EndIf
			EndIf

	EndSwitch

	_GUICtrlMenu_DestroyMenu($hMenu)
	_GUICtrlMenu_DestroyMenu($hMenu_Unkown_Icons)

	Return True

EndFunc   ;==>WM_CONTEXTMENU

Func WM_COMMAND($hWnd, $Msg, $wParam, $lParam)
	; Local $nNotifyCode = BitShift($wParam, 16)
	; $nID = BitAND($wParam, 0x0000FFFF)
	; $hCtrl = $lParam
	Switch BitAND($wParam, 0x0000FFFF); $nID
		Case $c_Hyperlink_URL_homepage
			ShellExecute('http://www.funk.eu')
		Case $c_Hyperlink_Donate_Picture
			ShellExecute("https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=smf%40funk%2eeu&item_name=Thank%20you%20for%20your%20donation%20to%20ICU...&no_shipping=0&no_note=1&tax=0&currency_code=EUR&lc=US&bn=PP%2dDonationsBF&charset=UTF%2d8")
		Case $c_Hyperlink_CC
			ShellExecute("http://creativecommons.org/licenses/by-nc-nd/3.0/us/")
		Case $c_Checkbox_Warning_AutoArrange
			If BitAND(GUICtrlRead($c_Checkbox_Warning_AutoArrange), $GUI_CHECKED) Then
				IniWrite($sConfig_Path & "\ICU.ini", "Settings", "Checkbox_Warning_AutoArrange", $GUI_CHECKED)
			Else
				IniWrite($sConfig_Path & "\ICU.ini", "Settings", "Checkbox_Warning_AutoArrange", $GUI_UNCHECKED)
			EndIf
		Case $c_Checkbox_Warning_AlignToGrid
			If BitAND(GUICtrlRead($c_Checkbox_Warning_AlignToGrid), $GUI_CHECKED) Then
				IniWrite($sConfig_Path & "\ICU.ini", "Settings", "Checkbox_Warning_AlignToGrid", $GUI_CHECKED)
			Else
				IniWrite($sConfig_Path & "\ICU.ini", "Settings", "Checkbox_Warning_AlignToGrid", $GUI_UNCHECKED)
			EndIf
	EndSwitch
	Return $GUI_RUNDEFMSG
EndFunc   ;==>WM_COMMAND


; Based on File to Base64 String Code Generator
; by UEZ
; http://www.autoitscript.com/forum/topic/134350-file-to-base64-string-code-generator-v103-build-2011-11-21/

;======================================================================================
; Function Name:        Load_BMP_From_Mem
; Description:          Loads an image which is saved as a binary string and converts it to a bitmap or hbitmap
;
; Parameters:           $bImage:    the binary string which contains any valid image which is supported by GDI+
; Optional:             $hHBITMAP:  if false a bitmap will be created, if true a hbitmap will be created
;
; Remark:               hbitmap format is used generally for GUI internal images, $bitmap is more a GDI+ image format
;                       Don't forget _GDIPlus_Startup() and _GDIPlus_Shutdown()
;
; Requirement(s):       GDIPlus.au3, Memory.au3 and _GDIPlus_BitmapCreateDIBFromBitmap() from WinAPIEx.au3
; Return Value(s):      Success: handle to bitmap (GDI+ bitmap format) or hbitmap (WinAPI bitmap format),
;                       Error: 0
; Error codes:          1: $bImage is not a binary string
;                       2: unable to create stream on HGlobal
;                       3: unable to create bitmap from stream
;
; Author(s):            UEZ
; Additional Code:      thanks to progandy for the MemGlobalAlloc and tVARIANT lines and
;                       Yashied for _GDIPlus_BitmapCreateDIBFromBitmap() from WinAPIEx.au3
; Version:              v0.97 Build 2012-01-04 Beta
;=======================================================================================
Func _Load_BMP_From_Mem($bImage, $hHBITMAP = False)
	If Not IsBinary($bImage) Then Return SetError(1, 0, 0)
	Local $aResult
	Local Const $memBitmap = Binary($bImage) ;load image  saved in variable (memory) and convert it to binary
	Local Const $len = BinaryLen($memBitmap) ;get length of image
	Local Const $hData = _MemGlobalAlloc($len, $GMEM_MOVEABLE) ;allocates movable memory  ($GMEM_MOVEABLE = 0x0002)
	Local Const $pData = _MemGlobalLock($hData) ;translate the handle into a pointer
	Local $tMem = DllStructCreate("byte[" & $len & "]", $pData) ;create struct
	DllStructSetData($tMem, 1, $memBitmap) ;fill struct with image data
	_MemGlobalUnlock($hData) ;decrements the lock count  associated with a memory object that was allocated with GMEM_MOVEABLE
	$aResult = DllCall("ole32.dll", "int", "CreateStreamOnHGlobal", "handle", $pData, "int", True, "ptr*", 0) ;Creates a stream object that uses an HGLOBAL memory handle to store the stream contents
	If @error Then SetError(2, 0, 0)
	Local Const $hStream = $aResult[3]
	$aResult = DllCall($ghGDIPDll, "uint", "GdipCreateBitmapFromStream", "ptr", $hStream, "int*", 0) ;Creates a Bitmap object based on an IStream COM interface
	If @error Then SetError(3, 0, 0)
	Local Const $hBitmap = $aResult[2]
	Local $tVARIANT = DllStructCreate("word vt;word r1;word r2;word r3;ptr data; ptr")
	DllCall("oleaut32.dll", "long", "DispCallFunc", "ptr", $hStream, "dword", 8 + 8 * @AutoItX64, _
			"dword", 4, "dword", 23, "dword", 0, "ptr", 0, "ptr", 0, "ptr", DllStructGetPtr($tVARIANT)) ;release memory from $hStream to avoid memory leak
	$tMem = 0
	$tVARIANT = 0
	If $hHBITMAP Then
		Local Const $hHBmp = _GDIPlus_BitmapCreateDIBFromBitmap($hBitmap)
		_GDIPlus_BitmapDispose($hBitmap)
		Return $hHBmp
	EndIf
	Return $hBitmap
EndFunc   ;==>_Load_BMP_From_Mem

Func _GDIPlus_BitmapCreateDIBFromBitmap($hBitmap)
	Local $tBIHDR, $Ret, $tData, $pBits, $hResult = 0
	$Ret = DllCall($ghGDIPDll, 'uint', 'GdipGetImageDimension', 'ptr', $hBitmap, 'float*', 0, 'float*', 0)
	If (@error) Or ($Ret[0]) Then Return 0
	$tData = _GDIPlus_BitmapLockBits($hBitmap, 0, 0, $Ret[2], $Ret[3], $GDIP_ILMREAD, $GDIP_PXF32ARGB)
	$pBits = DllStructGetData($tData, 'Scan0')
	If Not $pBits Then Return 0
	$tBIHDR = DllStructCreate('dword;long;long;ushort;ushort;dword;dword;long;long;dword;dword')
	DllStructSetData($tBIHDR, 1, DllStructGetSize($tBIHDR))
	DllStructSetData($tBIHDR, 2, $Ret[2])
	DllStructSetData($tBIHDR, 3, $Ret[3])
	DllStructSetData($tBIHDR, 4, 1)
	DllStructSetData($tBIHDR, 5, 32)
	DllStructSetData($tBIHDR, 6, 0)
	$hResult = DllCall('gdi32.dll', 'ptr', 'CreateDIBSection', 'hwnd', 0, 'ptr', DllStructGetPtr($tBIHDR), 'uint', 0, 'ptr*', 0, 'ptr', 0, 'dword', 0)
	If (Not @error) And ($hResult[0]) Then
		DllCall('gdi32.dll', 'dword', 'SetBitmapBits', 'ptr', $hResult[0], 'dword', $Ret[2] * $Ret[3] * 4, 'ptr', DllStructGetData($tData, 'Scan0'))
		$hResult = $hResult[0]
	Else
		$hResult = 0
	EndIf
	_GDIPlus_BitmapUnlockBits($hBitmap, $tData)
	Return $hResult
EndFunc   ;==>_GDIPlus_BitmapCreateDIBFromBitmap

Func _Decompress_Binary_String_to_Bitmap($Base64String)
	$Base64String = Binary($Base64String)
	Local $iSize_Source = BinaryLen($Base64String)
	Local $pBuffer_Source = _WinAPI_CreateBuffer($iSize_Source)
	DllStructSetData(DllStructCreate('byte[' & $iSize_Source & ']', $pBuffer_Source), 1, $Base64String)
	Local $pBuffer_Decompress = _WinAPI_CreateBuffer(8388608)
	Local $Size_Decompressed = _WinAPI_DecompressBuffer($pBuffer_Decompress, 8388608, $pBuffer_Source, $iSize_Source)
	Local $b_Result = Binary(DllStructGetData(DllStructCreate('byte[' & $Size_Decompressed & ']', $pBuffer_Decompress), 1))
	_WinAPI_FreeMemory($pBuffer_Source)
	_WinAPI_FreeMemory($pBuffer_Decompress)
	Return $b_Result
EndFunc   ;==>_Decompress_Binary_String_to_Bitmap

Func _BinaryString_Picture_License()
	Local $Base64String
	$Base64String &= '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'
	$Base64String &= '8V/Gq1pR/wCpemu/+UAkQ01o64+C+VJ8w93dhPjs1Prom+zHdmImMv479NnkMo/LzsVJgJ85bLQZ2Bk+GP3dpAey7YH4MZMTQxTHRUlZnrHRaaCa7kOyHtWY5V7jJWpA40SuAdRWZLFuVCZVa9ejUcK2YmWxEeuXWygGBaIhYJ8jkixddfqADpBLr9sq2QkP1L01l/kAjxVhklGlBfFneYcnpYvyhZMAuGfs8GtimIT7f7kdkIgg0IyV0gF+NP5xCwIPrrS7q0AmB8MX6kWi8kDitl7GQdqkcr/MPWdQcknGkwuSROzU6wEVu2UcmBLNhXlwk01TDksUOgJkPj4IvowWAP8AXBdVdq+WtFtzPSaoDQ/5AvsrR9eq1b9EvzswO7AUdsMgVxBQWZnUOWS/0vmsBmjOOTkyw9GYeKh/sJLZkP8AU9dfMB//2Q=='
	Return Binary(_Base64Decode($Base64String))
EndFunc   ;==>_BinaryString_Picture_License

Func _BinaryString_Picture_Donate()
	Local $Base64String
	$Base64String &= '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'
	$Base64String &= 'BiQ59DpqaiDMpwyyGil/y8jUtzKbs/XrPX6NlzA0Fq9foqA7EYddkKhhvXqW68nIhK5YUDZtCRlS7vKubCww2f7X/TgI1DZypAvt745Zrq74ep06A04y+0pt1F1bySLEccF+jURppamw3nU66shA/CMyjYfkMcs11d8cs11d8cs11d8cs11d8cs11d8cs11d8cs11d8cs11d8Ba0JFk2ATj/xAAhEAEBAAIBBAMBAQAAAAAAAAABEQAhMUFRwfAQYYEwof/aAAgBAQABPyEjt9Sm/s/3N+Tk+N6dyqu8mReAF6bkuL1MpnVzvVlo7AqyBemOUCl5I/rA1zcI+CNmEtSUVQ1UcJJoLXlVWoB1XFfjR6R6E0baz3zxnvnjPfPGe+eMZyioRfoyh7AlLRBxx0Y9fYp5BYPjlNbM3zC89jUAzgcl1jFNRJVIbnTaCMoSXOMHNplE/ebvkZqiniGi6pQMOwXSyBsltvCZrjmxfqQOYTU5cYHHXXboKYjzWwqMDtY+1CcxjDHwUapL28PdaZMZtBUj17bWB0rfAr2lMK3QJ0+BKVrGNKgsovGWlRShRN77Bo7H8SSSSSSSSeQQ0SVeq98//9oADAMBAAIAAwAAABDAku1tuYBXOASefb//AP8A/wD/xAAgEQEAAgMAAwADAQAAAAAAAAABABEhMWFBUXEggZHw/9oACAEDAQE/EGaGz+EoW4bwH5dpAusuwJ3zn7UA+J7ZrEQo1yxVPj7v5UQk7q2U5HNV8jtsKNsr8FeJZQMC8efM4E4E4E4EI0eIgKKKGhaLLwZ1DgZkDAivLnOaxCzhob76iivWv5Eprxv0m2u9VXuz3AL4FFaV0XWcueREhdpuA4aY158foJSxO4Ha0owa/LR8gwUTgRkERKf9cXDHW1x6ys4E4E4E4E4E4E4E4EQtn//EACARAQACAwADAQADAAAAAAAAAAEAESExYUFRcYEgkaH/2gAIAQIBAT8QPi4D+2pbmlshfyj3f7F2yqlDzxRfpZ7Caye28cr7BwNXQHLTqvtwltur1YaTA39xAAVmmGvNvO9NagBpyaz4vH+Tozozozoxjb5gKuCEWhdEMqG0fyFpfDtZXwYaKvMpBd/BcG2/eVmbKuz7Ji/6v0D6j2ZQEWDbV4wYfcKUmEFZGGxm8efcGwjSTZgBvCmefy2fYsts6MvwiWONn5AyUu9Bn3gLZ0Z0Z0Z0Z0Z0Z0Z0YBRP/8QAHxABAQEBAAEEAwAAAAAAAAAAAREAIUEQMVFhIDCB/9oACAEBAAE/EA7IDlu0yqo+V+Tmt+pO4G+dFuUcCWCR+2mANAWCYKrl4BIJSsFTgNojpCgkkEl9M/VLL492YIQQnADPN1OCQCmEfnpz/mV+Bz8a1atWW6/IRWA7A79ZqmiliF92jvmTJYuvyADJaRCNKNQSxgjJSMKADB6m3aWsmWIMbGxEELhbhBEuNQ5gAwW0qo35faywmYAHZlpg/JwoBjx9RwQCmMeLBHdYu/DRlHPCo+zcdS3zApEBFyyKnpPfN/JUlwjiSD7mGoKUCQYWJYHsHpILSTWoQ4JUJaI9y6S1Rh6CGiKI8P0SSSSSSSSTAMD5k7LX53//2Q=='
	Return Binary(_Base64Decode($Base64String))
EndFunc   ;==>_BinaryString_Picture_Donate

Func _Base64Decode($input_string)
	Local $struct = DllStructCreate("int")
	Local $a_Call = DllCall("Crypt32.dll", "int", "CryptStringToBinary", "str", $input_string, "int", 0, "int", 1, "ptr", 0, "ptr", DllStructGetPtr($struct, 1), "ptr", 0, "ptr", 0)
	If @error Or Not $a_Call[0] Then Return SetError(1, 0, "")
	Local $a = DllStructCreate("byte[" & DllStructGetData($struct, 1) & "]")
	$a_Call = DllCall("Crypt32.dll", "int", "CryptStringToBinary", "str", $input_string, "int", 0, "int", 1, "ptr", DllStructGetPtr($a), "ptr", DllStructGetPtr($struct, 1), "ptr", 0, "ptr", 0)
	If @error Or Not $a_Call[0] Then Return SetError(2, 0, "")
	Return DllStructGetData($a, 1)
EndFunc   ;==>_Base64Decode

Func _GetDesktop_MousePos($sToolTip_Text = "")
	$i_GetDesktop_MousePos_Exit = 0

	_MouseHook_Set()
	OnAutoItExitRegister("_MouseHook_UnSet")

	Send("#m")
	HotKeySet("{Esc}", "_GetDesktop_MousePos_Exit")

	Local $VirtX = DllCall("user32.dll", "int", "GetSystemMetrics", "int", 78) ;SM_CXVIRTUALSCREEN 78
	;The width of the virtual screen, in pixels. The virtual screen is the bounding rectangle of all display monitors.
	;The SM_XVIRTUALSCREEN metric is the coordinates for the left side of the virtual screen.
	Local $VirtY = DllCall("user32.dll", "int", "GetSystemMetrics", "int", 79) ;SM_CYVIRTUALSCREEN 79
	;The height of the virtual screen, in pixels. The virtual screen is the bounding rectangle of all display monitors.
	;The SM_YVIRTUALSCREEN metric is the coordinates for the top of the virtual screen

	Local $hGUI = GUICreate("GUI", $VirtX[0], $VirtY[0], 0, 0, $WS_POPUP, BitOR($WS_EX_TOOLWINDOW, $WS_EX_TOPMOST, $WS_EX_LAYERED))
	GUISetBkColor(0xABABAB)
	_WinAPI_SetLayeredWindowAttributes($hGUI, 0x010101, 0)
	GUISetCursor(3) ; Cross
	GUISetState()

	Local $aMousePos, $aMousePos_Buffer
	$aMousePos = MouseGetPos()
	$aMousePos_Buffer = $aMousePos
	If Not $sToolTip_Text Then
		ToolTip("Select Desktop Position with left mouseclick (ESC to Exit)", Default, Default, "ICU", 1, 4)
	Else
		ToolTip(@CRLF & $sToolTip_Text & @CRLF & @CRLF & $aMousePos[0] & "x" & $aMousePos[1] & ", Press ESC to exit", Default, Default, "ICU - Move unkown Icon", 1, 4)
	EndIf

	While Sleep(10)
		If $i_GetDesktop_MousePos_Exit Then ExitLoop
		$aMousePos = MouseGetPos()
		If $aMousePos[0] <> $aMousePos_Buffer[0] Or $aMousePos[1] <> $aMousePos_Buffer[1] Then
			$aMousePos_Buffer = $aMousePos
			If $sToolTip_Text Then
				ToolTip(@CRLF & $sToolTip_Text & @CRLF & @CRLF & $aMousePos[0] & "x" & $aMousePos[1] & ", Press ESC to exit", Default, Default, "ICU - Move unkown Icon", 1, 4)
			Else
				ToolTip($aMousePos[0] & "x" & $aMousePos[1])
			EndIf
		EndIf
	WEnd

	ToolTip("")
	GUIDelete($hGUI)
	HotKeySet("{Esc}")
	_MouseHook_UnSet()
	OnAutoItExitUnRegister("_MouseHook_UnSet")

	If $i_GetDesktop_MousePos_Exit = 2 Then
		$aMousePos[0] = -1
		$aMousePos[1] = -1
	EndIf
	Return $aMousePos

EndFunc   ;==>_GetDesktop_MousePos

Func _GetDesktop_MousePos_Exit()
	$i_GetDesktop_MousePos_Exit = 2
EndFunc   ;==>_GetDesktop_MousePos_Exit

Func _MouseHook_Set()
	If $hMouseProc = -1 Then
		$hMouseProc = DllCallbackRegister("WM_MOUSEMOVE", "int", "uint;wparam;lparam")
	EndIf
	If $hMouseHook = -1 Then
		Local $hM_Module = _WinAPI_GetModuleHandle(0)
		$hMouseHook = _WinAPI_SetWindowsHookEx($WH_MOUSE_LL, DllCallbackGetPtr($hMouseProc), $hM_Module, 0)
	EndIf
EndFunc   ;==>_MouseHook_Set

Func _MouseHook_UnSet()
	If $hMouseHook <> -1 Then
		_WinAPI_UnhookWindowsHookEx($hMouseHook)
		$hMouseHook = -1
	EndIf
	If $hMouseProc <> -1 Then
		DllCallbackFree($hMouseProc)
		$hMouseProc = -1
	EndIf
EndFunc   ;==>_MouseHook_UnSet

Func WM_MOUSEMOVE($nCode, $wParam, $lParam)
	#forceref $nCode, $wParam, $lParam
	If $nCode < 0 Then Return _WinAPI_CallNextHookEx($hMouseHook, $nCode, $wParam, $lParam) ; let other hooks continue processing if any
	Switch $wParam
		Case $WM_LBUTTONDOWN
			Return -1 ; consume click
		Case $WM_LBUTTONUP
			$i_GetDesktop_MousePos_Exit = 1
			Return -1 ; consume click
	EndSwitch
	Return _WinAPI_CallNextHookEx($hMouseHook, $nCode, $wParam, $lParam) ; let other hooks continue processing if any
EndFunc   ;==>WM_MOUSEMOVE

Func _GUI_Help_Show()

	$b_GUI_Help_Exit = False

	GUISetState(@SW_HIDE, $h_GUI_Main)
	GUISetState(@SW_SHOW, $hGUI_Help)
	Opt("GUICloseOnESC", 1)

	Local $Msg

	While 1
		$Msg = GUIGetMsg(1)
		Switch $Msg[1]
			Case $hGUI_Help
				Switch $Msg[0]
					Case $GUI_EVENT_CLOSE
						ExitLoop
					Case $c_Help_Hyperlink_CC
						ShellExecute("http://creativecommons.org/licenses/by-nc-sa/3.0/", "", "", "open")
					Case $c_Help_Hyperlink_Funk
						ShellExecute('http://www.funk.eu')
				EndSwitch
		EndSwitch
		If $b_GUI_Help_Exit = True Then ExitLoop
	WEnd

	Opt("GUICloseOnESC", 0)
	GUISetState(@SW_HIDE, $hGUI_Help)
	GUISetState(@SW_SHOW, $h_GUI_Main)

	If $b_GUI_Help_Tray_Save Then
		$b_GUI_Help_Tray_Save = False
		_Save_Config()
		If $i_DCI_Is_Enabled Then _DCI_Registry_Update()
	EndIf

EndFunc   ;==>_GUI_Help_Show

Func _GUI_Help_Create()
	$hGUI_Help = GUICreate($sGUITitle, 600, 330, Default, Default, $WS_SYSMENU)
	_SetFont_hWnd(8, 400, 0, "Arial")
	GUISetBkColor(0xEEF1F6)
	WinSetOnTop($hGUI_Help, "", 1)

	GUICtrlCreateIcon(@ScriptName, 99, 20, 40, 48, 48)
	GUICtrlSetCursor(-1, 0)

	GUICtrlCreateLabel($sGUITitle, 80 + 10, 10, 380, 20)
	_SetFont_Ctrl(-1, 9, 800, 0, "Arial")

	GUICtrlCreateLabel('This program is freeware under a Creative Commons License "by-nc-sa 3.0":', 80 + 10, 40 - 10, 380, 20)
	GUICtrlCreateLabel('- Attribution' & @CRLF _
			 & '- Noncommercial' & @CRLF _
			 & '- Share Alike', 80 + 20, 60 - 10, 380, 50)
	_SetFont_Ctrl(-1, 8.5, 800, 0, "Arial")

	$c_Help_Hyperlink_CC = GUICtrlCreateLabel("http://creativecommons.org/licenses/by-nc-sa/3.0/", 80 + 34, 110 - 10, 230, 20)
	GUICtrlSetColor(-1, 0x0000FF)
	GUICtrlSetCursor(-1, 0)
	GUICtrlCreateLabel('Visit                                                                               for details.', 80 + 10, 110 - 10, 380, 20)
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)

	GUICtrlCreateEdit('I share this program with NO WARRANTIES and NO LIABILITY FOR DAMAGES!' & @CRLF _
			 & @CRLF _
			 & 'Special thanks goes to Melba23 for helping with the initial program version.' & @CRLF & @CRLF _
			 & 'Saved config files can be changed with the "right-click" contextmenu on the listview.' & @CRLF & @CRLF _
			 & 'ICU supports the following commandline parameters:' & @CRLF & @CRLF _
			 & '"icu.exe restore 2"' & @CRLF & 'Will restore the config #2 in the list.' & @CRLF & @CRLF _
			 & '"icu.exe restore NameX"' & @CRLF & 'Will restore the first config with "NameX" in the name.' & @CRLF & @CRLF _
			 & '"icu.exe restore %resolution%"' & @CRLF & '%resolution% as a wildcard will be replaced with the current resolution and bit depth (e.g. "1440x900x32"). Will restore the first config that matches the wildcard name name.' & @CRLF & @CRLF _
			 & '"icu.exe autosave"' & @CRLF & 'Saves the config to a timestamped file (e.g. for autostart usage).' & @CRLF & @CRLF _
			 & '"icu.exe save"' & @CRLF & 'Will bring up the ICU save config dialog.' & @CRLF & @CRLF _
			 & '"icu.exe savereplace 2"' & @CRLF & 'Will replace the saved config #2 with a new save, will NOT bring up save config dialog but use most recent settings.' & @CRLF & @CRLF _
			 & '"icu.exe savereplace NameX"' & @CRLF & 'Will replace the first config with "NameX" in the name with a new save, will NOT bring up save config dialog but use most recent settings.' & @CRLF & @CRLF _
			 & '"icu.exe savereplace %resolution%"' & @CRLF & '%resolution% as a wildcard will be replaced with the current resolution and bit depth (e.g. "1440x900x32"). Will replace the first config that matches the new save name.' & @CRLF & @CRLF _
			 & '"icu.exe minimized"' & @CRLF & 'Will start ICU in minimized mode / adds an ICU icon to tray. Useful for "Autostart" (esp. on XP without DCI) usage.' & @CRLF & @CRLF _
			 & '"icu.exe toggle 1 2"' & @CRLF & '"icu.exe toggle Config_A Config_B"' & @CRLF & 'Both configs must exist. The configs have a "last saved timestamp", ICU will evaluate which timestamp is older. The older one will be replaced with the current config and the newer one will be restored. CAUTION: ICU might get confused which config to restore if other configs are used in parallel. Always create a duplicate of the respective config files before trying the "toggle" switch.' & @CRLF & @CRLF _
			 & 'For commerical usage contact me via my homepage at http://www.funk.eu.' & @CRLF & @CRLF _
			 & '© ICU - Icon Configuration Utility 2009-2013 by Karsten Funk. All rights reserved.' _
			 & '', 10, 140, 575, 140, BitOR($WS_VSCROLL, $ES_READONLY))
	GUICtrlSetBkColor(-1, 0xffffff)
EndFunc   ;==>_GUI_Help_Create

Func _Tray_Show_Error_and_Exit($sText, $bExit = True)
	TraySetState(1 + 4) ; show & flash
	TraySetToolTip("ICU")
	TraySetIcon("stop")
	TrayTip($sGUITitle & " - Error", $sText, 10, 3)
	If $bExit Then
		Sleep(5000)
		AutoItWinSetTitle("")
		Exit
	EndIf
	Sleep(3000)
	TraySetState(8) ; stop flashing
	TraySetIcon(@ScriptDir, 0)
	TraySetState(2) ; hide
EndFunc   ;==>_Tray_Show_Error_and_Exit

Func _Epoch_encrypt($Date)

	Local $main_split = StringSplit($Date, " ")
	If $main_split[0] - 2 Then
		Return SetError(1, 0, "") ; invalid time format
	EndIf

	Local $asDatePart = StringSplit($main_split[1], "/")
	Local $asTimePart = StringSplit($main_split[2], ":")

	If $asDatePart[0] - 3 Or $asTimePart[0] - 3 Then
		Return SetError(1, 0, "") ; invalid time format
	EndIf

	If $asDatePart[2] < 3 Then
		$asDatePart[2] += 12
		$asDatePart[1] -= 1
	EndIf

	Local $i_aFactor = Int($asDatePart[1] / 100)
	Local $i_bFactor = Int($i_aFactor / 4)
	Local $i_cFactor = 2 - $i_aFactor + $i_bFactor
	Local $i_eFactor = Int(1461 * ($asDatePart[1] + 4716) / 4)
	Local $i_fFactor = Int(153 * ($asDatePart[2] + 1) / 5)
	Local $aDaysDiff = $i_cFactor + $asDatePart[3] + $i_eFactor + $i_fFactor - 2442112

	Local $iTimeDiff = $asTimePart[1] * 3600 + $asTimePart[2] * 60 + $asTimePart[3]

	Return SetError(0, 0, $aDaysDiff * 86400 + $iTimeDiff)

EndFunc   ;==>_Epoch_encrypt
