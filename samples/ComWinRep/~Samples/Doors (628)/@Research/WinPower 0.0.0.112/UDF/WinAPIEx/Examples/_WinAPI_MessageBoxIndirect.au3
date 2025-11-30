#Include <Constants.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global Const $MB_USERICON = 0x80

Global Const $sTitle = 'Message'
Global Const $sText = 'This is a simple message box with a custom icon.'

Global $tMBP = DllStructCreate($tagMSGBOXPARAMS)
Global $tTitle = DllStructCreate('wchar[' & (StringLen($sTitle) + 1) & ']')
Global $tText = DllStructCreate('wchar[' & (StringLen($sText) + 1) & ']')
Global $Result

DllStructSetData($tTitle, 1, $sTitle)
DllStructSetData($tText, 1, $sText)
DllStructSetData($tMBP, 'Size', DllStructGetSize($tMBP))
DllStructSetData($tMBP, 'hOwner', 0)
DllStructSetData($tMBP, 'hInstance', _WinAPI_GetModuleHandle(@SystemDir & '\shell32.dll'))
DllStructSetData($tMBP, 'Text', DllStructGetPtr($tText))
DllStructSetData($tMBP, 'Caption', DllStructGetPtr($tTitle))
DllStructSetData($tMBP, 'Style', BitOR($MB_OKCANCEL, $MB_USERICON))
DllStructSetData($tMBP, 'Icon', 239)
DllStructSetData($tMBP, 'ContextHelpId', 0)
DllStructSetData($tMBP, 'MsgBoxCallback', 0)
DllStructSetData($tMBP, 'LanguageId', 0)

$Result = _WinAPI_MessageBoxIndirect($tMBP)

ConsoleWrite('Return: ' & $Result & @CR)
