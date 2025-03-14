#include <Array.au3>

_Example()

Func _Example()

	ConsoleWrite("> $aTest_1_Empty_Array" & @CRLF)
	Local $aTest_1_Empty_Array[]
	ConsoleWrite(UBound($aTest_1_Empty_Array, $UBOUND_DIMENSIONS) & @CRLF)
	ConsoleWrite(UBound($aTest_1_Empty_Array, $UBOUND_ROWS) & @CRLF)
	ConsoleWrite(UBound($aTest_1_Empty_Array, $UBOUND_COLUMNS) & @CRLF)

	ConsoleWrite("> $aTest_2_Empty_1D" & @CRLF)
	Local $aTest_2_Empty_1D[0]
	ConsoleWrite(UBound($aTest_2_Empty_1D, $UBOUND_DIMENSIONS) & @CRLF)
	ConsoleWrite(UBound($aTest_2_Empty_1D, $UBOUND_ROWS) & @CRLF)
	ConsoleWrite(UBound($aTest_2_Empty_1D, $UBOUND_COLUMNS) & @CRLF)

	ConsoleWrite("> $aTest_3_Empty_2D" & @CRLF)
	Local $aTest_3_Empty_2D[0][5]
	ConsoleWrite(UBound($aTest_3_Empty_2D, $UBOUND_DIMENSIONS) & @CRLF)
	ConsoleWrite(UBound($aTest_3_Empty_2D, $UBOUND_ROWS) & @CRLF)
	ConsoleWrite(UBound($aTest_3_Empty_2D, $UBOUND_COLUMNS) & @CRLF)

	ConsoleWrite("> $aTest_4_1D" & @CRLF)
	Local $aTest_4_1D[] = [0, 1, 2]
	ConsoleWrite(UBound($aTest_4_1D, $UBOUND_DIMENSIONS) & @CRLF)
	ConsoleWrite(UBound($aTest_4_1D, $UBOUND_ROWS) & @CRLF)
	ConsoleWrite(UBound($aTest_4_1D, $UBOUND_COLUMNS) & @CRLF)

	ConsoleWrite("> $aTest_5_2D" & @CRLF)
	Local $aTest_5_2D[][] = _ ; [[0, 1, 2], [3, 4, 5]]
			[ _
			[0, 1, 2], _
			[3, 4, 5] _
			]
	ConsoleWrite(UBound($aTest_5_2D, $UBOUND_DIMENSIONS) & @CRLF)
	ConsoleWrite(UBound($aTest_5_2D, $UBOUND_ROWS) & @CRLF)
	ConsoleWrite(UBound($aTest_5_2D, $UBOUND_COLUMNS) & @CRLF)

	ConsoleWrite("> $aTest_6_2D" & @CRLF)
	Local $aTest_6_2D[][] = _ ; [[0, 1, 2], [3, 4, 5], [6, 7, 8], [0, 1, 2]]
			[ _
			[0, 1, 2], _
			[3, 4, 5], _
			[6, 7, 8], _
			[0, 1, 2] _
			]
	ConsoleWrite(UBound($aTest_6_2D, $UBOUND_DIMENSIONS) & @CRLF)
	ConsoleWrite(UBound($aTest_6_2D, $UBOUND_ROWS) & @CRLF)
	ConsoleWrite(UBound($aTest_6_2D, $UBOUND_COLUMNS) & @CRLF)

EndFunc   ;==>_Example
