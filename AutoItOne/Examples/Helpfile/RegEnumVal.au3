#include <MsgBoxConstants.au3>

Example()

Func Example()
	Local $i, $sVar, $sWow64 = "", $sEnumVal = "Under AutoIt3 key." & @CRLF & @CRLF
	Local $aRegValueType[12] = ["REG_NONE", "REG_SZ", "REG_EXPAND_SZ", "REG_BINARY", _
			"REG_DWORD_LITTLE_ENDIAN", "REG_DWORD_BIG_ENDIAN", "REG_LINK", _
			"REG_MULTI_SZ", "REG_RESOURCE_LIST", "REG_FULL_RESOURCE_DESCRIPTOR", _
			"REG_RESOURCE_REQUIREMENTS_LIST", "REG_QWORD_LITTLE_ENDIAN"]

	; X64 running support
	If @AutoItX64 Then $sWow64 = "\Wow6432Node"

	For $i = 1 To 100
		$sVar = RegEnumVal("HKEY_LOCAL_MACHINE\SOFTWARE" & $sWow64 & "\AutoIt v3\AutoIt", $i)
		If @error <> 0 Then ExitLoop
		$sEnumVal &= "# " & $i & ":" & StringLeft($aRegValueType[@extended] & "                         ", 31) & $sVar & @CRLF
	Next

	MsgBox($MB_SYSTEMMODAL, "RegEnumVal example", $sEnumVal)

EndFunc   ;==>Example
