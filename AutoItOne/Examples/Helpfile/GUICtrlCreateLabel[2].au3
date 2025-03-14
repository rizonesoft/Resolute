; == GUICtrlCreateLabel() overlapping controls

#include <GUIConstants.au3>

Local $hGUI = GUICreate("Example", 300, 200)

Local $idLabel = GUICtrlCreateLabel(" Label overlapping the whole client area", 0, 0, 300, 200, $WS_CLIPSIBLINGS)
; $WS_CLIPSIBLINGS imply a small perf drawback
; see ​https://social.msdn.microsoft.com/Forums/en-US/dcd6a33c-2a6f-440f-ba0b-4a5fa26d14bb/when-to-use-wsclipchildren-and-wsclipsibilings-styles?forum=vcgeneral
; better to not overlap controls
;~ Local $idLabel = GUICtrlCreateLabel(" Label NOT OVERLAPPING others controls", 0, 0, 290, 170)

Local $idClose = GUICtrlCreateButton("Close", 210, 170, 85, 25)
GUICtrlSetState(-1, $GUI_ONTOP)

GUISetState()

While True
  Switch GUIGetMsg()
    Case $GUI_EVENT_CLOSE, $idClose
      ExitLoop
    Case $idLabel
      ConsoleWrite("Label" & @CRLF)
  EndSwitch
WEnd
