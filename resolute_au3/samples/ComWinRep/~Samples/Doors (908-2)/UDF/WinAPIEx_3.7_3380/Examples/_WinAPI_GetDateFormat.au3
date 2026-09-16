#Include <APIConstants.au3>
#Include <WinAPIEx.au3>

ConsoleWrite(_WinAPI_GetDateFormat() & @CR)
ConsoleWrite(_WinAPI_GetDateFormat(0, 0, $DATE_LONGDATE) & @CR)
ConsoleWrite(_WinAPI_GetDateFormat(0, 0, 0, 'dddd dd, yyyy') & @CR)
