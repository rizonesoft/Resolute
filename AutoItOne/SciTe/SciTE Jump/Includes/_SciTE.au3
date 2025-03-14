#include-once
#include <String.au3>
#include <WinAPIEx.au3>

#include '_Functions.au3' ; By SoftwareSpot.
#include '_SciTE_Send_Command.au3' ; By SoftwareSpot.
#include 'WM_COPYDATA.au3' ; By SoftwareSpot.

Global Enum $__hSciTEResponseGUI, $__hSciTEHandle, $__hSciTEDirector, $__hSciTEWindow, $__hSciTEEdit, $__iSciTEMax
Global $__vSciTEAPI[$__iSciTEMax] ; SciTE related array.

#cs
	Local Const $SCI_SETSELECTIONSTART = 2142, _
	$SCI_GETSELECTIONSTART = 2143, _
	$SCI_SETSELECTIONEND = 2144 _
	$SCI_GETSELECTIONEND = 2145

	MsgBox($MB_SYSTEMMODAL, $__vSciTEAPI[$__hSciTEEdit], _SciTE_GetLineFromPosition(_SendMessage($__vSciTEAPI[$__hSciTEEdit], $SCI_GETSELECTIONSTART)) & @CRLF & _
	_SciTE_GetLineFromPosition(_SendMessage($__vSciTEAPI[$__hSciTEEdit], $SCI_GETSELECTIONEND)))
#ce

Func _SciTE_AskProperty($sString)
	_SciTE_Send_Command($__vSciTEAPI[$__hSciTEResponseGUI], $__vSciTEAPI[$__hSciTEDirector], 'askproperty:' & $sString)
	Return _SciTE_ParseReturnString(_SciTE_ReturnString(), 4)
EndFunc   ;==>_SciTE_AskProperty

Func _SciTE_ChangeWorkingDirectory($sFilePath)
	Return _SciTE_Send_Command(0, $__vSciTEAPI[$__hSciTEDirector], 'cwd:' & StringReplace($sFilePath, '\', '\\'))
EndFunc   ;==>_SciTE_ChangeWorkingDirectory

Func _SciTE_ExportToHTML($sFilePath)
	If FileExists($sFilePath) Then
		$sFilePath = _WinAPI_PathRemoveExtension($sFilePath) & '.html'
		_SciTE_Send_Command(0, $__vSciTEAPI[$__hSciTEDirector], 'exportashtml:' & StringReplace($sFilePath, '\', '\\'))
	Else
		$sFilePath = ''
	EndIf
	Return SetError(FileExists($sFilePath) = 0, 0, $sFilePath)
EndFunc   ;==>_SciTE_ExportToHTML

Func _SciTE_ExportToLatex($sFilePath)
	If FileExists($sFilePath) Then
		$sFilePath = _WinAPI_PathRemoveExtension($sFilePath) & '.latex'
		_SciTE_Send_Command(0, $__vSciTEAPI[$__hSciTEDirector], 'exportaslatex:' & StringReplace($sFilePath, '\', '\\'))
	Else
		$sFilePath = ''
	EndIf
	Return SetError(FileExists($sFilePath) = 0, 0, $sFilePath)
EndFunc   ;==>_SciTE_ExportToLatex

Func _SciTE_ExportToPDF($sFilePath)
	If FileExists($sFilePath) Then
		$sFilePath = _WinAPI_PathRemoveExtension($sFilePath) & '.pdf'
		_SciTE_Send_Command(0, $__vSciTEAPI[$__hSciTEDirector], 'exportaspdf:' & StringReplace($sFilePath, '\', '\\'))
	Else
		$sFilePath = ''
	EndIf
	Return SetError(FileExists($sFilePath) = 0, 0, $sFilePath)
EndFunc   ;==>_SciTE_ExportToPDF

Func _SciTE_ExportToRTF($sFilePath)
	If FileExists($sFilePath) Then
		$sFilePath = _WinAPI_PathRemoveExtension($sFilePath) & '.rtf'
		_SciTE_Send_Command(0, $__vSciTEAPI[$__hSciTEDirector], 'exportasrtf:' & StringReplace($sFilePath, '\', '\\'))
	Else
		$sFilePath = ''
	EndIf
	Return SetError(FileExists($sFilePath) = 0, 0, $sFilePath)
EndFunc   ;==>_SciTE_ExportToRTF

Func _SciTE_ExportToXML($sFilePath)
	If FileExists($sFilePath) Then
		$sFilePath = _WinAPI_PathRemoveExtension($sFilePath) & '.xml'
		_SciTE_Send_Command(0, $__vSciTEAPI[$__hSciTEDirector], 'exportasxml:' & StringReplace($sFilePath, '\', '\\'))
	Else
		$sFilePath = ''
	EndIf
	Return SetError(FileExists($sFilePath) = 0, 0, $sFilePath)
EndFunc   ;==>_SciTE_ExportToXML

Func _SciTE_Find($sString, $sAdd = '')
	_SciTE_GoToLine(1) ; Workaround for starting from the beginning of the script.
	Return _SciTE_Send_Command(0, $__vSciTEAPI[$__hSciTEDirector], 'find:' & StringReplace($sString, '\', '\\') & $sAdd)
EndFunc   ;==>_SciTE_Find

Func _SciTE_GetFirstVisibleLine()
	Local Const $SCI_GETFIRSTVISIBLELINE = 2152
	Return _SendMessage($__vSciTEAPI[$__hSciTEEdit], $SCI_GETFIRSTVISIBLELINE)
EndFunc   ;==>_SciTE_GetFirstVisibleLine

Func _SciTE_GetCurrentFile()
	Local Const $sTitle = WinGetTitle($__vSciTEAPI[$__hSciTEWindow])
	If @error Then ; No Window
		Return SetError(1, 0, '')
	EndIf
	If _IsEmpty($sTitle) Then ; New File.
		Return SetError(3, 0, '')
	EndIf
	Local Const $sFilePath = StringRegExpReplace($sTitle, '^(\V+)(?:\h[-*]\V+)$', '\1')
	If FileExists($sFilePath) Then
		If _IsValidFileType($sFilePath, 'au3') Then
			Return $sFilePath
		Else
			Return SetError(4, 0, '') ; File Is Not Supported.
		EndIf
	EndIf
	Return SetError(2, 0, '') ; File Does Not Exist.
EndFunc   ;==>_SciTE_GetCurrentFile

Func _SciTE_GetCurrentPosition()
	Local Const $SCI_GETCURRENTPOS = 2008
	Return _SendMessage($__vSciTEAPI[$__hSciTEEdit], $SCI_GETCURRENTPOS)
EndFunc   ;==>_SciTE_GetCurrentPosition

Func _SciTE_GetFullPathProperty($sSciTEDirectory)
	Local $aReturn = StringRegExp(_GetFile($sSciTEDirectory & '\SciTEUser.properties'), '(?im)^\h*title\.full\.path=(\d)', 3)
	If @error Then
		$aReturn = StringRegExp(_GetFile($sSciTEDirectory & '\SciTEGlobal.properties'), '(?im)^\h*title\.full\.path=(\d)', 3)
		If @error Then
			Local Const $aError[1] = [0]
			$aReturn = $aError
		EndIf
	EndIf
	Return (Int($aReturn[0]) = 0)
EndFunc   ;==>_SciTE_GetFullPathProperty

Func _SciTE_GetLineCount()
	Local Const $SCI_GETLINECOUNT = 2154
	Return _SendMessage($__vSciTEAPI[$__hSciTEEdit], $SCI_GETLINECOUNT) ; ControlCommand($__vSciTEAPI[$__hSciTEWindow], '', '[CLASS:Scintilla; INSTANCE:1]', 'GetLineCount', '')
EndFunc   ;==>_SciTE_GetLineCount

Func _SciTE_GetLineFromPosition($iLineNumber)
	Local Const $SCI_LINEFROMPOSITION = 2166
	Return _SendMessage($__vSciTEAPI[$__hSciTEEdit], $SCI_LINEFROMPOSITION, $iLineNumber)
EndFunc   ;==>_SciTE_GetLineFromPosition

Func _SciTE_GetPositionFromLine($iLineNumber)
	Local Const $SCI_POSITIONFROMLINE = 2167
	Return _SendMessage($__vSciTEAPI[$__hSciTEEdit], $SCI_POSITIONFROMLINE, $iLineNumber)
EndFunc   ;==>_SciTE_GetPositionFromLine

Func _SciTE_GetResponseGUI()
	Return $__vSciTEAPI[$__hSciTEResponseGUI]
EndFunc   ;==>_SciTE_GetResponseGUI

Func _SciTE_GetSelectedLineNumber()
	Return _SciTE_GetLineFromPosition(_SciTE_GetCurrentPosition())
EndFunc   ;==>_SciTE_GetSelectedLineNumber

Func _SciTE_GetSelectionStartLine()
	Local Const $SCI_DOCUMENTSTART = 2316
	Return _SendMessage($__vSciTEAPI[$__hSciTEEdit], $SCI_DOCUMENTSTART) ; _SciTE_AskProperty('SelectionStartLine')
EndFunc   ;==>_SciTE_GetSelectionStartLine

Func _SciTE_GetText() ; Thanks To Jos: http://www.autoitscript.com/forum/topic/130437-new-scite4autoit3-available-with-scite-v227/page__view__findpost__p__907702
	Return ControlGetText($__vSciTEAPI[$__hSciTEWindow], '', '[CLASS:Scintilla; INSTANCE:1]') ; v3.3.9.11+
	#cs
		Local $sReturn = ''
		If Int(StringRegExpReplace(@AutoItVersion, '\D', '')) >= 33911 Then
		$sReturn = ControlGetText($__vSciTEAPI[$__hSciTEWindow], '', '[CLASS:Scintilla; INSTANCE:1]') ; v3.3.9.11+
		Else
		$sReturn = StringToBinary(ControlGetText($__vSciTEAPI[$__hSciTEWindow], '', '[CLASS:Scintilla; INSTANCE:1]'), 2)
		; Translate Back To ANSI Text
		$sReturn = BinaryToString($sReturn, 1)
		; Strip Ending 00 Plus Extra Characters.
		$sReturn = String($sReturn)
		EndIf
		Return $sReturn
	#ce
EndFunc   ;==>_SciTE_GetText

Func _SciTE_GetUDFCreator($sSciTEDirectory)
	Local Const $aError[1] = ['Your Name'], _
			$sSciTEProperties = $sSciTEDirectory & '\properties\au3.properties', $sSciTEUserProperties = $sSciTEDirectory & '\SciTEUser.properties'
	Local $sData = _GetFile($sSciTEUserProperties)
	Local $aReturn = StringRegExp($sData, '(?im)^UDFCreator=(\V*)', 3)
	If @error Then
		$sData = _GetFile($sSciTEProperties)
		$aReturn = StringRegExp($sData, '(?im)^UDFCreator=(\V*)', 3)
		If @error Then
			$aReturn = $aError
		EndIf
	EndIf
	Return $aReturn[0]
EndFunc   ;==>_SciTE_GetUDFCreator

Func _SciTE_GetVisibleFromDocLine($iLineNumber)
	Local Const $SCI_VISIBLEFROMDOCLINE = 2220
	Return _SendMessage($__vSciTEAPI[$__hSciTEEdit], $SCI_VISIBLEFROMDOCLINE, $iLineNumber)
EndFunc   ;==>_SciTE_GetVisibleFromDocLine

Func _SciTE_GoToLine($iLineNumber)
	Local Const $SCI_GOTOLINE = 2024
	Return _SendMessage($__vSciTEAPI[$__hSciTEEdit], $SCI_GOTOLINE, $iLineNumber) ; _SciTE_Send_Command(0, $__vSciTEAPI[$__hSciTEDirector], 'goto:' & $iLineNumber)
EndFunc   ;==>_SciTE_GoToLine

Func _SciTE_LinesOnScreen()
	Local Const $SCI_LINESONSCREEN = 2370
	Return _SendMessage($__vSciTEAPI[$__hSciTEEdit], $SCI_LINESONSCREEN)
EndFunc   ;==>_SciTE_LinesOnScreen

Func _SciTE_IsActive()
	Return WinExists($__vSciTEAPI[$__hSciTEDirector]) = 1
EndFunc   ;==>_SciTE_IsActive

Func _SciTE_LoadSession($sFilePath)
	Return _SciTE_Send_Command(0, $__vSciTEAPI[$__hSciTEDirector], 'loadsession:' & StringReplace($sFilePath, '\', '\\'))
EndFunc   ;==>_SciTE_LoadSession

Func _SciTE_Open($sFilePath)
	Return _SciTE_Send_Command(0, $__vSciTEAPI[$__hSciTEDirector], 'open:' & StringReplace($sFilePath, '\', '\\'))
EndFunc   ;==>_SciTE_Open

Func _SciTE_ParseReturnString($sString, $iCount = 3)
	Return StringTrimLeft($sString, StringInStr($sString, ':', Default, $iCount)) ; By Xenobiologist. OR StringRegExpReplace($sString, '(?::\d+:macro:stringinfo:)', '')
EndFunc   ;==>_SciTE_ParseReturnString

Func _SciTE_Quit()
	Return _SciTE_Send_Command(0, $__vSciTEAPI[$__hSciTEDirector], 'quit:')
EndFunc   ;==>_SciTE_Quit

Func _SciTE_ReloadProperties()
	Return _SciTE_Send_Command(0, $__vSciTEAPI[$__hSciTEDirector], 'reloadproperties:')
EndFunc   ;==>_SciTE_ReloadProperties

Func _SciTE_ReturnString()
	Return _WM_COPYDATA_GetData()
EndFunc   ;==>_SciTE_ReturnString

Func _SciTE_Save($sFilePath)
	Return _SciTE_Send_Command(0, $__vSciTEAPI[$__hSciTEDirector], 'saveas:' & StringReplace($sFilePath, '\', '\\'))
EndFunc   ;==>_SciTE_Save

Func _SciTE_SaveSession($sFilePath)
	Return _SciTE_Send_Command(0, $__vSciTEAPI[$__hSciTEDirector], 'savesession:' & StringReplace($sFilePath, '\', '\\'))
EndFunc   ;==>_SciTE_SaveSession

Func _SciTE_SetCaretLineVisible($fState) ; <<<<< Set the caret as visible.
	Local Const $SCI_SETCARETLINEVISIBLE = 2096
	Return _SendMessage($__vSciTEAPI[$__hSciTEEdit], $SCI_SETCARETLINEVISIBLE, $fState)
EndFunc   ;==>_SciTE_SetCaretLineVisible

Func _SciTE_SetFirstVisibleLine($iLineNumber)
	Local Const $SCI_SETFIRSTVISIBLELINE = 2613
	Return _SendMessage($__vSciTEAPI[$__hSciTEEdit], $SCI_SETFIRSTVISIBLELINE, $iLineNumber)
EndFunc   ;==>_SciTE_SetFirstVisibleLine

Func _SciTE_SetFullPathProperty($sSciTEDirectory)
	Local Const $sSciTEUserProperties = $sSciTEDirectory & '\SciTEUser.properties'
	Local $sData = _GetFile($sSciTEUserProperties)
	$sData = StringRegExpReplace($sData, '(?im)^(\h*title\.full\.path=)(?:\d)', '${1}1')
	If @extended Then
		_SetFile($sData, $sSciTEUserProperties, $FO_APPEND)
	Else
		_SetFile($sData & @CRLF & 'title.full.path=1' & @CRLF, $sSciTEUserProperties, $FO_APPEND)
	EndIf
	Return SetError(@error, 0, 0)
EndFunc   ;==>_SciTE_SetFullPathProperty

Func _SciTE_SetResponseGUI($hGUI)
	$__vSciTEAPI[$__hSciTEResponseGUI] = $hGUI
EndFunc   ;==>_SciTE_SetResponseGUI

Func _SciTE_SettingsDir(ByRef $sProgramSettings, $sAppendDir, ByRef $sSciTESettings, $iLevel = Default)
	Local $sLevel = ''
	If $iLevel = Default Then
		$iLevel = 1
	EndIf
	If $iLevel Then
		$sLevel = _StringRepeat('\..', $iLevel)
	EndIf
	If $sAppendDir = Default Then
		$sAppendDir = ''
	EndIf
	If $sAppendDir Then
		$sAppendDir = '\' & $sAppendDir
	EndIf
	; Idea provided by Jos as how he does it in AutoItWrapper.
	Local Const $sSciTE_UserHome = EnvGet('SciTE_USERHOME'), _
			$sSciTE_Home = EnvGet('SciTE_HOME')
	If $sSciTE_UserHome Then
		$sProgramSettings = $sSciTE_UserHome & $sAppendDir
		$sSciTESettings = $sSciTE_UserHome
	ElseIf $sSciTE_Home Then
		$sProgramSettings = $sSciTE_Home & $sAppendDir
		$sSciTESettings = $sSciTE_Home
	Else
		$sProgramSettings = @ScriptDir
		$sSciTESettings = _GetFullPath($sProgramSettings & $sLevel)
	EndIf
EndFunc   ;==>_SciTE_SettingsDir

Func _SciTE_SetUDFCreator($sSciTEDirectory, $sUserName)
	Local Const $sSciTEUserProperties = $sSciTEDirectory & '\SciTEUser.properties'
	Local $sData = _GetFile($sSciTEUserProperties)
	$sData = StringRegExpReplace($sData, '(?im)^UDFCreator=(\V*)', 'UDFCreator=' & $sUserName & @CRLF)
	If @extended Then
		_SetFile($sData, $sSciTEUserProperties, $FO_APPEND)
	Else
		_SetFile($sData & @CRLF & 'UDFCreator=' & $sUserName & @CRLF, $sSciTEUserProperties, $FO_APPEND)
	EndIf
	Return SetError(@error, 0, 0)
EndFunc   ;==>_SciTE_SetUDFCreator

Func _SciTE_Shutdown()
	$__vSciTEAPI[$__hSciTEDirector] = -1
	$__vSciTEAPI[$__hSciTEEdit] = -1
	$__vSciTEAPI[$__hSciTEWindow] = -1
EndFunc   ;==>_SciTE_Shutdown

Func _SciTE_Startup()
	_SciTE_Shutdown()
	$__vSciTEAPI[$__hSciTEDirector] = WinGetHandle('DirectorExtension')
	If $__vSciTEAPI[$__hSciTEDirector] = '' Then
		$__vSciTEAPI[$__hSciTEDirector] = -9999
	EndIf
	$__vSciTEAPI[$__hSciTEWindow] = WinGetHandle('[CLASS:SciTEWindow]')
	$__vSciTEAPI[$__hSciTEEdit] = ControlGetHandle($__vSciTEAPI[$__hSciTEWindow], '', '[CLASS:Scintilla; INSTANCE:1]')
EndFunc   ;==>_SciTE_Startup

Func _SciTE_ToggleFold($iLineNumber)
	Local Const $SCI_TOGGLEFOLD = 2231
	Return _SendMessage($__vSciTEAPI[$__hSciTEEdit], $SCI_TOGGLEFOLD, $iLineNumber)
EndFunc   ;==>_SciTE_ToggleFold

Func _SciTE_WinGetEdit()
	Return $__vSciTEAPI[$__hSciTEEdit]
EndFunc   ;==>_SciTE_WinGetEdit

Func _SciTE_WinGetEditId()
	Return '[CLASS:Scintilla; INSTANCE:1]'
EndFunc   ;==>_SciTE_WinGetEditId

Func _SciTE_WinGetDirector()
	Return $__vSciTEAPI[$__hSciTEDirector]
EndFunc   ;==>_SciTE_WinGetDirector

Func _SciTE_WinGetSciTE()
	Return $__vSciTEAPI[$__hSciTEWindow]
EndFunc   ;==>_SciTE_WinGetSciTE
