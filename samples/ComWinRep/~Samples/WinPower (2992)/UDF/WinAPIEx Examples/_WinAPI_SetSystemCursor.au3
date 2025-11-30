#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $hCursor, $hPrev = _WinAPI_DuplicateCursor(_WinAPI_LoadCursor(0, 32512)) ; IDC_ARROW

$hCursor = _WinAPI_DuplicateCursor(_WinAPI_LoadCursor(_WinAPI_GetModuleHandle(@SystemDir & '\shell32.dll'), 1004))
_WinAPI_SetSystemCursor($hCursor, 32512) ; OCR_NORMAL
Sleep(5000)
_WinAPI_SetSystemCursor($hPrev, 32512)
