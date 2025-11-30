; ===============================================================================================================================
; GUICtrlMenuEx UDF Example
; Purpose: Demonstrate The Usage Of GUICtrlMenuEx UDF
; Author:  Ward
; ===============================================================================================================================

#Include "GUICtrlMenuEx.au3"

GUIRegisterMsg($WM_COMMAND, "WM_COMMAND")

Example1()
Example2()
Example3()
Example4()

Func Example1()
	Example("Example1", Default, 24, 24, 24, 24, "Basic Example")
EndFunc

Func Example2()

	Example("Example2", Default, 16, 36, 48, 64, "Differet Icon Size")
EndFunc

Func Example3()
	Example("Example3", True, 24, 24, 24, 24, "Force Use Callback (2K/XP Default)")
EndFunc

Func Example4()
	Example("Example4", False, 24, 24, 24, 24, "Force Not Use Callback (Vista/Win7 Default)")
EndFunc

Func Example($Title, $UseCallback, $Size1, $Size2, $Size3, $Size4, $Text)

	_GUICtrlMenuEx_Startup($UseCallback)

	Local $Icon1 = _WinAPI_ShellExtractIcons("shell32.dll", 0, $Size1, $Size1)
	Local $Icon2 = _WinAPI_ShellExtractIcons("shell32.dll", 1, $Size2, $Size2)
	Local $Icon3 = _WinAPI_ShellExtractIcons("shell32.dll", 2, $Size3, $Size3)
	Local $Icon4 = _WinAPI_ShellExtractIcons("shell32.dll", 3, $Size4, $Size4)
	Local $Icon5 = _WinAPI_ShellExtractIcons("shell32.dll", 7, 64, 64)

	Local $GUI = GUICreate($Title, 600)

	Local $SubMenu = _GUICtrlMenu_CreatePopup()
	_GUICtrlMenuEx_AddMenuItem($SubMenu, "Test Menu Item 1", 1001, $Icon1)
	_GUICtrlMenuEx_AddMenuItem($SubMenu, "Test Menu Item 2", 1002, $Icon2)
	_GUICtrlMenuEx_AddMenuBar($SubMenu)
	_GUICtrlMenuEx_AddMenuItem($SubMenu, "Test Menu Item 3", 1003, $Icon3)

	_GUICtrlMenuEx_InsertMenuItem($SubMenu, 1, "Test Menu Item Insertion", 1004, $Icon4)
	_GUICtrlMenuEx_InsertMenuBar($SubMenu, 1)

	Local $MainMenu = _GUICtrlMenu_CreateMenu()
	_GUICtrlMenu_AddMenuItem($MainMenu, $Text, 0, $SubMenu)
	_GUICtrlMenuEx_SetItemIcon($MainMenu, 0, $Icon5)
	_GUICtrlMenu_SetMenu($GUI, $MainMenu)

	GUISetState()

	_WinAPI_DestroyIcon($Icon1)
	_WinAPI_DestroyIcon($Icon2)
	_WinAPI_DestroyIcon($Icon3)
	_WinAPI_DestroyIcon($Icon4)
	_WinAPI_DestroyIcon($Icon5)

	While 1
		Switch GUIGetMsg()
		Case $GUI_EVENT_CLOSE
			GUISetState(@SW_HIDE)
			_GUICtrlMenuEx_DestroyMenu($SubMenu)	; Release the image resource used by GUICtrlMenuEx
			_GUICtrlMenuEx_DestroyMenu($MainMenu)	; Release the image resource used by GUICtrlMenuEx
			ExitLoop

		Case $GUI_EVENT_SECONDARYUP
			_GUICtrlMenu_TrackPopupMenu($SubMenu, $GUI)

		EndSwitch
	WEnd
EndFunc

Func WM_COMMAND($hWnd, $Msg, $wParam, $lParam)
	Local $Code =_WinAPI_HiWord($wParam)
	If $Code = 0 Then ; Menu Command
		Local $MenuID = _WinAPI_LoWord($wParam)
		ConsoleWrite("MenuID " & $MenuID & @CRLF)
	EndIf
EndFunc

Func _WinAPI_ShellExtractIcons($Icon, $Index, $Width, $Height)
	Local $Ret = DllCall('shell32.dll', 'int', 'SHExtractIconsW', 'wstr', $Icon, 'int', $Index, 'int', $Width, 'int', $Height, 'ptr*', 0, 'ptr*', 0, 'int', 1, 'int', 0)
	If @Error Or $Ret[0] = 0 Or $Ret[5] = Ptr(0) Then Return SetError(1, 0, 0)
	Return $Ret[5]
EndFunc
