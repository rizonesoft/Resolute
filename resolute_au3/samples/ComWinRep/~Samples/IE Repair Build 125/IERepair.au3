#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.2.0
 Author:         Rizone Technologies

 Script Function:
	Repair Internet Explorer.

#ce ----------------------------------------------------------------------------

#AutoIt3Wrapper_icon=Resources\IERepair.ico
#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_Res_Description=Repair Internet Explorer
#AutoIt3Wrapper_Res_Fileversion=0.0.0.125
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=y


#NoTrayIcon
#RequireAdmin


#include <WindowsConstants.au3>
#include <ButtonConstants.au3>
#include <GuiConstantsEx.au3>
#include <EditConstants.au3>
#Include <GuiEdit.au3>
#include <Misc.au3>


Opt("TrayMenuMode", 1) ;~ Default tray menu items (Script Paused/Exit) will not be shown.
;~ Opt("GUIOnEventMode", 1)
;~ Opt("TrayOnEventMode", 1)
Opt("MouseClickDelay", 5)
Opt('MustDeclareVars', 1)
Opt("MouseClickDownDelay", 5)
Opt("MouseClickDragDelay", 200)
;~ Opt("TrayIconDebug", 1) ;~ 0 = no info, 1 = debug line info


Global Const $IERepSettings = @ScriptDir & "\IERepair.ini"
Global Const $IERepTitle = "Internet Explorer Repair", $IERepVer = FileGetVersion(@ScriptDir & "\" & @ScriptName)
Global Const $IERFormTitle = $IERepTitle & " " & $IERepVer
Global Const $BinDir = @ScriptDir & "\Bin"
Global Const $ResDir = @ScriptDir & "\Resources"
Global Const $LogDir = @ScriptDir & "\Logging"
Global Const $SoundDir = @ScriptDir & "\Sounds"
Global Const $IERepLog = $LogDir & "\IERepair.log"
Global Const $IERepIconRes = $ResDir & "\IEReapir.ico"
Global Const $IERepProccRes = $ResDir & "\Process.ani"
Global Const $GNote2Exe = $BinDir & "\Notepad2\Notepad2.exe"

Global $GIERepLogSize = IniRead($IERepSettings, "Logging", "Size", 2)
Global $IERepForm, $IERepIcon, $GProcAni, $BtnGo, $eStatus
Global $IEEXE = @ProgramFilesDir & "\Internet Explorer\iexplore.exe", $IEVersion


If FileExists($IEEXE) Then

	Local $TString =  StringSplit(FileGetVersion($IEEXE), ".")
	$IEVersion = $TString[1] & "." & $TString[2]

EndIf


If _Singleton(@ScriptName, 1) = 0 Then

	MsgBox(262192, "Warning", "An occurence of " & $IERepTitle & " is already running.", 30)
	Exit

Else

	If @ScriptName <> "IERepair.exe" Then
		FileMove(@ScriptFullPath, @ScriptDir & "\IERepair.exe", 0)
		MsgBox(48, "Tamper Warning", 	"It looks like you renamed IERepair.exe to " & @ScriptName & ". It is not polite to tamper with other people's hard work. " &  _
										"No worries, we renamed it back to IERepair.exe. All you need to do is start it again.")
		Exit
	EndIf

	If Not FileExists($LogDir) Then DirCreate($LogDir)
	If Not FileExists($BinDir) Then DirCreate($BinDir)
	If Not FileExists($SoundDir) Then DirCreate($SoundDir)

	If FileExists($IERepLog) Then
		If Not FileSetAttrib($IERepLog, "-RASHOT") Then
			MsgBox(4096, "Error", "Problem setting attributes.")
		EndIf
	Else
		If FileGetSize($IERepLog) > ($GIERepLogSize * 1024) * 1024 Then
			FileDelete($IERepLog)
		EndIf
	EndIf

	_Main()

EndIf


Func _Main()

	Local $nMsg

	If Not FileExists($ResDir) Then DirCreate($ResDir)

	If @Compiled Then
		FileInstall("Resources\IERepair.ico", $IERepIconRes, 0)
		FileInstall("Resources\Process.ani", $IERepProccRes, 0)
	EndIf

	$IERepForm = GUICreate($IERFormTitle, 400, 300, -1, -1)
	GUISetFont(8.5, 400, 0, "Verdana")
	GUISetBkColor(0xEBEBEB)
	$IERepIcon = GUICtrlCreateIcon($IERepIconRes, -1, 10, 10, 48, 48)
	GUICtrlCreateLabel(	"If you face any problems running Internet Explorer, just press the 'Go!' button to re-register all the " & _
						"dll and ocx files required by Internet Explorer for smooth operation.", 75, 10, 300, 100)
	$BtnGo = GUICtrlCreateButton("Go!", 190, 120, 200, 50, $BS_DEFPUSHBUTTON)
	GuiCtrlSetState($BtnGo, $GUI_FOCUS)
	GUICtrlSetFont($BtnGo, 11, 400, 0, "Verdana")
	$eStatus = GUICtrlCreateEdit("", 10, 180, 380, 100, BitOR($WS_VSCROLL, $WS_HSCROLL, $ES_READONLY, $ES_AUTOVSCROLL))
	GUICtrlSetBkColor($eStatus, 0xFFFFFF)

	_MemoLogWrite("--------------------------------------------------", 0, 0)
	_MemoLogWrite("Internet Explorer " & $IEVersion, 0, 0)
	_MemoLogWrite("--------------------------------------------------", 0, 0)

	SoundPlay($SoundDir & "\welcome.wav")

	GUISetState(@SW_SHOW)

	While 1

		$nMsg = GUIGetMsg()

		Switch $nMsg

			Case $BtnGo

				_DisableControls()
				;~ _ReregisterDLL(@SystemDir & "\browseui.dll", "/s /i")
				_ReregisterDLL("corpol.dll")
				_ReregisterDLL("dxtmsft.dll")
				_ReregisterDLL("dxtrans.dll")

				;~ Simple HTML Mail API
				;~ _ReregisterDLL(@ProgramFilesDir & "\Internet Explorer\hmmapi.dll")

				;~ Group Policy Snap-In
				_ReregisterDLL("ieaksie.dll")

;~ 				;~ Smart Screen
;~ 				_ReregisterDLL("ieapfltr.dll")

;~ 				;~ IEAK Branding
;~ 				_ReregisterDLL("iedkcs32.dll")

;~ 				;~ Dev Tools
;~ 				_ReregisterDLL(@ProgramFilesDir & "\Internet Explorer\iedvtool.dll")
;~ 				_ReregisterDLL("iepeers.dll")

;~ 				;~ Symptom: IE8 closes immediately on launch, missing from IE7
;~ 				_ReregisterDLL(@ProgramFilesDir & "\Internet Explorer\ieproxy.dll")

;~ 				;~ No install point anymore
;~ 				;~ _ReregisterDLL("iesetup.dll", "/s /i")
;~ 				;~ No reg point anymore
;~ 				;~ _ReregisterDLL("imgutil.dll")
;~ 				_ReregisterDLL("inetcpl.cpl", "/s /i /n")
;~ 				;~ No install point anymore
;~ 				;~ _ReregisterDLL("inseng.dll", "/s /i")
;~ 				_ReregisterDLL("jscript.dll")

;~ 				;~ License manager
;~ 				_ReregisterDLL("licmgr10.dll")
;~ 				;~ _ReregisterDLL("msapsspc.dll")
;~ 				;~ _ReregisterDLL("mshta.exe")

;~ 				;~ VS debugger
;~ 				_ReregisterDLL("msdbg2.dll")
;~ 				;~ No install point anymore
;~ 				;~ _ReregisterDLL("mshtml.dll", "/s /i")
;~ 				_ReregisterDLL("mshtmled.dll")
;~ 				_ReregisterDLL("msident.dll")
;~ 				;~ No reg point anymore
;~ 				;~ _ReregisterDLL("msrating.dll")

;~ 				;~ Multimedia timer
;~ 				_ReregisterDLL("mstime.dll")
;~ 				;~ No install point anymore
;~ 				;~ _ReregisterDLL("occache.dll", "/s /i")

;~ 				;~ Process debug manager
;~ 				_ReregisterDLL(@ProgramFilesDir & "\Internet Explorer\pdm.dll")
;~ 				;~ No reg point anymore
;~ 				;~ _ReregisterDLL("pngfilt.dll")
;~ 				;~ _ReregisterDLL("setupwbv.dll", "/s /i")	(not there anymore!)
;~ 				_ReregisterDLL("tdc.ocx")
;~ 				_ReregisterDLL("urlmon.dll", "/s /i")
;~ 				;~ _ReregisterDLL("urlmon.dll,NI,HKLM", "/s /i")
;~ 				_ReregisterDLL("vbscript.dll")

;~ 				;~ VML renderer
;~ 				_ReregisterDLL(@CommonFilesDir & "\microsoft shared\VGX\VGX.dll")
;~ 				;~ No install point anymore
;~ 				;~ _ReregisterDLL("webcheck.dll", "/s /i")
;~ 				_ReregisterDLL("wininet.dll", "/s /i /n")

;~ 				;~ Registering system files
;~ 				;~ dditional system dlls known to be used by IE
;~ 				;~ Symptom: Add-Ons-Manager menu entry is present but nothing happens
;~ 				_ReregisterDLL("extmgr.dll")

;~ 				;~ Symptom: Javascript links don't work
;~ 				_ReregisterDLL("mscoree.dll")

;~ 				;~ Symptom: Find on this page is blank
;~ 				_ReregisterDLL("oleacc.dll")

;~ 				;~ Symptom: Printing problems, open in new window
;~ 				_ReregisterDLL("ole32.dll")
;~ 				;~ mscorier.dll
;~ 				;~ mscories.dll

;~ 				;~ Symptom: open in new tab/window not working
;~ 				_ReregisterDLL("actxprxy.dll")
;~ 				_ReregisterDLL("asctrls.ocx")
;~ 				_ReregisterDLL("cdfview.dll")
;~ 				_ReregisterDLL("comcat.dll")
;~ 				_ReregisterDLL("comctl32.dll", "/s /i /n")
;~ 				_ReregisterDLL("cryptdlg.dll")
;~ 				_ReregisterDLL("digest.dll", "/s /i /n")
;~ 				_ReregisterDLL("dispex.dll")
;~ 				_ReregisterDLL("hlink.dll")
;~ 				_ReregisterDLL("mlang.dll")
;~ 				_ReregisterDLL("mobsync.dll")
;~ 				_ReregisterDLL("msieftp.dll", "/s /i")
;~ 				;~ _ReregisterDLL("msnsspc.dll") #No entry point
;~ 				_ReregisterDLL("msr2c.dll")
;~ 				_ReregisterDLL("msxml.dll")
;~ 				_ReregisterDLL("oleaut32.dll")
;~ 				;~ _ReregisterDLL("plugin.ocx") #No entry point
;~ 				_ReregisterDLL("proctexe.ocx")
;~ 				;~ Plus DllRegisterServerEx ExA ExW ... ?
;~ 				_ReregisterDLL("scrobj.dll", "/s /i")
;~ 				;~ shdocvw.dll hasn't been updated for IE7 and IE8, it still registers itself for the Windows Internet Controls
;~ 				_ReregisterDLL("shdocvw.dll", "/s /i")
;~ 				_ReregisterDLL("sendmail.dll")

;~ 				;~ PKI/crypto functionality
;~ 				_ReregisterDLL("initpki.dll", "/s /i:A")
;~ REM initpki can take very long to run and is rarely a problem
;~ REM if there are problems with crypto, SSL, certificates
;~ REM remove the three following REMs from the lines
;~ REM echo We are almost done except one crypto file
;~ REM echo but this will take very long, be patient!
;~ REM regsvr32 /s /i:A initpki.dll
;~ REM ******************************
;~ REM tabbed browser, do at the end, why originally with /n ?
;~ regsvr32 /s /i ieframe.dll
;~ REM ******************************
;~ echo correcting bugs in the registry
;~ REM do some corrective work
;~ REM Symptom: new tabs page cannot display content because it cannot access the controls (added 27. 3.2009)
;~ REM This is a result of a bug in shdocvw.dll (see above), probably only on Windows XP
;~ reg add "HKCR\TypeLib\{EAB22AC0-30C1-11CF-A7EB-0000C05BAE0B}\1.1\0\win32" /ve /t REG_SZ /d %systemroot%\system32\ieframe.dll /f
;~ REM ******************************
;~ echo all tasks have been finished
;~ echo.
;~ pause

				_EnableControls()

			Case $GUI_EVENT_CLOSE
				Exit

	EndSwitch

	WEnd

EndFunc


Func _ReregisterDLL($FilePath, $Param = "/s")

		_MemoLogWrite("RegSvr32.exe: Registering '" & $FilePath & "'.....")
		Local $RSVR32Error = ShellExecuteWait("regsvr32.exe", " " & $Param & " " & $FilePath, "")

		Switch $RSVR32Error
			Case 0
				_MemoLogWrite("RegSvr32.exe: '" & $FilePath & "' registration succeeded.", 1)
			Case 1
				_MemoLogWrite("RegSvr32.exe: Registration failed: To register a module, you must provide a binary name.", 2)
			Case 3
				_MemoLogWrite("RegSvr32.exe: Registration failed: Specified module not found", 2)
			Case 4
				_MemoLogWrite("RegSvr32.exe: Module loaded but entry-point DllRegisterServer was not found.", 2)
				_MemoLogWrite("RegSvr32.exe: Make sure that '" & $FilePath & "' is a valid dll or ocx.")
			Case 5
				_MemoLogWrite("RegSvr32.exe: Registration failed: Error number: 0x80070005", 2)
		EndSwitch

EndFunc   ;==>_ReregisterDLL


Func _MemoLogWrite($Message = "", $iWarning = 0, $iTimeStamp = 1, $iToMemo = 1, $iToFile = 1)

	Local $sPrefix = "", $sTStamp = "", $OpenLog

	If $iTimeStamp = 1  Then $sTStamp = "[" & @YEAR & "-" & @MON & "-" & @MDAY & "  " & @HOUR & ":" & @MIN & "] "
	If $iToMemo = 1 Then
		Select
			Case $iWarning = 1 ; Success
				GUICtrlSetBkColor($eStatus, 0xC1DCfC)
			Case $iWarning = 2 ; Error
				GUICtrlSetBkColor($eStatus, 0xEFD6E1)
				SoundPlay($SoundDir & "\error.wav")
				$sPrefix = "ERROR: "
			Case $iWarning = 3 ; Warning
				GUICtrlSetBkColor($eStatus, 0xF4FFD4)
				SoundPlay($SoundDir & "\warning.wav")
		EndSelect
		Sleep(10)

		_GUICtrlEdit_AppendText($eStatus, $Message & @CRLF)
	EndIf


	If $iToFile = 1 Then
		$OpenLog = FileOpen($IERepLog, 1)

		If $OpenLog = -1 Then
			;_GUICtrlEdit_AppendText($eStatus, "The status could not be written to the log file, make sure the " & _
											;$GPowerLog & " directory is not write protected." & @CRLF)
			;GUICtrlSetBkColor($eStatus, 0xEFD6E1)
		EndIf

		FileWrite($OpenLog, $sTStamp & $sPrefix & $Message & @CRLF)
		FileClose($OpenLog)

	EndIf

EndFunc


Func _DisableControls()

	GUICtrlDelete($IERepIcon)
	$GProcAni = GUICtrlCreateIcon($IERepProccRes, -1, 9, 9, 50, 50)

	GuiCtrlSetState($BtnGo, $GUI_DISABLE)

EndFunc


Func _EnableControls()

	GUISwitch($IERepForm)
	GUICtrlDelete($GProcAni)
	$IERepIcon = GUICtrlCreateIcon($IERepIconRes, -1, 10, 10, 48, 48)

	GuiCtrlSetState($BtnGo, $GUI_ENABLE)
	GuiCtrlSetState($BtnGo, $GUI_FOCUS)

EndFunc



