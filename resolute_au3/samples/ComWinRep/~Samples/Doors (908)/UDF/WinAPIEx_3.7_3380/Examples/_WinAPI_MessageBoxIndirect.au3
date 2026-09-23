#Include <APIConstants.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global Const $Title = 'Message'
Global Const $Text = 'This is a simple message box with a custom icon.'

Global $tMBP, $Result

$tMBP = DllStructCreate($tagMSGBOXPARAMS & 'wchar[' & (StringLen($Title) + 1) & '];wchar[' & (StringLen($Text) + 1) & ']')
DllStructSetData($tMBP, 'Size', DllStructGetPtr($tMBP, 11) - DllStructGetPtr($tMBP))
DllStructSetData($tMBP, 'hOwner', 0)
DllStructSetData($tMBP, 'hInstance', _WinAPI_GetModuleHandle(@SystemDir & '\shell32.dll'))
DllStructSetData($tMBP, 'Text', DllStructGetPtr($tMBP, 12))
DllStructSetData($tMBP, 'Caption', DllStructGetPtr($tMBP, 11))
DllStructSetData($tMBP, 'Style', BitOR($MB_OKCANCEL, $MB_USERICON))
DllStructSetData($tMBP, 'Icon', 239)
DllStructSetData($tMBP, 'ContextHelpId', 0)
DllStructSetData($tMBP, 'MsgBoxCallback', 0)
DllStructSetData($tMBP, 'LanguageId', 0)
DllStructSetData($tMBP, 11, $Title)
DllStructSetData($tMBP, 12, $Text)

$Result = _WinAPI_MessageBoxIndirect($tMBP)

ConsoleWrite('Return: ' & $Result & @CR)
