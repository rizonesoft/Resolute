#include <AutoItConstants.au3>
#include <MsgBoxConstants.au3>

Example()

Func Example()
	; Create a constant variable in Local scope of the directory.
	Local Const $sFilePath = @TempDir & "\DirRemoveFolder"

	; If the directory exists the don't continue.
	If FileExists($sFilePath) Then
		MsgBox($MB_SYSTEMMODAL, "", "An error occurred. The directory already exists.")
		Return False
	EndIf

	; Open the temporary directory.
	ShellExecute(@TempDir)

	; Create the directory.
	DirCreate($sFilePath)

	; Display a message of the directory creation.
	MsgBox($MB_SYSTEMMODAL, "", "The directory has been created.")

	; Remove the directory and all sub-directories.
	DirRemove($sFilePath, $DIR_REMOVE)

	; Display a message of the directory removal.
	MsgBox($MB_SYSTEMMODAL, "", "The sub folder: Folder2 has been deleted.")
EndFunc   ;==>Example
