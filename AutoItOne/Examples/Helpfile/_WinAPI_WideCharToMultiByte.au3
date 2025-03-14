#include <WinAPIConv.au3>

;~ Global Const $CP = 0 ; CP_ACP default copepage
;~ Global Const $CP = GetACP() ; current codeoage
;~ Global Const $CP = 65001 ; UTF-8 certainly the best value
Global Const $CP = 932 ; CP_SHIFT_JIS

Local $sText = "データのダウンロードに失敗しました。"
;~ Local $sText = "abcdefg 1234567890"

Local $sOutput = @TAB & @TAB & "Copepage =" & $CP & @CRLF & @CRLF
$sOutput &= @TAB & "String[" & StringLen($sText) & "] = " & $sText & @CRLF & @CRLF

; ============== _WinAPI_WideCharToMultiByte Test ==============

Local $sTest = _WinAPI_WideCharToMultiByte($sText, $CP, True, False)
$sOutput &= "WideChar to String (MultiByte)" & @TAB & VarGetType($sTest) & " " & StringLen($sTest) & " :" & @CRLF & $sTest & @CRLF & @CRLF

$sTest = _WinAPI_WideCharToMultiByte($sText, $CP, True, True)
$sOutput &= "WideChar to Binary" & @TAB & VarGetType($sTest) & " " & BinaryLen($sTest) & " :" & @CRLF & $sTest & @CRLF & @CRLF

; ============== _WinAPI_MultiByteToWideChar Test ==============

Local $sMultiByte = _WinAPI_WideCharToMultiByte($sText, $CP, True, False)
$sOutput &= @CRLF & @TAB & "MultiByte[" & StringLen($sMultiByte) & "] = " & $sMultiByte & @CRLF & @CRLF

Local $tStruct = _WinAPI_MultiByteToWideChar($sMultiByte, $CP, 0, False)
$sOutput &= "MultiByte to Struct" & @TAB & @TAB & VarGetType($tStruct) & " " & DllStructGetSize($tStruct) & " :" & @CRLF & DllStructGetData($tStruct, 1) & @CRLF & @CRLF

$sTest = _WinAPI_MultiByteToWideChar($sMultiByte, $CP, 0, True)
$sOutput &= "MultiByte to String" & @TAB & VarGetType($sTest) & " " & StringLen($sTest) & " :" & @CRLF & $sTest & @CRLF & @CRLF

Local $iMB_TYPE = 0
If $sTest == $sText Then
	$sOutput &= @CRLF & @TAB & @TAB & "Conversion OK"
Else
	$sOutput &= @CRLF & @TAB & @TAB & " !!! Erreur de Conversion !!!"
	$iMB_TYPE = $MB_ICONERROR
EndIf

MsgBox($MB_SYSTEMMODAL + $iMB_TYPE, "Results", $sOutput)

Func GetACP()
	Local $aResult = DllCall("kernel32.dll", "int", "GetACP")
	If @error Or Not $aResult[0] Then Return SetError(@error + 20, @extended, "")
	Return $aResult[0]
EndFunc   ;==>GetACP
