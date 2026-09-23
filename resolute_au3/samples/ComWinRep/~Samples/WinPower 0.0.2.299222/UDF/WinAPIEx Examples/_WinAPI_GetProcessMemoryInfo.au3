#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $tPROCESSMEMORYCOUNTERS = _WinAPI_GetProcessMemoryInfo()

ConsoleWrite('Number of page faults: ' & DllStructGetData($tPROCESSMEMORYCOUNTERS, 'PageFaultCount') & ' bytes' & @CR)
ConsoleWrite('Peak working set size: ' & DllStructGetData($tPROCESSMEMORYCOUNTERS, 'PeakWorkingSetSize') & ' bytes' & @CR)
ConsoleWrite('Current working set size: ' & DllStructGetData($tPROCESSMEMORYCOUNTERS, 'WorkingSetSize') & ' bytes' & @CR)
ConsoleWrite('Peak paged pool usage: ' & DllStructGetData($tPROCESSMEMORYCOUNTERS, 'QuotaPeakPagedPoolUsage') & ' bytes' & @CR)
ConsoleWrite('Current paged pool usage: ' & DllStructGetData($tPROCESSMEMORYCOUNTERS, 'QuotaPagedPoolUsage') & ' bytes' & @CR)
ConsoleWrite('Peak nonpaged pool usage: ' & DllStructGetData($tPROCESSMEMORYCOUNTERS, 'QuotaPeakNonPagedPoolUsage') & ' bytes' & @CR)
ConsoleWrite('Current nonpaged pool usage: ' & DllStructGetData($tPROCESSMEMORYCOUNTERS, 'QuotaNonPagedPoolUsage') & ' bytes' & @CR)
ConsoleWrite('Peak space allocated for the pagefile: ' & DllStructGetData($tPROCESSMEMORYCOUNTERS, 'PeakPagefileUsage') & ' bytes' & @CR)
ConsoleWrite('Current space allocated for the pagefile: ' & DllStructGetData($tPROCESSMEMORYCOUNTERS, 'PagefileUsage') & ' bytes' & @CR)
