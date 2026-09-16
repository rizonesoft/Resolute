#Include <APIConstants.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $Url = 'http://msdn.microsoft.com/en-us/library/ee663300%28VS.85%29.aspx'

ConsoleWrite(_WinAPI_UrlCanonicalize($Url, $URL_UNESCAPE) & @CR)
