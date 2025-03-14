#include <MemoryConstants.au3>
#include <MsgBoxConstants.au3>

Local $aMemStats = MemGetStats()
MsgBox($MB_OK, "Feature Request", "Total load currently on RAM: " & @TAB & $aMemStats[$MEM_LOAD] & '%' &@CRLF & _
	"Total physical RAM: " & @TAB & @TAB & $aMemStats[$MEM_TOTALPHYSRAM] & ' Kb' & @TAB & '(' & Round($aMemStats[$MEM_TOTALPHYSRAM]/1024/1024, 2) & ' Gb)' & @CRLF & _
	"Available physical RAM: " & @TAB & $aMemStats[$MEM_AVAILPHYSRAM] & ' Kb' & @TAB & '(' & Round($aMemStats[$MEM_AVAILPHYSRAM]/1024/1024, 2) & ' Gb)' & @CRLF & _
	"Total Page Size: " & @TAB & @TAB& $aMemStats[$MEM_TOTALPAGEFILE] & ' Kb' & @TAB & '(' & Round($aMemStats[$MEM_TOTALPAGEFILE]/1024/1024, 2) & ' Gb)' & @CRLF & _
	"Available Page Size: " & @TAB & @TAB& $aMemStats[$MEM_AVAILPAGEFILE] & ' Kb' & @TAB & '(' & Round($aMemStats[$MEM_AVAILPAGEFILE]/1024/1024, 2) & ' Gb)' & @CRLF & _
	"Total virtual Size: " & @TAB & @TAB & $aMemStats[$MEM_TOTALVIRTUAL] & ' Kb' & @TAB & '(' & Round($aMemStats[$MEM_TOTALVIRTUAL]/1024/1024, 2) & ' Gb)' & @CRLF & _
	"Available virtual RAM: " & @TAB & $aMemStats[$MEM_AVAILVIRTUAL] & ' Kb' & @TAB & '(' & Round($aMemStats[$MEM_AVAILVIRTUAL]/1024/1024, 2) & ' Gb)')
