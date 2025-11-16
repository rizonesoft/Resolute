#include-once


#Region AutoIt3Wrapper Directives Section
;===============================================================================================================
; Tidy Settings
;===============================================================================================================
#AutoIt3Wrapper_Run_Tidy=Y										;~ (Y/N) Run Tidy before compilation. Default=N
#AutoIt3Wrapper_Tidy_Stop_OnError=Y								;~ (Y/N) Continue when only Warnings. Default=Y

#EndRegion AutoIt3Wrapper Directives Section


#include <GuiListView.au3>


; #INDEX# =======================================================================================================================
; Title .........: ImageListEx
; AutoIt Version : 3.3.12.0
; Language ......: English
; Description ...: Image List Extended Functions.
; Author(s) .....: Derick Payne
; Dll(s) ........:
; ===============================================================================================================================

; #CURRENT# =====================================================================================================================
; _ImageListEx_AddBlankIcon
; ===============================================================================================================================


Func _ImageListEx_AddBlankIcon($hWnd, $hWndListView, $sFilePath, $iIndex = 0, $bLarge = False)

	_GUIImageList_AddIcon($hWnd, $sFilePath, $iIndex, $bLarge)
	If @error Then
		_GUIImageList_Add($hWnd, _GUICtrlListView_CreateSolidBitMap($hWndListView, 0xFFEFEF, 16, 16))
	EndIf

EndFunc