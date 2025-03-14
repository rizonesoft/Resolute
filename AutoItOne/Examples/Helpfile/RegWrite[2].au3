#include <MsgboxConstants.au3>

;~ #RequireAdmin

; require admin privilege
Local $sKey = "HKEY_LOCAL_MACHINE64\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Active Setup Temp Folders"
Local $iRegWrite = RegWrite($sKey, "test", "REG_DWORD", "1")
If $iRegWrite = 0 Then
	MsgBox($MB_ICONWARNING + $MB_TOPMOST, "REQUIRE Admin", "Cannot be created" & @CRLF & @CRLF & $sKey & @CRLF & @CRLF & 'Return = ' & $iRegWrite & @CRLF & '@error = ' & @error & @TAB & '@extended = ' & @extended & ' (0x' & Hex(@extended) & ')') ;### Debug MSGBOX
Else
	MsgBox($MB_TOPMOST, "RegWrite", $sKey & @CRLF & @CRLF & "succesfully created")

	; clean registry
	RegDelete($sKey, "test")
EndIf

; Does not require admin privilege
$sKey = "HKEY_CURRENT_USER\Software\Test"
$iRegWrite = RegWrite("HKEY_CURRENT_USER\Software\Test", "test", "REG_DWORD", "1")
If $iRegWrite = 0 Then
	; Should not occur
	MsgBox($MB_ICONERROR + $MB_TOPMOST, "AutoIt Error", "Cannot create" & @CRLF & @CRLF & $sKey & @CRLF & @CRLF & 'Return = ' & $iRegWrite & @CRLF & '@error = ' & @error & @TAB & '@extended = ' & @extended & ' (0x' & Hex(@extended) & ')')
Else
	If IsAdmin() Then
		MsgBox($MB_TOPMOST, "RegWrite", $sKey & " succesfully created")
	Else
		ConsoleWrite("- " & $sKey & " succesfully created" & @CRLF)
	EndIf

	; clean registry
	RegDelete($sKey, "test")
	RegDelete($sKey)
EndIf
