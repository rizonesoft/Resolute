#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $Url1 = 'http://xyz/abc/'
Global $Url2 = 'http://xyz/abc'

ConsoleWrite(_WinAPI_UrlCombine($Url1, 'bar') & @CR)
ConsoleWrite(_WinAPI_UrlCombine($Url2, 'bar') & @CR)
