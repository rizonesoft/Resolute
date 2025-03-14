#include-once

#include "Memory.au3"
#include "WinAPISysInternals.au3"

; #INDEX# =======================================================================================================================
; Title .........: GUI Ctrl Extended UDF Library for AutoIt3
; AutoIt Version : 3.3.16.1
; Description ...: Functions that assist with _GUI control management.
; Author(s) .....: jpm
; ===============================================================================================================================

#Region Global Variables and Constants

; #VARIABLES# ===================================================================================================================
Global $__g_hGUICtrl_LastWnd
; ===============================================================================================================================

; #CONSTANTS# ===================================================================================================================
; ===============================================================================================================================

#EndRegion Global Variables and Constants

#Region Functions list

; #CURRENT# =====================================================================================================================
; ===============================================================================================================================

; #INTERNAL_USE_ONLY# ===========================================================================================================
; __GUICtrl_SendMsg
; ===============================================================================================================================

#EndRegion Functions list

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __GUICtrl_SendMsg
; Description ...: _SendMessage() wrapper  for handling In or out process
; Syntax.........: __GUICtrl_SendMsg($hWnd, $iMsg, $iIndex, ByRef $tItem, $tBuffer, $bRetItem, $iElement, $bRetBuffer, $iElementMAX)
; Parameters ....: $hWnd        - Handle of the control
;                  $iMsg        - SendMessage Msg value
;                  $iIndex      - index of the Item
;                  $tItem       - Struct of the Item
;                  $tBuffer     - Struct to contain return chars
;                  $bRetItem    - tItem must be return
;                  $iElement    - index of the element
;                  $bRetBuffer  - tBuffer must be return
;                  $iElementMax - index of the MAX element
; Return values .: result of the SendMessage
; Author ........: Jpm
; Modified ......:
; Remarks .......:
; Related .......: _GUICtrlListView_GetItemEx, _GUICtrlListView_GetItemText, __GUICtrlListView_Sort
; ===============================================================================================================================
Func __GUICtrl_SendMsg($hWnd, $iMsg, $iIndex, ByRef $tItem, $tBuffer = 0, $bRetItem = False, $iElement = -1, $bRetBuffer = False, $iElementMax = $iElement)
	If $iElement > 0 Then
		DllStructSetData($tItem, $iElement, DllStructGetPtr($tBuffer))
		If $iElement = $iElementMax Then DllStructSetData($tItem, $iElement + 1, DllStructGetSize($tBuffer))
	EndIf

	Local $iRet
	If IsHWnd($hWnd) Then
		If _WinAPI_InProcess($hWnd, $__g_hGUICtrl_LastWnd) Then
			$iRet = DllCall("user32.dll", "lresult", "SendMessageW", "hwnd", $hWnd, "uint", $iMsg, "wparam", $iIndex, "struct*", $tItem)[0]
		Else
			Local $iItem = DllStructGetSize($tItem)
			Local $tMemMap, $pText
			Local $iBuffer = 0
			If ($iElement > 0) Or ($iElementMax = 0) Then $iBuffer = DllStructGetSize($tBuffer)
			Local $pMemory = _MemInit($hWnd, $iItem + $iBuffer, $tMemMap)
			If $iBuffer Then
				$pText = $pMemory + $iItem
				If $iElementMax Then
					DllStructSetData($tItem, $iElement, $pText)
				Else
					$iIndex = $pText
				EndIf
				_MemWrite($tMemMap, $tBuffer, $pText, $iBuffer)
			EndIf
			_MemWrite($tMemMap, $tItem, $pMemory, $iItem)
			$iRet = DllCall("user32.dll", "lresult", "SendMessageW", "hwnd", $hWnd, "uint", $iMsg, "wparam", $iIndex, "ptr", $pMemory)[0]
			If $iBuffer And $bRetBuffer Then _MemRead($tMemMap, $pText, $tBuffer, $iBuffer)
			If $bRetItem Then _MemRead($tMemMap, $pMemory, $tItem, $iItem)
			_MemFree($tMemMap)
		EndIf
	Else
		$iRet = GUICtrlSendMsg($hWnd, $iMsg, $iIndex, DllStructGetPtr($tItem))
	EndIf

	Return $iRet
EndFunc   ;==>__GUICtrl_SendMsg

Func __GUICtrl_SendMsg_Init($hWnd, $iMsg, $iIndex, ByRef $tItem, $tBuffer = 0, $bRetItem = False, $iElement = -1, $bRetBuffer = False, $iElementMax = $iElement)
	#forceref $iMsg, $iIndex, $bRetItem, $bRetBuffer
	DllStructSetData($tItem, $iElement, DllStructGetPtr($tBuffer))
	If $iElement = $iElementMax Then DllStructSetData($tItem, $iElement + 1, DllStructGetSize($tBuffer))

	Local $pFunc
	If IsHWnd($hWnd) Then
		If _WinAPI_InProcess($hWnd, $__g_hGUICtrl_LastWnd) Then
			$pFunc = __GUICtrl_SendMsg_InProcess
			SetExtended(1)
		Else
			$pFunc = __GUICtrl_SendMsg_OutProcess
			SetExtended(2)
		EndIf
	Else
		$pFunc = __GUICtrl_SendMsg_Internal
		SetExtended(3)
	EndIf

	Return $pFunc
EndFunc   ;==>__GUICtrl_SendMsg_Init

Func __GUICtrl_SendMsg_InProcess($hWnd, $iMsg, $iIndex, ByRef $tItem, $tBuffer = 0, $bRetItem = False, $iElement = -1, $bRetBuffer = False, $iElementMax = $iElement)
	#forceref $tBuffer, $bRetItem, $bRetBuffer, $iElementMax
	Return DllCall("user32.dll", "lresult", "SendMessageW", "hwnd", $hWnd, "uint", $iMsg, "wparam", $iIndex, "struct*", $tItem)[0]
EndFunc   ;==>__GUICtrl_SendMsg_InProcess

Func __GUICtrl_SendMsg_OutProcess($hWnd, $iMsg, $iIndex, ByRef $tItem, $tBuffer = 0, $bRetItem = False, $iElement = -1, $bRetBuffer = False, $iElementMax = $iElement)
	Local $iItem = DllStructGetSize($tItem)
	Local $tMemMap, $pText
	Local $iBuffer = 0
	If ($iElement > 0) Or ($iElementMax = 0) Then $iBuffer = DllStructGetSize($tBuffer)
	Local $pMemory = _MemInit($hWnd, $iItem + $iBuffer, $tMemMap)
	If $iBuffer Then
		$pText = $pMemory + $iItem
		If $iElementMax Then
			DllStructSetData($tItem, $iElement, $pText)
		Else
			$iIndex = $pText
		EndIf
		_MemWrite($tMemMap, $tBuffer, $pText, $iBuffer)
	EndIf
	_MemWrite($tMemMap, $tItem, $pMemory, $iItem)
	Local $iRet = DllCall("user32.dll", "lresult", "SendMessageW", "hwnd", $hWnd, "uint", $iMsg, "wparam", $iIndex, "ptr", $pMemory)[0]
	If $iBuffer And $bRetBuffer Then _MemRead($tMemMap, $pText, $tBuffer, $iBuffer)
	If $bRetItem Then _MemRead($tMemMap, $pMemory, $tItem, $iItem)
	_MemFree($tMemMap)

	Return $iRet
EndFunc   ;==>__GUICtrl_SendMsg_OutProcess

Func __GUICtrl_SendMsg_Internal($hWnd, $iMsg, $iIndex, ByRef $tItem, $tBuffer = 0, $bRetItem = False, $iElement = -1, $bRetBuffer = False, $iElementMax = $iElement)
	#forceref $tBuffer, $bRetItem, $bRetBuffer, $iElementMax
	Return GUICtrlSendMsg($hWnd, $iMsg, $iIndex, DllStructGetPtr($tItem))
EndFunc   ;==>__GUICtrl_SendMsg_Internal
