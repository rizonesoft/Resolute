#include <MsgBoxConstants.au3>

Example()

Func Example()
	; Check if the registry key is already existing, so as not to damage the user's system.
	RegRead("HKEY_CURRENT_USER\Software\AutoIt_Example", "Key1")

	; @error is set to non-zero when reading a registry key that doesn't exist.
	If Not @error Then
		MsgBox($MB_SYSTEMMODAL, "", "An error occurred whilst the temporary registry key. ""AutoIt_Example"" appears to already exist.")
		Return False
	EndIf

	; Write a single REG_SZ value to the key "Key1".
	RegWrite("HKEY_CURRENT_USER\Software\AutoIt_Example", "Key1", "REG_SZ", "This is an example of RegWrite")

	; Write the REG_MULTI_SZ value of "Line 1" and "Line 2". Always append an extra line-feed character when writing a REG_MULTI_SZ value.
	RegWrite("HKEY_CURRENT_USER\Software\AutoIt_Example", "Key2", "REG_MULTI_SZ", "Line 1" & @LF & "Line 2" & @LF)

	; Write the REG_MULTI_SZ value of "Line 1". Always append an extra line-feed character when writing a REG_MULTI_SZ value.
	RegWrite("HKEY_CURRENT_USER\Software\AutoIt_Example", "Key3", "REG_MULTI_SZ", "Line 1" & @LF)

	; Display a message to navigate to RegEdit.exe manually.
	MsgBox($MB_SYSTEMMODAL, "", "Open RegEdit.exe and navigate the the registry key ""HKEY_CURRENT_USER\Software\AutoIt_Example"".")

	; Delete the temporary registry key.
	RegDelete("HKEY_CURRENT_USER\Software\AutoIt_Example")
EndFunc   ;==>Example
