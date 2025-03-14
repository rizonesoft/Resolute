#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>

Example()

; Simple example: Embedding an Internet Explorer Object inside an AutoIt GUI
Func Example()
	; This particular object is declared as ObjEvent() need to stored the Object, #forceref to avoid Au3Check warning.
	Local $oErrorHandler = ObjEvent("AutoIt.Error", "_ErrFunc")
	#forceref $oErrorHandler

	Local $idButton_Back, $idButton_Forward
	Local $idButton_Home, $idButton_Stop, $iMsg

	Local $oIE = ObjCreate("Shell.Explorer.2")

	; Create a simple GUI for our output
	GUICreate("Embedded Web control Test", 640, 580, (@DesktopWidth - 640) / 2, (@DesktopHeight - 580) / 2, BitOR($WS_OVERLAPPEDWINDOW, $WS_CLIPSIBLINGS, $WS_CLIPCHILDREN))
	GUICtrlCreateObj($oIE, 10, 40, 600, 360)
	GUICtrlSetResizing(-1, $GUI_DOCKAUTO)

	$idButton_Back = GUICtrlCreateButton("Back", 10, 420, 100, 30)
	$idButton_Forward = GUICtrlCreateButton("Forward", 120, 420, 100, 30)
	$idButton_Home = GUICtrlCreateButton("AutoIt Home", 230, 420, 100, 30)
	$idButton_Stop = GUICtrlCreateButton("Stop", 330, 420, 100, 30)

	GUISetState(@SW_SHOW) ;Show GUI

	$oIE.navigate("http://google.com")
	Sleep(3000)
	$oIE.navigate("http://www.autoitscript.com")

	; Loop until the user exits.
	While 1
		$iMsg = GUIGetMsg()

		Select
			Case $iMsg = $GUI_EVENT_CLOSE
				ExitLoop
			Case $iMsg = $idButton_Home
				$oIE.navigate("http://www.autoitscript.com")
			Case $iMsg = $idButton_Back
				$oIE.GoBack
			Case $iMsg = $idButton_Forward
				$oIE.GoForward
			Case $iMsg = $idButton_Stop
				$oIE.Stop
		EndSelect

	WEnd

	GUIDelete()
EndFunc   ;==>Example

; User's COM error function. Will be called if COM error occurs
Func _ErrFunc($oError)
	; Do anything here.
	ConsoleWrite(@ScriptName & " (" & $oError.scriptline & ") : ==> COM Error intercepted !" & @CRLF & _
			@TAB & "err.number is: " & @TAB & @TAB & "0x" & Hex($oError.number) & @CRLF & _
			@TAB & "err.windescription:" & @TAB & $oError.windescription & @CRLF & _
			@TAB & "err.description is: " & @TAB & $oError.description & @CRLF & _
			@TAB & "err.source is: " & @TAB & @TAB & $oError.source & @CRLF & _
			@TAB & "err.helpfile is: " & @TAB & $oError.helpfile & @CRLF & _
			@TAB & "err.helpcontext is: " & @TAB & $oError.helpcontext & @CRLF & _
			@TAB & "err.lastdllerror is: " & @TAB & $oError.lastdllerror & @CRLF & _
			@TAB & "err.scriptline is: " & @TAB & $oError.scriptline & @CRLF & _
			@TAB & "err.retcode is: " & @TAB & "0x" & Hex($oError.retcode) & @CRLF & @CRLF)
EndFunc   ;==>_ErrFunc
