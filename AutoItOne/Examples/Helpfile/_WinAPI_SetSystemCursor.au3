#include <WinAPIRes.au3>

Local $hPrev = _WinAPI_CopyCursor(_WinAPI_LoadCursor(0, $OCR_NORMAL))

_WinAPI_SetSystemCursor(_WinAPI_LoadCursorFromFile(@ScriptDir & '\Extras\Lens.cur'), $OCR_NORMAL)
Sleep(5000)
_WinAPI_SetSystemCursor($hPrev, $OCR_NORMAL)
