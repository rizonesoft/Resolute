#include <GuiComboBoxEx.au3>
#include <GUIConstantsEx.au3>
#include <GuiImageList.au3>

Global $g_idMemo

Example()

Func Example()
	; Create GUI
	Local $hGUI = GUICreate("ComboBoxEx Get ItemEx (v" & @AutoItVersion & ")", 400, 300)
	Local $hCombo = _GUICtrlComboBoxEx_Create($hGUI, "", 2, 2, 394, 100)
	$g_idMemo = GUICtrlCreateEdit("", 2, 32, 396, 266, 0)
	GUICtrlSetFont($g_idMemo, 9, 400, 0, "Courier New")
	GUISetState(@SW_SHOW)

	Local $hImage = _GUIImageList_Create(16, 16, 5, 3)
	_GUIImageList_AddIcon($hImage, @SystemDir & "\shell32.dll", 110)
	_GUIImageList_AddIcon($hImage, @SystemDir & "\shell32.dll", 131)
	_GUIImageList_AddIcon($hImage, @SystemDir & "\shell32.dll", 165)
	_GUIImageList_AddIcon($hImage, @SystemDir & "\shell32.dll", 168)
	_GUIImageList_AddIcon($hImage, @SystemDir & "\shell32.dll", 137)
	_GUIImageList_AddIcon($hImage, @SystemDir & "\shell32.dll", 146)
	_GUIImageList_Add($hImage, _GUICtrlComboBoxEx_CreateSolidBitMap($hCombo, 0xFF0000, 16, 16))
	_GUIImageList_Add($hImage, _GUICtrlComboBoxEx_CreateSolidBitMap($hCombo, 0x00FF00, 16, 16))
	_GUIImageList_Add($hImage, _GUICtrlComboBoxEx_CreateSolidBitMap($hCombo, 0x0000FF, 16, 16))
	_GUICtrlComboBoxEx_SetImageList($hCombo, $hImage)

	For $x = 0 To 8
		_GUICtrlComboBoxEx_AddString($hCombo, StringFormat("%03d : string", $x), $x, $x)
	Next

	;Set Item indent
	_GUICtrlComboBoxEx_SetItemIndent($hCombo, 1, 1)

	;Create Structure
	Local $tItem = DllStructCreate($tagCOMBOBOXEXITEM)
	;Set Mask for what to retrieve
	DllStructSetData($tItem, "Mask", BitOR($CBEIF_IMAGE, $CBEIF_INDENT, $CBEIF_LPARAM, $CBEIF_SELECTEDIMAGE, $CBEIF_OVERLAY))
	;Set Index of item to retrieve
	DllStructSetData($tItem, "Item", 1)

	_GUICtrlComboBoxEx_GetItemEx($hCombo, $tItem)
	Local $sText
	Local $iLen = _GUICtrlComboBoxEx_GetItemText($hCombo, 1, $sText)
	MemoWrite("Item Text : " & $sText)
	MemoWrite("Item Len ..........................: " & $iLen)
	MemoWrite("# image widths to indent ..........: " & DllStructGetData($tItem, "Indent"))
	MemoWrite("0-based item image index .......: " & DllStructGetData($tItem, "Image"))
	MemoWrite("0-based item state image index .: " & DllStructGetData($tItem, "SelectedImage"))
	MemoWrite("0-based item image overlay index: " & DllStructGetData($tItem, "OverlayImage"))
	MemoWrite("Item application defined value ....: " & DllStructGetData($tItem, "Param"))

	; Change item 1
	MsgBox($MB_SYSTEMMODAL, "Information", "Changing item 1")
	$tItem = DllStructCreate($tagCOMBOBOXEXITEM)
	DllStructSetData($tItem, "Mask", $CBEIF_INDENT)
	DllStructSetData($tItem, "Item", 1)
	DllStructSetData($tItem, "Indent", 2)

	_GUICtrlComboBoxEx_SetItemEx($hCombo, $tItem)

	; show drop down
	_GUICtrlComboBoxEx_ShowDropDown($hCombo, True)

	Do
	Until GUIGetMsg() = $GUI_EVENT_CLOSE
EndFunc   ;==>Example

; Write a line to the memo control
Func MemoWrite($sMessage)
	GUICtrlSetData($g_idMemo, $sMessage & @CRLF, 1)
EndFunc   ;==>MemoWrite
