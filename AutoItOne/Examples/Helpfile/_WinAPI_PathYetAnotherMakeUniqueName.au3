#include <FileConstants.au3>
#include <WinAPIShPath.au3>

DirRemove(@TempDir & '\Temp', $DIR_REMOVE)
DirCreate(@TempDir & '\Temp')
For $i = 1 To 4
	FileClose(FileOpen(_WinAPI_PathYetAnotherMakeUniqueName(@TempDir & '\Temp\My File.txt'), $FO_OVERWRITE))
Next
ShellExecute(@TempDir & '\Temp')
