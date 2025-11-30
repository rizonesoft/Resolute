#Include <APIConstants.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

ConsoleWrite('Virtual-key code: 0x' & Hex($VK_A) & @CR)
ConsoleWrite('Scan code: 0x' & Hex(_WinAPI_MapVirtualKey($VK_A, $MAPVK_VK_TO_VSC)) & @CR)
