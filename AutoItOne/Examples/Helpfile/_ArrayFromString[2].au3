#include <Array.au3>
#include <Debug.au3>
#include <MsgBoxConstants.au3>
#include <SQLite.au3>
#include <SQLite.dll.au3>

Example()

Func Example()
	Local $aResult, $iRows, $iColumns, $iRval, $sText, $aArrayFromText

	_SQLite_Startup()
	If @error Then
		MsgBox($MB_SYSTEMMODAL, "SQLite Error", "SQLite.dll Can't be Loaded!")
		Exit -1
	EndIf
	ConsoleWrite("_SQLite_LibVersion=" & _SQLite_LibVersion() & @CRLF)

	_SQLite_Open() ; Open a :memory: database
	If @error Then
		MsgBox($MB_SYSTEMMODAL, "SQLite Error", "Can't Load Database!")
		Exit -1
	EndIf

	; Example Table
	; Name        | Age
	; -----------------------
	; Alice       | 43
	; Bob         | 28
	; Cindy       | 21

	If Not _SQLite_Exec(-1, "CREATE TEMP TABLE persons (Name, Age);" & _
			"INSERT INTO persons VALUES ('Alice','43');" & _
			"INSERT INTO persons VALUES ('Bob','28');" & _
			"INSERT INTO persons VALUES ('Cindy','21');") = $SQLITE_OK Then _
			MsgBox($MB_SYSTEMMODAL, "SQLite Error", _SQLite_ErrMsg())

	; Query
	$iRval = _SQLite_GetTable2D(-1, "SELECT * FROM persons;", $aResult, $iRows, $iColumns)
	If $iRval = $SQLITE_OK Then

		ConsoleWrite('--- --- --- ---' & @CRLF)
		_SQLite_Display2DResult($aResult)
		ConsoleWrite('--- --- --- ---' & @CRLF)

		; demo using _SQLite_Display2DResult()
		$sText = _SQLite_Display2DResult($aResult, Default, True, @TAB)
		ConsoleWrite($sText & @CRLF) ; ..say, you save this in a log file ...
		$aArrayFromText = _ArrayFromString($sText, @TAB) ; ... then rebuild the array
		_DebugArrayDisplay($aArrayFromText, "from _SQLite_Display2DResult()")
		ConsoleWrite('--- --- --- ---' & @CRLF)

		; demo using _ArrayToString()
		$sText = _ArrayToString($aResult)
		ConsoleWrite($sText & @CRLF)
		$aArrayFromText = _ArrayFromString($sText)
		_DebugArrayDisplay($aArrayFromText, "from _ArrayToString()")
		ConsoleWrite('--- --- --- ---' & @CRLF)

	Else
		MsgBox($MB_SYSTEMMODAL, "SQLite Error: " & $iRval, _SQLite_ErrMsg())
	EndIf

	_SQLite_Close()
	_SQLite_Shutdown()
EndFunc   ;==>Example
