#include <GDIPlus.au3>
#include <GUIConstantsEx.au3>
#include <GuiImageList.au3>
#include <GuiListView.au3>

Example_2() ; use UDF built listview

Func Example_2()
	Local $iGUIWidth = 500, $iGUIHeight = 300

	Local $hGUI = GUICreate("(UDF Created) ListView Set Background Image  (v" & @AutoItVersion & ")", $iGUIWidth, $iGUIHeight)
	WinSetTrans($hGUI, '', 0)
	GUISetState()

	; Draws the background of the GUI
	_GDIPlus_Startup()
	Local $hImage = _GDIPlus_ImageLoadFromFile(RegRead('HKEY_CURRENT_USER\Control Panel\Desktop', 'Wallpaper'))
	Local $hGraphics = _GDIPlus_GraphicsCreateFromHWND($hGUI)
	_GDIPlus_GraphicsDrawImageRect($hGraphics, $hImage, 0, 0, $iGUIWidth, $iGUIHeight)

	; Creates $hGDIBmp
	Local $hGDIBmp = _CreateHBITMAP($hImage, $iGUIWidth, $iGUIHeight)

	_GDIPlus_GraphicsDispose($hGraphics)
	_GDIPlus_ImageDispose($hImage)
	_GDIPlus_Shutdown()

	Local $hListView = _GUICtrlListView_Create($hGUI, "", 30, 30, $iGUIWidth - 60, $iGUIHeight - 60, BitOR($LVS_REPORT, $LVS_NOCOLUMNHEADER))
	_GUICtrlListView_SetExtendedListViewStyle($hListView, $LVS_EX_FULLROWSELECT)
	_GUICtrlListView_SetTextColor($hListView, 0x00FF00)

	; Load images
	Local $hImageList = _GUIImageList_Create()
	_GUIImageList_Add($hImageList, _GUICtrlListView_CreateSolidBitMap($hListView, 0xFF0000, 16, 16))
	_GUIImageList_Add($hImageList, _GUICtrlListView_CreateSolidBitMap($hListView, 0xFFFF00, 16, 16))
	_GUIImageList_Add($hImageList, _GUICtrlListView_CreateSolidBitMap($hListView, 0x0000FF, 16, 16))
	_GUICtrlListView_SetImageList($hListView, $hImageList, 1)

	; Add columns
	_GUICtrlListView_InsertColumn($hListView, 0, "Column 1", 100)
	_GUICtrlListView_InsertColumn($hListView, 1, "Column 2", 100)
	_GUICtrlListView_InsertColumn($hListView, 2, "Column 3", 100)

	; Add items
	_GUICtrlListView_AddItem($hListView, "Row 1: Col 1", 0)
	_GUICtrlListView_AddSubItem($hListView, 0, "Row 1: Col 2", 1)
	_GUICtrlListView_AddSubItem($hListView, 0, "Row 1: Col 3", 2)
	_GUICtrlListView_AddItem($hListView, "Row 2: Col 1", 1)
	_GUICtrlListView_AddSubItem($hListView, 1, "Row 2: Col 2", 1)
	_GUICtrlListView_AddItem($hListView, "Row 3: Col 1", 2)

	; Build groups
	_GUICtrlListView_EnableGroupView($hListView)
	_GUICtrlListView_InsertGroup($hListView, -1, 1, "Group 1")
	_GUICtrlListView_InsertGroup($hListView, -1, 2, "Group 2")
	_GUICtrlListView_SetItemGroupID($hListView, 0, 1)
	_GUICtrlListView_SetItemGroupID($hListView, 1, 2)
	_GUICtrlListView_SetItemGroupID($hListView, 2, 2)

	; Sets the background image in the ListView
	_GUICtrlListView_SetBkHBITMAP($hListView, $hGDIBmp, 1, -30, -30, True)

	WinSetTrans($hGUI, '', 255)

	; Loop until the user exits
	Do
	Until GUIGetMsg() = $GUI_EVENT_CLOSE
	GUIDelete()
EndFunc   ;==>Example_2

Func _CreateHBITMAP($hImage, $iWidth, $iHeight)
	Local $hBitmap = _GDIPlus_BitmapCreateFromScan0($iWidth, $iHeight)
	Local $hGraphics = _GDIPlus_ImageGetGraphicsContext($hBitmap)
	_GDIPLus_GraphicsDrawImageRect($hGraphics, $hImage, 0, 0, $iWidth, $iHeight)
	Local $hGDIBmp = _GDIPlus_BitmapCreateHBITMAPFromBitmap($hBitmap)

	_GDIPlus_ImageDispose($hBitmap)
	_GDIPlus_GraphicsDispose($hGraphics)
	Return $hGDIBmp
EndFunc   ;==>_CreateHBITMAP
