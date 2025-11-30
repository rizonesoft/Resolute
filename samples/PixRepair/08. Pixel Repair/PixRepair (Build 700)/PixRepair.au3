#NoTrayIcon
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=Resources\PixRepair.ico
#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_UseUpx=y
#AutoIt3Wrapper_Res_Description=Repair stuck LCD pixels
#AutoIt3Wrapper_Res_Fileversion=0.6.9.701
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=y
#AutoIt3Wrapper_Res_LegalCopyright=Copyright © 2012, Datum
#AutoIt3Wrapper_Res_Icon_Add=Resources\Facebook.ico
#AutoIt3Wrapper_Res_Icon_Add=Resources\Twitter.ico
#AutoIt3Wrapper_Res_Icon_Add=Resources\LinkedIn.ico
#AutoIt3Wrapper_Res_Icon_Add=Resources\Google.ico
#AutoIt3Wrapper_Res_Icon_Add=Resources\Donate.ico
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****




#include <WindowsConstants.au3>
#include <StaticConstants.au3>
#include <ButtonConstants.au3>
#include <GUIConstantsEx.au3>
#include <WinAPIProc.au3>
#include <Misc.au3>

#include "UDF\Functions.au3"


Opt("TrayMenuMode", 1) ; Default tray menu items (Script Paused/Exit) will not be shown.
Opt('MustDeclareVars', 1)


;~ Application Settings
Global Const $APPSET_COMPANY = "Rizonesoft"
Global Const $APPSET_TITLE = "Pixel Repair"
Global Const $APPSET_VERSION = FileGetVersion(@ScriptFullPath)
;~ Application Settings


Global $GUI_CORE, $aboutDlg, $FileMenu, $HelpMenu, $HlpAbout

Global $btnWhite, $btnBlack, $btnRed, $btnGreen, $btnBlue, $btnYellow, $btnMagenta, $btnCyan, $speedSlider, $btnGo
Global $btnAbout, $btnClose, $cMode1, $cMode2, $cMode3, $cMode4, $cMode5, $cMode6, $cMode7, $lblWarn, $GoForm
Global $GuiStyles, $FullScreen = False


HotKeySet("{F11}", "_FullScreenMode")

_Singleton(@ScriptName, 0)
_Main()


Func _FullScreenMode()

	If Not $FullScreen Then
		GUISetState(@SW_MAXIMIZE, $GoForm)
		$GuiStyles = GUIGetStyle($GoForm)
		GUISetStyle($WS_POPUPWINDOW)
		$FullScreen = True
	Else
		GUISetStyle($GuiStyles[0], $GuiStyles[1])
		GUISetState(@SW_RESTORE, $GoForm)
		$FullScreen = False
	EndIf

EndFunc


Func _Main()

	Local $filDownMovie, $filClose, $pixIcon

	$GUI_CORE = GUICreate($APPSET_COMPANY & " " & $APPSET_TITLE & " " & _GetExecVersioning(@ScriptFullPath, 5), 530, 510, -1, -1)
	GUISetFont(8.5, 400, 0, "Verdana")

	$FileMenu = GUICtrlCreateMenu("&File")
	$filDownMovie = GUICtrlCreateMenuItem("&iPhone and Other Devices", $FileMenu)
	GUICtrlCreateMenuItem("", $FileMenu)
	$filClose = GUICtrlCreateMenuItem("&Close" & @TAB & "Esc", $FileMenu)
	$HelpMenu = GUICtrlCreateMenu("&Help")
	$hlpAbout = GUICtrlCreateMenuItem("&About...", $HelpMenu)

	$pixIcon = GUICtrlCreateIcon(@ScriptFullPath, 99, 10, 10, 64, 64)
	GuiCtrlCreateLabel(	"Repair stuck pixels with this tool. It won't repair dead pixels (Black Ones). " & _
						"It won't work everytime either!", 85, 10, 185,100)
	GuiCtrlSetFont(-1, 9)
	GUICtrlCreateGroup("1)  Dead pixel locator", 10, 80, 260, 290)
	GUICtrlCreateLabel("", 20, 115, 10, 25)
	GUICtrlSetBkColor(-1, 0xFFFFFF)
	$btnWhite = GUICtrlCreateButton("White", 35, 115, 100, 25)
	GUICtrlCreateLabel("", 20, 140, 10, 25)
	GUICtrlSetBkColor(-1, 0x000000)
	$btnBlack = GUICtrlCreateButton("Black", 35, 140, 100, 25)
	GUICtrlCreateLabel("", 20, 165, 10, 25)
	GUICtrlSetBkColor(-1, 0xFF0000)
	$btnRed = GUICtrlCreateButton("Red", 35, 165, 100, 25)
	GUICtrlCreateLabel("", 20, 190, 10, 25)
	GUICtrlSetBkColor(-1, 0x00FF00)
	$btnGreen = GUICtrlCreateButton("Green", 35, 190, 100, 25)
	GUICtrlCreateLabel("", 140, 115, 10, 25)
	GUICtrlSetBkColor(-1, 0x0000FF)
	$btnBlue = GUICtrlCreateButton("Blue", 155, 115, 100, 25)
	GUICtrlCreateLabel("", 140, 140, 10, 25)
	GUICtrlSetBkColor(-1, 0xFFFF00)
	$btnYellow = GUICtrlCreateButton("Yellow", 155, 140, 100, 25)
	GUICtrlCreateLabel("", 140, 165, 10, 25)
	GUICtrlSetBkColor(-1, 0xFF00FF)
	$btnMagenta = GUICtrlCreateButton("Magenta", 155, 165, 100, 25)
	GUICtrlCreateLabel("", 140, 190, 10, 25)
	GUICtrlSetBkColor(-1, 0x00FFFF)
	$btnCyan = GUICtrlCreateButton("Cyan", 155, 190, 100, 25)

	GUICtrlCreateLabel("1", 20, 230, 20, 45)
	GUICtrlSetFont(-1, 12, 800)
	GUICtrlCreateLabel("Click any color button on the left to display a color over the entire screen.", 40, 230, 220, 45)
	GUICtrlCreateLabel("2", 20, 275, 20, 45)
	GUICtrlSetFont(-1, 12, 800)
	GUICtrlCreateLabel(	"After a color is displayed, you can use the arrow keys on your keyboard to " & _
						"switch between colors.", 40, 275, 220, 45)
	GUICtrlCreateLabel("3", 20, 320, 20, 45)
	GUICtrlSetFont(-1, 12, 800)
	GUICtrlCreateLabel(	"Press the 'Esc' key to exit the color display and return to this window.", 40, 320, 220, 45)
	GUICtrlCreateGroup("", -99, -99, 1, 1)

	GUICtrlCreateGroup("Examples", 10, 375, 260, 55)
	GuiCtrlCreateLabel("", 40, 400, 20, 20)
	GUICtrlSetBkColor(-1, 0xFFFFFF)
	GuiCtrlCreateLabel("", 55, 405, 1, 1)
	GUICtrlSetBkColor(-1, 0x000000)
	GuiCtrlCreateLabel("", 65, 400, 20, 20)
	GUICtrlSetBkColor(-1, 0x000000)
	GuiCtrlCreateLabel("", 80, 405, 1, 1)
	GUICtrlSetBkColor(-1, 0xFFFFFF)
	GuiCtrlCreateLabel("", 90, 400, 20, 20)
	GUICtrlSetBkColor(-1, 0xFF0000)
	GuiCtrlCreateLabel("", 105, 405, 1, 1)
	GUICtrlSetBkColor(-1, 0x0000FF)
	GuiCtrlCreateLabel("", 115, 400, 20, 20)
	GUICtrlSetBkColor(-1, 0x00FF00)
	GuiCtrlCreateLabel("", 130, 405, 1, 1)
	GUICtrlSetBkColor(-1, 0xFF0000)
	GuiCtrlCreateLabel("", 140, 400, 20, 20)
	GUICtrlSetBkColor(-1, 0x0000FF)
	GuiCtrlCreateLabel("", 155, 405, 1, 1)
	GUICtrlSetBkColor(-1, 0x00FF00)
	GuiCtrlCreateLabel("", 165, 400, 20, 20)
	GUICtrlSetBkColor(-1, 0xFFFF00)
	GuiCtrlCreateLabel("", 180, 405, 1, 1)
	GUICtrlSetBkColor(-1, 0xFF0000)
	GuiCtrlCreateLabel("", 190, 400, 20, 20)
	GUICtrlSetBkColor(-1, 0xFF00FF)
	GuiCtrlCreateLabel("", 205, 405, 1, 1)
	GUICtrlSetBkColor(-1, 0x00FF00)
	GuiCtrlCreateLabel("", 215, 400, 20, 20)
	GUICtrlSetBkColor(-1, 0x00FFFF)
	GuiCtrlCreateLabel("", 230, 405, 1, 1)
	GUICtrlSetBkColor(-1, 0x0000FF)
	GUICtrlCreateGroup("", -99, -99, 1, 1)

	$btnAbout = GUICtrlCreateButton("About...", 10, 440, 100, 30)

	GUICtrlCreateGroup("2)  Color mode", 280, 8, 240, 215)
	$cMode1 = GUICtrlCreateRadio("", 290, 35, 20, 20)
	GuiCtrlCreateLabel("", 310, 35, 20, 20)
	GUICtrlSetBkColor(-1, 0xFF0000)
	GUICtrlSetTip(-1, " Red ")
	GuiCtrlCreateLabel("", 335, 35, 20, 20)
	GUICtrlSetBkColor(-1, 0x00FF00)
	GUICtrlSetTip(-1, " Green ")
	GuiCtrlCreateLabel("", 360, 35, 20, 20)
	GUICtrlSetBkColor(-1, 0x0000FF)
	GUICtrlSetTip(-1, " Blue ")
	$cMode2 = GUICtrlCreateRadio("", 290, 60, 20, 20)
	GuiCtrlCreateLabel("", 310, 60, 20, 20)
	GUICtrlSetBkColor(-1, 0xFF0000)
	GuiCtrlCreateLabel("", 335, 60, 20, 20)
	GUICtrlSetBkColor(-1, 0x00FF00)
	GuiCtrlCreateLabel("", 360, 60, 20, 20)
	GUICtrlSetBkColor(-1, 0x0000FF)
	GuiCtrlCreateLabel("", 385, 60, 20, 20)
	GUICtrlSetBkColor(-1, 0xFFFF00)
	GuiCtrlCreateLabel("", 410, 60, 20, 20)
	GUICtrlSetBkColor(-1, 0xFF00FF)
	GuiCtrlCreateLabel("", 435, 60, 20, 20)
	GUICtrlSetBkColor(-1, 0x00FFFF)
	$cMode3 = GUICtrlCreateRadio("", 290, 85, 20, 20)
	GuiCtrlCreateLabel("", 310, 85, 20, 20)
	GUICtrlSetBkColor(-1, 0xFFFF00)
	GuiCtrlCreateLabel("", 335, 85, 20, 20)
	GUICtrlSetBkColor(-1, 0xFF00FF)
	GuiCtrlCreateLabel("", 360, 85, 20, 20)
	GUICtrlSetBkColor(-1, 0x00FFFF)
	$cMode4 = GUICtrlCreateRadio("", 290, 110, 20, 20)
	GuiCtrlCreateLabel("", 310, 110, 20, 20)
	GUICtrlSetBkColor(-1, 0xFFFFFF)
	GuiCtrlCreateLabel("", 335, 110, 20, 20)
	GUICtrlSetBkColor(-1, 0x000000)
	$cMode5 = GUICtrlCreateRadio("", 290, 135, 20, 20)
	GuiCtrlCreateLabel("", 310, 135, 20, 20)
	GUICtrlSetBkColor(-1, 0xFFFFFF)
	GuiCtrlCreateLabel("", 335, 135, 20, 20)
	GUICtrlSetBkColor(-1, 0x000000)
	GuiCtrlCreateLabel("", 360, 135, 20, 20)
	GUICtrlSetBkColor(-1, 0xFF0000)
	GuiCtrlCreateLabel("", 385, 135, 20, 20)
	GUICtrlSetBkColor(-1, 0x00FF00)
	GuiCtrlCreateLabel("", 410, 135, 20, 20)
	GUICtrlSetBkColor(-1, 0x0000FF)
	$cMode6 = GUICtrlCreateRadio("", 290, 160, 20, 20)
	GuiCtrlCreateLabel("", 310, 160, 20, 20)
	GUICtrlSetBkColor(-1, 0xFFFFFF)
	GuiCtrlCreateLabel("", 335, 160, 20, 20)
	GUICtrlSetBkColor(-1, 0x000000)
	GuiCtrlCreateLabel("", 360, 160, 20, 20)
	GUICtrlSetBkColor(-1, 0xFFFF00)
	GuiCtrlCreateLabel("", 385, 160, 20, 20)
	GUICtrlSetBkColor(-1, 0xFF00FF)
	GuiCtrlCreateLabel("", 410, 160, 20, 20)
	GUICtrlSetBkColor(-1, 0x00FFFF)
	$cMode7 = GUICtrlCreateRadio("", 290, 185, 20, 20)
	GuiCtrlCreateLabel("", 310, 185, 20, 20)
	GUICtrlSetBkColor(-1, 0xFFFFFF)
	GuiCtrlCreateLabel("", 335, 185, 20, 20)
	GUICtrlSetBkColor(-1, 0x000000)
	GuiCtrlCreateLabel("", 360, 185, 20, 20)
	GUICtrlSetBkColor(-1, 0xFF0000)
	GuiCtrlCreateLabel("", 385, 185, 20, 20)
	GUICtrlSetBkColor(-1, 0x00FF00)
	GuiCtrlCreateLabel("", 410, 185, 20, 20)
	GUICtrlSetBkColor(-1, 0x0000FF)
	GuiCtrlCreateLabel("", 435, 185, 20, 20)
	GUICtrlSetBkColor(-1, 0xFFFF00)
	GuiCtrlCreateLabel("", 460, 185, 20, 20)
	GUICtrlSetBkColor(-1, 0xFF00FF)
	GuiCtrlCreateLabel("", 485, 185, 20, 20)
	GUICtrlSetBkColor(-1, 0x00FFFF)
	GUICtrlCreateGroup("", -99, -99, 1, 1)

	GUICtrlCreateGroup("3)  Speed", 280, 235, 230, 80)
	$speedSlider = GUICtrlCreateSlider(295, 260, 200, 30)
	GUICtrlSetLimit($speedSlider, 100, 1)
	GUICtrlSetData($speedSlider, 20)
	GuiCtrlCreateLabel("Faster", 295, 290, 50, 15)
	GuiCtrlCreateLabel("Slower", 455, 290, 50, 15)
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	GUICtrlCreateLabel(	"On the flashy window, press 'F11' to display it in Fullscreen mode and 'F11' again to switch back.", 280, 330, 220, 45)
	$btnGO = GUICtrlCreateButton("Go!", 280, 380, 230, 50, $BS_DEFPUSHBUTTON)
	GuiCtrlSetFont($btnGO, 12)
	$lblWarn = GuiCtrlCreateLabel(	"WARNING: Do not stare at the flashy thingy if you suffer from seizures or have a family history of epilepsy.", _
									280, 440, 230, 50)
	GUICtrlSetTip(-1, "http://en.wikipedia.org/wiki/Epilepsy")
	GuiCtrlSetCursor(-1, 0)
	GuiCtrlSetFont(-1, 8, 800)
	GUICtrlSetColor(-1, 0xCC292D)


	$btnClose = GUICtrlCreateButton("Close (Esc)", 170, 440, 100, 30)
	GUICtrlSetState($cMode1, $GUI_CHECKED)

	GUISetState(@SW_SHOW)

	While 1

		Local $nMsg = GUIGetMsg()

		Switch $nMsg

			Case $filDownMovie
				If FileExists(@ScriptDir & "\All-Devices.exe") Then ShellExecute(@ScriptDir & "\All-Devices.exe")
			Case $HlpAbout, $pixIcon, $btnAbout
				_AboutDlg()
			Case $GUI_EVENT_CLOSE, $FilClose, $btnClose
				Exit

			Case $BtnWhite
				 _DeadPixelLocatorScreen(0xFFFFFF)
			Case $BtnBlack
				 _DeadPixelLocatorScreen(0x000000)
			Case $BtnRed
				 _DeadPixelLocatorScreen(0xFF0000)
			Case $BtnGreen
				 _DeadPixelLocatorScreen(0x00FF00)
			Case $BtnBlue
				 _DeadPixelLocatorScreen(0x0000FF)
			Case $BtnYellow
				 _DeadPixelLocatorScreen(0xFFFF00)
			Case $BtnMagenta
				 _DeadPixelLocatorScreen(0xFF00FF)
			Case $BtnCyan
				 _DeadPixelLocatorScreen(0x00FFFF)

			Case $btnGO
				_DisableControls()
				If GUICtrlRead($CMode1) = $GUI_CHECKED Then
					_Go(1)
				ElseIf GUICtrlRead($CMode2) = $GUI_CHECKED Then
					_Go(2)
				ElseIf GUICtrlRead($CMode3) = $GUI_CHECKED Then
					_Go(3)
				ElseIf GUICtrlRead($CMode4) = $GUI_CHECKED Then
					_Go(4)
				ElseIf GUICtrlRead($CMode5) = $GUI_CHECKED Then
					_Go(5)
				ElseIf GUICtrlRead($CMode6) = $GUI_CHECKED Then
					_Go(6)
				ElseIf GUICtrlRead($CMode7) = $GUI_CHECKED Then
					_Go(7)
				EndIf
				_EnableControls()

			Case $lblWarn
				 ShellExecute("http://en.wikipedia.org/wiki/Epilepsy")

		EndSwitch

		_WinAPI_EmptyWorkingSet()

	WEnd

EndFunc


Func _DisableControls()

	WinSetTrans($GUI_CORE, "", 220)
	GUICtrlSetState($btnGO, $GUI_DISABLE)
	GUICtrlSetState($btnWhite, $GUI_DISABLE)
	GUICtrlSetState($btnBlack, $GUI_DISABLE)
	GUICtrlSetState($btnRed, $GUI_DISABLE)
	GUICtrlSetState($btnGreen, $GUI_DISABLE)
	GUICtrlSetState($btnBlue, $GUI_DISABLE)
	GUICtrlSetState($btnYellow, $GUI_DISABLE)
	GUICtrlSetState($btnMagenta, $GUI_DISABLE)
	GUICtrlSetState($btnCyan, $GUI_DISABLE)
	GUICtrlSetState($cMode1, $GUI_DISABLE)
	GUICtrlSetState($cMode2, $GUI_DISABLE)
	GUICtrlSetState($cMode3, $GUI_DISABLE)
	GUICtrlSetState($cMode4, $GUI_DISABLE)
	GUICtrlSetState($cMode5, $GUI_DISABLE)
	GUICtrlSetState($cMode6, $GUI_DISABLE)
	GUICtrlSetState($cMode7, $GUI_DISABLE)
	GUICtrlSetState($lblWarn, $GUI_DISABLE)
	GUICtrlSetState($FileMenu, $GUI_DISABLE)
	GUICtrlSetState($HelpMenu, $GUI_DISABLE)
	GUICtrlSetState($btnAbout, $GUI_DISABLE)
	GUICtrlSetState($btnClose, $GUI_DISABLE)

EndFunc


Func _Go($cMode)

	Local $cc = 1
	$GoForm = GUICreate("", 100, 100, 100, 100, $WS_SIZEBOX, BitOR($WS_EX_TOOLWINDOW, $WS_EX_TOPMOST))

	GUISetCursor(16)

	GUISetState(@SW_SHOW)

	Local $recTimer = 0

	While 1

		If TimerDiff($recTimer) >= GUICtrlRead($speedSlider) * 10 Then

			Switch $cMode
				Case 1
					Switch $cc
						Case 1
							GUISetBkColor(0xFF0000, $GoForm)
							$cc = 2
						Case 2
							GUISetBkColor(0x00FF00, $GoForm)
							$cc = 3
						Case 3
							GUISetBkColor(0x0000FF, $GoForm)
							$cc = 1
					EndSwitch
				Case 2
					Switch $cc
						Case 1
							GUISetBkColor(0xFF0000, $GoForm)
							$cc = 2
						Case 2
							GUISetBkColor(0x00FF00, $GoForm)
							$cc = 3
						Case 3
							GUISetBkColor(0x0000FF, $GoForm)
							$cc = 4
						Case 4
							GUISetBkColor(0xFFFF00, $GoForm)
							$cc = 5
						Case 5
							GUISetBkColor(0xFF00FF, $GoForm)
							$cc = 6
						Case 6
							GUISetBkColor(0x00FFFF, $GoForm)
							$cc = 1
					EndSwitch
				Case 3
					Switch $cc
						Case 1
							GUISetBkColor(0xFFFF00, $GoForm)
							$cc = 2
						Case 2
							GUISetBkColor(0xFF00FF, $GoForm)
							$cc = 3
						Case 3
							GUISetBkColor(0x00FFFF, $GoForm)
							$cc = 1
					EndSwitch
				Case 4
					Switch $cc
						Case 1
							GUISetBkColor(0xFFFFFF, $GoForm)
							$cc = 2
						Case 2
							GUISetBkColor(0x000000, $GoForm)
							$cc = 1
					EndSwitch
				Case 5
					Switch $cc
						Case 1
							GUISetBkColor(0xFFFFFF, $GoForm)
							$cc = 2
						Case 2
							GUISetBkColor(0x000000, $GoForm)
							$cc = 3
						Case 3
							GUISetBkColor(0xFF0000, $GoForm)
							$cc = 4
						Case 4
							GUISetBkColor(0x00FF00, $GoForm)
							$cc = 5
						Case 5
							GUISetBkColor(0x0000FF, $GoForm)
							$cc = 1
					EndSwitch
				Case 6
					Switch $cc
						Case 1
							GUISetBkColor(0xFFFFFF, $GoForm)
							$cc = 2
						Case 2
							GUISetBkColor(0x000000, $GoForm)
							$cc = 3
						Case 3
							GUISetBkColor(0xFFFF00, $GoForm)
							$cc = 4
						Case 4
							GUISetBkColor(0xFF00FF, $GoForm)
							$cc = 5
						Case 5
							GUISetBkColor(0x00FFFF, $GoForm)
							$cc = 1
					EndSwitch
				Case 7
					Switch $cc
						Case 1
							GUISetBkColor(0xFFFFFF, $GoForm)
							$cc = 2
						Case 2
							GUISetBkColor(0x000000, $GoForm)
							$cc = 3
						Case 3
							GUISetBkColor(0xFF0000, $GoForm)
							$cc = 4
						Case 4
							GUISetBkColor(0x00FF00, $GoForm)
							$cc = 5
						Case 5
							GUISetBkColor(0x0000FF, $GoForm)
							$cc = 6
						Case 6
							GUISetBkColor(0xFFFF00, $GoForm)
							$cc = 7
						Case 7
							GUISetBkColor(0xFF00FF, $GoForm)
							$cc = 8
						Case 8
							GUISetBkColor(0x00FFFF, $GoForm)
							$cc = 1
					EndSwitch
			EndSwitch

			$recTimer = TimerInit()

		EndIf

		Local $goMsg = GUIGetMsg(1)

		Select

			Case $goMsg[0] = $GUI_EVENT_CLOSE And $goMsg[1] = $GoForm
				GUIDelete($GoForm)
				ExitLoop

		EndSelect
	WEnd

EndFunc


Func _EnableControls()

	GUICtrlSetState($btnGO, $GUI_ENABLE)
	GUICtrlSetState($btnWhite, $GUI_ENABLE)
	GUICtrlSetState($btnBlack, $GUI_ENABLE)
	GUICtrlSetState($btnRed, $GUI_ENABLE)
	GUICtrlSetState($btnGreen, $GUI_ENABLE)
	GUICtrlSetState($btnBlue, $GUI_ENABLE)
	GUICtrlSetState($btnYellow, $GUI_ENABLE)
	GUICtrlSetState($btnMagenta, $GUI_ENABLE)
	GUICtrlSetState($btnCyan, $GUI_ENABLE)
	GUICtrlSetState($cMode1, $GUI_ENABLE)
	GUICtrlSetState($cMode2, $GUI_ENABLE)
	GUICtrlSetState($cMode3, $GUI_ENABLE)
	GUICtrlSetState($cMode4, $GUI_ENABLE)
	GUICtrlSetState($cMode5, $GUI_ENABLE)
	GUICtrlSetState($cMode6, $GUI_ENABLE)
	GUICtrlSetState($cMode7, $GUI_ENABLE)
	GUICtrlSetState($lblWarn, $GUI_ENABLE)
	GUICtrlSetState($FileMenu, $GUI_ENABLE)
	GUICtrlSetState($HelpMenu, $GUI_ENABLE)
	GUICtrlSetState($btnAbout, $GUI_ENABLE)
	GUICtrlSetState($btnClose, $GUI_ENABLE)
	WinSetTrans($GUI_CORE, "", 255)

EndFunc


Func _DeadPixelLocatorScreen($Color)

	Local $FullForm, $btnBack, $btnNext

	$FullForm = GUICreate("", @DesktopWidth, @DesktopHeight, -1, -1, $WS_POPUP, $WS_EX_TOPMOST)
	GUISetBkColor($Color)

	$btnBack = GUICtrlCreateButton("Back", 50, 50, 100, 30)
	GUICtrlSetState($btnBack, $GUI_HIDE)
	$btnNext = GUICtrlCreateButton("Next", 150, 50, 100, 30)
	GUICtrlSetState($btnNext, $GUI_HIDE)

	GUISetCursor(3)

	Dim $AccelKeys[2][2]=[["{LEFT}", $BtnBack], ["{RIGHT}", $BtnNext]]
	GUISetAccelerators($AccelKeys)

	GUISetState(@SW_SHOW)
	GUISetState(@SW_MAXIMIZE)


	While 1

		Local $locsMsg = GUIGetMsg()

		Switch $locsMsg

			Case $GUI_EVENT_CLOSE
				GUIDelete($FullForm)
				ExitLoop

			Case $BtnNext

				Switch $Color
					Case 0xFFFFFF
						$Color = 0x000000
						GUISetBkColor($Color)
					Case 0x000000
						$Color = 0xFF0000
						GUISetBkColor($Color)
					Case 0xFF0000
						$Color = 0x00FF00
						GUISetBkColor($Color)
					Case 0x00FF00
						$Color = 0x0000FF
						GUISetBkColor($Color)
					Case 0x0000FF
						$Color = 0xFFFF00
						GUISetBkColor($Color)
					Case 0xFFFF00
						$Color = 0xFF00FF
						GUISetBkColor($Color)
					Case 0xFF00FF
						$Color = 0x00FFFF
						GUISetBkColor($Color)
					Case 0x00FFFF
						$Color = 0xFFFFFF
						GUISetBkColor($Color)
				EndSwitch

			Case $BtnBack

				Switch $Color
					Case 0xFFFFFF
						$Color = 0x00FFFF
						GUISetBkColor($Color)
					Case 0x00FFFF
						$Color = 0xFF00FF
						GUISetBkColor($Color)
					Case 0xFF00FF
						$Color = 0xFFFF00
						GUISetBkColor($Color)
					Case 0xFFFF00
						$Color = 0x0000FF
						GUISetBkColor($Color)
					Case 0x0000FF
						$Color = 0x00FF00
						GUISetBkColor($Color)
					Case 0x00FF00
						$Color = 0xFF0000
						GUISetBkColor($Color)
					Case 0xFF0000
						$Color = 0x000000
						GUISetBkColor($Color)
					Case 0x000000
						$Color = 0xFFFFFF
						GUISetBkColor($Color)
				EndSwitch

		EndSwitch

	WEnd

EndFunc



Func _AboutDlg()

	GuiCtrlSetState($btnAbout, $GUI_DISABLE)
	GuiCtrlSetState($hlpAbout, $GUI_DISABLE)

	Opt("GUIOnEventMode", 1)

	Local $abTitle, $abVersion, $abCopyright
	Local $abHome, $abGNU
	Local $abSpaceLabel, $abSpaceProg, $abBtnOK
	Local $abPayPal, $abFacebook, $abTwittter, $abLinkedIn, $abGoogle

	$aboutDlg = GUICreate("About " & $APPSET_COMPANY & " " & $APPSET_TITLE, 400, 500, -1, -1, BitOr($WS_CAPTION, $WS_POPUPWINDOW), $WS_EX_TOPMOST)
	GUISetFont(8.5, 400, 0, "Verdana", $AboutDlg, 5)

	GUISetOnEvent($GUI_EVENT_CLOSE, "_CloseAboutDlg", $AboutDlg)

	GUICtrlCreateIcon(@ScriptFullPath, 99, 10, 10, 64, 64)
	$abPayPal = GUICtrlCreateIcon(@ScriptFullPath, 205, 320, 0, 64, 64)
	GUICtrlSetTip($abPayPal, "Help us keep our software free.")
	GUICtrlSetCursor($abPayPal, 0)
	$abTitle = GUICtrlCreateLabel($APPSET_COMPANY & " " & $APPSET_TITLE, 88, 16, 220, 18)
	GuiCtrlSetFont($abTitle, 10)
	$abVersion = GUICtrlCreateLabel("Version " & FileGetVersion(@ScriptFullPath), 88, 40, 220, 20)
	$abCopyright = GUICtrlCreateLabel("Copyright © 2014 Rizonesoft", 88, 55, 220, 20)
	GuiCtrlSetColor(-1, 0x555555)

	GUICtrlCreateLabel("Rizonesoft Home: ", 20, 90, 130, 15, $SS_RIGHT)
	$abHome = GUICtrlCreateLabel("www.rizonesoft.com", 155, 90, 220, 15)
	GuiCtrlSetFont($abHome, -1, -1, 4) ;Underlined
	GuiCtrlSetColor($abHome, 0x0000FF)
	GuiCtrlSetCursor($abHome, 0)
	$abGNU = GUICtrlCreateLabel("This program is free software: you can redistribute it and/or modify " & _
								"it under the terms of the GNU General Public License as published by " & _
								"the Free Software Foundation, either version 3 of the License, or " & _
								"(at your option) any later version." & @CRLF & @CRLF & _
								"This program is distributed in the hope that it will be useful, " & _
								"but WITHOUT ANY WARRANTY; without even the implied warranty of " & _
								"MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the " & _
								"GNU General Public License for more details.", 20, 125, 350, 180)
	GuiCtrlSetColor($abGNU, 0x555555)
	GUICtrlCreateLabel(	"Contributors: Derick Payne (Rizonesoft)", 20, 280, 350, 100)

	Local $ScriptDirSplt = StringSplit(@ScriptDir, "\")
	Local $ScriptDrive  = $ScriptDirSplt[1]
	Local $drvSpaceUsed = DriveSpaceTotal($ScriptDrive) - DriveSpaceFree($ScriptDrive)

	$abSpaceLabel = GUICtrlCreateLabel("(" & $ScriptDrive & ") " & Round(DriveSpaceFree($ScriptDrive) / 1024, 1) & " GB free of " & _
					Round(DriveSpaceTotal($ScriptDrive) / 1024, 1) & " GB", 15, 380, 300, 15)
	$abSpaceProg = GUICtrlCreateProgress(15, 400, 350, 15)
	GUICtrlSetData($abSpaceProg, ($drvSpaceUsed / DriveSpaceTotal($ScriptDrive)) * 100)
	$abBtnOK = GUICtrlCreateButton("OK", 250, 450, 123, 33, $BS_DEFPUSHBUTTON)

	$abFacebook = GUICtrlCreateIcon(@ScriptFullPath, 201, 20, 450, 32, 32)
	GUICtrlSetTip($abFacebook, "Like us on Facebook")
	GUICtrlSetCursor($abFacebook, 0)
	$abTwittter = GUICtrlCreateIcon(@ScriptFullPath, 202, 55, 450, 32, 32)
	GUICtrlSetTip($abTwittter, "Follow us on Twitter")
	GUICtrlSetCursor($abTwittter, 0)
	$abLinkedIn = GUICtrlCreateIcon(@ScriptFullPath, 203, 90, 450, 32, 32)
	GUICtrlSetTip($abLinkedIn, "Connect with us on LinkedIn")
	GUICtrlSetCursor($abLinkedIn, 0)
	$abGoogle = GUICtrlCreateIcon(@ScriptFullPath, 204, 125, 450, 32, 32)
	GUICtrlSetTip($abGoogle, "Connect with us on Google+")
	GUICtrlSetCursor($abGoogle, 0)

	GUICtrlSetOnEvent($abHome, "_HomePageClicked")
	GUICtrlSetOnEvent($abFacebook, "_OpenFacebook")
	GUICtrlSetOnEvent($abTwittter, "_FollowOnTwitter")
	GUICtrlSetOnEvent($abLinkedIn, "_OpenLinkedIn")
	GUICtrlSetOnEvent($abGoogle, "_OpenGooglePlus")
	GUICtrlSetOnEvent($abBtnOK, "_CloseAboutDlg")
	GUICtrlSetOnEvent($abPayPal, "_DonateSomething")

	GUISetState(@SW_SHOW, $AboutDlg)

EndFunc

Func _CloseAboutDlg()

	GuiCtrlSetState($btnAbout, $GUI_ENABLE)
	GuiCtrlSetState($hlpAbout, $GUI_ENABLE)

	Opt("GUIOnEventMode", 0)
	GUISetState(@SW_HIDE, @GUI_WinHandle)

EndFunc

Func _HomePageClicked()
	ShellExecute("http://rizonesoft.com")
EndFunc


Func _OpenFacebook()
	ShellExecute("https://www.facebook.com/rizonesoft")
EndFunc


Func _FollowOnTwitter()
	ShellExecute("https://twitter.com/rizonesoft")
EndFunc

Func _OpenLinkedIn()
	ShellExecute("http://www.linkedin.com/in/rizonesoft")
EndFunc

Func _OpenGooglePlus()
	ShellExecute("https://plus.google.com/+Rizonesoftsa/posts")
EndFunc

Func _DonateSomething()
	ShellExecute("https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=7UGGCSDUZJPFE")
EndFunc