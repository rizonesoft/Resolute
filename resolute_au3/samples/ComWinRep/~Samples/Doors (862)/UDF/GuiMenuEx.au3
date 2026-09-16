#Region Header

#cs

    Title:          Rizonesoft Menu UDF Library
    Filename:       GuiMenuEx.au3
    Description:
    Author:         Rizonesoft (Derick Payne)
    Version:        3.3.8.0
    Requirements:
    Uses:
    Note:           The library uses the following system DLLs:



    Available functions:

    _GUICtrlMenuEx_Startup

#ce

#Include-once

#include <OSVersion.au3>

#EndRegion Header


#Region Initialization
#EndRegion Initialization


#Region Global Variables and Constants

; Messages
;~ Global Const $WM_DRAWITEM = 0x002B
;~ Global Const $WM_MEASUREITEM = 0x002C

#EndRegion Global Variables and Constants


#Region Local Variables and Constants

Global $__g_GUICtrlMenuEx_UseCallback

#EndRegion Local Variables and Constants


#Region Public Functions

Func _GUICtrlMenuEx_Startup($UseCallback = Default)

	If IsKeyword($UseCallback) Then
		If _OsVersionTest(3, 6) Then ;~ $VER_GREATER_EQUAL = 3
			$UseCallback = False
		Else
			$UseCallback = True
		EndIf
	EndIf

	If $UseCallback Then
		;GUIRegisterMsg($WM_DRAWITEM, "__GUICtrlMenuEx_WM_DRAWITEM")
		;GUIRegisterMsg($WM_MEASUREITEM, "__GUICtrlMenuEx_WM_MEASUREITEM")
	Else
		GUIRegisterMsg(0x002B, "") ;~ $WM_DRAWITEM = 0x002B
		GUIRegisterMsg(0x002C, "") ;~ $WM_MEASUREITEM = 0x002C
	EndIf

	$__g_GUICtrlMenuEx_UseCallback = $UseCallback

EndFunc

#EndRegion Public Functions


#EndRegion Internal Functions

#EndRegion Internal Functions