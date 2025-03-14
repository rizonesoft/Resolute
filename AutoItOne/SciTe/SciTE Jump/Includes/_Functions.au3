#include-once
#include <APIConstants.au3>
#include <GUIConstantsEx.au3>
#include <WinAPIEx.au3>

#include '_SciTE.au3' ; By SoftwareSpot.
#include '_SciTE_GetSciTEDefaultHome.au3' ; By SoftwareSpot.
#include '_Language.au3' ; By SoftwareSpot.

Global Const $ASCII_BEL = Chr(7)
Global $___hAutoItConstants = 0, _
		$__vFunctionLines = 0

Func _ArrayUniqueFast(ByRef Const $aArray, ByRef $sOutput, $iStart, $iEnd, $fIsCaseSensitive = False) ; By Yashied. Taken from: http://www.autoitscript.com/forum/topic/122192-arraysort-and-eliminate-duplicates/#entry849187
	Local Const $sSep = ChrW(160)
	Local $hUnique = 0
	_AssociativeArray_Startup($hUnique, $fIsCaseSensitive)
	For $i = $iStart To $iEnd
		If Not $hUnique.Exists($aArray[$i]) Then
			$hUnique.Item($aArray[$i])
			$sOutput &= $aArray[$i] & $sSep
		EndIf
	Next
	; $hUnique.RemoveAll()
	$hUnique = 0
	$sOutput = StringTrimRight($sOutput, StringLen($sSep))
EndFunc   ;==>_ArrayUniqueFast

Func _AssociativeArray_Startup(ByRef $aArray, $fIsCaseSensitive = False) ; Idea from MilesAhead.
	Local $fReturn = False
	$aArray = ObjCreate('Scripting.Dictionary')
	If IsObj($aArray) Then
		$aArray.CompareMode = Int(Not $fIsCaseSensitive)
		$fReturn = True
	EndIf
	Return $fReturn
EndFunc   ;==>_AssociativeArray_Startup

Func _AutoIt_AddCmdLine()
	Local Const $aVariables[3] = [2, '$CmdLine', '$CmdLineRaw']
	_AutoIt_AddConstantsGlobal($aVariables, '__GLOBALVARS__')
EndFunc   ;==>_AutoIt_AddCmdLine

Func _AutoIt_AddConstantsGlobal(ByRef Const $aArray, $sUniqueString)
	For $i = 1 To $aArray[0]
		If Not $___hAutoItConstants.Exists($sUniqueString & $aArray[$i]) Then
			$___hAutoItConstants.Item($sUniqueString & $aArray[$i])
		EndIf
	Next
EndFunc   ;==>_AutoIt_AddConstantsGlobal

Func _AutoIt_IsDeclared($sVariable, $sUniqueString)
	Return $___hAutoItConstants.Exists($sUniqueString & $sVariable)
EndFunc   ;==>_AutoIt_IsDeclared

Func _AutoIt_Shutdown()
	$___hAutoItConstants.RemoveAll()
	$___hAutoItConstants = 0
	Return True
EndFunc   ;==>_AutoIt_Shutdown

Func _AutoIt_Startup()
	Return _AssociativeArray_Startup($___hAutoItConstants, False)
EndFunc   ;==>_AutoIt_Startup

Func _ConvertCRToCRLF(ByRef $sData)
	$sData = StringRegExpReplace(@LF & $sData, '\r(?!\n)', @CRLF) ; By DXRW4E. http://www.autoitscript.com/forum/topic/157255-regular-expression-challenge-for-stripping-single-comments/
EndFunc   ;==>_ConvertCRToCRLF

; Additional code and testing by mlipok - 17/11/2013.
Func _DockToWindow($hWnd_1, $hWnd_2, ByRef $iWindowPos_1, ByRef $iWindowPos_2, $fRightSide = True, $hActivate = 0)
	Local Const $aSciTEJump_Window = WinGetPos($hWnd_2)
	; Local Const $iOffSet = 10
	Local $aSciTE_Window = WinGetPos($hWnd_1)

	If UBound($aSciTE_Window) = 0 Or UBound($aSciTEJump_Window) = 0 Then
		Return SetError(1, 0, False)
	EndIf
	Local $iPos_1 = 0, $iPos_2 = 0
	For $i = 0 To 3
		$iPos_1 += $aSciTE_Window[$i] * ($i + 1)
		$iPos_2 += $aSciTEJump_Window[$i] * ($i + 1)
	Next

	If $iWindowPos_1 = $iPos_1 And $iWindowPos_2 = $iPos_2 Then
		Return SetError(2, 0, True)
	EndIf
	$iWindowPos_1 = $iPos_1
	$iWindowPos_2 = $iPos_2

	Local Enum $eDockLeft, $eDockTop, $eDockWidth, $eDockHeight
	Local Const $aDesktop_Window = _GetDesktopArea()

	Local Const $fIsMaximized = _IsMaximized($hWnd_1)
	If $fRightSide = Default Then
		$fRightSide = $aSciTEJump_Window[$eDockLeft] + $aSciTEJump_Window[$eDockWidth] > $aDesktop_Window[$eDockLeft] + $aSciTE_Window[$eDockLeft] + ($aSciTE_Window[$eDockWidth] / 2)
	EndIf

	#Region Moving "SciTE" when docking "SciTE Jump"
	If $fRightSide Then
		If $aSciTE_Window[$eDockLeft] + $aSciTE_Window[$eDockWidth] + $aSciTEJump_Window[$eDockWidth] > $aDesktop_Window[$eDockWidth] Then
			If $fIsMaximized Then
				$aSciTE_Window[$eDockLeft] = $aDesktop_Window[$eDockLeft]
				$aSciTE_Window[$eDockTop] = $aDesktop_Window[$eDockTop]
				$aSciTE_Window[$eDockWidth] = ($aDesktop_Window[$eDockWidth] - $aDesktop_Window[$eDockLeft]) - ($aSciTEJump_Window[$eDockWidth] - $aDesktop_Window[$eDockLeft])
				$aSciTE_Window[$eDockHeight] = ($aDesktop_Window[$eDockHeight] + $aDesktop_Window[$eDockTop]) - $aDesktop_Window[$eDockTop]
			Else
				$aSciTE_Window[$eDockLeft] = $aDesktop_Window[$eDockLeft] + $aDesktop_Window[$eDockWidth] - $aSciTE_Window[$eDockWidth] - $aSciTEJump_Window[$eDockWidth]
				Do
					$aSciTE_Window[$eDockWidth] -= 2
				Until $aSciTE_Window[$eDockLeft] + $aSciTE_Window[$eDockWidth] + $aSciTEJump_Window[$eDockWidth] < $aDesktop_Window[$eDockWidth] + $aDesktop_Window[$eDockLeft]
				; $aSciTE_Window[$eDockHeight] -= $iOffSet
				; $aSciTE_Window[$eDockWidth] -= $iOffSet
			EndIf

			; Moving SciTE and re-sizing accordingly.
			WinMove($hWnd_1, '', $aSciTE_Window[$eDockLeft], $aSciTE_Window[$eDockTop], $aSciTE_Window[$eDockWidth], $aSciTE_Window[$eDockHeight])
		EndIf
	Else
		If $aSciTE_Window[$eDockLeft] <= $aDesktop_Window[$eDockLeft] + $aSciTEJump_Window[$eDockWidth] Then
			If $fIsMaximized Then
				$aSciTE_Window[$eDockLeft] = $aDesktop_Window[$eDockLeft] + $aSciTEJump_Window[$eDockWidth]
				$aSciTE_Window[$eDockTop] = $aDesktop_Window[$eDockTop]
				$aSciTE_Window[$eDockWidth] = ($aDesktop_Window[$eDockWidth] - $aDesktop_Window[$eDockLeft]) - ($aSciTEJump_Window[$eDockWidth] - $aDesktop_Window[$eDockLeft])
				$aSciTE_Window[$eDockHeight] = ($aDesktop_Window[$eDockHeight] + $aDesktop_Window[$eDockTop]) - $aDesktop_Window[$eDockTop]
			Else
				If $aSciTE_Window[$eDockWidth] + $aSciTEJump_Window[$eDockWidth] > $aDesktop_Window[$eDockWidth] Then
					$aSciTE_Window[$eDockWidth] = $aDesktop_Window[$eDockWidth] - $aSciTEJump_Window[$eDockWidth]
				EndIf
				$aSciTE_Window[$eDockLeft] = $aDesktop_Window[$eDockLeft] + $aSciTEJump_Window[$eDockWidth]

				; $aSciTE_Window[$eDockHeight] -= $iOffSet
				; $aSciTE_Window[$eDockWidth] -= $iOffSet
			EndIf
		Else
			If $aSciTE_Window[$eDockLeft] + $aSciTE_Window[$eDockWidth] > $aDesktop_Window[$eDockLeft] + $aDesktop_Window[$eDockWidth] Then
				$aSciTE_Window[$eDockWidth] = $aDesktop_Window[$eDockWidth] - $aSciTE_Window[$eDockLeft] + $aDesktop_Window[$eDockLeft]
			EndIf
		EndIf

		; Moving SciTE and re-sizing accordingly.
		WinMove($hWnd_1, '', $aSciTE_Window[$eDockLeft], $aSciTE_Window[$eDockTop], $aSciTE_Window[$eDockWidth], $aSciTE_Window[$eDockHeight])
	EndIf
	#EndRegion Moving "SciTE" when docking "SciTE Jump"

	#Region Moving "SciTE Jump" when docking "SciTE Jump"
	If $fRightSide Then
		$aSciTE_Window[$eDockLeft] += $aSciTE_Window[$eDockWidth]
	Else
		$aSciTE_Window[$eDockLeft] -= $aSciTEJump_Window[$eDockWidth]
	EndIf
	; Moving SciTE Jump and re-sizing the height.
	WinMove($hWnd_2, '', $aSciTE_Window[$eDockLeft], $aSciTE_Window[$eDockTop], Default, $aSciTE_Window[$eDockHeight])
	#EndRegion Moving "SciTE Jump" when docking "SciTE Jump"

	If IsHWnd($hActivate) Then
		WinActivate($hActivate)
	EndIf
	Return True
EndFunc   ;==>_DockToWindow

Func _DockToWindowEx($hWnd_1, $hWnd_2, ByRef $iWindowPos_1, ByRef $iWindowPos_2, $fRightSide = True, $hActivate = 0)
	Local Const $aSciTEJump_Window = WinGetPos($hWnd_2)
	Local $aSciTE_Window = WinGetPos($hWnd_1)

	If UBound($aSciTE_Window) = 0 Or UBound($aSciTEJump_Window) = 0 Then
		Return SetError(1, 0, False)
	EndIf
	Local $iPos_1 = 0, $iPos_2 = 0
	For $i = 0 To 3
		$iPos_1 += $aSciTE_Window[$i] * $i
		$iPos_2 += $aSciTEJump_Window[$i] * $i
	Next

	If $iWindowPos_1 = $iPos_1 And $iWindowPos_2 = $iPos_2 Then
		Return SetError(2, 0, True)
	EndIf
	$iWindowPos_1 = $iPos_1
	$iWindowPos_2 = $iPos_2

	Local Enum $eDockLeft, $eDockTop, $eDockWidth, $eDockHeight
	Local Const $aDesktop_Window = _GetDesktopArea()

	Local Const $fIsMaximized = _IsMaximized($hWnd_1)
	If $fRightSide = Default Then
		$fRightSide = $aSciTEJump_Window[$eDockLeft] + $aSciTEJump_Window[$eDockWidth] > $aDesktop_Window[$eDockLeft] + $aSciTE_Window[$eDockLeft] + ($aSciTE_Window[$eDockWidth] / 2)
	EndIf

	If $fRightSide Then
		If $aSciTE_Window[$eDockLeft] + $aSciTE_Window[$eDockWidth] + $aSciTEJump_Window[$eDockWidth] > $aDesktop_Window[$eDockWidth] Then
			If $fIsMaximized Then
				$aSciTE_Window[$eDockLeft] = $aDesktop_Window[$eDockLeft]
				$aSciTE_Window[$eDockTop] = $aDesktop_Window[$eDockTop]
				$aSciTE_Window[$eDockWidth] = ($aDesktop_Window[$eDockWidth] - $aDesktop_Window[$eDockLeft]) - ($aSciTEJump_Window[$eDockWidth] - $aDesktop_Window[$eDockLeft])
				$aSciTE_Window[$eDockHeight] = ($aDesktop_Window[$eDockHeight] + $aDesktop_Window[$eDockTop]) - $aDesktop_Window[$eDockTop]
			Else
				$aSciTE_Window[$eDockLeft] = $aDesktop_Window[$eDockWidth] - $aSciTE_Window[$eDockWidth] - $aSciTEJump_Window[$eDockWidth]
				Do
					$aSciTE_Window[$eDockWidth] -= 1
				Until $aSciTE_Window[$eDockLeft] + $aSciTE_Window[$eDockWidth] + $aSciTEJump_Window[$eDockWidth] < $aDesktop_Window[$eDockWidth]
			EndIf
			WinMove($hWnd_1, '', $aSciTE_Window[$eDockLeft], $aSciTE_Window[$eDockTop], $aSciTE_Window[$eDockWidth], $aSciTE_Window[$eDockHeight])
		EndIf
	Else
		If $aSciTEJump_Window[$eDockLeft] < $aDesktop_Window[$eDockLeft] Then
			If $fIsMaximized Then
				$aSciTE_Window[$eDockLeft] = $aDesktop_Window[$eDockLeft] + $aSciTEJump_Window[$eDockWidth]
				$aSciTE_Window[$eDockTop] = $aDesktop_Window[$eDockTop]
				$aSciTE_Window[$eDockWidth] = ($aDesktop_Window[$eDockWidth] - $aDesktop_Window[$eDockLeft]) - ($aSciTEJump_Window[$eDockWidth] - $aDesktop_Window[$eDockLeft])
				$aSciTE_Window[$eDockHeight] = ($aDesktop_Window[$eDockHeight] + $aDesktop_Window[$eDockTop]) - $aDesktop_Window[$eDockTop]
			Else
				$aSciTE_Window[$eDockLeft] = $aDesktop_Window[$eDockLeft] + $aSciTEJump_Window[$eDockWidth]
				Do
					$aSciTE_Window[$eDockWidth] -= 1
				Until $aSciTE_Window[$eDockLeft] + $aSciTE_Window[$eDockWidth] < $aDesktop_Window[$eDockWidth]
			EndIf
			WinMove($hWnd_1, '', $aSciTE_Window[$eDockLeft], $aSciTE_Window[$eDockTop], $aSciTE_Window[$eDockWidth], $aSciTE_Window[$eDockHeight])
		EndIf
	EndIf

	If $fRightSide Then
		$aSciTE_Window[$eDockLeft] += $aSciTE_Window[$eDockWidth]
	Else
		$aSciTE_Window[$eDockLeft] -= $aSciTEJump_Window[$eDockWidth]
	EndIf
	WinMove($hWnd_2, '', $aSciTE_Window[$eDockLeft], $aSciTE_Window[$eDockTop], Default, $aSciTE_Window[$eDockHeight])

	If IsHWnd($hActivate) Then
		WinActivate($hActivate)
	EndIf
	Return True
EndFunc   ;==>_DockToWindowEx

Func _FileSearch($sFilePath, $sFilter = '*.*', $iControlID = -9999)
	Local Const $aError[2] = [1, $sFilePath]
	If Not _WinAPI_PathIsDirectory($sFilePath) Then
		Return SetError(1, 0, $aError)
	EndIf

	$sFilePath = _WinAPI_PathAddBackslash($sFilePath)
	Local Const $iPID = Run(@ComSpec & ' /C DIR "' & $sFilePath & $sFilter & '" /B /A-D /S', $sFilePath, @SW_HIDE, $STDOUT_CHILD)
	Local $sOutput = ''
	While 1
		$sOutput &= StdoutRead($iPID)
		If @error Then
			ExitLoop
		EndIf
		If _IsChecked($iControlID) Then
			_Toggle_CheckOrUnCheck($iControlID, False)
			_ProcessKill($iPID)
			Return SetError(1, 0, $aError)
		EndIf
	WEnd
	Return StringSplit(StringTrimRight($sOutput, StringLen(@CRLF)), @CRLF, $STR_ENTIRESPLIT)
EndFunc   ;==>_FileSearch

Func _FunctionToLine($sFilePath) ; By UEZ.
	If FileExists($sFilePath) = 0 Then Return 0

	Local $sData = _GetFile($sFilePath)
	_StripWhitespace($sData)
	_StripFunctionsOutside($sData)
	Local Const $aArray = StringSplit($sData, @CRLF, $STR_ENTIRESPLIT)
	Local $aFunctions[$aArray[0] + 1] = [$aArray[0]], _
			$aReturn = 0, _
			$fIsFunction = False, _
			$sFunctionName = ''
	For $i = 1 To $aArray[0]
		If $fIsFunction Then
			$aFunctions[$i] = $sFunctionName
			If StringRegExp($aArray[$i], '(?i:^EndFunc)') Then
				$fIsFunction = False
				$sFunctionName = ''
			EndIf
		EndIf
		If Not $fIsFunction Then
			$aReturn = StringRegExp($aArray[$i], '(?i:^Func\h+)(\w+)', 3)
			If @error = 0 Then
				$fIsFunction = True
				$aFunctions[$i] = $aReturn[0]
				$sFunctionName = $aFunctions[$i]
			EndIf
		EndIf
	Next
	Return $aFunctions
EndFunc   ;==>_FunctionToLine

Func _FunctionToLineMonitor()
	Local Static $iPreviousLineNumber = -1
	Local $sFunction = ''
	If UBound($__vFunctionLines) Then
		Local Const $iLineNumber = _SciTE_GetSelectedLineNumber() + 1
		If $iLineNumber <= $__vFunctionLines[0] Then
			$sFunction = $__vFunctionLines[$iLineNumber]
			If Not ($sFunction == '') And Not ($iPreviousLineNumber = $iLineNumber) Then
				$iPreviousLineNumber = $iLineNumber
			Else
				$sFunction = ''
			EndIf
		EndIf
	EndIf
	Return SetError($sFunction = '', 0, $sFunction)
EndFunc   ;==>_FunctionToLineMonitor

Func _GetComments(ByRef Const $sData, ByRef $aArray, ByRef Const $iTreeViewID)
	Local $aReturn = StringRegExp('; CommentCount' & @CRLF & $sData, '(?m:^;(~?\h*\V+))|;(\h*[^''"\s][^''"\v]+)\R|(?ims:^(#cs|#comments-start)\s+(\V+).*?#(?:ce|comments-end))', 4)
	$aReturn[0] = UBound($aReturn) - 1
	If $aReturn[0] Then
		Local $aSubArray = 0, _
				$hUnique = 0, _
				$sComment = '', $sString = ''
		_AssociativeArray_Startup($hUnique, False)
		$aArray[0][2] = BitOR($aArray[0][2], $iTreeViewID)
		ReDim $aArray[$aArray[0][0] + $aReturn[0] + 1][$aArray[0][1]]
		For $i = 1 To $aReturn[0]
			$aSubArray = $aReturn[$i]
			$sComment = $aSubArray[1]
			$sString = $aSubArray[0]
			If Not $sComment Then
				$sComment = $aSubArray[2] ; Second capture group.
			EndIf
			If Not $sComment Then ; Third capture group, set the first line in the comment as the line to search for as there can (and likely will) be more than one '#cs...#ce'
				$sComment = $aSubArray[3] & '....' & $aSubArray[4]
				$sString = $aSubArray[4]
			EndIf
			If Not $hUnique.Exists($sString) Then
				$aArray[0][0] += 1
				$aArray[$aArray[0][0]][0] = $sString ; $sComment
				$aArray[$aArray[0][0]][1] = $iTreeViewID
				$hUnique.Item($sString)
			EndIf
		Next
		; $hUnique.RemoveAll()
		$hUnique = 0
	EndIf
	$aReturn = 0
	Return True
EndFunc   ;==>_GetComments

Func _GetDirectives(ByRef Const $sData, ByRef $aArray, ByRef Const $iTreeViewID)
	Local $aReturn = StringRegExp('#autoitwrapper directivecount' & @CRLF & $sData, '(?im)^(#(?:autoitwrapper|forceref|pragma)[^\r\n]*)', 3) ; Make sure we capture something usable to search for later.
	$aReturn[0] = UBound($aReturn) - 1
	If $aReturn[0] Then
		$aArray[0][2] = BitOR($aArray[0][2], $iTreeViewID)
		ReDim $aArray[$aArray[0][0] + $aReturn[0] + 1][$aArray[0][1]]
		Local $hUnique = 0
		_AssociativeArray_Startup($hUnique, False)
		For $i = 1 To $aReturn[0]
			If Not $hUnique.Exists($aReturn[$i]) Then
				$aArray[0][0] += 1
				$aArray[$aArray[0][0]][0] = $aReturn[$i]
				$aArray[$aArray[0][0]][1] = $iTreeViewID
				$hUnique.Item($aReturn[$i])
			EndIf
		Next
		; $hUnique.RemoveAll()
		$hUnique = 0
	EndIf
	$aReturn = 0
	Return True
EndFunc   ;==>_GetDirectives

Func _GetDesktopArea()
	Local Const $tRECT = DllStructCreate($tagRECT)
	_WinAPI_SystemParametersInfo($SPI_GETWORKAREA, 0, DllStructGetPtr($tRECT))
	Local Const $aReturn[4] = [DllStructGetData($tRECT, 'Left'), DllStructGetData($tRECT, 'Top'), _
			DllStructGetData($tRECT, 'Right') - DllStructGetData($tRECT, 'Left'), DllStructGetData($tRECT, 'Bottom') - DllStructGetData($tRECT, 'Top')]
	Return $aReturn
EndFunc   ;==>_GetDesktopArea

Func _GetDockState($sFilePath)
	Local $fIsDockState = Number(IniRead($sFilePath, 'General', 'DockState', Number(Default)))
	If Number(Default) = $fIsDockState Then
		$fIsDockState = Default
	Else
		$fIsDockState = $fIsDockState = 1
	EndIf
	Return $fIsDockState
EndFunc   ;==>_GetDockState

Func _GetFile($sFilePath, $iFormat = $FO_READ)
	Local Const $hFileOpen = FileOpen($sFilePath, $iFormat)
	If $hFileOpen = -1 Then
		Return SetError(1, 0, '')
	EndIf
	Local Const $sData = FileRead($hFileOpen)
	FileClose($hFileOpen)
	Return $sData
EndFunc   ;==>_GetFile

Func _GetFileInfo(ByRef $aFunctions, ByRef $sData, $sFilePath)
	$sData = @CRLF & $sData & @CRLF
	Local $aIncludes = _GetIncludeInfo($sData, $sFilePath, False), $sReturn = ''
	If @error = 0 Then
		_Sort($aIncludes, True, 1, $aIncludes[0])
		_SetCustomVariable(1, $aIncludes[0])
		$sReturn &= '# ' & StringUpper(_GetLanguage('TIP_EXPORT_5', 'Total number of includes - %TOTALNUMBER%')) & ' #' & @CRLF
		For $i = 1 To $aIncludes[0]
			$sReturn &= '> ' & $aIncludes[$i] & @CRLF
		Next
		$sReturn &= @CRLF
	EndIf

	_AutoIt_Startup()
	_AutoIt_AddCmdLine()
	_GetIncludeVariables($sFilePath)

	$sData = @CRLF & $sData & @CRLF
	_StripWhitespace($sData)
	_StripEmptyLines($sData)
	_StripStringLiterals($sData)
	_StripCommentLines($sData)
	_StripFunctionsEnd($sData)
	_StripDirectives($sData)
	_StripMerge($sData)
	_StripForVariables($sData)
	_StripEmptyLines($sData)
	_StripWhitespace($sData)

	Local $iCount = 0, _
			$sVariables = ''
	Local $aVariables = _GetVariablesOutsideFunction($sData)
	If @error = 0 Then
		_Sort($aVariables, True, 1, $aVariables[0])

		For $i = 1 To $aVariables[0]
			If _AutoIt_IsDeclared($aVariables[$i], '__GLOBALVARS__') Then
				ContinueLoop
			EndIf
			$iCount += 1
			$sVariables &= '> ' & $aVariables[$i] & @CRLF
		Next
		_SetCustomVariable(1, $iCount)
		$sReturn &= '# ' & StringUpper(_GetLanguage('TIP_EXPORT_6', 'Total number of Global variables - %TOTALNUMBER%')) & ' #' & @CRLF
		$sReturn &= $sVariables & @CRLF

		_AutoIt_AddConstantsGlobal($aVariables, '__GLOBALVARS__')
		$aVariables = 0
		$iCount = 0
		$sVariables = ''
	EndIf

	If $aFunctions[0] Then
		Local $aVariableScoped = 0, $sFunctionSnippet = ''
		_Sort($aFunctions, False, 1, $aFunctions[0])

		_SetCustomVariable(1, $aFunctions[0])
		$sReturn &= '# ' & StringUpper(_GetLanguage('TIP_EXPORT_1', 'Total number of functions - %TOTALNUMBER%')) & ' #' & @CRLF

		For $i = 1 To $aFunctions[0]
			$aVariables = _GetVariablesInFunction($sData, $aFunctions[$i], $sFunctionSnippet)
			If @error = 0 Then
				_Sort($aVariables, True, 1, $aVariables[0])
				$aVariableScoped = _GetVariablesScoped($sFunctionSnippet)
				_AutoIt_AddConstantsGlobal($aVariableScoped, '__LOCALVARS__' & $aFunctions[$i] & '__')

				$iCount = 0
				$sVariables = ''
				For $j = 1 To $aVariables[0]
					If _AutoIt_IsDeclared($aVariables[$j], '__GLOBALVARS__') And Not _AutoIt_IsDeclared($aVariables[$j], '__LOCALVARS__' & $aFunctions[$i] & '__') Then
						ContinueLoop
					EndIf
					$iCount += 1
					$sVariables &= @TAB & $aVariables[$j] & @CRLF
				Next
				$sReturn &= '> ' & $aFunctions[$i] & ' [' & $iCount & ']:' & @CRLF & $sVariables

				If $i < $aFunctions[0] Then
					$sReturn &= @CRLF
				EndIf
			EndIf
		Next
	EndIf

	_AutoIt_Shutdown()
	Return $sReturn
EndFunc   ;==>_GetFileInfo

Func _GetFullPath($sRelativePath, $sBasePath = @WorkingDir)
	Local Const $sWorkingDir = @WorkingDir
	FileChangeDir($sBasePath)
	$sRelativePath = _WinAPI_GetFullPathName($sRelativePath)
	FileChangeDir($sWorkingDir)
	Return $sRelativePath
EndFunc   ;==>_GetFullPath

Func _GetFunctions(ByRef $sData, ByRef $aArray, ByRef Const $iTreeViewID, $fSort = Default)
	Local $aReturn = 0
	_GetFunctionInfo($sData, $aReturn, $fSort)
	If $aReturn[0] Then
		$aArray[0][2] = BitOR($aArray[0][2], $iTreeViewID)
		ReDim $aArray[$aArray[0][0] + $aReturn[0] + 1][$aArray[0][1]]
		Local $hUnique = 0
		_AssociativeArray_Startup($hUnique, False)
		For $i = 1 To $aReturn[0]
			If Not $hUnique.Exists($aReturn[$i]) Then
				$aArray[0][0] += 1
				$aArray[$aArray[0][0]][0] = $aReturn[$i]
				$aArray[$aArray[0][0]][1] = $iTreeViewID
				$hUnique.Item($aReturn[$i])
			EndIf
		Next
		; $hUnique.RemoveAll()
		$hUnique = 0
	EndIf
	$aReturn = 0
	Return True
EndFunc   ;==>_GetFunctions

Func _GetFunctionInfo(ByRef $sData, ByRef $aArray, $fIsSort = Default)
	; Strip comment blocks to avoid unintended matches. By Robjong
	$aArray = StringRegExp('Func FunctionCount()' & @CRLF & 'EndFunc' & @CRLF & StringRegExpReplace($sData, '(?ims:^\h*#(?:cs|comments-start)(?!\w).+?#(?:ce|comments-end)[^\r\n]*\R)', ''), '(?im)^Func (\h*\w+)\h*\(', 3)
	$aArray[0] = UBound($aArray) - 1
	If $fIsSort Then
		_Sort($aArray, False, 1, $aArray[0])
	EndIf
EndFunc   ;==>_GetFunctionInfo

Func _GetFunctionsInFunctions(ByRef Const $sData)
	Local $aReturn = StringRegExp('Execute("Count")' & @CRLF & $sData, _
			'\b(?i:Adlib(?:Un)?Register|Call|DllCallbackRegister|Execute|OnAutoItExit(?:Un)?Register)\b' & _
			'(?:\(["''](\w+?)["''])?' & _
			'|' & _
			'\b(?i:GUICtrlRegisterListViewSort|GUICtrlSetOnEvent|GUIRegisterMsg|HotKeySet|TraySetOnEvent|TrayItemSetOnEvent)\b' & _
			'\([^,]*,[^\w]+(\w+)', _ ; By PhoenixXL.
			3)
	$aReturn[0] = UBound($aReturn) - 1
	Return SetError($aReturn[0] = 0, 0, $aReturn)
EndFunc   ;==>_GetFunctionsInFunctions

Func _GetIncludesArray($sFilePath, ByRef $sData, ByRef $sMerged, ByRef $aFunctions, ByRef $sIncludeString, ByRef $sIncludeParent, ByRef Const $iTreeViewID, $iFlags = Default)
	Local Enum Step *2 $eINCLUDES_RECURSIVESEARCH, $eINCLUDES_USERDEFINED, $eINCLUDES_PARSEFUNCTIONS
	; Local Static $iTreeViewCustomID = 0, $iRecursionCall = 0, $sIncludePath = _WinAPI_PathRemoveFileSpec(@AutoItExe) & '\Include', $sUserIncludePath = ''
	Local Static $iTreeViewCustomID = 0, $iRecursionCall = 0, $sIncludePath = _GetFullPath('..\Include', _SciTE_GetSciTEDefaultHome()), $sUserIncludePath = ''
	If Not $iRecursionCall Then
		$iTreeViewCustomID = $aFunctions[0][2] ; Hold onto the treeview id.
		$aFunctions[0][2] = $aFunctions[0][0] + 1 ; Set to the current size of the array.
		If $sUserIncludePath = '' Then
			$sUserIncludePath = RegRead('HKEY_CURRENT_USER\SOFTWARE\AutoIt v3\AutoIt', 'Include')
			If $sUserIncludePath = '' Then
				$sUserIncludePath = RegRead('HKEY_LOCAL_MACHINE\SOFTWARE\AutoIt v3\AutoIt', 'Include')
			EndIf
			If Not ($sUserIncludePath = '') Then
				If StringLeft($sUserIncludePath, 1) == ';' Then
					$sUserIncludePath = StringTrimLeft($sUserIncludePath, 1)
				EndIf
				If Not (StringRight($sUserIncludePath, 1) == ';') Then
					$sUserIncludePath &= ';'
				EndIf
			EndIf
		EndIf
		$sIncludeParent &= $sFilePath & '|'
		$sIncludeString &= $sFilePath & '|'
	EndIf

	If $iFlags = Default Then
		$iFlags = BitOR($eINCLUDES_RECURSIVESEARCH, $eINCLUDES_USERDEFINED, $eINCLUDES_PARSEFUNCTIONS)
	EndIf
	Local Const $fParseFunctions = BitAND($iFlags, $eINCLUDES_PARSEFUNCTIONS) = $eINCLUDES_PARSEFUNCTIONS
	Local Const $fRecursiveSearch = BitAND($iFlags, $eINCLUDES_RECURSIVESEARCH) = $eINCLUDES_RECURSIVESEARCH
	Local Const $fUserDefinedOnly = BitAND($iFlags, $eINCLUDES_USERDEFINED) = $eINCLUDES_USERDEFINED

	Local Const $sFileFolder = _WinAPI_PathRemoveFileSpec($sFilePath)
	Local $aFunctionsList = 0, $aIncludesSplit = 0, $iAutoItInclude = 1, _
			$sFilePathNonStripped = '', $sStrippedData = ''
	Local Const $aFilePaths[2] = [$sFileFolder, $sIncludePath]
	Local $aArray = StringRegExp('#include "IncludeCount.au3"' & @CRLF & $sData, '(?im)^#include\h*([<"''](?![^>"'']*\.\ba3x\b)[^*?"''<>|]+)', 3) ; Skip a3x includes.
	$aArray[0] = UBound($aArray) - 1

	For $i = 1 To $aArray[0]
		Switch StringLeft($aArray[$i], 1)
			Case '<' ; AutoIt includes, Registry, Relative path.
				$iAutoItInclude = 1
			Case '''', '"' ; Relative path, Registry, AutoIt includes.
				$iAutoItInclude = 0
		EndSwitch
		$sFilePathNonStripped = $aArray[$i]
		$aArray[$i] = StringStripWS(StringTrimLeft($aArray[$i], 1), $STR_STRIPLEADING + $STR_STRIPTRAILING)

		If Not _IsFullPath($aArray[$i]) Or FileExists($aArray[$i]) = 0 Then
			If FileExists($aFilePaths[$iAutoItInclude] & '\' & $aArray[$i]) Then
				$aArray[$i] = $aFilePaths[$iAutoItInclude] & '\' & $aArray[$i]
			Else
				$aIncludesSplit = StringSplit($sUserIncludePath & $aFilePaths[Int(Not $iAutoItInclude)], ';')
				For $j = 1 To $aIncludesSplit[0]
					$aIncludesSplit[$j] = _WinAPI_PathRemoveBackslash($aIncludesSplit[$j])
					$aArray[$i] = $aIncludesSplit[$j] & '\' & $aArray[$i]
					$aArray[$i] = _WinAPI_GetFullPathName($aArray[$i])
					If FileExists($aArray[$i]) Then
						ExitLoop
					EndIf
				Next
			EndIf
		EndIf

		If FileExists($aArray[$i]) And Not StringInStr('|' & $sIncludeString, '|' & $aArray[$i] & '|') Then
			$sIncludeParent &= $sFilePath & '|'
			$sIncludeString &= $aArray[$i] & '|'
			; _ConsoleWrite($aArray[$i] & @CRLF)

			If $fRecursiveSearch Then
				$sData = _GetFile($aArray[$i])

				$sStrippedData = $sData
				_StripWhitespace($sStrippedData)
				_StripCommentLines($sStrippedData)
				_StripMerge($sStrippedData)

				$sMerged = StringRegExpReplace($sMerged, '(?im:^#include\h*' & $sFilePathNonStripped & '[>"''])', $ASCII_BEL, 1)
				If @extended Then
					$sMerged = StringRegExpReplace($sMerged, $ASCII_BEL, _StringRegExpExpand($sStrippedData) & @CRLF, 1)
				Else
					$sMerged &= $sStrippedData & @CRLF
				EndIf
				$sStrippedData = ''

				If $fUserDefinedOnly And (_WinAPI_PathRemoveFileSpec($aArray[$i]) == $sIncludePath) Then
					$sData = ''
					$sIncludeParent = StringLeft($sIncludeParent, StringInStr($sIncludeParent, '|', $STR_NOCASESENSE, -2))
					$sIncludeString = StringLeft($sIncludeString, StringInStr($sIncludeString, '|', $STR_NOCASESENSE, -2))
				EndIf

				If $sData And $fParseFunctions Then
					_GetFunctionInfo($sData, $aFunctionsList)
					For $j = 1 To $aFunctionsList[0]
						_ReDim($aFunctions, $aFunctions[0][2])
						$aFunctions[0][0] += 1
						$aFunctions[$aFunctions[0][0]][0] = $aFunctionsList[$j]
						$aFunctions[$aFunctions[0][0]][1] = $iTreeViewID
						$aFunctions[$aFunctions[0][0]][2] = $aArray[$i]
					Next
				EndIf

				$iRecursionCall += 1
				_GetIncludesArray($aArray[$i], $sData, $sMerged, $aFunctions, $sIncludeString, $sIncludeParent, $iTreeViewID, $iFlags)
				$iRecursionCall -= 1
			EndIf
		EndIf
	Next

	If Not $iRecursionCall Then
		$sIncludeParent = StringTrimLeft($sIncludeParent, StringInStr($sIncludeParent, '|', $STR_NOCASESENSE, 1)) ; Remove the main script file.
		$sIncludeString = StringTrimLeft($sIncludeString, StringInStr($sIncludeString, '|', $STR_NOCASESENSE, 1)) ; Remove the main script file.
		$sIncludeParent = StringTrimRight($sIncludeParent, StringLen('|'))
		$sIncludeString = StringTrimRight($sIncludeString, StringLen('|'))

		If StringStripWS(StringReplace($sIncludeString, '|', ''), $STR_STRIPALL) Then
			$aFunctions[0][2] = BitOR($iTreeViewCustomID, $iTreeViewID) ; Set the treeview id as containing UDF functions.
		Else
			$aFunctions[0][2] = $iTreeViewCustomID
		EndIf
		$iTreeViewCustomID = 0 ; Reset the treeview id variable to 0.

		If Not $fRecursiveSearch And Not $fUserDefinedOnly Then
			$sIncludeParent = StringReplace($sIncludeParent, $sIncludePath & '\', '')
			$sIncludeString = StringReplace($sIncludeString, $sIncludePath & '\', '')
		EndIf
		$sUserIncludePath = ''
	EndIf
	Return Not ($sIncludeString == '')
EndFunc   ;==>_GetIncludesArray

Func _GetIncludeInfo($sData, $sFilePath, $fFullPath = False)
	Local $aFunctions[2][3] = [[0, 3, 1]], $iTreeViewID = Int($fFullPath), $sIncludeParent = '', $sIncludeString = '', $sMerged = ''
	_GetIncludesArray($sFilePath, $sData, $sMerged, $aFunctions, $sIncludeString, $sIncludeParent, $iTreeViewID, $iTreeViewID)
	Local $aReturn = StringSplit($sIncludeString, '|')
	If @error Then
		$aReturn[0] = 0
	EndIf
	Return SetError($aReturn[0] = 0, 0, $aReturn)
EndFunc   ;==>_GetIncludeInfo

Func _GetIncludeVariables($sFilePath)
	Local $sData = _GetFile($sFilePath)
	Local Const $aIncludes = _GetIncludeInfo($sData, $sFilePath, True)
	$sData = ''
	For $i = 1 To $aIncludes[0]
		$sData &= _GetFile($aIncludes[$i]) & @CRLF
	Next

	$sData = @CRLF & $sData & @CRLF
	_StripWhitespace($sData)
	_StripEmptyLines($sData)
	_StripStringLiterals($sData)
	_StripCommentLines($sData)
	_StripFunctionsEnd($sData)
	_StripDirectives($sData)
	_StripMerge($sData)
	_StripFunctions($sData)
	_StripForVariables($sData)
	_StripEmptyLines($sData)
	_StripWhitespace($sData)

	Local $aVariables = _GetVariableInfo($sData)
	_Sort($aVariables, True, 1, $aVariables[0])
	_AutoIt_AddConstantsGlobal($aVariables, '__GLOBALVARS__')
	$aVariables = 0
	Return True
EndFunc   ;==>_GetIncludeVariables

Func _GetRegions(ByRef Const $sData, ByRef $aArray, ByRef Const $iTreeViewID)
	Local $aReturn = StringRegExp('#region regioncount' & @CRLF & $sData, '(?im)^#region ([^\r\n]*)', 3) ; Make sure we capture something usable to search for later.
	$aReturn[0] = UBound($aReturn) - 1
	If $aReturn[0] Then
		$aArray[0][2] = BitOR($aArray[0][2], $iTreeViewID)
		ReDim $aArray[$aArray[0][0] + $aReturn[0] + 1][$aArray[0][1]]
		Local $hUnique = 0
		_AssociativeArray_Startup($hUnique, False)
		For $i = 1 To $aReturn[0]
			If Not $hUnique.Exists($aReturn[$i]) Then
				$aArray[0][0] += 1
				$aArray[$aArray[0][0]][0] = $aReturn[$i]
				$aArray[$aArray[0][0]][1] = $iTreeViewID
				$hUnique.Item($aReturn[$i])
			EndIf
		Next
		; $hUnique.RemoveAll()
		$hUnique = 0
	EndIf
	$aReturn = 0
	Return True
EndFunc   ;==>_GetRegions

Func _GetVariableInfo(ByRef Const $sData) ; By James1337 And Modified By softwarespot.
	Local $aReturn = StringRegExp('$iVariableCount = 0' & @CRLF & $sData, '(\$\w+)(?:[\h\[.=+*/^,)\-])?', 3)
	$aReturn[0] = UBound($aReturn) - 1
	Return SetError($aReturn[0] = 0, 0, $aReturn)
EndFunc   ;==>_GetVariableInfo

Func _GetVariablesInFunction(ByRef $sData, $sFunction, ByRef $sFunctionSnippet) ; By James1337 And Modified By softwarespot.
	$sFunctionSnippet = $sData
	Local Const $sEnd = BinaryToString('0x1010101010'), $sStart = BinaryToString('0x0101010101')
	$sFunctionSnippet = StringRegExpReplace($sFunctionSnippet, '(?im)^\h*Func\h+' & StringStripWS($sFunction, $STR_STRIPALL) & '\h*\(', $sStart)
	$sFunctionSnippet = StringRegExpReplace($sFunctionSnippet, '(?im)^\h*EndFunc', $sEnd)

	Local Const $iStart = StringInStr($sFunctionSnippet, $sStart, $STR_NOCASESENSE, 1)
	Local Const $iEnd = StringInStr($sFunctionSnippet, $sEnd, $STR_NOCASESENSE, 1, $iStart)
	If $iStart > 0 And $iEnd > $iStart Then
		$sFunctionSnippet = StringMid($sFunctionSnippet, $iStart, $iEnd - $iStart + StringLen($sStart))
	Else
		$sFunctionSnippet = ''
	EndIf

	Local Const $aReturn = _GetVariableInfo($sFunctionSnippet)
	If $sFunctionSnippet Then
		$sFunctionSnippet = StringReplace($sFunctionSnippet, $sStart, 'Func ' & $sFunction & '(')
		$sFunctionSnippet = StringReplace($sFunctionSnippet, $sEnd, 'EndFunc   ;==>' & $sFunction)
	EndIf
	Return SetError($sFunctionSnippet = '', 0, $aReturn)
EndFunc   ;==>_GetVariablesInFunction

Func _GetVariablesOutsideFunction($sData)
	_StripFunctions($sData)
	Local Const $aReturn = _GetVariableInfo($sData)
	Return SetError(@error, 0, $aReturn)
EndFunc   ;==>_GetVariablesOutsideFunction

Func _GetVariablesScoped(ByRef Const $sData)
	#cs
		Possible combinations:
		Local
		Local Const
		Local Enum
		Local Static
		Global
		Global Const
		Global Enum
		Global Static

		Const
		Enum [Step */-/+Int]
		Static
	#ce
	Local $sVarString = ',$iCount,'
	$sVarString &= StringRegExpReplace($sData, '(?im:^(?!Func)[^\n]*|Func\h+\w+\(([^\r\n]*)\))', '\1') & ','
	; (?mi)^\h*(?:(?:Local|Global|Static|Enum|Const)\h+(?:(?:Local|Global|Static|Enum|Const)\h+)?(?:Step(?:\h+\*\d+)?\h+)?)(.+?)\s+$ ; By AZJIO.
	Local $aArray = StringRegExp($sData, _
			'(?im:^(?=Global|Local|Const|Enum|Static)(?:Global|Local)?\h*(?:Const|Enum|Static)?(?:(?<=Enum)\h+Step\h+[+*-]\d+)?\h*)([^\r\n]+)', 3) ; By guinness.
	If @error = 0 Then
		For $i = 0 To UBound($aArray, 1) - 1
			$sVarString &= $aArray[$i] & ','
		Next
	EndIf
	$sVarString = StringStripWS($sVarString, $STR_STRIPALL)
	_StripArrayBrackets($sVarString)
	_StripFunctionsNested($sVarString)
	Local $aReturn = StringRegExp($sVarString, '(?i)(?<=,|ByRef|Const)\$\w+', 3) ; By AZJIO.
	$aReturn[0] = UBound($aReturn, 1) - 1
	Return SetError($aReturn[0] = 0, 0, $aReturn)
EndFunc   ;==>_GetVariablesScoped

Func _Is($sData, $sDefault = Default, $sSection = 'General', $sDefaultFilePath = @ScriptDir)
	If $sSection = Default Then $sSection = 'General'
	Return Int(IniRead($sDefaultFilePath & '\Settings.ini', $sSection, $sData, $sDefault))
EndFunc   ;==>_Is

Func _IsActive($hWnd)
	Return BitAND(WinGetState($hWnd), 8) = 8
EndFunc   ;==>_IsActive

Func _IsChecked($iControlID)
	Return BitAND(GUICtrlRead($iControlID), $GUI_CHECKED) = $GUI_CHECKED
EndFunc   ;==>_IsChecked

Func _IsEmpty($sFilePath)
	If StringStripWS($sFilePath, $STR_STRIPALL) = '' Then
		Return True
	EndIf
	Return StringRegExp($sFilePath, '(?i)\(Untitled\)|\(NoFile\)|\(NoWindow\)') == 1
EndFunc   ;==>_IsEmpty

Func _IsFullPath($sFilePath)
	Return StringMid($sFilePath, 2, 2) == ':\'
EndFunc   ;==>_IsFullPath

Func _IsMaximized($hWnd)
	Return BitAND(WinGetState($hWnd), 32) = 32
EndFunc   ;==>_IsMaximized

Func _IsMinimized($hWnd)
	Return BitAND(WinGetState($hWnd), 16) = 16
EndFunc   ;==>_IsMinimized

Func _IsReadOnly($sFilePath)
	Return StringInStr(FileGetAttrib($sFilePath), 'R') > 0
EndFunc   ;==>_IsReadOnly

Func _IsValidFileType($sFilePath, $sList = 'bat;cmd;exe', $iOpFast = 1)
	If StringStripWS($sList, $STR_STRIPALL) = '' Then
		$sList = '*'
	EndIf
	Return _WinAPI_PathMatchSpec($sFilePath, StringReplace(';' & $sList, ';', ';*.', 0, $iOpFast * $STR_NOCASESENSE))
EndFunc   ;==>_IsValidFileType

Func _ProcessKill($iPID)
	Local Const $hTimer = TimerInit(), $iTimeOut = 5000
	While ProcessExists($iPID)
		If TimerDiff($hTimer) > $iTimeOut Then
			ExitLoop
		EndIf
		RunWait('TASKKILL /F /PID ' & $iPID, @SystemDir & '', @SW_HIDE)
		Sleep(20)
	WEnd
	Return ProcessExists($iPID) > 0
EndFunc   ;==>_ProcessKill

Func _ReDim(ByRef $aArray, ByRef $iDimension)
	If ($aArray[0][0] + 1) >= $iDimension Then
		$iDimension = Ceiling(($aArray[0][0] + 1) * 1.3)
		ReDim $aArray[$iDimension][$aArray[0][1]]
	EndIf
EndFunc   ;==>_ReDim

Func _SetFile($sString, $sFilePath, $iOverwrite = $FO_READ)
	Local Const $hFileOpen = FileOpen($sFilePath, $iOverwrite + $FO_APPEND)
	FileWrite($hFileOpen, $sString)
	FileClose($hFileOpen)
	If @error Then
		Return SetError(1, 0, False)
	EndIf
	Return True
EndFunc   ;==>_SetFile

Func _Sort(ByRef $aArray, $fUnique, $iStart, $iEnd)
	Local $sOutput = ''
	If $fUnique Then
		_ArrayUniqueFast($aArray, $sOutput, $iStart, $iEnd)
		$sOutput = StringReplace($sOutput, ChrW(160), @CRLF) ; Replace the seperator with @CRLF.
	Else
		For $i = $iStart To $iEnd
			$sOutput &= $aArray[$i] & @CRLF
		Next
	EndIf
	Local Const $iPID = Run('sort.exe', @SystemDir, @SW_HIDE, $STDIN_CHILD + $STDOUT_CHILD)
	StdinWrite($iPID, $sOutput)
	StdinWrite($iPID)
	$sOutput = ''
	While 1
		$sOutput &= StdoutRead($iPID)
		If @error Then
			ExitLoop
		EndIf
	WEnd
	$aArray = StringSplit(StringStripWS($sOutput, $STR_STRIPLEADING + $STR_STRIPTRAILING), @CRLF, 1)
	If @error And StringStripWS($aArray[1], $STR_STRIPALL) = '' Then
		$aArray[0] = 0
		ReDim $aArray[1]
	EndIf
EndFunc   ;==>_Sort

Func _StringRegExpMetaCharacters($sString)
	Return StringRegExpReplace($sString, '([].|*?+(){}^$\\[])', '\\\1')
EndFunc   ;==>_StringRegExpMetaCharacters

Func _StripArrayBrackets(ByRef $sData)
	Do
		$sData = StringRegExpReplace($sData, '\[[^\[\]]*?\]', '') ; Remove square brackets. By AZJIO.
	Until @extended = 0
EndFunc   ;==>_StripArrayBrackets

Func _StripCommentLines(ByRef $sData, $sReplace = Default)
	If $sReplace = Default Then
		$sReplace = ''
	EndIf
	_ConvertCRToCRLF($sData)
	$sData = StringTrimLeft(StringRegExpReplace($sData, '\R[^;"''\r\n]*(?:[^;"''\r\n]|''[^''\r\n]*''|"[^"\r\n]*")*\K;[^\r\n]*', ''), StringLen(@LF)) ; By DXRW4E. http://www.autoitscript.com/forum/topic/157255-regular-expression-challenge-for-stripping-single-comments/
	$sData = StringRegExpReplace($sData, '(?ims:^\h*#(?:cs|comments-start)(?!\w).+?#(?:ce|comments-end)[^\r\n]*\R)', $sReplace) ; Strip comment blocks to avoid unintended matches. By Robjong
	$sData = StringRegExpReplace($sData, '(?im:^#(?:(?:end)?region)(?!\w)[^\r\n]+\R)', $sReplace) ; By DXRW4E. Fixed by guinness.
	$sData = StringRegExpReplace($sData, '(?im:^#(?!autoit|force(def|ref)|ignorefunc|include(-once)?|' & _
			'noautoit|notrayicon|onautoitstartregister|au3stripper|obfuscator|pragma|requireadmin|tidy)[^\r\n]*\R)', $sReplace) ; Strip user custom comments. By guinness.
EndFunc   ;==>_StripCommentLines

Func _StripDirectives(ByRef $sData)
	$sData = StringRegExpReplace($sData, '(?im:^\h*#.*$)', '') ; Strip directives. By guinness.
EndFunc   ;==>_StripDirectives

Func _StripEmptyLines(ByRef $sData)
	$sData = StringRegExpReplace($sData, '(?m:^\h*\R)', '') ; Empty lines. By guinness.
EndFunc   ;==>_StripEmptyLines

Func _StringRegExpExpand($sString)
	Return StringRegExpReplace($sString, '([$\\])', '\\\1')
EndFunc   ;==>_StringRegExpExpand

Func _StripForVariables(ByRef $sData)
	Local Const $aFileRead = StringSplit($sData, @CRLF, 1)
	Local $aReturn[$aFileRead[0] + 1], $iIndex = 0
	For $i = 1 To $aFileRead[0]
		Select
			Case StringRegExp($aFileRead[$i], '(?i)^For\h+\$\w+') = 1
				If $iIndex = 0 Then
					$aReturn[0] += 1
					$iIndex += 1
				Else
					$iIndex += 1
				EndIf
				$aReturn[$aReturn[0]] &= $aFileRead[$i] & @CRLF
			Case StringRegExp($aFileRead[$i], '(?i)^Next\h*') = 1
				$iIndex -= 1
				$aReturn[$aReturn[0]] &= $aFileRead[$i] & @CRLF
			Case $iIndex > 0
				$aReturn[$aReturn[0]] &= $aFileRead[$i] & @CRLF
		EndSelect
	Next
	ReDim $aReturn[$aReturn[0] + 1]
	Local $aArray = 0, $sReplace = ''
	For $i = 1 To $aReturn[0]
		$aArray = StringRegExp('For $i = 0' & @CRLF & $aReturn[$i], '(?im:^For\h+\$)(\w+)', 3)
		$aArray[0] = UBound($aArray) - 1
		$sReplace = $aReturn[$i]
		For $j = 1 To $aArray[0]
			$sReplace = StringRegExpReplace($sReplace, '\$\b' & $aArray[$j] & '\b', '0')
		Next
		$sData = StringReplace($sData, $aReturn[$i], $sReplace)
	Next
EndFunc   ;==>_StripForVariables

Func _StripFunctions(ByRef $sData)
	$sData = StringRegExpReplace($sData, '(?ims:^Func(?=\h).*?(?<=\r|\n|\r\n)EndFunc(?=\s)[^\r\n]*\R?)', '') ; Strip functions. By guinness.
EndFunc   ;==>_StripFunctions

Func _StripFunctionsEnd(ByRef $sData)
	$sData = StringRegExpReplace($sData, '(?im:^EndFunc(?!\w)[^\r\n]+)', 'EndFunc') ; EndFunc comment lines. By guinness.
EndFunc   ;==>_StripFunctionsEnd

Func _StripFunctionsNested(ByRef $sData)
	Do
		$sData = StringRegExpReplace($sData, '\([^()]*?\)', '') ; Remove functions. By AZJIO.
	Until @extended = 0
EndFunc   ;==>_StripFunctionsNested

Func _StripFunctionsOutside(ByRef $sData)
	$sData = StringRegExpReplace($sData, '(?im:^(?!Func|EndFunc)[^\r\n]+)', '') ; Strip content not Func or EndFunc. By guinness.
EndFunc   ;==>_StripFunctionsOutside

Func _StripMerge(ByRef $sData)
	$sData = StringRegExpReplace($sData, '(?:_\h*\R\h*)', '') ; Merge continuation lines that use _. By guinness.
EndFunc   ;==>_StripMerge

Func _StripStringLiterals(ByRef $sData)
	$sData = StringRegExpReplace($sData, '([''"])\V*?\1', '') ; Strip string literals. By PhoenixXL & guinness.
EndFunc   ;==>_StripStringLiterals

Func _StripWhitespace(ByRef $sData)
	$sData = StringRegExpReplace($sData, '\h+(?=\R)', '') ; Trailing whitespace. By DXRW4E.
	$sData = StringRegExpReplace($sData, '\R\h+', @CRLF) ; Strip leading whitespace. By DXRW4E.
EndFunc   ;==>_StripWhitespace

Func _Toggle_CheckOrUnCheck($iControlID, $fOverride = Default)
	If $fOverride = Default Then
		$fOverride = Not (BitAND(GUICtrlGetState($iControlID), $GUI_CHECKED) = $GUI_CHECKED)
	EndIf
	GUICtrlSetState($iControlID, $fOverride ? $GUI_CHECKED : $GUI_UNCHECKED)
EndFunc   ;==>_Toggle_CheckOrUnCheck

Func IsNullOrEmpty($vValue)
	$vValue = String($vValue)
	Return StringStripWS($vValue, $STR_STRIPALL) = '' Or $vValue == '0'
EndFunc   ;==>IsNullOrEmpty
