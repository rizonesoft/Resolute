#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $Url1 = 'http://xyz/abc/'
Global $Url2 = 'http://xyz/abc'

ConsoleWrite('URLs comparison result: ' & _WinAPI_UrlCompare($Url1, $Url2) & @CR)
