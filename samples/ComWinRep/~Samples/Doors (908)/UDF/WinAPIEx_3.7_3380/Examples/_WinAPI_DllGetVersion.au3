#Include <APIConstants.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global Const $sDll = @SystemDir & '\comctl32.dll'

Global $Data, $Text

$Data = _WinAPI_DllGetVersion($sDll)
Switch @error
	Case 0
		Switch $Data[3]
			Case $DLLVER_PLATFORM_WINDOWS
				$Text = 'Windows 95/98'
			Case $DLLVER_PLATFORM_NT
				$Text = 'NT-based'
			Case Else
				$Text = 'Unknown platform'
		EndSwitch
		ConsoleWrite($sDll & ' => ' & $Data[0] & '.' & $Data[1] & '.' & $Data[2] & ' (' & $Text & ')' & @CR)
	Case 3
		ConsoleWrite('DllGetVersion not implemented in ' & $sDll & '.' & @CR)
	Case Else
		ConsoleWrite('Unable to retrieve version information.' & @CR)
EndSwitch
