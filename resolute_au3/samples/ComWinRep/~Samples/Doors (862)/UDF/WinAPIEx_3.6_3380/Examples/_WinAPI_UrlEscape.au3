#Include <APIConstants.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $Url = 'http://social.msdn.microsoft.com/search/en-us?query=UrlEscape UrlUnescape'

ConsoleWrite(_WinAPI_UrlEscape($Url, $URL_ESCAPE_SPACES_ONLY) & @CR)
ConsoleWrite(_WinAPI_UrlUnescape($Url) & @CR)
