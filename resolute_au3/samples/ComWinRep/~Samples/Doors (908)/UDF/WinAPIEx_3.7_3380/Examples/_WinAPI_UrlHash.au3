#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $Url = 'http://www.microsoft.com'

ConsoleWrite(_WinAPI_UrlHash($Url) & @CR)
