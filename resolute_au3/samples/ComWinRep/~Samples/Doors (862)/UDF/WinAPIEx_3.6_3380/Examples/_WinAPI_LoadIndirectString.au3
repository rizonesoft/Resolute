#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

ConsoleWrite(_WinAPI_LoadIndirectString('@"' & @AutoItExe & '",-122') & @CR)
