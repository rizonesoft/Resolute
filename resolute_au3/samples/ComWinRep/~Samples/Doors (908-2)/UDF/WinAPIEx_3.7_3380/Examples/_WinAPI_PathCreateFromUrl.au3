#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $Path = @ScriptFullPath

$Path = _WinAPI_UrlCreateFromPath($Path)
ConsoleWrite($Path & @CR)

$Path = _WinAPI_PathCreateFromUrl($Path)
ConsoleWrite($Path & @CR)
