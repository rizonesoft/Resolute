#AutoIt3Wrapper_icon=Resources\EvBeGone.ico
#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_Res_Fileversion=0.0.0.248
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=y
#AutoIt3Wrapper_Res_requestedExecutionLevel=requireAdministrator
#AutoIt3Wrapper_Res_Icon_Add=Resources\Question.ico
#AutoIt3Wrapper_Res_Icon_Add=Resources\RecDoc.ico




#include <TreeViewConstants.au3>
#include <WindowsConstants.au3>
#include <GUIConstantsEx.au3>
#include <GuiImageList.au3>
#include <GuiListView.au3>
#Include <GuiButton.au3>
#Include <String.au3>

#include <GuiEdit.au3>

#include <UDF\SecureDelete.au3>


Opt("TrayMenuMode", 1) ;~ Default tray menu items (Script Paused/Exit) will not be shown.
Opt("MustDeclareVars", 1)
Opt("GUIOnEventMode", 1)

Global Const $EBGLog = @ScriptDir & "\Logging\EvBeGone.log"
Global Const $EBGTitle = "Rizone Evidence Be-Gone"

Global $mForm, $hListView, $BtnAnalyze, $BtnGo, $icoInro, $lblInfo, $pProgress, $eStatus
Global $GFSm, $GOHPage, $LogMaxSize, $LogEnabled, $Drives
Global $WinXP = 0

Global $SFolKey[2], $WinRecent
Global $Szes, $Fsize = 0, $Fcount = 0, $DelSize = 0, $DelCount = 0
Global $iCount = 1, $Cancel = 0
Global $SecDelete = True



_LoadSettings()
_Main()

Func _LoadSettings()

	$GFSm = IniRead(@ScriptDir & "\WinPower.ini", "Global", "FontSmoothing", 5)
	$GOHPage = IniRead(@ScriptDir & "\WinPower.ini", "Global", "OpenHomePage", 1)
	$LogMaxSize = IniRead(@ScriptDir & "\CIntRep.ini", "Logging", "LogMaxSize", 2048)
	$LogEnabled = IniRead(@ScriptDir & "\CIntRep.ini", "Logging", "LogEnabled", 1)

EndFunc

Func _Core()

	If @OSVersion = "WIN_XP" Or @OSVersion = "WIN_XPe" Or @OSVersion = "WIN_2003" Then $WinXP = 1

	$SFolKey[0] = "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders"
	$SFolKey[1] = "HKLM\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders"

	$WinRecent = RegRead($SFolKey[0], "Recent")
	If $WinRecent <> "" Then
		$WinRecent = StringTrimLeft($WinRecent, StringInStr($WinRecent, "\", 0, -1))
		If $WinXP Then
		;DELFILE($PATH & $RECENT & "\*.lnk")
		;DELFILE($PATH & "\Recent\*.lnk")
		;CLEANDIR($PATH & "\Application Data\Microsoft\Office\Recent")
		Else
			$WinRecent = @UserProfileDir & "\AppData\Roaming\Microsoft\Windows\" & $WinRecent
		;_DeleteFile(@UserProfileDir & "\AppData\Roaming\Microsoft\Windows\" & $WinRecent & "\*.lnk")
		;CLEANDIR($PATH & "\AppData\Roaming\Microsoft\Office\Recent")
		EndIf
	EndIf


	$Drives = DriveGetDrive("FIXED")
	If @error = 1 Then _ErrorHandling(57, "No fixed drives were detected.")
	For $i = 1 To $Drives[0]
		$Drives[$i] = StringUpper($Drives[$i])
		If DriveStatus($Drives[$i]) = "READY" Then ContinueLoop
		For $j = $i To $Drives[0] - 1
			$Drives[$j] = $Drives[$j + 1]
		Next
		$Drives[0] -= 1
	Next

EndFunc

Func _Main()

Local $hImage

	$mForm = GUICreate("Rizone Complete Windows Cleaner", 750, 510, -1, -1)

	$hListView = GUICtrlCreateListView("", 10, 35, 300, 400, BitOR($LVS_REPORT, $LVS_SHOWSELALWAYS, $LVS_SINGLESEL), _
	BitOR($LVS_EX_FULLROWSELECT, $LVS_EX_GRIDLINES, $LVS_EX_CHECKBOXES, $LVS_EX_DOUBLEBUFFER, $WS_EX_CLIENTEDGE))
	GuiCtrlSetFont($hListView, 8.5, 400, 0, "Verdana", 5)

	$hImage = _GUIImageList_Create(16, 16, 5, 3)
    _GUIImageList_AddIcon($hImage, @ScriptFullPath, -202)
	_GUIImageList_AddIcon($hImage, @ScriptFullPath, -203)
	_GUIImageList_AddIcon($hImage, @ScriptFullPath, -204)
	_GUIImageList_AddIcon($hImage, @ScriptFullPath, -205)
	_GUICtrlListView_SetImageList($hListView, $hImage, 1)
	_GUICtrlListView_InsertColumn($hListView, 0, "", 280)

	_GUICtrlListView_AddItem($hListView, "Recent Documents", 0)
;~ 	_GUICtrlListView_AddItem($hListView, "Hibernate Mode")
;~ 	_GUICtrlListView_AddItem($hListView, "Performance Monitor")
;~ 	_GUICtrlListView_AddItem($hListView, "Memory Dump Files")
;~ 	_GUICtrlListView_AddItem($hListView, "Crash Dumps")
;~ 	_GUICtrlListView_AddItem($hListView, "Windows Log Files")
;~ 	_GUICtrlListView_AddItem($hListView, "Recycle Bin")
;~ 	;_GUICtrlListView_AddItem($hListView, "Temporary Files (.tmp)")
;~ 	_GUICtrlListView_AddItem($hListView, "Recent Documents")
;~ 	_GUICtrlListView_AddItem($hListView, "Temporary Internet Files")
;~ 	_GUICtrlListView_AddItem($hListView, "Browsing History")
;~ 	_GUICtrlListView_AddItem($hListView, "Cookies")
;~ 	_GUICtrlListView_AddItem($hListView, "Recently Typed URLs")
;~ 	_GUICtrlListView_AddItem($hListView, "Last Download Location")
;~ 	_GUICtrlListView_AddItem($hListView, "Internet Explorer Form Data")
;~ 	_GUICtrlListView_AddItem($hListView, "Office Installer Cache")
;~ 	_GUICtrlListView_AddItem($hListView, "Office Recent Documents")
;~ 	_GUICtrlListView_AddItem($hListView, "Backup Files (.bak)")
;~ 	_GUICtrlListView_AddItem($hListView, "Old Files (.old)")
;~ 	_GUICtrlListView_AddItem($hListView, "bootsqm.dat")
;~ 	_GUICtrlListView_AddItem($hListView, "Windows.old")
;~ 	_GUICtrlListView_AddItem($hListView, "Firefox Browsing Cache")
;~ 	_GUICtrlListView_AddItem($hListView, "Firefox Browsing History")
;~ 	_GUICtrlListView_AddItem($hListView, "Firefox Cookies")
;~ 	_GUICtrlListView_AddItem($hListView, "Firefox Form Data")
;~ 	_GUICtrlListView_AddItem($hListView, "Corrupt Firefox Databases")
;~ 	_GUICtrlListView_AddItem($hListView, "Firefox Crash Reports")
;~ 	_GUICtrlListView_AddItem($hListView, "Optimize Firefox Databases")
;~ 	_GUICtrlListView_AddItem($hListView, "Chrome Browsing Data")
;~ 	_GUICtrlListView_AddItem($hListView, "Chrome History")
;~ 	_GUICtrlListView_AddItem($hListView, "Chrome Cookies")
;~ 	_GUICtrlListView_AddItem($hListView, "Chrome Database Optimization")
;~ 	_GUICtrlListView_AddItem($hListView, "Opera Browsing Data")
;~ 	_GUICtrlListView_AddItem($hListView, "Opera History")
;~ 	_GUICtrlListView_AddItem($hListView, "Opera Cookies")
;~ 	_GUICtrlListView_AddItem($hListView, "Flash Player Cache")
;~ 	_GUICtrlListView_AddItem($hListView, "Shockwave Player Cache")
;~ 	_GUICtrlListView_AddItem($hListView, "Apple QuickTime Cache")

;~ 	_GUICtrlListView_AddItem($hListView, "MSN Messanger")
;~ 	_GUICtrlListView_AddItem($hListView, "Google Talk Avatars")
;~ 	_GUICtrlListView_AddItem($hListView, "Google Talk Chat Logs")
;~ 	_GUICtrlListView_AddItem($hListView, "InstallShield Files (._mp)")




	; Build groups
	_GUICtrlListView_EnableGroupView($hListView)
	_GUICtrlListView_InsertGroup($hListView, -1, 1, "Windows")
;~ 	_GUICtrlListView_InsertGroup($hListView, -1, 2, "Windows")
;~ 	_GUICtrlListView_InsertGroup($hListView, -1, 3, "Internet Explorer")
;~ 	_GUICtrlListView_InsertGroup($hListView, -1, 4, "Microsoft Office")
;~ 	_GUICtrlListView_InsertGroup($hListView, -1, 5, "Advance")
;~ 	_GUICtrlListView_InsertGroup($hListView, -1, 6, "Mozilla Firefox")
;~ 	_GUICtrlListView_InsertGroup($hListView, -1, 7, "Google Chrome")
;~ 	_GUICtrlListView_InsertGroup($hListView, -1, 8, "Opera")
;~ 	_GUICtrlListView_InsertGroup($hListView, -1, 9, "Multimedia")
;~ 	_GUICtrlListView_InsertGroup($hListView, -1, 10, "Instant Messaging")
;~ 	_GUICtrlListView_InsertGroup($hListView, -1, 11, "Applications")



	_GUICtrlListView_SetItemGroupID($hListView, 0, 1)
;~ 	_GUICtrlListView_SetItemGroupID($hListView, 1, 1)
;~ 	_GUICtrlListView_SetItemGroupID($hListView, 2, 1)
;~ 	_GUICtrlListView_SetItemGroupID($hListView, 3, 1)
;~ 	_GUICtrlListView_SetItemGroupID($hListView, 4, 1)
;~ 	_GUICtrlListView_SetItemGroupID($hListView, 5, 1)
;~ 	_GUICtrlListView_SetItemGroupID($hListView, 6, 1)
;~ 	_GUICtrlListView_SetItemGroupID($hListView, 7, 2)
;~ 	_GUICtrlListView_SetItemGroupID($hListView, 8, 3)
;~ 	_GUICtrlListView_SetItemGroupID($hListView, 9, 3)
;~ 	_GUICtrlListView_SetItemGroupID($hListView, 10, 3)
;~ 	_GUICtrlListView_SetItemGroupID($hListView, 11, 3)
;~ 	_GUICtrlListView_SetItemGroupID($hListView, 12, 3)
;~ 	_GUICtrlListView_SetItemGroupID($hListView, 13, 3)
;~ 	_GUICtrlListView_SetItemGroupID($hListView, 14, 4)
;~ 	_GUICtrlListView_SetItemGroupID($hListView, 15, 4)
;~ 	_GUICtrlListView_SetItemGroupID($hListView, 16, 5)
;~ 	_GUICtrlListView_SetItemGroupID($hListView, 17, 5)
;~ 	_GUICtrlListView_SetItemGroupID($hListView, 18, 5)
;~ 	_GUICtrlListView_SetItemGroupID($hListView, 19, 5)
;~ 	_GUICtrlListView_SetItemGroupID($hListView, 20, 6)
;~ 	_GUICtrlListView_SetItemGroupID($hListView, 21, 6)
;~ 	_GUICtrlListView_SetItemGroupID($hListView, 22, 6)
;~ 	_GUICtrlListView_SetItemGroupID($hListView, 23, 6)
;~ 	_GUICtrlListView_SetItemGroupID($hListView, 24, 6)
;~ 	_GUICtrlListView_SetItemGroupID($hListView, 25, 6)
;~ 	_GUICtrlListView_SetItemGroupID($hListView, 26, 6)
;~ 	_GUICtrlListView_SetItemGroupID($hListView, 27, 7)
;~ 	_GUICtrlListView_SetItemGroupID($hListView, 28, 7)
;~ 	_GUICtrlListView_SetItemGroupID($hListView, 29, 7)
;~ 	_GUICtrlListView_SetItemGroupID($hListView, 30, 7)
;~ 	_GUICtrlListView_SetItemGroupID($hListView, 31, 8)
;~ 	_GUICtrlListView_SetItemGroupID($hListView, 32, 8)
;~ 	_GUICtrlListView_SetItemGroupID($hListView, 33, 8)
;~ 	_GUICtrlListView_SetItemGroupID($hListView, 34, 9)
;~ 	_GUICtrlListView_SetItemGroupID($hListView, 35, 9)
;~ 	_GUICtrlListView_SetItemGroupID($hListView, 36, 9)
;~ 	_GUICtrlListView_SetItemGroupID($hListView, 37, 10)
;~ 	_GUICtrlListView_SetItemGroupID($hListView, 38, 10)
;~ 	_GUICtrlListView_SetItemGroupID($hListView, 39, 10)
;~ 	_GUICtrlListView_SetItemGroupID($hListView, 40, 11)

	$BtnAnalyze = GUICtrlCreateButton("Analyze", 315, 395, 150, 35)
	GuiCtrlSetFont($BtnAnalyze, 10, 400, 0, "Verdana", $GFSm)
	$BtnGo = GUICtrlCreateButton("Go!", 465, 395, 150, 35)
	GuiCtrlSetFont($BtnGo, 10, 400, 0, "Verdana", $GFSm)
	$pProgress = GUICtrlCreateProgress(315, 35, 420, 20)
	$eStatus = GUICtrlCreateEdit("", 315, 60, 420, 200, BitOR($WS_VSCROLL, $WS_HSCROLL, $ES_READONLY, $ES_AUTOVSCROLL))
	GUICtrlSetFont($eStatus, 9, 400, 0, "courier new", $GFSm)
	$icoInro = GuiCtrlCreateIcon(@ScriptFullPath, 99, 10, 440, 48, 48)
	$lblInfo = GUICtrlCreateLabel("Information", 70, 440, 660, 50)
	GUICtrlSetFont($lblInfo, 8.5, 400, 0, "Verdana", 5)
	$iCount =  _GUICtrlListView_GetItemCount($hListView)

	GUISetState(@SW_SHOW)

	_Core()

	GUIRegisterMsg($WM_COMMAND, "MY_WM_COMMAND")
	GUIRegisterMsg($WM_NOTIFY, "WM_NOTIFY")

	GUISetOnEvent($GUI_EVENT_CLOSE, "_CloseClicked")

While 1
	Sleep(25)
WEnd

EndFunc

Func _CloseClicked()

	GuiDelete($mForm)
	IniWrite(@ScriptDir & "\WinPower.ini", "Global", "OpenHomePage", 0)
	Local $PID = ProcessExists(@ScriptName) ; Will return the PID or 0 if the process isn't found.
	If $PID Then ProcessClose(@ScriptName)
	Exit

EndFunc

Func WM_NOTIFY($hWnd, $iMsg, $iwParam, $ilParam)
    #forceref $hWnd, $iMsg, $iwParam
    Local $hWndFrom, $iIDFrom, $iCode, $tNMHDR, $hWndListView, $tInfo
;~  Local $tBuffer
    $hWndListView = $hListView
    If Not IsHWnd($hListView) Then $hWndListView = GUICtrlGetHandle($hListView)

    $tNMHDR = DllStructCreate($tagNMHDR, $ilParam)
    $hWndFrom = HWnd(DllStructGetData($tNMHDR, "hWndFrom"))
    $iIDFrom = DllStructGetData($tNMHDR, "IDFrom")
    $iCode = DllStructGetData($tNMHDR, "Code")
    Switch $hWndFrom
        Case $hWndListView
            Switch $iCode
                Case $NM_CLICK ; Sent by a list-view control when the user clicks an item with the left mouse button
                    $tInfo = DllStructCreate($tagNMITEMACTIVATE, $ilParam)
					_DisplayListViewItemInfo(DllStructGetData($tInfo, "Index"))
				Case $NM_DBLCLK ; Sent by a list-view control when the user double-clicks an item with the left mouse button
                    $tInfo = DllStructCreate($tagNMITEMACTIVATE, $ilParam)

				Case $LVN_KEYDOWN ; A key has been pressed
                    ;$tInfo = DllStructCreate($tagNMLVKEYDOWN, $ilParam)
					Local $iSel = _GUICtrlListView_GetSelectedIndices($hWndListView, True)
					If $iSel[0] > 0 Then _DisplayListViewItemInfo($iSel[1])
            EndSwitch
    EndSwitch
    Return $GUI_RUNDEFMSG
EndFunc   ;==>WM_NOTIFY

Func MY_WM_COMMAND($hWnd, $iMsg, $wParam, $lParam)

    Switch BitAND($wParam, 0xFFFF) ;LoWord = IDFrom
         Case $BtnAnalyze
            Switch BitShift($wParam, 16) ;HiWord = Code
				Case $BN_CLICKED
					If GUICtrlRead($BtnAnalyze) = "Analyze" Then
						_AnalyzeSelections()
					Else
						$Cancel = 1
					EndIf
            EndSwitch
		Case $BtnGo
            Switch BitShift($wParam, 16) ;HiWord = Code
				Case $BN_CLICKED
					If GUICtrlRead($BtnGo) = "Go!" Then
						_Go()
					Else
						$Cancel = 1
					EndIf
            EndSwitch
    EndSwitch

    Return $GUI_RUNDEFMSG
EndFunc;==>WM_COMMAND


Func _DisplayListViewItemInfo($li = 0)

			Switch _GUICtrlListView_GetItemText($hListView, $li)
				Case "Recent Documents"
					GUICtrlSetImage($icoInro, @ScriptFullPath, 201)
					GuiCtrlSetData($lblInfo, 	"Clears the list of Recent Documents and Files opened on your Computer. " & _
												"This list is usually located in the [Start Menu] -> [My Recent Documents].")
;~ 				Case "Hibernate Mode"
;~ 					GUICtrlSetImage($icoInro, @ScriptFullPath, 203)
;~ 					GuiCtrlSetData($lblInfo, 	"Hibernate mode, which completely writes the memory out to the hard drive " & _
;~ 												"(hiberfil.sys). This option will remove the hiberfil.sys from all drives. " & _
;~ 												"You can disable Hibarnate mode to keep it clean. Simply select ""Disable " & _
;~ 												"Hibarnate mode"" under the ""Keep Clean"" section.")
;~ 				Case "Office Installer Cache"
;~ 					GUICtrlSetImage($icoInro, @ScriptFullPath, 205)
;~ 					GuiCtrlSetData($lblInfo, 	"Office Setup has a feature that copies the install source files " & _
;~ 												"from the Office installation media to the Msocache folder. " & _
;~ 												"After you remove the Msocache folder, you may have to provide the " & _
;~ 												"installation media.")
				Case Else
					GUICtrlSetImage($icoInro, @ScriptFullPath, 99)
			EndSwitch

EndFunc

Func _GetFreespace()
EndFunc

Func _StartCleaning()
	GuiCtrlSetData($BtnGo, "Stop!")
EndFunc

Func _EndCleaning()

	GuiCtrlSetData($BtnGo, "Go!")



EndFunc

Func _AnalyzeSelections()

	Local $TotalFiles, $TotalSize, $SectionFiles, $SectionSize, $Str
	For $i = 1 To 85
		$Str &= "="
	Next

	If $WinRecent <> "" Then _Analyze($WinRecent)
	GUICtrlSetData($pProgress, 10)
	$TotalFiles += $Fcount
	$TotalSize += Round($Szes / 1024, 2)
	GUICtrlSetData($eStatus, 	"Recent Documents :" & Chr(09) & Chr(09) & Chr(09) & _
								Round($Szes / 1024, 2) & Chr(09) & " MB" & Chr(09) & Chr(09) & _
								$Fcount & Chr(09) & " File(s)" & @CRLF, 1)

	GUICtrlSetData($eStatus, $Str & @CRLF, 1)
	GUICtrlSetData($eStatus, 	"Total :" & Chr(09) & Chr(09) & Chr(09) & Chr(09) & Chr(09) & _
								$TotalSize & Chr(09) & " MB" & Chr(09) & Chr(09) & _
								$TotalFiles & Chr(09) & " File(s)" & @CRLF, 1)
	GUICtrlSetData($eStatus, $Str & @CRLF, 1)

EndFunc

Func _Analyze($szMask, $Ex = "*.*")

	Local $mSearch = 0, $FileSearch = 0, $mBuffer, $FileBuffer, $PathList = "*"

	$Fsize = ""
	$Szes = ""
	$Fcount = ""

	If StringRight($szMask, 1) <> "\" Then $szMask = $szMask & "\"

	While $Cancel = 0
		$mSearch = FileFindFirstFile($szMask & $Ex)
		If $mSearch >= 0 Then
			$mBuffer = FileFindNextFile($mSearch)
			While Not @error
				If StringInStr(FileGetAttrib($szMask & $mBuffer), "D") Then $PathList &= $szMask & $mBuffer & "*"
				$mBuffer = FileFindNextFile($mSearch)
			WEnd
			FileClose($mSearch)
		EndIf

		$FileSearch = FileFindFirstFile($szMask & $Ex)
		If $FileSearch >= 0 Then
			$FileBuffer = FileFindNextFile($FileSearch)
			While Not @error And $Cancel = 0
				If Not StringInStr(FileGetAttrib($szMask & $FileBuffer), "D") Then
					$Fsize = Round(FileGetSize($szMask & $FileBuffer) / 1024, 1)
					$Szes += $Fsize
					$Fcount += 1
				EndIf
				$FileBuffer = FileFindNextFile($FileSearch)
			WEnd
			FileClose($FileSearch)
		EndIf

		If $PathList == "*" Then ExitLoop
		$PathList = StringTrimLeft($PathList, 1)
		$szMask = StringLeft($PathList, StringInStr($PathList, "*") - 1) & "\"
		$PathList = StringTrimLeft($PathList, StringInStr($PathList, "*") - 1)
	WEnd
	If $Fcount = "" Then $Fcount = 0

EndFunc


Func _Go()

	Local $cs, $iText
	Local $cCount = _CountChecked($hListView), $Progress = 0
	$DelSize = 0
	$DelCount = 0

	_StartCleaning()

	For $i = 0 To $iCount - 1
		$cs = _GUICtrlListView_GetItemChecked($hListView, $i)
		If $cs = 1 Then
			$iText = _GUICtrlListView_GetItemText($hListView, $i)
			If $Cancel = 1 Then
				$i = $iCount + 1
				ExitLoop
			EndIf
			If $iText == "Recent Documents" Then
				If $WinXP Then
					;DELFILE($PATH & $RECENT & "\*.lnk")
					;DELFILE($PATH & "\Recent\*.lnk")
					;CLEANDIR($PATH & "\Application Data\Microsoft\Office\Recent")
				Else
					_CleanDirectory($WinRecent)
					;CLEANDIR($PATH & "\AppData\Roaming\Microsoft\Office\Recent")
				EndIf
;~ 			If $iText == "Installer Configuration" Then
;~ 				$Progress += 1
;~ 				GuiCtrlSetData($pProgress, ($Progress / $cCount) * 100)
;~ 				_GUICtrlListView_SetItemImage($hListView, 0, 0)
;~ 			ElseIf $iText == "Office Installer Cache" Then
;~ 				_MemoLogWrite("Cleaning Office Installer Cache, pleas wait...", False)
;~ 				_LogWrite("-----------------------------------------------------------------------------------------", False)
;~ 				For $i = 1 To $Drives[0]
;~ 					If FileExists($Drives[$i] & "\MSOCache") Then
;~ 						$Cleaning = True
;~ 						_MemoLogWrite("Cleaning Office Installer Cache from " & $Drives[$i])
;~ 						DirRemove($Drives[$i] & "\MSOCache", 1)
;~ 					EndIf
;~ 				Next
;~ 				If $Cleaning = False Then _MemoLogWrite("Nothing to Clean")
;~ 				$Cleaning = False
;~ 				_LogWrite("", False)
;~ 				_LogWrite("-----------------------------------------------------------------------------------------", False)
;~ 				$Progress += 1
;~ 				GuiCtrlSetData($pProgress, ($Progress / $cCount) * 100)
;~ 				_GUICtrlListView_SetItemImage($hListView, 3, 0)
			EndIf
		EndIf
	Next
	GUICtrlSetData($eStatus, $DelCount & " File(s) Has been deleted : " & Round($DelSize / 1024) & " KB " & "(" & Round(($DelSize / 1024 / 1024), 2) & " MB)" & " Regained" & @CRLF, 1)
	$DelSize = 0
	$DelCount = 0
	_EndCleaning()
	$Cancel = 0
	$Progress = 0

EndFunc

Func _CleanDirectory($Dir)
	Local $FileName, $Search
	$Search = FileFindFirstFile($Dir & "\*")
	If $Search = -1 Then Return
	While 1
		$FileName = FileFindNextFile($Search)
		If @error Then ExitLoop
		If StringInStr(FileGetAttrib($Dir & "\" & $FileName), "D", 2) Then
			_CleanDirectory($Dir & "\" & $FileName)
			ContinueLoop
		Else
			$DelCount += 1
			$DelSize += FileGetSize($Dir & "\" & $FileName)
			_DeleteFile($Dir & "\" & $FileName)
			ContinueLoop
		EndIf
	WEnd
	FileClose($Search)
EndFunc

Func _DeleteFile($File, $Recycle = 0)
	If FileExists($File) = 0 Then Return
	If $Recycle = 1 Then
		If FileRecycle($File) Then
			Return True
		Else
			Return False
		EndIf
		Return
	Else
		If StringInStr($File, "*", 2, -1) = 0 Then
			FileDelete($File)
			Return
		Else
			Local $FileName, $Search, $Dir = _GetDir($File)
			$Search = FileFindFirstFile($File)
			If $Search <> -1 Then
				While 1
					$FileName = FileFindNextFile($Search)
					If @error = 1 Then ExitLoop
					If _IsDir($Dir & "\" & $FileName) Then ContinueLoop
					FileDelete($Dir & "\" & $FileName)
				WEnd
				FileClose($Search)
			EndIf
			Return
		EndIf
	EndIf
EndFunc

Func _CountChecked($lView = 0)

	Local $RetCount, $Ch

	For $i = 0 To _GUICtrlListView_GetItemCount($lView) - 1
		$Ch = _GUICtrlListView_GetItemChecked($lView, $i)
		If $Ch = 1 Then $RetCount += 1
	Next

	Return $RetCount

EndFunc

Func _MemoLogWrite($Message = "", $iWarning = 0, $bTStamp = True)

	Local $sPrefix = ""

	Select
		Case $iWarning = 1
			GuiCtrlSetColor($eStatus, 0x066186)
		Case $iWarning = 2
			GuiCtrlSetColor($eStatus, 0xB20000)
		Case $iWarning = 3
			GuiCtrlSetColor($eStatus, 0xE6791A)
	EndSelect
	Sleep(10)

	_GUICtrlEdit_AppendText($eStatus, $sPrefix & "--> " & $Message & @CRLF)
	_LogWrite($sPrefix & $Message, $bTStamp)

EndFunc


Func _LogWrite($Message = "", $bTStamp = True)

	Local $OpenLog, $sTStamp = ""

	If $LogEnabled = 1 Then

		$OpenLog = FileOpen($EBGLog, 1)
		If $OpenLog = -1 Then
		EndIf

		If $bTStamp Then $sTStamp = "[" & @MDAY & "/" & @MON & "/" & @YEAR & _
									" " & @HOUR & ":" & @MIN & ":" & @SEC & "] "
		FileWrite($OpenLog, $sTStamp & $Message & @CRLF)
		FileClose($OpenLog)

	EndIf

EndFunc

Func _ErrorHandling($ErrNo, $ErrorTxt = "Unknown error.", $Solution = "No specific advice.", $IsFatal = 1)

	Local $MsgBoxStyle = 16

	If $IsFatal = 0 Then $MsgBoxStyle = 48
	MsgBox($MsgBoxStyle, $EBGTitle & " - Error", "Error: (" & $ErrNo & ") - " & $ErrorTxt & @CRLF & @CRLF & _
						"Solution: " & $Solution, 60)
	If $IsFatal = 1 Then Exit
EndFunc