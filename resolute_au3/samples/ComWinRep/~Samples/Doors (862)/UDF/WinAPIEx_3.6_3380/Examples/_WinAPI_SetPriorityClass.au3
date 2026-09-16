#Include <APIConstants.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Run(@SystemDir & '\taskmgr.exe')

_WinAPI_SetPriorityClass($HIGH_PRIORITY_CLASS)
MsgBox(64 + 262144, '', 'Look what priority class has the "' & _WinAPI_PathStripPath(FileGetLongName(@AutoItExe)) & '" (' & @AutoItPID & ') process.' & @CR & @CR & 'Should be "High".')

_WinAPI_SetPriorityClass($IDLE_PRIORITY_CLASS)
MsgBox(64 + 262144, '', 'Look what priority class has the "' & _WinAPI_PathStripPath(FileGetLongName(@AutoItExe)) & '" (' & @AutoItPID & ') process.' & @CR & @CR & 'Should be "Low".')
