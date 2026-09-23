#Include <WinAPIEx.au3>
#Include <File.au3>

Opt('MustDeclareVars', 1)

Global $hFile, $sTemp

; Create temporary file
$sTemp = _TempFile()
$hFile = FileOpen($sTemp, 2)
FileClose($hFile)

; Delete to Recycle Bin
ConsoleWrite(StringRegExpReplace($sTemp, '^.*\\', '') & @CR)
If FileExists($sTemp) Then
	_WinAPI_ShellFileOperation($sTemp, '', $FO_DELETE, BitOR($FOF_ALLOWUNDO, $FOF_NO_UI))
EndIf
