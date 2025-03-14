#include <Array.au3>

Local $oDi = ObjCreate('scripting.dictionary')
For $i = 0 To 10
	$oDi.Add('key' & $i, 'item' & $i)
Next

_ArrayDisplay(_Array2DCreate($oDi.Keys, $oDi.Items))
