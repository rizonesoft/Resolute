#Include <Constants.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $hCursor, $hPrev = _WinAPI_CopyCursor(_WinAPI_LoadCursor(0, 32512))

$hCursor = _WinAPI_LoadCursorFromFile(@ScriptDir & '\Extras\Lens.cur')
_WinAPI_SetSystemCursor($hCursor, 32512)
Sleep(5000)
_WinAPI_SetSystemCursor($hPrev, 32512)
_WinAPI_DestroyCursor($hCursor)
