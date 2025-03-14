#include-once

#include '_Functions.au3' ; By SoftwareSpot.

Func _SciTE_GetSciTEDefaultHome()
	Local Const $sSciTEPath = _GetFullPath('..') ; Get the path up from the application.
	Return FileExists($sSciTEPath & '\SciTE.exe') ? $sSciTEPath : _WinAPI_PathRemoveFileSpec(_WinAPI_GetProcessFileName(ProcessExists('SciTE.exe')))
EndFunc   ;==>_SciTE_GetSciTEDefaultHome
