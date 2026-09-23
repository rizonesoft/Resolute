#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $Url = 'www.microsoft.com'

ConsoleWrite(_WinAPI_UrlApplyScheme($Url) & @CR)
