#Include <APIConstants.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global Const $sEmf = @ScriptDir & '\Test.emf'

Global $hDC, $tRECT, $hPen, $hBrush, $hPen, $hRgn, $hEmf

Dim $aPoint[10][2] = [[0, 90], [95, 90], [125, 0], [154, 90], [250, 90], [172, 147], [202, 238], [125, 181], [47, 238], [77, 147]]

If FileExists($sEmf) Then
	If MsgBox(3 + 32 + 256, 'Create Enhanced Metafile', $sEmf & ' is already exists.' & @CR & @CR & 'Do you want to replace it?') <> 6 Then
		Exit
	EndIf
	If Not FileDelete($sEmf) Then
		MsgBox(16, 'Create Enhanced Metafile', 'Unable to delete file.')
		Exit
	EndIf
EndIf

; Create device context for an enhanced-format metafile
$tRECT = _WinAPI_CreateRect(0, 0, 250, 250)
$hDC = _WinAPI_CreateEnhMetaFile(0, $tRECT, 1, @ScriptDir & '\Test.emf')

; Draw objects
$hBrush = _WinAPI_SelectObject($hDC, _WinAPI_GetStockObject($DC_BRUSH))
$hPen = _WinAPI_SelectObject($hDC, _WinAPI_GetStockObject($NULL_PEN))
_WinAPI_SetDCBrushColor($hDC, 0xAA0000)
_WinAPI_Rectangle($hDC, $tRECT)
_WinAPI_SetDCBrushColor($hDC, 0xFFFFFF)
$hRgn = _WinAPI_CreatePolygonRgn($aPoint)
_WinAPI_OffsetRgn($hRgn, 0, 6)
_WinAPI_PaintRgn($hDC, $hRgn)

; Release objects
_WinAPI_SelectObject($hDC, $hBrush)
_WinAPI_SelectObject($hDC, $hPen)
$hEmf = _WinAPI_CloseEnhMetaFile($hDC)
_WinAPI_DeleteEnhMetaFile($hEmf)
_WinAPI_DeleteObject($hRgn)

; Show created .emf file into the Microsoft Paint
If FileExists($sEmf) Then
	ShellExecute(@SystemDir & '\mspaint.exe', $sEmf)
EndIf
