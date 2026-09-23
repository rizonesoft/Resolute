#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $Val[3] = [23506, 2400016, 2400000000]

For $i = 0 to 2
	ConsoleWrite(StringFormat('%10s %12s', $Val[$i], _WinAPI_StrFormatKBSize($Val[$i])) & @CR)
Next
