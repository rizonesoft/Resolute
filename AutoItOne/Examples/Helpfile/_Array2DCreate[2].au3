; == Example 2 _Array2DCreate() with 1D or 2D arrays

#include <Array.au3>

Local $aArray3

Local $aArray1 = [10, 11, 12]
Local $aArray2 = [20, 21, 22]
$aArray3 = _Array2DCreate($aArray1, $aArray2)
If @error Then Exit MsgBox(0, "_Array2DCreate 1D + 1D", "error " & @error)
_ArrayDisplay($aArray3, "1D + 1D")

Local $aArray1 = [10, 11, 12]
Local $aArray2 = [[20, 23], [21, 24], [22, 25]]
$aArray3 = _Array2DCreate($aArray1, $aArray2)
If @error Then Exit MsgBox(0, "_Array2DCreate 1D + 2D", "error " & @error)
_ArrayDisplay($aArray3, "1D + 2D")

Local $aArray1 = [[10, 13], [11, 14], [12, 15]]
Local $aArray2 = [20, 21, 22]
$aArray3 = _Array2DCreate($aArray1, $aArray2)
If @error Then Exit MsgBox(0, "_Array2DCreate 2D + 1D", "error " & @error)
_ArrayDisplay($aArray3, "2D + 1D")
Local $aArray1 = [[10, 13], [11, 14], [12, 15]]
Local $aArray2 = [[20, 23], [21, 24], [22, 25]]
$aArray3 = _Array2DCreate($aArray1, $aArray2)
If @error Then Exit MsgBox(0, "_Array2DCreate 2D + 2D", "error " & @error)
_ArrayDisplay($aArray3, "2D + 2D")

Local $oDi = ObjCreate('scripting.dictionary')
For $i = 0 To 10
	$oDi.Add('key' & $i, 'item' & $i)
Next

$aArray3 = _Array2DCreate($oDi.Keys, $oDi.Items)
If @error Then Exit MsgBox(0, "_Array2DCreate object 1D + 1D", "error " & @error)
_ArrayDisplay($aArray3, "object 1D + 1D", "", 0, Default, Default, -90)
