#include <Array.au3>
#include <GDIPlus.au3>

Example()

Func Example()
	_GDIPlus_Startup()

	; X64 running support
	Local $sWow64 = ""
	If @AutoItX64 Then $sWow64 = "\Wow6432Node"

	Local $hImage = _GDIPlus_ImageLoadFromFile(RegRead("HKLM\SOFTWARE" & $sWow64 & "\AutoIt v3\AutoIt", "InstallDir") & "\Examples\GUI\Torus.png")
	If @error Then
		_GDIPlus_Shutdown()
		MsgBox(16, "", "An error has occured - unable to load image!", 30)
		Return False
	EndIf

	Local $aPropID = _GDIPlus_ImageGetPropertyIdList($hImage)
	_ArrayDisplay($aPropID)

	Local $aValues
	For $i = 1 To $aPropID[0][0]
		$aValues = _GDIPlus_ImageGetPropertyItem($hImage, $aPropID[$i][0])
		_ArrayDisplay($aValues, $aPropID[$i][1])
	Next

	_GDIPlus_ImageDispose($hImage)
	_GDIPlus_Shutdown()
EndFunc   ;==>Example
