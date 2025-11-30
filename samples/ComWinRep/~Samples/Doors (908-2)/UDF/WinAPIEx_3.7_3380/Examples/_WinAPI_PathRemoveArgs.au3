#Include <APIConstants.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $Path = _WinAPI_AssocQueryString('.txt', $ASSOCSTR_COMMAND)

ConsoleWrite('Command: ' & $Path & @CR)
ConsoleWrite('Path: ' & _WinAPI_PathRemoveArgs($Path) & @CR)
ConsoleWrite('Arguments: ' & _WinAPI_PathGetArgs($Path) & @CR)
