#Include <APIConstants.au3>
#Include <WinAPIEx.au3>

ConsoleWrite(_WinAPI_GetTimeFormat() & @CR)
ConsoleWrite(_WinAPI_GetTimeFormat(0, 0, BitOR($TIME_FORCE24HOURFORMAT, $TIME_NOSECONDS)) & @CR)
