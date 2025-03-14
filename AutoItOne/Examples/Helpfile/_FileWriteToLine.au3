#include <File.au3>
#include <MsgBoxConstants.au3>
#include <WinAPIFiles.au3>

Example()

Func Example()
	; Create a constant variable in Local scope of the filepath that will be read/written to.
	Local Const $sFilePath = _WinAPI_GetTempFileName(@TempDir)

	; Create data to be written to the file.
	Local $sData = "Line 1: This is an example of using _FileWriteToLine()" & @CRLF & _
			"Line 2: This is an example of using _FileWriteToLine()" & @CRLF & _
			"Line 3: This is an example of using _FileWriteToLine()" & @CRLF & _
			"Line 4: This is an example of using _FileWriteToLine()" & @CRLF & _
			"Line 5: This is an example of using _FileWriteToLine()" & @CRLF

	; Create a temporary file to read data from.
	If Not FileWrite($sFilePath, $sData) Then
		MsgBox($MB_SYSTEMMODAL, "", "An error occurred whilst writing the temporary file.")
		Return False
	EndIf

	; Write to line 3 with overwriting set to true.
	_FileWriteToLine($sFilePath, 3, "Line 3: THIS HAS BEEN REPLACED", True)

	; Read the contents of the file using the filepath.
	Local $sFileRead = FileRead($sFilePath)

	; Display the contents of the file.
	MsgBox($MB_SYSTEMMODAL, "", "Contents of the file:" & @CRLF & $sFileRead)

	; Write to line 3 with overwriting set to false.
	_FileWriteToLine($sFilePath, 3, "Line 3: THIS HAS BEEN INSERTED", False)

	; Read the contents of the file using the filepath.
	$sFileRead = FileRead($sFilePath)

	; Display the contents of the file.
	MsgBox($MB_SYSTEMMODAL, "", "Contents of the file:" & @CRLF & $sFileRead)

	; Delete the temporary file.
	FileDelete($sFilePath)
EndFunc   ;==>Example
