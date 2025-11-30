#Include <APIConstants.au3>
#Include <Memory.au3>
#Include <WinAPIEx.au3>

Opt('WinTitleMatchMode', 3)

Global $tPRINTDLGEX, $tPRINTPAGERANGE, $tDEVNAMES, $hDevNames, $pDevNames
Global $Page[2]

; Create PRINTDLGEX structure and set initial values for the number of copies, starting, and ending page
$tPRINTPAGERANGE = DllStructCreate($tagPRINTPAGERANGE)
DllStructSetData($tPRINTPAGERANGE, 'FromPage', 2)
DllStructSetData($tPRINTPAGERANGE, 'ToPage', 3)
$tPRINTDLGEX = DllStructCreate($tagPRINTDLGEX)
DllStructSetData($tPRINTDLGEX, 'Size', DllStructGetSize($tPRINTDLGEX))
DllStructSetData($tPRINTDLGEX, 'hOwner', WinGetHandle(AutoItWinGetTitle()))
DllStructSetData($tPRINTDLGEX, 'Flags', BitOR($PD_PAGENUMS, $PD_NOCURRENTPAGE, $PD_NOSELECTION))
DllStructSetData($tPRINTDLGEX, 'NumPageRanges', 1)
DllStructSetData($tPRINTDLGEX, 'MaxPageRanges', 1)
DllStructSetData($tPRINTDLGEX, 'PageRanges', DllStructGetPtr($tPRINTPAGERANGE))
DllStructSetData($tPRINTDLGEX, 'MinPage', 1)
DllStructSetData($tPRINTDLGEX, 'MaxPage', 9)
DllStructSetData($tPRINTDLGEX, 'Copies', 4)
DllStructSetData($tPRINTDLGEX, 'StartPage', -1)

; Display Print property sheet
If Not _WinAPI_PrintDlgEx($tPRINTDLGEX) Then
	Exit
EndIf

Switch @extended
	Case $PD_RESULT_PRINT
		; The user clicked the "Print" button
	Case $PD_RESULT_APPLY
		; The user clicked the "Apply" button and later clicked the "Cancel" button
	Case $PD_RESULT_CANCEL
		Exit
EndSwitch

; Show results
$hDevNames = DllStructGetData($tPRINTDLGEX, 'hDevNames')
$pDevNames = _MemGlobalLock($hDevNames)
$tDEVNAMES = DllStructCreate($tagDEVNAMES, $pDevNames)
ConsoleWrite('Printer: ' & _WinAPI_GetString($pDevNames + 2 * DllStructGetData($tDEVNAMES, 'DeviceOffset')))
If DllStructGetData($tDEVNAMES, 'Default') Then
	ConsoleWrite(' (Default)' & @CR)
Else
	ConsoleWrite(@CR)
EndIf
If BitAND(DllStructGetData($tPRINTDLGEX, 'Flags'), $PD_PAGENUMS) Then
	$Page[0] = DllStructGetData($tPRINTPAGERANGE, 'FromPage')
	$Page[1] = DllStructGetData($tPRINTPAGERANGE, 'ToPage')
Else
	$Page[0] = DllStructGetData($tPRINTDLGEX, 'MinPage')
	$Page[1] = DllStructGetData($tPRINTDLGEX, 'MaxPage')
EndIf
ConsoleWrite('First page: ' & $Page[0] & @CR)
ConsoleWrite('Last page: ' & $Page[1] & @CR)
ConsoleWrite('Copies: ' & DllStructGetData($tPRINTDLGEX, 'Copies') & @CR)

; Free global memory objects that contains a DEVMODE and DEVNAMES structures
_MemGlobalFree(DllStructGetData($tPRINTDLGEX, 'hDevMode'))
_MemGlobalFree($hDevNames)
