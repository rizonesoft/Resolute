#include <GDIPlus.au3>
#include <GUIConstantsEx.au3>
#include <GuiImageList.au3>
#include <GuiListView.au3>

Example_1() ; use UDF built listview

Func Example_1()
	Local $iLVWidth = 440, $iLVHeight = 340

	Local $hGUI = GUICreate("(UDF Created) ListView Set Background Image  (v" & @AutoItVersion & ")", 500, 400)
	GUISetBkColor(0x52F77E)

	Local $hListView = _GUICtrlListView_Create($hGUI, '', 30, 30, $iLVWidth, $iLVHeight)
	_GUICtrlListView_SetExtendedListViewStyle($hListView, $LVS_EX_FULLROWSELECT)

	; Load images
	Local $hImage = _GUIImageList_Create()
	_GUIImageList_Add($hImage, _GUICtrlListView_CreateSolidBitMap($hListView, 0xFF0000, 16, 16))
	_GUIImageList_Add($hImage, _GUICtrlListView_CreateSolidBitMap($hListView, 0x00FF00, 16, 16))
	_GUIImageList_Add($hImage, _GUICtrlListView_CreateSolidBitMap($hListView, 0x0000FF, 16, 16))
	_GUICtrlListView_SetImageList($hListView, $hImage, 1)

	; Add columns
    _GUICtrlListView_InsertColumn($hListView, 0, 'Column 1', 100)
    _GUICtrlListView_InsertColumn($hListView, 1, 'Column 2', 100)
    _GUICtrlListView_InsertColumn($hListView, 2, 'Column 3', 100)

    ; Add items
    _GUICtrlListView_AddItem($hListView, 'Row 1: Col 1', 0)
    _GUICtrlListView_AddSubItem($hListView, 0, 'Row 1: Col 2', 1)
    _GUICtrlListView_AddSubItem($hListView, 0, 'Row 1: Col 3', 2)
    _GUICtrlListView_AddItem($hListView, 'Row 2: Col 1', 1)
    _GUICtrlListView_AddSubItem($hListView, 1, 'Row 2: Col 2', 1)
    _GUICtrlListView_AddItem($hListView, 'Row 3: Col 1', 2)

    ; Build groups
    _GUICtrlListView_EnableGroupView($hListView)
    _GUICtrlListView_InsertGroup($hListView, -1, 1, 'Group 1')
    _GUICtrlListView_InsertGroup($hListView, -1, 2, 'Group 2')
    _GUICtrlListView_SetItemGroupID($hListView, 0, 1)
    _GUICtrlListView_SetItemGroupID($hListView, 1, 2)
    _GUICtrlListView_SetItemGroupID($hListView, 2, 2)

	; Creates $g_hGDIBmp - Linear gradient
	Local $hGDIBmp = _CreateHBITMAP($iLVWidth, $iLVHeight)

	; Sets the background image in the ListView
	_GUICtrlListView_SetBkHBITMAP($hListView, $hGDIBmp, 0, 0, 0, True)

	GUISetState()
	; Loop until the user exits
	Do
	Until GUIGetMsg() = $GUI_EVENT_CLOSE
	GUIDelete()
EndFunc   ;==>Example_UDF_Created

Func _CreateHBITMAP($iWidth, $iHeight)
	_GDIPlus_Startup()

	Local $tRectF = _GDIPlus_RectFCreate(0, 0, $iWidth, $iHeight)
	Local $hBitmap = _GDIPlus_BitmapCreateFromScan0($iWidth, $iHeight)
	Local $hGraphics = _GDIPlus_ImageGetGraphicsContext($hBitmap)
	Local $hBrush = _GDIPlus_LineBrushCreateFromRectWithAngle($tRectF, 0xFFFFF700, 0xFF2F00FF, 45)
	_GDIPlus_GraphicsFillRect($hGraphics, 0, 0, $iWidth, $iHeight, $hBrush)
	Local $hGDIBmp = _GDIPlus_BitmapCreateHBITMAPFromBitmap($hBitmap)

	_GDIPlus_ImageDispose($hBitmap)
	_GDIPlus_BrushDispose($hBrush)
	_GDIPlus_GraphicsDispose($hGraphics)
	_GDIPlus_Shutdown()
	Return $hGDIBmp
EndFunc   ;==>_CreateHBITMAP
