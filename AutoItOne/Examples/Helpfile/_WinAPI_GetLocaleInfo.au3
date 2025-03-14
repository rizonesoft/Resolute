#include <APILocaleConstants.au3>
#include <WinAPILocale.au3>

Local $iID = _WinAPI_GetUserDefaultLCID()

ConsoleWrite('Language => ' & _WinAPI_GetLocaleInfo($iID, $LOCALE_SLANGUAGE) & @CRLF)
ConsoleWrite('Date format => ' & _WinAPI_GetLocaleInfo($iID, $LOCALE_SSHORTDATE) & @CRLF)
ConsoleWrite('Date format => ' & _WinAPI_GetLocaleInfo($iID, $LOCALE_SLONGDATE) & @CRLF)
ConsoleWrite('Time format => ' & _WinAPI_GetLocaleInfo($iID, $LOCALE_STIMEFORMAT) & @CRLF)
ConsoleWrite('Currency name => ' & _WinAPI_GetLocaleInfo($iID, $LOCALE_SNATIVECURRNAME) & @CRLF)
ConsoleWrite('Monetary symbol => ' & _WinAPI_GetLocaleInfo($iID, $LOCALE_SCURRENCY) & @CRLF)

Local $sLongDate = _WinAPI_GetLocaleInfo($LOCALE_USER_DEFAULT, $LOCALE_SLONGDATE)
Local $sShortDate = _WinAPI_GetLocaleInfo($LOCALE_USER_DEFAULT, $LOCALE_SSHORTDATE)

ConsoleWrite(@CRLF & "--- SetLocaleInfo ---" & @CRLF)
_WinAPI_SetLocaleInfo($LOCALE_USER_DEFAULT, $LOCALE_SLONGDATE, 'dddd, MMMM dd, yyyy')
ConsoleWrite('Date format => ' & _WinAPI_GetLocaleInfo($LOCALE_USER_DEFAULT, $LOCALE_SLONGDATE) & @CRLF)
_WinAPI_SetLocaleInfo($LOCALE_USER_DEFAULT, $LOCALE_SSHORTDATE, 'dd-MMM-yy')
ConsoleWrite('Date format => ' & _WinAPI_GetLocaleInfo($LOCALE_USER_DEFAULT, $LOCALE_SSHORTDATE) & @CRLF)

_WinAPI_SetLocaleInfo($LOCALE_USER_DEFAULT, $LOCALE_SLONGDATE, $sLongDate)
_WinAPI_SetLocaleInfo($LOCALE_USER_DEFAULT, $LOCALE_SSHORTDATE, $sShortDate)
