#include <Array.au3>
#include <WinAPIShellEx.au3>

Local $aRecycleBinInfo = _WinAPI_ShellQueryRecycleBin()

_ArrayDisplay($aRecycleBinInfo, '_WinAPI_ShellQueryRecycleBin')
