#Include <APIConstants.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

_WinAPI_SetLocaleInfo($LOCALE_USER_DEFAULT, $LOCALE_SLONGDATE, 'dddd, MMMM dd, yyyy')
_WinAPI_SetLocaleInfo($LOCALE_USER_DEFAULT, $LOCALE_SSHORTDATE, 'dd-MMM-yy')
