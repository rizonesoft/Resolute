#Include <APIConstants.au3>
#Include <Array.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

If _WinAPI_GetVersion() < '6.1' Then
	MsgBox(16, 'Error', 'Require Windows 7 or later.')
	Exit
EndIf

Global $Item, $Temp

; Create array of strings ("Item*")
Dim $Item[100]
For $i = 0 To UBound($Item) - 1
	$Item[$i] = 'Item' & Random(0, 100, 1)
Next

_ArrayDisplay($Item)

; Simple array sorting
_ArraySort($Item)

_ArrayDisplay($Item)

; Sort array (bubble sort) ignoring case sensitive and according to the digits
For $i = 0 To UBound($Item) - 2
	For $j = $i + 1 To UBound($Item) - 1
		Switch _WinAPI_CompareString($LOCALE_INVARIANT, $Item[$i], $Item[$j], BitOR($NORM_IGNORECASE, $SORT_DIGITSASNUMBERS))
			Case $CSTR_GREATER_THAN
				$Temp = $Item[$i]
				$Item[$i] = $Item[$j]
				$Item[$j] = $Temp
			Case Else

		EndSwitch
	Next
Next

_ArrayDisplay($Item)
