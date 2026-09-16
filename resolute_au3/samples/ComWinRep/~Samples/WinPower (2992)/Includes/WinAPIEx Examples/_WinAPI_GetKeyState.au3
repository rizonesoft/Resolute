#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global Const $VK_NUMLOCK = 0x90

Dim $OnOff[2] = ['OFF', 'ON']

ConsoleWrite('NumLock: ' & $OnOff[BitAND(_WinAPI_GetKeyState($VK_NUMLOCK), 1)] & @CR)
Sleep(1500)
Send('{NUMLOCK toggle}')
ConsoleWrite('NumLock: ' & $OnOff[BitAND(_WinAPI_GetKeyState($VK_NUMLOCK), 1)] & @CR)
Sleep(1500)
Send('{NUMLOCK toggle}')
ConsoleWrite('NumLock: ' & $OnOff[BitAND(_WinAPI_GetKeyState($VK_NUMLOCK), 1)] & @CR)
