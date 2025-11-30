#Include <APIConstants.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Dim $OnOff[2] = ['OFF', 'ON']

ConsoleWrite('NumLock: ' & $OnOff[BitAND(_WinAPI_GetKeyState($VK_NUMLOCK), 1)] & @CR)
Sleep(1500)
Send('{NUMLOCK toggle}')
ConsoleWrite('NumLock: ' & $OnOff[BitAND(_WinAPI_GetKeyState($VK_NUMLOCK), 1)] & @CR)
Sleep(1500)
Send('{NUMLOCK toggle}')
ConsoleWrite('NumLock: ' & $OnOff[BitAND(_WinAPI_GetKeyState($VK_NUMLOCK), 1)] & @CR)
