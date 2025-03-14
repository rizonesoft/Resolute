#include <WinAPIConv.au3>

Local $sIID = "{7b7166ec-21c7-44ae-b21a-c9ae321ae369}"
ConsoleWrite('@@ Debug(' & @ScriptLineNumber & ') : $sIID = ' & $sIID & @CRLF & '>Error code: ' & @error & '    Extended code: ' & @extended & ' (0x' & Hex(@extended) & ')' & @CRLF) ;### Debug Console

Local $tRIID = _WinAPI_GUIDFromString($sIID)

Local $sIID_Temp = _WinAPI_StringFromGUID($tRIID)
ConsoleWrite('@@ Debug(' & @ScriptLineNumber & ') : $sIID_Temp = ' & $sIID_Temp & @CRLF & '>Error code: ' & @error & '    Extended code: ' & @extended & ' (0x' & Hex(@extended) & ')' & @CRLF) ;### Debug Console

If $sIID_Temp <> $sIID Then MsgBox(0, "Error", $sIID & @CRLF & @TAB & "<> " & @CRLF & $sIID_Temp)
