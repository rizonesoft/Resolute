#Include <APIConstants.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $Ext = '.au3'

ConsoleWrite('(' & $Ext & ')' & @CR)
ConsoleWrite('--------------------' & @CR)
ConsoleWrite('Type: ' & _WinAPI_AssocQueryString($Ext, $ASSOCSTR_FRIENDLYDOCNAME) & @CR)
ConsoleWrite('Command: ' & _WinAPI_AssocQueryString($Ext, $ASSOCSTR_COMMAND) & @CR)
ConsoleWrite('Executable: ' & _WinAPI_AssocQueryString($Ext, $ASSOCSTR_EXECUTABLE) & @CR)
ConsoleWrite('Icon: ' & _WinAPI_AssocQueryString($Ext, $ASSOCSTR_DEFAULTICON) & @CR)
