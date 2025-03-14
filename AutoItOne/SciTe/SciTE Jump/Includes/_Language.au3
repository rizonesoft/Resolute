#include-once
#include <Constants.au3>
#include <WinAPI.au3>

Global Const $__sLanguagePathRead = @ScriptDir
Global $__sLanguagePathWrite = @ScriptDir

Func _GetLanguage($sData, $sDefault, $fEnvironmentVariables = True)
	Local $sCurrentLanguage = _GetLanguageCurrent()
	$sData = IniRead($__sLanguagePathRead & '\Languages\' & $sCurrentLanguage & '.lng', 'Language', $sData, $sDefault)
	If $fEnvironmentVariables Then
		$sData = _WinAPI_ExpandEnvironmentStrings($sData)
		If @error Then
			$sData = _WinAPI_ExpandEnvironmentStrings($sDefault)
		EndIf
	EndIf
	$sData = StringReplace($sData, '@NL', ' @CRLF ')
	$sData = StringReplace($sData, '@TAB', ' @TAB ')
	$sData = StringStripWS($sData, $STR_STRIPSPACES)
	$sData = StringReplace($sData, '@CRLF ', @CRLF)
	$sData = StringReplace($sData, '@TAB ', @TAB)
	Return $sData
EndFunc   ;==>_GetLanguage

Func _GetLanguageAuthor($sKey, $sData)
	_SetLanguageVariables()
	Return _GetLanguage($sKey, $sData)
EndFunc   ;==>_GetLanguageAuthor

Func _GetLanguageCode($sLanguage = Default)
	Local $sCode = 'unknown'
	If $sLanguage = Default Then
		$sLanguage = _GetLanguageCurrent()
	EndIf
	If $sLanguage == 'English' Then
		$sCode = 'gb'
	EndIf
	Return StringLower(IniRead($__sLanguagePathRead & '\Languages\' & $sLanguage & '.lng', 'Country', 'CODE', $sCode))
EndFunc   ;==>_GetLanguageCode

Func _GetLanguageCurrent()
	Local $sData = IniRead($__sLanguagePathWrite & '\Settings.ini', 'General', 'Language', -1)
	If $sData = -1 Then
		$sData = _SetLanguageCurrent(_GetLanguageOS())
	EndIf
	If FileExists($__sLanguagePathRead & '\Languages\' & $sData & '.lng') = 0 Then
		$sData = 'English'
	EndIf
	Return $sData
EndFunc   ;==>_GetLanguageCurrent

Func _GetLanguageList($fString = Default)
	Local $aReturn = _FileSearch($__sLanguagePathRead & '\Languages\', '*.lng'), $sReturn = ''
	If @error Then
		Local $aDefault[2] = [1, $__sLanguagePathRead & '\Languages\' & 'English.lng']
		$aReturn = $aDefault
	EndIf
	For $i = 1 To $aReturn[0]
		If $fString Then
			$sReturn = $aReturn[$i] & '|'
		Else
			$aReturn[$i] = StringRegExpReplace($aReturn[$i], '^.*\\|\..*$', '')
		EndIf
	Next
	If $fString Then
		Return $sReturn
	EndIf
	Return $aReturn
EndFunc   ;==>_GetLanguageList

Func _GetLanguageOS()
	Local $aString[22] = [21, '0409 0809 0c09 1009 1409 1809 1c09 2009 2409 2809 2c09 3009 3409', '0404 0804 0c04 1004 0406', '0406', '0413 0813', '0425', _
			'040b', '040c 080c 0c0c 100c 140c 180c', '0407 0807 0c07 1007 1407', '408', '040e', _
			'0410 0810', '0411', '0414 0814', '0415', '0816', '0416', _
			'0418', '0419', '081a 0c1a', '040a 080a 0c0a 100a 140a 180a 1c0a 200a 240a 280a 2c0a 300a 340a 380a 3c0a 400a 440a 480a 4c0a 500a', '041d 081d']

	Local $aLanguage[22] = [21, 'English', 'Chinese', 'Danish', 'Dutch', 'Estonian', 'Finnish', 'French', 'German', 'Greek', 'Hungarian', _
			'Italian', 'Japanese', 'Norwegian', 'Polish', 'Portuguese', 'Brazilian Portuguese', 'Romanian', 'Russian', 'Serbian', 'Spanish', 'Swedish']
	For $i = 1 To $aString[0]
		If StringInStr($aString[$i], @OSLang) Then
			Return $aLanguage[$i]
		EndIf
	Next
	Return $aLanguage[1]
EndFunc   ;==>_GetLanguageOS

Func _SetLanguageCurrent($sLanguage)
	IniWrite($__sLanguagePathWrite & '\Settings.ini', 'General', 'Language', $sLanguage)
	Return $sLanguage
EndFunc   ;==>_SetLanguageCurrent

Func _SetLanguageVariables()
	Local $sLanguage = _GetLanguageCurrent()
	Local $aArray[5][3] = [[4, 3], _
			['LANGUAGE', $sLanguage, $sLanguage], _
			['LANGUAGEAUTHOR', 'AUTHOR', 'SoftwareSpot'], _
			['LANGUAGEUPDATED', 'UPDATED', StringRegExpReplace(FileGetTime(@ScriptFullPath, 1, 1), '^(\d{4})(\d{2})(\d{2})(\d{2})(\d{2})(\d{2})$', '\3/\2/\1')], _
			['LANGUAGEVERSION', 'VERSION', FileGetVersion(@ScriptFullPath)]]

	Local $sFileName = $__sLanguagePathRead & '\Languages\' & $sLanguage & '.lng'
	For $i = 1 To $aArray[0][0]
		EnvSet($aArray[$i][0], IniRead($sFileName, 'Author', $aArray[$i][1], $aArray[$i][2]))
	Next
	Return $aArray
EndFunc   ;==>_SetLanguageVariables

Func _ProgramName()
	Return _WinAPI_ExpandEnvironmentStrings('%PROGRAMNAME%')
EndFunc   ;==>_ProgramName

Func _SetCustomVariable($iIndex = Default, $sString = Default)
	Local $aArray[3][2] = [[2, 2], _
			['TOTALNUMBER', 0], _
			['CREATIONDATE', 0]]
	If $iIndex = Default Then
		For $i = 1 To $aArray[0][0]
			EnvSet($aArray[$i][0], $aArray[$i][1])
		Next
		Return $aArray
	EndIf
	If $sString = Default Then
		$sString = -1
	EndIf
	Return EnvSet($aArray[$iIndex][0], $sString)
EndFunc   ;==>_SetCustomVariable

Func _SetLanguagePath($sFilePath)
	$__sLanguagePathWrite = $sFilePath
EndFunc   ;==>_SetLanguagePath

Func _SetVariables()
	Local $iStartYear = 2011
	If $iStartYear <> Int(@YEAR) Then
		$iStartYear = $iStartYear & '-' & @YEAR
	EndIf
	Local $aArray[6][2] = [[5, 2], _
			['COPYRIGHT', 'SoftwareSpot ' & Chr(169) & ' ' & $iStartYear], _
			['LICENSE', 'GPLv3'], _
			['PROGRAMNAME', 'SciTE Jump'], _
			['VERSION', FileGetVersion(@ScriptFullPath)], _
			['WEBSITE', 'http://softwarespot.wordpress.com']]

	For $i = 1 To $aArray[0][0]
		EnvSet($aArray[$i][0], $aArray[$i][1])
	Next
	Return $aArray
EndFunc   ;==>_SetVariables
