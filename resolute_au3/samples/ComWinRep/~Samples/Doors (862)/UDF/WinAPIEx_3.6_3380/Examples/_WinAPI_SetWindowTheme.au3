#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

If _WinAPI_GetVersion() < '6.0' Then
	MsgBox(16, 'Error', 'Require Windows Vista or later.')
	Exit
EndIf

Global $ListView

GUICreate('MyGUI', 332, 400)

$ListView = GUICtrlCreateListView('Column 1|Column 2|Column 3|Column 4', 10, 10, 312, 380)
For $i = 1 To 9
	GUICtrlCreateListViewItem('Item ' & $i & '|' & 'Sub ' & $i & '|' & 'Sub ' & $i & '|' & 'Sub ' & $i, $ListView)
Next

_WinAPI_SetWindowTheme(GUICtrlGetHandle($ListView), 'Explorer')

GUISetState()

Do
Until GUIGetMsg() = -3
