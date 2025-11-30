#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $Data, $Text

$Data = _WinAPI_GetKeyboardType(0)
Switch $Data
	Case 1
		$Text = 'IBM PC/XT or compatible (83-key) keyboard'
	Case 2
		$Text = 'Olivetti "ICO" (102-key) keyboard'
	Case 3
		$Text = 'IBM PC/AT (84-key) or similar keyboard'
	Case 4
		$Text = 'IBM enhanced (101- or 102-key) keyboard'
	Case 5
		$Text = 'Nokia 1050 and similar keyboards'
	Case 6
		$Text = 'Nokia 9140 and similar keyboards'
	Case 7
		$Text = 'Japanese keyboard'
EndSwitch

ConsoleWrite('Type   : ' & $Text & @CR)
ConsoleWrite('Subtype: ' & _WinAPI_GetKeyboardType(1) & @CR)
ConsoleWrite('F-keys : ' & _WinAPI_GetKeyboardType(2) & @CR)
