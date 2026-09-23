#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $Dirs[3] = [@DesktopDir, @WindowsDir, @SystemDir]

ConsoleWrite('Searching for Notepad.exe => ' & _WinAPI_PathFindOnPath('Notepad.exe', $Dirs) & @CR)
ConsoleWrite('Searching for Web => ' & _WinAPI_PathFindOnPath('Web', $Dirs) & @CR)
ConsoleWrite('Searching for My File.txt => ' & _WinAPI_PathFindOnPath('My File.txt', $Dirs) & @CR)
