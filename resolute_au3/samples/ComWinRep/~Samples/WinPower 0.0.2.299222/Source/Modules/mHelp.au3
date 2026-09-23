Func _About()
	Opt("GUICloseOnESC", 1)

	$FrmAout = GUICreate("About " & $PowerTitle, 409, 300, 192, 124, BitOr($WS_CAPTION, $WS_POPUPWINDOW), $WS_EX_TOPMOST)
	WinSetOnTop ("About " & $PowerTitle,"",1 )
	GUISetFont(8.5, 400, 0, "Verdana")
	GUICtrlCreateIcon($GPowerRes, 1, 8, 8, 64, 64)

	GUICtrlCreateLabel($PowerTitle, 88, 16, 300, 18)
	GUICtrlSetFont(-1, 9, 800, 0, "Verdana")

	GUICtrlCreateLabel("Version " & $PowerVer & @CRLF & "Copyright © 2009 Rizone Technologies", 88, 40, 300, 40)
	$AbSEmail1 = GUICtrlCreateLabel("rizonetech@gmail.com", 88, 88, 159, 15)
	GuiCtrlSetFont($AbSEmail1, 8.5, -1, 4) ;Underlined
	GuiCtrlSetColor($AbSEmail1, 0x0000FF)
	GuiCtrlSetCursor($AbSEmail1, 0)
	$AbSEmail2 = GUICtrlCreateLabel("rizonetech@live.co.uk", 88, 104, 159, 15)
	GuiCtrlSetFont($AbSEmail2, 8.5, -1, 4) ;Underlined
	GuiCtrlSetColor($AbSEmail2, 0x0000FF)
	GuiCtrlSetCursor($AbSEmail2, 0)
	$AbHome = GUICtrlCreateLabel("http://www.rizonetech.com", 88, 120, 159, 15)
	GuiCtrlSetFont($AbHome, 8.5, -1, 4) ;Underlined
	GuiCtrlSetColor($AbHome, 0x0000FF)
	GuiCtrlSetCursor($AbHome, 0)

	GUICtrlCreateLabel("Derick Payne, Petro Joubert", 10, 165, 400, 15)
	GuiCtrlSetFont(-1, 7.5, -1, 0)

	$AbBClose = GUICtrlCreateButton("Close", 280, 250, 123, 33, $WS_GROUP)

	GUISetState(@SW_SHOW, $FrmAout)

	GUISetOnEvent($GUI_EVENT_CLOSE, "_AboutCloseClicked", $FrmAout)
	GUICtrlSetOnEvent($AbBClose, "_AboutCloseClicked")
	GUICtrlSetOnEvent($AbSEmail1, "_AboutEmail")
	GUICtrlSetOnEvent($AbSEmail2, "_AboutEmail2")
	GUICtrlSetOnEvent($AbHome, "_AboutHome")

EndFunc

Func _AboutCloseClicked()
	GUIDelete(@GUI_WinHandle)
	Opt("GUICloseOnESC", 0)
EndFunc

Func _AboutEmail()
	ShellExecute("mailto:rizonetech@gmail.com")
EndFunc

Func _AboutEmail2()
	ShellExecute("mailto:rizonetech@live.co.uk")
EndFunc

Func _AboutHome()
	ShellExecute("http://www.rizonetech.com")
EndFunc
