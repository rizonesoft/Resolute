#include <Array.au3>
#include <WinAPIDiag.au3>
#include <WinAPIMisc.au3>

_Example()

Func _Example()
	Local $aData = _WinAPI_EnumDllProc('ntdll.dll', 'Rtl*', $SYMOPT_CASE_INSENSITIVE)

	If IsArray($aData) Then
		For $i = 1 To $aData[0][0]
			$aData[$i][0] = '0x' & Hex($aData[$i][0])
		Next
	EndIf

	_ArrayDisplay($aData, _WinAPI_GetExtended())
EndFunc   ;==>_Example
