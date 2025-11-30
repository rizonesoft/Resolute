#Include <APIConstants.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $ID = _WinAPI_GetUserDefaultLCID()

ConsoleWrite('Language => ' & _WinAPI_GetLocaleInfo($ID, $LOCALE_SLANGUAGE) & @CR)
ConsoleWrite('Date format => ' & _WinAPI_GetLocaleInfo($ID, $LOCALE_SSHORTDATE) & @CR)
ConsoleWrite('Time format => ' & _WinAPI_GetLocaleInfo($ID, $LOCALE_STIMEFORMAT) & @CR)
ConsoleWrite('Currency name => ' & _WinAPI_GetLocaleInfo($ID, $LOCALE_SNATIVECURRNAME) & @CR)
ConsoleWrite('Monetary symbol => ' & _WinAPI_GetLocaleInfo($ID, $LOCALE_SCURRENCY) & @CR)
