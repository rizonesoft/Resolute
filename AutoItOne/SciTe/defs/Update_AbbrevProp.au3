#include <Array.au3>
;
$Abbrev_Keyword_tot = ""
$Abbrev_Keyword = "au3.keywords.abbrev="
$Abbrev = Fileread("D:\Development\AutoIt3\installer_SciTe4AutoIt3\wscite\properties\au3abbrev.properties")
$A_Keywords = StringRegExp($Abbrev,"(.*?)=",3)
;
_ArraySort($A_Keywords)
For $i = 0 To UBound($A_Keywords) - 1
	If StringStripWS($A_Keywords[$i],3) = "" or StringLeft($A_Keywords[$i],1) = "#" or StringInStr($A_Keywords[$i]," ") Then
		; not a abbrev
	Else
;~ 		ConsoleWrite('@@ Debug(' & @ScriptLineNumber & ') : $A_Keywords[$i] = ' & $A_Keywords[$i] & @crlf & '>Error code: ' & @error & @crlf) ;### Debug Console
		If StringLen($Abbrev_Keyword) > 110 Then
			$Abbrev_Keyword_tot &= $Abbrev_Keyword & " \" & @CRLF
			$Abbrev_Keyword = "      " & StringLower($A_Keywords[$i])
		Else
			$Abbrev_Keyword &= " " & StringLower($A_Keywords[$i])
		EndIf
	EndIf
Next
$Abbrev_Keyword_tot &= $Abbrev_Keyword & @CRLF
ConsoleWrite('@@ Debug(' & @ScriptLineNumber & ') : $Abbrev_Keyword_tot = ' & @crlf & $Abbrev_Keyword_tot & '>Error code: ' & @error & @crlf) ;### Debug Console
FileRecycle("D:\Development\AutoIt3\installer_SciTe4AutoIt3\wscite\properties\au3.keywords.abbreviations.properties")
FileWrite("D:\Development\AutoIt3\installer_SciTe4AutoIt3\wscite\properties\au3.keywords.abbreviations.properties",$Abbrev_Keyword_tot)
