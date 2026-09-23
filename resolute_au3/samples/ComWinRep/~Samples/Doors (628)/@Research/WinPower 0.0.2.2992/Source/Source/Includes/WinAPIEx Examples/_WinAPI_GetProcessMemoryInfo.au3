#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $tPROCESS_MEMORY_COUNTERS = _WinAPI_GetProcessMemoryInfo()

ConsoleWrite('Number of page faults: ' & DllStructGetData($tPROCESS_MEMORY_COUNTERS, 'PageFaultCount') & ' bytes' & @CR)
ConsoleWrite('Peak working set size: ' & DllStructGetData($tPROCESS_MEMORY_COUNTERS, 'PeakWorkingSetSize') & ' bytes' & @CR)
ConsoleWrite('Current working set size: ' & DllStructGetData($tPROCESS_MEMORY_COUNTERS, 'WorkingSetSize') & ' bytes' & @CR)
ConsoleWrite('Peak paged pool usage: ' & DllStructGetData($tPROCESS_MEMORY_COUNTERS, 'QuotaPeakPagedPoolUsage') & ' bytes' & @CR)
ConsoleWrite('Current paged pool usage: ' & DllStructGetData($tPROCESS_MEMORY_COUNTERS, 'QuotaPagedPoolUsage') & ' bytes' & @CR)
ConsoleWrite('Peak nonpaged pool usage: ' & DllStructGetData($tPROCESS_MEMORY_COUNTERS, 'QuotaPeakNonPagedPoolUsage') & ' bytes' & @CR)
ConsoleWrite('Current nonpaged pool usage: ' & DllStructGetData($tPROCESS_MEMORY_COUNTERS, 'QuotaNonPagedPoolUsage') & ' bytes' & @CR)
ConsoleWrite('Peak space allocated for the pagefile: ' & DllStructGetData($tPROCESS_MEMORY_COUNTERS, 'PeakPagefileUsage') & ' bytes' & @CR)
ConsoleWrite('Current space allocated for the pagefile: ' & DllStructGetData($tPROCESS_MEMORY_COUNTERS, 'PagefileUsage') & ' bytes' & @CR)
