#include <APILocaleConstants.au3>
#include <Array.au3>
#include <WinAPILocale.au3>

Local $aData = _WinAPI_EnumSystemGeoID()

If Not @error Then
	Local $aData2[UBound($aData)][$GEO_PARENT]
	For $iData_idx = 0 To $aData[0]
		For $iData2_idx = 1 To $GEO_PARENT
			$aData2[$iData_idx][$iData2_idx-1] = _WinAPI_GetGeoInfo($aData[$iData_idx], $iData2_idx)
		Next
	Next
	_ArrayDisplay($aData2, '_WinAPI_GetGeoInfo')
EndIf
