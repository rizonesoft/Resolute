#include <GDIPlus.au3>
#include <GUIConstantsEx.au3>
#include <WinAPIGdiDC.au3>

Example1()
Example2()

Func Example1()
	_GDIPlus_Startup()
	Local $hGUI = GUICreate("GDI+", 400, 300)
	GUISetState(@SW_SHOW)
	Local $hGraphic = _GDIPlus_GraphicsCreateFromHWND($hGUI)
	Local $hRegion = _GDIPlus_RegionCreate()
	_GDIPlus_RegionSetEmpty($hRegion)
	_GDIPlus_RegionCombineRect($hRegion, 50, 50, 300, 200, 3)
	_GDIPlus_GraphicsSetClipRegion($hGraphic, $hRegion)
	_GDIPlus_GraphicsClear($hGraphic, 0xFF00FF00)
	_GDIPlus_RegionSetInfinite($hRegion)
	_GDIPlus_RegionCombineRect($hRegion, 50, 50, 300, 200, 3)
	_GDIPlus_GraphicsSetClipRegion($hGraphic, $hRegion)
	_GDIPlus_GraphicsClear($hGraphic, 0xFF0000FF)
	Do
	Until GUIGetMsg() = $GUI_EVENT_CLOSE
	_GDIPlus_RegionDispose($hRegion)
	_GDIPlus_GraphicsDispose($hGraphic)
	_GDIPlus_Shutdown()
	GUIDelete($hGUI)
EndFunc   ;==>Example1

Func Example2()
	; X64 running support
	Local $sWow64 = ""
	If @AutoItX64 Then $sWow64 = "\Wow6432Node"

	Run(RegRead("HKLM\SOFTWARE" & $sWow64 & "\AutoIt v3\AutoIt", "InstallDir") & "\Au3Info.exe")
	Local $sClass = "Au3Info"

	WinWait("[CLASS:" & $sClass & "]", "", 3)
	Local $hWnd = WinGetHandle("[CLASS:" & $sClass & "]")
	If @error Then Return MsgBox(16, "", "An error occurred when trying to retrieve the window handle of class " & $sClass)

	Local $aCtrlList = _EnumCtrl($hWnd)

	_GDIPlus_Startup()
	Local $hDC = _WinAPI_GetDC($hWnd)
	Local $hGraphics = _GDIPlus_GraphicsCreateFromHDC($hDC)

	Local $hRegion = _GDIPlus_RegionCreate()
	_GDIPlus_RegionSetEmpty($hRegion)

	Local $aPos
	For $i = 1 To $aCtrlList[0]
		$aPos = ControlGetPos($hWnd, "", $aCtrlList[$i])
		If @error Or Not IsArray($aPos) Then ContinueLoop
		Select
			Case StringInStr($aCtrlList[$i], "SysTabControl32")
				_GDIPlus_RegionCombineRect($hRegion, $aPos[0], $aPos[1], $aPos[2], $aPos[3], 3)
			Case StringInStr($aCtrlList[$i], "Button")
				_GDIPlus_RegionCombineRect($hRegion, $aPos[0], $aPos[1], $aPos[2], $aPos[3], 4)
			Case StringInStr($aCtrlList[$i], "Edit")
				_GDIPlus_RegionCombineRect($hRegion, $aPos[0], $aPos[1], $aPos[2], $aPos[3], 3)
		EndSelect
	Next

	_GDIPlus_GraphicsSetClipRegion($hGraphics, $hRegion)

	Local $iBlue, $iDir = 1
	While WinExists($hWnd)
		$iBlue += 1 * $iDir
		If BitOR($iBlue = 0, $iBlue = 255) Then $iDir *= -1
		_GDIPlus_GraphicsClear($hGraphics, BitOR(0xFF000000, BitAND($iBlue, 0xFF)))
		Sleep(10)
	WEnd

	_GDIPlus_RegionDispose($hRegion)
	_GDIPlus_GraphicsDispose($hGraphics)
	_WinAPI_ReleaseDC($hWnd, $hDC)
	_GDIPlus_Shutdown()
EndFunc   ;==>Example2

Func _EnumCtrl($hWnd)
	Local $sClassList = WinGetClassList($hWnd)
	Local $aSplit = StringSplit($sClassList, @CRLF)

	Local $iCnt, $aCtrlList[1]
	For $i = 1 To $aSplit[0]
		$iCnt = 1
		If $aSplit[$i] = "" Then ContinueLoop
		$aCtrlList[0] += 1
		ReDim $aCtrlList[$aCtrlList[0] + 1]
		$aCtrlList[$aCtrlList[0]] = $aSplit[$i] & $iCnt
		For $j = $i + 1 To $aSplit[0]
			If $aSplit[$i] <> $aSplit[$j] Then
				ContinueLoop
			Else
				$iCnt += 1
				$aCtrlList[0] += 1
				ReDim $aCtrlList[$aCtrlList[0] + 1]
				$aCtrlList[$aCtrlList[0]] = $aSplit[$i] & $iCnt
				$aSplit[$j] = ""
			EndIf
		Next
		$aSplit[$i] = ""
	Next
	Return $aCtrlList
EndFunc   ;==>_EnumCtrl
