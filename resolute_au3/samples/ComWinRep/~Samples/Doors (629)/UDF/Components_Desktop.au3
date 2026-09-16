#include-once


Func _ReturnRemoveDeleteCaption()
	If RegRead("HKEY_CLASSES_ROOT\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}\shell\Delete", "Description") <> "" Or _
		RegRead("HKEY_CLASSES_ROOT\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}\ShellFolder", "Attributes") = "0x50010020" Then
		Return "Restore Delete or remove Rename from Recycle Bin"
	Else
		Return "Remove Delete or add Rename to Recycle Bin"
	EndIf
EndFunc
