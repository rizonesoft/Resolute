#include <ColorConstants.au3>
#include <GUIConstantsEx.au3>
#include <ListViewConstants.au3>

Example()

Func Example()
	; Create a GUI with a listview.
	Local $hGUI = GUICreate("Colored ListView Items", 250, 170, 100, 200, -1)
	Local $idListview = GUICtrlCreateListView("col1|col2|col3", 10, 10, 230, 150)

	; Alternate between the listview background color and the listview item background color.
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_LV_ALTERNATE)

	; Set the background color for the listview.
	; Odd listview items will be shown with the background color of the listview,
	; even with the background color of the listview item.
	GUICtrlSetBkColor(-1, $COLOR_AQUA)

	; Create listview items and set the backgroundcolor for each of them.
	GUICtrlCreateListViewItem("item1|col12|col13", $idListview)

	; The following line could be dropped as the background color is taken from the listview.
	GUICtrlSetBkColor(-1, $COLOR_GREEN)
	GUICtrlCreateListViewItem("item2|col22|col23", $idListview)
	GUICtrlSetBkColor(-1, $COLOR_GREEN)
	GUICtrlCreateListViewItem("item3|col32|col33", $idListview)

	; The following line could be dropped as the background color is taken from the listview.
	GUICtrlSetBkColor(-1, $COLOR_GREEN)

	; Change the color of a single listview item.
	GUICtrlCreateListViewItem("Now|change|color", $idListview)
	GUICtrlSetBkColor(-1, $COLOR_LIME)
	GUICtrlCreateListViewItem("item5|col52|col53", $idListview)

	; The following line could be dropped as the background color is taken from the listview.
	GUICtrlSetBkColor(-1, $COLOR_GREEN)
	GUICtrlCreateListViewItem("item6|col62|col63", $idListview)
	GUICtrlSetBkColor(-1, $COLOR_GREEN)
	GUISetState(@SW_SHOW, $hGUI)

	While 1
		Switch GUIGetMsg()
			Case $GUI_EVENT_CLOSE
				ExitLoop

		EndSwitch
	WEnd

	; Delete the previous GUI and all controls
	GUIDelete($hGUI)
EndFunc   ;==>Example
