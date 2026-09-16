#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $Duration = (90 * 60 + 14) * 1000 * 1000 * 10

ConsoleWrite(_WinAPI_GetDurationFormat(0, $Duration, 'hh:mm:ss') & @CR)
ConsoleWrite(_WinAPI_GetDurationFormat(0, $Duration, 'mm:ss') & @CR)
ConsoleWrite(_WinAPI_GetDurationFormat(0, $Duration, 'ss') & @CR)
