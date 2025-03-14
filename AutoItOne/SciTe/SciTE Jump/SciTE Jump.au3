#AutoIt3Wrapper_Au3Check_Parameters=-d -w 1 -w 2 -w 3 -w- 4 -w 5 -w 6 -w 7
#cs
	Program Created By:							SoftwareSpot
	Last Textual Changes In This Script:		15th July 2014
	The Program Can Be Run By Selecting: 		<SciTE Jump.exe>

	Thanks To The Following...

	Icon --> http://icons.mysitemyway.com/category/yellow-road-sign-icons/
	Help --> http://www.scintilla.org/SciTEDirector.html & http://www.scintilla.org/ScintillaDoc.html (Scintilla.h)
	Additional --> Based on idea's from...
	Ashalshaikh: http://www.autoitscript.com/forum/topic/119544-scite-Jump-01-jump-to-any-line-by-one-click/
	Melba23: http://www.autoitscript.com/forum/topic/109558-new-scite4autoit3-available-with-scite-v179/page__view__findpost__p__901838

	License:
	Quickly navigate between functions and regions in an AutoIt script.
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

#pragma compile(Icon, Bin\ICON_1.ico)
#pragma compile(UPX, False)
#pragma compile(FileDescription, Quickly navigate between functions and regions in an AutoIt script.)
#pragma compile(FileVersion, 2.19.103.245)
#pragma compile(LegalCopyright, SoftwareSpot (C) 2011-2014)
; #pragma compile(x64, True)
#pragma compile(Comments, 'Comment at the website')
#pragma compile(ExecLevel, asInvoker)
#pragma compile(AutoItExecuteAllowed, True)

#AutoIt3Wrapper_Outfile=SciTE Jump.exe
#AutoIt3Wrapper_Res_Language=2057
#AutoIt3Wrapper_Run_Au3Stripper=Y
#Au3Stripper_Parameters=/SO /RM /MI=99
#AutoIt3Wrapper_Outfile_Type=exe
#AutoIt3Wrapper_Compile_Both=Y
#AutoIt3Wrapper_Run_After=del "%SCRIPTDIR%\%SCRIPTFILE%_stripped.au3"

#include <Constants.au3>
#include <GUIButton.au3>
#include <GUIComboBoxEx.au3>
#include <GUIEdit.au3>
#include <GUIListView.au3>
#include <GUIMenu.au3>
#include <GUITab.au3>
#include <GUITreeView.au3>
#include <ProgressConstants.au3>

#include 'Includes\_CRC32ForFile.au3' ; By SoftwareSpot.
#include 'Includes\_Functions.au3' ; By SoftwareSpot.
#include 'Includes\_GUIDisable.au3' ; By SoftwareSpot.
#include 'Includes\_SciTE.au3' ; By SoftwareSpot.
#include 'Includes\WM_COPYDATA.au3' ; By SoftwareSpot.

_SetVariables()
Global Const $__sScriptDir = _GetInstalledSettingsDir() ; If AutoIt & SciTE are installed then use the application directory instead.

_SciTE_Startup()

_INIUnicode($__sScriptDir & '\Settings.ini')
_SetLanguagePath($__sScriptDir)

_IsRestarted() ; Check the application wasn't restarted.
_IsX64() ; Run the x64 version of SciTE Jump.

If Not _SciTE_IsActive() Then
	$__vSciTEAPI[$__hSciTEResponseGUI] = _GetFullPath(IniRead($__sScriptDir & '\Settings.ini', 'General', 'SciTE', ''), @ScriptDir)
	If FileExists($__vSciTEAPI[$__hSciTEResponseGUI]) Then
		Run($__vSciTEAPI[$__hSciTEResponseGUI], _WinAPI_PathRemoveFileSpec($__vSciTEAPI[$__hSciTEResponseGUI]) & '\')
		_WinWait('DirectorExtension', 5)
	EndIf

	_SciTE_Startup()
	If Not _SciTE_IsActive() Then
		Exit MsgBox(BitOR($MB_ICONSTOP, $MB_SYSTEMMODAL), _GetLanguage('ERROR', 'An unexpected error occurred.'), _GetLanguage('SCITE_ERROR', 'SciTE needs to be running for %PROGRAMNAME% to function correctly.'))
	EndIf
EndIf

If _Update() Then
	Exit
EndIf

_WM_COPYDATA_SetID('BAE168EC-85EA-11E2-A7D3-360D79957A39')

$__vSciTEAPI[$__hSciTEResponseGUI] = _WM_COPYDATA_Start(Default, True)
If @error Then
	_SciTE_Send_Command(0, $__vSciTEAPI[$__hSciTEResponseGUI], 'GUI_Activate')
	Exit 1001
EndIf

Global Const $GUI_NO_INDEX = -9999
Global Const $SCITE_JUMP_SCRIPTS = 'au3;bat;cmd;html;htm;log;txt'
Global Const $PBT_APMRESUMEAUTOMATIC = 0x0012, _
		$SC_DRAGMOVE = 0xF012, _
		$WA_INACTIVE = 0, $WA_ACTIVE = 1, $WA_CLICKACTIVE = 2
Global $__vSciTEWindow = False
Global Enum $__iTreeViewSearchBefore, $__iTreeViewItemID
Global Enum Step *2 $__iTreeViewIsComment, $__iTreeViewIsFunctionOrFile, $__iTreeViewIsRegion, $__iTreeViewIsCustomFunction
#cs
	How the FindInFiles, Items And Search Are Structured.
	$__aTreeViewItems[0][0] = Total Rows.
	$__aTreeViewItems[0][1] = Total Columns.

	$__aTreeViewItems[n][0] = Search String Before.
	$__aTreeViewItems[n][2] = BitAND ID e.g. $__iTreeViewIsFunctionOrFile.
#ce

Global Enum $LANGAUGE_ITEMS_COMMENTS = 1, $LANGAUGE_ITEMS_FUNCTIONS, $LANGAUGE_ITEMS_REGIONS, $LANGAUGE_ITEMS_USERDEFINED, _
		$LANGAUGE_ITEMS_PARENTSSEARCH, $LANGAUGE_ITEMS_PARENTSSEARCHSTART, $LANGAUGE_ITEMS_PARENTSFIND, $LANGAUGE_ITEMS_PARENTSFINDSTART
Global $__aLanguageItems[9][5] = [[8, 5]], _ ; Language Strings For Title ContextMenu.
		$__aTreeViewItems[2][2] = [[0, 2], [-1, -1]], _ ; Standard TreeView.
		$__aFindItems = $__aTreeViewItems, _ ; FindInFiles TreeView.
		$__aSearchItems = $__aTreeViewItems ; Search TreeView.

Global Enum $__iCurrentFileSize, _
		$__sCurrentFileFolder, $__sCurrentFileName, $__sCurrentFilePath, $__iCurrentFileMax
Global $__vCurrentFileAPI[$__iCurrentFileMax] ; Current file related.

Global Enum $__bGUIIsMinimised, _
		$__iGUIAbout, $__iGUIArrayListView, $__iGUIButtonExport_1, $__iGUIDockWindow, $__iGUIHeight, $__iGUIHelp, $__iGUIInputFind, _
		$__iGUIInputLine, $__iGUIInputLinePixel, $__iGUIInputSearch, $__iGUIMinHeight, $__iGUIMinWidth, $__iGUIProgressBar, $__iGUIRefresh, _
		$__iGUITreeView, $__iGUITreeViewCurrent, $__iGUITreeViewFind, $__iGUITreeViewSearch, $__iGUIWidth, $__iGUIMax
Global $__vGUIAPI[$__iGUIMax] ; GUI related array.
$__vGUIAPI[$__bGUIIsMinimised] = False

Global Enum $__bMiscFindInFile, $__bMiscFunctionSnippet, $__bMiscIsSearchUDFs, $__bMiscIsSort, _
		$__bMiscSearchFocus, $__bMiscSearchParams, _
		$__bMiscToggleFoldOrNoRefresh, _
		$__iMiscAddHeaderOrOpenLocation, $__iMiscExpandState, _
		$__sMiscSearchedText, $__iMiscMax
Global $__vMiscAPI[$__iMiscMax] ; Misc related array.

$__vMiscAPI[$__bMiscFindInFile] = False
$__vMiscAPI[$__bMiscFunctionSnippet] = False
$__vMiscAPI[$__bMiscIsSearchUDFs] = _IsEx('SearchUDFs', 0) = 1
$__vMiscAPI[$__bMiscIsSort] = _IsEx('Sort', 0) = 1
$__vMiscAPI[$__bMiscSearchFocus] = _IsEx('SearchFocus', 0) = 1
$__vMiscAPI[$__bMiscSearchParams] = BitOR($__vMiscAPI[$__bMiscSearchParams], _IsEx('SearchInComments', 0) * $__iTreeViewIsComment)
$__vMiscAPI[$__bMiscSearchParams] = BitOR($__vMiscAPI[$__bMiscSearchParams], _IsEx('SearchInFunctions', 1) * ($__iTreeViewIsFunctionOrFile + $__iTreeViewIsCustomFunction))
$__vMiscAPI[$__bMiscSearchParams] = BitOR($__vMiscAPI[$__bMiscSearchParams], _IsEx('SearchInRegions', 0) * $__iTreeViewIsRegion)
$__vMiscAPI[$__bMiscToggleFoldOrNoRefresh] = False

Global Enum $__iMiscLastFunctionFuncName, $__iMiscLastFunctionTreeViewID, $__bMiscLastFunctionSelect
Global $__aMiscLastFunction = 0
_AssociativeArray_Startup($__aMiscLastFunction)

Global Enum $__iTreeViewParentsCount, $__iTreeViewParentsComment, $__iTreeViewParentsFunction, $__iTreeViewParentsRegion, $__iTreeViewParentsUDF, $__iTreeViewParentsSearch, _
		$__iTreeViewParentsFind, _
		$__iTreeViewParentsFindStart, $__iTreeViewParentsFindEnd, $__iTreeViewParentsSearchStart, $__iTreeViewParentsSearchEnd, $__iTreeViewParentsTreeViewStart, _
		$__iTreeViewParentsTreeViewEnd, _
		$__iTreeViewParentsFindReDim, $__iTreeViewParentsSearchReDim, $__iTreeViewParentsTreeViewReDim, _
		$__sTreeViewParentsFind, $__sTreeViewParentsSearch, $__sTreeViewParentsTreeView, _
		$__iTreeViewParentsMax
Global $__vTreeViewParentsAPI[$__iTreeViewParentsMax] ; TreeView parents related.
$__vTreeViewParentsAPI[$__iTreeViewParentsCount] = $__iTreeViewParentsUDF
$__vTreeViewParentsAPI[$__iTreeViewParentsFindReDim] = 0
$__vTreeViewParentsAPI[$__iTreeViewParentsSearchReDim] = 0
$__vTreeViewParentsAPI[$__iTreeViewParentsTreeViewReDim] = 0

$__vMiscAPI[$__iMiscExpandState] = $__iTreeViewParentsFunction

Global $__aContextMenu[3], $__aExportDummy[7] = [6] ; System ContextMenu.
Global Enum $__iContextMenu1, $__iContextMenu2

OnAutoItExitRegister('_Exit')

_Main()

Func _Main()
	Local $aGUI_Window = False, _
			$aLanguage[1][5] = [[0, 5, 0]], _
			$aSearch = 0, _
			$aStateDockWindows[2] = [1, 2], _
			$bDockSelection = False, _
			$iCount = 0, $iMsg = $GUI_NO_INDEX, _
			$sReturn = '', _
			$vDummyValue = 0, $vFilePathOrLineNumber = 0
	Local $iIsLineToPixel = Int(IniRead($__sScriptDir & '\Settings.ini', 'General', 'LineToPixel', 0))

	Local $iLeft = 0, $iTop = 0
	_GetCurrentPosition($iLeft, $iTop)

	Local $sSciTESettings = '', $sSciTEPath = ''
	_SciTE_SettingsDir($sSciTEPath, Default, $sSciTESettings) ; $sSciTEPath is only a dummy variable for now.
	$sSciTEPath = _SciTE_GetSciTEDefaultHome()
	Local Const $sIncludePath = _GetFullPath('..\Include', $sSciTEPath) ; _GetFullPath('..\Aut2Exe\Aut2exe.exe', $sSciTEPath)
	Local Const $sAu3StripperPath = _GetFullPath('.\Au3Stripper\Au3Stripper.exe', $sSciTEPath)
	$sSciTEPath = _SaveSciTEPath()

	Local Const $sHelpFile = @ScriptDir & '\HelpFile.chm'
	Local $sHelpPath = $sHelpFile & '::/html'

	$__vSciTEAPI[$__hSciTEResponseGUI] = GUICreate(_GetTitle(), $__vGUIAPI[$__iGUIWidth], $__vGUIAPI[$__iGUIHeight], $iLeft, $iTop, BitOR($GUI_SS_DEFAULT_GUI, $WS_MAXIMIZEBOX, $WS_SIZEBOX), $WS_EX_ACCEPTFILES, $__vSciTEAPI[$__hSciTEWindow])
	; _SciTE_SetResponseGUI($__vSciTEAPI[$__hSciTEResponseGUI])
	If IsAdmin() Then
		_WinAPI_ChangeWindowMessageFilterEx($__vSciTEAPI[$__hSciTEResponseGUI], $WM_DROPFILES, $MSGFLT_ALLOW)
		_WinAPI_ChangeWindowMessageFilterEx($__vSciTEAPI[$__hSciTEResponseGUI], $WM_COPYDATA, $MSGFLT_ALLOW)
		_WinAPI_ChangeWindowMessageFilterEx($__vSciTEAPI[$__hSciTEResponseGUI], $WM_COPYGLOBALDATA, $MSGFLT_ALLOW)
	EndIf
	If Not ($sSciTEPath == '') And FileExists($sHelpFile) = 0 Then
		If FileExists(_WinAPI_PathRemoveFileSpec($sSciTEPath) & '\Scite4AutoIt3.chm') Then
			$sHelpPath = _WinAPI_PathRemoveFileSpec($sSciTEPath) & '\Scite4AutoIt3.chm::'
		EndIf
	EndIf

	If FileExists($sHelpFile) Then
		GUISetHelp('"' & @WindowsDir & '\hh.exe" "' & $sHelpPath & '/SciTEJump_Doc.htm"', $__vSciTEAPI[$__hSciTEResponseGUI])
	EndIf
	Local Const $iWM_COPYDATA = _WM_COPYDATA_Start($__vSciTEAPI[$__hSciTEResponseGUI]) ; Start the communication process.
	_Monitor_Run(True)

	Local Enum $eContextMenuRestart = 1, $eContextMenuReset, $eContextMenuExit = 4, $eContextMenuSettings = 6, $eContextMenuHelp, $eContextMenuAbout
	Local $aContextMenu[9][3] = [[8, 3, 0], _
			[-1, 'TIP_SETTINGS_12', 'Restart'], _
			[-1, 'TIP_SETTINGS_11', 'Reset %PROGRAMNAME%'], _
			[-1, '', ''], _
			[-1, 'CLOSE', 'Close'], _
			[-1, '', ''], _
			[-1, 'TIP_SETTINGS_1', 'Settings'], _
			[-1, 'MENU_HELP', 'Help (F1)'], _
			[-1, 'MENU_ABOUT', 'About']]

	$aContextMenu[0][2] = GUICtrlCreateContextMenu()
	For $i = 1 To $aContextMenu[0][0]
		$aContextMenu[$i][0] = GUICtrlCreateMenuItem(_GetLanguage($aContextMenu[$i][1], $aContextMenu[$i][2]), $aContextMenu[0][2])
		_LanguageAdd($aLanguage, -1, $aContextMenu[$i][0], $aContextMenu[$i][1], $aContextMenu[$i][2])
	Next

	Local $sBackState = 3, $sForwardState = 4
	Local Const $iBack = GUICtrlCreateButton('', 5, 5, 25, 25) ; 3 (<) & 4 (>).
	GUICtrlSetResizing($iBack, $GUI_DOCKLEFT + $GUI_DOCKSIZE + $GUI_DOCKTOP)
	If _IsFontExists('Webdings.ttf') And _IsWindowsVersion() Then ; Windows Vista+.
		GUICtrlSetFont($iBack, 10, Default, Default, 'Webdings')
	Else
		$sBackState = '<'
		$sForwardState = '>'
	EndIf
	GUICtrlSetData($iBack, $sForwardState)

	$__vGUIAPI[$__iGUIProgressBar] = GUICtrlCreateProgress(35, 5, 85, 25, $PBS_MARQUEE)
	GUICtrlSetResizing($__vGUIAPI[$__iGUIProgressBar], $GUI_DOCKLEFT + $GUI_DOCKRIGHT + $GUI_DOCKHEIGHT + $GUI_DOCKTOP)
	_Toggle_ShowOrHide($__vGUIAPI[$__iGUIProgressBar], 0)

	$__vGUIAPI[$__iGUIRefresh] = GUICtrlCreateCheckbox('&' & _GetLanguage('REFRESH', 'Refresh'), $__vGUIAPI[$__iGUIWidth] - 90, 5, 85, 25, BitOR($BS_CHECKBOX, $BS_AUTOCHECKBOX, $BS_PUSHLIKE, $WS_TABSTOP))
	GUICtrlSetResizing($__vGUIAPI[$__iGUIRefresh], $GUI_DOCKRIGHT + $GUI_DOCKSIZE + $GUI_DOCKTOP)
	_LanguageAdd($aLanguage, -1, $__vGUIAPI[$__iGUIRefresh], 'REFRESH', 'Refresh', '&')

	Local Const $iComboHistory = GUICtrlCreateCombo('', 10, $__vGUIAPI[$__iGUIHeight] - 25, $__vGUIAPI[$__iGUIWidth] - 45, 260, $CBS_DROPDOWNLIST)
	GUICtrlSetResizing($iComboHistory, $GUI_DOCKLEFT + $GUI_DOCKRIGHT + $GUI_DOCKHEIGHT + $GUI_DOCKBOTTOM)

	$aSearch = StringSplit(IniRead($__sScriptDir & '\Settings.ini', 'General', 'History', ''), '|')
	If @error = 0 Then
		$vDummyValue = ''
		For $i = 1 To $aSearch[0] - 1
			$vDummyValue &= $aSearch[$i] & '|'
		Next
		GUICtrlSetData($iComboHistory, StringTrimRight($vDummyValue, StringLen('|')), $aSearch[$aSearch[0]])
	EndIf
	$aSearch = 0

	Local Const $iClear = GUICtrlCreateButton(' ', $__vGUIAPI[$__iGUIWidth] - 32.5, $__vGUIAPI[$__iGUIHeight] - 25, 30, 20, $BS_ICON)
	GUICtrlSetResizing($iClear, $GUI_DOCKRIGHT + $GUI_DOCKSIZE + $GUI_DOCKBOTTOM)

	If _IsWindowsVersion() Then ; Windows Vista+.
		$vDummyValue = '238'
		_GUICtrlComboBox_SetCueBanner($iComboHistory, _GetLanguage('TIP_SEARCH_6', 'Folder to Search'))
	Else
		$vDummyValue = -240
	EndIf
	_GUICtrlButton_SetImage(GUICtrlGetHandle($iClear), @SystemDir & '\shell32.dll', $vDummyValue) ; Refresh Icon.

	Local Enum $eTabOne, $eTabTwo, $eTabThree, $eTabID, $eTabMax
	Local $aTabs[$eTabMax] = [0, 0, 0, 0] ; Tabs.
	$aTabs[$eTabID] = GUICtrlCreateTab(-99, -99, 0, 0)
	GUICtrlSetResizing($aTabs[$eTabID], $GUI_DOCKLEFT + $GUI_DOCKTOP)
	$aTabs[$eTabOne] = GUICtrlCreateTabItem('Tab_1')
	Local $iTabItem = $eTabOne

	$__vGUIAPI[$__iGUIDockWindow] = GUICtrlCreateButton('', 5, 37.5, 25, 25) ; 1 & 2.
	GUICtrlSetResizing($__vGUIAPI[$__iGUIDockWindow], $GUI_DOCKLEFT + $GUI_DOCKSIZE + $GUI_DOCKTOP)
	If _IsFontExists('Webdings.ttf') And _IsWindowsVersion() Then ; Windows Vista+.
		GUICtrlSetFont($__vGUIAPI[$__iGUIDockWindow], 10, Default, Default, 'Webdings')
	Else
		$aStateDockWindows[0] = '-'
		$aStateDockWindows[1] = '+'
	EndIf
	GUICtrlSetData($__vGUIAPI[$__iGUIDockWindow], $aStateDockWindows[$bDockSelection])

	$__vGUIAPI[$__iGUIInputSearch] = GUICtrlCreateInput('', 35, 40, $__vGUIAPI[$__iGUIWidth] - 85, 20)
	GUICtrlSetResizing($__vGUIAPI[$__iGUIInputSearch], $GUI_DOCKLEFT + $GUI_DOCKRIGHT + $GUI_DOCKHEIGHT + $GUI_DOCKTOP)
	GUICtrlSendMsg($__vGUIAPI[$__iGUIInputSearch], $EM_SETCUEBANNER, False, _GetLanguage('TIP_SEARCH_3', 'Search Functions'))

	$__vGUIAPI[$__iGUIInputLine] = GUICtrlCreateInput('', $__vGUIAPI[$__iGUIWidth] - 50, 40, 40, 20)
	GUICtrlSetResizing($__vGUIAPI[$__iGUIInputLine], $GUI_DOCKRIGHT + $GUI_DOCKSIZE + $GUI_DOCKTOP)
	GUICtrlSendMsg($__vGUIAPI[$__iGUIInputLine], $EM_SETCUEBANNER, False, _GetLanguage('TIP_SEARCH_4', 'Line'))

	$__vGUIAPI[$__iGUIInputFind] = GUICtrlCreateInput('', 10, $__vGUIAPI[$__iGUIHeight] - 50, $__vGUIAPI[$__iGUIWidth] - 45, 20)
	GUICtrlSetResizing($__vGUIAPI[$__iGUIInputFind], $GUI_DOCKLEFT + $GUI_DOCKRIGHT + $GUI_DOCKHEIGHT + $GUI_DOCKBOTTOM)
	GUICtrlSendMsg($__vGUIAPI[$__iGUIInputFind], $EM_SETCUEBANNER, False, _GetLanguage('TIP_SEARCH_5', 'Search in Scripts') & ' (' & $SCITE_JUMP_SCRIPTS & ')')

	Local Const $iFolder = GUICtrlCreateButton(' ', $__vGUIAPI[$__iGUIWidth] - 32.5, $__vGUIAPI[$__iGUIHeight] - 50, 30, 20, $BS_ICON)
	GUICtrlSetResizing($iFolder, $GUI_DOCKRIGHT + $GUI_DOCKSIZE + $GUI_DOCKBOTTOM)
	_GUICtrlButton_SetImage(GUICtrlGetHandle($iFolder), @SystemDir & '\shell32.dll', '4') ; Folder Icon.

	$__vGUIAPI[$__iGUIButtonExport_1] = GUICtrlCreateButton('&' & _GetLanguage('EXPORT', 'Export'), $__vGUIAPI[$__iGUIWidth] - 180, 5, 85, 25)
	GUICtrlSetResizing($__vGUIAPI[$__iGUIButtonExport_1], $GUI_DOCKRIGHT + $GUI_DOCKSIZE + $GUI_DOCKTOP)
	_LanguageAdd($aLanguage, -1, $__vGUIAPI[$__iGUIButtonExport_1], 'EXPORT', 'Export', '&')
	Local Const $iExportContext = GUICtrlCreateDummy(), _
			$iExportContextMenu = GUICtrlCreateContextMenu($iExportContext), _
			$iExportContextItem_1 = GUICtrlCreateMenuItem(_GetLanguage('HTML', 'HTML'), $iExportContextMenu), _
			$iExportContextItem_2 = GUICtrlCreateMenuItem(_GetLanguage('LATEX', 'LATEX'), $iExportContextMenu), _
			$iExportContextItem_3 = GUICtrlCreateMenuItem(_GetLanguage('PDF', 'PDF'), $iExportContextMenu), _
			$iExportContextItem_4 = GUICtrlCreateMenuItem(_GetLanguage('RTF', 'RTF'), $iExportContextMenu), _
			$iExportContextItem_5 = GUICtrlCreateMenuItem(_GetLanguage('XML', 'XML'), $iExportContextMenu)
	GUICtrlCreateMenuItem('', $iExportContextMenu)
	Local Const $iExportContextItem_6 = GUICtrlCreateMenuItem(_GetLanguage('FUNCTION_LIST', 'Function and Region list'), $iExportContextMenu)

	_LanguageAdd($aLanguage, -1, $iExportContextItem_1, 'HTML', 'HTML')
	_LanguageAdd($aLanguage, -1, $iExportContextItem_3, 'LATEX', 'LATEX')
	_LanguageAdd($aLanguage, -1, $iExportContextItem_3, 'PDF', 'PDF')
	_LanguageAdd($aLanguage, -1, $iExportContextItem_4, 'RTF', 'RTF')
	_LanguageAdd($aLanguage, -1, $iExportContextItem_5, 'XML', 'XML')
	_LanguageAdd($aLanguage, -1, $iExportContextItem_6, 'FUNCTION_LIST', 'Function and Region list')

	$aTabs[$eTabTwo] = GUICtrlCreateTabItem('Tab_2')
	Local Const $iForward = GUICtrlCreateButton('', 30, 5, 25, 25) ; 3 (<) & 4 (>).
	GUICtrlSetResizing($iForward, $GUI_DOCKLEFT + $GUI_DOCKSIZE + $GUI_DOCKTOP)
	If _IsFontExists('Webdings.ttf') And _IsWindowsVersion() Then ; Windows Vista+.
		GUICtrlSetFont($iForward, 10, Default, Default, 'Webdings')
	EndIf
	GUICtrlSetData($iForward, $sForwardState)

	Local Const $iReplaceGroup = GUICtrlCreateGroup(_GetLanguage('TIP_REPLACE_1', 'Replace in Scripts'), 5, 35, $__vGUIAPI[$__iGUIWidth] - 10, 170)
	GUICtrlSetResizing($iReplaceGroup, $GUI_DOCKLEFT + $GUI_DOCKRIGHT + $GUI_DOCKHEIGHT + $GUI_DOCKTOP)
	_LanguageAdd($aLanguage, -1, $iReplaceGroup, 'TIP_REPLACE_1', 'Replace in Scripts')

	Local Enum $eSearchInputFind, $eSearchInputReplace, $eSearchInputFileTypes, $eSearchInputMax
	Local $aSearchInput[$eSearchInputMax] = [0, 0, 0]
	$aSearchInput[$eSearchInputFind] = GUICtrlCreateInput('', 10, 60, $__vGUIAPI[$__iGUIWidth] - 20, 20)
	GUICtrlSendMsg($aSearchInput[$eSearchInputFind], $EM_SETCUEBANNER, False, _GetLanguage('TIP_REPLACE_2', 'Search for...'))
	GUICtrlSetResizing($aSearchInput[$eSearchInputFind], $GUI_DOCKLEFT + $GUI_DOCKRIGHT + $GUI_DOCKHEIGHT + $GUI_DOCKTOP)

	$aSearchInput[$eSearchInputReplace] = GUICtrlCreateInput('', 10, 85, $__vGUIAPI[$__iGUIWidth] - 20, 20)
	GUICtrlSendMsg($aSearchInput[$eSearchInputReplace], $EM_SETCUEBANNER, False, _GetLanguage('TIP_REPLACE_3', 'Replace with...'))
	GUICtrlSetResizing($aSearchInput[$eSearchInputReplace], $GUI_DOCKLEFT + $GUI_DOCKRIGHT + $GUI_DOCKHEIGHT + $GUI_DOCKTOP)

	Local Const $iCheckboxReplace = GUICtrlCreateCheckbox(_GetLanguage('TIP_REPLACE_4', 'Preview before'), 10, 110, 100, 20)
	GUICtrlSetResizing($iCheckboxReplace, $GUI_DOCKLEFT + $GUI_DOCKSIZE + $GUI_DOCKTOP)
	_LanguageAdd($aLanguage, -1, $iCheckboxReplace, 'TIP_REPLACE_4', 'Preview before')
	_Toggle_CheckOrUnCheck($iCheckboxReplace)

	Local Const $iCheckboxSensitive = GUICtrlCreateCheckbox(_GetLanguage('TIP_REPLACE_5', 'Case sensitive'), 10, 130, 100, 20)
	GUICtrlSetResizing($iCheckboxSensitive, $GUI_DOCKLEFT + $GUI_DOCKSIZE + $GUI_DOCKTOP)
	_LanguageAdd($aLanguage, -1, $iCheckboxSensitive, 'TIP_REPLACE_5', 'Case sensitive')
	_Toggle_CheckOrUnCheck($iCheckboxSensitive)

	Local Const $iCheckboxRegExp = GUICtrlCreateCheckbox(_GetLanguage('TIP_REPLACE_7', 'RegExp'), 10, 150, 100, 20)
	GUICtrlSetResizing($iCheckboxRegExp, $GUI_DOCKLEFT + $GUI_DOCKSIZE + $GUI_DOCKTOP)
	_LanguageAdd($aLanguage, -1, $iCheckboxRegExp, 'TIP_REPLACE_7', 'RegExp')

	Local Const $iReplace = GUICtrlCreateCheckbox(_GetLanguage('REPLACE', 'Replace'), $__vGUIAPI[$__iGUIWidth] - 95, 120, 85, 25, BitOR($BS_CHECKBOX, $BS_AUTOCHECKBOX, $BS_PUSHLIKE, $WS_TABSTOP))
	GUICtrlSetResizing($iReplace, $GUI_DOCKRIGHT + $GUI_DOCKSIZE + $GUI_DOCKTOP)
	_LanguageAdd($aLanguage, -1, $iReplace, 'REPLACE', 'Replace')

	$aSearchInput[$eSearchInputFileTypes] = GUICtrlCreateInput(IniRead($__sScriptDir & '\Settings.ini', 'General', 'SearchFileTypes', ''), 10, 175, $__vGUIAPI[$__iGUIWidth] - 20, 20)
	GUICtrlSetResizing($aSearchInput[$eSearchInputFileTypes], $GUI_DOCKLEFT + $GUI_DOCKRIGHT + $GUI_DOCKHEIGHT + $GUI_DOCKTOP)
	GUICtrlSendMsg($aSearchInput[$eSearchInputFileTypes], $EM_SETCUEBANNER, False, _GetLanguage('TIP_REPLACE_6', 'Filetypes, leave blank for all files'))

	GUICtrlCreateGroup('', -99, -99, 1, 1) ; Close the Group.

	$vDummyValue = GUICtrlCreateGroup(_GetLanguage('TIP_UDFS_1', 'Include Files'), 5, 210, $__vGUIAPI[$__iGUIWidth] - 10, 100)
	GUICtrlSetResizing($vDummyValue, $GUI_DOCKLEFT + $GUI_DOCKRIGHT + $GUI_DOCKHEIGHT + $GUI_DOCKTOP)
	_LanguageAdd($aLanguage, -1, $vDummyValue, 'TIP_UDFS_1', 'Include Files')

	Local Const $iUDF_Add = GUICtrlCreateButton(_GetLanguage('TIP_UDFS_2', 'Add to Includes'), 10, 225, $__vGUIAPI[$__iGUIWidth] - 20, 25)
	GUICtrlSetResizing($iUDF_Add, $GUI_DOCKLEFT + $GUI_DOCKRIGHT + $GUI_DOCKHEIGHT + $GUI_DOCKTOP)
	_LanguageAdd($aLanguage, -1, $iUDF_Add, 'TIP_UDFS_2', 'Add to Includes')

	Local Const $iUDF_Remove = GUICtrlCreateButton(_GetLanguage('TIP_UDFS_3', 'Remove from Includes'), 10, 255, $__vGUIAPI[$__iGUIWidth] - 20, 25)
	GUICtrlSetResizing($iUDF_Remove, $GUI_DOCKLEFT + $GUI_DOCKRIGHT + $GUI_DOCKHEIGHT + $GUI_DOCKTOP)
	_LanguageAdd($aLanguage, -1, $iUDF_Remove, 'TIP_UDFS_3', 'Remove from Includes')
	_Toggle_EnableOrDisable($iUDF_Remove, False)

	Local Const $iUDF_Overwrite = GUICtrlCreateCheckbox(_GetLanguage('TIP_UDFS_4', 'Overwrite include file'), 10, 285, $__vGUIAPI[$__iGUIWidth] - 20, 20)
	GUICtrlSetResizing($iUDF_Overwrite, $GUI_DOCKLEFT + $GUI_DOCKRIGHT + $GUI_DOCKHEIGHT + $GUI_DOCKTOP)
	_LanguageAdd($aLanguage, -1, $iUDF_Overwrite, 'TIP_UDFS_4', 'Overwrite include file')
	_Toggle_EnableOrDisable($iUDF_Overwrite, False)

	GUICtrlCreateGroup('', -99, -99, 1, 1) ; Close the Group.

	$vDummyValue = GUICtrlCreateGroup(_GetLanguage('TIP_PREPROCESSOR_1', 'Pre-Processor'), 5, 315, $__vGUIAPI[$__iGUIWidth] - 10, 75)
	GUICtrlSetResizing($vDummyValue, $GUI_DOCKLEFT + $GUI_DOCKRIGHT + $GUI_DOCKHEIGHT + $GUI_DOCKTOP)
	_LanguageAdd($aLanguage, -1, $vDummyValue, 'TIP_PREPROCESSOR_1', 'Pre-Processor')

	Local Const $iPreProcessor = GUICtrlCreateButton('', ($__vGUIAPI[$__iGUIWidth] / 2) - 25, 330, 50, 50, $BS_ICON)
	GUICtrlSetResizing($iPreProcessor, $GUI_DOCKHCENTER + $GUI_DOCKTOP + $GUI_DOCKSIZE)
	GUICtrlSetImage($iPreProcessor, $sAu3StripperPath, 0)
	_Toggle_EnableOrDisable($iPreProcessor, FileExists($sAu3StripperPath) = 1)

	GUICtrlCreateGroup('', -99, -99, 1, 1) ; Close the Group.

	$vDummyValue = GUICtrlCreateGroup(_GetLanguage('TIP_UDFNAME_1', 'UDF header name'), 5, 395, $__vGUIAPI[$__iGUIWidth] - 10, 50)
	GUICtrlSetResizing($vDummyValue, $GUI_DOCKLEFT + $GUI_DOCKRIGHT + $GUI_DOCKHEIGHT + $GUI_DOCKTOP)
	_LanguageAdd($aLanguage, -1, $vDummyValue, 'TIP_UDFNAME_1', 'UDF header name')

	Local $sUDF_HeaderName = _SciTE_GetUDFCreator($sSciTESettings)
	If $sUDF_HeaderName == 'Your Name' Then
		$sUDF_HeaderName = _GetLanguage('TIP_UDFNAME_2', 'Your Name')
	EndIf
	Local Const $iUDF_HeaderName = GUICtrlCreateInput($sUDF_HeaderName, 10, 415, $__vGUIAPI[$__iGUIWidth] - 55, 20)
	GUICtrlSetResizing($iUDF_HeaderName, $GUI_DOCKLEFT + $GUI_DOCKRIGHT + $GUI_DOCKHEIGHT + $GUI_DOCKTOP)

	Local Const $iUDF_HeaderSet = GUICtrlCreateButton(_GetLanguage('SET', 'Set'), $__vGUIAPI[$__iGUIWidth] - 40, 415, 30, 20)
	GUICtrlSetResizing($iUDF_HeaderSet, $GUI_DOCKRIGHT + $GUI_DOCKSIZE + $GUI_DOCKTOP)
	_LanguageAdd($aLanguage, -1, $iUDF_HeaderSet, 'SET', 'Set')
	GUICtrlCreateGroup('', -99, -99, 1, 1) ; Close the Group.

	$vDummyValue = GUICtrlCreateLabel('', 0, 0, $__vGUIAPI[$__iGUIWidth], $__vGUIAPI[$__iGUIHeight])
	GUICtrlSetResizing($vDummyValue, $GUI_DOCKBORDERS)
	GUICtrlSetState($vDummyValue, $GUI_DROPACCEPTED)
	GUICtrlSetBkColor($vDummyValue, $GUI_BKCOLOR_TRANSPARENT)

	$aTabs[$eTabThree] = GUICtrlCreateTabItem('Tab_3')

	Local Const $iSettingsGroup = GUICtrlCreateGroup(_GetLanguage('TIP_SETTINGS_1', 'Settings'), 5, 35, $__vGUIAPI[$__iGUIWidth] - 10, 240)
	GUICtrlSetResizing($iSettingsGroup, $GUI_DOCKLEFT + $GUI_DOCKRIGHT + $GUI_DOCKHEIGHT + $GUI_DOCKTOP)
	_LanguageAdd($aLanguage, -1, $iSettingsGroup, 'TIP_SETTINGS_1', 'Settings')

	Local Const $iSearchUDFs = GUICtrlCreateCheckbox(_GetLanguage('TIP_SETTINGS_2', 'Search within custom UDFs'), 10, 50, $__vGUIAPI[$__iGUIWidth] - 20, 20)
	GUICtrlSetResizing($iSearchUDFs, $GUI_DOCKLEFT + $GUI_DOCKRIGHT + $GUI_DOCKHEIGHT + $GUI_DOCKTOP)
	_LanguageAdd($aLanguage, -1, $iSearchUDFs, 'TIP_SETTINGS_2', 'Search within custom UDFs')
	_Toggle_CheckOrUnCheck($iSearchUDFs, $__vMiscAPI[$__bMiscIsSearchUDFs])

	Local Const $iSortFunctions = GUICtrlCreateCheckbox(_GetLanguage('TIP_SETTINGS_3', 'Sort the functions listed'), 10, 70, $__vGUIAPI[$__iGUIWidth] - 20, 20)
	GUICtrlSetResizing($iSortFunctions, $GUI_DOCKLEFT + $GUI_DOCKRIGHT + $GUI_DOCKHEIGHT + $GUI_DOCKTOP)
	_LanguageAdd($aLanguage, -1, $iSortFunctions, 'TIP_SETTINGS_3', 'Sort the functions listed')
	_Toggle_CheckOrUnCheck($iSortFunctions, $__vMiscAPI[$__bMiscIsSort])

	Local Const $iScrollFunctionList = GUICtrlCreateCheckbox(_GetLanguage('TIP_SETTINGS_4', 'Scroll to the highlighted function'), 10, 90, $__vGUIAPI[$__iGUIWidth] - 20, 20)
	GUICtrlSetResizing($iScrollFunctionList, $GUI_DOCKLEFT + $GUI_DOCKRIGHT + $GUI_DOCKHEIGHT + $GUI_DOCKTOP)
	_LanguageAdd($aLanguage, -1, $iScrollFunctionList, 'TIP_SETTINGS_4', 'Scroll to the highlighted function')
	_Toggle_CheckOrUnCheck($iScrollFunctionList, _IsEx('MonitorLine', 0) = 1)

	$vDummyValue = GUICtrlCreateLabel(_GetLanguage('TIP_SETTINGS_5', 'Focus the search input upon refresh'), 27.5, 112.5, $__vGUIAPI[$__iGUIWidth] - 20, 30)
	GUICtrlSetResizing($vDummyValue, $GUI_DOCKLEFT + $GUI_DOCKRIGHT + $GUI_DOCKHEIGHT + $GUI_DOCKTOP)
	_LanguageAdd($aLanguage, -1, $vDummyValue, 'TIP_SETTINGS_5', 'Focus the search input upon refresh')
	Local Const $iSearchInputFocus = GUICtrlCreateCheckbox('', 10, 110, 17, 17)
	GUICtrlSetResizing($iSearchInputFocus, $GUI_DOCKLEFT + $GUI_DOCKSIZE + $GUI_DOCKTOP)
	_Toggle_CheckOrUnCheck($iSearchInputFocus, $__vMiscAPI[$__bMiscSearchFocus])

	Local Const $iSearchInComments = GUICtrlCreateCheckbox(_GetLanguage('TIP_SETTINGS_6', 'Search for comments'), 10, 140, $__vGUIAPI[$__iGUIWidth] - 20, 20)
	GUICtrlSetResizing($iSearchInComments, $GUI_DOCKLEFT + $GUI_DOCKRIGHT + $GUI_DOCKHEIGHT + $GUI_DOCKTOP)
	_LanguageAdd($aLanguage, -1, $iSearchInComments, 'TIP_SETTINGS_6', 'Search for comments')
	_Toggle_CheckOrUnCheck($iSearchInComments, BitAND($__vMiscAPI[$__bMiscSearchParams], $__iTreeViewIsComment) = $__iTreeViewIsComment)

	Local Const $iSearchInFuctions = GUICtrlCreateCheckbox(_GetLanguage('TIP_SETTINGS_7', 'Search for functions'), 10, 160, $__vGUIAPI[$__iGUIWidth] - 20, 20)
	GUICtrlSetResizing($iSearchInFuctions, $GUI_DOCKLEFT + $GUI_DOCKRIGHT + $GUI_DOCKHEIGHT + $GUI_DOCKTOP)
	_LanguageAdd($aLanguage, -1, $iSearchInFuctions, 'TIP_SETTINGS_7', 'Search for functions')
	_Toggle_CheckOrUnCheck($iSearchInFuctions, BitAND($__vMiscAPI[$__bMiscSearchParams], ($__iTreeViewIsFunctionOrFile + $__iTreeViewIsCustomFunction)) = ($__iTreeViewIsFunctionOrFile + $__iTreeViewIsCustomFunction))

	Local Const $iSearchInRegions = GUICtrlCreateCheckbox(_GetLanguage('TIP_SETTINGS_8', 'Search for regions'), 10, 180, $__vGUIAPI[$__iGUIWidth] - 20, 20)
	GUICtrlSetResizing($iSearchInRegions, $GUI_DOCKLEFT + $GUI_DOCKRIGHT + $GUI_DOCKHEIGHT + $GUI_DOCKTOP)
	_LanguageAdd($aLanguage, -1, $iSearchInRegions, 'TIP_SETTINGS_8', 'Search for regions')
	_Toggle_CheckOrUnCheck($iSearchInRegions, BitAND($__vMiscAPI[$__bMiscSearchParams], $__iTreeViewIsRegion) = $__iTreeViewIsRegion)

	Local Const $iLineToPixel = GUICtrlCreateCheckbox(_GetLanguage('TIP_SETTINGS_9', 'Offset from the top of SciTE (px)'), 10, 200, $__vGUIAPI[$__iGUIWidth] - 20, 20)
	GUICtrlSetResizing($iLineToPixel, $GUI_DOCKLEFT + $GUI_DOCKRIGHT + $GUI_DOCKHEIGHT + $GUI_DOCKTOP)
	_LanguageAdd($aLanguage, -1, $iLineToPixel, 'TIP_SETTINGS_9', 'Offset from the top of SciTE (px)')
	_Toggle_CheckOrUnCheck($iLineToPixel, $iIsLineToPixel > 0)

	$__vGUIAPI[$__iGUIInputLinePixel] = GUICtrlCreateInput($iIsLineToPixel, $__vGUIAPI[$__iGUIWidth] - 40, 220, 30, 20)
	GUICtrlSetResizing($__vGUIAPI[$__iGUIInputLinePixel], $GUI_DOCKLEFT + $GUI_DOCKSIZE + $GUI_DOCKTOP)
	_Toggle_EnableOrDisable($__vGUIAPI[$__iGUIInputLinePixel], $iIsLineToPixel > 0)

	$vDummyValue = GUICtrlCreateLabel(_GetLanguage('TIP_SETTINGS_17', 'Disable refresh on file change'), 27.5, 240, $__vGUIAPI[$__iGUIWidth] - 20, 30)
	GUICtrlSetResizing($vDummyValue, $GUI_DOCKLEFT + $GUI_DOCKRIGHT + $GUI_DOCKHEIGHT + $GUI_DOCKTOP)
	_LanguageAdd($aLanguage, -1, $vDummyValue, 'TIP_SETTINGS_17', 'Disable refresh on file change')
	Local Const $iTreeViewDisableRefresh = GUICtrlCreateCheckbox('', 10, 240, 17, 17)
	GUICtrlSetResizing($iTreeViewDisableRefresh, $GUI_DOCKLEFT + $GUI_DOCKSIZE + $GUI_DOCKTOP)
	_Toggle_CheckOrUnCheck($iTreeViewDisableRefresh, _IsEx('DisableRefresh', 0) = 1)

	GUICtrlCreateGroup('', -99, -99, 1, 1) ; Close the Group.

	$vDummyValue = GUICtrlCreateGroup(_GetLanguage('TIP_SETTINGS_10', 'Language'), 5, 280, $__vGUIAPI[$__iGUIWidth] - 10, 55)
	GUICtrlSetResizing($vDummyValue, $GUI_DOCKLEFT + $GUI_DOCKRIGHT + $GUI_DOCKHEIGHT + $GUI_DOCKTOP)
	_LanguageAdd($aLanguage, -1, $vDummyValue, 'TIP_SETTINGS_10', 'Language')

	Local Const $iComboLanguage = GUICtrlCreateCombo('', _
			($__vGUIAPI[$__iGUIWidth] / 2) - (($__vGUIAPI[$__iGUIWidth] - 20) / 2), _
			300, _
			$__vGUIAPI[$__iGUIWidth] - 20, _
			260, _
			$CBS_DROPDOWNLIST)
	GUICtrlSetResizing($iComboLanguage, $GUI_DOCKHCENTER + $GUI_DOCKTOP)

	Local $sLanguage = _GetLanguageCurrent()
	$aSearch = _GetLanguageList(False)
	$vDummyValue = ''
	For $i = 1 To $aSearch[0]
		$vDummyValue &= $aSearch[$i] & '|'
	Next
	GUICtrlSetData($iComboLanguage, StringTrimRight($vDummyValue, StringLen('|')), _GetLanguageCurrent())
	$aSearch = 0

	GUICtrlCreateGroup('', -99, -99, 1, 1) ; Close the Group.

	$vDummyValue = GUICtrlCreateGroup(_GetLanguage('TIP_SETTINGS_14', 'Dock State'), 5, 340, $__vGUIAPI[$__iGUIWidth] - 10, 55)
	GUICtrlSetResizing($vDummyValue, $GUI_DOCKLEFT + $GUI_DOCKRIGHT + $GUI_DOCKHEIGHT + $GUI_DOCKTOP)
	_LanguageAdd($aLanguage, -1, $vDummyValue, 'TIP_SETTINGS_14', 'Dock State')

	Local $aDockState[3][3] = [['TIP_DOCKSTATE_1', 'Automatic docking'], _
			['TIP_DOCKSTATE_2', 'Left docking'], _
			['TIP_DOCKSTATE_3', 'Right docking']]
	Local Const $iComboDockState = GUICtrlCreateCombo('', _
			($__vGUIAPI[$__iGUIWidth] / 2) - (($__vGUIAPI[$__iGUIWidth] - 20) / 2), _
			360, _
			$__vGUIAPI[$__iGUIWidth] - 20, _
			260, _
			$CBS_DROPDOWNLIST)
	GUICtrlSetResizing($iComboDockState, $GUI_DOCKHCENTER + $GUI_DOCKTOP)
	$vDummyValue = ''
	For $i = 0 To UBound($aDockState) - 1
		$aDockState[$i][2] = _GetLanguage($aDockState[$i][0], $aDockState[$i][1])
		$vDummyValue &= $aDockState[$i][2] & '|'
	Next
	GUICtrlSetData($iComboDockState, StringTrimRight($vDummyValue, StringLen('|')), $aDockState[Number(_GetDockState($__sScriptDir & '\Settings.ini')) + 1][2])

	GUICtrlCreateGroup('', -99, -99, 1, 1) ; Close the Group.

	$vDummyValue = GUICtrlCreateGroup(_GetLanguage('TIP_SETTINGS_16', 'Highlight'), 5, 400, $__vGUIAPI[$__iGUIWidth] - 10, 55)
	GUICtrlSetResizing($vDummyValue, $GUI_DOCKLEFT + $GUI_DOCKRIGHT + $GUI_DOCKHEIGHT + $GUI_DOCKTOP)
	_LanguageAdd($aLanguage, -1, $vDummyValue, 'TIP_SETTINGS_16', 'Highlight')

	Local $aExpandState[4][3] = [['COMMENTS', 'User comments'], _
			['FUNCTIONS', 'Functions'], _
			['REGIONS', 'Regions'], _
			['UDFS', 'User Defined']]
	Local Const $iComboExpandState = GUICtrlCreateCombo('', _
			($__vGUIAPI[$__iGUIWidth] / 2) - (($__vGUIAPI[$__iGUIWidth] - 20) / 2), _
			420, _
			$__vGUIAPI[$__iGUIWidth] - 20, _
			260, _
			$CBS_DROPDOWNLIST)
	GUICtrlSetResizing($iComboExpandState, $GUI_DOCKHCENTER + $GUI_DOCKTOP)
	$vDummyValue = ''
	For $i = 0 To UBound($aExpandState) - 1
		$aExpandState[$i][2] = _GetLanguage($aExpandState[$i][0], $aExpandState[$i][1])
		$vDummyValue &= $aExpandState[$i][2] & '|'
	Next
	$__vMiscAPI[$__iMiscExpandState] = Int(IniRead($__sScriptDir & '\Settings.ini', 'General', 'ExpandState', $__iTreeViewParentsFunction))
	GUICtrlSetData($iComboExpandState, StringTrimRight($vDummyValue, StringLen('|')), $aExpandState[$__vMiscAPI[$__iMiscExpandState] - $__iTreeViewParentsComment][2])

	GUICtrlCreateGroup('', -99, -99, 1, 1) ; Close the Group.

	Local Const $iUpgrade = GUICtrlCreateButton(_GetLanguage('TIP_SETTINGS_15', 'Upgrade %PROGRAMNAME%'), ($__vGUIAPI[$__iGUIWidth] / 2) - 60, $__vGUIAPI[$__iGUIHeight] - 90, 120, 25)
	GUICtrlSetResizing($iUpgrade, $GUI_DOCKHCENTER + $GUI_DOCKBOTTOM + $GUI_DOCKSIZE)
	_LanguageAdd($aLanguage, -1, $iUpgrade, 'TIP_SETTINGS_15', 'Upgrade %PROGRAMNAME%')
	_Toggle_EnableOrDisable($iUpgrade, _IsUpdate(_SciTE_GetSciTEDefaultHome() & '\SciTEJump\SciTE Jump.exe', True) And @Compiled)

	Local Const $iReset = GUICtrlCreateButton(_GetLanguage('TIP_SETTINGS_11', 'Reset %PROGRAMNAME%'), 10, $__vGUIAPI[$__iGUIHeight] - 60, 100, 25)
	GUICtrlSetResizing($iReset, $GUI_DOCKLEFT + $GUI_DOCKBOTTOM + $GUI_DOCKSIZE)
	_LanguageAdd($aLanguage, -1, $iReset, 'TIP_SETTINGS_11', 'Reset %PROGRAMNAME%')

	Local Const $iRestart = GUICtrlCreateButton(_GetLanguage('TIP_SETTINGS_12', 'Restart'), $__vGUIAPI[$__iGUIWidth] - 100, $__vGUIAPI[$__iGUIHeight] - 60, 90, 25)
	GUICtrlSetResizing($iRestart, $GUI_DOCKRIGHT + $GUI_DOCKBOTTOM + $GUI_DOCKSIZE)
	_LanguageAdd($aLanguage, -1, $iRestart, 'TIP_SETTINGS_12', 'Restart')

	Local Const $iAddToSciTE = GUICtrlCreateButton(_GetLanguage('TIP_SETTINGS_13', 'Add to SciTE'), ($__vGUIAPI[$__iGUIWidth] / 2) - 60, $__vGUIAPI[$__iGUIHeight] - 30, 120, 25)
	GUICtrlSetResizing($iAddToSciTE, $GUI_DOCKHCENTER + $GUI_DOCKBOTTOM + $GUI_DOCKSIZE)
	_LanguageAdd($aLanguage, -1, $iAddToSciTE, 'TIP_SETTINGS_13', 'Add to SciTE')
	_Toggle_EnableOrDisable($iAddToSciTE, _AddToSciTEJump(False) = False)

	GUICtrlCreateTabItem('') ; Close the Tab Group.

	GUISwitch($__vSciTEAPI[$__hSciTEResponseGUI])

	Local Const $iEnter = GUICtrlCreateDummy(), $iSciTEActivate = GUICtrlCreateDummy(), $iSearch = GUICtrlCreateDummy()
	$__vGUIAPI[$__iGUIAbout] = GUICtrlCreateDummy()
	$__vGUIAPI[$__iGUIHelp] = GUICtrlCreateDummy()

	For $i = 1 To $__aExportDummy[0]
		$__aExportDummy[$i] = GUICtrlCreateDummy()
	Next
	_System_ContextMenu($__vSciTEAPI[$__hSciTEResponseGUI], Default)

	GUIRegisterMsg($WM_ACTIVATE, 'WM_ACTIVATE')
	GUIRegisterMsg($WM_COMMAND, 'WM_COMMAND')
	GUIRegisterMsg($WM_GETMINMAXINFO, 'WM_GETMINMAXINFO')
	GUIRegisterMsg($WM_LBUTTONDBLCLK, 'WM_LBUTTONDBLCLK')
	GUIRegisterMsg($WM_NOTIFY, 'WM_NOTIFY')
	GUIRegisterMsg($WM_POWERBROADCAST, 'WM_POWERBROADCAST')
	GUIRegisterMsg($WM_SIZE, 'WM_SIZE')
	GUIRegisterMsg($WM_SYSCOMMAND, 'WM_SYSCOMMAND')

	Local $sStyle = -1, $sStyleEx = -1

	; Use a temporary variable for recording the previous style.
	$vDummyValue = GUIGetStyle($__vSciTEAPI[$__hSciTEResponseGUI])
	If UBound($vDummyValue) Then
		$sStyle = $vDummyValue[0]
		$sStyleEx = $vDummyValue[1]
	EndIf
	$vDummyValue = 0

	GUISetState(@SW_SHOW, $__vSciTEAPI[$__hSciTEResponseGUI])
	_GUIInBounds($__vSciTEAPI[$__hSciTEResponseGUI])

	Local Const $aAcceleratorKeys[3][2] = [['{ENTER}', $iEnter], _
			['!q', $iSciTEActivate], _ ; Alt + Q
			['^f', $iSearch]] ; Ctrl + F
	GUISetAccelerators($aAcceleratorKeys, $__vSciTEAPI[$__hSciTEResponseGUI])

	_TreeView_Create(False)
	_FindCreate(False)
	_SearchCreate(False)
	_Monitor()

	If _SciTE_GetFullPathProperty($sSciTESettings) Then
		_SciTE_SetFullPathProperty($sSciTESettings)
		ControlClick($__vSciTEAPI[$__hSciTEResponseGUI], '', $iRestart)
	EndIf

	Local $bSearchFocus = False
	If _IsEx('IsDocked') Then
		$bSearchFocus = True
		_IsWrite('IsDocked', False)
		ControlClick($__vSciTEAPI[$__hSciTEResponseGUI], '', $__vGUIAPI[$__iGUIDockWindow])
	Else
		If $__vMiscAPI[$__bMiscSearchFocus] Then
			; Activate search input for keyboard focus.
			GUICtrlSetState($__vGUIAPI[$__iGUIInputSearch], $GUI_FOCUS)
		EndIf
	EndIf
	Local $bIsSciTERefresh = False

	While 1
		$iMsg = GUIGetMsg()
		Switch $iMsg
			Case $GUI_EVENT_CLOSE, $aContextMenu[$eContextMenuExit][0]
				If $bDockSelection Then
					$iTabItem = $eTabOne
					_GUICtrlTab_SetCurFocus($aTabs[$eTabID], $iTabItem)
					Sleep(50)
					$vDummyValue = 'Monitor_Exit'
					ControlClick($__vSciTEAPI[$__hSciTEResponseGUI], '', $__vGUIAPI[$__iGUIDockWindow])
					_IsWrite('IsDocked', True)
				Else
					ExitLoop
				EndIf

			Case $GUI_EVENT_DROPPED
				If _WinAPI_PathIsDirectory(@GUI_DragFile) Then
					$vDummyValue = StringReplace(@GUI_DragFile, '\\', '\')
					GUICtrlSetData($iComboHistory, $vDummyValue, $vDummyValue)
					$vDummyValue = 0
					_Flash($__vSciTEAPI[$__hSciTEResponseGUI], $COLOR_LIME)
				ElseIf _IsValidFileType(@GUI_DragFile, 'au3') Then
					_SciTE_Open(@GUI_DragFile)
					_Flash($__vSciTEAPI[$__hSciTEResponseGUI], $COLOR_LIME)
				ElseIf _IsValidFileType(@GUI_DragFile, 'session') Then ; If the file is a SciTE session file.
					_SciTE_LoadSession(@GUI_DragFile)
					_Flash($__vSciTEAPI[$__hSciTEResponseGUI], $COLOR_LIME)
				Else
					_Flash($__vSciTEAPI[$__hSciTEResponseGUI], $COLOR_RED)
				EndIf

			Case $GUI_EVENT_MAXIMIZE, $GUI_EVENT_RESTORE
				$__vSciTEWindow = False
				$aGUI_Window = False
				$bDockSelection = False
				GUICtrlSetData($__vGUIAPI[$__iGUIDockWindow], $aStateDockWindows[$bDockSelection])

				$__vGUIAPI[$__bGUIIsMinimised] = False
				_WinAPI_SetFocus(GUICtrlGetHandle($__vGUIAPI[$__iGUIProgressBar]))

				_Monitor()

			Case $GUI_EVENT_MINIMIZE
				$__vGUIAPI[$__bGUIIsMinimised] = True
				_WinAPI_SetFocus(GUICtrlGetHandle($__vGUIAPI[$__iGUIProgressBar]))

			Case $GUI_EVENT_PRIMARYDOWN
				If $bDockSelection Then
					_Monitor_Check(False, 'Monitor_Pause')
					_SendMessage($__vSciTEAPI[$__hSciTEResponseGUI], $WM_SYSCOMMAND, $SC_DRAGMOVE, False)
				EndIf

			Case $GUI_EVENT_PRIMARYUP
				If $bDockSelection Then
					_Monitor_Check(False, 'Monitor_Continue')
				EndIf

			Case $aTabs[$eTabID] ; Hide The TreeView.
				Switch GUICtrlRead($aTabs[$eTabID], 1)
					Case $aTabs[$eTabOne]
						GUICtrlSetData($iBack, $sForwardState)
						GUICtrlSetPos($__vGUIAPI[$__iGUITreeViewCurrent], 10, Default, Default, Default)
						_Toggle_ShowOrHide($__vGUIAPI[$__iGUITreeViewCurrent], True)

						$__vGUIAPI[$__bGUIIsMinimised] = False
						_Monitor()

					Case $aTabs[$eTabTwo]
						GUICtrlSetData($iBack, $sBackState)
						GUICtrlSetPos($__vGUIAPI[$__iGUITreeViewCurrent], $GUI_NO_INDEX, Default, Default, Default)
						_Toggle_ShowOrHide($__vGUIAPI[$__iGUITreeViewCurrent], False)

						_Toggle_ShowOrHide($__vGUIAPI[$__iGUIRefresh], True)
						_Toggle_ShowOrHide($iComboHistory, True)
						_Toggle_ShowOrHide($iClear, True)

						$__vGUIAPI[$__bGUIIsMinimised] = True

						$vDummyValue = _IsValidFileType($__vCurrentFileAPI[$__sCurrentFilePath], 'au3') = 1
						_Toggle_EnableOrDisable($iUDF_Add, $vDummyValue)

						$vDummyValue = FileExists($sIncludePath & '\' & $__vCurrentFileAPI[$__sCurrentFileName]) = 1
						_Toggle_EnableOrDisable($iUDF_Overwrite, $vDummyValue)
						_Toggle_EnableOrDisable($iUDF_Remove, $vDummyValue)

						$vDummyValue = 0

					Case $aTabs[$eTabThree]
						GUICtrlSetData($iBack, $sBackState)
						GUICtrlSetPos($__vGUIAPI[$__iGUITreeViewCurrent], $GUI_NO_INDEX, Default, Default, Default)
						_Toggle_ShowOrHide($__vGUIAPI[$__iGUITreeViewCurrent], False)

						$__vGUIAPI[$__bGUIIsMinimised] = True

						_Toggle_ShowOrHide($__vGUIAPI[$__iGUIRefresh], False)
						_Toggle_ShowOrHide($iComboHistory, False)
						_Toggle_ShowOrHide($iClear, False)

				EndSwitch

			Case $__vGUIAPI[$__iGUIAbout], $aContextMenu[$eContextMenuAbout][0]
				MsgBox(BitOR($MB_ICONINFORMATION, $MB_SYSTEMMODAL), _ProgramName() & ' - V' & _WinAPI_ExpandEnvironmentStrings('%VERSION%'), _GetLanguage("ABOUT", "%PROGRAMNAME% is an application that allows you to jump quickly between functions and regions in an AutoIt script. Works with only the full version of SciTE. @NL @NL The application has been created by %COPYRIGHT%.") & _
						@CRLF & @CRLF & _
						_GetLanguageAuthor('LANGUAGE_AUTHOR', 'Thanks to %LANGUAGEAUTHOR% for the %LANGUAGE% translation. The translation was created on the %LANGUAGEUPDATED%.'), 0, $__vSciTEAPI[$__hSciTEResponseGUI])

			Case $iAddToSciTE
				If _AddToSciTEJump(True) Then
					_Toggle_EnableOrDisable($iAddToSciTE, False)
					If _Update(True) Then
						_WM_COPYDATA_SetID('')
						ExitLoop
					EndIf
				EndIf

			Case $iBack
				If $iTabItem = $eTabThree Then
					$vDummyValue = Int(GUICtrlRead($__vGUIAPI[$__iGUIInputLinePixel])) * _IsChecked($iLineToPixel)
					If Not ($iIsLineToPixel = $vDummyValue) Then
						$iIsLineToPixel = $vDummyValue
						IniWrite($__sScriptDir & '\Settings.ini', 'General', 'LineToPixel', $iIsLineToPixel)
						_Toggle_EnableOrDisable($__vGUIAPI[$__iGUIInputLinePixel], $iIsLineToPixel > 0)
					EndIf
					$vDummyValue = 0
				EndIf
				If $iTabItem = $eTabOne Then
					$iTabItem += 1
				Else
					$iTabItem -= 1
				EndIf
				_GUICtrlTab_SetCurFocus($aTabs[$eTabID], $iTabItem)
				ContinueLoop

			Case $iCheckboxRegExp
				_Toggle_EnableOrDisable($iCheckboxSensitive, _IsChecked($iCheckboxRegExp) = False)

			Case $iClear
				GUICtrlSetData($iComboHistory, '')

			Case $iComboLanguage
				$vDummyValue = GUICtrlRead($iComboLanguage)
				If Not ($vDummyValue == $sLanguage) Then
					$sLanguage = $vDummyValue
					_SetLanguageCurrent($sLanguage)

					_LanguageUpdate($aLanguage)
					_LanguageUpdate($__aLanguageItems)

					$vDummyValue = _SciTE_GetUDFCreator($sSciTESettings)
					If $vDummyValue == 'Your Name' Then
						$sUDF_HeaderName = _GetLanguage('TIP_UDFNAME_2', 'Your Name')
						GUICtrlSetData($iUDF_HeaderName, $sUDF_HeaderName)
					EndIf

					$vDummyValue = ''
					GUICtrlSetData($iComboDockState, $vDummyValue)
					For $i = 0 To UBound($aDockState) - 1
						$aDockState[$i][2] = _GetLanguage($aDockState[$i][0], $aDockState[$i][1])
						$vDummyValue &= $aDockState[$i][2] & '|'
					Next
					GUICtrlSetData($iComboDockState, StringTrimRight($vDummyValue, StringLen('|')), $aDockState[Number(_GetDockState($__sScriptDir & '\Settings.ini')) + 1][2])

					$vDummyValue = ''
					GUICtrlSetData($iComboExpandState, $vDummyValue)
					For $i = 0 To UBound($aExpandState) - 1
						$aExpandState[$i][2] = _GetLanguage($aExpandState[$i][0], $aExpandState[$i][1])
						$vDummyValue &= $aExpandState[$i][2] & '|'
					Next
					GUICtrlSetData($iComboExpandState, StringTrimRight($vDummyValue, StringLen('|')), $aExpandState[$__vMiscAPI[$__iMiscExpandState] - $__iTreeViewParentsComment][2])

					GUICtrlSendMsg($__vGUIAPI[$__iGUIInputSearch], $EM_SETCUEBANNER, False, _GetLanguage('TIP_SEARCH_3', 'Search Functions'))
					GUICtrlSendMsg($__vGUIAPI[$__iGUIInputLine], $EM_SETCUEBANNER, False, _GetLanguage('TIP_SEARCH_4', 'Line'))
					GUICtrlSendMsg($__vGUIAPI[$__iGUIInputFind], $EM_SETCUEBANNER, False, _GetLanguage('TIP_SEARCH_5', 'Search in Scripts') & ' (' & $SCITE_JUMP_SCRIPTS & ')')

					If _IsWindowsVersion() Then ; Windows Vista+.
						_GUICtrlComboBox_SetCueBanner($iComboHistory, _GetLanguage('TIP_SEARCH_6', 'Folder to Search'))
					EndIf

					GUICtrlSendMsg($aSearchInput[$eSearchInputFind], $EM_SETCUEBANNER, False, _GetLanguage('TIP_REPLACE_2', 'Search for...'))
					GUICtrlSendMsg($aSearchInput[$eSearchInputReplace], $EM_SETCUEBANNER, False, _GetLanguage('TIP_REPLACE_3', 'Replace with...'))
					GUICtrlSendMsg($aSearchInput[$eSearchInputFileTypes], $EM_SETCUEBANNER, False, _GetLanguage('TIP_REPLACE_6', 'Filetypes, leave blank for all files'))

					_GUICtrlMenu_SetItemText($__aContextMenu[0], $__aContextMenu[1], _GetLanguage('MENU_HELP', 'Help (F1)'))
					_GUICtrlMenu_SetItemText($__aContextMenu[0], $__aContextMenu[2], _GetLanguage('MENU_ABOUT', 'About'))
				EndIf
				$vDummyValue = 0

			Case $iComboDockState
				IniWrite($__sScriptDir & '\Settings.ini', 'General', 'DockState', _GUICtrlComboBox_GetCurSel($iComboDockState) - 1)

				_Monitor_Check(False, 'Monitor_SettingsChange')

			Case $iComboExpandState
				$__vMiscAPI[$__iMiscExpandState] = _GUICtrlComboBox_GetCurSel($iComboExpandState) + $__iTreeViewParentsComment
				IniWrite($__sScriptDir & '\Settings.ini', 'General', 'ExpandState', $__vMiscAPI[$__iMiscExpandState])

				_Monitor_Check(False, 'Monitor_SettingsChange')

			Case $__vGUIAPI[$__iGUIDockWindow]
				GUICtrlSetData($__vGUIAPI[$__iGUIDockWindow], $aStateDockWindows[Not $bDockSelection])

				If $bDockSelection Then ; Undock SciTE Jump.
					_Monitor_Check(False, 'Monitor_Pause')
					If $__vSciTEWindow = True Then
						WinSetState($__vSciTEAPI[$__hSciTEWindow], '', @SW_RESTORE)
						WinSetState($__vSciTEAPI[$__hSciTEWindow], '', @SW_MAXIMIZE)
					Else
						WinMove($__vSciTEAPI[$__hSciTEWindow], '', $__vSciTEWindow[0], $__vSciTEWindow[1], $__vSciTEWindow[2], $__vSciTEWindow[3])
					EndIf
					If $aGUI_Window = True Then
						; WinSetState($__vSciTEAPI[$__hSciTEResponseGUI], '', @SW_RESTORE)
						WinSetState($__vSciTEAPI[$__hSciTEResponseGUI], '', @SW_MAXIMIZE)
					Else
						WinMove($__vSciTEAPI[$__hSciTEResponseGUI], '', $aGUI_Window[0], $aGUI_Window[1], $aGUI_Window[2], $aGUI_Window[3])
					EndIf

					If _IsWindowsVersion() Then ; Windows Vista+.
						GUISetStyle($sStyle, $sStyleEx, $__vSciTEAPI[$__hSciTEResponseGUI])
						If UBound($aGUI_Window) Then
							_WinAPI_SetWindowPos($__vSciTEAPI[$__hSciTEResponseGUI], 0, 0, 0, 0, 0, BitOR($SWP_NOMOVE, $SWP_NOSIZE, $SWP_NOZORDER, $SWP_FRAMECHANGED))

							GUICtrlSetPos($__vGUIAPI[$__iGUITreeView], Default, Default, Default, $aGUI_Window[3] - 161)
							GUICtrlSetPos($__vGUIAPI[$__iGUITreeViewSearch], Default, Default, Default, $aGUI_Window[3] - 161)
							GUICtrlSetPos($__vGUIAPI[$__iGUITreeViewFind], Default, Default, Default, $aGUI_Window[3] - 161)

							GUICtrlSetPos($__vGUIAPI[$__iGUIInputFind], Default, $aGUI_Window[3] - 87, Default, Default)
							GUICtrlSetPos($iFolder, Default, $aGUI_Window[3] - 87, Default, Default)
							GUICtrlSetPos($iComboHistory, Default, $aGUI_Window[3] - 62, Default, Default)
							GUICtrlSetPos($iClear, Default, $aGUI_Window[3] - 62, Default, Default)

							GUICtrlSetPos($iReplaceGroup, Default, 35, Default, Default)

							GUICtrlSetPos($iUpgrade, Default, $aGUI_Window[3] - 127, Default, Default)
							GUICtrlSetPos($iReset, Default, $aGUI_Window[3] - 97, Default, Default)
							GUICtrlSetPos($iRestart, Default, $aGUI_Window[3] - 97, Default, Default)
							GUICtrlSetPos($iAddToSciTE, Default, $aGUI_Window[3] - 67, Default, Default)

							ControlClick($__vSciTEAPI[$__hSciTEResponseGUI], '', $__vGUIAPI[$__iGUIRefresh])
						EndIf
					EndIf
					$aGUI_Window = 0
					$__vSciTEWindow = False

					If $vDummyValue == 'Monitor_Exit' Or $vDummyValue == 'Monitor_Exit_Restart' Then
						ExitLoop
					EndIf
					$vDummyValue = 0
				Else
					If Not _IsMinimized($__vSciTEAPI[$__hSciTEWindow]) Then
						If _IsMaximized($__vSciTEAPI[$__hSciTEWindow]) Then
							$__vSciTEWindow = True
						Else
							$__vSciTEWindow = WinGetPos($__vSciTEAPI[$__hSciTEWindow])
						EndIf
						If _IsMaximized($__vSciTEAPI[$__hSciTEResponseGUI]) Then
							$aGUI_Window = True
						Else
							$aGUI_Window = WinGetPos($__vSciTEAPI[$__hSciTEResponseGUI])
						EndIf

						_DockToWindow($__vSciTEAPI[$__hSciTEWindow], $__vSciTEAPI[$__hSciTEResponseGUI], $vDummyValue, $vDummyValue, _GetDockState($__sScriptDir & '\Settings.ini'), $__vSciTEAPI[$__hSciTEResponseGUI])
						$vDummyValue = 0

						If _IsWindowsVersion() Then ; Windows Vista+.
							GUISetStyle(BitOR($WS_POPUPWINDOW, $WS_SIZEBOX), $sStyleEx, $__vSciTEAPI[$__hSciTEResponseGUI])
							If UBound($aGUI_Window) Then
								$vDummyValue = WinGetPos($__vSciTEAPI[$__hSciTEResponseGUI])
								GUICtrlSetPos($__vGUIAPI[$__iGUIInputFind], Default, $vDummyValue[3] - 87, Default, Default)
								GUICtrlSetPos($iFolder, Default, $vDummyValue[3] - 87, Default, Default)
								GUICtrlSetPos($iComboHistory, Default, $vDummyValue[3] - 62, Default, Default)
								GUICtrlSetPos($iClear, Default, $vDummyValue[3] - 62, Default, Default)

								GUICtrlSetPos($__vGUIAPI[$__iGUITreeView], Default, Default, Default, $vDummyValue[3] - 161)
								GUICtrlSetPos($__vGUIAPI[$__iGUITreeViewFind], Default, Default, Default, $vDummyValue[3] - 161)
								GUICtrlSetPos($__vGUIAPI[$__iGUITreeViewSearch], Default, Default, Default, $vDummyValue[3] - 161)

								GUICtrlSetPos($iReplaceGroup, Default, 35, Default, Default)

								GUICtrlSetPos($iUpgrade, Default, $vDummyValue[3] - 127, Default, Default)
								GUICtrlSetPos($iReset, Default, $vDummyValue[3] - 97, Default, Default)
								GUICtrlSetPos($iRestart, Default, $vDummyValue[3] - 97, Default, Default)
								GUICtrlSetPos($iAddToSciTE, Default, $vDummyValue[3] - 67, Default, Default)

								_WinAPI_SetWindowPos($__vSciTEAPI[$__hSciTEResponseGUI], 0, 0, 0, 0, 0, BitOR($SWP_NOMOVE, $SWP_NOSIZE, $SWP_NOZORDER, $SWP_FRAMECHANGED))

								ControlClick($__vSciTEAPI[$__hSciTEResponseGUI], '', $__vGUIAPI[$__iGUIRefresh])
								$vDummyValue = 0
							EndIf
						EndIf
						If $bSearchFocus Then
							$bSearchFocus = False
							; Activate search input for keyboard focus.
							GUICtrlSetState($__vGUIAPI[$__iGUIInputSearch], $GUI_FOCUS)
						EndIf
						_Monitor_Run()
						_Monitor_Check(False, 'Monitor_Continue')
					EndIf

				EndIf
				$bDockSelection = Not $bDockSelection
				$vDummyValue = 0

			Case $iEnter
				Switch _WinAPI_GetDlgCtrlID(_WinAPI_GetFocus())
					Case $__vGUIAPI[$__iGUIInputFind]
						_Toggle_EnableOrDisable($iBack)
						_Toggle_EnableOrDisable($__vGUIAPI[$__iGUIDockWindow])
						_Toggle_ProgressBar(True)

						$vDummyValue = GUICtrlRead($iComboHistory)
						If $vDummyValue = '' Then
							$vDummyValue = @ScriptDir & '\'
						EndIf
						_FindDestroy()
						_SearchDestroy()

						$__vMiscAPI[$__bMiscFindInFile] = True

						_TreeView_Create(False)
						_SearchCreate(False)
						_FindCreate()

						_Find(GUICtrlRead($__vGUIAPI[$__iGUIInputFind]), $vDummyValue)

						_Toggle_ProgressBar(False)
						_Toggle_EnableOrDisable($iBack)
						_Toggle_EnableOrDisable($__vGUIAPI[$__iGUIDockWindow])
						$vDummyValue = 0

					Case $aSearchInput[$eSearchInputFind] To $aSearchInput[UBound($aSearchInput, 1) - 1]
						ControlClick($__vSciTEAPI[$__hSciTEResponseGUI], '', $iReplace)

				EndSwitch

			Case $__vGUIAPI[$__iGUIButtonExport_1]
				_GUICtrlButton_ContextMenuEx($__vSciTEAPI[$__hSciTEResponseGUI], $__vGUIAPI[$__iGUIButtonExport_1], $iExportContextMenu)

			Case $iExportContextItem_1, $__aExportDummy[1]
				_Toggle_ShowOrHide($__vGUIAPI[$__iGUIButtonExport_1])
				_ProgressMarquee_Start($__vGUIAPI[$__iGUIProgressBar])
				$vDummyValue = _SciTE_ExportToHTML($__vCurrentFileAPI[$__sCurrentFilePath])
				If @error Then
					_Flash($__vSciTEAPI[$__hSciTEResponseGUI], $COLOR_RED)
				Else
					_Flash($__vSciTEAPI[$__hSciTEResponseGUI], $COLOR_LIME)
					ShellExecute('explorer.exe', '/select,"' & $vDummyValue & '"')
				EndIf
				_ProgressMarquee_Stop($__vGUIAPI[$__iGUIProgressBar], True, True)
				_Toggle_ShowOrHide($__vGUIAPI[$__iGUIButtonExport_1])
				$vDummyValue = 0

			Case $iExportContextItem_2, $__aExportDummy[2]
				_Toggle_ShowOrHide($__vGUIAPI[$__iGUIButtonExport_1])
				_ProgressMarquee_Start($__vGUIAPI[$__iGUIProgressBar])
				$vDummyValue = _SciTE_ExportToLatex($__vCurrentFileAPI[$__sCurrentFilePath])
				If @error Then
					_Flash($__vSciTEAPI[$__hSciTEResponseGUI], $COLOR_RED)
				Else
					_Flash($__vSciTEAPI[$__hSciTEResponseGUI], $COLOR_LIME)
					ShellExecute('explorer.exe', '/select,"' & $vDummyValue & '"')
				EndIf
				_ProgressMarquee_Stop($__vGUIAPI[$__iGUIProgressBar], True, True)
				_Toggle_ShowOrHide($__vGUIAPI[$__iGUIButtonExport_1])
				$vDummyValue = 0

			Case $iExportContextItem_3, $__aExportDummy[3]
				_Toggle_ShowOrHide($__vGUIAPI[$__iGUIButtonExport_1])
				_ProgressMarquee_Start($__vGUIAPI[$__iGUIProgressBar])
				$vDummyValue = _SciTE_ExportToPDF($__vCurrentFileAPI[$__sCurrentFilePath])
				If @error Then
					_Flash($__vSciTEAPI[$__hSciTEResponseGUI], $COLOR_RED)
				Else
					_Flash($__vSciTEAPI[$__hSciTEResponseGUI], $COLOR_LIME)
					ShellExecute('explorer.exe', '/select,"' & $vDummyValue & '"')
				EndIf
				_ProgressMarquee_Stop($__vGUIAPI[$__iGUIProgressBar], True, True)
				_Toggle_ShowOrHide($__vGUIAPI[$__iGUIButtonExport_1])
				$vDummyValue = 0

			Case $iExportContextItem_4, $__aExportDummy[4]
				_Toggle_ShowOrHide($__vGUIAPI[$__iGUIButtonExport_1])
				_ProgressMarquee_Start($__vGUIAPI[$__iGUIProgressBar])
				$vDummyValue = _SciTE_ExportToRTF($__vCurrentFileAPI[$__sCurrentFilePath])
				If @error Then
					_Flash($__vSciTEAPI[$__hSciTEResponseGUI], $COLOR_RED)
				Else
					_Flash($__vSciTEAPI[$__hSciTEResponseGUI], $COLOR_LIME)
					ShellExecute('explorer.exe', '/select,"' & $vDummyValue & '"')
				EndIf
				_ProgressMarquee_Stop($__vGUIAPI[$__iGUIProgressBar], True, True)
				_Toggle_ShowOrHide($__vGUIAPI[$__iGUIButtonExport_1])
				$vDummyValue = 0

			Case $iExportContextItem_5, $__aExportDummy[5]
				_Toggle_ShowOrHide($__vGUIAPI[$__iGUIButtonExport_1])
				_ProgressMarquee_Start($__vGUIAPI[$__iGUIProgressBar])
				$vDummyValue = _SciTE_ExportToXML($__vCurrentFileAPI[$__sCurrentFilePath])
				If @error Then
					_Flash($__vSciTEAPI[$__hSciTEResponseGUI], $COLOR_RED)
				Else
					_Flash($__vSciTEAPI[$__hSciTEResponseGUI], $COLOR_LIME)
					ShellExecute('explorer.exe', '/select,"' & $vDummyValue & '"')
				EndIf
				_ProgressMarquee_Stop($__vGUIAPI[$__iGUIProgressBar], True, True)
				_Toggle_ShowOrHide($__vGUIAPI[$__iGUIButtonExport_1])
				$vDummyValue = 0

			Case $iExportContextItem_6, $__aExportDummy[6]
				_Toggle_ShowOrHide($__vGUIAPI[$__iGUIButtonExport_1])
				_ProgressMarquee_Start($__vGUIAPI[$__iGUIProgressBar])
				_Export_FunctionRegionList($__vCurrentFileAPI[$__sCurrentFilePath], $__vCurrentFileAPI[$__sCurrentFileName], $__vCurrentFileAPI[$__iCurrentFileSize], _
						$__vCurrentFileAPI[$__sCurrentFileFolder], $__vGUIAPI[$__iGUIRefresh])
				If @error Then
					_Flash($__vSciTEAPI[$__hSciTEResponseGUI], $COLOR_RED)
				Else
					_Flash($__vSciTEAPI[$__hSciTEResponseGUI], $COLOR_LIME)
					ShellExecute('explorer.exe', '/select,"' & $__vCurrentFileAPI[$__sCurrentFileFolder] & '\FunctionList.txt' & '"')
				EndIf
				_ProgressMarquee_Stop($__vGUIAPI[$__iGUIProgressBar], True, True)
				_Toggle_ShowOrHide($__vGUIAPI[$__iGUIButtonExport_1])

			Case $iFolder
				$vDummyValue = FileSelectFolder(_GetLanguage('FOLDER_SELECT', 'Select a folder to search for a specific keyword.'), '', 2, @ScriptDir & '\', $__vSciTEAPI[$__hSciTEResponseGUI]) & '\'
				If @error Then
					ContinueLoop
				EndIf
				$vDummyValue = StringReplace($vDummyValue, '\\', '\')
				GUICtrlSetData($iComboHistory, $vDummyValue, $vDummyValue)
				$vDummyValue = 0

			Case $__vGUIAPI[$__iGUIHelp], $aContextMenu[$eContextMenuHelp][0]
				If Not ($sHelpPath == '') Then
					Run('"' & @WindowsDir & '\hh.exe" "' & $sHelpPath & '/SciTEJump_Doc.htm"')
				EndIf

			Case $iForward
				$iTabItem += 1
				_GUICtrlTab_SetCurFocus($aTabs[$eTabID], $iTabItem)
				ContinueLoop

			Case $iLineToPixel
				_Toggle_EnableOrDisable($__vGUIAPI[$__iGUIInputLinePixel], _IsChecked($iLineToPixel))

				$vDummyValue = Int(GUICtrlRead($__vGUIAPI[$__iGUIInputLinePixel])) * _IsChecked($iLineToPixel)
				If Not ($iIsLineToPixel = $vDummyValue) Then
					$iIsLineToPixel = $vDummyValue
					IniWrite($__sScriptDir & '\Settings.ini', 'General', 'LineToPixel', $iIsLineToPixel)
					_Toggle_EnableOrDisable($__vGUIAPI[$__iGUIInputLinePixel], $iIsLineToPixel > 0)
				EndIf
				$vDummyValue = 0

			Case $iPreProcessor
				If FileExists($sAu3StripperPath) Then
					ShellExecute(_WinAPI_PathRemoveFileSpec($sAu3StripperPath))
				EndIf

			Case $__vGUIAPI[$__iGUIRefresh]
				If $__vMiscAPI[$__bMiscToggleFoldOrNoRefresh] Then ; Don't refresh if the Cancel button is selected.
					$__vMiscAPI[$__bMiscToggleFoldOrNoRefresh] = False
				Else
					_Toggle_CheckOrUnCheck($__vGUIAPI[$__iGUIRefresh], False)
					If $iTabItem = $eTabTwo Then
						For $i = 0 To UBound($aSearchInput, 1) - 1
							GUICtrlSetData($aSearchInput[$i], '')
						Next
					Else
						_SciTE_Startup()
						_TreeView_Create()

						_FindDestroy()
						_SearchDestroy()

						GUICtrlSetData($__vGUIAPI[$__iGUIInputFind], '')
						GUICtrlSetData($__vGUIAPI[$__iGUIInputLine], '')

						$__vMiscAPI[$__sMiscSearchedText] = ''
						GUICtrlSetData($__vGUIAPI[$__iGUIInputSearch], '')

						For $i = 0 To UBound($__vCurrentFileAPI) - 1
							$__vCurrentFileAPI[$i] = ''
						Next

						_TreeView_Reset($__aTreeViewItems, $__vTreeViewParentsAPI[$__iTreeViewParentsTreeViewReDim])
						$__vTreeViewParentsAPI[$__iTreeViewParentsTreeViewStart] = $GUI_NO_INDEX
						$__vTreeViewParentsAPI[$__iTreeViewParentsTreeViewEnd] = $GUI_NO_INDEX

						_Monitor()
						_Monitor_Check(False, 'Monitor_Refresh')

						_TreeView_Reset($__aFindItems, $__vTreeViewParentsAPI[$__iTreeViewParentsFindReDim])
						_TreeView_Reset($__aSearchItems, $__vTreeViewParentsAPI[$__iTreeViewParentsSearchReDim])

						If $__vMiscAPI[$__bMiscSearchFocus] Then
							; Activate search input for keyboard focus.
							GUICtrlSetState($__vGUIAPI[$__iGUIInputSearch], $GUI_FOCUS)
						EndIf
					EndIf
				EndIf

			Case $iReplace
				If $vDummyValue And TimerDiff($vDummyValue) < 750 Then ; Workaround for if the Cancel button is selected.
					$vDummyValue = 0
					_Toggle_CheckOrUnCheck($iReplace, False)
				Else
					_Toggle_CheckOrUnCheck($iReplace, False)
					If StringStripWS(GUICtrlRead($aSearchInput[$eSearchInputFind]), $STR_STRIPALL) = '' Then
						_Flash($__vSciTEAPI[$__hSciTEResponseGUI], $COLOR_RED)
					Else
						$vDummyValue = GUICtrlRead($iComboHistory)
						If $vDummyValue = '' Then
							$vDummyValue = @ScriptDir & '\'
						EndIf
						_Toggle_EnableOrDisable($iBack)
						_Toggle_ShowOrHide($iForward)
						_Toggle_EnableOrDisable($__vGUIAPI[$__iGUIRefresh])
						$aSearch = _FileSearch($vDummyValue, '*.*', $__vGUIAPI[$__iGUIRefresh])
						Local $aReturn[1][2] = [[0, 2]]
						GUICtrlSetData($iReplace, '&' & _GetLanguage('CANCEL', 'Cancel'))
						$vDummyValue = 0

						_ProgressMarquee_Start($__vGUIAPI[$__iGUIProgressBar])
						If _ReplaceInFiles($iReplace, $aReturn, $aSearch, GUICtrlRead($aSearchInput[$eSearchInputFind]), GUICtrlRead($aSearchInput[$eSearchInputReplace]), (Not _IsChecked($iCheckboxReplace)), GUICtrlRead($aSearchInput[$eSearchInputFileTypes]), _IsChecked($iCheckboxSensitive), _IsChecked($iCheckboxRegExp)) Then
							If _IsChecked($iCheckboxReplace) Then ; Display the replace GUI.
								_GUIDisable($__vSciTEAPI[$__hSciTEResponseGUI], 1, 25)
								_ProgressMarquee_Stop($__vGUIAPI[$__iGUIProgressBar], True, True)
								GUIRegisterMsg($WM_ACTIVATE, '')
								GUIRegisterMsg($WM_GETMINMAXINFO, '')
								GUIRegisterMsg($WM_SIZE, '')
								$aSearch = _ArrayListView($__vSciTEAPI[$__hSciTEResponseGUI], $aReturn, _IsChecked($iCheckboxReplace), Default, Default, GUICtrlRead($aSearchInput[$eSearchInputFind]), GUICtrlRead($aSearchInput[$eSearchInputReplace]), _IsChecked($iCheckboxSensitive), _IsChecked($iCheckboxRegExp))
								If @error Then
									_GUIDisable($__vSciTEAPI[$__hSciTEResponseGUI], 1)
								Else
									_GUIDisable($__vSciTEAPI[$__hSciTEResponseGUI], 1)
									_ProgressMarquee_Start($__vGUIAPI[$__iGUIProgressBar])
									_ReplaceInFiles($iReplace, $aReturn, $aSearch, GUICtrlRead($aSearchInput[$eSearchInputFind]), GUICtrlRead($aSearchInput[$eSearchInputReplace]), True, GUICtrlRead($aSearchInput[$eSearchInputFileTypes]), _IsChecked($iCheckboxSensitive), _IsChecked($iCheckboxRegExp))
								EndIf
								GUIRegisterMsg($WM_ACTIVATE, 'WM_ACTIVATE')
								GUIRegisterMsg($WM_GETMINMAXINFO, 'WM_GETMINMAXINFO')
								GUIRegisterMsg($WM_SIZE, 'WM_SIZE')
							Else
								_Flash($__vSciTEAPI[$__hSciTEResponseGUI], $COLOR_LIME)
							EndIf
						Else
							_Flash($__vSciTEAPI[$__hSciTEResponseGUI], $COLOR_RED)
							$vDummyValue = TimerInit()
						EndIf
						_ProgressMarquee_Stop($__vGUIAPI[$__iGUIProgressBar], True, True)

						GUICtrlSetData($iReplace, _GetLanguage('REPLACE', 'Replace'))
						_Toggle_EnableOrDisable($iBack)
						_Toggle_ShowOrHide($iForward)
						_Toggle_EnableOrDisable($__vGUIAPI[$__iGUIRefresh])
						$aSearch = 0
					EndIf
				EndIf

			Case $iReset, $aContextMenu[$eContextMenuReset][0]
				_Toggle_EnableOrDisable($iRestart)
				_Monitor_Run(True)
				If Not $bDockSelection Then
					_Monitor_Check(False, 'Monitor_Continue')
				EndIf
				_Toggle_EnableOrDisable($iRestart)
				ControlClick($__vSciTEAPI[$__hSciTEResponseGUI], '', $__vGUIAPI[$__iGUIRefresh])

			Case $iRestart, $aContextMenu[$eContextMenuRestart][0]
				_Monitor_Check(True)
				If $__vCurrentFileAPI[$__sCurrentFilePath] Then
					_SciTE_Save($__vCurrentFileAPI[$__sCurrentFilePath])
				EndIf
				_SciTE_SaveSession($__sScriptDir & '\SciTEJump.session')
				_SciTE_Quit()
				If Not _IsMinimized($__vSciTEAPI[$__hSciTEResponseGUI]) Then
					_SetCurrentPosition($__vSciTEAPI[$__hSciTEResponseGUI])
				EndIf
				$vDummyValue = 'Monitor_Exit_Restart'
				If $bDockSelection Then
					$iTabItem = $eTabOne
					_GUICtrlTab_SetCurFocus($aTabs[$eTabID], $iTabItem)
					Sleep(50)
					ControlClick($__vSciTEAPI[$__hSciTEResponseGUI], '', $__vGUIAPI[$__iGUIDockWindow])
					_IsWrite('IsDocked', True)
				Else
					ExitLoop
				EndIf

			Case $iSciTEActivate
				If $bIsSciTERefresh Then
					ControlClick($__vSciTEAPI[$__hSciTEResponseGUI], '', $__vGUIAPI[$__iGUIRefresh])
				EndIf
				WinActivate($__vSciTEAPI[$__hSciTEWindow])

			Case $iScrollFunctionList
				_IsWrite('MonitorLine', _IsChecked($iScrollFunctionList))
				_Monitor_Check(False, 'Monitor_SettingsChange')

			Case $iSearch
				ControlClick($__vSciTEAPI[$__hSciTEResponseGUI], '', $__vGUIAPI[$__iGUIInputSearch])

			Case $iSearchInputFocus
				$__vMiscAPI[$__bMiscSearchFocus] = _IsChecked($iSearchInputFocus)

				_IsWrite('SearchFocus', $__vMiscAPI[$__bMiscSearchFocus])

			Case $iSearchInComments, $iSearchInFuctions, $iSearchInRegions
				_IsWrite('SearchInComments', _IsChecked($iSearchInComments))
				_IsWrite('SearchInFunctions', _IsChecked($iSearchInFuctions))
				_IsWrite('SearchInRegions', _IsChecked($iSearchInRegions))

				$__vMiscAPI[$__bMiscSearchParams] = 0

				$__vMiscAPI[$__bMiscSearchParams] = BitOR($__vMiscAPI[$__bMiscSearchParams], _IsEx('SearchInComments', 0) * $__iTreeViewIsComment)
				$__vMiscAPI[$__bMiscSearchParams] = BitOR($__vMiscAPI[$__bMiscSearchParams], _IsEx('SearchInFunctions', 1) * ($__iTreeViewIsFunctionOrFile + $__iTreeViewIsCustomFunction))
				$__vMiscAPI[$__bMiscSearchParams] = BitOR($__vMiscAPI[$__bMiscSearchParams], _IsEx('SearchInRegions', 0) * $__iTreeViewIsRegion)

			Case $iSearchUDFs
				$__vMiscAPI[$__bMiscIsSearchUDFs] = _IsChecked($iSearchUDFs)

				_IsWrite('SearchUDFs', $__vMiscAPI[$__bMiscIsSearchUDFs])
				ControlClick($__vSciTEAPI[$__hSciTEResponseGUI], '', $__vGUIAPI[$__iGUIRefresh])

			Case $aContextMenu[$eContextMenuSettings][0]
				$iTabItem = $eTabThree
				_GUICtrlTab_SetCurFocus($aTabs[$eTabID], $iTabItem)
				ContinueLoop

			Case $iSortFunctions
				$__vMiscAPI[$__bMiscIsSort] = _IsChecked($iSortFunctions)

				_IsWrite('Sort', $__vMiscAPI[$__bMiscIsSort])
				ControlClick($__vSciTEAPI[$__hSciTEResponseGUI], '', $__vGUIAPI[$__iGUIRefresh])

			Case $iTreeViewDisableRefresh
				_IsWrite('DisableRefresh', _IsChecked($iTreeViewDisableRefresh))

			Case $iUDF_Add
				If FileCopy($__vCurrentFileAPI[$__sCurrentFilePath], $sIncludePath, Int(_IsChecked($iUDF_Overwrite) And _IsControlEnabled($iUDF_Overwrite))) Then
					_Flash($__vSciTEAPI[$__hSciTEResponseGUI], $COLOR_LIME)
					_Toggle_EnableOrDisable($iUDF_Overwrite, True)
					_Toggle_EnableOrDisable($iUDF_Remove, True)
				Else
					_Flash($__vSciTEAPI[$__hSciTEResponseGUI], $COLOR_RED)
					If FileExists($sIncludePath & '\' & $__vCurrentFileAPI[$__sCurrentFileName]) Then
						_Toggle_EnableOrDisable($iUDF_Overwrite, True)
						_Toggle_EnableOrDisable($iUDF_Remove, True)
					Else
						_Toggle_EnableOrDisable($iUDF_Overwrite, False)
						_Toggle_EnableOrDisable($iUDF_Remove, False)
					EndIf
				EndIf

			Case $iUDF_HeaderSet
				$vDummyValue = GUICtrlRead($iUDF_HeaderName)
				If StringStripWS($vDummyValue, $STR_STRIPALL) = '' Or $sUDF_HeaderName = $vDummyValue Then
					_Flash($__vSciTEAPI[$__hSciTEResponseGUI], $COLOR_RED)
				Else
					_SciTE_SetUDFCreator($sSciTESettings, $vDummyValue)
					If @error Then
						_Flash($__vSciTEAPI[$__hSciTEResponseGUI], $COLOR_RED)
					Else
						_SciTE_ReloadProperties()
						_Flash($__vSciTEAPI[$__hSciTEResponseGUI], $COLOR_LIME)
					EndIf
					$sUDF_HeaderName = $vDummyValue
				EndIf
				$vDummyValue = 0

			Case $iUDF_Remove
				If FileExists($sIncludePath & '\' & $__vCurrentFileAPI[$__sCurrentFileName]) Then
					If FileDelete($sIncludePath & '\' & $__vCurrentFileAPI[$__sCurrentFileName]) And _
							FileExists($sIncludePath & '\' & $__vCurrentFileAPI[$__sCurrentFileName]) = 0 Then
						_Flash($__vSciTEAPI[$__hSciTEResponseGUI], $COLOR_LIME)
						_Toggle_EnableOrDisable($iUDF_Overwrite, False)
						_Toggle_EnableOrDisable($iUDF_Remove, False)
					Else
						_Flash($__vSciTEAPI[$__hSciTEResponseGUI], $COLOR_RED)
						_Toggle_EnableOrDisable($iUDF_Overwrite, True)
						_Toggle_EnableOrDisable($iUDF_Remove, True)
					EndIf
				EndIf

			Case $iUpgrade
				_Toggle_EnableOrDisable($iUpgrade, False)
				If _Update(True) Then
					_WM_COPYDATA_SetID('')
					ExitLoop
				EndIf

			Case $iWM_COPYDATA ; If the WM_COPYDATA message is interecepted then parse the command that was passed.
				$vDummyValue = _SciTE_ParseReturnString(_WM_COPYDATA_GetData(), 2)
				Switch $vDummyValue
					Case 'GUI_Activate'
						If $__vGUIAPI[$__bGUIIsMinimised] Then
							GUISetState(@SW_RESTORE, $__vSciTEAPI[$__hSciTEResponseGUI])
						EndIf

						_GUIInBounds($__vSciTEAPI[$__hSciTEResponseGUI])
						WinActivate($__vSciTEAPI[$__hSciTEResponseGUI])

						If $bIsSciTERefresh Then
							ControlClick($__vSciTEAPI[$__hSciTEResponseGUI], '', $__vGUIAPI[$__iGUIRefresh])
						EndIf
						$bIsSciTERefresh = False

						If $__vMiscAPI[$__bMiscSearchFocus] Then
							; Activate search input for keyboard focus.
							GUICtrlSetState($__vGUIAPI[$__iGUIInputSearch], $GUI_FOCUS)
						EndIf

					Case 'Monitor_Exit'
						; Not used.

					Case 'Monitor_Refresh'
						If Not _IsChecked($iTreeViewDisableRefresh) Then ; Idea by mlipok.
							_Monitor()
						EndIf
						$bIsSciTERefresh = True

					Case Else
						If StringInStr($vDummyValue, 'FunctionToLine:', $STR_NOCASESENSE) Then
							$vDummyValue = StringTrimLeft($vDummyValue, StringLen('FunctionToLine:'))
							$vDummyValue = _GUICtrlTreeView_FindItem($__vGUIAPI[$__iGUITreeView], $vDummyValue)
							_GUICtrlTreeView_EnsureVisible($__vGUIAPI[$__iGUITreeView], $vDummyValue)
							_GUICtrlTreeView_SelectItem($__vGUIAPI[$__iGUITreeView], $vDummyValue, $TVGN_FIRSTVISIBLE)
						EndIf

				EndSwitch
				$vDummyValue = 0

			Case $__vTreeViewParentsAPI[$__iTreeViewParentsFunction]
				_SciTE_GetSelectionStartLine()

			Case $__vTreeViewParentsAPI[$__iTreeViewParentsFindStart] To $__vTreeViewParentsAPI[$__iTreeViewParentsFindEnd]
				$iMsg = Int(StringRegExpReplace($__vTreeViewParentsAPI[$__sTreeViewParentsFind], '[&|\d]*&' & $iMsg & '\|(\d{1,5})[&|\d]*', '\1'))
				If $iMsg Then
					If $__vMiscAPI[$__iMiscAddHeaderOrOpenLocation] Then
						ShellExecute(_WinAPI_PathRemoveFileSpec($__aFindItems[$iMsg][$__iTreeViewSearchBefore]))
					Else
						If FileExists($__aFindItems[$iMsg][$__iTreeViewSearchBefore]) Then
							_SciTE_Open($__aFindItems[$iMsg][$__iTreeViewSearchBefore])
						EndIf
					EndIf
					$__vMiscAPI[$__iMiscAddHeaderOrOpenLocation] = 0
				EndIf
				$iMsg = 0

			Case $__vTreeViewParentsAPI[$__iTreeViewParentsSearchStart] To $__vTreeViewParentsAPI[$__iTreeViewParentsSearchEnd]
				$iMsg = Int(StringRegExpReplace($__vTreeViewParentsAPI[$__sTreeViewParentsSearch], '[&|\d]*&' & $iMsg & '\|(\d{1,5})[&|\d]*', '\1'))
				If $iMsg Then
					If $__vMiscAPI[$__bMiscFunctionSnippet] Then
						$__vMiscAPI[$__bMiscFunctionSnippet] = False
						$vDummyValue = _SciTE_GetText()
						_GetVariablesInFunction($vDummyValue, $__aSearchItems[$iMsg][$__iTreeViewSearchBefore], $vDummyValue)
						If @error Or ClipPut($vDummyValue) = 0 Then ; Retrieve Function Snippet.
							_Flash($__vSciTEAPI[$__hSciTEResponseGUI], $COLOR_RED)
						Else
							_Flash($__vSciTEAPI[$__hSciTEResponseGUI], $COLOR_LIME)
						EndIf
						$vDummyValue = 0
					Else
						If $__vMiscAPI[$__bMiscFindInFile] Then
							If FileExists($__aSearchItems[$iMsg][$__iTreeViewSearchBefore]) Then
								_SciTE_Open($__aSearchItems[$iMsg][$__iTreeViewSearchBefore])
							EndIf
						Else
							If $__aSearchItems[$iMsg][$__iTreeViewItemID] = $__iTreeViewIsCustomFunction Then
								$vFilePathOrLineNumber = StringRegExpReplace($__aSearchItems[$iMsg][$__iTreeViewSearchBefore], '(?m)^(?:\w+)\|(\V+)', '\1') ; FilePath
								$vDummyValue = StringRegExpReplace($__aSearchItems[$iMsg][$__iTreeViewSearchBefore], '(?m)^(\w+)\|(?:\V+)', '\1') ; Function

								; Set last function for the next open file.
								$__aMiscLastFunction.Item($vFilePathOrLineNumber) = _ ; FilePath
										$vDummyValue & '|' & _ ; Function
										$__aSearchItems[$iMsg][$__iTreeViewItemID] & '|1'

								; Set the last function for the current file.
								$__aMiscLastFunction.Item($__vCurrentFileAPI[$__sCurrentFilePath]) = _
										$vDummyValue & '|' & _ ; Function
										$__aSearchItems[$iMsg][$__iTreeViewItemID] & '|0'
								_SciTE_Open($vFilePathOrLineNumber) ; FilePath
								$vFilePathOrLineNumber = 0
								$vDummyValue = 0
							Else
								Switch $__aSearchItems[$iMsg][$__iTreeViewItemID]
									Case $__iTreeViewIsComment
										_SciTE_Find($__aSearchItems[$iMsg][$__iTreeViewSearchBefore])
									Case $__iTreeViewIsFunctionOrFile
										_SciTE_Find('Func ' & $__aSearchItems[$iMsg][$__iTreeViewSearchBefore] & '(')
									Case $__iTreeViewIsRegion
										_SciTE_Find('#region ' & $__aSearchItems[$iMsg][$__iTreeViewSearchBefore] & @CRLF)
								EndSwitch
								$vFilePathOrLineNumber = _SciTE_GetVisibleFromDocLine(_SciTE_GetSelectedLineNumber())
								If $__vMiscAPI[$__bMiscToggleFoldOrNoRefresh] Then
									_SciTE_ToggleFold($vFilePathOrLineNumber)
								EndIf
								_SciTE_GoToLine($vFilePathOrLineNumber)
								If $iIsLineToPixel Then
									$vFilePathOrLineNumber = _GetLineNumberFromPixel($vFilePathOrLineNumber, $iIsLineToPixel)
								EndIf
								_SciTE_SetFirstVisibleLine($vFilePathOrLineNumber)
								If $__vMiscAPI[$__iMiscAddHeaderOrOpenLocation] Then
									_SciTE_Send_Command($__vSciTEAPI[$__hSciTEResponseGUI], $__vSciTEAPI[$__hSciTEDirector], 'menucommand:1134') ; Run Header Function.
								EndIf
							EndIf
						EndIf
					EndIf
					$__vMiscAPI[$__iMiscAddHeaderOrOpenLocation] = 0
					$__aMiscLastFunction.Item($__vCurrentFileAPI[$__sCurrentFilePath]) = $__aSearchItems[$iMsg][$__iTreeViewSearchBefore] & '|' & $__aSearchItems[$iMsg][$__iTreeViewItemID] & '|0'
					$__vMiscAPI[$__bMiscToggleFoldOrNoRefresh] = False
				EndIf
				$iMsg = 0

			Case $__vTreeViewParentsAPI[$__iTreeViewParentsTreeViewStart] To $__vTreeViewParentsAPI[$__iTreeViewParentsTreeViewEnd]
				$iMsg = Int(StringRegExpReplace($__vTreeViewParentsAPI[$__sTreeViewParentsTreeView], '[&|\d]*&' & $iMsg & '\|(\d{1,5})[&|\d]*', '\1'))
				If $__vMiscAPI[$__iMiscAddHeaderOrOpenLocation] = 2 Then
					$__vMiscAPI[$__iMiscAddHeaderOrOpenLocation] = 0
					If $iMsg And $__aTreeViewItems[$iMsg][$__iTreeViewItemID] = $__iTreeViewIsCustomFunction Then
						ShellExecute(_WinAPI_PathRemoveFileSpec(StringRegExpReplace($__aTreeViewItems[$iMsg][$__iTreeViewSearchBefore], '(?m)^(\w+)\|(\V+)', '\2')))
					Else
						ShellExecute($__vCurrentFileAPI[$__sCurrentFileFolder])
					EndIf
					ContinueLoop
				EndIf
				If $iMsg Then
					If $__vMiscAPI[$__bMiscFunctionSnippet] Then
						$__vMiscAPI[$__bMiscFunctionSnippet] = False
						$vDummyValue = _SciTE_GetText()
						_GetVariablesInFunction($vDummyValue, $__aTreeViewItems[$iMsg][$__iTreeViewSearchBefore], $vDummyValue)
						If @error Or ClipPut($vDummyValue) = 0 Then ; Retrieve Function Snippet.
							_Flash($__vSciTEAPI[$__hSciTEResponseGUI], $COLOR_RED)
						Else
							_Flash($__vSciTEAPI[$__hSciTEResponseGUI], $COLOR_LIME)
						EndIf
						$vDummyValue = 0
					Else
						If $__aTreeViewItems[$iMsg][$__iTreeViewItemID] = $__iTreeViewIsCustomFunction Then
							$vFilePathOrLineNumber = StringRegExpReplace($__aTreeViewItems[$iMsg][$__iTreeViewSearchBefore], '(?m)^(?:\w+)\|(\V+)', '\1') ; FilePath
							$vDummyValue = StringRegExpReplace($__aTreeViewItems[$iMsg][$__iTreeViewSearchBefore], '(?m)^(\w+)\|(?:\V+)', '\1') ; Function

							; Set last function for the next open file.
							$__aMiscLastFunction.Item($vFilePathOrLineNumber) = _ ; FilePath
									$vDummyValue & '|' & _ ; Function
									$__aTreeViewItems[$iMsg][$__iTreeViewItemID] & '|1'

							; Set the last function for the current file.
							$__aMiscLastFunction.Item($__vCurrentFileAPI[$__sCurrentFilePath]) = _
									$vDummyValue & '|' & _ ; Function
									$__aTreeViewItems[$iMsg][$__iTreeViewItemID] & '|0'
							_SciTE_Open($vFilePathOrLineNumber) ; FilePath
							$vFilePathOrLineNumber = 0
							$vDummyValue = 0
						Else
							Switch $__aTreeViewItems[$iMsg][$__iTreeViewItemID]
								Case $__iTreeViewIsComment
									_SciTE_Find($__aTreeViewItems[$iMsg][$__iTreeViewSearchBefore])
								Case $__iTreeViewIsFunctionOrFile
									_SciTE_Find('Func ' & $__aTreeViewItems[$iMsg][$__iTreeViewSearchBefore] & '(')
								Case $__iTreeViewIsRegion
									_SciTE_Find('#region ' & $__aTreeViewItems[$iMsg][$__iTreeViewSearchBefore] & @CRLF)
							EndSwitch
							$vFilePathOrLineNumber = _SciTE_GetVisibleFromDocLine(_SciTE_GetSelectedLineNumber())
							If $__vMiscAPI[$__bMiscToggleFoldOrNoRefresh] Then
								_SciTE_ToggleFold($vFilePathOrLineNumber)
							EndIf
							_SciTE_GoToLine($vFilePathOrLineNumber)
							If $iIsLineToPixel Then
								$vFilePathOrLineNumber = _GetLineNumberFromPixel($vFilePathOrLineNumber, $iIsLineToPixel)
							EndIf
							_SciTE_SetFirstVisibleLine($vFilePathOrLineNumber)
							If $__vMiscAPI[$__iMiscAddHeaderOrOpenLocation] Then
								_SciTE_Send_Command($__vSciTEAPI[$__hSciTEResponseGUI], $__vSciTEAPI[$__hSciTEDirector], 'menucommand:1134') ; Run Header Function.
							EndIf
						EndIf
					EndIf
					$__vMiscAPI[$__iMiscAddHeaderOrOpenLocation] = 0
					$__aMiscLastFunction.Item($__vCurrentFileAPI[$__sCurrentFilePath]) = $__aTreeViewItems[$iMsg][$__iTreeViewSearchBefore] & '|' & $__aTreeViewItems[$iMsg][$__iTreeViewItemID] & '|0'
					$__vMiscAPI[$__bMiscToggleFoldOrNoRefresh] = False
				EndIf
				$iMsg = 0

		EndSwitch
	WEnd
	GUISetState(@SW_HIDE, $__vSciTEAPI[$__hSciTEResponseGUI])

	_SaveSciTEPath()
	If Not _IsMinimized($__vSciTEAPI[$__hSciTEResponseGUI]) Then
		_SetCurrentPosition($__vSciTEAPI[$__hSciTEResponseGUI])
	EndIf

	Local Const $bRestart = $vDummyValue == 'Monitor_Exit_Restart'
	$sReturn = ''
	$vDummyValue = ''
	$iCount = _GUICtrlComboBox_GetCount($iComboHistory)
	If $iCount > 0 Then
		For $i = 0 To $iCount - 1
			_GUICtrlComboBox_GetLBText($iComboHistory, $i, $vDummyValue)
			$sReturn &= $vDummyValue & '|'
		Next
		$sReturn &= GUICtrlRead($iComboHistory)
	EndIf
	$vDummyValue = 0

	IniWrite($__sScriptDir & '\Settings.ini', 'General', 'History', $sReturn)
	IniWrite($__sScriptDir & '\Settings.ini', 'General', 'SearchFileTypes', GUICtrlRead($aSearchInput[$eSearchInputFileTypes]))
	GUIDelete($__vSciTEAPI[$__hSciTEResponseGUI])

	If $bRestart Then
		OnAutoItExitUnRegister('_Exit')
		Exit Run('"' & @ScriptFullPath & '"' & ' /Restart "' & $sSciTEPath & '"', @ScriptDir & '\', @SW_SHOW)
	EndIf
EndFunc   ;==>_Main

Func _AddToSciTEJump($bWrite = True)
	Local Const $sScriptDir = _SciTE_GetSciTEDefaultHome()
	Local $sSciTEUser = $sScriptDir
	If _IsInstalled() Then
		$sSciTEUser = @UserProfileDir
	EndIf

	Local Const $sData = _GetFile($sScriptDir & '\properties\au3.properties') & @CRLF & _GetFile($sSciTEUser & '\SciTEUser.properties')
	Local Const $sProgramName = _ProgramName()
	Local $bIsSciTEJump = StringRegExp($sData, '(?im)^command\.name\.\d+\.\$\(au3\)=' & $sProgramName) = 1, _
			$iIndex = -1
	If Not $bIsSciTEJump And $bWrite Then
		Local $aReturn = StringRegExp('command.0.iCount' & @CRLF & $sData, '(?im)^command\.(?:name\.)?(\d+)\.', 3), _
				$bSwapped = False, $iValue = 0
		$aReturn[0] = UBound($aReturn) - 1
		If $aReturn[0] Then
			Do ; Bubble sort.
				$bSwapped = False
				For $i = 2 To $aReturn[0]
					$aReturn[$i] = Int($aReturn[$i])
					$iIndex = $i - 1
					If $aReturn[$iIndex] > $aReturn[$i] Then
						$iValue = $aReturn[$iIndex]
						$aReturn[$iIndex] = $aReturn[$i]
						$aReturn[$i] = $iValue
						$bSwapped = True
					EndIf
				Next
			Until Not $bSwapped
			$iIndex = $aReturn[$aReturn[0]] + 1
		EndIf
	EndIf

	If $bWrite And $iIndex > -1 Then
		$bIsSciTEJump = _SetFile('# ' & $iIndex & ' guinness ' & $sProgramName & @CRLF & _
				'command.' & $iIndex & '.$(au3)="$(SciteDefaultHome)\' & $sProgramName & '\' & $sProgramName & '.exe"' & @CRLF & _
				'command.name.' & $iIndex & '.$(au3)=' & $sProgramName & @CRLF & _
				'command.shortcut.' & $iIndex & '.$(au3)=Alt+Q' & @CRLF & _
				'command.subsystem.' & $iIndex & '.$(au3)=2' & @CRLF & _
				'command.save.before.' & $iIndex & '.$(au3)=2' & @CRLF & _
				'command.replace.selection.' & $iIndex & '.$(au3)=0' & @CRLF & _
				'command.quiet.' & $iIndex & '.$(au3)=1' & @CRLF, $sSciTEUser & '\SciTEUser.properties')
	EndIf
	Return $bIsSciTEJump
EndFunc   ;==>_AddToSciTEJump

Func _ArrayListView($hWnd, ByRef Const $aArray, $bIsCheckBoxes, $sHeader = '', $sTitle = 'Array Display', $sBeforeString = '', $sAfterString = '', $iCaseSensitive = 1, $iRegularExpression = 0)
	Local Const $iHeight = 200, $iWidth = 510
	Local $aReturn[$aArray[0][0] + 1] = [0], _
			$iDeSelectAll = -99, $iError = 0, $iListViewStyleEx = Default, $iSelectAll = -99

	If $aArray[0][0] = 0 Then
		Return SetError(1, 0, 0)
	EndIf

	$__vMiscAPI[$__iMiscAddHeaderOrOpenLocation] = -1 ; Reset for use with WinMerge.
	If IsHWnd($hWnd) = 0 Then
		$hWnd = WinGetHandle(AutoItWinGetTitle())
	EndIf

	If StringStripWS($sHeader, $STR_STRIPALL) = '' Or $sHeader = Default Then
		For $i = 1 To $aArray[0][1]
			$sHeader &= 'Column ' & $i & '|'
		Next
	EndIf
	If StringStripWS($sTitle, $STR_STRIPALL) = '' Or $sTitle = Default Then
		$sTitle = 'Array Display'
	EndIf

	If $bIsCheckBoxes Then
		$iListViewStyleEx = BitOR($LVS_EX_CHECKBOXES, $LVS_EX_FULLROWSELECT)
	Else
		$iListViewStyleEx = Default
	EndIf

	Local Const $hGUI = GUICreate($sTitle, $iWidth, $iHeight, Default, Default, BitOR($GUI_SS_DEFAULT_GUI, $WS_MAXIMIZEBOX, $WS_SIZEBOX), Default, $hWnd)
	$__vGUIAPI[$__iGUIArrayListView] = GUICtrlCreateListView(StringTrimRight($sHeader, 1), 0, 0, $iWidth, $iHeight - 35, Default, $iListViewStyleEx)
	Local Const $hListView = GUICtrlGetHandle($__vGUIAPI[$__iGUIArrayListView])
	GUICtrlSetResizing($__vGUIAPI[$__iGUIArrayListView], $GUI_DOCKBORDERS)

	If $bIsCheckBoxes Then
		$iSelectAll = GUICtrlCreateButton(_GetLanguage('SELECT_ALL', 'Select All'), 5, $iHeight - 30, 85, 25)
		GUICtrlSetResizing($iSelectAll, $GUI_DOCKLEFT + $GUI_DOCKSIZE + $GUI_DOCKBOTTOM)
		$iDeSelectAll = GUICtrlCreateButton(_GetLanguage('DESELECT_ALL', 'De-Select All'), 90, $iHeight - 30, 85, 25)
		GUICtrlSetResizing($iDeSelectAll, $GUI_DOCKLEFT + $GUI_DOCKSIZE + $GUI_DOCKBOTTOM)
	EndIf

	Local Const $iCopyAll = GUICtrlCreateButton(_GetLanguage('COPY_ALL', 'Copy All'), $iWidth - 270, $iHeight - 30, 85, 25)
	GUICtrlSetResizing($iCopyAll, $GUI_DOCKRIGHT + $GUI_DOCKSIZE + $GUI_DOCKBOTTOM)
	Local Const $iCopySelected = GUICtrlCreateButton(_GetLanguage('COPY_SELECTED', 'Copy Selected'), $iWidth - 180, $iHeight - 30, 85, 25)
	GUICtrlSetResizing($iCopySelected, $GUI_DOCKRIGHT + $GUI_DOCKSIZE + $GUI_DOCKBOTTOM)
	Local Const $iOK = GUICtrlCreateButton(_GetLanguage('OK', 'OK'), $iWidth - 90, $iHeight - 30, 85, 25)
	GUICtrlSetResizing($iOK, $GUI_DOCKRIGHT + $GUI_DOCKSIZE + $GUI_DOCKBOTTOM)

	_GUICtrlListView_BeginUpdate($__vGUIAPI[$__iGUIArrayListView])

	For $i = 1 To $aArray[0][0]
		$sHeader = ''
		For $j = 0 To $aArray[0][1] - 1
			$sHeader &= $aArray[$i][$j] & '|'
		Next
		GUICtrlCreateListViewItem(StringTrimRight($sHeader, 1), $__vGUIAPI[$__iGUIArrayListView])
		If $bIsCheckBoxes Then
			_GUICtrlListView_SetItemChecked($hListView, $i - 1)
		EndIf
	Next

	_GUICtrlListView_EndUpdate($__vGUIAPI[$__iGUIArrayListView])

	For $i = 0 To $aArray[0][1] - 1
		_GUICtrlListView_SetColumnWidth($hListView, $i, $LVSCW_AUTOSIZE)
	Next

	GUISetState(@SW_SHOW, $hGUI)

	While 1
		If $__vMiscAPI[$__iMiscAddHeaderOrOpenLocation] >= 0 Then
			_ReplaceInFileCompare(_GUICtrlListView_GetItemText($__vGUIAPI[$__iGUIArrayListView], $__vMiscAPI[$__iMiscAddHeaderOrOpenLocation]), $GUI_NO_INDEX, $sBeforeString, $sAfterString, $iCaseSensitive, $iRegularExpression)
			$__vMiscAPI[$__iMiscAddHeaderOrOpenLocation] = -1
		EndIf
		Switch GUIGetMsg()
			Case $GUI_EVENT_CLOSE
				$iError = 1
				ExitLoop

			Case $iOK
				ExitLoop

			Case $iCopyAll
				$sHeader = ''
				For $i = 1 To $aArray[0][0]
					For $j = 0 To $aArray[0][1] - 1
						$sHeader &= $aArray[$i][$j] & '|'
					Next
					$sHeader = StringTrimRight($sHeader, 1) & @CRLF
				Next
				If ClipPut($sHeader) Then
					_Flash($hGUI, $COLOR_LIME)
				Else
					_Flash($hGUI, $COLOR_RED)
				EndIf

			Case $iCopySelected
				$sHeader = _GUICtrlListView_GetItemTextString($hListView, _GUICtrlListView_GetSelectionMark($hListView))
				If Not (StringStripWS(StringReplace($sHeader, '|', '', 0, $STR_NOCASESENSE), $STR_STRIPALL) == '') Then
					If ClipPut($sHeader) Then
						_Flash($hGUI, $COLOR_LIME)
					Else
						_Flash($hGUI, $COLOR_RED)
					EndIf
				Else
					_Flash($hGUI, $COLOR_RED)
				EndIf

			Case $iSelectAll
				_GUICtrlListView_SetCheckedStates($hListView, 1)

			Case $iDeSelectAll
				_GUICtrlListView_SetCheckedStates($hListView, 0)

		EndSwitch
	WEnd

	If $bIsCheckBoxes Then
		For $i = 0 To $aArray[0][0] - 1
			If _GUICtrlListView_GetItemChecked($hListView, $i) Then
				$aReturn[0] += 1
				$aReturn[$aReturn[0]] = $aArray[$i + 1][0]
			EndIf
		Next
	EndIf

	$__vGUIAPI[$__iGUIArrayListView] = 0
	$__vMiscAPI[$__iMiscAddHeaderOrOpenLocation] = 0
	_GUICtrlListView_DeleteAllItems($hListView)
	GUIDelete($hGUI)
	GUISwitch($hWnd)
	If $aReturn[0] = 0 Then
		$iError = 1
	EndIf

	Return SetError($iError, 0, $aReturn)
EndFunc   ;==>_ArrayListView

Func _ByteSuffix($iBytes, $iRound = 2) ; By Spiff59
	Local Const $aArray[9] = [' bytes', ' KB', ' MB', ' GB', ' TB', ' PB', ' EB', ' ZB', ' YB']
	Local $iIndex = 0
	While $iBytes > 1023
		$iIndex += 1
		$iBytes /= 1024
	WEnd
	Return Round($iBytes, $iRound) & $aArray[$iIndex]
EndFunc   ;==>_ByteSuffix

Func _ClientToScreen($hWnd, ByRef $iX, ByRef $iY)
	Local $tPOINT = DllStructCreate($tagPOINT)
	DllStructSetData($tPOINT, 'X', $iX)
	DllStructSetData($tPOINT, 'Y', $iY)
	_WinAPI_ClientToScreen($hWnd, $tPOINT)
	$iX = DllStructGetData($tPOINT, 'X')
	$iY = DllStructGetData($tPOINT, 'Y')
EndFunc   ;==>_ClientToScreen

Func _CreateJumpArray(ByRef $aAllAnchors, ByRef $sData)
	_StripEmptyLines($sData)
	_GetComments($sData, $aAllAnchors, $__iTreeViewIsComment)
	_GetFunctions($sData, $aAllAnchors, $__iTreeViewIsFunctionOrFile, _IsEx('Sort', 0) = 1)
	_GetRegions($sData, $aAllAnchors, $__iTreeViewIsRegion)
	If $__vMiscAPI[$__bMiscIsSearchUDFs] Then
		Local $sIncludeParent = '', $sIncludeString = '', $sMerged = ''
		_GetIncludesArray($__vCurrentFileAPI[$__sCurrentFilePath], $sData, $sMerged, $aAllAnchors, $sIncludeString, $sIncludeParent, $__iTreeViewIsCustomFunction)
	EndIf
	Return $aAllAnchors
EndFunc   ;==>_CreateJumpArray

Func _CreateTreeView()
	Local Const $iTreeView = GUICtrlCreateTreeView(10, 70, $__vGUIAPI[$__iGUIWidth] - 20, $__vGUIAPI[$__iGUIHeight] - 125, BitOR($TVS_HASBUTTONS, $TVS_HASLINES, $TVS_LINESATROOT, $TVS_DISABLEDRAGDROP, $TVS_SHOWSELALWAYS), $WS_EX_CLIENTEDGE)
	GUICtrlSetResizing($iTreeView, $GUI_DOCKBORDERS)
	GUICtrlSetState($iTreeView, $GUI_DROPACCEPTED)
	Return $iTreeView
EndFunc   ;==>_CreateTreeView

Func _EnumArray2D(ByRef $aArray, $iBefore = 3, $iStart = 1)
	$iStart = $iBefore + $iStart
	For $i = 0 To UBound($aArray, 1) - 1
		For $j = 0 To UBound($aArray, 2) - 1
			$aArray[$i][$j] = $iStart
		Next
		$iStart += 1
	Next
	Return $iStart - 1
EndFunc   ;==>_EnumArray2D

Func _Exit()
	If $__vSciTEWindow Then
		WinSetState($__vSciTEAPI[$__hSciTEWindow], '', @SW_MAXIMIZE)
	Else
		If UBound($__vSciTEWindow) Then
			WinMove($__vSciTEAPI[$__hSciTEWindow], '', $__vSciTEWindow[0], $__vSciTEWindow[1], $__vSciTEWindow[2], $__vSciTEWindow[3])
		EndIf
	EndIf
	If FileExists($__sScriptDir & '\WinMergeTemp') Then
		DirRemove($__sScriptDir & '\WinMergeTemp', 1)
	EndIf

	_Monitor_Check(True)
	_SciTE_Shutdown()
	_WM_COPYDATA_Shutdown()
	Exit
EndFunc   ;==>_Exit

Func _Export_FunctionRegionList($sFilePath, $sFileName, $iFileSize, $sFileFolder, $iControlID = $GUI_NO_INDEX)
	Local $iCountFunctions = 0, $iCountFunctionsUnUsed = 0, $iCountRegions = 0, _
			$sEndFunctions = '', $sEndRegions = '', $sStartFunctions = '', $sStartRegions = ''

	If _IsEmpty($sFilePath) Then
		Return SetError(1, 0, False)
	EndIf

	Local $sUnUsedFunctions = '# ' & StringUpper(_GetLanguage('TIP_EXPORT_3', 'Functions UnUsed')) & ' #' & @CRLF
	Local $sData = _GetFile($sFilePath)
	Local Const $aIncludes = _GetIncludeInfo($sData, $sFilePath, True)
	For $i = 1 To $aIncludes[0]
		$sData &= _GetFile($aIncludes[$i]) & @CRLF
	Next

	$sData = @CRLF & $sData & @CRLF
	Local $aArray = _GetFunctionsInFunctions($sData)
	For $i = 1 To $aArray[0]
		$sStartRegions &= $aArray[$i] & @CRLF
	Next
	$aArray = 0

	$sData = $sStartRegions & @CRLF & $sData & @CRLF
	$sStartRegions = ''
	_StripWhitespace($sData)
	_StripEmptyLines($sData)
	_StripStringLiterals($sData)
	_StripCommentLines($sData)
	_StripFunctionsEnd($sData)

	For $i = 1 To $__aTreeViewItems[0][0]
		Switch $__aTreeViewItems[$i][$__iTreeViewItemID]
			Case $__iTreeViewIsFunctionOrFile
				$iCountFunctions += 1
				$sEndFunctions &= '> ' & $__aTreeViewItems[$i][$__iTreeViewSearchBefore] & ' => ' & @CRLF
				$sData = StringRegExpReplace($sData, '\b' & $__aTreeViewItems[$i][$__iTreeViewSearchBefore] & '\b', '')
				If @extended <= 1 Then
					$iCountFunctionsUnUsed += 1
					$sUnUsedFunctions &= $__aTreeViewItems[$i][$__iTreeViewSearchBefore] & @CRLF
				EndIf
			Case $__iTreeViewIsRegion
				$iCountRegions += 1
				$sEndRegions &= '> ' & $__aTreeViewItems[$i][$__iTreeViewSearchBefore] & ' => ' & @CRLF
		EndSwitch
	Next
	$sData = ''

	If $iCountFunctions Then
		_SetCustomVariable(1, $iCountFunctions)
		$sStartFunctions = '# ' & StringUpper(_GetLanguage('TIP_EXPORT_1', 'Total number of functions - %TOTALNUMBER%')) & ' #' & @CRLF
		$sEndFunctions &= @CRLF
	Else
		$sStartFunctions = ''
		$sEndFunctions = ''
	EndIf

	If $iCountFunctionsUnUsed Then
		$sUnUsedFunctions &= @CRLF
	Else
		$sUnUsedFunctions = ''
	EndIf

	If $iCountRegions Then
		_SetCustomVariable(1, $iCountRegions)
		$sStartRegions = '# ' & StringUpper(_GetLanguage('TIP_EXPORT_4', 'Total number of regions - %TOTALNUMBER%')) & ' #' & @CRLF
		$sEndRegions &= @CRLF
	Else
		$sStartRegions = ''
		$sEndRegions = ''
	EndIf

	_SetCustomVariable(2, @MDAY & '/' & @MON & '/' & @YEAR)
	Local $sStart = _
			'# -------------------------------- #' & @CRLF & _
			@TAB & StringUpper(_GetLanguage('NAME', 'Name')) & ': ' & $sFileName & @CRLF & _
			@TAB & StringUpper(_GetLanguage('PATH', 'Path')) & ': ' & $sFilePath & @CRLF & _
			@TAB & StringUpper(_GetLanguage('SIZE', 'Size')) & ': ' & _ByteSuffix($iFileSize, 0) & @CRLF & _
			@TAB & StringUpper(_GetLanguage('LINE_COUNT', 'Line Count')) & ': ' & _SciTE_GetLineCount() & @CRLF & _
			@TAB & StringUpper(_GetLanguage('CRC32', 'CRC32')) & ': ' & StringRight(_CRC32ForFile($sFilePath), 8) & @CRLF & _
			@TAB & StringUpper(_GetLanguage('TIP_EXPORT_2', 'Created on the %CREATIONDATE%')) & @CRLF & _
			'# -------------------------------- #' & @CRLF & @CRLF

	$sStart &= $sStartFunctions & $sEndFunctions & $sUnUsedFunctions & $sStartRegions & $sEndRegions
	_SetFile($sStart, $sFileFolder & '\FunctionList.txt', $FO_APPEND)

	Local Const $sCmdLine = '\MonitorFileInfo "<filepath>' & $sFilePath & '</filepath>' & _
			'<functionlist>' & $sFileFolder & '\FunctionList.txt' & '</functionlist>"'
	Local Const $iPID = _RunAu3($__sScriptDir & '\Bin\Monitor.a3x', $sCmdLine, $__sScriptDir)
	While Sleep(250) * ProcessExists($iPID)
		If $iControlID > 0 And _IsChecked($iControlID) Then
			ProcessClose($iPID)
			ExitLoop
		EndIf
	WEnd
	Return True
EndFunc   ;==>_Export_FunctionRegionList

Func _Find($sFindText, $sDirectory)
	_FindCreate()
	$__vTreeViewParentsAPI[$__sTreeViewParentsFind] = ''

	$__vTreeViewParentsAPI[$__iTreeViewParentsFind] = GUICtrlCreateTreeViewItem(_GetLanguage('TIP_SEARCH_1', 'Search results'), $__vGUIAPI[$__iGUITreeViewFind])
	_LanguageAdd($__aLanguageItems, $LANGAUGE_ITEMS_PARENTSFIND, $__vTreeViewParentsAPI[$__iTreeViewParentsFind], 'TIP_SEARCH_1', 'Search results')

	Local Const $aSearch = _FileSearch($sDirectory, '*.*', $__vGUIAPI[$__iGUIRefresh])
	Local $aReturn[1][2] = [[0, 2]]
	If $sFindText = '' Then
		ReDim $aReturn[$aSearch[0] + 1][$aReturn[0][1]]
		For $i = 1 To $aSearch[0]
			If _IsValidFileType($aSearch[$i], 'au3') Then
				$aReturn[0][0] += 1
				$aReturn[$aReturn[0][0]][0] = $aSearch[$i]
			EndIf
		Next
	Else
		_ReplaceInFiles($__vGUIAPI[$__iGUIRefresh], $aReturn, $aSearch, $sFindText, $sFindText, False, $SCITE_JUMP_SCRIPTS, 0, 0)
		If @error Then
			$aReturn = 0
			Return SetError(1, 0, False)
		EndIf
	EndIf

	If $aReturn[0][0] = 0 Then
		$aReturn = 0
		GUICtrlSetState($__vTreeViewParentsAPI[$__iTreeViewParentsFind], BitOR($GUI_EXPAND, $GUI_DEFBUTTON))
		$__aFindItems[0][0] = 1
		$__vTreeViewParentsAPI[$__iTreeViewParentsFindStart] = GUICtrlCreateTreeViewItem(_GetLanguage('TIP_SEARCH_2', 'No search results'), $__vGUIAPI[$__iGUITreeViewFind])
		$__vTreeViewParentsAPI[$__iTreeViewParentsFindEnd] = $__vTreeViewParentsAPI[$__iTreeViewParentsFindStart]
		_LanguageAdd($__aLanguageItems, $LANGAUGE_ITEMS_PARENTSFINDSTART, $__vTreeViewParentsAPI[$__iTreeViewParentsFindStart], 'TIP_SEARCH_2', 'No search results')
		Return SetError(2, 0, False)
	EndIf
	_LanguageAdd($__aLanguageItems, $LANGAUGE_ITEMS_PARENTSFINDSTART, '', '', '')

	_GUICtrlTreeView_BeginUpdate($__vGUIAPI[$__iGUITreeViewCurrent])

	$__aFindItems[0][0] = $aReturn[0][0]
	_ReDim($__aFindItems, $__vTreeViewParentsAPI[$__iTreeViewParentsFindReDim])

	For $i = 1 To $aReturn[0][0]
		$__aFindItems[$i][$__iTreeViewSearchBefore] = $aReturn[$i][0]
		$__aFindItems[$i][$__iTreeViewItemID] = $__iTreeViewIsFunctionOrFile

		$aReturn[$i][0] = GUICtrlCreateTreeViewItem(_WinAPI_PathStripPath($aReturn[$i][0]), $__vTreeViewParentsAPI[$__iTreeViewParentsFind])
		$__vTreeViewParentsAPI[$__sTreeViewParentsFind] &= '&' & $aReturn[$i][0] & '|' & $i ; Add to the message id string.
	Next
	$__vTreeViewParentsAPI[$__iTreeViewParentsFindStart] = $aReturn[1][0]
	$__vTreeViewParentsAPI[$__iTreeViewParentsFindEnd] = $aReturn[$aReturn[0][0]][0]
	$__vTreeViewParentsAPI[$__sTreeViewParentsFind] &= '&'
	$aReturn = 0

	_GUICtrlTreeView_EndUpdate($__vGUIAPI[$__iGUITreeViewCurrent])

	GUICtrlSetState($__vTreeViewParentsAPI[$__iTreeViewParentsFind], BitOR($GUI_EXPAND, $GUI_DEFBUTTON))
	Return True
EndFunc   ;==>_Find

Func _FindCreate($bSetCurrent = Default)
	If $__vGUIAPI[$__iGUITreeViewFind] = 0 Then
		$__vGUIAPI[$__iGUITreeViewFind] = _CreateTreeView()
	EndIf
	If $bSetCurrent Or $bSetCurrent = Default Then
		_TreeView_SetCurrent($__vGUIAPI[$__iGUITreeViewFind])
	Else
		_Toggle_ShowOrHide($__vGUIAPI[$__iGUITreeViewFind], False)
	EndIf
EndFunc   ;==>_FindCreate

Func _FindDestroy($bReset = Default)
	_Toggle_ShowOrHide($__vGUIAPI[$__iGUITreeViewFind], False)
	_GUICtrlTreeView_DeleteAll($__vGUIAPI[$__iGUITreeViewFind])
	GUICtrlDelete($__vTreeViewParentsAPI[$__iTreeViewParentsFind])
	$__vTreeViewParentsAPI[$__iTreeViewParentsFind] = 0
	_TreeView_Delete($__vTreeViewParentsAPI[$__sTreeViewParentsFind], 3)
	$__vMiscAPI[$__bMiscFindInFile] = False
	If $bReset Or $bReset = Default Then
		$__aFindItems[0][0] = 0
		$__vTreeViewParentsAPI[$__iTreeViewParentsFindStart] = $GUI_NO_INDEX
		$__vTreeViewParentsAPI[$__iTreeViewParentsFindEnd] = $GUI_NO_INDEX
	EndIf
EndFunc   ;==>_FindDestroy

Func _Flash($hWnd, $dColor)
	For $i = 1 To 2
		If Mod($i, 2) Then ; Odd.
			GUISetBkColor($dColor, $hWnd)
		Else ; Even.
			GUISetBkColor(_WinAPI_GetSysColor($COLOR_MENU), $hWnd)
		EndIf
		Sleep(100)
	Next
EndFunc   ;==>_Flash

Func _GetCurrentPosition(ByRef $iLeft, ByRef $iTop)
	Local Const $aControl = ControlGetPos($__vSciTEAPI[$__hSciTEWindow], '', '[CLASS:Scintilla; INSTANCE:1]')
	If @error Then
		$__vGUIAPI[$__iGUIWidth] = 215 ; Width.
		$__vGUIAPI[$__iGUIHeight] = @DesktopHeight - 215 ; Height.
		$iLeft = @DesktopWidth - $__vGUIAPI[$__iGUIWidth] - 25
		$iTop = (@DesktopHeight / 2) - ($__vGUIAPI[$__iGUIHeight] / 2)
	Else
		$__vGUIAPI[$__iGUIWidth] = 215 ; Width.
		$__vGUIAPI[$__iGUIHeight] = $aControl[3] - 50 ; Height.
		$iLeft = @DesktopWidth - $__vGUIAPI[$__iGUIWidth] - 25
		$iTop = $aControl[1] + 50
	EndIf

	Local Const $sINI = $__sScriptDir & '\Settings.ini'
	If $__vGUIAPI[$__iGUIHeight] < 560 Then
		$__vGUIAPI[$__iGUIHeight] = 560
	EndIf
	$__vGUIAPI[$__iGUIWidth] = IniRead($sINI, 'General', 'SizeW', $__vGUIAPI[$__iGUIWidth]) ; Width.
	$__vGUIAPI[$__iGUIHeight] = IniRead($sINI, 'General', 'SizeH', $__vGUIAPI[$__iGUIHeight]) ; Height.
	$iLeft = IniRead($sINI, 'General', 'PosX', $iLeft)
	$iTop = IniRead($sINI, 'General', 'PosY', $iTop)

	$__vGUIAPI[$__iGUIMinWidth] = 215 ; Minimum Width.
	$__vGUIAPI[$__iGUIMinHeight] = $__vGUIAPI[$__iGUIHeight] ; Minimum Height.
EndFunc   ;==>_GetCurrentPosition

Func _GetInstalledSettingsDir()
	Local Const $sProgramName = _ProgramName()
	Local $sSciTESettings = '', $sSettingsDir = ''
	_SciTE_SettingsDir($sSettingsDir, $sProgramName, $sSciTESettings)
	If _IsInstalled() Then ; If AutoIt & SciTE is installed then use the application directory instead.
		; Before SciTE Jump v2.17.
		If FileExists(@AppDataDir & '\' & $sProgramName) Then DirMove(@AppDataDir & '\' & $sProgramName, $sSettingsDir, $FC_OVERWRITE)
		; Copy the settings file and Monitor.a3x if it doesn't exist.
		If FileExists($sSettingsDir & '\Settings.ini') = 0 Then FileCopy(@ScriptDir & '\Settings.ini', $sSettingsDir & '\Settings.ini', $FC_OVERWRITE + $FC_CREATEPATH)
		If FileExists($sSettingsDir & '\Bin\Monitor.a3x') = 0 Then FileCopy(@ScriptDir & '\Bin\Monitor.a3x', $sSettingsDir & '\Bin\Monitor.a3x', $FC_OVERWRITE + $FC_CREATEPATH)
		If FileExists($sSettingsDir) = 0 Then DirCreate($sSettingsDir) ; Check the settings directory exists.
	EndIf
	Return $sSettingsDir
EndFunc   ;==>_GetInstalledSettingsDir

Func _GetLineNumberFromPixel($iLineNumber, $iPixels = Default)
	If $iPixels = Default Then
		$iPixels = 180
	EndIf
	Local $iVisibleLineNumber = _SciTE_GetFirstVisibleLine()
	Local Const $aSize = WinGetClientSize($__vSciTEAPI[$__hSciTEEdit])
	If @error Then
		Return $iLineNumber
	EndIf
	If $iPixels >= $aSize[1] Then
		Return $iLineNumber
	EndIf
	Local Const $iPixelPerLine = Floor($aSize[1] / Ceiling(_SciTE_LinesOnScreen()))
	Local Const $iPixelLinesFromTop = ($iLineNumber - $iVisibleLineNumber) * $iPixelPerLine
	Local Const $iLineDifference = Floor(($iPixels - $iPixelLinesFromTop) / $iPixelPerLine)

	If $iLineDifference < 0 Then
		$iVisibleLineNumber += Abs($iLineDifference)
	Else
		$iVisibleLineNumber -= Abs($iLineDifference)
	EndIf
	Return $iVisibleLineNumber
EndFunc   ;==>_GetLineNumberFromPixel

Func _GetOSArch()
	Return '_x' & StringRegExpReplace(@OSArch, '(?i)x86|\D+', '') ; Thanks to wraithdu.
EndFunc   ;==>_GetOSArch

Func _GetRelativePath($sFrom, $sTo)
	Local Const $iIsFolder = Int(_WinAPI_PathIsDirectory($sTo) > 0)
	If $iIsFolder Then
		$sTo = _WinAPI_PathAddBackslash($sTo)
	EndIf
	If _WinAPI_PathIsDirectory($sFrom) = 0 Then
		$sFrom = _WinAPI_PathRemoveFileSpec($sFrom)
	EndIf
	Local $sRelativePath = _WinAPI_PathRelativePathTo(_WinAPI_PathAddBackslash($sFrom), 1, $sTo, $iIsFolder) ; Retrieve the relative path.
	If @error Then
		Return SetError(1, 0, $sTo)
	EndIf
	If $sRelativePath = '.' Then
		$sRelativePath &= '\' ; This is used when the source and destination are the same directory.
	EndIf
	Return $sRelativePath
EndFunc   ;==>_GetRelativePath

Func _GetTitle()
	Return _ProgramName() & (@AutoItX64 ? ' (64-bit)' : '') & (_IsInstalled() ? '' : ' (Portable)')
EndFunc   ;==>_GetTitle

Func _GUICtrlButton_ContextMenuEx($hWnd, $iControlID, $iContextMenu)
	Local Const $hMenu = GUICtrlGetHandle($iContextMenu)
	Local $aControlGetPos = ControlGetPos($hWnd, '', $iControlID)
	$aControlGetPos[1] += $aControlGetPos[3]
	_ClientToScreen($hWnd, $aControlGetPos[0], $aControlGetPos[1])
	_GUICtrlMenu_TrackPopupMenu($hMenu, $hWnd, $aControlGetPos[0], $aControlGetPos[1])
EndFunc   ;==>_GUICtrlButton_ContextMenuEx

; $iType: 0 - UnCheck all, 1 - Check all & 2 - Invert selection.
Func _GUICtrlListView_SetCheckedStates($hListView, $iType) ; By Zedna, modified by guinness.
	Local $bState = False
	If $iType < 0 Or $iType > 2 Then
		Return SetError(1, 0, False)
	EndIf
	If $iType Then
		$bState = True
	EndIf
	For $i = 0 To _GUICtrlListView_GetItemCount($hListView) - 1
		If $iType = 2 Then
			$bState = (Not _GUICtrlListView_GetItemChecked($hListView, $i)) ; Invert checked state with $iType 2.
		EndIf
		_GUICtrlListView_SetItemChecked($hListView, $i, $bState)
	Next
	Return True
EndFunc   ;==>_GUICtrlListView_SetCheckedStates

Func _GUICtrlTreeView_ContextMenu($hGUI, $iIndex, $iSubItem, $iMode = 1) ; 0 = Find In Files ContextMenu, 1 = TreeView Items ContextMenu, 2 = Search ContextMenu, 3 = TreeView Items (Basic) ContextMenu, 4 = Array Display
	Local Enum $iContextItem1 = 1000, $iContextItem2, $iContextItem3, $iContextItem4, $iContextItem5, $iContextItem6
	Local Const $iExportUbound = 6
	Local $aContextMenuExport[$iExportUbound + 1][3], $hContextMenu, $hContextSubMenu, $iControlID, $iError = 1
	Local Const $aExport[$iExportUbound + 1][3] = [['HTML', 'HTML', 1], ['LATEX', 'LATEX', 2], ['PDF', 'PDF', 3], ['RTF', 'RTF', 4], ['XML', 'XML', 5], ['', '', ''], ['FUNCTION_LIST', 'Function and Region list', 6]], _
			$bIsAutoIt = _IsValidFileType($__vCurrentFileAPI[$__sCurrentFilePath], 'au3') = 1

	If $iMode = 1 Then
		_EnumArray2D($aContextMenuExport, 1005, 1)
		For $i = 0 To $iExportUbound
			$aContextMenuExport[$i][1] = _GetLanguage($aExport[$i][0], $aExport[$i][1])
			$aContextMenuExport[$i][2] = $aExport[$i][2]
		Next
	EndIf
	$hContextMenu = _GUICtrlMenu_CreatePopup()
	If $iMode = 1 Or $iMode = 3 Then
		_GUICtrlMenu_AddMenuItem($hContextMenu, _GetLanguage('REFRESH', 'Refresh'), $iContextItem1)
		_GUICtrlMenu_AddMenuItem($hContextMenu, _GetLanguage('MENU_OPENLOCATION', 'Open File Location'), $iContextItem6)
	ElseIf $iMode = 0 Then
		_GUICtrlMenu_AddMenuItem($hContextMenu, _GetLanguage('MENU_OPEN', 'Open File'), $iContextItem1)
	EndIf

	If Not ($iIndex = -1) And Not ($iSubItem = -1) Then ; Won't Show These MenuItem(s) Unless An Item Is Selected.
		If $iMode = 1 Or $iMode = 3 Then
			_GUICtrlMenu_AddMenuItem($hContextMenu, '')
		ElseIf $iMode = 0 Or $iMode = 4 Then
			If $iMode = 4 Then
				_GUICtrlMenu_AddMenuItem($hContextMenu, _GetLanguage('MENU_OPEN', 'Open File'), $iContextItem1)
			EndIf
			_GUICtrlMenu_AddMenuItem($hContextMenu, '')
			If $iMode = 4 Then
				_WinMerge_Get()
				If @error = 0 Then
					_GUICtrlMenu_AddMenuItem($hContextMenu, _GetLanguage('MENU_OPENWINMERGE', 'Compare with WinMerge'), $iContextItem2)
				EndIf
			EndIf
			_GUICtrlMenu_AddMenuItem($hContextMenu, _GetLanguage('MENU_OPENLOCATION', 'Open File Location'), $iContextItem3)
		EndIf

		If $iMode > 0 And $iMode < 4 Then
			_GUICtrlMenu_AddMenuItem($hContextMenu, _GetLanguage('MENU_FIND', 'Find'), $iContextItem2)
			If $bIsAutoIt And Not ($iMode = 3) Then
				_GUICtrlMenu_AddMenuItem($hContextMenu, _GetLanguage('MENU_HEADER', 'Add Header'), $iContextItem3)
				_GUICtrlMenu_AddMenuItem($hContextMenu, _GetLanguage('MENU_SNIPPET', 'Function Snippet'), $iContextItem4)
			EndIf
			If Not ($iMode = 3) Then
				_GUICtrlMenu_AddMenuItem($hContextMenu, _GetLanguage('MENU_TOGGLE', 'Toggle Fold'), $iContextItem5)
			EndIf
			If $iMode = 1 Then
				_GUICtrlMenu_AddMenuItem($hContextMenu, '')
			EndIf
		EndIf
	EndIf

	If $iIndex = -1 And Not ($iSubItem = -1) Then ; Will Show These MenuItem(s) If No Item Is Selected.
	EndIf

	If $iMode = 1 Then
		$hContextSubMenu = _GUICtrlMenu_CreateMenu()
		_GUICtrlMenu_AddMenuItem($hContextMenu, _GetLanguage('EXPORT', 'Export'), 0, $hContextSubMenu)
		For $i = 0 To $iExportUbound
			_GUICtrlMenu_AddMenuItem($hContextSubMenu, $aContextMenuExport[$i][1], $aContextMenuExport[$i][0])
		Next
		If Not $bIsAutoIt Then
			_GUICtrlMenu_SetItemDisabled($hContextSubMenu, $aContextMenuExport[$iExportUbound][0], True, False)
		EndIf
	EndIf

	$iControlID = _GUICtrlMenu_TrackPopupMenu($hContextMenu, $hGUI, -1, -1, 1, 1, 2)
	Switch $iControlID
		Case $iContextItem1
			$iControlID = 1
			If $iMode > 0 And $iMode < 4 Then ; Refresh or Open.
				ControlClick($__vSciTEAPI[$__hSciTEResponseGUI], '', $__vGUIAPI[$__iGUIRefresh])
			Else
				$iError = 0
			EndIf

		Case $iContextItem2
			$iControlID = 2
			$iError = 0

		Case $iContextItem3
			$__vMiscAPI[$__iMiscAddHeaderOrOpenLocation] = 1
			$iControlID = 3
			$iError = 0

		Case $iContextItem4
			$__vMiscAPI[$__bMiscFunctionSnippet] = True
			$iControlID = 4
			$iError = 0

		Case $iContextItem5
			$__vMiscAPI[$__bMiscToggleFoldOrNoRefresh] = True
			$iControlID = 5
			$iError = 0

		Case $iContextItem6
			$__vMiscAPI[$__iMiscAddHeaderOrOpenLocation] = 2
			$iControlID = 6
			$iError = 0

		Case $aContextMenuExport[0][0] To $aContextMenuExport[$iExportUbound][0]
			For $i = 0 To $iExportUbound
				If $iControlID = $aContextMenuExport[$i][0] Then
					$iIndex = $i
					ExitLoop
				EndIf
			Next
			$iControlID = 6
			GUICtrlSendToDummy($__aExportDummy[$aContextMenuExport[$iIndex][2]], $aContextMenuExport[$iIndex][2])

	EndSwitch
	_GUICtrlMenu_DestroyMenu($hContextMenu)
	Return SetError($iError, 0, $iControlID)
EndFunc   ;==>_GUICtrlTreeView_ContextMenu

Func _GUIInBounds($hWnd) ; Original idea by wraithdu, modified by guinness.
	Local Const $tRECT = DllStructCreate($tagRECT)
	Local $iXPos = 5, $iYPos = 5
	_WinAPI_SystemParametersInfo($SPI_GETWORKAREA, 0, DllStructGetPtr($tRECT))

	Local Const $iLeft = DllStructGetData($tRECT, 'Left'), $iTop = DllStructGetData($tRECT, 'Top')
	Local $iWidth = DllStructGetData($tRECT, 'Right') - $iLeft
	If _WinAPI_GetSystemMetrics($SM_CYVIRTUALSCREEN) > $iWidth Then
		$iWidth = _WinAPI_GetSystemMetrics($SM_CYVIRTUALSCREEN)
	EndIf
	$iWidth -= $iLeft
	Local Const $iHeight = DllStructGetData($tRECT, 'Bottom') - $iTop
	Local Const $aWinGetPos = WinGetPos($hWnd)
	If @error Then
		Return SetError(1, 0, WinMove($hWnd, '', $iXPos, $iYPos))
	EndIf

	If $aWinGetPos[0] < $iLeft Then
		$iXPos = $iLeft
	ElseIf ($aWinGetPos[0] + $aWinGetPos[2]) > $iWidth Then
		$iXPos = $iWidth - $aWinGetPos[2]
	Else
		$iXPos = $aWinGetPos[0]
	EndIf

	If $aWinGetPos[1] < $iTop Then
		$iYPos = $iTop
	ElseIf ($aWinGetPos[1] + $aWinGetPos[3]) > $iHeight Then
		$iYPos = $iHeight - $aWinGetPos[3]
	Else
		$iYPos = $aWinGetPos[1]
	EndIf
	Return WinMove($hWnd, '', $iXPos, $iYPos)
EndFunc   ;==>_GUIInBounds

Func _INIUnicode($sINI)
	If Not FileExists($sINI) Then
		Return FileClose(FileOpen($sINI, $FO_OVERWRITE + $FO_UNICODE))
	Else
		Local Const $iEncoding = FileGetEncoding($sINI)
		Local $bReturn = True
		If Not ($iEncoding = $FO_UNICODE) Then
			Local $sData = _GetFile($sINI, $iEncoding)
			If @error Then
				$bReturn = False
			EndIf
			_SetFile($sData, $sINI, $FO_APPEND + $FO_UNICODE)
		EndIf
		Return $bReturn
	EndIf
EndFunc   ;==>_INIUnicode

Func _IsEx($sData, $sDefault = Default, $sSection = 'General')
	Return _Is($sData, $sDefault, $sSection, $__sScriptDir)
EndFunc   ;==>_IsEx

Func _IsControlEnabled($iControlID)
	Return BitAND(GUICtrlGetState($iControlID), $GUI_ENABLE) = $GUI_ENABLE
EndFunc   ;==>_IsControlEnabled

Func _IsEnvExists($sVariable)
	Return Not (EnvGet($sVariable) == '')
EndFunc   ;==>_IsEnvExists

Func _IsFontExists($sFontType)
	Return FileExists(_WinAPI_ShellGetSpecialFolderPath($CSIDL_FONTS) & '\' & $sFontType) = 1
EndFunc   ;==>_IsFontExists

Func _IsInstalled()
	Local $sWow6432Node = ''
	If @AutoItX64 Then
		$sWow6432Node = 'Wow6432Node\'
	EndIf
	Local $bReturn = True
	RegRead('HKEY_LOCAL_MACHINE\SOFTWARE\' & $sWow6432Node & 'AutoIt v3\AutoIt\', 'InstallDir')
	$bReturn = (@error = 0)

	If Not $bReturn Then $bReturn = FileExists(EnvGet('SciTE_USERHOME') & '\abbrev.properties') Or FileExists(EnvGet('SciTE_HOME') & '\abbrev.properties')
	Return $bReturn
EndFunc   ;==>_IsInstalled

Func _IsRestarted()
	Local $bReturn = False
	If $CmdLine[0] = 2 Then
		If $CmdLine[1] = '/Restart' Then
			Local Const $iPID = Run('"' & $CmdLine[2] & '"', _WinAPI_PathRemoveFileSpec($CmdLine[2]) & '\', @SW_SHOW)

			_WinWait('DirectorExtension', 10)
			_WinWait('[CLASS:SciTEWindow]', 10)
			Sleep(750)
			_SciTE_Startup()

			_SciTE_LoadSession($__sScriptDir & '\SciTEJump.session')
			FileDelete($__sScriptDir & '\SciTE.session')
			$bReturn = $iPID > 0
		EndIf
	EndIf
	Return $bReturn
EndFunc   ;==>_IsRestarted

Func _IsUpdate($sFilePath, $bOverride = Default)
	Local Const $iBefore = Int(StringRegExpReplace(FileGetVersion($sFilePath), '\D', ''))
	Local Const $iAfter = Int(StringRegExpReplace(_WinAPI_ExpandEnvironmentStrings('%VERSION%'), '\D', ''))
	Local $bReturn = $iAfter > $iBefore
	If Not $bOverride Then
		If Int(IniRead($__sScriptDir & '\Settings.ini', 'General', 'UpdateKey', $iBefore)) = $iAfter Then
			$bReturn = False
		EndIf
		IniWrite($__sScriptDir & '\Settings.ini', 'General', 'UpdateKey', $iAfter)
	EndIf
	Return $bReturn
EndFunc   ;==>_IsUpdate

Func _IsWindowsVersion()
	Return $__WINVER >= 0x0600
EndFunc   ;==>_IsWindowsVersion

Func _IsWrite($sData, $sDefault = Default, $sSection = 'General')
	Return IniWrite($__sScriptDir & '\Settings.ini', $sSection, $sData, Int($sDefault = True)) = 1
EndFunc   ;==>_IsWrite

Func _IsX64()
	Local Const $sFilePath = @ScriptDir & '\' & _ProgramName() & _GetOSArch() & '.exe'
	If Not @AutoItX64 And @OSArch = 'X64' And FileExists($sFilePath) Then
		Exit Run('"' & $sFilePath & '"' & (IsNullOrEmpty($CmdLineRaw) ? '' : ' ' & $CmdLineRaw))
	EndIf
	Return False
EndFunc   ;==>_IsX64

Func _LanguageAdd(ByRef $aArray, $iIndex, $iControlID, $sData, $sDefault, $sBefore = '', $sAfter = '')
	If $iControlID = -1 Then
		$iControlID = _WinAPI_GetDlgCtrlID(GUICtrlGetHandle($iControlID))
	EndIf
	If $iIndex = -1 Then
		_ReDim($aArray, $aArray[0][2])
		$aArray[0][0] += 1
		$iIndex = $aArray[0][0]
	EndIf
	$aArray[$iIndex][0] = $iControlID
	$aArray[$iIndex][1] = $sData
	$aArray[$iIndex][2] = $sDefault
	$aArray[$iIndex][3] = $sBefore
	$aArray[$iIndex][4] = $sAfter
	; GUICtrlSetData($iControlID, $sBefore & _GetLanguage($sData, $sDefault) & $sAfter) ; To increase speed of showing the GUI.
EndFunc   ;==>_LanguageAdd

Func _LanguageUpdate(ByRef Const $aArray)
	For $i = 1 To $aArray[0][0]
		If $aArray[$i][0] > 0 Then
			GUICtrlSetData($aArray[$i][0], $aArray[$i][3] & _GetLanguage($aArray[$i][1], $aArray[$i][2]) & $aArray[$i][4])
		EndIf
	Next
EndFunc   ;==>_LanguageUpdate

Func _Monitor()
	If $__vGUIAPI[$__bGUIIsMinimised] Or $__vMiscAPI[$__bMiscFindInFile] Then
		Return False
	EndIf
	Local Const $bIsActive = _IsActive($__vSciTEAPI[$__hSciTEWindow])

	Local Const $sFilePath = _SciTE_GetCurrentFile()
	If @error Then
		Switch @error
			Case 1 ; No Window.
				If Not ($__vCurrentFileAPI[$__sCurrentFilePath] == '(NoWindow)') Then
					$__vCurrentFileAPI[$__sCurrentFilePath] = '(NoWindow)'
					_TreeView_Refresh(True, 'TIP_ERROR_4', 'SciTE seems to be closed.')
				EndIf

			Case 2 ; File Does Not Exist.
				If Not ($__vCurrentFileAPI[$__sCurrentFilePath] == '(NoFile)') Then
					$__vCurrentFileAPI[$__sCurrentFilePath] = '(NoFile)'
					_TreeView_Refresh(True, "TIP_ERROR_3", "File doesn't exist.")
				EndIf

			Case 3 ; New File.
				If Not ($__vCurrentFileAPI[$__sCurrentFilePath] == '(Untitled)') Then
					$__vCurrentFileAPI[$__sCurrentFilePath] = '(Untitled)'
					_TreeView_Refresh(True)
					WinActivate($__vSciTEAPI[$__hSciTEWindow]) ; Re-activate SciTE.
				EndIf

		EndSwitch
		_SciTE_ChangeWorkingDirectory(@ScriptDir & '\')
		_Toggle_EnableOrDisable($__vGUIAPI[$__iGUIButtonExport_1], False)
		Return False
	EndIf

	If $__vCurrentFileAPI[$__sCurrentFilePath] = $sFilePath And $__vCurrentFileAPI[$__iCurrentFileSize] = FileGetSize($sFilePath) Then
		Return False
	EndIf

	$__vCurrentFileAPI[$__sCurrentFilePath] = $sFilePath
	$__vCurrentFileAPI[$__sCurrentFileFolder] = _WinAPI_PathRemoveFileSpec($sFilePath)
	$__vCurrentFileAPI[$__iCurrentFileSize] = FileGetSize($sFilePath)
	$__vCurrentFileAPI[$__sCurrentFileName] = _WinAPI_PathStripPath($sFilePath)
	If $__vCurrentFileAPI[$__iCurrentFileSize] = 0 Then ; If the file contains zero bytes.
		_Toggle_EnableOrDisable($__vGUIAPI[$__iGUIButtonExport_1], False)
		_TreeView_Refresh(True)
		If $bIsActive Then
			WinActivate($__vSciTEAPI[$__hSciTEWindow])
		EndIf
		Return False
	EndIf
	_TreeView_Refresh()

	_Toggle_EnableOrDisable($__vGUIAPI[$__iGUIButtonExport_1], _IsValidFileType($__vCurrentFileAPI[$__sCurrentFilePath], 'au3'))
	If $bIsActive Then
		WinActivate($__vSciTEAPI[$__hSciTEWindow])
	EndIf
	Return True
EndFunc   ;==>_Monitor

Func _Monitor_Check($bClose, $sSendString = '')
	Local $hWnd = 0
	Local Const $aDockList = WinList('[REGEXPTITLE:Monitor(FileInfo|Rename|Run)_SciTE_Jump_A17DA5D6-487D-11E3-B453-DE83E5AF4BA6]')
	If $aDockList[0][0] Then
		If $bClose Or $aDockList[0][0] > 1 Then
			For $i = 1 To $aDockList[0][0]
				$hWnd = HWnd(ControlGetText($aDockList[$i][1], '', ControlGetHandle($aDockList[$i][1], '', 'Edit1')))
				_SciTE_Send_Command(0, $hWnd, 'Monitor_Exit')
				If WinWaitClose($hWnd, '', 5) = 0 Then
					ProcessWaitClose(WinGetProcess($aDockList[$i][1]), 5)
				EndIf
			Next
			$hWnd = 0
		Else
			$hWnd = HWnd(ControlGetText($aDockList[1][1], '', ControlGetHandle($aDockList[1][1], '', 'Edit1')))
			If Not ($aDockList[1][0] == 'MonitorRun_SciTE_Jump_A17DA5D6-487D-11E3-B453-DE83E5AF4BA6') Then
				_SciTE_Send_Command(0, $hWnd, 'Monitor_Exit')
				If WinWaitClose($hWnd, '', 5) = 0 Then
					ProcessWaitClose(WinGetProcess($aDockList[1][1]), 5)
				EndIf
				$hWnd = 0
			EndIf
		EndIf
	EndIf
	If $hWnd And $sSendString Then
		_SciTE_Send_Command(0, $hWnd, $sSendString)
	EndIf
	Return $hWnd
EndFunc   ;==>_Monitor_Check

Func _Monitor_Run($bClose = Default)
	Local Const $hWnd = _Monitor_Check($bClose)
	If $hWnd = 0 Then
		Local Const $iA3XVersion = 22 ; a3x Version.
		If FileExists($__sScriptDir & '\Bin\Monitor.a3x') = 0 Or Not (Int(IniRead($__sScriptDir & '\Settings.ini', 'General', 'MonitorVersion', 0)) = $iA3XVersion) Then
			IniWrite($__sScriptDir & '\Settings.ini', 'General', 'MonitorVersion', $iA3XVersion)
			DirCreate($__sScriptDir & '\Bin\')
			FileInstall('Bin\Monitor.a3x', $__sScriptDir & '\Bin\Monitor.a3x', 1)
		EndIf
		If FileExists($__sScriptDir & '\Bin\Monitor.a3x') Then
			_RunAu3($__sScriptDir & '\Bin\Monitor.a3x', '\MonitorRun ' & $__vSciTEAPI[$__hSciTEResponseGUI], $__sScriptDir)
		EndIf
	EndIf
	Return $hWnd
EndFunc   ;==>_Monitor_Run

Func _ProgressMarquee_Start($iControlID = -1)
	GUICtrlSetState($iControlID, $GUI_SHOW)
	Return GUICtrlSendMsg($iControlID, $PBM_SETMARQUEE, 1, 50)
EndFunc   ;==>_ProgressMarquee_Start

Func _ProgressMarquee_Stop($iControlID = -1, $bReset = Default, $bHide = Default)
	Local Const $bReturn = GUICtrlSendMsg($iControlID, $PBM_SETMARQUEE, 0, 50)
	If $bReset Then
		GUICtrlSetStyle($iControlID, $PBS_MARQUEE)
	EndIf
	If $bHide Then
		GUICtrlSetState($iControlID, $GUI_HIDE)
	EndIf
	Return $bReturn
EndFunc   ;==>_ProgressMarquee_Stop

Func _ReplaceInFileCompare($sFilePath, $iControlID, $sBeforeString, $sAfterString, $iCaseSensitive = 1, $iRegularExpression = 0)
	Local $iError = 0, $sTempPath = $__sScriptDir & '\WinMergeTemp'
	If _IsInstalled() Then
		$sTempPath = FileGetLongName(@TempDir)
	EndIf
	If FileExists($sTempPath) = 0 Then
		DirCreate($sTempPath)
	EndIf
	$sTempPath = _WinAPI_GetTempFileName($sTempPath)
	Local Const $aSearch[2] = [1, $sTempPath]
	Local $aReturn[1][2] = [[0, 2]]
	If FileCopy($sFilePath, $sTempPath, $FC_OVERWRITE) Then
		If _ReplaceInFiles($iControlID, $aReturn, $aSearch, $sBeforeString, $sAfterString, True, '*', $iCaseSensitive, $iRegularExpression) Then
			_WinMerge_Run($sFilePath, $sTempPath)
		Else
			$iError = 2
		EndIf
	Else
		$iError = 1
	EndIf
	$aReturn = 0
	Return SetError($iError, 0, $sTempPath)
EndFunc   ;==>_ReplaceInFileCompare

Func _ReplaceInFiles($iControlID, ByRef $aReturn, $aSearch, $sBeforeString, $sAfterString, $bReplace = Default, $sFileExtensions = 'txt', _
		$iCaseSensitive = 1, $iRegularExpression = 0)

	If $iCaseSensitive = 0 Then
		$iCaseSensitive = $STR_NOCASESENSE
	EndIf

	Local Const $sFilePath = $__sScriptDir & '\Bin\84B946A50D.dat'
	Local Const $sCmdLine = '\MonitorRename "<filepath>' & $sFilePath & '</filepath>' & _
			'<beforestring>' & $sBeforeString & '</beforestring>' & _
			'<afterstring>' & $sAfterString & '</afterstring>' & _
			'<fileextensions>' & $sFileExtensions & '</fileextensions>' & _
			'<replacestring>' & Int($bReplace) & '</replacestring>' & _
			'<casesensitive>' & Int($iCaseSensitive) & '</casesensitive>' & _
			'<regularexpression>' & Int($iRegularExpression) & '</regularexpression>"'

	Local $iCount = 0, $iError = 0, $sReturn = ''
	For $i = 1 To $aSearch[0]
		$sReturn &= $aSearch[$i] & '|0|' & @CRLF
	Next
	_SetFile($sReturn, $sFilePath, $FO_APPEND)

	If FileExists($sFilePath) And FileExists($__sScriptDir & '\Bin\Monitor.a3x') Then
		Local Const $iPID = _RunAu3($__sScriptDir & '\Bin\Monitor.a3x', $sCmdLine, $__sScriptDir)
		While Sleep(500) * ProcessExists($iPID)
			If $iControlID > 0 And _IsChecked($iControlID) Then
				$iError = 1
				ProcessClose($iPID)
				$sReturn = ''
				_SetFile($sReturn, $sFilePath, $FO_APPEND) ; Erase the file.
				ExitLoop
			EndIf
		WEnd

		If FileExists($sFilePath) Then
			$aSearch = StringRegExp(@ScriptFullPath & '|' & @CRLF & _GetFile($sFilePath), '([^|]+)\|(\d+)?\|?\R', 3)
			$aSearch[0] = UBound($aSearch) - 1
			ReDim $aReturn[$aReturn[0][0] + $aSearch[0] + 1][$aReturn[0][1]]
			For $i = 1 To $aSearch[0] Step 2
				$aReturn[0][0] += 1
				$aReturn[$aReturn[0][0]][0] = $aSearch[$i]
				$aReturn[$aReturn[0][0]][1] = $aSearch[$i + 1]
				$iCount += 1
			Next
		EndIf

		If ProcessExists($iPID) Then
			_ProcessKill($iPID)
		EndIf
	EndIf

	$sReturn = ''
	_SetFile($sReturn, $sFilePath, $FO_APPEND) ; Erase the file.
	Return SetError($iError, 0, $iCount > 0)
EndFunc   ;==>_ReplaceInFiles

Func _RunAu3($sFilePath, $sCommandLine = '', $sWorkingDir = '', $iShowFlag = @SW_SHOW, $iOptFlag = 0)
	Return FileExists($sFilePath) ? Run('"' & @AutoItExe & '" /AutoIt3ExecuteScript "' & $sFilePath & '" ' & $sCommandLine, $sWorkingDir, $iShowFlag, $iOptFlag) : 0
EndFunc   ;==>_RunAu3

Func _SaveSciTEPath()
	Local $sFilePath = _SciTE_GetSciTEDefaultHome() & '\' & 'SciTE.exe'
	If FileExists($sFilePath) Then
		FileChangeDir(@ScriptDir & '\')
		IniWrite($__sScriptDir & '\Settings.ini', 'General', 'SciTE', _GetRelativePath(@ScriptDir & '\', $sFilePath))
	Else
		$sFilePath = ''
	EndIf
	Return $sFilePath
EndFunc   ;==>_SaveSciTEPath

Func _Search($sSearchText, ByRef $aArray)
	$__aSearchItems[0][0] = $aArray[0][0]
	_ReDim($__aSearchItems, $__vTreeViewParentsAPI[$__iTreeViewParentsSearchReDim])
	_SearchDestroy()

	_SearchCreate()
	$__vTreeViewParentsAPI[$__sTreeViewParentsSearch] = ''

	_GUICtrlTreeView_BeginUpdate($__vGUIAPI[$__iGUITreeViewSearch])

	$__vTreeViewParentsAPI[$__iTreeViewParentsSearch] = GUICtrlCreateTreeViewItem(_GetLanguage('TIP_SEARCH_1', 'Search results'), $__vGUIAPI[$__iGUITreeViewSearch])
	_LanguageAdd($__aLanguageItems, $LANGAUGE_ITEMS_PARENTSSEARCH, $__vTreeViewParentsAPI[$__iTreeViewParentsSearch], 'TIP_SEARCH_1', 'Search results')
	Local $sData = ''
	For $i = 1 To $aArray[0][0]
		$sData = $aArray[$i][$__iTreeViewSearchBefore]
		If StringInStr($sData, $sSearchText, $STR_NOCASESENSE) And _
				BitAND($__vMiscAPI[$__bMiscSearchParams], $aArray[$i][$__iTreeViewItemID]) = $aArray[$i][$__iTreeViewItemID] Then
			If $aArray[$i][$__iTreeViewItemID] = $__iTreeViewIsCustomFunction Then
				$sData = StringRegExpReplace($sData, '(?m)^(\w+)\|(?:\V+)', '\1') ; Function
			EndIf
			If $__vMiscAPI[$__bMiscFindInFile] Then
				$sData = _WinAPI_PathStripPath($sData)
			EndIf

			$__aSearchItems[0][0] += 1
			$__vTreeViewParentsAPI[$__iTreeViewParentsSearchEnd] = GUICtrlCreateTreeViewItem($sData, $__vTreeViewParentsAPI[$__iTreeViewParentsSearch])
			$__vTreeViewParentsAPI[$__sTreeViewParentsSearch] &= '&' & $__vTreeViewParentsAPI[$__iTreeViewParentsSearchEnd] & '|' & $__aSearchItems[0][0] ; Add to the message id string.
			$__aSearchItems[$__aSearchItems[0][0]][$__iTreeViewSearchBefore] = $aArray[$i][$__iTreeViewSearchBefore]
			$__aSearchItems[$__aSearchItems[0][0]][$__iTreeViewItemID] = $aArray[$i][$__iTreeViewItemID]
		EndIf
	Next

	_GUICtrlTreeView_EndUpdate($__vGUIAPI[$__iGUITreeViewSearch])

	If $__aSearchItems[0][0] = 0 Then
		$__aSearchItems[0][0] = 1
		$__vTreeViewParentsAPI[$__iTreeViewParentsSearchStart] = GUICtrlCreateTreeViewItem(_GetLanguage('TIP_SEARCH_2', 'No search results'), $__vGUIAPI[$__iGUITreeViewSearch])
		$__vTreeViewParentsAPI[$__iTreeViewParentsSearchEnd] = $__vTreeViewParentsAPI[$__iTreeViewParentsSearchStart]
		_LanguageAdd($__aLanguageItems, $LANGAUGE_ITEMS_PARENTSSEARCH, $__vTreeViewParentsAPI[$__iTreeViewParentsSearchStart], 'TIP_SEARCH_2', 'No search results')
	Else
		$__vTreeViewParentsAPI[$__sTreeViewParentsSearch] &= '&'
		$__vTreeViewParentsAPI[$__iTreeViewParentsSearchStart] = Int(StringRegExpReplace($__vTreeViewParentsAPI[$__sTreeViewParentsSearch], '(?m)^&(\d+)\|\d{1,5}&.*', '\1'))
		_LanguageAdd($__aLanguageItems, $LANGAUGE_ITEMS_PARENTSSEARCH, '', '', '')
	EndIf
	GUICtrlSetState($__vTreeViewParentsAPI[$__iTreeViewParentsSearch], BitOR($GUI_EXPAND, $GUI_DEFBUTTON))
EndFunc   ;==>_Search

Func _SearchCreate($bSetCurrent = Default)
	If $__vGUIAPI[$__iGUITreeViewSearch] = 0 Then
		$__vGUIAPI[$__iGUITreeViewSearch] = _CreateTreeView()
	EndIf
	If $bSetCurrent Or $bSetCurrent = Default Then
		_TreeView_SetCurrent($__vGUIAPI[$__iGUITreeViewSearch])
	Else
		_Toggle_ShowOrHide($__vGUIAPI[$__iGUITreeViewSearch], False)
	EndIf
EndFunc   ;==>_SearchCreate

Func _SearchDestroy($bReset = Default)
	_Toggle_ShowOrHide($__vGUIAPI[$__iGUITreeViewSearch], False)
	_GUICtrlTreeView_DeleteAll($__vGUIAPI[$__iGUITreeViewSearch])
	GUICtrlDelete($__vTreeViewParentsAPI[$__iTreeViewParentsSearch])
	$__vTreeViewParentsAPI[$__iTreeViewParentsSearch] = 0
	_TreeView_Delete($__vTreeViewParentsAPI[$__sTreeViewParentsSearch], 3)
	If $bReset Or $bReset = Default Then
		$__aSearchItems[0][0] = 0
		$__vTreeViewParentsAPI[$__iTreeViewParentsSearchStart] = $GUI_NO_INDEX
		$__vTreeViewParentsAPI[$__iTreeViewParentsSearchEnd] = $GUI_NO_INDEX
	EndIf
EndFunc   ;==>_SearchDestroy

Func _SetCurrentPosition($hWnd)
	Local Const $aINISection[4] = ['SizeW', 'SizeH', 'PosX', 'PosY'], $sINI = $__sScriptDir & '\Settings.ini'
	Local $aReturn[4] = [0, 0, 0, 0]
	Local Const $aWinGetPos = WinGetPos($hWnd)
	If @error = 0 Then
		$aReturn[2] = $aWinGetPos[0]
		$aReturn[3] = $aWinGetPos[1]
	EndIf
	Local Const $aWinGetClientSize = WinGetClientSize($hWnd)
	If @error = 0 Then
		$aReturn[0] = $aWinGetClientSize[0]
		$aReturn[1] = $aWinGetClientSize[1]
	EndIf
	For $i = 0 To 3
		If $aReturn[$i] > 0 Then
			IniWrite($sINI, 'General', $aINISection[$i], $aReturn[$i])
		Else
			IniDelete($sINI, 'General', $aINISection[$i])
		EndIf
	Next
	Return $aReturn
EndFunc   ;==>_SetCurrentPosition

Func _System_ContextMenu($hWnd, $iControlID = Default)
	Switch $iControlID
		Case Default
			$__aContextMenu[0] = _GUICtrlMenu_GetSystemMenu($hWnd)

			_GUICtrlMenu_AppendMenu($__aContextMenu[0], $MF_SEPARATOR, 0, '')
			If FileExists(_WinAPI_PathRemoveFileSpec(_SaveSciTEPath()) & '\Scite4AutoIt3.chm') Or FileExists(@ScriptDir & '\HelpFile.chm') Then
				_GUICtrlMenu_AppendMenu($__aContextMenu[0], $MF_STRING, $__iContextMenu1, _GetLanguage('MENU_HELP', 'Help (F1)'))
			EndIf
			_GUICtrlMenu_AppendMenu($__aContextMenu[0], $MF_STRING, $__iContextMenu2, _GetLanguage('MENU_ABOUT', 'About'))

			$__aContextMenu[1] = _GUICtrlMenu_FindItem($__aContextMenu[0], _GetLanguage('MENU_HELP', 'Help (F1)'))
			$__aContextMenu[2] = _GUICtrlMenu_FindItem($__aContextMenu[0], _GetLanguage('MENU_ABOUT', 'About'))

		Case Else
			Switch $iControlID
				Case $__iContextMenu1
					GUICtrlSendToDummy($__vGUIAPI[$__iGUIHelp])

				Case $__iContextMenu2
					GUICtrlSendToDummy($__vGUIAPI[$__iGUIAbout])

			EndSwitch
	EndSwitch
EndFunc   ;==>_System_ContextMenu

Func _Toggle_EnableOrDisable($iControlID, $bOverride = Default)
	If $bOverride = Default Then
		$bOverride = Not (BitAND(GUICtrlGetState($iControlID), $GUI_ENABLE) = $GUI_ENABLE)
	EndIf
	GUICtrlSetState($iControlID, $bOverride ? $GUI_ENABLE : $GUI_DISABLE)
EndFunc   ;==>_Toggle_EnableOrDisable

Func _Toggle_ProgressBar($bEnable = Default)
	If $bEnable Then
		GUICtrlSetData($__vGUIAPI[$__iGUIRefresh], '&' & _GetLanguage('CANCEL', 'Cancel'))
		_Toggle_ShowOrHide($__vGUIAPI[$__iGUIButtonExport_1])
		_ProgressMarquee_Start($__vGUIAPI[$__iGUIProgressBar])
	Else
		_ProgressMarquee_Stop($__vGUIAPI[$__iGUIProgressBar], True, True)
		_Toggle_ShowOrHide($__vGUIAPI[$__iGUIButtonExport_1])
		GUICtrlSetData($__vGUIAPI[$__iGUIRefresh], '&' & _GetLanguage('REFRESH', 'Refresh'))
	EndIf
EndFunc   ;==>_Toggle_ProgressBar

Func _Toggle_ShowOrHide($iControlID, $bOverride = Default)
	If $iControlID <= 0 Then Return
	If $bOverride = Default Then
		$bOverride = Not (BitAND(GUICtrlGetState($iControlID), $GUI_SHOW) = $GUI_SHOW)
	Else
		If $bOverride Then
			Return ControlShow($__vSciTEAPI[$__hSciTEResponseGUI], '', $iControlID)
		Else
			Return ControlHide($__vSciTEAPI[$__hSciTEResponseGUI], '', $iControlID)
		EndIf
	EndIf
	GUICtrlSetState($iControlID, $bOverride ? $GUI_SHOW : $GUI_HIDE)
EndFunc   ;==>_Toggle_ShowOrHide

Func _TreeView_Create($bSetCurrent = Default)
	If $__vGUIAPI[$__iGUITreeView] = 0 Then
		$__vGUIAPI[$__iGUITreeView] = _CreateTreeView()
	EndIf
	If $bSetCurrent Or $bSetCurrent = Default Then
		_TreeView_SetCurrent($__vGUIAPI[$__iGUITreeView])
	Else
		_Toggle_ShowOrHide($__vGUIAPI[$__iGUITreeView], 0)
	EndIf
EndFunc   ;==>_TreeView_Create

Func _TreeView_Delete(ByRef $vArrayString, $iDimension = Default)
	If $iDimension = Default Then
		$iDimension = 1
	EndIf
	Switch $iDimension
		Case 1
			For $i = 1 To $vArrayString[0]
				GUICtrlDelete($vArrayString[$i]) ; Delete the controlid.
			Next
		Case 2
			For $i = 1 To $vArrayString[0][0]
				GUICtrlDelete($vArrayString[$i][0]) ; Delete the controlid.
			Next
		Case 3
			Local Const $aDelete = StringRegExp($vArrayString, '&(\d{1,5})\|\d{1,5}', 3)
			If @error = 0 Then
				For $i = 0 To UBound($aDelete) - 1
					GUICtrlDelete($aDelete[$i]) ; Delete the controlid.
				Next
			EndIf
			$vArrayString = ''

	EndSwitch
EndFunc   ;==>_TreeView_Delete

Func _TreeView_Refresh($bEmpty = False, $sData = 'TIP_ERROR_1', $sDefault = 'Empty file.')
	_TreeView_Delete($__vTreeViewParentsAPI, 1)

	_SearchDestroy()

	_GUICtrlTreeView_DeleteAll($__vGUIAPI[$__iGUITreeView])
	_TreeView_Delete($__vTreeViewParentsAPI[$__sTreeViewParentsTreeView], 3)
	$__aTreeViewItems[0][0] = 0

	_TreeView_Create()

	$__vTreeViewParentsAPI[$__iTreeViewParentsFunction] = $GUI_NO_INDEX
	If $bEmpty Then
		$__vTreeViewParentsAPI[$__iTreeViewParentsComment] = GUICtrlCreateTreeViewItem(_GetLanguage($sData, $sDefault), $__vGUIAPI[$__iGUITreeView])
		_LanguageAdd($__aLanguageItems, $LANGAUGE_ITEMS_COMMENTS, $__vTreeViewParentsAPI[$__iTreeViewParentsComment], $sData, $sDefault)
		Return False
	EndIf

	Local $sFileData = _GetFile($__vCurrentFileAPI[$__sCurrentFilePath])
	If @error Then
		; Clear the first row with the value -1.
		For $i = 0 To $__aTreeViewItems[0][1] - 1
			$__aTreeViewItems[1][$i] = -1
		Next
	EndIf
	_StripWhitespace($sFileData)
	_StripFunctionsEnd($sFileData)

	Local $vAllAnchorsAndClear[1][3] = [[0, 3, 0]]
	_CreateJumpArray($vAllAnchorsAndClear, $sFileData)
	$sFileData = ''
	If $vAllAnchorsAndClear[0][0] = 0 Then
		$vAllAnchorsAndClear = 0
		$__vTreeViewParentsAPI[$__iTreeViewParentsComment] = GUICtrlCreateTreeViewItem(_GetLanguage('TIP_ERROR_2', 'No jump data found.'), $__vGUIAPI[$__iGUITreeView])
		_LanguageAdd($__aLanguageItems, $LANGAUGE_ITEMS_COMMENTS, $__vTreeViewParentsAPI[$__iTreeViewParentsComment], 'TIP_ERROR_2', 'No jump data found.')
		Return SetError(1, 0, False)
	EndIf

	Local Const $bCancelButton = $vAllAnchorsAndClear[0][0] > 7500 ; Display the cancel button if more than 7500 items are in the script file.
	If $bCancelButton Then
		_Toggle_ProgressBar(True)
	EndIf

	; Re-size the main array if only required.
	$__aTreeViewItems[0][0] = $vAllAnchorsAndClear[0][0]
	_ReDim($__aTreeViewItems, $__vTreeViewParentsAPI[$__iTreeViewParentsTreeViewReDim])

	$__vTreeViewParentsAPI[$__iTreeViewParentsComment] = $GUI_NO_INDEX
	If BitAND($vAllAnchorsAndClear[0][2], $__iTreeViewIsComment) Then
		$__vTreeViewParentsAPI[$__iTreeViewParentsComment] = GUICtrlCreateTreeViewItem(_GetLanguage('COMMENTS', 'User comments'), $__vGUIAPI[$__iGUITreeView])
	EndIf
	_LanguageAdd($__aLanguageItems, $LANGAUGE_ITEMS_COMMENTS, $__vTreeViewParentsAPI[$__iTreeViewParentsComment], 'COMMENTS', 'User comments')

	$__vTreeViewParentsAPI[$__iTreeViewParentsFunction] = $GUI_NO_INDEX
	If BitAND($vAllAnchorsAndClear[0][2], $__iTreeViewIsFunctionOrFile) Then
		$__vTreeViewParentsAPI[$__iTreeViewParentsFunction] = GUICtrlCreateTreeViewItem(_GetLanguage('FUNCTIONS', 'Functions'), $__vGUIAPI[$__iGUITreeView])
	EndIf
	_LanguageAdd($__aLanguageItems, $LANGAUGE_ITEMS_FUNCTIONS, $__vTreeViewParentsAPI[$__iTreeViewParentsFunction], 'FUNCTIONS', 'Functions')

	$__vTreeViewParentsAPI[$__iTreeViewParentsRegion] = $GUI_NO_INDEX
	If BitAND($vAllAnchorsAndClear[0][2], $__iTreeViewIsRegion) Then
		$__vTreeViewParentsAPI[$__iTreeViewParentsRegion] = GUICtrlCreateTreeViewItem(_GetLanguage('REGIONS', 'Regions'), $__vGUIAPI[$__iGUITreeView])
	EndIf
	_LanguageAdd($__aLanguageItems, $LANGAUGE_ITEMS_REGIONS, $__vTreeViewParentsAPI[$__iTreeViewParentsRegion], 'REGIONS', 'Regions')

	$__vTreeViewParentsAPI[$__iTreeViewParentsUDF] = $GUI_NO_INDEX
	If BitAND($vAllAnchorsAndClear[0][2], $__iTreeViewIsCustomFunction) Then
		$__vTreeViewParentsAPI[$__iTreeViewParentsUDF] = GUICtrlCreateTreeViewItem(_GetLanguage('UDFS', 'User Defined'), $__vGUIAPI[$__iGUITreeView])
	EndIf
	_LanguageAdd($__aLanguageItems, $LANGAUGE_ITEMS_USERDEFINED, $__vTreeViewParentsAPI[$__iTreeViewParentsUDF], 'UDFS', 'User Defined')

	_GUICtrlTreeView_BeginUpdate($__vGUIAPI[$__iGUITreeViewCurrent])

	Local $aLastFunction = StringRegExp($__aMiscLastFunction.Item($__vCurrentFileAPI[$__sCurrentFilePath]), '([^|]*)\|(\d)\|(\d)', 3)
	If @error Then
		Local $aLastFunction[3] = ['', '', '']
	EndIf
	$aLastFunction[$__iMiscLastFunctionTreeViewID] = Int($aLastFunction[$__iMiscLastFunctionTreeViewID])
	$aLastFunction[$__bMiscLastFunctionSelect] = Int($aLastFunction[$__bMiscLastFunctionSelect]) = 1
	For $i = 1 To $vAllAnchorsAndClear[0][0]
		Switch $vAllAnchorsAndClear[$i][1]
			Case $__iTreeViewIsComment
				$__vTreeViewParentsAPI[$__iTreeViewParentsTreeViewEnd] = GUICtrlCreateTreeViewItem($vAllAnchorsAndClear[$i][0], $__vTreeViewParentsAPI[$__iTreeViewParentsComment])
			Case $__iTreeViewIsFunctionOrFile
				$__vTreeViewParentsAPI[$__iTreeViewParentsTreeViewEnd] = GUICtrlCreateTreeViewItem($vAllAnchorsAndClear[$i][0], $__vTreeViewParentsAPI[$__iTreeViewParentsFunction])
			Case $__iTreeViewIsRegion
				$__vTreeViewParentsAPI[$__iTreeViewParentsTreeViewEnd] = GUICtrlCreateTreeViewItem($vAllAnchorsAndClear[$i][0], $__vTreeViewParentsAPI[$__iTreeViewParentsRegion])
			Case $__iTreeViewIsCustomFunction
				$__vTreeViewParentsAPI[$__iTreeViewParentsTreeViewEnd] = GUICtrlCreateTreeViewItem($vAllAnchorsAndClear[$i][0], $__vTreeViewParentsAPI[$__iTreeViewParentsUDF])
				$vAllAnchorsAndClear[$i][0] = $vAllAnchorsAndClear[$i][0] & '|' & $vAllAnchorsAndClear[$i][2]
		EndSwitch
		$__vTreeViewParentsAPI[$__sTreeViewParentsTreeView] &= '&' & $__vTreeViewParentsAPI[$__iTreeViewParentsTreeViewEnd] & '|' & $i ; Add to the message id string.

		$__aTreeViewItems[$i][$__iTreeViewSearchBefore] = $vAllAnchorsAndClear[$i][0]
		$__aTreeViewItems[$i][$__iTreeViewItemID] = $vAllAnchorsAndClear[$i][1]

		If $aLastFunction[$__iMiscLastFunctionFuncName] = $__aTreeViewItems[$i][$__iTreeViewSearchBefore] Then
			$aLastFunction[$__iMiscLastFunctionTreeViewID] = $__vTreeViewParentsAPI[$__iTreeViewParentsTreeViewEnd]
		EndIf
		If $bCancelButton Then
			If _IsChecked($__vGUIAPI[$__iGUIRefresh]) Then
				$__vMiscAPI[$__bMiscToggleFoldOrNoRefresh] = True
				_Toggle_CheckOrUnCheck($__vGUIAPI[$__iGUIRefresh], False)
				ExitLoop
			EndIf
		EndIf
	Next
	$__vTreeViewParentsAPI[$__sTreeViewParentsTreeView] &= '&'
	$__vTreeViewParentsAPI[$__iTreeViewParentsTreeViewStart] = Int(StringRegExpReplace($__vTreeViewParentsAPI[$__sTreeViewParentsTreeView], '(?m)^&(\d+)\|\d{1,5}&.*', '\1'))

	$vAllAnchorsAndClear = 0
	If $bCancelButton Then
		_Toggle_ProgressBar(False)
	EndIf

	_GUICtrlTreeView_EndUpdate($__vGUIAPI[$__iGUITreeViewCurrent])

	If $__vTreeViewParentsAPI[$__vMiscAPI[$__iMiscExpandState]] > 0 Then
		GUICtrlSetState($__vTreeViewParentsAPI[$__vMiscAPI[$__iMiscExpandState]], BitOR($GUI_DEFBUTTON, $GUI_EXPAND))
	EndIf

	$vAllAnchorsAndClear = True
	If $__vMiscAPI[$__iMiscExpandState] = $__iTreeViewParentsFunction And $aLastFunction[$__iMiscLastFunctionTreeViewID] Then
		_GUICtrlTreeView_SelectItem($__vGUIAPI[$__iGUITreeView], GUICtrlGetHandle($aLastFunction[$__iMiscLastFunctionTreeViewID]), $TVGN_FIRSTVISIBLE)
		If $aLastFunction[$__bMiscLastFunctionSelect] Then
			$__aMiscLastFunction.Item($__vCurrentFileAPI[$__sCurrentFilePath]) = $aLastFunction[$__iMiscLastFunctionFuncName] & '|' & $aLastFunction[$__iMiscLastFunctionTreeViewID] & '|0'
			$vAllAnchorsAndClear = False
			GUICtrlSetState($aLastFunction[$__iMiscLastFunctionTreeViewID], $GUI_FOCUS)
		EndIf
	EndIf

	If $vAllAnchorsAndClear Then
		While GUIGetMsg() ; Workaround to clear the message queue.
		WEnd
	EndIf

	If $__vMiscAPI[$__sMiscSearchedText] Then
		$__vMiscAPI[$__sMiscSearchedText] = ''
		AdlibRegister('WM_COMMAND_TIMER', 250)
	EndIf
	Return True
EndFunc   ;==>_TreeView_Refresh

Func _TreeView_Reset(ByRef $aArray, ByRef $iDimension)
	$iDimension = 0
	$aArray[0][0] = 0
	ReDim $aArray[2][$aArray[0][1]]
EndFunc   ;==>_TreeView_Reset

Func _TreeView_SetCurrent($iWnd)
	$__vGUIAPI[$__iGUITreeViewCurrent] = $iWnd
	_Toggle_ShowOrHide($iWnd, True)
EndFunc   ;==>_TreeView_SetCurrent

Func _Update($bOverride = Default)
	Local Const $aProcess[3] = [2, 'SciTE Jump.exe', 'SciTE Jump_x64.exe'], _
			$iDelay = 5, $iInternalDelay = 2, _
			$sTempDir = FileGetLongName(@TempDir)

	If @Compiled = 0 Then
		Return SetError(1, 0, 0)
	EndIf

	Local Const $sScriptDir = _SciTE_GetSciTEDefaultHome() & '\' & _ProgramName()
	Local Const $sSciTEJump = $sScriptDir & '\' & $aProcess[1]
	If Not $bOverride And FileExists($sSciTEJump) = 0 Then
		Return SetError(2, 0, 0)
	EndIf

	If Not $bOverride Then
		If Not _IsUpdate($sSciTEJump) Then
			Return SetError(4, 0, 0)
		EndIf
	EndIf

	If Not $bOverride Then
		If MsgBox(BitOR($MB_SYSTEMMODAL, $MB_YESNO), _ProgramName(), _GetLanguage('UPDATE', 'Would you like to update %PROGRAMNAME%?')) = $IDNO Then
			Return SetError(4, 0, 0)
		EndIf
	EndIf

	Local $aArray = 0
	For $i = 1 To $aProcess[0]
		$aArray = ProcessList($aProcess[$i])
		For $j = 1 To $aArray[0][0]
			If Not ($aArray[$j][1] == @AutoItPID) Then
				ProcessClose($aArray[$j][1])
			EndIf
		Next
	Next

	Local Const $sBatFilePath = $sTempDir & '\' & _WinAPI_PathRemoveExtension(@ScriptName) & '.bat'
	Local Const $sScriptFullPath = @ScriptDir & '\' & _ProgramName() & '.exe'
	Local Const $sScriptFullPathX64 = @ScriptDir & '\' & _ProgramName() & '_x64.exe'

	Local Const $sFilePath = $sScriptDir & '\' & _WinAPI_PathStripPath($sScriptFullPath)
	Local Const $sFilePathX64 = $sScriptDir & '\' & _WinAPI_PathStripPath($sScriptFullPathX64)

	DirRemove($sScriptDir & '\Language\')
	FileMove(@ScriptDir & '\Languages\*.*', $sScriptDir & '\Languages\', $FC_OVERWRITE + $FC_CREATEPATH)
	FileMove(@ScriptDir & '\Source\*.*', $sScriptDir & '\Source\', $FC_OVERWRITE + $FC_CREATEPATH)
	FileMove(@ScriptDir & '\HelpFile.chm', $sScriptDir & '\HelpFile.chm', $FC_OVERWRITE + $FC_CREATEPATH)
	FileCopy(@ScriptDir & '\License.txt', $sScriptDir & '\License.txt', $FC_OVERWRITE + $FC_CREATEPATH)
	FileCopy(@ScriptDir & '\Readme.txt', $sScriptDir & '\Readme.txt', $FC_OVERWRITE + $FC_CREATEPATH)
	FileCopy($sScriptFullPath, $sFilePath, $FC_OVERWRITE + $FC_CREATEPATH)
	FileCopy($sScriptFullPathX64, $sFilePathX64, $FC_OVERWRITE + $FC_CREATEPATH)

	Local Const $iRecursiveRemove = 1
	DirRemove(@ScriptDir & '\Language\', $iRecursiveRemove)
	DirRemove(@ScriptDir & '\Source\', $iRecursiveRemove)
	FileSetAttrib(@ScriptDir & '\License.txt', '-R')
	FileDelete(@ScriptDir & '\License.txt')
	FileDelete(@ScriptDir & '\Readme.txt')

	Local Const $sData = 'SET TIMER=0' & @CRLF _
			 & ':START' & @CRLF _
			 & 'PING -n ' & $iInternalDelay & ' 127.0.0.1 > nul' & @CRLF _
			 & 'IF %TIMER% GTR ' & $iDelay & ' GOTO END' & @CRLF _
			 & 'SET /A TIMER+=1' & @CRLF _
			 & 'GOTO START' & @CRLF _
			 & @CRLF _
			 & ':END' & @CRLF _
			 & 'RD /S /Q  "' & @ScriptDir & '\Bin\"' & @CRLF _
			 & 'RD /S /Q  "' & @ScriptDir & '\Languages\"' & @CRLF _
			 & 'DEL /Q  "' & @ScriptDir & '\Settings.ini"' & @CRLF _
			 & 'DEL /Q "' & $sScriptFullPath & '"' & @CRLF _
			 & 'DEL /Q "' & $sScriptFullPathX64 & '"' & @CRLF _
			 & 'DEL /Q "' & $sBatFilePath & '"'

	_SetFile($sData, $sBatFilePath, $FO_APPEND)
	Run($sBatFilePath, $sTempDir, @SW_HIDE)
	Exit Run('"' & $sFilePath & '"', $sScriptDir)
EndFunc   ;==>_Update

Func _WinMerge_Get()
	Local $sWinMergePath = _WinAPI_ExpandEnvironmentStrings(IniRead($__sScriptDir & '\Settings.ini', 'General', 'WinMergePath', ''))
	If FileExists($sWinMergePath) Then
		Return $sWinMergePath
	EndIf

	Local Const $aFilePath[4] = [3, @ProgramFilesDir, EnvGet('PROGRAMFILES(X86)'), EnvGet('PROGRAMFILES')]
	Local $iError = 1
	For $i = 1 To $aFilePath[0]
		$sWinMergePath = $aFilePath[$i] & '\WinMerge\WinMergeU.exe'
		If FileExists($sWinMergePath) Then
			$iError = 0
			ExitLoop
		EndIf
	Next
	If $iError = 0 Then
		IniWrite($__sScriptDir & '\Settings.ini', 'General', 'WinMergePath', _WinAPI_PathUnExpandEnvStrings($sWinMergePath))
	EndIf
	Return SetError($iError, 0, $sWinMergePath)
EndFunc   ;==>_WinMerge_Get

Func _WinMerge_Run($sFilePath_1, $sFilePath_2)
	Local $iPID = 0
	Local Const $sWinMergePath = _WinMerge_Get()
	If @error = 0 Then
		$iPID = Run($sWinMergePath & ' "' & $sFilePath_1 & '" "' & $sFilePath_2 & '"')
	EndIf
	Return SetError($iPID = 0, 0, $iPID)
EndFunc   ;==>_WinMerge_Run

Func _WinWait($sTitle, $iTime)
	$iTime *= 1000
	Local Const $hTimer = TimerInit()
	Local $bWinExists = False

	While 1
		$bWinExists = WinExists($sTitle) = 1
		If $bWinExists Or TimerDiff($hTimer) > $iTime Then
			ExitLoop
		EndIf
		Sleep(10)
	WEnd
	Return $bWinExists
EndFunc   ;==>_WinWait

Func WM_ACTIVATE($hWnd, $iMsg, $wParam, $lParam)
	#forceref $iMsg, $lParam

	If $hWnd = $__vSciTEAPI[$__hSciTEResponseGUI] Then
		Switch _WinAPI_LoWord($wParam)
			Case $WA_ACTIVE, $WA_CLICKACTIVE
				If $__vGUIAPI[$__bGUIIsMinimised] Then
					GUISetState(@SW_SHOWNORMAL, $__vSciTEAPI[$__hSciTEResponseGUI])
					$__vGUIAPI[$__bGUIIsMinimised] = False
				EndIf

			Case $WA_INACTIVE
				_WinAPI_SetFocus(GUICtrlGetHandle($__vGUIAPI[$__iGUIProgressBar]))

		EndSwitch
	EndIf
EndFunc   ;==>WM_ACTIVATE

Func WM_COMMAND($hWnd, $iMsg, $wParam, $lParam)
	#forceref $hWnd, $iMsg, $lParam

	Local Const $iLoWord = _WinAPI_LoWord($wParam)
	Local Const $iHiWord = _WinAPI_HiWord($wParam)
	Local $vInput = ''
	Switch $iLoWord
		Case $__vGUIAPI[$__iGUIInputFind]
			Switch $iHiWord
				Case $EN_CHANGE
					$__vMiscAPI[$__sMiscSearchedText] = ''
					$vInput = GUICtrlRead($__vGUIAPI[$__iGUIInputFind])
					If Not $vInput Then
						_TreeView_Create()
						_FindDestroy()
						_SearchDestroy()
					EndIf

				Case $EN_SETFOCUS
					$__vMiscAPI[$__sMiscSearchedText] = ''
					$vInput = GUICtrlRead($__vGUIAPI[$__iGUIInputFind])
					If $vInput And $__vMiscAPI[$__bMiscFindInFile] Then
						_TreeView_Create(False)
						_SearchCreate(False)
						_FindCreate()
					Else
						_FindCreate(False)
						_SearchCreate(False)
						_TreeView_Create()
					EndIf

			EndSwitch

		Case $__vGUIAPI[$__iGUIInputLine]
			Switch $iHiWord
				Case $EN_CHANGE, $EN_SETFOCUS
					If _WinAPI_GetFocus() = GUICtrlGetHandle($__vGUIAPI[$__iGUIInputLine]) Then ; Workaround for focus on input.
						$vInput = GUICtrlRead($__vGUIAPI[$__iGUIInputLine])
						If StringRegExp($vInput, '\D') Then
							$vInput = Int(StringRegExpReplace($vInput, '\D', ''))
						EndIf
						If $vInput = 0 Then
							$vInput = ''
							GUICtrlSetData($__vGUIAPI[$__iGUIInputLine], $vInput)
						EndIf
						If $vInput > 0 Then
							_SciTE_GoToLine($vInput - 1)
							_SciTE_SetFirstVisibleLine($vInput - 1)
						EndIf
					EndIf

				Case $EN_KILLFOCUS

			EndSwitch

		Case $__vGUIAPI[$__iGUIInputLinePixel]
			$vInput = GUICtrlRead($__vGUIAPI[$__iGUIInputLinePixel])
			If StringRegExp($vInput, '\D') Then
				$vInput = Int(StringRegExpReplace($vInput, '\D', ''))
				GUICtrlSetData($__vGUIAPI[$__iGUIInputLinePixel], $vInput)
			EndIf

		Case $__vGUIAPI[$__iGUIInputSearch]
			$vInput = GUICtrlRead($__vGUIAPI[$__iGUIInputSearch])
			Switch $iHiWord
				Case $EN_SETFOCUS
					$__vMiscAPI[$__sMiscSearchedText] = ''
					AdlibUnRegister('WM_COMMAND_TIMER')
					AdlibRegister('WM_COMMAND_TIMER', 250)

				Case $EN_CHANGE
					AdlibUnRegister('WM_COMMAND_TIMER')
					AdlibRegister('WM_COMMAND_TIMER', 250)

				Case $EN_MAXTEXT
					AdlibUnRegister('WM_COMMAND_TIMER')
					If StringStripWS($vInput, $STR_STRIPALL) Then
						If Not ($__vMiscAPI[$__sMiscSearchedText] == $vInput) Then
							$__vMiscAPI[$__sMiscSearchedText] = $vInput
							If $__vMiscAPI[$__bMiscFindInFile] Then
								_FindCreate(False)
								_Search($vInput, $__aFindItems)
							Else
								_TreeView_Create(False)
								_Search($vInput, $__aTreeViewItems)
							EndIf
						EndIf

					Else
						$__vMiscAPI[$__sMiscSearchedText] = ''
						_SearchCreate(False)
						_SearchDestroy()
						If $__vMiscAPI[$__bMiscFindInFile] And $__aFindItems[0][0] > 0 Then
							_TreeView_Create(False)
							_FindCreate()
						Else
							_FindDestroy()
							_TreeView_Create()
						EndIf
					EndIf

				Case $EN_KILLFOCUS
					; _SendMessage($__vSciTEAPI[$__hSciTEResponseGUI], $WM_COMMAND, _WinAPI_MakeLong($__vGUIAPI[$__iGUIInputSearch], $EN_CHANGE))
					; _SendMessage($__vSciTEAPI[$__hSciTEResponseGUI], $WM_COMMAND, _WinAPI_MakeLong($__vGUIAPI[$__iGUIInputSearch], $EN_KILLFOCUS))

			EndSwitch
	EndSwitch
	Return $GUI_RUNDEFMSG
EndFunc   ;==>WM_COMMAND

Func WM_COMMAND_TIMER()
	AdlibUnRegister('WM_COMMAND_TIMER')
	_SendMessage($__vSciTEAPI[$__hSciTEResponseGUI], $WM_COMMAND, _WinAPI_MakeLong($__vGUIAPI[$__iGUIInputSearch], $EN_MAXTEXT))
EndFunc   ;==>WM_COMMAND_TIMER

Func WM_GETMINMAXINFO($hWnd, $iMsg, $wParam, $lParam) ; Original idea by Zedna & updated by guinness.
	#forceref $hWnd, $iMsg, $wParam
	Local Const $aControl = ControlGetPos($__vSciTEAPI[$__hSciTEWindow], '', '[CLASS:Scintilla; INSTANCE:1]')
	If @error = 0 Then
		If $aControl[3] - 50 < $__vGUIAPI[$__iGUIMinHeight] Then
			$__vGUIAPI[$__iGUIMinHeight] = $aControl[3] - 50
		EndIf
	EndIf
	Local Const $tagMINMAXINFO = 'struct; long ReservedX;long ReservedY;long MaxSizeX;long MaxSizeY;long MaxPositionX;long MaxPositionY;' & _
			'long MinTrackSizeX;long MinTrackSizeY;long MaxTrackSizeX;long MaxTrackSizeY; endstruct'
	Local Const $tMINMAXINFO = DllStructCreate($tagMINMAXINFO, $lParam)
	DllStructSetData($tMINMAXINFO, 'MinTrackSizeX', $__vGUIAPI[$__iGUIMinWidth] + 16)
	DllStructSetData($tMINMAXINFO, 'MinTrackSizeY', $__vGUIAPI[$__iGUIMinHeight] + 38)
	DllStructSetData($tMINMAXINFO, 'MaxTrackSizeX', @DesktopWidth)
	DllStructSetData($tMINMAXINFO, 'MaxTrackSizeY', @DesktopHeight)
EndFunc   ;==>WM_GETMINMAXINFO

Func WM_LBUTTONDBLCLK($hWnd, $iMsg, $wParam, $lParam)
	#forceref $hWnd, $iMsg, $wParam, $lParam
	ControlClick($__vSciTEAPI[$__hSciTEResponseGUI], '', $__vGUIAPI[$__iGUIDockWindow])
	Return $GUI_RUNDEFMSG
EndFunc   ;==>WM_LBUTTONDBLCLK

Func WM_NOTIFY($hWnd, $iMsg, $wParam, $lParam)
	#forceref $hWnd, $iMsg, $wParam

	Local Const $tNMHDR = DllStructCreate($tagNMHDR, $lParam)
	Local Const $hWndFrom = DllStructGetData($tNMHDR, 'hWndFrom')
	Local Const $iIDFrom = DllStructGetData($tNMHDR, 'IDFrom')
	Local Const $iCode = DllStructGetData($tNMHDR, 'Code')

	Local $iItem = 0, $iMode = -1, $tHitTest = 0
	Switch $iCode
		Case $NM_RCLICK
			Switch $iIDFrom
				Case $__vGUIAPI[$__iGUIArrayListView]
					$tHitTest = DllStructCreate($tagNMITEMACTIVATE, $lParam)
					$iItem = DllStructGetData($tHitTest, 'Index')

					$iMode = _GUICtrlTreeView_ContextMenu($__vSciTEAPI[$__hSciTEResponseGUI], $iItem, DllStructGetData($tHitTest, 'SubItem'), 4)
					If @error = 0 Then
						$__vMiscAPI[$__iMiscAddHeaderOrOpenLocation] = -1
						Switch $iMode
							Case 1
								_SciTE_Open(_GUICtrlListView_GetItemText($__vGUIAPI[$__iGUIArrayListView], $iItem))
							Case 2
								$__vMiscAPI[$__iMiscAddHeaderOrOpenLocation] = $iItem
							Case 3
								ShellExecute(_WinAPI_PathRemoveFileSpec(_GUICtrlListView_GetItemText($__vGUIAPI[$__iGUIArrayListView], $iItem)))
						EndSwitch
					EndIf

				Case $__vGUIAPI[$__iGUITreeView], $__vGUIAPI[$__iGUITreeViewFind], $__vGUIAPI[$__iGUITreeViewSearch]
					Local $tPOINT = _WinAPI_GetMousePos(True, $hWndFrom)
					$tHitTest = _GUICtrlTreeView_HitTestEx($hWndFrom, DllStructGetData($tPOINT, 'X'), DllStructGetData($tPOINT, 'Y'))
					If BitAND(DllStructGetData($tHitTest, 'Flags'), $TVHT_ONITEM) Then
						$iItem = DllStructGetData($tHitTest, 'Item')
						Local $hTreeViewParent = _GUICtrlTreeView_GetParentHandle($iIDFrom, _GUICtrlTreeView_GetItemHandle($iIDFrom, $iItem))
						If $__vMiscAPI[$__bMiscFindInFile] Then
							$iMode = 0
						ElseIf $__vMiscAPI[$__bMiscFindInFile] = False And $iIDFrom = $__vGUIAPI[$__iGUITreeView] And Not _IsEmpty($__vCurrentFileAPI[$__sCurrentFilePath]) Then
							If ($hTreeViewParent = GUICtrlGetHandle($__vTreeViewParentsAPI[$__iTreeViewParentsComment])) Or _
									($hTreeViewParent = GUICtrlGetHandle($__vTreeViewParentsAPI[$__iTreeViewParentsRegion])) Or _
									($hTreeViewParent = GUICtrlGetHandle($__vTreeViewParentsAPI[$__iTreeViewParentsUDF])) Then
								$iMode = 3
							Else
								$iMode = 1
							EndIf
						ElseIf $__vMiscAPI[$__bMiscFindInFile] = False And $iIDFrom = $__vGUIAPI[$__iGUITreeViewSearch] And Not _IsEmpty($__vCurrentFileAPI[$__sCurrentFilePath]) Then
							$iMode = 2
						EndIf

						Local $bIsChild = 0
						For $i = 1 To $__vTreeViewParentsAPI[$__iTreeViewParentsCount]
							$bIsChild += Int(_GUICtrlTreeView_IsParent($__vGUIAPI[$__iGUITreeViewCurrent], $__vTreeViewParentsAPI[$i], $iItem))
						Next
						$bIsChild = $bIsChild > 0

						If $iMode >= 0 And $bIsChild Then
							_GUICtrlTreeView_ContextMenu($__vSciTEAPI[$__hSciTEResponseGUI], $iItem, 1, $iMode)
							If @error = 0 Then
								_GUICtrlTreeView_SelectItem($hWndFrom, 0)
								_GUICtrlTreeView_SelectItem($hWndFrom, $iItem)
							EndIf
						EndIf
					EndIf
			EndSwitch

		Case $NM_DBLCLK
			Switch $iIDFrom
				Case $__vGUIAPI[$__iGUIArrayListView]
					$tHitTest = DllStructCreate($tagNMITEMACTIVATE, $lParam)
					$iItem = DllStructGetData($tHitTest, 'Index')
					If $iItem > -1 Then
						_SciTE_Open(_GUICtrlListView_GetItemText($__vGUIAPI[$__iGUIArrayListView], $iItem))
					EndIf
			EndSwitch

		Case $TVN_ITEMEXPANDINGA, $TVN_ITEMEXPANDINGW

	EndSwitch
	Return $GUI_RUNDEFMSG
EndFunc   ;==>WM_NOTIFY

Func WM_POWERBROADCAST($hWnd, $iMsg, $wParam, $lParam)
	#forceref $hWnd, $iMsg, $lParam
	Switch $wParam
		Case $PBT_APMRESUMEAUTOMATIC
			$__vGUIAPI[$__bGUIIsMinimised] = False
			$__vMiscAPI[$__bMiscToggleFoldOrNoRefresh] = False
			_SciTE_Startup()
			_TreeView_Create()
			_FindDestroy()
			_SearchDestroy()
			_Monitor()
			_Monitor_Check(False, 'Monitor_Refresh')
	EndSwitch
EndFunc   ;==>WM_POWERBROADCAST

Func WM_SIZE($hWnd, $iMsg, $wParam, $lParam)
	#forceref $hWnd, $iMsg, $wParam
	$__vGUIAPI[$__iGUIHeight] = _WinAPI_HiWord($lParam)
	$__vGUIAPI[$__iGUIWidth] = _WinAPI_LoWord($lParam)
	Return $GUI_RUNDEFMSG
EndFunc   ;==>WM_SIZE

Func WM_SYSCOMMAND($hWnd, $iMsg, $wParam, $lParam)
	#forceref $hWnd, $iMsg, $lParam
	$wParam = Int($wParam)
	Switch $wParam
		Case $__iContextMenu1 To $__iContextMenu2
			_System_ContextMenu(Default, $wParam)

	EndSwitch
	Return $GUI_RUNDEFMSG
EndFunc   ;==>WM_SYSCOMMAND

#Region >>>>> Additional Language Strings <<<<<
#cs
	_GetLanguage('CLOSE', 'Close')
	_GetLanguage('LANGUAGE_AUTHOR', 'Thanks to %LANGUAGEAUTHOR% for the %LANGUAGE% translation. The translation was created on the %LANGUAGEUPDATED%.')
	_GetLanguage('TIP_ERROR_1', 'Empty file.')
	_GetLanguage("TIP_ERROR_3", "File doesn't exist.")
	_GetLanguage('TIP_ERROR_4', 'SciTE seems to be closed.')
	_GetLanguage('TIP_DOCKSTATE_1', 'Automatic docking')
	_GetLanguage('TIP_DOCKSTATE_2', 'Left docking')
	_GetLanguage('TIP_DOCKSTATE_3', 'Right docking')
#ce
#EndRegion >>>>> Additional Language Strings <<<<<
