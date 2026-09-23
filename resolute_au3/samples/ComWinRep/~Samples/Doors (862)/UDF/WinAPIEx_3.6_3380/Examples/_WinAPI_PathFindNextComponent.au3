#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $Str, $Path = @ScriptFullPath

While $Path
	ConsoleWrite($Path & @CR)
	$Path = _WinAPI_PathFindNextComponent($Path)
WEnd
