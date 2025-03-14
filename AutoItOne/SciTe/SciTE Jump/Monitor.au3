#AutoIt3Wrapper_Au3Check_Parameters=-d -w 1 -w 2 -w 3 -w- 4 -w 5 -w 6 -w 7
#cs
	Program Created By:							SoftwareSpot
	Last Textual Changes In This Script:		9th February 2014
	The Program Can Be Run By Selecting: 		<Monitor.a3x>

	License:
	Internal program to monitor the position of SciTE when SciTE Jump is docked and renaming in files.
	Copyright (C) 2011-2014 SoftwareSpot

	This program is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
	GNU General Public License for more details.
#ce
#NoTrayIcon

#AutoIt3Wrapper_Outfile=Monitor.a3x
#AutoIt3Wrapper_Run_Au3Stripper=Y
#Au3Stripper_Parameters=/SO /RM /MI=99
#AutoIt3Wrapper_Outfile_Type=a3x
#AutoIt3Wrapper_Run_After=del "%SCRIPTDIR%\%SCRIPTFILE%_stripped.au3"

#include 'Includes\_Functions.au3' ; By SoftwareSpot.

Global Enum $__hGUIMonitor, $__iGUISciTEChange, $__iGUIMax
Global $__vGUIAPI[$__iGUIMax] ; SciTE related array.

Global Enum $__sExitFilePath, $__iExitMax
Global $__vExitAPI[$__iExitMax] ; Exit related array.

_SetLanguagePath(@WorkingDir)

If $CmdLine[0] Then
	_SciTE_Startup()

	Switch StringTrimLeft($CmdLine[1], StringLen('\'))
		Case 'MonitorRename'
			_WM_COPYDATA_SetID('MonitorRename_SciTE_Jump_A17DA5D6-487D-11E3-B453-DE83E5AF4BA6')
			AutoItWinSetTitle(_WM_COPYDATA_GetID()) ; Set the window title manually.
			_Monitor_Rename($CmdLine[2])

		Case 'MonitorRun'
			_SciTE_SetResponseGUI(HWnd($CmdLine[2]))
			_WM_COPYDATA_SetID('MonitorRun_SciTE_Jump_A17DA5D6-487D-11E3-B453-DE83E5AF4BA6')
			_Monitor_Run()

		Case 'MonitorFileInfo'
			_WM_COPYDATA_SetID('MonitorFileInfo_SciTE_Jump_A17DA5D6-487D-11E3-B453-DE83E5AF4BA6')
			_Monitor_FileInfo($CmdLine[2])
	EndSwitch
EndIf

#Region MonitorFileInfo Functions
Func _Monitor_FileInfo($sData)
	Local Enum $eFilePath, $eFunctionList
	Local $aArray = StringRegExp($sData, '<filepath>([^<]+)</filepath><functionlist>([^<]*)</functionlist>', 3)
	If @error Or Not (UBound($aArray) = 2) Then
		Return False
	EndIf
	$sData = _GetFile($aArray[$eFilePath])
	Local $aFunctions = 0
	_GetFunctionInfo($sData, $aFunctions)

	Return _SetFile(_GetFileInfo($aFunctions, $sData, $aArray[$eFilePath]), $aArray[$eFunctionList])
EndFunc   ;==>_Monitor_FileInfo
#EndRegion MonitorFileInfo Functions

#Region MonitorRename Functions
Func _Monitor_Rename($sData)
	Local Enum $eFilePath, $eBeforeString, $eAfterString, $eFileExtensions, $eReplaceString, $eCaseSensitive, $eRegularExpression
	Local $aArray = StringRegExp($sData, '<filepath>([^<]+)</filepath><beforestring>([^<]*)</beforestring><afterstring>([^<]*)</afterstring>' & _
			'<fileextensions>([^<]*)</fileextensions><[a-z]+>(\d)</[a-z]+><[a-z]+>(\d)</[a-z]+><[a-z]+>(\d)</[a-z]+>', 3)
	If @error Or Not (UBound($aArray) = 7) Then
		Return False
	EndIf

	$__vExitAPI[$__sExitFilePath] = $aArray[$eFilePath]
	OnAutoItExitRegister('_Exit')

	Local Const $bReplace = Int($aArray[$eReplaceString]) = 1
	Local Const $iCaseSensitive = Int($aArray[$eCaseSensitive])
	Local Const $bRegularExpression = Int($aArray[$eRegularExpression]) = 1

	Local $iExtended = 0, $iFileEncoding = 0, $sRead = '', $sReturn = ''
	Local $aSearch = StringRegExp(@ScriptFullPath & '|' & @CRLF & _GetFile($aArray[$eFilePath]), '([^|]+)\|(\d+)?\|?\R', 3)
	If @error Then
		_SetFile('', $aArray[$eFilePath], $FO_APPEND) ; Erase the file.
		Return False
	EndIf

	$aSearch[0] = UBound($aSearch) - 1
	For $i = 1 To $aSearch[0]
		If _IsReadOnly($aSearch[$i]) Or _IsValidFileType($aSearch[$i], $aArray[$eFileExtensions]) = 0 Then
			ContinueLoop
		EndIf
		$sRead = _GetFile($aSearch[$i])
		If @error Then
			ContinueLoop
		EndIf

		If $bRegularExpression Then
			$sRead = StringRegExpReplace($sRead, $aArray[$eBeforeString], $aArray[$eAfterString])
			$iExtended = @extended
		Else
			$sRead = StringReplace($sRead, $aArray[$eBeforeString], $aArray[$eAfterString], 0, $iCaseSensitive)
			$iExtended = @extended
		EndIf
		If $iExtended > 0 Then
			$sReturn &= $aSearch[$i] & '|' & $iExtended & '|' & @CRLF
			If $bReplace Then
				$iFileEncoding = FileGetEncoding($aSearch[$i])
				_SetFile($sRead, $aSearch[$i], $iFileEncoding + $FO_APPEND)
			EndIf
		EndIf
		$sRead = '' ; Clear variable data.
	Next
	OnAutoItExitUnRegister('_Exit')

	_SetFile($sReturn, $aArray[$eFilePath], $FO_APPEND)
	Return True
EndFunc   ;==>_Monitor_Rename
#EndRegion MonitorRename Functions

#Region MonitorRun Functions
Func _Monitor_Run()
	Local $bIsContinue = False, _
			$sScriptDir = @WorkingDir

	Local Const $iWM_COPYDATA = _WM_COPYDATA_Start(Default) ; Start the communication process.
	If @error = 0 Then
		OnAutoItExitRegister('_Exit')

		$__vGUIAPI[$__hGUIMonitor] = _WM_COPYDATA_Start(Default, False)
		GUIRegisterMsg(_WinAPI_RegisterWindowMessage('SHELLHOOK'), 'WM_SHELLHOOK')
		_WinAPI_RegisterShellHookWindow($__vGUIAPI[$__hGUIMonitor])

		$__vGUIAPI[$__iGUISciTEChange] = GUICtrlCreateDummy()

		Local $bIsDockRight = _GetDockState($sScriptDir & '\Settings.ini'), _
				$bIsFunctionToLine = _Is('MonitorLine', 0, Default, $sScriptDir) = 1, _
				$hTimer = 0, _
				$iPos_1 = 0, $iPos_2 = 0, _
				$sAu3Script = _SciTE_GetCurrentFile(), $sFunction = '', _
				$iAu3Size = FileGetSize($sAu3Script), _
				$vDummyValue = 0
		If $bIsFunctionToLine Then
			$__vFunctionLines = _FunctionToLine($sAu3Script)
		EndIf

		Local Const $hResponseGUI = _SciTE_GetResponseGUI(), $hSciTEGUI = _SciTE_WinGetSciTE()
		While 1
			If $bIsContinue Then
				If Not _DockToWindow($hSciTEGUI, $hResponseGUI, $iPos_1, $iPos_2, $bIsDockRight, 0) Then
					ExitLoop
				EndIf
			EndIf

			If TimerDiff($hTimer) > 1500 Then
				$vDummyValue = _SciTE_GetCurrentFile()
				If Not ($vDummyValue = $sAu3Script) Or Not (FileGetSize($vDummyValue) = $iAu3Size) Then
					GUICtrlSendToDummy($__vGUIAPI[$__iGUISciTEChange])
				Else
					If $bIsFunctionToLine Then
						$vDummyValue = _FunctionToLineMonitor()
						If @error = 0 And Not ($vDummyValue = $sFunction) And Not _IsActive($hResponseGUI) Then
							$sFunction = $vDummyValue
							_SciTE_Send_Command(0, $hResponseGUI, 'FunctionToLine:' & $sFunction)
						EndIf
					EndIf
				EndIf
				$hTimer = TimerInit()
			EndIf

			Switch GUIGetMsg()
				Case $GUI_EVENT_CLOSE
					ExitLoop

				Case $__vGUIAPI[$__iGUISciTEChange]
					If ProcessExists('AutoIt3Wrapper.exe') Then Sleep(120) ; Workaround for SciTE Jump taking focus too quickly.
					_SciTE_Send_Command(0, $hResponseGUI, 'Monitor_Refresh')
					$sAu3Script = _SciTE_GetCurrentFile()
					$iAu3Size = FileGetSize($sAu3Script)
					If $bIsFunctionToLine Then
						$__vFunctionLines = _FunctionToLine($sAu3Script)
					EndIf

				Case $iWM_COPYDATA ; If the WM_COPYDATA message is interecepted then parse the command that was passed.
					Switch _SciTE_ParseReturnString(_WM_COPYDATA_GetData(), 2)
						Case 'Monitor_Exit'
							ExitLoop

						Case 'Monitor_Continue'
							$bIsContinue = True

						Case 'Monitor_Pause'
							$bIsContinue = False

						Case 'Monitor_Refresh'
							_SciTE_Startup()
							$sAu3Script = _SciTE_GetCurrentFile()
							$iAu3Size = FileGetSize($sAu3Script)
							If $bIsFunctionToLine Then
								$__vFunctionLines = _FunctionToLine($sAu3Script)
							EndIf

						Case 'Monitor_SettingsChange'
							_SciTE_Startup()
							$bIsDockRight = _GetDockState($sScriptDir & '\Settings.ini')
							$bIsFunctionToLine = _Is('MonitorLine', 0, Default, $sScriptDir) = 1
							$sAu3Script = _SciTE_GetCurrentFile()
							If $bIsFunctionToLine Then
								$__vFunctionLines = _FunctionToLine($sAu3Script)
							EndIf

					EndSwitch
			EndSwitch
		WEnd
		OnAutoItExitUnRegister('_Exit')

		_WinAPI_DeregisterShellHookWindow($__vGUIAPI[$__hGUIMonitor])
		$__vGUIAPI[$__hGUIMonitor] = 0
	EndIf
	_WM_COPYDATA_Shutdown()
EndFunc   ;==>_Monitor_Run

Func WM_SHELLHOOK($hWnd, $iMsg, $wParam, $lParam)
	#forceref $iMsg
	Local Static $iCount = -1
	If $hWnd = $__vGUIAPI[$__hGUIMonitor] Then
		If $lParam = _SciTE_WinGetSciTE() Then
			$iCount += 1 ; Workaround.
			Switch $wParam
				Case $HSHELL_REDRAW
					If $iCount Then
						GUICtrlSendToDummy($__vGUIAPI[$__iGUISciTEChange])
					EndIf

				Case $HSHELL_WINDOWDESTROYED
					If $iCount Then
						WinClose( _SciTE_GetResponseGUI())
					EndIf

			EndSwitch
			If $iCount Then
				$iCount = -1
			EndIf
		EndIf
	EndIf
EndFunc   ;==>WM_SHELLHOOK
#EndRegion MonitorRun Functions

Func _Exit()
	If $CmdLine[0] Then
		Switch StringTrimLeft($CmdLine[1], StringLen('\'))
			Case 'MonitorRename'
				If FileExists($__vExitAPI[$__sExitFilePath]) Then
					_SetFile('', $__vExitAPI[$__sExitFilePath], $FO_APPEND) ; Erase the file.
				EndIf

			Case 'MonitorRun'
				If $__vGUIAPI[$__hGUIMonitor] Then
					_WinAPI_RegisterShellHookWindow($__vGUIAPI[$__hGUIMonitor])
				EndIf
				_WM_COPYDATA_Shutdown()

			Case 'MonitorFileInfo'
		EndSwitch
		_SciTE_Shutdown()
	EndIf
	Exit
EndFunc   ;==>_Exit
