#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $Val[5] = [532, 1340, 23506, 2400016, 2400000000]

For $i = 0 to 4
	ConsoleWrite(StringFormat('%10s ' & _WinAPI_StrFormatByteSize($Val[$i]), $Val[$i]) & @CR)
Next
