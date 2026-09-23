#Include <Array.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $Data = _WinAPI_EnumDesktopWindows(_WinAPI_GetThreadDesktop(_WinAPI_GetCurrentThreadID()))

_ArrayDisplay($Data, '_WinAPI_EnumDesktopWindows')
