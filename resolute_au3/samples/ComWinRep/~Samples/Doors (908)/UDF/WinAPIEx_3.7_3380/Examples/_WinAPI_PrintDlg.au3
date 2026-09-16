#Include <APIConstants.au3>
#Include <Memory.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $tPRINTDLG, $tDEVNAMES, $hDevNames, $pDevNames

; Create PRINTDLG structure and set initial values for the number of copies, starting, and ending page
$tPRINTDLG = DllStructCreate($tagPRINTDLG)
DllStructSetData($tPRINTDLG, 'Size', DllStructGetSize($tPRINTDLG))
DllStructSetData($tPRINTDLG, 'Flags', $PD_PAGENUMS)
DllStructSetData($tPRINTDLG, 'FromPage', 2)
DllStructSetData($tPRINTDLG, 'ToPage', 3)
DllStructSetData($tPRINTDLG, 'MinPage', 1)
DllStructSetData($tPRINTDLG, 'MaxPage', 9)
DllStructSetData($tPRINTDLG, 'Copies', 4)

; Create Print dialog box
If Not _WinAPI_PrintDlg($tPRINTDLG) Then
	Exit
EndIf

; Show results
$hDevNames = DllStructGetData($tPRINTDLG, 'hDevNames')
$pDevNames = _MemGlobalLock($hDevNames)
$tDEVNAMES = DllStructCreate($tagDEVNAMES, $pDevNames)
ConsoleWrite('Printer: ' & _WinAPI_GetString($pDevNames + 2 * DllStructGetData($tDEVNAMES, 'DeviceOffset')))
If DllStructGetData($tDEVNAMES, 'Default') Then
	ConsoleWrite(' (Default)' & @CR)
Else
	ConsoleWrite(@CR)
EndIf
ConsoleWrite('First page: ' & DllStructGetData($tPRINTDLG, 'FromPage') & @CR)
ConsoleWrite('Last page: ' & DllStructGetData($tPRINTDLG, 'ToPage') & @CR)
ConsoleWrite('Copies: ' & DllStructGetData($tPRINTDLG, 'Copies') & @CR)

; Free global memory objects that contains a DEVMODE and DEVNAMES structures
_MemGlobalFree(DllStructGetData($tPRINTDLG, 'hDevMode'))
_MemGlobalFree($hDevNames)
