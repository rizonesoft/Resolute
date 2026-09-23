#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global Const $sPath1 = 'Test.txt'
Global Const $sPath2 = 'Test\Test.txt'
Global Const $sPath3 = 'C:\Test\Test.txt'

ConsoleWrite($sPath1 & ' => ' & _WinAPI_GetFullPathName($sPath1) & @CR)
ConsoleWrite($sPath2 & ' => ' & _WinAPI_GetFullPathName($sPath2) & @CR)
ConsoleWrite($sPath3 & ' => ' & _WinAPI_GetFullPathName($sPath3) & @CR)
