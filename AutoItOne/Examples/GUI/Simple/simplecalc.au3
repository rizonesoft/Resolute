#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>

_Example()
Exit

Func _Example()
	GUICreate("Calculator", 260, 230)
	; Digit's buttons
	Local $idButton_0 = GUICtrlCreateButton("0", 54, 171, 36, 29)
	Local $idButton_1 = GUICtrlCreateButton("1", 54, 138, 36, 29)
	Local $idButton_2 = GUICtrlCreateButton("2", 93, 138, 36, 29)
	Local $idButton_3 = GUICtrlCreateButton("3", 132, 138, 36, 29)
	Local $idButton_4 = GUICtrlCreateButton("4", 54, 106, 36, 29)
	Local $idButton_5 = GUICtrlCreateButton("5", 93, 106, 36, 29)
	Local $idButton_6 = GUICtrlCreateButton("6", 132, 106, 36, 29)
	Local $idButton_7 = GUICtrlCreateButton("7", 54, 73, 36, 29)
	Local $idButton_8 = GUICtrlCreateButton("8", 93, 73, 36, 29)
	Local $idButton_9 = GUICtrlCreateButton("9", 132, 73, 36, 29)
	Local $idButton_Period = GUICtrlCreateButton(".", 132, 171, 36, 29)
	#forceref $idButton_0, $idButton_1, $idButton_2, $idButton_3, $idButton_4, $idButton_5
	#forceref $idButton_6, $idButton_7, $idButton_8, $idButton_9, $idButton_Period

	; Memory's buttons
	Local $idButton_MClear = GUICtrlCreateButton("MC", 8, 73, 36, 29)
	Local $idButton_MRestore = GUICtrlCreateButton("MR", 8, 106, 36, 29)
	Local $idButton_MStore = GUICtrlCreateButton("MS", 8, 138, 36, 29)
	Local $idButton_MAdd = GUICtrlCreateButton("M+", 8, 171, 36, 29)
	#forceref $idButton_MClear, $idButton_MRestore, $idButton_MStore, $idButton_MAdd

	; Operators
	Local $idButton_ChangeSign = GUICtrlCreateButton("+/-", 93, 171, 36, 29)
	Local $idButton_Division = GUICtrlCreateButton("/", 171, 73, 36, 29)
	Local $idButton_Multiplication = GUICtrlCreateButton("*", 171, 106, 36, 29)
	Local $idButton_Subtract = GUICtrlCreateButton("-", 171, 138, 36, 29)
	Local $idButton_Add = GUICtrlCreateButton("+", 171, 171, 36, 29)
	Local $idButton_Answer = GUICtrlCreateButton("=", 210, 171, 36, 29)
	Local $idButton_Inverse = GUICtrlCreateButton("1/x", 210, 138, 36, 29)
	Local $idButton_Sqrt = GUICtrlCreateButton("Sqrt", 210, 73, 36, 29)
	Local $idButton_Percentage = GUICtrlCreateButton("%", 210, 106, 36, 29)
	Local $idButton_Backspace = GUICtrlCreateButton("Backspace", 54, 37, 63, 29)
	Local $idButton_ClearE = GUICtrlCreateButton("CE", 120, 37, 62, 29)
	Local $idButton_Clear = GUICtrlCreateButton("C", 185, 37, 62, 29)

	; Local $idEdit_Screen = GUICtrlCreateEdit("0.", 8, 2, 239, 23)
	Local $idEdit_Screen = GUICtrlCreateEdit(" 0.", 8, 2, 239, 23, BitOR($ES_READONLY, $ES_RIGHT), $WS_EX_STATICEDGE)

	; Local $idLabel_Memory = GUICtrlCreateLabel("", 12, 39, 27, 26)
	Local $idLabel_Memory = GUICtrlCreateLabel("", 12, 39, 27, 26, $SS_SUNKEN)

	#forceref $idButton_ChangeSign, $idButton_Division, $idButton_Multiplication, $idButton_Subtract, $idButton_Add
	#forceref $idButton_Answer, $idButton_Inverse, $idButton_Sqrt, $idButton_Percentage, $idButton_Backspace
	#forceref $idButton_ClearE, $idButton_Clear, $idEdit_Screen, $idLabel_Memory
	GUISetState()

	Local $iMsg
	Do
		$iMsg = GUIGetMsg()
		; this is only demo for GUI building not for math calculation
	Until $iMsg = $GUI_EVENT_CLOSE

EndFunc   ;==>_Example
