#Include <APIConstants.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $Url = 'http://social.msdn.microsoft.com/search/en-us?query=UrlGetPart'

ConsoleWrite('Scheme: ' & _WinAPI_UrlGetPart($Url, $URL_PART_SCHEME) & @CR)
ConsoleWrite('Host:   ' & _WinAPI_UrlGetPart($Url, $URL_PART_HOSTNAME) & @CR)
ConsoleWrite('Query:  ' & _WinAPI_UrlGetPart($Url, $URL_PART_QUERY) & @CR)
