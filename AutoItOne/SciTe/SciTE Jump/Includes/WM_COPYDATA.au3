#include-once
#include <SendMessage.au3>
#include <StringConstants.au3>
#include <WindowsConstants.au3>

Global Enum $__hInterCommunicationGUI, $__iInterCommunicationControlID, $__sInterCommunicationIDString, $__sInterCommunicationData, $__iInterCommunicationMax
Global $__vInterCommunicationAPI[$__iInterCommunicationMax] ; Internal array for the WM_COPYDATA functions.

Func _WM_COPYDATA($hWnd, $iMsg, $wParam, $lParam)
	#forceref $hWnd, $iMsg, $wParam
	Local Const $tagCOPYDATASTRUCT = 'ptr;dword;ptr' ; 'ulong_ptr;dword;ptr'
	Local Const $tParam = DllStructCreate($tagCOPYDATASTRUCT, $lParam)
	Local Const $tData = DllStructCreate('char[' & DllStructGetData($tParam, 2) + 1 & ']', DllStructGetData($tParam, 3)) ; wchar
	$__vInterCommunicationAPI[$__sInterCommunicationData] = StringLeft(DllStructGetData($tData, 1), DllStructGetData($tParam, 2))
	GUICtrlSendToDummy($__vInterCommunicationAPI[$__iInterCommunicationControlID])
EndFunc   ;==>_WM_COPYDATA

Func _WM_COPYDATA_GetData()
	Local $sReturn = $__vInterCommunicationAPI[$__sInterCommunicationData]
	$__vInterCommunicationAPI[$__sInterCommunicationData] = ''
	Return $sReturn
EndFunc   ;==>_WM_COPYDATA_GetData

Func _WM_COPYDATA_GetGUI()
	Return $__vInterCommunicationAPI[$__hInterCommunicationGUI]
EndFunc   ;==>_WM_COPYDATA_GetGUI

Func _WM_COPYDATA_GetID()
	Return $__vInterCommunicationAPI[$__sInterCommunicationIDString]
EndFunc   ;==>_WM_COPYDATA_GetID

Func _WM_COPYDATA_Send($sMsg)
	If _WM_COPYDATA_GetGUI() = -1 Then
		Return SetError(1, 0, 0)
	EndIf

	If StringStripWS($sMsg, $STR_STRIPALL) = '' Then
		Return SetError(2, 0, 0)
	EndIf

	If _WM_COPYDATA_GetGUI() Then
		Local Const $tBuffer = DllStructCreate('wchar cdata[' & StringLen($sMsg) + 1 & ']')
		DllStructSetData($tBuffer, 'cdata', $sMsg)
		Local Const $tagCOPYDATASTRUCT = 'ulong_ptr dwData;dword cbData;ptr lpData' ; 'ulong_ptr dwData;dword cbData;ptr lpData'
		Local Const $tCOPYDATASTRUCT = DllStructCreate($tagCOPYDATASTRUCT)
		DllStructSetData($tCOPYDATASTRUCT, 'dwData', 0)
		DllStructSetData($tCOPYDATASTRUCT, 'cbData', DllStructGetSize($tBuffer))
		DllStructSetData($tCOPYDATASTRUCT, 'lpData', DllStructGetPtr($tBuffer))
		_SendMessage(_WM_COPYDATA_GetGUI(), $WM_COPYDATA, 0, DllStructGetPtr($tCOPYDATASTRUCT))
		Return Number(Not @error)
	EndIf
EndFunc   ;==>_WM_COPYDATA_Send

Func _WM_COPYDATA_SetGUI($vGUI)
	$__vInterCommunicationAPI[$__hInterCommunicationGUI] = $vGUI
EndFunc   ;==>_WM_COPYDATA_SetGUI

Func _WM_COPYDATA_SetID($sIDString)
	$__vInterCommunicationAPI[$__sInterCommunicationIDString] = $sIDString
	Return $sIDString
EndFunc   ;==>_WM_COPYDATA_SetID

Func _WM_COPYDATA_Shutdown()
	Local Const $hWnd = WinGetHandle(AutoItWinGetTitle())
	GUIRegisterMsg($WM_COPYDATA, '')
	GUIDelete(_WM_COPYDATA_GetGUI())
	ControlSetText($hWnd, '', ControlGetHandle($hWnd, '', 'Edit1'), '')
EndFunc   ;==>_WM_COPYDATA_Shutdown

Func _WM_COPYDATA_Start($hGUI, $fCheckOnly = Default)
	Local $hWnd = WinGetHandle(_WM_COPYDATA_GetID())
	If @error Then
		If $fCheckOnly Then
			Return 0
		EndIf
		AutoItWinSetTitle(_WM_COPYDATA_GetID())
		$hWnd = WinGetHandle(_WM_COPYDATA_GetID())

		If IsHWnd($hGUI) = 0 Or $hGUI = Default Then
			$hGUI = GUICreate('', 0, 0, -99, -99, '', $WS_EX_TOOLWINDOW)
			GUISetState(@SW_SHOW, $hGUI)
		EndIf
		If IsAdmin() Then
			_WinAPI_ChangeWindowMessageFilterEx($hGUI, $WM_COPYDATA, $MSGFLT_ALLOW)
		EndIf
		ControlSetText($hWnd, '', ControlGetHandle($hWnd, '', 'Edit1'), $hGUI)
		GUIRegisterMsg($WM_COPYDATA, '_WM_COPYDATA')
		_WM_COPYDATA_SetGUI(-1)
		$__vInterCommunicationAPI[$__iInterCommunicationControlID] = GUICtrlCreateDummy()
		Return $__vInterCommunicationAPI[$__iInterCommunicationControlID]
	Else
		$hWnd = HWnd(ControlGetText($hWnd, '', ControlGetHandle($hWnd, '', 'Edit1')))
		_WM_COPYDATA_SetGUI($hWnd)
		Return SetError(1, 0, $hWnd)
	EndIf
EndFunc   ;==>_WM_COPYDATA_Start
