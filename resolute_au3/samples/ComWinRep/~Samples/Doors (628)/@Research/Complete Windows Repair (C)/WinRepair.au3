#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=Resources\WinRepair.ico
#AutoIt3Wrapper_Outfile=WinRepair.exe
#AutoIt3Wrapper_Outfile_x64=WinRepair_64Bit.exe
#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_Compile_Both=y
#AutoIt3Wrapper_UseX64=y
#AutoIt3Wrapper_Res_Description=Complete Windows Repair
#AutoIt3Wrapper_Res_Fileversion=0.0.0.52
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=y
#AutoIt3Wrapper_Res_LegalCopyright=Rizonesoft
#AutoIt3Wrapper_Res_requestedExecutionLevel=highestAvailable
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****


Opt("TrayMenuMode", 1) ;~ Default tray menu items (Script Paused/Exit) will not be shown.
Opt("MustDeclareVars", 1)
Opt("GUIOnEventMode", 1)


#include <WindowsConstants.au3>
#include <GUIConstantsEx.au3>
#include <GuiButton.au3>
#Include <GuiEdit.au3>
#include <Misc.au3>

#include <UDF\Core.au3>


Global Const $winRepLog = $DIR_RECORDING & "\WinRepair.log"

Global Const $exitProcess = False

Global $crepForm, $cwrIco, $eStatus

Global $btnHome, $btnClean, $btnDesktop, $btnExplorer, $btnAssociations, $btnAssociations2, $btnApplications, $btnInternet, $btnSystem
Global $homePage, $homeGroup, $btnSFCScan, $btnRestore, $btnHomeNext

Global $cleanPage, $cleanGroup,  $btnCleanBack, $btnCleanNext, $cleanBtnGo, $cleanCount = 19
Global $cleanChk[$cleanCount + 1], $cleanRepIco[$cleanCount + 1], $cleanRepBtn[$cleanCount + 1], $cleanHover[$cleanCount + 1]
Global $deskPage, $deskGroup, $btnDeskBack, $btnDeskNext, $deskBtnGo, $deskCount = 19
Global $deskChk[$deskCount + 1], $deskRepIco[$deskCount + 1], $deskRepBtn[$deskCount + 1], $deskHover[$deskCount + 1]
Global $explPage, $explGroup, $btnExplBack, $btnExplNext, $explCount = 19
Global $explChk[$explCount + 1], $explRepIco[$explCount + 1], $explRepBtn[$explCount + 1], $explHover[$explCount + 1]
Global $assPage, $assGroup, $btnAssBack, $btnAssNext, $assBtnGo, $assCount = 19
Global $assChk[$assCount + 1], $assRepIco[$assCount + 1], $assRepBtn[$assCount + 1], $assHover[$assCount + 1]
Global $ass2Page, $ass2Group, $btnAss2Back, $btnAss2Next, $ass2BtnGo, $ass2Count = 19
Global $ass2Chk[$ass2Count + 1], $ass2RepIco[$ass2Count + 1], $ass2RepBtn[$ass2Count + 1], $ass2Hover[$ass2Count + 1]
Global $appPage, $appGroup, $btnAppBack, $btnAppNext, $appBtnGo, $appCount = 19
Global $appChk[$assCount + 1], $appRepIco[$appCount + 1], $appRepBtn[$appCount + 1], $appHover[$appCount + 1]

Global $intPage, $intGroup, $btnIntBack, $btnIntNext, $intBtnGo, $intCount = 19
Global $intChk[$intCount + 1], $intRepIco[$intCount + 1], $intRepBtn[$intCount + 1], $intHover[$intCount + 1]
Global $sysPage, $sysGroup, $btnSysBack, $sysBtnGo, $sysCount = 19
Global $sysChk[$sysCount + 1], $sysRepIco[$sysCount + 1], $sysRepBtn[$sysCount + 1], $sysHover[$sysCount + 1]

If _Singleton(@ScriptName, 1) = 0 Then

	MsgBox(262192, "Warning!", "An occurence of 'Complete Windows Repair' is already running.", 30)
	Exit

Else

	_InitializeLogFile($winRepLog, 5)
	_LoggingWrite("", False)
	_LoggingWrite("", False)
	_LoggingWrite("                                            ./", False)
	_LoggingWrite("                                          (o o)", False)
	_LoggingWrite("--------------------------------------oOOo-(_)-oOOo--------------------------------------", False)

	_loadMainGUI()

EndIf

Func _loadMainGUI()

	Local $mainTAB
	Local Const $Gap = 20

	$crepForm = GUICreate("Rizonesoft Complete Windows Repair " & FileGetVersion(@ScriptFullPath), 650, 680)
	GUISetFont(8.5, 400, -1, "Verdana", $crepForm, 5)

	$cwrIco = GUICtrlCreateIcon(@ScriptFullPath, 99, 43, 10, 64, 64)

	$btnHome = GUICtrlCreateButton("Home", 10, 100, 130, 30)
	$btnClean = GUICtrlCreateButton("Clean", 10, 130, 130, 30)
	$btnDesktop = GUICtrlCreateButton("Desktop", 10, 160, 130, 30)
	$btnExplorer = GUICtrlCreateButton("Explorer", 10, 190, 130, 30)
	$btnAssociations = GUICtrlCreateButton("Associations (1)", 10, 220, 130, 30)
	$btnAssociations2 = GUICtrlCreateButton("Associations (2)", 10, 250, 130, 30)
	$btnApplications = GUICtrlCreateButton("Applications", 10, 280, 130, 30)
	$btnInternet = GUICtrlCreateButton("Internet", 10, 310, 130, 30)
	$btnSystem = GUICtrlCreateButton("System", 10, 340, 130, 30)

	GuiCtrlSetOnEvent($btnHome, "_SelectPage")
	GuiCtrlSetOnEvent($btnClean, "_SelectPage")
	GuiCtrlSetOnEvent($btnDesktop, "_SelectPage")
	GuiCtrlSetOnEvent($btnExplorer, "_SelectPage")
	GuiCtrlSetOnEvent($btnAssociations, "_SelectPage")
	GuiCtrlSetOnEvent($btnAssociations2, "_SelectPage")
	GuiCtrlSetOnEvent($btnApplications, "_SelectPage")
	GuiCtrlSetOnEvent($btnInternet, "_SelectPage")
	GuiCtrlSetOnEvent($btnSystem, "_SelectPage")

	$eStatus = GUICtrlCreateEdit("", 150, 530, 490, 125, BitOR($WS_VSCROLL, $WS_HSCROLL, $ES_READONLY, $ES_AUTOVSCROLL, $ES_MULTILINE))
	GUICtrlSetBkColor($eStatus, 0xFFFFFF)

	$mainTAB = GUICtrlCreateTab(150, -25, 525, 550)

	$homePage = GUICtrlCreateTabItem("Home")
	$homeGroup = GuiCtrlCreateGroup("Welcome", 165, 10, 470, 450)
	GUICtrlSetFont($homeGroup, 10)
	GuiCtrlCreateLabel(	"Windows has this nasty little habit of breaking down, mostly because of malicious software. " & _
						"Normally malware uses a feature of Windows called policies to lock you out of certain " & _
						"functions. If that was not bad enough, malware also uses other techniques or configuration " & _
						"changes to make life suck just a little more. Apart from all of this, you also need to " & _
						"deal with file corruption and other badly programmed applications messing things up. With " & _
						"millions of things that can go wrong with your Windows computer, the 100 or so solutions are " & _
						"just not adequate. Complete Windows Repair tries to fill the gaps. " & @CRLF & @CRLF & _
						"Before you try any of the solutions, we suggest you scan your system files using a little hidden " & _
						"Windows utility called System File Checker (SFC). To scan your system files you can run the " & Chr(34) & "sfc  " & _
						"/scannow" & Chr(34) & " command from the Windows command prompt or click the Scannow button below. Let SFC do " & _
						"its thing and reboot your computer if asked.  ", 190, 50, 420, 210)
	GUICtrlCreateGroup("", -99, -99, 1, 1)  ;~ Close group
	$btnSFCScan = GUICtrlCreateButton("Scannow", 200, 280, 130, 30)
	GuiCtrlCreateLabel(	"It is highly recommended that you create a system restore point in case Complete Windows Repair " & _
						"breaks something. Click the button below to create a system restore point. ", 190, 340, 420, 50)
	$btnRestore = GuiCTrlCreateButton("Create system restore point", 200, 410, 200, 30)
	GuiCtrlSetOnEvent($btnSFCScan, "_RunSystemFileScanner")
	GuiCtrlSetOnEvent($btnRestore, "_CreateSystemRestorePoint")
	GUICtrlCreateTabItem("") ; end tabitem definition

	GUISetState(@SW_SHOW)

	;GUIRegisterMsg($WM_COMMAND, "MY_WM_COMMAND")
	GUISetOnEvent($GUI_EVENT_CLOSE, "_CloseWindowsRepair")

	While 1

		Sleep(55)
		;_ExplorerHover()

	WEnd

EndFunc


Func _SelectPage()
	Switch @GUI_CtrlId
		Case $btnHome, $btnCleanBack
			GuiCTrlSetState($homePage, $GUI_SHOW)
		Case $btnClean, $btnHomeNext, $btnDeskBack
			GUICtrlSetState($cleanPage, $GUI_SHOW)
		Case $btnDesktop, $btnCleanNext, $btnExplBack
			GUICtrlSetState($deskPage, $GUI_SHOW)
		Case $btnExplorer, $btnDeskNext, $btnAssBack
			GUICtrlSetState($explPage, $GUI_SHOW)
		Case $btnAssociations, $btnExplNext, $btnAss2Back
			GUICtrlSetState($assPage, $GUI_SHOW)
		Case $btnAssociations2, $btnAssNext, $btnAppBack
			GUICtrlSetState($ass2Page, $GUI_SHOW)
		Case $btnApplications, $btnAss2Next, $btnIntBack
			GUICtrlSetState($appPage, $GUI_SHOW)
		Case $btnInternet, $btnAppNext, $btnSysBack
			GUICtrlSetState($intPage, $GUI_SHOW)
		Case $btnSystem, $btnIntNext
			GUICtrlSetState($sysPage, $GUI_SHOW)
	EndSwitch
EndFunc


Func _CloseWindowsRepair()

	GUISetState(@SW_HIDE, $crepForm)
	GUIDelete($crepForm)

	If $exitProcess = True Then
		Local $processID = ProcessExists(@ScriptName) ; Will return the PID or 0 if the process isn't found.
		If $processID Then ProcessClose($processID)
	EndIf

	Exit

EndFunc


Func _RunSystemFileScanner()

	_ClearLoggingMemo()
	_MemoLoggingWrite("Scanning your system files, please do not close the openned window...", 0, False)
	_MemoLoggingWrite("-----------------------------------------------------------------------------------------", 0, False)
	_MemoLoggingWrite("SFC /SCANNOW")
	ShellExecute("SFC", "/SCANNOW", "", "", @SW_SHOW)
	;Run(@ComSpec & " /c " & "sfc.exe /scannow", "", @SW_SHOW)
	_MemoLoggingWrite("", 0, False)
	_MemoLoggingWrite("-----------------------------------------------------------------------------------------", 0, False)

EndFunc


Func _CreateSystemRestorePoint()
EndFunc


Func _InitializeLogFile($logFile, $maxSize)

	$maxSize = $maxSize / 1048576

	If Not FileExists($DIR_RECORDING) Then DirCreate($DIR_RECORDING)

	If FileExists($logFile) Then
		FileSetAttrib($logFile, "-A-S-R-H")
		If Round(FileGetSize($logFile) / 1048576) > $maxSize Then
			If FileExists($logFile) Then
				FileDelete($logFile)
			EndIf
		EndIf
	Else
	EndIf

EndFunc


Func _StartLogging($logFile, $Message)

	_ClearLoggingMemo()
	_MemoLoggingWrite($Message, 0, False)
	_MemoLoggingWrite("-----------------------------------------------------------------------------------------", 0, False)

EndFunc


Func _EndLogging($logFile)

	_MemoLoggingWrite("", 0, False)
	_MemoLoggingWrite("-----------------------------------------------------------------------------------------", 0, False)

EndFunc


Func _ClearLoggingMemo()
	If not IsDeclared("eStatus") Then Local $eStatus
	GuicTrlSetData($eStatus, "")
EndFunc


Func _MemoLoggingWrite($Message = "", $iSuccess = 0, $timeStamp = True)


	If not IsDeclared("eStatus") Then Local $eStatus
	Local $strPrefix = ""

	Select
		Case $iSuccess = 1
			GuiCtrlSetColor($eStatus, 0x066186)
		Case $iSuccess = 2
			GuiCtrlSetColor($eStatus, 0xB20000)
		Case $iSuccess = 3
			GuiCtrlSetColor($eStatus, 0xE6791A)
	EndSelect
	Sleep(10)

	_GUICtrlEdit_AppendText($eStatus, $strPrefix & $Message & @CRLF)
	_LoggingWrite($strPrefix & $Message, $timeStamp)

EndFunc


Func _LoggingWrite($Message = "", $timeStamp = True)

	Local $openLog, $sTimeStamp = ""

	;If $logEnabled = 1 Then

		$openLog = FileOpen($winRepLog, 1)
		If $openLog = -1 Then
		EndIf

		If $timeStamp Then $sTimeStamp = 	"[" & @MDAY & "/" & @MON & "/" & @YEAR & _
										" " & @HOUR & ":" & @MIN & ":" & @SEC & "] "
		FileWrite($openLog, $sTimeStamp & $Message & @CRLF)
		FileClose($openLog)

	;EndIf

EndFunc